--------------------------------------------------------
--  DDL for Package Body AR_RECEIPT_API_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RECEIPT_API_COVER" AS
/* $Header: ARXRCCVB.pls 120.2 2003/08/12 17:48:56 jbeckett noship $           */
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
--			      Management. This version compatible with 11.5.10+
--			      AR installations.
-- End of comments


PROCEDURE Create_cash(
           -- Standard API parameters.
                 p_api_version      IN  NUMBER,
                 p_init_msg_list    IN  VARCHAR2,
                 p_commit           IN  VARCHAR2,
                 p_validation_level IN  NUMBER,
                 x_return_status    OUT NOCOPY VARCHAR2,
                 x_msg_count        OUT NOCOPY NUMBER,
                 x_msg_data         OUT NOCOPY VARCHAR2,
                 -- Receipt info. parameters
                 p_usr_currency_code       IN  VARCHAR2, --the translated currency code
                 p_currency_code           IN  VARCHAR2,
                 p_usr_exchange_rate_type  IN  VARCHAR2,
                 p_exchange_rate_type      IN  VARCHAR2,
                 p_exchange_rate           IN  NUMBER  ,
                 p_exchange_rate_date      IN  DATE    ,
                 p_amount                  IN  NUMBER  ,
                 p_factor_discount_amount  IN  NUMBER  ,
                 p_receipt_number          IN  VARCHAR2,
                 p_receipt_date            IN  DATE    ,
                 p_gl_date                 IN  DATE    ,
                 p_maturity_date           IN  DATE    ,
                 p_postmark_date           IN  DATE    ,
                 p_customer_id             IN  NUMBER  ,
                 p_customer_name           IN  VARCHAR2,
                 p_customer_number         IN  VARCHAR2,
                 p_customer_bank_account_id IN NUMBER  ,
                 p_customer_bank_account_num   IN  VARCHAR2,
                 p_customer_bank_account_name  IN  VARCHAR2,
                 p_location                 IN  VARCHAR2,
                 p_customer_site_use_id     IN  NUMBER  ,
                 p_customer_receipt_reference IN  VARCHAR2,
                 p_override_remit_account_flag IN  VARCHAR2,
                 p_remittance_bank_account_id  IN  NUMBER  ,
                 p_remittance_bank_account_num  IN VARCHAR2,
                 p_remittance_bank_account_name IN VARCHAR2,
                 p_deposit_date             IN  DATE     ,
                 p_receipt_method_id        IN  NUMBER   ,
                 p_receipt_method_name      IN  VARCHAR2 ,
                 p_doc_sequence_value       IN  NUMBER   ,
                 p_ussgl_transaction_code   IN  VARCHAR2 ,
                 p_anticipated_clearing_date IN DATE     ,
                 p_called_from               IN VARCHAR2 ,
                 p_attribute_rec         IN  ar_receipt_api_pub.attribute_rec_type ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type,
                 p_comments             IN VARCHAR2 ,
      --   ***  Notes Receivable Additional Information  ***
                 p_issuer_name                  IN VARCHAR2,
                 p_issue_date                   IN DATE  ,
                 p_issuer_bank_branch_id        IN NUMBER,
      --   ** OUT NOCOPY variables
                 p_cr_id		  OUT NOCOPY NUMBER
                  )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Create_cash(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_usr_currency_code       =>  p_usr_currency_code, --the translated currency code
                 p_currency_code           =>  p_currency_code ,
                 p_usr_exchange_rate_type  => p_usr_exchange_rate_type ,
                 p_exchange_rate_type      => p_exchange_rate_type       ,
                 p_exchange_rate           => p_exchange_rate ,
                 p_exchange_rate_date      => p_exchange_rate_date ,
                 p_amount                  =>  p_amount,
                 p_factor_discount_amount  =>  p_factor_discount_amount  ,
                 p_receipt_number          =>  p_receipt_number,
                 p_receipt_date            =>  p_receipt_date,
                 p_gl_date                 =>  p_gl_date,
                 p_maturity_date           =>  p_maturity_date           ,
                 p_postmark_date           =>  p_postmark_date           ,
                 p_customer_id             =>  p_customer_id             ,
                 p_customer_name	   =>  p_customer_name,
                 p_customer_number         =>  p_customer_number         ,
                 p_customer_bank_account_id => p_customer_bank_account_id,
                 p_customer_bank_account_num   => p_customer_bank_account_num   ,
                 p_customer_bank_account_name  => p_customer_bank_account_name   ,
                 p_location                 =>  p_location                 ,
                 p_customer_site_use_id     => p_customer_site_use_id      ,
                 p_customer_receipt_reference =>  p_customer_receipt_reference ,
                 p_override_remit_account_flag => p_override_remit_account_flag  ,
                 p_remittance_bank_account_id  => p_remittance_bank_account_id   ,
                 p_remittance_bank_account_num  => p_remittance_bank_account_num  ,
                 p_remittance_bank_account_name =>  p_remittance_bank_account_name ,
                 p_deposit_date             =>  p_deposit_date             ,
                 p_receipt_method_id        =>  p_receipt_method_id        ,
                 p_receipt_method_name      =>  p_receipt_method_name      ,
                 p_doc_sequence_value       =>  p_doc_sequence_value       ,
                 p_ussgl_transaction_code   =>  p_ussgl_transaction_code   ,
                 p_anticipated_clearing_date => p_anticipated_clearing_date ,
                 p_called_from               => p_called_from               ,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
      --   ***  Notes Receivable Additional Information  ***
                 p_issuer_name                  => p_issuer_name                  ,
                 p_issue_date                   => p_issue_date                   ,
                 p_issuer_bank_branch_id        => p_issuer_bank_branch_id        ,
      --   ** OUT NOCOPY variables
                 p_cr_id		  => p_cr_id
                  ) ;
