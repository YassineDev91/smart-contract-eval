// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelInventory {
    string private _room;
    uint256 private _date;
    uint256 private _price;
    address payable private _hotel;
    mapping(address => uint256) private _balances;

    event RoomBooked(address guest, uint256 date, string room);

    constructor(
        string memory room,
        uint256 date,
        uint256 price,
        address payable hotel,
        uint256 availability
    ) {
        _room = room;
        _date = date;
        _price = price;
        _hotel = hotel;
        _balances[hotel] = availability;
    }

    function bookRoom() external payable {
        require(msg.value == _price, "Incorrect payment");
        require(_balances[_hotel] > 0, "No rooms available");
        
        _balances[_hotel]--;
        payable(_hotel).transfer(msg.value);
        emit RoomBooked(msg.sender, _date, _room);
    }

    function checkAvailability() external view returns (uint256) {
        return _balances[_hotel];
    }

    function getRoomDetails() external view returns (string memory, uint256, uint256) {
        return (_room, _date, _price);
    }
}
