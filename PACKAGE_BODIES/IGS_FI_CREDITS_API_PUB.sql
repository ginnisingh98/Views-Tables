--------------------------------------------------------
--  DDL for Package Body IGS_FI_CREDITS_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CREDITS_API_PUB" AS
/* $Header: IGSFI54B.pls 120.5 2005/07/27 13:00:04 appldev ship $ */


/*Change History

Who         When        What
pmarada    26-JUL-2005  Enh 3392095, modifed as per tution waiver build, passing p_api_version
                        parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
svuppala   9-JUN-2005    Enh 4213629 - The automatic generation of the Receipt Number.
                         Added a new procedure, create_credit with all the parameters of existing procedure
                         and additional OUT parameter, x_credit_number
vvutukur   16-Jun-2003   Enh#2831582.Lockbox Build.Modified procedure create_credit.
schodava   11-Jun-2003   Enh # 2831587. Added 3 new parameters to the Public API
vvutukur   04-Apr-2003   Enh#2831554. Internal Credits API Build. Rewritten the code by placing a call to igs_fi_credit_pvt.create_credit and
                         removing earlier the code.
vvutukur   11-Dec-2002   Enh#2584741.Removed parameter p_validation_level and Added 3 new parameters p_v_check_number,
                         p_v_source_tran_type,p_v_source_tran_ref_number in create_credit procedure.Modified
                         validate_credit_type,created local functions validate_unique_enrdeposit, validate_dep_crtype
                         and changes as specified in TD.
vvutukur   23-Nov-2002  Enh#2584986.Added local function validate_gl_date.Modifications done in create_credit.
                        Removed local procedure get_local_curr and modified validate_cur.
vvutukur   07-Oct-2002  Enh#2562745.Reassess Balances Build. Modifications done in create_credit
                        procedure and validate_lkp function.
smvk       16-Sep-2002  Removed the parameter subaccount_id and the associated code as a part of Bug # 2564643.
                        Removed the default used in this api to overcome gscc warnings.
smadathi   03-Jul-2002   Bug 2443082. Modified create_credit procedure call.
vchappid    13-Jun-2002 Bug#2411529, Incorrectly used message name has been modified
vvutukur    27-02-2002  removed local function validate_person and called generic function
                        igs_fi_gen_007.validate_person in create_credit procedure.as part of bug:2238362
------------------------------------------------------------------------------------------*/

  PROCEDURE create_credit(p_api_version                 IN               NUMBER,
                          p_init_msg_list               IN               VARCHAR2,
                          p_commit                      IN               VARCHAR2,
                          p_credit_number               IN               igs_fi_credits_all.credit_number%TYPE,
                          p_credit_status               IN               igs_fi_credits_all.status%TYPE ,
                          p_credit_source               IN               igs_fi_credits_all.credit_source%TYPE,
                          p_party_id                    IN               igs_fi_credits_all.party_id%TYPE,
                          p_credit_type_id              IN               igs_fi_credits_all.credit_type_id%TYPE,
                          p_credit_instrument           IN               igs_fi_credits_all.credit_instrument%TYPE,
                          p_description                 IN               igs_fi_credits_all.description%TYPE,
                          p_amount                      IN               igs_fi_credits_all.amount%TYPE,
                          p_currency_cd                 IN               igs_fi_credits_all.currency_cd%TYPE,
                          p_exchange_rate               IN               igs_fi_credits_all.exchange_rate%TYPE,
                          p_transaction_date            IN               igs_fi_credits_all.transaction_date%TYPE,
                          p_effective_date              IN               igs_fi_credits_all.effective_date%TYPE,
                          p_source_transaction_id       IN               igs_fi_credits_all.source_transaction_id%TYPE,
                        /* Removed the parameter p_subaccount_id as a part of Bug # 2564643 */
                          p_receipt_lockbox_number      IN               igs_fi_credits_all.receipt_lockbox_number%TYPE,
                          p_credit_card_code            IN               igs_fi_credits_all.credit_card_code%TYPE,
                          p_credit_card_holder_name     IN               igs_fi_credits_all.credit_card_holder_name%TYPE,
                          p_credit_card_number          IN               igs_fi_credits_all.credit_card_number%TYPE,
                          p_credit_card_expiration_date IN               igs_fi_credits_all.credit_card_expiration_date%TYPE,
                          p_credit_card_approval_code   IN               igs_fi_credits_all.credit_card_approval_code%TYPE,
                          p_attribute_record            IN               attribute_rec_type,
                          p_invoice_id                  IN               igs_fi_inv_int_all.invoice_id%TYPE,--bug:2195715
                        /* Parameters added as part of bug:2191470 - sfcr020 */
                          p_awd_yr_cal_type             IN               igs_fi_credits_all.awd_yr_cal_type%TYPE,
                          p_awd_yr_ci_sequence_number   IN               igs_fi_credits_all.awd_yr_ci_sequence_number%TYPE,
                          p_fee_cal_type                IN               igs_fi_credits_all.fee_cal_type%TYPE,
                          p_fee_ci_sequence_number      IN               igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                          p_d_gl_date                   IN               igs_fi_credits_all.gl_date%TYPE,
                          /* Parameters added as part of bug:2191470 - sfcr020 */
                          x_credit_id                  OUT NOCOPY        igs_fi_credits_all.credit_id%TYPE,
                          x_credit_activity_id         OUT NOCOPY        igs_fi_cr_activities.credit_activity_id%TYPE,
                          x_return_status              OUT NOCOPY        VARCHAR2,
                          x_msg_count                  OUT NOCOPY        NUMBER,
                          x_msg_data                   OUT NOCOPY        VARCHAR2,
                          p_v_check_number             IN                VARCHAR2,
                          p_v_source_tran_type         IN                VARCHAR2,
                          p_v_source_tran_ref_number   IN                VARCHAR2,
			  p_v_credit_card_payee_cd     IN                VARCHAR2,
			  p_v_credit_card_status_code  IN                VARCHAR2,
			  p_v_credit_card_tangible_cd  IN                VARCHAR2,
                          p_lockbox_interface_id       IN                igs_fi_credits_all.lockbox_interface_id%TYPE,
                          p_batch_name                 IN                igs_fi_credits_all.batch_name%TYPE,
                          p_deposit_date               IN                igs_fi_credits_all.deposit_date%TYPE
                          )AS
