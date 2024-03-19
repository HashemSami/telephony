defprotocol Subscriber do
  def print_invoice(subscriber_type, calls, year, month)
  def make_call(subscriber_type, time_spent, date)
  def make_recharge(subscriber_type, value, date)
end

defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil,
            phone_number: nil,
            subscriber_type: :prepaid,
            calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def new(payload) do
    struct(__MODULE__, payload)
  end

  def make_call(
        %__MODULE__{subscriber_type: %Postpaid{} = _subscriber_type} = postpaid,
        time_spent,
        date
      ) do
    Subscriber.make_call(postpaid, time_spent, date)
  end

  def make_call(
        %__MODULE__{subscriber_type: %Prepaid{} = _subscriber_type} = postpaid,
        time_spent,
        date
      ) do
    Subscriber.make_call(postpaid, time_spent, date)
  end

  def make_recharge(
        %__MODULE__{subscriber_type: %Prepaid{} = _subscriber_type} = prepaid,
        value,
        date
      ) do
    Subscriber.make_recharge(prepaid, value, date)
  end

  def make_recharge(
        _postpaid,
        _value,
        _date
      ) do
    {:error, "Only prepaid can make a recharge"}
  end
end
