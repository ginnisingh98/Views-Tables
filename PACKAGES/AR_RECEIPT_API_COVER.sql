--------------------------------------------------------
--  DDL for Package AR_RECEIPT_API_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RECEIPT_API_COVER" AUTHID CURRENT_USER AS
/* $Header: ARXRCCVS.pls 120.2 2003/08/12 17:48:47 jbeckett noship $           */
--Start of comments
--API name : Receipt API cover routine
--Type     : Public.
--Function : Create , apply, unapply and reverse Receipts
--Pre-reqs :
--
-- Notes : Note text
--
-- Modification History
-- Date         Name          Description
-- 20-MAY-2003  Jon Beckett   Created to ensure backward compatibility for Trade
--			      Management.  This version compatible with 11.5.10+
--			      AR installations.
-- End of comments


PROCEDURE Create_cash(
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
                 p_currency_code           IN  VARCHAR2 DEFAULT NULL,
                 p_usr_exchange_rate_type  IN  VARCHAR2 DEFAULT NULL,
                 p_exchange_rate_type      IN  VARCHAR2 DEFAULT NULL,
                 p_exchange_rate           IN  NUMBER   DEFAULT NULL,
                 p_exchange_rate_date      IN  DATE     DEFAULT NULL,
                 p_amount                  IN  NUMBER   DEFAULT NULL,
                 p_factor_discount_amount  IN  NUMBER   DEFAULT NULL,
                 p_receipt_number          IN  VARCHAR2 DEFAULT NULL,
                 p_receipt_date            IN  DATE     DEFAULT NULL,
                 p_gl_date                 IN  DATE     DEFAULT NULL,
                 p_maturity_date           IN  DATE     DEFAULT NULL,
                 p_postmark_date           IN  DATE     DEFAULT NULL,
                 p_customer_id             IN  NUMBER   DEFAULT NULL,
                 p_customer_name           IN  VARCHAR2 DEFAULT NULL,
                 p_customer_number         IN  VARCHAR2  DEFAULT NULL,
                 p_customer_bank_account_id IN NUMBER   DEFAULT NULL,
                 p_customer_bank_account_num   IN  VARCHAR2  DEFAULT NULL,
                 p_customer_bank_account_name  IN  VARCHAR2  DEFAULT NULL,
                 p_location                 IN  VARCHAR2 DEFAULT NULL,
                 p_customer_site_use_id     IN  NUMBER  DEFAULT NULL,
                 p_customer_receipt_reference IN  VARCHAR2  DEFAULT NULL,
                 p_override_remit_account_flag IN  VARCHAR2 DEFAULT NULL,
                 p_remittance_bank_account_id  IN  NUMBER  DEFAULT NULL,
                 p_remittance_bank_account_num  IN VARCHAR2 DEFAULT NULL,
                 p_remittance_bank_account_name IN VARCHAR2 DEFAULT NULL,
                 p_deposit_date             IN  DATE     DEFAULT NULL,
                 p_receipt_method_id        IN  NUMBER   DEFAULT NULL,
                 p_receipt_method_name      IN  VARCHAR2 DEFAULT NULL,
                 p_doc_sequence_value       IN  NUMBER   DEFAULT NULL,
                 p_ussgl_transaction_code   IN  VARCHAR2 DEFAULT NULL,
                 p_anticipated_clearing_date IN DATE     DEFAULT NULL,
                 p_called_from               IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
                 p_attribute_rec         IN  ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
                 p_comments             IN VARCHAR2 DEFAULT NULL,
      --   ***  Notes Receivable Additional Information  ***
                 p_issuer_name                  IN VARCHAR2  DEFAULT NULL,
                 p_issue_date                   IN DATE   DEFAULT NULL,
                 p_issuer_bank_branch_id        IN NUMBER  DEFAULT NULL,
      --   ** OUT NOCOPY variables
                 p_cr_id		  OUT NOCOPY NUMBER
                  );

