defmodule LogRotate.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project do
    [app: :log_rotate,
     version: @version,
     elixir: "~> 1.11",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do [
    applications: [:logger],
    mod: {LogRotate, []}
    ]
  end

  defp deps do [
    {:earmark, "~> 1.4.10"},
    {:ex_doc, "~> 0.23.0"}
   ]
  end
end
