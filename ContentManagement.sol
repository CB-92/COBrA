pragma solidity 0.4.23;

import "./BaseContentManagement.sol";

contract ContentManagement is BaseContentManagement{
    
    constructor(string _title, string _author, string _genre, address _catalogAddress)
    BaseContentManagement(_title, _author, _genre, _catalogAddress) public{
        Catalog(catalogAddress).LinkToTheCatalog();
    }

    event PaymentAvailable(bytes32 id);

    function grantAccess(address _user) external isCatalog{
        allowedUsers[_user] = true;
    }

    function consumeContent() external isCatalog onlyIfAllowed() returns(bytes32){
        allowedUsers[msg.sender] = false;
        if(!Catalog(catalogAddress).IsPremium(msg.sender)){
            views++;
            viewsSincePayed++;
        }

        if(viewsSincePayed == Catalog(catalogAddress).paymentDelay()){
            //Catalog(catalogAddress).CollectPayment();
            viewsSincePayed = 0;
            emit PaymentAvailable(title);
        }

        return content;
    }
}