END Create_Cash;

PROCEDURE Apply(
-- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2,
      p_commit           IN  VARCHAR2,
      p_validation_level IN  NUMBER  ,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
 --  Receipt application parameters.
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE ,
      p_customer_trx_id         IN ra_customer_trx.customer_trx_id%TYPE ,
      p_trx_number              IN ra_customer_trx.trx_number%TYPE ,
      p_installment             IN ar_payment_schedules.terms_sequence_number%TYPE ,
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE ,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE ,
      -- this is the allocated receipt amount
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE ,
      p_trans_to_receipt_rate   IN ar_receivable_applications.trans_to_receipt_rate%TYPE ,
      p_discount                IN ar_receivable_applications.earned_discount_taken%TYPE ,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE ,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_customer_trx_line_id	  IN ar_receivable_applications.applied_customer_trx_line_id%TYPE ,
      p_line_number             IN ra_customer_trx_lines.line_number%TYPE ,
      p_show_closed_invoices    IN VARCHAR2 , /* Bug fix 2462013 */
      p_called_from             IN VARCHAR2 ,
      p_move_deferred_tax       IN VARCHAR2 ,
      p_link_to_trx_hist_id     IN ar_receivable_applications.link_to_trx_hist_id%TYPE ,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type ,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                IN ar_receivable_applications.comments%TYPE ,
      p_payment_set_id          IN ar_receivable_applications.payment_set_id%TYPE ,
      p_application_ref_type         IN ar_receivable_applications.application_ref_type%TYPE ,
      p_application_ref_id           IN ar_receivable_applications.application_ref_id%TYPE ,
      p_application_ref_num          IN ar_receivable_applications.application_ref_num%TYPE ,
      p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE ,
      p_application_ref_reason       IN ar_receivable_applications.application_ref_reason%TYPE ,
      p_customer_reference           IN ar_receivable_applications.customer_reference%TYPE ,
      p_customer_reason              IN ar_receivable_applications.customer_reason%TYPE
	  )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Apply(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
                 p_customer_trx_id         =>  p_customer_trx_id,
                 p_trx_number              =>  p_trx_number    ,
      		 p_installment             => p_installment             ,
      		 p_applied_payment_schedule_id =>    p_applied_payment_schedule_id     ,
		 p_amount_applied          => p_amount_applied          ,
      -- this is the allocated receipt amount
	         p_amount_applied_from     =>p_amount_applied_from     ,
	         p_trans_to_receipt_rate   => p_trans_to_receipt_rate   ,
	         p_discount                => p_discount                ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         p_ussgl_transaction_code  => p_ussgl_transaction_code  ,
	         p_customer_trx_line_id	=> p_customer_trx_line_id	,
	         p_line_number             => p_line_number             ,
	         p_show_closed_invoices    => p_show_closed_invoices    , /* Bug fix 2462013 */
                 p_called_from               => p_called_from               ,
	         p_move_deferred_tax       => p_move_deferred_tax       ,
	         p_link_to_trx_hist_id     => p_link_to_trx_hist_id,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
	         p_payment_set_id	=> p_payment_set_id,
	         p_application_ref_type => p_application_ref_type,
	         p_application_ref_id => p_application_ref_id,
	         p_application_ref_num => p_application_ref_num,
	         p_secondary_application_ref_id => p_secondary_application_ref_id,
	         p_application_ref_reason => p_application_ref_reason,
	         p_customer_reference => p_customer_reference,
	         p_customer_reason => p_customer_reason
                  ) ;
