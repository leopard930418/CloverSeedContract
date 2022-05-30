pragma solidity 0.8.12;

// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./IContract.sol";
import "./SafeMath.sol";
import "./Strings.sol";

contract Clover_Seeds_Picker is Ownable {
    using SafeMath for uint256;

    uint16 public totalCloverFieldCarbon = 330; // 33% for total Clover Field
    uint16 public totalCloverFieldPearl = 330; // 33% for total Clover Field
    uint16 public totalCloverFieldRuby = 330; // 33% for total Clover Field
    uint16 public totalCloverFieldDiamond = 10; // 1% for total Clover Field

    uint16 public totalCloverYardCarbon = 3300; // 33% for total Clover Yard
    uint16 public totalCloverYardPearl = 3300; // 33% for total Clover Yard
    uint16 public totalCloverYardRuby = 3300; // 33% for total Clover Yard
    uint16 public totalCloverYardDiamond = 100; // 1% for total Clover Yard

    uint16 public totalCloverPotCarbon = 33000; // 33% for total Clover Pot
    uint16 public totalCloverPotPearl = 33000; // 33% for total Clover Pot
    uint16 public totalCloverPotRuby = 33000; // 33% for total Clover Pot
    uint16 public totalCloverPotDiamond = 1000; // 1% for total Clover Pot

    uint16 public totalCloverFieldCarbonMinted;
    uint16 public totalCloverFieldPearlMinted;
    uint16 public totalCloverFieldRubyMinted;
    uint16 public totalCloverFieldDiamondMinted;

    uint16 public totalCloverYardCarbonMinted;
    uint16 public totalCloverYardPearlMinted;
    uint16 public totalCloverYardRubyMinted;
    uint16 public totalCloverYardDiamondMinted;

    uint24 public totalCloverPotCarbonMinted;
    uint24 public totalCloverPotPearlMinted;
    uint24 public totalCloverPotRubyMinted;
    uint24 public totalCloverPotDiamondMinted;

    address public Clover_Seeds_Controller;
    address public Clover_Seeds_NFT_Token;

    string private _baseURIFieldCarbon;
    string private _baseURIFieldPearl;
    string private _baseURIFieldRuby;
    string private _baseURIFieldDiamond;
    string private _baseURIYardCarbon;
    string private _baseURIYardPearl;
    string private _baseURIYardRuby;
    string private _baseURIYardDiamond;
    string private _baseURIPotCarbon;
    string private _baseURIPotPearl;
    string private _baseURIPotRuby;
    string private _baseURIPotDiamond;

    constructor(address _Seeds_NFT_Token, address _Clover_Seeds_Controller) {
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
        Clover_Seeds_NFT_Token = _Seeds_NFT_Token;
    }

    function setBaseURIFieldCarbon(string calldata _uri) public onlyOwner {
        _baseURIFieldCarbon = _uri;
    }
    function setBaseURIFieldPearl(string calldata _uri) public onlyOwner {
        _baseURIFieldPearl = _uri;
    }
    function setBaseURIFieldRuby(string calldata _uri) public onlyOwner {
        _baseURIFieldRuby = _uri;
    }
    function setBaseURIFieldDiamond(string calldata _uri) public onlyOwner {
        _baseURIFieldDiamond = _uri;
    }
    function setBaseURIYardCarbon(string calldata _uri) public onlyOwner {
        _baseURIYardCarbon = _uri;
    }
    function setBaseURIYardPearl(string calldata _uri) public onlyOwner {
        _baseURIYardPearl = _uri;
    }
    function setBaseURIYardRuby(string calldata _uri) public onlyOwner {
        _baseURIYardRuby = _uri;
    }
    function setBaseURIYardDiamond(string calldata _uri) public onlyOwner {
        _baseURIYardDiamond = _uri;
    }
    function setBaseURIPotCarbon(string calldata _uri) public onlyOwner {
        _baseURIPotCarbon = _uri;
    }
    function setBaseURIPotPearl(string calldata _uri) public onlyOwner {
        _baseURIPotPearl = _uri;
    }
     function setBaseURIPotRuby(string calldata _uri) public onlyOwner {
        _baseURIPotRuby = _uri;
    }
     function setBaseURIPotDiamond(string calldata _uri) public onlyOwner {
        _baseURIPotDiamond = _uri;
    }


    function randomNumber(uint256 seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            block.difficulty,
            blockhash(block.number - 1), 
            block.timestamp, 
            seed
            )));
    }

    function random(uint seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(tx.origin, blockhash(block.number), block.timestamp, seed)));
    }

    function setSeeds_NFT_Token(address _Seeds_NFT_Token) public onlyOwner {
        Clover_Seeds_NFT_Token = _Seeds_NFT_Token;
    }

    function setClover_Seeds_Controller(address _Clover_Seeds_Controller) public onlyOwner {
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
    }

    function randomLayer(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_NFT_Token, "Clover_Seeds_Picker: You are not Clover_Seeds_NFT_Token..");
        
        uint256 index = random(tokenId);
        uint8 num = uint8(index % 100);
        if (tokenId <= 1e3) {
            if (totalCloverFieldDiamondMinted == totalCloverFieldDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverFieldCarbonMinted == totalCloverFieldCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverFieldPearlMinted == totalCloverFieldPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverFieldRubyMinted == totalCloverFieldRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverFieldDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIFieldDiamond, Strings.toString(totalCloverFieldDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverFieldCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIFieldCarbon, Strings.toString(totalCloverFieldCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverFieldPearlMinted++;
                uri = string(abi.encodePacked(_baseURIFieldPearl, Strings.toString(totalCloverFieldPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverFieldRubyMinted++;
                uri = string(abi.encodePacked(_baseURIFieldRuby, Strings.toString(totalCloverFieldRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldRuby..");
            }
            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);

        } else if (tokenId <= 11e3) {
            if (totalCloverYardDiamondMinted == totalCloverYardDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverYardCarbonMinted == totalCloverYardCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverYardPearlMinted == totalCloverYardPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverYardRubyMinted == totalCloverYardRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverYardDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIYardDiamond, Strings.toString(totalCloverYardDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverYardCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIYardCarbon, Strings.toString(totalCloverYardCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverYardPearlMinted++;
                uri = string(abi.encodePacked(_baseURIYardPearl, Strings.toString(totalCloverYardPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverYardRubyMinted++;
                uri = string(abi.encodePacked(_baseURIYardRuby, Strings.toString(totalCloverYardRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardRuby..");
            }

            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);

        } else {
            if (totalCloverPotDiamondMinted == totalCloverPotDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverPotCarbonMinted == totalCloverPotCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverPotPearlMinted == totalCloverPotPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverPotRubyMinted == totalCloverPotRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverPotDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIPotDiamond, Strings.toString(totalCloverPotDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverPotCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIPotCarbon, Strings.toString(totalCloverPotCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverPotPearlMinted++;
                uri = string(abi.encodePacked(_baseURIPotPearl, Strings.toString(totalCloverPotPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverPotRubyMinted++;
                uri = string(abi.encodePacked(_baseURIPotRuby, Strings.toString(totalCloverPotRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotRuby..");
            }
            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);
        }
        return true;
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Picker: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Picker: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}