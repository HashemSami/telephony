defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.Core
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert result == expect
  end

  test "Create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Moh",
      phone_number: "1234",
      subscriber_type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Moh",
        phone_number: "1234",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert result == expect
  end

  test "Display Error when subscriber already exists", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `123`, already exist"} == result
  end

  test "Display Error when subscriber type does not exist", %{
    payload: payload
  } do
    payload = Map.put(payload, :subscriber_type, :asdfasdf)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are excepted"} == result
  end
end
