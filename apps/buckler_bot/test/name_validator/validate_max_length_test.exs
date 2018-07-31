defmodule BucklerBot.NameValidator.ValidateMaxLengthTest do
  use ExUnit.Case

  describe "Max Length validator" do
    setup do
      {:ok, %{conn: %Agala.Conn{assigns: %{user: %{first_name: "TestFirstName"}}}}}
    end

    test "validate success for normal names", %{conn: conn} do
      assert nil == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 50)[:assigns][:name_validator_error]
      assert nil == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 100)[:assigns][:name_validator_error]
      assert nil == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 1000)[:assigns][:name_validator_error]
    end

    test "validate fail for bad names", %{conn: conn} do
      assert :max_length == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 3)[:assigns][:name_validator_error]
      assert :max_length == BucklerBot.NameValidator.ValidateMaxLength.call(conn, -1000)[:assigns][:name_validator_error]
      assert :max_length == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 0)[:assigns][:name_validator_error]
    end

    test "validate ok if name length matches the max length", %{conn: conn} do
      assert nil == BucklerBot.NameValidator.ValidateMaxLength.call(conn, 13)[:assigns][:name_validator_error]
    end
  end
end
