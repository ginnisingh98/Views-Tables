--------------------------------------------------------
--  DDL for Package AR_RECEIPT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RECEIPT_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXPREVS.pls 120.14.12010000.2 2008/11/14 08:58:40 pbapna ship $             */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- jbeckett  25-MAR-02 Bug 2270825 - additional parameters for claims in
--                     validate_application_ref.  Added dbdrv commands.
-- jbeckett  14-FEB-03 Bug 2751910 - added validate_open_receipt_info.
-- Enter package declarations as shown below
--
--  23-OCT-2003 Obaidur Rashid
--
--  Description of changes:
--  =======================
--
--    Changes for the CONSOLIDATE BANK ACCOUNTS project are done in this
--    version.  List of changes are given below.
--
--    PLEASE NOTE ONLY SOME OF THESE MAY APPLY TO THIS FILE.
--
--    1. References to ap_bank_branches has been changed to ce_bank_branches_v
--       where possible.
--
--    2. Reference to ap_bank_accounts for internal bank accounts has been
--       changed to ce_bank_acct_uses.  An additional join may have been added
--       to ce_bank_accounts table if the column selected does not appear in
--       the uses table.
--
--    3. All bank branch/bank account related identifiers declared with %TYPE
--       has been appropriately changed to point to the new data model.
--
--    4. All local identifiers holding the remittance_bank_account_id has been
--       renamed to remit_bank_acct_use_id signifying what it holds now.
--       Please note that parameters for subroutines are left alone even though
--       they too hold use ids now.
--
--    5. Some columns are renamed when mapped in the new data model, so those
--       changes are also made.
--
--    6. For internal bank account, the Where clause conditions involving
--       ap_bank_accounts.set_of_books_id has been omitted as it is now
--       redundant and the column set_of_books_id column is obsolete.
--
--    Payment uptake  bichatte ( Reverted )
--     i) removed the reference to customer_bank_account_id
--          from CUSTOMER_REC.
--    ii) removed customer_bank_account_id from Validate_cash_receipt
--

TYPE Receipt_Method_Rec     IS RECORD
         (method_id          ar_receipt_methods.receipt_method_id%TYPE,
          bank_account_id    ar_cash_receipts.remit_bank_acct_use_id%type,
          state              ar_receipt_classes.creation_status%TYPE,
          remit_flag         ar_receipt_classes.remit_flag%TYPE
         );
TYPE Customer_Rec   IS  RECORD
         (customer_id          ar_cash_receipts.pay_from_customer%TYPE,
          /* 6612301 */
          bank_account_id      ar_cash_receipts.customer_bank_account_id%TYPE,
          bank_branch_id       ar_cash_receipts.customer_bank_branch_id%TYPE,
          site_use_id          ar_cash_receipts.customer_site_use_id%TYPE
         );

TYPE Rec_Method_Info_Tbl_Type   IS TABLE OF Receipt_Method_Rec
                                INDEX BY BINARY_INTEGER;

TYPE Rec_Customer_Tbl_Type  IS TABLE OF Customer_Rec
                             INDEX BY BINARY_INTEGER;
Method_Info_Cache_Tbl   Rec_Method_Info_Tbl_Type ;

