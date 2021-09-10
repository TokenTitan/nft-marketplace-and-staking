pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract ChildAsset is ERC1155Upgradeable, AccessControlUpgradeable {
    address public childChainManagerProxy;
    uint256 public counter;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

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

    function initialize(string memory _uri, address _childChainManagerProxy)
        external
        initializer
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setURI(_uri);
        childChainManagerProxy = _childChainManagerProxy;
    }

    function forge(
        address _user,
        uint256 _amount,
        bytes memory _data
    ) external onlyAdmin returns (uint256) {
        counter++;
        _mint(_user, counter, _amount, _data);
        emit ItemForged(counter);
        return counter;
    }

    /**
     * @notice called when tokens are deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required tokens for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded ids array and amounts array
     */
    function deposit(address user, bytes calldata depositData)
        external
    {
        require(msg.sender == childChainManagerProxy, "Asset: Unauthorized Call");
        (
            uint256[] memory ids,
            uint256[] memory amounts,
            bytes memory data
        ) = abi.decode(depositData, (uint256[], uint256[], bytes));

        require(
            user != address(0),
            "ChildMintableERC1155: INVALID_DEPOSIT_USER"
        );

        _mintBatch(user, ids, amounts, data);
    }

    /**
     * @notice called when user wants to withdraw single token back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param id id to withdraw
     * @param amount amount to withdraw
     */
    function withdrawSingle(uint256 id, uint256 amount) external {
        _burn(_msgSender(), id, amount);
    }

    /**
     * @notice called when user wants to batch withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param ids ids to withdraw
     * @param amounts amounts to withdraw
     */
    function withdrawBatch(uint256[] calldata ids, uint256[] calldata amounts)
        external
    {
        _burnBatch(_msgSender(), ids, amounts);
    }

    function updateChildChainManager(address newChildChainManagerProxy)
        external
        onlyAdmin
    {
        require(newChildChainManagerProxy != address(0), "Asset: Bad address");
        childChainManagerProxy = newChildChainManagerProxy;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
