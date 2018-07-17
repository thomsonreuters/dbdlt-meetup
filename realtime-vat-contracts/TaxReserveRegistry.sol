pragma solidity ^0.4.23;

import "./Ownable.sol";

contract TaxReserveRegistry is Ownable {
    mapping(uint => address) public reserves;

    /*
        Add a new reserve to the registry
        so it can be looked up.
    */
    function add(uint _id, address _addr) external onlyOwner {
        require(_addr != address(0));
        reserves[_id] = _addr;
    }

    /*
        Bulk update method used if upgrading all
        jurisdictional contracts at once.
    */
    function update(uint[] _ids, address[] _addrs) external onlyOwner {
        require (_ids.length == _addrs.length);
        for (uint i = 0; i < _ids.length; i++) {
            reserves[_ids[i]] = _addrs[i];
        }
    }

    /* 
        If this contract is upgraded/obsoleted
        this method should be called to remove
        it from etherum state so it can no longer
        be called.
    */
    function retire() external onlyOwner {
        selfdestruct(owner);
    }
}