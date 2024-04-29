--------------------------------------------------------
--  DDL for Package AP_PAY_IN_FULL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAY_IN_FULL_PKG" AUTHID CURRENT_USER AS
/* $Header: apayfuls.pls 120.7.12010000.4 2009/01/20 05:02:36 sbonala ship $ */

  --Modified below procedure parameter types for bug #7721348
  PROCEDURE AP_Lock_Invoices(
	   P_invoice_id_list     IN  VARCHAR2,
	   P_payment_num_list	 IN  VARCHAR2,
	   P_currency_code       OUT NOCOPY VARCHAR2,
	   P_payment_method      OUT NOCOPY AP_PAYMENT_SCHEDULES.PAYMENT_METHOD_CODE%TYPE,  --VARCHAR2,
           P_vendor_id           OUT NOCOPY AP_SUPPLIERS.VENDOR_ID%TYPE,              --NUMBER,
           P_vendor_site_id      OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_ID%TYPE,    --NUMBER,
           P_party_id            OUT NOCOPY AP_SUPPLIERS.PARTY_ID%TYPE,               --NUMBER,
           P_party_site_id       OUT NOCOPY AP_SUPPLIER_SITES.PARTY_SITE_ID%TYPE,     --NUMBER,
           P_org_id              OUT NOCOPY NUMBER,
           P_payment_function    OUT NOCOPY AP_INVOICES.PAYMENT_FUNCTION%TYPE,          --VARCHAR2, -- 4965233
           P_proc_trxn_type      OUT NOCOPY AP_INVOICES.PAY_PROC_TRXN_TYPE_CODE%TYPE,   --VARCHAR2, -- 4965233
           P_num_payments        OUT NOCOPY NUMBER,
           P_le_id               OUT NOCOPY NUMBER,   -- 5617689
           --Added below variables for the bug 7662240
	   P_remit_vendor_id        OUT NOCOPY AP_SUPPLIERS.VENDOR_ID%TYPE,            --NUMBER,
           P_remit_vendor_site_id   OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_ID%TYPE,   --NUMBER,
           P_remit_party_id         OUT NOCOPY AP_SUPPLIERS.PARTY_ID%TYPE,              --NUMBER,
           P_remit_party_site_id    OUT NOCOPY AP_SUPPLIER_SITES.PARTY_SITE_ID%TYPE,    --NUMBER,
           P_remit_vendor_name      OUT NOCOPY AP_SUPPLIERS.VENDOR_NAME%TYPE,           --VARCHAR2,
           P_remit_vendor_site_name OUT NOCOPY AP_SUPPLIER_SITES.VENDOR_SITE_CODE%TYPE, --VARCHAR2,
           P_calling_sequence    IN  VARCHAR2,
		     --Added below parameter for 7688200
	    p_relationship_id	OUT NOCOPY NUMBER);

  FUNCTION AP_Discount_Available(P_invoice_id_list   IN  VARCHAR2,
			         P_payment_num_list  IN  VARCHAR2,
			         P_check_date        IN  DATE,
			         P_currency_code     IN  VARCHAR2,
			         P_calling_sequence  IN  VARCHAR2)
    RETURN BOOLEAN;

  FUNCTION AP_Get_Check_Amount(P_invoice_id_list 	IN  VARCHAR2,
			       P_payment_num_list       IN  VARCHAR2,
			       P_payment_type_flag      IN  VARCHAR2,
			       P_check_date             IN  DATE,
			       P_currency_code          IN  VARCHAR2,
			       P_take_discount          IN  VARCHAR2,
			       P_sys_auto_calc_int_flag IN  VARCHAR2,
			       P_auto_calc_int_flag     IN  VARCHAR2,
			       P_calling_sequence       IN  VARCHAR2)
    RETURN NUMBER;

  PROCEDURE AP_Create_Payments(P_invoice_id_list	IN  VARCHAR2,
			       P_payment_num_list	IN  VARCHAR2,
			       P_check_id		IN  NUMBER,
			       P_payment_type_flag	IN  VARCHAR2,
			       P_payment_method		IN  VARCHAR2,
			       P_ce_bank_acct_use_id	IN  NUMBER,
			       P_bank_account_num	IN  VARCHAR2,
			       P_bank_account_type	IN  VARCHAR2,
			       P_bank_num		IN  VARCHAR2,
			       P_check_date             IN  DATE,
			       P_period_name		IN  VARCHAR2,
			       P_currency_code          IN  VARCHAR2,
			       P_base_currency_code	IN  VARCHAR2,
			       P_checkrun_name		IN  VARCHAR2,
			       P_doc_sequence_value	IN  NUMBER,
			       P_doc_sequence_id	IN  NUMBER,
			       P_exchange_rate		IN  NUMBER,
			       P_exchange_rate_type	IN  VARCHAR2,
			       P_exchange_date		IN  DATE,
			       P_take_discount          IN  VARCHAR2,
			       P_sys_auto_calc_int_flag IN  VARCHAR2,
			       P_auto_calc_int_flag     IN  VARCHAR2,
			       P_set_of_books_id	IN  NUMBER,
			       P_future_pay_ccid	IN  NUMBER,
			       P_last_updated_by	IN  NUMBER,
			       P_last_update_login	IN  NUMBER,
			       P_calling_sequence	IN  VARCHAR2,
                               P_sequential_numbering   IN  VARCHAR2 DEFAULT 'N', --1724353
                               P_accounting_event_id    IN  NUMBER, --Events
                               P_org_id                 IN  NUMBER);
END AP_PAY_IN_FULL_PKG;

/
