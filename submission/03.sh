# Create a SegWit address.
# Add funds to the address.
# Return only the Address
address=$(bitcoin-cli -regtest getnewaddress "" bech32)
# Generate 101 blocks to the address to make the coinbase output mature
bitcoin-cli -regtest generatetoaddress 101 $address > /dev/null
# Return only the Address
echo $address