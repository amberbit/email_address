defmodule EmailAddress.Address do
  @enforce_keys [:addr_spec, :display_name]
  defstruct [:addr_spec, :display_name]
end
