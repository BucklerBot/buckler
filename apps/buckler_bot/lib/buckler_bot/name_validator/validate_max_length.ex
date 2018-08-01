defmodule BucklerBot.NameValidator.ValidateMaxLength do
  def validate(%{first_name: first_name}, max_length) do
    case String.length(first_name) > max_length do
      true -> {:error, __MODULE__}
      false -> {:ok, __MODULE__}
    end
  end
end
