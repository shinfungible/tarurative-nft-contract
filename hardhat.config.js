require("dotenv").config();

require('hardhat-contract-sizer');
require("solidity-coverage");
require('hardhat-gas-reporter');
require('hardhat-deploy');
require('hardhat-deploy-ethers');
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

function getMnemonic(networkName) {
  if (networkName) {
    const mnemonic = process.env['MNEMONIC_' + networkName.toUpperCase()]
    if (mnemonic && mnemonic !== '') {
      return mnemonic
    }
  }

  const mnemonic = process.env.MNEMONIC
  if (!mnemonic || mnemonic === '') {
    return 'test test test test test test test test test test test junk'
  }

  return mnemonic
}

function accounts(chainKey) {
  return { mnemonic: getMnemonic(chainKey) }
}

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  // solidity: "0.8.4",
  contractSizer: {
    alphaSort: false,
    runOnCompile: true,
    disambiguatePaths: false,
  },

  namedAccounts: {
    deployer: {
      default: 0,    // wallet address 0, of the mnemonic in .env
    }
  },

  networks: {
    polygon: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/svGj_UjuF4fGCw5jCDzV1oFJ9IbNllRu",
      chainId: 137,
      accounts: accounts(),
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/4VVTnG_GjxsnEJGcqF-lB4Kxs9_aFYbZ", // public infura endpoint
      chainId: 4,
      accounts: accounts(),
    },
  },
  etherscan: {
    // apiKey: 'WBT5H7DHNZVP8149E5878DBY3HQQDKDDTH' // Etherscan
    apiKey: 'F2F9Y35AE8VA444WCP8EBYQNU3VDF27DFC' // Polygonscan
  }

};