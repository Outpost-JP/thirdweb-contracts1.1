// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC1155Base.sol";
import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract comap is Permissions, ERC1155Base {
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");  // WHITELISTED_ROLEを定義

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    )
        ERC1155Base(
            _defaultAdmin,
            _name,
            _symbol,
            _royaltyRecipient,
            _royaltyBps
        )
    {
        // ホワイトリストのロールを設定
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin); // Permissionsで使用するデフォルトの管理者ロール
    }

    // safeTransferFromをオーバーライド
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
        require(isEOAorWhitelisted(_msgSender()), "Only EOA or whitelisted addresses allowed");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    // safeBatchTransferFromをオーバーライド
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
        require(isEOAorWhitelisted(_msgSender()), "Only EOA or whitelisted addresses allowed");
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    // アドレスがEOAまたはホワイトリストに登録されているか確認
    function isEOAorWhitelisted(address account) internal view returns (bool) {
        return (tx.origin == account || hasRole(WHITELISTED_ROLE, account));
    }

    // アドレスをホワイトリストに追加
    function addToWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(WHITELISTED_ROLE, account);
    }

    // アドレスをホワイトリストから削除
    function removeFromWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(WHITELISTED_ROLE, account);
    }
}