PROCEDURE Apply(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
 --  Receipt application parameters.
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_customer_trx_id         IN ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL,
      p_trx_number              IN ra_customer_trx.trx_number%TYPE DEFAULT NULL,
      p_installment             IN ar_payment_schedules.terms_sequence_number%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      -- this is the allocated receipt amount
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL,
      p_trans_to_receipt_rate   IN ar_receivable_applications.trans_to_receipt_rate%TYPE DEFAULT NULL,
      p_discount                IN ar_receivable_applications.earned_discount_taken%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_customer_trx_line_id	  IN ar_receivable_applications.applied_customer_trx_line_id%TYPE DEFAULT NULL,
      p_line_number             IN ra_customer_trx_lines.line_number%TYPE DEFAULT NULL,
      p_show_closed_invoices    IN VARCHAR2 DEFAULT 'N', /* Bug fix 2462013 */
      p_called_from             IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
      p_move_deferred_tax       IN VARCHAR2 DEFAULT 'Y',
      p_link_to_trx_hist_id     IN ar_receivable_applications.link_to_trx_hist_id%TYPE DEFAULT NULL,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_payment_set_id          IN ar_receivable_applications.payment_set_id%TYPE DEFAULT NULL,
      p_application_ref_type         IN ar_receivable_applications.application_ref_type%TYPE DEFAULT NULL,
      p_application_ref_id           IN ar_receivable_applications.application_ref_id%TYPE DEFAULT NULL,
      p_application_ref_num          IN ar_receivable_applications.application_ref_num%TYPE DEFAULT NULL,
      p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL,
      p_application_ref_reason       IN ar_receivable_applications.application_ref_reason%TYPE DEFAULT NULL,
      p_customer_reference           IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
      p_customer_reason              IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL
	  );

