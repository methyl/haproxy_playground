defmodule HaproxyPlaygroundWeb.LiveData.Socket do
  use Phoenix.Socket

  channel("App:*", HaproxyPlaygroundWeb.LiveData.App.Channel)
  channel("Haproxy:*", HaproxyPlaygroundWeb.LiveData.Haproxy.Channel)
  channel("Server:*", HaproxyPlaygroundWeb.LiveData.Server.Channel)

  transport(:websocket, Phoenix.Transports.WebSocket)

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
