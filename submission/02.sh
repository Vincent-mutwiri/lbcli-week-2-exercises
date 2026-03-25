#!/usr/bin/env bash
set -euo pipefail

# Create a new Bitcoin address, for receiving change.
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true
bitcoin-cli -regtest -rpcwallet=btrustwallet getrawchangeaddress bech32
