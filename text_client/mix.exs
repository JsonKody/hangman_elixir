defmodule TextClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :text_client,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      include_applications: [:hangman],
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      { :hangman, path: "../hangman" },
    ]
  end
end
