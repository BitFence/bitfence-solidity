pragma solidity ^0.4.17;

import "../node_modules/zeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/crowdsale/price/IncreasingPriceCrowdsale.sol";
import "../node_modules/zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "./HNYToken.sol";

/**
 * @title The BitFence HNY Crowdsale contract
 * @dev The BitFence HNY Crowdsale contract
 * @dev inherits from CappedCrowdsale by Zeppelin
 */
 contract HNYCrowdsale is CappedCrowdsale, FinalizableCrowdsale, MintedCrowdsale, IncreasingPriceCrowdsale {
   // customize the rate for each whitelisted buyer
   mapping (address => uint256) public buyerRate;

   // override rate discount if necessary
   uint256 public rateOverride = 0;

    // ctor
   function HNYCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rateStart, uint256 _rateEnd, address _wallet, address _token) public
     Crowdsale(_rateStart, _wallet, HNYToken(_token))
     CappedCrowdsale(100000 ether)
     FinalizableCrowdsale()
     TimedCrowdsale(_startTime, _endTime)
     IncreasingPriceCrowdsale(_rateStart, _rateEnd)
   {
      require(_startTime >= now);
      require(_endTime >= _startTime);
      require(_rateStart > 0);
      require(_rateEnd > 0);
      require(_wallet != address(0));
      require(_token  != address(0));
   }

   // authorize rate for volume buyer
   function setBuyerRate(address _buyer, uint256 _rate) onlyOwner public {
     require(_rate  != 0);
     require(_buyer != 0x0);
     buyerRate[_buyer] = _rate;
   }

   // emergency wallet reset
   function setWallet(address _wallet) onlyOwner public {
      require(_wallet != 0x0);
      wallet = _wallet;
   }

    // pause control
    function unpauseToken() public onlyOwner {
        HNYToken(token).unpause();
    }
    function pauseToken() public onlyOwner {
        HNYToken(token).pause();
    }

    // shapeshift purchase
    function purchaseEx(address _beneficiary, uint256 _tokenAmount) public onlyOwner {
      require(MintableToken(token).mint(_beneficiary, _tokenAmount));
      require(MintableToken(token).mint(wallet,       _tokenAmount));
    }

    // rate override
    function rateUpdate(uint256 _tokenAmount) public onlyOwner {
        rateOverride = _tokenAmount;
    }

    // MintedCrowdsale override
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
      require(MintableToken(token).mint(_beneficiary, _tokenAmount));
      require(MintableToken(token).mint(wallet,       _tokenAmount));
    }

    // emergency token owner change
    function backHNYTokenOwner() onlyOwner public {
		    HNYToken(token).transferOwnership(owner);
	  }

    // IncreasingPriceCrowdsale override
    function getCurrentRate() public view returns (uint256) {

      // check for volume buyers and return their rate if registered
      if (buyerRate[msg.sender] != 0) {
          return buyerRate[msg.sender];
      }

      // rate override
      if (rateOverride !=0) {
        return rateOverride;
      }

      // initial rate
      if (now < openingTime.add(14 days)) {
          return initialRate;
      }

      // progressive rate
      if (now >= openingTime.add(14 days) && now <= closingTime) {
        uint256 elapsedTime = now.sub(openingTime);
        uint256 timeRange = closingTime.sub(openingTime);
        uint256 rateRange = initialRate.sub(finalRate);
        return initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
      }

      return finalRate;
    }

    // our rate is per ether, not wei
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
      uint256 currentRate    = getCurrentRate();
      uint256 volumeDiscount = 0;

      // volume discount
      if (_weiAmount >= 10 ether) volumeDiscount = _weiAmount / 1 ether;

      return currentRate.mul(_weiAmount / 1 ether) +
             volumeDiscount * currentRate.mul(_weiAmount / 1 ether)/100;
    }

    // validate address and price
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
      require(_beneficiary != address(0));
      require(_weiAmount != 0);
      require(!isFinalized);
    }

    // nothing here
    function finalization() internal {
    }
 }
