#!/bin/bash

# Import helper functions
source .github/functions.sh

# Week Two Exercise: Advanced Bitcoin Transaction MASTERY
# Completing a series of Bitcoin transaction tasks from decoding to timelocks

# Ensure script fails on error
set -e

echo "========================================================"
echo "🚀 ADVANCED BITCOIN TRANSACTION MASTERY CHALLENGE 🚀"
echo "========================================================"
echo ""
echo "Demonstrating mastery of Bitcoin transactions by completing"
echo "increasingly complex tasks on the regtest network."
echo ""

# Configuration Data
RAW_BASE="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
RAW_SEC="0200000000010182aabd8115c43e5b37a1b0c77a409b229896a2ffd255098c8056a954f9651d0b0000000000fdffffff023007000000000000160014618be8a3b3a80d01503de9255f6be79ffd2f91f2c89e0000000000001600146566e3df810b10943b851073bd0363d38f24901602473044022072afb72deafbb9b5716e5b48d5e32e3bfed34c03d291e6cd3dd06cf4a7bd118e0220630d076cb5ada15a401d0c63c30e9b392c6cd3ce11137d966e42c40be9971d700121025798c893c7930231e4254a2b79c64acd5d81811ae6d6a46de29257849b5705e800000000"

PRIV_KEY_TEST="L27QxBowwWzRPVuLCCwGxAwehP6uGaDsrC8K4wmPjxdbjztrGJZb"
ADDR_TEST="mxqPaW7UH8F82R7dN6bsBbntnzFNbFYkMm"

# CHALLENGE 1: Decode Base Transaction
echo "CHALLENGE 1: Decoding and Analysis"
BASE_INFO=$(bitcoin-cli -regtest decoderawtransaction "$RAW_BASE")
MAIN_TX_ID=$(echo "$BASE_INFO" | jq -r '.txid')
echo "TXID: $MAIN_TX_ID"

I_COUNT=$(echo "$BASE_INFO" | jq '.vin | length')
O_COUNT=$(echo "$BASE_INFO" | jq '.vout | length')
SATS_VAL=$(echo "$BASE_INFO" | jq '.vout[0].value * 100000000 | round')

check_cmd "Decode" "MAIN_TX_ID" "$MAIN_TX_ID"
check_cmd "Inputs" "I_COUNT" "$I_COUNT"
check_cmd "Outputs" "O_COUNT" "$O_COUNT"
check_cmd "Satoshis" "SATS_VAL" "$SATS_VAL"

# CHALLENGE 2: Select UTXO
echo "CHALLENGE 2: UTXO Selection"
V_INDEX=0
V_VALUE=$SATS_VAL
check_cmd "Vout Index" "V_INDEX" "$V_INDEX"
check_cmd "Vout Value" "V_VALUE" "$V_VALUE"

# CHALLENGE 3: Calculate Fees (10 sat/vbyte)
echo "CHALLENGE 3: Fee Estimation"
EST_VSIZE=$((10 + 68 + 31 * 2))
CALC_FEE=$((EST_VSIZE * 10))
check_cmd "Vsize" "EST_VSIZE" "$EST_VSIZE"
check_cmd "Fee" "CALC_FEE" "$CALC_FEE"

# CHALLENGE 4: Create Raw Transaction with RBF
echo "CHALLENGE 4: Raw Transaction Creation (RBF)"
RECIPIENT_A="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
REMAINDER_A="bcrt1qg09ftw43jvlhj4wlwwhkxccjzmda3kdm4y83ht"

RAW_INPUTS="[{\"txid\":\"$MAIN_TX_ID\",\"vout\":$V_INDEX,\"sequence\":4294967293}]"
PAY_SATS=15000000
BACK_SATS=$((V_VALUE - PAY_SATS - CALC_FEE))

PAY_BTC=$(awk "BEGIN {printf \"%.8f\", $PAY_SATS / 100000000}")
BACK_BTC=$(awk "BEGIN {printf \"%.8f\", $BACK_SATS / 100000000}")

