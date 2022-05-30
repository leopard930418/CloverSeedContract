pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./EnumerableSet.sol";
import "./IterableMapping.sol";

contract Clover_Seeds_Stake is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using IterableMapping for IterableMapping.Map;

    uint256 public CloverFieldCarbonRewardRate = 15e19;
    uint256 public CloverFieldPearlRewardRate = 22e19;
    uint256 public CloverFieldRubyRewardRate = 6e20;
    uint256 public CloverFieldDiamondRewardRate = 15e20;

    uint256 public CloverYardCarbonRewardRate = 1e19;
    uint256 public CloverYardPearlRewardRate = 15e18;
    uint256 public CloverYardRubyRewardRate = 3e19;
    uint256 public CloverYardDiamondRewardRate = 6e19;

    uint256 public CloverPotCarbonRewardRate = 8e17;
    uint256 public CloverPotPearlRewardRate = 1e18;
    uint256 public CloverPotRubyRewardRate = 12e17;
    uint256 public CloverPotDiamondRewardRate = 3e18;

    uint256 public rewardInterval = 1 days;
    uint256 public marketingFee = 1000;
    uint256 public totalClaimedRewards;
    uint256 public marketingFeeTotal;
    uint256 public waterInterval = 2 days;

    address public Seeds_Token;
    address public Seeds_NFT_Token;
    address public Clover_Seeds_Controller;
    address public Clover_Seeds_Picker;

    address public marketingWallet;
    
    bool public isStakingEnabled = false;
    bool public isMarketingFeeActiveted = false;
    bool public canClaimReward = false;

    EnumerableSet.AddressSet private CloverDiamondFieldAddresses;
    EnumerableSet.AddressSet private CloverDiamondYardAddresses;
    EnumerableSet.AddressSet private CloverDiamondPotAddresses;
    EnumerableSet.AddressSet private holders;

    mapping (address => uint256) public depositedCloverFieldCarbon;
    mapping (address => uint256) public depositedCloverFieldPearl;
    mapping (address => uint256) public depositedCloverFieldRuby;
    mapping (address => uint256) public depositedCloverFieldDiamond;

    mapping (address => uint256) public depositedCloverYardCarbon;
    mapping (address => uint256) public depositedCloverYardPearl;
    mapping (address => uint256) public depositedCloverYardRuby;
    mapping (address => uint256) public depositedCloverYardDiamond;

    mapping (address => uint256) public depositedCloverPotCarbon;
    mapping (address => uint256) public depositedCloverPotPearl;
    mapping (address => uint256) public depositedCloverPotRuby;
    mapping (address => uint256) public depositedCloverPotDiamond;

    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public totalDepositedTokens;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public lastWatered;
    mapping (address => uint256) public wastedTime;

    IterableMapping.Map private _owners;
    // mapping(uint256 => address) private _owners;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _marketingWallet, address _Seeds_Token, address _Seeds_NFT_Token, address _Clover_Seeds_Controller, address _Clover_Seeds_Picker) {
        Clover_Seeds_Picker = _Clover_Seeds_Picker;
        Seeds_Token = _Seeds_Token;
        Seeds_NFT_Token = _Seeds_NFT_Token;
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
        marketingWallet = _marketingWallet;

        CloverDiamondFieldAddresses.add(address(0));
        CloverDiamondYardAddresses.add(address(0));
        CloverDiamondPotAddresses.add(address(0));
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners.get(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function randomNumberForCloverField() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverField() public view returns (address) {
        require (msg.sender == Clover_Seeds_Controller, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverField() % CloverDiamondFieldAddresses.length();
        return CloverDiamondFieldAddresses.at(luckyWallet);
    }

    function randomNumberForCloverYard() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverYard() public view returns (address) {
        require (msg.sender == Clover_Seeds_Controller, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverYard() % CloverDiamondYardAddresses.length();
        return CloverDiamondYardAddresses.at(luckyWallet);
    }

    function randomNumberForCloverPot() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverPot() public view returns (address) {
        require (msg.sender == Clover_Seeds_Controller, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverPot() % CloverDiamondPotAddresses.length();
        return CloverDiamondPotAddresses.at(luckyWallet);
    }

    function updateAccount(address account) private {
        uint256 _lastWatered = block.timestamp.sub(lastWatered[account]);
        uint256 pendingDivs = getPendingDivs(account);
        uint256 _marketignFee = pendingDivs.mul(marketingFee).div(1e4);
        uint256 afterFee = pendingDivs.sub(_marketignFee);

        require(_lastWatered <= waterInterval, "Please give water your plant..");
        
        if (pendingDivs > 0 && !isMarketingFeeActiveted) {
            require(IContract(Seeds_Token).sendToken2Account(account, pendingDivs), "Can't transfer tokens!");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }

        if (pendingDivs > 0 && isMarketingFeeActiveted) {
            require(IContract(Seeds_Token).sendToken2Account(account, afterFee), "Can't transfer tokens!");
            require(IContract(Seeds_Token).sendToken2Account(marketingWallet, marketingFee), "Can't transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(afterFee);
            totalClaimedRewards = totalClaimedRewards.add(afterFee);
            emit RewardsTransferred(account, afterFee);
        }

        lastClaimedTime[account] = block.timestamp;
        wastedTime[account] = 0;
    }
    
    function getPendingDivs(address _holder) public view returns (uint256) {
        
        uint256 pendingDivs = getPendingDivsField(_holder)
        .add(getPendingDivsYard(_holder))
        .add(getPendingDivsPot(_holder));
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    function claimDivs() public {
        require(canClaimReward, "Please waite to enable this function..");
        updateAccount(msg.sender);
    }

    function updateRewardInterval(uint256 _sec) public onlyOwner {
        rewardInterval = _sec;
    }

    function updateCloverField_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverFieldCarbonRewardRate = _carbon;
        CloverFieldPearlRewardRate = _pearl;
        CloverFieldRubyRewardRate = _ruby;
        CloverFieldDiamondRewardRate = _diamond;
    }

    function updateCloverYard_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverYardCarbonRewardRate = _carbon;
        CloverYardPearlRewardRate = _pearl;
        CloverYardRubyRewardRate = _ruby;
        CloverYardDiamondRewardRate = _diamond;
    }

    function updateCloverPot_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverPotCarbonRewardRate = _carbon;
        CloverPotPearlRewardRate = _pearl;
        CloverPotRubyRewardRate = _ruby;
        CloverPotDiamondRewardRate = _diamond;
    }

    function getTimeDiff(address _holder) internal view returns (uint256) {
        require(holders.contains(_holder), "You are not a holder!");
        require(totalDepositedTokens[_holder] > 0, "You have no tokens!");
        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        if (timeDiff > waterInterval) {
            timeDiff = waterInterval;
        }
        return timeDiff;
    }

    function getCloverFieldCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldCarbon = depositedCloverFieldCarbon[_holder];
        uint256 CloverFieldCarbonReward = cloverFieldCarbon.mul(CloverFieldCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldCarbonReward;
    }

    function getCloverFieldPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldPearl = depositedCloverFieldPearl[_holder];
        uint256 CloverFieldPearlReward = cloverFieldPearl.mul(CloverFieldPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldPearlReward;
    }

    function getCloverFieldRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldRuby = depositedCloverFieldRuby[_holder];
        uint256 CloverFieldRubyReward = cloverFieldRuby.mul(CloverFieldRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldRubyReward;
    }

    function getCloverFieldDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldDiamond = depositedCloverFieldDiamond[_holder];
        uint256 CloverFieldDiamondReward = cloverFieldDiamond.mul(CloverFieldDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldDiamondReward;
    }

    function getCloverYardCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardCarbon = depositedCloverYardCarbon[_holder];
        uint256 CloverYardCarbonReward = cloverYardCarbon.mul(CloverYardCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardCarbonReward;
    }

    function getCloverYardPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardPearl = depositedCloverYardPearl[_holder];
        uint256 CloverYardPearlReward = cloverYardPearl.mul(CloverYardPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardPearlReward;
    }

    function getCloverYardRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardRuby = depositedCloverYardRuby[_holder];
        uint256 CloverYardRubyReward = cloverYardRuby.mul(CloverYardRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardRubyReward;
    }

    function getCloverYardDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardDiamond = depositedCloverYardDiamond[_holder];
        uint256 CloverYardDiamondReward = cloverYardDiamond.mul(CloverYardDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardDiamondReward;
    }

    function getCloverPotCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotCarbon = depositedCloverPotCarbon[_holder];
        uint256 CloverPotCarbonReward = cloverPotCarbon.mul(CloverPotCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotCarbonReward;
    }

    function getCloverPotPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotPearl = depositedCloverPotPearl[_holder];
        uint256 CloverPotPearlReward = cloverPotPearl.mul(CloverPotPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotPearlReward;
    }

    function getCloverPotRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotRuby = depositedCloverPotRuby[_holder];
        uint256 CloverPotRubyReward = cloverPotRuby.mul(CloverPotRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotRubyReward;
    }

    function getCloverPotDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotDiamond = depositedCloverPotDiamond[_holder];
        uint256 CloverPotDiamondReward = cloverPotDiamond.mul(CloverPotDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotDiamondReward;
    }
    
    function getPendingDivsField(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverFieldCarbonReward(_holder)
        .add(getCloverFieldPearlReward(_holder))
        .add(getCloverFieldRubyReward(_holder))
        .add(getCloverFieldDiamondReward(_holder));
            
        return pendingDivs;
    }
    
    function getPendingDivsYard(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverYardCarbonReward(_holder)
        .add(getCloverYardPearlReward(_holder))
        .add(getCloverYardRubyReward(_holder))
        .add(getCloverYardDiamondReward(_holder));
            
        return pendingDivs;
    }
    
    function getPendingDivsPot(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverPotCarbonReward(_holder)
        .add(getCloverPotPearlReward(_holder))
        .add(getCloverPotRubyReward(_holder))
        .add(getCloverPotDiamondReward(_holder));
            
        return pendingDivs;
    }

    function stake(uint256[] memory tokenId) public {
        require(isStakingEnabled, "Staking is not activeted yet..");

        uint256 pendingDivs = getPendingDivs(msg.sender);

        if (pendingDivs > 0) {
            updateAccount(msg.sender);
        }

        if (pendingDivs == 0) {
            lastClaimedTime[msg.sender] = block.timestamp;
            lastWatered[msg.sender] = block.timestamp;
        }

        for (uint256 i = 0; i < tokenId.length; i++) {

            IContract(Seeds_NFT_Token).setApprovalForAll_(address(this));
            IContract(Seeds_NFT_Token).safeTransferFrom(msg.sender, address(this), tokenId[i]);

            if (tokenId[i] <= 1e3) {
                if (IContract(Clover_Seeds_Controller).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender]++;
                    if (!CloverDiamondFieldAddresses.contains(msg.sender)) {
                        CloverDiamondFieldAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(Clover_Seeds_Controller).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender]++;
                    if (!CloverDiamondYardAddresses.contains(msg.sender)) {
                        CloverDiamondYardAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(Clover_Seeds_Controller).isCloverPotCarbon_(tokenId[i])) {
                    depositedCloverPotCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender]++;
                    if (!CloverDiamondPotAddresses.contains(msg.sender)) {
                        CloverDiamondPotAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 0) {
                _owners.set(tokenId[i], msg.sender);
            }

            totalDepositedTokens[msg.sender]++;
        }

        if (!holders.contains(msg.sender) && totalDepositedTokens[msg.sender] > 0) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
        }
    }
    
    function unstake(uint256[] memory tokenId) public {
        require(totalDepositedTokens[msg.sender] > 0, "Stake: You don't have staked token..");
        updateAccount(msg.sender);

        for (uint256 i = 0; i < tokenId.length; i++) {
            require(_owners.get(tokenId[i]) == msg.sender, "Stake: Please enter correct tokenId..");
            
            if (tokenId[i] > 0) {
                IContract(Seeds_NFT_Token).safeTransferFrom(address(this), msg.sender, tokenId[i]);
            }
            totalDepositedTokens[msg.sender] --;

            if (tokenId[i] <= 1e3) {
                if (IContract(Clover_Seeds_Controller).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender] --;
                    if (depositedCloverFieldDiamond[msg.sender] == 0) {
                        CloverDiamondFieldAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(Clover_Seeds_Controller).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender] --;
                    if (depositedCloverYardDiamond[msg.sender] == 0) {
                        CloverDiamondYardAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(Clover_Seeds_Controller).isCloverPotCarbon_(tokenId[i])) {
                    depositedCloverPotCarbon[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender] --;
                    if (depositedCloverPotDiamond[msg.sender] == 0) {
                        CloverDiamondPotAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 0) {
                _owners.remove(tokenId[i]);
            }
        }
        
        if (holders.contains(msg.sender) && totalDepositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function water() public {
        uint256 _lastWatered = block.timestamp.sub(lastWatered[msg.sender]);
        
        if (_lastWatered > waterInterval) {
            uint256 time = _lastWatered.sub(waterInterval);
            wastedTime[msg.sender] = wastedTime[msg.sender].add(time);
        }

        lastWatered[msg.sender] = block.timestamp;
    }

    function updateWaterInterval(uint256 sec) public onlyOwner {
        waterInterval = sec;
    }
    
    function enableStaking() public onlyOwner {
        isStakingEnabled = true;
    }

    function disableStaking() public onlyOwner {
        isStakingEnabled = false;
    }

    function enableClaimFunction() public onlyOwner {
        canClaimReward = true;
    }

    function disableClaimFunction() public onlyOwner {
        canClaimReward = false;
    }

    function enableMarketingFee() public onlyOwner {
        isMarketingFeeActiveted = true;
    }

    function disableMarketingFee() public onlyOwner {
        isMarketingFeeActiveted = false;
    }

    function setClover_Seeds_Picker(address _Clover_Seeds_Picker) public onlyOwner {
        Clover_Seeds_Picker = _Clover_Seeds_Picker;
    }

    function set_Seed_Controller(address _wallet) public onlyOwner {
        Clover_Seeds_Controller = _wallet;
    }

    function set_Seeds_Token(address SeedsToken) public onlyOwner {
        Seeds_Token = SeedsToken;
    }

    function set_Seeds_NFT_Token(address nftToken) public onlyOwner {
        Seeds_NFT_Token = nftToken;
    }

       // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Stake: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Stake: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }

    function stakedTokensByOwner(address account) public view returns (uint[] memory) {
        uint[] memory tokenIds = new uint[](totalDepositedTokens[account]);
        uint counter = 0;
        for (uint i = 0; i < _owners.size(); i++) {
            uint tokenId = _owners.getKeyAtIndex(i);
            if (_owners.get(tokenId) == account) {
                tokenIds[counter] = tokenId;
                counter++;
            }
        }
        return tokenIds;
    }

    function totalStakedCloverFieldsByOwner(address account) public view returns (uint) {
        return depositedCloverFieldCarbon[account] 
        + depositedCloverFieldDiamond[account]
        + depositedCloverFieldPearl[account]
        + depositedCloverFieldRuby[account]; 
    }

    function totalStakedCloverYardsByOwner(address account) public view returns (uint) {
        return depositedCloverYardCarbon[account] 
        + depositedCloverYardDiamond[account]
        + depositedCloverYardPearl[account]
        + depositedCloverYardRuby[account]; 
    }

    function totalStakedCloverPotsByOwner(address account) public view returns (uint) {
        return depositedCloverPotCarbon[account] 
        + depositedCloverPotDiamond[account]
        + depositedCloverPotPearl[account]
        + depositedCloverPotRuby[account]; 
    }

    function totalStakedCloverFields() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverFieldsByOwner(holders.at(i));
        }
        return  counter;
    }

    function totalStakedCloverYards() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverYardsByOwner(holders.at(i));
        }
        return  counter;
    }

    function totalStakedCloverPots() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverPotsByOwner(holders.at(i));
        }
        return  counter;
    }

    function passedTime(address account) public view returns (uint) {
        if (totalDepositedTokens[account] == 0) {
          return 0;  
        } else {
            return block.timestamp - lastWatered[account];
        }
    }

    function readRewardRates() public view returns(
        uint fieldCarbon, uint fieldPearl, uint fieldRuby, uint fieldDiamond,
        uint yardCarbon, uint yardPearl, uint yardRuby, uint yardDiamond,
        uint potCarbon, uint potPearl, uint potRuby, uint potDiamond
    ){
        fieldCarbon = CloverFieldCarbonRewardRate;
        fieldPearl = CloverFieldPearlRewardRate;
        fieldRuby = CloverFieldRubyRewardRate;
        fieldDiamond = CloverFieldDiamondRewardRate;

        yardCarbon = CloverYardCarbonRewardRate;
        yardPearl = CloverYardPearlRewardRate;
        yardRuby = CloverYardRubyRewardRate;
        yardDiamond = CloverYardDiamondRewardRate;

        potCarbon = CloverPotCarbonRewardRate;
        potPearl = CloverPotPearlRewardRate;
        potRuby = CloverPotRubyRewardRate;
        potDiamond = CloverPotDiamondRewardRate;
    }
}