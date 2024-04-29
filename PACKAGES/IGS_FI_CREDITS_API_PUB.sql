--------------------------------------------------------
--  DDL for Package IGS_FI_CREDITS_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CREDITS_API_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSFI54S.pls 120.4 2006/01/17 02:42:49 svuppala ship $ */
/*#
 * The Credits API is a public API that is used internally or externally to create payment or credit information in the Student Finance module of Student System.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Import Credits
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_PARTY_CREDIT
 */

-- CHANGE HISTORY:
-- WHO          WHEN              WHAT
-- svuppala   9-Jan-2006    R12 iRep Annotation - added annotation
-- svuppala   9-JUN-2005    Enh 4213629 - The automatic generation of the Receipt Number.
--                          Added a new procedure, create_credit with all the parameters of existing procedure
--                          excluding p_credit_number and adding additional OUT parameter, x_credit_number
-- schodava   11-Jun-2003   Enh # 2831587. Added 3 new parameters to the Public API
-- vvutukur   04-Apr-2003   Enh#2831554. Internal Credits API Build.Changed igs_fi_credits to igs_fi_credits_all and
--                          igs_fi_invln_int to igs_fi_invln_int_all and applied checklist for package spec.
-- vvutukur   11-Dec-2002   Enh#2584741.Removed parameter p_validation_level.Added 3 new parameters p_v_check_number,
--                          p_v_source_tran_type,p_v_source_tran_ref_number to create_credit procedure.
-- vvutukur    12-Nov-2002        Enh#2584986.Added new parameter p_d_gl_date to create_credit procedure.
-- smvk        16-Sep-2002        Removed the parameter p_subaccount_id as a part of Bug # 2564643
-- vvutukur    31-JAN-2002        Added parameter p_invoice_id for bug:2195715
-- sykrishn     04-FEB-2002       Added parameters  fee period and award year (default null) in  create credit for bug:2191470 -SFCr020
--				  made p_credit_source as DEFAUTL NULL (non mandatory)

