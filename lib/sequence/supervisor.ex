defmodule Sequence.Supervisor do
  use Supervisor
  require Logger

  def start_link(initial_number) do
    Supervisor.start_link(__MODULE__, [initial_number])
  end

  def start_stash(sup, initial_number) do
    Logger.info "starting stash in #{inspect sup} with #{inspect initial_number}"
    {:ok, stash} = Supervisor.start_child(sup, worker(Sequence.Stash, [initial_number]))
    Logger.info "stash worked"
    {:ok, stash}
  end

  def start_worker_sup(sup, stash) do
    Supervisor.start_child(sup, supervisor(Sequence.WorkerSupervisor, [stash]))
  end

  def init([initial_number]) do
    Logger.info "initial number #{inspect initial_number}"
    child_processes = [worker(Sequence.Server, [self(), initial_number])]
    supervise child_processes, strategy: :one_for_all
  end
end
