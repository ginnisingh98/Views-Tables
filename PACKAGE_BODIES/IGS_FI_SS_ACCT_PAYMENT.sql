--------------------------------------------------------
--  DDL for Package Body IGS_FI_SS_ACCT_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_SS_ACCT_PAYMENT" AS
/* $Header: IGSFI63B.pls 120.7 2006/06/27 14:14:35 skharida ship $ */
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --skharida  26-Jun-2006      Bug 5208136: Modified  finp_decline_Optional_fee and finp_set_optional_fee_flag procedures
  --                           removed the obseleted columns of IGS_FI_INV_INT_ALL.
  --gurprsin   6-Dec-2005       Bug 4735807, Modified the finp_calc_fees_todo method, Added a condition to skip the addition of message onto the stack as it is already added in
  --                            finp_ins_enr_fee_ass method for the case ' if no fee category is attached to the SPA.'. Otherwise a null message
  --                            will be added and shown on the SS page.
  --gurprsin    13-Sep-2005    Bug 3765876, Modified the Cursor c_get_msg_text select statement to add userenv. language condition with application id
  --bannamal   26-Aug-2005     Enh#3392095 Tuition Waiver Build. Modified the call to finp_ins_enr_fee_ass
  --                           to include two new parameters.
  --svuppala  04-AUG-2005      Enh 3392095 - Tution Waivers build
  --                           Impact of Charges API version Number change
  --                           Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  --pmarada    26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
  --                           parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  -- svuppala   9-JUN-2005     Enh 3442712 - Impact of automatic generation of the Receipt Number.
  --                           changed logic for credit_number in procedure create_cc_credit.
  --pathipat    21-Apr-2004    Enh 3558549 - Comm Receivables Enh
  --                           Modified update_cc_credit() - added param x_source_invoice_id
  --                           in call to igs_fi_credits_pkg.update_row()
  --schodava   21-Jan-2004     Bug # 3062706 - Modified procedure finp_calc_fees_todo
  --vvutukur   04-Dec-2003     Bug#3249288.Modified proceudure finp_set_optional_fee_flag.
  --pathipat   06-Nov-2003     Enh 3117341 - Audit and Special Fees TD
  --                           Modified finp_calc_fees_todo()
  --vvutukur   26-Sep-2003     Enh#3045007.Payment Plans Build.Changes specific to TD.
  --pathipat   19-Aug-2003     Enh 3076768 - Automatic Release of Holds build
  --                           Modified create_cc_credit
  --smadathi   01-jul-2003     Bug 3029782. Modified the procedure create_cc_credit.
  --vvutukur   16-Jun-2003     Enh#2831582.Lockbox Build.Modified create_cc_credit,update_cc_credit.
  --schodava   16-Jun-2003     Enh 2381587 - Credit Card Fund Transfer Build.
  --                           Modified procedures create_cc_credit, update_cc_credit
  --pathipat   04-Jun-2003     Enh. 2831584- SS Enhancements build
  --                           Modified procedures create_cc_credit() and finp_set_optional_fee_flag()
  --smadathi   03-jun-2002     Enh. Bug 2831584. Added new function get_msg_text
  --smadathi   28-MAY-2003     Bug 2849142. Modified procedure finp_calc_fees_todo
  --shtatiko   09-APR-2003     Enh# 2831554, modified procedure create_cc_credit
  --vchappid   14-Mar-2003     Bug#2849142,In procedure finp_calc_fees_todo, Only one error message has to be shown
  --                           to the user when any error occurs.
  --schodava   7-Jan-2003      Bug # 2662124. SQLs using literals is against performance standards.
  --                           Modified cursor c_credit_inst_cd to use cursor parameters.
  --vvutukur   13-Dec-2002     Enh#2584741.Modified procedures create_cc_credit,update_cc_credit.
  --vchappid   02-Dec-2002     Enh#2584986, NOCOPY is manually added for x_return_status parameter in procedure update_cc_credit
  --vvutukur   15-Nov-2002     Enh#2584986.Modified procedures finp_decline_Optional_fee,create_cc_credit,
  --                           finp_set_optional_fee_flag,update_cc_credit.
  --smadathi   06-Nov-2002     Enh. Bug 2584986. Removed procedure create_posting_int. Modified
  --                           finp_calc_fees_todo procedure .
  --vvutukur   16-Sep-2002     Enh#2564643.Removed references to subaccount_id from CREATE_CC_CREDIT,
  --                           UPDATE_CC_CREDIT,FINP_DECLINE_OPTIONAL_FEE,FINP_SET_OPTIONAL_FEE_FLAG.
 --                         In finp_calc_fees_todo procedure,removed DEFAULT from procedure parameters
 --                            to avoid gscc warning.
  --smadathi   24-Jun-2002     Bug 2404720. Procedure create_cc_credit Modified.
  --smadathi   25-Mar-2002     Bug 2280971. Added new procedure finp_calc_fees_todo
  --jbegum     25 Feb 02       As part of Enh bug #2238226
  --                           Modified the local procedure create_posting_int
  --                           Removed the following parameters:
  --                           p_batch_name,p_source_transaction_id,p_source_transaction_type,
  --                           p_status, x_result
  --                           Added the following parameters:
  --                           p_person_number,p_adm_appl_number,x_return_status,
  --                           x_msg_count,x_msg_data
  --                           Also added the local procedure lookup_desc
  ------------------------------------------------------------------


 FUNCTION lookup_desc( l_type in igs_lookups_view.lookup_type%TYPE ,
                       l_code in igs_lookups_view.lookup_code%TYPE
                     )RETURN VARCHAR2 IS
  /******************************************************************
  Created By        : jbegum
  Date Created By   : 25-FEB-2002
  Purpose           : Local Function Returns the meaning for the given lookup code

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  smadathi 13-nov-2002 Bug 2584986. Modified cursor cur_desc
                       select list to fetch meaning from igs_lookup_values
   ******************************************************************/

     CURSOR cur_desc( x_type igs_lookups_view.lookup_type%TYPE, x_code  igs_lookups_view.lookup_code%TYPE ) IS
     SELECT meaning
     FROM   igs_lookup_values
     WHERE  lookup_type = x_type
     AND    lookup_code = x_code
     AND    (SYSDATE BETWEEN NVL(start_date_active,SYSDATE)
     AND    NVL(end_date_active,SYSDATE))
     AND    enabled_flag = 'Y';

 l_desc igs_lookups_view.meaning%TYPE;

 BEGIN
   IF l_code IS NULL OR l_type IS NULL THEN
     RETURN NULL ;
   ELSE
      OPEN cur_desc(l_type,l_code);
      FETCH cur_desc into l_desc ;
      CLOSE cur_desc ;
   END IF ;
   RETURN l_desc ;
 END lookup_desc;

