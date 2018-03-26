pragma solidity ^0.4.17;

import "../node_modules/zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

/**
 * @title The BitFence HNY Token contract
 * @dev The BitFence HNY Token contract
 * @dev inherits from MintableToken by Zeppelin
 */
contract HNYToken is BurnableToken, MintableToken, PausableToken {
  string public constant name = "BitFence HNY Token";
  string public constant symbol = "HNY";
  uint8 public constant decimals = 18;
}