END Apply;

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
      p_receipt_number   IN  ar_cash_receipts.receipt_number%TYPE ,
      p_cash_receipt_id  IN  ar_cash_receipts.cash_receipt_id%TYPE ,
      p_trx_number       IN  ra_customer_trx.trx_number%TYPE ,
      p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE ,
      p_installment      IN  ar_payment_schedules.terms_sequence_number%TYPE ,
      p_applied_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE ,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE ,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE ,
      p_called_from      IN VARCHAR2 ,
      p_cancel_claim_flag      IN VARCHAR2
	  )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Unapply(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_receipt_number          =>  p_receipt_number,
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_trx_number              =>  p_trx_number    ,
                 p_customer_trx_id         =>  p_customer_trx_id,
      		 p_installment             => p_installment             ,
      		 p_applied_payment_schedule_id =>    p_applied_payment_schedule_id     ,
	         p_receivable_application_id => p_receivable_application_id,
	         p_reversal_gl_date          => p_reversal_gl_date,
                 p_called_from               => p_called_from,
                 p_cancel_claim_flag         => p_cancel_claim_flag
      );
END Unapply;

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
      p_usr_currency_code       IN  VARCHAR2 , --the translated currency code
      p_currency_code      IN  ar_cash_receipts.currency_code%TYPE ,
      p_usr_exchange_rate_type  IN  VARCHAR2 ,
      p_exchange_rate_type IN  ar_cash_receipts.exchange_rate_type%TYPE ,
      p_exchange_rate      IN  ar_cash_receipts.exchange_rate%TYPE ,
      p_exchange_rate_date IN  ar_cash_receipts.exchange_date%TYPE ,
      p_amount                           IN  ar_cash_receipts.amount%TYPE ,
      p_factor_discount_amount           IN ar_cash_receipts.factor_discount_amount%TYPE ,
      p_receipt_number                   IN  ar_cash_receipts.receipt_number%TYPE ,
      p_receipt_date                     IN  ar_cash_receipts.receipt_date%TYPE ,
      p_gl_date                          IN  ar_cash_receipt_history.gl_date%TYPE ,
      p_maturity_date                    IN  DATE ,
      p_postmark_date                    IN  DATE ,
      p_customer_id                      IN  ar_cash_receipts.pay_from_customer%TYPE ,
      p_customer_name                    IN  hz_parties.party_name%TYPE ,
      p_customer_number                  IN  hz_cust_accounts.account_number%TYPE ,
      p_customer_bank_account_id         IN  ar_cash_receipts.customer_bank_account_id%TYPE ,
      p_customer_bank_account_num        IN  ap_bank_accounts.bank_account_num%TYPE ,
      p_customer_bank_account_name       IN  ap_bank_accounts.bank_account_name%TYPE ,
      p_location                         IN  hz_cust_site_uses.location%TYPE ,
      p_customer_site_use_id             IN  hz_cust_site_uses.site_use_id%TYPE ,
      p_customer_receipt_reference       IN  ar_cash_receipts.customer_receipt_reference%TYPE ,
      p_override_remit_account_flag      IN  ar_cash_receipts.override_remit_account_flag%TYPE ,
      p_remittance_bank_account_id       IN  ar_cash_receipts.remittance_bank_account_id%TYPE ,
      p_remittance_bank_account_num      IN  ap_bank_accounts.bank_account_num%TYPE ,
      p_remittance_bank_account_name     IN  ap_bank_accounts.bank_account_name%TYPE ,
      p_deposit_date                     IN  ar_cash_receipts.deposit_date%TYPE ,
      p_receipt_method_id                IN  ar_cash_receipts.receipt_method_id%TYPE ,
      p_receipt_method_name              IN  ar_receipt_methods.name%TYPE ,
      p_doc_sequence_value               IN  NUMBER   ,
      p_ussgl_transaction_code           IN  ar_cash_receipts.ussgl_transaction_code%TYPE ,
      p_anticipated_clearing_date        IN  ar_cash_receipts.anticipated_clearing_date%TYPE ,
      p_called_from                      IN VARCHAR2 ,
      p_attribute_rec                    IN ar_receipt_api_pub.attribute_rec_type ,
       -- ******* Global Flexfield parameters *******
      p_global_attribute_rec  IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_receipt_comments      IN VARCHAR2 ,
     --   ***  Notes Receivable Additional Information  ***
      p_issuer_name           IN ar_cash_receipts.issuer_name%TYPE ,
      p_issue_date            IN ar_cash_receipts.issue_date%TYPE ,
      p_issuer_bank_branch_id IN ar_cash_receipts.issuer_bank_branch_id%TYPE ,
  --  ** OUT NOCOPY variables for Creating receipt
      p_cr_id		      OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
   -- Receipt application parameters
      p_customer_trx_id         IN ra_customer_trx.customer_trx_id%TYPE ,
      p_trx_number              IN ra_customer_trx.trx_number%TYPE ,
      p_installment             IN ar_payment_schedules.terms_sequence_number%TYPE ,
      p_applied_payment_schedule_id     IN ar_payment_schedules.payment_schedule_id%TYPE ,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE ,
      -- this is the allocated receipt amount
      p_amount_applied_from     IN ar_receivable_applications.amount_applied_from%TYPE ,
      p_trans_to_receipt_rate   IN ar_receivable_applications.trans_to_receipt_rate%TYPE ,
      p_discount                IN ar_receivable_applications.earned_discount_taken%TYPE ,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date           IN ar_receivable_applications.gl_date%TYPE ,
      app_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_customer_trx_line_id	  IN ar_receivable_applications.applied_customer_trx_line_id%TYPE ,
      p_line_number             IN ra_customer_trx_lines.line_number%TYPE ,
      p_show_closed_invoices    IN VARCHAR2 , /* Bug fix 2462013 */
      p_move_deferred_tax       IN VARCHAR2 ,
      p_link_to_trx_hist_id     IN ar_receivable_applications.link_to_trx_hist_id%TYPE ,
      app_attribute_rec           IN ar_receipt_api_pub.attribute_rec_type ,
  -- ******* Global Flexfield parameters *******
      app_global_attribute_rec    IN ar_receipt_api_pub.global_attribute_rec_type ,
      app_comments                IN ar_receivable_applications.comments%TYPE ,
  -- OSTEINME 3/9/2001: added flag that indicates whether to call payment
  -- processor such as iPayments
      p_call_payment_processor    IN VARCHAR2

      -- OUT NOCOPY parameter for the Application
      )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Create_and_apply(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_usr_currency_code       =>  p_usr_currency_code, --the translated currency code
                 p_currency_code           =>  p_currency_code ,
                 p_usr_exchange_rate_type  => p_usr_exchange_rate_type ,
                 p_exchange_rate_type      => p_exchange_rate_type       ,
                 p_exchange_rate           => p_exchange_rate ,
                 p_exchange_rate_date      => p_exchange_rate_date ,
                 p_amount                  =>  p_amount,
                 p_factor_discount_amount  =>  p_factor_discount_amount  ,
                 p_receipt_number          =>  p_receipt_number,
                 p_receipt_date            =>  p_receipt_date,
                 p_gl_date                 =>  p_gl_date,
                 p_maturity_date           =>  p_maturity_date           ,
                 p_postmark_date           =>  p_postmark_date           ,
                 p_customer_id             =>  p_customer_id             ,
                 p_customer_name	   =>  p_customer_name,
                 p_customer_number         =>  p_customer_number         ,
                 p_customer_bank_account_id => p_customer_bank_account_id,
                 p_customer_bank_account_num   => p_customer_bank_account_num   ,
                 p_customer_bank_account_name  => p_customer_bank_account_name   ,
                 p_location                 =>  p_location                 ,
                 p_customer_site_use_id     => p_customer_site_use_id      ,
                 p_customer_receipt_reference =>  p_customer_receipt_reference ,
                 p_override_remit_account_flag => p_override_remit_account_flag  ,
                 p_remittance_bank_account_id  => p_remittance_bank_account_id   ,
                 p_remittance_bank_account_num  => p_remittance_bank_account_num  ,
                 p_remittance_bank_account_name =>  p_remittance_bank_account_name ,
                 p_deposit_date             =>  p_deposit_date             ,
                 p_receipt_method_id        =>  p_receipt_method_id        ,
                 p_receipt_method_name      =>  p_receipt_method_name      ,
                 p_doc_sequence_value       =>  p_doc_sequence_value       ,
                 p_ussgl_transaction_code   =>  p_ussgl_transaction_code   ,
                 p_anticipated_clearing_date => p_anticipated_clearing_date ,
                 p_called_from               => p_called_from               ,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_receipt_comments             => p_receipt_comments,
      --   ***  Notes Receivable Additional Information  ***
                 p_issuer_name                  => p_issuer_name                  ,
                 p_issue_date                   => p_issue_date                   ,
                 p_issuer_bank_branch_id        => p_issuer_bank_branch_id        ,
      --   ** OUT NOCOPY variables
                 p_cr_id		  => p_cr_id,
                 p_customer_trx_id         =>  p_customer_trx_id,
                 p_trx_number              =>  p_trx_number    ,
      		 p_installment             => p_installment             ,
      		 p_applied_payment_schedule_id =>    p_applied_payment_schedule_id     ,
		 p_amount_applied          => p_amount_applied          ,
      -- this is the allocated receipt amount
	         p_amount_applied_from     =>p_amount_applied_from     ,
	         p_trans_to_receipt_rate   => p_trans_to_receipt_rate   ,
	         p_discount                => p_discount                ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         app_ussgl_transaction_code  => app_ussgl_transaction_code  ,
	         p_customer_trx_line_id	=> p_customer_trx_line_id	,
	         p_line_number             => p_line_number             ,
	         p_show_closed_invoices    => p_show_closed_invoices    , /* Bug fix 2462013 */
	         p_move_deferred_tax       => p_move_deferred_tax       ,
	         p_link_to_trx_hist_id     => p_link_to_trx_hist_id,
                 app_attribute_rec         =>  app_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 app_global_attribute_rec  => app_global_attribute_rec  ,
                 app_comments              => app_comments             ,
		 p_call_payment_processor  => p_call_payment_processor) ;
