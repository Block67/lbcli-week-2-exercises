# Create a raw transaction with version 2
# Inputs: same as 07.sh
# Output: amount 0.23659108 BTC
bitcoin-cli -regtest createrawtransaction '[{"txid":"23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16","vout":0,"sequence":4294967293},{"txid":"23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16","vout":1,"sequence":4294967293}]' '{"2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP":0.23659108}' 0 false 2