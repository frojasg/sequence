defmodule Sequence.Supervisor do
  use Supervisor
  def start_link(initial_number) do
    Supervisor.start_link(__MODULE__, [initial_number], name: __MODULE__)
  end

  def start_stash(initial_number) do
    Supervisor.start_child(__MODULE__, worker(Sequence.Stash, [initial_number], restart: :temporary))
  end

  def start_worker_sup(stash) do
    Supervisor.start_child(__MODULE__, supervisor(Sequence.WorkerSupervisor, [stash], restart: :temporary))
  end

  def init([initial_number]) do
    child_processes = [worker(Sequence.Server, [self(), initial_number])]
    supervise child_processes, strategy: :one_for_all
  end
end
