const { setEnv } = require("../lib/config");
const { TAZOS_ADDRESS } = require("../config.json");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log("Deploying StakingArena from account", deployer);

  const stakingArena = await deploy("StakingArena", {
    from: deployer,
    proxy: {
      owner: deployer,
      method: "initialize",
      args: [TAZOS_ADDRESS],
    },
  });

  await setEnv("STAKING_ARENA_ADDRESS", stakingArena.address);
  console.log("StakingArena deployed to:", stakingArena.address);
};
module.exports.tags = ["StakingArena"];
module.exports.dependencies = ['Tazos'];
