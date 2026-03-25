#!/usr/bin/env bash
set -euo pipefail

# Create a wallet with the name "btrustwallet".
# (If it already exists, just load it so later exercises work.)
if bitcoin-cli -regtest listwalletdir | jq -e '.wallets[].name == "btrustwallet"' >/dev/null 2>&1; then
  bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true
else
  bitcoin-cli -regtest createwallet "btrustwallet"
fi
