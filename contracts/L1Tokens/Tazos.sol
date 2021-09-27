// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract Tazos is ERC20PresetMinterPauserUpgradeable {
    function initialize() external initializer {
        super.initialize("Tazos", "TAZ");
    }
}
