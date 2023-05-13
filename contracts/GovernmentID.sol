//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base/ERC4671.sol";

contract GovernmentID is ERC4671, Ownable {
    constructor(
        string memory _idType,
        string memory _idName
    ) ERC4671(_idName, _idType) {}

    mapping(address => uint256) public citizenUID;
    mapping(address => bool) public isBlacklisted;

    event TokenMinted(address indexed _owner, uint256 indexed _tokenId);
    event Blacklisted(address indexed _citizen);
    event Whitelisted(address indexed _citizen);

    modifier zeroAddressCheck(address _addr) {
        require(_addr != address(0), "Zero address");
        _;
    }

    function issueGovernmentID(
        address _citizen,
        string memory _tokenUri
    ) public onlyOwner {
        citizenUID[_citizen] = emittedCount();
        _mint(_citizen);
        setTokenURI(citizenUID[_citizen], _tokenUri);
        emit TokenMinted(_citizen, citizenUID[_citizen]);
    }

    function revokeGovernmentID(address _citizen) public onlyOwner {
        uint256 tokenId = citizenUID[_citizen];
        _revoke(tokenId);
        delete citizenUID[_citizen];
    }

    function blacklistCitizen(
        address _citizen
    ) public onlyOwner zeroAddressCheck(_citizen) {
        isBlacklisted[_citizen] = true;
        if (hasValid(_citizen)) {
            uint256[] memory tokens = tokensOfOwner(_citizen);
            for (uint256 i = 0; i < tokens.length; i++) {
                uint256 tokenId = tokens[i];
                if (isValid(tokenId)) {
                    _revoke(tokenId);
                }
            }
        }
        emit Blacklisted(_citizen);
    }

    function whitelistCitizen(
        address _citizen
    ) public onlyOwner zeroAddressCheck(_citizen) {
        isBlacklisted[_citizen] = false;
        emit Whitelisted(_citizen);
    }
}
