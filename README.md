# Gradualixir

Mix integration with [Gradualizer](https://github.com/josefs/Gradualizer).

Gradualizer is an enforced static typing checker based on BEAM specs.

## Installation

The package can currently be installed from github by adding `gradualixir`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gradualixir, github: "overminddl1/gradualixir", ref: "master"}
  ]
end
```

## Usage

Once added to a mix project dependencies and `mix deps.get` is run to acquire the dependencies, then just run the `mix gradualizer` command to check the files on the existing project, such as:

```zsh
╰─➤  mix gradualizer
/home/overminddl1/elixir/gradualixir/_build/dev/lib/gradualixir/ebin/Elixir.Gradualixir.beam: The binary [{bin_element,0,{string,0,"*.beam"},default,default}] on line 0 does not have type t()
/home/overminddl1/elixir/gradualixir/_build/dev/lib/gradualixir/ebin/Elixir.Mix.Tasks.Gradualizer.beam: The binary [{bin_element,0,{string,0,"*.beam"},default,default}] on line 0 does not have type t()
```

Currently Gradualizer is in early development and it's only output is currently just to `stdout` so the syntax is currently in Erlang format.  Hope to parse it out in short order however.

### Options

The currently supported options are:

* `--gradualize-preload` will preload all beam files known to the erlang runtime and all known paths to the gradualizer db process, otherwise it looks to load them on-demand.
* `--no-compile` will not compile the project before running gradualizer.
* `--quiet` will silence all shell output, will still set the return code to the shell however.

In addition it takes 0 or more position rest arguments:

* 0 arguments -> Gradualize just the current project's BEAM files but no consolidated files, this is the same as passing in `:project-ebin`.
* A single `:all` argument will gradualize all BEAM files **everywhere** known to the system, do note that a lot of erlang and elixir specs may not be 'good' for such a purpose, but it's great for testing and reporting and fixing bugs to them!
* A single `:project-ebin` argument will gradualize the non-consolidated BEAM files of the current project.  This is the default value if no arguments.
* A single `:project` argument will gradualize all BEAM files of the current project, including consolidated files (which Elixir does not generate very cleanly so expect errors in those).
* A single `:deps` argument will gradualize all BEAM files of the current project and all dependencies of the current project, essentially everything but the OTP and Elixir itself.
* Or 1 or more arguments of the paths to specific BEAM files to gradualize.

## Name?

Gradualixir is to Gradualizer as Dialyxir is to Dialyzer, and I hope Gradualizer will get a usable interface on par to that of Dialyzer for tool use in time.  :-)
