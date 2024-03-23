defmodule Telephony do
  @server :telephony

  # client calls

  def create_subscriber(payload) do
    GenServer.call(@server, {:create_subscriber, payload})
  end

  def search_subscriber(phone_number) do
    GenServer.call(@server, {:search_subscriber, phone_number})
  end

  def make_recharge(phone_number, value, date) do
    GenServer.cast(@server, {:make_recharge, {phone_number, value, date}})
  end

  def make_call(phone_number, time_spent, date) do
    GenServer.call(@server, {:make_call, {phone_number, time_spent, date}})
  end

  def print_invoice(phone_number, year, month) do
    GenServer.call(@server, {:print_invoice, {phone_number, year, month}})
  end

  def print_invoices(year, month) do
    GenServer.call(@server, {:print_invoices, {year, month}})
  end
end
