const { setEnv } = require("../lib/config");
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying L1ERC20 from account", deployer);

  const erc20 = await deploy("L1ERC20", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
    },
  });

  await setEnv("L1ERC20_ADDRESS", erc20.address);
  console.log("L1ERC20 deployed to:", erc20.address);
};
module.exports.tags = ["L1ERC20"];
