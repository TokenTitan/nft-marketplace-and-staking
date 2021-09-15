const dotenv = require("dotenv");
dotenv.config();

module.exports = async ({ getNamedAccounts, ethers, upgrades }) => {
  const { deployProxy } = upgrades;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying marketplace from account", deployer);

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await deployProxy(
    Marketplace,
    [process.env.POS_WETH_CONTRACT], // POS_WETH_CONTRACT when deploying on Mumbai
    {
      from: deployer,
    }
  );

  await marketplace.deployed();
  console.log("Marketplace deployed to:", marketplace.address);
};
module.exports.tags = ["Marketplace"];
