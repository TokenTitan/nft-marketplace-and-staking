// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract L2ERC20 is ERC20Upgradeable, AccessControlUpgradeable {
    uint256 public constant initialAmount = 10**5 * (10**18);
}
