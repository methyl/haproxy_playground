defmodule HaproxyPlaygroundWeb.LiveData.Server do
  use LiveData,
    endpoint: HaproxyPlaygroundWeb.Endpoint,
    types_output_path: "../../../assets/js"

  @type state :: %{
          haproxy: String.t(),
          servers: list(String.t())
        }

  def init(%{docker: docker, name: name}) do
    {:ok, pid, _} = Docker.start_server(docker, name)

    {:ok,
     %{
       docker: docker,
       server_pid: pid,
       logs: []
     }}
  end

  def handle_info({:stdout, _, msg}, state) do
    lines =
      String.split(msg, "\n")
      |> Enum.filter(fn
        "::ffff:" <> _ -> true
        _ -> false
      end)

    {:noreply,
     state
     |> Map.put(
       :logs,
       state.logs ++ lines
     )}
  end

  # def handle_info({:stderr, _, msg}, state) do
  #   {:noreply, state |> Map.put(:logs, state.logs ++ String.split(msg, "\n"))}
  # end

  @spec serialize(state) :: %{config: String.t()}
  def serialize(state) do
    %{
      logs: state.logs
    }
  end

  # defp start_
end
