#!/bin/bash

# Import helper functions
source .github/functions.sh

# Week Two Exercise: Advanced Bitcoin Transaction
# This script combines concepts from previous exercises into a comprehensive challenge

# Ensure script fails fast on errors
set -e

echo "========================================================"
echo "🚀 ADVANCED BITCOIN TRANSACTION MASTERY CHALLENGE 🚀"
echo "========================================================"
echo ""
echo "Welcome to the final challenge! In this exercise, you'll"
echo "demonstrate your mastery of Bitcoin transactions by"
echo "completing a series of increasingly complex tasks."
echo ""
echo "Each task builds on concepts from previous exercises."
echo "Let's begin your journey to becoming a Bitcoin transaction expert!"
echo ""

# ======================================================================
# SETUP - These transactions are provided for the challenges
# ======================================================================

# Base transaction data from previous exercises
BASE_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

SECONDARY_TX="0200000000010182aabd8115c43e5b37a1b0c77a409b229896a2ffd255098c8056a954f9651d0b0000000000fdffffff023007000000000000160014618be8a3b3a80d01503de9255f6be79ffd2f91f2c89e0000000000001600146566e3df810b10943b851073bd0363d38f24901602473044022072afb72deafbb9b5716e5b48d5e32e3bfed34c03d291e6cd3dd06cf4a7bd118e0220630d076cb5ada15a401d0c63c30e9b392c6cd3ce11137d966e42c40be9971d700121025798c893c7930231e4254a2b79c64acd5d81811ae6d6a46de29257849b5705e800000000"

# For the signing challenge, we'll need a private key
# This is a testnet private key - NEVER use this in production!
TEST_PRIVATE_KEY="L27QxBowwWzRPVuLCCwGxAwehP6uGaDsrC8K4wmPjxdbjztrGJZb"
TEST_ADDRESS="mxqPaW7UH8F82R7dN6bsBbntnzFNbFYkMm"

# =========================================================================
# CHALLENGE 1: Transaction Decoding - Identify transaction components
# =========================================================================
echo "CHALLENGE 1: Transaction Analysis"
echo "--------------------------------"

echo ""

# Decode the transaction to get the TXID
TXID=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq -r '.txid')
check_cmd "Transaction decoding" "TXID" "$TXID"

echo "Transaction ID: $TXID"

# Extract the number of inputs and outputs from the transaction
NUM_INPUTS=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq '.vin | length')
check_cmd "Input counting" "NUM_INPUTS" "$NUM_INPUTS"

NUM_OUTPUTS=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq '.vout | length')
check_cmd "Output counting" "NUM_OUTPUTS" "$NUM_OUTPUTS"

echo "Number of inputs: $NUM_INPUTS"
echo "Number of outputs: $NUM_OUTPUTS"

# Extract the value of the first output in satoshis
FIRST_OUTPUT_VALUE=$(bitcoin-cli -regtest decoderawtransaction "$BASE_TX" | jq -r '.vout[0].value * 100000000 | floor')
check_cmd "Output value extraction" "FIRST_OUTPUT_VALUE" "$FIRST_OUTPUT_VALUE"

echo "First output value: $FIRST_OUTPUT_VALUE satoshis"

# =========================================================================
# CHALLENGE 2: UTXO Selection - Identify and select appropriate UTXOs
# =========================================================================
echo ""
echo "CHALLENGE 2: UTXO Selection"
echo "--------------------------"

echo ""

# Select a UTXO index and value from the decoded transaction
UTXO_TXID=$TXID
UTXO_VOUT_INDEX=0
check_cmd "UTXO vout selection" "UTXO_VOUT_INDEX" "$UTXO_VOUT_INDEX"

UTXO_VALUE=$FIRST_OUTPUT_VALUE
check_cmd "UTXO value extraction" "UTXO_VALUE" "$UTXO_VALUE"

echo "Selected UTXO:"
echo "TXID: $UTXO_TXID"
echo "Vout Index: $UTXO_VOUT_INDEX"
echo "Value: $UTXO_VALUE satoshis"

# =========================================================================
# CHALLENGE 3: Fee Calculation - Calculate appropriate transaction fees
# =========================================================================
echo ""
echo "CHALLENGE 3: Fee Calculation"
echo "---------------------------"

echo ""