PROCEDURE create_cc_credit(
             p_party_id IN VARCHAR2,
             p_description IN VARCHAR2,
             p_amount IN VARCHAR,
             p_credit_card_code IN VARCHAR2,
             p_credit_card_holder_name IN VARCHAR2,
             p_credit_card_number IN VARCHAR2,
             p_credit_card_expiration_date IN VARCHAR2,
             p_credit_card_approval_code IN VARCHAR2,
             p_credit_card_tangible_cd IN VARCHAR2,
             x_credit_id          OUT NOCOPY NUMBER,
             x_credit_activity_id OUT NOCOPY NUMBER,
             x_return_status      OUT NOCOPY VARCHAR2,
             x_msg_count          OUT NOCOPY NUMBER,
             x_msg_data           OUT NOCOPY VARCHAR2,
             x_credit_number      OUT NOCOPY VARCHAR2,
             x_transaction_date   OUT NOCOPY DATE,
             p_credit_class       IN VARCHAR2
             ) AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 29-SEP-2001
  Purpose : This Procedure calls the Create Credits API
  Know limitations, enhancements or remarks
  Change History

  Who             When            What
  pmarada         26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
                                  parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  svuppala        9-JUN-2005      Enh 3442712 - Impact of automatic generation of the Receipt Number.
                                  changed logic for credit_number.
  pmarada         14-sep-2004     Bug 3886740, If there is no active credit type for a credit class then logging a message
  vvutukur        26-Sep-2003     Enh#3045007.Payment Plans Build.Changes specific to TD.
  pathipat        19-Aug-2003     Enh 3076768 - Automatic Release of Holds build
                                  Added code to check for return status of 'S' from credits api
  smadathi        01-jul-2003     Bug 3029782. Assigned TRUNC of l_credit_rec.p_transaction_date to out parameter x_transaction_date to
                                  remove time component.
  vvutukur        16-Jun-2003     Enh#2831582.Lockbox Build. Added 3 new parameters(lockbox_interface_id,batch_name,deposit_date) to the record
                                  type variable l_credit_rec before calling credits api.
  schodava        16-Jun-2003     Enh 2381587 - Credit Card Fund Transfer Build.
                                  Modified the spec of the procedure, and call to credits API.
  pathipat        04-Jun-2003     Enh 2831584 - SS Enhancements Build
                                  Added 2 new out parameters x_Credit_number, x_transaction_date
  shtatiko        09-APR-2003     Enh# 2831554, Replaced the call to Public Credits API with call with
                                  Private API with validation level as G_VALID_LEVEL_NONE
  schodava        7-Jan-2003      Bug # 2662124. SQLs using literals is against performance standards.
                                  Modified cursor c_credit_inst_cd to use cursor parameters.
  vvutukur        13-Dec-2002     Enh#2584741.Deposits Build.Modified the call to credits api to remove p_validation_level
                                  parameter and add 3 new parameters p_v_check_number,p_v_source_tran_type,p_v_source_tran_ref_number.
  vvutukur        15-Nov-2002     Enh#2584986.Modified the call to credits api to pass sysdate to the parameter
                                  p_d_gl_date.
  vvutukur        16-Sep-2002     Enh#2564643.Removed references to subaccount_id.ie., from parameters
                                  list,from where clause of cursor c_credittype_id,from the call to
                                  igs_fi_credits_api_pub.create_credit.
  smadathi        24-Jun-2002     Bug 2404720. The cursor c_credittype_id select is modified to fetch description column along
                                  with credit_type_id column. The call to IGS_FI_CREDITS_API_PUB.Create_Credit has been modified
                                  to  pass this description value to the formal parameter p_description.

  brajendr        22-FEB-2002     modifed the cursor (c_cc_number)which is used for creating the credit number as per the DLD

  jbegum          20-FEB-2002     Enh bug # 2228910
                                  Removed the source_transaction_id column from igs_fi_inv_int_pkg.update_row

  sykrishn        04-FEB-2002     Modifications due to SFCR020- Changes to call to credits  API and changes in igs_fi_credits_pkg.update_row
                                  to add the new columns
                                  Code related to derivation of credit_source removed since it is going to be passed as null to credits API. - SFCR020 - 2191470

  sarakshi        01-Feb-2002     In the call to the credit's API adding a new parameter p_invoice_id as a part of
                                  SFCR003 , bug:2195715.

  masehgal        17-Jan-2002     ENH # 2170429
                                  Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
  ***************************************************************/
  CURSOR c_credittype_id(cp_v_credit_class igs_fi_cr_types.credit_class%TYPE) IS
  SELECT credit_type_id , description
  FROM   igs_fi_cr_types
  WHERE  SYSDATE BETWEEN effective_start_date AND NVL(effective_end_date,SYSDATE)
  AND    credit_class  = cp_v_credit_class;


  CURSOR c_credit_card_code(cp_meaning VARCHAR2) IS
  SELECT lookup_code
  FROM   igs_lookup_values
  WHERE  lookup_type = 'IGS_CREDIT_CARDS'
  AND    meaning = ''||cp_meaning||'';

  CURSOR c_expiration_date(cp_month_year VARCHAR2) IS
  SELECT LAST_DAY(TO_DATE('01/' || cp_month_year,'DD/MM/YYYY')) expiry_date
  FROM   dual;

  l_cc_meaning  igs_lookup_values.meaning%TYPE;
  l_credit_type_id c_credittype_id%ROWTYPE;
  l_credit_card_code c_credit_card_code%ROWTYPE;
  l_attribute_rec igs_fi_credits_api_pub.attribute_rec_type;
  l_expiration_date c_expiration_date%ROWTYPE;

  l_v_currency      igs_fi_control_all.currency_cd%TYPE;
  l_v_curr_desc     fnd_currencies_tl.name%TYPE;
  l_v_message_name  fnd_new_messages.message_name%TYPE;

  l_b_return_status BOOLEAN;
  l_credit_rec      igs_fi_credit_pvt.credit_rec_type;
  l_exception       EXCEPTION;

  l_v_transaction_date    igs_fi_credits_all.transaction_date%TYPE := NULL;

