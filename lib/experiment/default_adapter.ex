defmodule Experiment.Adapters.Default do
  @moduledoc """
    This is the default lab adapter for Experiment. Records the output to
    Logger.info
  """

  alias Experiment.{ Base, Lab }
  require Logger

  @behaviour Base

  def record(%Lab{} = test, control, candidate) do
    Logger.info("""
    [Experiment] #{test.name} - #{candidate.name}

    Control: #{inspect control.result}
    Candidate: #{inspect candidate.result}
    """)
  end
end