END Create_and_apply;


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
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE ,
      p_reversal_category_code  IN ar_cash_receipts.reversal_category%TYPE ,
      p_reversal_category_name  IN ar_lookups.meaning%TYPE ,
      p_reversal_gl_date        IN ar_cash_receipt_history.reversal_gl_date%TYPE ,
      p_reversal_date           IN ar_cash_receipts.reversal_date%TYPE ,
      p_reversal_reason_code    IN ar_cash_receipts.reversal_reason_code%TYPE ,
      p_reversal_reason_name    IN ar_lookups.meaning%TYPE ,
      p_reversal_comments       IN ar_cash_receipts.reversal_comments%TYPE ,
      p_called_from             IN VARCHAR2 ,
      p_attribute_rec           IN ar_receipt_api_pub.attribute_rec_type ,
      p_global_attribute_rec    IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_cancel_claims_flag      IN VARCHAR2
       )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Reverse(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
	         p_reversal_category_code  => p_reversal_category_code,
	         p_reversal_category_name  =>  p_reversal_category_name,
	         p_reversal_gl_date          => p_reversal_gl_date,
	         p_reversal_date           => p_reversal_date,
	         p_reversal_reason_code    => p_reversal_reason_code,
	         p_reversal_reason_name    => p_reversal_reason_name,
	         p_reversal_comments       => p_reversal_comments,
                 p_called_from               => p_called_from,
                 p_attribute_rec         =>  p_attribute_rec         ,
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_cancel_claims_flag         => p_cancel_claims_flag
      );
