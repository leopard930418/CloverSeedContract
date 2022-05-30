async function main() {
    const team_address = "0x24be59F617ff5B93528F1471b80c1592eFfdF423";
    const marketing_address = "0x6B630A52F5Ec882A78B504065AED16a8C704c609";
    // const seedFT_address = "0x1969ae662f6cfC5C2220f6687b2C03FaE1025734"
    // const seedNFT_address = "0x9F46Aeb26b37921574b9C614Ce869D1d481cCE9c"
    // const seedController_address = "0xC1FA1087f8b5e1242028Dce7d257d48579e807b1"
    // const seedPicker_address = "0xc5199467A5e1cBC19ecfd0Bb6CFEfFaE9a1349f8"


    const seedFT = await ethers.getContractFactory("Clover_Seeds_Token");
    const seedNFT = await ethers.getContractFactory("Clover_Seeds_NFT");
    const seedController = await ethers.getContractFactory("Clover_Seeds_Controller");
    const seedPicker= await ethers.getContractFactory("Clover_Seeds_Picker");
    const seedStake= await ethers.getContractFactory("Clover_Seeds_Stake" ,{
      libraries: {
        IterableMapping: "0x267f604461E0D879d46B328fa70e95A0298be8A3",
      }
    });

    const seedFTContract = await seedFT.deploy(team_address, marketing_address);
    console.log("Clover_Seeds_Token deployed to:", seedFTContract.address);
    const seedFT_address = seedFTContract.address;

    const seedNFTContract = await seedNFT.deploy(seedFT_address);
    console.log("Clover_Seeds_NFT deployed to:", seedNFTContract.address);
    const seedNFT_address = seedNFTContract.address;

    const seedControllerContract = await seedController.deploy(team_address, seedFT_address, seedNFT_address) ;
    console.log("Clover_Seeds_Controller deployed to:", seedControllerContract.address);
    const seedController_address = seedControllerContract.address;

    const seedPickerContract = await seedPicker.deploy(seedNFT_address, seedController_address) ;
    console.log("Clover_Seeds_Picker deployed to:", seedPickerContract.address);
    const seedPicker_address = seedPickerContract.address;

    const seedStakeContract = await seedStake.deploy(marketing_address, seedFT_address, seedNFT_address, seedController_address, seedPicker_address);
    console.log("Clover_Seeds_Stake deployed to:", seedStakeContract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });