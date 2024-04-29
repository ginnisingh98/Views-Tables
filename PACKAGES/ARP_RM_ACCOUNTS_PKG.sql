--------------------------------------------------------
--  DDL for Package ARP_RM_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RM_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARSIRMAS.pls 120.4 2003/11/04 20:43:51 orashid ship $*/

--
-- Public procedures/functions
--
PROCEDURE fetch_p(
	p_receipt_method_id IN ar_receipt_method_accounts.receipt_method_id%TYPE,
        p_bank_account_id IN ar_receipt_method_accounts.remit_bank_acct_use_id%TYPE,
        p_rma_rec OUT NOCOPY ar_receipt_method_accounts%ROWTYPE );

END ARP_RM_ACCOUNTS_PKG;

 

/
