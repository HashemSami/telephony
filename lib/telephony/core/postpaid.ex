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
    def print(%{spent: spent}, calls, year, month) do
      calls_data =
        calls
        |> Enum.filter(&(&1.date.month == month && &1.date.year == year))
        |> Enum.map(
          &%{
            time_spent: &1.time_spent,
            value_spent: &1.time_spent * @price_per_minute,
            date: &1.date
          }
        )

      %{
        value_spent: Enum.reduce(calls_data, 0, &(&1.value_spent + &2)),
        calls: calls
      }
    end
  end
end
