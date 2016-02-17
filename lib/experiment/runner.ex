defmodule Experiment.Runner do
  @moduledoc """
  This module is a simple GenServer, providing a way to perform experiments
  concurrently.
  """

  use GenServer

  alias Experiment.{ Lab, Test, Runner }

  def start(lab) do
    GenServer.start(__MODULE__, { lab, 0 })
  end

  def init({lab, 0} = state) do
    lab.experiments
    |> Enum.map(fn(test) ->
         Task.start(__MODULE__, :process, [self(), test])
       end)

    state
  end

  def process(proc, test) do
    require Logger

    send(proc, {:result, %Test{ test | result: test.function.()}})
  end

  def handle_info({:result, test}, { lab, count }) do
    if !lab.compare_func.() do
      lab.adapter.record.(lab, lab.control, test)
    end

    new_count = count + 1

    if new_count == lab.experiment_count do
      GenServer.stop(self())
    else
      { lab, new_count }
    end
  end
end
