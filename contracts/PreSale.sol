//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract PreSale is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint256 public price = 10000;
    address payable public immutable receiver;
    AggregatorV3Interface public immutable ethToUsdPriceFeed;
    IERC20 public immutable usdc;

    constructor(IERC20 _token) {
        token = _token;
        receiver = payable(0x6c3fe383df36bA16650e176eA226F1ee691be3Fc);
        ethToUsdPriceFeed =
            AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

    receive() external payable {
        purchaseWithETH();
    }

    function purchaseWithETH()
        public
        payable
    {
        uint256 amount = msg.value;
        require(
            amount != 0,
            "PreSale::purchaseWithETH: invalid ether amount"
        );

        uint256 tokenAmount = amount
            * getLatestETHPrice()
            / price
            / 10 ** 2;

        token.safeTransfer(msg.sender, tokenAmount);
        receiver.transfer(address(this).balance);
    }

    function purchaseWithUSDC(uint256 amount) external {
        require(
            amount != 0,
            "PreSale::purchaseWithUSDC: invalid usdc amount"
        );

        uint256 tokenAmount = amount
            * 10 ** 18
            / price;

        token.safeTransfer(msg.sender, tokenAmount);

        usdc.safeTransferFrom(
            msg.sender,
            receiver,
            amount
        );
    }

    function withdrawTokenByOwner(uint256 amount)
        external
        onlyOwner
    {
        token.safeTransfer(msg.sender, amount);
    }

    function changePrice(uint256 newPrice)
        external
        onlyOwner
    {
        price = newPrice;
    }

    function getLatestETHPrice() public view returns (uint) {
        (
            uint80 roundID,
            int ethPrice,
            ,
            ,
            uint80 answeredInRound
        ) = ethToUsdPriceFeed.latestRoundData();

        require(
            answeredInRound >= roundID,
            "Crypto::getLatestETHPrice: ETH/USD price is not fresh"
        );

        require(
            ethPrice > 0,
            "Crypto::getLatestETHPrice: invalid ETH price"
        );
        return uint256(ethPrice);
    }
}