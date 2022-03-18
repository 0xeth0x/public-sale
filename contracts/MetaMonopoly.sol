//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.9;

import {
    ERC20Votes,
    ERC20Permit,
    ERC20
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

/**
 * @dev An ERC20 contract having 18 decimals and total fixed supply of
 * 1 Billion tokens.
 */
contract MetaMonopoly is ERC20Votes {

    // CAP of total supply.
    uint256 public immutable CAP;



    /// Initialises contract's state and mints 1 Billion tokens.
    constructor()
        ERC20Permit("Meta Monopoly")
        ERC20("Meta Monopoly", "MONOPOLY")
    {
        CAP = 1_000_000_000 * (10 ** decimals());

        _mint(msg.sender, CAP);

        assert(totalSupply() == CAP);
    }
}