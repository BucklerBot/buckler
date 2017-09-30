defmodule DB.Connections do
  import Ecto.Query
  alias DB.{Customer, Chat, Repo}
  require Logger

  defp chatuser_query(chat_id, user_id) do
    from c in Customer,
    where: c.chat_id == ^chat_id,
    where: c.user_id == ^user_id,
    select: c
  end

  def get_chatuser(chat_id, user_id), do: Repo.one(chatuser_query(chat_id, user_id))

  def get_or_create_chat(chat_id) do
    case Repo.get(Chat, chat_id) do
      nil -> create_chat(%{id: chat_id})
      chat -> {:ok, chat}
    end
  end

  def create_chat(params) do
    %Chat{}
    |> Chat.changeset(params)
    |> Repo.insert
  end

  def create_chatuser(chat, user_id, name, answer, connected_message_id) do
    chat
    |> Ecto.build_assoc(:customers, %{
      name: name,
      connected_message_id: connected_message_id,
      user_id: user_id,
      answer: answer,
      lang: chat.lang,
      attempts: chat.attempts
    })
    |> Repo.insert
  end

  def connect_user(chat_id, user_id, name, answer, connected_message_id) do
    with {:ok, chat} <- get_or_create_chat(chat_id) do
      create_chatuser(chat, user_id, name, answer, connected_message_id)
    else
      _ ->
        case Repo.transaction(fn ->
          with {:ok, chat} <- create_chat(%{chat_id: chat_id}) do
            create_chatuser(chat, user_id, name, answer, connected_message_id)
          end
        end) do
          {:ok, created} -> created
          err -> err
        end
    end
  end

  def decrease_attempts(chat_id, user_id, answer) do
    with customer when not is_nil(customer) <- get_chatuser(chat_id, user_id) do
      Repo.update(Customer.changeset(customer, %{answer: answer, attempts: customer.attempts-1}))
    end
  end

  def delete_chatuser(chat_id, user_id) do
    with customer when not is_nil(customer) <- get_chatuser(chat_id, user_id) do
      Repo.delete(customer)
    else
      _ -> Logger.error("Delete user not found")
    end
  end

  def user_unauthorized?(chat_id, user_id) do
    case get_chatuser(chat_id, user_id) do
      nil -> false
      customer -> {true, customer}
    end
  end

  def update_welcome_message(chat_id, user_id, message_id) do
    with customer when not is_nil(customer) <- get_chatuser(chat_id, user_id) do
      Repo.update(Customer.changeset(customer, %{welcome_message_id: message_id}))
    end
  end
end
