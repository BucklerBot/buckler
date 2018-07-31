defmodule BucklerBot.NameValidator do
  @pipeline [
    {BucklerBot.NameValidator.ValidateMaxLength, 50}
  ]

  def validate(user) do
    Enum.reduce(@pipeline, {:ok, __MODULE__}, fn
      {module, args}, {:ok, _} = acc ->
        case module.validate(user, args) do
          {:ok, _} -> acc
          {:error, validator} -> {:error, validator}
        end

      _, {:error, _} = acc ->
        acc
    end)
  end
end
