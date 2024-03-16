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
    Postpaid.make_call(postpaid, time_spent, date)
  end

  def make_call(
        %__MODULE__{subscriber_type: %Prepaid{} = _subscriber_type} = postpaid,
        time_spent,
        date
      ) do
    Prepaid.make_call(postpaid, time_spent, date)
  end

  def make_recharge(
        %__MODULE__{subscriber_type: %Prepaid{} = _subscriber_type} = postpaid,
        value,
        date
      ) do
    Prepaid.make_recharge(postpaid, value, date)
  end

  def make_recharge(
        _postpaid,
        _value,
        _date
      ) do
    {:error, "Only prepaid can make a recharge"}
  end
end
