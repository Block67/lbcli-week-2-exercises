# Create a raw transaction with version 2
# Inputs:
# 1. txid: 23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16, vout: 0, sequence: 0xfffffffd
# 2. txid: 23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16, vout: 1, sequence: 0xfffffffd
# Output:
# 1. address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP, amount: 0.2 BTC
bitcoin-cli -regtest createrawtransaction '[{"txid":"23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16","vout":0,"sequence":4294967293},{"txid":"23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16","vout":1,"sequence":4294967293}]' '{"2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP":0.2}' 0 false 2