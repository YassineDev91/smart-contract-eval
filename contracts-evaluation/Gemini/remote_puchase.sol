// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * @title Purchase
 * @dev Buyer-seller escrow transaction with state transitions and refund logic.
 * Implements a basic escrow system where a seller locks funds and a buyer confirms receipt.
 */
contract Purchase {

    // Enum defining the possible states of the purchase contract
    enum State { Created, Locked, Release, Inactive }

    // Public state variables
    uint public value; // Half of the total escrowed amount (purchase price)
    address payable public seller;
    address payable public buyer;
    State public state;

    // Events to log state changes and actions
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded(); // Custom event name for clarity

    // Modifiers for access control and state checks
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this.");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this.");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state.");
        _;
    }

    // Custom error for constructor check
    error ValueNotEven();

    /*
     * @dev Constructor: Initializes the contract, requires seller to deposit double the item value as collateral.
     */
    constructor() payable {
        seller = payable(msg.sender); // 'caller' is msg.sender
        value = msg.value / 2; // Purchase price is half the deposited value

        // Require the seller to deposit exactly twice the value (value + collateral)
        if (2 * value != msg.value) {
            revert ValueNotEven(); // Use custom error
        }
        state = State.Created; // Initial state (implied, set explicitly for clarity)
    }

    /*
     * @dev Abort the purchase (only by seller, only in Created state).
     * Seller gets their full deposit back.
     */
    function abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        // Refund the seller the total amount they deposited (2 * value)
        // Note: Solidity 0.8+ requires explicit casting for payable.
        // Using call for safer transfer with gas stipulation.
        (bool success, ) = seller.call{value: 2 * value}("");
        require(success, "Transfer failed.");
        // The JSON 'refund' method isn't standard; using direct transfer/call.
    }

    /*
     * @dev Confirm the purchase (only in Created state).
     * Buyer pays the value, locking the contract.
     */
    function confirmPurchase() external payable inState(State.Created) {
        require(msg.value == value, "Please send the correct amount"); // Buyer must pay the item value

        buyer = payable(msg.sender); // Set the buyer
        state = State.Locked;     // Update state
        emit PurchaseConfirmed();
    }

    /*
     * @dev Confirm item received (only by buyer, only in Locked state).
     * Buyer gets their collateral back (which was the seller's deposit).
     */
    function confirmReceived() external onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        state = State.Release; // Update state

        // Refund the buyer their initial payment (value)
        // This comes from the seller's initial deposit.
        (bool success, ) = buyer.call{value: value}("");
        require(success, "Transfer failed.");
    }

    /*
     * @dev Refund the seller (only by seller, only in Release state).
     * Seller gets the purchase price plus their collateral back.
     */
    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded(); // Use custom event name
        state = State.Inactive; // Update state

        // Refund the seller the remaining amount:
        // Their original collateral (value) + the buyer's payment (value) = 2 * value
        // Plus the buyer's payment that was held (value) = 3 * value total
        (bool success, ) = seller.call{value: 3 * value}("");
        require(success, "Transfer failed.");
    }
}
