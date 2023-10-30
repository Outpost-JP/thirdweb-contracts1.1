// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC1155Base.sol";
import "@thirdweb-dev/contracts/extension/Permissions.sol";

contract comap is Permissions, ERC1155Base {
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");
    mapping (address => bool) private _allowedTransferAddresses;

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
        _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    }

    function allowTransferAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _allowedTransferAddresses[addr] = true;
    }

    function disallowTransferAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _allowedTransferAddresses[addr] = false;
    }

    function isAllowedTransferAddress(address addr) public view returns (bool) {
        return _allowedTransferAddresses[addr];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(isAllowedTransferAddress(operator), "Only allowed addresses can be approved");
        super.setApprovalForAll(operator, approved);
    }
}