/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    05-05-2001

Purpose:            This procedure is the main api call.

Known limitations,enhancements,remarks:

Change History

Who         When           What
svuppala   9-JUN-2005    Enh 4213629 - The automatic generation of the Receipt Number.
                         Removed all the logic and  called new create_credit procedure with added x_credit_number.
vvutukur   16-Jun-2003   Enh#2831582.Lockbox Build. Added 3 new parameters lockbox_interface_id,batch_name,deposit_date.
schodava   11-Jun-2003   Enh# 2831587. Added 3 new parameters to the Public API
vvutukur   04-Apr-2003   Enh#2831554. Internal Credits API Build. Rewritten the code by placing a call to igs_fi_credit_pvt.create_credit and
                         removing earlier the code.
vvutukur   11-Dec-2002   Enh#2584741.Removed parameter p_validation_level. Added 3 new parameters p_v_check_number,
                         p_v_source_tran_type,p_v_source_tran_ref_number.
vvutukur   23-Nov-2002   Enh#2584986.Added new parameter p_d_gl_date and validated.Passed p_d_gl_date to the call to
                         igs_fi_credits_pkg.insert_row,and p_d_gl_date,gl_posted_date,posting_control_id to the call
                         to igs_fi_crd_activities_pkg.insert_row. Modified the logic of validation of currency_cd
                         and calculation of exchange_rate as exchange has been made mandatory if currency passed is
                         other than local currency specified in System Options Form. If currency is passed is same
                         as the one that is specified in System Options form, exchange rate is non-mandatory
                         and even if it is passed with some value, it will be ignored and has been considered as 1.
vvutukur   07-Oct-2002   Enh#2562745.1)Added two validations to error out NOCOPY of credits api a)if this procedure
                         is called while holds conversion process is running b)if no active balance rule
                         exists for HOLDS.2)Added code to call Update_balances procedure to update/create
                         Holds balance in igs_fi_balances table real time whenever a credit gets created
                         (just like STANDARD balance real time updation).
smvk       16-Sep-2002   Removed the parameter p_subaccount_id as a part of Bug # 2564643
                         Removed the local paramter l_psa.
smadathi   03-Jul-2002   Bug 2443082. Modified update_balances procedure call. Modified to pass transaction date
                         instead of system date.
vchappid   13-Jun-2002   Bug#2411529, Incorrectly used message name has been modified
SYKRISHN   19-APR-2002   Bug 2324088 - Introduced Desc Flex Field Validations.
vvutukur   27-02-2002    placed call to igs_fi_gen_007.validate_person instead of calling local function
                         validate_person.for bug:2238362
