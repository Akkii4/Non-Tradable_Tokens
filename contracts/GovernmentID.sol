//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base/ERC4671.sol";

contract GovernmentID is ERC4671, Ownable {
    mapping(address => bool) public isVerifier;

    constructor(
        string memory _idType,
        string memory _idName
    ) ERC4671(_idName, _idType) {
        isVerifier[owner()] = true;
    }

    mapping(address => uint256) public citizenUID;
    mapping(address => bool) public isBlacklisted;

    event TokenMinted(address indexed _owner, uint256 indexed _tokenId);
    event Blacklisted(address indexed _citizen);
    event Whitelisted(address indexed _citizen);
    event VerifierAdded(address indexed _verifier);
    event VerifierRemoved(address indexed _verifier);

    modifier onlyVerifier() {
        require(isVerifier[msg.sender], "Caller is not a verifier");
        _;
    }

    modifier zeroAddressCheck(address _addr) {
        require(_addr != address(0), "Zero address");
        _;
    }

    function issueGovernmentID(
        address _citizen,
        string memory _tokenUri
    ) public {
        citizenUID[_citizen] = emittedCount();
        _mint(_citizen);
        setTokenURI(citizenUID[_citizen], _tokenUri);
        emit TokenMinted(_citizen, citizenUID[_citizen]);
    }

    function revokeGovernmentID(address _citizen) public {
        uint256 tokenId = citizenUID[_citizen];
        _revoke(tokenId);
        delete citizenUID[_citizen];
    }

    function blacklist(address _citizen) public {
        require(_citizen != address(0), "Cannot blacklist zero address");
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

    function whitelist(address _citizen) public zeroAddressCheck(_citizen) {
        isBlacklisted[_citizen] = false;
        emit Whitelisted(_citizen);
    }

    function addVerifier(address _verifier) public zeroAddressCheck(_verifier) {
        isVerifier[_verifier] = true;
        emit VerifierAdded(_verifier);
    }

    function removeVerifier(address _verifier) public {
        isVerifier[_verifier] = false;
        emit VerifierRemoved(_verifier);
    }

    function ownerOf(
        uint256 tokenId
    ) public view override(ERC4671) returns (address) {
        require(
            isVerifier[msg.sender] || _isTokenOwner(tokenId),
            "Unauthorized access"
        );
        return super.ownerOf(tokenId);
    }

    function balanceOf(
        address owner
    ) public view override(ERC4671) returns (uint256) {
        require(
            isVerifier[msg.sender] || msg.sender == owner,
            "Unauthorized access"
        );
        return super.balanceOf(owner);
    }

    function tokensOfOwner(
        address owner
    ) public view override(ERC4671) returns (uint256[] memory) {
        require(
            isVerifier[msg.sender] || msg.sender == owner,
            "Unauthorized access"
        );
        return super.tokensOfOwner(owner);
    }

    function hasValid(
        address owner
    ) public view override(ERC4671) returns (bool) {
        require(
            isVerifier[msg.sender] || msg.sender == owner,
            "Unauthorized access"
        );
        return super.hasValid(owner);
    }

    function isValid(
        uint256 tokenId
    ) public view override(ERC4671) returns (bool) {
        require(
            isVerifier[msg.sender] || _isTokenOwner(tokenId),
            "Unauthorized access"
        );
        return super.isValid(tokenId);
    }

    function _isTokenOwner(uint256 tokenId) internal view returns (bool) {
        return ownerOf(tokenId) == msg.sender;
    }
}
