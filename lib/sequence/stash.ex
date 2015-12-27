defmodule Sequence.Stash do
  use GenServer

  require Logger
  ######
  # External API

  def start_link(current_number) do
    Logger.info "Stash start_link #{inspect current_number}"
    {:ok, _pid} = GenServer.start_link(__MODULE__, current_number)
  end

  def save_value(pid, value) do
    GenServer.cast pid, {:save_value, value}
  end

  def get_value(pid) do
    GenServer.call pid, :get_value
  end

  #####
  # GenServer implementation

  def init(state) do
    Logger.info "Stash.init"
    {:ok, state}
  end
  def handle_call(:get_value, _from, current_value) do
    {:reply, current_value, current_value}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:save_value, value}, _current_value) do
    {:noreply, value}
  end



  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end
end
