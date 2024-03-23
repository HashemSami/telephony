defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid}

  setup do
    %{postpaid: %Postpaid{spent: 0}}
  end

  test "Make a Call", %{postpaid: postpaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(postpaid, time_spent, date)

    expect =
      {%Postpaid{spent: 2.08}, %Call{time_spent: 2, date: date}}

    assert expect == result
  end

  test "Print Invoice" do
    date = ~D[2024-03-17]
    last_month = ~D[2024-02-15]

    postpaid = %Postpaid{spent: 90.0 * 1.04}

    calls = [
      %Call{
        time_spent: 10,
        date: date
      },
      %Call{
        time_spent: 50,
        date: last_month
      },
      %Call{
        time_spent: 30,
        date: last_month
      }
    ]

    year = 2024
    month = 2

    result =
      Subscriber.print_invoice(postpaid, calls, year, month)

    expect = %{
      value_spent: (80 * 1.04) |> Float.round(2),
      calls: [
        %{
          time_spent: 50,
          value_spent: (50 * 1.04) |> Float.round(2),
          date: last_month
        },
        %{
          time_spent: 30,
          value_spent: (30 * 1.04) |> Float.round(2),
          date: last_month
        }
      ]
    }

    assert expect == result
  end

  # test "Make a Call with no credits", %{subscriber_without_credits: subscriber} do
  #   time_spent = 2
  #   date = NaiveDateTime.utc_now()
  #   result = Prepaid.make_call(subscriber, time_spent, date)

  #   expect = {:error, "Subscriber does not have enough credits"}

  #   assert expect == result
  # end

  # test "Make a recharge", %{subscriber: subscriber} do
  #   value = 500
  #   date = NaiveDateTime.utc_now()
  #   result = Prepaid.make_recharge(subscriber, value, date)

  #   expect = %Subscriber{
  #     full_name: "Hashe",
  #     phone_number: "123",
  #     subscriber_type: %Prepaid{
  #       credits: 510,
  #       recharges: [
  #         %Recharge{value: 500, date: date}
  #       ]
  #     },
  #     calls: []
  #   }

  #   assert expect == result
  # end
end
