# Experiment

Elixir Library for carefully refactoring critical paths.

---

(this is in an unfinished stage, as we flesh out the design of Experiment)

Running Elixir in production? ExUnit says all your tests pass? Can't wait to be
utilizing the awesome hot-code reloading feature to push up your new changes?
Well, hold on there, for critical parts of your application you may need more
reassurance.

Experiment allows you to run refactored code side-by-side with your previously
written code, compare the outputs of each, and notifying when something didn't
return as expected.

### Usage

Let's say you're refactoring a super important controller. Tests can help, but
sometimes you really want to pit your refactored code against your current code.

```elixir
defmodule App.ImportantAPIController do
  use Experiment

  def index(conn, params) do
    widget =
      experiment("returns widget for rendering")
      |> experimental(:func_to_experiment, [])
      |> experimental(:another_func_to_experiment, [])
      |> control(:func_that_works, [])
      |> perform_experiment

    render conn, widget: widget
  end

  def func_to_experiment do
    %{type: "foo"}
  end

  def another_func_to_experiment do
    %{type: "bar"}
  end

  def func_that_works do
    %{type: "foo"}
  end

  def experiment_record(results) do
    # Record results into DB, notify me on Slack, etc.
  end

  # Override default behavior which `==` the control and candidate.
  def experiment_compare(control, candidate) do
    control.type == candidate.type
  end
end
```
