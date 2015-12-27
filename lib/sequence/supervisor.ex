defmodule Sequence.Supervisor do
  use Supervisor
  require Logger

  def start_link(initial_number) do
    Supervisor.start_link(__MODULE__, [initial_number], name: __MODULE__)
  end

  def start_stash(initial_number) do
    Logger.info "starting stash in #{inspect __MODULE__} with #{inspect initial_number} #{inspect worker(Sequence.Stash, [initial_number])}"
    {:ok, stash} = Supervisor.start_child(__MODULE__, worker(Sequence.Stash, [initial_number], restart: :temporary))
    Logger.info "stash worked"
    {:ok, stash}
  end

  def start_worker_sup(stash) do
    Supervisor.start_child(__MODULE__, supervisor(Sequence.WorkerSupervisor, [stash], restart: :temporary))
  end

  def init([initial_number]) do
    Logger.info "initial number #{inspect initial_number}"
    child_processes = [worker(Sequence.Server, [self(), initial_number])]
    supervise child_processes, strategy: :one_for_all
  end
end
