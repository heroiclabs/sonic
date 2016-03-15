defmodule Sonic.Client do

  #
  # Client API functions.
  #

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

  def dir_list(key, opts \\ [])
  def dir_list(key, opts) when is_binary(key) do
    dir_list([key], opts)
  end
  def dir_list(key, opts) when is_list(key) do
    method = :get
    path = "/v2/keys/" <> Enum.map_join(key, "/", &URI.encode/1)
    if opts[:recursive] == true do
      path = path <> "&recursive=true"
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
