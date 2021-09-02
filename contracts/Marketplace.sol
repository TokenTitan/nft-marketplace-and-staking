pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Marketplace is AccessControlUpgradeable {
    uint256 counter;
    IERC20Upgradeable weth;

    enum TokenTypes {
        ERC1155,
        ERC721
    }

    mapping(uint256 => Commodity) public commoditiesForSale;
    mapping(address => mapping(uint256 => uint256)) internal saleIdByCommodity;

    // keccak256("DEFAULT_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE =
        0x1effbbff9c66c5e59634f24fe842750c60d18891155c32dd155fc2d661a4c86d;

    // Struct
    struct Commodity {
        TokenTypes commodityType;
        address owner;
        address assetContract;
        uint256 id;
        uint256 amount;
        address acceptedERC20;
        uint256 listedPrice;
        bool listedForSale;
    }

    // Events
    event ItemListedForSale(uint256 _saleId);

    function initialize(IERC20Upgradeable _weth) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        weth = _weth;
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
            amount: _amount,
            acceptedERC20: _acceptedERC20,
            listedPrice: _price,
            listedForSale: true
        });
        saleId = counter++;
        commoditiesForSale[saleId] = commodity;
        saleIdByCommodity[_erc1155][_id] = saleId;
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

        Commodity memory commodity = Commodity({
            commodityType: TokenTypes.ERC721,
            owner: msg.sender,
            assetContract: _erc721,
            id: _id,
            amount: 1,
            acceptedERC20: _acceptedERC20,
            listedPrice: _price,
            listedForSale: true
        });
        saleId = counter++;
        commoditiesForSale[saleId] = commodity;
        saleIdByCommodity[_erc721][_id] = saleId;
        emit ItemListedForSale(counter);
    }

    function buy(uint256 _saleId) external {
        Commodity memory commodity = commoditiesForSale[_saleId];
        IERC20Upgradeable acceptedERC20 = (commodity.acceptedERC20 ==
            address(0))
            ? weth
            : IERC20Upgradeable(commodity.acceptedERC20);

        require(
            hasSufficientBalance(acceptedERC20, commodity.listedPrice),
            "Marketplace: Insufficient Balance"
        );

        // TODO: Transfer commodity to buyer and update contract state data
    }

    // function buyByCommodity(address _erc721, uint256 _id) {}
    // function buyByCommodity(address _erc1155, uint256 _id, uint256 _amount) {}

    // Getters

    function listedForSale(address _token, uint256 _id)
        external
        view
        returns (uint256 saleId)
    {
        return saleIdByCommodity[_token][_id];
    }

    function hasSufficientBalance(
        IERC20Upgradeable _acceptedERC20,
        uint256 _amount
    ) internal view returns (bool balanceCheck) {
        balanceCheck = _acceptedERC20.balanceOf(msg.sender) > _amount;
        if (
            !balanceCheck &&
            _acceptedERC20 == weth &&
            msg.sender.balance > _amount
        ) {
            balanceCheck = true;
        }
    }
}