Customer_Cache_Tbl Rec_Customer_Tbl_Type;

 PROCEDURE Validate_Cash_Receipt(
                 p_receipt_number  IN ar_cash_receipts.receipt_number%TYPE,
                 p_receipt_method_id IN ar_cash_receipts.receipt_method_id%TYPE,
                 p_state         IN ar_receipt_classes.creation_status%TYPE,
                 p_receipt_date  IN ar_cash_receipts.receipt_date%TYPE,
                 p_gl_date       IN ar_cash_receipt_history.gl_date%TYPE,
                 p_maturity_date IN DATE,
                 p_deposit_date  IN ar_cash_receipts.deposit_date%TYPE,
                 p_amount        IN OUT NOCOPY ar_cash_receipts.amount%TYPE,
                 p_factor_discount_amount   IN ar_cash_receipts.factor_discount_amount%TYPE,
                 p_customer_id              IN ar_cash_receipts.pay_from_customer%TYPE,
                 /* 6612301 */
                 p_customer_bank_account_id IN OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE,
                 p_location                 IN hz_cust_site_uses.location%TYPE,
                 p_customer_site_use_id     IN OUT NOCOPY ar_cash_receipts.customer_site_use_id%TYPE,
                 p_remittance_bank_account_id   IN ar_cash_receipts.remit_bank_acct_use_id%type,
                 p_override_remit_account_flag  IN ar_cash_receipts.override_remit_account_flag%TYPE,
                 p_anticipated_clearing_date    IN ar_cash_receipts.anticipated_clearing_date%TYPE,
                 p_currency_code            IN ar_cash_receipts.currency_code%TYPE,
                 p_exchange_rate_type       IN ar_cash_receipts.exchange_rate_type%TYPE,
                 p_exchange_rate            IN ar_cash_receipts.exchange_rate%TYPE,
                 p_exchange_rate_date       IN ar_cash_receipts.exchange_date%TYPE,
                 p_doc_sequence_value       IN NUMBER,
                 p_called_from              IN VARCHAR2,
                 p_return_status            OUT NOCOPY VARCHAR2);

 PROCEDURE Validate_Application_info(
                 p_apply_date                  IN DATE,
                 p_cr_date                     IN DATE,
                 p_trx_date                    IN DATE,
                 p_apply_gl_date               IN DATE,
                 p_trx_gl_date                 IN DATE,
                 p_cr_gl_date                  IN DATE,
                 p_amount_applied              IN NUMBER,
                 p_applied_payment_schedule_id IN NUMBER,
                 p_customer_trx_line_id        IN NUMBER,
                 p_inv_line_amount             IN NUMBER,
                 p_creation_sign               IN VARCHAR2,
                 p_allow_overappln_flag  IN VARCHAR2,
                 p_natural_appln_only_flag IN VARCHAR2,
                 p_discount                    IN NUMBER,
                 p_amount_due_remaining        IN NUMBER,
                 p_amount_due_original         IN NUMBER,
                 p_trans_to_receipt_rate       IN NUMBER,
                 p_cr_currency_code            IN VARCHAR2,
                 p_trx_currency_code           IN VARCHAR2,
                 p_amount_applied_from         IN NUMBER,
                 p_cr_unapp_amount             IN NUMBER,
                 p_partial_discount_flag       IN VARCHAR2,
                 p_discount_earned_allowed     IN NUMBER,
                 p_discount_max_allowed        IN NUMBER,
                 p_move_deferred_tax           IN VARCHAR2,
	 	 p_llca_type		       IN VARCHAR2,
 		 p_line_amount		       IN NUMBER,
		 p_tax_amount		       IN NUMBER,
		 p_freight_amount	       IN NUMBER,
		 p_charges_amount	       IN NUMBER,
	         p_line_discount               IN NUMBER,
	         p_tax_discount                IN NUMBER,
	         p_freight_discount            IN NUMBER,
		 p_line_items_original	       IN NUMBER,
		 p_line_items_remaining	       IN NUMBER,
		 p_tax_original		       IN NUMBER,
		 p_tax_remaining	       IN NUMBER,
		 p_freight_original	       IN NUMBER,
		 p_freight_remaining	       IN NUMBER,
		 p_rec_charges_charged	       IN NUMBER,
		 p_rec_charges_remaining       IN NUMBER,
                 p_return_status               OUT NOCOPY VARCHAR2
                    );
/*Added the parameter p_cr_unapp_amount for bug 3119391 */
PROCEDURE Validate_unapp_info(
                 p_receipt_gl_date             IN DATE,
                 p_receivable_application_id   IN NUMBER,
                 p_reversal_gl_date            IN DATE,
                 p_apply_gl_date               IN DATE,
		 p_cr_unapp_amount             IN  NUMBER,
                 p_return_status               OUT NOCOPY VARCHAR2
                    );
PROCEDURE Validate_reverse_info(
                 p_cash_receipt_id         IN NUMBER,
                 p_receipt_gl_date         IN DATE,
                 p_reversal_category_code  IN VARCHAR2,
                 p_reversal_reason_code    IN VARCHAR2,
                 p_reversal_gl_date        IN DATE,
                 p_reversal_date           IN DATE,
		 p_return_status           OUT NOCOPY VARCHAR2
                    );
PROCEDURE check_std_reversible(
                p_cash_receipt_id  IN NUMBER,
                p_reversal_date    IN DATE,
                p_receipt_state    IN VARCHAR2,
                p_called_from      IN VARCHAR2,
                p_std_reversal_possible  OUT NOCOPY VARCHAR2
                   );

PROCEDURE validate_on_ac_app( p_cash_receipt_id IN NUMBER,
                p_cr_gl_date  IN DATE,
                p_cr_unapp_amount IN NUMBER,
                p_cr_date IN DATE,
                p_cr_payment_schedule_id IN NUMBER,
                p_applied_amount IN NUMBER,
                p_apply_gl_date IN DATE,
                p_apply_date IN DATE,
                p_return_status OUT NOCOPY VARCHAR2,
                p_applied_ps_id IN NUMBER DEFAULT NULL,
                p_called_from IN VARCHAR2 DEFAULT NULL
                   );
