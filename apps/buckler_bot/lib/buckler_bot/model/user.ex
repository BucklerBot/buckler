defmodule BucklerBot.Model.User do
  defstruct [
    :conn,
    :name,
    :message_id,
    :user_id,
    :chat_id,
    :answer,
    :message_to_delete
  ]
end
