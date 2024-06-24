// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract V50ToMe {
    using PriceConverter for uint256;
    AggregatorV3Interface private s_priceFeed;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_v50ers;

    address private /* immutable */ i_owner;
    uint256 public constant MINIMUM_CNY = 50 * 10 ** 18;
    
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }


    function V50() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_CNY, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_v50ers.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    function getEthPrinceInCNY(uint256 ethAmount) public view returns (uint256){
        return ethAmount.getConversionRate(s_priceFeed);
    }
    
    modifier onlyOwner {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 v50ersLength = s_v50ers.length;
        for (uint256 funderIndex=0; funderIndex < v50ersLength; funderIndex++){
            address funder = s_v50ers[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_v50ers = new address[](0);
  
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < s_v50ers.length; funderIndex++){
            address funder = s_v50ers[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_v50ers = new address[](0);
  
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        V50();
    }

    receive() external payable {
        V50();
    }

    function getAddressToAmountV50(address v50Address) external view returns (uint256){
        return s_addressToAmountFunded[v50Address];
    }

    function getV50er(uint256 index) external view returns (address){
        return s_v50ers[index];
    }

    function getOwner() external view returns (address){
        return i_owner;
    }

}