defmodule Experiment.Adapters.Default do
  alias Experiment.{ Base, Lab }
  require Logger

  @behaviour Base

  def record(%Lab{} = test, control, results) do
    Logger.info("[Experiment] \"#{test.name}\"")
    Logger.info(["[Experiment] ", ~s("#{test.name}" - ), "Control: #{inspect control} but got #{inspect results}."])
  end
end
