pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Token is ERC1155Upgradeable, AccessControlUpgradeable {
    uint256 id;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

    // Events
    event ItemForged(uint256 _id);

    // Modifiers
    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "Item: Only Admin can perform this action"
        );
        _;
    }

    function initialize(string memory _uri) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setURI(_uri); // not sure
    }

    function forge(
        address _user,
        uint256 _amount,
        bytes memory _data
    ) external returns (uint256) { // TODO: onlyAdmin or onlyMarket
        id++;
        _mint(_user, id, _amount, _data);
        emit ItemForged(id);
        return id;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
