--------------------------------------------------------
--  DDL for Package Body IGS_FI_CRDAPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CRDAPI_UTIL" AS
/* $Header: IGSFI84B.pls 120.5 2006/02/10 04:43:13 sapanigr ship $ */

/*
Procedure VALIDATE_PARAMETERS is the main procedure which has calls to
individual procedures or functions. When this procedure is invoked with FULL
validation level then all parameter validations will take place.
 */
/***********************************************************************************************
  Created By     :
  Date Created By:
  Purpose        :

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  sapanigr  12-Feb-2006       Bug#5018036 - Modified  cursor c_valid_person in validate_party_id procedure. (R12 SQL Repository tuning)
  sapanigr  22-NOV-2005       Bug#4675424. Added function val_cal_inst
  svuppala  07-JUL-2005       Enh 3392095 - Tution Waivers build
                              Modified  validations of credit class and credit instrument in Validate_parameters.
  svuppala   9-JUN-2005       Enh 4213629 - The automatic generation of the Receipt Number.
                              Removed the validation to check if Credit Number is passed
                              if the combination of party_id and credit_number already exists in the system.
  vvutukur   13-Sep-2003      Enh#3045007.Payment Plans Build. Added procedures apply_installments,validate_plan_balance.
  vvutukur   14-Jul-2003      Enh#3038511.FICR106 Build. Added procedure get_award_year_status,modified validate_parameters.
  vvutukur   18-Jun-2003      Enh#2831582.Lockbox Build. Removed the function validate_lockbox and related call to the same.
********************************************************************************************** */

PROCEDURE get_award_year_status(p_v_awd_cal_type     IN VARCHAR2,
                                p_n_awd_seq_number   IN PLS_INTEGER,
                                p_v_awd_yr_status    OUT NOCOPY VARCHAR2,
                                p_v_message_name     OUT NOCOPY VARCHAR2) AS

/***********************************************************************************************
  Created By     :  vvutukur, Oracle India
  Date Created By:  15-Jul-2003
  Purpose        :  This procedure is meant for getting the award year status code
                    for the specified award year.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
  --Cursor to fetch the award year status code for the specified award year.
  CURSOR cur_awd_yr_status(cp_v_cal_type       VARCHAR2,
                           cp_n_ci_seq_number  NUMBER) IS
    SELECT award_year_status_code
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_v_cal_type
    AND    ci_sequence_number = cp_n_ci_seq_number;

    l_v_awd_yr_status_cd  igf_ap_batch_aw_map.award_year_status_code%TYPE;

BEGIN

  --Both input parameters are mandatory to this procedure, if either of them is null, return from the procedure
  --assigning false to return status and null to award year status.

  IF p_v_awd_cal_type IS NULL OR p_n_awd_seq_number IS NULL THEN
    p_v_message_name  := 'IGS_FI_INV_AWD_YR';
    p_v_awd_yr_status := NULL;
    RETURN;
  END IF;

  --if both the input parameters passed are passed as not null, then..
  --Fetch the award year status.
  OPEN cur_awd_yr_status(p_v_awd_cal_type,p_n_awd_seq_number);
  FETCH cur_awd_yr_status INTO l_v_awd_yr_status_cd;

  --If no matching award year status found for the input parameters passed, then
  IF cur_awd_yr_status%NOTFOUND THEN
    --Return from the procedure assigning false to return status and null to award year status.
    CLOSE cur_awd_yr_status;
    p_v_message_name  := 'IGS_FI_INV_AWD_YR';
    p_v_awd_yr_status := NULL;
    RETURN;
  END IF;

  CLOSE cur_awd_yr_status;
  p_v_awd_yr_status := l_v_awd_yr_status_cd;

  IF p_v_awd_yr_status <> 'O' THEN
    p_v_message_name := 'IGF_SP_INVALID_AWD_YR_STATUS';
  ELSE
    p_v_message_name := NULL;
  END IF;

END get_award_year_status;

PROCEDURE validate_plan_balance(p_n_person_id     IN PLS_INTEGER,
                                p_n_amount        IN NUMBER,
                                p_b_status        OUT NOCOPY BOOLEAN,
                                p_v_message_name  OUT NOCOPY VARCHAR2
                                ) AS
/***********************************************************************************************
  Created By     :  vvutukur, Oracle India
  Date Created By:  13-Sep-2003
  Purpose        :  Procedure to verify if the Installment balance for the person is
                    greater than or equal to the amount of the receipt that is being created.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */

  l_n_act_plan_id    igs_fi_pp_std_attrs.student_plan_id%TYPE;
  l_v_act_plan_name  igs_fi_pp_std_attrs.payment_plan_name%TYPE;
  l_n_pln_bal        NUMBER;

BEGIN
  --Get the Student's Active Payment Plan's details.
  igs_fi_gen_008.get_plan_details(p_n_person_id      => p_n_person_id,
                                  p_n_act_plan_id    => l_n_act_plan_id,
                                  p_v_act_plan_name  => l_v_act_plan_name);

  --If there is no active Payment Plan for the student, return from the procedure
  --by assigning proper error message and return status into the out parameters.
  IF l_v_act_plan_name IS NULL THEN
    p_b_status := FALSE;
    p_v_message_name := 'IGS_FI_PP_PRSN_NOT_ACTIVE_PP';
    RETURN;
  END IF;

  --Get the Student's Active Payment Plan Balance.
  l_n_pln_bal := igs_fi_gen_008.get_plan_balance(p_n_act_plan_id     => l_n_act_plan_id,
                                                 p_d_effective_date  => NULL
                                                 );
  --If the payment plan balance is less than the amount passed, return from the procedure
  --by assigning proper error message and return status into the out parameters.
  IF NVL(l_n_pln_bal,0) < NVL(p_n_amount,0) THEN
    p_b_status := FALSE;
    p_v_message_name := 'IGS_FI_PP_MORE_AMOUNT';
    RETURN;
  END IF;

  --if above validations are passed, return from the procedure with true status and message name being null.
  p_b_status := TRUE;
  p_v_message_name := NULL;

END validate_plan_balance;

PROCEDURE apply_installments(p_n_person_id       IN NUMBER,
                             p_n_amount          IN NUMBER,
                             p_n_credit_id       IN igs_fi_credits.credit_id%TYPE,
                             p_n_cr_activity_id  IN igs_fi_cr_activities.credit_activity_id%TYPE) AS
