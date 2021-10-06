const safeMath = artifacts.require("SafeMath.sol");
const AdEx = artifacts.require("AdExICO.sol");

module.exports = function(deployer) {
    deployer.deploy(safeMath);
    deployer.link(safeMath, AdEx);
    deployer.deploy(AdEx);
};