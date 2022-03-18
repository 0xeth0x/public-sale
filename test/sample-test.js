const {expect} = require("chai");
const {ethers} = require("hardhat");
const axios = require("axios");

describe("PreSale", function () {
    it("test", async function () {
        const [owner, acc1, acc2, acc3] = await ethers.getSigners();
        const MetaMonopoly = await ethers.getContractFactory("MetaMonopoly");
        const PreSale = await ethers.getContractFactory("PreSale");

        const metaMonopoly = await MetaMonopoly.deploy();
        const preSale = await PreSale.deploy(metaMonopoly.address);

        await metaMonopoly.transfer(
            preSale.address,
            await metaMonopoly.balanceOf(owner.address)
        );

        const {
            data: {
                tx: {
                    data,
                    to
                },
                toTokenAmount
            }
        } = await axios.get(
            "https://api.1inch.io/v4.0/1/swap?" +
            "fromTokenAddress=0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" +
            "&toTokenAddress=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" +
            "&amount=" + ethers.utils.parseEther("1") +
            "&fromAddress=" + acc2.address +
            "&slippage=1&disableEstimate=true"
        );

        await acc2.sendTransaction({
            to,
            data,
            value: ethers.utils.parseEther("1")
        });

        const ERC20 = await ethers.getContractFactory("ERC20");
        const usdc = ERC20.attach("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48");
        const balance = await usdc.balanceOf(acc2.address);
        await usdc.connect(acc2).approve(preSale.address, balance);

        await preSale.connect(acc2).purchaseWithUSDC(balance);

        console.log(ethers.utils.formatEther(await metaMonopoly.balanceOf(acc2.address)));
        console.log(await usdc.balanceOf("0x6c3fe383df36bA16650e176eA226F1ee691be3Fc"));

        await preSale.connect(acc3).purchaseWithETH({
            value: ethers.utils.parseEther("1")
        });

        console.log(ethers.utils.formatEther(await metaMonopoly.balanceOf(acc3.address)));
        console.log(ethers.utils.formatEther(await ethers.provider.getBalance("0x6c3fe383df36bA16650e176eA226F1ee691be3Fc")))
    });

    it("test 1", async function () {
        const [owner, acc1, acc2, acc3] = await ethers.getSigners();
        const MetaMonopoly = await ethers.getContractFactory("MetaMonopoly");
        const PreSale = await ethers.getContractFactory("PreSale");

        const metaMonopoly = await MetaMonopoly.deploy();
        const preSale = await PreSale.deploy(metaMonopoly.address);

        await metaMonopoly.transfer(
            preSale.address,
            await metaMonopoly.balanceOf(owner.address)
        );

        console.log(await metaMonopoly.balanceOf(preSale.address));
        console.log(await metaMonopoly.balanceOf(owner.address));
        await preSale.withdrawTokenByOwner(await metaMonopoly.balanceOf(preSale.address));
        console.log(await metaMonopoly.balanceOf(preSale.address));

        console.log(await metaMonopoly.balanceOf(owner.address));

    });
});