# Approx size: 10 + 1*68 + 2*31 = 140 vbytes
TX_SIZE=$((10 + 68 + 2 * 31))
check_cmd "Transaction size calculation" "TX_SIZE" "$TX_SIZE"

FEE_RATE=10  # satoshis/vbyte
FEE_SATS=$((TX_SIZE * FEE_RATE))
check_cmd "Fee calculation" "FEE_SATS" "$FEE_SATS"

echo "Estimated transaction size: $TX_SIZE vbytes"
echo "Calculated fee: $FEE_SATS satoshis"

# =========================================================================
# CHALLENGE 4: Create Raw Transaction - Build a raw transaction with RBF
# =========================================================================
echo ""
echo "CHALLENGE 4: Creating a Raw Transaction with RBF"
echo "----------------------------------------------"

echo ""

PAYMENT_ADDRESS="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
CHANGE_ADDRESS="bcrt1qg09ftw43jvlhj4wlwwhkxccjzmda3kdm4y83ht"

# RBF: sequence < 0xfffffffe
TX_INPUTS='[{"txid":"'$UTXO_TXID'","vout":'$UTXO_VOUT_INDEX',"sequence":10}]'
check_cmd "Input JSON creation" "TX_INPUTS" "$TX_INPUTS"

PAYMENT_AMOUNT=15000000  # satoshis
CHANGE_AMOUNT=$((UTXO_VALUE - PAYMENT_AMOUNT - FEE_SATS))
check_cmd "Change calculation" "CHANGE_AMOUNT" "$CHANGE_AMOUNT"

PAYMENT_BTC=$(echo "scale=8; $PAYMENT_AMOUNT/100000000" | bc -l)
CHANGE_BTC=$(echo "scale=8; $CHANGE_AMOUNT/100000000" | bc -l)

TX_OUTPUTS='{"'$PAYMENT_ADDRESS'":'$PAYMENT_BTC',"'$CHANGE_ADDRESS'":'$CHANGE_BTC'}'
check_cmd "Output JSON creation" "TX_OUTPUTS" "$TX_OUTPUTS"

RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$TX_INPUTS" "$TX_OUTPUTS")
check_cmd "Raw transaction creation" "RAW_TX" "$RAW_TX"

# =========================================================================
# CHALLENGE 5: Transaction Verification - Decode and verify the transaction
# =========================================================================
echo ""
echo "CHALLENGE 5: Transaction Verification"
echo "-----------------------------------"

echo ""

DECODED_TX=$(bitcoin-cli -regtest decoderawtransaction "$RAW_TX")
check_cmd "Transaction decoding" "DECODED_TX" "$DECODED_TX"

VERIFY_RBF=$(echo "$DECODED_TX" | jq -r '(.vin[0].sequence < 4294967294)')
check_cmd "RBF verification" "VERIFY_RBF" "$VERIFY_RBF"

VERIFY_PAYMENT=$(echo "$DECODED_TX" | jq -r --arg addr "$PAYMENT_ADDRESS" '.vout[] | select(.scriptPubKey.address == $addr) | .value' | head -n1)
check_cmd "Payment verification" "VERIFY_PAYMENT" "$VERIFY_PAYMENT"

VERIFY_CHANGE=$(echo "$DECODED_TX" | jq -r --arg addr "$CHANGE_ADDRESS" '.vout[] | select(.scriptPubKey.address == $addr) | .value' | head -n1)
check_cmd "Change verification" "VERIFY_CHANGE" "$VERIFY_CHANGE"

# =========================================================================
# CHALLENGE 6: Raw Transaction Creation (simple example)
# =========================================================================
echo ""
echo "CHALLENGE 6: Raw Transaction Creation"
echo "------------------------------"

echo ""

SIMPLE_TX_INPUTS='[{"txid":"'$TXID'","vout":0,"sequence":4294967293}]'
SIMPLE_TX_OUTPUTS='{"'$TEST_ADDRESS'":0.0001}'

SIMPLE_RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$SIMPLE_TX_INPUTS" "$SIMPLE_TX_OUTPUTS")
check_cmd "Simple transaction creation" "SIMPLE_RAW_TX" "$SIMPLE_RAW_TX"

# =========================================================================
# CHALLENGE 7: Child Transaction (CPFP)
# =========================================================================
echo ""
echo "CHALLENGE 7: Child Transaction (CPFP)"
echo "-----------------------------------"

echo ""

