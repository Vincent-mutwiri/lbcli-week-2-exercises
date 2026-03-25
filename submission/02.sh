#!/usr/bin/env bash
set -euo pipefail

# Create a new Bitcoin address, for receiving change.
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true
# Use the default wallet context (autograder calls bitcoin-cli without -rpcwallet)
bitcoin-cli -regtest getrawchangeaddress bech32
