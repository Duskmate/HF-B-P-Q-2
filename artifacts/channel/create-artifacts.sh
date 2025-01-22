#Generate Crypto artifactes for organizations
cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block

# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for BankMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./BankMSPanchors.tx -channelID $CHANNEL_NAME -asOrg BankMSP

echo "#######    Generating anchor peer update for InvestmentFirmMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./InvestmentFirmMSPanchors.tx -channelID $CHANNEL_NAME -asOrg InvestmentFirmMSP

echo "#######    Generating anchor peer update for ClearingHouseMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./ClearingHouseMSPanchors.tx -channelID $CHANNEL_NAME -asOrg ClearingHouseMSP
