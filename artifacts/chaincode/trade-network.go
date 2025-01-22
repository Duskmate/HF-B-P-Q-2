package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
	"github.com/hyperledger/fabric/common/flogging"
)

// SmartContract Define the Smart Contract structure
type SmartContract struct {
}

// Trade represents a trade structure

type Trade struct {
	TradeID   string  `json:"trade_id"`
	Symbol    string  `json:"symbol"`
	Quantity  string  `json:"quantity"`
	Price     string  `json:"price"`
	Timestamp string  `json:"timestamp"`
	Status    string  `json:"status"`
}

// Payment represents a payment structure
type Payment struct {
	PaymentID string  `json:"payment_id"`
	Sender    string  `json:"sender"`
	Receiver  string  `json:"receiver"`
	Amount    float64 `json:"amount"`
	Timestamp string  `json:"timestamp"`
	Status    string  `json:"status"`
}

// Settlement represents a settlement structure
type Settlement struct {
	SettlementID string  `json:"settlement_id"`
	TradeID      string  `json:"trade_id"`
	PaymentID    string  `json:"payment_id"`
	Amount       float64 `json:"amount"`
	Timestamp    string  `json:"timestamp"`
	Status       string  `json:"status"`
}

// Init ;  Method for initializing smart contract
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

var logger = flogging.MustGetLogger("tradenetwork_cc")

// Invoke :  Method for INVOKING smart contract
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	function, args := APIstub.GetFunctionAndParameters()

	logger.Infof("Function name is:  %d", function)
	logger.Infof("Args length is : %d", len(args))

	if function == "queryTrade" {
		return s.queryTrade(APIstub, args)
	} else if function == "initLedger" {
		return s.initLedger(APIstub)
	} else if function == "createTrade" {
		return s.createTrade(APIstub, args)
	}
	return shim.Error("Invalid Smart Contract function name.")
}

func (s *SmartContract) queryTrade(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	tradeAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(tradeAsBytes)
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	trades := []Trade{
		Trade{TradeID: "T1", Symbol: "AAPL", Quantity: "100", Price: "150.00", Timestamp: "2024-12-20T10:00:00Z", Status: "Completed"},
	}

	i := 0
	for i < len(trades) {
		tradeAsBytes, _ := json.Marshal(trades[i])
		APIstub.PutState("TRADE"+strconv.Itoa(i), tradeAsBytes)
		i = i + 1
	}

	return shim.Success(nil)
}

func (s *SmartContract) createTrade(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 6 {
		return shim.Error("Incorrect number of arguments. Expecting 7")
	}

	var trade = Trade{TradeID: args[0], Symbol: args[1], Quantity: args[2], Price: args[3], Timestamp: args[4], Status: args[5]}

	tradeAsBytes, _ := json.Marshal(trade)
	APIstub.PutState(args[0], tradeAsBytes)

	return shim.Success(tradeAsBytes)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