/***********************************************************************************************
  Created By     :  vvutukur, Oracle India
  Date Created By:  13-Sep-2003
  Purpose        :  Procedure to apply an Installment Payment against the student's Active
                    Payment Plans installments in the FIFO basis.
  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
  --Cursor to fetch the details of Student's Active Payment Plan installments.
  CURSOR cur_pp_insts(cp_n_person_id NUMBER,
                      cp_v_plan_status VARCHAR2) IS
    SELECT inst.rowid row_id, inst.*
    FROM   igs_fi_pp_instlmnts inst,
           igs_fi_pp_std_attrs stt
    WHERE  stt.student_plan_id = inst.student_plan_id AND
           stt.person_id = cp_n_person_id AND
           stt.plan_status_code = cp_v_plan_status AND
           inst.due_amt > 0
    ORDER BY inst.due_date;

  rec_cur_pp_insts    cur_pp_insts%ROWTYPE;

  --Cursor to fetch the details of Student's Active Payment Plan record.
  CURSOR cur_pmt_plan(cp_n_person_id NUMBER,
                      cp_v_plan_status VARCHAR2) IS
    SELECT stt.rowid row_id,stt.*
    FROM   igs_fi_pp_std_attrs stt
    WHERE  stt.person_id = cp_n_person_id AND
           stt.plan_status_code = cp_v_plan_status;

  rec_cur_pmt_plan    cur_pmt_plan%ROWTYPE;


  l_n_credit_amt      igs_fi_credits.amount%TYPE;
  l_n_amt_apply       igs_fi_credits.amount%TYPE;
  l_n_amt_due         igs_fi_credits.amount%TYPE;
  l_rowid             ROWID;
  l_n_inst_appl_id    igs_fi_pp_ins_appls.installment_application_id%TYPE;

BEGIN

  l_n_credit_amt := p_n_amount;

  --Fetch the Student's Active Payment Plan Installment record details and loop through each one of them.
  OPEN cur_pp_insts(p_n_person_id,'ACTIVE');
  LOOP
    FETCH cur_pp_insts INTO rec_cur_pp_insts;

    --Calculate the amount to be applied and due amount for each Active Payment Plan Installment record
    --to be updated.
    IF NVL(rec_cur_pp_insts.due_amt,0) >= NVL(l_n_credit_amt,0) THEN
      l_n_amt_apply   := l_n_credit_amt;
      l_n_amt_due     := rec_cur_pp_insts.due_amt - l_n_credit_amt;
      l_n_credit_amt  := 0;
    ELSE
      l_n_amt_apply   := rec_cur_pp_insts.due_amt;
      l_n_amt_due     := 0;
      l_n_credit_amt  := l_n_credit_amt - rec_cur_pp_insts.due_amt;
    END IF;

    --Update the due_amt column of igs_fi_pp_instlmnts table with outstanding due amt.
    igs_fi_pp_instlmnts_pkg.update_row(
                                        x_rowid                  => rec_cur_pp_insts.row_id,
                                        x_installment_id         => rec_cur_pp_insts.installment_id,
                                        x_student_plan_id        => rec_cur_pp_insts.student_plan_id,
                                        x_installment_line_num   => rec_cur_pp_insts.installment_line_num,
                                        x_due_day                => rec_cur_pp_insts.due_day,
                                        x_due_month_code         => rec_cur_pp_insts.due_month_code,
                                        x_due_year               => rec_cur_pp_insts.due_year,
                                        x_due_date               => rec_cur_pp_insts.due_date,
                                        x_installment_amt        => rec_cur_pp_insts.installment_amt,
                                        x_due_amt                => l_n_amt_due,
                                        x_penalty_flag           => rec_cur_pp_insts.penalty_flag,
                                        x_mode                   => 'R'
                                       );

    --Create an installment application record in igs_fi_pp_ins_appls table with appropriate amount applied.
    --and application type code as 'APP'.
    l_rowid := NULL;
    l_n_inst_appl_id := NULL;

    igs_fi_pp_ins_appls_pkg.insert_row(
                                        x_rowid                        => l_rowid,
                                        x_installment_application_id   => l_n_inst_appl_id,
                                        x_application_type_code        => 'APP',
                                        x_installment_id               => rec_cur_pp_insts.installment_id,
                                        x_credit_id                    => p_n_credit_id,
                                        x_credit_activity_id           => p_n_cr_activity_id,
                                        x_applied_amt                  => l_n_amt_apply,
                                        x_transaction_date             => TRUNC(SYSDATE),
                                        x_link_application_id          => NULL,
                                        x_mode                         => 'R'
                                        );

    --if the transaction amount become 0, terminate the looping Student's Active Payment Plan installment records.
    IF l_n_credit_amt = 0 THEN
      EXIT;
    END IF;

  END LOOP;
  CLOSE cur_pp_insts;

  --If the person has paid-off all his installments, then his active payment plan needs to be closed.
  IF igs_fi_gen_008.get_plan_balance(rec_cur_pp_insts.student_plan_id,NULL) = 0 THEN

    --Fetch the Student Active Payment Plan's details.
    OPEN cur_pmt_plan(p_n_person_id,'ACTIVE');
    FETCH cur_pmt_plan INTO rec_cur_pmt_plan;
    CLOSE cur_pmt_plan;

    --Close the Payment Plan specifying the System Date as plan end date.
    igs_fi_pp_std_attrs_pkg.update_row(
                                        x_rowid                    => rec_cur_pmt_plan.row_id,
                                        x_student_plan_id          => rec_cur_pmt_plan.student_plan_id,
                                        x_person_id                => rec_cur_pmt_plan.person_id,
                                        x_payment_plan_name        => rec_cur_pmt_plan.payment_plan_name,
                                        x_plan_start_date          => rec_cur_pmt_plan.plan_start_date,
                                        x_plan_end_date            => TRUNC(SYSDATE),
                                        x_plan_status_code         => 'CLOSED',
                                        x_processing_fee_amt       => rec_cur_pmt_plan.processing_fee_amt,
                                        x_processing_fee_type      => rec_cur_pmt_plan.processing_fee_type,
                                        x_fee_cal_type             => rec_cur_pmt_plan.fee_cal_type,
                                        x_fee_ci_sequence_number   => rec_cur_pmt_plan.fee_ci_sequence_number,
                                        x_notes                    => rec_cur_pmt_plan.notes,
                                        x_invoice_id               => rec_cur_pmt_plan.invoice_id,
                                        x_attribute_category       => rec_cur_pmt_plan.attribute_category,
                                        x_attribute1               => rec_cur_pmt_plan.attribute1,
                                        x_attribute2               => rec_cur_pmt_plan.attribute2,
                                        x_attribute3               => rec_cur_pmt_plan.attribute3,
                                        x_attribute4               => rec_cur_pmt_plan.attribute4,
                                        x_attribute5               => rec_cur_pmt_plan.attribute5,
                                        x_attribute6               => rec_cur_pmt_plan.attribute6,
                                        x_attribute7               => rec_cur_pmt_plan.attribute7,
                                        x_attribute8               => rec_cur_pmt_plan.attribute8,
                                        x_attribute9               => rec_cur_pmt_plan.attribute9,
                                        x_attribute10              => rec_cur_pmt_plan.attribute10,
                                        x_attribute11              => rec_cur_pmt_plan.attribute11,
                                        x_attribute12              => rec_cur_pmt_plan.attribute12,
                                        x_attribute13              => rec_cur_pmt_plan.attribute13,
                                        x_attribute14              => rec_cur_pmt_plan.attribute14,
                                        x_attribute15              => rec_cur_pmt_plan.attribute15,
                                        x_attribute16              => rec_cur_pmt_plan.attribute16,
                                        x_attribute17              => rec_cur_pmt_plan.attribute17,
                                        x_attribute18              => rec_cur_pmt_plan.attribute18,
                                        x_attribute19              => rec_cur_pmt_plan.attribute19,
                                        x_attribute20              => rec_cur_pmt_plan.attribute20,
                                        x_mode                     => 'R'
                                       );
  END IF;
END apply_installments;

PROCEDURE validate_parameters (
            p_n_validation_level IN NUMBER,
            p_credit_rec IN igs_fi_credit_pvt.credit_rec_type,
            p_attribute_rec IN igs_fi_credits_api_pub.attribute_rec_type,
            p_b_return_status OUT NOCOPY BOOLEAN
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  Procedure VALIDATE_PARAMETERS is the main procedure which has calls to
                    individual procedures or functions. When this procedure is invoked with FULL
                    validation level then all parameter validations will take place.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  svuppala  07-JUL-2005       Enh 3392095 - Tution Waivers build
                              Modified  validations of credit class and credit instrument in Validate_parameters.
 svuppala    9-JUN-2005       Enh 4213629 - The automatic generation of the Receipt Number.
                              Removed the validation to check if Credit Number is passed
                              if the combination of party_id and credit_number already exists in the system.
  vvutukur   23-Sep-2003      Enh#3045007.Payment Plan Build.Changes as specified in TD.
  vvutukur   15-Jul-2003      Enh#3038511.FICR106 Build. Added call to newly created generic procedure
                              get_award_year_status to validate the Award Year Status.
  vvutukur   18-Jun-2003      Enh#2831582.Lockbox Build. Removed call to function validate_lockbox as the same has been removed.
  schodava   11-Jun-03        Enh # 2831587. Credit Card Fund Transfer Build
                              Added validations for Credit Card status and credit card payee
********************************************************************************************** */
l_v_credit_class igs_fi_cr_types_all.credit_class%TYPE;
l_n_pay_cr_type_id igs_fi_cr_types.payment_credit_type_id%TYPE;
l_v_ld_cal_type  igs_ca_inst.cal_type%TYPE;
l_v_ld_ci_seq_num  igs_ca_inst.sequence_number%TYPE;
l_b_return_status BOOLEAN;
l_v_message_name fnd_new_messages.message_name%TYPE;
l_v_awd_yr_status_cd igf_ap_batch_aw_map.award_year_status_code%TYPE;

    FUNCTION get_cr_type(p_credit_type_id igs_fi_cr_types.credit_type_id%TYPE) RETURN VARCHAR2 AS
    /***********************************************************************************************
    Created By:      shtatiko
    Date Created By: 03-APR-2003
    Purpose:         This function returns credit type name for the specified credit type id.

    Known limitations,enhancements,remarks:
    Change History
    Who         When          What
    svuppala   9-JUN-2005     Enh 4213629 - The automatic generation of the Receipt Number.
                              Removed the validation to check if Credit Number is passed
                              if the combination of party_id and credit_number already exists in the system.
    ********************************************************************************************** */
    CURSOR cur_cr IS
      SELECT credit_type_name
      FROM   igs_fi_cr_types
      WHERE  credit_type_id = p_credit_type_id;
    l_cr_type igs_fi_cr_types.credit_type_name%TYPE;
    BEGIN
      OPEN cur_cr;
      FETCH cur_cr INTO l_cr_type;
      CLOSE cur_cr;
      RETURN l_cr_type;
    END get_cr_type;

