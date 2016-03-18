defmodule Sonic.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :sonic,
     version: @version,
     elixir: "~> 1.2",
     deps: deps,
     package: package,

     name: "Sonic",
     docs: [extras: ["README.md", "CHANGELOG.md"],
            main: "readme",
            source_ref: "v#{@version}"],
     source_url: "https://github.com/heroiclabs/sonic",
     description: description]
  end

  # Application configuration.
  def application do
    [
      mod: {Sonic, []},
      applications: [:poison, :hackney],
      env: [
        host: "localhost",
        client: [
          port: 2379,
          pool_name: :sonic_client_hackney_pool,
          timeout: 60_000,
          max_connections: 8
        ]
      ]
    ]
  end

  # List of dependencies.
  defp deps do
    [{:poison, "~> 2.1"},
     {:hackney, "~> 1.5"},

     # Docs
     {:ex_doc, "~> 0.11", only: :dev},
     {:earmark, "~> 0.2", only: :dev}]
  end

  # Description.
  defp description do
    """
    etcd library and bindings for Elixir.
    """
  end

  # Package info.
  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Andrei Mihu"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/heroiclabs/sonic"}]
  end

end
