defmodule Experiment.Base do
  use Behaviour
  alias Experiment.Lab

  @callback record(Lab.t, any) :: none
end
