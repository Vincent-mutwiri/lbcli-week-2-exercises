#!/usr/bin/env bash
set -euo pipefail

# Create a SegWit address.
# Add funds to the address.
# Return only the Address
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true

# Ensure the wallet has spendable funds (coinbase must mature: 100 blocks)
FUND_ADDR=$(bitcoin-cli -regtest getnewaddress "" bech32)
bitcoin-cli -regtest generatetoaddress 101 "$FUND_ADDR" >/dev/null

# Create the SegWit address we want to fund
ADDR=$(bitcoin-cli -regtest getnewaddress "" bech32)

# Send funds to it (wallet-recognized receipt)
# Use -named to set fee_rate explicitly (avoids fee estimation + fallbackfee issues)
bitcoin-cli -regtest -named sendtoaddress address="$ADDR" amount=1 fee_rate=1 >/dev/null

# Mine 1 block to confirm the send
bitcoin-cli -regtest generatetoaddress 1 "$FUND_ADDR" >/dev/null

echo "$ADDR"
