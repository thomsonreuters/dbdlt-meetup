pragma solidity ^0.4.22;

import "./Ownable.sol";

contract ReserveStructs is Ownable {

    event ID(uint256 id);
    event Initialized(address owner);
    event Limit(uint256 amount);
    event Received(address sender, uint256 amount);
    event Return(address recipient, uint256 transactionID, uint256 amount);
    event Sent(uint256 amount);

    //address of the tax authority whom a merchant will pay to
    address private taxAuth;

    //how much time is allowed after a transaction for a refund
    uint256 public refundTimeLimit;
    //limit on amount of ether stored in this contract. Extra ether is sent to
    //the tax authority address
    uint256 public reserveMaxBalance = 0;

    /**    Constructor for a basic reserve
     *     uint256 _refundTimeLimit the initial refundTimeLimit
     *     uint256 _reserveMaxValue the maximum reserve balance
     *     address _taxAuth the tax authority address
     *     address _owner the owner of the contract
     */
    //constructor(uint256 _refundTimeLimit, uint256 _reserveMaxValue, address _taxAuth, address _owner)
    constructor()
    public
    // onlyOwner 
    {
        owner = msg.sender;
        emit Initialized(msg.sender);
        // todo set these values.
        taxAuth = 0x0;
        reserveMaxBalance = 100;
        refundTimeLimit = 60;
    }

    /**    Function designating what to do when the contract receives ether.
     *    Upon receiving ether, the contract checks to see if the current balance stored in the
     *    contract is more than the allowed max balance and, if so, sends a Limit event with the 
     *    difference between the limit and the current balance. At the end, sends a "Received" event
     *    signaling that the contract was paid an amount and by who. Ideally, the customer *should*
     *    use the payEth function, but this accomplishes essentially the same thing, without 
     *    returning the transaction id (which is very important).
     */
    function () payable public {
        // this code causes transaction error. need to fix before limit/liquidate
        //if (address(this).balance > reserveMaxBalance) {
         //   uint256 overflow = address(this).balance - reserveMaxBalance;
         //   emit Limit(overflow);
       //}
        emit Received(msg.sender, msg.value);
    }

    function getOwner() public returns (address) {
        emit Initialized(owner);
        return owner;
    }

    /*Sets the refund time limit*/
    function setRefundTimeLimit(uint256 _refundTimeLimit) public
    onlyOwner
    returns (uint256) {
        emit ID(_refundTimeLimit);
        refundTimeLimit = _refundTimeLimit;
        return refundTimeLimit;
    }

    /*Returns the refund time limit*/
    function getRefundTimeLimit() public view returns (uint256) {
        return refundTimeLimit;
    }

    /**    Returns eth to the address corresponding to the _transactionID.
     *     uint256 _transactionID the txid that you want to return eth to.
     */
    function returnEth(address _addr, uint256 _id, uint256 _amount) public returns (bool) {
        _addr.transfer(_amount);
        emit Return(_addr, _id, _amount);
        return true;
    }

    /**    Sends x amount of eth stored in this contract to the address _to
     *     address _to the address to send the eth to.
     */
    function liquidate(address _to, uint256 amount) 
    public
    // onlyOwner // remove onlyOwner to allow liquidate by explicit unlock hack in the service
    returns (bool) {
        require(_to.send(amount));
        return true;
    }
}
