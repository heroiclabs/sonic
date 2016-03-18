defmodule Sonic.Client do

  @moduledoc """
  Client API functions.
  """

  @doc """
  Get a Key-Value pair and corresponding headers.

  ## Examples

  ```elixir
  > Sonic.Client.kv_get("test_key")
  {:ok, 200,
   [{"Content-Type", "application/json"},
    {"X-Etcd-Cluster-Id", "7e27652122e8b2ae"}, {"X-Etcd-Index", "5"},
    {"X-Raft-Index", "313719"}, {"X-Raft-Term", "2"},
    {"Date", "Mon, 14 Mar 2016 10:34:02 GMT"}, {"Content-Length", "90"}],
   "{\"action\":\"get\",\"node\":{\"key\":\"/test_key\",\"value\":\"test_value\",\"modifiedIndex\":5,\"createdIndex\":5}}\n"}
  ```

  """
  def kv_get(key, opts \\ [])
  def kv_get(key, opts) when is_binary(key) do
    kv_get([key], opts)
  end
  def kv_get(key, _opts) when is_list(key) do
    method = :get
    path = "/v2/keys/" <> Enum.map_join(key, "/", &URI.encode/1)
    headers = []
    body = <<>>
    request(method, path, headers, body)
  end

  @doc """
  Set the value of a Key-Value pair.

  Allowed options:
  * `ttl` - The key TTL in seconds.

  ## Examples

  ```elixir
  > Sonic.Client.kv_put("test_key", "test_value", ttl: 15)
  {:ok, 201,
   [{"Content-Type", "application/json"},
    {"X-Etcd-Cluster-Id", "7e27652122e8b2ae"}, {"X-Etcd-Index", "25792"},
    {"X-Raft-Index", "814223"}, {"X-Raft-Term", "3"},
    {"Date", "Fri, 18 Mar 2016 15:20:44 GMT"}, {"Content-Length", "162"}],
   %{"action" => "set",
     "node" => %{"createdIndex" => 25792,
       "expiration" => "2016-03-18T15:20:59.30566372Z", "key" => "/test_key",
       "modifiedIndex" => 25792, "ttl" => 15, "value" => "test_value"}}}
  ```

  """
  def kv_put(key, value, opts \\ [])
  def kv_put(key, value, opts) when is_binary(key) do
    kv_put([key], value, opts)
  end
  def kv_put(key, value, opts) when is_list(key) do
    method = :put
    path = "/v2/keys/" <> Enum.map_join(key, "/", &URI.encode/1)
    headers = []
    body = [value: value]
    if is_integer(opts[:ttl]) do
      body = Keyword.put(body, :ttl, opts[:ttl])
    end
    body = {:form, body}
    request(method, path, headers, body)
  end

  @doc """
  Perform a directory listing.

  Allowed options:
  * `recursive` - `true`/`false` indicates whether to recurse into any child directories. Default `false`.

  ## Examples

  ```elixir
  > Sonic.Client.dir_list("test_dir")                                   
  {:ok, 200,
   [{"Content-Type", "application/json"},
    {"X-Etcd-Cluster-Id", "7e27652122e8b2ae"}, {"X-Etcd-Index", "25794"},
    {"X-Raft-Index", "814446"}, {"X-Raft-Term", "3"},
    {"Date", "Fri, 18 Mar 2016 15:22:35 GMT"}, {"Content-Length", "256"}],
   %{"action" => "get",
     "node" => %{"createdIndex" => 25794, "dir" => true, "key" => "/test_dir",
       "modifiedIndex" => 25794,
       "nodes" => [%{"createdIndex" => 25794,
          "expiration" => "2016-03-18T15:22:48.953852633Z",
          "key" => "/test_dir/test_key", "modifiedIndex" => 25794, "ttl" => 14,
          "value" => "test_value"}]}}}
  ```

  """
  def dir_list(key, opts \\ [])
  def dir_list(key, opts) when is_binary(key) do
    dir_list([key], opts)
  end
  def dir_list(key, opts) when is_list(key) do
    method = :get
    path = "/v2/keys/" <> Enum.map_join(key, "/", &URI.encode/1)
    if opts[:recursive] == true do
      path = path <> "/?recursive=true"
    end
    headers = []
    body = <<>>
    request(method, path, headers, body)
  end

  #
  # Internal.
  #

  defp request(method, path, headers, body) do
    # Load config.
    sonic = Application.get_all_env(:sonic)
    host = sonic[:host]
    client = sonic[:client]
    port = client[:port]
    pool_name = client[:pool_name]

    # Set up request.
    url = "http://#{host}:#{port}#{path}"
    options = [
      {:pool, pool_name},
      {:with_body, true}
    ]

    case :hackney.request(method, url, headers, body, options) do
      {:ok, status, headers, body} ->
        case Poison.Parser.parse(body) do
          {:ok, body} ->
            {:ok, status, headers, body}
          {:error, _reason} = error ->
            error
        end
      {:error, _reason} = error ->
        error
    end
  end

end
