defmodule Experiment.Utils do
  @moduledoc """
  This module holds utility functions needed by Experiment.
  """

  @default_adapter Experiment.Adapters.Default

  @doc """
  Parses the configuration.
  """
  def parse_config do
    Application.get_env(:experiment, :adapter, @default_adapter)
  end

end
