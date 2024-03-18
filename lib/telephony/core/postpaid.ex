defmodule Telephony.Core.Postpaid do
  defstruct spent: 0

  alias Telephony.Core.{Call}

  defimpl Subscriber, for: Telephony.Core.Postpaid do
    @price_per_minute 1.04
    def print_invoice(_, calls, year, month) do
      calls_data =
        Enum.reduce(calls, [], fn current, acc ->
          if current.date.month == month && current.date.year == year do
            call =
              %{
                time_spent: current.time_spent,
                value_spent: (current.time_spent * @price_per_minute) |> Float.round(2),
                date: current.date
              }

            acc ++ [call]
          else
            acc
          end
        end)

      %{
        value_spent: Enum.reduce(calls_data, 0, &(&1.value_spent + &2)),
        calls: calls_data
      }
    end

    def make_call(subscriber_type, time_spent, date) do
      subscriber_type
      |> update_spending(time_spent)
      |> add_new_call(
        time_spent,
        date
      )
    end

    defp update_spending(
           subscriber_type,
           time_spent
         ) do
      credit_spent = @price_per_minute * time_spent
      %{subscriber_type | spent: subscriber_type.spent + credit_spent}
    end

    defp add_new_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end
  end
end
