pragma solidity ^0.4.23;

import "./Ownable.sol";

contract TaxReserve is Ownable {
    event Remitted(uint256 indexed _ref, uint256[] _ids);
    event Refunded(uint256 indexed _id, address indexed _from, address indexed _to, uint256 _principle, uint256 _tax);

    struct Transaction {
        uint id;
        address from;
        address to;
        uint256 principle;
        uint256 tax;
        uint256 blockNumber;
        bool expired;
    }

    uint256 public transactionCount = 0;
    mapping (uint256 => Transaction) public transactions;

    constructor(address _owner) public {
        require(address(owner) != 0x0);
        owner = _owner;
        //grantAccess(msg.sender);
    }

    /*
        Remit principle payment to payee and keep tax on reserve contract
        
        example: "asdf", ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c"], ["1000000000000000000"], ["1000000000000000000"]
    */
    function remit(uint256 ref, address[] _to, uint256[] _principle, uint256[] _tax) external payable {
        require(msg.value > 0 && _to.length > 0);
        require(_to.length == _principle.length && _to.length == _tax.length);
        
        uint256 total = 0;
        uint256[] memory txids = new uint256[](_to.length);
        
        for (uint256 i = 0; i < txids.length; i++) {
            address(_to[i]).transfer(_principle[i]);
            
            total += _principle[i] + _tax[i];
            uint256 id = transactionCount = transactionCount + 1;
            
            Transaction storage trx = transactions[id];
            trx.id = id;
            trx.from = msg.sender;
            trx.to = _to[i];
            trx.principle = _principle[i];
            trx.tax = _tax[i];
            trx.blockNumber = block.number;
            trx.expired = false;
            
            txids[i] = id;
         }
        
        require(msg.value == total);
        emit Remitted(ref, txids);
    }
    
    function refundImpl(uint256 _id, uint256 _amount, uint256 _tax) private {
        Transaction memory trx = transactions[_id];
        require(!trx.expired);                      // can only refund non-expired txs
        require(trx.principle >= _amount);          // ensure not trying to refund more than a tx has.
        require(trx.tax >= _tax);                   // ensure not trying to refund more than a tx has.
        require(trx.to == msg.sender);              // ensure refund is being sent by merchant who originally recieved the funds.

        // send payments. principle payment needs to succeed for tax payment to be paid.
        trx.from.transfer(_amount);
        trx.from.transfer(_tax);

        // update transaction with info so tax can't be stolen on future refunds against same tx.
        transactions[_id].principle = transactions[_id].principle - _amount;
        transactions[_id].tax = transactions[_id].tax - _tax;

        emit Refunded(trx.id, msg.sender, trx.from, _amount, _tax);
    }

    /*
        Refund principle and tax to original payor.
        
        example: ["1"], ["1000000000000000000"], ["1000000000000000000"]
    */
    function refund(uint256[] _ids, uint256[] _amounts, uint256[] _taxs) external payable {
        require(msg.value > 0);                     // Make sure an actual refund is being given.

        require(_ids.length == _amounts.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            refundImpl(_ids[i], _amounts[i], _taxs[i]);
        }
    }

    /*
        Expires all transactions 'before' a given block number.
    */
    function expire(uint256 _beforeBlockNumber) external onlyOwner {
        require(_beforeBlockNumber < block.number);
        for (uint i = 0; i < transactionCount; i++) {
            if (transactions[i].blockNumber < _beforeBlockNumber) {
                transactions[i].expired = true;
            }
        }
    }

    /*
        Transfers given amount to sepcified address.
    */
    function withdrawal(address _to, uint256 _amount) external onlyOwner {
        _to.transfer(_amount);
    }

    /*
        Retire contract so that it's not callable any longer.
    */
    function retire() external onlyOwner {
        require(address(this).balance == 0);
        selfdestruct(msg.sender);
    }

}
