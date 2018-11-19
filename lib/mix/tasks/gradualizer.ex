defmodule Mix.Tasks.Gradualizer do
  @shortdoc "Runs Gradualizer with default or project defined flags"

  @moduledoc """
  """

  use Mix.Task

  @command_options [
    gradualize_preload: :boolean,
    no_compile: :boolean,
    quiet: :boolean,
    verbose: :boolean
  ]

  @spec run(OptionParser.argv()) :: :ok | :error
  def run(args) do
    {opts, gargs, _ignored_flags} = OptionParser.parse(args, strict: @command_options)
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

  defp get_beams(type)
  defp get_beams([":all"]), do: :all
  defp get_beams([":project-ebin"]), do: get_beams([])

  defp get_beams([]) do
    Mix.Project.umbrella?()
    |> if do
      Mix.Project.apps_paths()
      |> Map.keys()
      |> Enum.map(fn app ->
        [Mix.Project.build_path(), "lib", to_string(app), "ebin", "*.beam"]
        |> Path.join()
        |> Path.wildcard()
      end)
    else
      [Mix.Project.compile_path(), "*.beam"]
      |> Path.join()
      |> Path.wildcard()
    end
    |> List.flatten()
  end

  defp get_beams([":project"]) do
    Mix.Project.umbrella?()
    |> if do
      Mix.Project.apps_paths()
      |> Map.keys()
      |> Enum.map(fn app ->
        [Mix.Project.build_path(), "lib", to_string(app), "consolidated", "*.beam"]
        |> Path.join()
        |> Path.wildcard()
      end)
    else
      [Mix.Project.compile_path(), "..", "consolidated", "*.beam"]
      |> Path.join()
      |> Path.wildcard()
    end
    |> List.flatten(get_beams([]))
  end

  defp get_beams([":deps"]) do
    [Mix.Project.build_path(), "**", "*.beam"]
    |> Path.join()
    |> Path.wildcard()
  end

  defp get_beams(paths) do
    paths
    |> Enum.map(&Path.expand/1)
    |> Enum.flat_map(fn path ->
      cond do
        String.ends_with?(path, ".beam") ->
          Path.wildcard(path)

        path ->
          [path, "**", "*.beam"]
          |> Path.join()
          |> Path.wildcard()
      end
    end)
  end

  defp run_gradualizer(opts, gargs) do
    files = get_beams(gargs)

    opts[:verbose] && IO.puts("\n\nBeam Files to parse:")
    opts[:verbose] && Enum.each(files, &IO.puts/1)

    opts[:verbose] && IO.puts("\n\nGradualizing:")

    args = [
      preload: (opts[:gradualizer_preload] && true) || false
    ]

    Gradualixir.gradualize(files, args)
  end
end
