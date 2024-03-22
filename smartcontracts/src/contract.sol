// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SeasonPassNFT is ERC721, ERC721Enumerable, Ownable {
    using Strins for uint256;
    
    struct SeasonPass {
      address owner;
      bool[4] selectedGames;
    }

    string public _baseTokenURI;
    uint256 public _mintPrice;
    uint256 public _maxSupply;
    uint256 public _maxPerWallet;
    uint256 private _nextTokenId;
    uint256[] private _ticketsPerGame;
    mapping(uint256 => SeasonPass) private _passDetails;

    constructor(string memory name, string memory symbol, address initialOwner) ERC721('LocalHeroPass', "LHp") Ownable(initialOwner) {
        _maxSupply = 1000;
        _mintPrice = 0.015 ether;
        _maxPerWallet = 2;
        _nextTokenId = 1;
        _ticketsPerGame = new uint256[](4); // Assuming 8 games in the season
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function mint(address to, bool[4] memory checkboxes) public payable {
        uint256 tokenId = _nextTokenId;
        uint256 supply = _totalSupply();

        if(msg.sender != owner()){
            require(msg.value == _mintPrice, "Valor errado para a compra do Passe");
            require(supply <= _maxSupply, "Sold out");
        }

        for (uint256 i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i] != true) {
                _ticketsPerGame[i]++;
            }
        }

        _passDetails[tokenId] = SeasonPass(to, checkboxes);
        _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId), "The provided token does not exists");

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId, ".json")): "";
    }

    function getTicketsPerGame() public view returns (uint256[] memory) {
        return _ticketsPerGame;
    }

    function getPassDetails(uint256 tokenId) public view returns (address, bool[4] memory) {
      SeasonPass memory pass = _passDetails[tokenId];
      return (pass.owner, pass.selectedGames);
    }

}