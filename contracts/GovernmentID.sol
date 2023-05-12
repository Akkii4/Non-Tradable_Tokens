//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base/ERC4671.sol";

contract GovernmentID is ERC4671, Ownable {
    constructor(
        string memory _idType,
        string memory _idName
    ) ERC4671(_idName, _idType) {}

    mapping(address => uint256) public personUID;

    event TokenMinted(address indexed _owner, uint256 indexed _tokenId);

    function issueGovernmentID(
        address _person,
        string memory _tokenUri
    ) public onlyOwner {
        personUID[_person] = emittedCount();
        _mint(_person);
        setTokenURI(personUID[_person], _tokenUri);
        emit TokenMinted(_person, personUID[_person]);
    }
}
