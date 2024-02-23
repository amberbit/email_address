defmodule EmailAddress.MixProject do
  use Mix.Project

  def project do
    [
      app: :email_address,
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      xref: [exclude: [:xmerl]],
      description: """
      Zero-dependency, forgiving, e-mail address parser and formatter library for Elixir 
      """
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
    []
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
end
