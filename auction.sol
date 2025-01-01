// 1:Auction for Battle Participation
// 2:Auction for Perks and Advantages

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionContract{
    address public Owner;
    uint public auctionCounter;

    struct Detail{
        uint auctionId;
        uint startTime;
        uint endTime;
        uint minBid;
        address highestBidder;
        uint highestBid;
        bool isActive;
    }

    constructor(){
        Owner == msg.sender;
        auctionCounter = 1;
    }

    mapping (uint => Detail) public Auction;
    mapping (uint => mapping (address => uint))public RefundableBids;

    event AuctionStartd(uint auctionId, uint startTime, uint endTime,uint minBid);
    event BidPlaced(uint auctionId, address bidder, uint amount);
    event AuctionEnded(uint auctionId, address highestBidder, uint heighestBid);

    // FUNCTIONS

    function starAuction(uint duration, uint _minBid)external{
        require(duration > 0,"Enter Positive duration");
        require(_minBid >0,"Enter positive Min Bid");

        uint auctionId = auctionCounter;
        uint startTime = block.timestamp;
        uint endTime = startTime + duration;

        Auction[auctionId] = Detail({
            auctionId: auctionCounter,
            startTime: startTime,
            endTime: endTime,
            minBid: _minBid,
            highestBidder: address(0),
            highestBid: 0,
            isActive: true
    });
    emit AuctionStartd(auctionId, startTime, endTime, _minBid);
    auctionCounter++;
    }

    function placeBid(uint auctionId)external payable {

        Detail storage detail = Auction[auctionId];

        require(detail.endTime > block.timestamp);
        require(detail.startTime < block.timestamp);
        require(detail.isActive);
        require(msg.value>= detail.minBid);
        require(msg.value > detail.highestBid);

        //check if the previous heighest bidder exists
        // if yes then add his bid to his refundable amount
        if(detail.highestBidder != address(0)){
            RefundableBids[auctionId][detail.highestBidder] += detail.highestBid;
        }

        // update the new heighest bid
        detail.highestBid = msg.value;
        detail.highestBidder = msg.sender;

        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    function withDrawRefund(uint auctionId)external {
        uint amount = RefundableBids[auctionId][msg.sender];

        require(amount > 0,"No pending refund");

        amount = 0;
        payable (msg.sender).transfer(amount);
    }

    function endAuciton(uint auctionId) external {
        Detail storage details = Auction[auctionId];

        require(block.timestamp > details.startTime);
        require(details.isActive,"No longer active");

        details.isActive = false;
        emit AuctionEnded(auctionId, details.highestBidder, details.highestBid);
    }

    function getRefundableAmount(uint auctionId, address user) external view returns (uint){
        return RefundableBids[auctionId][user];
    }
    function AuctionDetails(uint auctionId)external  view returns (Detail memory){
        return Auction[auctionId];
    }

}