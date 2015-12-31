defmodule Sequence.Server do
  use GenServer
  require Logger

  defmodule State, do: defstruct stash_pid: nil, worker_sup_pid: nil, initial_number: 0, refs: []

  def start_link(sup, initial_number) do
    GenServer.start_link(__MODULE__, [sup, initial_number])
  end

  def init([sup, initial_number]) do
    send self(), :start_servers
    {:ok, %State{initial_number: initial_number}}
  end

  def handle_call(:get_value, _from, state) do
    current_value = Sequence.Stash.get_value(state.stash_pid)
    Logger.info "get_value value: #{inspect current_value} #{inspect state}"
    {:reply, current_value, state}
  end

  def handle_cast({:save_value, value}, state) do
    Sequence.Stash.save_value(state.stash_pid, value)
    {:noreply, state}
  end

  def handle_info(:start_servers, state) do
    Logger.info "about start servers #{inspect self()} #{inspect state}"
    {:ok, stash} = Sequence.Supervisor.start_stash(state.initial_number)
    {:ok, worker_sup} = Sequence.Supervisor.start_worker_sup(self())
    stash_ref = Process.monitor(stash)
    worker_sup_ref = Process.monitor(worker_sup)
    {:noreply,
      %{state | stash_pid: stash, worker_sup_pid: worker_sup, refs: [stash_ref, worker_sup_ref]}
    }
  end

  def handle_info({:DOWN, ref, :process, pid, reason}, state) do
    stash_pid = state.stash_pid
    worker_sup_pid = state.worker_sup_pid
    case {pid, ref in state.refs} do
      {^stash_pid, true} ->
        {:ok, stash} = Sequence.Supervisor.start_stash(state.initial_number)
        stash_ref = Process.monitor(stash)
        state =  %{state | stash_pid: stash, refs: [stash_ref | state.refs] -- [ref]}
      {^worker_sup_pid, true} ->
        {:ok, worker_sup} = Sequence.Supervisor.start_worker_sup(self())
        worker_sup_ref = Process.monitor(worker_sup)
        state =  %{state | worker_sup_pid: worker_sup, refs: [worker_sup_ref | state.refs] -- [ref]}
      _ -> true
    end
    {:noreply, state}
  end
end
