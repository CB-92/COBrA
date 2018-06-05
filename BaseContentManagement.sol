pragma solidity 0.4.23;

contract BaseContentManagement {

    string title;
    string author;
    string genre;
    uint views;

    address catalogAddress;
    mapping (address => bool) allowedUsers;

    constructor(string _title, string _author, string _genre) public{
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

    function consumeContent(address _user) external isCatalog onlyIfAllowed(_user){
        allowedUsers[_user] = false;
    }
    
}