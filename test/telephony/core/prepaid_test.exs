defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Subscriber}

  setup do
    subscriber =
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }

    %{subscriber: subscriber}
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
end
