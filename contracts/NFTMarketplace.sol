// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // 데이터의 아이디 혹은 데이터의 길이를 나타낸다
    Counters.Counter private _itemSold; // 판매수량

    uint256 listingPrice = 0.025 ether; // NFT 게시 수수료
    address payable owner; // NFT 소유자

    constructor() ERC721("Metaverse Tokens", "METT") {
        // NFT이름 지정, 약어 지정
        owner = payable(msg.sender);
    }

    mapping(uint256 => MarketItem) private idToMarketItem; // {id:MarketItem}

    struct MarketItem {
        // MarketItem 객체
        uint256 tokenId; // NFT_ID
        address payable seller; // 판매자
        address payable owner; // 소유자
        uint256 price; // 가격
        bool sold; // 판매상태
    }

    // 이벤트가 수행되었다는 상태를 알수있게해주는 트리거
    event MarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // 수수료 수정 함수
    function updateListingPrice(uint _listingPrice) public payable {
        require(
            owner == msg.sender,
            "Only marketplace owner can update list price."
        );
        listingPrice = _listingPrice;
    }

    // 현재 수수료 파악 함수
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // NFT생성 함수
    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint)
    {
        _tokenIds.increment(); // 새로운 NFT가 생성될 때 마다 ID를 하나씩 증가시켜준다.
        uint256 newTokenId = _tokenIds.current(); // 현재의 ID번호를 가져온다.

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI); // NFT아이디와 이미지를 매핑시켜준다
        createMarketItem(newTokenId, price); // NFT를 생성한다.

        return newTokenId;
    }

    // NFT 생성함수
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at lest 1wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        // {tokenId:MarketItem} 매핑 시킨다.
        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        // 호출자의 주소에서 컨트렉트의 주소로 토큰아이디를 전송
        _transfer(msg.sender, address(this), tokenId);
        // 이벤트를 유발한다. -> 이벤트 유발을 통해 현재 이벤트가 발생했다는걸 프론트에 알려 줄 수 있다.
        emit MarketItemCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    // 판매상태를 불가에서 판매가능으로 변경하는 함수
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(
            idToMarketItem[tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemSold.decrement();

        // 호출자의 주소에서 컨트렉트의 주소로 토큰아이디를 전송
        _transfer(msg.sender, address(this), tokenId);
    }

    // NFT판매
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price; // tokenId기준으로 가격을 가져온다.
        address seller = idToMarketItem[tokenId].seller; // tokenId기준으로 판매자를 가져온다.
        require(
            msg.value == price,
            "Please submit the asking price in order t0 complete the purchase"
        );
        idToMarketItem[tokenId].owner = payable(msg.sender); // 현재 함수를 호출한 사람을 구매자로 설정
        idToMarketItem[tokenId].sold = true; // 판매상태를 판매로 설정
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemSold.increment(); // 판매 수량 증가
        _transfer(address(this), msg.sender, tokenId);

        payable(owner).transfer(listingPrice); // 소유자에게 게시 수수료 전송
        payable(seller).transfer(msg.value); // 판매자에게 금액 전송
    }

    // NFT 마켓 아이템들을 모두 가져온다.
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current(); // 현재 아이템 수량을 가져온다.
        uint unsoldItemCount = _tokenIds.current() - _itemSold.current(); // 현재 아이템 수량에서 판매된 아이템의 수량을 빼서 판매가 가능한 수량을 가져온다.
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            // 아이템 수량만큼 반복
            if (idToMarketItem[i + 1].owner == address(this)) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // NFT 마켓 아이템을 하나 가져온다.
    function fetchMarketItem(uint _tokenId)
        public
        view
        returns (MarketItem memory)
    {
        return idToMarketItem[_tokenId];
    }

    // 함수를 호출한 사람의 NFT를 불러온다.
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // 내가 게시한 아이템을 가져온다.
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
