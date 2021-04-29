const powerball = artifacts.require("Powerball");

module.exports = function (deployer) {
    deployer.deploy(powerball);
};