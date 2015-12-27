defmodule Sequence.Server do
  use GenServer

  def start_link(sup, initial_number) do
    GenServer.start_link(__MODULE__, [sup, initial_number])
  end

  def init([sup, initial_number]) do
    send self(), :start_servers
    {:ok, [sup, initial_number]}
  end

  def handle_info(:start_servers, state = [sup, initial_number]) do
    {:ok, stash} = Sequence.Supervisor.start_stash(initial_number)
    {:ok, worker_sup} = Sequence.Supervisor.start_worker_sup(stash)
    Process.monitor(stash)
    Process.monitor(worker_sup)
    {:noreply, [sup, initial_number]}
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    {:stop, :error, state}
  end
end
