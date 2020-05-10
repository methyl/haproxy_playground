defmodule Docker do
  def init() do
    id = Ecto.UUID.generate
    dir = "/tmp" |> Path.join(id)
    File.mkdir_p(dir)
    File.write!(Path.join(dir, "docker-compose.yml"), docker_compose_yml)
    # {:ok, file} = File.open(Path.join(dir, "haproxy.cfg"), [:read, :write, :binary])
    # IO.write(file, default_haproxy_cfg)
    File.write!(Path.join(dir, "haproxy.cfg"), default_haproxy_cfg |> prepare_cfg(id))
    Exexec.run("docker-compose --no-ansi up --no-start", cd: dir, sync: true, stderr: true, stdout: true)

    %{
      dir: dir,
      id: id,
    }
  end

  def haproxy_port(%{dir: dir}) do
    port = case Exexec.run("docker-compose port haproxy 44444", cd: dir, sync: true, stdout: true, stderr: true) do
      {:ok, [stdout: ["0.0.0.0:" <> port]]} -> port |> String.trim
      error -> IO.inspect(error)

    end
    port
  end

  def read_config(%{dir: dir, id: id}) do
    File.read!(Path.join(dir, "haproxy.cfg")) |> String.replace("#{id}_", "")
  end

  def start_haproxy(%{dir: dir, id: id}) do
    Exexec.run_link("docker-compose --no-ansi up haproxy", cd: dir, stdout: true, stderr: true, monitor: true)
  end

  # def start_server(%{dir: dir}, "server_1") do
  #   Exexec.run_link("docker-compose --log-level ERROR  up server_1.local", cd: dir, stdout: true, stderr: true)
  # end

  def start_server(%{dir: dir, id: id}, name) do
    Exexec.run_link("docker-compose run --rm --name #{id}_#{name}.local server", cd: dir, stdout: true, stderr: true)
  end

  def request(%{dir: dir}, args) do
    Exexec.run("docker-compose run --rm httpie #{args}", cd: dir, stdout: true, stderr: true, sync: true)
  end

  def reload_config(%{dir: dir, id: id}, new_config) do
    File.write!(Path.join(dir, "haproxy.cfg"), new_config |> prepare_cfg(id))
    Exexec.run("docker-compose kill -s HUP haproxy", cd: dir, sync: true)
  end

  def default_haproxy_cfg do
"""
global
    maxconn 50000
    log stdout format raw local0

defaults
    timeout connect 10s
    timeout client 30s
    timeout server 30s
    log global
    mode http
    option httplog
    maxconn 3000

frontend frontend_1
    bind 0.0.0.0:80
    default_backend backend_1

backend backend_1
    server server1 server_1.local:80
"""
  end

  def prepare_cfg(cfg, id) do
    cfg |> String.replace(~r/(server_\d+\.local)/, "#{id}_\\1")
  end

  def docker_compose_yml do
"""
version: "3.7"
services:
  haproxy:
    image: haproxy:latest
    volumes:
      - $PWD:/usr/local/etc/haproxy
    expose:
      - "80"

  server:
    image: mendhak/http-https-echo
    expose:
      - "80"

  httpie:
    image: alpine/httpie

  inspect:
    image: debian:buster
    command: ["/bin/bash"]

networks:
  default:
    driver: overlay
    internal: true
"""
  end
end
