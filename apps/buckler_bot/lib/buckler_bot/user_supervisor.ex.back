defmodule BucklerBot.UserSupervisor do
  @moduledoc """
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end
  def start_user_server(chat_id, user_id, conn) do
    Supervisor.start_child(BucklerBot.UserSupervisor, [chat_id, user_id, conn])
  end
  def stop_user_server(chat_id, user_id) do
    BucklerBot.UserServer.stop(chat_id, user_id)
  end
  def init(_) do
    children = [
      worker(BucklerBot.UserServer, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
