pragma solidity ^0.4.23;

contract Catalog {
    address public creator;
    uint contentPrice;
    uint premiumTime;
    uint lastElementsNumber;
    uint premiumPrice;
    /* List of content identifiers */
    bytes32[] contentList;

    constructor() public{
        creator = msg.sender;
        /* 1 month = (30 days * 24 h * 60 min * 60 sec) / 14 seconds per block = 185143 blocks */
        premiumTime = 185143;
    }


    /* Refer users through an username is more user_friendly than refer them using an address!*/
    mapping (string => address) nameToAddress;

    /* user address => block number of premium subscription*/
    mapping (address => uint) premiumUsers;

    /* content => allowed users */
    mapping (string => address[]) contentToAllowedUsers;

    /* modifier to restrict a functionality only to Premium users */
    modifier restrictToPremium{
        require(
            premiumUsers[msg.sender] + premiumTime > block.number,
            "Access restricted to Premium accounts!"
        );
        _;
    }

    /* Functionalities restricted to catalog creator only */
    modifier onlyCreator{
        require(
            msg.sender == creator,
            "Only Catalog creator could perform this action"
        );
        _;
    }
    
    /*function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }*/

    /* Check account balance */
    modifier costs(uint _amount){
        require(
            msg.value == _amount,
            "You didn't pay the correct amount of money!"
        );
        _;
    }
    

    /*
        pure -> non legge e non scrive storage
        view -> non scrive storage
        external -> può essere chiamata solo da fuori, consuma meno gas di public
    */

    function Register(string _username) external{
        nameToAddress[_username] = msg.sender;
    }

    function GetStatistics() external view returns (bytes32[], uint[]){

    }

    function GetContentList() external view returns (bytes32[]) {
        return contentList;
    }

    function GetNewContentsList(uint _x) external view returns (bytes32[]){
        bytes32[] memory latests = new bytes32[](_x);
        uint j = contentList.length - 1;
        for (uint i = _x - 1; i>=0; i--){
            latests[i] = contentList[j];
            j--;
        }
        return latests;
    }

    function GetLatestByGenre(string _genre) external view returns (string){

    }

    function GetMostPopularByGenre(string _genre) external view returns (string){

    }

    function GetLatestByAuthor(string _autor) external view returns (string){

    }

    function IsPremium(string _user) external view returns (bool){
        if(premiumUsers[nameToAddress[_user]] + premiumTime > block.number)
            return true;
        else return false;
    }

    function GetContent(string _content) external payable costs(contentPrice){
        contentToAllowedUsers[_content].push(msg.sender);
    }

    function GetContentPremium(string _content) external restrictToPremium{
        /* TODO */
    }

    function GiftContent(string _content, string _user) external payable costs(contentPrice){
        contentToAllowedUsers[_content].push(nameToAddress[_user]);
    }

    function GiftPremium(string _user) external payable costs(premiumPrice){
        premiumUsers[nameToAddress[_user]] = block.number;
    }

    function BuyPremium() external payable costs(premiumPrice){
        premiumUsers[msg.sender] = block.number;
    }

    function CloseCatalog() external onlyCreator{
        /* TODO: pagare autori in proporzione alle views */
        selfdestruct(creator);
    }

}