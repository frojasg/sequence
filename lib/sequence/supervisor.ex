defmodule Sequence.Supervisor do
  use Supervisor

  def start_link(initial_number) do
    Supervisor.start_link(__MODULE__, [initial_number])
  end

  def init([initial_number]) do
    children = [
      worker(Sequence.Stash, [initial_number]),
      supervisor(Sequence.SubSupervisor, [])
    ]
    supervise children, strategy: :one_for_one
  end
end
