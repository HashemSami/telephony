defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid, Prepaid, Recharge, Subscriber}

  setup do
    postpaid = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Postpaid{spent: 0},
      calls: []
    }

    prepaid = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []},
      calls: []
    }

    %{postpaid: postpaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    # when
    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    # then
    assert expect == result
  end

  test "create a postpaid subscriber" do
    # Given
    payload = %{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: :postpaid
    }

    # when
    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Postpaid{spent: 0},
      calls: []
    }

    # then
    assert expect == result
  end

  test "make a postpaid call", %{postpaid: postpaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    # when
    result = Subscriber.make_call(postpaid, time_spent, date)

    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Postpaid{spent: 2.08},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    # then
    assert expect == result
  end

  test "make a prepaid call", %{prepaid: prepaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(prepaid, time_spent, date)

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

    # then
    assert expect == result
  end

  test "make a prepaid recharge", %{prepaid: prepaid} do
    value = 500
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_recharge(prepaid, value, date)

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

    # then
    assert expect == result
  end

  test "make other type recharge", %{postpaid: postpaid} do
    value = 500
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_recharge(postpaid, value, date)

    expect = {:error, "Only prepaid can make a recharge"}

    # then
    assert expect == result
  end
end
