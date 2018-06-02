pragma solidity 0.4.23;

contract Catalog {
    address public creator;
    uint contentPayment;
    
    uint premiumTime;
    uint lastElementsNumber;

    constructor() public{
        creator = msg.sender;
        /* 1 month = (30 days * 24 h * 60 min * 60 sec) / 14 seconds per block = 185143 blocks */
        premiumTime = 185143;
    }

    struct User{
        address id;
        bool isPremium;
        uint premiumStartBlock;
    }

    /* Refer users through an username is more user_friendly than refer them using an address!*/
    mapping (string => User) users;

    mapping (address => string) addressToName;

    /* modifier to restrict a functionality only to Premium users */
    modifier restrictToPremium{
        require(
            users[addressToName[msg.sender]].premiumStartBlock + premiumTime > block.number,
            "Access restricted to Premium accounts!"
        );
        _;
    }

    modifier onlyCreator{
        require(
            msg.sender == creator,
            "Only Catalog creator could perform this action"
        );
        _;
    }

    /* List of content identifiers */
    string[] contentList;
    
    

    /*
        pure -> non legge e non scrive storage
        view -> non scrive storage
        external -> può essere chiamata solo da fuori, consuma meno gas di public
    */

    function GetStatistic() external view {

    }

    function GetContentList() external view{

    }

    function GetNewContentsList(uint _x) external view{

    }

    function GetLatestByGenre(string _genre) external view returns (string){

    }

    function GetMostPopularByGenre(string _genre) external view{

    }

    function GetLatestByAuthor(string _autor) external view{

    }

    function IsPremium(string _user) external view returns (bool){
        require(users[_user].isPremium);
        if(users[_user].premiumStartBlock + premiumTime > block.number)
            return true;
        else return false;
    }

    function GetContent(string _content) external{

    }

    function GetContentPremium(string _content) external restrictToPremium{

    }

    function GiftContent(string _content, string _user) external{

    }

    function GiftPremium(string _user) external{

    }

    function BuyPremium() external{

    }

    function CloseCatalog() external onlyCreator{
        /* TODO: pagare autori in proporzione alle views */
        selfdestruct(creator);
    }

}