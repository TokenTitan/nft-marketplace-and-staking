const dotenv = require("dotenv");
dotenv.config();

module.exports = async ({ getNamedAccounts, ethers, upgrades }) => {
  const { deployProxy } = upgrades;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying asset from account", deployer);

  const Asset = await ethers.getContractFactory("Asset");
  const asset = await deployProxy(Asset, [""], { from: deployer });

  // Deploying Child Asset when deploying on Matic
  // const Asset = await ethers.getContractFactory("ChildAsset");
  // const asset = await deployProxy(Asset, ["", process.env.CHILD_CHAIN_MANAGER_PROXY], { from: deployer });

  await asset.deployed();
  console.log("Asset deployed to:", asset.address);
};
module.exports.tags = ["Asset"];
