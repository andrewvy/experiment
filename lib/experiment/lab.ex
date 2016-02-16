defmodule Experiment.Lab do
  alias Experiment.Lab

  @type t :: %Lab{name: String.t, control: function | nil, experiments: list | nil, experiment_count: integer}

  defstruct name: "", control: nil, experiments: [], experiment_count: 0
end
