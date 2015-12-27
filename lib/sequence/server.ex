defmodule Sequence.Server do
  use GenServer
  require Logger

  def start_link(sup, initial_number) do
    Logger.info "start_link Sequence.Supervisor #{inspect sup} #{inspect initial_number}"
    GenServer.start_link(__MODULE__, [sup, initial_number])
  end

  def init([sup, initial_number]) do
    Logger.info "init Sequence.Server #{inspect sup} #{initial_number}"
    # {:ok, stash} = Supervisor.start_child(sup, worker(Sequence.Stash, [initial_number]))
    {:ok, stash} = Sequence.Supervisor.start_stash(sup, initial_number)
    Logger.info "#stash pid {inspect stash}"
    {:ok, worker_sup} = Sequence.Supervisor.start_worker_sup(sup, stash)
    Logger.info "#stash pid {inspect worker_sup}"
    # Supervisor.start_child(sup, supervisor(Sequence.WorkerSupervisor, [stash]))
  end
end