PROCEDURE Unapply(
      -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
   -- *** Receipt Info. parameters *****
      p_receipt_number   IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id  IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_trx_number       IN  ra_customer_trx.trx_number%TYPE DEFAULT NULL,
      p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL,
      p_installment      IN  ar_payment_schedules.terms_sequence_number%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL,
      p_called_from      IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
      p_cancel_claim_flag      IN VARCHAR2 DEFAULT 'Y'
      );

    PROCEDURE Create_and_apply(
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
      p_amount                           IN  ar_cash_receipts.amount%TYPE DEFAULT NULL,
      p_factor_discount_amount           IN ar_cash_receipts.factor_discount_amount%TYPE DEFAULT NULL,
      p_receipt_number                   IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_receipt_date                     IN  ar_cash_receipts.receipt_date%TYPE DEFAULT NULL,
      p_gl_date                          IN  ar_cash_receipt_history.gl_date%TYPE DEFAULT NULL,
      p_maturity_date                    IN  DATE DEFAULT NULL,
      p_postmark_date                    IN  DATE DEFAULT NULL,
      p_customer_id                      IN  ar_cash_receipts.pay_from_customer%TYPE DEFAULT NULL,
      p_customer_name                    IN  hz_parties.party_name%TYPE DEFAULT NULL,
      p_customer_number                  IN  hz_cust_accounts.account_number%TYPE DEFAULT NULL,
      p_customer_bank_account_id         IN  ar_cash_receipts.customer_bank_account_id%TYPE DEFAULT NULL,
      p_customer_bank_account_num        IN  ap_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_customer_bank_account_name       IN  ap_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_location                         IN  hz_cust_site_uses.location%TYPE DEFAULT NULL,
      p_customer_site_use_id             IN  hz_cust_site_uses.site_use_id%TYPE DEFAULT NULL,
      p_customer_receipt_reference       IN  ar_cash_receipts.customer_receipt_reference%TYPE DEFAULT NULL,
      p_override_remit_account_flag      IN  ar_cash_receipts.override_remit_account_flag%TYPE DEFAULT NULL,
      p_remittance_bank_account_id       IN  ar_cash_receipts.remittance_bank_account_id%TYPE DEFAULT NULL,
      p_remittance_bank_account_num      IN  ap_bank_accounts.bank_account_num%TYPE DEFAULT NULL,
      p_remittance_bank_account_name     IN  ap_bank_accounts.bank_account_name%TYPE DEFAULT NULL,
      p_deposit_date                     IN  ar_cash_receipts.deposit_date%TYPE DEFAULT NULL,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE DEFAULT NULL,
      p_receipt_method_name              IN  ar_receipt_methods.name%TYPE DEFAULT NULL,
      p_doc_sequence_value               IN  NUMBER   DEFAULT NULL,
      p_ussgl_transaction_code           IN  ar_cash_receipts.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_anticipated_clearing_date        IN  ar_cash_receipts.anticipated_clearing_date%TYPE DEFAULT NULL,
      p_called_from                      IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
      p_attribute_rec                    IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
       -- ******* Global Flexfield parameters *******
      p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_receipt_comments      IN VARCHAR2 DEFAULT NULL,
     --   ***  Notes Receivable Additional Information  ***
      p_issuer_name           IN ar_cash_receipts.issuer_name%TYPE DEFAULT NULL,
      p_issue_date            IN ar_cash_receipts.issue_date%TYPE DEFAULT NULL,
      p_issuer_bank_branch_id IN ar_cash_receipts.issuer_bank_branch_id%TYPE DEFAULT NULL,
  --  ** OUT NOCOPY variables for Creating receipt
      p_cr_id		      OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
   -- Receipt application parameters
      p_customer_trx_id         IN ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL,
      p_trx_number              IN ra_customer_trx.trx_number%TYPE DEFAULT NULL,
      p_installment             IN ar_payment_schedules.terms_sequence_number%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      -- this is the allocated receipt amount
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL,
      p_trans_to_receipt_rate   IN ar_receivable_applications.trans_to_receipt_rate%TYPE DEFAULT NULL,
      p_discount                IN ar_receivable_applications.earned_discount_taken%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date           IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      app_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_customer_trx_line_id	  IN ar_receivable_applications.applied_customer_trx_line_id%TYPE DEFAULT NULL,
      p_line_number             IN ra_customer_trx_lines.line_number%TYPE DEFAULT NULL,
      p_show_closed_invoices    IN VARCHAR2 DEFAULT 'N', /* Bug fix 2462013 */
      p_move_deferred_tax       IN VARCHAR2 DEFAULT 'Y',
      p_link_to_trx_hist_id     IN ar_receivable_applications.link_to_trx_hist_id%TYPE DEFAULT NULL,
      app_attribute_rec           IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
  -- ******* Global Flexfield parameters *******
      app_global_attribute_rec    IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      app_comments                IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
  -- OSTEINME 3/9/2001: added flag that indicates whether to call payment
  -- processor such as iPayments
      p_call_payment_processor    IN VARCHAR2 DEFAULT FND_API.G_FALSE

      -- OUT NOCOPY parameter for the Application
      );

PROCEDURE Reverse(
-- Standard API parameters.
      p_api_version             IN  NUMBER,
      p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
-- Receipt reversal related parameters
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_reversal_category_code  IN ar_cash_receipts.reversal_category%TYPE DEFAULT NULL,
      p_reversal_category_name  IN ar_lookups.meaning%TYPE DEFAULT NULL,
      p_reversal_gl_date        IN ar_cash_receipt_history.reversal_gl_date%TYPE DEFAULT NULL,
      p_reversal_date           IN ar_cash_receipts.reversal_date%TYPE DEFAULT NULL,
      p_reversal_reason_code    IN ar_cash_receipts.reversal_reason_code%TYPE DEFAULT NULL,
      p_reversal_reason_name    IN ar_lookups.meaning%TYPE DEFAULT NULL,
      p_reversal_comments       IN ar_cash_receipts.reversal_comments%TYPE DEFAULT NULL,
      p_called_from             IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
      p_attribute_rec           IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
      --p_global_attribute_rec    IN ar_receipt_api_pub.global_attribute_rec_type_upd DEFAULT ar_receipt_api_pub.global_attribute_rec_upd_cons
      p_global_attribute_rec    IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const  ,
      p_cancel_claims_flag      IN VARCHAR2 DEFAULT 'Y'
       );

