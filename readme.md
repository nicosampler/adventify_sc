## Adventify Smart Contract

Adventify is a smart contract for an ERC-1155 token that allows the creation of badges for specific locations taken from Google Maps.

### Contract Structure

The Adventify smart contract is composed of four imported contracts and five functions:

### Imported Contracts

ERC1155.sol: a standard ERC-1155 token contract for handling the creation and management of fungible and non-fungible tokens.

Ownable.sol: a contract that defines an owner that has special privileges such as the ability to modify the contract and transfer ownership.

ERC1155Supply.sol: a contract that adds a function for querying the total supply of a given token ID.

ERC1155URIStorage.sol: a contract that adds a function for setting and getting the URI for a given token ID.

### Functions

createPlace(string memory mapPlaceId, string memory metadataUri, bool isVerified): creates a new place, identified by a unique Google Maps location ID, with an associated token ID and metadata URI. The isVerified parameter is used to indicate whether the location has been verified.

createSpecialToken(string memory mapPlaceId, string memory metadataUri, uint256 maxItems): creates a special token for a verified place with the given mapPlaceId, metadataUri, and a maximum number of items that can be minted for that token ID.

updatePlace(string memory mapPlaceId, string memory metadataUri, bool isVerified): updates the metadata URI and verification status for the place identified by the given mapPlaceId.

mint(address account, uint256 \_tokenId, bytes memory data): mints a badge for the given account with the specified token ID and associated data.

burn(address account, uint256 \_tokenId): burns the token with the given ID that is owned by the given account.

### Data Structures

The Adventify smart contract includes three mappings to keep track of places and their associated tokens:

places: a mapping of mapPlaceId to a Place struct, which contains the default token ID for the place and a boolean indicating whether the place has been verified.

tokenIdToPlaceMapId: a mapping of token ID to mapPlaceId.
maxItemsPerToken: a mapping of token ID to the maximum number of items that can be minted for that token ID.
