defmodule Experiment.Base do
  @moduledoc """
  This is the base behaviour for creating a Lab Adapter for recording the
  results of experiments.
  """

  alias Experiment.{ Lab, Test }

  @callback record(Lab.t, any, Test.t) :: any
end
