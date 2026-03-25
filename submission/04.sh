#!/usr/bin/env bash
set -euo pipefail

# List the current UTXOs in your wallet.
bitcoin-cli -regtest loadwallet "btrustwallet" >/dev/null 2>&1 || true
bitcoin-cli -regtest -rpcwallet=btrustwallet listunspent