BEGIN

  -- Currently p_n_validation_level can only take values 0 and 100
  IF p_n_validation_level NOT IN (FND_API.G_VALID_LEVEL_NONE, FND_API.G_VALID_LEVEL_FULL) THEN
    fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
    fnd_msg_pub.ADD;
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  -- If p_n_validation_level is 0 then no validations need to be done.
  IF p_n_validation_level = FND_API.G_VALID_LEVEL_NONE THEN
    p_b_return_status := TRUE;
    RETURN;
  END IF;

  -- Do all kinds of validations if validation level is 100, FND_API.G_VALID_LEVEL_FULL
  IF p_n_validation_level = FND_API.G_VALID_LEVEL_FULL THEN



      --  Check the status with which the current transaction is being created
      IF NOT igs_fi_crdapi_util.validate_credit_status ( p_v_crd_status => p_credit_rec.p_credit_status ) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_INVALID_CR_STAT');
          fnd_message.set_token ( 'CR_STAT', p_credit_rec.p_credit_status );
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- Validate lookup code passed for Credit Source
      IF p_credit_rec.p_credit_source IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_igf_lkp ( p_v_lookup_type => 'IGF_AW_FED_FUND', p_v_lookup_code => p_credit_rec.p_credit_source) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CRD_SRC_NULL');
            fnd_message.set_token ( 'CR_SOURCE', p_credit_rec.p_credit_source );
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Check if the Credit Type is active as on the current date
      igs_fi_crdapi_util.validate_credit_type ( p_n_credit_type_id => p_credit_rec.p_credit_type_id,
                                                p_v_credit_class   => l_v_credit_class,
                                                p_b_return_stat    => l_b_return_status);
      IF (l_b_return_status = FALSE)
         OR (igs_fi_crdapi_util.validate_igs_lkp ( 'IGS_FI_CREDIT_CLASS', l_v_credit_class ) = FALSE) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CR_TYPE_INVALID');
          fnd_message.set_token ( 'CR_TYPE', p_credit_rec.p_credit_type_id );
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;
      --- Check if credit_class holds a value of WAIVER
      -- 3392095
      IF l_v_credit_class = 'WAIVER' THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CR_TYPE_INVALID');
          fnd_message.set_token ( 'CR_TYPE', p_credit_rec.p_credit_type_id );
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;


      -- Check if the Party ID, Credit Class combination is valid.
      IF NOT igs_fi_crdapi_util.validate_party_id ( p_n_party_id => p_credit_rec.p_party_id,
                                                    p_v_credit_class => l_v_credit_class) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_PARTY_INVALID');
          fnd_message.set_token ( 'PARTY_ID', p_credit_rec.p_party_id);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      IF l_v_credit_class IN ('EXTFA','INTFA') THEN
        IF p_credit_rec.p_awd_yr_cal_type IS NULL
           OR p_credit_rec.p_awd_yr_ci_sequence_number IS NULL
           OR p_credit_rec.p_fee_cal_type IS NULL
           OR p_credit_rec.p_fee_ci_sequence_number IS NULL THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name ( 'IGS', 'IGS_FI_FPAY_MAND');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Check if the Credit Instrument is valid
      IF NOT igs_fi_crdapi_util.validate_igs_lkp ( p_v_lookup_type => 'IGS_FI_CREDIT_INSTRUMENT',
                                                   p_v_lookup_code => p_credit_rec.p_credit_instrument) THEN

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CRD_INSTR_NULL');
          fnd_message.set_token ( 'CR_INSTR', p_credit_rec.p_credit_instrument);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;

      ELSE
      -- Check if the Credit Instrument is valid and whether instrument is of WAIVER Type
      -- 3392095
        IF p_credit_rec.p_credit_instrument = 'WAIVER' AND
           fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN

          fnd_message.set_name ( 'IGS', 'IGS_FI_CAPI_CRD_INSTR_NULL');
          fnd_message.set_token ( 'CR_INSTR', p_credit_rec.p_credit_instrument);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;

        END IF;
      END IF;

      -- If the Credit Class is either 'Enrollment Deposit' or 'Other Deposit' then check if the
      -- Payment Credit Type attached to the Deposit Credit Type is active as on the current date.
      IF l_v_credit_class IN ('ENRDEPOSIT','OTHDEPOSIT') THEN
        igs_fi_crdapi_util.validate_dep_crtype( p_credit_rec.p_credit_type_id,
                                                l_n_pay_cr_type_id,
                                                l_b_return_status);
        IF NOT l_b_return_status THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS','IGS_FI_PCT_DCT_INVALID');
            fnd_message.set_token('PAY_CR_TYPE', l_n_pay_cr_type_id);
            fnd_message.set_token('DEP_CR_TYPE', p_credit_rec.p_credit_type_id);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
          END IF;
        END IF;
      END IF;

      -- Only for a Credit Instrument of 'Check', a value can be provided to the Check Number parameter.
      IF p_credit_rec.p_check_number IS NOT NULL AND p_credit_rec.p_credit_instrument <> 'CHECK' THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_INVALID_CHECK_NUMBER');
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- Check if the GL Date parameter (P_CREDIT_REC.P_GL_DATE) is in valid period
      igs_fi_crdapi_util.validate_gl_date ( p_d_gl_date      => p_credit_rec.p_gl_date,
                                            p_v_credit_class => l_v_credit_class,
                                            p_b_return_status=> l_b_return_status,
                                            p_v_message_name => l_v_message_name );
      IF l_b_return_status = FALSE THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', l_v_message_name);
          IF l_v_message_name = 'IGS_FI_INVALID_GL_DATE' THEN
            fnd_message.set_token ('GL_DATE', p_credit_rec.p_gl_date );
          END IF;
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- User is not allowed to create a transaction with Credit Class as Payment/Enrollment Deposit/Other Deposit/
      -- Installment Payments with Credit Instrument as 'DEPOSIT'.
      IF l_v_credit_class IN ('PMT','ENRDEPOSIT','OTHDEPOSIT','INSTALLMENT_PAYMENTS') AND p_credit_rec.p_credit_instrument = 'DEPOSIT' THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS','IGS_FI_CAPI_CRD_INSTR_NULL');
          fnd_message.set_token('CR_INSTR', p_credit_rec.p_credit_instrument);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- Validate Source Transaction Type Parameter, if passed
      IF p_credit_rec.p_source_tran_type IS NOT NULL THEN
        igs_fi_crdapi_util.validate_source_tran_type ( p_v_source_tran_type => p_credit_rec.p_source_tran_type,
                                                       p_v_credit_class     => l_v_credit_class,
                                                       p_v_credit_instrument=> p_credit_rec.p_credit_instrument,
                                                       p_b_return_status    => l_b_return_status,
                                                       p_v_message_name     => l_v_message_name );
        IF l_b_return_status = FALSE THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', l_v_message_name);
            IF l_v_message_name = 'IGS_FI_SOURCE_TRAN_TYP_INVALID' THEN
              fnd_message.set_token('VALUE', p_credit_rec.p_source_tran_type);
            END IF;
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      ELSIF l_v_credit_class = 'ENRDEPOSIT' THEN
        -- Source Transaction Type is mandatory for ENRDEPOSIT Credit Class
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- Validate Source Transaction Reference Number
      IF l_v_credit_class = 'ENRDEPOSIT' AND p_credit_rec.p_credit_instrument <> 'DEPOSIT' THEN
        IF NOT igs_fi_crdapi_util.validate_source_tran_ref_num(p_n_party_id => p_credit_rec.p_party_id,
                                                               p_n_source_tran_ref_num => p_credit_rec.p_source_tran_ref_number) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_SOURCE_TRAN_REF_INVALID');
            fnd_message.set_token('VALUE', p_credit_rec.p_source_tran_ref_number);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate Award Year, If passed
      IF p_credit_rec.p_awd_yr_cal_type IS NOT NULL AND p_credit_rec.p_awd_yr_ci_sequence_number IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_cal_inst ( p_v_cal_type => p_credit_rec.p_awd_yr_cal_type,
                                                      p_n_ci_sequence_number => p_credit_rec.p_awd_yr_ci_sequence_number,
                                                      p_v_s_cal_cat => 'AWARD') THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_INV_AWD_YR');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;

        l_v_message_name := NULL;
        igs_fi_crdapi_util.get_award_year_status( p_v_awd_cal_type     =>  p_credit_rec.p_awd_yr_cal_type,
                                                 p_n_awd_seq_number   =>  p_credit_rec.p_awd_yr_ci_sequence_number,
                                                 p_v_awd_yr_status    =>  l_v_awd_yr_status_cd,
                                                 p_v_message_name     =>  l_v_message_name
                                                );

        IF l_v_message_name IS NOT NULL THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS',l_v_message_name);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate Fee Period, If passed
      IF p_credit_rec.p_fee_cal_type IS NOT NULL AND p_credit_rec.p_fee_ci_sequence_number IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_cal_inst ( p_v_cal_type => p_credit_rec.p_fee_cal_type,
                                                      p_n_ci_sequence_number => p_credit_rec.p_fee_ci_sequence_number,
                                                      p_v_s_cal_cat => 'FEE') THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_FCI_NOTFOUND');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- If Fee period is passed and it is valid then check if there exists any relation with load calendar
      IF p_credit_rec.p_fee_cal_type IS NOT NULL AND p_credit_rec.p_fee_ci_sequence_number IS NOT NULL THEN
        igs_fi_crdapi_util.validate_fci_lci_reln ( p_v_fee_cal_type => p_credit_rec.p_fee_cal_type,
                                                   p_n_fee_ci_sequence_number => p_credit_rec.p_fee_ci_sequence_number,
                                                   p_v_ld_cal_type => l_v_ld_cal_type,
                                                   p_n_ld_ci_sequence_number => l_v_ld_ci_seq_num,
                                                   p_v_message_name => l_v_message_name,
                                                   p_b_return_stat => l_b_return_status ) ;
        IF l_b_return_status = FALSE THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', l_v_message_name);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate the currency code
      IF p_credit_rec.p_currency_cd IS NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      ELSIF NOT igs_fi_crdapi_util.validate_curr ( p_v_currency_cd => p_credit_rec.p_currency_cd) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS', 'IGS_FI_INVALID_CUR');
          fnd_message.set_token('CUR_CD', p_credit_rec.p_currency_cd);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      -- Validate Amount Passed
      igs_fi_crdapi_util.validate_amount ( p_n_amount => p_credit_rec.p_amount,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name => l_v_message_name );
      IF l_b_return_status = FALSE THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS', l_v_message_name);
          IF l_v_message_name = 'IGS_FI_CRD_AMT_NEGATIVE' THEN
            fnd_message.set_token ( 'CR_AMT', p_credit_rec.p_amount );
          END IF;
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;

      l_v_message_name := NULL;
      l_b_return_status := NULL;
      IF l_v_credit_class = 'INSTALLMENT_PAYMENTS' THEN
        --User should not be allowed to create an Installment Payment with the transaction amount greater than
        --the active Installment balance for the person.
        igs_fi_crdapi_util.validate_plan_balance(p_n_person_id     =>  p_credit_rec.p_party_id,
                                                 p_n_amount        =>  p_credit_rec.p_amount,
                                                 p_b_status        =>  l_b_return_status,
                                                 p_v_message_name  =>  l_v_message_name
                                                 );
        IF NOT l_b_return_status THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS',l_v_message_name);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate Credit Card Code, if passed
      IF p_credit_rec.p_credit_card_code IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_igs_lkp ( p_v_lookup_type => 'IGS_CREDIT_CARDS',
                                                     p_v_lookup_code => p_credit_rec.p_credit_card_code) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_CRD_CARD_INVALID');
            fnd_message.set_token('CRD_CARD', p_credit_rec.p_credit_card_code);
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate Credit Card Expiration date, if passed
      IF p_credit_rec.p_credit_card_expiration_date IS NOT NULL
         AND TRUNC(p_credit_rec.p_credit_card_expiration_date) < TRUNC(SYSDATE) THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name('IGS', 'IGS_FI_CRD_EXPDT_INVALID');
          fnd_message.set_token('EXP_DATE', p_credit_rec.p_credit_card_expiration_date);
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;


      -- Validate the Invoice Id, if passed
      IF p_credit_rec.p_invoice_id IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_invoice_id ( p_n_invoice_id => p_credit_rec.p_invoice_id) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_NO_INV_INVOICE_TBL');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Validate the Credit Card Payee, if passed
      IF p_credit_rec.p_v_credit_card_payee_cd IS NOT NULL THEN
        IF NOT igs_fi_crdapi_util.validate_credit_card_payee(p_v_credit_card_payee_cd => p_credit_rec.p_v_credit_card_payee_cd) THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_FI_INV_PAYEEID');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
        END IF;
      END IF;

      -- Check if the Credit Card Status is valid, if passed
    IF p_credit_rec.p_v_credit_card_status_code IS NOT NULL THEN
      IF NOT igs_fi_crdapi_util.validate_igs_lkp ( p_v_lookup_type => 'IGS_FI_CREDIT_CARD_STATUS',
                                                   p_v_lookup_code => p_credit_rec.p_v_credit_card_status_code)
         OR p_credit_rec.p_v_credit_card_status_code <> 'PENDING' THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
          fnd_message.set_name ( 'IGS', 'IGS_FI_INV_CC_STATUS');
          fnd_msg_pub.ADD;
          p_b_return_status := FALSE;
          RETURN;
        END IF;
      END IF;
    END IF;

      -- Validate descriptive flex-field attribute values
      IF NOT igs_fi_crdapi_util.validate_desc_flex (
               p_v_attribute_category => p_attribute_rec.p_attribute_category,
               p_v_attribute1  =>              p_attribute_rec.p_attribute1,
               p_v_attribute2  =>              p_attribute_rec.p_attribute2,
               p_v_attribute3  =>              p_attribute_rec.p_attribute3,
               p_v_attribute4  =>              p_attribute_rec.p_attribute4,
               p_v_attribute5  =>              p_attribute_rec.p_attribute5,
               p_v_attribute6  =>              p_attribute_rec.p_attribute6,
               p_v_attribute7  =>              p_attribute_rec.p_attribute7,
               p_v_attribute8  =>              p_attribute_rec.p_attribute8,
               p_v_attribute9  =>              p_attribute_rec.p_attribute9,
               p_v_attribute10 =>              p_attribute_rec.p_attribute10,
               p_v_attribute11 =>              p_attribute_rec.p_attribute11,
               p_v_attribute12 =>              p_attribute_rec.p_attribute12,
               p_v_attribute13 =>              p_attribute_rec.p_attribute13,
               p_v_attribute14 =>              p_attribute_rec.p_attribute14,
               p_v_attribute15 =>              p_attribute_rec.p_attribute15,
               p_v_attribute16 =>              p_attribute_rec.p_attribute16,
               p_v_attribute17 =>              p_attribute_rec.p_attribute17,
               p_v_attribute18 =>              p_attribute_rec.p_attribute18,
               p_v_attribute19 =>              p_attribute_rec.p_attribute19,
               p_v_attribute20 =>              p_attribute_rec.p_attribute20,
               p_v_desc_flex_name => 'IGS_FI_CREDITS_ALL_FLEX') THEN
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
            fnd_message.set_name('IGS', 'IGS_AD_INVALID_DESC_FLEX');
            fnd_msg_pub.ADD;
            p_b_return_status := FALSE;
            RETURN;
          END IF;
      END IF;

      -- All validations are successfully completed. Return with success
      p_b_return_status := TRUE;
      RETURN;
  END IF; -- p_validation_level = FND_API.G_VALID_LEVEL_FULL

