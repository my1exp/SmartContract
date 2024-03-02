// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Claiming {
    address public owner;
    uint256 public feePrice;
    uint256 public feeAmount;

    event OrderCreated(bytes32 indexed orderId, uint256 blockNumber);
    event ClaimSuccess(
        uint256 claimValue,
        uint256 feePrice,
        uint256 NumberOfUsers,
        uint256 ValuePerUser
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    constructor(uint256 _fee) {
        owner = msg.sender;
        feePrice = _fee;
    }

    function createOrder()
        external
        returns (bytes32 orderId, uint256 blockNumber)
    {
        orderId = keccak256(abi.encodePacked(msg.sender, block.number));
        blockNumber = block.number;
        emit OrderCreated(orderId, blockNumber);
    }

    function claim(
        bytes32 OrderId,
        address[] memory users,
        uint256 blockNumber
    ) external payable returns (bool result) {
        require(
            (keccak256(abi.encodePacked(msg.sender, blockNumber))) == OrderId,
            "Order does not exist"
        );

        uint256 amountToCall = (msg.value / users.length) - feePrice;
        uint256 feeForClaim = msg.value - (amountToCall * users.length);

        for (uint8 count = 0; count < users.length; count++) {
            (bool sent, ) = users[count].call{value: amountToCall}("");
            require(sent, "Failed to send tokens");
        }
        emit ClaimSuccess(msg.value, feeForClaim, users.length, amountToCall);
        feeAmount += feeAmount + feeForClaim;
        return true;
    }

    function changeFeePrice(uint256 newFeePrice) public onlyOwner {
        feePrice = newFeePrice;
    }

    function withdraw() public onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: feeAmount}("");
        require(sent, "Failed to send tokens");
        feeAmount = 0;
    }
}
