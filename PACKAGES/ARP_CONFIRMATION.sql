--------------------------------------------------------
--  DDL for Package ARP_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CONFIRMATION" AUTHID CURRENT_USER AS
/* $Header: ARRECNFS.pls 120.3 2005/07/26 15:26:36 naneja ship $ */

-----------------------  Data types  -----------------------------

TYPE MaxDatesType IS RECORD
    (	max_trx_date		DATE,
	max_gl_date		DATE,
	cnf_date		DATE,
	cnf_gl_date		DATE,
	max_ra_apply_date	DATE,
	max_ra_gl_date		DATE);

TYPE id_arr IS TABLE OF NUMBER(15);
TYPE num_arr IS TABLE OF NUMBER;
TYPE var_arr1 IS TABLE OF VARCHAR2(1);
TYPE var_arr20 IS TABLE OF VARCHAR2(20);
TYPE var_arr30 IS TABLE OF VARCHAR2(30);
TYPE var_arr150 IS TABLE OF VARCHAR2(150);
TYPE var_arr240 IS TABLE OF VARCHAR2(240);
TYPE date_arr IS TABLE OF  DATE;

TYPE new_con_data IS RECORD
    ( l_old_rec_app_id                   id_arr,
      l_new_rec_app_id                   id_arr,
      l_acctd_amount_applied_from        num_arr,
      l_amount_applied                   num_arr,
      l_application_rule                 var_arr30,
      l_application_type                 var_arr20,
      l_apply_date                       date_arr,
      l_code_combination_id              id_arr,
      l_created_by                       id_arr,
      l_creation_date                    date_arr,
      l_display                          var_arr1,
      l_gl_date                          date_arr,
      l_last_updated_by                  id_arr,
      l_last_update_date                 date_arr,
      l_payment_schedule_id              id_arr,
      l_set_of_books_id                  id_arr,
      l_status                           var_arr30,
      l_acctd_amount_applied_to          num_arr,
      l_acctd_earned_discount_tkn        num_arr,
      l_acctd_unearned_discount_tkn      num_arr,
      l_applied_customer_trx_id          id_arr,
      l_applied_customer_trx_line_id     id_arr,
      l_applied_payment_schedule_id      id_arr,
      l_cash_receipt_id                  id_arr,
      l_comments                         var_arr240,
      l_confirmed_flag                   var_arr1,
      l_customer_trx_id                  id_arr,
      l_days_late                        num_arr,
      l_earned_discount_taken            num_arr,
      l_freight_applied                  num_arr,
      l_gl_posted_date                   date_arr,
      l_last_update_login                num_arr,
      l_line_applied                     num_arr,
      l_on_account_customer              num_arr,
      l_postable                         var_arr1,
      l_posting_control_id               id_arr,
      l_cash_receipt_history_id          id_arr,
      l_program_application_id           id_arr,
      l_program_id                       id_arr,
      l_program_update_date              date_arr,
      l_receivables_charges_applied      num_arr,
      l_receivables_trx_id               id_arr,
      l_request_id                       id_arr,
      l_tax_applied                      num_arr,
      l_unearned_discount_taken          num_arr,
      l_unearned_discount_ccid           id_arr,
      l_earned_discount_ccid             id_arr,
      l_ussgl_transaction_code           var_arr30,
      l_attribute_category               var_arr30,
      l_attribute1                       var_arr150,
      l_attribute2                       var_arr150,
      l_attribute3                       var_arr150,
      l_attribute4                       var_arr150,
      l_attribute5                       var_arr150,
      l_attribute6                       var_arr150,
      l_attribute7                       var_arr150,
      l_attribute8                       var_arr150,
      l_attribute9                       var_arr150,
      l_attribute10                      var_arr150,
      l_attribute11                      var_arr150,
      l_attribute12                      var_arr150,
      l_attribute13                      var_arr150,
      l_attribute14                      var_arr150,
      l_attribute15                      var_arr150,
      l_ussgl_transaction_code_cntxt     var_arr30,
      l_reversal_gl_date                 date_arr,
      l_org_id                           id_arr
     );
------------------ Public functions/procedures -------------------

PROCEDURE confirm(
	p_cr_id 		IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_module_name		IN VARCHAR2,
	p_module_version	IN VARCHAR2 );

