defmodule Experiment.Utils do

  @doc """
  Parses the configuration.
  """
  def parse_config(:error), do: nil
  def parse_config(otp_app), do: otp_app
  def parse_config(module, opts) do
    otp_app = parse_config(Keyword.fetch(opts, :otp_app))
    config  = Application.get_env(otp_app, module, [])
    adapter = opts[:adapter] || config[:adapter] || Experiment.Adapters.Default

    { otp_app, adapter, config }
  end

end
