defmodule Telephony.Core do
  alias __MODULE__.Subscriber

  # @subscriber_types [:prepaid, :postpaid]
  @subscriber_types ~w/prepaid postpaid/a

  def create_subscriber(subscribers, %{subscriber_type: subscriber_type} = payload)
      when subscriber_type in @subscriber_types do
    case Enum.find(subscribers, &(&1.phone_number == payload.phone_number)) do
      nil ->
        subscriber = Subscriber.new(payload)

        subscribers ++ [subscriber]

      subscriber ->
        {:error, "Subscriber `#{subscriber.phone_number}`, already exist"}
    end
  end

  def create_subscriber(_subscribers, _payload) do
    {:error, "Only 'prepaid' or 'postpaid' are excepted"}
  end

  def search_subscriber(subscribers, phone_number) do
    case Enum.find(subscribers, &(&1.phone_number == phone_number)) do
      nil ->
        {:error, "subscriber doesn't exists"}

      subscriber ->
        subscriber
    end
  end

  def make_recharge(subscribers, phone_number, value, date) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_recharge(subscriber, value, date)
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def make_call(subscribers, phone_number, time_spent, date) do
    perform = fn subscriber ->
      subscribers = List.delete(subscribers, subscriber)
      result = Subscriber.make_call(subscriber, time_spent, date)
      update_subscriber(subscribers, result)
    end

    execute_operation(subscribers, phone_number, perform)
  end

  def print_invoice(subscribers, phone_number, year, month) do
    perform = &Subscriber.print_invoice(&1, year, month)

    execute_operation(subscribers, phone_number, perform)
  end

  defp execute_operation(subscribers, phone_number, fun) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        fun.(subscriber)
      end
    end)
  end

  def print_all_invoices(subscribers, year, month) do
    subscribers
    |> Enum.map(&Subscriber.print_invoice(&1, year, month))
  end

  defp update_subscriber(subscribers, {:error, _message} = err) do
    {subscribers, err}
  end

  defp update_subscriber(subscribers, subscriber) do
    {subscribers ++ [subscriber], subscriber}
  end
end
