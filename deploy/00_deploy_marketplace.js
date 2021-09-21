const dotenv = require("dotenv");
dotenv.config();

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying marketplace from account", deployer);

  const marketplace = await deploy("Marketplace", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
      args: [process.env.GORLI_WETH_CONTRACT], // MUMBAI_WETH_CONTRACT when deploying on Mumbai
    },
  });

  console.log("Marketplace deployed to:", marketplace.address);
};
module.exports.tags = ["Marketplace"];
