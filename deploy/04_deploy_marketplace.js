const { setEnv } = require("../lib/config");
const { TAZOS_ADDRESS } = require("../config.json");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying Marketplace from account", deployer);

  const market = await deploy("Marketplace", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
      args: [process.env.GORLI_WETH_CONTRACT, TAZOS_ADDRESS],
    },
  });

  await setEnv("MARKETPLACE_ADDRESS", market.address);
  console.log("Marketplace deployed to:", market.address);
};
module.exports.tags = ["Marketplace"];
module.exports.dependencies = ['Tazos'];
