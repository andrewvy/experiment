defmodule ExperimentTest do
  use ExUnit.Case
  doctest Experiment

  alias Experiment.Lab

  defmodule ExampleWithoutControl do
    use Experiment

    def perform do
      lab("returns widget for rendering")
      |> experiment(&func_to_experiment/0)
      |> perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end
  end

  defmodule Example do
    use Experiment

    def perform do
      lab("returns widget for rendering")
      |> experiment(&func_to_experiment/0)
      |> control(&func_that_works/0)
      |> perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end

    def func_that_works do
      {:ok, :bar}
    end
  end

  test "raises error when experiment doesn't have a control" do
    assert_raise ArgumentError, fn ->
      ExampleWithoutControl.perform()
    end
  end

  test "hits Adapter.record/1 when results don't match" do
    Example.perform()
  end
end