PROCEDURE Apply_on_account(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
  --  Receipt application parameters.
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_application_ref_num IN ar_receivable_applications.application_ref_num%TYPE DEFAULT NULL,
      p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL,
      p_customer_reference IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
      p_called_from IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT'
	  );

PROCEDURE Unapply_on_account(
    -- Standard API parameters.
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status             OUT NOCOPY VARCHAR2 ,
      x_msg_count                 OUT NOCOPY NUMBER ,
      x_msg_data                  OUT NOCOPY VARCHAR2 ,
   -- *** Receipt Info. parameters *****
      p_receipt_number            IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id           IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_reversal_gl_date          IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL
      );

PROCEDURE Activity_application(
    -- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
    -- Receipt application parameters.
      p_cash_receipt_id              IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number               IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE, --this has no default
      p_link_to_customer_trx_id	     IN ra_customer_trx.customer_trx_id%TYPE DEFAULT NULL,
      p_receivables_trx_id           IN ar_receivable_applications.receivables_trx_id%TYPE, --this has no default
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code       IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_attribute_rec                IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                     IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_application_ref_type IN OUT NOCOPY
                ar_receivable_applications.application_ref_type%TYPE,
      p_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
      p_application_ref_num IN OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
      p_secondary_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.secondary_application_ref_id%TYPE,
      p_payment_set_id IN ar_receivable_applications.payment_set_id%TYPE DEFAULT NULL,
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_customer_reference IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
      p_val_writeoff_limits_flag    IN VARCHAR2 DEFAULT 'Y',
      p_called_from		    IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT'
      );

PROCEDURE Activity_unapplication(
    -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
   -- *** Receipt Info. parameters *****
      p_receipt_number   IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id  IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL,
      p_called_from      IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT'
      );

PROCEDURE Apply_other_account(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
  --  Receipt application parameters.
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_receivables_trx_id      IN ar_receivable_applications.receivables_trx_id%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id      IN ar_receivable_applications.applied_payment_schedule_id%TYPE DEFAULT NULL,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_application_ref_type IN ar_receivable_applications.application_ref_type%TYPE DEFAULT NULL,
      p_application_ref_id   IN OUT NOCOPY ar_receivable_applications.application_ref_id%TYPE ,
      p_application_ref_num  IN OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE ,
      p_secondary_application_ref_id IN OUT NOCOPY ar_receivable_applications.secondary_application_ref_id%TYPE ,
      p_payment_set_id               IN ar_receivable_applications.payment_set_id%TYPE DEFAULT NULL,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
         -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      p_application_ref_reason  IN ar_receivable_applications.application_ref_reason%TYPE DEFAULT NULL,
      p_customer_reference      IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
      p_customer_reason         IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL,
      p_called_from		IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT'
          );

PROCEDURE Unapply_other_account(
    -- Standard API parameters.
      p_api_version               IN  NUMBER,
      p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status             OUT NOCOPY VARCHAR2 ,
      x_msg_count                 OUT NOCOPY NUMBER ,
      x_msg_data                  OUT NOCOPY VARCHAR2 ,
   -- *** Receipt Info. parameters *****
      p_receipt_number            IN  ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_cash_receipt_id           IN  ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receivable_application_id IN  ar_receivable_applications.receivable_application_id%TYPE,
      p_reversal_gl_date          IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL,
      p_cancel_claim_flag         IN  VARCHAR2 DEFAULT 'Y',
      p_called_from		  IN  VARCHAR2 DEFAULT 'TRADE_MANAGEMENT'
      );

