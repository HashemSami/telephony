defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Invoice, Recharge, Subscriber}

  defstruct credits: 0, recharges: []
  @price_per_minute 1.45
  def make_call(
        %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
        time_spent,
        date
      ) do
    if is_subscriber_has_credits(subscriber_type, time_spent) do
      subscriber
      |> update_credits(time_spent)
      |> add_new_call(
        time_spent,
        date
      )
    else
      {:error, "Subscriber does not have enough credits"}
    end
  end

  defp is_subscriber_has_credits(subscriber_type, time_spent) do
    subscriber_type.credits > @price_per_minute * time_spent
  end

  defp update_credits(
         %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
         time_spent
       ) do
    credit_spent = @price_per_minute * time_spent

    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}

    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(%Subscriber{calls: calls} = subscriber, time_spent, date) do
    new_calls = calls ++ [Call.new(time_spent, date)]
    %{subscriber | calls: new_calls}
  end

  def make_recharge(subscriber, value, date) do
    subscriber
    |> charge_credit(value)
    |> add_recharge_data(value, date)
  end

  defp charge_credit(
         %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
         value
       ) do
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits + value}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_recharge_data(
         %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
         value,
         date
       ) do
    new_recharges = subscriber_type.recharges ++ [Recharge.new(value, date)]
    subscriber_type = %{subscriber_type | recharges: new_recharges}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defimpl Invoice, for: Telephony.Core.Prepaid do
    @price_per_minute 1.45

    def print(subscriber_type, calls, year, month) do
      %{
        recharges:
          subscriber_type.recharges
          |> Enum.filter(&(&1.date.month == month && &1.date.year == year))
          |> Enum.map(&%{date: &1.date, credits: &1.value}),
        calls:
          calls
          |> Enum.filter(&(&1.date.month == month && &1.date.year == year))
          |> Enum.map(
            &%{
              date: &1.date,
              time_spent: &1.time_spent,
              value_spent: &1.time_spent * @price_per_minute
            }
          )
      }
    end
  end
end