PROCEDURE unconfirm(
	p_cr_id 		IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_module_name		IN VARCHAR2,
	p_module_version	IN VARCHAR2 );

/* Bug fix 872506 */
PROCEDURE confirm_batch(
        p_batch_id              IN NUMBER,
        p_confirm_gl_date       IN DATE,
        p_confirm_date          IN DATE,
        p_num_rec_confirmed     OUT NOCOPY NUMBER,
        p_num_rec_error         OUT NOCOPY NUMBER);

PROCEDURE confirm_receipt(
        p_cr_id                 IN NUMBER,
        p_confirm_gl_date       IN DATE,
        p_confirm_date          IN DATE);
/* End bug fix 872506 */
----------------- Private functions/procedures ------------------

PROCEDURE do_confirm(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date		IN  DATE,
	p_confirm_date			IN  DATE,
	p_acctd_amount			IN  NUMBER);

PROCEDURE do_unconfirm(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date		IN  DATE,
	p_confirm_date			IN  DATE,
	p_acctd_amount			IN  NUMBER,
	p_batch_id
		IN ar_payment_schedules.selected_for_receipt_batch_id%TYPE);

PROCEDURE update_cr_history_confirm(
	p_cr_rec		IN ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_acctd_amount		IN NUMBER,
	p_receipt_clearing_ccid IN
		ar_receipt_method_accounts.receipt_clearing_ccid%TYPE);

PROCEDURE update_cr_history_unconfirm(
	p_cr_rec		IN ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_acctd_amount		IN NUMBER,
	p_batch_id	       OUT NOCOPY ar_cash_receipt_history.batch_id%TYPE,
	p_crh_id_rev	       OUT NOCOPY
			ar_cash_receipt_history.cash_receipt_history_id%TYPE
			);

PROCEDURE confirm_update_ps_rec(
		p_cr_rec		ar_cash_receipts%ROWTYPE,
		p_closed_date		DATE,
		p_closed_gl_date	DATE);

PROCEDURE modify_update_ra_rec(
	p_cr_id			 IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount_applied	 IN NUMBER,
	p_acctd_amount_applied   IN NUMBER,
	p_confirm_gl_date	 IN DATE,
	p_confirm_date	         IN DATE);

PROCEDURE create_matching_unapp_records(
	p_cr_id		IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_app_id        IN ar_receivable_applications.receivable_application_id%TYPE);

PROCEDURE get_receipt_clearing_ccid(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_receipt_clearing_ccid		OUT NOCOPY
		ar_receipt_method_accounts.receipt_clearing_ccid%TYPE);

PROCEDURE reverse_application_to_ps(
	p_ra_id			IN
		ar_receivable_applications.receivable_application_id%TYPE,
	p_confirm_gl_date	IN	DATE,
	p_confirm_date		IN 	DATE,
	p_batch_id		IN
		ar_payment_schedules.selected_for_receipt_batch_id%TYPE
			);

PROCEDURE reverse_ra_recs(
	p_cr_rec		IN	ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN 	DATE,
	p_confirm_date		IN 	DATE
			);

PROCEDURE unconfirm_update_ps_rec(
		p_cr_rec		ar_cash_receipts%ROWTYPE,
		p_closed_date		DATE,
		p_closed_gl_date	DATE
			);

PROCEDURE validate_in_parameters(
		p_cr_id		    IN 	ar_cash_receipts.cash_receipt_id%TYPE,
		p_confirm_gl_date   IN	DATE,
		p_confirm_date	    IN  DATE,
		p_module_name	    IN  VARCHAR2);

PROCEDURE get_application_flags(
	p_cust_trx_type_id  IN  ra_cust_trx_types.cust_trx_type_id%TYPE,
	p_ao_flag    OUT NOCOPY ra_cust_trx_types.allow_overapplication_flag%TYPE,
	p_nao_flag   OUT NOCOPY ra_cust_trx_types.natural_application_only_flag%TYPE,
        p_creation_sign OUT NOCOPY ra_cust_trx_types.creation_sign%TYPE);

PROCEDURE handle_max_dates(
	p_max_dates		IN OUT NOCOPY MaxDatesType,
	p_gl_date		IN DATE,
	p_apply_date		IN DATE,
	p_confirm_date		IN DATE,
	p_confirm_gl_date	IN DATE	);

END ARP_CONFIRMATION;
 

/
