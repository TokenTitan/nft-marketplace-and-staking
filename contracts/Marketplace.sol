pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

contract Marketplace is AccessControlUpgradeable {
    uint256 counter;

    enum TokenTypes {
        ERC1155,
        ERC721
    }

    mapping(uint256 => Commodity) public commoditiesForSale;
    mapping(address => mapping(uint256 => uint256)) internal stock;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

    // Struct
    struct Commodity {
        TokenTypes commodityType;
        address owner;
        address assetContract;
        uint256 id;
        address acceptedERC20;
        uint256 listedPrice;
        bool listedForSale;
    }

    // Events
    event ItemListedForSale(uint256 _saleId);

    function initialize() external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function listForSale(
        address _erc1155,
        uint256 _id,
        uint256 _amount,
        address _acceptedERC20,
        uint256 _price
    ) external returns (uint256 saleId) {
        require(
            IERC1155Upgradeable(_erc1155).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Marketplace: Permission not granted to manage asset"
        );

        counter++;
        Commodity memory commodity = Commodity({
            commodityType: TokenTypes.ERC1155,
            owner: msg.sender,
            assetContract: _erc1155,
            id: _id,
            acceptedERC20: _acceptedERC20,
            listedPrice: _price,
            listedForSale: true
        });
        commoditiesForSale[counter] = commodity;
        stock[_erc1155][_id] = _amount;
        saleId = counter;
        emit ItemListedForSale(counter);
    }

    function listForSale(
        address _erc721,
        uint256 _id,
        address _acceptedERC20,
        uint256 _price
    ) external returns (uint256 saleId) {
        require(
            IERC721Upgradeable(_erc721).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Marketplace: Permission not granted to manage asset"
        );

        counter++;
        Commodity memory commodity = Commodity({
            commodityType: TokenTypes.ERC721,
            owner: msg.sender,
            assetContract: _erc721,
            id: _id,
            acceptedERC20: _acceptedERC20,
            listedPrice: _price,
            listedForSale: true
        });
        commoditiesForSale[counter] = commodity;
        stock[_erc721][_id] = 1;
        saleId = counter;
        emit ItemListedForSale(counter);
    }

    // Getters

    function checkAvailability(address _token, uint256 _id)
        external
        view
        returns (uint256)
    {
        return stock[_token][_id];
    }
}
