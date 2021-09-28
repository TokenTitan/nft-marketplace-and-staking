const { TAZOS_ADDRESS } = require("../config.json");
const { deployments, getNamedAccounts } = require("hardhat");
const { setEnv } = require("../lib/config");
const dotenv = require("dotenv");
dotenv.config();

async function deployL2Contracts() {
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  console.log("Deploying contracts from account: ", deployer);

  const asset721 = await deploy("ChildAsset721", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "init",
      args: [TAZOS_ADDRESS],
    },
  });
  await setEnv("CHILD_ASSET_721", asset721.address);
  console.log("Asset721 deployed to:", asset721.address);

  const asset1155 = await deploy("ChildAsset1155", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "init",
      args: [process.env.TOKEN_URI, process.env.CHILD_CHAIN_MANAGER_PROXY],
    },
  });
  await setEnv("CHILD_ASSET_1155", asset1155.address);
  console.log("Asset1155 deployed to:", asset1155.address);

  const tazos = await deploy("ChildTazos", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "init",
      args: [process.env.CHILD_CHAIN_MANAGER_PROXY],
    },
  });
  await setEnv("CHILD_TAZOS", tazos.address);
  console.log("Tazos deployed to:", tazos.address);

  const market = await deploy("Marketplace", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "init",
      args: [process.env.MUMBAI_WETH_CONTRACT, tazos.address],
    },
  });
  console.log("Marketplace deployed to:", market.address);
}

deployL2Contracts()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
