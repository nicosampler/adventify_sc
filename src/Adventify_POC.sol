// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Adventify_POC is ERC1155, Ownable, ERC1155Supply, ERC1155URIStorage {
    struct Place {
        uint256 defaultTokenId;
        bool isVerified;
        uint256 maxItems;
        uint256 itemsAmount;
    }

    constructor() ERC1155("") {}

    // holds all the places.
    mapping(string => Place) public places;
    // links a mapPlaceId with a placeId.
    // mapping(string => uint256) public mapPlaceIdToPlaceId;
    // links a tokenId with a placeId.
    mapping(uint256 => string) public tokenIdBelongsToPlaceId;

    /**
     * @notice Create a new place if it does not exists yet. Only callable by the owner.
     * @param mapPlaceId from Google maps API.
     * @param metadataUri IPFS URL of the metadata of the place
     * @param isVerified if the Place is verified
     */
    function createPlace(
        string memory mapPlaceId,
        string memory metadataUri,
        bool isVerified
    ) public onlyOwner {
        require(places[mapPlaceId].defaultTokenId == 0, "Place already exists");

        // create tokenId
        _setURI(tokenId++, metadataUri);

        // register place
        places[mapPlaceId] = Place(tokenId, isVerified, type(uint256).max, 0);

        // link token with place
        tokenIdBelongsToPlaceId(tokenId, mapPlaceId);
    }

    function updatePlace(
        string memory mapPlaceId,
        bool isVerified,
        string memory metadataUri
    ) public onlyOwner {
        Place storage _place = places[mapPlaceId];
        require(_place.defaultTokenId != 0, "Place does not exists");

        _place.isVerified = isVerified;

        if (bytes(emitter.metadata).length > 0) {
            _setUri(_place.defaultTokenId, metadataUri);
        }
    }

    function mint(
        address account,
        uint256 id,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, 1, data);
    }

    // --------------
    // Overrides
    // --------------

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function uri(
        uint256 id
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(id);
    }
}
