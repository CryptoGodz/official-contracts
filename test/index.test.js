const SoulBEP20 = artifacts.require('SoulBEP20');
const SentzNFT = artifacts.require('SentzNFT');
const truffleAssert = require('truffle-assertions');

contract('SoulBEP20', (accounts) => {
    let soul, sentz;
    const fundingAccount = accounts[0];

    // build up and tear down a new Casino contract before each test
    beforeEach(async () => {
        if (!soul) {
            soul = await SoulBEP20.deployed();
        }
        if (!sentz) {
            sentz = await SentzNFT.deployed();
        }
    });

    it("spawn", async () => {
        tx = await sentz.spawn(1, { from: fundingAccount });

        // player should be the same as the betting account, and the payout should be 10 times the bet size
        truffleAssert.eventEmitted(tx, 'LogTransfer', (ev) => {
            console.log('event result');
            console.log(ev);
            return true;
        });
    });
    
    // const soul = await SoulBEP20.deployed()
    // await soul.approve("0x1d43935BC02a17411557a36A0f4EAC11E9EdD351", web3.utils.toBN(2000).mul(web3.utils.toBN(10).pow(web3.utils.toBN(18))))
   
   
   
    // const sentz = await SentzNFT.deployed()

    // it("transfer from", async () => {
    //     let tx = await soul.transferFrom(fundingAccount, accounts[1], 10, { from: fundingAccount });

    //     // player should be the same as the betting account, and the payout should be 10 times the bet size
    //     truffleAssert.eventEmitted(tx, 'Log', (ev) => {
    //         console.log('event result');
    //         console.log(ev);
    //         return true;
    //     });
    // });
});