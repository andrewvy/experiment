defmodule Experiment.Base do
  use Behaviour

  @callback record(any) :: none
end
