--------------------------------------------------------
--  DDL for Package AR_AUTOREM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AUTOREM_API" AUTHID CURRENT_USER AS
/* $Header: ARATREMS.pls 120.1.12010000.4 2009/05/01 04:12:33 naneja ship $ */

/*========================================================================+
 | PUBLIC PROCEDURE GET_PARAMETERS                                        |
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
      /* Changes for Parallelization */
      p_worker_number                   IN NUMBER DEFAULT 0,
      p_total_workers                   IN NUMBER DEFAULT 0
      );
/*========================================================================+
 |  PROCEDURE submit_autorem_parallel                                     |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 | Wraper to parallelize the Automatic Remittances creation program       |
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
 | 30-NOV-2007             aghoraka           Created                     |
 *=========================================================================*/
PROCEDURE submit_autorem_parallel(
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
			p_total_workers                   IN NUMBER default 1 );

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
      p_batch_date                       IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_batch_gl_date                    IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_approve_flag                     IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_format_flag                      IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_currency_code                    IN  ar_batches.currency_code%TYPE,
      p_remmitance_method                IN  ar_batches.remit_method_code%TYPE,
      p_receipt_class_id                    IN  ar_receipt_classes.receipt_class_id%TYPE,
      p_payment_method_id                   IN  ar_receipt_methods.receipt_method_id%TYPE,
      p_remmitance_bank_branch_id           IN  ap_bank_accounts.bank_branch_id%TYPE DEFAULT NULL,
      p_remmitance_bank_account_id               IN  ar_receipt_method_accounts.REMIT_BANK_ACCT_USE_ID%TYPE DEFAULT NULL,
      p_batch_id                         OUT NOCOPY  NUMBER
      );

/*========================================================================+
 |  PROCEDURE create_and_update_remit_rec                                 |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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



PROCEDURE create_and_update_remit_rec(
          p_batch_id       IN  NUMBER,
          p_return_status              OUT NOCOPY  VARCHAR2
                              );
/*========================================================================+
 |  PROCEDURE create_and_update_remit_rec_pa                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
 |   This procedure is called when the request is submitted through       |
 |   'Automatic Remittances Master program'.                              |
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
 | 28-MAY-2008              AGHORAKA           Created                    |
 *=========================================================================*/



PROCEDURE create_and_update_remit_rec_pa(
          p_batch_id       IN  NUMBER,
          p_return_status              OUT NOCOPY  VARCHAR2
                              );
/*========================================================================+
 |  PROCEDURE select_and_update_rec                                       |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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

PROCEDURE select_update_rec(
                                p_customer_number_l             IN hz_cust_accounts.account_number%TYPE,
                                p_customer_number_h             IN hz_cust_accounts.account_number%TYPE,
                                p_customer_name_l               IN hz_parties.party_name%type,
                                p_customer_name_h               IN hz_parties.party_name%type,
                                p_doc_num_l                     IN ar_cash_receipts.doc_sequence_value%type,
                                p_doc_num_h                     IN ar_cash_receipts.doc_sequence_value%type,
                                p_trx_date_l                    IN ar_payment_schedules.trx_date%TYPE,
                                p_trx_date_h                    IN ar_payment_schedules.trx_date%TYPE,
                                p_due_date_l                    IN ar_payment_schedules.due_date%TYPE,
                                p_due_date_h                    IN ar_payment_schedules.due_date%TYPE,
                                p_trx_num_l                     IN ar_payment_schedules.trx_number%TYPE,
                                p_trx_num_h                     IN ar_payment_schedules.trx_number%TYPE,
                                p_remittance_total_to           IN ar_cash_receipts.amount%TYPE,
                                p_remittance_total_from         IN ar_cash_receipts.amount%TYPE,
                                p_batch_id                      IN ar_batches.batch_id%TYPE,
                                p_receipt_method_id             IN ar_receipt_methods.receipt_method_id%TYPE,
                                p_currency_code                 IN ar_cash_receipts.currency_code%TYPE,
                                p_payment_type_code             IN ar_receipt_methods.payment_type_code%TYPE,
                                p_sob_id                        IN ar_cash_receipts.set_of_books_id%TYPE,
                                p_remit_method_code             IN ar_receipt_classes.remit_method_code%TYPE,
                                p_remit_bank_account_id         IN ar_cash_receipts.remittance_bank_account_id%TYPE,
                                p_return_status                 OUT NOCOPY  VARCHAR2
                                 );


/*========================================================================+
 |  PROCEDURE process_pay_receipt                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
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

PROCEDURE process_pay_receipt(
                p_batch_id            IN  NUMBER,
                p_called_from         IN  VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2
                );
/*========================================================================+
 |  PROCEDURE process_pay_receipt_parallel                                         |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to select receipts to be remitted             |
 |   update and insert records into the necessary tables.                 |
 |   This procedure is called when the request is submitted through       |
 |   'Automatic Remittances Master program'.                              |
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
 | 28-MAY-2008              AGHORAKA           Created                    |
 *=========================================================================*/

PROCEDURE process_pay_receipt_parallel(
                p_batch_id            IN  NUMBER,
                p_called_from         IN  VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2
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


PROCEDURE rec_reset ( p_request_id  NUMBER
                        );







END AR_AUTOREM_API;

/
