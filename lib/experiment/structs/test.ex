defmodule Experiment.Test do
  @moduledoc """
  This module defines the `Experiment.Test` struct, used for containing
  the test function and it's label. This struct gets passed into an Experiment
  adapter's record/3 method.
  """

  alias Experiment.Test

  @type t :: %Test{name: String.t, function: function, result: any}

  defstruct name: "", function: nil, result: nil
end
