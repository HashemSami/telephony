defmodule Telephony.ServerTest do
  use ExUnit.Case

  alias Telephony.Server

  setup do
    {:ok, pid} = Server.start_link(:test)

    payload = %{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    %{pid: pid, process_name: :test, payload: payload}
  end

  test "Check telephony subscriber state", %{pid: pid} do
    assert [] == :sys.get_state(pid)
  end

  test "Create a subscriber", %{process_name: process_name, payload: payload} do
    result = GenServer.call(process_name, {:create_subscriber, payload})

    expect = [
      %Telephony.Core.Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Telephony.Core.Prepaid{
          credits: 0,
          recharges: []
        },
        calls: []
      }
    ]

    assert expect == result
  end

  test "Error massage when trying to create a subscriber", %{
    pid: pid,
    process_name: process_name,
    payload: payload
  } do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    GenServer.call(process_name, {:create_subscriber, payload})
    # second call will generate error
    result = GenServer.call(process_name, {:create_subscriber, payload})

    expect = {:error, "Subscriber `123`, already exist"}

    assert expect == result
  end

  test "Search for subscriber", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})

    result = GenServer.call(process_name, {:search_subscriber, "123"})

    assert payload.phone_number == result.phone_number
  end

  test "Make a recharge", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    value = 100

    GenServer.call(process_name, {:create_subscriber, payload})

    result = GenServer.cast(process_name, {:make_recharge, {"123", value, date}})

    assert result == :ok

    state = :sys.get_state(process_name)

    expect = [
      %Telephony.Core.Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Telephony.Core.Prepaid{
          credits: 100,
          recharges: [
            %Telephony.Core.Recharge{
              value: 100,
              date: date
            }
          ]
        },
        calls: []
      }
    ]

    assert expect == state
  end

  test "Make a call", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    time_spent = 3
    value = 100

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.cast(process_name, {:make_recharge, {"123", value, date}})

    result = GenServer.call(process_name, {:make_call, {"123", time_spent, date}})

    expect = %Telephony.Core.Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Telephony.Core.Prepaid{
        credits: 95.65,
        recharges: [
          %Telephony.Core.Recharge{
            value: 100,
            date: date
          }
        ]
      },
      calls: [
        %Telephony.Core.Call{
          time_spent: 3,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "Make an error call", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    time_spent = 3

    GenServer.call(process_name, {:create_subscriber, payload})

    result = GenServer.call(process_name, {:make_call, {"123", time_spent, date}})

    expect = {:error, "Subscriber does not have enough credits"}

    assert expect == result
  end

  test "Print Invoice", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    time_spent = 3
    value = 100

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.cast(process_name, {:make_recharge, {"123", value, date}})
    GenServer.call(process_name, {:make_call, {"123", time_spent, date}})

    result = GenServer.call(process_name, {:print_invoice, {"123", date.year, date.month}})

    expect = %{
      credits: 95.65,
      recharges: [%{date: date, credits: 100}],
      calls: [
        %{
          date: date,
          time_spent: 3,
          value_spent: 4.35
        }
      ]
    }

    assert expect == result
  end

  test "Print Invoices", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    time_spent = 3
    value = 100

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.cast(process_name, {:make_recharge, {"123", value, date}})
    GenServer.call(process_name, {:make_call, {"123", time_spent, date}})

    result = GenServer.call(process_name, {:print_invoices, {date.year, date.month}})

    expect = %{
      credits: 95.65,
      recharges: [%{date: date, credits: 100}],
      calls: [
        %{
          date: date,
          time_spent: 3,
          value_spent: 4.35
        }
      ]
    }

    assert expect == Enum.at(result, 0).invoice
  end
end
