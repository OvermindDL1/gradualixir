defmodule Gradualixir do
  @moduledoc """
  Documentation for Gradualixir.
  """

  @doc """
  Hello world.

  ## Examples

  ### Gradualizing a beam file

      iex> beamfile = "_build/test/lib/gradualixir/ebin/Elixir.Gradualixir.beam"
      iex> Gradualixir.gradualize(beamfile)
      :ok

  ### Gradualizing many beam files

      iex> beamfiles = Path.wildcard("_build/test/lib/gradualixir/ebin/*.beam")
      iex> Gradualixir.gradualize(beamfiles)
      :ok

  """
  @spec gradualize(binary() | list(charlist()) | list(binary())) :: :ok | :error | list(error :: any())
  def gradualize(files, opts \\ [])

  def gradualize([_ | _] = files, opts) do
    {preload, _opts} = Keyword.pop(opts, :preload, false)
    if(preload, do: :gradualizer_db.import_beam_files(get_beam_files(opts)))

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
    try do
      :gradualizer.type_check_file(file, [{:print_file, true}, {:specs_override, 'priv/prelude'} | opts])
    rescue
      e in _ ->
        {e, stack} = Exception.blame(:error, e, __STACKTRACE__)

        IO.puts("""

        *********************************
        Report this error to Gradualizer:

        #{Exception.format(:error, e, stack)}

        """)

        :error
    else
      :ok -> :ok
      :nok -> :error
      [] -> :ok
      [_ | _] = errors -> {:error, errors}
    end
  end

  defp merge_results(result, acc) do
    case result do
      :ok -> acc
      :error -> :error
      {:error, errors} when acc == :ok -> errors
      {:error, errors} -> acc ++ errors
    end
  end
end
