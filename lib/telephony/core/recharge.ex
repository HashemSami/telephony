defmodule Telephony.Core.Recharge do
  defstruct value: nil, date: nil

  def new(value, date \\ NaiveDateTime.utc_now()),
    do: struct(__MODULE__, %{value: value, date: date})
end
