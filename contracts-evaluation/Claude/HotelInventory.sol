// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title HotelInventory
 * @dev Manages hotel room reservations with payment functionality
 */
contract HotelInventory {
    // Private variables for room details
    string private _room;
    uint256 private _date;
    uint256 private _price;
    address payable private _hotel;
    
    // Mapping to track available rooms and reservations
    mapping(address => uint256) private _balances;
    
    // Events for reservation activities
    event RoomBooked(address indexed guest, string room, uint256 date);
    event ReservationCancelled(address indexed guest, string room, uint256 date);
    event AvailabilityUpdated(string room, uint256 date, uint256 newAvailability);
    
    /**
     * @dev Constructor to initialize hotel room inventory
     * @param room The room identifier/type
     * @param date The date timestamp for availability
     * @param price The price per room night
     * @param hotel The hotel's address to receive payments
     * @param availability Initial number of available rooms
     */
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
    
    /**
     * @dev Get room information
     * @return Room identifier, date, price, and hotel address
     */
    function getRoomInfo() external view returns (string memory, uint256, uint256, address) {
        return (_room, _date, _price, _hotel);
    }
    
    /**
     * @dev Check availability of rooms for the specific date
     * @return Number of available rooms
     */
    function checkAvailability() external view returns (uint256) {
        return _balances[_hotel];
    }
    
    /**
     * @dev Book a room by paying the price
     * @param numberOfNights Number of nights to book
     */
    function bookRoom(uint256 numberOfNights) external payable {
        require(_balances[_hotel] > 0, "No rooms available");
        require(msg.value >= _price * numberOfNights, "Insufficient payment");
        
        // Reduce available rooms
        _balances[_hotel] -= 1;
        
        // Record the booking for the guest
        _balances[msg.sender] += 1;
        
        // Transfer payment to the hotel
        _hotel.transfer(msg.value);
        
        emit RoomBooked(msg.sender, _room, _date);
    }
    
    /**
     * @dev Cancel a reservation (with hotel's approval)
     * @param guest Address of the guest with the reservation
     * @param refundAmount Amount to refund to the guest
     */
    function cancelReservation(address payable guest, uint256 refundAmount) external {
        require(msg.sender == _hotel, "Only hotel can process cancellations");
        require(_balances[guest] > 0, "No reservation found");
        
        // Return the room to inventory
        _balances[_hotel] += 1;
        _balances[guest] -= 1;
        
        // Process refund if applicable
        if (refundAmount > 0) {
            guest.transfer(refundAmount);
        }
        
        emit ReservationCancelled(guest, _room, _date);
    }
    
    /**
     * @dev Update room availability (hotel only)
     * @param newAvailability New number of available rooms
     */
    function updateAvailability(uint256 newAvailability) external {
        require(msg.sender == _hotel, "Only hotel can update availability");
        _balances[_hotel] = newAvailability;
        
        emit AvailabilityUpdated(_room, _date, newAvailability);
    }
    
    /**
     * @dev Update room price (hotel only)
     * @param newPrice New price for the room
     */
    function updatePrice(uint256 newPrice) external {
        require(msg.sender == _hotel, "Only hotel can update price");
        _price = newPrice;
    }
}
