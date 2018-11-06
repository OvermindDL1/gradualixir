defmodule Gradualixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :gradualixir,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev, :test], runtime: false},
      {:gradualizer, github: "josefs/Gradualizer", ref: "master", manager: :rebar3}
    ]
  end
end
