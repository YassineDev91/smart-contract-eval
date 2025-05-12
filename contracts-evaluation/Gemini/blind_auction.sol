// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * @title BlindAuction
 * @dev Implements a blind auction where bids are hidden until the reveal phase.
 * @custom:ai-hint Multi-phase auction with hidden bids and timed reveal logic.
 */
contract BlindAuction {

    // Struct for storing bid details (blinded bid and deposit)
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    // Public state variables
    address payable public beneficiary; // Address receiving the funds
    uint public biddingEnd;       // Timestamp when bidding ends
    uint public revealEnd;        // Timestamp when reveal phase ends
    bool public ended;            // Flag indicating if the auction has concluded

    // Mapping from bidder address to their list of bids
    mapping(address => Bid[]) private bids;

    // Current highest bidder and bid amount
    address public highestBidder;
    uint public highestBid;

    // Mapping for pending returns of overbids
    mapping(address => uint) private pendingReturns;

    // Modifiers for time checks
    modifier onlyBefore(uint _time) {
        require(block.timestamp < _time, "Function called too late.");
        _;
    }
    modifier onlyAfter(uint _time) {
        require(block.timestamp > _time, "Function called too early.");
        _;
    }

    // Events
    event AuctionEnded(address winner, uint amount);

    // Custom Errors
    error AuctionEndAlreadyCalled();
    error RevealPhaseMismatch(); // Custom error for reveal length mismatch
    error InvalidBidHash();     // Custom error for invalid revealed bid
    error BidRevealNotReal();   // Custom error if bid is marked fake but deposit exists


    /*
     * @dev Constructor to initialize the auction parameters.
     * @param biddingTime Duration of the bidding phase in seconds.
     * @param revealTime Duration of the reveal phase in seconds.
     * @param beneficiaryAddress Address to receive the auction proceeds.
     */
    constructor(
        uint biddingTime,
        uint revealTime,
        address payable beneficiaryAddress
    ) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime; // Calculate end times based on current time
        revealEnd = biddingEnd + revealTime;
    }

    /*
     * @dev Place a blinded bid with a deposit.
     * The deposit must cover the actual bid amount.
     * Can only be called during the bidding phase.
     * @param _blindedBid A hash commitment of the bid (e.g., keccak256(abi.encode(value, fake, secret))).
     */
    function bid(bytes32 _blindedBid)
        external
        payable
        onlyBefore(biddingEnd)
    {
        // Add the bid structure to the sender's list of bids
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value // msg.value is the deposit
        }));
    }

    /*
     * @dev Reveal the actual bids after the bidding phase ends.
     * Bidders reveal their values, whether the bid was fake (to prevent analysis), and the secret used for hashing.
     * Calculates refunds for invalid or lower bids and determines the highest bidder.
     * @param _values Array of actual bid values.
     * @param _fake Array of booleans indicating if a bid was intentionally fake.
     * @param _secret Array of secrets used to blind the bids.
     */
    function reveal(
        uint[] memory _values,
        bool[] memory _fake,
        bytes32[] memory _secret
    )
        external
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        // Check if reveal arrays match the number of bids placed
        if (_values.length != length || _fake.length != length || _secret.length != length) {
             revert RevealPhaseMismatch();
        }


        uint refund = 0;
        for (uint i = 0; i < length; i++) {
             // Get the bid from storage (accessing the bidsList variable in the JSON)
            Bid storage bidToCheck = bids[msg.sender][i];

            // Decode the bid details from the provided arrays
            (uint value, bool fake, bytes32 secret) =
                    (_values[i], _fake[i], _secret[i]);

            // Verify the blinded bid hash (simulated logic based on common practice)
            bytes32 reBlindedBid = keccak256(abi.encodePacked(value, fake, secret));
             if (bidToCheck.blindedBid != reBlindedBid) {
                 // Bid hash doesn't match - refund deposit
                refund += bidToCheck.deposit;
                 continue; // Skip to next bid iteration (simulated break/continue logic)
            }


            // Add deposit to refund if the bid was marked as fake
            if (fake) {
                refund += bidToCheck.deposit;
                 continue; // Skip to next bid iteration
            }

             // Check if the revealed value is valid (greater than 0 and covered by deposit)
            if (value == 0 || bidToCheck.deposit < value) {
                 // Invalid value or insufficient deposit - refund deposit
                 refund += bidToCheck.deposit;
                continue; // Skip to next bid iteration
             }


            // Check if this bid is the new highest bid
            if (value > highestBid) {
                // Refund the previous highest bidder if there was one
                if (highestBidder != address(0)) {
                    pendingReturns[highestBidder] += highestBid;
                }
                // Update highest bid details
                highestBid = value;
                highestBidder = msg.sender;
            }

             // Add the difference between deposit and bid value to refund
            refund += (bidToCheck.deposit - value);

        }
         // Add the total calculated refund to the sender's pending returns
         pendingReturns[msg.sender] += refund;


        // Clear the bids for the sender to prevent re-revealing (optional but good practice)
         delete bids[msg.sender];

    }


    /*
     * @dev Withdraw the refunded amount for the caller.
     */
    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // Reset pending return amount before sending to prevent re-entrancy
            pendingReturns[msg.sender] = 0;

            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Withdrawal failed.");
        }
    }

    /*
     * @dev End the auction after the reveal phase.
     * Transfers the highest bid amount to the beneficiary.
     * Can only be called once after the reveal period ends.
     */
    function auctionEnd()
        external
        onlyAfter(revealEnd) // Check if revealEnd has passed
    {
        // Check if auction has already been ended
        if (ended) {
            revert AuctionEndAlreadyCalled(); // Use custom error
        }
        // The JSON includes a 'TooEarly' check, but the modifier handles this.

        ended = true; // Mark auction as ended
        emit AuctionEnded(highestBidder, highestBid); // Emit event

        // Transfer the highest bid amount to the beneficiary
        (bool success, ) = beneficiary.call{value: highestBid}("");
        require(success, "Beneficiary transfer failed.");
    }
}
