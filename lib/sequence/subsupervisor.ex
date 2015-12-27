defmodule Sequence.SubSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    child_processes = [worker(Sequence.Server, [])]
    supervise child_processes, strategy: :one_for_one
  end
end
