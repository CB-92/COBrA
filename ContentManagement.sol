pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract ContentManagement is BaseContentManagement{
    constructor(bytes32 _title, bytes32 _author, bytes32 _genre) public{
        new BaseContentManagement(_title, _author,  _genre);
    }
}