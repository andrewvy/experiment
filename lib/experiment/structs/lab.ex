defmodule Experiment.Lab do
  @moduledoc """
  This module defines the `Experiment.Lab` struct and the main functions for
  working with the lab. This struct holds all of the experimental functions, as
  well as the control functions.
  """

  alias Experiment.Lab

  @type t :: %Lab{name: String.t, control: function | nil,
                  compare: function | nil, experiments: list | nil,
                  adapter: module(), experiment_count: integer}

  defstruct name: "", control: nil, adapter: nil, experiments: [], compare: nil, experiment_count: 0
end
