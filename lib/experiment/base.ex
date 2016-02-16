defmodule Experiment.Base do
  alias Experiment.Lab

  @callback record(Lab.t, any, any) :: any
end
