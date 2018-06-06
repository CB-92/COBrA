pragma solidity 0.4.23;

contract BaseContentManagement {

    bytes32 public title;
    bytes32 public author;
    bytes32 public genre;
    bytes32 private content;

    address catalogAddress;
    mapping (address => bool) allowedUsers;

    constructor(bytes32 _title, bytes32 _author, bytes32 _genre) public{
        title = _title;
        author = _author;
        genre = _genre;
    }

    modifier onlyIfAllowed(address _user){
        require(
            allowedUsers[_user] == true,
            "User not allowed"
        );
        _;
    }

    modifier isCatalog{
        require(
            msg.sender == catalogAddress,
            "Only the Catalog could perform this action!"
        );
        _;
    }

    function grantAccess(address _user) external isCatalog{
        allowedUsers[_user] = true;
    }

    function consumeContent(address _user) external isCatalog onlyIfAllowed(_user) returns(bytes32){
        allowedUsers[_user] = false;
        return content;
    }
    
}