jbegum     12-Feb-2001   As part of Enh bug # 2201081
                         Added call to IGS_FI_GEN_005.validate_psa and IGS_FI_PARTY_SA_PKG.insert_row
sykrishn   4-FEB-2002    Added the new IN parameters p_awd_yr_cal_type,p_awd_yr_ci_sequence_number,p_fee_cal_type,p_fee_ci_sequence_number
                         These parameters are mandatory when  the Credit Class is Of Internal or External Financial Aid
                         Changes realted to credit source- refer DLD - sfcr020
                        Validations for Fee Period - LCI relation
                        IGS_LOOKUPS -check for credit source

vvutukur   31-Jan-2002   Added new parameter p_invoice_id and logic,if accounting method is ACCRUAL,
                         the default clearing account defined for the Adjustment Credit type gets
                         overridden by the revenue account of the charge being adjusted.
sarakshi   18-dec-2001   Removed the parameters p_source_date,p_fee_type,p_credit_type_id from
                         the call to procedure Update_Balances and added parameter p_source_id
                         as a part of Enh. bug:2124001
sarakshi   8-oct-2001    Replaced procedure igs_fi_prc_balances.calculate_balances with
                         igs_fi_prc_balances.update_balances also removed balance_flag parameter
                         from call to insert row of credits table.bug no:2030448
msrinivi  13 Aug,2001    Call to build process to populate rev/rec ccid/code before
                         inserting intoigs_fi_activities table
