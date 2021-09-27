// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "../L1Tokens/L1ERC20.sol";

contract L2ERC20 is L1ERC20 {
    address public childChainManagerProxy;

    function initialize(address _childChainManagerProxy) external {
        childChainManagerProxy = _childChainManagerProxy;
        super.initialize();
    }

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */
    function deposit(address user, bytes calldata depositData) external {
        require(
            msg.sender == childChainManagerProxy,
            "Asset: Unauthorized Call"
        );
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    /**
     * @notice called when user wants to withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param amount amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external {
        _burn(_msgSender(), amount);
    }
}
