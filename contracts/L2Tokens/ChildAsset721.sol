// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract ChildAsset721 is ERC721Upgradeable, AccessControlUpgradeable {
    address public childChainManagerProxy;
    uint256 public counter;

    // limit batching of tokens due to gas limit restrictions
    uint256 public constant BATCH_LIMIT = 20;

    // keccak256("ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // Events
    event ItemForged(uint256 _id);
    event WithdrawnBatch(address indexed user, uint256[] tokenIds);

    // Modifiers
    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Asset: Only Admin can perform this action"
        );
        _;
    }

    function initialize(address _childChainManagerProxy) external initializer {
        _setupRole(ADMIN_ROLE, msg.sender);
        childChainManagerProxy = _childChainManagerProxy;
    }

    function forge(address _user) external onlyAdmin returns (uint256) {
        counter++;
        _mint(_user, counter);
        emit ItemForged(counter);
        return counter;
    }

    /**
     * @notice called when tokens are deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required tokens for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded ids array
     */
    function deposit(address user, bytes calldata depositData) external {
        require(
            msg.sender == childChainManagerProxy,
            "Asset: Unauthorized Call"
        );
        // deposit single
        if (depositData.length == 32) {
            uint256 tokenId = abi.decode(depositData, (uint256));
            _mint(user, tokenId);

            // deposit batch
        } else {
            uint256[] memory tokenIds = abi.decode(depositData, (uint256[]));
            uint256 length = tokenIds.length;
            for (uint256 i; i < length; i++) {
                _mint(user, tokenIds[i]);
            }
        }
    }

    /**
     * @notice called when user wants to withdraw single token back to root chain
     * @dev Should burn user's token. This transaction will be verified when exiting on root chain
     * @param id id to withdraw
     */
    function withdrawSingle(uint256 id) external {
        _burn(id);
    }

    /**
     * @notice called when user wants to batch withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param tokenIds ids to withdraw
     */
    function withdrawBatch(uint256[] calldata tokenIds) external {
        uint256 length = tokenIds.length;
        require(length <= BATCH_LIMIT, "ChildERC721: EXCEEDS_BATCH_LIMIT");
        for (uint256 i; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            require(
                _msgSender() == ownerOf(tokenId),
                string(
                    abi.encodePacked(
                        "ChildERC721: INVALID_TOKEN_OWNER ",
                        tokenId
                    )
                )
            );
            _burn(tokenId);
        }
        emit WithdrawnBatch(_msgSender(), tokenIds);
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
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
