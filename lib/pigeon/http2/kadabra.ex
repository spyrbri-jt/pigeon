defmodule Pigeon.Http2.Client.Kadabra do
  @moduledoc false

  @behaviour Pigeon.Http2.Client

  require Logger

  def start do
    Application.ensure_all_started(:kadabra)
  end

  def connect(uri, scheme, opts) do
    host = "#{scheme}://#{uri}"
    Kadabra.open(host, ssl: opts)
  end

  def send_request(pid, headers, data) do
    Logger.info "[Kadabra] Sending request #{inspect(pid)}, body: #{inspect(data)}"
    Kadabra.request(pid, headers: headers, body: data)
  end

  @doc ~S"""
  send_ping/1 implementation

  ## Examples

      iex> {:ok, pid} = Kadabra.open("https://www.google.com")
      iex> Pigeon.Http2.Client.Kadabra.send_ping(pid)
      :ok
  """
  def send_ping(pid) do
    Logger.info "[Kadabra] Sending ping #{inspect(pid)}"
    Kadabra.ping(pid)
  end

  def handle_end_stream({:end_stream, stream}, _state) do
    %{id: id, status: status, headers: headers, body: body} = stream

    pigeon_stream = %Pigeon.Http2.Stream{
      id: id,
      status: status,
      headers: headers,
      body: body
    }

    {:ok, pigeon_stream}
  end

  def handle_end_stream(msg, _state) do
    Logger.info "[Kadabra] handle end stream #{inspect(msg)}"
    msg
  end
end
