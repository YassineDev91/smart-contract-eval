// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Purchase
 * @dev Implements an escrow system for safe remote purchases
 */
contract PurchaseClaude {
    // Public state variables
    uint public value;
    address payable public seller;
    address payable public buyer;
    
    // Transaction state enum
    enum State { Created, Locked, Release, Inactive }
    State public state;
    
    // Custom errors for better error reporting
    error ValueNotEven();
    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error InvalidAction();
    
    // Events for state transitions
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();
    
    // Ensure the function is only called in a specific state
    modifier inState(State _state) {
        require(state == _state, "Invalid state for this operation");
        _;
    }
    
    // Only the buyer can call this function
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }
    
    // Only the seller can call this function
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function");
        _;
    }
    
    /**
     * @dev Constructor to set up the escrow purchase
     * The seller puts up an escrow of twice the value of the item
     */
    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        
        if (2 * value != msg.value) {
            revert ValueNotEven();
        }
        
        state = State.Created;
    }
    
    /**
     * @dev Abort the purchase and reclaim the ether (seller only)
     */
    function abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        // The seller returns the escrow to themselves
        seller.transfer(address(this).balance);
    }
    
    /**
     * @dev Confirm the purchase as buyer by sending the required funds
     */
    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value == (2 * value), "Please send exactly 2x the item value");
        
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }
    
    /**
     * @dev Confirm receipt of the item and release payment to seller (buyer only)
     */
    function confirmReceived() external onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        state = State.Release;
        
        // Release buyer's deposit back to them
        buyer.transfer(value);
    }
    
    /**
     * @dev Refund seller after item is confirmed received (seller only)
     */
    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded();
        state = State.Inactive;
        
        // Release seller's deposit plus payment to them (3x value)
        seller.transfer(3 * value);
    }
    
    /**
     * @dev Get the current balance of the contract
     * @return The contract's balance
     */
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
