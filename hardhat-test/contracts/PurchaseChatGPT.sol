// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PurchaseChatGPT {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive }
    State public state;

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

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

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        require(2 * value == msg.value, "ValueNotEven");
    }

    function abort() external onlySeller inState(State.Created) {
        emit Aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value == 2 * value, "Incorrect value.");
        buyer = payable(msg.sender);
        state = State.Locked;
        emit PurchaseConfirmed();
    }

    function confirmReceived() external onlyBuyer inState(State.Locked) {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    function refundSeller() external onlySeller inState(State.Release) {
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3 * value);
    }
}
