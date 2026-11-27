// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract auctionContract {

    uint public item_ID;

    address public Owener;
    
    constructor() {Owener = msg.sender;}

    // Open Account Both Aucton Holder and Buyer

    // Holders
    struct Holder {
        string holderName;
        uint holderNumber;
        string holderMail;
        uint holderBalance;
    }
    mapping(address => Holder) public holder;
    mapping(address => bool) public isHolder;
    // Biders
    struct Biders {
        string biderName;
        uint biderNumber;
        string biderMail;
        uint biderBalance;
        string [] itemsBroughtbyBidder;
    }
    mapping(address => Biders) public biders;
    mapping(address => bool) public isBider;

     // Mapping
     struct Auction {
        string auctionItem;
        address auctionHolder;
        uint auctionMinimumBid;
        uint auctionEnd;
     }
    mapping(uint => Auction) public auction;
    struct History {
        address sellet_Address;
        address buyer_Address;
        uint sellingPrice;
    }
    mapping(uint => History) public history;
    struct Highest{
        address _bidderAddress;
        uint _bidderAmount;
    }
    mapping(uint => Highest) public highestBidder;
    // Holder Function Details 
    function holderData(string memory _name, uint __number, string memory _email) public {
        require(!isHolder[msg.sender], "You already ahve account");

        holder[msg.sender].holderName = _name;
        holder[msg.sender].holderNumber = __number;
        holder[msg.sender].holderMail = _email;

        isHolder[msg.sender] = true;
    }

    // Hold the Auction
    function holdAuction(string memory _itemName, uint _minimumPriceBid, uint _auctionEnd) public {
        // who's can call it in waht condition 
        require(isHolder[msg.sender], "You dont have any account, Please open the account");

        // Does state changes 
        auction[item_ID].auctionItem = _itemName;
        auction[item_ID].auctionHolder = msg.sender;
        auction[item_ID].auctionMinimumBid = _minimumPriceBid;
        auction[item_ID].auctionEnd = _auctionEnd * block.timestamp;

        // increase the Action id for unique numbering
        item_ID++;
       
    }
    // bidder Data 
    function bidderData(string memory _name, uint _number, string memory _mail ) public {
        require(!isBider[msg.sender], "You already have account");
        biders[msg.sender].biderName = _name;
        biders[msg.sender].biderNumber = _number;
        biders[msg.sender].biderMail = _mail;

        // 
        isBider[msg.sender] = true;
    }   
    // Bidders bidding place 
    function bidderPlace(uint _auction_itemID, address _holderAddress, uint _bidAmount) public {
        // who can call it in what condition 
        require(isBider[msg.sender], "You arenotin the list First opne the Account ");
        require(!isHolder[msg.sender], "You are hosting the Bid So you can not paticipant in it");
        require(_auction_itemID < item_ID, 'Auction does not Exist');
        require(auction[_auction_itemID].auctionEnd > block.timestamp, "Auction has Already Ended");
        require(_bidAmount > auction[_auction_itemID].auctionMinimumBid, "Bid must be higher, Try Again");
        // does state chages
       
        if(_bidAmount > auction[_auction_itemID].auctionMinimumBid) {
            auction[_auction_itemID].auctionMinimumBid = _bidAmount;
            highestBidder[_auction_itemID] = Highest(msg.sender, _bidAmount);

        }
    }

    // fucntion for transfer highest bidder to is item and auction owner to he money
    function winner(uint _auction_ID) public {
        // whos can call this fucntion under what condition 
        require(msg.sender == Owner, "You areno the owner");
        require(_auction_ID < item_ID, "This auction does not exist");
        require(auction[_auction_ID].auctionEnd > block.timestamp, "Auction has Ended");
        // get money from buyer and give to the seller
        address buyer = highestBidder[_auction_ID]._bidderAddress;
        uint price = highestBidder[_auction_ID]._bidderAmount;
        address seller = auction[_auction_ID].auctionHolder;
        string memory item = highestBidder[_auction_ID].
        
        // Trade
        biders[buyer].biderBalance -= price;
        holder[seller].holderBalance += price;
        biders[buyer].itemsBroughtbyBidder.push(auction[_auction_ID].auctionItem);
        
        // Auction history store
        history[_auction_ID] = History(seller, buyer, price);
        // remove the auction here
        delete auction[_auction_ID];
        
    }
     // Deposit Money buy bidders;
    function deposit(uint _amount) public {
        require(isBider[msg.sender], "You name is not in the list Please Open the Account");
        require(_amount > 0, "Amount should be greater then zero");
        biders[msg.sender].biderBalance += _amount;
    }
    // Normal Withdrawal
    function withdrawl(uint _amount) public {
        // Check
        require(isBider[msg.sender], "You dont have account here, Please first open the account");
        require(_amount >= biders[msg.sender].biderBalance, "Insufficinet Balance");
        // Effect
        biders[msg.sender].biderBalance -= _amount;
        // Interaction 
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer Failed");
    }

    // Withdrawal Money after the Aution --- 

}