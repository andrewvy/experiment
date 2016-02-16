# Experiment

Elixir Library for carefully refactoring critical paths, influenced heavily by [github/scientist](https://github.com/github/scientist).

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
  use Experiment, otp_app: :my_app

  def index(conn, params) do
    widget =
      lab("returns widget for rendering")
      |> experiment(&func_to_experiment/0)
      |> experiment(&another_func_to_experiment/0)
      |> control(&func_that_works/0)
      |> compare(&custom_compare_tests/2)
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

  # Override default behavior which `==` the control and candidate.
  def custom_compare_tests(control, candidate) do
    control.type == candidate.type
  end
end
```

You can define your own Experiment adapter for recording results by using the `Experiment.Base` module.

```elixir
defmodule App.ExperimentAdapter do
  use Experiment.Base

  def record(%Experiment.Lab = lab, control_result, candidate_result) do
    # Do something with the results, save them to the DB, etc.
  end
end
```

In your config, you can specify your own Experiment adapter.

```elixir
config :my_app, Experiment,
  adapter: App.ExperimentAdapter
```
