// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;

    // Store owner / admin of the contract
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "You need to be the owner of the contract to access the funds");
        _;
    }
    
    // Fund the smart contract 
    function fund() public payable{
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) > minimumUSD, "You need to spend more ETH to complete the transaction");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    // Get the actual price of ETH in USD
    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x0bF499444525a23E7Bb61997539725cA2e928138);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    // Convert ETH in UDT
    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000;
        return ethAmountInUsd;
    }

    // Withdraw all the ETH funded on the contract ( only if creator of the contract )
    function withdraw() payable onlyOwner public{
        payable(msg.sender).transfer(address(this).balance);
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }  
}