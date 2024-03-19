defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Recharge}

  defstruct credits: 0, recharges: []

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

    # ==============================================================
    # recharge functions

    def make_recharge(subscriber_type, value, date) do
      subscriber_type
      |> charge_credit(value)
      |> add_recharge_data(value, date)
    end

    defp charge_credit(
           subscriber_type,
           value
         ) do
      %{subscriber_type | credits: subscriber_type.credits + value}
    end

    defp add_recharge_data(
           subscriber_type,
           value,
           date
         ) do
      new_recharges = subscriber_type.recharges ++ [Recharge.new(value, date)]
      %{subscriber_type | recharges: new_recharges}
    end
  end
end
