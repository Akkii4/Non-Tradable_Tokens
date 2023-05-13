const { expect } = require("chai");

describe("GovernmentID", function () {
  let governmentID;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    const GovernmentID = await ethers.getContractFactory("GovernmentID");
    governmentID = await GovernmentID.deploy("idType", "idName");

    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("Should set the correct owner", async function () {
      expect(await governmentID.owner()).to.equal(owner.address);
    });
  });

  describe("issueGovernmentID", function () {
    it("Should issue a new government ID", async function () {
      await governmentID.issueGovernmentID(addr1.address, "tokenURI");
      const tokenId = await governmentID.citizenUID(addr1.address);
      expect(await governmentID.ownerOf(tokenId)).to.equal(addr1.address);
    });
  });

  describe("revokeGovernmentID", function () {
    it("Should revoke a government ID", async function () {
      await governmentID.issueGovernmentID(addr1.address, "tokenURI");
      const tokenId = await governmentID.citizenUID(addr1.address);
      await governmentID.revokeGovernmentID(addr1.address);
      expect(await governmentID.ownerOf(tokenId)).to.equal(
        "0x0000000000000000000000000000000000000000"
      );
    });
  });

  describe("blacklist", function () {
    it("Should blacklist a citizen", async function () {
      await governmentID.issueGovernmentID(addr1.address, "tokenURI");
      await governmentID.blacklist(addr1.address);
      expect(await governmentID.isBlacklisted(addr1.address)).to.be.true;
    });
  });

  describe("whitelist", function () {
    it("Should whitelist a citizen", async function () {
      await governmentID.issueGovernmentID(addr1.address, "tokenURI");
      await governmentID.blacklist(addr1.address);
      await governmentID.whitelist(addr1.address);
      expect(await governmentID.isBlacklisted(addr1.address)).to.be.false;
    });
  });

  describe("addVerifier", function () {
    it("Should add a verifier", async function () {
      await governmentID.addVerifier(addr1.address);
      expect(await governmentID.isVerifier(addr1.address)).to.be.true;
    });
  });

  describe("removeVerifier", function () {
    it("Should remove a verifier", async function () {
      await governmentID.addVerifier(addr1.address);
      await governmentID.removeVerifier(addr1.address);
      expect(await governmentID.isVerifier(addr1.address)).to.be.false;
    });
  });
});
