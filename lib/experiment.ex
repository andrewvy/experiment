defmodule Experiment do
  alias Experiment.Lab

  @moduledoc """
  This module injects the lab config for working with labs. This also has the
  methods for creating and running lab experiments.

  ## Example

      defmodule Controller do

        def main do
          Experiment.new("Test my new experimental function")
          |> Experiment.experiment(&experimental_function/0)
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
    Adds a new experiment to the lab.
  """
  @spec experiment(Experiment.Lab.t, fun) :: Experiment.Lab.t
  def experiment(%Lab{} = lab, func) when is_function(func) do
    %Lab{ lab | experiments: lab.experiments ++ [func] }
  end

  @doc """
    Adds a new experiment to the lab with the given name.
  """
  @spec experiment(Experiment.Lab.t, String.t, fun) :: Experiment.Lab.t
  def experiment(%Lab{} = lab, func_name, func) when is_function(func) do
    %Lab{ lab | experiments: lab.experiments ++ [func] }
  end

  @doc """
    Adds the control in which all experiments will be compared to.

    The result of this function will be the result of the experiment.
  """
  @spec control(Experiment.Lab.t, fun) :: Experiment.Lab.t
  def control(%Lab{} = lab, func) when is_function(func) do
    %Lab{ lab | control: func }
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
  def perform_experiment(%Lab{ control: nil } = lab), do: raise ArgumentError, message: "Control not found in Experiment"
  def perform_experiment(%Lab{} = lab) do
    # We should return the control result as soon as possible
    # - Should perform experiments async in their own task
    # - Once control + experiments are all done, compare the outputs.

    results = Enum.map(lab.experiments, &(&1.()))
    control = lab.control.()
    compare_func = lab.compare
    adapter = lab.adapter

    results
    |> Enum.reject(&(compare_func.(control, &1)))
    |> Enum.each(&(adapter.record(lab, control, &1)))

    control
  end

  @doc """
    Default comparator. Does `==` against the control and candidate.
  """
  @spec compare_tests(any, any) :: boolean
  def compare_tests(control, candidate), do: control == candidate
end