END validate_parameters;

FUNCTION validate_credit_status ( p_v_crd_status IN VARCHAR2 ) RETURN BOOLEAN
AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if transaction status is valid

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */

BEGIN
  -- Parameter p_v_crd_status is mandatory.
  IF (p_v_crd_status IS NULL) OR (p_v_crd_status <> 'CLEARED') THEN
    RETURN FALSE;
  END IF;
  RETURN igs_fi_crdapi_util.validate_igs_lkp (p_v_lookup_type => 'IGS_FI_CREDIT_STATUS', p_v_lookup_code => 'CLEARED');

END validate_credit_status;

FUNCTION validate_igs_lkp (
           p_v_lookup_type IN VARCHAR2,
           p_v_lookup_code IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the IGS lookup code is valid for the lookup type.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR cur_igs_lkp (cp_lookup_code igs_lookup_values.lookup_code%TYPE,
                    cp_lookup_type igs_lookup_values.lookup_type%TYPE,
                    cp_enabled_flag VARCHAR2)
IS
  SELECT 'x'
  FROM igs_lookup_values
  WHERE lookup_type = cp_lookup_type
  AND lookup_code = cp_lookup_code
  AND enabled_flag = cp_enabled_flag
  AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE_ACTIVE, SYSDATE)) AND TRUNC(NVL(END_DATE_ACTIVE, SYSDATE));
