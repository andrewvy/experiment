defmodule Experiment.Test do
  alias Experiment.Test

  @type t :: %Test{name: String.t, control: function | nil, experiments: list | nil}

  defstruct name: "", control: nil, experiments: []
end
