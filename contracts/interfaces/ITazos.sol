// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
 * @title Minimum expected interface for L1 custom token (see TestCustomTokenL1.sol for an example implementation)
 */
interface ITazos is IERC20Upgradeable {
    /**
     * @notice mints tokens
     * @param to the address of the user
     * @param amount units of token to mint
     */
    function mint(address to, uint256 amount) external;
}
