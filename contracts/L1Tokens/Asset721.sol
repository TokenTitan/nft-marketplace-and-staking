// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Asset721 is ERC721Upgradeable, AccessControlUpgradeable {
    uint256 public counter;

    // keccak256("ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // Events
    event ItemForged(uint256 _id);

    // Modifiers
    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Asset: Only Admin can perform this action"
        );
        _;
    }

    function initialize() public initializer {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function forge(address _user) external onlyAdmin returns (uint256) {
        counter++;
        _mint(_user, counter);
        emit ItemForged(counter);
        return counter;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