END Reverse;

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
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE ,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE ,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE ,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type ,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                IN ar_receivable_applications.comments%TYPE ,
      p_application_ref_num IN ar_receivable_applications.application_ref_num%TYPE ,
      p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE ,
      p_customer_reference IN ar_receivable_applications.customer_reference%TYPE ,
      p_called_from IN VARCHAR2
	  )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Apply_on_account(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
		 p_amount_applied          => p_amount_applied          ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         p_ussgl_transaction_code  => p_ussgl_transaction_code  ,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
	         p_application_ref_num => p_application_ref_num,
	         p_secondary_application_ref_id => p_secondary_application_ref_id,
	         p_customer_reference => p_customer_reference,
                 p_called_from               => p_called_from
                  ) ;
END Apply_on_account;

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
      p_receipt_number            IN  ar_cash_receipts.receipt_number%TYPE ,
      p_cash_receipt_id           IN  ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receivable_application_id IN ar_receivable_applications.receivable_application_id%TYPE ,
      p_reversal_gl_date          IN ar_receivable_applications.reversal_gl_date%TYPE
      )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Unapply_on_account(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_receipt_number          =>  p_receipt_number,
		 p_cash_receipt_id         => p_cash_receipt_id,
	         p_receivable_application_id => p_receivable_application_id,
	         p_reversal_gl_date          => p_reversal_gl_date
      );