********************************************************************************************** */

  l_credit_number                igs_fi_credits_all.credit_number%TYPE;

  BEGIN

   create_credit(  p_api_version                     =>   p_api_version,
                   p_init_msg_list                   =>	  p_init_msg_list,
                   p_commit                          =>   p_commit ,
                   p_credit_status                   =>	  p_credit_status  ,
                   p_credit_source                   =>	  p_credit_source   ,
                   p_party_id                        =>   p_party_id    ,
                   p_credit_type_id                  =>   p_credit_type_id   ,
                   p_credit_instrument               =>   p_credit_instrument ,
                   p_description                     =>   p_description       ,
                   p_amount                          =>   p_amount            ,
                   p_currency_cd		     =>   p_currency_cd       ,
                   p_exchange_rate                   =>	  p_exchange_rate     ,
                   p_transaction_date                =>   p_transaction_date  ,
                   p_effective_date                  =>   p_effective_date    ,
                   p_source_transaction_id           =>   p_source_transaction_id  ,
                   p_receipt_lockbox_number          =>   p_receipt_lockbox_number ,
                   p_credit_card_code                =>   p_credit_card_code       ,
                   p_credit_card_holder_name         =>   p_credit_card_holder_name,
                   p_credit_card_number              =>   p_credit_card_number     ,
                   p_credit_card_expiration_date     =>   p_credit_card_expiration_date ,
                   p_credit_card_approval_code       =>   p_credit_card_approval_code   ,
                   p_attribute_record                =>   p_attribute_record            ,
                   p_invoice_id              	     =>   p_invoice_id                  ,
                   p_awd_yr_cal_type                 =>   p_awd_yr_cal_type             ,
                   p_awd_yr_ci_sequence_number       =>   p_awd_yr_ci_sequence_number   ,
                   p_fee_cal_type                    =>   p_fee_cal_type                ,
                   p_fee_ci_sequence_number          =>   p_fee_ci_sequence_number      ,
                   p_d_gl_date             	     =>   p_d_gl_date                   ,
                   x_credit_id             	     =>   x_credit_id                   ,
                   x_credit_activity_id        	     =>   x_credit_activity_id          ,
                   x_return_status             	     =>   x_return_status               ,
                   x_msg_count             	     =>   x_msg_count                   ,
                   x_msg_data              	     =>   x_msg_data                    ,
                   p_v_check_number            	     =>   p_v_check_number              ,
                   p_v_source_tran_type        	     =>   p_v_source_tran_type          ,
                   p_v_source_tran_ref_number  	     =>   p_v_source_tran_ref_number    ,
                   p_v_credit_card_payee_cd          =>   p_v_credit_card_payee_cd      ,
                   p_v_credit_card_status_code       =>   p_v_credit_card_status_code   ,
                   p_v_credit_card_tangible_cd       =>   p_v_credit_card_tangible_cd   ,
                   p_lockbox_interface_id      	     =>   p_lockbox_interface_id        ,
                   p_batch_name                      =>   p_batch_name                  ,
                   p_deposit_date              	     =>   p_deposit_date                ,
                   x_credit_number             	     =>   l_credit_number
                   );

  END create_credit;


  PROCEDURE create_credit(p_api_version                 IN               NUMBER,
                          p_init_msg_list               IN               VARCHAR2,
                          p_commit                      IN               VARCHAR2,
                          p_credit_status               IN               igs_fi_credits_all.status%TYPE ,
                          p_credit_source               IN               igs_fi_credits_all.credit_source%TYPE,
                          p_party_id                    IN               igs_fi_credits_all.party_id%TYPE,
                          p_credit_type_id              IN               igs_fi_credits_all.credit_type_id%TYPE,
                          p_credit_instrument           IN               igs_fi_credits_all.credit_instrument%TYPE,
                          p_description                 IN               igs_fi_credits_all.description%TYPE,
                          p_amount                      IN               igs_fi_credits_all.amount%TYPE,
                          p_currency_cd                 IN               igs_fi_credits_all.currency_cd%TYPE,
                          p_exchange_rate               IN               igs_fi_credits_all.exchange_rate%TYPE,
                          p_transaction_date            IN               igs_fi_credits_all.transaction_date%TYPE,
                          p_effective_date              IN               igs_fi_credits_all.effective_date%TYPE,
                          p_source_transaction_id       IN               igs_fi_credits_all.source_transaction_id%TYPE,
                          p_receipt_lockbox_number      IN               igs_fi_credits_all.receipt_lockbox_number%TYPE,
                          p_credit_card_code            IN               igs_fi_credits_all.credit_card_code%TYPE,
                          p_credit_card_holder_name     IN               igs_fi_credits_all.credit_card_holder_name%TYPE,
                          p_credit_card_number          IN               igs_fi_credits_all.credit_card_number%TYPE,
                          p_credit_card_expiration_date IN               igs_fi_credits_all.credit_card_expiration_date%TYPE,
                          p_credit_card_approval_code   IN               igs_fi_credits_all.credit_card_approval_code%TYPE,
                          p_attribute_record            IN               attribute_rec_type,
                          p_invoice_id                  IN               igs_fi_inv_int_all.invoice_id%TYPE,
                          p_awd_yr_cal_type             IN               igs_fi_credits_all.awd_yr_cal_type%TYPE,
                          p_awd_yr_ci_sequence_number   IN               igs_fi_credits_all.awd_yr_ci_sequence_number%TYPE,
                          p_fee_cal_type                IN               igs_fi_credits_all.fee_cal_type%TYPE,
                          p_fee_ci_sequence_number      IN               igs_fi_credits_all.fee_ci_sequence_number%TYPE,
                          p_d_gl_date                   IN               igs_fi_credits_all.gl_date%TYPE,
                          x_credit_id                  OUT NOCOPY        igs_fi_credits_all.credit_id%TYPE,
                          x_credit_activity_id         OUT NOCOPY        igs_fi_cr_activities.credit_activity_id%TYPE,
                          x_return_status              OUT NOCOPY        VARCHAR2,
                          x_msg_count                  OUT NOCOPY        NUMBER,
                          x_msg_data                   OUT NOCOPY        VARCHAR2,
                          p_v_check_number             IN                VARCHAR2,
                          p_v_source_tran_type         IN                VARCHAR2,
                          p_v_source_tran_ref_number   IN                VARCHAR2,
			  p_v_credit_card_payee_cd     IN                VARCHAR2,
			  p_v_credit_card_status_code  IN                VARCHAR2,
			  p_v_credit_card_tangible_cd  IN                VARCHAR2,
                          p_lockbox_interface_id       IN                igs_fi_credits_all.lockbox_interface_id%TYPE,
                          p_batch_name                 IN                igs_fi_credits_all.batch_name%TYPE,
                          p_deposit_date               IN                igs_fi_credits_all.deposit_date%TYPE,
                          x_credit_number              OUT NOCOPY        igs_fi_credits_all.credit_number%TYPE
                          )AS

/***********************************************************************************************

Created By:         Sunil Vuppala

Date Created By:    10-06-2005

Purpose:            This procedure is the modified api call.
                    Enh 4213629 - The automatic generation of the Receipt Number.

Known limitations,enhancements,remarks:

Change History

Who         When           What

********************************************************************************************** */