PARENT_TXID=$(bitcoin-cli -regtest decoderawtransaction "$RAW_TX" | jq -r '.txid')
check_cmd "Parent TXID extraction" "PARENT_TXID" "$PARENT_TXID"

# Change output index (heuristic: assume second output is change)
CHANGE_OUTPUT_INDEX=1
check_cmd "Change output identification" "CHANGE_OUTPUT_INDEX" "$CHANGE_OUTPUT_INDEX"

CHILD_INPUTS='[{"txid":"'$PARENT_TXID'","vout":'$CHANGE_OUTPUT_INDEX',"sequence":10}]'
check_cmd "Child input creation" "CHILD_INPUTS" "$CHILD_INPUTS"

# Simple size estimate for child: 10 + 68 + 31 = 109
CHILD_TX_SIZE=$((10 + 68 + 31))
check_cmd "Child transaction size calculation" "CHILD_TX_SIZE" "$CHILD_TX_SIZE"

CHILD_FEE_RATE=20
CHILD_FEE_SATS=$((CHILD_TX_SIZE * CHILD_FEE_RATE))
check_cmd "Child fee calculation" "CHILD_FEE_SATS" "$CHILD_FEE_SATS"

# Use a nominal amount (since inputs are not actually spent on-chain in this exercise)
CHILD_SEND_AMOUNT=10000
check_cmd "Child amount calculation" "CHILD_SEND_AMOUNT" "$CHILD_SEND_AMOUNT"

CHILD_RECIPIENT="2MvM2nZjueT9qQJgZh7LBPoudS554B6arQc"
CHILD_SEND_BTC=$(echo "scale=8; $CHILD_SEND_AMOUNT/100000000" | bc -l)

CHILD_OUTPUTS='{"'$CHILD_RECIPIENT'":'$CHILD_SEND_BTC'}'
check_cmd "Child output creation" "CHILD_OUTPUTS" "$CHILD_OUTPUTS"

CHILD_RAW_TX=$(bitcoin-cli -regtest createrawtransaction "$CHILD_INPUTS" "$CHILD_OUTPUTS")
check_cmd "Child transaction creation" "CHILD_RAW_TX" "$CHILD_RAW_TX"

# =========================================================================
# CHALLENGE 8: CSV Timelock
# =========================================================================
echo ""
echo "CHALLENGE 8: Timelock Transaction"
echo "-------------------------------"

echo ""

SECONDARY_TXID=$(bitcoin-cli -regtest decoderawtransaction "$SECONDARY_TX" | jq -r '.txid')
check_cmd "Secondary TXID extraction" "SECONDARY_TXID" "$SECONDARY_TXID"

# 10-block relative timelock via sequence
TIMELOCK_INPUTS='[{"txid":"'$SECONDARY_TXID'","vout":0,"sequence":10}]'
check_cmd "Timelock input creation" "TIMELOCK_INPUTS" "$TIMELOCK_INPUTS"

TIMELOCK_ADDRESS="bcrt1qxhy8dnae50nwkg6xfmjtedgs6augk5edj2tm3e"

SECONDARY_OUTPUT_VALUE=$(bitcoin-cli -regtest decoderawtransaction "$SECONDARY_TX" | jq -r '.vout[0].value * 100000000 | floor')
check_cmd "Secondary output value extraction" "SECONDARY_OUTPUT_VALUE" "$SECONDARY_OUTPUT_VALUE"

TIMELOCK_FEE=1000
TIMELOCK_AMOUNT=$((SECONDARY_OUTPUT_VALUE - TIMELOCK_FEE))
check_cmd "Timelock amount calculation" "TIMELOCK_AMOUNT" "$TIMELOCK_AMOUNT"

TIMELOCK_BTC=$(echo "scale=8; $TIMELOCK_AMOUNT/100000000" | bc -l)

TIMELOCK_OUTPUTS='{"'$TIMELOCK_ADDRESS'":'$TIMELOCK_BTC'}'
check_cmd "Timelock output creation" "TIMELOCK_OUTPUTS" "$TIMELOCK_OUTPUTS"

TIMELOCK_TX=$(bitcoin-cli -regtest createrawtransaction "$TIMELOCK_INPUTS" "$TIMELOCK_OUTPUTS")
check_cmd "Timelock transaction creation" "TIMELOCK_TX" "$TIMELOCK_TX"

# Output the final transaction hex - useful for verification
echo $TIMELOCK_TX
