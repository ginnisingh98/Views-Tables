--------------------------------------------------------
--  DDL for Package AR_AUTOREC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AUTOREC_API" AUTHID CURRENT_USER AS
/* $Header: ARATRECS.pls 120.7.12010000.6 2009/04/28 03:28:33 nemani ship $ */

TYPE rcpt_creation_info IS RECORD (
	party_id                 NUMBER,
	pmt_channel_code         VARCHAR2(30),
	assignment_id            NUMBER );


TYPE receipt_info_rec  IS RECORD (
	customer_id                 NUMBER,
        cr_gl_date                  DATE,
        cr_amount                   NUMBER,
	cust_site_use_id            NUMBER,
	receipt_date                DATE,
	cr_currency_code            VARCHAR2(30),
	cr_exchange_rate            NUMBER,
	cr_payment_schedule_id      NUMBER,
	remittance_bank_account_id  NUMBER,
	receipt_method_id           NUMBER,
	cash_receipt_id             NUMBER,
	inv_bal_amount              NUMBER,
	inv_orig_amount             NUMBER,
	allow_over_app              ra_cust_trx_types.allow_overapplication_flag%type,
	unapplied_ccid              NUMBER,
	ed_disc_ccid                NUMBER,
	uned_disc_ccid              NUMBER,
	batch_id                    NUMBER,
	customer_trx_id             NUMBER,
	rev_rec_flag                VARCHAR2(30),
	def_tax_flag                VARCHAR2(30),
	cust_trx_type_id            NUMBER,
	trx_due_date                DATE,
	trx_currency_code           VARCHAR2(30),
	trx_exchange_rate           NUMBER,
	trx_date                    DATE,
	trx_gl_date                 DATE,
	calc_discount_on_lines_flag VARCHAR2(30),
	partial_discount_flag       VARCHAR2(30),
	allow_overappln_flag        VARCHAR2(30),
	natural_appln_only_flag     VARCHAR2(30),
	creation_sign               VARCHAR2(30),
	applied_payment_schedule_id NUMBER,
	ot_gl_date                  DATE,
	term_id                     NUMBER,
	amount_due_original         NUMBER,
	amount_line_items_original  NUMBER,
	amount_due_remaining        NUMBER,
	discount_taken_earned       NUMBER,
	discount_taken_unearned     NUMBER,
	line_items_original         NUMBER,
	line_items_remaining        NUMBER,
	tax_original                NUMBER,
	tax_remaining               NUMBER,
	freight_original            NUMBER,
	freight_remaining           NUMBER,
	rec_charges_charged         NUMBER,
	rec_charges_remaining       NUMBER,
	location                    hz_cust_site_uses.location%type,
	amount_apply		    NUMBER
);


/*========================================================================+
 | PUBLIC PROCEDURE GET_DETAIL_ACCOUNTS                                   |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to get the parameters from the Conc program   |
 |    and convert them to the type reqd for processing.                   |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/



PROCEDURE get_parameters(
      P_ERRBUF                          OUT NOCOPY VARCHAR2,
      P_RETCODE                         OUT NOCOPY NUMBER,
      p_process_type                    IN VARCHAR2,
      p_batch_date                      IN VARCHAR2,
      p_batch_gl_date                   IN VARCHAR2,
      p_create_flag                     IN VARCHAR2,
      p_approve_flag                    IN VARCHAR2,
      p_format_flag                     IN VARCHAR2,
      p_batch_id                        IN VARCHAR2,
      p_debug_mode_on                   IN VARCHAR2,
      p_batch_currency                  IN VARCHAR2,
      p_exchange_date                   IN VARCHAR2,
      p_exchange_rate                   IN VARCHAR2,
      p_exchange_rate_type              IN VARCHAR2,
      p_remit_method_code               IN VARCHAR2,
      p_receipt_class_id                IN VARCHAR2,
      p_payment_method_id               IN VARCHAR2,
      p_media_reference                 IN VARCHAR2,
      p_remit_bank_branch_id            IN VARCHAR2,
      p_remit_bank_account_id           IN VARCHAR2,
      p_remit_bank_deposit_number       IN VARCHAR2,
      p_comments                        IN VARCHAR2,
      p_trx_date_l                      IN VARCHAR2,
      p_trx_date_h                      IN VARCHAR2,
      p_due_date_l                      IN VARCHAR2,
      p_due_date_h                      IN VARCHAR2,
      p_trx_num_l                       IN VARCHAR2,
      p_trx_num_h                       IN VARCHAR2,
      p_doc_num_l                       IN VARCHAR2,
      p_doc_num_h                       IN VARCHAR2,
      p_customer_number_l               IN VARCHAR2,
      p_customer_number_h               IN VARCHAR2,
      p_customer_name_l                 IN VARCHAR2,
      p_customer_name_h                 IN VARCHAR2,
      p_customer_id                     IN VARCHAR2,
      p_site_l                          IN VARCHAR2,
      p_site_h                          IN VARCHAR2,
      p_site_id                         IN VARCHAR2,
      p_remittance_total_from           IN VARCHAR2,
      p_Remittance_total_to             IN VARCHAR2,
      p_billing_number_l                IN VARCHAR2,
      p_billing_number_h                IN VARCHAR2,
      p_customer_bank_acc_num_l         IN VARCHAR2,
      p_customer_bank_acc_num_h         IN VARCHAR2,
      p_current_worker_number           IN VARCHAR2 DEFAULT '0',
      p_total_workers                   IN VARCHAR2 DEFAULT '0'
      );


/*========================================================================+
 |  PROCEDURE submit_autorec_parallel                                     |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | Wraper to parallelize the Automatic Receipts creation program          |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 30-NOV-2007              nproddut          Created                     |
 *=========================================================================*/
