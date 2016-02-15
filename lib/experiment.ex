defmodule Experiment do

  defmacro __using__(_) do
    quote do
      alias Experiment.Test
      require Logger

      def experiment(name) do
        %Test{ name: name }
      end

      def experimental(%Test{} = test, func) when is_function(func) do
        %Test{ test | experiments: test.experiments ++ [func] }
      end

      def experimental(%Test{} = test, func_name, func) when is_function(func) do
        %Test{ test | experiments: test.experiments ++ [func] }
      end

      def control(%Test{} = test, func) when is_function(func) do
        %Test{ test | control: func }
      end

      def perform_experiment(%Test{ control: nil } = test), do: raise ArgumentError, message: "Control not found in Experiment"
      def perform_experiment(%Test{} = test) do
        # We should return the control result as soon as possible
        # - Should perform experiments async in their own task
        # - Once control + experiments are all done, compare the outputs.

        results = Enum.map(test.experiments, &(&1.()))
        control = test.control.()

        results
        |> Enum.reject(&(compare_tests(control, &1)))
        |> Enum.each(fn(_) -> Logger.info("[Experiment #{test.name}]") end)

        control
      end

      def compare_tests(control, candidate), do: control == candidate
    end
  end

  @callback experiment(String.t) :: Experiment.Test.t
  @callback experimental(Experiment.Test.t, fun) :: Experiment.Test.t
  @callback experimental(Experiment.Test.t, String.t, fun) :: Experiment.Test.t
  @callback control(Experimental.Test.t, fun) :: Experiment.Test.t
  @callback perform_experiment(Experimental.Test.t) :: any
end
