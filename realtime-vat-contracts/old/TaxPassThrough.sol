pragma solidity ^0.4.22;

import "./Ownable.sol";

contract TaxPassThrough is Ownable {

    event transactionIDs(uint cartID, uint[] ids);
    event DeployedStructReserve(address  taxReserve, uint  _jurId, address creator);
    event ChangedJurId(address addr, uint oldId, uint newId);

    mapping(uint => address) public juristictionLookup;

    function addReserve(uint _jurId, address _addr)
        public
        onlyOwner
        returns (bool)
    {
        require(_addr != address(0));
        juristictionLookup[_jurId] = _addr;
        emit DeployedStructReserve(_addr, _jurId, msg.sender);
        return true;
    }

    function changeJurID(uint oldJurId, uint newJurId)
        public
        onlyOwner
        returns (bool)
    {
        address taxReserve = juristictionLookup[oldJurId];
        emit ChangedJurId(taxReserve, oldJurId, newJurId);
        juristictionLookup[oldJurId] = address(0);
        juristictionLookup[newJurId] = taxReserve;
        return true;
    }

    function getJurAddress(uint _jurID)
        external view
        returns (address)
    {
        return juristictionLookup[_jurID];
    }

    //map from transactionID to transaction struct
    mapping(uint256 => Transaction) private transactionMap;
    //number of transactions - used for transactionIDs
    uint256 public transactionCount = 0;

    struct Transaction {
        //who made the payment
        address user;
        //id number of this transaction
        uint256 id;
        //how much they paid
        uint256 amount;
        //which block this was added on
        uint256 blockNumber;
        //whether or not this transaction has been refunded yet
        bool refunded;
    }

    function payStructs(uint _cartID, address[] _merchantPaymentArray, uint[] _merchantAmntArray, uint[] _taxPaymentIDs, uint[] _taxAmntArray) 
    public 
    payable
    returns(uint256[]) {
        address[] memory taxPaymentArray = new address[](_taxPaymentIDs.length);
        for (uint x = 0 ; x < taxPaymentArray.length;x++) {
            taxPaymentArray[x] = juristictionLookup[_taxPaymentIDs[x]];
        }
        payMerchants(_merchantPaymentArray,_merchantAmntArray);
        uint256[] memory txIDs = makeTaxPaymentsStructs(taxPaymentArray, _taxAmntArray);
        emit transactionIDs(_cartID, txIDs);
        return txIDs;
    }

    function payMerchants(address[] _merchantPaymentArray, uint[] _merchantAmntArray) 
    internal
    returns (bool) {
        require(_merchantPaymentArray.length == _merchantAmntArray.length);
        for (uint i = 0 ; i < _merchantPaymentArray.length; i++) {
            _merchantPaymentArray[i].transfer(_merchantAmntArray[i]);
        }
        return true;
    }

    function makeTaxPaymentsStructs(address[] _toArray, uint[] _amntArray) 
    internal
    returns (uint256[]) {
        require(_toArray.length == _amntArray.length);
        uint256[] memory txnIDs = new uint256[](_toArray.length);
        for (uint i = 0 ; i < _toArray.length; i++) {
            
            uint256 txid = transactionCount + 1;

            Transaction storage t = transactionMap[txid];
            t.user = msg.sender;
            t.id = txid;
            t.amount = _amntArray[i];
            t.blockNumber = block.number;
            t.refunded = false;

            transactionCount = txid;

            address reserve = _toArray[i];
            reserve.transfer(_amntArray[i]);
            txnIDs[i] = txid;

        }
        return txnIDs;
    }


    event Log(string msg);
    event Log2(address res, address to, uint256 id, uint256 amt);

    function getReturns(uint256[] _reserves, uint[] _txIDs) public view returns (address, address, uint256, uint256) {
        require(_reserves.length == _txIDs.length);
        //emit Log("getReturns entry...");
        
        // only support single jurisdiction at the moment.
        for (uint i = 0; i < _reserves.length; i++) {
           //require(transactionMap[_txIDs[i]].refunded == false);
        
            //emit Log("attempting to returnEth");

            address reserve = juristictionLookup[_reserves[i]];
            address payTo = transactionMap[_txIDs[i]].user;
            uint256 payTx = _txIDs[i];
            uint256 payAmt = transactionMap[_txIDs[i]].amount;
            //emit Log2(reserve, payTo, payTx, payAmt);
            // should really only be set after the refund call happens.
            //transactionMap[_txIDs[i]].refunded = true;


            return (reserve, payTo, payTx, payAmt);

            //require(reserve.call(bytes4(keccak256("test()"))));
           // require(reserve.call(bytes4(keccak256("returnEth(address, uint256, uint256)")), payTo, payTx, payAmt));

            //emit Log("call made...");
        }

        return (0x0, 0x0, 0, 0);
    }

}
