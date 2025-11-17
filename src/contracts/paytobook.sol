// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PaytoBook {
    address public owner;
    IERC20 public USDC; //we're building in base sepolia 0x036CbD53842c5426634e7929541eC2318f3dCF7e
    uint256 private USDC_DEC = 10**6;

    struct Expert {
        uint256 id;
        string name;
        string title;
        string imgUrl;
        uint256 hourlyRate;
        address wallet;
        bool registered;
    }

    struct Booking {
        address client;
        uint256 expertId;
        uint256 startTime;
        uint256 duration;
        uint256 amountPaid;
        bool cancelled;
        string meetingLink;
    }

    event Booked(
        address indexed client,
        uint256 expertId,
        uint256 amount,
        string startTime,
        string meetingLink
    );

    mapping(uint256 => Expert) public experts;
    mapping(uint256 => Booking) public bookings;
    mapping(uint256 => mapping(uint256 => bool)) public availableSlots;

    uint256 public nextExpertId = 3;
    uint256 public nextBookingId = 0;
    uint256 public platformFeePercentage = 10;

    event ExpertRegistered(uint256 expertId, address wallet, string name);
    event BookingCreated(
        uint256 bookingId,
        uint256 expertId,
        address client,
        uint256 amount
    );
    event BookingCancelled(uint256 bookingId, uint256 refundAmount);
    event ExpertDeleted(uint256 expertId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the admin");
        _;
    }

    modifier onlyExpert(uint256 _expertId) {
        require(experts[_expertId].wallet == msg.sender, "Not the expert");
        _;
    }

    constructor(address _usdc) {
        owner = msg.sender;
        USDC = IERC20(_usdc);

        experts[0] = Expert({
            id: 1,
            name: "John Doe",
            title: "Blockchain Developer",
            imgUrl: "https://randomuser.me/api/portraits/men/31.jpg",
            hourlyRate: 50,
            wallet: 0xA71fbBb12c8dBd2091eebc109A2B98c5636fb7Cf,
            registered: true
        });

        experts[1] = Expert({
            id: 2,
            name: "Jane Smith",
            title: "Smart Contract Auditor",
            imgUrl: "https://randomuser.me/api/portraits/women/57.jpg",
            hourlyRate: 50,
            wallet: 0xA71fbBb12c8dBd2091eebc109A2B98c5636fb7Cf,
            registered: true
        });

        experts[2] = Expert({
            id: 3,
            name: "Alice Johnson",
            title: "DeFi Specialist",
            imgUrl: "https://randomuser.me/api/portraits/women/59.jpg",
            hourlyRate: 50,
            wallet: 0xA71fbBb12c8dBd2091eebc109A2B98c5636fb7Cf,
            registered: true
        });
    }

    function registerExpert(
        string memory _name,
        string memory _title,
        string memory _imgUrl,
        uint256 _hourlyRate
    ) external onlyOwner {
        experts[nextExpertId] = Expert({
            id: nextExpertId,
            name: _name,
            title: _title,
            imgUrl: _imgUrl,
            hourlyRate: _hourlyRate,
            wallet: address(this), // This is just a sample dapp will use the contract address as expert wallet
            registered: true
        });
        nextExpertId++;
        emit ExpertRegistered(nextExpertId, msg.sender, _name);
    }

    function addAvailability(uint256 _expertId, uint256[] memory _timeSlots)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _timeSlots.length; i++) {
            availableSlots[_expertId][_timeSlots[i]] = true;
        }
    }

    function bookTime(
        uint256 _expertId,
        uint256 _startTime,
        uint256 _duration,
        string memory _meetingLink
    ) external {
        Expert memory expert = experts[_expertId];
        require(expert.registered, "Expert not registered");
        require(_startTime > block.timestamp, "Time cannot be in the past");
        uint256 totalCost = (expert.hourlyRate * _duration) / 60;

        require(
            USDC.transferFrom(msg.sender, address(this), totalCost),
            "USDC transfer failed"
        );
        
        uint256 feeAmount = (totalCost * platformFeePercentage) / 100;
        uint256 expertAmount = totalCost - feeAmount;

        USDC.transfer(owner, feeAmount);
        USDC.transfer(expert.wallet, expertAmount);

        uint256 bookingId = nextBookingId++;
        bookings[bookingId] = Booking({
            client: msg.sender,
            expertId: _expertId,
            startTime: _startTime,
            duration: _duration,
            amountPaid: totalCost,
            cancelled: false,
            meetingLink: _meetingLink
        });

        emit BookingCreated(bookingId, _expertId, msg.sender, totalCost);
    }

    function changePlatformFee(uint256 _newFee) external onlyOwner {
        require(
            _newFee > 0 && _newFee != platformFeePercentage,
            "Choose other percentage"
        );
        platformFeePercentage = _newFee;
    }

    function cancelBooking(uint256 _bookingId) external {
        Booking storage booking = bookings[_bookingId];
        require(
            booking.client == msg.sender ||
                experts[booking.expertId].wallet == msg.sender,
            "Not authorized"
        );
        require(!booking.cancelled, "Already cancelled");
        require(block.timestamp < booking.startTime, "Already started");

        uint256 refundAmount = (booking.amountPaid * 90) / 100;

        IERC20 usdc = IERC20(USDC);
        usdc.transfer(booking.client, refundAmount);

        booking.cancelled = true;
        emit BookingCancelled(_bookingId, refundAmount);
    }

    function deleteExpert(uint256 _expertId) external {
        require(
            _expertId > 0 && _expertId <= nextExpertId,
            "Invalid expert id"
        );
        Expert storage expert = experts[_expertId];
        require(
            msg.sender == expert.wallet || msg.sender == owner,
            "Not the expert"
        );
        delete experts[_expertId];
        nextExpertId--;
        emit ExpertDeleted(_expertId);
    }

    //earnings from fees :D
    function withdrawUSDC() external onlyOwner {
        IERC20 usdc = IERC20(USDC);
        uint256 balance = usdc.balanceOf(address(this));
        require(balance > 0, "No balance");
        usdc.transfer(owner, balance);
    }

    function getExpertBookings(uint256 _expertId)
        external
        view
        returns (Booking[] memory)
    {
        uint256 count;
        for (uint256 i = 1; i < nextBookingId; i++) {
            if (bookings[i].expertId == _expertId) count++;
        }

        Booking[] memory result = new Booking[](count);
        uint256 index;
        for (uint256 i = 1; i < nextBookingId; i++) {
            if (bookings[i].expertId == _expertId) {
                result[index] = bookings[i];
                index++;
            }
        }
        return result;
    }

    function getClientBookings(address _client)
        external
        view
        returns (Booking[] memory)
    {
        uint256 count;
        for (uint256 i = 1; i < nextBookingId; i++) {
            if (bookings[i].client == _client) count++;
        }

        Booking[] memory result = new Booking[](count);
        uint256 index;
        for (uint256 i = 1; i < nextBookingId; i++) {
            if (bookings[i].client == _client) {
                result[index] = bookings[i];
                index++;
            }
        }
        return result;
    }

    function getBalance() public view returns (uint256) {
        return USDC.balanceOf(address(this));
    }

    function checkAllowance() public view returns (uint256) {
        return USDC.allowance(msg.sender, address(this));
    }

    function checkSpenderBalance() public view returns (uint256) {
        return USDC.balanceOf(msg.sender);
    }

    receive() external payable {}
}
