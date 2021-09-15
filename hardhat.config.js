require("@openzeppelin/hardhat-upgrades");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    matic: {
      url: process.env.MATIC_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },
    gorli: {
      url: process.env.GORLI_INFURA_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
      throwOnTransactionFailures: true,
      loggingEnabled: true,
    },
    arbitrum: {
      url: process.env.ARBITRUM_ALCHEMY_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
      gasPrice: 0,
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};
