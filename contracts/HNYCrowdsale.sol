pragma solidity ^0.4.17;

import "../node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "./HNYToken.sol";

/**
 * @title The BitFence HNY Crowdsale contract
 * @dev The BitFence HNY Crowdsale contract
 * @dev inherits from CappedCrowdsale by Zeppelin
 */
 contract HNYCrowdsale is CappedCrowdsale {

   uint256 public _startTime = 0;
   uint256 public _endTime = 0;
   uint256 public _rate = 0;
   uint256 public _cap = 0;
   address public _wallet = 0;

   function HNYCrowdsale() public
     CappedCrowdsale(_cap)
     Crowdsale(_startTime, _endTime, _rate, _wallet)
   {
   }

   function createTokenContract() internal returns (MintableToken) {
     return new HNYToken();
   }
   // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    address team = 0;
    address bounty = 0;
    address reserve = 0;

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    uint256 bountyAmount = weiAmount.mul(50);
    uint256 teamAmount = weiAmount.mul(100);
    uint256 reserveAmount = weiAmount.mul(50);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    token.mint(bounty, bountyAmount);
    token.mint(team, teamAmount);
    token.mint(reserve, reserveAmount);

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }
 }
