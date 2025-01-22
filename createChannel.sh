export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_BANK_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/peers/peer0.bank.example.com/tls/ca.crt
export PEER0_INVESTMENTFIRM_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/investmentfirm.example.com/peers/peer0.investmentfirm.example.com/tls/ca.crt
export PEER0_CLEARINGHOUSE_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clearinghouse.example.com/peers/peer0.clearinghouse.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer(){
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
    
}

setGlobalsForPeer0Bank(){
    export CORE_PEER_LOCALMSPID="BankMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BANK_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/users/Admin@bank.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Bank(){
    export CORE_PEER_LOCALMSPID="BankMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BANK_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/users/Admin@bank.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0InvestmentFirm(){
    export CORE_PEER_LOCALMSPID="InvestmentFirmMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INVESTMENTFIRM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/investmentfirm.example.com/users/Admin@investmentfirm.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1InvestmentFirm(){
    export CORE_PEER_LOCALMSPID="InvestmentFirmMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INVESTMENTFIRM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/investmentfirm.example.com/users/Admin@investmentfirm.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

setGlobalsForPeer0ClearingHouse() {
    export CORE_PEER_LOCALMSPID="ClearingHouseMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLEARINGHOUSE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clearinghouse.example.com/users/Admin@clearinghouse.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

}

createChannel(){
    setGlobalsForPeer0Bank
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# createChannel


joinChannel(){
    setGlobalsForPeer0Bank
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1Bank
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0InvestmentFirm
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer1InvestmentFirm
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    sleep 2
    setGlobalsForPeer0ClearingHouse
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

# joinChannel

updateAnchorPeers(){
    setGlobalsForPeer0Bank
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0InvestmentFirm
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0ClearingHouse
    peer channel update -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.example.com \
    -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# updateAnchorPeers

# createChannel
# sleep 3
# joinChannel
# sleep 2
# updateAnchorPeers
