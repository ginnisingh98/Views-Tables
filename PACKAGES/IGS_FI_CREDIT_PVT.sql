--------------------------------------------------------
--  DDL for Package IGS_FI_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CREDIT_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSFI83S.pls 120.2 2005/07/27 12:53:29 appldev ship $ */

/*----------------------------------------------------------------------------
  ||  Created By : vvutukur
  ||  Created On : 03-Apr-2003
  ||  Purpose    : Private Credits API.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pmarada          6-Jul-2005     Enh 3392095 Modified as per the Tuition Waivers Build, added p_waiver_name
  ||                                  parameter to the credit_rec_type record type, and incremented the l_api_version by 0.1
  ||  svuppala         9-JUN-2005     Enh 4213629 - The automatic generation of the Receipt Number.
  ||                                  Added x_credit_number OUT parameter
  ||  vvutukur        16-Jun-2003     Enh#2831582.Lockbox Build. Added 3 new parameters lockbox_interface_id,batch_name,deposit_date
  ||                                  for credit_rec_type record type variable.
  ||  schodava        11-Jun-2003     Enh # 2831587. Credit Card Fund Transfer Build
  ||                                  Modified the credit_rec_type record
----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name               : create_credit
-- Type                   : Private
-- Function               : Creates a credit in the credits and credit activities table.
-- Pre-reqs               : None
-- Parameters             :
-- IN                     :
--                           p_api_version                 IN            NUMBER                              Required
--                             This parameter specifies the current version number of the API.
--                           p_init_msg_list               IN            VARCHAR2 DEFAULT FND_API.G_FALSE,   Optional
--                              This parameter is message stack initialization parameter.
--                              Default value FND_API.G_FALSE.
--                           p_commit                      IN            VARCHAR2 DEFAULT FND_API.G_FALSE,   Optional
--                             This is Standard API Parameter to check if the current transactions have to be committed explicitly.
--                             Default value FND_API.G_FALSE
--                           p_validation_level            IN            NUMBER,                            Optional
--                             Depending on this parameter, parameter validations are performed.
--                             Default value FND_API.G_VALID_LEVEL_NONE.
--                           p_credit_rec                  IN            credit_rec_type,                    Required
--                             This parameter is of record type which consists of credit transaction Input parameters.
--                           p_attribute_record            IN            igs_fi_credits_api_pub.attribute_rec_type. Optional
--                             This parametes is of record type and specifies the Descriptive flexfield attributes input parameters.
--
-- OUT                    :
--                           x_return_status               OUT NOCOPY    VARCHAR2,
--                             This is standard API out Parameter to convey API return status.
--                           x_msg_count                   OUT NOCOPY    NUMBER,
--                             This is standard API out Parameter contains message count returned by the API.
--                           x_msg_data                    OUT NOCOPY    VARCHAR2,
--                             This is standard API out Parameter that contains the messages in the encoded format. User has to decode the error messages
--                             when they want to see the actual message text.
--                           x_credit_id                   OUT NOCOPY    igs_fi_credits_all.credit_id%TYPE,
--                             This out parameter contains the identifier for the credit transaction that got created.
--                           x_credit_activity_id          OUT NOCOPY    igs_fi_cr_activities.credit_activity_id%TYPE
--                             This out parameter contains the identifier for the credit activity transaction that got created.
--                           x_credit_number               OUT NOCOPY    igs_fi_credits_all.credit_number%TYPE
--                             This out parameter contains the creditreceipt number for the credit transaction that got created.
--
-- Version                : Current Version 2.1
--                          Current Version 1.2
--                          Initial Version 1.0
-- Notes                  :
--
-- End of Comments

TYPE credit_rec_type IS RECORD(     p_credit_status                igs_fi_credits_all.status%TYPE,
                                    p_credit_source                igs_fi_credits_all.credit_source%TYPE,
                                    p_party_id                     igs_fi_credits_all.party_id%TYPE,
                                    p_credit_type_id               igs_fi_credits_all.credit_type_id%TYPE,
                                    p_credit_instrument            igs_fi_credits_all.credit_instrument%TYPE,
                                    p_description                  igs_fi_credits_all.description%TYPE,
                                    p_amount                       igs_fi_credits_all.amount%TYPE,
                                    p_currency_cd                  igs_fi_credits_all.currency_cd%TYPE,
                                    p_exchange_rate                igs_fi_credits_all.exchange_rate%TYPE,
                                    p_transaction_date             igs_fi_credits_all.transaction_date%TYPE,
                                    p_effective_date               igs_fi_credits_all.effective_date%TYPE,
                                    p_source_transaction_id        igs_fi_credits_all.source_transaction_id%TYPE,
                                    p_receipt_lockbox_number       igs_fi_credits_all.receipt_lockbox_number%TYPE,
                                    p_credit_card_code             igs_fi_credits_all.credit_card_code%TYPE,
                                    p_credit_card_holder_name      igs_fi_credits_all.credit_card_holder_name%TYPE,
                                    p_credit_card_number           igs_fi_credits_all.credit_card_number%TYPE,
                                    p_credit_card_expiration_date  igs_fi_credits_all.credit_card_expiration_date%TYPE,
                                    p_credit_card_approval_code    igs_fi_credits_all.credit_card_approval_code%TYPE,
                                    p_invoice_id                   igs_fi_inv_int_all.invoice_id%TYPE,
                                    p_awd_yr_cal_type              igs_fi_credits_all.awd_yr_cal_type%TYPE,
                                    p_awd_yr_ci_sequence_number    igs_fi_credits_all.awd_yr_ci_sequence_number%TYPE,
                                    p_fee_cal_type                 igs_fi_credits_all.fee_cal_type%TYPE,
                                    p_fee_ci_sequence_number       igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                                    p_check_number                 igs_fi_credits_all.check_number%TYPE,
                                    p_source_tran_type             igs_fi_credits_all.source_transaction_type%TYPE,
                                    p_source_tran_ref_number       igs_fi_credits_all.source_transaction_ref%TYPE,
                                    p_gl_date                      igs_fi_credits_all.gl_date%TYPE,
				    p_v_credit_card_payee_cd       igs_fi_credits_all.credit_card_payee_cd%TYPE,
				    p_v_credit_card_status_code    igs_fi_credits_all.credit_card_status_code%TYPE,
				    p_v_credit_card_tangible_cd    igs_fi_credits_all.credit_card_tangible_cd%TYPE,
                                    p_lockbox_interface_id         igs_fi_credits_all.lockbox_interface_id%TYPE,
                                    p_batch_name                   igs_fi_credits_all.batch_name%TYPE,
                                    p_deposit_date                 igs_fi_credits_all.deposit_date%TYPE,
                                    p_waiver_name                  igs_fi_credits_all.waiver_name%TYPE
			       );


PROCEDURE create_credit(  p_api_version                 IN            NUMBER,
                          p_init_msg_list               IN            VARCHAR2 DEFAULT fnd_api.g_false,
                          p_commit                      IN            VARCHAR2 DEFAULT fnd_api.g_false,
                          p_validation_level            IN            NUMBER DEFAULT fnd_api.g_valid_level_none,
                          x_return_status               OUT NOCOPY    VARCHAR2,
                          x_msg_count                   OUT NOCOPY    NUMBER,
                          x_msg_data                    OUT NOCOPY    VARCHAR2,
                          p_credit_rec                  IN            credit_rec_type,
                          p_attribute_record            IN            igs_fi_credits_api_pub.attribute_rec_type DEFAULT NULL,
                          x_credit_id                   OUT NOCOPY    igs_fi_credits_all.credit_id%TYPE,
                          x_credit_activity_id          OUT NOCOPY    igs_fi_cr_activities.credit_activity_id%TYPE,
                          x_credit_number               OUT NOCOPY    igs_fi_credits_all.credit_number%TYPE);

END igs_fi_credit_pvt;

 

/
