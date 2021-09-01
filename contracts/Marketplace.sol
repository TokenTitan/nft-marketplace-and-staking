pragma solidity 0.8.0;

import "contracts/interfaces/IToken.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Marketplace is AccessControlUpgradeable {
    IToken token;
    mapping(uint256 => address) public itemForSale;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

    // Events
    event ItemListedForSale(uint256 _id);

    function initialize(IToken _token) external initializer {
        token = _token;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerItemForSale(uint256 _amount, bytes memory _data)
        external
        returns (uint256 _id)
    {
        _id = token.forge(msg.sender, _amount, _data);
        itemForSale[_id] = msg.sender;
        emit ItemListedForSale(_id);
    }

    // Getters

    function checkItemStock(uint256 _id) external view returns (bool) {
        return itemForSale[_id] == address(0) ? false : true;
    }
}
