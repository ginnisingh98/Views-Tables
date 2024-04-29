--------------------------------------------------------
--  DDL for Package AR_PREPAYMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_PREPAYMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: ARPPAYAS.pls 120.6 2006/06/27 08:37:30 shveeram noship $ */
/*#
* The Prepayments API enables the creation of a receipt in advance of
* the invoicing event. It provides a mechanism for matching a
* prepayment  receipt to a prepaid invoice. The Prepayments API lets
* you model down  payments, deposits, or prepayments as receipts
* created in Oracle Receivables in advance of the invoice creation event.
* @rep:scope public
* @rep:metalink 236938.1 See OracleMetaLink note 236938.1
* @rep:product AR
* @rep:lifecycle active
* @rep:displayname Prepayment
* @rep:category BUSINESS_ENTITY AR_RECEIPT
*/

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

   TYPE installment_rec_type IS RECORD (
       installment_number   NUMBER(15) DEFAULT NULL ,
       installment_amount   NUMBER DEFAULT NULL);

  TYPE installment_tbl IS TABLE of installment_rec_type
  INDEX BY BINARY_INTEGER;

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/
    temp_exception EXCEPTION;


/*========================================================================
 | PUBLIC Procedure create_prepayment
 |
 | DESCRIPTION
 |      Create prepayment receipt and put it on prepayment
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author         Description of Changes
 | 10-SEP-2001           S Nambiar      Created
 | 08-AUG-2003           J Pandey       Bug: 3063445 Moved the logic from
 |                                      AR_PREPAYMENTS to this public API
 | 11-DEC-2003           J Pandey       Bug 3220078 Change the parameter to TRUE
 *=======================================================================*/
 /*#
 * Use this procedure to creates a prepayment receipt.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Prepayment
 */

 PROCEDURE Create_Prepayment(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
 -- Receipt info. parameters
      p_usr_currency_code       IN  VARCHAR2 DEFAULT NULL, --the translated currency code
      p_currency_code      IN  ar_cash_receipts.currency_code%TYPE DEFAULT NULL,
      p_usr_exchange_rate_type  IN  VARCHAR2 DEFAULT NULL,
      p_exchange_rate_type IN  ar_cash_receipts.exchange_rate_type%TYPE DEFAULT NULL,
      p_exchange_rate      IN  ar_cash_receipts.exchange_rate%TYPE DEFAULT NULL,
      p_exchange_rate_date IN  ar_cash_receipts.exchange_date%TYPE DEFAULT NULL,
      p_amount                           IN  ar_cash_receipts.amount%TYPE,
      p_factor_discount_amount           IN  ar_cash_receipts.factor_discount_amount%TYPE DEFAULT NULL,

      -----Multiple prepayments project: receipt number should be IN OUT
      p_receipt_number   IN OUT NOCOPY  ar_cash_receipts.receipt_number%TYPE,

      p_receipt_date     IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_gl_date          IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_maturity_date    IN  DATE DEFAULT NULL,
      p_postmark_date    IN  DATE DEFAULT NULL,
      p_customer_id      IN  ar_cash_receipts.pay_from_customer%TYPE DEFAULT NULL,
      p_customer_name    IN  hz_parties.party_name%TYPE DEFAULT NULL,
      p_customer_number  IN  hz_cust_accounts.account_number%TYPE DEFAULT NULL,
      p_customer_bank_account_id  IN  ar_cash_receipts.customer_bank_account_id%TYPE DEFAULT NULL,
      p_customer_bank_account_num IN  ap_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_customer_bank_account_name   IN  ap_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_location                 IN  hz_cust_site_uses.location%TYPE DEFAULT NULL,
      p_customer_site_use_id     IN  hz_cust_site_uses.site_use_id%TYPE DEFAULT NULL,
      p_customer_receipt_reference       IN  ar_cash_receipts.customer_receipt_reference%TYPE DEFAULT NULL,
      p_override_remit_account_flag      IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_remittance_bank_account_id       IN  ar_cash_receipts.remit_bank_acct_use_id%type DEFAULT NULL,
      p_remittance_bank_account_num      IN  ce_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_remittance_bank_account_name     IN  ce_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_deposit_date                     IN  ar_cash_receipts.deposit_date%TYPE DEFAULT NULL,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE DEFAULT NULL,
      p_receipt_method_name              IN  ar_receipt_methods.name%TYPE DEFAULT NULL,
      p_doc_sequence_value               IN  NUMBER   DEFAULT NULL,
      p_ussgl_transaction_code           IN  ar_cash_receipts.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_anticipated_clearing_date        IN  ar_cash_receipts.anticipated_clearing_date%TYPE DEFAULT NULL,
      p_called_from                      IN VARCHAR2 DEFAULT NULL,
      p_attribute_rec                    IN ar_receipt_api_pub.attribute_rec_type
                                            DEFAULT ar_receipt_api_pub.attribute_rec_const,
       -- ******* Global Flexfield parameters *******
      p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type
                                 DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_receipt_comments      IN VARCHAR2 DEFAULT NULL,
   -- ***  Notes Receivable Additional Information  ***
      p_issuer_name           IN ar_cash_receipts.issuer_name%TYPE DEFAULT NULL,
      p_issue_date            IN ar_cash_receipts.issue_date%TYPE DEFAULT NULL,
      p_issuer_bank_branch_id IN ar_cash_receipts.issuer_bank_branch_id%TYPE DEFAULT NULL,
   -- ** OUT NOCOPY variables for Creating receipt
      p_cr_id                 OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
   -- Receipt application parameters
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_application_ref_type IN VARCHAR2 DEFAULT NULL,
      p_application_ref_id   IN OUT NOCOPY NUMBER ,
      p_application_ref_num  IN OUT NOCOPY VARCHAR2 ,
      p_secondary_application_ref_id IN OUT NOCOPY NUMBER ,
      p_receivable_trx_id       IN ar_receivable_applications.receivables_trx_id%TYPE DEFAULT NULL,
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date           IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      app_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_show_closed_invoices    IN VARCHAR2 DEFAULT 'FALSE',
      p_move_deferred_tax       IN VARCHAR2 DEFAULT 'Y',
      app_attribute_rec         IN ar_receipt_api_pub.attribute_rec_type
                                   DEFAULT ar_receipt_api_pub.attribute_rec_const,
   -- ******* Global Flexfield parameters *******
      app_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type
                                   DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      app_comments              IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
   -- processor such as iPayments
      p_payment_server_order_num IN OUT NOCOPY ar_cash_receipts.payment_server_order_num%TYPE,
      p_approval_code            IN OUT NOCOPY ar_cash_receipts.approval_code%TYPE,

      ---Bug 3220078 Change the parameter to TRUE
      p_call_payment_processor  IN VARCHAR2 DEFAULT FND_API.G_TRUE,

      p_payment_response_error_code OUT NOCOPY VARCHAR2,
   -- OUT NOCOPY parameter for the Application
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_payment_set_id            IN OUT NOCOPY NUMBER,
      p_org_id                    IN NUMBER DEFAULT NULL,
      -- bug 4491278  payment uptake project
      p_payment_trxn_extension_id IN ar_cash_receipts.payment_trxn_extension_id%TYPE DEFAULT NULL
      );
 /*#
 * Use this procedure to calculate the amount of all the installments of
 * a given payment term.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Installment Amount
 */

 PROCEDURE get_installment(
      p_term_id         IN  NUMBER,
      p_amount          IN  NUMBER,
      p_currency_code   IN  VARCHAR2,
      p_org_id          IN NUMBER DEFAULT NULL,
      p_installment_tbl OUT NOCOPY ar_prepayments_pub.installment_tbl,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);



END AR_PREPAYMENTS_PUB;

 

/
