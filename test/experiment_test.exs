defmodule ExperimentTest do
  use ExUnit.Case
  doctest Experiment

  alias Experiment.Lab

  defmodule ExampleWithoutControl do
    def perform do
      Experiment.new("ExampleWithoutControl: returns widget for rendering")
      |> Experiment.test(&func_to_experiment/0)
      |> Experiment.perform_experiment
    end

    def func_to_experiment do
      {:ok, :foo}
    end
  end

  defmodule Example do
    def perform do
      Experiment.new("Example: returns widget for rendering")
      |> Experiment.test(&func_to_experiment/1, [:foo])
      |> Experiment.control(&func_that_works/0)
      |> Experiment.perform_experiment
    end

    def func_to_experiment(type) do
      {:ok, type}
    end

    def func_that_works do
      {:ok, :bar}
    end
  end

  defmodule CompareExample do
    def perform do
      Experiment.new("CompareExample: returns widget for rendering")
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
    @behaviour Experiment.Base

    alias Experiment.Lab

    def record(%Lab{} = _test, _control, _results) do
    end
  end

  test "raises error when experiment doesn't have a control" do
    assert_raise ArgumentError, fn ->
      ExampleWithoutControl.perform()
    end
  end

  test "hits Adapter.record/3 when results don't match" do
    assert {:ok, :bar} == Example.perform()
  end

  test "can override compare function" do
    compare_tests = fn(control, candidate) ->
      assert control == candidate
      control == candidate
    end

    control = fn ->
      {:ok, :foo}
    end

    experiment = fn ->
      {:ok, :foo}
    end

    experiment = Experiment.new("returns widget for rendering, override compare")
    |> Experiment.test(experiment)
    |> Experiment.control(control)
    |> Experiment.compare(compare_tests)

    result =
      experiment
      |> Experiment.perform_experiment

    assert {:ok, :foo} == result
  end

  test "can pass params to functions" do
    compare_tests = fn(control, candidate) ->
      control == candidate
    end

    control = fn ->
      {:ok, :foo}
    end

    experiment = fn(type) ->
      assert type == :foo

      {:ok, type}
    end

    experiment = Experiment.new("returns widget for rendering")
    |> Experiment.test(control)
    |> Experiment.control(experiment, [:foo])
    |> Experiment.compare(compare_tests)

    result =
      experiment
      |> Experiment.perform_experiment

    assert {:ok, :foo} == result
  end

  test "handles experiment exceptions" do
    control = fn ->
      {:ok, :foo}
    end

    experiment = fn(_type) ->
      throw ArgumentError
    end

    experiment = Experiment.new("returns widget for rendering")
    |> Experiment.test(experiment, [:foo])
    |> Experiment.control(control)

    result =
      experiment
      |> Experiment.perform_experiment

    assert {:ok, :foo} == result
  end
end
