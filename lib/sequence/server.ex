defmodule Sequence.Server do
  use GenServer
  @vsn "1"

  require Logger

  defmodule State, do: defstruct current_number: 0, delta: 1


  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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
  def init(_) do
    current_number = Sequence.Stash.get_value
    {:ok, %State{current_number: current_number}}
  end

  def handle_call(:next_number, _from, state) do
    {
      :reply,
      state.current_number,
      %{state | current_number: state.current_number + state.delta }
    }
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

  def terminate(_reason, state) do
    Sequence.Stash.save_value state.current_number
  end

  def format_status(_reason, [ _pdict, state ]) do
    [data: [{'State', "My current state is '#{inspect state}', and I'm happy"}]]
  end

  def code_change("0", old_state = { current_number, stash_pid}, _extra) do
    new_state = %State{current_number: current_number, delta: 1}

    Logger.info "Changing code from 0 to 1"
    Logger.info inspect(old_state)
    Logger.info inspect(new_state)
    {:ok, new_state}
  end
end
