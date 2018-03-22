package main

import (
	"fmt"
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

func checkInit(t *testing.T, stub *shim.MockStub, args [][]byte) {
	res := stub.MockInit("1", args)
	if res.Status != shim.OK {
		fmt.Println("Init failed", string(res.Message))
		t.FailNow()
	}
}

func checkState(t *testing.T, stub *shim.MockStub, key, value string) {
	bytes := stub.State[key]
	if bytes == nil {
		fmt.Println("State", key, "failed to get value")
		t.FailNow()
	}
	if string(bytes) != value {
		fmt.Println("State value", key, "was not", value, "as expected")
		t.FailNow()
	}
}

func checkInvoke(t *testing.T, stub *shim.MockStub, args [][]byte) string {
	res := stub.MockInvoke("1", args)
	if res.Status != shim.OK {
		fmt.Println("Invoke", args, "failed", string(res.Message))
		t.FailNow()
	}
	return string(res.Payload)
}

func Test_Init(t *testing.T) {
	scc := new(Contract)
	stub := shim.NewMockStub("contract", scc)
	checkInit(t, stub, [][]byte{})
}

func Test_AddEntry(t *testing.T) {
	scc := new(Contract)
	stub := shim.NewMockStub("contract", scc)

	checkInit(t, stub, [][]byte{})

	id := checkInvoke(t, stub, [][]byte{[]byte("add"), []byte("test data")})
	checkState(t, stub, id, "test data")
}

func Test_GetEntry(t *testing.T) {
	scc := new(Contract)
	stub := shim.NewMockStub("contract", scc)

	checkInit(t, stub, [][]byte{})

	id := checkInvoke(t, stub, [][]byte{[]byte("add"), []byte("test data")})
	val := checkInvoke(t, stub, [][]byte{[]byte("get"), []byte(id)})
	if val != "test data" {
		fmt.Println("State value", id, "was not", val, "as expected")
		t.FailNow()
	}
}

func Test_UpdateEntry(t *testing.T) {
	scc := new(Contract)
	stub := shim.NewMockStub("contract", scc)

	checkInit(t, stub, [][]byte{})
	id := checkInvoke(t, stub, [][]byte{[]byte("add"), []byte("test data")})
	checkState(t, stub, id, "test data")
	checkInvoke(t, stub, [][]byte{[]byte("update"), []byte(id), []byte("new data")})
	checkState(t, stub, id, "new data")
}

func Test_DeleteEntry(t *testing.T) {
	scc := new(Contract)
	stub := shim.NewMockStub("contract", scc)

	checkInit(t, stub, [][]byte{})
	id := checkInvoke(t, stub, [][]byte{[]byte("add"), []byte("test data")})
	checkState(t, stub, id, "test data")
	checkInvoke(t, stub, [][]byte{[]byte("delete"), []byte(id)})
	if stub.State[id] != nil {
		fmt.Println("State for", id, "not deleted")
		t.FailNow()
	}
}

func Test_Query(t *testing.T) {
	// Cannot unit test query since it only works with Couchbase.
}
