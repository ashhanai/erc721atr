# ERC721ATR
POC of a custom ERC721 token implementation that enables a token owner to tokenize assets transfer rights (ATR). The holder of the ATR token has exclusive rights to transfer the NFT. Not owner nor approved addresses can transfer the NFT if an ATR token is minted. There is no need for calling an additional transfer function. Just by owning the ATR token, an address gains transfer rights. ATR token has the same id as the underlying NFT. Can be minted by an NFT owner and burned by an ATR token owner. ATR contract has a deterministic address and is deployed on an NFT contract deployment with a `CREATE2` opcode and `bytes32(uint256(keccak256("AssetTransferRightsToken")) - 1)` salt.

## Use cases
- safety: keep NFTs in a hot wallet to conveniently access utility, but store ATR tokens in a multisig/cold wallet
- lending: use ATR token as collateral backing a loan (instead of locking the NFT in a protocol Vault)
- renting: rent an NFT without the need for a wrapper or additional collateral (by using an ATR token as the collateral)
