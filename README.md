Sonic
=====

[![hex.pm version](https://img.shields.io/hexpm/v/sonic.svg?style=flat)](https://hex.pm/packages/sonic)

[etcd](https://coreos.com/etcd/) library and bindings for Elixir.

__Note:__ This library is still experimental, some aspects of the `etcd` API are not yet implemented.

### Installation

The latest version is `0.1.0` and requires Elixir `~> 1.2`. New releases may change this minimum compatible version depending on breaking language changes. The [changelog](https://github.com/heroiclabs/sonic/blob/master/CHANGELOG.md) lists every available release and its corresponding language version requirement.

Releases are published through [hex.pm](https://hex.pm/packages/sonic). Add as a dependency in your `mix.exs` file:
```elixir
defp deps do
  [ { :sonic, "~> 0.1" } ]
end
```

Also ensure it's listed in the `mix.exs` list of applications to start:
```elixir
def application do
  [
    applications: [:sonic]
  ]
end
```

### Configuration

Below is the complete default configuration. All parameters can be changed.

```elixir
config :sonic,
  host: "localhost",
  client: [
    port: 2379,
    pool_name: :sonic_client_hackney_pool,
    timeout: 60_000,
    max_connections: 8
  ]
```

### Usage

```elixir
iex> Sonic.Client.kv_put("test_key", "test_value")
{:ok, 201,
 [{"Content-Type", "application/json"},
  {"X-Etcd-Cluster-Id", "7e27652122e8b2ae"}, {"X-Etcd-Index", "4"},
  {"X-Raft-Index", "313681"}, {"X-Raft-Term", "2"},
  {"Date", "Mon, 14 Mar 2016 10:33:44 GMT"}, {"Content-Length", "90"}],
 "{\"action\":\"set\",\"node\":{\"key\":\"/test_key\",\"value\":\"test_value\",\"modifiedIndex\":4,\"createdIndex\":4}}\n"}

iex> Sonic.Client.kv_get("test_key")
{:ok, 200,
 [{"Content-Type", "application/json"},
  {"X-Etcd-Cluster-Id", "7e27652122e8b2ae"}, {"X-Etcd-Index", "5"},
  {"X-Raft-Index", "313719"}, {"X-Raft-Term", "2"},
  {"Date", "Mon, 14 Mar 2016 10:34:02 GMT"}, {"Content-Length", "90"}],
 "{\"action\":\"get\",\"node\":{\"key\":\"/test_key\",\"value\":\"test_value\",\"modifiedIndex\":5,\"createdIndex\":5}}\n"}
```

`Sonic.Client` functions accept options such as `ttl` for `Sonic.Client.kv_put` and more. See the `Sonic.Client` module documentation and function reference for details.

### License

```none
Copyright 2016 Heroic Labs

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
