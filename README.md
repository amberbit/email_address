# EmailAddress

EmailAddress provides top-level parsing & formatting API to deal with RFC5322-formatted
e-mail addresses.

This library is meant to be very forgiving and deal with invalid / malformed e-mail
addresses in a fashion allowing for a recovery and avoiding common errors that happen
when clients send malformed emails.

The case for having a forgiving library to parse e-mail addresses, is that the e-mail
clients do not stick to the rules or have bugs allowing for invalid e-mail addresses to
be used when sending, receiving or processing e-mails.

This library defines e-mail address as a string, which contains what most people think as
sender name + e-mail address.

When parsing, we support various formats encountered in the wild:

```
- jack.black@example.com
- Jack Black <jack.black@example.com>
- "Jack@Black" <jack.black@example.com>
- Jack Black jack.black@example.com
- Jack\n\rBlack\tjack.black@example.com
- jack.black@example.com (Jack Black)
- Jack Black <jack.black@127.0.0.1>
```

## Installation

If [available in Hex](https://hex.pm/packages/email_address), the package can be installed
by adding `email_address` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:email_address, "~> 1.0"}
  ]
end
```

Documentation can be can be found at
[https://hexdocs.pm/email_address](https://hexdocs.pm/email_address).

## Usage

Parsing e-mail addresses:

    EmailAddress.parse("jack.black@example.com")
    => %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: ""}

    EmailAddress.parse("Jack Black <jack.black@example.com>")
    => %EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"}

    EmailAddress.parse("Not an e-mail")
    => nil

Formatting e-mail address:

    EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: ""})
    => "jack.black@example.com"

    EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack Black"})
    => "Jack Black <jack.black@example.com>"

    EmailAddress.format(%EmailAddress.Address{addr_spec: "jack.black@example.com", display_name: "Jack <Black's> Email"})
    => "\\"Jack <Black's> Email\\" <jack.black@example.com>"

## Thanks

This code has been made open source thanks to [Keeping.com](https://keeping.com). Please check them out if you need a shared Gmail inbox!

## Copyright and License

Copyright (c) 2024, Hubert Łępicki.

EmailAddress source code is licensed under the [MIT License](LICENSE.md).

