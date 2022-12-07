// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../src/ERC721ATR.sol";


abstract contract ERC721ATRTest is Test {

    ERC721ATR token;

    uint256 tokenId = 42;
    address owner = makeAddr("owner");
    address receiver = makeAddr("receiver");
    address approved = makeAddr("approved");

    function setUp() virtual public {
        token = new ERC721ATR();

        // Mock token owner
        vm.store(
            address(token),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(owner)))
        );

        // Mock owner balance
        vm.store(
            address(token),
            keccak256(abi.encode(owner, uint256(3))),
            bytes32(uint256(1))
        );
    }


    function _checkTokenOwner(address _expectedOwner) internal {
        bytes32 expectedOwner = vm.load(
            address(token),
            keccak256(abi.encode(tokenId, uint256(2)))
        );
        assertEq(expectedOwner, bytes32(uint256(uint160(_expectedOwner))));
    }

}

contract ERC721ATR_MintTransferRights_Test is ERC721ATRTest {

    function test_shouldFail_whenCallerIsNotTokenOwner() external {
        vm.expectRevert("Caller is not token owner");
        token.mintTransferRights(tokenId);
    }

    function test_shouldMintATRToken() external {
        vm.expectCall(
            address(token.atr()),
            abi.encodeWithSignature("mint(address,uint256)", owner, tokenId)
        );

        vm.prank(owner);
        token.mintTransferRights(tokenId);
    }

}

contract ERC721ATR_BurnTransferRights_Test is ERC721ATRTest {

    function setUp() override public {
        super.setUp();

        // Mock token owner
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(owner)))
        );

        // Mock owner balance
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(owner, uint256(3))),
            bytes32(uint256(1))
        );
    }


    function test_shouldFail_whenCallerIsNotATRTokenOwner() external {
        vm.expectCall(
            address(token.atr()),
            abi.encodeWithSignature("ownerOf(uint256)")
        );

        vm.expectRevert("Caller is not token owner");
        token.burnTransferRights(tokenId);
    }

    function test_shouldBurnATRToken() external {
        vm.expectCall(
            address(token.atr()),
            abi.encodeWithSignature("burn(uint256)", tokenId)
        );

        vm.prank(owner);
        token.burnTransferRights(tokenId);
    }

}

contract ERC721ATR_HasTransferRights_Test is ERC721ATRTest {

    function setUp() override public {
        super.setUp();

        // Mock token owner
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(owner)))
        );
    }


    function test_shouldReturnTrue_whenAddressOwnsATRToken() external {
        bool hasTransferRights = token.hasTransferRights(owner, tokenId);

        assertTrue(hasTransferRights);
    }

    function test_shouldReturnFalse_whenAddressDoesNotOwnATRToken() external {
        bool hasTransferRights = token.hasTransferRights(address(2), tokenId);

        assertFalse(hasTransferRights);
    }

}

contract ERC721ATR_TransferFrom_ATRNotMinted_Test is ERC721ATRTest {

    function test_shouldTransfer_whenCallerIsOwner_whenATRNotMinted() external {
        vm.prank(owner);
        token.transferFrom(owner, receiver, tokenId);

        _checkTokenOwner(receiver);
    }

    function test_shouldTransfer_whenCallerIsOperator_whenATRNotMinted() external {
        vm.prank(owner);
        token.setApprovalForAll(approved, true);

        vm.prank(approved);
        token.transferFrom(owner, receiver, tokenId);

        _checkTokenOwner(receiver);
    }

    function test_shouldTransfer_whenCallerIsApproved_whenATRNotMinted() external {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.prank(approved);
        token.transferFrom(owner, receiver, tokenId);

        _checkTokenOwner(receiver);
    }

}

contract ERC721ATR_TransferFrom_ATRMinted_Test is ERC721ATRTest {

    address atrTokenOwner = makeAddr("atrTokenOwner");

    function setUp() override public {
        super.setUp();

        // Mock token owner
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(atrTokenOwner)))
        );

        // Mock owner balance
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(atrTokenOwner, uint256(3))),
            bytes32(uint256(1))
        );
    }


    function test_shouldTransfer_whenCallerIsATRTokenOwner_whenATRIsMinted() external {
        vm.prank(atrTokenOwner);
        token.transferFrom(owner, receiver, tokenId);

        _checkTokenOwner(receiver);
    }

    function test_shouldFail_whenCallerIsOwner_whenATRIsMinted() external {
        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(owner);
        token.transferFrom(owner, receiver, tokenId);
    }

    function test_shouldFail_whenCallerIsOperator_whenATRIsMinted() external {
        vm.prank(owner);
        token.setApprovalForAll(approved, true);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(approved);
        token.transferFrom(owner, receiver, tokenId);
    }

    function test_shouldFail_whenCallerIsApproved_whenATRIsMinted() external {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(approved);
        token.transferFrom(owner, receiver, tokenId);
    }

}

contract ERC721ATR_SafeTransferFrom_ATRNotMinted_Test is ERC721ATRTest {

    function test_shouldTransfer_whenCallerIsOwner_whenATRNotMinted() external {
        vm.prank(owner);
        token.safeTransferFrom(owner, receiver, tokenId, "");

        _checkTokenOwner(receiver);
    }

    function test_shouldTransfer_whenCallerIsOperator_whenATRNotMinted() external {
        vm.prank(owner);
        token.setApprovalForAll(approved, true);

        vm.prank(approved);
        token.safeTransferFrom(owner, receiver, tokenId, "");

        _checkTokenOwner(receiver);
    }

    function test_shouldTransfer_whenCallerIsApproved_whenATRNotMinted() external {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.prank(approved);
        token.safeTransferFrom(owner, receiver, tokenId, "");

        _checkTokenOwner(receiver);
    }

}

contract ERC721ATR_SafeTransferFrom_ATRMinted_Test is ERC721ATRTest {

    address atrTokenOwner = makeAddr("atrTokenOwner");

    function setUp() override public {
        super.setUp();

        // Mock token owner
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(tokenId, uint256(2))),
            bytes32(uint256(uint160(atrTokenOwner)))
        );

        // Mock owner balance
        vm.store(
            address(token.atr()),
            keccak256(abi.encode(atrTokenOwner, uint256(3))),
            bytes32(uint256(1))
        );
    }


    function test_shouldTransfer_whenCallerIsATRTokenOwner_whenATRIsMinted() external {
        vm.prank(atrTokenOwner);
        token.safeTransferFrom(owner, receiver, tokenId, "");

        _checkTokenOwner(receiver);
    }

    function test_shouldFail_whenCallerIsOwner_whenATRIsMinted() external {
        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(owner);
        token.safeTransferFrom(owner, receiver, tokenId, "");
    }

    function test_shouldFail_whenCallerIsOperator_whenATRIsMinted() external {
        vm.prank(owner);
        token.setApprovalForAll(approved, true);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(approved);
        token.safeTransferFrom(owner, receiver, tokenId, "");
    }

    function test_shouldFail_whenCallerIsApproved_whenATRIsMinted() external {
        vm.prank(owner);
        token.approve(approved, tokenId);

        vm.expectRevert("ERC721: caller is not token owner or approved");
        vm.prank(approved);
        token.safeTransferFrom(owner, receiver, tokenId, "");
    }

}
