defmodule Experiment.Test do
  alias Experiment.Test

  @type t :: %Test{name: String.t, control: function | nil, experiments: list | nil, experiment_count: integer}

  defstruct name: "", control: nil, experiments: [], experiment_count: 0
end
