defmodule Sonic do
  use Application
  require Logger

  @moduledoc """
  etcd library and bindings for Elixir.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Sonic.Client, [
        [
          pool_name: Application.get_env(:sonic, :client)[:pool_name],
          host: Application.get_env(:sonic, :host),
          port: Application.get_env(:sonic, :client)[:port]
        ]
      ]),
      :hackney_pool.child_spec(Application.get_env(:sonic, :client)[:pool_name], [
        timeout: Application.get_env(:sonic, :client)[:timeout],
        max_connections: Application.get_env(:sonic, :client)[:max_connections]
      ])
    ]

    # Set options and start supervisor.
    opts = [strategy: :one_for_one, name: Sonic.Supervisor]
    sup = Supervisor.start_link(children, opts)

    sup
  end

end
