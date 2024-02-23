defmodule EmailAddress.MixProject do
  use Mix.Project


  @version "1.0.1"
  def project do
    [
      app: :email_address,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      xref: [exclude: [:xmerl]],
      description: """
      Zero-dependency, forgiving, e-mail address parser and formatter library for Elixir 
      """,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}]
  end

  defp package do
    [
      maintainers: ["Hubert Łępicki"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/email_address/changelog.html",
        GitHub: "https://github.com/amberbit/email_address"
      },
      files:
        ~w(lib) ++
          ~w(CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      formatters: ["html", "epub"],
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
    ]
  end
end