PROCEDURE validate_unapp_on_ac_act_info(
                p_receipt_gl_date  IN DATE,
                p_receivable_application_id  IN NUMBER,
                p_reversal_gl_date  IN DATE,
                p_apply_gl_date    IN DATE,
                p_cr_unapp_amt     IN NUMBER, /* Bug fix 3569640 */
                p_return_status  OUT NOCOPY VARCHAR2
                   );
PROCEDURE validate_activity_app(
                p_receivables_trx_id           IN     NUMBER,
                p_applied_ps_id                IN     NUMBER,
                p_cash_receipt_id              IN     NUMBER,
                p_cr_gl_date                   IN     DATE,
                p_cr_unapp_amount              IN     NUMBER,
                p_cr_date                      IN     DATE,
                p_cr_payment_schedule_id       IN     NUMBER,
                p_applied_amount               IN     NUMBER,
                p_apply_gl_date                IN     DATE,
                p_apply_date                   IN     DATE,
                p_link_to_customer_trx_id      IN     NUMBER,
                p_cr_currency_code             IN     VARCHAR2,
                p_return_status                OUT NOCOPY VARCHAR2,
                p_val_writeoff_limits_flag     IN VARCHAR2 DEFAULT 'Y',
		p_called_from		       IN VARCHAR2 DEFAULT NULL
                     );
PROCEDURE validate_application_ref(
                p_applied_ps_id                IN     NUMBER,
                p_application_ref_type         IN     VARCHAR2,
                p_application_ref_id           IN     NUMBER,
                p_application_ref_num          IN     VARCHAR2,
                p_secondary_application_ref_id IN     NUMBER,
                p_cash_receipt_id              IN     NUMBER,
                p_amount_applied               IN     NUMBER,
                p_amount_due_remaining         IN     NUMBER,
                p_cr_currency_code             IN     VARCHAR2,
                p_trx_currency_code            IN     VARCHAR2,
                p_application_ref_reason       IN     VARCHAR2,
                p_return_status                OUT NOCOPY    VARCHAR2
                   );

PROCEDURE Validate_misc_receipt(
                p_receipt_number               IN     VARCHAR2,
                p_receipt_method_id            IN     NUMBER,
                p_state                        IN     VARCHAR2,
                p_receipt_date                 IN     DATE,
                p_gl_date                      IN     DATE,
                p_deposit_date                 IN     DATE,
                p_amount                       IN     NUMBER,
                p_orig_receivables_trx_id      IN     NUMBER,
                p_receivables_trx_id           IN     NUMBER,
                p_distribution_set_id          IN OUT NOCOPY NUMBER,
                p_orig_vat_tax_id              IN     NUMBER,
                p_vat_tax_id                   IN     NUMBER,
                p_tax_rate                     IN OUT NOCOPY NUMBER,
                p_tax_amount                   IN     NUMBER,
                p_reference_num                IN     VARCHAR2,
                p_orig_reference_id            IN     NUMBER,
                p_reference_id                 IN     NUMBER,
                p_reference_type               IN     VARCHAR2,
                p_remittance_bank_account_id   IN     NUMBER,
                p_anticipated_clearing_date    IN     DATE,
                p_currency_code                IN     VARCHAR2,
                p_exchange_rate_type           IN     VARCHAR2,
                p_exchange_rate                IN     NUMBER,
                p_exchange_date                IN     DATE,
                p_doc_sequence_value           IN     NUMBER,
                p_return_status                   OUT NOCOPY VARCHAR2
                   );

PROCEDURE validate_prepay_amount(
                p_receipt_number              IN  VARCHAR2,
                p_cash_receipt_id             IN  NUMBER,
                p_applied_ps_id               IN  NUMBER,
                p_receivable_application_id   IN  NUMBER,
                p_refund_amount               IN  NUMBER,
                p_return_status               OUT NOCOPY VARCHAR2
                   );

PROCEDURE validate_payment_type(
                p_receipt_number              IN  VARCHAR2,
                p_cash_receipt_id             IN  NUMBER,
                p_receivable_application_id   IN  NUMBER,
                p_payment_action              IN  VARCHAR2,
                p_return_status               OUT NOCOPY VARCHAR2
                   );

