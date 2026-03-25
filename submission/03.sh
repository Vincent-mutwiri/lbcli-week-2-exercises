#!/usr/bin/env bash
set -euo pipefail

# Create a SegWit address.
# Add funds to the address.
# Return only the Address
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true

# Create the SegWit address in the default wallet context
ADDR=$(bitcoin-cli -regtest getnewaddress "" bech32)


bitcoin-cli -regtest generatetoaddress 1 "$ADDR" >/dev/null

echo "$ADDR"
