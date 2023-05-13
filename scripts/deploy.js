async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const GovernmentID = await ethers.getContractFactory("GovernmentID");
  const governmentID = await GovernmentID.deploy("idType", "idName");

  console.log("GovernmentID address:", governmentID.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
