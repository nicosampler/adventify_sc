// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

contract Adventify is ERC1155, Ownable, ERC1155Supply, ERC1155URIStorage {
    error Adventify_mint_onlyOwner();

    struct Place {
        uint256 defaultTokenId;
        bool isVerified;
    }

    // tokens ids tracker
    uint256 public tokenId = 0;

    constructor() ERC1155("") {}

    // holds all the places.
    mapping(string => Place) public places;
    // links a tokenId with a mapPlaceId.
    mapping(uint256 => string) public tokenIdToPlaceMapId;
    // set max amount of items per tokenId (0 is undefined)
    mapping(uint256 => uint256) public maxItemsPerToken;

    /**
     * @notice Create a new place if it does not exists yet. Only callable by the owner.
     * @param mapPlaceId from Google maps API.
     * @param metadataUri IPFS URL of the metadata of the place
     * @param isVerified if the Place is verified
     */
    function createPlace(string memory mapPlaceId, string memory metadataUri, bool isVerified) public onlyOwner {
        require(places[mapPlaceId].defaultTokenId == 0, "Place already exists");

        // create default token for place
        tokenId++;
        _setURI(tokenId, metadataUri);

        // register place
        places[mapPlaceId] = Place(tokenId, isVerified);

        tokenIdToPlaceMapId[tokenId] = mapPlaceId;
        maxItemsPerToken[tokenId] = 0;
    }

    /**
     * @notice Create a special token for verified place
     * @param mapPlaceId from Google maps API.
     * @param metadataUri IPFS URL of the metadata of the place
     * @param maxItems if the Place is verified
     */
    function createSpecialToken(
        string memory mapPlaceId,
        string memory metadataUri,
        uint256 maxItems
    ) public onlyOwner {
        Place storage _place = places[mapPlaceId];
        require(_place.isVerified == true, "Place is not verified");

        // create token
        tokenId++;
        _setURI(tokenId, metadataUri);

        tokenIdToPlaceMapId[tokenId] = mapPlaceId;
        maxItemsPerToken[tokenId] = maxItems;
    }
 
    /**
     * @notice Update isVerified and metadataUri for a place.
     * @param mapPlaceId from Google maps API.
     * @param metadataUri IPFS URL of the metadata of the place
     * @param isVerified if the Place is verified
     */
    function updatePlace(string memory mapPlaceId, string memory metadataUri, bool isVerified) public onlyOwner {
        Place storage _place = places[mapPlaceId];
        require(_place.defaultTokenId != 0, "Place does not exists");

        _place.isVerified = isVerified;

        if (bytes(metadataUri).length > 0) {
            _setURI(_place.defaultTokenId, metadataUri);
        }
    }

    /**
     * @notice Mints a badge for an address.
     * @param account The address that will receive the item.
     * @param _tokenId the tokenId
     * @param data data
     */
    function mint(address account, uint256 _tokenId, bytes memory data) public {
        require(tokenId >= _tokenId, "Token does not exists.");
        require(
            maxItemsPerToken[_tokenId] == 0 || maxItemsPerToken[_tokenId] < totalSupply(_tokenId),
            "This token has reached the max items amount"
        );

        string memory placeId = tokenIdToPlaceMapId[_tokenId];
        Place storage place = places[placeId];

        if (place.isVerified && owner() != _msgSender()) {
            revert Adventify_mint_onlyOwner();
        }

        _mint(account, _tokenId, 1, data);
    }

    /**
     * @notice Burns a token, it has to be called by the address owning the token.
     * @param account The address that will receive the item.
     * @param _tokenId the tokenId
     */
    function burn(address account, uint256 _tokenId) public {
        require(tokenId >= _tokenId, "Token does not exists.");
        require(msg.sender == account, "Forbidden");
        _burn(account, _tokenId, 1);
    }

    // TODO: transfer logic

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

    function uri(uint256 id) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(id);
    }
}
