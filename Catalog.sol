pragma solidity ^0.4.23;
pragma experimental ABIEncoderV2;
import "./BaseContentManagement.sol";

contract Catalog {
    address public creator;
    uint contentPrice;
    uint premiumTime;
    uint premiumPrice;
    /* List of content identifiers */
    bytes32[] contentList;
    uint paymentDelay;
    uint allTheViews;

    struct ContentMetadata{
        BaseContentManagement content;
        address authorAddress;
        bool isLinked;
        uint views;
        uint viewsSincePayed;
    }

    mapping(bytes32 => ContentMetadata) addedContents;

    constructor() public{
        creator = msg.sender;
        /* 1 day = (24 h * 60 min * 60 sec) / 14.93 seconds per block = 53788 blocks */
        premiumTime = 53788;
        contentPrice = 100;
        premiumPrice = 500;
        paymentDelay = 5;
        allTheViews = 0;
    }

    /* events */
    event AccessGranted(string _content, address _user);
    event NewLinkedContent(string _content);
    event ClosedCatalog();

    /* user address => block number of premium subscription*/
    mapping (address => uint) premiumUsers;

    /* modifier to restrict a functionality only to Premium users */
    modifier restrictToPremium{
        require(
            premiumUsers[msg.sender] + premiumTime > block.number,
            "Access restricted to Premium accounts!"
        );
        _;
    }

    modifier ifLinkedContent(bytes32 _content){
        require(
            addedContents[_content].isLinked == true,
            "Content not linked to the catalog!"
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

    /* Check account balance */
    modifier costs(uint _amount){
        require(
            msg.value == _amount,
            "You didn't pay the correct amount of money!"
        );
        _;
    }

    /* Converts a bytes32 value into a string value */
    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function LinkToTheCatalog(BaseContentManagement _bcm) external{
        bytes32 _title = _bcm.title();
        contentList.push(_title);
        addedContents[_title].content = _bcm;
        addedContents[_title].authorAddress = msg.sender;
        addedContents[_title].views = 0;
        addedContents[_title].viewsSincePayed = 0;
        addedContents[_title].isLinked = true;
        emit NewLinkedContent(bytes32ToString(_title));
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
            if(i==0) break;
        }
        return latests;
    }

    function GetLatestByGenre(bytes32 _genre) external view returns (string){
        string memory tmp;
        for (uint i = contentList.length - 1; i>=0; i--){
            if (addedContents[contentList[i]].content.genre() == _genre){
                tmp = bytes32ToString(contentList[i]);
                break;
            }
            if(i == 0)
                break;
        }
        return tmp;
    }

    function GetMostPopularByGenre(bytes32 _genre) external view returns (string){
        uint max = 0;
        string memory tmp;
        for(uint i = 0; i<contentList.length; i++){
            if(addedContents[contentList[i]].content.genre() == _genre &&
            addedContents[contentList[i]].views > max){
                max = addedContents[contentList[i]].views;
                tmp = bytes32ToString(contentList[i]);
            }
        }
        return tmp;
    }

    function GetLatestByAuthor(bytes32 _author) external view returns (string){
        string memory tmp;
        for (uint i = contentList.length - 1; i>=0; i--){
            if (addedContents[contentList[i]].content.author() == _author){
                tmp = bytes32ToString(contentList[i]);
                break;
            }
            if(i == 0)
                break;
        }
        return tmp;

    }

    function GetMostPopularByAuthor(bytes32 _author) external view returns(string){
        uint max = 0;
        string memory tmp;
        for(uint i = 0; i<contentList.length; i++){
            if(addedContents[contentList[i]].content.author() == _author &&
            addedContents[contentList[i]].views > max){
                max = addedContents[contentList[i]].views;
                tmp = bytes32ToString(contentList[i]);
            }
        }
        return tmp;
    }

    function IsPremium(address _user) external view returns (bool){
        if(premiumUsers[_user] + premiumTime > block.number)
            return true;
        else return false;
    }

    function GetContent(bytes32 _content) external payable costs(contentPrice) ifLinkedContent(_content) returns (address){
        addedContents[_content].content.grantAccess(msg.sender);
        addedContents[_content].views++;
        addedContents[_content].viewsSincePayed++;

        /* Pay authors every paymentDelay views */
        if(addedContents[_content].viewsSincePayed == paymentDelay){
            addedContents[_content].authorAddress.transfer(paymentDelay * contentPrice);
            addedContents[_content].viewsSincePayed = 0;
        }
        emit AccessGranted(bytes32ToString(_content), msg.sender);
        return addedContents[_content].authorAddress;
    }

    function GetContentPremium(bytes32 _content) external restrictToPremium returns (address){
        addedContents[_content].content.grantAccess(msg.sender);
        emit AccessGranted(bytes32ToString(_content), msg.sender);
        return addedContents[_content].authorAddress;
    }

    function GiftContent(bytes32 _content, address _user) external payable costs(contentPrice) ifLinkedContent(_content) returns(address){
        addedContents[_content].content.grantAccess(_user);
        emit AccessGranted(bytes32ToString(_content), _user);
        return addedContents[_content].authorAddress;
    }

    function GiftPremium(address _user) external payable costs(premiumPrice) {
        premiumUsers[_user] = block.number;
    }

    function BuyPremium() external payable costs(premiumPrice){
        premiumUsers[msg.sender] = block.number;
    }

    function CloseCatalog() external onlyCreator{
        for(uint i = 0; i<contentList.length; i++){
            uint toTransfer = address(this).balance * addedContents[contentList[i]].views / allTheViews;
            addedContents[contentList[i]].authorAddress.transfer(toTransfer);
            emit ClosedCatalog();
        }
        selfdestruct(creator);
    }

}