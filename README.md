# Experiment

[![Hex.pm](https://img.shields.io/hexpm/v/experiment.svg?style=flat-square)](https://hex.pm/packages/experiment)
[![Hex.pm](https://img.shields.io/hexpm/dt/experiment.svg?style=flat-square)](https://hex.pm/packages/experiment)
[![Inline docs](http://inch-ci.org/github/andrewvy/experiment.svg)](http://inch-ci.org/github/andrewvy/experiment)

Elixir Library for carefully refactoring critical paths, influenced heavily by [github/scientist](https://github.com/github/scientist).

---

Running Elixir in production? ExUnit says all your tests pass? Can't wait to be
utilizing the awesome hot-code reloading feature to push up your new changes?
Well, hold on there, for critical parts of your application you may need more
reassurance.

Experiment allows you to run refactored code side-by-side with your previously
written code, compare the outputs of each, and notifying when something didn't
return as expected.

---

### Documentation

Documentation is available at [http://hexdocs.pm/experiment](http://hexdocs.pm/experiment)

---

### Installation

Add Experiment as a dependency to your project.

```elixir
defp deps do
  [{:experiment, "~> 0.0.3"}]
end
```

Then run `mix deps.get` to fetch it.

---

### Usage

Let's say you're refactoring a super important controller. Tests can help, but
sometimes you really want to pit your refactored code against your current code.

```elixir
defmodule App.ImportantAPIController do
  def index(conn, params) do
    widget =
      Experiment.new("returns widget for rendering")
      |> Experiment.test(&func_to_experiment/1, ["foo"])
      |> Experiment.test(&another_func_to_experiment/0)
      |> Experiment.control(&func_that_works/0)
      |> Experiment.compare(&custom_compare_tests/2)
      |> Experiment.perform_experiment

    render conn, widget: widget
  end

  def func_to_experiment(type) do
    %{type: type}
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

By default, the default Experiment adapter uses `Logger.info` for outputting. If an experiment crashes, a stacktrace is provided as it's result.

```
12:53:14.250 [info]  [Experiment] Example: returns widget for rendering - Test 1

Control: {:ok, :bar}
Candidate: {:ok, :foo}


12:53:14.256 [info]  [Experiment] returns widget for rendering - Test 1

Control: {:ok, :foo}
Candidate: "** (ErlangError) erlang error: ArgumentError\n    test/experiment_test.exs:139: anonymous fn/1 in ExperimentTest.test handles experiment exceptions/1\n    (experiment) lib/experiment/utils.ex:18: anonymous fn/2 in Experiment.Utils.bind/2\n    (experiment) lib/experiment.ex:99: anonymous fn/1 in Experiment.perform_experiment/1\n    (elixir) lib/task/supervised.ex:89: Task.Supervised.do_apply/2\n    (elixir) lib/task/supervised.ex:40: Task.Supervised.reply/5\n    (stdlib) proc_lib.erl:240: :proc_lib.init_p_do_apply/3\n"
```

---

### Customizing Adapter

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
config :experiment,
  adapter: App.ExperimentAdapter
```
