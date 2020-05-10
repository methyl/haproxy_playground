defmodule HaproxyPlaygroundWeb.LiveData.App do
  use LiveData,
    endpoint: HaproxyPlaygroundWeb.Endpoint,
    types_output_path: "../../../assets/js"

  @type state :: %{
          haproxy: String.t(),
          servers: list(String.t())
        }

  def init(params) do
    docker = Docker.init()

    server = create_server("server_1", docker)
    haproxy_id = Ecto.UUID.generate()

    {:ok, haproxy_pid} =
      GenServer.start(
        HaproxyPlaygroundWeb.LiveData.Haproxy,
        ["Haproxy:#{haproxy_id}", %{docker: docker}],
        name: :"#{HaproxyPlaygroundWeb.LiveData.Haproxy}_Haproxy:#{haproxy_id}"
      )

    send(haproxy_pid, {:__live_data_monitor__, self()})

    {:ok,
     %{
       haproxy: haproxy_id,
       servers: [server],
       docker: docker,
       request_error: nil
     }}
  end

  # @spec handle_call({:hello, %{who: String.t()}}, {pid(), any}, state) ::
  #         {:reply, :ok, state}
  def handle_call({:request, %{attrs: attrs}}, _from, state) do
    # server = create_server("server_#{length(state.servers)  + 1}", state.docker)
    state =
      case Task.async(fn -> Docker.request(state.docker, attrs) end) |> Task.yield(4000) do
        {:ok, {:ok, _}} ->
          state |> Map.put(:request_error, nil)

        {:ok, {:error,
         [
           exit_status: 256,
           stderr: stderr
         ]}} ->
          state |> Map.put(:request_error, stderr)
        nil ->
          state |> Map.put(:request_error, "timeout")
      end

    {:reply, :ok, state}
  end

  def handle_call({:add_server, %{}}, _from, state) do
    server = create_server("server_#{length(state.servers) + 1}", state.docker)

    {:reply, :ok, state |> Map.put(:servers, [server | state.servers])}
  end

  # parse error when passing :: state
  @spec serialize(state) :: %{who: String.t()}
  def serialize(state), do: state

  defp create_server(name, docker) do
    server_id = Ecto.UUID.generate()

    {:ok, server_pid} =
      GenServer.start(
        HaproxyPlaygroundWeb.LiveData.Server,
        ["Server:#{server_id}", %{docker: docker, name: name}],
        name: :"#{HaproxyPlaygroundWeb.LiveData.Server}_Server:#{server_id}"
      )

    send(server_pid, {:__live_data_monitor__, self()})
    %{id: server_id, name: name}
  end
end
