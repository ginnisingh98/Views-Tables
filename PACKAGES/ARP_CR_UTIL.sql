--------------------------------------------------------
--  DDL for Package ARP_CR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CR_UTIL" AUTHID CURRENT_USER AS
/*$Header: ARRUTILS.pls 120.2 2003/11/04 20:43:35 orashid ship $*/
--
-- Public procedures/functions
--
PROCEDURE get_dist_ccid( P_cr_id    IN ar_cash_receipts.cash_receipt_id%TYPE,
                         P_source_table IN ar_distributions.source_table%TYPE,
                         P_source_type IN ar_distributions.source_type%TYPE,
                         P_rma_rec IN ar_receipt_method_accounts%ROWTYPE,
                         P_ccid  OUT NOCOPY ar_distributions.code_combination_id%TYPE);
--
PROCEDURE get_creation_info( P_receipt_method_id    IN ar_cash_receipts.receipt_method_id%TYPE,
                         P_remit_bank_account_id    IN ar_cash_receipts.remit_bank_acct_use_id%TYPE,
                         P_history_status OUT NOCOPY ar_cash_receipt_history.status%TYPE,
                         P_source_type OUT NOCOPY ar_distributions.source_type%TYPE,
			 P_ccid OUT NOCOPY ar_distributions.code_combination_id%TYPE,
			 P_override_remit_account_flag OUT NOCOPY ar_cash_receipts.override_remit_account_flag%TYPE);
--
PROCEDURE get_batch_id( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
		  	p_batch_id OUT NOCOPY ar_batches.batch_id%TYPE);
--

END ARP_CR_UTIL;

 

/