-- Start of Comments
-- API Name               : Create_Credit
-- Type                   : Private
-- Pre-reqs               : None
-- Function               : Creates a credit in the credits and credit activities table
-- Parameters
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- IN                       p_credit_number
--                          This is the credit number for the credit to be created. The
--                          credit number is used for creating the records in the credits table
--                          and corresponds to the Credit_Number field of the IGS_FI_CREDITS_ALL
--                          table.
-- IN                       p_credit_status
--                          This is the status of the credit record. It may be CLEARED or REVERSED
--                          and should be a valid value in the Lookups.
-- IN                       p_credit_source
--                          This is the credit source and should be a valid value in the Lookups (NON MANDATORY as PER SFCR020).
-- IN                       p_party_id
--                          This is the party id and should be present in the HZ_PARTIES table.
-- IN                       p_credit_type_id
--                          This parameter holds the value for the credit type. This should be a valid
--                          credit type set up in the IGS_FI_CR_TYPES table.
-- IN                       p_credit_instrument
--                          This parameter holds the value for the Credit Instrument. This should be a valid
--                          lookup with lookup type as "IGS_FI_CREDIT_INSTRUMENT".
-- IN                       p_description
-- IN                       p_amount
--                          This parameter holds the amount of the credit record.
-- IN                       p_currency_cd
--                          This parameter holds the currency code for the credit record. The API converts this
--                          to the local currency as all credit records should be present in the local currency.
-- IN                       p_exchange_rate
--                          This parameter holds the value for the exchange rate for the currency. If the currency is
--                          local currency, then the exchange rate is defaulted to 1.
-- IN                       p_transaction_date
--                          This parameter holds the value for the transaction date. If it is not provided then
--                          it is defaulted to sysdate.
-- IN                       p_effective_date
--                          This parameter holds the value for the effective date. If it is not provided then
--                          it is defaulted to the Transaction Date.
-- IN                       p_source_transaction_id
--                          This parameter holds the value for the source transaction. It would be used to keep the
--                          track for the imported AR Lockbox transactions.
-- IN                       p_subaccount_id(Removed the parameter p_subaccount_id as a part of Bug # 2564643)
--                          This parameter holds the value for the subaccount id which is used for identifying the
--                          subaccount associated with this transaction.
-- IN                       p_receipt_lockbox_number
--                          This parameter holds the value for the receipt lockbox number.
-- IN                       p_credit_card_code
--                          This parameter holds the value for the Credit Card Code which is a set up data defined in the
--                          Lookups.This is an optional parameter and can be null.
-- IN                       p_credit_card_holder_name
--                          This parameter holds the value for the Credit Card Holder Name and it can be null.
-- IN                       p_credit_card_number
--                          This parameter holds the value for the Credit Card Number.This is an optional parameter and can
--                          be defaulted to null.
-- IN                       p_credit_card_expiration_date
--                          This parameter holds the value for the Credit Card Expiration Date and is an optional parameter.
--                          If provided, this should be greater than or equal to the system date.
-- IN                       p_credit_card_approval_code
--                          This parameter holds the value for the Credit Card Approval Code and is an optional parameter.
-- IN                       p_attribute_record
-- IN                       p_invoice_id
--                          The invoice id of the Source Charge Transaction in the case of a Negative Adjustment related credit.
-- IN
-- IN			    p_awd_yr_cal_type
--                          Award Year cal type - mandatory if credit class is of Financial Aid
-- IN                       p_awd_yr_ci_sequence_number
--                          Award Year ci sequence  - mandatory if credit class is of f Financial Aid
-- IN			    p_fee_cal_type
--                          Fee cal type - mandatory if credit class is of Financial Aid
-- IN   		    p_fee_ci_sequence_number
--                          Fee Ci Sequnce number - mandatory if credit class is of Financial Aid
-- IN                       p_v_credit_card_payee_cd
--                          The credit card payee
-- IN                       p_v_credit_card_status_code
--                          The status of the Credit Card payment
-- IN                       p_v_credit_card_tangible_cd
--                          The tangible code generated, to be passed to iPayment, to identify the transaction
-- OUT                      x_credit_id
-- OUT                      x_credit_activity_id
-- OUT                      x_return_status
-- OUT                      x_msg_count
-- OUT                      x_msg_data
-- Version: Current Version 1.2
-- End of Comments
  TYPE attribute_rec_type IS RECORD(p_attribute_category            igs_fi_credits_all.attribute_category%TYPE,
                                    p_attribute1                    igs_fi_credits_all.attribute1%TYPE,
                                    p_attribute2                    igs_fi_credits_all.attribute2%TYPE,
                                    p_attribute3                    igs_fi_credits_all.attribute3%TYPE,
                                    p_attribute4                    igs_fi_credits_all.attribute4%TYPE,
                                    p_attribute5                    igs_fi_credits_all.attribute5%TYPE,
                                    p_attribute6                    igs_fi_credits_all.attribute6%TYPE,
                                    p_attribute7                    igs_fi_credits_all.attribute7%TYPE,
                                    p_attribute8                    igs_fi_credits_all.attribute8%TYPE,
                                    p_attribute9                    igs_fi_credits_all.attribute9%TYPE,
                                    p_attribute10                   igs_fi_credits_all.attribute10%TYPE,
                                    p_attribute11                   igs_fi_credits_all.attribute11%TYPE,
                                    p_attribute12                   igs_fi_credits_all.attribute12%TYPE,
                                    p_attribute13                   igs_fi_credits_all.attribute13%TYPE,
                                    p_attribute14                   igs_fi_credits_all.attribute14%TYPE,
                                    p_attribute15                   igs_fi_credits_all.attribute15%TYPE,
                                    p_attribute16                   igs_fi_credits_all.attribute16%TYPE,
                                    p_attribute17                   igs_fi_credits_all.attribute17%TYPE,
                                    p_attribute18                   igs_fi_credits_all.attribute18%TYPE,
                                    p_attribute19                   igs_fi_credits_all.attribute19%TYPE,
                                    p_attribute20                   igs_fi_credits_all.attribute20%TYPE);

  /*#
 * The Credits API is a public API that is used internally or externally to create payment or credit information in the Student Finance module of Student System.
 * @param p_api_version The version number will be used to compare with this public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_FALSE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_FALSE to have API to commit automatically.
 * @param p_party_id This is the Party Identifer, and should be present in the HZ_PARTIES table.
 * @param p_credit_number This is the credit number for the credit to be created. The credit number is used for creating the records in the credits table and corresponds to the Credit_Number field of the IGS_FI_CREDITS_ALL  table.
 * @param p_credit_status This is the status of the credit record. It may be CLEARED or REVERSED  and should be a valid value in the Lookups.
 * @param p_credit_source This is the credit source and should be a valid value in the Lookups.
 * @param p_credit_type_id This parameter holds the value for the credit type. This should be a valid credit type set up in the IGS_FI_CR_TYPES table.
 * @param p_credit_instrument This parameter holds the value for the Credit Instrument. This should be a valid lookup with lookup type as "IGS_FI_CREDIT_INSTRUMENT".
 * @param p_description Credit Description
 * @param p_amount This parameter holds the amount of the credit record.
 * @param p_currency_cd This parameter holds the currency code for the credit record. The API converts this to the local currency as all credit records should be present in the local currency
 * @param p_exchange_rate This parameter holds the value for the exchange rate for the currency. If the currency is local currency, then the exchange rate is defaulted to 1.
 * @param p_transaction_date This parameter holds the value for the transaction date. If it is not provided then it is defaulted to sysdate.
 * @param p_effective_date This parameter holds the value for the effective date. If it is not provided then it is defaulted to the Transaction Date.
 * @param p_source_transaction_id This parameter holds the value for the source transaction. It would be used to keep the track for the imported AR Lockbox transactions.
 * @param p_receipt_lockbox_number This parameter holds the value for the receipt lockbox number.
 * @param p_credit_card_code This parameter holds the value for the Credit Card Code which is a set up data defined in the Lookups.
 * @param p_credit_card_holder_name This parameter holds the value for the Credit Card Holder Name.
 * @param p_credit_card_number This parameter holds the value for the Credit Card Number.
 * @param p_credit_card_expiration_date This parameter holds the value for the Credit Card Expiration Date. If provided, this should be greater than or equal to the system date.
 * @param p_credit_card_approval_code This parameter holds the value for the Credit Card Approval Code.
 * @param p_attribute_record This parameter holds the values of the attributes of the credit record.
 * @param p_invoice_id The invoice ID of the Source Charge Transaction in the case of a Negative Adjustment related credit.
 * @param p_awd_yr_cal_type This is the Financial Aid Award Year calendar type and is mandatory if credit class is of Financial Aid
 * @param p_awd_yr_ci_sequence_number This is the Financial Aid Award Year sequence number and is mandatory if the credit class is of Financial Aid.
 * @param p_fee_cal_type This is the fee calendar type and is mandatory if the credit class is of Financial Aid.
 * @param p_fee_ci_sequence_number This is the fee calendar instance sequence number and is mandatory if the credit class is of Financial Aid.
 * @param p_d_gl_date The general ledger date.
 * @param x_credit_id The credit identifier.
 * @param x_credit_activity_id The credit activity identifier.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXp_ERROR
 * @param x_msg_count The message count.
 * @param x_msg_data The message data.
 * @param p_v_check_number The check number.
 * @param p_v_source_tran_type The Source Transaction Type,
 * @param p_v_source_tran_ref_number The Source Transaction Reference Number,
 * @param p_v_credit_card_payee_cd The credit card payee.
 * @param p_v_credit_card_status_code The status of the Credit Card payment.
 * @param p_v_credit_card_tangible_cd The tangible code generated, to be passed to iPayment to identify the transaction.
 * @param p_lockbox_interface_id The lockbox interface ID.
 * @param p_batch_name The batch name.
 * @param p_deposit_date The deposit date.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Credits
 */
  PROCEDURE create_credit(p_api_version                 IN               NUMBER,
                          p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_credit_number               IN               igs_fi_credits_all.credit_number%TYPE,
                          p_credit_status               IN               igs_fi_credits_all.status%TYPE DEFAULT 'CLEARED',
                          p_credit_source               IN               igs_fi_credits_all.credit_source%TYPE DEFAULT NULL,
                          p_party_id                    IN               igs_fi_credits_all.party_id%TYPE,
                          p_credit_type_id              IN               igs_fi_credits_all.credit_type_id%TYPE,
                          p_credit_instrument           IN               igs_fi_credits_all.credit_instrument%TYPE,
                          p_description                 IN               igs_fi_credits_all.description%TYPE DEFAULT NULL,
                          p_amount                      IN               igs_fi_credits_all.amount%TYPE,
                          p_currency_cd                 IN               igs_fi_credits_all.currency_cd%TYPE DEFAULT NULL,
                          p_exchange_rate               IN               igs_fi_credits_all.exchange_rate%TYPE DEFAULT 1,
                          p_transaction_date            IN               igs_fi_credits_all.transaction_date%TYPE DEFAULT NULL,
                          p_effective_date              IN               igs_fi_credits_all.effective_date%TYPE DEFAULT NULL,
                          p_source_transaction_id       IN               igs_fi_credits_all.source_transaction_id%TYPE DEFAULT NULL,
                        /* Removed the parameter p_subaccount_id as a part of Bug # 2564643 */
                          p_receipt_lockbox_number      IN               igs_fi_credits_all.receipt_lockbox_number%TYPE DEFAULT NULL,
                          p_credit_card_code            IN               igs_fi_credits_all.credit_card_code%TYPE DEFAULT NULL,
                          p_credit_card_holder_name     IN               igs_fi_credits_all.credit_card_holder_name%TYPE DEFAULT NULL,
                          p_credit_card_number          IN               igs_fi_credits_all.credit_card_number%TYPE DEFAULT NULL,
                          p_credit_card_expiration_date IN               igs_fi_credits_all.credit_card_expiration_date%TYPE DEFAULT NULL,
                          p_credit_card_approval_code   IN               igs_fi_credits_all.credit_card_approval_code%TYPE DEFAULT NULL,
                          p_attribute_record            IN               attribute_rec_type DEFAULT NULL,
                          p_invoice_id                  IN               igs_fi_inv_int_all.invoice_id%TYPE DEFAULT NULL,--bug:2195715
                        /* Parameters added as part of bug:2191470 - sfcr020 */
                          p_awd_yr_cal_type             IN               igs_fi_credits_all.awd_yr_cal_type%TYPE DEFAULT NULL,
                          p_awd_yr_ci_sequence_number   IN               igs_fi_credits_all.awd_yr_ci_sequence_number%TYPE DEFAULT NULL,
                          p_fee_cal_type                IN               igs_fi_credits_all.fee_cal_type%TYPE DEFAULT NULL,
                          p_fee_ci_sequence_number      IN               igs_fi_credits_all.fee_ci_sequence_number%TYPE DEFAULT NULL,
                          p_d_gl_date                   IN               igs_fi_credits_all.gl_date%TYPE DEFAULT NULL,
                          /* Parameters added as part of bug:2191470 - sfcr020 */
                          x_credit_id                  OUT NOCOPY        igs_fi_credits_all.credit_id%TYPE,
                          x_credit_activity_id         OUT NOCOPY        igs_fi_cr_activities.credit_activity_id%TYPE,
                          x_return_status              OUT NOCOPY        VARCHAR2,
                          x_msg_count                  OUT NOCOPY        NUMBER,
                          x_msg_data                   OUT NOCOPY        VARCHAR2,
                          p_v_check_number             IN                VARCHAR2,
                          p_v_source_tran_type         IN                VARCHAR2,
                          p_v_source_tran_ref_number   IN                VARCHAR2,
			  p_v_credit_card_payee_cd     IN                VARCHAR2 DEFAULT NULL,
			  p_v_credit_card_status_code  IN                VARCHAR2 DEFAULT NULL,
			  p_v_credit_card_tangible_cd  IN                VARCHAR2 DEFAULT NULL,
                          p_lockbox_interface_id       IN                igs_fi_credits_all.lockbox_interface_id%TYPE DEFAULT NULL,
                          p_batch_name                 IN                igs_fi_credits_all.batch_name%TYPE DEFAULT NULL,
                          p_deposit_date               IN                igs_fi_credits_all.deposit_date%TYPE DEFAULT NULL
                          );

-- svuppala    Enh 4213629 - The automatic generation of the Receipt Number.
--                          Added a new procedure, create_credit with all the parameters of existing procedure
--                          excluding p_credit_number and adding additional OUT parameter, x_credit_number
-- Start of Comments
-- API Name               : Create_Credit
-- Type                   : Private
-- Pre-reqs               : None
-- Function               : Creates a credit in the credits and credit activities table
-- Parameters
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- IN                       p_credit_status
--                          This is the status of the credit record. It may be CLEARED or REVERSED
--                          and should be a valid value in the Lookups.
-- IN                       p_credit_source
--                          This is the credit source and should be a valid value in the Lookups (NON MANDATORY as PER SFCR020).
-- IN                       p_party_id
--                          This is the party id and should be present in the HZ_PARTIES table.
-- IN                       p_credit_type_id
--                          This parameter holds the value for the credit type. This should be a valid
--                          credit type set up in the IGS_FI_CR_TYPES table.
-- IN                       p_credit_instrument
--                          This parameter holds the value for the Credit Instrument. This should be a valid
--                          lookup with lookup type as "IGS_FI_CREDIT_INSTRUMENT".
-- IN                       p_description
-- IN                       p_amount
--                          This parameter holds the amount of the credit record.
-- IN                       p_currency_cd
--                          This parameter holds the currency code for the credit record. The API converts this
--                          to the local currency as all credit records should be present in the local currency.
-- IN                       p_exchange_rate
--                          This parameter holds the value for the exchange rate for the currency. If the currency is
--                          local currency, then the exchange rate is defaulted to 1.
-- IN                       p_transaction_date
--                          This parameter holds the value for the transaction date. If it is not provided then
--                          it is defaulted to sysdate.
-- IN                       p_effective_date
--                          This parameter holds the value for the effective date. If it is not provided then
--                          it is defaulted to the Transaction Date.
-- IN                       p_source_transaction_id
--                          This parameter holds the value for the source transaction. It would be used to keep the
--                          track for the imported AR Lockbox transactions.
-- IN                       p_subaccount_id(Removed the parameter p_subaccount_id as a part of Bug # 2564643)
--                          This parameter holds the value for the subaccount id which is used for identifying the
--                          subaccount associated with this transaction.
-- IN                       p_receipt_lockbox_number
--                          This parameter holds the value for the receipt lockbox number.
-- IN                       p_credit_card_code
--                          This parameter holds the value for the Credit Card Code which is a set up data defined in the
--                          Lookups.This is an optional parameter and can be null.
-- IN                       p_credit_card_holder_name
--                          This parameter holds the value for the Credit Card Holder Name and it can be null.
-- IN                       p_credit_card_number
--                          This parameter holds the value for the Credit Card Number.This is an optional parameter and can
--                          be defaulted to null.
-- IN                       p_credit_card_expiration_date
--                          This parameter holds the value for the Credit Card Expiration Date and is an optional parameter.
--                          If provided, this should be greater than or equal to the system date.
-- IN                       p_credit_card_approval_code
--                          This parameter holds the value for the Credit Card Approval Code and is an optional parameter.
-- IN                       p_attribute_record
-- IN                       p_invoice_id
--                          The invoice id of the Source Charge Transaction in the case of a Negative Adjustment related credit.
-- IN
-- IN			    p_awd_yr_cal_type
--                          Award Year cal type - mandatory if credit class is of Financial Aid
-- IN                       p_awd_yr_ci_sequence_number
--                          Award Year ci sequence  - mandatory if credit class is of f Financial Aid
-- IN			    p_fee_cal_type
--                          Fee cal type - mandatory if credit class is of Financial Aid
-- IN   		    p_fee_ci_sequence_number
--                          Fee Ci Sequnce number - mandatory if credit class is of Financial Aid
-- IN                       p_v_credit_card_payee_cd
--                          The credit card payee
-- IN                       p_v_credit_card_status_code
--                          The status of the Credit Card payment
-- IN                       p_v_credit_card_tangible_cd
--                          The tangible code generated, to be passed to iPayment, to identify the transaction
-- OUT                      x_credit_id
-- OUT                      x_credit_activity_id
-- OUT                      x_return_status
-- OUT                      x_msg_count
-- OUT                      x_msg_data
-- OUT                      x_credit_number
--                          This is the credit number that is automatically generated. The
--                          credit number is used for creating the records in the credits table
--                          and corresponds to the Credit_Number field of the IGS_FI_CREDITS_ALL
--                          table.
-- Version: Current Version 1.3
-- End of Comments

  /*#
 * The Credits API is a public API that is used internally or externally to create payment or credit information in the Student Finance module of Student System.
 * @param p_api_version The version number will be used to compare with this public api's current version number.Unexpected error is raised if version in-compatibility exists.
 * @param p_init_msg_list Set to FND_API.G_FALSE to have API automatically to initialize message list.
 * @param p_commit Set to FND_API.G_FALSE to have API to commit automatically.
 * @param p_party_id This is the Party Identifer, and should be present in the HZ_PARTIES table.
 * @param p_credit_status This is the status of the credit record. It may be CLEARED or REVERSED  and should be a valid value in the Lookups.
 * @param p_credit_source This is the credit source and should be a valid value in the Lookups.
 * @param p_credit_type_id This parameter holds the value for the credit type. This should be a valid credit type set up in the IGS_FI_CR_TYPES table.
 * @param p_credit_instrument This parameter holds the value for the Credit Instrument. This should be a valid lookup with lookup type as "IGS_FI_CREDIT_INSTRUMENT".
 * @param p_description Credit Description
 * @param p_amount This parameter holds the amount of the credit record.
 * @param p_currency_cd This parameter holds the currency code for the credit record. The API converts this to the local currency as all credit records should be present in the local currency
 * @param p_exchange_rate This parameter holds the value for the exchange rate for the currency. If the currency is local currency, then the exchange rate is defaulted to 1.
 * @param p_transaction_date This parameter holds the value for the transaction date. If it is not provided then it is defaulted to sysdate.
 * @param p_effective_date This parameter holds the value for the effective date. If it is not provided then it is defaulted to the Transaction Date.
 * @param p_source_transaction_id This parameter holds the value for the source transaction. It would be used to keep the track for the imported AR Lockbox transactions.
 * @param p_receipt_lockbox_number This parameter holds the value for the receipt lockbox number.
 * @param p_credit_card_code This parameter holds the value for the Credit Card Code which is a set up data defined in the Lookups.
 * @param p_credit_card_holder_name This parameter holds the value for the Credit Card Holder Name.
 * @param p_credit_card_number This parameter holds the value for the Credit Card Number.
 * @param p_credit_card_expiration_date This parameter holds the value for the Credit Card Expiration Date. If provided, this should be greater than or equal to the system date.
 * @param p_credit_card_approval_code This parameter holds the value for the Credit Card Approval Code.
 * @param p_attribute_record This parameter holds the values of the attributes of the credit record.
 * @param p_invoice_id The invoice ID of the Source Charge Transaction in the case of a Negative Adjustment related credit.
 * @param p_awd_yr_cal_type This is the Financial Aid Award Year calendar type and is mandatory if credit class is of Financial Aid
 * @param p_awd_yr_ci_sequence_number This is the Financial Aid Award Year sequence number and is mandatory if the credit class is of Financial Aid.
 * @param p_fee_cal_type This is the fee calendar type and is mandatory if the credit class is of Financial Aid.
 * @param p_fee_ci_sequence_number This is the fee calendar instance sequence number and is mandatory if the credit class is of Financial Aid.
 * @param p_d_gl_date The general ledger date.
 * @param x_credit_id The credit identifier.
 * @param x_credit_activity_id The credit activity identifier.
 * @param x_return_status The return status values are as follows; Success - FND_API.G_RET_STS_SUCCESS ; Error - FND_API.G_RET_STS_ERROR ; Unexpected error - FND_API.G_RET_STS_UNEXp_ERROR
 * @param x_msg_count The message count.
 * @param x_msg_data The message data.
 * @param p_v_check_number The check number.
 * @param p_v_source_tran_type The Source Transaction Type,
 * @param p_v_source_tran_ref_number The Source Transaction Reference Number,
 * @param p_v_credit_card_payee_cd The credit card payee.
 * @param p_v_credit_card_status_code The status of the Credit Card payment.
 * @param p_v_credit_card_tangible_cd The tangible code generated, to be passed to iPayment to identify the transaction.
 * @param p_lockbox_interface_id The lockbox interface ID.
 * @param p_batch_name The batch name.
 * @param p_deposit_date The deposit date.
 * @param x_credit_number The credit number.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Import Credits
 */
  PROCEDURE create_credit(p_api_version                 IN               NUMBER,
                          p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_credit_status               IN               igs_fi_credits_all.status%TYPE DEFAULT 'CLEARED',
                          p_credit_source               IN               igs_fi_credits_all.credit_source%TYPE DEFAULT NULL,
                          p_party_id                    IN               igs_fi_credits_all.party_id%TYPE,
                          p_credit_type_id              IN               igs_fi_credits_all.credit_type_id%TYPE,
                          p_credit_instrument           IN               igs_fi_credits_all.credit_instrument%TYPE,
                          p_description                 IN               igs_fi_credits_all.description%TYPE DEFAULT NULL,
                          p_amount                      IN               igs_fi_credits_all.amount%TYPE,
                          p_currency_cd                 IN               igs_fi_credits_all.currency_cd%TYPE DEFAULT NULL,
                          p_exchange_rate               IN               igs_fi_credits_all.exchange_rate%TYPE DEFAULT 1,
                          p_transaction_date            IN               igs_fi_credits_all.transaction_date%TYPE DEFAULT NULL,
                          p_effective_date              IN               igs_fi_credits_all.effective_date%TYPE DEFAULT NULL,
                          p_source_transaction_id       IN               igs_fi_credits_all.source_transaction_id%TYPE DEFAULT NULL,
                          p_receipt_lockbox_number      IN               igs_fi_credits_all.receipt_lockbox_number%TYPE DEFAULT NULL,
                          p_credit_card_code            IN               igs_fi_credits_all.credit_card_code%TYPE DEFAULT NULL,
                          p_credit_card_holder_name     IN               igs_fi_credits_all.credit_card_holder_name%TYPE DEFAULT NULL,
                          p_credit_card_number          IN               igs_fi_credits_all.credit_card_number%TYPE DEFAULT NULL,
                          p_credit_card_expiration_date IN               igs_fi_credits_all.credit_card_expiration_date%TYPE DEFAULT NULL,
                          p_credit_card_approval_code   IN               igs_fi_credits_all.credit_card_approval_code%TYPE DEFAULT NULL,
                          p_attribute_record            IN               attribute_rec_type DEFAULT NULL,
                          p_invoice_id                  IN               igs_fi_inv_int_all.invoice_id%TYPE DEFAULT NULL,
                          p_awd_yr_cal_type             IN               igs_fi_credits_all.awd_yr_cal_type%TYPE DEFAULT NULL,
                          p_awd_yr_ci_sequence_number   IN               igs_fi_credits_all.awd_yr_ci_sequence_number%TYPE DEFAULT NULL,
                          p_fee_cal_type                IN               igs_fi_credits_all.fee_cal_type%TYPE DEFAULT NULL,
                          p_fee_ci_sequence_number      IN               igs_fi_credits_all.fee_ci_sequence_number%TYPE DEFAULT NULL,
                          p_d_gl_date                   IN               igs_fi_credits_all.gl_date%TYPE DEFAULT NULL,
                          x_credit_id                  OUT NOCOPY        igs_fi_credits_all.credit_id%TYPE,
                          x_credit_activity_id         OUT NOCOPY        igs_fi_cr_activities.credit_activity_id%TYPE,
                          x_return_status              OUT NOCOPY        VARCHAR2,
                          x_msg_count                  OUT NOCOPY        NUMBER,
                          x_msg_data                   OUT NOCOPY        VARCHAR2,
                          p_v_check_number             IN                VARCHAR2,
                          p_v_source_tran_type         IN                VARCHAR2,
                          p_v_source_tran_ref_number   IN                VARCHAR2,
			  p_v_credit_card_payee_cd     IN                VARCHAR2 DEFAULT NULL,
			  p_v_credit_card_status_code  IN                VARCHAR2 DEFAULT NULL,
			  p_v_credit_card_tangible_cd  IN                VARCHAR2 DEFAULT NULL,
                          p_lockbox_interface_id       IN                igs_fi_credits_all.lockbox_interface_id%TYPE DEFAULT NULL,
                          p_batch_name                 IN                igs_fi_credits_all.batch_name%TYPE DEFAULT NULL,
                          p_deposit_date               IN                igs_fi_credits_all.deposit_date%TYPE DEFAULT NULL,
                          x_credit_number              OUT NOCOPY        igs_fi_credits_all.credit_number%TYPE
                          );


END igs_fi_credits_api_pub;

 

/
