defmodule Sonic.Client do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([pool_name: _, host: _, port: _] = args) do
    {:ok, args}
  end
  def init(_) do
    {:stop, "Sonic.Client invalid init arguments"}
  end

  #
  # Client API functions.
  #

  def version() do
    method = :get
    path = "/version"
    GenServer.call(__MODULE__, {method, path})
  end

  def get(key) do
    method = :get
    path = "/v2/keys/#{key}"
    GenServer.call(__MODULE__, {method, path})
  end

  def put(key, value) do
    method = :put
    path = "/v2/keys/#{key}"
    body = {:form, [value: value]}
    GenServer.call(__MODULE__, {method, path, body})
  end

  # def put(key, value) do
    
  # end

  # def delete(key) do
    
  # end

  #
  # Internal.
  #

  def handle_call({:get, path}, _from, [pool_name: pool_name, host: host, port: port] = state) do
    result = request(pool_name, :get, "http://#{host}:#{port}#{path}", [], <<>>)
    {:reply, result, state}
  end
  def handle_call({:put, path, body}, _from, [pool_name: pool_name, host: host, port: port] = state) do
    result = request(pool_name, :put, "http://#{host}:#{port}#{path}", [], body)
    {:reply, result, state}
  end

  defp request(pool_name, method, url, headers, body) do
    options = [
      {:pool, pool_name},
      {:with_body, true}
    ]

    :hackney.request(method, url, headers, body, options)
  end

end
