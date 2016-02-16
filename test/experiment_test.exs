defmodule ExperimentTest do
  use ExUnit.Case
  doctest Experiment

  alias Experiment.Lab

  defmodule ExampleWithoutControl do
    def perform do
      Experiment.new("returns widget for rendering")
      |> Experiment.test(&func_to_experiment/0)
      |> Experiment.perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end
  end

  defmodule Example do
    def perform do
      Experiment.new("returns widget for rendering")
      |> Experiment.test(&func_to_experiment/0)
      |> Experiment.control(&func_that_works/0)
      |> Experiment.perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end

    def func_that_works do
      {:ok, :bar}
    end
  end

  defmodule CompareExample do
    def perform do
      Experiment.new("returns widget for rendering")
      |> Experiment.test(&func_to_experiment/0)
      |> Experiment.control(&func_that_works/0)
      |> Experiment.compare(&compare_tests/2)
      |> Experiment.perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end

    def func_that_works do
      {:ok, :bar}
    end

    def compare_tests(control, candidate) do
      {status, _} = control
      {candidate_status, _} = candidate

      status == candidate_status
    end
  end

  defmodule TestLabAdapter do
    @behaviour Base

    alias Experiment.Lab

    def record(%Lab{} = test, control, results) do
    end
  end

  test "raises error when experiment doesn't have a control" do
    assert_raise ArgumentError, fn ->
      ExampleWithoutControl.perform()
    end
  end

  test "hits Adapter.record/1 when results don't match" do
    assert {:ok, :bar} == Example.perform()
  end

  test "can override compare function" do
    assert {:ok, :bar} == CompareExample.perform()
  end
end
