const { expect } = require("chai");

let team_address = "0x24be59F617ff5B93528F1471b80c1592eFfdF423";
let marketing_address = "0x6B630A52F5Ec882A78B504065AED16a8C704c609";
let reward_address = "0xbED6f3b2e6557Fe370Cb7aEB0C116b695BFf1925";

describe("My Test!", function() {
  it("Mint function test", async function() {
    const [owner] = await ethers.getSigners();
    team_address = owner1.address;
    marketing_address = owner2.address;
    const seedFT = await ethers.getContractFactory("Clover_Seeds_Token");
    const seedNFT = await ethers.getContractFactory("Clover_Seeds_NFT");
    const seedController = await ethers.getContractFactory("Clover_Seeds_Controller");
    const  seedPicker= await ethers.getContractFactory("Clover_Seeds_Picker");
    const  seedStake= await ethers.getContractFactory("Clover_Seeds_Stake");

    const seedFTContract = await seedFT.deploy(team_address, marketing_address);
    console.log("Clover_Seeds_Token deployed to:", seedFTContract.address);
    await seedFTContract.deployed();

    const seedNFTContract = await seedNFT.deploy(seedFTContract.address);
    console.log("Clover_Seeds_NFT deployed to:", seedNFTContract.address);
    await seedNFTContract.deployed();

    const seedControllerContract = await seedController.deploy(seedFTContract.address, seedNFTContract.address) ;
    console.log("Clover_Seeds_Controller deployed to:", seedControllerContract.address);
    await seedControllerContract.deployed();

    const seedPickerContract = await seedPicker.deploy(seedNFTContract.address, seedControllerContract.address) ;
    console.log("Clover_Seeds_Picker deployed to:", seedPickerContract.address);
    await seedPickerContract.deployed();

    const seedStakeContract = await seedStake.deploy(marketing_address, seedFTContract.address, seedNFTContract.address, seedControllerContract.address, seedPickerContract.address);
    console.log("Clover_Seeds_Stake deployed to:", seedStakeContract.address);
    await seedStakeContract.deployed();

    await seedFTContract.AddController(seedNFTContract.address);
    await seedFTContract.AddController(seedControllerContract.address);
    await seedFTContract.AddController(seedStakeContract.address);
    await seedFTContract.enableTrading();

    await seedNFTContract.addMinter(seedControllerContract.address);
    await seedNFTContract.setClover_Seeds_Picker(seedPickerContract.address);
    await seedNFTContract.setController(seedControllerContract.address);
    await seedNFTContract.setApprover(seedStakeContract.address);

    await seedControllerContract.setClover_Seeds_Picker(seedPickerContract.address);
    await seedControllerContract.setClover_Seeds_Stake(seedStakeContract.address);
    await seedControllerContract.ActiveThisContract();


    await seedPickerContract.setBaseURIFieldCarbon("https://ipfs.io/ipfs/QmZZFVLnwmJ5SBev4v337giMVSYxQuEBV5dzyAyzwSDESc/");
    await seedPickerContract.setBaseURIFieldDiamond("https://ipfs.io/ipfs/QmefEjS8ohnTR4VoBtCHFBGpv2PGMLeBHXHEkgUGs2ZeRw/");
    await seedPickerContract.setBaseURIFieldPearl("https://ipfs.io/ipfs/QmWy3rbUwmVtQQzZ3HGxivvqzz2EGsGDtWqLdcjxUdJxAo/");
    await seedPickerContract.setBaseURIFieldRuby("https://ipfs.io/ipfs/QmWKMynTu3jVsCFheNajEBv8ahM2X9Tqt2jhLtzsarGNvw/");

    await seedPickerContract.setBaseURIYardCarbon("https://ipfs.io/ipfs/QmZZFVLnwmJ5SBev4v337giMVSYxQuEBV5dzyAyzwSDESc/");
    await seedPickerContract.setBaseURIYardDiamond("https://ipfs.io/ipfs/QmefEjS8ohnTR4VoBtCHFBGpv2PGMLeBHXHEkgUGs2ZeRw/");
    await seedPickerContract.setBaseURIYardPearl("https://ipfs.io/ipfs/QmWy3rbUwmVtQQzZ3HGxivvqzz2EGsGDtWqLdcjxUdJxAo/");
    await seedPickerContract.setBaseURIYardRuby("https://ipfs.io/ipfs/QmWKMynTu3jVsCFheNajEBv8ahM2X9Tqt2jhLtzsarGNvw/");

    await seedPickerContract.setBaseURIPotCarbon("https://ipfs.io/ipfs/QmZZFVLnwmJ5SBev4v337giMVSYxQuEBV5dzyAyzwSDESc/");
    await seedPickerContract.setBaseURIPotDiamond("https://ipfs.io/ipfs/QmefEjS8ohnTR4VoBtCHFBGpv2PGMLeBHXHEkgUGs2ZeRw/");
    await seedPickerContract.setBaseURIPotPearl("https://ipfs.io/ipfs/QmWy3rbUwmVtQQzZ3HGxivvqzz2EGsGDtWqLdcjxUdJxAo/");
    await seedPickerContract.setBaseURIPotRuby("https://ipfs.io/ipfs/QmWKMynTu3jVsCFheNajEBv8ahM2X9Tqt2jhLtzsarGNvw/");

    await seedControllerContract.buyCloverField();
    await seedControllerContract.buyCloverField();
    await seedControllerContract.buyCloverField();
    
    const nfts = await seedNFTContract.getCSNFTsByOwner(owner.address);
    const num = await seedNFTContract.balanceOf(owner.address);
    const fieldMinted = await seedControllerContract.totalCloverFieldMinted();

    await seedStakeContract.enableStaking();
    await seedStakeContract.stake(nfts);
    let stakedTokens = await seedStakeContract.totalDepositedTokens(owner.address);
    let stakedFieldCarbonTokens = await seedStakeContract.depositedCloverFieldCarbon(owner.address);
    let remainTokens = await seedNFTContract.getCSNFTsByOwner(owner.address);
    
    console.log("my nfts", nfts.length);
    console.log("field minted:", fieldMinted);
    console.log("owner.address", owner.address);
    console.log("nft count", num);

    console.log("stakedTokens", stakedTokens);
    console.log("stakedFieldCarbonTokens", stakedFieldCarbonTokens);
    console.log("remainTokens", remainTokens);
    await seedStakeContract.enableClaimFunction();
    await seedStakeContract.claimDivs();

    await seedStakeContract.unstake(nfts);
    stakedTokens = await seedStakeContract.totalDepositedTokens(owner.address);
    stakedFieldCarbonTokens = await seedStakeContract.depositedCloverFieldCarbon(owner.address);
    await seedStakeContract.water();
    remainTokens = await seedNFTContract.getCSNFTsByOwner(owner.address);
    console.log("stakedTokens", stakedTokens);
    console.log("stakedFieldCarbonTokens", stakedFieldCarbonTokens);
    console.log("remainTokens", remainTokens);
  });
});