PROCEDURE create_misc(
    -- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status                OUT NOCOPY VARCHAR2 ,
      x_msg_count                    OUT NOCOPY NUMBER ,
      x_msg_data                     OUT NOCOPY VARCHAR2 ,
    -- Misc Receipt info. parameters
      p_usr_currency_code            IN  VARCHAR2 DEFAULT NULL, --the translated currency code
      p_currency_code                IN  VARCHAR2 DEFAULT NULL,
      p_usr_exchange_rate_type       IN  VARCHAR2 DEFAULT NULL,
      p_exchange_rate_type           IN  VARCHAR2 DEFAULT NULL,
      p_exchange_rate                IN  NUMBER   DEFAULT NULL,
      p_exchange_rate_date           IN  DATE     DEFAULT NULL,
      p_amount                       IN  NUMBER,
      p_receipt_number               IN  OUT NOCOPY VARCHAR2,
      p_receipt_date                 IN  DATE     DEFAULT NULL,
      p_gl_date                      IN  DATE     DEFAULT NULL,
      p_receivables_trx_id           IN  NUMBER   DEFAULT NULL,
      p_activity                     IN  VARCHAR2 DEFAULT NULL,
      p_misc_payment_source          IN  VARCHAR2 DEFAULT NULL,
      p_tax_code                     IN  VARCHAR2 DEFAULT NULL,
      p_vat_tax_id                   IN  VARCHAR2 DEFAULT NULL,
      p_tax_rate                     IN  NUMBER   DEFAULT NULL,
      p_tax_amount                   IN  NUMBER   DEFAULT NULL,
      p_deposit_date                 IN  DATE     DEFAULT NULL,
      p_reference_type               IN  VARCHAR2 DEFAULT NULL,
      p_reference_num                IN  VARCHAR2 DEFAULT NULL,
      p_reference_id                 IN  NUMBER   DEFAULT NULL,
      p_remittance_bank_account_id   IN  NUMBER   DEFAULT NULL,
      p_remittance_bank_account_num  IN  VARCHAR2 DEFAULT NULL,
      p_remittance_bank_account_name IN  VARCHAR2 DEFAULT NULL,
      p_receipt_method_id            IN  NUMBER   DEFAULT NULL,
      p_receipt_method_name          IN  VARCHAR2 DEFAULT NULL,
      p_doc_sequence_value           IN  NUMBER   DEFAULT NULL,
      p_ussgl_transaction_code       IN  VARCHAR2 DEFAULT NULL,
      p_anticipated_clearing_date    IN  DATE     DEFAULT NULL,
      p_attribute_record             IN  ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
      p_global_attribute_record      IN  ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                     IN  VARCHAR2 DEFAULT NULL,
      p_misc_receipt_id              OUT NOCOPY NUMBER);

PROCEDURE Apply_Open_Receipt(
-- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_validation_level             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
 --  Receipt application parameters.
      p_cash_receipt_id              IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_receipt_number               IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE DEFAULT NULL,
      p_open_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL,
      p_open_receipt_number          IN ar_cash_receipts.receipt_number%TYPE DEFAULT NULL,
      p_open_rec_app_id              IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL,
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE DEFAULT NULL,
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
      p_called_from                  IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT',
      p_attribute_rec                IN ar_receipt_api_pub.attribute_rec_type DEFAULT ar_receipt_api_pub.attribute_rec_const,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
      p_comments                     IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
      x_application_ref_num          OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE,
      x_receivable_application_id    OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      x_applied_rec_app_id           OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE
);

PROCEDURE Unapply_Open_Receipt(
    -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
      p_validation_level IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
      p_receivable_application_id   IN  ar_receivable_applications.receivable_application_id%TYPE,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE DEFAULT NULL,
      p_called_from                  IN VARCHAR2 DEFAULT 'TRADE_MANAGEMENT');

END AR_RECEIPT_API_COVER;

 

/
