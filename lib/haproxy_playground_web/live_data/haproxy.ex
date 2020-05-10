defmodule HaproxyPlaygroundWeb.LiveData.Haproxy do
  use LiveData,
    endpoint: HaproxyPlaygroundWeb.Endpoint,
    types_output_path: "../../../assets/js"

  @type state :: %{
    haproxy: String.t(),
    servers: list(String.t())
  }

  def init(%{docker: docker}) do
    {:ok, pid, _} = Docker.start_haproxy(docker)
      {:ok, %{
      docker: docker,
      haproxy_pid: pid,
      config_loading: false,
      logs: [],
      port: nil,
      }}
  end

  def handle_info(:config_updated, state) do
    {:noreply, state |> Map.put(:config_loading, :false)}
  end

  def handle_call({:update_config, %{new_config: new_config}}, _from, state) do
    pid = self()
    Task.async(fn ->
      Docker.reload_config(state.docker, new_config)
      send(pid, :config_updated)
    end)
    {:reply, :ok, state |> Map.put(:config_loading, true)}
  end

  def handle_info({:stdout, _, msg}, state) do
    {:noreply, state |> Map.put(:logs, state.logs ++ String.split(msg, "\n"))}
  end

  # parse error when passing :: state
  @spec serialize(state) :: %{config: String.t()}
  def serialize(state) do
    %{
      config: Docker.read_config(state.docker),
      logs: state.logs,
      port: state.port,
      config_loading: state.config_loading

    }
  end

  # defp start_
end
