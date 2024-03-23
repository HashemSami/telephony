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
        %__MODULE__{subscriber_type: subscriber_type} = subscriber,
        value,
        date
      ) do
    case Subscriber.make_call(subscriber_type, value, date) do
      {:error, message} ->
        {:error, message}

      {type, call} ->
        %{subscriber | subscriber_type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def make_recharge(
        %__MODULE__{subscriber_type: %Prepaid{} = subscriber_type} = subscriber,
        value,
        date
      ) do
    type = Subscriber.make_recharge(subscriber_type, value, date)
    %{subscriber | subscriber_type: type}
  end

  def make_recharge(
        _postpaid,
        _value,
        _date
      ) do
    {:error, "Only prepaid can make a recharge"}
  end

  def print_invoice(%__MODULE__{} = subscriber, year, month) do
    invoice = Subscriber.print_invoice(subscriber.subscriber_type, subscriber.calls, year, month)

    %{subscriber: subscriber, invoice: invoice}
  end
end
