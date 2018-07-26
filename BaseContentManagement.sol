pragma solidity ^0.4.23;
import "./Catalog.sol";

contract BaseContentManagement {
    bytes32 public title;
    bytes32 public author;
    bytes32 public genre;
    bytes32[] internal content;
    address internal catalogAddress;
    Catalog internal catalog;

    mapping (address => bool) allowedUsers;

    modifier onlyIfAllowed(){
        require(
            allowedUsers[msg.sender] == true,
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

    function consumeContent() external onlyIfAllowed() returns(bytes32[]){
        allowedUsers[msg.sender] = false;
        if(catalog.IsPremium(msg.sender)==false){
            catalog.AddViews(title);
        }

        return content;
    }
    
}