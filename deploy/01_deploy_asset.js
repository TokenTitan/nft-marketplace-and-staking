const dotenv = require("dotenv");
dotenv.config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying asset from account", deployer);

  const asset = await deploy("Asset", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
      args: ["https://goerli.etherscan.io/"],
    },
  });

  // Deploying Child Asset when deploying on Mumbai/Matic
  // const asset = await deploy("ChildAsset", {
  //   from: deployer,
  //   proxy: {
  //     owner: deployer,
  //     method: "initialize",
  //     args: ["", process.env.CHILD_CHAIN_MANAGER_PROXY],
  //   },
  // });

  console.log("Asset deployed to:", asset.address);
};
module.exports.tags = ["Asset"];
