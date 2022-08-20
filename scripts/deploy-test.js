const hre = require("hardhat")

async function main() {
    const contract = await hre.ethers.getContractFactory("Tesrative");
    const deployedContract = await contract.deploy();

    await deployedContract.deployed();

    console.log("Tarurative depoyed to:", deployedContract.address);

    const tokenURI = deployedContract.tokenURI;
    console.log("TOKEN URI: ", tokenURI)
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
})