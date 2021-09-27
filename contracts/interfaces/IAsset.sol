// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";

interface IAsset is IERC1155Upgradeable {
    function forge(
        address _user,
        uint256 _amount,
        bytes memory _data
    ) external returns (uint256);
}
