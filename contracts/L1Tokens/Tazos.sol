// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Tazos is
    Initializable,
    ContextUpgradeable,
    AccessControlEnumerableUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155PausableUpgradeable
{
    // 0xFFFFFFFF
    uint32 public constant MAX_INT_32 = type(uint32).max;
    // OxFFFFFFFFFFFFFFFF
    uint64 public constant MAX_INT_64 = type(uint64).max;

    // keccak256("MINTER_ROLE")
    bytes32 public constant MINTER_ROLE =
        0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    // keccak256("PAUSER_ROLE")
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;


    function initialize(string memory uri) public initializer {
        __Tazos_init(uri);
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, and `PAUSER_ROLE` to the account that
     * deploys the contract.
     */
    function __Tazos_init(string memory uri) internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC165_init_unchained();
        __ERC1155_init_unchained(uri);
        __ERC1155Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC1155Pausable_init_unchained();
        __Tazos_init_unchained(uri);
    }

    function __Tazos_init_unchained(
        string memory /* uri */
    ) internal initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @notice burns tokens
     * @param account the address of the user
     * @param id the id of the token
     * @param value the amount to be burned
     */
    function burnFrom(
        address account,
        uint256 id,
        uint256 value
    ) external {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "Tazos: must have minter role to burn"
        );

        _burn(account, id, value);
    }

    /**
     * @notice mints tokens
     * @param to the address of the user
     * @param id the current period value
     * @param amount units of token to mint
     */
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "Tazos: must have minter role to mint"
        );

        _mint(to, id, amount, data);
    }

    /**
     * @dev Toggle pause/unpause for all token transfers.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function togglePause() external {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "Tazos: must have pauser role to unpause"
        );
        paused() ? _unpause() : _pause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, AccessControlEnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155PausableUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    uint256[50] private __gap;
}
