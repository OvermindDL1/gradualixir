defmodule Mix.Tasks.Compile.Gradualixir do
  use Mix.Task

  @spec run(OptionParser.argv()) :: :ok
  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          verbose: :boolean
        ]
      )

    verbose = opts[:verbose]

    if(verbose, do: IO.puts("Gradualizing project..."))
    if(verbose, do: IO.puts("Gradualizing complete"))

    :ok
  end
end
