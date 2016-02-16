defmodule Experiment.Adapters.Default do
  alias Experiment.{ Base, Lab }
  require Logger

  @behaviour Base

  def record(%Lab{} = test, results) do
    Logger.info("[Experiment #{test.name}]")
  end
end
