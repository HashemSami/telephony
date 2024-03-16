defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

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
end