BEGIN
     x_credit_id := NULL;
     x_credit_activity_id :=NULL;
     x_return_status  :=NULL;
     x_msg_count :=NULL;
     x_msg_data  :=NULL;
     x_credit_number := NULL;
     -- Calling Credits API to insert data in the credits table in student finance.
     l_attribute_rec.p_attribute_category := NULL;
     l_attribute_rec.p_attribute1         := NULL;
     l_attribute_rec.p_attribute2         := NULL;
     l_attribute_rec.p_attribute3         := NULL;
     l_attribute_rec.p_attribute4         := NULL;
     l_attribute_rec.p_attribute5         := NULL;
     l_attribute_rec.p_attribute6         := NULL;
     l_attribute_rec.p_attribute7         := NULL;
     l_attribute_rec.p_attribute8         := NULL;
     l_attribute_rec.p_attribute9         := NULL;
     l_attribute_rec.p_attribute10        := NULL;
     l_attribute_rec.p_attribute11        := NULL;
     l_attribute_rec.p_attribute12        := NULL;
     l_attribute_rec.p_attribute13        := NULL;
     l_attribute_rec.p_attribute14        := NULL;
     l_attribute_rec.p_attribute15        := NULL;
     l_attribute_rec.p_attribute16        := NULL;
     l_attribute_rec.p_attribute17        := NULL;
     l_attribute_rec.p_attribute18        := NULL;
     l_attribute_rec.p_attribute19        := NULL;
     l_attribute_rec.p_attribute20        := NULL;
     -- Fetch the parameters from the respective cursors

     -- Initialize the message stack.
     fnd_msg_pub.initialize;

      -- Get the Credit Type Id
      -- Check whether credit id exists or not
     OPEN c_credittype_id(p_credit_class);
     FETCH c_credittype_id INTO l_credit_type_id;
     IF c_credittype_id%NOTFOUND THEN
        -- Get the lookup meaning
       l_cc_meaning := IGS_FI_GEN_GL.get_lkp_meaning('IGS_FI_CREDIT_CLASS',p_credit_class);
       CLOSE c_credittype_id;
       fnd_message.set_name('IGS','IGS_FI_NO_ACTIVE_CT');
       fnd_message.set_token('CREDIT_CLASS',l_cc_meaning);
       fnd_msg_pub.add;
       RAISE l_exception;
     END IF;
     CLOSE c_credittype_id;

     -- Credit Instrument Code
     -- Validate Credit Instrument Code by calling igs_fi_crdapi_util.validate_igs_lkp function
     -- This call has been added as part of Enh# 2831554, Internal Credits API Build
     IF NOT igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type => 'IGS_FI_CREDIT_INSTRUMENT', p_v_lookup_code => 'CC' ) THEN
       fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CRD_INSTR_NULL' );
       fnd_message.set_token ( 'CR_INSTR', 'CC' );
       fnd_msg_pub.ADD;
       RAISE l_exception;
     END IF;

     -- Validate amount. This validation has been added as part of Enh# 2831554, Internal Credits API Build
     igs_fi_crdapi_util.validate_amount ( p_n_amount => p_amount,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name => l_v_message_name );
     IF NOT l_b_return_status THEN
       fnd_message.set_name('IGS', l_v_message_name);
       IF l_v_message_name = 'IGS_FI_CRD_AMT_NEGATIVE' THEN
         fnd_message.set_token ( 'CR_AMT', p_amount );
       END IF;
       fnd_msg_pub.ADD;
       RAISE l_exception;
     END IF;

    --Capture the default currency that is set up in System Options Form.
    igs_fi_gen_gl.finp_get_cur( p_v_currency_cd   => l_v_currency,
                                p_v_curr_desc     => l_v_curr_desc,
                                p_v_message_name  => l_v_message_name
                               );
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_msg_pub.ADD;
      RAISE l_exception;
    END IF;

     -- Credit Card Code
     OPEN c_credit_card_code(p_credit_card_code);
     FETCH c_credit_card_code INTO l_credit_card_code;
     CLOSE c_credit_card_code;
     -- Credit Card Expiry Date
     OPEN c_expiration_date(p_credit_card_expiration_date);
     FETCH c_expiration_date INTO l_expiration_date;
     CLOSE c_expiration_date;

     -- Validate Expiry Date. This validation has been added as part of Enh# 2831554, Internal Credits API Build
     IF TRUNC(l_expiration_date.expiry_date) < TRUNC(SYSDATE) THEN
       fnd_message.set_name('IGS', 'IGS_FI_CRD_EXPDT_INVALID');
       fnd_message.set_token('EXP_DATE', l_expiration_date.expiry_date);
       fnd_msg_pub.ADD;
       RAISE l_exception;
     END IF;

     -- Replaced the call to Public Credits API with call with Private API with validation level as G_VALID_LEVEL_NONE
     -- This has been added as part of Enh# 2831554, Internal Credits API.
     l_credit_rec.p_credit_status := 'CLEARED';
     l_credit_rec.p_credit_source := NULL;
     l_credit_rec.p_party_id := TO_NUMBER( p_party_id );
     l_credit_rec.p_credit_type_id := l_credit_type_id.credit_type_id;
     l_credit_rec.p_credit_instrument := 'CC';
     l_credit_rec.p_description := l_credit_type_id.description;
     l_credit_rec.p_amount := TO_NUMBER( p_amount );
     l_credit_rec.p_currency_cd := l_v_currency;
     l_credit_rec.p_exchange_rate := 1;
     l_credit_rec.p_transaction_date := SYSDATE;
     l_credit_rec.p_effective_date := SYSDATE;
     l_credit_rec.p_source_transaction_id := NULL;
     l_credit_rec.p_receipt_lockbox_number := NULL;
     l_credit_rec.p_credit_card_code := l_credit_card_code.lookup_code;
     l_credit_rec.p_credit_card_holder_name := p_credit_card_holder_name;
     l_credit_rec.p_credit_card_number := p_credit_card_number;
     l_credit_rec.p_credit_card_expiration_date := l_expiration_date.expiry_date;
     l_credit_rec.p_credit_card_approval_code := NULL;
     l_credit_rec.p_invoice_id := NULL;
     l_credit_rec.p_awd_yr_cal_type := NULL;
     l_credit_rec.p_awd_yr_ci_sequence_number := NULL;
     l_credit_rec.p_fee_cal_type := NULL;
     l_credit_rec.p_fee_ci_sequence_number := NULL;
     l_credit_rec.p_check_number := NULL;
     l_credit_rec.p_source_tran_type := NULL;
     l_credit_rec.p_source_tran_ref_number := NULL;
     l_credit_rec.p_gl_date := TRUNC(SYSDATE);
     l_credit_rec.p_v_credit_card_payee_cd := fnd_profile.value('IGS_FI_PAYEE_NAME');
     l_credit_rec.p_v_credit_card_status_code := 'PENDING';
     l_credit_rec.p_v_credit_card_tangible_cd := p_credit_card_tangible_cd;
     l_credit_rec.p_lockbox_interface_id      := NULL;
     l_credit_rec.p_batch_name                := NULL;
     l_credit_rec.p_deposit_date              := NULL;

     l_v_transaction_date := TRUNC(l_credit_rec.p_transaction_date);

     igs_fi_credit_pvt.create_credit ( p_api_version         => 2.1,
                                       p_init_msg_list       => fnd_api.g_false, /* Passing False because stack has already been initialized */
                                       p_commit              => fnd_api.g_false,
                                       p_validation_level    => fnd_api.g_valid_level_none,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_credit_rec          => l_credit_rec,
                                       p_attribute_record    => l_attribute_rec,
                                       x_credit_id           => x_credit_id,
                                       x_credit_activity_id  => x_credit_activity_id,
                                       x_credit_number       => x_credit_number);


     -- Pass the following values to the out parameters
     x_transaction_date :=  l_v_transaction_date;

     -- If the credit creation was successful, but holds release failed, then
     -- the return status will be S but message count will be > 0.
     IF ( x_return_status = 'S' AND x_msg_count <> 0 ) THEN
           x_msg_data := 'IGS_FI_NO_AUTO_HOLD_REL';
           RETURN;
     END IF;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       x_return_status := 'E';
       RETURN ;
    WHEN l_exception THEN
      x_return_status := 'E';
      fnd_msg_pub.count_and_get( p_count  => x_msg_count,
                                 p_data   => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := 'E';
      fnd_msg_pub.count_and_get( p_count  => x_msg_count,
                                 p_data   => x_msg_data);
      RETURN;
END create_cc_credit;


PROCEDURE update_cc_credit(
             p_credit_card_approval_code IN NUMBER,
             p_credit_id IN NUMBER,
             x_return_status OUT NOCOPY VARCHAR2,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data  OUT NOCOPY VARCHAR2
             ) AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 29-SEP-2001
  Purpose : This Procedure calls the Create Credits API
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pmarada         26-May-2005     Enh#3020586- added tax year code column as per 1098-t reporting build
  pathipat        21-Apr-2004     Enh 3558549 - Comm Receivables Enh
                                  Added param x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  vvutukur        16-Jun-2003     Enh#2831582.Lockbox Build. Added 3 new parameters(lockbox_interface_id,batch_name,deposit_date) to the TBH
                                  update_row call of credits table.
  schodava        16-Jun-2003     Enh 2381587 - Credit Card Fund Transfer Build.
                                  Modified the Credits TBH update row
  vvutukur        16-Dec-2002     Enh#2584741.Modified the tbh call to igs_fi_credits_pkg.update_row to add 3 new
                                  parameters check_number,source_transaction_type,source_transaction_ref.
  vchappid        02-Dec-2002     Enh#2584986, NOCOPY is manually added for x_return_status procedure parameter
  vvutukur        25-Nov-2002     Enh#2584986.Modified the call to igs_fi_credits_pkg.update_row to pass gl_date.
  vvutukur        16-Sep-2002     Enh#2564643.Removed references to subaccount_id.ie.,from the call to
                                  IGS_FI_CREDITS_pkg.Update_Row,
  ***************************************************************/
  CURSOR c_credit_dtls(cp_credit_id NUMBER) IS
    SELECT *
    FROM igs_fi_credits
    WHERE credit_id = cp_credit_id;

  l_credit_dtls_rec c_credit_dtls%ROWTYPE;
BEGIN

     -- Fetch the values from the igs_fi_credits table for the credit_id
     -- Credit Source
     OPEN c_credit_dtls(p_credit_id);
     FETCH c_credit_dtls INTO l_credit_dtls_rec;
     CLOSE c_credit_dtls;

         igs_fi_credits_pkg.update_row(x_rowid                       => l_credit_dtls_rec.row_id,
                                       x_credit_id                   => l_credit_dtls_rec.credit_id,
                                       x_credit_number               => l_credit_dtls_rec.credit_number,
                                       x_status                      => l_credit_dtls_rec.status,
                                       x_credit_source               => l_credit_dtls_rec.credit_source,
                                       x_party_id                    => l_credit_dtls_rec.party_id,
                                       x_credit_type_id              => l_credit_dtls_rec.credit_type_id,
                                       x_credit_instrument           => l_credit_dtls_rec.credit_instrument,
                                       x_description                 => l_credit_dtls_rec.description,
                                       x_amount                      => l_credit_dtls_rec.amount,
                                       x_currency_cd                 => l_credit_dtls_rec.currency_cd,
                                       x_exchange_rate               => l_credit_dtls_rec.exchange_rate,
                                       x_transaction_date            => l_credit_dtls_rec.transaction_date,
                                       x_effective_date              => l_credit_dtls_rec.effective_date,
                                       x_reversal_date               => l_credit_dtls_rec.reversal_date,
                                       x_reversal_reason_code        => l_credit_dtls_rec.reversal_reason_code,
                                       x_reversal_comments           => l_credit_dtls_rec.reversal_comments,
                                       x_unapplied_amount            => l_credit_dtls_rec.unapplied_amount,
                                       x_source_transaction_id       => l_credit_dtls_rec.source_transaction_id,
                                       x_receipt_lockbox_number      => l_credit_dtls_rec.receipt_lockbox_number,
                                       x_merchant_id                 => l_credit_dtls_rec.merchant_id,
                                       x_credit_card_code            => l_credit_dtls_rec.credit_card_code,
                                       x_credit_card_holder_name     => l_credit_dtls_rec.credit_card_holder_name,
                                       x_credit_card_number          => l_credit_dtls_rec.credit_card_number,
                                       x_credit_card_expiration_date => l_credit_dtls_rec.credit_card_expiration_date,
                                       x_credit_card_approval_code   => TO_CHAR(p_credit_card_approval_code),
                                       x_awd_yr_cal_type             => l_credit_dtls_rec.awd_yr_cal_type,
                                       x_awd_yr_ci_sequence_number   => l_credit_dtls_rec.awd_yr_ci_sequence_number,
                                       x_fee_cal_type                => l_credit_dtls_rec.fee_cal_type,
                                       x_fee_ci_sequence_number      => l_credit_dtls_rec.fee_ci_sequence_number,
                                       x_attribute_category          => l_credit_dtls_rec.attribute_category,
                                       x_attribute1                  => l_credit_dtls_rec.attribute1,
                                       x_attribute2                  => l_credit_dtls_rec.attribute2,
                                       x_attribute3                  => l_credit_dtls_rec.attribute3,
                                       x_attribute4                  => l_credit_dtls_rec.attribute4,
                                       x_attribute5                  => l_credit_dtls_rec.attribute5,
                                       x_attribute6                  => l_credit_dtls_rec.attribute6,
                                       x_attribute7                  => l_credit_dtls_rec.attribute7,
                                       x_attribute8                  => l_credit_dtls_rec.attribute8,
                                       x_attribute9                  => l_credit_dtls_rec.attribute9,
                                       x_attribute10                 => l_credit_dtls_rec.attribute10,
                                       x_attribute11                 => l_credit_dtls_rec.attribute11,
                                       x_attribute12                 => l_credit_dtls_rec.attribute12,
                                       x_attribute13                 => l_credit_dtls_rec.attribute13,
                                       x_attribute14                 => l_credit_dtls_rec.attribute14,
                                       x_attribute15                 => l_credit_dtls_rec.attribute15,
                                       x_attribute16                 => l_credit_dtls_rec.attribute16,
                                       x_attribute17                 => l_credit_dtls_rec.attribute17,
                                       x_attribute18                 => l_credit_dtls_rec.attribute18,
                                       x_attribute19                 => l_credit_dtls_rec.attribute19,
                                       x_attribute20                 => l_credit_dtls_rec.attribute20,
                                       x_gl_date                     => l_credit_dtls_rec.gl_date,
                                       x_check_number                => l_credit_dtls_rec.check_number,
                                       x_source_transaction_type     => l_credit_dtls_rec.source_transaction_type,
                                       x_source_transaction_ref      => l_credit_dtls_rec.source_transaction_ref,
                                       x_credit_card_status_code     => l_credit_dtls_rec.credit_card_status_code,
                                       x_credit_card_payee_cd        => l_credit_dtls_rec.credit_card_payee_cd,
                                       x_credit_card_tangible_cd     => l_credit_dtls_rec.credit_card_tangible_cd,
                                       x_lockbox_interface_id        => l_credit_dtls_rec.lockbox_interface_id,
                                       x_batch_name                  => l_credit_dtls_rec.batch_name,
                                       x_deposit_date                => l_credit_dtls_rec.deposit_date,
                                       x_source_invoice_id           => l_credit_dtls_rec.source_invoice_id,
                                       x_tax_year_code               => l_credit_dtls_rec.tax_year_code,
                                       x_waiver_name                 => l_credit_dtls_rec.waiver_name
                                      );


         x_return_status := 'S';
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       x_return_status := 'E';
       RETURN ;
     WHEN OTHERS THEN
       x_return_status := 'E';
       RETURN;
END update_cc_credit;

PROCEDURE finp_decline_Optional_fee(
p_invoice_id IN VARCHAR2,
p_return_status OUT NOCOPY VARCHAR2,
p_message_count OUT NOCOPY NUMBER,
p_message_data  OUT NOCOPY VARCHAR2
)AS
/*************************************************************
  Created By :knaraset
  Date Created By : 02-OCT-2001
  Purpose : This Procedure Create Reversal of the charge for the Declined Invoice record
            And Update Invoice record with optional_fee_flag=>'D'(Declined)
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala        04-AUG-2005     Enh 3392095 - Tution Waivers build
                                 Impact of Charges API version Number change
                                 Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  pmarada         26-May-2005    Enh#3020586- added tax year code column as per 1098-t reporting build
  smadathi        03-jun-2002    Enh. Bug 2831584. Modified opening of cursor cur_invheader to pass TO_NUMBER(p_invoice_id))
                                 instead of passing l_inv_id. This was changed because the amount due and amount made same
                                 by the update row call even after the declining of fees by charges API.
  vvutukur        15-Nov-2002    Enh#2584986.Passed SYSDATE to the call to charges API for the parameter
                                 l_chg_line_tbl(1).p_gl_date.
  vvutukur        16-Sep-2002    Enh#2564643.Removed references to subaccount_id.ie.,the assignment of
                                 L_CHG_REC.P_SUBACCOUNT_ID to L_CUR_INVHEADER.SUBACCOUNT_ID,and from
                                 calls to igs_fi_inv_int_pkg.update_row.
  masehgal        17-Jan-2002     ENH # 2170429
                                  Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
***************************************************************/
-- Cursor for fetching Invoice Header details
    CURSOR cur_invheader(cp_invoice_id IGS_FI_INV_INT.Invoice_Id%TYPE) IS
          SELECT *
      FROM igs_fi_inv_int
          WHERE invoice_id = cp_invoice_id;
-- Cursor for fetching Invoice Lines details
  CURSOR cur_invln(p_invoice_id    IGS_FI_INV_INT.Invoice_Id%TYPE) IS
    SELECT *
    FROM   IGS_FI_INVLN_INT
    WHERE  invoice_id = p_invoice_id;
    l_chg_rec             Igs_Fi_Charges_Api_Pvt.Header_Rec_Type;
    l_chg_line_tbl        Igs_Fi_Charges_Api_Pvt.Line_Tbl_Type;
    l_line_tbl            Igs_Fi_Charges_Api_Pvt.Line_Id_Tbl_Type;
    l_inv_id              IGS_FI_INV_INT.Invoice_Id%TYPE;
    l_msg_data            VARCHAR2(2000);
    l_var                 NUMBER(5) := 0;
    l_cur_invheader cur_invheader%ROWTYPE;
        l_msg                 VARCHAR2(2000);
    l_n_waiver_amount NUMBER;

BEGIN
-- Fetch the Invoice Header Details
OPEN cur_invheader(TO_NUMBER(p_invoice_id));
FETCH cur_invheader INTO l_cur_invheader;
CLOSE cur_invheader;
-- Assign Invoice Header details to the Record Variable
    l_chg_rec.p_person_id                := l_cur_invheader.person_id;
    l_chg_rec.p_fee_type                 := l_cur_invheader.fee_type;
    l_chg_rec.p_fee_cat                  := l_cur_invheader.fee_cat;
    l_chg_rec.p_fee_cal_type             := l_cur_invheader.fee_cal_type;
    l_chg_rec.p_fee_ci_sequence_number   := l_cur_invheader.fee_ci_sequence_number;
    l_chg_rec.p_course_cd                := l_cur_invheader.course_cd;
    l_chg_rec.p_attendance_type          := l_cur_invheader.attendance_type;
    l_chg_rec.p_attendance_mode          := l_cur_invheader.attendance_mode;
    l_chg_rec.p_invoice_amount           := -(l_cur_invheader.invoice_amount);
    l_chg_rec.p_invoice_creation_date    := TRUNC(SYSDATE);
    l_chg_rec.p_invoice_desc             := l_cur_invheader.invoice_desc;
    l_chg_rec.p_transaction_type         := l_cur_invheader.transaction_type;
    l_chg_rec.p_currency_cd              := l_cur_invheader.currency_cd;
    l_chg_rec.p_exchange_rate            := l_cur_invheader.exchange_rate;
    l_chg_rec.p_effective_date           := l_cur_invheader.effective_date;
    l_chg_rec.p_waiver_flag              := NULL;
    l_chg_rec.p_waiver_reason            := NULL;
    l_chg_rec.p_source_transaction_id    := l_cur_invheader.invoice_id;
    FOR invrec IN cur_invln(l_cur_invheader.invoice_id) LOOP
      l_var := l_var + 1;
      l_chg_line_tbl(l_var).p_s_chg_method_type         := invrec.s_chg_method_type;
      l_chg_line_tbl(l_var).p_description               := invrec.description;
      l_chg_line_tbl(l_var).p_chg_elements              := invrec.chg_elements;
      l_chg_line_tbl(l_var).p_amount                    := -(invrec.amount);
      l_chg_line_tbl(l_var).p_uoo_id                    := invrec.uoo_id;
      l_chg_line_tbl(l_var).p_unit_attempt_status       := invrec.unit_attempt_status;
      l_chg_line_tbl(l_var).p_eftsu                     := invrec.eftsu;
      l_chg_line_tbl(l_var).p_credit_points             := invrec.credit_points;
      l_chg_line_tbl(l_var).p_org_unit_cd               := invrec.org_unit_cd;
      l_chg_line_tbl(l_var).p_attribute_category        := invrec.attribute_category;
      l_chg_line_tbl(l_var).p_attribute1                := invrec.attribute1;
      l_chg_line_tbl(l_var).p_attribute2                := invrec.attribute2;
      l_chg_line_tbl(l_var).p_attribute3                := invrec.attribute3;
      l_chg_line_tbl(l_var).p_attribute4                := invrec.attribute4;
      l_chg_line_tbl(l_var).p_attribute5                := invrec.attribute5;
      l_chg_line_tbl(l_var).p_attribute6                := invrec.attribute6;
      l_chg_line_tbl(l_var).p_attribute7                := invrec.attribute7;
      l_chg_line_tbl(l_var).p_attribute8                := invrec.attribute8;
      l_chg_line_tbl(l_var).p_attribute9                := invrec.attribute9;
      l_chg_line_tbl(l_var).p_attribute10               := invrec.attribute10;
      l_chg_line_tbl(l_var).p_attribute11               := invrec.attribute11;
      l_chg_line_tbl(l_var).p_attribute12               := invrec.attribute12;
      l_chg_line_tbl(l_var).p_attribute13               := invrec.attribute13;
      l_chg_line_tbl(l_var).p_attribute14               := invrec.attribute14;
      l_chg_line_tbl(l_var).p_attribute15               := invrec.attribute15;
      l_chg_line_tbl(l_var).p_attribute16               := invrec.attribute16;
      l_chg_line_tbl(l_var).p_attribute17               := invrec.attribute17;
      l_chg_line_tbl(l_var).p_attribute18               := invrec.attribute18;
      l_chg_line_tbl(l_var).p_attribute19               := invrec.attribute19;
      l_chg_line_tbl(l_var).p_attribute20               := invrec.attribute20;
      l_chg_line_tbl(l_var).p_override_dr_rec_ccid      := invrec.rec_gl_ccid;
      l_chg_line_tbl(l_var).p_override_cr_rev_ccid      := invrec.rev_gl_ccid;
      l_chg_line_tbl(l_var).p_override_dr_rec_account_cd := invrec.rec_account_cd;
      l_chg_line_tbl(l_var).p_override_cr_rev_account_cd := invrec.rev_account_cd;
      l_chg_line_tbl(l_var).p_d_gl_date                  := TRUNC(SYSDATE);

    END LOOP;
    Igs_Fi_Charges_Api_Pvt.Create_Charge(p_api_version      => 2.0,
                                         p_init_msg_list    => 'T',
                                         p_commit           => 'F',
                                         p_validation_level => 100,
                                         p_header_rec       => l_chg_rec,
                                         p_line_tbl         => l_chg_line_tbl,
                                         x_invoice_id       => l_inv_id,
                                         x_line_id_tbl      => l_line_tbl,
                                         x_return_status    => p_return_status,
                                         x_msg_count        => p_message_count,
                                         x_msg_data         => p_message_data,
                                         x_waiver_amount    => l_n_waiver_amount);
    IF p_return_status <> 'S' THEN
/*         IF p_message_count = 1 THEN
             FND_MESSAGE.SET_ENCODED(l_msg_data);
                 p_message_data := FND_MESSAGE.Get;
           ELSE
             FOR l_cnt IN 1..p_message_count LOOP
                   l_msg := l_msg||FND_MSG_PUB.Get(p_msg_index => l_cnt,
                                            p_encoded   => 'T');
                 END LOOP;
         p_message_data := l_msg;
           END IF;*/
       RETURN;
        ELSE
        -- Update Invoice record with optional_fee_flag=>'D'(Declined)

--Change History
--Who        When              What
--skharida     26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
--vvutukur     25-Nov-2002    Enh#2584986.Removed the call to igs_fi_inv_int_pkg.update_row.
--vvutukur     16-Sep-2002    Enh#2564643.As part of subaccount removal build,removed parameter
--                            x_subaccount_id from the following call to igs_fi_inv_int_pkg.update_row.
--jbegum       20 feb 02      Enh bug # 2228910
--                            Removed the source_transaction_id column from igs_fi_inv_int_pkg.update_row
--masehgal   17-Jan-2002       ENH # 2170429
--                             Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler

       -- Fetch the Invoice Header Details for the Reversal record to update optional_fee_flag to 'D'
           -- So that reversal record won't be available for Decline again
       OPEN cur_invheader(TO_NUMBER(p_invoice_id));
       FETCH cur_invheader INTO l_cur_invheader;
       CLOSE cur_invheader;

          igs_fi_inv_int_pkg.update_row(  x_rowid                                    =>    l_cur_invheader.row_id                        ,
                                          x_invoice_id                               =>    l_cur_invheader.invoice_id                    ,
                                          x_person_id                                =>    l_cur_invheader.person_id                     ,
                                          x_fee_type                                 =>    l_cur_invheader.fee_type                      ,
                                          x_fee_cat                                  =>    l_cur_invheader.fee_cat                       ,
                                          x_fee_cal_type                             =>    l_cur_invheader.fee_cal_type                  ,
                                          x_fee_ci_sequence_number                   =>    l_cur_invheader.fee_ci_sequence_number        ,
                                          x_course_cd                                =>    l_cur_invheader.course_cd                     ,
                                          x_attendance_mode                          =>    l_cur_invheader.attendance_mode               ,
                                          x_attendance_type                          =>    l_cur_invheader.attendance_type               ,
                                          x_invoice_amount_due                       =>    l_cur_invheader.invoice_amount_due            ,
                                          x_invoice_creation_date                    =>    l_cur_invheader.invoice_creation_date         ,
                                          x_invoice_desc                             =>    l_cur_invheader.invoice_desc                  ,
                                          x_transaction_type                         =>    l_cur_invheader.transaction_type              ,
                                          x_currency_cd                              =>    l_cur_invheader.currency_cd                   ,
                                          x_status                                   =>    l_cur_invheader.status                        ,
                                          x_attribute_category                       =>    l_cur_invheader.attribute_category            ,
                                          x_attribute1                               =>    l_cur_invheader.attribute1                    ,
                                          x_attribute2                               =>    l_cur_invheader.attribute2                    ,
                                          x_attribute3                               =>    l_cur_invheader.attribute3                    ,
                                          x_attribute4                               =>    l_cur_invheader.attribute4                    ,
                                          x_attribute5                               =>    l_cur_invheader.attribute5                    ,
                                          x_attribute6                               =>    l_cur_invheader.attribute6                    ,
                                          x_attribute7                               =>    l_cur_invheader.attribute7                    ,
                                          x_attribute8                               =>    l_cur_invheader.attribute8                    ,
                                          x_attribute9                               =>    l_cur_invheader.attribute9                    ,
                                          x_attribute10                              =>    l_cur_invheader.attribute10                   ,
                                          x_invoice_amount                           =>    l_cur_invheader.invoice_amount                ,
                                          x_bill_id                                  =>    l_cur_invheader.bill_id                       ,
                                          x_bill_number                              =>    l_cur_invheader.bill_number                   ,
                                          x_bill_date                                =>    l_cur_invheader.bill_date                     ,
                                          x_waiver_flag                              =>    l_cur_invheader.waiver_flag                   ,
                                          x_waiver_reason                            =>    l_cur_invheader.waiver_reason                 ,
                                          x_effective_date                           =>    l_cur_invheader.effective_date                ,
                                          x_invoice_number                           =>    l_cur_invheader.invoice_number                ,
                                          x_exchange_rate                            =>    l_cur_invheader.exchange_rate                 ,
                                          x_bill_payment_due_date                    =>    l_cur_invheader.bill_payment_due_date         ,
                                          x_optional_fee_flag                        =>    'D'                                           ,
                                          x_mode                                     =>    'R',
                                          x_reversal_gl_date                         =>    TRUNC(SYSDATE),
                                          x_tax_year_code                            =>    l_cur_invheader.tax_year_code,
                                          x_waiver_name                              =>    l_cur_invheader.waiver_name
                                       );
    END IF;

 EXCEPTION
     WHEN OTHERS THEN
       p_return_status := 'E';
       RETURN;

END finp_decline_Optional_fee;

PROCEDURE finp_set_optional_fee_flag(
p_person_id IN VARCHAR2,
p_return_status OUT NOCOPY  VARCHAR2,
p_message_count OUT NOCOPY  NUMBER,
p_message_data  OUT NOCOPY  VARCHAR2
) AS
/*************************************************************
  Created By :knaraset
  Date Created By : 02-OCT-2001
  Purpose : This Procedure Updates All Invoice records which are not Declined
            for the given Student and SubAccountID with optional_fee_flag => 'A'(Accepted)
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pmarada        26-May-2005    Enh#3020586- added tax year code column as per 1098-t reporting build
  vvutukur        04-Dec-2003   Bug#3249288.Modified cursor cur_opt_fees to select invoice records having
                                optional fee flag as 'O' without need to look at the value of optional_payment_ind
				at fee type set up level.
  pathipat        04-Jun-2003   Enh 2831584 - SS Enhancements Build
                                Modified cursor cur_opt_fees - included join with igs_fi_invln_int_all
  vvutukur        25-Nov-2002   Enh#2584986.Passed NULL to the newly added parameter x_reversal_gl_date in the call to
                                igs_fi_inv_int_pkg.update_row.
  vvutukur        16-Sep-2002   Enh#2564643.Removed the references to subaccount_id.ie., from
                                parameters list p_subaccount_id,from cursor cur_opt_fees and from the
                                call to igs_fi_inv_int_pkg.update_row.9/16/02
                                  removal build.
  masehgal        17-Jan-2002     ENH # 2170429
                                  Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
  ***************************************************************/

-- Cursor to fetch all the Optional fees which are not Declined
  CURSOR cur_opt_fees IS
    SELECT inv.invoice_id
    FROM   igs_fi_inv_int_all inv ,
           igs_fi_invln_int_all invln
    WHERE  invln.invoice_id = inv.invoice_id
    AND    NVL(invln.error_account,'N') = 'N'
    AND    inv.person_id = p_person_id
    AND    inv.optional_fee_flag ='O';

-- cursor reads from the charges tables
   CURSOR  cur_inv_int(p_invoice_id NUMBER) IS
     SELECT  *
     FROM  igs_fi_inv_int
     WHERE invoice_id = p_invoice_id;
l_cur_inv_int cur_inv_int%ROWTYPE;
BEGIN
  FOR l_cur_opt_fees IN cur_opt_fees LOOP
     OPEN cur_inv_int(l_cur_opt_fees.invoice_id);
         FETCH cur_inv_int INTO l_cur_inv_int ;

--Change History
--Who             When             What
--skharida     26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
--vvutukur     16-Sep-2002    Enh#2564643.As part of subaccount removal build, removed parameter
--                            x_subaccount_id from the following call to igs_fi_inv_int_pkg.update_row.
--jbegum       20 feb 02      Enh bug # 2228910
--                            Removed the source_transaction_id column from igs_fi_inv_int_pkg.update_row
--masehgal        17-Jan-2002      ENH # 2170429
--                                 Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler

          Igs_Fi_Inv_Int_Pkg.update_row(  x_rowid                                    =>    l_cur_inv_int.row_id                        ,
                                          x_invoice_id                               =>    l_cur_inv_int.invoice_id                    ,
                                          x_person_id                                =>    l_cur_inv_int.person_id                     ,
                                          x_fee_type                                 =>    l_cur_inv_int.fee_type                      ,
                                          x_fee_cat                                  =>    l_cur_inv_int.fee_cat                       ,
                                          x_fee_cal_type                             =>    l_cur_inv_int.fee_cal_type                  ,
                                          x_fee_ci_sequence_number                   =>    l_cur_inv_int.fee_ci_sequence_number        ,
                                          x_course_cd                                =>    l_cur_inv_int.course_cd                     ,
                                          x_attendance_mode                          =>    l_cur_inv_int.attendance_mode               ,
                                          x_attendance_type                          =>    l_cur_inv_int.attendance_type               ,
                                          x_invoice_amount_due                       =>    l_cur_inv_int.invoice_amount_due            ,
                                          x_invoice_creation_date                    =>    l_cur_inv_int.invoice_creation_date         ,
                                          x_invoice_desc                             =>    l_cur_inv_int.invoice_desc                  ,
                                          x_transaction_type                         =>    l_cur_inv_int.transaction_type              ,
                                          x_currency_cd                              =>    l_cur_inv_int.currency_cd                   ,
                                          x_status                                   =>    l_cur_inv_int.status                        ,
                                          x_attribute_category                       =>    l_cur_inv_int.attribute_category            ,
                                          x_attribute1                               =>    l_cur_inv_int.attribute1                    ,
                                          x_attribute2                               =>    l_cur_inv_int.attribute2                    ,
                                          x_attribute3                               =>    l_cur_inv_int.attribute3                    ,
                                          x_attribute4                               =>    l_cur_inv_int.attribute4                    ,
                                          x_attribute5                               =>    l_cur_inv_int.attribute5                    ,
                                          x_attribute6                               =>    l_cur_inv_int.attribute6                    ,
                                          x_attribute7                               =>    l_cur_inv_int.attribute7                    ,
                                          x_attribute8                               =>    l_cur_inv_int.attribute8                    ,
                                          x_attribute9                               =>    l_cur_inv_int.attribute9                    ,
                                          x_attribute10                              =>    l_cur_inv_int.attribute10                   ,
                                          x_invoice_amount                           =>    l_cur_inv_int.invoice_amount                ,
                                          x_bill_id                                  =>    l_cur_inv_int.bill_id                       ,
                                          x_bill_number                              =>    l_cur_inv_int.bill_number                   ,
                                          x_bill_date                                =>    l_cur_inv_int.bill_date                     ,
                                          x_waiver_flag                              =>    l_cur_inv_int.waiver_flag                   ,
                                          x_waiver_reason                            =>    l_cur_inv_int.waiver_reason                 ,
                                          x_effective_date                           =>    l_cur_inv_int.effective_date                ,
                                          x_invoice_number                           =>    l_cur_inv_int.invoice_number                ,
                                          x_exchange_rate                            =>    l_cur_inv_int.exchange_rate                 ,
                                          x_bill_payment_due_date                    =>    l_cur_inv_int.bill_payment_due_date         ,
                                          x_optional_fee_flag                        =>    'A'                                         ,
                                          x_mode                                     =>    'R',
                                          x_reversal_gl_date                         =>    l_cur_inv_int.reversal_gl_date,
                                          x_tax_year_code                            =>    l_cur_inv_int.tax_year_code,
                                          x_waiver_name                              =>    l_cur_inv_int.waiver_name
                                       );
     CLOSE cur_inv_int;
  END LOOP; -- l_cur_opt_fees

 EXCEPTION
     WHEN OTHERS THEN
       p_return_status := 'E';
       RETURN;

END finp_set_optional_fee_flag;


PROCEDURE  finp_calc_fees_todo
           (
             p_person_id     IN  igs_pe_std_todo_ref.person_id%TYPE,
             p_init_msg_list IN  VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2,
             p_message_count OUT NOCOPY NUMBER,
             p_message_data  OUT NOCOPY VARCHAR2
           ) IS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 22 Mar 2002
  --
  --Purpose:
  -- Invoked     : From  Student Acoount History and Payment Page.
  -- Function    : Procedure checks for any pending todo records of type fee_recalc.
  --               If any entry is found, process calls the fee assessment routine for the FCI
  -- Parameters  : p_person_id : IN parameter. Required. Identifies the person for which ToDo Enteries
  --               needs to be checked from IGS_PE_STD_TODO_REF table.
  --
  --               p_return_status : OUT parmeter.
  --
  --               p_message_count : OUT parameter
  --
  --               p_message_data  : OUT parameter
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --gurprsin   6-Dec-2005      Bug 4735807, Modified the finp_calc_fees_todo method, Added a condition to skip the addition of message onto the stack as it is already added in
  --                           finp_ins_enr_fee_ass method for the case ' if no fee category is attached to the SPA.'. Otherwise a null message
  --                           will be added and shown on the SS page.
  --schodava   21-Jan-2004     Bug # 3062706 - Removed the initialization of the variable l_d_creation_dt
  --                           within the loop across the records in the IGS_PE_STD_TODO_REF table.
  --shtatiko   15-DEC_2003     Bug# 3230754, Replaced AND with OR when checking for uniqueness of FTCI.
  --pathipat   06-Nov-2003     Enh 3117341 - Audit and Special Fees TD
  --                           Added logic for processing Special Fees after Fee Assessment
  --smadathi   28-MAY-2003     Bug 2849142. Modified the exceptional handling. Used p_message_data to return message_name
  --                           instead.
  --knaraset   12-May-2003    Modified cursor c_igs_pe_std_todo_ref to select uoo_id
  --                          also added uoo_id in TBH call to todo_ref, as part of MUS build bug 2829262
  --vchappid   14-Mar-2003    Bug#2849142, Only one error message has to be shown to the user when any error occurs.
  --smadathi   13-nov-2002    Added p_d_gl_date parameter to the call igs_fi_prc_fee_ass.finp_ins_enr_fee_ass
  --vvutukur   17-Sep-2002    Enh#2564643.Removed DEFAULT clause from parameter list to avoid
  --                          gscc warning in order to comply with 9i standards.
  ------------------------------------------------------------------
  l_c_rpt_ld_cal_type             igs_pe_std_todo_ref.cal_type%TYPE;
  l_n_rpt_ld_ci_sequence_number   igs_pe_std_todo_ref.ci_sequence_number%TYPE;
  l_c_fee_cal_type                igs_fi_f_typ_ca_inst.fee_cal_type%TYPE;
  l_n_fee_ci_sequence_number      igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE;
  l_c_message_name                fnd_new_messages.message_name%TYPE DEFAULT NULL;
  l_c_message                     VARCHAR2(32767) DEFAULT NULL;
  l_d_creation_dt                 DATE;
  cst_fee_recalc                  CONSTANT VARCHAR2(10) := 'FEE_RECALC';

  l_c_msg VARCHAR2(2000);
  l_c_appln VARCHAR2(10);

  -- Cursor to fetch all the open todo records from the igs_pe_std_todo_ref table for the person that are
  -- of type 'FEE_RECALC'

  CURSOR   c_igs_pe_std_todo_ref( cp_n_person_id igs_pe_std_todo_ref.person_id%TYPE) IS
  SELECT   person_id           ,  s_student_todo_type    , sequence_number    ,
           reference_number    ,  cal_type               , ci_sequence_number ,
           course_cd           ,  unit_cd                , other_reference    ,
           logical_delete_dt   ,  Created_by             , creation_date      ,
           last_updated_by     ,  last_update_date       , last_update_login  ,
           request_id          ,  program_application_id , program_id         ,
           program_update_date ,  rowid,uoo_id
  FROM     igs_pe_std_todo_ref
  WHERE    person_id            = cp_n_person_id
  AND      s_student_todo_type  = cst_fee_recalc
  AND      logical_delete_dt  IS NULL
  ORDER BY cal_type , ci_sequence_number;
  -- cursor % rowtype variable
  rec_c_igs_pe_std_todo_ref c_igs_pe_std_todo_ref%ROWTYPE;
  -- user defined exception
  e_resource_busy  EXCEPTION;
  --associating the oracle error number and user defined exception using compiler directive
  PRAGMA EXCEPTION_INIT(e_resource_busy,-00054);

  l_b_fees_assessed     BOOLEAN := TRUE;
  l_b_recs_found        BOOLEAN := FALSE;
  l_v_ret_status        VARCHAR2(1) := NULL;
  l_n_waiver_amount     NUMBER;

  BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;
    -- Initialize return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize repeat counter for load calendar type and load sequence number
    l_c_rpt_ld_cal_type             :=  ' ';
    l_n_rpt_ld_ci_sequence_number   :=  0;

    --Validating if the mandatory parameter person_id is passed to the process
    IF (p_person_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PARAMETER_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- validate the person id passed to the procedure
    IF (igs_fi_gen_007.validate_person(p_person_id) = 'N' ) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_b_fees_assessed := TRUE;
    FOR rec_c_igs_pe_std_todo_ref  IN c_igs_pe_std_todo_ref (cp_n_person_id => p_person_id) LOOP

      -- compare the fetched LCI with the last processed LCI
      IF ((l_c_rpt_ld_cal_type <> rec_c_igs_pe_std_todo_ref.cal_type ) OR
          (l_n_rpt_ld_ci_sequence_number <> rec_c_igs_pe_std_todo_ref.ci_sequence_number))
      THEN
        l_c_message_name  := NULL;
        -- call to function which converts the LCI to FCI
        IF igs_fi_gen_001.finp_get_lfci_reln
           (
            p_cal_type                   =>   rec_c_igs_pe_std_todo_ref.cal_type  ,
            p_ci_sequence_number         =>   rec_c_igs_pe_std_todo_ref.ci_sequence_number ,
            p_cal_category               =>   'LOAD',
            p_ret_cal_type               =>   l_c_fee_cal_type,
            p_ret_ci_sequence_number     =>   l_n_fee_ci_sequence_number,
            p_message_name               =>   l_c_message_name
           ) = FALSE  THEN
          IF l_c_message_name IS NOT NULL THEN
            fnd_message.set_name('IGS', l_c_message_name);
            fnd_msg_pub.ADD;
          END IF;
          -- Set Flag denoting that Fee Assessment failed
          -- Exception is raised after Special Fee processing happens
          l_b_fees_assessed := FALSE;
        ELSE
          -- Removed commit from this place as COMMIT has to happen once for all Load Calendars.
          -- COMMIT after the for loop will do that.
          l_c_message_name := NULL;
          BEGIN
            -- calls the fee calc routine
            -- This routine will commit internally as we are calling with Test Run parameter as N.
            IF igs_fi_prc_fee_ass.finp_ins_enr_fee_ass
               (
                 p_effective_dt           =>    SYSDATE,
                 p_person_id              =>    rec_c_igs_pe_std_todo_ref.person_id,
                 p_course_cd              =>    NULL,
                 p_fee_category           =>    NULL,
                 p_fee_cal_type           =>    l_c_fee_cal_type,
                 p_fee_ci_sequence_num    =>    l_n_fee_ci_sequence_number,
                 p_fee_type               =>    NULL,
                 p_trace_on               =>    'N',
                 p_test_run               =>    'N',
                 p_creation_dt            =>    l_d_creation_dt,
                 p_message_name           =>    l_c_message_name,
                 p_d_gl_date              =>    TRUNC(SYSDATE),
                 p_v_wav_calc_flag        =>    'N',
                 p_n_waiver_amount        =>    l_n_waiver_amount
               ) = FALSE THEN
              IF l_c_message_name IS NOT NULL THEN
                --Bug 4735807, Added thiscondition to skip the addition of message onto the stack as it is already added in
                --finp_ins_enr_fee_ass method for the case ' if no fee category is attached to the SPA.'. Otherwise a null message
                --will be added and shown on the SS page.
                IF l_c_message_name <> 'IGS_FI_NO_SPA_FEE_CAT' THEN
                  fnd_message.set_name('IGS', l_c_message_name);
                  IF l_c_message_name = 'IGS_FI_NO_CENSUS_DT_SETUP' THEN
                    fnd_message.set_token('ALT_CD', igs_fi_prc_fee_ass.g_v_load_alt_code);
                  END IF;
                  fnd_msg_pub.ADD;
                END IF;
              END IF;
              -- Exception is raised after Special Fee processing happens
              l_b_fees_assessed := FALSE;
            END IF; -- fee calc routine check condition ends here
          EXCEPTION
            WHEN OTHERS THEN
              -- Even if Fee Assessment raises exception, Special Fees processing
              -- has to happen. So set flag to False and continue
              -- Exception is raised after Special Fee processing happens
              l_b_fees_assessed := FALSE;
          END ;
        END IF; -- condition check for LCI to FCI ends here

        -- assign the fetched values to repeat values
        l_c_rpt_ld_cal_type             :=  rec_c_igs_pe_std_todo_ref.cal_type;
        l_n_rpt_ld_ci_sequence_number   :=  rec_c_igs_pe_std_todo_ref.ci_sequence_number;
      END IF;  -- check condition for comparing the fetched LCI with the last processed LCI

      -- update the logical delete date so that this record would no longer be an open todo
      -- Update the TODO record only if Fee Assessment was successful.
      IF l_b_fees_assessed THEN
        igs_pe_std_todo_ref_pkg.update_row ( x_rowid                  =>    rec_c_igs_pe_std_todo_ref.rowid,
                                             x_person_id              =>    rec_c_igs_pe_std_todo_ref.person_id,
                                             x_s_student_todo_type    =>    rec_c_igs_pe_std_todo_ref.s_student_todo_type,
                                             x_sequence_number        =>    rec_c_igs_pe_std_todo_ref.sequence_number,
                                             x_reference_number       =>    rec_c_igs_pe_std_todo_ref.reference_number,
                                             x_cal_type               =>    rec_c_igs_pe_std_todo_ref.cal_type,
                                             x_ci_sequence_number     =>    rec_c_igs_pe_std_todo_ref.ci_sequence_number,
                                             x_course_cd              =>    rec_c_igs_pe_std_todo_ref.course_cd,
                                             x_unit_cd                =>    rec_c_igs_pe_std_todo_ref.unit_cd,
                                             x_other_reference        =>    rec_c_igs_pe_std_todo_ref.other_reference,
                                             x_logical_delete_dt      =>    SYSDATE,
                                             x_mode                   =>    'R',
                                             x_uoo_id                 =>    rec_c_igs_pe_std_todo_ref.uoo_id);
      ELSE
        -- i.e., l_b_fees_assessed == FALSE which means there is an error in deriving the Fee/Load period relation OR in fee assessment.
        -- So, Stop processing TODO REF records and exit out of loop
        EXIT;
      END IF;

    END LOOP;

    -- Commit if Fees is assessed.
    IF l_b_fees_assessed THEN
      COMMIT WORK;
    END IF;

    -- Call Special Fees routine to assess Special Fees
    -- This has to be called irrespective of whether Fee Assessment is successful or not.
    igs_fi_prc_sp_fees.process_special_fees(p_n_person_id          => p_person_id,
                                            p_v_fee_cal_type       => NULL,
                                            p_n_fee_ci_seq_number  => NULL,
                                            p_v_load_cal_type      => NULL,
                                            p_n_load_ci_seq_number => NULL,
                                            p_d_gl_date            => TRUNC(SYSDATE),
                                            p_v_test_run           => 'N',
                                            p_b_log_messages       => FALSE,
                                            p_b_recs_found         => l_b_recs_found,
                                            p_v_return_status      => l_v_ret_status);
    -- If Fee Assessment completed successfully, only then log any error messages of
    -- Special Fees Assessment, else SS pages would show only the Fee Assessment error
    IF l_b_fees_assessed THEN
      IF l_v_ret_status <> 'S' THEN
        -- Add Special Fee error message to the stack
        fnd_message.set_name('IGS','IGS_FI_SS_SP_NOT_ASSESSED');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- Raise error since Fee Assessment errored out
      -- Error messages have already been added to the stack
      RAISE fnd_api.g_exc_error;
    END IF;

    fnd_msg_pub.count_and_get(p_count      => p_message_count,
                              p_data       => p_message_data
                             );

  EXCEPTION
    WHEN e_resource_busy THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_message_count := 1;
      p_message_data := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK ;
      p_return_status := FND_API.G_RET_STS_ERROR;

      -- assign message data to this out parameter
      -- count should be initialized to 1 such that only one message is shown in the SS page
      -- after setting the message data OUT variable, initialize the message stack.

      p_message_count := 1;
      p_message_data := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK ;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_message_count := 1;
      p_message_data := fnd_msg_pub.get(p_msg_index => 1, p_encoded => 'F');

    WHEN OTHERS THEN
      ROLLBACK ;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_message_count := 1;
      p_message_data := fnd_message.get_string('IGS', 'IGS_FI_SS_SP_NOT_ASSESSED');

  END finp_calc_fees_todo;

FUNCTION get_msg_text(
             p_v_message_name  IN  fnd_new_messages.message_name%TYPE
             ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 30 May 2003
  --
  --Purpose:
  -- Invoked     : From  Student Homepage VO
  -- Function    : Returns message text for the input message passed as parameter to it.
  -- Parameters  :
  --               p_v_message_name : IN parmeter.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --gurprsin    13-Sep-2005     Bug 3765876, Modified the Cursor c_get_msg_text select statement to add userenv. language condition with application id
  ------------------------------------------------------------------

  CURSOR c_get_msg_text(cp_v_message_name fnd_new_messages.message_name%TYPE) IS
  SELECT message_text
  FROM   fnd_new_messages
  WHERE  message_name = cp_v_message_name
  AND    application_id = 8405
  AND    language_code = USERENV('LANG');

  rec_c_get_msg_text c_get_msg_text%ROWTYPE;

  BEGIN

    IF p_v_message_name IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN  c_get_msg_text(cp_v_message_name => p_v_message_name);
    FETCH c_get_msg_text INTO rec_c_get_msg_text;
    CLOSE c_get_msg_text;

    RETURN rec_c_get_msg_text.message_text;

  END get_msg_text;

END igs_fi_ss_acct_payment;

/
