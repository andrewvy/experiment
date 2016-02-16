defmodule Experiment do
  alias Experiment.Lab

  @moduledoc """
  This module injects the lab config for working with labs. This also has the
  methods for creating and running lab experiments.

  ## Example

      defmodule Controller do
        use Experiment

        def main do
          lab("Test my new experimental function")
          |> experiment(&experimental_function/0)
          |> control(&control_function/0)
          |> perform_experiment
        end

        def control_function do
          {:ok, :foo}
        end

        def experimental_function do
          {:ok, :bar}
        end
      end
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Experiment.Lab
      require Logger

      {otp_app, adapter, config} = Experiment.Utils.parse_config(__MODULE__, opts)

      @lab_otp_app otp_app
      @lab_adapter adapter
      @lab_config  config

      def lab(name) do
        %Lab{ name: name }
      end

      def experiment(%Lab{} = lab, func) when is_function(func) do
        %Lab{ lab | experiments: lab.experiments ++ [func] }
      end

      def experiment(%Lab{} = lab, func_name, func) when is_function(func) do
        %Lab{ lab | experiments: lab.experiments ++ [func] }
      end

      def control(%Lab{} = lab, func) when is_function(func) do
        %Lab{ lab | control: func }
      end

      def compare(%Lab{} = lab, func) when is_function(func) do
        %Lab{ lab | compare: func }
      end

      def perform_experiment(%Lab{ control: nil } = lab), do: raise ArgumentError, message: "Control not found in Experiment"
      def perform_experiment(%Lab{} = lab) do
        # We should return the control result as soon as possible
        # - Should perform experiments async in their own task
        # - Once control + experiments are all done, compare the outputs.

        results = Enum.map(lab.experiments, &(&1.()))
        control = lab.control.()
        compare_func = lab.compare || &Experiment.compare_tests/2

        results
        |> Enum.reject(&(compare_func.(control, &1)))
        |> Enum.each(&(@lab_adapter.record(lab, control, &1)))

        control
      end

    end
  end

  @doc """
    Returns a new lab experiment with the given name.
  """
  @callback lab(String.t) :: Experiment.Lab.t

  @doc """
    Adds a new experiment to the lab.
  """
  @callback experiment(Experiment.Lab.t, fun) :: Experiment.Lab.t

  @doc """
    Adds a new experiment to the lab with the given name.
  """
  @callback experiment(Experiment.Lab.t, String.t, fun) :: Experiment.Lab.t

  @doc """
    Adds the control in which all experiments will be compared to.

    The result of this function will be the result of the experiment.
  """
  @callback control(Experiment.Lab.t, fun) :: Experiment.Lab.t

  @doc """
    Runs the lab experiment, returning the result of the control.
  """
  @callback perform_experiment(Experiment.Lab.t) :: any

  @doc """
  """
  @spec compare_tests(any, any) :: boolean
  def compare_tests(control, candidate), do: control == candidate
end
