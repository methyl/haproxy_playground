defmodule HaproxyPlayground.Repo do
  use Ecto.Repo,
    otp_app: :haproxy_playground,
    adapter: Ecto.Adapters.Postgres
end
