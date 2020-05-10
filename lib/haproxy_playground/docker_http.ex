defmodule DockerHttp do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://127.0.0.1:2376"
  plug Tesla.Middleware.JSON

  def create_container() do
    {:ok, %{body: %{"Id" => container_id}}} = post("/containers/create", %{
      Image: "haproxy",
      HostConfig: %{
        Binds: [
          "/tmp/haproxy:/usr/local/etc/haproxy:ro"
        ]
      }
    })
    post("/containers/#{container_id}/start", %{})
    get("/containers/#{container_id}/logs?stdout=true&stderr=true")
    |> decode_log
    # get("/users/" <> login <> "/repos")
  end

  def create_image() do
    post("/images/create?fromImage=haproxy:latest", %{})
    # get("/users/" <> login <> "/repos")
  end

  def decode_log({:ok, %{body: <<type, 0, 0, 0, size1, size2, size3, size4>> <> payload}}) do
    length = :binary.decode_unsigned(<<size1, size2, size3, size4>>)
    {decode_type(type), payload}
  end

  def decode_type(0), do: :stdin
  def decode_type(1), do: :stdout
  def decode_type(2), do: :stderr
end
