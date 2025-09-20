// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "forge-std/Test.sol";

// Reference contract
import {Purchase} from "./Purchase.sol";

// Generated contracts from LLMs
import {PurchaseGemini} from "./PurchaseGemini.sol";
import {PurchaseClaude} from "./PurchaseClaude.sol";
import {PurchaseDeepSeek} from "./PurchaseDeepSeek.sol";
import {PurchaseChatGPT} from "./PurchaseChatGPT.sol";

contract PurchaseTest is Test {
    address payable seller = payable(address(0xABCD));
    address payable buyer = payable(address(0xBEEF));

    uint256 constant DEPLOY_VALUE = 4 ether;

    // ========== INITIALIZATION TESTS ==========

    function test_Reference_Initialization() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.startPrank(seller);
        Purchase p = new Purchase{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(p.value() == 2 ether);
        assertTrue(p.seller() == seller);
        assertTrue(uint256(p.state()) == 0); // Created state
    }

    function test_Gemini_Initialization() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.startPrank(seller);
        PurchaseGemini p = new PurchaseGemini{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(p.value() == 2 ether);
        assertTrue(p.seller() == seller);
        assertTrue(uint256(p.state()) == 0); // Created state
    }

    function test_Claude_Initialization() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.startPrank(seller);
        PurchaseClaude p = new PurchaseClaude{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(p.value() == 2 ether);
        assertTrue(p.seller() == seller);
        assertTrue(uint256(p.state()) == 0); // Created state
    }

    function test_DeepSeek_Initialization() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.startPrank(seller);
        PurchaseDeepSeek p = new PurchaseDeepSeek{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(p.value() == 2 ether);
        assertTrue(p.seller() == seller);
        assertTrue(uint256(p.state()) == 0); // Created state
    }

    function test_ChatGPT_Initialization() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.startPrank(seller);
        PurchaseChatGPT p = new PurchaseChatGPT{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(p.value() == 2 ether);
        assertTrue(p.seller() == seller);
        assertTrue(uint256(p.state()) == 0); // Created state
    }

    // ========== CONFIRM PURCHASE TESTS ==========

    function test_Reference_ConfirmPurchase() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        Purchase p = new Purchase{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 1); // Locked state
        assertTrue(p.buyer() == buyer);
    }

    function test_Gemini_ConfirmPurchase() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, 2 ether); // Gemini needs only 1x value
        
        vm.startPrank(seller);
        PurchaseGemini p = new PurchaseGemini{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: 2 ether}(); // Gemini takes 1x value
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 1); // Locked state
        assertTrue(p.buyer() == buyer);
    }

    function test_Claude_ConfirmPurchase() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseClaude p = new PurchaseClaude{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 1); // Locked state
        assertTrue(p.buyer() == buyer);
    }

    function test_DeepSeek_ConfirmPurchase() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseDeepSeek p = new PurchaseDeepSeek{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 1); // Locked state
        assertTrue(p.buyer() == buyer);
    }

    function test_ChatGPT_ConfirmPurchase() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseChatGPT p = new PurchaseChatGPT{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 1); // Locked state
        assertTrue(p.buyer() == buyer);
    }

    // ========== CONFIRM RECEIVED TESTS ==========

    function test_Reference_ConfirmReceived() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        Purchase p = new Purchase{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 2); // Release state
    }

    function test_Gemini_ConfirmReceived() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, 2 ether);
        
        vm.startPrank(seller);
        PurchaseGemini p = new PurchaseGemini{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: 2 ether}();
        p.confirmReceived();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 2); // Release state
    }

    function test_Claude_ConfirmReceived() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseClaude p = new PurchaseClaude{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 2); // Release state
    }

    function test_DeepSeek_ConfirmReceived() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseDeepSeek p = new PurchaseDeepSeek{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 2); // Release state
    }

    function test_ChatGPT_ConfirmReceived() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseChatGPT p = new PurchaseChatGPT{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 2); // Release state
    }

    // ========== REFUND SELLER TESTS ==========

    function test_Reference_RefundSeller() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        Purchase p = new Purchase{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();

        vm.startPrank(seller);
        p.refundSeller();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 3); // Inactive state
    }

    function test_Gemini_RefundSeller() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, 2 ether);
        
        vm.startPrank(seller);
        PurchaseGemini p = new PurchaseGemini{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: 2 ether}();
        p.confirmReceived();
        vm.stopPrank();

        vm.startPrank(seller);
        p.refundSeller();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 3); // Inactive state
    }

    function test_Claude_RefundSeller() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseClaude p = new PurchaseClaude{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();

        vm.startPrank(seller);
        p.refundSeller();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 3); // Inactive state
    }

    function test_DeepSeek_RefundSeller() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseDeepSeek p = new PurchaseDeepSeek{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();

        vm.startPrank(seller);
        p.refundSeller();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 3); // Inactive state
    }

    function test_ChatGPT_RefundSeller() public {
        vm.deal(seller, DEPLOY_VALUE);
        vm.deal(buyer, DEPLOY_VALUE);
        
        vm.startPrank(seller);
        PurchaseChatGPT p = new PurchaseChatGPT{value: DEPLOY_VALUE}();
        vm.stopPrank();

        vm.startPrank(buyer);
        p.confirmPurchase{value: DEPLOY_VALUE}();
        p.confirmReceived();
        vm.stopPrank();

        vm.startPrank(seller);
        p.refundSeller();
        vm.stopPrank();
        
        assertTrue(uint256(p.state()) == 3); // Inactive state
    }
}
