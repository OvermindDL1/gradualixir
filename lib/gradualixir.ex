defmodule Gradualixir do
  @moduledoc """
  Documentation for Gradualixir.
  """

  @def_opts [print_file: true, specs_override: 'priv/prelude']

  @doc """
  Examples speak for themselves

  ## Examples

  ### Gradualizing a beam file

      iex> beamfile = "_build/test/lib/gradualixir/ebin/Elixir.Gradualixir.beam"
      iex> Gradualixir.gradualize(beamfile)
      :ok

  ### Gradualizing many beam files, with format option

      iex> beamfiles = Path.wildcard("_build/test/lib/gradualixir/ebin/*.beam")
      iex> Gradualixir.gradualize(beamfiles, fmt_location: :brief)
      :ok

  """
  @spec gradualize(binary() | list(charlist()) | list(binary())) ::
          :ok | :error | list(error :: any())
  def gradualize(files, opts \\ [])

  def gradualize([_ | _] = files, opts) do
    if opts[:preload] do
      :gradualizer_db.import_beam_files(get_beam_files(opts))
    end

    files
    |> Enum.reduce(:ok, fn file, result ->
      file
      |> to_charlist()
      |> safe_type_check_file(opts)
      |> merge_results(result)
    end)
  end

  def gradualize(file, opts) when is_binary(file) do
    gradualize([file], opts)
  end

  def gradualize(:all, opts) do
    get_beam_files(opts)
    |> gradualize(opts)
  end

  def get_beam_files(opts) do
    opts
    |> get_base_paths()
    |> Enum.flat_map(fn path ->
      path
      |> Path.join("*.beam")
      |> Path.wildcard()
    end)
  end

  defp get_base_paths(opts) do
    case opts[:ebin_root] do
      nil -> :code.get_path()
      paths -> List.wrap(paths)
    end
  end

  defp safe_type_check_file(file, opts) do
    :gradualizer.type_check_file(file, @def_opts ++ opts)
  else
    :ok -> :ok
    :nok -> :error
    [] -> :ok
    [_ | _] = errors -> {:error, errors}
  rescue
    e in _ ->
      {e, stack} = Exception.blame(:error, e, __STACKTRACE__)

      IO.puts("""

      *********************************
      Report this error to Gradualizer:

      #{Exception.format(:error, e, stack)}

      """)

      :error
  end

  defp merge_results(:ok, acc), do: acc
  defp merge_results(:error, _acc), do: :error
  defp merge_results({:error, errors}, :ok), do: errors
  defp merge_results({:error, errors}, acc), do: acc ++ errors
end
