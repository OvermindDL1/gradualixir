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
  @spec gradualize(binary() | list(charlist()) | list(binary())) :: :ok
  def gradualize(files, opts \\ [])

  def gradualize([_ | _] = files, opts) do
    {preload, _opts} = Keyword.pop(opts, :preload, false)
    if(preload, do: :gradualizer_db.import_beam_files(get_beam_files(opts)))

    files
    |> Enum.map(&to_charlist/1)
    |> Enum.reduce_while(:ok, fn file, result ->
      file
      |> to_charlist()
      |> :gradualizer.type_check_file(print_file: true)
      |> case do
        :ok -> {:cont, if(result == :ok, do: :ok, else: result)}
        :nok -> {:cont, :error}
      end
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
end