rec_igs_lkp cur_igs_lkp%ROWTYPE;

BEGIN
  -- Both parameters are mandatory
  IF p_v_lookup_type IS NULL OR p_v_lookup_code IS NULL THEN
    RETURN FALSE;
  END IF;
  OPEN cur_igs_lkp (p_v_lookup_code, p_v_lookup_type, 'Y');
  FETCH cur_igs_lkp INTO rec_igs_lkp;
  IF cur_igs_lkp%FOUND THEN
    CLOSE cur_igs_lkp;
    RETURN TRUE;
  ELSE
    CLOSE cur_igs_lkp;
    RETURN FALSE;
  END IF;
END validate_igs_lkp;

FUNCTION validate_igf_lkp (
           p_v_lookup_type IN VARCHAR2,
           p_v_lookup_code IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the IGF lookup code is valid for the lookup type.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR cur_igf_lkp (cp_lookup_code igf_lookups_view.lookup_code%TYPE,
                    cp_lookup_type igf_lookups_view.lookup_type%TYPE,
                    cp_enabled_flag VARCHAR2)
IS
  SELECT 'x'
  FROM igf_lookups_view
  WHERE lookup_type = cp_lookup_type
  AND lookup_code = cp_lookup_code
  AND enabled_flag= cp_enabled_flag;
rec_igf_lkp cur_igf_lkp%ROWTYPE;

BEGIN
  -- Both parameters are mandatory
  IF p_v_lookup_type IS NULL OR p_v_lookup_code IS NULL THEN
    RETURN FALSE;
  END IF;

  OPEN cur_igf_lkp (p_v_lookup_code, p_v_lookup_type, 'Y');
  FETCH cur_igf_lkp INTO rec_igf_lkp;
  IF cur_igf_lkp%FOUND THEN
    CLOSE cur_igf_lkp;
    RETURN TRUE;
  ELSE
    CLOSE cur_igf_lkp;
    RETURN FALSE;
  END IF;
END validate_igf_lkp;

PROCEDURE validate_credit_type (
            p_n_credit_type_id IN PLS_INTEGER,
            p_v_credit_class OUT NOCOPY VARCHAR2,
            p_b_return_stat OUT NOCOPY BOOLEAN
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure validates a credit type is active and effective as on the
                    current system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR cur_cr_typ (cp_credit_type_id igs_fi_cr_types_all.credit_type_id%TYPE)
IS
  SELECT credit_class
  FROM   igs_fi_cr_types_all
  WHERE credit_type_id = cp_credit_type_id
  AND TRUNC(SYSDATE) BETWEEN TRUNC(effective_start_date) AND TRUNC(NVL(effective_end_date,SYSDATE));

BEGIN

  IF p_n_credit_type_id IS NULL THEN
    p_v_credit_class := NULL;
    p_b_return_stat := FALSE;
    RETURN;
  END IF;

  OPEN cur_cr_typ(p_n_credit_type_id);
  FETCH cur_cr_typ INTO p_v_credit_class;
  IF cur_cr_typ%FOUND THEN
    p_b_return_stat := TRUE;
  ELSE
    p_v_credit_class := NULL;
    p_b_return_stat := FALSE;
  END IF;
  CLOSE cur_cr_typ;
END validate_credit_type;

FUNCTION validate_curr ( p_v_currency_cd IN VARCHAR2 ) RETURN BOOLEAN
AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the currency code is active in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR c_cur_cd (cp_currency_cd fnd_currencies_active_v.currency_code%TYPE)
IS
  SELECT 'x'
  FROM fnd_currencies_active_v
  WHERE currency_code = cp_currency_cd
  AND   currency_code <> 'STAT';
rec_cur_cd c_cur_cd%ROWTYPE;
BEGIN

  IF p_v_currency_cd IS NULL THEN
    RETURN FALSE;
  END IF;
  OPEN c_cur_cd( p_v_currency_cd );
  FETCH c_cur_cd INTO rec_cur_cd;
  IF c_cur_cd%FOUND THEN
    CLOSE c_cur_cd;
    RETURN TRUE;
  ELSE
    CLOSE c_cur_cd;
    RETURN FALSE;
  END IF;

END validate_curr;

FUNCTION validate_cal_inst (
           p_v_cal_type IN VARCHAR2,
           p_n_ci_sequence_number IN PLS_INTEGER,
           p_v_s_cal_cat IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the Calendar Instance is active in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR c_cal_inst(cp_cal_type IN igs_ca_inst.cal_type%TYPE,
                  cp_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                  cp_s_cal_cat IN igs_ca_type.s_cal_cat%TYPE)
IS
  SELECT 'x'
  FROM   igs_ca_inst ci,
         igs_ca_type cat,
         igs_ca_stat stat
  WHERE ci.cal_type = cp_cal_type
  AND   ci.sequence_number = cp_ci_sequence_number
  AND   ci.cal_status = stat.cal_status
  AND   stat.s_cal_status = 'ACTIVE'
  AND   ci.cal_type = cat.cal_type
  AND   cat.s_cal_cat = cp_s_cal_cat;
rec_cal_inst c_cal_inst%ROWTYPE;

BEGIN

  -- All three parameters are mandatory
  IF p_v_cal_type IS NULL OR p_n_ci_sequence_number IS NULL OR p_v_s_cal_cat IS NULL THEN
    RETURN FALSE;
  END IF;

  OPEN c_cal_inst ( p_v_cal_type, p_n_ci_sequence_number, p_v_s_cal_cat );
  FETCH c_cal_inst INTO rec_cal_inst;
  IF c_cal_inst%FOUND THEN
    CLOSE c_cal_inst;
    RETURN TRUE;
  ELSE
    CLOSE c_cal_inst;
    RETURN FALSE;
  END IF;

END validate_cal_inst;

FUNCTION val_cal_inst (
           p_v_cal_type IN VARCHAR2,
           p_n_ci_sequence_number IN NUMBER,
           p_v_s_cal_cat IN VARCHAR2
) RETURN VARCHAR2 AS
/***********************************************************************************************
  Created By     :  sapanigr
  Date Created By:  22-NOV-2005
  Purpose        :  This function is similar to validate_cal_inst but returns VARCHAR TRUE or FALSE

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
BEGIN
    IF igs_fi_crdapi_util.validate_cal_inst(
       p_v_cal_type,
       p_n_ci_sequence_number,
       p_v_s_cal_cat) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
END val_cal_inst;



PROCEDURE validate_fci_lci_reln (
            p_v_fee_cal_type IN VARCHAR2,
            p_n_fee_ci_sequence_number IN PLS_INTEGER,
            p_v_ld_cal_type OUT NOCOPY VARCHAR2,
            p_n_ld_ci_sequence_number OUT NOCOPY PLS_INTEGER,
            p_v_message_name OUT NOCOPY VARCHAR2,
            p_b_return_stat OUT NOCOPY BOOLEAN
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure checks if there exists a relation between Fee and Load calendar
                    instance and checks if the Load Calendar Instance is active in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
  l_b_ret BOOLEAN;
  l_v_ld_cal_type  igs_ca_inst.cal_type%TYPE;
  l_n_ld_seq_number  igs_ca_inst.sequence_number%TYPE;
  l_v_message_name fnd_new_messages.message_name%TYPE;

BEGIN

  IF p_v_fee_cal_type IS NULL OR p_n_fee_ci_sequence_number IS NULL THEN
    p_v_message_name := NULL;
    p_b_return_stat := FALSE;
    RETURN;
  END IF;

  -- Check if a relation exists
  l_b_ret := igs_fi_gen_001.finp_get_lfci_reln (
               p_cal_type               => p_v_fee_cal_type,
               p_ci_sequence_number     => p_n_fee_ci_sequence_number,
               p_cal_category           => 'FEE',
               p_ret_cal_type           => l_v_ld_cal_type,
               p_ret_ci_sequence_number => l_n_ld_seq_number,
               p_message_name           => l_v_message_name );
  IF NOT l_b_ret THEN
    p_v_message_name := l_v_message_name;
    p_b_return_stat := FALSE;
  ELSE
    -- Check if load calendar instance is active in the system.
    IF igs_fi_crdapi_util.validate_cal_inst (
         p_v_cal_type => l_v_ld_cal_type,
         p_n_ci_sequence_number => l_n_ld_seq_number,
         p_v_s_cal_cat => 'LOAD') THEN
      p_v_message_name := NULL;
      p_b_return_stat := TRUE;
      p_v_ld_cal_type := l_v_ld_cal_type;
      p_n_ld_ci_sequence_number := l_n_ld_seq_number;
    ELSE
      p_v_message_name := 'IGS_FI_LOAD_CAL_NOT_ACTIVE';
      p_b_return_stat := FALSE;
      p_v_ld_cal_type := NULL;
      p_n_ld_ci_sequence_number := NULL;
    END IF;
  END IF;

END validate_fci_lci_reln;

PROCEDURE validate_dep_crtype (
            p_n_credit_type_id IN PLS_INTEGER,
            p_n_pay_credit_type_id OUT NOCOPY PLS_INTEGER,
            p_b_return_stat OUT NOCOPY BOOLEAN
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure checks if the payment credit type attached to the Enrollment
                    Deposit or Other Deposit credit type is active in the system as on the current
                    system date. When Payment Credit Type is found to be active then this procedure
                    returns this payment credit type as OUT variable.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
CURSOR c_check_cr_typ_id (cp_cr_typ_id igs_fi_cr_types.credit_type_id%TYPE)
IS
  SELECT c.payment_credit_type_id
  FROM igs_fi_cr_types c
  WHERE c.credit_type_id = cp_cr_typ_id
  AND TRUNC(SYSDATE) BETWEEN TRUNC(c.effective_start_date) AND TRUNC(NVL(c.effective_end_date,SYSDATE))
  AND EXISTS (SELECT 'x'
              FROM igs_fi_cr_types p
              WHERE p.credit_type_id = c.payment_credit_type_id
              AND TRUNC(SYSDATE) BETWEEN TRUNC(p.effective_start_date) AND TRUNC(NVL(p.effective_end_date,SYSDATE)));

BEGIN

  IF p_n_credit_type_id IS NULL THEN
    p_n_pay_credit_type_id := NULL;
    p_b_return_stat := FALSE;
    RETURN;
  END IF;

  OPEN c_check_cr_typ_id ( p_n_credit_type_id );
  FETCH c_check_cr_typ_id INTO p_n_pay_credit_type_id;
  IF c_check_cr_typ_id%FOUND THEN
    CLOSE c_check_cr_typ_id;
    p_b_return_stat := TRUE;
  ELSE
    CLOSE c_check_cr_typ_id;
    p_b_return_stat := FALSE;
    p_n_pay_credit_type_id := NULL;
  END IF;

END validate_dep_crtype;

FUNCTION validate_party_id (
           p_n_party_id IN PLS_INTEGER,
           p_v_credit_class IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  Validates the combination of Party Id and Credit Class

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
 sapanigr 12-Feb-2006 Bug#5018036 - Cursor c_valid_person now uses hz_parties instead of igs_fi_parties_v. (R12 SQL Repository tuning)
 vvutukur 13-Sep-2003 Enh#3045007.Payment Plans Build. Modified the code so that the function validates if the
                      input person is on an Active Payment Plan if the input credit class is Installment Payments.
***********************************************************************************************/
CURSOR c_valid_person( cp_party_id       igs_fi_parties_v.person_id%TYPE,
                       cp_party_type     igs_fi_parties_v.party_type%TYPE
                     ) IS
  SELECT 'x'
  FROM   hz_parties
  WHERE  party_id = cp_party_id
  AND    party_type = cp_party_type;
rec_valid_person c_valid_person%ROWTYPE;

BEGIN

  IF p_n_party_id IS NULL OR p_v_credit_class IS NULL THEN
    RETURN FALSE;
  END IF;

  IF p_v_credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT') THEN
    IF igs_fi_gen_007.validate_person( p_n_party_id ) = 'N' THEN
      RETURN FALSE;
    ELSE
      --If the input credit class is Installment Payments.. then
      IF p_v_credit_class = 'INSTALLMENT_PAYMENTS' THEN
        --Check if the person is on an active Payment Plan. If yes, return TRUE else return FALSE from this function.
        IF igs_fi_gen_008.chk_active_pay_plan(p_n_party_id) = 'Y' THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      END IF;
      RETURN TRUE;
    END IF;
  ELSE -- If Credit Class is ENRDEPOSIT or OTHDEPOSIT
    -- If Credit Class is ENRDEPOSIT Party should be a PERSON and a STUDENT
    -- If Credit Class is OTHDEPOSIT Party should be a PERSON
    OPEN c_valid_person ( p_n_party_id, 'PERSON' );
    FETCH c_valid_person INTO rec_valid_person;
    IF c_valid_person%FOUND THEN
      CLOSE c_valid_person;
      IF ( p_v_credit_class = 'ENRDEPOSIT' AND NVL(SUBSTR(igs_en_gen_007.enrp_get_student_ind(p_n_party_id),1,1),'N')= 'Y' )
         OR p_v_credit_class = 'OTHDEPOSIT' THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      CLOSE c_valid_person;
      RETURN FALSE;
    END IF;
  END IF;

END validate_party_id;

PROCEDURE validate_gl_date (
            p_d_gl_date IN DATE,
            p_v_credit_class IN VARCHAR2,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure checks if the GL Date is valid in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
l_v_message_name     fnd_new_messages.message_name%TYPE;
l_v_closing_status   gl_period_statuses.closing_status%TYPE;
BEGIN

  IF p_d_gl_date IS NULL OR p_v_credit_class IS NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER' ;
    RETURN;
  END IF;

  IF p_v_credit_class IN ('ONLINE PAYMENT') THEN
    p_b_return_status := TRUE;
    p_v_message_name := NULL ;
    RETURN;
  END IF;

  -- Check the closing status of the passed gl_date
  igs_fi_gen_gl.get_period_status_for_date(p_d_date           => p_d_gl_date,
                                           p_v_closing_status => l_v_closing_status,
                                           p_v_message_name   => l_v_message_name);
  IF l_v_message_name IS NOT NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name  := l_v_message_name;
    RETURN;
  END IF;
  IF l_v_closing_status NOT IN ('O','F') THEN
    p_b_return_status := FALSE;
    p_v_message_name  := 'IGS_FI_INVALID_GL_DATE';
    RETURN;
  END IF;
  p_v_message_name := NULL ;
  p_b_return_status := TRUE;
END validate_gl_date;

PROCEDURE validate_source_tran_type (
            p_v_source_tran_type IN VARCHAR2,
            p_v_credit_class IN VARCHAR2,
            p_v_credit_instrument IN VARCHAR2,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure checks if the combination of Source Transaction Type,
                    Credit Class is valid.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
  vvutukur  13-Sep-2003   Enh#3045007.Payment Plans Build. Modified the code to validate source transaction type,
                          if provided.
***********************************************************************************************/

BEGIN

  IF p_v_source_tran_type IS NULL OR p_v_credit_class IS NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER' ;
    RETURN;
  END IF;

  -- Check if source transaction type is valid
  IF NOT igs_fi_crdapi_util.validate_igs_lkp ( p_v_lookup_type => 'IGS_FI_SOURCE_TRANSACTION_REF',
                                               p_v_lookup_code => p_v_source_tran_type ) THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_SOURCE_TRAN_TYP_INVALID';
    RETURN;
  END IF;

  -- Source transaction reference type can be provided for Payment, Enrollment Deposit ,
  -- Other Deposit,Installment Payments credit class only.
  IF p_v_credit_class NOT IN ('PMT', 'ENRDEPOSIT', 'OTHDEPOSIT','INSTALLMENT_PAYMENTS') THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_SOURCE_TRAN_CC_INVALID';
    RETURN;
  END IF;

  -- If Credit Class is 'Other Deposit' then the Source Transaction type should be other than  'ADM', 'DEPOSIT'
  -- For a receipt transaction with 'Payment' credit class and with a Credit Instrument other than 'Deposit', if a value is
  -- passed to Source Transaction Type parameter then check if the value provided is other than 'Admission Application' or 'Deposit'
  -- If Credit Class is 'Enrollment Deposit' then the Source Transaction type should always be 'Admission Application' - 'ADM'
  IF ((p_v_credit_class = 'OTHDEPOSIT' AND p_v_source_tran_type IN ('ADM', 'DEPOSIT'))
       OR (p_v_credit_class IN ('PMT','INSTALLMENT_PAYMENTS') AND p_v_credit_instrument <> 'DEPOSIT' AND p_v_source_tran_type IN ('ADM', 'DEPOSIT'))
       OR (p_v_credit_class IN ('ENRDEPOSIT') AND p_v_source_tran_type <> 'ADM')
     ) THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_SOURCE_TRAN_TYP_INVALID';
    RETURN;
  END IF;
  -- If all validations passed then return with success.
  p_b_return_status := TRUE;
  p_v_message_name := NULL;

END validate_source_tran_type;

FUNCTION validate_source_tran_ref_num (
           p_n_party_id IN PLS_INTEGER,
           p_n_source_tran_ref_num IN PLS_INTEGER
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the Source Transaction Reference Number is valid in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
CURSOR c_source_tran_ref (cp_party_id IN NUMBER,
                          cp_appl_id  IN NUMBER
                         )IS
SELECT 'x'
FROM   igs_ad_appl appl
WHERE  appl.person_id = cp_party_id
AND    appl.application_id = cp_appl_id
AND    EXISTS ( SELECT 'X'
                FROM  igs_ad_ps_appl_inst apl_in,
                      igs_ad_ofrdfrmt_stat df,
                      igs_ad_ofr_resp_stat off
                WHERE apl_in.person_id = appl.person_id
                AND   apl_in.admission_appl_number = appl.admission_appl_number
                AND   apl_in.adm_offer_resp_status = off.adm_offer_resp_status
                AND   apl_in.adm_offer_dfrmnt_status = df.adm_offer_dfrmnt_status
                AND   (off.s_adm_offer_resp_status ='ACCEPTED' OR
                       (off.s_adm_offer_resp_status ='DEFERRAL' AND df.s_adm_offer_dfrmnt_status = 'CONFIRM')
                       ));
rec_source_tran_ref c_source_tran_ref%ROWTYPE;

BEGIN

  IF p_n_party_id IS NULL OR p_n_source_tran_ref_num IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Check if the Source Transaction Reference Number is a valid application number for the given person
  OPEN c_source_tran_ref ( p_n_party_id, p_n_source_tran_ref_num );
  FETCH c_source_tran_ref INTO rec_source_tran_ref;
  IF c_source_tran_ref%FOUND THEN
    CLOSE c_source_tran_ref;
    RETURN TRUE;
  ELSE
    CLOSE c_source_tran_ref;
    RETURN FALSE;
  END IF;

END validate_source_tran_ref_num;

PROCEDURE validate_amount (
            p_n_amount IN NUMBER,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure will validates Amount

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
BEGIN

  IF p_n_amount IS NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_CAPI_CRD_AMT_NULL';
    RETURN;
  END IF;

  IF p_n_amount < 0 THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_CRD_AMT_NEGATIVE';
    RETURN;
  END IF;

  p_b_return_status := TRUE;
  p_v_message_name := NULL;

END validate_amount;

FUNCTION validate_desc_flex (
           p_v_attribute_category IN VARCHAR2,
           p_v_attribute1 IN VARCHAR2,
           p_v_attribute2 IN VARCHAR2,
           p_v_attribute3 IN VARCHAR2,
           p_v_attribute4 IN VARCHAR2,
           p_v_attribute5 IN VARCHAR2,
           p_v_attribute6 IN VARCHAR2,
           p_v_attribute7 IN VARCHAR2,
           p_v_attribute8 IN VARCHAR2,
           p_v_attribute9 IN VARCHAR2,
           p_v_attribute10 IN VARCHAR2,
           p_v_attribute11 IN VARCHAR2,
           p_v_attribute12 IN VARCHAR2,
           p_v_attribute13 IN VARCHAR2,
           p_v_attribute14 IN VARCHAR2,
           p_v_attribute15 IN VARCHAR2,
           p_v_attribute16 IN VARCHAR2,
           p_v_attribute17 IN VARCHAR2,
           p_v_attribute18 IN VARCHAR2,
           p_v_attribute19 IN VARCHAR2,
           p_v_attribute20 IN VARCHAR2,
           p_v_desc_flex_name IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  Function for validating Descriptive Flex-Field combination.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/

BEGIN
  -- Parameter p_v_desc_flex_name are mandatory
  IF p_v_desc_flex_name IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN igs_ad_imp_018.validate_desc_flex (
    p_attribute_category => p_v_attribute_category,
    p_attribute1  => p_v_attribute1,
    p_attribute2  => p_v_attribute2,
    p_attribute3  => p_v_attribute3,
    p_attribute4  => p_v_attribute4,
    p_attribute5  => p_v_attribute5,
    p_attribute6  => p_v_attribute6,
    p_attribute7  => p_v_attribute7,
    p_attribute8  => p_v_attribute8,
    p_attribute9  => p_v_attribute9,
    p_attribute10 => p_v_attribute10,
    p_attribute11 => p_v_attribute11,
    p_attribute12 => p_v_attribute12,
    p_attribute13 => p_v_attribute13,
    p_attribute14 => p_v_attribute14,
    p_attribute15 => p_v_attribute15,
    p_attribute16 => p_v_attribute16,
    p_attribute17 => p_v_attribute17,
    p_attribute18 => p_v_attribute18,
    p_attribute19 => p_v_attribute19,
    p_attribute20 => p_v_attribute20,
    p_desc_flex_name => p_v_desc_flex_name);

END validate_desc_flex;

FUNCTION validate_invoice_id ( p_n_invoice_id IN PLS_INTEGER ) RETURN BOOLEAN
AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This function checks if the Invoice ID exists in the system.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
CURSOR c_inv_id(cp_invoice_id  igs_fi_inv_int.invoice_id%TYPE) IS
  SELECT 'x'
  FROM   igs_fi_inv_int
  WHERE invoice_id=cp_invoice_id;
rec_inv_id c_inv_id%ROWTYPE;

BEGIN
  IF p_n_invoice_id IS NULL THEN
    RETURN FALSE;
  END IF;

  OPEN c_inv_id ( p_n_invoice_id );
  FETCH c_inv_id INTO rec_inv_id;
  IF c_inv_id%FOUND THEN
    CLOSE c_inv_id;
    RETURN TRUE;
  ELSE
    CLOSE c_inv_id;
    RETURN FALSE;
  END IF;

END validate_invoice_id;

FUNCTION validate_credit_card_payee (p_v_credit_card_payee_cd IN VARCHAR2 ) RETURN BOOLEAN
AS
/***********************************************************************************************
  Created By     :  schodava
  Date Created By:  11-Jun-2003
  Purpose        :  This function checks if credit card payee is valid

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */

-- Get the payee
CURSOR c_payee (cp_payeeid IN VARCHAR2) IS
  SELECT name, payeeid
  FROM   iby_payee
  WHERE  payeeid = cp_payeeid
  AND    NVL(activestatus,'N')='Y';
  rec_payee c_payee%ROWTYPE;

BEGIN
  -- Check if the payee parameter is a valid payee in the iPayment table
  OPEN c_payee(cp_payeeid => p_v_credit_card_payee_cd);
  FETCH c_payee INTO rec_payee;
  IF c_payee%NOTFOUND THEN
    CLOSE c_payee;
    RETURN FALSE;
  ELSE
    CLOSE c_payee;
    RETURN TRUE;
  END IF;
END validate_credit_card_payee;

PROCEDURE translate_local_currency (
            p_n_amount IN OUT NOCOPY NUMBER,
            p_v_currency_cd IN OUT NOCOPY VARCHAR2,
            p_n_exchange_rate IN  NUMBER,
            p_b_return_status OUT NOCOPY BOOLEAN,
            p_v_message_name OUT NOCOPY VARCHAR2
) AS
/***********************************************************************************************
  Created By     :  Shtatiko
  Date Created By:  03-APR-2003
  Purpose        :  This procedure will determine the transaction amount in terms of the
                    functional currency.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
***********************************************************************************************/
l_v_currency_cd   igs_fi_control_v.currency_cd%TYPE;
l_v_curr_desc     igs_fi_control_v.name%TYPE;
l_v_message_name  fnd_new_messages.message_name%TYPE;

BEGIN

  IF p_n_amount IS NULL
     OR p_v_currency_cd IS NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER';
    RETURN;
  END IF;
  -- Get the local currency that is set at the System Options Form
  igs_fi_gen_gl.finp_get_cur ( p_v_currency_cd => l_v_currency_cd,
                               p_v_curr_desc   => l_v_curr_desc,
                               p_v_message_name=> l_v_message_name );
  IF l_v_message_name IS NOT NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := l_v_message_name;
    RETURN;
  END IF;

  -- Check if the derived local currency code and the passed one are same.
  IF l_v_currency_cd = p_v_currency_cd THEN
    p_b_return_status := TRUE;
    p_v_message_name := NULL;
    RETURN;
  END IF;

  -- Local currency code and the passed one are different, then exchange rate should be passed
  IF p_n_exchange_rate IS NULL THEN
    p_b_return_status := FALSE;
    p_v_message_name := 'IGS_FI_NO_EXCHG_RATE';
  ELSE
    p_v_currency_cd := l_v_currency_cd;
    p_n_amount:= p_n_amount * p_n_exchange_rate;
    p_b_return_status := TRUE;
    p_v_message_name := NULL;
  END IF;

END translate_local_currency;

END igs_fi_crdapi_util;

/
