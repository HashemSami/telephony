defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Subscriber}

  defstruct credits: 0, recharges: []
  @price_per_minute 1.45
  def make_call(
        subscriber,
        time_spent,
        date
      ) do
    credit_spent = @price_per_minute * time_spent

    subscriber
    |> update_credits(credit_spent)
    |> update_calls(
      time_spent,
      date
    )
  end

  def update_credits(
        %Subscriber{subscriber_type: %__MODULE__{} = subscriber_type} = subscriber,
        credit_spent
      ) do
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  def update_calls(%Subscriber{calls: calls} = subscriber, time_spent, date) do
    new_calls = calls ++ [Call.new(time_spent, date)]
    %{subscriber | calls: new_calls}
  end
end
