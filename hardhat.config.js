require("@openzeppelin/hardhat-upgrades");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
const dotenv = require("dotenv");
const { version } = require("ethers");
dotenv.config();

module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    gorli: {
      url: process.env.GORLI_INFURA_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
      throwOnTransactionFailures: true,
      loggingEnabled: true,
      gas: 100000000000000,
    },
    mumbai: {
      url: process.env.MUMBAI_ALCHEMY_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 100000000000000,
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};