PROCEDURE validate_claim_unapply(
                p_secondary_app_ref_id        IN  VARCHAR2,
                p_invoice_ps_id               IN  NUMBER,
                p_customer_trx_id             IN  NUMBER,
                p_cash_receipt_id             IN  NUMBER,
                p_receipt_number              IN  VARCHAR2,
                p_amount_applied              IN  NUMBER,
                p_cancel_claim_flag           IN  VARCHAR2,
                p_return_status               OUT NOCOPY VARCHAR2
                   );

PROCEDURE validate_open_receipt_info(
       p_cash_receipt_id         IN  NUMBER
     , p_open_cash_receipt_id    IN  NUMBER
     , p_apply_date              IN  DATE
     , p_apply_gl_date           IN  DATE
     , p_cr_gl_date              IN  DATE
     , p_open_cr_gl_date         IN  DATE
     , p_cr_date                 IN  DATE
     , p_amount_applied          IN  NUMBER
     , p_other_amount_applied    IN  NUMBER
     , p_receipt_currency        IN  VARCHAR2
     , p_open_receipt_currency   IN  VARCHAR2
     , p_cr_customer_id          IN  NUMBER
     , p_open_cr_customer_id     IN  NUMBER
     , p_unapplied_cash          IN  NUMBER
     , p_called_from             IN  VARCHAR2
     , p_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE validate_unapp_open_receipt(
       p_applied_cash_receipt_id IN  NUMBER
     , p_amount_applied          IN  NUMBER
     , p_return_status           IN OUT NOCOPY VARCHAR2);

PROCEDURE validate_llca_insert_ad(
         p_cash_receipt_id       IN	NUMBER
        ,p_customer_trx_id       IN	NUMBER
        ,p_customer_trx_line_id  IN	NUMBER
        ,p_cr_unapp_amount       IN	NUMBER
        ,p_llca_type             IN	VARCHAR2
        ,p_group_id              IN	VARCHAR2
        ,p_line_amount           IN	NUMBER
        ,p_tax_amount            IN	NUMBER
        ,p_freight_amount        IN	NUMBER
        ,p_charges_amount        IN	NUMBER
        ,p_line_discount         IN	NUMBER
        ,p_tax_discount          IN	NUMBER
        ,p_freight_discount      IN	NUMBER
        ,p_amount_applied        IN     NUMBER
        ,p_amount_applied_from   IN	NUMBER
        ,p_trans_to_receipt_rate IN	NUMBER
        ,p_invoice_currency_code IN	VARCHAR2
        ,p_receipt_currency_code IN	VARCHAR2
        ,p_earned_discount       IN	NUMBER
        ,p_unearned_discount     IN	NUMBER
        ,p_max_discount          IN	NUMBER
        ,p_line_items_original	 IN	NUMBER
	,p_line_items_remaining	 IN	NUMBER
	,p_tax_original		 IN	NUMBER
	,p_tax_remaining	 IN	NUMBER
	,p_freight_original	 IN	NUMBER
	,p_freight_remaining	 IN	NUMBER
	,p_rec_charges_charged	 IN	NUMBER
	,p_rec_charges_remaining IN	NUMBER
        ,p_attribute_category    IN	VARCHAR2
        ,p_attribute1            IN	VARCHAR2
        ,p_attribute2            IN	VARCHAR2
        ,p_attribute3            IN	VARCHAR2
        ,p_attribute4            IN	VARCHAR2
        ,p_attribute5            IN	VARCHAR2
        ,p_attribute6            IN	VARCHAR2
        ,p_attribute7            IN	VARCHAR2
        ,p_attribute8            IN	VARCHAR2
        ,p_attribute9            IN	VARCHAR2
        ,p_attribute10           IN	VARCHAR2
        ,p_attribute11           IN	VARCHAR2
        ,p_attribute12           IN	VARCHAR2
        ,p_attribute13           IN	VARCHAR2
        ,p_attribute14           IN	VARCHAR2
        ,p_attribute15           IN	VARCHAR2
        ,p_comments              IN	VARCHAR2
        ,p_return_status         OUT NOCOPY VARCHAR2
        ,p_msg_count             OUT NOCOPY NUMBER
        ,p_msg_data              OUT NOCOPY VARCHAR2
	);

PROCEDURE validate_llca_insert_app(
         p_cash_receipt_id       IN     NUMBER
        ,p_customer_trx_id       IN     NUMBER
        ,p_disc_earn_allowed     IN     NUMBER
        ,p_disc_max_allowed      IN     NUMBER
        ,p_return_status         OUT NOCOPY VARCHAR2
        ,p_msg_count             OUT NOCOPY NUMBER
        ,p_msg_data              OUT NOCOPY VARCHAR2
       );

END AR_RECEIPT_VAL_PVT ; -- Package spec


/
