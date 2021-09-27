const { setEnv } = require("../lib/config");
const dotenv = require("dotenv");
dotenv.config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying Asset1155 from account", deployer);

  const asset1155 = await deploy("Asset1155", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
      args: [process.env.TOKEN_URI],
    },
  });

  await setEnv("ASSET_1155", asset1155.address);
  console.log("Asset1155 deployed to:", asset1155.address);
};
module.exports.tags = ["Asset1155"];
