defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Postpaid, Prepaid, Subscriber}

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

  test "create a post subscriber" do
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
      subscriber_type: %Postpaid{spent: 0}
    }

    # then
    assert expect == result
  end
end
