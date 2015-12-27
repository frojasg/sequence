defmodule Sequence.Worker do
  use GenServer
  @vsn "1"

  require Logger

  defmodule State, do: defstruct current_number: 0, stash_pid: nil, delta: 1


  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def next_number do
    GenServer.call __MODULE__, :next_number
  end

  def increment_number(delta) do
    GenServer.cast __MODULE__, {:increment_number, delta}
  end

  def get_stash do
    GenServer.call __MODULE__, :get_stash
  end

  #####
  # GenServer implementation
  def init(stash_pid) do
    Logger.info "Worker.init"
    Logger.info "stash pid #{inspect stash_pid} alive: #{Process.alive? stash_pid}"
    current_number = Sequence.Stash.get_value stash_pid
    {:ok, %State{current_number: current_number, stash_pid: stash_pid}}
  end

  def handle_call(:next_number, _from, state) do
    {
      :reply,
      state.current_number,
      %{state | current_number: state.current_number + state.delta }
    }
  end

  def handle_call(:get_stash, _from, state) do
    {:reply, state.stash_pid, state}
  end
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end


  def handle_cast({:increment_number, delta}, state) do
    {:noreply,
      %{state | current_number: state.current_number + delta, delta: delta}
    }
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def terminate(_reason, {current_number, stash_pid}) do
    Sequence.Stash.save_value stash_pid, current_number
  end

  def format_status(_reason, [ _pdict, state ]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
  end

  def code_change("0", old_state = { current_number, stash_pid}, _extra) do
    new_state = %State{current_number: current_number, stash_pid: stash_pid, delta: 1}

    Logger.info "Changing code from 0 to 1"
    Logger.info inspect(old_state)
    Logger.info inspect(new_state)
    {:ok, new_state}
  end
end
