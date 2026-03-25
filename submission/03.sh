#!/usr/bin/env bash
set -euo pipefail

# Create a SegWit address.
# Add funds to the address.
# Return only the Address
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true
ADDR=$(bitcoin-cli -regtest -rpcwallet=btrustwallet getnewaddress "" bech32)

# Mine 1 block to the address to fund it (regtest).
bitcoin-cli -regtest generatetoaddress 1 "$ADDR" >/dev/null

echo "$ADDR"
