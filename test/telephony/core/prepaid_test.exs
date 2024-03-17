defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Invoice, Recharge, Subscriber}

  setup do
    subscriber =
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }

    subscriber_without_credits = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_without_credits: subscriber_without_credits}
  end

  test "Make a Call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "Make a Call with no credits", %{subscriber_without_credits: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = {:error, "Subscriber does not have enough credits"}

    assert expect == result
  end

  test "Make a recharge", %{subscriber: subscriber} do
    value = 500
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_recharge(subscriber, value, date)

    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{
        credits: 510,
        recharges: [
          %Recharge{value: 500, date: date}
        ]
      },
      calls: []
    }

    assert expect == result
  end

  test "Print invoice" do
    date = ~D[2024-03-17]
    last_month = ~D[2024-02-15]

    subscriber = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{value: 100, date: date},
          %Recharge{value: 100, date: last_month},
          %Recharge{value: 100, date: last_month}
        ]
      },
      calls: [
        %Call{
          time_spent: 2,
          date: date
        },
        %Call{
          time_spent: 10,
          date: last_month
        },
        %Call{
          time_spent: 20,
          date: last_month
        }
      ]
    }

    year = 2024
    month = 2

    result = Invoice.print(subscriber.subscriber_type, subscriber.calls, year, month)

    expect = %{
      calls: [
        %{
          time_spent: 10,
          # 10 * 1.45 (time spent * min price)
          value_spent: 14.5,
          date: last_month
        },
        %{
          time_spent: 20,
          value_spent: 29.0,
          date: last_month
        }
      ],
      recharges: [
        %{credits: 100, date: last_month},
        %{credits: 100, date: last_month}
      ],
      credits: 253.6
    }

    assert result == expect
  end
end
