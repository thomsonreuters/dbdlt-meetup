package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

func main() {
	if err := shim.Start(new(Contract)); err != nil {
		fmt.Printf("Error creating new contract: %s", err)
	}
}

// Contract ...
type Contract struct {
}

// Init ...
func (c *Contract) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

// Invoke ...
func (c *Contract) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, args := stub.GetFunctionAndParameters()

	switch function {
	case "get":
		return c.get(stub, args)
	case "all":
		return c.all(stub, args)
	case "add":
		return c.add(stub, args)
	case "update":
		return c.update(stub, args)
	case "delete":
		return c.delete(stub, args)
	case "query":
		return c.query(stub, args)
	case "history":
		return c.history(stub, args)
	case "bulk":
		return c.bulk(stub, args)
	}
	return shim.Error("Invalid function name: " + function)
}

func (c *Contract) get(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Expected single key arg")
	}

	state, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(state)
}

func (c *Contract) all(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	itr, err := stub.GetStateByRange("", "")
	if err != nil {
		return shim.Error(err.Error())
	}
	defer itr.Close()

	var results []string
	for itr.HasNext() {
		state, err := itr.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		results = append(results, fmt.Sprintf("{\"key\": \"%s\", \"value\": %s}", state.Key, state.Value))
	}

	return shim.Success([]byte(fmt.Sprintf("[%s]", strings.Join(results, ","))))
}

func (c *Contract) bulk(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	for _, i := range args {
		err := stub.PutState(uuid(), []byte(i))
		if err != nil {
			return shim.Error(err.Error())
		}
	}

	return shim.Success([]byte("SUCCESS"))
}

func (c *Contract) add(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	id := uuid()
	data := []byte(args[0])
	if len(args) == 2 {
		id = args[0]
		data = []byte(args[1])
	}

	err := stub.PutState(id, data)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success([]byte(id))
}

func (c *Contract) update(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Expected key and value args")
	}

	err := stub.PutState(args[0], []byte(args[1]))
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func (c *Contract) delete(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	err := stub.DelState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func (c *Contract) query(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Expected single query arg")
	}

	itr, err := stub.GetQueryResult(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	defer itr.Close()

	var results []string
	for itr.HasNext() {
		state, err := itr.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		results = append(results, fmt.Sprintf("{\"key\": \"%s\", \"value\": %s}", state.Key, state.Value))
	}

	return shim.Success([]byte(fmt.Sprintf("[%s]", strings.Join(results, ","))))
}

func (c *Contract) history(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Expected single key arg")
	}

	itr, err := stub.GetHistoryForKey(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	var results []string
	for itr.HasNext() {
		state, err := itr.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		results = append(results, fmt.Sprintf("{\"txid\": \"%s\", \"deleted\": %v, \"timestamp\": \"%v\", \"value\": %s}",
			state.TxId, state.IsDelete, state.Timestamp, state.Value))
	}

	return shim.Success([]byte(fmt.Sprintf("[%s]", strings.Join(results, ","))))
}

func uuid() string {
	var u [16]byte
	if _, err := rand.Read(u[:]); err != nil {
		panic(err)
	}

	u[6] = (u[6] & 0x0f) | (4 << 4)
	u[8] = (u[8] & 0xbf) | 0x80

	buf := make([]byte, 36)
	hex.Encode(buf[0:8], u[0:4])
	buf[8] = '-'
	hex.Encode(buf[9:13], u[4:6])
	buf[13] = '-'
	hex.Encode(buf[14:18], u[6:8])
	buf[18] = '-'
	hex.Encode(buf[19:23], u[8:10])
	buf[23] = '-'
	hex.Encode(buf[24:], u[10:])

	return string(buf)
}
