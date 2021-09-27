const { setEnv } = require("../lib/config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying Tazos from account", deployer);

  const tazos = await deploy("Tazos", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
    },
  });

  await setEnv("TAZOS_ADDRESS", tazos.address);
  console.log("Tazos deployed to:", tazos.address);
};
module.exports.tags = ["Tazos"];
