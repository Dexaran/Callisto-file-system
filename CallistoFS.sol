pragma solidity ^0.4.19;

import './safeMath.sol';

contract Callisto_FS {
    
    using SafeMath for uint256;
    
    mapping (string => entity) files;
    
    struct entity
    {
        uint256 deposit;
        address owner;
        uint256 size;
    }
    
    event FileUpload(string indexed _hash, uint256 indexed _deposit, uint256 indexed _size);
    event FileWithdrawn(string indexed _hash, uint256 indexed _remaining);
    
    function upload(string _hash, uint256 _size) payable
    {
        files[_hash].owner   = msg.sender;
        files[_hash].deposit = files[_hash].deposit.add(msg.value);
        files[_hash].size    = _size;
        emit FileUpload(_hash, msg.value, _size);
    }
    
    function deposit(string _hash) payable
    {
        files[_hash].deposit = files[_hash].deposit.add(msg.value);
    }
    
    function withdraw(string _hash, uint256 _amount) only_owner(_hash)
    {
        files[_hash].deposit = files[_hash].deposit.sub(_amount);
        msg.sender.transfer(_amount);
        emit FileWithdrawn(_hash, files[_hash].deposit);
    }
    
    function reallocate(string _hash, string _new_hash, uint256 _new_size) only_owner(_hash)
    {
        files[_new_hash].deposit = files[_hash].deposit;
        files[_hash].deposit     = 0;
        
        files[_new_hash].owner   = msg.sender;
        files[_new_hash].size    = _new_size;
        emit FileUpload(_new_hash, files[_new_hash].deposit, _new_size);
        emit FileWithdrawn(_hash, 0);
    }
    
    modifier only_owner(string _hash)
    {
        require(msg.sender == files[_hash].owner);
        _;
    }
}
