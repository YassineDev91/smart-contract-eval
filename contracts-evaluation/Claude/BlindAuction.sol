// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BlindAuction
 * @dev Implements a blind auction with revealed bids and timed phases
 */
contract BlindAuction {
    // Struct for a blinded bid
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    // Public state variables
    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    // Private state variables
    mapping(address => Bid[]) private bids;
    
    // Public winner variables
    address public highestBidder;
    uint public highestBid;
    
    // Mapping of pending returns to bidders who were overbid
    mapping(address => uint) private pendingReturns;

    // Events for auction actions
    event AuctionEnded(address winner, uint highestBid);
    event BidPlaced(address indexed bidder);
    event BidRevealed(address indexed bidder, uint value, bool success);

    // Custom errors
    error TooEarly(uint currentTime);
    error TooLate(uint currentTime);
    error AuctionEndAlreadyCalled();

    // Modifiers for timing checks
    modifier onlyBefore(uint time) {
        if (block.timestamp >= time) revert TooLate(block.timestamp);
        _;
    }
    
    modifier onlyAfter(uint time) {
        if (block.timestamp <= time) revert TooEarly(block.timestamp);
        _;
    }

    /**
     * @dev Constructor to initialize the blind auction
     * @param biddingTime Duration of bidding phase in seconds
     * @param revealTime Duration of reveal phase in seconds
     * @param beneficiaryAddress Address where auction proceeds will be sent
     */
    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }

    /**
     * @dev Place a blinded bid
     * @param _blindedBid Hashed bid information
     */
    function bid(bytes32 _blindedBid) external payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
        
        emit BidPlaced(msg.sender);
    }

    /**
     * @dev Reveal your blinded bids
     * @param _values Array of bid values
     * @param _fake Array of which bids were fake
     * @param _secret Array of secrets used to blind bids
     */
    function reveal(
        uint[] calldata _values,
        bool[] calldata _fake,
        bytes32[] calldata _secret
    ) external onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        uint length = bids[msg.sender].length;
        require(_values.length == length, "Arrays length mismatch");
        require(_fake.length == length, "Arrays length mismatch");
        require(_secret.length == length, "Arrays length mismatch");

        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            
            bytes32 calculatedHash = keccak256(abi.encodePacked(value, fake, secret));
            if (bidToCheck.blindedBid != calculatedHash) {
                // Bid was not correctly revealed
                continue;
            }
            
            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
            
            // Make it impossible to reclaim the bid
            bidToCheck.blindedBid = bytes32(0);
            
            emit BidRevealed(msg.sender, value, !fake && bidToCheck.deposit >= value);
        }
        
        payable(msg.sender).transfer(refund);
    }

    /**
     * @dev Internal function to place a bid
     * @param bidder Address of the bidder
     * @param value Bid amount
     * @return success Whether the bid was successful (became highest)
     */
    function placeBid(address bidder, uint value) internal returns (bool success) {
        if (value <= highestBid) {
            return false;
        }
        
        if (highestBidder != address(0)) {
            // Record previous highest bidder's refund
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /**
     * @dev Withdraw a previously refunded bid
     */
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Set to zero first to prevent re-entrancy attacks
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    /**
     * @dev End the auction and send the highest bid to the beneficiary
     */
    function auctionEnd() external onlyAfter(revealEnd) {
        if (ended) revert AuctionEndAlreadyCalled();
        
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    /**
     * @dev Calculate time remaining in the bidding phase
     * @return Time remaining in seconds
     */
    function biddingTimeRemaining() public view returns (uint) {
        return block.timestamp < biddingEnd ? biddingEnd - block.timestamp : 0;
    }
    
    /**
     * @dev Calculate time remaining in the reveal phase
     * @return Time remaining in seconds
     */
    function revealTimeRemaining() public view returns (uint) {
        if (block.timestamp < biddingEnd) {
            return revealEnd - biddingEnd;
        } else if (block.timestamp < revealEnd) {
            return revealEnd - block.timestamp;
        } else {
            return 0;
        }
    }
}
