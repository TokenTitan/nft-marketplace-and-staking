// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract L1ERC20 is ERC20Upgradeable, AccessControlUpgradeable {
    uint256 public constant initialAmount = 10**5 * (10**18);
    
    // keccak256("ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // Modifiers
    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Asset: Only Admin can perform this action"
        );
        _;
    }
    
    function initialize() public {
        _setupRole(ADMIN_ROLE, _msgSender());
    }
    
    function forge(address _user, uint256 _amount) external onlyAdmin {
        _mint(_user, _amount);
    }
}