END Unapply_on_account;

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
      p_cash_receipt_id              IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receipt_number               IN ar_cash_receipts.receipt_number%TYPE ,
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE ,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE, --this has no default
      p_link_to_customer_trx_id	     IN ra_customer_trx.customer_trx_id%TYPE ,
      p_receivables_trx_id           IN ar_receivable_applications.receivables_trx_id%TYPE, --this has no default
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE ,
      p_ussgl_transaction_code       IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_attribute_rec                IN ar_receipt_api_pub.attribute_rec_type ,
    -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                     IN ar_receivable_applications.comments%TYPE ,
      p_application_ref_type IN OUT NOCOPY
                ar_receivable_applications.application_ref_type%TYPE,
      p_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
      p_application_ref_num IN OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
      p_secondary_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.secondary_application_ref_id%TYPE,
      p_payment_set_id IN ar_receivable_applications.payment_set_id%TYPE ,
      p_receivable_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      p_customer_reference IN ar_receivable_applications.customer_reference%TYPE ,
      p_val_writeoff_limits_flag    IN VARCHAR2 ,
      p_called_from		    IN VARCHAR2
      )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Activity_application(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
		 p_amount_applied          => p_amount_applied          ,
		 p_applied_payment_schedule_id => p_applied_payment_schedule_id          ,
		 p_link_to_customer_trx_id => p_link_to_customer_trx_id          ,
		 p_receivables_trx_id      => p_receivables_trx_id          ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         p_ussgl_transaction_code  => p_ussgl_transaction_code  ,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
	         p_application_ref_type => p_application_ref_type,
	         p_application_ref_id => p_application_ref_id,
	         p_application_ref_num => p_application_ref_num,
	         p_secondary_application_ref_id => p_secondary_application_ref_id,
	         p_payment_set_id => p_payment_set_id,
	         p_receivable_application_id => p_receivable_application_id,
	         p_customer_reference => p_customer_reference,
	         p_val_writeoff_limits_flag => p_val_writeoff_limits_flag,
                 p_called_from               => p_called_from
                  ) ;
END Activity_application;

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
      p_receipt_number   IN  ar_cash_receipts.receipt_number%TYPE ,
      p_cash_receipt_id  IN  ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receivable_application_id   IN ar_receivable_applications.receivable_application_id%TYPE ,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE ,
      p_called_from      IN VARCHAR2
      )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Activity_Unapplication(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_receipt_number          =>  p_receipt_number,
		 p_cash_receipt_id         => p_cash_receipt_id,
	         p_receivable_application_id => p_receivable_application_id,
	         p_reversal_gl_date          => p_reversal_gl_date,
	         p_called_from          => p_called_from
      );
END Activity_Unapplication;

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
      p_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receipt_number          IN ar_cash_receipts.receipt_number%TYPE ,
      p_amount_applied          IN ar_receivable_applications.amount_applied%TYPE ,
      p_receivables_trx_id      IN ar_receivable_applications.receivables_trx_id%TYPE ,
      p_applied_payment_schedule_id      IN ar_receivable_applications.applied_payment_schedule_id%TYPE ,
      p_apply_date              IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date                 IN ar_receivable_applications.gl_date%TYPE ,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_application_ref_type IN ar_receivable_applications.application_ref_type%TYPE ,
      p_application_ref_id   IN OUT NOCOPY ar_receivable_applications.application_ref_id%TYPE ,
      p_application_ref_num  IN OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE ,
      p_secondary_application_ref_id IN OUT NOCOPY ar_receivable_applications.secondary_application_ref_id%TYPE ,
      p_payment_set_id               IN ar_receivable_applications.payment_set_id%TYPE ,
      p_attribute_rec      IN ar_receipt_api_pub.attribute_rec_type ,
         -- ******* Global Flexfield parameters *******
      p_global_attribute_rec IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                IN ar_receivable_applications.comments%TYPE ,
      p_application_ref_reason  IN ar_receivable_applications.application_ref_reason%TYPE ,
      p_customer_reference      IN ar_receivable_applications.customer_reference%TYPE ,
      p_customer_reason         IN ar_receivable_applications.customer_reason%TYPE ,
      p_called_from		IN VARCHAR2
          )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Apply_other_account(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
		 p_receivable_application_id => p_receivable_application_id,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
		 p_amount_applied          => p_amount_applied          ,
		 p_receivables_trx_id      => p_receivables_trx_id          ,
		 p_applied_payment_schedule_id => p_applied_payment_schedule_id          ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         p_ussgl_transaction_code  => p_ussgl_transaction_code  ,
	         p_application_ref_type => p_application_ref_type,
	         p_application_ref_id => p_application_ref_id,
	         p_application_ref_num => p_application_ref_num,
	         p_secondary_application_ref_id => p_secondary_application_ref_id,
	         p_payment_set_id => p_payment_set_id,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
	         p_application_ref_reason => p_application_ref_reason,
	         p_customer_reference     => p_customer_reference,
	         p_customer_reason        => p_customer_reason,
                 p_called_from            => p_called_from
                  ) ;