l_pkg_name           CONSTANT    VARCHAR2(30) := 'IGS_FI_CREDITS_API_PUB';
l_api_name           CONSTANT    VARCHAR2(30) := 'create_credit';
l_api_version        CONSTANT    NUMBER       := 1.3;

l_credit_rec         igs_fi_credit_pvt.credit_rec_type;
l_attribute_rec_type attribute_rec_type;


  BEGIN

    SAVEPOINT create_credit_pub;

    --Check for the Compatible API call.
    IF NOT fnd_api.compatible_api_call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        l_pkg_name) THEN
      --if the versions of the API and the version passed are different then raise the unexpected error message.
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --If the calling program has passed the parameter for initializing the message list.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      --then call the Initialize program of the fnd_msg_pub package.
      fnd_msg_pub.initialize;
    END IF;

    l_credit_rec.p_credit_status              := p_credit_status;
    l_credit_rec.p_credit_source              := p_credit_source;
    l_credit_rec.p_party_id                   := p_party_id;
    l_credit_rec.p_credit_type_id             := p_credit_type_id;
    l_credit_rec.p_credit_instrument          := p_credit_instrument;
    l_credit_rec.p_description                := p_description;
    l_credit_rec.p_amount                     := p_amount;
    l_credit_rec.p_currency_cd                := p_currency_cd;
    l_credit_rec.p_exchange_rate              := p_exchange_rate;
    l_credit_rec.p_transaction_date           := p_transaction_date;
    l_credit_rec.p_effective_date             := p_effective_date;
    l_credit_rec.p_source_transaction_id      := p_source_transaction_id;
    l_credit_rec.p_receipt_lockbox_number     := p_receipt_lockbox_number;
    l_credit_rec.p_credit_card_code           := p_credit_card_code;
    l_credit_rec.p_credit_card_holder_name    := p_credit_card_holder_name;
    l_credit_rec.p_credit_card_number         := p_credit_card_number;
    l_credit_rec.p_credit_card_expiration_date:= p_credit_card_expiration_date;
    l_credit_rec.p_credit_card_approval_code  := p_credit_card_approval_code;
    l_credit_rec.p_invoice_id                 := p_invoice_id;
    l_credit_rec.p_awd_yr_cal_type            := p_awd_yr_cal_type;
    l_credit_rec.p_awd_yr_ci_sequence_number  := p_awd_yr_ci_sequence_number;
    l_credit_rec.p_fee_cal_type               := p_fee_cal_type;
    l_credit_rec.p_fee_ci_sequence_number     := p_fee_ci_sequence_number;
    l_credit_rec.p_check_number               := p_v_check_number;
    l_credit_rec.p_source_tran_type           := p_v_source_tran_type;
    l_credit_rec.p_source_tran_ref_number     := p_v_source_tran_ref_number;
    l_credit_rec.p_gl_date                    := p_d_gl_date;
    l_credit_rec.p_v_credit_card_payee_cd     := p_v_credit_card_payee_cd;
    l_credit_rec.p_v_credit_card_status_code  := p_v_credit_card_status_code;
    l_credit_rec.p_v_credit_card_tangible_cd  := p_v_credit_card_tangible_cd;
    l_credit_rec.p_lockbox_interface_id       := p_lockbox_interface_id;
    l_credit_rec.p_batch_name                 := p_batch_name;
    l_credit_rec.p_deposit_date               := p_deposit_date;

    l_attribute_rec_type := p_attribute_record;

    --Call the private api with full validation_level.
    igs_fi_credit_pvt.create_credit( p_api_version            => 2.1,
                                     p_init_msg_list          => p_init_msg_list,
                                     p_commit                 => p_commit,
                                     p_validation_level       => fnd_api.g_valid_level_full,
                                     x_return_status          => x_return_status,
                                     x_msg_count              => x_msg_count,
                                     x_msg_data               => x_msg_data,
                                     p_credit_rec             => l_credit_rec,
                                     p_attribute_record       => l_attribute_rec_type,
                                     x_credit_id              => x_credit_id,
                                     x_credit_activity_id     => x_credit_activity_id,
                                     x_credit_number          => x_credit_number
                                    );
    EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_credit_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_credit_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_credit_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(l_pkg_name,
                                l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);
  END create_credit;


END igs_fi_credits_api_pub;

/
