defmodule EmailAddress do
  # NOTICE: I wrote this years ago and *may have copied some initial code from somehwere*.
  # My google-fu and Github-search-fu fails me in finding the source exp. for the regexps
  # If you are a developer that I stole the code from, please do reach out over:
  # hubert.lepicki@amberbit.com and I'll get it sorted out with appropriate attribution.

  @moduledoc """
  EmailAddress provides top-level parsing & formatting API to deal with RFC5322-formatted
  e-mail addresses and (in the future) lists of e-mail addresses.

  This library is meant to be very forgiving and deal with invalid / malformed e-mail
  addresses in a fashion allowing for a recovery and avoiding common errors that happen
  when clients send malformed emails.
  """

  @doc """
  Given string containing single e-mail address, return `EmailAddress.Address` struct
  containing `addr_spec` and `display_name` fields or nil if address could not be
  parsed.

  ## Examples

      iex> EmailAddress.parse("jack.black@example.com")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: ""}

      iex> EmailAddress.parse("Jack Black <jack.black@example.com>")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"}

      iex> EmailAddress.parse("\\"Jack@Black\\" <jack.black@example.com>")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack@Black"}

      iex> EmailAddress.parse("Jack Black jack.black@example.com")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"}

      iex> EmailAddress.parse("Jack\\n\\rBlack\\tjack.black@example.com")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"}

      iex> EmailAddress.parse("\\"Jack@Black\\" <jack.black@example.com> ")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack@Black"}

      iex> EmailAddress.parse("")
      nil

      iex> EmailAddress.parse("Not an email")
      nil

      iex> EmailAddress.parse("http://example.com")
      nil

      iex> EmailAddress.parse("notanemail")
      nil

      iex> EmailAddress.parse("<notanemail>")
      nil

      iex> EmailAddress.parse("Not an email <notanemail>")
      nil

      iex> EmailAddress.parse("Jack Black jack.black@example.com>")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"}

      iex> EmailAddress.parse("Jack Black\\" jack.black@example.com>")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black\\""}

      iex> EmailAddress.parse("Jack.black@example.com jack.black@example.com")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack.black@example.com"}

      iex> EmailAddress.parse("Jack.black@example.com jack.black@example.com;,:")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack.black@example.com"}

      iex> EmailAddress.parse("Hubert Łępicki <hubert.łępicki@hubertłępicki.com>")
      %EmailAddress.Address{addr_spec: "hubert.łępicki@hubertłępicki.com", display_name: "Hubert Łępicki"}

      iex> EmailAddress.parse("Hubert Łępicki <hubert.łępicki@hubertłępicki.com>")
      %EmailAddress.Address{addr_spec: "hubert.łępicki@hubertłępicki.com", display_name: "Hubert Łępicki"}

      iex> EmailAddress.parse("client@example.com (Client Client)")
      %EmailAddress.Address{addr_spec: "client@example.com", display_name: "Client Client"}

      iex> EmailAddress.parse("\\"Black, Jack\\" <jack.black@example.com>")
      %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Black, Jack"}

      iex> EmailAddress.parse("\\"Black, Jack\\" <jack.black@127.0.0.1>")
      %EmailAddress.Address{addr_spec: "jack.black@127.0.0.1", display_name: "Black, Jack"}

      iex> EmailAddress.parse("\\"=?UTF-8?Q?Tesorer=C3=ADa?=\\" <user@u-oerre.md>")
      %EmailAddress.Address{addr_spec: "user@u-oerre.md", display_name: "=?UTF-8?Q?Tesorer=C3=ADa?="}

  """
  def parse(string) when is_binary(string) do
    string = normalize_whitespace(string)

    case Regex.named_captures(~r/<(?<addr_spec>[^\s<;,]+@[^\s;,>]+)>$/, string) do
      %{"addr_spec" => addr_spec} ->
        display_name =
          string
          |> String.replace(~r/<([^\s;,]+@[^\s;,>]+)>$/, "")
          |> trim()
          |> unescape_display_name()

        %EmailAddress.Address{display_name: display_name, addr_spec: addr_spec}

      _ ->
        case Regex.named_captures(
               ~r/^(?<addr_spec>[^\s<;,]+@[^\s;,>]+) \((?<display_name>.*)\)$/,
               string
             ) do
          %{"addr_spec" => addr_spec, "display_name" => display_name} ->
            display_name =
              (display_name || "")
              |> trim()
              |> unescape_display_name()

            %EmailAddress.Address{display_name: display_name, addr_spec: addr_spec}

          _ ->
            [last_part | other_parts] = string |> String.split(" ") |> Enum.reverse()

            case Regex.named_captures(~r/(?<addr_spec>[^\s;,<]+@[^\s;,>]+)/, last_part) do
              %{"addr_spec" => addr_spec} ->
                display_name =
                  other_parts
                  |> Enum.reverse()
                  |> Enum.join(" ")
                  |> trim()
                  |> unescape_display_name()

                %EmailAddress.Address{addr_spec: addr_spec, display_name: display_name}

              _ ->
                nil
            end
        end
    end
  end

  def parse(nil), do: nil

  @doc """
  Given `EmailAddress.Address` struct return RFC5322-formatted String containing
  e-mail address.

  This function performs escaping and quoting special characters found in `display_name` if and only if
  required, leaving `display_name` unquoted in cases when it's not necessary.

  ## Examples

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: ""})
      "jack.black@example.com"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"})
      "Jack Black <jack.black@example.com>"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black's Email"})
      "Jack Black's Email <jack.black@example.com>"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack <Black's> Email"})
      "\\"Jack <Black's> Email\\" <jack.black@example.com>"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "jack.black@example.com"})
      "\\"jack.black@example.com\\" <jack.black@example.com>"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black\\""})
      "\\"Jack Black\\\\\\"\\" <jack.black@example.com>"

      iex> EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Black, Jack"})
      "\\"Black, Jack\\" <jack.black@example.com>"

  """
  def format(%EmailAddress.Address{display_name: display_name, addr_spec: addr_spec}) do
    case display_name do
      "" -> addr_spec
      _ -> "#{escape_and_quote_display_name(display_name)} <#{addr_spec}>"
    end
  end

  # RFC 5322 special characters that need ""
  # "." commonly allowed in implementations
  @specials ["(", ")", "<", ">", "[", "]", ":", ";", "@", ",", "\\", "\""]
  defp escape_and_quote_display_name(display_name) do
    case Enum.any?(@specials, &String.contains?(display_name, &1)) do
      true ->
        "\"#{escape_display_name(display_name)}\""

      false ->
        display_name
    end
  end

  defp escape_display_name(display_name) do
    display_name |> String.replace("\\", "\\\\") |> String.replace("\"", "\\\"")
  end

  defp unescape_display_name(display_name) do
    display_name |> String.replace("\\\"", "\"") |> String.replace("\\\\", "\\")
  end

  defp trim(string) do
    string = String.trim(string)

    case Regex.run(~r/^"(.*)"$/, string, capture: :all_but_first) do
      [trimmed] -> trimmed
      _ -> string
    end
  end

  defp normalize_whitespace(string) do
    string
    |> String.replace(~r/(\s)+/, " ")
    |> String.trim()
  end
end
