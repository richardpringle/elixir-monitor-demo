defmodule Riakchain.Node do
  use GenServer

  def start_link(_state) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  ### Client API
  def write(command) do
    GenServer.call(__MODULE__, command)
  end

  def restart() do
    GenServer.call(__MODULE__, :restart)
  end

  ### GenServer Server API
  def init(_) do
    IO.puts("GenServer PID:")
    IO.inspect(self())

    port = Port.open({:spawn, "node node.js"}, [:binary, :exit_status])

    receive do
      {^port, {:data, "started\n"}} -> IO.puts("working")
    end
    IO.puts("still working")

    {:ok, port}
  end

  def handle_call(:restart, _from, port) do
    Port.close(port)
    {:reply, :ok, spawn_node_server()}
  end

  def handle_call(command, _from, port) do
    IO.inspect(port)
    result = Port.command(port, command)
    {:reply, result, port}
  end

  def handle_info({_from, {:data, command }}, port) do
    IO.puts("command:")
    IO.inspect(command)

    Port.command(port, "RUNNING")

    {:noreply, port}
  end

  def handle_info({_from, {:exit_status, _status}}, _state) do
    {:noreply, spawn_node_server()}
  end

  def handle_info(message, port) do
    IO.inspect(message)
    {:noreply, port}
  end

  ## Privates ##
  defp spawn_node_server() do
    Port.open({:spawn, "node node.js"}, [:binary, :exit_status])
  end
end
