defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.Core
  alias Telephony.Core.{Prepaid, Postpaid, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    subscribers_mix = [
      %Subscriber{
        full_name: "Hashe",
        phone_number: "123",
        subscriber_type: %Postpaid{spent: 0}
      },
      %Subscriber{
        full_name: "Hashe",
        phone_number: "1234",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }
    ]

    payload = %{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, subscribers_mix: subscribers_mix, payload: payload}
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

  test "Search subscriber", %{
    subscribers: subscribers
  } do
    expect = %Subscriber{
      full_name: "Hashe",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    result = Core.search_subscriber(subscribers, "123")

    assert expect == result
  end

  test "Search subscriber throws error when subscriber doesn't exists", %{
    subscribers: subscribers
  } do
    result = Core.search_subscriber(subscribers, "1234")
    expect = {:error, "subscriber doesn't exists"}

    assert expect == result
  end

  test "Make a recharge", %{
    subscribers: subscribers
  } do
    date = Date.utc_today()

    result = Core.make_recharge(subscribers, "123", 2, date)

    expect =
      {[
         %Telephony.Core.Subscriber{
           full_name: "Hashe",
           phone_number: "123",
           subscriber_type: %Telephony.Core.Prepaid{
             credits: 2,
             recharges: [
               %Telephony.Core.Recharge{
                 value: 2,
                 date: date
               }
             ]
           },
           calls: []
         }
       ],
       %Telephony.Core.Subscriber{
         full_name: "Hashe",
         phone_number: "123",
         subscriber_type: %Telephony.Core.Prepaid{
           credits: 2,
           recharges: [
             %Telephony.Core.Recharge{
               value: 2,
               date: date
             }
           ]
         },
         calls: []
       }}

    assert expect == result
  end

  test "Make a recharge postpaid", %{
    subscribers_mix: subscribers_mix
  } do
    date = Date.utc_today()

    result = Core.make_recharge(subscribers_mix, "123", 2, date)

    expect =
      {[
         %Telephony.Core.Subscriber{
           full_name: "Hashe",
           phone_number: "1234",
           subscriber_type: %Telephony.Core.Prepaid{
             credits: 10,
             recharges: []
           },
           calls: []
         }
       ], {:error, "Only prepaid can make a recharge"}}

    assert expect == result
  end

  test "Make a call", %{
    subscribers_mix: subscribers_mix
  } do
    date = Date.utc_today()

    result = Core.make_call(subscribers_mix, "123", 2, date)

    expect =
      {[
         %Telephony.Core.Subscriber{
           full_name: "Hashe",
           phone_number: "1234",
           subscriber_type: %Telephony.Core.Prepaid{
             credits: 10,
             recharges: []
           },
           calls: []
         },
         %Telephony.Core.Subscriber{
           full_name: "Hashe",
           phone_number: "123",
           subscriber_type: %Telephony.Core.Postpaid{
             spent: 2.08
           },
           calls: [
             %Telephony.Core.Call{
               time_spent: 2,
               date: date
             }
           ]
         }
       ],
       %Telephony.Core.Subscriber{
         full_name: "Hashe",
         phone_number: "123",
         subscriber_type: %Telephony.Core.Postpaid{
           spent: 2.08
         },
         calls: [
           %Telephony.Core.Call{
             time_spent: 2,
             date: date
           }
         ]
       }}

    assert expect == result
  end

  test "Print Invoice", %{
    subscribers_mix: subscribers_mix
  } do
    date = Date.utc_today()

    result = Core.print_invoice(subscribers_mix, "123", date.year, date.month)

    expect =
      %{
        subscriber: %Subscriber{
          full_name: "Hashe",
          phone_number: "123",
          subscriber_type: %Postpaid{spent: 0},
          calls: []
        },
        invoice: %{calls: [], value_spent: 0}
      }

    assert expect == result
  end

  test "Print All Invoices", %{
    subscribers_mix: subscribers_mix
  } do
    date = Date.utc_today()

    result = Core.print_all_invoices(subscribers_mix, date.year, date.month)

    expect =
      [
        %{
          subscriber: %Telephony.Core.Subscriber{
            full_name: "Hashe",
            phone_number: "123",
            subscriber_type: %Telephony.Core.Postpaid{
              spent: 0
            },
            calls: []
          },
          invoice: %{calls: [], value_spent: 0}
        },
        %{
          subscriber: %Telephony.Core.Subscriber{
            full_name: "Hashe",
            phone_number: "1234",
            subscriber_type: %Telephony.Core.Prepaid{
              credits: 10,
              recharges: []
            },
            calls: []
          },
          invoice: %{credits: 10, recharges: [], calls: []}
        }
      ]

    assert expect == result
  end
end
