export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_BANK_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/peers/peer0.bank.example.com/tls/ca.crt
export PEER0_INVESTMENTFIRM_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/investmentfirm.example.com/peers/peer0.investmentfirm.example.com/tls/ca.crt
export PEER0_CLEARINGHOUSE_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/clearinghouse.example.com/peers/peer0.clearinghouse.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Bank() {
    export CORE_PEER_LOCALMSPID="BankMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BANK_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/users/Admin@bank.example.com/msp
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/peers/peer0.bank.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Bank() {
    export CORE_PEER_LOCALMSPID="BankMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BANK_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bank.example.com/users/Admin@bank.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

setGlobalsForPeer0InvestmentFirm() {
    export CORE_PEER_LOCALMSPID="InvestmentFirmMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INVESTMENTFIRM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/investmentfirm.example.com/users/Admin@investmentfirm.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1InvestmentFirm() {
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

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/chaincode/
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}

# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/chaincode"
CC_NAME="trade-network"

packageChaincode() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.bank ===================== "
}

# packageChaincode

installChaincode() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.bank ===================== "

    setGlobalsForPeer0InvestmentFirm
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.investmentfirm ===================== "
    
    setGlobalsForPeer0ClearingHouse
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.clearinghouse ===================== "

}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.bank on channel ===================== "
}

# queryInstalled

approveForMyBank() {
    setGlobalsForPeer0Bank
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from Bank ===================== "

}

# approveForMyBank

checkCommitReadyness() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Bank ===================== "
}

# checkCommitReadyness

approveForMyInvestmentFirm() {
    setGlobalsForPeer0InvestmentFirm

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Invesment Firm ===================== "
}

# approveForMyInvestmentFirm

checkCommitReadyness() {

    setGlobalsForPeer0Bank
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BANK_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Bank ===================== "
}

# checkCommitReadyness

approveForMyClearingHouse() {
    setGlobalsForPeer0ClearingHouse

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from Clearing House ===================== "
}

# approveForMyClearingHouse

checkCommitReadyness() {

    setGlobalsForPeer0Bank
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BANK_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from Bank ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BANK_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INVESTMENTFIRM_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_CLEARINGHOUSE_CA \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Bank
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Bank
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_BANK_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INVESTMENTFIRM_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_CLEARINGHOUSE_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Bank

    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_BANK_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_INVESTMENTFIRM_CA \
        -c '{"Args":["createTrade", "T2", "GOOGL", "50", "2800", "2024-12-20T12:00:00Z", "Pending"]}'
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0InvestmentFirm
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryTrade", "T2"]}'

}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode

queryInstalled
approveForMyBank
# checkCommitReadyness
approveForMyInvestmentFirm
# checkCommitReadyness
approveForMyClearingHouse
checkCommitReadyness

commitChaincodeDefination
queryCommitted
chaincodeInvokeInit

sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
