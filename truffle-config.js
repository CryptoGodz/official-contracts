require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const path = require('path');
const KOVAN_URL = "wss://kovan.infura.io/ws/v3/831d85cb6a304f6fbd3e4a9f2209674c";
const BSC_TEST_URL = "https://data-seed-prebsc-1-s3.binance.org:8545";
const BSC_URL = "https://bsc-dataseed3.binance.org";

module.exports = {
  // Uncommenting the defaults below 
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  contracts_build_directory: path.join(__dirname, "contracts/build"),

  networks: {
    dev_app: { 
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    dev_cli: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    kovan: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMOC, KOVAN_URL)
      },
      network_id: '42',
      skipDryRun: true,
    },
    bsc_test: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMOC, BSC_TEST_URL)
      },
      network_id: '97',
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    bsc: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMOC, BSC_URL)
      },
      network_id: '56',
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200,
      skipDryRun: true,
      gas: 10000000,
      gasPrice: 20000000000
    },
  },
  //
  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows: 
  // $ truffle migrate --reset --compile-all
  //
  // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
  // }

  plugins: [
    'truffle-contract-size'
  ],

  // Configure your compilers
  compilers: {
    solc: {
      version: "pragma", // A version or constraint - Ex. "^0.5.0"
                         // Can be set to "native" to use a native solc or
                         // "pragma" which attempts to autodetect compiler versions
      // docker: true, // Use a version obtained through docker
      // parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      settings: {
        optimizer: {
          enabled: true,
          runs: 1337   // Optimize for how many times you intend to run the code
        },
        // evmVersion: "istanbul" // Default: "istanbul"
      },
      // modelCheckerSettings: {
      //   // contains options for SMTChecker
      // }
    }
  }
};
