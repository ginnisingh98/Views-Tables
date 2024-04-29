--------------------------------------------------------
--  DDL for Package AR_RECEIPT_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RECEIPT_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXPRELS.pls 120.19.12010000.4 2009/04/10 16:38:52 spdixit ship $    */
--These package variables contain the profile option values.
pg_profile_doc_seq             VARCHAR2(240);
pg_profile_enable_cc           VARCHAR2(240);
pg_profile_appln_gl_date_def   VARCHAR2(240);
pg_profile_amt_applied_def     VARCHAR2(240);
pg_profile_cc_rate_type        VARCHAR2(240);
pg_profile_dsp_inv_rate        VARCHAR2(240);
pg_profile_create_bk_charges   VARCHAR2(240);
pg_profile_def_x_rate_type     VARCHAR2(240);

pg_cust_derived_from           VARCHAR2(20);

/* Revert changes done for customer bank ref from Default_cash_ids under payment uptake */
PROCEDURE Default_cash_ids(
              p_usr_currency_code           IN  fnd_currencies_vl.name%TYPE,
              p_usr_exchange_rate_type      IN  gl_daily_conversion_types.user_conversion_type%TYPE,
              p_customer_name               IN  hz_parties.party_name%TYPE,
              p_customer_number             IN  hz_cust_accounts.account_number%TYPE,
              p_location                    IN  hz_cust_site_uses.location%type,
              p_receipt_method_name         IN  OUT NOCOPY ar_receipt_methods.name%TYPE,
              /* 6612301 */
              p_customer_bank_account_name   IN     iby_ext_bank_accounts_v.bank_account_name%TYPE,
              p_customer_bank_account_num    IN     iby_ext_bank_accounts_v.bank_account_number%TYPE,
              p_remittance_bank_account_name IN  ce_bank_accounts.bank_account_name%TYPE,
              p_remittance_bank_account_num IN  ce_bank_accounts.bank_account_num%TYPE,
              p_currency_code               IN OUT NOCOPY ar_cash_receipts.currency_code%TYPE,
              p_exchange_rate_type          IN OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE,
              p_customer_id                 IN OUT NOCOPY ar_cash_receipts.pay_from_customer%TYPE,
              p_customer_site_use_id        IN OUT NOCOPY hz_cust_site_uses.site_use_id%TYPE,
              p_receipt_method_id           IN OUT NOCOPY ar_cash_receipts.receipt_method_id%TYPE,
              /* 6612301 */
              p_customer_bank_account_id    IN OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE,
	            p_customer_bank_branch_id     IN OUT NOCOPY  ar_cash_receipts.customer_bank_branch_id%TYPE,
	            p_remittance_bank_account_id  IN OUT NOCOPY ar_cash_receipts.remit_bank_acct_use_id%TYPE,
              p_receipt_date                IN  DATE,
              p_return_status               OUT NOCOPY VARCHAR2,
              p_default_site_use            IN VARCHAR2 --bug4448307-4509459
                  );

PROCEDURE Get_Cash_Defaults(
              p_currency_code      IN OUT NOCOPY ar_cash_receipts.currency_code%TYPE,
              p_exchange_rate_type IN OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE,
              p_exchange_rate      IN OUT NOCOPY ar_cash_receipts.exchange_rate%TYPE,
              p_exchange_rate_date IN OUT NOCOPY ar_cash_receipts.exchange_date%TYPE,
              p_amount             IN OUT NOCOPY ar_cash_receipts.amount%TYPE,
              p_factor_discount_amount IN OUT NOCOPY ar_cash_receipts.factor_discount_amount%TYPE,
              p_receipt_date       IN  OUT NOCOPY ar_cash_receipts.receipt_date%TYPE,
              p_gl_date            IN  OUT NOCOPY DATE,
              p_maturity_date      IN  OUT NOCOPY DATE,
              p_customer_receipt_reference       IN OUT NOCOPY ar_cash_receipts.customer_receipt_reference%TYPE,
              p_override_remit_account_flag      IN OUT NOCOPY ar_cash_receipts.override_remit_account_flag%TYPE,
              p_remittance_bank_account_id       IN OUT NOCOPY ar_cash_receipts.remit_bank_acct_use_id%TYPE,
              p_deposit_date                     IN OUT NOCOPY ar_cash_receipts.deposit_date%TYPE,
              p_receipt_method_id                IN OUT NOCOPY ar_cash_receipts.receipt_method_id%TYPE,
              p_state                               OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
              p_anticipated_clearing_date        IN OUT NOCOPY ar_cash_receipts.anticipated_clearing_date%TYPE,
              p_called_from                      IN     VARCHAR2,
              p_creation_method_code                OUT NOCOPY ar_receipt_classes.creation_method_code%TYPE,
              p_return_status                       OUT NOCOPY VARCHAR2
           );