PROCEDURE submit_autorec_parallel(
      p_errbuf                          OUT NOCOPY VARCHAR2,
      p_retcode                         OUT NOCOPY NUMBER,
      p_process_type                    IN VARCHAR2,
      p_batch_date                      IN VARCHAR2,
      p_batch_gl_date                   IN VARCHAR2,
      p_create_flag                     IN VARCHAR2,
      p_approve_flag                    IN VARCHAR2,
      p_format_flag                     IN VARCHAR2,
      p_batch_id                        IN VARCHAR2,
      p_debug_mode_on                   IN VARCHAR2,
      p_batch_currency                  IN VARCHAR2,
      p_exchange_date                   IN VARCHAR2,
      p_exchange_rate                   IN VARCHAR2,
      p_exchange_rate_type              IN VARCHAR2,
      p_remit_method_code               IN VARCHAR2,
      p_receipt_class_id                IN VARCHAR2,
      p_payment_method_id               IN VARCHAR2,
      p_media_reference                 IN VARCHAR2,
      p_remit_bank_branch_id            IN VARCHAR2,
      p_remit_bank_account_id           IN VARCHAR2,
      p_remit_bank_deposit_number       IN VARCHAR2,
      p_comments                        IN VARCHAR2,
      p_trx_date_l                      IN VARCHAR2,
      p_trx_date_h                      IN VARCHAR2,
      p_due_date_l                      IN VARCHAR2,
      p_due_date_h                      IN VARCHAR2,
      p_trx_num_l                       IN VARCHAR2,
      p_trx_num_h                       IN VARCHAR2,
      p_doc_num_l                       IN VARCHAR2,
      p_doc_num_h                       IN VARCHAR2,
      p_customer_number_l               IN VARCHAR2,
      p_customer_number_h               IN VARCHAR2,
      p_customer_name_l                 IN VARCHAR2,
      p_customer_name_h                 IN VARCHAR2,
      p_customer_id                     IN VARCHAR2,
      p_site_l                          IN VARCHAR2,
      p_site_h                          IN VARCHAR2,
      p_site_id                         IN VARCHAR2,
      p_remittance_total_from           IN VARCHAR2,
      p_Remittance_total_to             IN VARCHAR2,
      p_billing_number_l                IN VARCHAR2,
      p_billing_number_h                IN VARCHAR2,
      p_customer_bank_acc_num_l         IN VARCHAR2,
      p_customer_bank_acc_num_h         IN VARCHAR2,
      p_total_workers                   IN NUMBER default 1);

