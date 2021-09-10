pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Marketplace is AccessControlUpgradeable {
    uint256 public counter;
    IERC20Upgradeable public weth;

    enum TokenTypes {
        ERC1155,
        ERC721
    }

    // Struct
    struct Commodity {
        TokenTypes commodityType;
        address seller;
        address assetContract;
        uint256 id;
        uint256 amount;
        IERC20Upgradeable acceptedERC20;
        uint256 price;
        bool available;
    }

    // Mappings
    mapping(uint256 => Commodity) public commoditiesForSale;
    mapping(address => mapping(uint256 => uint256)) internal saleIdByCommodity;

    // Events
    event ItemListedForSale(uint256 indexed _saleId);
    event Sold(uint256 indexed _saleId, address _seller);

    function initialize(IERC20Upgradeable _weth) external initializer {
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
            IERC1155Upgradeable(_erc1155).balanceOf(msg.sender, _id) >= _amount,
            "Marketplace: Can only sell the amount owned"
        );

        require(
            IERC1155Upgradeable(_erc1155).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Marketplace: Permission not granted to manage asset"
        );
        
        counter++;
        saleId = saleIdByCommodity[_erc1155][_id] == 0
            ? counter
            : saleIdByCommodity[_erc1155][_id];
        IERC20Upgradeable acceptedERC20 = _acceptedERC20 == address(0)
            ? weth
            : IERC20Upgradeable(_acceptedERC20);
        Commodity memory commodity = Commodity({
            commodityType: TokenTypes.ERC1155,
            seller: msg.sender,
            assetContract: _erc1155,
            id: _id,
            amount: _amount,
            acceptedERC20: acceptedERC20,
            price: _price,
            available: true
        });
        commoditiesForSale[saleId] = commodity;
        saleIdByCommodity[_erc1155][_id] = saleId;
        emit ItemListedForSale(saleId);
    }

    function listForSale(
        address _erc721,
        uint256 _id,
        address _acceptedERC20,
        uint256 _price
    ) external returns (uint256 saleId) {
        require(
            IERC721Upgradeable(_erc721).ownerOf(_id) == msg.sender,
            "Marketplace: Only Owner can create sale"
        );

        require(
            IERC721Upgradeable(_erc721).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Marketplace: Permission not granted to manage asset"
        );
        
        counter++;
        saleId = saleIdByCommodity[_erc721][_id] == 0
            ? counter
            : saleIdByCommodity[_erc721][_id];

        IERC20Upgradeable acceptedERC20 = _acceptedERC20 == address(0)
            ? weth
            : IERC20Upgradeable(_acceptedERC20);
        Commodity memory commodity = Commodity({
            commodityType: TokenTypes.ERC721,
            seller: msg.sender,
            assetContract: _erc721,
            id: _id,
            amount: 1,
            acceptedERC20: acceptedERC20,
            price: _price,
            available: true
        });
        commoditiesForSale[saleId] = commodity;
        saleIdByCommodity[_erc721][_id] = saleId;
        emit ItemListedForSale(saleId);
    }

    function buy(uint256 _saleId) external payable {
        Commodity memory commodity = commoditiesForSale[_saleId];
        require(
            commodity.available,
            "Marketplace: Currently not available for sale"
        );

        commoditiesForSale[_saleId].available = false;
        commoditiesForSale[_saleId].seller = msg.sender;

        if (msg.value == 0) {
            require(
                commodity.acceptedERC20.balanceOf(msg.sender) > commodity.price,
                "Marketplace: Insufficient Balance"
            );
            require(
                commodity.acceptedERC20.allowance(msg.sender, address(this)) >=
                    commodity.price,
                "Marketplace: Insufficient allowance to fetch funds"
            );

            commodity.acceptedERC20.transferFrom(
                msg.sender,
                address(this),
                commodity.price
            );
            _executeSale(commodity, _saleId);
        } else if (
            commodity.acceptedERC20 == weth && commodity.price >= msg.value
        ) {
            uint256 remainder = msg.value - commodity.price;
            if (remainder != 0) {
                payable(msg.sender).transfer(remainder);
            }
            _executeSale(commodity, _saleId);
        } else {
            payable(msg.sender).transfer(msg.value);
        }
    }

    function _executeSale(Commodity memory _commodity, uint256 _saleId)
        internal
    {
        _commodity.commodityType == TokenTypes.ERC721
            ? IERC721Upgradeable(_commodity.assetContract).transferFrom(
                _commodity.seller,
                msg.sender,
                _commodity.id
            )
            : IERC1155Upgradeable(_commodity.assetContract).safeTransferFrom(
                _commodity.seller,
                msg.sender,
                _commodity.id,
                _commodity.amount,
                bytes("Commodity Bought")
            );
        emit Sold(_saleId, msg.sender);
    }

    function cancelSale(uint256 _saleId) external {
        commoditiesForSale[_saleId].available = false;
    }

    // Getters

    function commodityAvailable(address _token, uint256 _id)
        external
        view
        returns (bool)
    {
        uint256 saleId = saleIdByCommodity[_token][_id];
        return commoditiesForSale[saleId].available;
    }
}
