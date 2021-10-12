const AdExICO = artifacts.require("AdExICO");
const BigNumber = require('bignumber.js');
//Test if contract is deployed properly
contract("AdExICO", accounts => {
    let newAdExICO = null;
    before(async() => {
        newAdExICO = await AdExICO.deployed();
    })
    it("Deploy smart contract.", async() => {
        console.log(newAdExICO.address);
        assert(newAdExICO.address != '');
    });
    it("Should get name when calling getname().", async() => {
        var name = await newAdExICO.getName();
        console.log(name);
        assert(name === "AdEx");
    });
    it("Should get symbol when calling getSymbol().", async() => {
        var symbol = await newAdExICO.getSymbol();
        console.log(symbol);
        assert(symbol === "ADX");
    });
    it("Should get totalSupply when calling getTotalSupply().", async() => {
        var totalSupply = await newAdExICO.getTotalSupply();
        console.log(totalSupply);
        assert(totalSupply.toString() === "100000000");
    });
    it("Should get hardCap when calling getHardCap().", async() => {
        var hardCap = await newAdExICO.getHardCap();
        console.log(hardCap);
        assert(hardCap.toNumber() === 40000);
    });
    it("Should get start day and end day difference when calling getStartDayEndDayDiff().", async() => {
        var getStartDayEndDayDiff = await newAdExICO.getStartDayEndDayDiff();
        console.log(getStartDayEndDayDiff);
        assert(getStartDayEndDayDiff.toNumber() === 30);
    });

    it("Should get start day when calling getStartDAte.", async() => {
        var getStartDate = await newAdExICO.getStartDate();
        console.log(getStartDate);
        assert(getStartDate.toNumber() > 0);
    });

    it("Should buy AdEx tokens using ETH.", async() => {
        const instance = await AdExICO.deployed();
        const tokenBuyer = accounts[3];
        const meta = instance;

        let balance = await instance.ownerEtherBalance();
        const balanceOfContractAddress = balance.toNumber();
        balance = await instance.balanceOf(tokenBuyer);
        let balanceOfTokenBuyer = balance.toNumber();

        console.log(balanceOfContractAddress);
        console.log(tokenBuyer);
        console.log(balanceOfTokenBuyer);

        const amount = 2;
        await instance.buyADX({
            from: tokenBuyer,
            value: web3.utils.toWei(amount.toString(), "ether")
        });

        balance = await instance.ownerEtherBalance();
        const newBalanceOfContractAddress = balance.toNumber();
        console.log(newBalanceOfContractAddress);
        assert((balanceOfContractAddress + amount) === newBalanceOfContractAddress, "ETH wasn't correctly sent to the contract address");

        balance = await instance.balanceOf(tokenBuyer);
        balanceOfTokenBuyer = balance.toNumber();
        let tokensEarned = (amount * 900) * 130 / 100;
        assert.equal(tokensEarned, balanceOfTokenBuyer, "Amount wasn't correctly sent to the receiver");
    });

    it("Should calculate token bonus by given token amount", async() => {
        const instance = await AdExICO.deployed();
        const amount = 1000;
        let tokenBonus = await instance.getBonusTokens(amount);
        console.log(tokenBonus);
        assert.equal(tokenBonus.toNumber(), 1300, "Bonus should be amount * 130 /100");
    });
});