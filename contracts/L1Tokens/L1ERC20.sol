// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract L1ERC20 is ERC20, AccessControl {
    uint256 public constant initialAmount = 10**10 * (10**18);

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(_msgSender(), initialAmount);
    }
}
