const { setEnv } = require("../lib/config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying Asset721 from account", deployer);

  const asset721 = await deploy("Asset721", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
    },
  });

  await setEnv("ASSET_721", asset721.address);
  console.log("Asset721 deployed to:", asset721.address);
};
module.exports.tags = ["Asset721"];
