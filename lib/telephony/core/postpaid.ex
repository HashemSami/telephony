defmodule Telephony.Core.Postpaid do
  defstruct spent: 0
  @price_per_minute 1.04

  alias Telephony.Core.{Call, Invoice, Subscriber}

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_spending(time_spent)
    |> add_new_call(
      time_spent,
      date
    )
  end

  defp update_spending(
         %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
         time_spent
       ) do
    credit_spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + credit_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(%Subscriber{calls: calls} = subscriber, time_spent, date) do
    new_calls = calls ++ [Call.new(time_spent, date)]
    %{subscriber | calls: new_calls}
  end

  defimpl Invoice, for: Telephony.Core.Postpaid do
    @price_per_minute 1.04
    def print(_, calls, year, month) do
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
  end
end
