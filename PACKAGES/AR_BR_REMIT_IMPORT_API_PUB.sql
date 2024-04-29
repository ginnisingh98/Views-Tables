--------------------------------------------------------
--  DDL for Package AR_BR_REMIT_IMPORT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BR_REMIT_IMPORT_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARBRIMRS.pls 120.4 2006/06/27 08:36:17 shveeram ship $ */
/*#
* Remittance Import API allows the user to import a remittance from a
* third party system into Receivables. This API validates the passed
* parameters and updates  the remittance if it already exists or
* creates a new remittance.  It also ensures that the bill receivable
* is assigned to  the correct remittance.
* @rep:scope public
* @rep:metalink 236938.1 See OracleMetaLink note 236938.1
* @rep:product AR
* @rep:lifecycle active
* @rep:displayname Remittance Import
* @rep:category BUSINESS_ENTITY AR_REMITTANCE
*/

PROCEDURE Dummy_Remittance (p_reserved_value ar_payment_schedules.reserved_value%TYPE,x_return_status  IN OUT NOCOPY VARCHAR2);

PROCEDURE Check_BR_and_Batch_Status (p_internal_reference        IN  RA_CUSTOMER_TRX.Customer_trx_id%TYPE,
                                     p_reserved_value            OUT NOCOPY AR_PAYMENT_SCHEDULES.reserved_value%TYPE,
                                     p_payment_schedule_id       OUT NOCOPY AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
                                     p_media_reference           OUT NOCOPY AR_BATCHES.media_reference%TYPE);

PROCEDURE compare_old_versus_new_values (
  p_media_reference            IN  ar_batches.media_reference%TYPE,
  p_remittance_accounting_Date IN  ar_batches.gl_date%TYPE,
  p_remittance_method          IN  ar_batches.remit_method_code%TYPE,
  p_with_recourse_flag         IN  ar_batches.with_recourse_flag%TYPE,
  p_payment_method             IN  ar_receipt_methods.name%TYPE,
  p_remittance_date            IN  ar_batches.batch_date%TYPE,
  p_Currency_code              IN  ar_batches.currency_code%TYPE,
  p_remittance_bnk_acct_number IN  ce_bank_accounts.bank_account_num%TYPE,
  l_batch_applied_status       OUT NOCOPY ar_batches.batch_applied_status%TYPE,
  l_batch_id 		       OUT NOCOPY ar_batches.batch_id%TYPE
);


PROCEDURE existing_remittance (
  p_media_reference            IN ar_batches.media_reference%TYPE,
  p_remittance_accounting_Date IN ar_batches.gl_date%TYPE,
  p_internal_reference         IN ra_customer_trx.customer_trx_id%TYPE,
  p_remittance_method          IN ar_batches.remit_method_code%TYPE,
  p_with_recourse_flag         IN ar_batches.with_recourse_flag%TYPE,
  p_payment_method	       IN ar_receipt_methods.name%TYPE,
  p_remittance_date            IN ar_batches.batch_date%TYPE,
  p_currency_code              IN ar_batches.currency_code%TYPE,
  p_remittance_bnk_acct_number IN ce_bank_accounts.bank_account_num%TYPE,
  x_return_status              IN OUT NOCOPY VARCHAR2
);


PROCEDURE new_remittance(
  p_media_reference 		 IN ar_batches.media_reference%TYPE,
  p_remittance_accounting_date   IN ar_batches.gl_date%TYPE,
  p_remittance_Date 		 IN ar_batches.batch_date%TYPE,
  p_internal_reference   	 IN ra_customer_trx.Customer_trx_id%TYPE,
  p_with_recourse_flag		 IN ar_batches.with_recourse_flag%TYPE,
  p_currency_code 		 IN ar_batches.currency_code%TYPE,
  p_remittance_method    	 IN ar_batches.remit_method_code%TYPE,
  p_remittance_bnk_branch_number IN ce_bank_branches_v.branch_number%TYPE,
  p_remittance_bank_number       IN ce_bank_branches_v.bank_number%TYPE,
  p_remittance_bnk_acct_number   IN ce_bank_accounts.bank_account_num%TYPE,
  p_payment_method		 IN ar_receipt_methods.name%TYPE,
  x_batch_name                   OUT NOCOPY ar_batches.name%TYPE,
  x_return_status                IN OUT NOCOPY VARCHAR2
);


FUNCTION Remittance_Exists (p_media_reference AR_BATCHES.media_reference%TYPE)  return boolean;
 /*#
 * Use this procedure to import a remittance and call corresponding
 * packages to create data. It is the main procedure for the Remittance Import API.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_validation_level Validation level
 * @param p_remittance_bank_number Remittance bank number
 * @param p_remittance_bnk_branch_number Remittance branch number
 * @param p_remittance_bnk_acct_number Remmittance bank account number
 * @param p_media_reference  Media reference
 * @param p_remittance_method  Remittance method
 * @param p_with_recourse_flag Remit with recourse flag
 * @param p_payment_method Payment method
 * @param p_remittance_date Remittance date
 * @param p_remittance_accounting_date GL date
 * @param p_Currency_code Currency code
 * @param p_internal_reference Transaction ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Remittance Import
 */

PROCEDURE import_remittance_main (
  p_api_version        		 IN  NUMBER,
  p_init_msg_list    		 IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit           		 IN  VARCHAR2,  -- := FND_API.G_FALSE,
  p_validation_level 		 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    		 OUT NOCOPY VARCHAR2,
  x_msg_count        		 OUT NOCOPY NUMBER,
  x_msg_data         		 OUT NOCOPY VARCHAR2,
  p_remittance_bank_number       IN  ce_bank_branches_v.bank_number%TYPE,
  p_remittance_bnk_branch_number IN  ce_bank_branches_v.branch_number%TYPE,
  p_remittance_bnk_acct_number 	 IN  ce_bank_accounts.bank_account_num%TYPE,
  p_media_reference              IN  ar_batches.media_reference%TYPE,
  p_remittance_method            IN  ar_batches.remit_method_code%TYPE,
                                     -- 'STANDARD' , 'FACTORING' etc.
  p_with_recourse_flag		 IN  ar_batches.with_recourse_flag%TYPE,
  p_payment_method               IN  ar_receipt_methods.name%TYPE,
  p_remittance_date              IN  ar_batches.batch_date%TYPE,
  p_remittance_accounting_date   IN  ar_batches.gl_date%TYPE,
  p_currency_code       	 IN  ar_batches.currency_code%TYPE,
  p_internal_reference           IN  ra_customer_trx.Customer_trx_id%TYPE,
  p_org_id                       IN  Number default null,
  p_remittance_name              OUT NOCOPY ar_batches.name%TYPE
);

END AR_BR_REMIT_IMPORT_API_PUB;


 

/
