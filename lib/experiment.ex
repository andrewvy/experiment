defmodule Experiment do
  alias Experiment.{ Lab, Test }

  @moduledoc """
  This module injects the lab config for working with labs. This also has the
  methods for creating and running lab experiments.

  ## Example

      defmodule Controller do

        def main do
          Experiment.new("Test my new experimental function")
          |> Experiment.test(&experimental_function/0)
          |> Experiment.control(&control_function/0)
          |> Experiment.perform_experiment
        end

        def control_function do
          {:ok, :foo}
        end

        def experimental_function do
          {:ok, :bar}
        end
      end
  """

  @doc """
    Returns a new lab experiment with the given name.
  """
  @spec new(String.t) :: Experiment.Lab.t
  def new(name) do
    adapter = Experiment.Utils.parse_config() || Experiment.Adapters.Default

    compare = &Experiment.compare_tests/2

    %Lab{ name: name, adapter: adapter, compare: compare }
  end

  @doc """
    Adds a new experimental test to the lab.
  """
  @spec test(Experiment.Lab.t, fun, list) :: Experiment.Lab.t
  def test(%Lab{} = lab, func, params \\ []) when is_function(func) do
    bound = Experiment.Utils.bind(func, params)

    test = %Test{ name: "Test #{lab.experiment_count + 1}", function: bound }

    %Lab{ lab | experiments: lab.experiments ++ [test], experiment_count: lab.experiment_count + 1 }
  end

  @doc """
    Adds a new experimental test to the lab with the given name.
  """
  @spec test(Experiment.Lab.t, String.t, fun, list) :: Experiment.Lab.t
  def test(%Lab{} = lab, func_name, func, params) when is_function(func) do
    bound = Experiment.Utils.bind(func, params)
    test = %Test{ name: func_name, function: bound }

    %Lab{ lab | experiments: lab.experiments ++ [test], experiment_count: lab.experiment_count + 1 }
  end

  @doc """
    Adds the control in which all experiments will be compared to.

    The result of this function will be the result of the experiment.
  """
  @spec control(Experiment.Lab.t, fun, list) :: Experiment.Lab.t
  def control(%Lab{} = lab, func, params \\ []) when is_function(func) do
    bound = Experiment.Utils.bind(func, params)
    test = %Test{ name: "Control", function: bound }

    %Lab{ lab | control: test }
  end

  @doc """
    Overrides the default compare function on the lab.
  """
  @spec compare(Experiment.Lab.t, fun) :: Experiment.Lab.t
  def compare(%Lab{} = lab, func) when is_function(func) do
    %Lab{ lab | compare: func }
  end

  @doc """
    Runs the lab experiment, returning the result of the control.
  """
  @spec perform_experiment(Experiment.Lab.t) :: any
  def perform_experiment(%Lab{ control: nil }), do: raise ArgumentError, message: "Control not found in Experiment"
  def perform_experiment(%Lab{} = lab) do
    # We should return the control result as soon as possible
    # - Should perform experiments async in their own task
    # - Once control + experiments are all done, compare the outputs.

    control = %Test{ lab.control | result: lab.control.function.() }
    lab = %{ lab | control: control }

    tests = lab.experiments
    |> Enum.map(fn(test) -> Task.async(fn -> %Test{ test | result: test.function.() } end) end)
    |> Task.yield_many(5000)
    |> Enum.map(fn({task, test}) ->
      test || Task.shutdown(task, :brutal_kill)
    end)

    for {:ok, test} <- tests do
      if !lab.compare.(control.result, test.result) do
        lab.adapter.record(lab, control, test)
      end
    end

    control.result
  end

  @doc """
    Default comparator. Does `==` against the control and candidate.
  """
  @spec compare_tests(any, any) :: boolean
  def compare_tests(control, candidate), do: control == candidate
end
