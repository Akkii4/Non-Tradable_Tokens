const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GovernmentID", function () {
  let governmentID;
  let owner;
  let citizen1;
  let citizen2;

  beforeEach(async function () {
    const GovernmentID = await ethers.getContractFactory("GovernmentID");
    [owner, citizen1, citizen2] = await ethers.getSigners();
    governmentID = await GovernmentID.deploy("Passport", "PASS");
    await governmentID.deployed();
  });

  it("should issue a government ID to a citizen", async function () {
    const tokenUri = "https://example.com/token";
    await governmentID.issueGovernmentID(citizen1.address, tokenUri);
    const tokenId = await governmentID.citizenUID(citizen1.address);
    expect(tokenId).to.equal(0);
    expect(await governmentID.ownerOf(tokenId)).to.equal(citizen1.address);
    expect(await governmentID.tokenURI(tokenId)).to.equal(tokenUri);
    expect(await governmentID.isValid(tokenId)).to.be.true;
    expect(await governmentID.hasValid(citizen1.address)).to.be.true;
  });

  it("should blacklist a citizen", async function () {
    const tokenUri = "https://example.com/token";

    await governmentID.issueGovernmentID(citizen1.address, tokenUri);
    await governmentID.issueGovernmentID(citizen2.address, tokenUri);

    await governmentID.blacklistCitizen(citizen1.address);

    const isBlacklisted1 = await governmentID.isBlacklisted(citizen1.address);
    const isBlacklisted2 = await governmentID.isBlacklisted(citizen2.address);
    expect(isBlacklisted1).to.be.true;
    expect(isBlacklisted2).to.be.false;

    const tokens = await governmentID.tokensOfOwner(citizen1.address);
    const isRevoked = await governmentID.isValid(tokens[0]);
    expect(isRevoked).to.be.false;
  });

  it("should return all ids owned by an citizen", async function () {
    const tokenUris = [
      "https://example.com/token1",
      "https://example.com/token2",
    ];
    await governmentID.issueGovernmentID(citizen1.address, tokenUris[0]);
    await governmentID.issueGovernmentID(citizen1.address, tokenUris[1]);
    const tokens = await governmentID.tokensOfOwner(citizen1.address);
    expect(tokens.length).to.equal(2);
    expect(await governmentID.tokenURI(tokens[0])).to.equal(tokenUris[0]);
    expect(await governmentID.tokenURI(tokens[1])).to.equal(tokenUris[1]);
  });

  it("should return the total number of ids issued", async function () {
    const tokenUris = [
      "https://example.com/token1",
      "https://example.com/token2",
    ];
    await governmentID.issueGovernmentID(citizen1.address, tokenUris[0]);
    await governmentID.issueGovernmentID(citizen2.address, tokenUris[1]);
    expect(await governmentID.emittedCount()).to.equal(2);
  });

  it("should return the total number of ids holders", async function () {
    const tokenUris = [
      "https://example.com/token1",
      "https://example.com/token2",
    ];
    await governmentID.issueGovernmentID(citizen1.address, tokenUris[0]);
    await governmentID.issueGovernmentID(citizen2.address, tokenUris[1]);
    expect(await governmentID.holdersCount()).to.equal(2);
  });
});
