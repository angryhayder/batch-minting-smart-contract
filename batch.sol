// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RavenSHollow is ERC721, Pausable, Ownable, ERC721Burnable {

    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string baseURI;
    string public baseExtension = ".json";

    uint256 public cost = # ether;
    uint256 public costFirst500 = # ether;

    uint256 public maxSupply = #;
    uint256 public maxMintAmount = #;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    constructor(string memory _initBaseURI) ERC721("#", "#") {
        setBaseURI(_initBaseURI);
        _tokenIdCounter.increment();
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function safeMint(address to, uint256 numberOfTokens) public payable {
        uint256 current = _tokenIdCounter.current();

        if (msg.sender != owner()) {
        ///@consensys SWC-115
        require(balanceOf(to) + numberOfTokens  <= maxMintAmount, "Number of NFTS are greater than max");
        if(current < 600 ) {
          require(msg.value >= costFirst500 * numberOfTokens , "Not enough ETH sent");
        } else {
          require(msg.value >= cost * numberOfTokens , "Not enough ETH sent");
        }
        }
        
          for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            if(tokenId < maxSupply) {
                _safeMint(to, tokenId);
                tokenURI(tokenId);
                _tokenIdCounter.increment();
            }
        }
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function getCounter() public view returns(uint256){
        return _tokenIdCounter.current();
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }
    
    function withdraw() public onlyOwner {
            address _owner = owner();
            uint256 amount = address(this).balance;
            (bool sent, ) = _owner.call{value: amount}("");
            require(sent, "Failed to send Ether");
    }

}
