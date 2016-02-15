defmodule Experiment do

  defmacro __using__() do
    quote do
      alias Experiment.Test

      def experiment(name) when is_string(name) do
        %Test{name: name}
      end

      def experimental(%Test{} = experiment, func) when is_function(func) do
      end

      def control(%Test{} = experiment, func) when is_function(func) do
      end

      def perform_experiment(%Test{} = test) do
      end
    end
  end

  @callback experiment(String.t) :: Experiment.Test.t
  @callback experimental(Experiment.Test.t, fun) :: Experiment.Test.t
  @callback control(Experimental.Test.t, fun) :: Experiment.Test.t
  @callback perform_experiment(Experimental.Test.t) :: any
end
