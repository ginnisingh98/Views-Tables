--------------------------------------------------------
--  DDL for Package ARP_PROCESS_BOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_BOE" AUTHID CURRENT_USER AS
/* $Header: ARREBOES.pls 120.2 2003/10/24 19:44:35 orashid ship $ */
-----------------------  Data types  -----------------------------


------------------ Public functions/procedures -------------------


PROCEDURE add_or_rm_remit_rec_to_batch (
        p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_crh_id      IN ar_cash_receipt_history.cash_receipt_history_id%TYPE,
        p_selected_remittance_batch_id   IN
                   ar_cash_receipts.selected_remittance_batch_id%TYPE,
        p_remittance_bank_account_id IN
                   ar_cash_receipts.remit_bank_acct_use_id%type,
        p_override_remit_account_flag IN
                   ar_cash_receipts.override_remit_account_flag%TYPE,
        p_customer_bank_account_id IN
                   ar_cash_receipts.customer_bank_account_id%TYPE,
        p_bank_charges IN
                   ar_cash_receipt_history.factor_discount_amount%TYPE,
        p_maturity_date IN
                   ar_payment_schedules.due_date%TYPE,
        p_batch_id		IN NUMBER,
        p_control_count		IN NUMBER,
	p_control_amount	IN NUMBER,
        p_module_name           IN VARCHAR2,
        p_module_version        IN VARCHAR2 );

PROCEDURE create_remit_batch_conc_req( p_create_flag IN VARCHAR2,
              p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_due_date_low IN ar_payment_schedules.due_date%TYPE,
              p_due_date_high IN ar_payment_schedules.due_date%TYPE,
              p_receipt_date_low IN ar_cash_receipts.receipt_date%TYPE,
              p_receipt_date_high IN ar_cash_receipts.receipt_date%TYPE,
              p_receipt_number_low IN ar_cash_receipts.receipt_number%TYPE,
              p_receipt_number_high IN ar_cash_receipts.receipt_number%TYPE,
              p_document_number_low IN NUMBER,
              p_document_number_high IN NUMBER,
              p_customer_number_low IN hz_cust_accounts.account_number%TYPE,
              p_customer_number_high IN hz_cust_accounts.account_number%TYPE,
              p_customer_name_low IN hz_parties.party_name%TYPE,
              p_customer_name_high IN hz_parties.party_name%TYPE,
              p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
              p_location_low IN hz_cust_site_uses.location%TYPE,
              p_location_high IN hz_cust_site_uses.location%TYPE,
              p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
              p_remit_total_low IN NUMBER,
              p_remit_total_high IN NUMBER,
              p_request_id  OUT NOCOPY NUMBER,
              p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 );

PROCEDURE app_fmt_auto_batch_conc_req( p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
              p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 );
--
PROCEDURE app_fmt_remit_batch_conc_req( p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
              p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2 );
--
PROCEDURE create_auto_batch_conc_req( p_create_flag IN VARCHAR2,
              p_approve_flag IN VARCHAR2,
              p_format_flag IN VARCHAR2,
              p_batch_id IN ar_batches.batch_id%TYPE,
              p_due_date_low IN ar_payment_schedules.due_date%TYPE,
              p_due_date_high IN ar_payment_schedules.due_date%TYPE,
              p_trx_date_low IN ra_customer_trx.trx_date%TYPE,
              p_trx_date_high IN ra_customer_trx.trx_date%TYPE,
              p_trx_number_low IN ra_customer_trx.trx_number%TYPE,
              p_trx_number_high IN ra_customer_trx.trx_number%TYPE,
              p_document_number_low IN NUMBER,
              p_document_number_high IN NUMBER,
              p_customer_number_low IN hz_cust_accounts.account_number%TYPE,
              p_customer_number_high IN hz_cust_accounts.account_number%TYPE,
              p_customer_name_low IN hz_parties.party_name%TYPE,
              p_customer_name_high IN hz_parties.party_name%TYPE,
              p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
              p_location_low IN hz_cust_site_uses.location%TYPE,
              p_location_high IN hz_cust_site_uses.location%TYPE,
              p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
              p_billing_number_low IN ar_cons_inv.cons_billing_number%TYPE,
              p_billing_number_high IN ar_cons_inv.cons_billing_number%TYPE,
              p_request_id  OUT NOCOPY NUMBER,
              p_batch_applied_status OUT NOCOPY VARCHAR2,
              p_module_name IN VARCHAR2,
              p_module_version IN VARCHAR2,
	      p_bank_account_low IN VARCHAR2,
	      p_bank_account_high IN VARCHAR2 );

PROCEDURE add_or_rm_txn_from_auto_batch(
        p_ct_id       IN ra_customer_trx.customer_trx_id%TYPE,
        p_ps_id       IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_selected_for_rec_batch_id   IN
                   ar_payment_schedules.selected_for_receipt_batch_id%TYPE,
        p_paying_customer_id IN ra_customer_trx.paying_customer_id%TYPE,
        p_customer_bank_account_id IN
                   ra_customer_trx.customer_bank_account_id%TYPE,
        p_module_name           IN VARCHAR2,
        p_module_version        IN VARCHAR2 );

----------------- Private functions/procedures ------------------


END ARP_PROCESS_BOE;

 

/
