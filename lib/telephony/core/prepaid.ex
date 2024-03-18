defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Recharge}

  defstruct credits: 0, recharges: []

  def make_recharge(subscriber, value, date) do
    subscriber
    |> charge_credit(value)
    |> add_recharge_data(value, date)
  end

  defp charge_credit(
         %Telephony.Core.Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} =
           subscriber,
         value
       ) do
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits + value}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_recharge_data(
         %Telephony.Core.Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} =
           subscriber,
         value,
         date
       ) do
    new_recharges = subscriber_type.recharges ++ [Recharge.new(value, date)]
    subscriber_type = %{subscriber_type | recharges: new_recharges}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defimpl Subscriber, for: Telephony.Core.Prepaid do
    @price_per_minute 1.45

    def print_invoice(%{recharges: recharges, credits: credits}, calls, year, month) do
      %{
        recharges:
          recharges
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
          ),
        credits: credits
      }
    end

    def make_call(
          subscriber_type,
          time_spent,
          date
        ) do
      if is_subscriber_has_credits(subscriber_type, time_spent) do
        subscriber_type
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
           subscriber_type,
           time_spent
         ) do
      credit_spent = @price_per_minute * time_spent

      %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    end

    defp add_new_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end
  end
end
