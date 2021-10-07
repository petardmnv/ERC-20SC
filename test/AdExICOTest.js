const AdExICO = artifacts.require("AdExICO");

//Test if contract is deployed properly
contract("AdExICO", () => {
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

});