END Apply_other_account;

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
      p_receipt_number            IN  ar_cash_receipts.receipt_number%TYPE ,
      p_cash_receipt_id           IN  ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receivable_application_id IN  ar_receivable_applications.receivable_application_id%TYPE,
      p_reversal_gl_date          IN ar_receivable_applications.reversal_gl_date%TYPE ,
      p_cancel_claim_flag         IN  VARCHAR2 ,
      p_called_from		  IN  VARCHAR2
      )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Unapply_other_account(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_receipt_number          =>  p_receipt_number,
		 p_cash_receipt_id         => p_cash_receipt_id,
	         p_receivable_application_id => p_receivable_application_id,
	         p_reversal_gl_date        => p_reversal_gl_date,
	         p_cancel_claim_flag       => p_cancel_claim_flag,
	         p_called_from             => p_called_from
      );
END Unapply_other_account;

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
      p_usr_currency_code            IN  VARCHAR2 , --the translated currency code
      p_currency_code                IN  VARCHAR2 ,
      p_usr_exchange_rate_type       IN  VARCHAR2 ,
      p_exchange_rate_type           IN  VARCHAR2 ,
      p_exchange_rate                IN  NUMBER   ,
      p_exchange_rate_date           IN  DATE     ,
      p_amount                       IN  NUMBER,
      p_receipt_number               IN  OUT NOCOPY VARCHAR2,
      p_receipt_date                 IN  DATE     ,
      p_gl_date                      IN  DATE     ,
      p_receivables_trx_id           IN  NUMBER   ,
      p_activity                     IN  VARCHAR2 ,
      p_misc_payment_source          IN  VARCHAR2 ,
      p_tax_code                     IN  VARCHAR2 ,
      p_vat_tax_id                   IN  VARCHAR2 ,
      p_tax_rate                     IN  NUMBER   ,
      p_tax_amount                   IN  NUMBER   ,
      p_deposit_date                 IN  DATE     ,
      p_reference_type               IN  VARCHAR2 ,
      p_reference_num                IN  VARCHAR2 ,
      p_reference_id                 IN  NUMBER   ,
      p_remittance_bank_account_id   IN  NUMBER   ,
      p_remittance_bank_account_num  IN  VARCHAR2 ,
      p_remittance_bank_account_name IN  VARCHAR2 ,
      p_receipt_method_id            IN  NUMBER   ,
      p_receipt_method_name          IN  VARCHAR2 ,
      p_doc_sequence_value           IN  NUMBER   ,
      p_ussgl_transaction_code       IN  VARCHAR2 ,
      p_anticipated_clearing_date    IN  DATE     ,
      p_attribute_record             IN  ar_receipt_api_pub.attribute_rec_type ,
      p_global_attribute_record      IN  ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                     IN  VARCHAR2 ,
      p_misc_receipt_id              OUT NOCOPY NUMBER)
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Create_misc(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
                 p_usr_currency_code       =>  p_usr_currency_code, --the translated currency code
                 p_currency_code           =>  p_currency_code ,
                 p_usr_exchange_rate_type  => p_usr_exchange_rate_type ,
                 p_exchange_rate_type      => p_exchange_rate_type       ,
                 p_exchange_rate           => p_exchange_rate ,
                 p_exchange_rate_date      => p_exchange_rate_date ,
                 p_amount                  =>  p_amount,
                 p_receipt_number          =>  p_receipt_number,
                 p_receipt_date            =>  p_receipt_date,
                 p_gl_date                 =>  p_gl_date,
                 p_receivables_trx_id      =>  p_receivables_trx_id           ,
                 p_activity                =>  p_activity    ,
                 p_misc_payment_source     =>  p_misc_payment_source ,
                 p_tax_code	           =>  p_tax_code,
                 p_vat_tax_id              =>  p_vat_tax_id,
                 p_tax_rate                =>  p_tax_rate,
                 p_tax_amount              =>  p_tax_amount,
                 p_deposit_date            =>  p_deposit_date             ,
                 p_reference_type          => p_reference_type   ,
                 p_reference_num           => p_reference_num    ,
                 p_reference_id            => p_reference_id     ,
                 p_remittance_bank_account_id  => p_remittance_bank_account_id   ,
                 p_remittance_bank_account_num  => p_remittance_bank_account_num  ,
                 p_remittance_bank_account_name =>  p_remittance_bank_account_name ,
                 p_receipt_method_id        =>  p_receipt_method_id        ,
                 p_receipt_method_name      =>  p_receipt_method_name      ,
                 p_doc_sequence_value       =>  p_doc_sequence_value       ,
                 p_ussgl_transaction_code   =>  p_ussgl_transaction_code   ,
                 p_anticipated_clearing_date => p_anticipated_clearing_date ,
                 p_attribute_record         =>  p_attribute_record         ,
                 p_global_attribute_record  => p_global_attribute_record  ,
                 p_comments                 => p_comments             ,
                 p_misc_receipt_id 	    => p_misc_receipt_id
                  ) ;