RAW_OUTPUTS="{\"$RECIPIENT_A\":$PAY_BTC,\"$REMAINDER_A\":$BACK_BTC}"
FINAL_RAW_HEX=$(bitcoin-cli -regtest createrawtransaction "$RAW_INPUTS" "$RAW_OUTPUTS")
check_cmd "Raw Hex" "FINAL_RAW_HEX" "$FINAL_RAW_HEX"

# CHALLENGE 5: Verification
echo "CHALLENGE 5: Decoding Verification"
CHECK_DECODE=$(bitcoin-cli -regtest decoderawtransaction "$FINAL_RAW_HEX")
RBF_ENABLED=$(echo "$CHECK_DECODE" | jq -r 'if .vin[0].sequence < 4294967294 then "true" else "false" end')

check_cmd "RBF Check" "RBF_ENABLED" "$RBF_ENABLED"

# CHALLENGE 6: Simple Signing Transaction
echo "CHALLENGE 6: Signing Preparation"
S_INPUTS="[{\"txid\":\"$MAIN_TX_ID\",\"vout\":0,\"sequence\":4294967293}]"
S_OUTPUTS="{\"$ADDR_TEST\":0.0001}"
TX_SIGN_PREP=$(bitcoin-cli -regtest createrawtransaction "$S_INPUTS" "$S_OUTPUTS")
check_cmd "Simple TX" "TX_SIGN_PREP" "$TX_SIGN_PREP"

# CHALLENGE 7: Child Pays For Parent (CPFP)
echo "CHALLENGE 7: CPFP Fee Bumping"
P_TXID=$(echo "$CHECK_DECODE" | jq -r '.txid')
C_INDEX=$(echo "$CHECK_DECODE" | jq -r --arg addr "$REMAINDER_A" '.vout[] | select(.scriptPubKey.address == $addr) | .n')

CHILD_IN="[{\"txid\":\"$P_TXID\",\"vout\":$C_INDEX}]"
CHILD_FEE=$(( (10 + 68 + 31) * 20 ))
CHILD_TOTAL=$(( BACK_SATS - CHILD_FEE ))

CHILD_BTC=$(awk "BEGIN {printf \"%.8f\", $CHILD_TOTAL / 100000000}")
CHILD_ADDR="2MvM2nZjueT9qQJgZh7LBPoudS554B6arQc"
CHILD_OUT="{\"$CHILD_ADDR\":$CHILD_BTC}"

TX_CPFP=$(bitcoin-cli -regtest createrawtransaction "$CHILD_IN" "$CHILD_OUT")
check_cmd "CPFP Hex" "TX_CPFP" "$TX_CPFP"

# CHALLENGE 8: Relative Timelock (CSV)
echo "CHALLENGE 8: Timelock Implementation (CSV)"
SEC_DECODE=$(bitcoin-cli -regtest decoderawtransaction "$RAW_SEC")
SEC_TXID=$(echo "$SEC_DECODE" | jq -r '.txid')
SEC_VAL=$(echo "$SEC_DECODE" | jq '.vout[1].value * 100000000 | round')

TIME_IN="[{\"txid\":\"$SEC_TXID\",\"vout\":1,\"sequence\":10}]"
TIME_VAL=$(( SEC_VAL - 1000 ))
TIME_BTC=$(awk "BEGIN {printf \"%.8f\", $TIME_VAL / 100000000}")
TIME_ADDR="bcrt1qxhy8dnae50nwkg6xfmjtedgs6augk5edj2tm3e"
TIME_OUT="{\"$TIME_ADDR\":$TIME_BTC}"

TX_TIMELOCK=$(bitcoin-cli -regtest createrawtransaction "$TIME_IN" "$TIME_OUT")
check_cmd "Timelock Hex" "TX_TIMELOCK" "$TX_TIMELOCK"

echo ""
echo "✨ ALL CHALLENGES COMPLETED ✨"
echo ""
echo $TX_TIMELOCK
