defmodule BucklerBot.UserServer do
  @moduledoc """
  Отвечает за работу одного пользователя вК
  """
  use GenServer
  require Logger
  import BucklerBot.Gettext

  alias BucklerBot.Repo

  @lifetime Application.get_env(:buckler_bot, :lifetime)

  defp via_tuple(chat_id, user_id) do
    {:via, Registry, {BucklerBot.Registry, {:user_server, chat_id, user_id}}}
  end

  ### Initializing
  def start_link(chat_id, user_id, conn) do
    GenServer.start_link(__MODULE__, [chat_id, user_id, conn], name: via_tuple(chat_id, user_id))
  end

  def stop(chat_id, user_id) do
    GenServer.cast(via_tuple(chat_id, user_id), :stop)
  end

  def init([chat_id, user_id, conn]) do
    Process.send(self(), :init, [])
    {:ok, %{chat_id: chat_id, user_id: user_id, conn: conn}}
  end

  def handle_info(:init, state = %{
    chat_id: chat_id,
    user_id: user_id,
    conn: %Agala.Conn{
      request: %{
        "message" => %{
          "message_id" => message_id
        },
        "from" => %{
          "first_name" => first_name
        }
      }
    } = conn
  }) do
    case Repo.get(chat_id, user_id) do
      {:ok, user} -> :ok
      {:error, :not_found} ->
        Repo.new_user(conn)
        conn
        |> Agala.Provider.Telegram.Helpers.send_message(
          chat_id,
          gettext("Hello, %{first_name}! Please, responce here with captcha, or all your messages will be baned!", first_name: first_name),
          reply_to_message_id: message_id
        )
        |> Agala.response_with
    end
    {:noreply, state}
  end

  def handle_info(:stop, state = %{chat_id: chat_id, user_id: user_id}) do
    Repo.delete_user(chat_id, user_id)
  end
end