/*========================================================================+
 |  PROCEDURE insert_batch                                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to insert the batch record when called from   |
 |   srs. It also gets the other required parameters from sysparm         |
 |   and conc program                                                     |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/


PROCEDURE insert_batch(
      p_gl_date                          IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_batch_date                       IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_receipt_class_id                 IN  ar_receipt_classes.receipt_class_id%TYPE DEFAULT NULL,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE DEFAULT NULL,
      p_currency_code                    IN  ar_cash_receipts.currency_code%TYPE DEFAULT NULL,
      p_approve_flag                     IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_format_flag                      IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_create_flag                      IN  ar_cash_receipts.confirmed_flag%TYPE DEFAULT NULL,
      p_batch_id                         OUT NOCOPY NUMBER
      );



/*========================================================================+
 | PUBLIC PROCEDURE GET_DETAIL_ACCOUNTS                                   |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select the valied invoices and insert them |
 |   into the GT table rec_gt                                             |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/

PROCEDURE select_valid_invoices(
                                p_trx_date_l                      IN ar_payment_schedules.trx_date%TYPE,
                                p_trx_date_h                      IN ar_payment_schedules.trx_date%TYPE,
                                p_due_date_l                      IN ar_payment_schedules.due_date%TYPE,
                                p_due_date_h                     IN ar_payment_schedules.due_date%TYPE,
                                p_trx_num_l                      IN ar_payment_schedules.trx_number%TYPE,
                                p_trx_num_h                      IN ar_payment_schedules.trx_number%TYPE,
                                p_doc_num_l                      IN ra_customer_trx.doc_sequence_value%TYPE,
                                p_doc_num_h                      IN ra_customer_trx.doc_sequence_value%TYPE,
				p_customer_number_l		 IN hz_cust_accounts.account_number%TYPE,  --Bug6734688
				p_customer_number_h		 IN hz_cust_accounts.account_number%TYPE,  --Bug6734688
				p_customer_name_l		 IN hz_parties.party_name%TYPE,  --Bug6734688
				p_customer_name_h		 IN hz_parties.party_name%TYPE,  --Bug6734688
                                p_batch_id                       IN ar_batches.batch_id%TYPE,
			        p_approve_only_flag                  IN VARCHAR2  DEFAULT NULL,--Bug 5344405
                                p_receipt_method_id              IN ar_receipt_methods.receipt_method_id%TYPE,
                                p_total_workers              IN NUMBER DEFAULT 1
                                 );







/*========================================================================+
 |  PROCEDURE insert_exceptions                                           |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to insert the exception record when           |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/
PROCEDURE insert_exceptions(
             p_batch_id               IN  ar_batches.batch_id%TYPE DEFAULT NULL,
             p_request_id             IN  ar_cash_receipts.request_id%TYPE DEFAULT NULL,
             p_cash_receipt_id        IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
             p_payment_schedule_id    IN  ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
             p_paying_customer_id     IN  ar_cash_receipts.pay_from_customer%TYPE DEFAULT NULL,
             p_paying_site_use_id     IN  ar_cash_receipts.customer_site_use_id%TYPE DEFAULT NULL,
             p_due_date               IN  ar_payment_schedules.due_date%TYPE DEFAULT NULL,
             p_cust_min_rec_amount    IN  NUMBER DEFAULT NULL,
             p_bank_min_rec_amount    IN NUMBER DEFAULT NULL,
             p_exception_code         IN VARCHAR2,
             p_additional_message     IN VARCHAR2
             );


/*========================================================================+
 | PUBLIC PROCEDURE SUBMIT_REPORT                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to get the parameters from the Conc program   |
 |    and convert them to the type reqd for processing.                   |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 16-JUL-2005              bichatte           Created                    |
 *=========================================================================*/

PROCEDURE SUBMIT_REPORT (
                          p_batch_id    ar_batches.batch_id%TYPE,
                          p_request_id  ar_cash_receipts.request_id%TYPE
                        );




PROCEDURE rec_reset( p_apply_fail IN  VARCHAR2,
                          p_pay_process_fail IN  VARCHAR2,
			  p_gt_id            IN  NUMBER
                        );


FUNCTION Get_Invoice_Bal_After_Disc(
		p_applied_payment_schedule_id  IN  NUMBER,
		p_apply_date                   IN  DATE ) RETURN NUMBER;



/*========================================================================+
 |  PROCEDURE populate_cached_data                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | This procedure is to access the cached receipt_info_rec                |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 30-NOV-2007              nproddut          Created                     |
 *=========================================================================*/
PROCEDURE populate_cached_data(p_receipt_info_rec OUT NOCOPY receipt_info_rec);


/*========================================================================+
 |  PROCEDURE populate_cached_data                                        |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | This procedure is to access the cached rcpt_creation_info              |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                     Author            Description of Changes      |
 | 30-NOV-2007              nproddut          Created                     |
 *=========================================================================*/
PROCEDURE populate_cached_data(p_rcpt_creation_rec OUT NOCOPY rcpt_creation_info);


END AR_AUTOREC_API;

/
