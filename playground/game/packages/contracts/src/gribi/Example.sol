// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { BaseThread } from "@gribi/src/BaseThread.sol";
import { Operation, Transaction, PublicInput } from "@gribi/src/Structs.sol";
import { Forest } from "@gribi/src/Forest.sol";

contract Example is BaseThread {
    function getModuleID() public virtual override returns (uint256) {
        return uint256(keccak256(abi.encodePacked("example-module")));
    }

    function createCommitment(Transaction memory transaction) external {
        if (transaction.operations.length > 0) {
            forest.addCommitment(transaction.operations[0].value);
        }
    }

    function revealCommitment(Transaction memory transaction) external {
        require(transaction.inputs.length > 2, "malformed transaction");
        uint256 commitment = transaction.inputs[0].value;
        uint256 salt = transaction.inputs[1].value;
        uint256 secret = transaction.inputs[2].value;

        require(forest.commitmentExists(commitment), "This value was not properly committed to earlier!");
        uint256 hash = uint256(keccak256(abi.encodePacked([salt, secret])));
        require(hash == commitment, "The revealed commitment is incorrect");

        forest.setReturnValue(0, secret);
    }

    //These are mostly for testing, you'd want to be more careful about what could be read or written through the module contract
    function writePublicInput(PublicInput memory input) external {
        forest.setPublicState(input);
    }

    function getPublicInput(uint256 slot) external view returns (PublicInput memory) {
        return forest.getPublicState(slot);
    }
}
