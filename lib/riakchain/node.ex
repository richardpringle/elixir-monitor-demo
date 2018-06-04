defmodule Riakchain.Node do
  use GenServer

  def start_link(_state) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  ### Client API
  def write(command) do
    GenServer.call(__MODULE__, command)
  end

  ### GenServer Server API
  def init(_) do
    port = Port.open({:spawn, "node node.js"}, [:binary, :exit_status])
    {:ok, port}
  end

  def handle_call(command, _from, port) do
    IO.inspect(port)
    result = Port.command(port, command)
    {:reply, result, port}
  end

  def handle_info({_port, {:exit_status, _status}}, _) do
    port = Port.open({:spawn, "node node.js"}, [:binary, :exit_status])
    {:noreply, port}
  end

  def handle_info(message, port) do
    IO.inspect(message)
    {:noreply, port}
  end
end
