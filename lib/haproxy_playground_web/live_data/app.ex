
defmodule HaproxyPlaygroundWeb.LiveData.App do
  use LiveData,
    endpoint: HaproxyPlaygroundWeb.Endpoint,
    types_output_path: "../../../assets/js"

  @type state :: %{who: String.t()}

  def init(params) do
    IO.inspect(params)
    {:ok, %{who: "live_data"}}
  end

  @spec handle_call({:hello, %{who: String.t()}}, {pid(), any}, state) ::
          {:reply, :ok, state}
  def handle_call({:hello, %{who: who}}, _from, state) do
    {:reply, :ok, %{who: who}}
  end

  # parse error
  @spec serialize(state) :: %{who: String.t()}
  def serialize(state), do: state
end
