defmodule Mix.Tasks.Gradualizer do
  @shortdoc "Runs Gradualizer with default or project defined flags"

  @moduledoc """
  """

  use Mix.Task

  @command_options [
    gradualize_preload: :boolean,
    no_compile: :boolean,
    quiet: :boolean
  ]

  @spec run(OptionParser.argv()) :: :ok | :error
  def run(args) do
    {opts, _, gargs} = OptionParser.parse(args, strict: @command_options)
    original_shell = Mix.shell()
    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)
    opts = Keyword.delete(opts, :quiet)

    result =
      if Mix.Project.get() do
        unless opts[:no_compile], do: Mix.Project.compile([])
        run_gradualizer(opts, gargs)
      else
        IO.puts("No mix project found")
        :error
      end

    Mix.shell(original_shell)
    result
  end

  defp run_gradualizer(opts, gargs) do
    files =
      case gargs do
        [":all"] ->
          :all

        v when v in [[":project-ebin"], []] ->
          Path.wildcard(Path.join([Mix.Project.compile_path(), "*.beam"]))

        [":project"] ->
          Path.wildcard(Path.join([Mix.Project.compile_path(), "..", "*", "*.beam"]))

        [":deps"] ->
          Path.wildcard(
            Path.join([
              Mix.Project.build_path(),
              "*",
              "*",
              "*",
              "*.beam"
            ])
          )

        files ->
          files
      end

    args = [
      preload: (opts[:gradualizer_preload] && true) || false
    ]

    Gradualixir.gradualize(files, args)
  end
end
