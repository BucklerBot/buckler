defmodule BucklerBot.NameValidatorTest do
  use ExUnit.Case

  describe "Name Validator" do
    test "is valid Chain" do
      assert %Agala.Conn{} = BucklerBot.NameValidator.call(%Agala.Conn{}, [])
    end
  end
end
