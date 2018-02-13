pragma solidity ^0.4.17;

import "../node_modules/zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol";
import "./HNYToken.sol";

/**
 * @title The BitFence HNY Crowdsale contract
 * @dev The BitFence HNY Crowdsale contract
 * @dev inherits from CappedCrowdsale by Zeppelin
 */
 contract HNYCrowdsale is CappedCrowdsale, FinalizableCrowdsale {

   uint256 public _startTime = 0;
   uint256 public _endTime = 0;
   uint256 public _rate = 0;
   uint256 public _cap = 0;
   address public _wallet = 0;

   address public _team = 0;
   address public _bounty = 0;
   address public _reserve = 0;

   uint256 public constant TOTAL_SHARE = 100;
   uint256 public constant CROWDSALE_SHARE = 40;
   uint256 public constant FOUNDATION_SHARE = 60;

   // initial rate at which tokens are offered
   uint256 public initialRate = 600;

   // end rate at which tokens are offered
   uint256 public endRate = 300;


    // customize the rate for each whitelisted buyer
    mapping (address => uint256) public buyerRate;

  event WalletChange(address wallet);

   event PreferentialRateChange(address indexed buyer, uint256 rate);

   event InitialRateChange(uint256 rate);

   event EndRateChange(uint256 rate);

   function HNYCrowdsale() public
     CappedCrowdsale(_cap)
     Crowdsale(_startTime, _endTime, _rate, _wallet)
   {
      HNYToken(token).pause();
   }

   function createTokenContract() internal returns (MintableToken) {
     return new HNYToken();
   }

   // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());



    uint256 weiAmount = msg.value;

    // adjust rate
    rate = getRate();

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    uint256 bountyAmount = weiAmount.mul(50);
    uint256 teamAmount = weiAmount.mul(100);
    uint256 reserveAmount = weiAmount.mul(50);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    token.mint(_bounty, bountyAmount);
    token.mint(_team, teamAmount);
    token.mint(_reserve, reserveAmount);

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

   // pause control
    function unpauseToken() public onlyOwner {
        HNYToken(token).unpause();
    }

    function pauseToken() public onlyOwner {
        HNYToken(token).pause();
    }

    // fin
    function finalization() internal  {
       uint256 totalSupply = token.totalSupply();
       uint256 finalSupply = TOTAL_SHARE.mul(totalSupply).div(CROWDSALE_SHARE);

       // emit tokens for the foundation
       token.mint(wallet, FOUNDATION_SHARE.mul(finalSupply).div(TOTAL_SHARE));

       // NOTE: cannot call super here because it would finish minting and
       // the continuous sale would not be able to proceed
       //HNYToken(token).unpause();
   }

   // rate calculation fun
   function getRate() internal returns(uint256) {
       // some early buyers are offered a discount on the crowdsale price
       if (buyerRate[msg.sender] != 0) {
           return buyerRate[msg.sender];
       }

       // whitelisted buyers can purchase at preferential price before crowdsale ends
    //   if (isWhitelisted(msg.sender)) {
    //       return preferentialRate;
    //   }

       // otherwise compute the price for the auction
       uint256 elapsed = block.number - startTime;
       uint256 rateRange = initialRate - endRate;
       uint256 blockRange = endTime - startTime;

       return rate.sub(rateRange.mul(elapsed).div(blockRange));
   }

   // rate public functions
   function setBuyerRate(address buyer, uint256 rate) onlyOwner public {
     require(rate != 0);
  //   require(block.number < startBlock);

     buyerRate[buyer] = rate;

     PreferentialRateChange(buyer, rate);
 }

 function setInitialRate(uint256 rate) onlyOwner public {
     require(rate != 0);
//     require(block.number < startDate);

     initialRate = rate;

     InitialRateChange(rate);
 }

 function setEndRate(uint256 rate) onlyOwner public {
     require(rate != 0);
  //   require(block.number < startDate);

     endRate = rate;

     EndRateChange(rate);
 }

      function setWallet(address _wallet) onlyOwner public {
         require(_wallet != 0x0);
         wallet = _wallet;
         WalletChange(_wallet);
     }


 }