/* Bug fix  3435834 : Added two new parameters p_customer_trx_line_id and p_line_number */

PROCEDURE Default_appln_ids(
              p_cash_receipt_id   IN OUT NOCOPY NUMBER,
              p_receipt_number    IN VARCHAR2,
              p_customer_trx_id   IN OUT NOCOPY NUMBER,
              p_trx_number        IN VARCHAR2,
              p_customer_trx_line_id IN OUT NOCOPY NUMBER,
              p_line_number       IN NUMBER,
              p_installment       IN OUT NOCOPY NUMBER,
              p_applied_payment_schedule_id IN NUMBER,
      	      p_llca_type	  IN VARCHAR2,
      	      p_group_id          IN VARCHAR2,  /* Bug 5284890 */
              p_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE Default_application_info(
              p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
              p_cr_gl_date            OUT NOCOPY DATE,
              p_cr_date               OUT NOCOPY DATE,
              p_cr_amount             OUT NOCOPY ar_cash_receipts.amount%TYPE,
              p_cr_unapp_amount       OUT NOCOPY NUMBER,
              p_cr_currency_code      OUT NOCOPY VARCHAR2,
              p_customer_trx_id       IN ra_customer_trx.customer_trx_id%TYPE,
              p_installment           IN OUT NOCOPY NUMBER,
              p_show_closed_invoices  IN VARCHAR2,
              p_customer_trx_line_id  IN NUMBER,
              p_trx_due_date          OUT NOCOPY DATE,
              p_trx_currency_code     OUT NOCOPY VARCHAR2,
              p_trx_date              OUT NOCOPY DATE,
              p_trx_gl_date                   OUT NOCOPY DATE,
              p_apply_gl_date              IN OUT NOCOPY DATE,
              p_calc_discount_on_lines_flag   OUT NOCOPY VARCHAR2,
              p_partial_discount_flag         OUT NOCOPY VARCHAR2,
              p_allow_overappln_flag          OUT NOCOPY VARCHAR2,
              p_natural_appln_only_flag       OUT NOCOPY VARCHAR2,
              p_creation_sign                 OUT NOCOPY VARCHAR2,
              p_cr_payment_schedule_id        OUT NOCOPY NUMBER,
              p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
              p_term_id                       OUT NOCOPY NUMBER,
              p_amount_due_original           OUT NOCOPY NUMBER,
              p_amount_due_remaining          OUT NOCOPY NUMBER,
              p_trx_line_amount               OUT NOCOPY NUMBER,
              p_discount                   IN OUT NOCOPY NUMBER,
              p_apply_date                 IN OUT NOCOPY DATE,
              p_discount_max_allowed          OUT NOCOPY NUMBER,
              p_discount_earned_allowed       OUT NOCOPY NUMBER,
              p_discount_earned               OUT NOCOPY NUMBER,
              p_discount_unearned             OUT NOCOPY NUMBER,
              p_new_amount_due_remaining      OUT NOCOPY NUMBER,
              p_remittance_bank_account_id    OUT NOCOPY NUMBER,
              p_receipt_method_id             OUT NOCOPY NUMBER,
              p_amount_applied             IN OUT NOCOPY NUMBER,
              p_amount_applied_from        IN OUT NOCOPY NUMBER,
              p_trans_to_receipt_rate      IN OUT NOCOPY NUMBER,
      	      p_llca_type		   IN VARCHAR2,
	      p_line_amount		   IN OUT NOCOPY NUMBER,
	      p_tax_amount		   IN OUT NOCOPY NUMBER,
	      p_freight_amount		   IN OUT NOCOPY NUMBER,
	      p_charges_amount		   IN OUT NOCOPY NUMBER,
	      p_line_discount              IN OUT NOCOPY NUMBER,
	      p_tax_discount               IN OUT NOCOPY NUMBER,
	      p_freight_discount           IN OUT NOCOPY NUMBER,
      	      p_line_items_original	      OUT NOCOPY NUMBER,
	      p_line_items_remaining	      OUT NOCOPY NUMBER,
	      p_tax_original		      OUT NOCOPY NUMBER,
	      p_tax_remaining		      OUT NOCOPY NUMBER,
	      p_freight_original	      OUT NOCOPY NUMBER,
	      p_freight_remaining	      OUT NOCOPY NUMBER,
	      p_rec_charges_charged	      OUT NOCOPY NUMBER,
	      p_rec_charges_remaining	      OUT NOCOPY NUMBER,
              p_called_from                IN     VARCHAR2,
              p_return_status                 OUT NOCOPY VARCHAR2);

PROCEDURE Default_cash_receipt_id(
              p_cash_receipt_id IN OUT NOCOPY NUMBER,
              p_receipt_number  IN VARCHAR2,
              p_return_status   OUT NOCOPY VARCHAR2
                         );

PROCEDURE Derive_unapp_ids(
              p_trx_number                   IN VARCHAR2,
              p_customer_trx_id              IN OUT NOCOPY NUMBER,
              p_installment                  IN NUMBER,
              p_applied_payment_schedule_id  IN OUT NOCOPY NUMBER,
              p_receipt_number               IN VARCHAR2,
              p_cash_receipt_id              IN OUT NOCOPY NUMBER,
              p_receivable_application_id    IN OUT NOCOPY NUMBER,
              p_called_from                  IN VARCHAR2,
              p_apply_gl_date                OUT NOCOPY DATE,
              p_return_status                OUT NOCOPY VARCHAR2
                    );
/* Added for bug 3119391 */
PROCEDURE Default_unapp_info(
              p_receivable_application_id IN NUMBER,
              p_apply_gl_date    IN  DATE,
              p_cash_receipt_id  IN  NUMBER,
              p_reversal_gl_date IN OUT NOCOPY DATE,
              p_receipt_gl_date  OUT NOCOPY DATE,
	      p_cr_unapp_amount  OUT NOCOPY NUMBER );

PROCEDURE Default_reverse_info(p_cash_receipt_id  IN NUMBER,
              p_reversal_gl_date IN OUT NOCOPY DATE,
              p_reversal_date    IN OUT NOCOPY DATE,
              p_receipt_state    OUT NOCOPY VARCHAR2,
              p_receipt_gl_date  OUT NOCOPY DATE,
              p_type             OUT NOCOPY VARCHAR2
                     ) ;

PROCEDURE Derive_reverse_ids(
                         p_receipt_number         IN     VARCHAR2,
                         p_cash_receipt_id        IN OUT NOCOPY NUMBER,
                         p_reversal_category_name IN     VARCHAR2,
                         p_reversal_category_code IN OUT NOCOPY VARCHAR2,
                         p_reversal_reason_name   IN     VARCHAR2,
                         p_reversal_reason_code   IN OUT NOCOPY VARCHAR2,
                         p_return_status             OUT NOCOPY VARCHAR2
                           );
PROCEDURE Default_on_ac_app_info(
                         p_cash_receipt_id         IN NUMBER,
                         p_cr_gl_date                 OUT NOCOPY DATE,
                         p_cr_unapp_amount            OUT NOCOPY NUMBER,
                         p_receipt_date               OUT NOCOPY DATE,
                         p_cr_payment_schedule_id     OUT NOCOPY NUMBER,
                         p_amount_applied          IN OUT NOCOPY NUMBER,
                         p_apply_gl_date           IN OUT NOCOPY DATE,
                         p_apply_date              IN OUT NOCOPY DATE,
                         p_cr_currency_code           OUT NOCOPY VARCHAR2,
                         p_return_status              OUT NOCOPY VARCHAR2
                              );
PROCEDURE Derive_unapp_on_ac_ids(
                         p_receipt_number    IN VARCHAR2,
                         p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date    OUT NOCOPY DATE,
                         p_return_status  OUT NOCOPY VARCHAR2
                               );

PROCEDURE Derive_otheraccount_ids(
                         p_receipt_number    IN VARCHAR2,
                         p_cash_receipt_id   IN OUT NOCOPY NUMBER,
                         p_applied_ps_id     IN NUMBER,
                         p_receivable_application_id   IN OUT NOCOPY NUMBER,
                         p_apply_gl_date    OUT NOCOPY DATE,
                         p_cr_unapp_amt     OUT NOCOPY NUMBER, /* Bug fix 3569640 */
                         p_return_status  OUT NOCOPY VARCHAR2
                               );

PROCEDURE Default_unapp_on_ac_act_info(
                         p_receivable_application_id IN NUMBER,
                         p_apply_gl_date             IN DATE,
                         p_cash_receipt_id           IN NUMBER,
                         p_reversal_gl_date          IN OUT NOCOPY DATE,
                         p_receipt_gl_date           OUT NOCOPY DATE
                               );

PROCEDURE Derive_activity_unapp_ids(
              p_receipt_number               IN      VARCHAR2,
              p_cash_receipt_id              IN OUT NOCOPY  NUMBER,
              p_receivable_application_id    IN OUT NOCOPY  NUMBER,
              p_called_from                  IN      VARCHAR2,
              p_apply_gl_date                   OUT NOCOPY  DATE,
              p_cr_unapp_amount                 OUT NOCOPY  NUMBER, /* Bug fix 3569640 */
              p_return_status                   OUT NOCOPY  VARCHAR2);

/* bug 2649369, proactive change to param p_met_code, change type from CHAR to VARCHAR2 */

PROCEDURE  get_doc_seq(
              p_application_id               IN      NUMBER,
              p_document_name                IN      VARCHAR2,
              p_sob_id                       IN      NUMBER,
              p_met_code	             IN      VARCHAR2,
              p_trx_date                     IN      DATE,
              p_doc_sequence_value           IN OUT NOCOPY  NUMBER,
              p_doc_sequence_id                 OUT NOCOPY  NUMBER,
              p_return_status                   OUT NOCOPY  VARCHAR2
                         );
PROCEDURE Derive_cust_info_from_trx(
              p_customer_trx_id              IN      ar_payment_schedules.customer_trx_id%TYPE,
              p_trx_number                   IN      ra_customer_trx.trx_number%TYPE,
              p_installment                  IN      ar_payment_schedules.terms_sequence_number%TYPE,
              p_applied_payment_schedule_id  IN      ar_payment_schedules.payment_schedule_id%TYPE,
              p_currency_code                IN      ar_cash_receipts.currency_code%TYPE,
              p_customer_id                     OUT NOCOPY  ar_payment_schedules.customer_id%TYPE,
              p_customer_site_use_id            OUT NOCOPY  hz_cust_site_uses.site_use_id%TYPE,
              p_return_status                   OUT NOCOPY  VARCHAR2
                       );
PROCEDURE Validate_Desc_Flexfield(
              p_desc_flex_rec                IN OUT NOCOPY  ar_receipt_api_pub.attribute_rec_type,
              p_desc_flex_name               IN      VARCHAR2,
              p_return_status                IN OUT NOCOPY  VARCHAR2
                       );
/* Bug fix 3539008 */
PROCEDURE Default_Desc_Flexfield(
              p_desc_flex_rec                OUT NOCOPY  ar_receipt_api_pub.attribute_rec_type,
              p_cash_receipt_id              IN      NUMBER,
              p_return_status                IN OUT NOCOPY  VARCHAR2
                       );
-- Bug 4594101:  ETAX: added p_receipt_Date for derivation of
-- tax rates.
PROCEDURE Default_misc_ids(
              p_usr_currency_code            IN      VARCHAR2,
              p_usr_exchange_rate_type       IN      VARCHAR2,
              p_activity                     IN      VARCHAR2,
              p_reference_type               IN      VARCHAR2,
              p_reference_num                IN      VARCHAR2,
              p_tax_code                     IN      VARCHAR2,
              p_receipt_method_name          IN OUT NOCOPY  VARCHAR2,
              p_remittance_bank_account_name IN      VARCHAR2,
              p_remittance_bank_account_num  IN      VARCHAR2,
              p_currency_code                IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate_type           IN OUT NOCOPY  VARCHAR2,
              p_receivables_trx_id           IN OUT NOCOPY  NUMBER,
              p_reference_id                 IN OUT NOCOPY  NUMBER,
              p_vat_tax_id                   IN OUT NOCOPY  NUMBER,
              p_receipt_method_id            IN OUT NOCOPY  NUMBER,
              p_remittance_bank_account_id   IN OUT NOCOPY  NUMBER,
              p_return_status                   OUT NOCOPY  VARCHAR2,
              p_receipt_date                 IN DATE DEFAULT NULL
                       );
PROCEDURE Get_misc_defaults(
              p_currency_code                IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate_type           IN OUT NOCOPY  VARCHAR2,
              p_exchange_rate                IN OUT NOCOPY  NUMBER,
              p_exchange_date                IN OUT NOCOPY  DATE,
              p_amount                       IN OUT NOCOPY  NUMBER,
              p_receipt_date                 IN OUT NOCOPY  DATE,
              p_gl_date                      IN OUT NOCOPY  DATE,
              p_remittance_bank_account_id   IN OUT NOCOPY  NUMBER,
              p_deposit_date                 IN OUT NOCOPY  DATE,
              p_state                        IN OUT NOCOPY  VARCHAR2,
              p_distribution_set_id          IN OUT NOCOPY  NUMBER,
              p_vat_tax_id                   IN OUT NOCOPY  NUMBER,
              p_tax_rate                     IN OUT NOCOPY  NUMBER,
              p_receipt_method_id            IN      NUMBER,
              p_receivables_trx_id           IN      NUMBER,
              p_tax_code                     IN      VARCHAR2,
              p_tax_amount                   IN      NUMBER,
              p_creation_method_code            OUT NOCOPY  VARCHAR2,
              p_return_status                   OUT NOCOPY  VARCHAR2
                        );

PROCEDURE Default_prepay_cc_activity(
              p_appl_type                    IN      VARCHAR2,
              p_receivable_trx_id            IN OUT NOCOPY  NUMBER,
              p_return_status                OUT NOCOPY     VARCHAR2
             );

PROCEDURE default_open_receipt(
              p_cash_receipt_id          IN OUT NOCOPY NUMBER
            , p_receipt_number           IN OUT NOCOPY VARCHAR2
            , p_applied_ps_id            IN OUT NOCOPY NUMBER
            , p_open_cash_receipt_id     IN OUT NOCOPY NUMBER
            , p_open_receipt_number      IN OUT NOCOPY VARCHAR2
            , p_apply_gl_date            IN OUT NOCOPY DATE
            , p_open_rec_app_id          IN NUMBER
            , x_cr_payment_schedule_id   OUT NOCOPY NUMBER
            , x_last_receipt_date        OUT NOCOPY DATE
            , x_open_applied_ps_id       OUT NOCOPY NUMBER
            , x_unapplied_cash           OUT NOCOPY NUMBER
            , x_open_amount_applied      OUT NOCOPY NUMBER
            , x_claim_rec_trx_id         OUT NOCOPY NUMBER
            , x_application_ref_num      OUT NOCOPY VARCHAR2
            , x_secondary_app_ref_id     OUT NOCOPY NUMBER
            , x_application_ref_reason   OUT NOCOPY VARCHAR2
            , x_customer_reference       OUT NOCOPY VARCHAR2
            , x_customer_reason          OUT NOCOPY VARCHAR2
            , x_cr_gl_date               OUT NOCOPY DATE
            , x_open_cr_gl_date          OUT NOCOPY DATE
            , x_receipt_currency         OUT NOCOPY VARCHAR2
            , x_open_receipt_currency    OUT NOCOPY VARCHAR2
            , x_cr_customer_id           OUT NOCOPY NUMBER
            , x_open_cr_customer_id      OUT NOCOPY NUMBER
            , x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE default_unapp_open_receipt(
              p_receivable_application_id  IN  NUMBER
            , x_applied_cash_receipt_id    OUT NOCOPY NUMBER
            , x_applied_rec_app_id         OUT NOCOPY NUMBER
            , x_amount_applied             OUT NOCOPY NUMBER
            , x_return_status              OUT NOCOPY VARCHAR2);

FUNCTION get_legal_entity (p_remit_bank_acct_use_id IN NUMBER)
RETURN NUMBER;

PROCEDURE default_refund_attributes (
	 p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE
	,p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE
	,p_currency_code IN fnd_currencies.currency_code%TYPE
	,p_amount IN NUMBER
	,p_party_id IN OUT NOCOPY hz_parties.party_id%TYPE
	,p_party_site_id IN OUT NOCOPY hz_party_sites.party_site_id%TYPE
	,x_party_name OUT NOCOPY hz_parties.party_name%TYPE
	,x_party_number OUT NOCOPY hz_parties.party_number%TYPE
	,x_party_address OUT NOCOPY VARCHAR2
	,x_exchange_rate OUT NOCOPY ar_cash_receipts.exchange_rate%TYPE
	,x_exchange_rate_type OUT NOCOPY ar_cash_receipts.exchange_rate_type%TYPE
	,x_exchange_date OUT NOCOPY ar_cash_receipts.exchange_date%TYPE
	,x_legal_entity_id OUT NOCOPY ar_cash_receipts.legal_entity_id%TYPE
    	,x_payment_method_code OUT NOCOPY ap_invoices.payment_method_code%TYPE
    	,x_payment_method_name OUT NOCOPY VARCHAR2
    	,x_bank_account_id OUT NOCOPY ar_cash_receipts.customer_bank_account_id%TYPE

    	,x_bank_account_num OUT NOCOPY VARCHAR2
    	,x_payment_reason_code OUT NOCOPY ap_invoices.payment_reason_code%TYPE
    	,x_payment_reason_name OUT NOCOPY VARCHAR2
    	,x_delivery_channel_code OUT NOCOPY ap_invoices.delivery_channel_code%TYPE
    	,x_delivery_channel_name OUT NOCOPY VARCHAR2
    	,x_pay_alone_flag OUT NOCOPY VARCHAR2
	,x_return_status OUT NOCOPY VARCHAR2
	,x_msg_count OUT NOCOPY NUMBER
	,x_msg_data OUT NOCOPY VARCHAR2
	);



PROCEDURE populate_llca_gt (
	     p_customer_trx_id        IN NUMBER,
  	     p_llca_type              IN VARCHAR2,
             p_llca_trx_lines_tbl     IN ar_receipt_api_pub.llca_trx_lines_tbl_type,
	     p_line_amount	      IN NUMBER,
	     p_tax_amount	      IN NUMBER,
  	     p_freight_amount	      IN NUMBER,
	     p_charges_amount	      IN NUMBER,
	     p_line_discount	      IN NUMBER,
	     p_tax_discount	      IN NUMBER,
	     p_freight_discount	      IN NUMBER,
	     p_amount_applied	      IN NUMBER,
	     p_amount_applied_from    IN NUMBER,
             p_return_status          OUT NOCOPY VARCHAR2);

PROCEDURE populate_errors_gt (
	     p_customer_trx_id        IN NUMBER,
	     p_customer_trx_line_id   IN NUMBER,
	     p_error_message	      IN VARCHAR2,
	     p_invalid_value	      IN VARCHAR2
	     );

PROCEDURE Default_disc_and_amt_applied(
    p_customer_id                 IN NUMBER,
    p_bill_to_site_use_id         IN NUMBER,
    p_applied_payment_schedule_id IN NUMBER,
    p_amount_applied              IN  OUT NOCOPY NUMBER,
    p_discount                    IN OUT NOCOPY NUMBER,
    p_term_id                     IN NUMBER,
    p_installment                 IN NUMBER,
    p_trx_date                    IN DATE,
    p_cr_date                     IN DATE,
    p_cr_currency_code            IN VARCHAR2,
    p_trx_currency_code           IN VARCHAR2,
    p_cr_exchange_rate            IN NUMBER,
    p_trx_exchange_rate           IN NUMBER,
    p_apply_date                  IN DATE,
    p_amount_due_original         IN NUMBER,
    p_amount_due_remaining        IN NUMBER,
    p_cr_unapp_amount             IN NUMBER,
    p_allow_overappln_flag        IN VARCHAR2,
    p_calc_discount_on_lines_flag IN VARCHAR2,
    p_partial_discount_flag       IN VARCHAR2,
    p_amount_line_items_original  IN NUMBER,
    p_discount_taken_unearned     IN NUMBER,
    p_discount_taken_earned       IN NUMBER,
    p_customer_trx_line_id        IN NUMBER,
    p_trx_line_amount             IN NUMBER,
    p_llca_type                   IN VARCHAR2,
    p_discount_max_allowed       OUT NOCOPY NUMBER,
    p_discount_earned_allowed    OUT NOCOPY NUMBER,
    p_discount_earned            OUT NOCOPY NUMBER,
    p_discount_unearned          OUT NOCOPY NUMBER,
    p_new_amount_due_remaining   OUT NOCOPY NUMBER,
    p_return_status              OUT NOCOPY VARCHAR2
);

PROCEDURE Default_Receipt_Method_Info(
           p_receipt_method_id          IN ar_cash_receipts.receipt_method_id%TYPE,
           p_currency_code              IN ar_cash_receipts.currency_code%TYPE,
           p_receipt_date               IN ar_cash_receipts.receipt_date%TYPE,
           p_remittance_bank_account_id IN OUT NOCOPY ar_receipt_method_accounts_all.remit_bank_acct_use_id%TYPE,
           p_state                      OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
           p_creation_method_code       OUT NOCOPY ar_receipt_classes.creation_method_code%TYPE,
           p_called_from                IN VARCHAR2,
           p_return_status              OUT NOCOPY VARCHAR2
           ) ;

END ar_receipt_lib_pvt;

/
