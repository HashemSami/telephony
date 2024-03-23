defmodule Telephony.Server do
  use GenServer

  alias Telephony.Core

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  # server calls
  def init(subscribers) do
    {:ok, subscribers}
  end

  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_subscriber(subscribers, payload) do
      {:error, _} = err ->
        {:reply, err, subscribers}

      subscribers ->
        {:reply, subscribers, subscribers}
    end
  end

  def handle_call({:search_subscriber, phone_number}, _from, subscribers) do
    case Core.search_subscriber(subscribers, phone_number) do
      {:error, _} = err ->
        {:reply, err, subscribers}

      subscriber ->
        {:reply, subscriber, subscribers}
    end
  end

  def handle_call({:make_call, {phone_number, time_spent, date}}, _from, subscribers) do
    case Core.make_call(subscribers, phone_number, time_spent, date) do
      {subscribers, {:error, _} = err} ->
        {:reply, err, subscribers}

      {subscribers, subscriber} ->
        {:reply, subscriber, subscribers}
    end
  end

  def handle_call({:print_invoice, {phone_number, year, month}}, _from, subscribers) do
    invoice = Core.print_invoice(subscribers, phone_number, year, month)

    {:reply, invoice.invoice, subscribers}
  end

  def handle_call({:print_invoices, {year, month}}, _from, subscribers) do
    invoice = Core.print_all_invoices(subscribers, year, month)

    {:reply, invoice, subscribers}
  end

  def handle_cast({:make_recharge, {phone_number, value, date}}, subscribers) do
    {subscribers, _err} = Core.make_recharge(subscribers, phone_number, value, date)
    {:noreply, subscribers}
  end
end
