defmodule BucklerBot.NameValidator.ValidateMaxLength do
  def init(max_length), do: max_length

  def call(conn = %Agala.Conn{assigns: %{user: %{first_name: first_name}}}, max_length) do
    case String.length(first_name) > max_length do
      true ->
        conn
        |> Agala.Conn.assign(:name_validator_error, :max_length)
      _ -> conn
    end
  end

  def call(conn, _) do
    raise ArgumentError, "ValidateMaxLength is called with wrong arguments"
  end
end
