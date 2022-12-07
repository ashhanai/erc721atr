// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../src/ATRToken.sol";


abstract contract ATRTokenTest is Test {

    ATRToken atrToken;
    address mainContract = makeAddr("mainContract");

    uint256 tokenId = 42;
    address owner = address(1);

    function setUp() virtual public {
        vm.prank(mainContract);
        atrToken = new ATRToken();
    }

}

contract ATRToken_Mint_Test is ATRTokenTest {

    function test_shouldFail_whenCallerIsNotMainContract() external {
        vm.expectRevert("Caller is not the main contract");
        atrToken.mint(owner, tokenId);
    }

    function test_shouldMintATRToken() external {
        vm.prank(mainContract);
        atrToken.mint(owner, tokenId);

        // Check owner
        bytes32 expectedOwner = vm.load(
            address(atrToken),
            keccak256(abi.encode(tokenId, uint256(2)))
        );
        assertEq(expectedOwner, bytes32(uint256(uint160(owner))));

        // Check balance
        bytes32 expectedBalance = vm.load(
            address(atrToken),
            keccak256(abi.encode(owner, uint256(3)))
        );
        assertEq(expectedBalance, bytes32(uint256(1)));
    }

}

contract ATRToken_Burn_Test is ATRTokenTest {

    function setUp() override public {
        super.setUp();

        // Mock token owner
        vm.store(
            address(atrToken),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(owner)))
        );

        // Mock owner balance
        vm.store(
            address(atrToken),
            keccak256(abi.encode(owner, uint256(3))),
            bytes32(uint256(1))
        );
    }


    function test_shouldFail_whenCallerIsNotMainContract() external {
        vm.expectRevert("Caller is not the main contract");
        atrToken.burn(tokenId);
    }

    function test_shouldBurnATRToken() external {
        vm.prank(mainContract);
        atrToken.burn(tokenId);

        // Check owner
        bytes32 expectedOwner = vm.load(
            address(atrToken),
            keccak256(abi.encode(tokenId, uint256(2)))
        );
        assertEq(expectedOwner, bytes32(0));

        // Check balance
        bytes32 expectedBalance = vm.load(
            address(atrToken),
            keccak256(abi.encode(owner, uint256(3)))
        );
        assertEq(expectedBalance, bytes32(0));
    }

}

contract ATRToken_Exists_Test is ATRTokenTest {

    function test_shouldReturnFalse_whenTokenDoesNotExist() external {
        bool exists = atrToken.exists(tokenId);

        assertFalse(exists);
    }

    function test_shouldReturnTrue_whenTokenExists() external {
        // Mock token owner
        vm.store(
            address(atrToken),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(owner)))
        );

        bool exists = atrToken.exists(tokenId);

        assertTrue(exists);
    }

}
