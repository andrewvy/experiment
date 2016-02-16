defmodule Experiment do

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Experiment.Lab
      require Logger

      {otp_app, adapter, config} = Experiment.Utils.parse_config(__MODULE__, opts)

      @otp_app otp_app
      @adapter adapter
      @config  config

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

      def perform_experiment(%Lab{ control: nil } = lab), do: raise ArgumentError, message: "Control not found in Experiment"
      def perform_experiment(%Lab{} = lab) do
        # We should return the control result as soon as possible
        # - Should perform experiments async in their own task
        # - Once control + experiments are all done, compare the outputs.

        results = Enum.map(lab.experiments, &(&1.()))
        control = lab.control.()

        results
        |> Enum.reject(&(compare_tests(control, &1)))
        |> Enum.each(&(@adapter.record(lab, control, &1)))

        control
      end

      def compare_tests(control, candidate), do: control == candidate
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
  @callback control(Experimental.Lab.t, fun) :: Experiment.Lab.t

  @doc """
    Runs the lab experiment, returning the result of the control.
  """
  @callback perform_experiment(Experimental.Lab.t) :: any
end
