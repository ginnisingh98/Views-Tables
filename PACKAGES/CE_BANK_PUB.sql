--------------------------------------------------------
--  DDL for Package CE_BANK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_PUB" AUTHID CURRENT_USER AS
/*$Header: ceextbas.pls 120.3.12010000.4 2010/04/29 09:07:01 talapati ship $ */

  TYPE BankAcct_rec_type IS RECORD (
    bank_account_id             NUMBER(15),    -- required for update
    branch_id                   NUMBER(15),    -- required for create
    bank_id                     NUMBER(15),
    account_owner_party_id      NUMBER(15),
    account_owner_org_id        NUMBER(15),    -- required for create (cannot be updated)
    account_classification      VARCHAR2(30),  -- required
    bank_account_name           VARCHAR2(80),  -- required
    bank_account_num            VARCHAR2(100), -- required
    currency                    VARCHAR2(15),
    iban                        VARCHAR2(50),
    check_digits                VARCHAR2(30),
    eft_requester_id            VARCHAR2(25),
    secondary_account_reference VARCHAR2(30),
    multi_currency_allowed_flag VARCHAR2(1),
    alternate_acct_name         VARCHAR2(320),
    short_account_name          VARCHAR2(30),
    acct_type                   VARCHAR2(25),
    acct_suffix                 VARCHAR2(30),
    description_code1           VARCHAR2(60),
    description_code2           VARCHAR2(60),
    description                 VARCHAR2(240),
    agency_location_code        VARCHAR2(30),
    ap_use_allowed_flag         VARCHAR2(1),
    ar_use_allowed_flag         VARCHAR2(1),
    xtr_use_allowed_flag        VARCHAR2(1),
    pay_use_allowed_flag        VARCHAR2(1),
    payment_multi_currency_flag VARCHAR2(1),
    receipt_multi_currency_flag VARCHAR2(1),
    zero_amount_allowed         VARCHAR2(1),
    max_outlay                  NUMBER(15),
    max_check_amount            NUMBER(15),
    min_check_amount            NUMBER,       -- Bug 9665618
    ap_amount_tolerance         NUMBER(15),
    ar_amount_tolerance         NUMBER(15),
    xtr_amount_tolerance        NUMBER(15),
    pay_amount_tolerance        NUMBER(15),
    ce_amount_tolerance		NUMBER(15),
    ap_percent_tolerance        NUMBER(15),
    ar_percent_tolerance        NUMBER(15),
    xtr_percent_tolerance       NUMBER(15),
    pay_percent_tolerance       NUMBER(15),
    ce_percent_tolerance	NUMBER(15),
    start_date                  DATE,
    end_date                    DATE,
    account_holder_name_alt     VARCHAR2(150),
    account_holder_name         VARCHAR2(240),
    cashflow_display_order      NUMBER(15),
    pooled_flag                 VARCHAR2(1),
    min_target_balance          NUMBER(15),
    max_target_balance          NUMBER(15),
    eft_user_num                VARCHAR2(30),
    masked_account_num          VARCHAR2(100),
    masked_iban                 VARCHAR2(50),
    interest_schedule_id        NUMBER(15),
    asset_code_combination_id	NUMBER(15),
    cash_clearing_ccid		NUMBER(15),
    bank_charges_ccid		NUMBER(15),
    bank_errors_ccid		NUMBER(15),
    cashpool_min_payment_amt	NUMBER,
    cashpool_min_receipt_amt    NUMBER,
    cashpool_round_factor 	NUMBER(15),
    cashpool_round_rule		VARCHAR2(4),
    attribute_category          VARCHAR2(150),
    attribute1                  VARCHAR2(150),
    attribute2                  VARCHAR2(150),
    attribute3                  VARCHAR2(150),
    attribute4                  VARCHAR2(150),
    attribute5                  VARCHAR2(150),
    attribute6                  VARCHAR2(150),
    attribute7                  VARCHAR2(150),
    attribute8                  VARCHAR2(150),
    attribute9                  VARCHAR2(150),
    attribute10                 VARCHAR2(150),
    attribute11                 VARCHAR2(150),
    attribute12                 VARCHAR2(150),
    attribute13                 VARCHAR2(150),
    attribute14                 VARCHAR2(150),
    attribute15                 VARCHAR2(150),
    xtr_bank_account_reference  VARCHAR2(20)
  );


  TYPE BankAcct_use_rec_type IS RECORD (
    bank_acct_use_id            NUMBER(15),   -- required for update
    bank_account_id             NUMBER(15),   -- required for create
    org_type			VARCHAR2(2),  -- required, valid values: LE, OU, BG
    primary_flag                VARCHAR2(1),
    org_id                      NUMBER(15),   -- required if OU or BG
    org_party_id                NUMBER(15),
    ap_use_enable_flag          VARCHAR2(1),
    ar_use_enable_flag          VARCHAR2(1),
    xtr_use_enable_flag         VARCHAR2(1),
    pay_use_enable_flag         VARCHAR2(1),
    edisc_receivables_trx_id    NUMBER(15),
    unedisc_receivables_trx_id  NUMBER(15),
    end_date                    DATE,
    br_std_receivables_trx_id   NUMBER(15),
    legal_entity_id             NUMBER(15),   -- required if LE
    investment_limit_code       VARCHAR2(7),
    funding_limit_code          VARCHAR2(7),
    ap_default_settlement_flag  VARCHAR2(1),
    xtr_default_settlement_flag VARCHAR2(1),
    payroll_bank_account_id     NUMBER(15),
    pricing_model               VARCHAR2(30),
    authorized_flag             VARCHAR2(1),
    eft_script_name             VARCHAR2(50),
    default_account_flag        VARCHAR2(1),
    portfolio_code              VARCHAR2(7),
    attribute_category          VARCHAR2(150),
    attribute1                  VARCHAR2(150),
    attribute2                  VARCHAR2(150),
    attribute3                  VARCHAR2(150),
    attribute4                  VARCHAR2(150),
    attribute5                  VARCHAR2(150),
    attribute6                  VARCHAR2(150),
    attribute7                  VARCHAR2(150),
    attribute8                  VARCHAR2(150),
    attribute9                  VARCHAR2(150),
    attribute10                 VARCHAR2(150),
    attribute11                 VARCHAR2(150),
    attribute12                 VARCHAR2(150),
    attribute13                 VARCHAR2(150),
    attribute14                 VARCHAR2(150),
    attribute15                 VARCHAR2(150),
    asset_code_combination_id	NUMBER(15),       -- required for AP and AR use
    ap_asset_ccid		NUMBER(15),
    ar_asset_ccid		NUMBER(15),
    cash_clearing_ccid		NUMBER(15),
    bank_charges_ccid		NUMBER(15),
    bank_errors_ccid		NUMBER(15),
    gain_code_combination_id	NUMBER(15),
    loss_code_combination_id	NUMBER(15),
    on_account_ccid		NUMBER(15),
    unapplied_ccid		NUMBER(15),
    unidentified_ccid		NUMBER(15),
    factor_ccid			NUMBER(15),
    receipt_clearing_ccid	NUMBER(15),
    remittance_ccid		NUMBER(15),
    ar_short_term_deposit_ccid	NUMBER(15),
    br_short_term_deposit_ccid	NUMBER(15),
    future_dated_payment_ccid	NUMBER(15),
    br_remittance_ccid		NUMBER(15),
    br_factor_ccid		NUMBER(15),
    bank_interest_expense_ccid	NUMBER(15),
    bank_interest_income_ccid	NUMBER(15),
    xtr_asset_ccid		NUMBER(15),
    ar_bank_charges_ccid	NUMBER(15)  --7437641
   );



   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank as a TCA organization party.         	           |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.create_bank						   |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_country_code             Country code of the bank.              |
   |     p_bank_name                Bank name.                             |
   |     p_bank_number              Bank number.                           |
   |     p_alternate_bank_name      Alternate bank name.                   |
   |     p_short_bank_name          Short bank name.                       |
   |     p_description              Description.                           |
   |     p_tax_payer_id             Tax payer ID.                          |
   |     p_tax_registration_number  Tax registration number                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_id            Party ID for the bank.                       |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank (
	p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
	p_country_code	           IN     VARCHAR2,
	p_bank_name	           IN     VARCHAR2,
	p_bank_number              IN     VARCHAR2 DEFAULT NULL,
	p_alternate_bank_name      IN     VARCHAR2 DEFAULT NULL,
	p_short_bank_name          IN     VARCHAR2 DEFAULT NULL,
	p_description              IN     VARCHAR2 DEFAULT NULL,
	p_tax_payer_id             IN     VARCHAR2 DEFAULT NULL,
	p_tax_registration_number  IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category       IN     VARCHAR2 DEFAULT NULL,
        p_attribute1               IN     VARCHAR2 DEFAULT NULL,
        p_attribute2               IN     VARCHAR2 DEFAULT NULL,
        p_attribute3               IN     VARCHAR2 DEFAULT NULL,
        p_attribute4               IN     VARCHAR2 DEFAULT NULL,
        p_attribute5               IN     VARCHAR2 DEFAULT NULL,
        p_attribute6               IN     VARCHAR2 DEFAULT NULL,
        p_attribute7               IN     VARCHAR2 DEFAULT NULL,
        p_attribute8               IN     VARCHAR2 DEFAULT NULL,
        p_attribute9               IN     VARCHAR2 DEFAULT NULL,
        p_attribute10              IN     VARCHAR2 DEFAULT NULL,
        p_attribute11              IN     VARCHAR2 DEFAULT NULL,
        p_attribute12              IN     VARCHAR2 DEFAULT NULL,
        p_attribute13              IN     VARCHAR2 DEFAULT NULL,
        p_attribute14              IN     VARCHAR2 DEFAULT NULL,
        p_attribute15              IN     VARCHAR2 DEFAULT NULL,
        p_attribute16              IN     VARCHAR2 DEFAULT NULL,
        p_attribute17              IN     VARCHAR2 DEFAULT NULL,
        p_attribute18              IN     VARCHAR2 DEFAULT NULL,
        p_attribute19              IN     VARCHAR2 DEFAULT NULL,
        p_attribute20              IN     VARCHAR2 DEFAULT NULL,
        p_attribute21              IN     VARCHAR2 DEFAULT NULL,
        p_attribute22              IN     VARCHAR2 DEFAULT NULL,
        p_attribute23              IN     VARCHAR2 DEFAULT NULL,
        p_attribute24              IN     VARCHAR2 DEFAULT NULL,
	x_bank_id                  OUT  NOCOPY  NUMBER,
	x_return_status            OUT  NOCOPY  VARCHAR2,
	x_msg_count                OUT  NOCOPY  NUMBER,
	x_msg_data                 OUT  NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank organization.                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_bank_id                  Party ID of the bank to be updated.    |
   |     p_bank_name                Bank name.                             |
   |     p_bank_number              Bank number.                           |
   |     p_alternate_bank_name      Alternate bank name.                   |
   |     p_short_bank_name          Short bank name.                       |
   |     p_description              Description.                           |
   |     p_tax_payer_id             Tax payer ID.                          |
   |     p_tax_registration_number  Tax registration number                |
   |   IN/OUT:                                                             |
   |     p_object_version_number Current object version number for the bank|
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.			   |
   |   05-MAR-2009    TALAPATI  Added a new parameter p_country_validate   |
   |                            to enable or disable the country specific  |
   |                            validation.(Bug #8286747)                  |
   +=======================================================================*/
  PROCEDURE update_bank (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_bank_id	           IN     NUMBER,
        p_bank_name                IN     VARCHAR2,
        p_bank_number              IN     VARCHAR2 DEFAULT NULL,
        p_alternate_bank_name      IN     VARCHAR2 DEFAULT NULL,
        p_short_bank_name          IN     VARCHAR2 DEFAULT NULL,
        p_description              IN     VARCHAR2 DEFAULT NULL,
        p_tax_payer_id             IN     VARCHAR2 DEFAULT NULL,
        p_tax_registration_number  IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category       IN     VARCHAR2 DEFAULT NULL,
        p_attribute1               IN     VARCHAR2 DEFAULT NULL,
        p_attribute2               IN     VARCHAR2 DEFAULT NULL,
        p_attribute3               IN     VARCHAR2 DEFAULT NULL,
        p_attribute4               IN     VARCHAR2 DEFAULT NULL,
        p_attribute5               IN     VARCHAR2 DEFAULT NULL,
        p_attribute6               IN     VARCHAR2 DEFAULT NULL,
        p_attribute7               IN     VARCHAR2 DEFAULT NULL,
        p_attribute8               IN     VARCHAR2 DEFAULT NULL,
        p_attribute9               IN     VARCHAR2 DEFAULT NULL,
        p_attribute10              IN     VARCHAR2 DEFAULT NULL,
        p_attribute11              IN     VARCHAR2 DEFAULT NULL,
        p_attribute12              IN     VARCHAR2 DEFAULT NULL,
        p_attribute13              IN     VARCHAR2 DEFAULT NULL,
        p_attribute14              IN     VARCHAR2 DEFAULT NULL,
        p_attribute15              IN     VARCHAR2 DEFAULT NULL,
        p_attribute16              IN     VARCHAR2 DEFAULT NULL,
        p_attribute17              IN     VARCHAR2 DEFAULT NULL,
        p_attribute18              IN     VARCHAR2 DEFAULT NULL,
        p_attribute19              IN     VARCHAR2 DEFAULT NULL,
        p_attribute20              IN     VARCHAR2 DEFAULT NULL,
        p_attribute21              IN     VARCHAR2 DEFAULT NULL,
        p_attribute22              IN     VARCHAR2 DEFAULT NULL,
        p_attribute23              IN     VARCHAR2 DEFAULT NULL,
        p_attribute24              IN     VARCHAR2 DEFAULT NULL,
	p_country_validate         IN     VARCHAR2 DEFAULT 'Y',
	p_object_version_number	   IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE set_bank_end_date                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Set the end date of a bank.                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_bank_id                Party ID of the bank to be updated.      |
   |     p_end_date		  End date of the bank.               	   |
   |   IN/OUT:                                                             |
   |     p_object_version_number Current object version number for the code|
   |                             assignment for the bank institution type. |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE set_bank_end_date (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_bank_id                  IN     NUMBER,
	p_end_date		   IN	  DATE,
        p_object_version_number    IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE check_bank_exist                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check whether a bank already exists, if so, return the bank ID.     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |	 p_country_code		    Country code.			   |
   |     p_bank_name                Bank name.    			   |
   |     p_bank_number		    Bank number.                           |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_id                  Bank Party ID if bank exists,          |
   |			 	    null if bank does not exist.	   |
   |     x_end_date		    End date of the bank.		   |
   |									   |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE check_bank_exist(
        p_country_code             IN     VARCHAR2,
        p_bank_name                IN     VARCHAR2,
	p_bank_number		   IN	  VARCHAR2,
	x_bank_id		   OUT    NOCOPY NUMBER,
	x_end_date		   OUT    NOCOPY DATE
  );



   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank branch as a TCA organization party.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.create_bank_branch                                      |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |	 p_bank_party_id            Party ID of the bank that the branch   |
   |                                belongs.                               |
   |     p_branch_name              Bank branch name.                      |
   |     p_branch_number            Bank branch number.                    |
   |     p_branch_type              Bank branch type.                      |
   |     p_alternate_branch_name    Alternate bank branch name.            |
   |     p_description              Description.                           |
   |     p_bic                      BIC (Bank Identification Code).        |
   |     p_eft_number               EFT number.                            |
   |     p_rfc_identifier           Regional Finance Center Identifier.    |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_branch_id          Party ID for the bank branch.                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank_branch (
        p_init_msg_list              IN     VARCHAR2:= fnd_api.g_false,
	p_bank_id		     IN	    NUMBER,
        p_branch_name                IN     VARCHAR2,
        p_branch_number              IN     VARCHAR2 DEFAULT NULL,
        p_branch_type		     IN	    VARCHAR2 DEFAULT NULL,
        p_alternate_branch_name      IN     VARCHAR2 DEFAULT NULL,
        p_description                IN     VARCHAR2 DEFAULT NULL,
	p_bic                        IN     VARCHAR2 DEFAULT NULL,
	p_eft_number		     IN     VARCHAR2 DEFAULT NULL,
	p_rfc_identifier	     IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category         IN     VARCHAR2 DEFAULT NULL,
        p_attribute1                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute2                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute3                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute4                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute5                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute6                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute7                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute8                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute9                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute10                IN     VARCHAR2 DEFAULT NULL,
        p_attribute11                IN     VARCHAR2 DEFAULT NULL,
        p_attribute12                IN     VARCHAR2 DEFAULT NULL,
        p_attribute13                IN     VARCHAR2 DEFAULT NULL,
        p_attribute14                IN     VARCHAR2 DEFAULT NULL,
        p_attribute15                IN     VARCHAR2 DEFAULT NULL,
        p_attribute16                IN     VARCHAR2 DEFAULT NULL,
        p_attribute17                IN     VARCHAR2 DEFAULT NULL,
        p_attribute18                IN     VARCHAR2 DEFAULT NULL,
        p_attribute19                IN     VARCHAR2 DEFAULT NULL,
        p_attribute20                IN     VARCHAR2 DEFAULT NULL,
        p_attribute21                IN     VARCHAR2 DEFAULT NULL,
        p_attribute22                IN     VARCHAR2 DEFAULT NULL,
        p_attribute23                IN     VARCHAR2 DEFAULT NULL,
        p_attribute24                IN     VARCHAR2 DEFAULT NULL,
        x_branch_id                  OUT  NOCOPY  NUMBER,
        x_return_status              OUT  NOCOPY  VARCHAR2,
        x_msg_count                  OUT  NOCOPY  NUMBER,
        x_msg_data                   OUT  NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank branch organization party in TCA.                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank_branch                                      |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_branch_id		    Party ID of the branch to be updated.  |
   |     p_branch_name              Bank branch name.                      |
   |     p_branch_number            Bank branch number.                    |
   |     p_branch_type              Bank branch type.                      |
   |     p_alternate_branch_name    Alternate bank branch name.            |
   |     p_description              Description.                           |
   |     p_bic                      BIC (Bank Identification Code).        |
   |     p_eft_number               EFT number.                            |
   |     p_rfc_identifier           RFC Identifier.                        |
   |   IN/OUT:                                                             |
   |     p_bch_object_version_number    Current object version number for  |
   |                                    the bank branch.                   |
   |     p_typ_object_version_number    Current object version number for  |
   |                                    bank branch type code assignment.  |
   |     p_rfc_object_version_number    Current object version number for  |
   |                                    RFC code assignment.               |
   |     p_eft_object_version_number    Current object version number for  |
   |                                    BIC(EFT) contact point.            |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   |   05-MAR-2009    TALAPATI  Added a new parameter p_country_validate   |
   |                            to enable or disable the country specific  |
   |                            validation.(Bug #8286747)                  |
   +=======================================================================*/
  PROCEDURE update_bank_branch (
        p_init_msg_list              IN     VARCHAR2:= fnd_api.g_false,
	p_branch_id		     IN     NUMBER,
        p_branch_name                IN     VARCHAR2,
        p_branch_number              IN     VARCHAR2 DEFAULT NULL,
        p_branch_type                IN     VARCHAR2 DEFAULT NULL,
        p_alternate_branch_name      IN     VARCHAR2 DEFAULT NULL,
        p_description                IN     VARCHAR2 DEFAULT NULL,
        p_bic                        IN     VARCHAR2 DEFAULT NULL,
        p_eft_number                 IN     VARCHAR2 DEFAULT NULL,
        p_rfc_identifier             IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category         IN     VARCHAR2 DEFAULT NULL,
        p_attribute1                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute2                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute3                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute4                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute5                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute6                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute7                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute8                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute9                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute10                IN     VARCHAR2 DEFAULT NULL,
        p_attribute11                IN     VARCHAR2 DEFAULT NULL,
        p_attribute12                IN     VARCHAR2 DEFAULT NULL,
        p_attribute13                IN     VARCHAR2 DEFAULT NULL,
        p_attribute14                IN     VARCHAR2 DEFAULT NULL,
        p_attribute15                IN     VARCHAR2 DEFAULT NULL,
        p_attribute16                IN     VARCHAR2 DEFAULT NULL,
        p_attribute17                IN     VARCHAR2 DEFAULT NULL,
        p_attribute18                IN     VARCHAR2 DEFAULT NULL,
        p_attribute19                IN     VARCHAR2 DEFAULT NULL,
        p_attribute20                IN     VARCHAR2 DEFAULT NULL,
        p_attribute21                IN     VARCHAR2 DEFAULT NULL,
        p_attribute22                IN     VARCHAR2 DEFAULT NULL,
        p_attribute23                IN     VARCHAR2 DEFAULT NULL,
        p_attribute24                IN     VARCHAR2 DEFAULT NULL,
	p_country_validate         IN     VARCHAR2 DEFAULT 'Y',
	p_bch_object_version_number  IN OUT NOCOPY  NUMBER,
   	p_typ_object_version_number  IN OUT NOCOPY  NUMBER,
	p_rfc_object_version_number  IN OUT NOCOPY  NUMBER,
	p_eft_object_version_number  IN OUT NOCOPY  NUMBER,
        x_return_status              OUT    NOCOPY  VARCHAR2,
        x_msg_count                  OUT    NOCOPY  NUMBER,
        x_msg_data                   OUT    NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE set_bank_branch_end_date                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Set the end date of a bank branch.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_branch_id              Party ID of the branch to be inactivated.|
   |     p_end_date               Inactive date of the bank branch.        |
   |   IN/OUT:                                                             |
   |     p_object_version_number    Current object version number for the  |
   |                                code assignment of the bank institution|
   | 				    type for the bank branch.		   |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE set_bank_branch_end_date (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_branch_id                IN     NUMBER,
        p_end_date                 IN     DATE,
        p_object_version_number    IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE check_branch_exist                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check whether a bank branch already exists.                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_id		    Bank Party ID.                         |
   |     p_branch_name              Bank branch name.                      |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_branch_id                Bank branch Party ID if branch exists, |
   |				    null if branch does not already exist. |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE check_branch_exist(
        p_bank_id                  IN     NUMBER,
        p_branch_name              IN     VARCHAR2,
	p_branch_number		   IN	  VARCHAR2,
	x_branch_id		   OUT    NOCOPY NUMBER,
	x_end_date		   OUT    NOCOPY DATE
  );



   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_acct                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create an internal or subsidiary bank account.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false   |
   |     p_acct_rec           Bank account record.                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_acct_id            Bank account ID.                             |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank_acct (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_rec                      IN      BankAcct_rec_type,
        x_acct_id                       OUT     NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  );


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_acct                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update an internal or subsidiary bank account.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_acct_rec               External bank account record.            |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Current object version number for the    |
   |                              bank account.                            |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE update_bank_acct (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_rec                      IN      BankAcct_rec_type,
        p_object_version_number         IN OUT  NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  );


  PROCEDURE create_bank_acct_use (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_use_rec                  IN      BankAcct_use_rec_type,
        x_acct_use_id                   OUT     NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  );


  PROCEDURE update_bank_acct_use (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_use_rec                  IN      BankAcct_use_rec_type,
        p_use_ovn	         	IN OUT  NOCOPY NUMBER,
	p_ccid_ovn			IN OUT  NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  );



END ce_bank_pub;

/