END Create_misc;

PROCEDURE Apply_Open_Receipt(
-- Standard API parameters.
      p_api_version                  IN  NUMBER,
      p_init_msg_list                IN  VARCHAR2 ,
      p_commit                       IN  VARCHAR2 ,
      p_validation_level             IN  NUMBER   ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
 --  Receipt application parameters.
      p_cash_receipt_id              IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_receipt_number               IN ar_cash_receipts.receipt_number%TYPE ,
      p_applied_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE,
      p_open_cash_receipt_id         IN ar_cash_receipts.cash_receipt_id%TYPE ,
      p_open_receipt_number          IN ar_cash_receipts.receipt_number%TYPE ,
      p_open_rec_app_id              IN ar_receivable_applications.receivable_application_id%TYPE ,
      p_amount_applied               IN ar_receivable_applications.amount_applied%TYPE ,
      p_apply_date                   IN ar_receivable_applications.apply_date%TYPE ,
      p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE ,
      p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE ,
      p_called_from                  IN VARCHAR2 ,
      p_attribute_rec                IN ar_receipt_api_pub.attribute_rec_type ,
	 -- ******* Global Flexfield parameters *******
      p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type ,
      p_comments                     IN ar_receivable_applications.comments%TYPE ,
      x_application_ref_num          OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE,
      x_receivable_application_id    OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
      x_applied_rec_app_id           OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE
)
IS

  l_acctd_amount_applied_from   	NUMBER;
  l_acctd_amount_applied_to     	NUMBER;

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Apply_open_receipt(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
                 -- Receipt info. parameters
		 p_cash_receipt_id         => p_cash_receipt_id,
                 p_receipt_number          =>  p_receipt_number,
		 p_applied_payment_schedule_id => p_applied_payment_schedule_id          ,
		 p_open_cash_receipt_id        => p_open_cash_receipt_id,
                 p_open_receipt_number         =>  p_open_receipt_number,
                 p_open_rec_app_id             =>  p_open_rec_app_id    ,
		 p_amount_applied          => p_amount_applied          ,
	         p_apply_date              => p_apply_date              ,
	         p_apply_gl_date           => p_apply_gl_date           ,
	         p_ussgl_transaction_code  => p_ussgl_transaction_code  ,
                 p_called_from            => p_called_from ,
                 p_attribute_rec         =>  p_attribute_rec         ,
       -- ******* Global Flexfield parameters *******
                 p_global_attribute_rec  => p_global_attribute_rec  ,
                 p_comments             => p_comments             ,
	         x_application_ref_num    => x_application_ref_num   ,
                 x_receivable_application_id => x_receivable_application_id,
		 x_applied_rec_app_id     => x_applied_rec_app_id,
		 x_acctd_amount_applied_from => l_acctd_amount_applied_from,
		 x_acctd_amount_applied_to => l_acctd_amount_applied_to
                  ) ;
END Apply_open_receipt;

PROCEDURE Unapply_Open_Receipt(
    -- Standard API parameters.
      p_api_version      IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 ,
      p_commit           IN  VARCHAR2 ,
      p_validation_level IN  NUMBER   ,
      x_return_status    OUT NOCOPY VARCHAR2 ,
      x_msg_count        OUT NOCOPY NUMBER ,
      x_msg_data         OUT NOCOPY VARCHAR2 ,
      p_receivable_application_id   IN  ar_receivable_applications.receivable_application_id%TYPE,
      p_reversal_gl_date IN ar_receivable_applications.reversal_gl_date%TYPE ,
      p_called_from                  IN VARCHAR2 )
IS

BEGIN

   -- Call the receipt API
      AR_Receipt_API_PUB.Unapply_open_receipt(
           -- Standard API parameters.
                 p_api_version      =>  p_api_version,
                 p_init_msg_list    =>  p_init_msg_list,
                 p_commit           =>  p_commit,
                 p_validation_level =>  p_validation_level,
                 x_return_status    =>  x_return_status,
                 x_msg_count        =>  x_msg_count ,
                 x_msg_data         =>  x_msg_data ,
	         p_receivable_application_id => p_receivable_application_id,
	         p_reversal_gl_date        => p_reversal_gl_date,
                 p_called_from            => p_called_from
      );
END Unapply_open_receipt;

END AR_RECEIPT_API_COVER;

/
