--------------------------------------------------------
--  DDL for Package Body IGS_AS_ADI_UPLD_PR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ADI_UPLD_PR_PKG" AS
/* $Header: IGSPR33B.pls 120.3 2006/05/29 06:27:30 ijeddy noship $ */
  --
  -- API to upload the Progression and Unit Outcomes from Web ADI that is used
  -- to upload multiple outcomes for Progression and Unit together from a
  -- single spreadsheet.
  --
  -- This routine calls the existing routines for Progression and Unit Grading
  -- that validate and upload the data from Web ADI to corresponding OSS tables.
  --
  PROCEDURE prog_ug_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    p_batch_date DATE := TO_DATE (p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
    --
    CURSOR error_pr IS
      SELECT *
      FROM   igs_pr_spo_interface
      WHERE  user_id = p_user_id
      AND    trunc(batch_date) = trunc(p_batch_date)
      AND    error_code IS NOT NULL
      AND    NVL (progression_outcome_type, '--') <> '-';
    --
  BEGIN
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_process',
        'Entered the prog_ug_process procedure with values:' ||
        'p_user_id => ' || p_user_id || ';' ||
        'p_batch_datetime => ' || p_batch_datetime || ';' ||
        'p_grade_creation_method_type => ' || p_grade_creation_method_type || ';' ||
        'p_delete_rows => ' || p_delete_rows
      );
    END IF;
    --
    -- Invoke Progression Outcome Upload API
    --
    progression_outcome_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_statement,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_process',
        'Completed progression_outcome_process'
      );
    END IF;
    --
    -- Invoke Unit Grading Upload API
    --
    igs_as_adi_upld_ug_pkg.grading_period_grade_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_statement,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_process',
        'Completed igs_as_adi_upld_ug_pkg.grading_period_grade_process'
      );
    END IF;
    --
    -- Transfer the errors from Progression Interface table to Unit Grading
    -- Interface table as Unit Grading Interface table is used to publish the
    -- errors back in the Web ADI spread sheet
    --
    FOR pr_error_rows IN error_pr LOOP
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_statement,
          'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_process',
          'There were errors in the progression upload, error are being transferred to the IGS_AS_UG_INTERFACE table'
        );
      END IF;
      --
      UPDATE igs_as_ug_interface
      SET    error_code = pr_error_rows.error_code
      WHERE  user_id = p_user_id
      AND    trunc(batch_date) = trunc(p_batch_date)
      AND    (alternate_code = pr_error_rows.progression_outcome_type
              OR (alternate_code IS NULL
                  AND pr_error_rows.progression_outcome_type IS NULL)
             )
      AND    (person_number = pr_error_rows.person_number
              OR anonymous_id = pr_error_rows.anonymous_id)
      AND    course_cd = pr_error_rows.course_cd;
      --
    END LOOP;
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_process',
        'Exiting the prog_ug_process procedure'
      );
    END IF;
    --
  END prog_ug_process;
  --
  -- API to upload the Progression, Unit and Assessment Item Outcomes from
  -- Web ADI that is used to upload multiple outcomes for Progression, Unit
  -- and Assessment Items together from a single spreadsheet.
  --
  -- This routine calls the existing routines for Progression, Unit Grading
  -- and Assessment Item that validate and upload the data from Web ADI to
  -- corresponding OSS tables.
  --
  PROCEDURE prog_ug_aio_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    p_batch_date DATE := TO_DATE (p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
    --
    CURSOR error_pr IS
      SELECT *
      FROM   igs_pr_spo_interface
      WHERE  user_id = p_user_id
      AND    TRUNC (batch_date) = TRUNC (p_batch_date)
      AND    ERROR_CODE IS NOT NULL
      AND    NVL (progression_outcome_type, '--') <> '-';
    --
    CURSOR error_aio IS
      SELECT *
      FROM   igs_as_aio_interface
      WHERE  user_id = p_user_id
      AND    trunc(batch_date) = trunc(p_batch_date)
      AND    ERROR_CODE IS NOT NULL
      AND    ass_id IS NOT NULL;
    --
  BEGIN
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
        'Entered the prog_ug_aio_process procedure with values:' ||
        'p_user_id => ' || p_user_id || ';' ||
        'p_batch_datetime => ' || p_batch_datetime || ';' ||
        'p_grade_creation_method_type => ' || p_grade_creation_method_type || ';' ||
        'p_delete_rows => ' || p_delete_rows
      );
    END IF;
    --
    -- Invoke Progression Outcome Upload API
    --
    progression_outcome_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_statement,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
        'Completed progression_outcome_process'
      );
    END IF;
    --
    -- Invoke Assessment Item Outcome Upload API
    --
    igs_as_adi_upld_aio_pkg.assessment_item_grade_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_statement,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
        'Completed igs_as_adi_upld_aio_pkg.assessment_item_grade_process'
      );
    END IF;
    --
    -- Invoke Unit Grading Upload API
    --
    igs_as_adi_upld_ug_pkg.grading_period_grade_process (
      errbuf,
      retcode,
      p_user_id,
      p_batch_datetime,
      p_grade_creation_method_type,
      p_delete_rows
    );
    --
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_statement,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
        'Completed igs_as_adi_upld_ug_pkg.grading_period_grade_process'
      );
    END IF;
    --
    -- Transfer the errors from Progression Interface table to Unit Grading
    -- Interface table as Unit Grading Interface table is used to publish the
    -- errors back in the Web ADI spread sheet
    --
    FOR pr_error_rows IN error_pr LOOP
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_statement,
          'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
          'There were errors in the progression upload, error are being transferred to the IGS_AS_UG_INTERFACE table'
        );
      END IF;
      --
      UPDATE igs_as_ug_interface
      SET    error_code = pr_error_rows.error_code
      WHERE  user_id = p_user_id
      AND    trunc(batch_date) = trunc(p_batch_date)
      AND    (alternate_code = pr_error_rows.progression_outcome_type
              OR (alternate_code IS NULL
                  AND pr_error_rows.progression_outcome_type IS NULL)
             )
      AND    (person_number = pr_error_rows.person_number
              OR anonymous_id = pr_error_rows.anonymous_id)
      AND    course_cd = pr_error_rows.course_cd
      AND    grading_period_cd = '-';
      --
    END LOOP;
    --
    -- Transfer the errors from Assessment Item Interface table to Unit Grading
    -- Interface table as Unit Grading Interface table is used to publish the
    -- errors back in the Web ADI spread sheet
    --
    FOR aio_error_rows IN error_aio LOOP
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_statement,
          'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
          'There were errors in the assessment item upload, error are being transferred to the IGS_AS_UG_INTERFACE table'
        );
      END IF;
      --
      UPDATE igs_as_ug_interface
      SET    error_code = aio_error_rows.error_code
      WHERE  user_id = p_user_id
      AND    trunc(batch_date) = trunc(p_batch_date)
      AND    (person_number = aio_error_rows.person_number
              OR anonymous_id = aio_error_rows.anonymous_id)
      AND    course_cd = aio_error_rows.course_cd
      AND    uoo_id = aio_error_rows.uoo_id
      AND    cal_type = aio_error_rows.cal_type
      AND    ci_sequence_number = aio_error_rows.ci_sequence_number
      AND    unit_class = aio_error_rows.unit_class
      AND    location_cd = aio_error_rows.location_cd
      AND    incomp_default_mark = aio_error_rows.ass_id
      AND    grading_period_cd = '-';
      --
    END LOOP;
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        'igs.plsql.igs_as_adi_upld_pr_pkg.prog_ug_aio_process',
        'Exiting the prog_ug_aio_process procedure'
      );
    END IF;
    --
  END prog_ug_aio_process;
  --
  -- Validate the records before inserting into base table and call the table handlers
  --
  PROCEDURE progression_outcome_process (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_user_id                      IN     NUMBER,
    p_batch_datetime               IN     VARCHAR2,
    p_grade_creation_method_type   IN     VARCHAR2,
    p_delete_rows                  IN     VARCHAR2 DEFAULT 'Y'
  ) IS
    --
    v_person_id              NUMBER (15);
    v_prg_cal_type           VARCHAR2 (10);
    v_prg_ci_sequence_number NUMBER (6);
    v_spo_sequence_number    NUMBER (10);
    v_error_code             VARCHAR2 (30);
    v_load_file_flag         VARCHAR2 (1);
    v_load_file_master       VARCHAR2 (1) := 'Y';
    v_load_record_flag       VARCHAR2 (1);
    v_rowid                  VARCHAR2 (25);
    v_org_id                 NUMBER (15);
    v_request_id             NUMBER;
    v_he_rowid               VARCHAR2 (25);
    v_hesa_en_susa_id        NUMBER (6, 0);
    --
    CURSOR c_susa (
      cp_person_id                          igs_he_en_susa.person_id%TYPE,
      cp_course_cd                          igs_he_en_susa.course_cd%TYPE,
      cp_unit_set_cd                        igs_he_en_susa.unit_set_cd%TYPE,
      cp_sequence_number                    igs_he_en_susa.sequence_number%TYPE,
      cp_us_version_number                  igs_he_en_susa.us_version_number%TYPE
    ) IS
      SELECT ROWID,
             hesa_en_susa_id,
             person_id,
             course_cd,
             unit_set_cd,
             us_version_number,
             sequence_number,
             new_he_entrant_cd,
             term_time_accom,
             disability_allow,
             additional_sup_band,
             sldd_discrete_prov,
             study_mode,
             study_location,
             fte_perc_override,
             franchising_activity,
             completion_status,
             good_stand_marker,
             complete_pyr_study_cd,
             credit_value_yop1,
             credit_value_yop2,
             credit_level_achieved1,
             credit_level_achieved2,
             credit_pt_achieved1,
             credit_pt_achieved2,
             credit_level1,
             credit_level2,
             grad_sch_grade,
             mark,
             teaching_inst1,
             teaching_inst2,
             pro_not_taught,
             fundability_code,
             fee_eligibility,
             fee_band,
             non_payment_reason,
             student_fee,
             fte_intensity,
             calculated_fte,
             fte_calc_type,
             type_of_year,
             credit_value_yop3,
             credit_value_yop4,
             credit_level_achieved3,
             credit_level_achieved4,
             credit_pt_achieved3,
             credit_pt_achieved4,
             credit_level3,
             credit_level4,
             additional_sup_cost,
             enh_fund_elig_cd,
             disadv_uplift_factor,
             year_stu
      FROM   igs_he_en_susa
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_course_cd
      AND    unit_set_cd = cp_unit_set_cd
      AND    sequence_number = cp_sequence_number
      AND    us_version_number = cp_us_version_number;
    --
    v_susa                   c_susa%ROWTYPE;
    p_batch_date             DATE := TO_DATE (p_batch_datetime, 'YYYY/MM/DD HH24:MI:SS');
    v_unit_set_cd            igs_he_en_susa.unit_set_cd%TYPE;
    v_us_version_number      igs_he_en_susa.us_version_number%TYPE;
    v_sequence_number        igs_he_en_susa.sequence_number%TYPE;
    --
    CURSOR c_upload_outcome_spoi IS
      SELECT spoi.user_id,
             spoi.batch_date,
             decode(spoi.person_number,'-',null,spoi.person_number) person_number,
             decode(spoi.anonymous_id,'-',null,spoi.anonymous_id) anonymous_id,
             spoi.course_cd,
             spoi.progression_outcome_type,
             spoi.comments,
             spoi.error_code,
             spoi.ROWID,
             spoi.yop_grade,
             spoi.yop_mark
      FROM   igs_pr_spo_interface spoi
      WHERE  spoi.user_id = p_user_id
      AND    trunc(spoi.batch_date) = trunc(p_batch_date)
      AND    NVL (spoi.progression_outcome_type, '--') <> '-';
    --
    CURSOR spo_exists (
             cp_person_id         NUMBER,
             cp_course_cd         VARCHAR2,
             cp_prg_cal_type      VARCHAR2,
             cp_prg_ci_sequence_number   NUMBER,
             cp_progression_outcome_type VARCHAR2
           ) IS
      SELECT 'X' spo_exists
      FROM   igs_pr_stdnt_pr_ou_all
      WHERE  person_id = cp_person_id
      AND    course_cd = cp_course_cd
      AND    prg_cal_type = cp_prg_cal_type
      AND    prg_ci_sequence_number = cp_prg_ci_sequence_number
      AND    progression_outcome_type = cp_progression_outcome_type;
    --
    lspo_exists              VARCHAR2 (1);
    l_validuser              VARCHAR2(1);
    --
  BEGIN
    --

    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    FOR v_spoi_rec IN c_upload_outcome_spoi LOOP
      --
      -- Check if the user is authorised to upload data.
      -- Only Admin/valid Faculty can upload progression data to OSS.
      --
      l_validuser := igs_as_adi_upld_aio_pkg.isvaliduser (
                       v_spoi_rec.user_id
                     );
      --
      IF (l_validuser <> 'Y') THEN
        UPDATE igs_pr_spo_interface
        SET    error_code = 'IGS_EN_PERSON_NO_RESP'
        WHERE  ROWID = v_spoi_rec.ROWID;
      ELSE
        v_error_code := NULL;
        --
        -- Call routine to upload for validate the particular row
        --
        igs_as_pr_val_upld (
          v_spoi_rec.person_number,
          v_spoi_rec.anonymous_id,
          v_spoi_rec.course_cd,
          v_spoi_rec.progression_outcome_type,
          v_person_id,
          v_prg_cal_type,
          v_prg_ci_sequence_number,
          v_error_code,
          v_load_file_flag,
          v_load_record_flag,
          v_unit_set_cd,
          v_us_version_number,
          v_sequence_number,
          v_spoi_rec.yop_mark,
          v_spoi_rec.yop_grade
        );
        --
        IF v_load_file_flag = 'N' THEN
          v_load_file_master := 'N';
        END IF;
        --
        IF (v_error_code IS NOT NULL) THEN
          --
          -- Update the interface record with the error code
          --
          UPDATE igs_pr_spo_interface
          SET    error_code = v_error_code
          WHERE  ROWID = v_spoi_rec.ROWID;
        END IF;
      END IF;
    END LOOP;
    --
    COMMIT;
    --
    -- If any of the records set the
    --
    IF v_load_file_master = 'Y'  THEN
      FOR v_spoi_rec IN c_upload_outcome_spoi LOOP
        igs_as_pr_val_upld (
          v_spoi_rec.person_number,
          v_spoi_rec.anonymous_id,
          v_spoi_rec.course_cd,
          v_spoi_rec.progression_outcome_type,
          v_person_id,
          v_prg_cal_type,
          v_prg_ci_sequence_number,
          v_error_code,
          v_load_file_flag,
          v_load_record_flag,
          v_unit_set_cd,
          v_us_version_number,
          v_sequence_number,
          v_spoi_rec.yop_mark,
          v_spoi_rec.yop_grade
        );
        OPEN spo_exists (
               v_person_id,
               v_spoi_rec.course_cd,
               v_prg_cal_type,
               v_prg_ci_sequence_number,
               v_spoi_rec.progression_outcome_type
             );
        FETCH spo_exists INTO lspo_exists;
        CLOSE spo_exists;
        IF ((v_load_record_flag = 'Y' OR v_load_record_flag = 'W')
                AND lspo_exists IS NULL )
           THEN
          BEGIN
          IF v_spoi_rec.progression_outcome_type IS NOT NULL THEN
            SELECT igs_pr_spo_seq_num_s.NEXTVAL
            INTO   v_spo_sequence_number
            FROM   DUAL;
            --
            igs_pr_stdnt_pr_ou_pkg.insert_row (
              x_rowid                        => v_rowid,
              x_person_id                    => v_person_id,
              x_course_cd                    => v_spoi_rec.course_cd,
              x_sequence_number              => v_spo_sequence_number,
              x_prg_cal_type                 => v_prg_cal_type,
              x_prg_ci_sequence_number       => v_prg_ci_sequence_number,
              x_rule_check_dt                => NULL,
              x_progression_rule_cat         => NULL,
              x_pra_sequence_number          => NULL,
              x_pro_sequence_number          => NULL,
              x_progression_outcome_type     => v_spoi_rec.progression_outcome_type,
              x_duration                     => NULL,
              x_duration_type                => NULL,
              x_decision_status              => 'PENDING',
              x_decision_dt                  => NULL,
              x_decision_org_unit_cd         => NULL,
              x_decision_ou_start_dt         => NULL,
              x_applied_dt                   => NULL,
              x_show_cause_expiry_dt         => NULL,
              x_show_cause_dt                => NULL,
              x_show_cause_outcome_dt        => NULL,
              x_show_cause_outcome_type      => NULL,
              x_appeal_expiry_dt             => NULL,
              x_appeal_dt                    => NULL,
              x_appeal_outcome_dt            => NULL,
              x_appeal_outcome_type          => NULL,
              x_encmb_course_group_cd        => NULL,
              x_restricted_enrolment_cp      => NULL,
              x_restricted_attendance_type   => NULL,
              x_comments                     => v_spoi_rec.comments,
              x_show_cause_comments          => NULL,
              x_appeal_comments              => NULL,
              x_expiry_dt                    => NULL,
              x_pro_pra_sequence_number      => NULL,
              x_mode                         => 'S',
              x_org_id                       => v_org_id
            );
          END IF; --IF v_spoi_rec.progression_outcome_type IS NOT NULL THEN
          EXCEPTION
            WHEN OTHERS THEN
              DECLARE
                app_short_name VARCHAR2 (10);
                message_name   VARCHAR2 (100);
              BEGIN
                fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
                fnd_message.parse_encoded (
                  fnd_message.get_encoded,
                  app_short_name,
                  message_name
                );
                retcode := 2;
                errbuf := message_name;
                IF (errbuf IS NOT NULL) THEN
                  UPDATE igs_pr_spo_interface
                  SET    error_code = errbuf
                  WHERE  rowid = v_spoi_rec.rowid;
                END IF;
              END;
          END;
          --
          IF (fnd_profile.VALUE ('CAREER_MODEL_ENABLED') = 'N'
              AND fnd_profile.VALUE ('IGS_PS_PRENRL_YEAR_IND') = 'Y'
              AND v_load_record_flag = 'Y'
              AND (v_spoi_rec.yop_grade IS NOT NULL OR v_spoi_rec.yop_mark IS NOT NULL)
             ) THEN
            BEGIN
              igs_he_en_susa_pkg.insert_row (
                x_mode                         => 'S',
                x_rowid                        => v_he_rowid,
                x_hesa_en_susa_id              => v_hesa_en_susa_id,
                x_person_id                    => v_person_id,
                x_course_cd                    => v_spoi_rec.course_cd,
                x_unit_set_cd                  => v_unit_set_cd,
                x_us_version_number            => v_us_version_number,
                x_sequence_number              => v_sequence_number,
                x_new_he_entrant_cd            => NULL,
                x_term_time_accom              => NULL,
                x_disability_allow             => NULL,
                x_additional_sup_band          => NULL,
                x_sldd_discrete_prov           => NULL,
                x_study_mode                   => NULL,
                x_study_location               => NULL,
                x_fte_perc_override            => NULL,
                x_franchising_activity         => NULL,
                x_completion_status            => NULL,
                x_good_stand_marker            => NULL,
                x_complete_pyr_study_cd        => NULL,
                x_credit_value_yop1            => NULL,
                x_credit_value_yop2            => NULL,
                x_credit_level_achieved1       => NULL,
                x_credit_level_achieved2       => NULL,
                x_credit_pt_achieved1          => NULL,
                x_credit_pt_achieved2          => NULL,
                x_credit_level1                => NULL,
                x_credit_level2                => NULL,
                x_grad_sch_grade               => v_spoi_rec.yop_grade,
                x_mark                         => TO_NUMBER (v_spoi_rec.yop_mark),
                x_teaching_inst1               => NULL,
                x_teaching_inst2               => NULL,
                x_pro_not_taught               => NULL,
                x_fundability_code             => NULL,
                x_fee_eligibility              => NULL,
                x_fee_band                     => NULL,
                x_non_payment_reason           => NULL,
                x_student_fee                  => NULL,
                x_fte_intensity                => NULL,
                x_calculated_fte               => NULL,
                x_fte_calc_type                => NULL,
                x_type_of_year                 => NULL,
                x_credit_value_yop3            => NULL,
                x_credit_value_yop4            => NULL,
                x_credit_level_achieved3       => NULL,
                x_credit_level_achieved4       => NULL,
                x_credit_pt_achieved3          => NULL,
                x_credit_pt_achieved4          => NULL,
                x_credit_level3                => NULL,
                x_credit_level4                => NULL,
                x_additional_sup_cost          => NULL,
                x_enh_fund_elig_cd             => NULL,
                x_disadv_uplift_factor         => NULL,
                x_year_stu                     => NULL
              );
            EXCEPTION
              WHEN OTHERS THEN
                DECLARE
                  app_short_name VARCHAR2 (10);
                  message_name   VARCHAR2 (100);
                BEGIN
                  fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
                  fnd_message.parse_encoded (
                    fnd_message.get_encoded,
                    app_short_name,
                    message_name
                  );
                  retcode := 2;
                  errbuf := message_name;
                  IF (errbuf IS NOT NULL) THEN
                    UPDATE igs_pr_spo_interface
                    SET    error_code = errbuf
                    WHERE  rowid = v_spoi_rec.rowid;
                  END IF;
                END;
            END;
          END IF;
        END IF; -- load record
        --
        IF v_load_record_flag = 'W' THEN
          OPEN c_susa (v_person_id, v_spoi_rec.course_cd, v_unit_set_cd, v_sequence_number, v_us_version_number);
          FETCH c_susa INTO v_susa;
          BEGIN
            igs_he_en_susa_pkg.update_row (
              x_mode                         => 'S',
              x_rowid                        => v_susa.ROWID,
              x_hesa_en_susa_id              => v_susa.hesa_en_susa_id,
              x_person_id                    => v_susa.person_id,
              x_course_cd                    => v_susa.course_cd,
              x_unit_set_cd                  => v_susa.unit_set_cd,
              x_us_version_number            => v_susa.us_version_number,
              x_sequence_number              => v_susa.sequence_number,
              x_new_he_entrant_cd            => v_susa.new_he_entrant_cd,
              x_term_time_accom              => v_susa.term_time_accom,
              x_disability_allow             => v_susa.disability_allow,
              x_additional_sup_band          => v_susa.additional_sup_band,
              x_sldd_discrete_prov           => v_susa.sldd_discrete_prov,
              x_study_mode                   => v_susa.study_mode,
              x_study_location               => v_susa.study_location,
              x_fte_perc_override            => v_susa.fte_perc_override,
              x_franchising_activity         => v_susa.franchising_activity,
              x_completion_status            => v_susa.completion_status,
              x_good_stand_marker            => v_susa.good_stand_marker,
              x_complete_pyr_study_cd        => v_susa.complete_pyr_study_cd,
              x_credit_value_yop1            => v_susa.credit_value_yop1,
              x_credit_value_yop2            => v_susa.credit_value_yop2,
              x_credit_level_achieved1       => v_susa.credit_level_achieved1,
              x_credit_level_achieved2       => v_susa.credit_level_achieved2,
              x_credit_pt_achieved1          => v_susa.credit_pt_achieved1,
              x_credit_pt_achieved2          => v_susa.credit_pt_achieved2,
              x_credit_level1                => v_susa.credit_level1,
              x_credit_level2                => v_susa.credit_level2,
              x_grad_sch_grade               => v_spoi_rec.yop_grade,
              x_mark                         => TO_NUMBER (v_spoi_rec.yop_mark),
              x_teaching_inst1               => v_susa.teaching_inst1,
              x_teaching_inst2               => v_susa.teaching_inst2,
              x_pro_not_taught               => v_susa.pro_not_taught,
              x_fundability_code             => v_susa.fundability_code,
              x_fee_eligibility              => v_susa.fee_eligibility,
              x_fee_band                     => v_susa.fee_band,
              x_non_payment_reason           => v_susa.non_payment_reason,
              x_student_fee                  => v_susa.student_fee,
              x_fte_intensity                => v_susa.fte_intensity,
              x_calculated_fte               => v_susa.calculated_fte,
              x_fte_calc_type                => v_susa.fte_calc_type,
              x_type_of_year                 => v_susa.type_of_year,
              x_credit_value_yop3            => v_susa.credit_value_yop3,
              x_credit_value_yop4            => v_susa.credit_value_yop4,
              x_credit_level_achieved3       => v_susa.credit_level_achieved3,
              x_credit_level_achieved4       => v_susa.credit_level_achieved4,
              x_credit_pt_achieved3          => v_susa.credit_pt_achieved3,
              x_credit_pt_achieved4          => v_susa.credit_pt_achieved4,
              x_credit_level3                => v_susa.credit_level3,
              x_credit_level4                => v_susa.credit_level4,
              x_additional_sup_cost          => v_susa.additional_sup_cost,
              x_enh_fund_elig_cd             => v_susa.enh_fund_elig_cd,
              x_disadv_uplift_factor         => v_susa.disadv_uplift_factor,
              x_year_stu                     => v_susa.year_stu
            );
          EXCEPTION
            WHEN OTHERS THEN
              DECLARE
                app_short_name VARCHAR2 (10);
                message_name   VARCHAR2 (100);
              BEGIN
                fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
                fnd_message.parse_encoded (
                  fnd_message.get_encoded,
                  app_short_name,
                  message_name
                );
                retcode := 2;
                errbuf := message_name;
                IF (errbuf IS NOT NULL) THEN
                  UPDATE igs_pr_spo_interface
                  SET    error_code = errbuf
                  WHERE  rowid = v_spoi_rec.rowid;
                END IF;
              END;
          END;
          CLOSE c_susa;
        END IF;
      END LOOP;
    END IF; -- Load File
    --
    -- Call Reports to generate  the error report with parameters
    -- then delete the records from by calling after report trigger.
    --
    /*  Extracting WebADI from Concurrent Program LOV */
    IF p_grade_creation_method_type <> 'WEBADI' THEN
      v_request_id :=
           fnd_request.submit_request ('IGS', 'IGSPRS04', NULL, NULL, FALSE, p_user_id, p_batch_datetime, p_delete_rows);
    END IF;
    IF v_request_id = 0 THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
    COMMIT;
    --
  END progression_outcome_process;
  --
  -- Validate single Grading Period record from the interface table
  -- before being uploaded.
  -- This validation is called from the interface table import routine,
  -- and also the ADI pre-validation functionality.
  --
  PROCEDURE igs_as_pr_val_upld (
    p_person_number                IN     VARCHAR2,
    p_anonymous_id                 IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_progression_outcome_type     IN     VARCHAR2,
    p_person_id                    OUT NOCOPY NUMBER,
    p_prg_cal_type                 OUT NOCOPY VARCHAR2,
    p_prg_ci_sequence_number       OUT NOCOPY NUMBER,
    p_error_code                   OUT NOCOPY VARCHAR2,
    p_load_file_flag               OUT NOCOPY VARCHAR2,
    p_load_record_flag             OUT NOCOPY VARCHAR2,
    p_unit_set_cd                  OUT NOCOPY igs_as_su_setatmpt.unit_set_cd%TYPE,
    p_us_version_number            OUT NOCOPY igs_as_su_setatmpt.us_version_number%TYPE,
    p_sequence_number              OUT NOCOPY igs_he_en_susa.sequence_number%TYPE,
    p_mark                         IN     NUMBER,
    p_grade                        IN OUT NOCOPY VARCHAR2
  ) IS
    --
    v_course_attempt_status      VARCHAR2 (30);
    v_version_number             NUMBER (3);
    v_s_progression_outcome_type VARCHAR2 (30);
    v_upld_person_no_exist       VARCHAR2 (1);
    v_upld_crs_not_enrolled      VARCHAR2 (1);
    v_dummy                      VARCHAR2 (1);
    v_grading_schema_cd          igs_as_grd_sch_grade.grading_schema_cd%TYPE;
    v_gs_version_number          igs_as_grd_sch_grade.version_number%TYPE;
    --
    -- Get Grading Entry Configuration
    --
    CURSOR c_ec IS
      SELECT ec.upld_person_no_exist,
             ec.upld_crs_not_enrolled
      FROM   igs_as_entry_conf ec
      WHERE  s_control_num = 1;
    --
    -- Get Person ID based on Anonymous ID - Assumes UK program based ID's
    --
    CURSOR c_aip IS
      SELECT aip.person_id
      FROM   igs_as_anon_id_ps aip
      WHERE  aip.anonymous_id = p_anonymous_id
      AND    aip.course_cd = p_course_cd;
    --
    -- Get Person ID based on Person Number
    --
    CURSOR c_p IS
      SELECT p.party_id
      FROM   hz_parties p
      WHERE  p.party_number = p_person_number;
    --
    -- Get Student Program Attempt details
    --
    CURSOR c_spa (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE) IS
      SELECT spa.course_attempt_status,
             spa.version_number
      FROM   igs_en_stdnt_ps_att_all spa
      WHERE  spa.person_id = cp_person_id
      AND    spa.course_cd = p_course_cd;
    --
    -- Get the System Progession Outcome Type
    --
    CURSOR c_pot IS
      SELECT pot.s_progression_outcome_type
      FROM   igs_pr_ou_type pot
      WHERE  pot.progression_outcome_type = p_progression_outcome_type;
    --
    -- Check Student Progression Outcome doesn't already exist
    --
    CURSOR c_spo (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_prg_cal_type                       igs_ca_inst.cal_type%TYPE,
      cp_prg_ci_sequence_number             igs_ca_inst.sequence_number%TYPE
    ) IS
      SELECT 'X'
      FROM   igs_pr_stdnt_pr_ou spo
      WHERE  spo.person_id = cp_person_id
      AND    spo.course_cd = p_course_cd
      AND    spo.progression_outcome_type = p_progression_outcome_type
      AND    spo.decision_status IN ('PENDING', 'APPROVED')
      AND    spo.prg_cal_type = cp_prg_cal_type
      AND    spo.prg_ci_sequence_number = cp_prg_ci_sequence_number;
    --
    -- Determine the current progression period
    --
    CURSOR c_scpc (cp_version_number igs_ps_ver.version_number%TYPE) IS
      SELECT 'X'
      FROM   igs_pr_s_crv_prg_cal scpc
      WHERE  scpc.course_cd = p_course_cd
      AND    scpc.version_number = cp_version_number;

    CURSOR c_scpc_ci (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_version_number                     igs_ps_ver.version_number%TYPE
    ) IS
      SELECT   ci.cal_type,
               ci.sequence_number
      FROM     igs_pr_s_crv_prg_cal scpc,
               igs_ca_inst ci,
               igs_ca_stat cs
      WHERE    scpc.course_cd = p_course_cd
      AND      scpc.version_number = cp_version_number
      AND      ci.cal_type = scpc.prg_cal_type
      AND      ci.cal_status = cs.cal_status
      AND      cs.s_cal_status = 'ACTIVE'
      AND      ci.start_dt < SYSDATE
      --AND     ci.end_dt = (SELECT  MAX(ci.end_dt)
      AND      EXISTS ( SELECT 'X'
                        FROM   igs_ca_inst_rel cir,
                               igs_en_su_attempt sua
                        WHERE  cir.sup_cal_type = ci.cal_type
                        AND    cir.sup_ci_sequence_number = ci.sequence_number
                        AND    cir.sub_cal_type = sua.cal_type
                        AND    cir.sub_ci_sequence_number = sua.ci_sequence_number
                        AND    sua.person_id = cp_person_id
                        AND    sua.course_cd = p_course_cd
                        AND    sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED'))
      ORDER BY ci.end_dt DESC;
    --
    --
    --
    CURSOR c_sopc (cp_version_number igs_ps_ver.version_number%TYPE) IS
      SELECT 'X'
      FROM   igs_pr_s_ou_prg_cal sopc
      WHERE  igs_pr_gen_001.prgp_get_crv_cmt (p_course_cd, cp_version_number, sopc.org_unit_cd, sopc.ou_start_dt) = 'Y';
    --
    --
    --
    CURSOR c_sopc_ci (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_version_number                     igs_ps_ver.version_number%TYPE
    ) IS
      SELECT   ci.cal_type,
               ci.sequence_number
      FROM     igs_pr_s_ou_prg_cal sopc,
               igs_ca_inst ci,
               igs_ca_stat cs
      WHERE    igs_pr_gen_001.prgp_get_crv_cmt (p_course_cd, cp_version_number, sopc.org_unit_cd, sopc.ou_start_dt) = 'Y'
      AND      ci.cal_type = sopc.prg_cal_type
      AND      ci.cal_status = cs.cal_status
      AND      cs.s_cal_status = 'ACTIVE'
      AND      ci.start_dt < SYSDATE
      --AND     ci.end_dt = (SELECT  MAX(ci.end_dt)
      AND      EXISTS ( SELECT 'X'
                        FROM   igs_ca_inst_rel cir,
                               igs_en_su_attempt sua
                        WHERE  cir.sup_cal_type = ci.cal_type
                        AND    cir.sup_ci_sequence_number = ci.sequence_number
                        AND    cir.sub_cal_type = sua.cal_type
                        AND    cir.sub_ci_sequence_number = sua.ci_sequence_number
                        AND    sua.person_id = cp_person_id
                        AND    sua.course_cd = p_course_cd
                        AND    sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED'))
      ORDER BY ci.end_dt DESC;
    --
    --
    --
    CURSOR c_spc_ci (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE) IS
      SELECT   ci.cal_type,
               ci.sequence_number
      FROM     igs_pr_s_prg_cal spc,
               igs_ca_inst ci,
               igs_ca_stat cs
      WHERE    spc.s_control_num = 1
      AND      ci.cal_type = spc.prg_cal_type
      AND      ci.cal_status = cs.cal_status
      AND      cs.s_cal_status = 'ACTIVE'
      AND      ci.start_dt < SYSDATE
      --AND     ci.end_dt = (SELECT  MAX(ci.end_dt)
      AND      EXISTS ( SELECT 'X'
                        FROM   igs_ca_inst_rel cir,
                               igs_en_su_attempt sua
                        WHERE  cir.sup_cal_type = ci.cal_type
                        AND    cir.sup_ci_sequence_number = ci.sequence_number
                        AND    cir.sub_cal_type = sua.cal_type
                        AND    cir.sub_ci_sequence_number = sua.ci_sequence_number
                        AND    sua.person_id = cp_person_id
                        AND    sua.course_cd = p_course_cd
                        AND    sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED'))
      ORDER BY ci.end_dt DESC;
    --
    --
    --
    CURSOR c_grd_sch (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_course_cd                          igs_en_stdnt_ps_att_all.course_cd%TYPE
    ) IS
      SELECT hpoous.grading_schema_cd,
             hpoous.gs_version_number,
             yop.unit_set_cd,
             yop.us_version_number,
             yop.sequence_number
      FROM   igs_en_susa_year_v yop,
             igs_en_stdnt_ps_att_all spa,
             igs_ps_ofr_opt_all coo,
             igs_he_poous_all hpoous
      WHERE  yop.person_id = cp_person_id
      AND    yop.course_cd = cp_course_cd
      AND    yop.completion_dt IS NULL
      AND    yop.end_dt IS NULL
      AND    yop.person_id = spa.person_id
      AND    yop.course_cd = spa.course_cd
      AND    spa.coo_id = coo.coo_id
      AND    hpoous.unit_set_cd = yop.unit_set_cd
      AND    hpoous.us_version_number = yop.us_version_number
      AND    hpoous.course_cd = coo.course_cd
      AND    hpoous.crv_version_number = coo.version_number
      AND    hpoous.cal_type = coo.cal_type
      AND    hpoous.location_cd = coo.location_cd
      AND    hpoous.attendance_type = coo.attendance_type
      AND    hpoous.attendance_mode = coo.attendance_mode;
    --
    -- Cursor to check if the grade entered in part of the grading schema
    --
    CURSOR cur_grade_exists (
      cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE,
      cp_grade                              igs_as_grd_sch_grade.grade%TYPE
    ) IS
      SELECT 'Y' grade_found
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number
      AND    gsg.grade = cp_grade;
    --
    rec_grade_exists cur_grade_exists%ROWTYPE;
    --
    --
    --
    CURSOR c_calc_grade (
      cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE,
      cp_marks                              igs_as_grd_sch_grade.lower_mark_range%TYPE
    ) IS
      SELECT grade
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number
      AND    system_only_ind = 'N'
      AND    cp_marks BETWEEN gsg.lower_mark_range AND gsg.upper_mark_range;
    --
    rec_calc_grade c_calc_grade%ROWTYPE;
    --
    -- Cursor to fix the issue progression outcome uploading incorrect marks and grades
    --
    CURSOR c_gsg_min_max (
             cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
             cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE
           ) IS
      SELECT MIN (gsg.lower_mark_range) min_lower_mark_range,
             MAX (gsg.upper_mark_range) max_upper_mark_range
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
      AND    gsg.version_number = cp_gs_version_number;
    rec_gsg_min_max c_gsg_min_max%ROWTYPE;
    --
  BEGIN
    -- Initialise flags
    p_load_file_flag := 'Y';
    p_load_record_flag := 'Y';
    --
    -- Get Grade Entry Configuration
    --
    OPEN c_ec;
    FETCH c_ec INTO v_upld_person_no_exist,
                    v_upld_crs_not_enrolled;
    CLOSE c_ec;
    --
    -- Get Person ID from Person Number and Anonymous ID
    --
    IF  p_person_number IS NULL
        AND p_anonymous_id IS NULL THEN
      IF v_upld_person_no_exist = 'D' THEN
        p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_person_no_exist = 'A' THEN
        p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    ELSIF  p_person_number IS NOT NULL
           AND p_anonymous_id IS NOT NULL THEN
      p_error_code := 'IGS_AS_ASD_PER_ANON_BOTH_EXIST';
      p_load_record_flag := 'N';
      RETURN;
    ELSIF  p_person_number IS NULL
           AND p_anonymous_id IS NOT NULL THEN
      -- Get the Person ID based on the Anonymous ID
      OPEN c_aip;
      FETCH c_aip INTO p_person_id;
      IF c_aip%NOTFOUND THEN
        IF v_upld_person_no_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_person_no_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
          p_load_file_flag := 'N';
          RETURN;
        END IF;
      END IF;
      CLOSE c_aip;
    ELSIF  p_person_number IS NOT NULL
           AND p_anonymous_id IS NULL THEN
      --
      -- Get the Person ID based on the Person Number
      --
      OPEN c_p;
      FETCH c_p INTO p_person_id;
      IF c_p%NOTFOUND THEN
        IF v_upld_person_no_exist = 'D' THEN
          p_error_code := 'IGS_AS_ASD_AN_NO_PERSON_EXIST';
          p_load_record_flag := 'N';
          RETURN;
        ELSIF v_upld_person_no_exist = 'A' THEN
          p_error_code := 'IGS_AS_ASA_AN_NO_PERSON_EXIST';
          p_load_file_flag := 'N';
          RETURN;
        END IF;
      END IF;
      CLOSE c_p;
    END IF;
    --
    -- Check for a valid Student Program Attempt
    --
    OPEN c_spa (p_person_id);
    FETCH c_spa INTO v_course_attempt_status,
                     v_version_number;
    IF c_spa%NOTFOUND THEN
      p_error_code := 'IGS_AS_ASA_PR_NO_PRGRM_ATTEMPT';
      p_load_file_flag := 'N';
      RETURN;
    END IF;
    CLOSE c_spa;
    IF v_course_attempt_status NOT IN ('ENROLLED', 'INACTIVE') THEN
      IF v_upld_crs_not_enrolled = 'D' THEN
        p_error_code := 'IGS_AS_ASD_COURSE_NOT_ENROLLED';
        p_load_record_flag := 'N';
        RETURN;
      ELSIF v_upld_crs_not_enrolled = 'A' THEN
        p_error_code := 'IGS_AS_ASA_COURSE_NOT_ENROLLED';
        p_load_file_flag := 'N';
        RETURN;
      END IF;
    END IF;
    --
    -- Validate that progression outcome type is valid.
    --
IF p_progression_outcome_type IS NOT NULL THEN
    OPEN c_pot;
    FETCH c_pot INTO v_s_progression_outcome_type;
    IF c_pot%NOTFOUND THEN
      p_error_code := 'IGS_AS_ASA_PR_NOT_VALID';
      p_load_file_flag := 'N';
      RETURN;
    ELSIF v_s_progression_outcome_type NOT IN ('NOPENALTY', 'ADVANCE', 'REPEATYR',
                                               'MANUAL', 'EXCLUSION',  'EXPULSION') THEN
      p_error_code := 'IGS_AS_ASA_PR_TYPE_INVALID';
      p_load_file_flag := 'N';
      RETURN;
    END IF;
    CLOSE c_pot;
    --
    -- Check for Progression Calendar Stream configuration at Program
    -- Version level
    --
    OPEN c_scpc (v_version_number);
    FETCH c_scpc INTO v_dummy;
    IF c_scpc%FOUND THEN
      CLOSE c_scpc;
      -- Get Matching Progression Calendar at Program Version level
      OPEN c_scpc_ci (p_person_id, v_version_number);
      FETCH c_scpc_ci INTO p_prg_cal_type,
                           p_prg_ci_sequence_number;
      IF c_scpc_ci%NOTFOUND THEN
        p_error_code := 'IGS_AS_ASA_PR_CLNDR_NOT_FOUND';
        p_load_record_flag := 'N';
        RETURN;
      END IF;
      CLOSE c_scpc_ci;
    ELSE
      --
      -- Check for Progression Calendar Stream configuration at Org
      -- Unit level
      --
      OPEN c_sopc (v_version_number);
      FETCH c_sopc INTO v_dummy;
      IF c_sopc%FOUND THEN
        CLOSE c_sopc;
        -- Get Matching Progression Calendar at Org Unit level
        OPEN c_sopc_ci (p_person_id, v_version_number);
        FETCH c_sopc_ci INTO p_prg_cal_type,
                             p_prg_ci_sequence_number;
        IF c_sopc_ci%NOTFOUND THEN
          p_error_code := 'IGS_AS_ASA_PR_CLNDR_NOT_FOUND';
          p_load_record_flag := 'N';
          RETURN;
        END IF;
        CLOSE c_sopc_ci;
      ELSE
        -- Get matching Progression Calendar at Institution level
        OPEN c_spc_ci (p_person_id);
        FETCH c_spc_ci INTO p_prg_cal_type,
                            p_prg_ci_sequence_number;
        IF c_spc_ci%NOTFOUND THEN
          p_error_code := 'IGS_AS_ASA_PR_CLNDR_NOT_FOUND';
          p_load_record_flag := 'N';
          RETURN;
        END IF;
        CLOSE c_spc_ci;
      END IF;
    END IF;
    --
    --Check that person doesn't already have an outcome of this type.
    --
    IF (fnd_profile.VALUE ('CAREER_MODEL_ENABLED') = 'Y') THEN
      OPEN c_spo (p_person_id, p_prg_cal_type, p_prg_ci_sequence_number);
      FETCH c_spo INTO v_dummy;
      IF c_spo%FOUND THEN
        CLOSE c_spo;
        p_error_code := 'IGS_AS_ASA_PR_OUTCOME_EXIST';
        p_load_record_flag := 'N';
        RETURN;
      END IF;
    END IF;
END IF;
    --
    -- Get the Grading schema Grades
    --
    OPEN c_grd_sch (p_person_id, p_course_cd);
    FETCH c_grd_sch INTO v_grading_schema_cd,
                         v_gs_version_number,
                         p_unit_set_cd,
                         p_us_version_number,
                         p_sequence_number;
    CLOSE c_grd_sch;
    --
      --
      -- Validate that the grade entered by the user is part of the grading schema
      --
    IF p_grade IS NOT NULL THEN
      OPEN cur_grade_exists (v_grading_schema_cd, v_gs_version_number, p_grade);
      FETCH cur_grade_exists INTO rec_grade_exists;
      IF (cur_grade_exists%NOTFOUND) THEN
        p_error_code := 'IGS_AS_GRADE_INVALID';
      END IF;
      CLOSE cur_grade_exists;

    END IF;

    --
    -- Determine action if record already exists
    --
    BEGIN
      IF igs_he_en_susa_pkg.get_uk_for_validation (
           x_person_id                    => p_person_id,
           x_course_cd                    => p_course_cd,
           x_unit_set_cd                  => p_unit_set_cd,
           x_sequence_number              => p_sequence_number
         ) THEN
        p_load_record_flag := 'W';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      p_load_file_flag := 'N';
      p_load_record_flag := 'N';
      p_error_code := 'No Data Found - Others';
  END igs_as_pr_val_upld;
END igs_as_adi_upld_pr_pkg;

/
