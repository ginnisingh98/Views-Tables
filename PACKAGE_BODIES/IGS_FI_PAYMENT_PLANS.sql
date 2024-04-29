--------------------------------------------------------
--  DDL for Package Body IGS_FI_PAYMENT_PLANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PAYMENT_PLANS" AS
/* $Header: IGSFI87B.pls 120.4 2006/06/13 08:50:33 sapanigr noship $ */
------------------------------------------------------------------
--Created by  : vvutukur, Oracle IDC
--Date created: 27-Aug-2003
--
--Purpose:  This package contains the Concurrent processes related to
--          the Payment Plans.(Created as part of Payment Plans Build,
--          Enh#3045007.
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--sapanigr  13-Jun-2006    Bug#5088965.Modified activate_plan
--sapanigr  12-Jun-2006    Bug 5068241.Modified assign_students.
--abshriva   4-May-2006   Bug 5178077: Modification in CLOSE_STATUS and ACTIVATE_PLAN
--vvutukur  03-Feb-2004    Bug#3399850.Modified assign_students.
--bannamal  22-jul-2004    Bug#3781266.GSCC warning file.sql.35 was
--                         fixed. The procedure activate_plan was modified.
-------------------------------------------------------------------

  --Declaration of a ref cursor type.
  TYPE cur_ref IS REF CURSOR;

  e_skip_record        EXCEPTION;
  e_resource_busy      EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_resource_busy, -54);

  g_v_ind_yes          CONSTANT VARCHAR2(1) := 'Y';
  g_v_ind_no           CONSTANT VARCHAR2(1) := 'N';
  g_v_planned          CONSTANT igs_fi_pp_std_attrs.plan_status_code%TYPE := 'PLANNED';
  g_v_active           CONSTANT igs_fi_pp_std_attrs.plan_status_code%TYPE := 'ACTIVE';
  g_v_monthly          CONSTANT igs_fi_pp_templates.installment_period_code%TYPE := 'MONTHLY';
  g_v_bi_monthly       CONSTANT igs_fi_pp_templates.installment_period_code%TYPE := 'BI_MONTHLY';
  g_v_quarterly        CONSTANT igs_fi_pp_templates.installment_period_code%TYPE := 'QUARTERLY';
  g_v_line             CONSTANT VARCHAR2(100) := '+'||RPAD('-',75,'-')||'+';

  g_v_offset_days      CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','OFFSET_DAYS');
  g_v_person_group     CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP');
  g_v_fee_period       CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_PERIOD');
  g_v_pp_status        CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','STATUS');
  g_v_warning          CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','WARNING');
  g_v_success          CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','SUCCESS');
  g_v_error            CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','ERROR');
  g_v_person           CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON');
  g_d_sysdate          CONSTANT DATE := TRUNC(SYSDATE);

  --Cursor for validating person group.
  CURSOR cur_pers_grp(cp_n_pers_grp_id igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT 'x'
    FROM   igs_pe_persid_group_all
    WHERE  group_id = cp_n_pers_grp_id
    AND    TRUNC(create_dt) <= g_d_sysdate
    AND    NVL(closed_ind,g_v_ind_no) = g_v_ind_no;


  PROCEDURE activate_plan(errbuf                  OUT NOCOPY VARCHAR2,
                          retcode                 OUT NOCOPY NUMBER,
                          p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE,
                          p_v_fee_period          IN  VARCHAR2,
                          p_n_offset_days         IN  NUMBER
                          ) AS
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 27-Aug-2003
  --
  --Purpose:  Concurrent program that activates the Payment Plans
  --          that are in a planned status for the Student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr    13-Jun-2006     Bug#5088965.Message 'IGS_FI_PP_NO_PRC_FEE_SETUP' is now logged
  --                            if fee period parameter is passed as input and no processing fee
  --                            type has been setup for student.

  --abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
  --bannamal    22-jul-2004     Bug#3781266.Modified the logging status from
  --                            warning to error in case of failure to activate
  --                            the payment plan
  -------------------------------------------------------------------

    --Declaration of Ref cursor variable type.
    l_cur_ref cur_ref;
    l_org_id     VARCHAR2(15);
    --Cursor to validate if the Student has a Payment Plan with the status of ACTIVE.
    CURSOR cur_pmt_active(cp_n_person_id igs_fi_parties_v.person_id%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    plan_status_code = g_v_active;

    --Cursor to validate if the Student has a Payment Plan with the status of PLANNED.
    --This cursor also selects the details of the Planned Payment Plans for a Student.
    CURSOR cur_pmt_planned(cp_n_person_id igs_fi_parties_v.person_id%TYPE) IS
      SELECT a.rowid,a.*
      FROM   igs_fi_pp_std_attrs a
      WHERE  a.person_id = cp_n_person_id
      AND    a.plan_status_code = g_v_planned
      AND    a.plan_start_date <= g_d_sysdate
      FOR UPDATE NOWAIT;

    rec_cur_pmt_planned cur_pmt_planned%ROWTYPE;

    --Cursor to validate if the specified Payment Plan has the Start Date
    --overlapping with the End Date of the previous plan.
    CURSOR cur_validate_st_dt(cp_n_person_id   igs_fi_parties_v.person_id%TYPE,
                              cp_n_std_plan_id igs_fi_pp_std_attrs.student_plan_id%TYPE,
                              cp_d_start_dt    igs_fi_pp_std_attrs.plan_start_date%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    student_plan_id <> cp_n_std_plan_id
      AND    TRUNC(plan_end_date) >= TRUNC(cp_d_start_dt);

    --Cursor to validate if the Payment Plan has some installments for which the
    --due date is earlier than the System Date.
    CURSOR cur_pln_inst(cp_n_std_plan_id igs_fi_pp_std_attrs.student_plan_id%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_pp_instlmnts
      WHERE  student_plan_id = cp_n_std_plan_id
      AND    TRUNC(due_date) < g_d_sysdate
      AND    rownum < 2;

    --Cursor to validate if the Installment Due Date of the first installment is earlier than
    --the Start Date of the Payment Plan.
    CURSOR cur_pln_due_dt(cp_n_std_plan_id igs_fi_pp_std_attrs.student_plan_id%TYPE) IS
      SELECT due_date
      FROM   igs_fi_pp_instlmnts
      WHERE  student_plan_id = cp_n_std_plan_id
      ORDER BY due_date;

    --Cursor to validate if the Fee Type and Fee Calendar Instance combination is an active combination.
    CURSOR cur_validate_ftci(cp_v_fee_type          igs_fi_fee_type.fee_type%TYPE,
                             cp_v_fee_cal_type      igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                             cp_n_fee_ci_seq_number igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_f_typ_ca_inst ftci,
             igs_fi_fee_str_stat fst
      WHERE  ftci.fee_type = cp_v_fee_type
      AND    ftci.fee_cal_type = cp_v_fee_cal_type
      AND    ftci.fee_ci_sequence_number = cp_n_fee_ci_seq_number
      AND    ftci.fee_type_ci_status = fst.fee_structure_status
      AND    fst.s_fee_structure_status = g_v_active;

    l_v_manage_acc              igs_fi_control.manage_accounts%TYPE := NULL;
    l_v_message_name            fnd_new_messages.message_name%TYPE := NULL;
    l_v_fee_cal_type            igs_fi_inv_int.fee_cal_type%TYPE := NULL;
    l_n_fee_ci_sequence_number  igs_fi_inv_int.fee_ci_sequence_number%TYPE := NULL;
    l_d_due_dt                  igs_fi_pp_instlmnts.due_date%TYPE;

    l_b_valid_param             BOOLEAN := TRUE;

    l_v_var                     VARCHAR2(1);
    l_v_sql                     VARCHAR2(32767);
    l_v_status                  VARCHAR2(1);

    l_v_person_number           igs_fi_parties_v.person_number%TYPE;
    l_n_person_id               igs_fi_parties_v.person_id%TYPE;
    l_n_count                   PLS_INTEGER;

  BEGIN
    BEGIN
       l_org_id := NULL;
       igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         retcode:=2;
         RETURN;
    END;
    SAVEPOINT sp_activate_pp;
    retcode := 0;
    errbuf  := NULL;

    --Log the input parameters.
    fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
    fnd_file.put_line(fnd_file.log,fnd_message.get||':');
    fnd_file.new_line(fnd_file.log);

    fnd_file.put_line(fnd_file.log,g_v_person_group||':'||igs_fi_gen_005.finp_get_prsid_grp_code(p_n_person_id_grp));
    fnd_file.put_line(fnd_file.log,g_v_fee_period||':'||p_v_fee_period);
    fnd_file.put_line(fnd_file.log,g_v_offset_days||':'||p_n_offset_days);

    fnd_file.put_line(fnd_file.log,g_v_line);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                                );
    IF (l_v_manage_acc = 'OTHER' OR l_v_manage_acc IS NULL) THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;

    --Person Group is a mandatory parameter for this process.
    --If the parameter p_n_person_id_grp is null, log the error message.
    IF p_n_person_id_grp IS NULL THEN
      fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    ELSE
      --Validate if the input parameter person id group is valid.
      OPEN cur_pers_grp(p_n_person_id_grp);
      FETCH cur_pers_grp INTO l_v_var;
      --If not valid, log the error message in the log file.
      IF cur_pers_grp%NOTFOUND THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',g_v_person_group);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_valid_param := FALSE;
      END IF;
      CLOSE cur_pers_grp;
    END IF;

    --The Fee Period process parameter is a string of concatenated values.
    --Derive the values of fee calendar type and fee calendar instance from the fee period string.
    IF p_v_fee_period IS NOT NULL THEN
      l_v_fee_cal_type := RTRIM(SUBSTR(p_v_fee_period,102,10));
      l_n_fee_ci_sequence_number := TO_NUMBER(LTRIM(SUBSTR(p_v_fee_period,113,8)));

      --Validate the Fee Period parameter.
      IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type           => l_v_fee_cal_type,
                                                   p_n_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                   p_v_s_cal_cat          => 'FEE'
                                                  ) THEN
        --If Fee Period is not valid, then log the error message in the log file.
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',g_v_fee_period);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_valid_param := FALSE;
      END IF;
    END IF;

    --Validate offset days parameter, whether it contains negative value.
    IF p_n_offset_days IS NOT NULL AND p_n_offset_days < 0 THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',g_v_offset_days);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;

    --If any of the above parameter validations fail, process should complete with error.
    IF NOT l_b_valid_param THEN
      retcode := 2;
      RETURN;
    END IF;

    --For the Person Group passed as input to the process, identify all the Persons that are members of this group
    --using generic function.
    l_v_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_groupid => p_n_person_id_grp,
                                                               p_status  => l_v_status
                                                               );
    --If the sql returned is invalid, then..
    IF l_v_status <> 'S' THEN
      --Log the error message and stop the processing.
      fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,l_v_sql);
      retcode := 2;
      RETURN;
    END IF;

    l_n_count := 1;
    --Execute the sql statement using ref cursor.
    OPEN l_cur_ref FOR l_v_sql;
    LOOP
      --Fetch the person id in a local variable.
      FETCH l_cur_ref INTO l_n_person_id;
      EXIT WHEN l_cur_ref%NOTFOUND;

      l_n_count := l_n_count + 1;

      BEGIN

        --Log the person details.
        l_v_person_number := igs_fi_gen_008.get_party_number(l_n_person_id);
        fnd_file.put_line(fnd_file.log,g_v_person||':'||l_v_person_number);

        --Check if the Student has a Payment Plan with ACTIVE status.
        OPEN cur_pmt_active(l_n_person_id);
        FETCH cur_pmt_active INTO l_v_var;
        --If yes, then..
        IF cur_pmt_active%FOUND THEN
          CLOSE cur_pmt_active;
          --no processing needs to be done for the Student.Next Student needs to be picked up for processing.
          fnd_message.set_name('IGS','IGS_FI_PP_ACT_PAY_PLAN');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;
        CLOSE cur_pmt_active;

        --Check if the Student has a Payment Plan with the status PLANNED...
        OPEN cur_pmt_planned(l_n_person_id);
        FETCH cur_pmt_planned INTO rec_cur_pmt_planned;
        --If the Student does not have a Payment Plan with status PLANNED...
        IF cur_pmt_planned%NOTFOUND THEN
          CLOSE cur_pmt_planned;
          --Log the message in log file and proceed to next Student in the Person Group passed as input.
          fnd_message.set_name('IGS','IGS_FI_PP_PLANNED_PAY_PLANS');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;
        CLOSE cur_pmt_planned;

        --Validate if the Start Date of the Payment Plan is overlapping with the End Date of the previous plan.
        OPEN cur_validate_st_dt(l_n_person_id,
                                rec_cur_pmt_planned.student_plan_id,
                                rec_cur_pmt_planned.plan_start_date
                                );
        FETCH cur_validate_st_dt INTO l_v_var;
        --if yes, log the error message,skip the current Student and process next Student in the Person Group.
        IF cur_validate_st_dt%FOUND THEN
          CLOSE cur_validate_st_dt;
          fnd_message.set_name('IGS','IGS_FI_PP_ACTIVE_START_DATE');
          fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;
        CLOSE cur_validate_st_dt;

        --Validate if the Start Date of the Payment Plan is greater than the current System Date.
        --if yes, log the error message,skip the current Student and process next Student in the Person Group.
        IF TRUNC(rec_cur_pmt_planned.plan_start_date) > g_d_sysdate THEN
          fnd_message.set_name('IGS','IGS_FI_PP_NOT_ACTIVE');
          fnd_message.set_token('START_DATE',rec_cur_pmt_planned.plan_start_date);
          fnd_message.set_token('PAY_PLAN',rec_cur_pmt_planned.payment_plan_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;

        --Validate fi the Payment Plan has some installments for which the due date is earlier than the System Date.
        OPEN cur_pln_inst(rec_cur_pmt_planned.student_plan_id);
        FETCH cur_pln_inst INTO l_v_var;
        --if yes, log the error message,skip the current Student and process next Student in the Person Group.
        IF cur_pln_inst%FOUND THEN
          CLOSE cur_pln_inst;
          fnd_message.set_name('IGS','IGS_FI_PP_INST_DUE_SYSDATE');
          fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;
        CLOSE cur_pln_inst;

        --Fetch the due date of the first installment of the Payment Plan.
        OPEN cur_pln_due_dt(rec_cur_pmt_planned.student_plan_id);
        FETCH cur_pln_due_dt INTO l_d_due_dt;
        CLOSE cur_pln_due_dt;

        --Validate if the Installment Due Date of the first installment is earlier than
        --the Start Date of the Payment Plan.
        --if yes, log the error message,skip the current Student and process next Student in the Person Group.
        IF TRUNC(l_d_due_dt) < TRUNC(rec_cur_pmt_planned.plan_start_date) THEN
          fnd_message.set_name('IGS','IGS_FI_PP_INST_DUE_DATE');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;

        --Validate if the offset days, provided as input to this procees,is greater than the days between the
        --first installment due date and the System Date.
        --if offset days is greater, then log the error message,skip the current Student and
        --process next Student in the Person Group.
        IF (TRUNC(l_d_due_dt) - g_d_sysdate) < NVL(p_n_offset_days,0) THEN
          fnd_message.set_name('IGS','IGS_FI_PP_PAY_PLAN_OFFSET');
          fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
          fnd_message.set_token('PERSON_NUMBER',l_v_person_number);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE e_skip_record;
        END IF;

        --If processing fee amt and processing fee type are NOT PROVIDED for the Payment Plan record, then..
        IF rec_cur_pmt_planned.processing_fee_type IS NULL AND rec_cur_pmt_planned.processing_fee_amt IS NULL THEN
          --FTCI details are to be passed as NULL, while updating the Payment Plan Record.
          rec_cur_pmt_planned.fee_cal_type := NULL;
          rec_cur_pmt_planned.fee_ci_sequence_number := NULL;
          --..if Fee Period parameter is not null then log should indicate that fee period is skipped for student.
          IF p_v_fee_period IS NOT NULL THEN
            fnd_message.set_name('IGS','IGS_FI_PP_NO_PRC_FEE_SETUP');
            fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF;

        ELSE --If processing fee amt and processing fee type are PROVIDED for the Payment Plan record,

          --If the FTCI details are not provided for the Payment Plan record.
          IF rec_cur_pmt_planned.fee_cal_type IS NULL AND rec_cur_pmt_planned.fee_ci_sequence_number IS NULL THEN
            --Check if the Fee Period input parameter to this process has some value.
            --If Fee Period parameter is also null,then log the error message,skip the current Student and
            --process next Student in the Person Group.
            IF p_v_fee_period IS NULL THEN
              fnd_message.set_name('IGS','IGS_FI_PP_NO_FEE_PERIOD');
              fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              RAISE e_skip_record;
            ELSE--Fee Period parameter is not null, then...
              --Validate the FTCI combination.
              OPEN cur_validate_ftci(rec_cur_pmt_planned.processing_fee_type,
                                     l_v_fee_cal_type,
                                     l_n_fee_ci_sequence_number
                                     );
              FETCH cur_validate_ftci INTO l_v_var;
              --If FTCI combination is not valid, then log the error message,skip the current Student and
              --process next Student in the Person Group.
              IF cur_validate_ftci%NOTFOUND THEN
                CLOSE cur_validate_ftci;
                fnd_message.set_name('IGS','IGS_FI_PP_NO_FEE_PERIOD_MATCH');
                fnd_message.set_token('PLAN_NAME',rec_cur_pmt_planned.payment_plan_name);
                fnd_message.set_token('FEE_TYPE_NAME',rec_cur_pmt_planned.processing_fee_type);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                RAISE e_skip_record;
              ELSE
                rec_cur_pmt_planned.fee_cal_type := l_v_fee_cal_type;
                rec_cur_pmt_planned.fee_ci_sequence_number := l_n_fee_ci_sequence_number;
              END IF;
              CLOSE cur_validate_ftci;
            END IF;
          END IF;
        END IF;

        --If all the validations are thru and if the Student need not be skipped from processing,
        --Update the Payment Plan record to set the Planned Status Code to 'ACTIVE' with appropriate
        --FTCI details as derived above.
        BEGIN
          igs_fi_pp_std_attrs_pkg.update_row(
            x_rowid                    => rec_cur_pmt_planned.rowid,
            x_student_plan_id          => rec_cur_pmt_planned.student_plan_id,
            x_person_id                => rec_cur_pmt_planned.person_id,
            x_payment_plan_name        => rec_cur_pmt_planned.payment_plan_name,
            x_plan_start_date          => rec_cur_pmt_planned.plan_start_date,
            x_plan_end_date            => rec_cur_pmt_planned.plan_end_date,
            x_plan_status_code         => g_v_active,
            x_processing_fee_amt       => rec_cur_pmt_planned.processing_fee_amt,
            x_processing_fee_type      => rec_cur_pmt_planned.processing_fee_type,
            x_fee_cal_type             => rec_cur_pmt_planned.fee_cal_type,
            x_fee_ci_sequence_number   => rec_cur_pmt_planned.fee_ci_sequence_number,
            x_notes                    => rec_cur_pmt_planned.notes,
            x_invoice_id               => rec_cur_pmt_planned.invoice_id,
            x_attribute_category       => rec_cur_pmt_planned.attribute_category,
            x_attribute1               => rec_cur_pmt_planned.attribute1,
            x_attribute2               => rec_cur_pmt_planned.attribute2,
            x_attribute3               => rec_cur_pmt_planned.attribute3,
            x_attribute4               => rec_cur_pmt_planned.attribute4,
            x_attribute5               => rec_cur_pmt_planned.attribute5,
            x_attribute6               => rec_cur_pmt_planned.attribute6,
            x_attribute7               => rec_cur_pmt_planned.attribute7,
            x_attribute8               => rec_cur_pmt_planned.attribute8,
            x_attribute9               => rec_cur_pmt_planned.attribute9,
            x_attribute10              => rec_cur_pmt_planned.attribute10,
            x_attribute11              => rec_cur_pmt_planned.attribute11,
            x_attribute12              => rec_cur_pmt_planned.attribute12,
            x_attribute13              => rec_cur_pmt_planned.attribute13,
            x_attribute14              => rec_cur_pmt_planned.attribute14,
            x_attribute15              => rec_cur_pmt_planned.attribute15,
            x_attribute16              => rec_cur_pmt_planned.attribute16,
            x_attribute17              => rec_cur_pmt_planned.attribute17,
            x_attribute18              => rec_cur_pmt_planned.attribute18,
            x_attribute19              => rec_cur_pmt_planned.attribute19,
            x_attribute20              => rec_cur_pmt_planned.attribute20,
            x_mode                     => 'R'
           );

        --If no error is raised, log the status as Success.
        fnd_file.put_line(fnd_file.log,g_v_pp_status||':'||g_v_success);

        EXCEPTION
        WHEN OTHERS THEN
          --In case TBH throws any errors, log the error status.
          fnd_file.put_line(fnd_file.log,g_v_pp_status||':'||g_v_error);
          fnd_file.put_line(fnd_file.log,SQLERRM);
          retcode := 1;
        END;
      EXCEPTION
      WHEN e_skip_record THEN
        --log the Status as Warning(as the error message is already being logged as and when validation failed.)
        --and retcode need to be set to 1 to complete the process also in Warning status.
        fnd_file.put_line(fnd_file.log,g_v_pp_status||':'||g_v_error);
        retcode := 1;
      END;
      fnd_file.new_line(fnd_file.log);
    END LOOP;
    CLOSE l_cur_ref;

    --If person group passed as input does not have any members associated,
    --then process should log the message ***No Data Found***.
    IF l_n_count = 1 THEN
      fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);
    END IF;
    fnd_file.put_line(fnd_file.log,g_v_line);

  EXCEPTION
    --Handle the Locking exception.
    WHEN e_resource_busy THEN
      ROLLBACK TO sp_activate_pp;
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);
    WHEN OTHERS THEN
      ROLLBACK TO sp_activate_pp;
      retcode := 2;
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||' - '||SQLERRM);
  END activate_plan;

  PROCEDURE assign_students(errbuf                  OUT NOCOPY VARCHAR2,
                            retcode                 OUT NOCOPY NUMBER,
                            p_v_payment_plan_name   IN  igs_fi_pp_templates.payment_plan_name%TYPE,
                            p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE,
                            p_v_start_date          IN  VARCHAR2,
                            p_v_fee_period          IN  VARCHAR2
                            ) AS
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 27-Aug-2003
  --
  --Purpose:  Concurrent program that assigns a Payment Plan to a Student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sapanigr  12-Jun-2006    Bug 5068241. Value assigned to status variable l_v_pers_status while logging
  --                         message IGS_FI_PP_NO_NEW_ASSIGN has been changed from WARNING to ERROR.
  --abshriva  12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  --vvutukur  03-Feb-2004    Bug#3399850.Validation of start date parameter is made erroroneous situation
  --                         in stead of warning. Record creation is prevented if validation fails.
  -------------------------------------------------------------------

    --Ref cursor variable.
    l_cur_ref cur_ref;

    --Cursor for fetching the payment plan details.
    CURSOR cur_pmt_plan(cp_v_pmt_plan igs_fi_pp_templates.payment_plan_name%TYPE) IS
      SELECT *
      FROM   igs_fi_pp_templates
      WHERE  payment_plan_name = cp_v_pmt_plan
      AND    NVL(closed_flag,g_v_ind_no) = g_v_ind_no;

    rec_cur_pmt_plan   cur_pmt_plan%ROWTYPE;

    --Cursor for fetching all the installment lines for the payment plan passed as input.
    CURSOR cur_pp_lines(cp_v_pmt_plan igs_fi_pp_templates.payment_plan_name%TYPE) IS
      SELECT *
      FROM   igs_fi_pp_tmpl_lns
      WHERE  payment_plan_name = cp_v_pmt_plan;

    --Cursor used to validate if the Person has a Payment Plan with status as Planned.
    CURSOR cur_pp_planned(cp_n_person_id igs_fi_parties_v.person_id%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    plan_status_code = g_v_planned;

    --Cursor used to validate if the Start Date passed as input to the process is eariler than
    --the End Date of any plan for the person.
    CURSOR cur_validate_start_dt(cp_n_person_id igs_fi_parties_v.person_id%TYPE,
                                 cp_d_start_date DATE) IS
      SELECT 'x'
      FROM   igs_fi_pp_std_attrs
      WHERE  person_id = cp_n_person_id
      AND    TRUNC(cp_d_start_date) <= TRUNC(plan_end_date);

    --Declare a local PL/SQL Table to hold certain values for the creation of student payment plan record.
    TYPE temp_rec_type IS RECORD (
    plan_line_num     igs_fi_pp_tmpl_lns.plan_line_num%TYPE,
    plan_amount       igs_fi_pp_tmpl_lns.plan_amt%TYPE,
    due_date          igs_fi_pp_instlmnts.due_date%TYPE);

    TYPE temp_tbl_type IS TABLE OF temp_rec_type INDEX BY BINARY_INTEGER;
    l_temp_plsql_tbl temp_tbl_type;

    l_v_manage_acc              igs_fi_control.manage_accounts%TYPE := NULL;
    l_v_message_name            fnd_new_messages.message_name%TYPE := NULL;
    l_v_fee_cal_type            igs_fi_inv_int.fee_cal_type%TYPE := NULL;
    l_n_fee_ci_sequence_number  igs_fi_inv_int.fee_ci_sequence_number%TYPE := NULL;
    l_b_valid_param             BOOLEAN := TRUE;
    l_b_planned_plan            BOOLEAN := FALSE;
    l_b_no_rec                  BOOLEAN := FALSE;

    l_d_due_dt_fst_inst         DATE;
    l_d_prev_due_dt             DATE;
    l_d_start_date              DATE;
    l_v_var                     VARCHAR2(1);
    l_rowid                     ROWID;
    l_n_installment_id          igs_fi_pp_instlmnts.installment_id%TYPE;
    l_n_student_plan_id         igs_fi_pp_instlmnts.student_plan_id%TYPE;
    l_v_person_number           igs_fi_parties_v.person_number%TYPE;
    l_n_person_id               igs_fi_parties_v.person_id%TYPE;
    l_v_sql                     VARCHAR2(32767);
    l_v_status                  VARCHAR2(1);
    l_v_pers_status             igs_lookup_values.meaning%TYPE;
    l_v_pers_message            fnd_new_messages.message_text%TYPE;

    l_n_count                   PLS_INTEGER;
    l_n_cnt                     PLS_INTEGER;
    l_n_months                  PLS_INTEGER;

    l_v_pmt_plan_template       CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PAYPLAN_TEMPLATE');
    l_v_start_date              CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','START_DT');

    TYPE dff_seg_values IS RECORD (
    attribute1        igs_fi_pp_std_attrs.attribute1%TYPE,
    attribute2        igs_fi_pp_std_attrs.attribute2%TYPE,
    attribute3        igs_fi_pp_std_attrs.attribute3%TYPE,
    attribute4        igs_fi_pp_std_attrs.attribute4%TYPE,
    attribute5        igs_fi_pp_std_attrs.attribute5%TYPE,
    attribute6        igs_fi_pp_std_attrs.attribute6%TYPE,
    attribute7        igs_fi_pp_std_attrs.attribute7%TYPE,
    attribute8        igs_fi_pp_std_attrs.attribute8%TYPE,
    attribute9        igs_fi_pp_std_attrs.attribute9%TYPE,
    attribute10       igs_fi_pp_std_attrs.attribute10%TYPE,
    attribute11       igs_fi_pp_std_attrs.attribute11%TYPE,
    attribute12       igs_fi_pp_std_attrs.attribute12%TYPE,
    attribute13       igs_fi_pp_std_attrs.attribute13%TYPE,
    attribute14       igs_fi_pp_std_attrs.attribute14%TYPE,
    attribute15       igs_fi_pp_std_attrs.attribute15%TYPE,
    attribute16       igs_fi_pp_std_attrs.attribute16%TYPE,
    attribute17       igs_fi_pp_std_attrs.attribute17%TYPE,
    attribute18       igs_fi_pp_std_attrs.attribute18%TYPE,
    attribute19       igs_fi_pp_std_attrs.attribute19%TYPE,
    attribute20       igs_fi_pp_std_attrs.attribute20%TYPE);

    l_dff_seg_values dff_seg_values;

  BEGIN

    SAVEPOINT sp_assign_student;
    retcode := 0;
    errbuf  := NULL;

    --Parameter p_v_start_date is of type VARCHAR2, converting and truncating the same.
    IF p_v_start_date IS NOT NULL THEN
      l_d_start_date  := TRUNC(igs_ge_date.igsdate(p_v_start_date));
    END IF;

    --Log the input parameters.
    fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
    fnd_file.put_line(fnd_file.log,fnd_message.get||':');
    fnd_file.new_line(fnd_file.log);

    fnd_file.put_line(fnd_file.log,l_v_pmt_plan_template||':'||p_v_payment_plan_name);
    fnd_file.put_line(fnd_file.log,g_v_person_group||':'||igs_fi_gen_005.finp_get_prsid_grp_code(p_n_person_id_grp));
    fnd_file.put_line(fnd_file.log,l_v_start_date||':'||l_d_start_date);
    fnd_file.put_line(fnd_file.log,g_v_fee_period||':'||p_v_fee_period);

    fnd_file.put_line(fnd_file.log,g_v_line);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                                );
    IF (l_v_manage_acc = 'OTHER' OR l_v_manage_acc IS NULL) THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;

    --Check if the required parameters are passed, if not log the error message.
    IF p_v_payment_plan_name IS NULL OR p_n_person_id_grp IS NULL OR p_v_start_date IS NULL THEN
      fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;

    --Validate Payment Plan parameter.
    OPEN cur_pmt_plan(p_v_payment_plan_name);
    FETCH cur_pmt_plan INTO rec_cur_pmt_plan;
    IF cur_pmt_plan%NOTFOUND THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',l_v_pmt_plan_template);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;
    CLOSE cur_pmt_plan;

    OPEN cur_pers_grp(p_n_person_id_grp);
    FETCH cur_pers_grp INTO l_v_var;
    IF cur_pers_grp%NOTFOUND THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',g_v_person_group);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;
    CLOSE cur_pers_grp;

    --The Fee Period process parameter is a string of concatenated values.
    --Derive the values of fee calendar type and fee calendar instance from the fee period string.
    IF p_v_fee_period IS NOT NULL THEN
      l_v_fee_cal_type := RTRIM(SUBSTR(p_v_fee_period,102,10));
      l_n_fee_ci_sequence_number := TO_NUMBER(LTRIM(SUBSTR(p_v_fee_period,113,8)));

      --Validate the Fee Period parameters.
      IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type           => l_v_fee_cal_type,
                                                   p_n_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                   p_v_s_cal_cat          => 'FEE'
                                                  ) THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',g_v_fee_period);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_valid_param := FALSE;
      END IF;
    END IF;

    --Validate if the Descriptive Flexfield for the Student Payment Plan has been setup with some mandatory attributes.
    fnd_flex_descval.clear_column_values;
    fnd_flex_descval.set_context_value(context_value => NULL);

    --Set all the attribute column values to NULL.
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE1', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE2', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE3', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE4', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE5', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE6', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE7', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE8', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE9', column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE10',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE11',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE12',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE13',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE14',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE15',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE16',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE17',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE18',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE19',column_value => '');
    fnd_flex_descval.set_column_value(column_name => 'ATTRIBUTE20',column_value => '');

    --If DFF is defined with mandatory attributes, then the error message needs to be logged.
    IF NOT fnd_flex_descval.validate_desccols(appl_short_name  => 'IGS',
                                              desc_flex_name   => 'IGS_FI_PP_STD_ATTRS_FLEX',
                                              values_or_ids    => 'V',
                                              validation_date  => SYSDATE) THEN
      fnd_file.put_line(fnd_file.log,fnd_flex_descval.error_message);
      l_b_valid_param := FALSE;
    END IF;

    --For the Person Group passed as input to the process, identify all the Persons that are members of this group
    --using generic function.
    l_v_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_groupid => p_n_person_id_grp,
                                                               p_status  => l_v_status
                                                               );
    --If the sql returned is invalid, then..
    IF l_v_status <> 'S' THEN
      --Log the error message and stop processing.
      fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,l_v_sql);
      l_b_valid_param := FALSE;
    END IF;

    IF NOT l_b_valid_param THEN
      retcode := 2;
      RETURN;
    END IF;

    --Get the due date of the first installment.
    l_d_due_dt_fst_inst := igs_fi_gen_008.get_start_date(p_d_start_date  => l_d_start_date,
                                                         p_n_due_day     => rec_cur_pmt_plan.due_day_of_month,
                                                         p_v_last_day    => rec_cur_pmt_plan.due_end_of_month_flag,
                                                         p_n_offset_days => rec_cur_pmt_plan.due_cutoff_day
                                                         );

    l_n_months := 0;

    --Calculate the number of months to be used for calculating the due date of each
    --installment of a Payment Plan.
    IF rec_cur_pmt_plan.installment_period_code = g_v_monthly THEN
      l_n_months := 1;
    ELSIF rec_cur_pmt_plan.installment_period_code = g_v_bi_monthly THEN
      l_n_months := 2;
    ELSIF rec_cur_pmt_plan.installment_period_code = g_v_quarterly THEN
      l_n_months := 3;
    END IF;

    l_d_prev_due_dt := NULL;

    l_n_count :=1;
    --Loop through all the Payment Plan Line records pertaining to the payment plan name passed as input.
    FOR rec_cur_pp_lines IN cur_pp_lines(rec_cur_pmt_plan.payment_plan_name) LOOP

      l_temp_plsql_tbl(l_n_count).plan_line_num := rec_cur_pp_lines.plan_line_num;

      --For the first record, the due date will be the value identified earlier.ie., l_d_due_dt_fst_inst.
      IF l_d_prev_due_dt IS NULL THEN
        l_d_prev_due_dt := l_d_due_dt_fst_inst;
      ELSE
        --if the record is not the first record, Due Date needs to be calculated as:
        --Due Date of the prior record + No. of months as per the INSTALLMENT_PERIOD_CODE.
        --If the Installment Period Code is Monthly,    prior due date + 1 month.
        --If the Installment Period Code is Bi-Monthly, prior due date + 2 months.
        --If the Installment Period Code is Quarterly,  prior due date + 3 months.
        l_d_prev_due_dt := ADD_MONTHS(l_d_prev_due_dt,l_n_months);
      END IF;

      --Store the value of due_date calculated as above in a local variable sothat the variable contains
      --the due date of last installment of the Payment Plan at the end of the loop.
      l_temp_plsql_tbl(l_n_count).due_date := l_d_prev_due_dt;

      --If the installment period flag is 'P',plan percent is considered for the calculation of plan amount.
      IF rec_cur_pmt_plan.installment_method_flag = 'P' THEN
        l_temp_plsql_tbl(l_n_count).plan_amount := (NVL(rec_cur_pp_lines.plan_percent,0) * NVL(rec_cur_pmt_plan.base_amt,0))/100;

      --If the installment period flag is 'A',plan_amt is equal to plan amount.
      ELSIF rec_cur_pmt_plan.installment_method_flag = 'A' THEN

        l_temp_plsql_tbl(l_n_count).plan_amount := NVL(rec_cur_pp_lines.plan_amt,0);
      END IF;

      l_n_count := l_n_count + 1;

    END LOOP;

    --Before processing each person in the Person Group,
    --capture the values of Descriptive Flexfield Segment Values into record type local variable
    --as these values are not variable for each person.
    l_dff_seg_values.attribute1  := fnd_flex_descval.segment_value(1);
    l_dff_seg_values.attribute2  := fnd_flex_descval.segment_value(2);
    l_dff_seg_values.attribute3  := fnd_flex_descval.segment_value(3);
    l_dff_seg_values.attribute4  := fnd_flex_descval.segment_value(4);
    l_dff_seg_values.attribute5  := fnd_flex_descval.segment_value(5);
    l_dff_seg_values.attribute6  := fnd_flex_descval.segment_value(6);
    l_dff_seg_values.attribute7  := fnd_flex_descval.segment_value(7);
    l_dff_seg_values.attribute8  := fnd_flex_descval.segment_value(8);
    l_dff_seg_values.attribute9  := fnd_flex_descval.segment_value(9);
    l_dff_seg_values.attribute10 := fnd_flex_descval.segment_value(10);
    l_dff_seg_values.attribute11 := fnd_flex_descval.segment_value(11);
    l_dff_seg_values.attribute12 := fnd_flex_descval.segment_value(12);
    l_dff_seg_values.attribute13 := fnd_flex_descval.segment_value(13);
    l_dff_seg_values.attribute14 := fnd_flex_descval.segment_value(14);
    l_dff_seg_values.attribute15 := fnd_flex_descval.segment_value(15);
    l_dff_seg_values.attribute16 := fnd_flex_descval.segment_value(16);
    l_dff_seg_values.attribute17 := fnd_flex_descval.segment_value(17);
    l_dff_seg_values.attribute18 := fnd_flex_descval.segment_value(18);
    l_dff_seg_values.attribute19 := fnd_flex_descval.segment_value(19);
    l_dff_seg_values.attribute20 := fnd_flex_descval.segment_value(20);

    --For Payment Plan passed as input, if processing fee type is not defined, then FTCI information
    --has to be passed as NULL while creating Student Payment Plan Record.
    IF rec_cur_pmt_plan.processing_fee_type IS NULL THEN
      l_v_fee_cal_type := NULL;
      l_n_fee_ci_sequence_number := NULL;
    END IF;

    --Execute the sql statement using ref cursor.
    OPEN l_cur_ref FOR l_v_sql;
    LOOP

      l_b_planned_plan := FALSE;
      l_v_pers_status  := NULL;
      l_v_pers_message := NULL;

      --Fetch the person id in a local variable.
      FETCH l_cur_ref INTO l_n_person_id;
      EXIT WHEN l_cur_ref%NOTFOUND;

      IF NOT l_b_no_rec THEN
        l_b_no_rec := TRUE;
      END IF;

      --Log the person details.
      l_v_person_number := igs_fi_gen_008.get_party_number(l_n_person_id);
      fnd_file.put_line(fnd_file.log,g_v_person||':'||l_v_person_number);

      --Validate if the person has a Payment Plan with status as Planned, if so, no further proceesing
      --required for the person and the process should proceed to the next person member of the group skipping
      --the person being processed.
      OPEN cur_pp_planned(l_n_person_id);
      FETCH cur_pp_planned INTO l_v_var;
      IF cur_pp_planned%FOUND THEN
        --Log the error message.
        fnd_message.set_name('IGS','IGS_FI_PP_NO_NEW_ASSIGN');
        l_v_pers_message := fnd_message.get;
        l_b_planned_plan := TRUE;
        --and retcode need to be set to 1 to complete the process also in Warning status.
        l_v_pers_status := g_v_error;
        retcode := 1;
      END IF;
      CLOSE cur_pp_planned;

      --Validate if the Start Date passed as input to the process is earlier than the End Date of
      --any plan for the person.
      OPEN cur_validate_start_dt(l_n_person_id,l_d_start_date);
      FETCH cur_validate_start_dt INTO l_v_var;
      IF cur_validate_start_dt%FOUND THEN
        --Log the error message.
        fnd_message.set_name('IGS','IGS_FI_PP_END_DATE_EARLY');
        fnd_message.set_token('PERSON_NUMBER',l_v_person_number);
        l_v_pers_message := l_v_pers_message || fnd_message.get;
	l_b_planned_plan := TRUE;
        l_v_pers_status := g_v_error;
        retcode := 1;
      END IF;
      CLOSE cur_validate_start_dt;

      IF NOT l_b_planned_plan THEN
        BEGIN
          --Nullify the IN/OUT variables l_rowid and l_n_installment_id before inserting a row in
          --Student Payment Plans Table.
          l_rowid := NULL;
          l_n_student_plan_id := NULL;
          rec_cur_pmt_plan.processing_fee_amt:=igs_fi_gen_gl.get_formatted_amount(rec_cur_pmt_plan.processing_fee_amt);
          --For the Person being processed, create a record in the IGS_FI_PP_STD_ATTRS table.
          igs_fi_pp_std_attrs_pkg.insert_row(x_rowid                 => l_rowid,
                                           x_student_plan_id         => l_n_student_plan_id,
                                           x_person_id               => l_n_person_id,
                                           x_payment_plan_name       => p_v_payment_plan_name,
                                           x_plan_start_date         => TRUNC(l_d_start_date),
                                           x_plan_end_date           => l_d_prev_due_dt,
                                           x_plan_status_code        => g_v_planned,
                                           x_processing_fee_amt      => rec_cur_pmt_plan.processing_fee_amt,
                                           x_processing_fee_type     => rec_cur_pmt_plan.processing_fee_type,
                                           x_fee_cal_type            => l_v_fee_cal_type,
                                           x_fee_ci_sequence_number  => l_n_fee_ci_sequence_number,
                                           x_notes                   => NULL,
                                           x_invoice_id              => NULL,
                                           x_attribute_category      => NULL,
                                           x_attribute1              => l_dff_seg_values.attribute1,
                                           x_attribute2              => l_dff_seg_values.attribute2,
                                           x_attribute3              => l_dff_seg_values.attribute3,
                                           x_attribute4              => l_dff_seg_values.attribute4,
                                           x_attribute5              => l_dff_seg_values.attribute5,
                                           x_attribute6              => l_dff_seg_values.attribute6,
                                           x_attribute7              => l_dff_seg_values.attribute7,
                                           x_attribute8              => l_dff_seg_values.attribute8,
                                           x_attribute9              => l_dff_seg_values.attribute9,
                                           x_attribute10             => l_dff_seg_values.attribute10,
                                           x_attribute11             => l_dff_seg_values.attribute11,
                                           x_attribute12             => l_dff_seg_values.attribute12,
                                           x_attribute13             => l_dff_seg_values.attribute13,
                                           x_attribute14             => l_dff_seg_values.attribute14,
                                           x_attribute15             => l_dff_seg_values.attribute15,
                                           x_attribute16             => l_dff_seg_values.attribute16,
                                           x_attribute17             => l_dff_seg_values.attribute17,
                                           x_attribute18             => l_dff_seg_values.attribute18,
                                           x_attribute19             => l_dff_seg_values.attribute19,
                                           x_attribute20             => l_dff_seg_values.attribute20,
                                           x_mode                    => 'R'
                                           );

          -- Check if there are any records in the temporary PL/SQL table.
          IF l_temp_plsql_tbl.COUNT > 0 THEN

            l_n_cnt := 0;

            --Loop through the temporary PL/SQL Table for creation of Student Payment Plan Line Records.
            FOR l_n_cnt IN l_temp_plsql_tbl.FIRST..l_temp_plsql_tbl.LAST LOOP

              IF l_temp_plsql_tbl.EXISTS(l_n_cnt) THEN

                --Nullify the IN/OUT variables l_rowid and l_n_installment_id before inserting
                --a record in igs_fi_pp_instlmnts table.
                l_rowid := NULL;
                l_n_installment_id := NULL;

                l_temp_plsql_tbl(l_n_cnt).plan_amount :=igs_fi_gen_gl.get_formatted_amount(l_temp_plsql_tbl(l_n_cnt).plan_amount);
                igs_fi_pp_instlmnts_pkg.insert_row(
                                           x_rowid                 => l_rowid,
                                           x_installment_id        => l_n_installment_id,
                                           x_student_plan_id       => l_n_student_plan_id,
                                           x_installment_line_num  => l_temp_plsql_tbl(l_n_cnt).plan_line_num,
                                           x_due_day               => TO_NUMBER(TO_CHAR(l_temp_plsql_tbl(l_n_cnt).due_date,'DD')),
                                           x_due_month_code        => TO_CHAR(l_temp_plsql_tbl(l_n_cnt).due_date,'MON'),
                                           x_due_year              => TO_NUMBER(TO_CHAR(l_temp_plsql_tbl(l_n_cnt).due_date,'YYYY')),
                                           x_due_date              => TRUNC(l_temp_plsql_tbl(l_n_cnt).due_date),
                                           x_installment_amt       => NVL(l_temp_plsql_tbl(l_n_cnt).plan_amount,0),
                                           x_due_amt               => NVL(l_temp_plsql_tbl(l_n_cnt).plan_amount,0),
                                           x_penalty_flag          => g_v_ind_no,
                                           x_mode                  => 'R'
                                           );
              END IF;
            END LOOP;
          END IF;

          --After successful creation of records, log the status as success.
          IF l_v_pers_status IS NULL THEN
            l_v_pers_status := g_v_success;
          END IF;

        EXCEPTION
        WHEN OTHERS THEN
          --In case TBH throws any errors, log the error status.
          l_v_pers_status := g_v_error;
          l_v_pers_message := l_v_pers_message ||fnd_message.get;
        END;
      END IF;
      fnd_file.put_line(fnd_file.log,g_v_pp_status||':'||l_v_pers_status);
      IF l_v_pers_message IS NOT NULL THEN
        fnd_file.put_line(fnd_file.log,LTRIM(l_v_pers_message,'.'));
      END IF;
      fnd_file.new_line(fnd_file.log);
    END LOOP;
    CLOSE l_cur_ref;

    --If person group passed as input does not have any members associated,
    --then process should log the message ***No Data Found***.
    IF NOT l_b_no_rec THEN
      fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);
    END IF;

  EXCEPTION
    --Handle the Locking exception.
    WHEN e_resource_busy THEN
      ROLLBACK TO sp_assign_student;
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);

    WHEN OTHERS THEN
      ROLLBACK TO sp_assign_student;
      retcode := 2;
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||' - '||SQLERRM);
  END assign_students;

  FUNCTION close_active_pp(p_n_person_id           IN igs_fi_parties_v.person_id%TYPE,
                           p_n_tolerance_threshold IN NUMBER) RETURN NUMBER IS
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 10-Sep-2003
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva  12-May-2006    Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  -------------------------------------------------------------------
    --Cursor to fetch the Student ACTIVE Payment Plan details.

    --The following cursor will fetch a single record(ACTIVE Payment Plan details) if the input parameter to the cursor
    --i.e., cp_n_person_id is passed as not null. In case the input parameter to the cursor is passed as null,
    --the cursor returns multiple ACTIVE Payment Plan records for different Students.
    --(note: One Student Can have only one Active Payment Plan at a time).
    CURSOR cur_pp_dtls(cp_n_person_id igs_fi_pp_std_attrs.person_id%TYPE) IS
      SELECT a.rowid,a.*
      FROM   igs_fi_pp_std_attrs a
      WHERE  (a.person_id = cp_n_person_id OR
              cp_n_person_id IS NULL)
      AND    a.plan_status_code = g_v_active
      FOR UPDATE NOWAIT;

    rec_cur_pp_dtls cur_pp_dtls%ROWTYPE;

    --Cursor to fetch the details of all the Installments of a Student Payment Plan.
    CURSOR cur_pp_insts(cp_n_std_pln_id igs_fi_pp_instlmnts.student_plan_id%TYPE) IS
      SELECT a.rowid,a.*
      FROM   igs_fi_pp_instlmnts a
      WHERE  a.student_plan_id = cp_n_std_pln_id
      FOR UPDATE NOWAIT;

    l_n_balance         igs_fi_pp_instlmnts.due_amt%TYPE;
    l_v_closed          CONSTANT igs_fi_pp_std_attrs.plan_status_code%TYPE := 'CLOSED';
    l_n_inst_bal        igs_fi_pp_instlmnts.installment_amt%TYPE;
    l_v_end_dt_msg      VARCHAR2(2000);
    l_n_count           NUMBER :=0;
    l_v_plan_name       CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PLAN_NAME');
    l_v_plan_bal        CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PLAN_BAL');
    l_v_end_dt          CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','END_DT');

  BEGIN

    --Loop through all the persons.
    FOR rec_cur_pp_dtls IN cur_pp_dtls(p_n_person_id) LOOP

      l_n_count := l_n_count + 1;

      --Log the Student Payment Plan details.
      fnd_file.put_line(fnd_file.log,g_v_person||': '||igs_fi_gen_008.get_party_number(rec_cur_pp_dtls.person_id));
      fnd_file.put_line(fnd_file.log,l_v_plan_name||': '||rec_cur_pp_dtls.payment_plan_name);

      --Calculate the Outstanding Balance of the Active Payment Plan of the Student, by calling the generic function.
      l_n_balance := igs_fi_gen_008.get_plan_balance(p_n_act_plan_id    => rec_cur_pp_dtls.student_plan_id,
                                                     p_d_effective_date => NULL
                                                     );
      --Log the Outstanding Balance.
      fnd_file.put_line(fnd_file.log,l_v_plan_bal||': '||l_n_balance);
      l_v_end_dt_msg := l_v_end_dt||': ';

      --If the Payment Plan Outstanding Balance is less than or equal to the threshold amount parameter,
      --passed as input to this process.
      IF NVL(l_n_balance,0) <= NVL(p_n_tolerance_threshold,0) THEN
        --if so, update the Payment Plan status(plan_status_code column) of igs_fi_pp_std_attrs table to a
        --status of 'CLOSED' and also Update the End Date(plan_end_date column) of the Plan with the System Date.
        BEGIN
          igs_fi_pp_std_attrs_pkg.update_row(
                            x_rowid                        => rec_cur_pp_dtls.rowid,
                            x_student_plan_id              => rec_cur_pp_dtls.student_plan_id,
                            x_person_id                    => rec_cur_pp_dtls.person_id,
                            x_payment_plan_name            => rec_cur_pp_dtls.payment_plan_name,
                            x_plan_start_date              => rec_cur_pp_dtls.plan_start_date,
                            x_plan_end_date                => g_d_sysdate,
                            x_plan_status_code             => l_v_closed,
                            x_processing_fee_amt           => rec_cur_pp_dtls.processing_fee_amt,
                            x_processing_fee_type          => rec_cur_pp_dtls.processing_fee_type,
                            x_fee_cal_type                 => rec_cur_pp_dtls.fee_cal_type,
                            x_fee_ci_sequence_number       => rec_cur_pp_dtls.fee_ci_sequence_number,
                            x_notes                        => rec_cur_pp_dtls.notes,
                            x_invoice_id                   => rec_cur_pp_dtls.invoice_id,
                            x_attribute_category           => rec_cur_pp_dtls.attribute_category,
                            x_attribute1                   => rec_cur_pp_dtls.attribute1,
                            x_attribute2                   => rec_cur_pp_dtls.attribute2,
                            x_attribute3                   => rec_cur_pp_dtls.attribute3,
                            x_attribute4                   => rec_cur_pp_dtls.attribute4,
                            x_attribute5                   => rec_cur_pp_dtls.attribute5,
                            x_attribute6                   => rec_cur_pp_dtls.attribute6,
                            x_attribute7                   => rec_cur_pp_dtls.attribute7,
                            x_attribute8                   => rec_cur_pp_dtls.attribute8,
                            x_attribute9                   => rec_cur_pp_dtls.attribute9,
                            x_attribute10                  => rec_cur_pp_dtls.attribute10,
                            x_attribute11                  => rec_cur_pp_dtls.attribute11,
                            x_attribute12                  => rec_cur_pp_dtls.attribute12,
                            x_attribute13                  => rec_cur_pp_dtls.attribute13,
                            x_attribute14                  => rec_cur_pp_dtls.attribute14,
                            x_attribute15                  => rec_cur_pp_dtls.attribute15,
                            x_attribute16                  => rec_cur_pp_dtls.attribute16,
                            x_attribute17                  => rec_cur_pp_dtls.attribute17,
                            x_attribute18                  => rec_cur_pp_dtls.attribute18,
                            x_attribute19                  => rec_cur_pp_dtls.attribute19,
                            x_attribute20                  => rec_cur_pp_dtls.attribute20,
                            x_mode                         => 'R');

          --Loop through all the Payment Plan Installment records and update the installment_amt column to
          --a value (installment_amt - due_amt) of the same Payment Plan Installment record.
          --Also update the due_amt to 0 for the each record.
          FOR rec_cur_pp_insts IN cur_pp_insts(rec_cur_pp_dtls.student_plan_id) LOOP

            --Calculate the value to be updated in the column installment_amt.
            l_n_inst_bal := NVL(rec_cur_pp_insts.installment_amt,0) - NVL(rec_cur_pp_insts.due_amt,0);

            l_n_inst_bal :=igs_fi_gen_gl.get_formatted_amount(l_n_inst_bal);
            igs_fi_pp_instlmnts_pkg.update_row(
                      x_rowid                        => rec_cur_pp_insts.rowid,
                      x_installment_id               => rec_cur_pp_insts.installment_id,
                      x_student_plan_id              => rec_cur_pp_insts.student_plan_id,
                      x_installment_line_num         => rec_cur_pp_insts.installment_line_num,
                      x_due_day                      => rec_cur_pp_insts.due_day,
                      x_due_month_code               => rec_cur_pp_insts.due_month_code,
                      x_due_year                     => rec_cur_pp_insts.due_year,
                      x_due_date                     => rec_cur_pp_insts.due_date,
                      x_installment_amt              => l_n_inst_bal,
                      x_due_amt                      => 0,
                      x_penalty_flag                 => rec_cur_pp_insts.penalty_flag,
                      x_mode                         => 'R');
          END LOOP;
          l_v_end_dt_msg := l_v_end_dt_msg||g_d_sysdate;
        EXCEPTION
          WHEN OTHERS THEN
            l_v_end_dt_msg := l_v_end_dt_msg||fnd_message.get;
        END;

      ELSE--If the outstanding balance for the student is greater than the p_n_tolerance_threshold parameter..

        --Against the End Date placeholder,log the message that Payment Plan does not meet the Criteria and
        --Remains Active and Process the next Student.

        fnd_message.set_name('IGS','IGS_FI_PP_NOT_CLOSED');
        l_v_end_dt_msg := l_v_end_dt_msg||fnd_message.get;
      END IF;

      --Log the end date details.
      fnd_file.put_line(fnd_file.log,l_v_end_dt_msg);
      fnd_file.new_line(fnd_file.log);

    END LOOP;
    RETURN l_n_count;

  END close_active_pp;

  PROCEDURE close_status(errbuf                  OUT NOCOPY VARCHAR2,
                         retcode                 OUT NOCOPY NUMBER,
                         p_n_tolerance_threshold IN  NUMBER,
                         p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE,
                         p_v_test_mode           IN  VARCHAR2
                         ) AS
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 27-Aug-2003
  --
  --Purpose:  Concurrent process that closes the Payment Plans.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
  -------------------------------------------------------------------
    --Ref cursor variable.
    l_cur_ref cur_ref;

    l_v_meaning                 igs_lookup_values.meaning%TYPE;
    l_v_sql                     VARCHAR2(32767);
    l_v_status                  VARCHAR2(1);
    l_v_var                     VARCHAR2(1);
    l_b_valid_param             BOOLEAN := TRUE;
    l_v_manage_acc              igs_fi_control.manage_accounts%TYPE := NULL;
    l_v_message_name            fnd_new_messages.message_name%TYPE := NULL;
    l_n_person_id               igs_fi_parties_v.person_id%TYPE;

    l_v_tol_thr   CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TOLERANCE_THRESHOLD');
    l_v_test_mode CONSTANT igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TEST_MODE');
    l_n_count                   PLS_INTEGER := 0;
    l_n_cnt                     PLS_INTEGER;
    l_org_id                    VARCHAR2(15);
  BEGIN

    BEGIN
       l_org_id := NULL;
       igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.log, fnd_message.get);
         retcode:=2;
         RETURN;
    END;
    --Create the savepoint for rollback.
    SAVEPOINT sp_close_status;

    retcode := 0;
    errbuf  := NULL;

    --Log the input parameters.
    fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
    fnd_file.put_line(fnd_file.log,fnd_message.get||':');
    fnd_file.new_line(fnd_file.log);

    fnd_file.put_line(fnd_file.log,l_v_tol_thr||':'||p_n_tolerance_threshold);
    fnd_file.put_line(fnd_file.log,g_v_person_group||':'||igs_fi_gen_005.finp_get_prsid_grp_code(p_n_person_id_grp));
    fnd_file.put_line(fnd_file.log,l_v_test_mode||':'||p_v_test_mode);

    fnd_file.new_line(fnd_file.log,1);

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                                );
    IF (l_v_manage_acc = 'OTHER' OR l_v_manage_acc IS NULL) THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;

    --Tolerance Threshold and Test Mode are mandatory parameters to this process.
    --If they are null, log the error message in the log file and error out the process.
    IF p_n_tolerance_threshold IS NULL OR p_v_test_mode IS NULL THEN
      fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;

    --Tolerance Threshold parameter cannot be negative, if so, log the error message in the log file
    --and error out the process.
    IF NVL(p_n_tolerance_threshold,0) < 0 THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',l_v_tol_thr);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_valid_param := FALSE;
    END IF;

    --Validate the Person Group input parameter, if passed as not null.
    IF p_n_person_id_grp IS NOT NULL THEN
      OPEN cur_pers_grp(p_n_person_id_grp);
      FETCH cur_pers_grp INTO l_v_var;
      --If the person group passed is not valid, then log the error message in the log file and error out the process.
      IF cur_pers_grp%NOTFOUND THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',g_v_person_group);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_valid_param := FALSE;
      END IF;
      CLOSE cur_pers_grp;
    END IF;

    --Validate the Test Mode parameter is passed as not null.
    IF p_v_test_mode IS NOT NULL THEN
      --Validate whether the passed p_v_test_mode parameter is a valid lookup.
      l_v_meaning  := igs_fi_gen_gl.get_lkp_meaning('VS_AS_YN',p_v_test_mode);
      --If it is not a valid lookup, then log the error message in the log file and error out the process.
      IF l_v_meaning IS NULL THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',l_v_test_mode);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_b_valid_param := FALSE;
      END IF;
    END IF;

    --If any of the above parameter validations fail, error out the process.
    IF NOT l_b_valid_param THEN
      retcode := 2;
      RETURN;
    END IF;

    l_n_count := 0;

    --If Person Group parameter passed as input to the process is not null, then identify all the Persons
    --that are members of this group using generic function.
    IF p_n_person_id_grp IS NOT NULL THEN
      l_v_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_groupid => p_n_person_id_grp,
                                                                 p_status  => l_v_status
                                                                 );
      --If the sql returned is invalid, then..
      IF l_v_status <> 'S' THEN
        --Log the error message the stop processing.
        fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.put_line(fnd_file.log,l_v_sql);
        retcode := 2;
        RETURN;
      END IF;

      --Execute the sql statement using ref cursor.
      OPEN l_cur_ref FOR l_v_sql;
      LOOP
        --Fetch the person id into local variable.
        FETCH l_cur_ref INTO l_n_person_id;
        EXIT WHEN l_cur_ref%NOTFOUND;

        l_n_count := l_n_count + 1;

        --Check if the person has an active payment plan, otherwise, log the error message
        --and process the next person in the group.
        IF igs_fi_gen_008.chk_active_pay_plan(l_n_person_id) = 'N' THEN

          --Log the person number and error message conveying that the person does not have any active payment plan.
          fnd_file.put_line(fnd_file.log,g_v_person||': '||igs_fi_gen_008.get_party_number(l_n_person_id));
          fnd_message.set_name('IGS','IGS_FI_PP_NO_ACT_PLANS');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.new_line(fnd_file.log);
        ELSE
          --Call the local function for closing the active payment plan record.
          l_n_cnt := close_active_pp(p_n_person_id           => l_n_person_id,
                                     p_n_tolerance_threshold => p_n_tolerance_threshold);
        END IF;
      END LOOP;
      CLOSE l_cur_ref;

    ELSE--if input parameter person id group is passed as null.

      --Call the local function for closing the active payment plan records.
      --In this case, as person id group is passed as null, this local function
      --will return the number of persons processed.
      l_n_count := close_active_pp(p_n_person_id           => NULL,
                                   p_n_tolerance_threshold => p_n_tolerance_threshold);
    END IF;

    --If Test Mode flag is not Y, then all the transactions need to be committed else
    --rollback to the savepoint.
    IF p_v_test_mode <> g_v_ind_yes THEN
      COMMIT;
    ELSE
      IF l_n_count <> 0 THEN
        fnd_message.set_name('IGS','IGS_FI_PRC_TEST_RUN');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        ROLLBACK TO sp_close_status;
      END IF;
    END IF;

    --If there are no persons to be processed...
    --then process should log the message ***No Data Found***.
    IF l_n_count = 0 THEN
      fnd_message.set_name('IGS','IGS_GE_NO_DATA_FOUND');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);
    END IF;

    fnd_file.new_line(fnd_file.log);

    EXCEPTION
    --Handle the Locking exception.
    WHEN e_resource_busy THEN
      ROLLBACK TO sp_close_status;
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log);

    WHEN OTHERS THEN
      ROLLBACK TO sp_close_status;
      retcode := 2;
      fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||' - '||SQLERRM);
    END close_status;

END igs_fi_payment_plans;

/
