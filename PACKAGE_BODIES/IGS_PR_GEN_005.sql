--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_005" AS
/* $Header: IGSPR26B.pls 120.0 2005/07/05 12:13:31 appldev noship $ */
  FUNCTION igs_pr_clc_apl_expry (
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_sequence_number          IN     NUMBER,
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_sequence_number              IN     NUMBER
  ) RETURN DATE IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_clc_apl_expry
    -- Calculate the appeal expiry date for a nominated rule within a nominated
    -- progression calendar. This routine also considers whether appeal is
    -- actually permitted ; if not, the date is returned as null
    DECLARE
      cst_ap     CONSTANT VARCHAR2 (2)                              := 'AP';
      v_expiry_dt         DATE;
      v_cutoff_dt         DATE;
      v_level             VARCHAR2 (10);
      v_org_unit_cd       igs_or_unit.org_unit_cd%TYPE;
      v_ou_start_dt       igs_or_unit.start_dt%TYPE;
      v_stream_number     igs_pr_s_prg_cal.stream_num%TYPE;
      v_show_cause_length igs_pr_s_prg_cal.show_cause_length%TYPE;
      v_appeal_length     igs_pr_s_prg_cal.appeal_length%TYPE;
    BEGIN
      IF igs_pr_gen_005.igs_pr_get_appeal_alwd (
           p_progression_rule_cat,
           p_pra_sequence_number,
           p_sequence_number,
           p_course_cd,
           p_version_number
         ) = 'N' THEN
        RETURN NULL;
      END IF;
      igs_pr_gen_003.igs_pr_get_cal_parm (
        p_course_cd,
        p_version_number,
        p_prg_cal_type,
        v_level,
        v_org_unit_cd,
        v_ou_start_dt,
        v_stream_number,
        v_show_cause_length,
        v_appeal_length
      );
      IF v_level IS NULL THEN
        RETURN NULL;
      ELSE
        v_expiry_dt := TRUNC (SYSDATE) + NVL (v_appeal_length, 0);
        v_cutoff_dt := igs_pr_gen_005.igs_pr_get_prg_dai (
                         p_course_cd,
                         p_version_number,
                         p_prg_cal_type,
                         p_prg_sequence_number,
                         cst_ap
                       );
        IF  v_cutoff_dt IS NOT NULL
            AND v_expiry_dt > v_cutoff_dt THEN
          IF v_cutoff_dt < SYSDATE THEN
            v_expiry_dt := TRUNC (SYSDATE);
          ELSE
            v_expiry_dt := TRUNC (v_cutoff_dt);
          END IF;
        END IF;
      END IF;
      RETURN v_expiry_dt;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_CLC_APL_EXPRY');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_clc_apl_expry;

  FUNCTION igs_pr_clc_cause_expry (
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_sequence_number          IN     NUMBER,
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_sequence_number              IN     NUMBER
  ) RETURN DATE IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_clc_cause_expiry
    -- Calculate the show case expiry date for a nominated  rule within a
    -- nominated progression calender. This routine also considers whether
    -- show case is actually permitted; if not, the date is returned as null.
    DECLARE
      cst_sc     CONSTANT VARCHAR2 (10)                             := 'SC';
      v_level             VARCHAR2 (10);
      v_org_unit_cd       igs_or_unit.org_unit_cd%TYPE;
      v_ou_start_dt       igs_or_unit.start_dt%TYPE;
      v_stream_number     igs_pr_s_prg_cal.stream_num%TYPE;
      v_show_cause_length igs_pr_s_prg_cal.show_cause_length%TYPE;
      v_appeal_length     igs_pr_s_prg_cal.appeal_length%TYPE;
      v_expiry_dt         DATE;
      v_cutoff_dt         DATE;
    BEGIN
      IF igs_pr_gen_005.igs_pr_get_cause_alwd (
           p_progression_rule_cat,
           p_pra_sequence_number,
           p_sequence_number,
           p_course_cd,
           p_version_number
         ) = 'N' THEN
        RETURN NULL;
      END IF;
      igs_pr_gen_003.igs_pr_get_cal_parm (
        p_course_cd,
        p_version_number,
        p_prg_cal_type,
        v_level,
        v_org_unit_cd,
        v_ou_start_dt,
        v_stream_number,
        v_show_cause_length,
        v_appeal_length
      );
      IF v_level IS NULL THEN
        -- Could not determine from configuration structure
        RETURN NULL;
      ELSE
        v_expiry_dt := TRUNC (SYSDATE) + NVL (v_show_cause_length, 0);
        v_cutoff_dt := igs_pr_gen_005.igs_pr_get_prg_dai (
                         p_course_cd,
                         p_version_number,
                         p_prg_cal_type,
                         p_prg_sequence_number,
                         cst_sc
                       );
        IF  v_cutoff_dt IS NOT NULL
            AND v_expiry_dt > v_cutoff_dt THEN
          IF v_cutoff_dt < SYSDATE THEN
            v_expiry_dt := TRUNC (SYSDATE);
          ELSE
            v_expiry_dt := v_cutoff_dt;
          END IF;
        END IF;
      END IF;
      RETURN v_expiry_dt;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_CLC_CAUSE_EXPRY');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_clc_cause_expry;

  FUNCTION igs_pr_clc_stdnt_comp (
    p_person_id                    IN     NUMBER,
    p_sca_course_cd                IN     VARCHAR2,
    p_sca_version_number           IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_unit_set_cd                  IN     VARCHAR2,
    p_us_version_number                   NUMBER,
    p_cst_sequence_number          IN     NUMBER,
    p_predicted_ind                IN     VARCHAR2 DEFAULT 'N',
    p_s_rule_call_cd               IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_evaluate_ind                 IN     VARCHAR2 DEFAULT 'N',
    p_log_dt                       OUT NOCOPY DATE,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_clc_stdnt_comp
    -- This routine is used by the functionality associated with the form PRGF9030
    -- Inquire On Student Completion. The form displays the completion rules
    -- associated with a course. This routine is called to evaluate the completion
    -- rules for a student's course attempt. It can be at different levels,
    -- eg. course, course stage, unit set or alternative exit. This routine will
    -- call the appropriate routine in the rules sub-system which will return the
    -- result of the evaulation in a text field. This routine will pass the text
    -- fields to genp_ins_ssp_cmp_dtl which will break up the text fields and
    -- store them into a temporary table where the data will be queried and
    -- displayed by the form.The evaluation parameter will allow for the display
    -- of the appropriate rules without the need to wait for the evaluation.
    DECLARE
      v_rule_text           igs_ru_named_rule.rule_text%TYPE;
      v_message_text        igs_ru_named_rule.rule_text%TYPE;
      v_rule_status         VARCHAR2 (50);
      v_ssp_sequence_number igs_pr_s_scratch_pad.sequence_number%TYPE;
      v_course_cd           igs_en_stdnt_ps_att.course_cd%TYPE;
      v_version_number      igs_en_stdnt_ps_att.version_number%TYPE;
      CURSOR c_cvr IS
        SELECT igs_ru_gen_003.rulp_get_rule (rul_sequence_number)
        FROM   igs_ps_ver_ru
        WHERE  course_cd = v_course_cd
        AND    version_number = v_version_number
        AND    s_rule_call_cd = p_s_rule_call_cd;
      CURSOR c_csr IS
        SELECT igs_ru_gen_003.rulp_get_rule (rul_sequence_number)
        FROM   igs_ps_stage_ru
        WHERE  course_cd = v_course_cd
        AND    version_number = v_version_number
        AND    cst_sequence_number = p_cst_sequence_number
        AND    s_rule_call_cd = p_s_rule_call_cd;
      CURSOR c_usr IS
        SELECT igs_ru_gen_003.rulp_get_rule (rul_sequence_number)
        FROM   igs_en_unit_set_rule
        WHERE  unit_set_cd = p_unit_set_cd
        AND    version_number = p_us_version_number
        AND    s_rule_call_cd = p_s_rule_call_cd;
    BEGIN
      -- Set the default message name
      p_message_name := NULL;
      --
      -- kdande; 31-Dec-2003; Bug# 3213317;
      -- Removed the TRUNC for the SYSDATE; Removed the call to delete stmt
      --
      p_log_dt := SYSDATE;
      v_course_cd := p_course_cd;
      v_version_number := p_version_number;
      IF p_course_cd IS NULL THEN
        v_course_cd := p_sca_course_cd;
      END IF;
      IF p_version_number IS NULL THEN
        v_version_number := p_sca_version_number;
      END IF;
      v_rule_status := NULL;
      v_message_text := NULL;
      IF p_s_rule_call_cd = 'CRS-COMP' THEN
        OPEN c_cvr;
        FETCH c_cvr INTO v_rule_text;
        IF c_cvr%NOTFOUND THEN
          CLOSE c_cvr;
          p_message_name := 'IGS_PR_NO_RU_EXT';
          RETURN FALSE;
        END IF;
        CLOSE c_cvr;
        IF p_evaluate_ind = 'Y' THEN
          IF igs_ru_gen_005.rulp_val_sca_comp (
               p_person_id,
               p_sca_course_cd,
               p_sca_version_number,
               v_course_cd,
               v_version_number,
               p_predicted_ind,
               v_message_text
             ) THEN
            -- Determine if the course completion or alternative exit functionality
            -- is being called.
            IF  p_sca_course_cd = v_course_cd
                AND p_sca_version_number = v_version_number THEN
              -- Calling course completion
              IF p_predicted_ind = 'N' THEN
                v_rule_status := 'COURSE COMPLETION RULES SATISFIED|';
              ELSE
                v_rule_status := 'CAN COMPLETE COURSE|';
              END IF;
            ELSE
              -- Calling alternative exit completion
              IF p_predicted_ind = 'N' THEN
                v_rule_status := 'ALTERNATIVE EXIT COMPLETION RULES SATISFIED|';
              ELSE
                v_rule_status := 'CAN COMPLETE ALTERNATIVE EXIT|';
              END IF;
            END IF;
          ELSE
            -- Determine if the course completion or alternative exit functionality
            -- is being called.
            IF  p_sca_course_cd = v_course_cd
                AND p_sca_version_number = v_version_number THEN
              -- Calling course completion
              IF p_predicted_ind = 'N' THEN
                v_rule_status := 'COURSE COMPLETION RULES NOT SATISFIED|';
              ELSE
                v_rule_status := 'CANNOT COMPLETE COURSE|';
              END IF;
            ELSE
              -- Calling alternative exit completion
              IF p_predicted_ind = 'N' THEN
                v_rule_status := 'ALTERNATIVE EXIT COMPLETION RULES NOT SATISFIED|';
              ELSE
                v_rule_status := 'CANNOT COMPLETE ALTERNATIVE EXIT|';
              END IF;
            END IF;
          END IF;
        END IF;
      ELSIF p_s_rule_call_cd = 'STG-COMP' THEN
        OPEN c_csr;
        FETCH c_csr INTO v_rule_text;
        IF c_csr%NOTFOUND THEN
          CLOSE c_csr;
          p_message_name := 'IGS_PR_NO_RU_EXT';
          RETURN FALSE;
        END IF;
        CLOSE c_csr;
        IF p_evaluate_ind = 'Y' THEN
          IF igs_ru_gen_005.rulp_val_stg_comp (
               p_person_id,
               p_sca_course_cd,
               p_sca_version_number,
               v_course_cd,
               v_version_number,
               p_cst_sequence_number,
               p_predicted_ind,
               v_message_text
             ) THEN
            IF p_predicted_ind = 'N' THEN
              v_rule_status := 'COURSE STAGE COMPLETION RULES SATISFIED|';
            ELSE
              v_rule_status := 'CAN COMPLETE STAGE|';
            END IF;
          ELSE
            IF p_predicted_ind = 'N' THEN
              v_rule_status := 'COURSE STAGE COMPLETION RULES NOT SATISFIED|';
            ELSE
              v_rule_status := 'CANNOT COMPLETE STAGE|';
            END IF;
          END IF;
        END IF;
      ELSIF p_s_rule_call_cd = 'US-COMP' THEN
        OPEN c_usr;
        FETCH c_usr INTO v_rule_text;
        IF c_usr%NOTFOUND THEN
          CLOSE c_usr;
          p_message_name := 'IGS_PR_NO_RU_EXT';
          RETURN FALSE;
        END IF;
        CLOSE c_usr;
        IF p_evaluate_ind = 'Y' THEN
          IF igs_ru_gen_005.rulp_val_susa_comp (
               p_person_id,
               p_sca_course_cd,
               p_sca_version_number,
               v_course_cd,
               v_version_number,
               p_unit_set_cd,
               p_us_version_number,
               p_predicted_ind,
               v_message_text
             ) THEN
            IF p_predicted_ind = 'N' THEN
              v_rule_status := 'UNIT SET COMPLETION RULES SATISFIED|';
            ELSE
              v_rule_status := 'CAN COMPLETE UNIT SET|';
            END IF;
          ELSE
            IF p_predicted_ind = 'N' THEN
              v_rule_status := 'UNIT SET COMPLETION RULES NOT SATISFIED|';
            ELSE
              v_rule_status := 'CANNOT COMPLETE UNIT SET|';
            END IF;
          END IF;
        END IF;
      END IF;
      --Insert the status of the rule into the temporary table (s_scratch_pad).
      -- Note: the status will be null if p_evaluate_ind = 'N'
      igs_pr_gen_003.igs_pr_ins_ssp (
        p_log_dt,
        p_key || '|' || p_s_rule_call_cd || '|RULE_STATUS',
        NULL,
        v_rule_status,
        v_ssp_sequence_number
      );
      --Insert the result of the evaluation of the rules.
      --Note: the v_message_text will be null if p_evaluate_ind = 'N'
      IF igs_pr_gen_006.igs_pr_ins_ssp_cmp_dtl (
           v_rule_text,
           v_message_text,
           p_log_dt,
           p_key || '|' || p_s_rule_call_cd || '|DETAIL',
           p_message_name
         ) = FALSE THEN
        RETURN FALSE;
      END IF;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_cvr%ISOPEN THEN
          CLOSE c_cvr;
        END IF;
        IF c_csr%ISOPEN THEN
          CLOSE c_csr;
        END IF;
        IF c_usr%ISOPEN THEN
          CLOSE c_usr;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_CLC_STDNT_COMP');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_clc_stdnt_comp;

  FUNCTION igs_pr_get_appeal_alwd (
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_sequence_number              IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_appeal_alwd
    -- Determine whether an appeal is permitted on a nominated outcome.
    DECLARE
      v_override_appeal_ind        igs_pr_ru_ou.override_appeal_ind%TYPE;
      v_apply_start_dt_alias       igs_pr_s_prg_conf.apply_start_dt_alias%TYPE;
      v_apply_end_dt_alias         igs_pr_s_prg_conf.apply_end_dt_alias%TYPE;
      v_end_benefit_dt_alias       igs_pr_s_prg_conf.end_benefit_dt_alias%TYPE;
      v_end_penalty_dt_alias       igs_pr_s_prg_conf.end_penalty_dt_alias%TYPE;
      v_show_cause_cutoff_dt_alias igs_pr_s_prg_conf.show_cause_cutoff_dt_alias%TYPE;
      v_appeal_cutoff_dt_alias     igs_pr_s_prg_conf.appeal_cutoff_dt_alias%TYPE;
      v_show_cause_ind             igs_pr_s_prg_conf.show_cause_ind%TYPE;
      v_apply_before_show_ind      igs_pr_s_prg_conf.apply_before_show_ind%TYPE;
      v_appeal_ind                 igs_pr_s_prg_conf.appeal_ind%TYPE;
      v_apply_before_appeal_ind    igs_pr_s_prg_conf.apply_before_appeal_ind%TYPE;
      v_count_sus_in_time_ind      igs_pr_s_prg_conf.count_sus_in_time_ind%TYPE;
      v_count_exc_in_time_ind      igs_pr_s_prg_conf.count_exc_in_time_ind%TYPE;
      v_calculate_wam_ind          igs_pr_s_prg_conf.calculate_wam_ind%TYPE;
      v_calculate_gpa_ind          igs_pr_s_prg_conf.calculate_gpa_ind%TYPE;
      v_outcome_check_type         igs_pr_s_prg_conf.outcome_check_type%TYPE;
      CURSOR c_pro IS
        SELECT pro.override_appeal_ind
        FROM   igs_pr_rule_out_v pro
        WHERE  pro.progression_rule_cat = p_progression_rule_cat
        AND    pro.pra_sequence_number = p_pra_sequence_number
        AND    pro.sequence_number = p_sequence_number;
    BEGIN
      IF p_progression_rule_cat IS NOT NULL THEN
        OPEN c_pro;
        FETCH c_pro INTO v_override_appeal_ind;
        IF c_pro%FOUND THEN
          CLOSE c_pro;
          IF v_override_appeal_ind IS NOT NULL THEN
            RETURN v_override_appeal_ind;
          END IF;
        ELSE
          CLOSE c_pro;
        END IF;
      END IF;
      igs_pr_gen_003.igs_pr_get_config_parm (
        p_course_cd,
        p_version_number,
        v_apply_start_dt_alias,
        v_apply_end_dt_alias,
        v_end_benefit_dt_alias,
        v_end_penalty_dt_alias,
        v_show_cause_cutoff_dt_alias,
        v_appeal_cutoff_dt_alias,
        v_show_cause_ind,
        v_apply_before_show_ind,
        v_appeal_ind,
        v_apply_before_appeal_ind,
        v_count_sus_in_time_ind,
        v_count_exc_in_time_ind,
        v_calculate_wam_ind,
        v_calculate_gpa_ind,
        v_outcome_check_type
      );
      RETURN v_appeal_ind;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_pro%ISOPEN THEN
          CLOSE c_pro;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_APPEAL_ALWD');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_appeal_alwd;

  FUNCTION igs_pr_get_cause_alwd (
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_sequence_number              IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_cause_alwd
    -- Determine whether a show cause is permitted on a nominated outcome.
    DECLARE
      v_override_show_cause_ind    igs_pr_ru_ou.override_show_cause_ind%TYPE;
      v_apply_start_dt_alias       igs_pr_s_prg_conf.apply_start_dt_alias%TYPE;
      v_apply_end_dt_alias         igs_pr_s_prg_conf.apply_end_dt_alias%TYPE;
      v_end_benefit_dt_alias       igs_pr_s_prg_conf.end_benefit_dt_alias%TYPE;
      v_end_penalty_dt_alias       igs_pr_s_prg_conf.end_penalty_dt_alias%TYPE;
      v_show_cause_cutoff_dt_alias igs_pr_s_prg_conf.show_cause_cutoff_dt_alias%TYPE;
      v_appeal_cutoff_dt_alias     igs_pr_s_prg_conf.appeal_cutoff_dt_alias%TYPE;
      v_show_cause_ind             igs_pr_s_prg_conf.show_cause_ind%TYPE;
      v_apply_before_show_ind      igs_pr_s_prg_conf.apply_before_show_ind%TYPE;
      v_appeal_ind                 igs_pr_s_prg_conf.appeal_ind%TYPE;
      v_apply_before_appeal_ind    igs_pr_s_prg_conf.apply_before_appeal_ind%TYPE;
      v_count_sus_in_time_ind      igs_pr_s_prg_conf.count_sus_in_time_ind%TYPE;
      v_count_exc_in_time_ind      igs_pr_s_prg_conf.count_exc_in_time_ind%TYPE;
      v_calculate_wam_ind          igs_pr_s_prg_conf.calculate_wam_ind%TYPE;
      v_calculate_gpa_ind          igs_pr_s_prg_conf.calculate_gpa_ind%TYPE;
      v_outcome_check_type         igs_pr_s_prg_conf.outcome_check_type%TYPE;
      CURSOR c_pro IS
        SELECT pro.override_show_cause_ind
        FROM   igs_pr_rule_out_v pro
        WHERE  pro.progression_rule_cat = p_progression_rule_cat
        AND    pro.pra_sequence_number = p_pra_sequence_number
        AND    pro.sequence_number = p_sequence_number;
    BEGIN
      IF p_progression_rule_cat IS NOT NULL THEN
        OPEN c_pro;
        FETCH c_pro INTO v_override_show_cause_ind;
        IF c_pro%FOUND THEN
          CLOSE c_pro;
          IF v_override_show_cause_ind IS NOT NULL THEN
            RETURN v_override_show_cause_ind;
          END IF;
        ELSE
          CLOSE c_pro;
        END IF;
      END IF;
      igs_pr_gen_003.igs_pr_get_config_parm (
        p_course_cd,
        p_version_number,
        v_apply_start_dt_alias,
        v_apply_end_dt_alias,
        v_end_benefit_dt_alias,
        v_end_penalty_dt_alias,
        v_show_cause_cutoff_dt_alias,
        v_appeal_cutoff_dt_alias,
        v_show_cause_ind,
        v_apply_before_show_ind,
        v_appeal_ind,
        v_apply_before_appeal_ind,
        v_count_sus_in_time_ind,
        v_count_exc_in_time_ind,
        v_calculate_wam_ind,
        v_calculate_gpa_ind,
        v_outcome_check_type
      );
      RETURN v_show_cause_ind;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_pro%ISOPEN THEN
          CLOSE c_pro;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_CAUSE_ALWD');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_cause_alwd;

  FUNCTION igs_pr_get_num_fail (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_sequence_number          IN     NUMBER,
    p_prg_rule_repeat_fail_type    IN     VARCHAR2
  ) RETURN NUMBER IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_num_fail
    -- Get the number of failures of a nominated rule application by a student ;
    -- handles both repeat failures and consecutive-repeat failures.
    -- Note: This routine assumes that the latest failure of the rule has been
    -- stored on the database ; it is expecting to find the failure when
    -- calculating the number of fails.
    DECLARE
      cst_consecrpt CONSTANT VARCHAR2 (10)                         := 'CONSECRPT';
      v_number_of_failures   NUMBER                                DEFAULT 0;
      v_passed_ind           igs_pr_sdt_pr_ru_ck.passed_ind%TYPE;

      CURSOR c_spc IS
        SELECT DISTINCT spc.prg_cal_type,
                        spc.prg_ci_sequence_number,
                        ci1.start_dt
        FROM            igs_pr_stdnt_pr_ck spc,
                        igs_ca_inst ci1
        WHERE           spc.person_id = p_person_id
        AND             spc.course_cd = p_course_cd
        AND             igs_pr_gen_001.prgp_get_cal_stream (
                          p_course_cd,
                          p_version_number,
                          p_prg_cal_type,
                          spc.prg_cal_type
                        ) = 'Y'
        AND             ci1.cal_type = spc.prg_cal_type
        AND             ci1.sequence_number = spc.prg_ci_sequence_number
        AND             ci1.start_dt <= (SELECT ci2.start_dt
                                         FROM   igs_ca_inst ci2
                                         WHERE  ci2.cal_type = p_prg_cal_type
                                         AND    ci2.sequence_number = p_prg_sequence_number)
        ORDER BY        ci1.start_dt DESC;
      CURSOR c_sprc (
        cp_prg_cal_type                       igs_pr_sdt_pr_ru_ck.prg_cal_type%TYPE,
        cp_prg_ci_sequence_number             igs_pr_sdt_pr_ru_ck.prg_ci_sequence_number%TYPE
      ) IS
        SELECT   sprc.passed_ind
        FROM     igs_pr_sdt_pr_ru_ck sprc
        WHERE    sprc.person_id = p_person_id
        AND      sprc.course_cd = p_course_cd
        AND      sprc.prg_cal_type = cp_prg_cal_type
        AND      sprc.prg_ci_sequence_number = cp_prg_ci_sequence_number
        AND      sprc.progression_rule_cat = p_progression_rule_cat
        AND      sprc.pra_sequence_number = p_pra_sequence_number
        ORDER BY sprc.rule_check_dt DESC;
    BEGIN
      -- If repeat type then retrieve the number of failures from previous checks
      -- within the same calendar stream. Only consider the latest check of the
      -- applicable rule within each progression calendar.
      FOR v_spc_rec IN c_spc LOOP
        OPEN c_sprc (v_spc_rec.prg_cal_type, v_spc_rec.prg_ci_sequence_number);
        FETCH c_sprc INTO v_passed_ind;
        IF c_sprc%FOUND THEN
          CLOSE c_sprc;
          IF v_passed_ind = 'N' THEN
            v_number_of_failures := v_number_of_failures + 1;
          ELSIF p_prg_rule_repeat_fail_type = cst_consecrpt THEN
            -- Once a gap is found the consecutive period ends
            EXIT;
          END IF;
        ELSE
          CLOSE c_sprc;
        END IF;
      END LOOP;
      RETURN v_number_of_failures;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_spc%ISOPEN THEN
          CLOSE c_spc;
        END IF;
        IF c_sprc%ISOPEN THEN
          CLOSE c_sprc;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_NUM_FAIL');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_num_fail;

  FUNCTION igs_pr_get_prg_dai (
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_sequence_number          IN     NUMBER,
    p_alias_type                   IN     VARCHAR2
  ) RETURN DATE IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_prg_dai
    -- get the appropriate date alias value applicable to a nominated course
    -- version / calendar instance
    -- routine refers to the progression configuration structure to get the date
    -- alias to use and then queries for it
    DECLARE
      cst_sa              CONSTANT VARCHAR2 (2)                                        := 'SA';
      cst_ea              CONSTANT VARCHAR2 (2)                                        := 'EA';
      cst_sc              CONSTANT VARCHAR2 (2)                                        := 'SC';
      cst_ap              CONSTANT VARCHAR2 (2)                                        := 'AP';
      cst_eb              CONSTANT VARCHAR2 (2)                                        := 'EB';
      cst_ep              CONSTANT VARCHAR2 (2)                                        := 'EP';
      v_dt_alias                   VARCHAR2 (10);
      v_alias_val                  DATE;
      v_apply_start_dt_alias       igs_pr_s_prg_conf.apply_start_dt_alias%TYPE;
      v_apply_end_dt_alias         igs_pr_s_prg_conf.apply_end_dt_alias%TYPE;
      v_end_benefit_dt_alias       igs_pr_s_prg_conf.end_benefit_dt_alias%TYPE;
      v_end_penalty_dt_alias       igs_pr_s_prg_conf.end_penalty_dt_alias%TYPE;
      v_show_cause_cutoff_dt_alias igs_pr_s_prg_conf.show_cause_cutoff_dt_alias%TYPE;
      v_appeal_cutoff_dt_alias     igs_pr_s_prg_conf.appeal_cutoff_dt_alias%TYPE;
      v_show_cause_ind             igs_pr_s_prg_conf.show_cause_ind%TYPE;
      v_apply_before_show_ind      igs_pr_s_prg_conf.apply_before_show_ind%TYPE;
      v_appeal_ind                 igs_pr_s_prg_conf.appeal_ind%TYPE;
      v_apply_before_appeal_ind    igs_pr_s_prg_conf.apply_before_appeal_ind%TYPE;
      v_count_sus_in_time_ind      igs_pr_s_prg_conf.count_sus_in_time_ind%TYPE;
      v_count_exc_in_time_ind      igs_pr_s_prg_conf.count_exc_in_time_ind%TYPE;
      v_calculate_wam_ind          igs_pr_s_prg_conf.calculate_wam_ind%TYPE;
      v_calculate_gpa_ind          igs_pr_s_prg_conf.calculate_gpa_ind%TYPE;
      v_outcome_check_type         igs_pr_s_prg_conf.outcome_check_type%TYPE;
      CURSOR c_dai (cp_dt_alias VARCHAR2) IS
        SELECT   igs_ca_gen_001.calp_get_alias_val (
                   dai.dt_alias,
                   dai.sequence_number,
                   dai.cal_type,
                   dai.ci_sequence_number
                 )
        FROM     igs_ca_da_inst dai
        WHERE    dai.cal_type = p_prg_cal_type
        AND      dai.ci_sequence_number = p_prg_sequence_number
        AND      dai.dt_alias = cp_dt_alias
        ORDER BY 1;
    BEGIN
      igs_pr_gen_003.igs_pr_get_config_parm (
        p_course_cd,
        p_version_number,
        v_apply_start_dt_alias,
        v_apply_end_dt_alias,
        v_end_benefit_dt_alias,
        v_end_penalty_dt_alias,
        v_show_cause_cutoff_dt_alias,
        v_appeal_cutoff_dt_alias,
        v_show_cause_ind,
        v_apply_before_show_ind,
        v_appeal_ind,
        v_apply_before_appeal_ind,
        v_count_sus_in_time_ind,
        v_count_exc_in_time_ind,
        v_calculate_wam_ind,
        v_calculate_gpa_ind,
        v_outcome_check_type
      );
      IF p_alias_type = cst_sa THEN
        v_dt_alias := v_apply_start_dt_alias;
      ELSIF p_alias_type = cst_ea THEN
        v_dt_alias := v_apply_end_dt_alias;
      ELSIF p_alias_type = cst_sc THEN
        v_dt_alias := v_show_cause_cutoff_dt_alias;
      ELSIF p_alias_type = cst_ap THEN
        v_dt_alias := v_appeal_cutoff_dt_alias;
      ELSIF p_alias_type = cst_eb THEN
        v_dt_alias := v_end_benefit_dt_alias;
      ELSIF p_alias_type = cst_ep THEN
        v_dt_alias := v_end_penalty_dt_alias;
      END IF;
      OPEN c_dai (v_dt_alias);
      FETCH c_dai INTO v_alias_val;
      IF c_dai%NOTFOUND THEN
        CLOSE c_dai;
        RETURN NULL;
      ELSE
        CLOSE c_dai;
        RETURN v_alias_val;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_dai%ISOPEN THEN
          CLOSE c_dai;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_DAI');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_prg_dai;

  FUNCTION igs_pr_get_prg_pen_end (
    p_prg_cal_type IN VARCHAR2,
    p_prg_sequence_number IN NUMBER
  ) RETURN DATE IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_prg_pen_end
    -- Get the encumbrance end date of the nominated progression period.
    -- This is retrieved from the IGS_CA_DA_INST table matching the value
    -- stored in the progression configuration table. If no date alias is found,
    -- then the end date of the progression period is returned.
    DECLARE
      v_alias_val DATE;
      v_end_dt    DATE;
      CURSOR c_dai_spc IS
        SELECT   NVL (
                   dai.absolute_val,
                   igs_ca_gen_001.calp_get_alias_val (
                     dai.dt_alias,
                     dai.sequence_number,
                     dai.cal_type,
                     dai.ci_sequence_number
                   )
                 )
        FROM     igs_ca_da_inst dai,
                 igs_pr_s_prg_conf spc
        WHERE    dai.cal_type = p_prg_cal_type
        AND      dai.ci_sequence_number = p_prg_sequence_number
        AND      dai.dt_alias = spc.encumb_end_dt_alias
        ORDER BY 1 DESC;
      CURSOR c_ci IS
        SELECT ci.end_dt
        FROM   igs_ca_inst ci
        WHERE  ci.cal_type = p_prg_cal_type
        AND    ci.sequence_number = p_prg_sequence_number;
    BEGIN
      OPEN c_dai_spc;
      FETCH c_dai_spc INTO v_alias_val;
      IF c_dai_spc%NOTFOUND THEN
        CLOSE c_dai_spc;
        OPEN c_ci;
        FETCH c_ci INTO v_end_dt;
        CLOSE c_ci;
        RETURN v_end_dt;
      ELSE
        CLOSE c_dai_spc;
        RETURN v_alias_val;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_dai_spc%ISOPEN THEN
          CLOSE c_dai_spc;
        END IF;
        IF c_ci%ISOPEN THEN
          CLOSE c_ci;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_PEN_END');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_prg_pen_end;

  FUNCTION igs_pr_get_prg_status (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_ci_sequence_number       IN     NUMBER
  )
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    -- Derive the progression status for a nominated student course attempt,
    -- being one of :
    -- UNDCONSID  Under Consideration ; Outcomes are currently pending awaiting
    --    approval / waiving.
    -- SHOWCAUSE  Show Cause ; Student is still within the applicable show cause
    --    period, or has shown cause an no outcome has yet been entered.
    -- PROBATION  Probation ; Student is currently has a probation outcome
    --    applicable.
    -- SUSPENSION Suspension ; Student is currently suspended as the result of a
    --    progression breach.
    -- EXCLUSION  Exclusion ; Student is currently excluded as the result of a
    --    progression breach.
    -- EXPULSION  Expulsion ; Student has been expelled as the result of a
    --    progression breach.
    DECLARE
      cst_approved    CONSTANT VARCHAR2 (10)                      := 'APPROVED';
      cst_pending     CONSTANT VARCHAR2 (10)                      := 'PENDING';
      cst_showcause   CONSTANT VARCHAR2 (10)                      := 'SHOWCAUSE';
      cst_expulsion   CONSTANT VARCHAR2 (10)                      := 'EXPULSION';
      cst_exclusion   CONSTANT VARCHAR2 (10)                      := 'EXCLUSION';
      cst_suspension  CONSTANT VARCHAR2 (10)                      := 'SUSPENSION';
      cst_probation   CONSTANT VARCHAR2 (10)                      := 'PROBATION';
      cst_undconsid   CONSTANT VARCHAR2 (10)                      := 'UNDCONSID';
      cst_goodstand   CONSTANT VARCHAR2 (10)                      := 'GOODSTAND';
      v_show_cause             BOOLEAN                            DEFAULT FALSE;
      v_expulsion              BOOLEAN                            DEFAULT FALSE;
      v_exclusion              BOOLEAN                            DEFAULT FALSE;
      v_suspension             BOOLEAN                            DEFAULT FALSE;
      v_probation              BOOLEAN                            DEFAULT FALSE;
      v_pending                BOOLEAN                            DEFAULT FALSE;
      v_latest_cal_type        igs_ca_inst.cal_type%TYPE;
      v_latest_sequence_number igs_ca_inst.sequence_number%TYPE;
      CURSOR c_spo_ci IS
        SELECT   spo.prg_cal_type,
                 spo.prg_ci_sequence_number
        FROM     igs_pr_stdnt_pr_ou spo,
                 igs_ca_inst ci,
                 igs_pr_ou_type pot
        WHERE    spo.person_id = p_person_id
        AND      spo.course_cd = p_course_cd
        AND      spo.decision_status IN (cst_approved, cst_pending)
        AND      ci.cal_type = spo.prg_cal_type
        AND      ci.sequence_number = spo.prg_ci_sequence_number
        AND      ((p_prg_cal_type IS NOT NULL
                   AND p_prg_ci_sequence_number IS NOT NULL
                   AND p_prg_cal_type = spo.prg_cal_type
                   AND p_prg_ci_sequence_number = spo.prg_ci_sequence_number
                  )
                  OR (p_prg_cal_type IS NULL
                      OR p_prg_ci_sequence_number IS NULL
                     )
                 )
        AND      spo.progression_outcome_type = pot.progression_outcome_type
        AND      pot.positive_outcome_ind = 'N'
        ORDER BY ci.start_dt DESC;
      CURSOR c_spo (
        cp_latest_cal_type                    igs_ca_inst.cal_type%TYPE,
        cp_latest_sequence_number             igs_ca_inst.sequence_number%TYPE
      ) IS
        SELECT spo.course_cd,
               spo.sequence_number,
               spo.progression_outcome_type,
               spo.decision_status,
               spo.show_cause_expiry_dt,
               spo.show_cause_dt,
               spo.show_cause_outcome_dt,
               spo.encmb_course_group_cd
        FROM   igs_pr_stdnt_pr_ou spo
        WHERE  spo.person_id = p_person_id
        AND    spo.course_cd = p_course_cd
        AND    spo.decision_status IN (cst_approved, cst_pending)
        AND    spo.prg_cal_type = cp_latest_cal_type
        AND    spo.prg_ci_sequence_number = cp_latest_sequence_number
        AND    igs_pr_gen_006.igs_pr_get_spo_expiry (
                 spo.person_id,
                 spo.course_cd,
                 spo.sequence_number,
                 spo.expiry_dt) <> 'EXPIRED';
      FUNCTION prgpl_course_match (
        pl_spo_course_cd                      igs_pr_stdnt_pr_ou.course_cd%TYPE,
        pl_spo_sequence_number                igs_pr_stdnt_pr_ou.sequence_number%TYPE
      ) RETURN BOOLEAN IS
        gvl_other_detail VARCHAR2 (255);
      BEGIN -- prgpl_course_match
        DECLARE
          v_dummy          VARCHAR2 (1);
          CURSOR c_spc IS
            SELECT 'X'
            FROM   igs_pr_stdnt_pr_ps spc
            WHERE  spc.person_id = p_person_id
            AND    spc.spo_course_cd = pl_spo_course_cd
            AND    spc.spo_sequence_number = pl_spo_sequence_number
            AND    spc.course_cd = p_course_cd;
          CURSOR c_person (cp_party_id NUMBER) IS
            SELECT party_number
            FROM   hz_parties
            WHERE  party_id = cp_party_id;
          lv_person_number hz_parties.party_number%TYPE;
        BEGIN
          OPEN c_spc;
          FETCH c_spc INTO v_dummy;
          IF c_spc%FOUND THEN
            CLOSE c_spc;
            RETURN TRUE;
          ELSIF c_spc%NOTFOUND THEN
            CLOSE c_spc;
            OPEN c_person (p_person_id);
            FETCH c_person INTO lv_person_number;
            CLOSE c_person;
            fnd_file.put_line (
              fnd_file.LOG,
                 'There is no  Excluded Courses given for the Person := '
              || lv_person_number
              || 'Course code := '
              || p_course_cd
              || 'Skipping the record .. '
            );
            RETURN FALSE;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            IF c_spc%ISOPEN THEN
              CLOSE c_spc;
            END IF;
            RAISE;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_STATUS.PRGPL_COURSE_MATCH');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
      END prgpl_course_match;

      FUNCTION prgpl_course_group_match (
        pl_encmb_course_group_cd igs_pr_stdnt_pr_ou.encmb_course_group_cd%TYPE
      ) RETURN BOOLEAN IS
        gvl_other_detail VARCHAR2 (255);
      BEGIN -- prgpl_course_group_match
        DECLARE
          v_dummy          VARCHAR2 (1);
          CURSOR c_cgm IS
            SELECT 'X'
            FROM   igs_ps_grp_mbr cgm
            WHERE  cgm.course_cd = p_course_cd
            AND    cgm.version_number = p_version_number
            AND    course_group_cd = pl_encmb_course_group_cd;
          CURSOR c_person (cp_party_id NUMBER) IS
            SELECT party_number
            FROM   hz_parties
            WHERE  party_id = cp_party_id;
          lv_person_number hz_parties.party_number%TYPE;
        BEGIN
          IF pl_encmb_course_group_cd IS NOT NULL THEN
            OPEN c_cgm;
            FETCH c_cgm INTO v_dummy;
            IF c_cgm%FOUND THEN
              CLOSE c_cgm;
              RETURN TRUE;
            ELSIF c_cgm%NOTFOUND THEN
              CLOSE c_cgm;
              OPEN c_person (p_person_id);
              FETCH c_person INTO lv_person_number;
              CLOSE c_person;
              fnd_file.put_line (
                fnd_file.LOG,
                   'There is no matching course group defined for Person :='
                || lv_person_number
                || 'Course code := '
                || p_course_cd
                || 'Skipping the record .. '
              );
              RETURN FALSE;
            END IF;
          END IF;
          RETURN FALSE;
        EXCEPTION
          WHEN OTHERS THEN
            IF c_cgm%ISOPEN THEN
              CLOSE c_cgm;
            END IF;
            RAISE;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_STATUS.PRGPL_COURSE_GROUP_MATCH');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
      END prgpl_course_group_match;

      PROCEDURE prgpl_determine_outcome_level (
        pl_spo_course_cd                      igs_pr_stdnt_pr_ou.course_cd%TYPE,
        pl_spo_sequence_number                igs_pr_stdnt_pr_ou.sequence_number%TYPE,
        pl_progression_outcome_type           igs_pr_ou_type.progression_outcome_type%TYPE,
        pl_encmb_course_group_cd              igs_pr_stdnt_pr_ou.encmb_course_group_cd%TYPE
      ) IS
        gvl_other_detail VARCHAR2 (255);
      BEGIN -- prgpl_determine_outcome_level
        DECLARE
          cst_exc_course CONSTANT VARCHAR2 (10)                                    := 'EXC_COURSE';
          cst_exc_crs_gp CONSTANT VARCHAR2 (10)                                    := 'EXC_CRS_GP';
          cst_manual     CONSTANT VARCHAR2 (10)                                    := 'MANUAL';
          cst_nopenalty  CONSTANT VARCHAR2 (10)                                    := 'NOPENALTY';
          cst_probation  CONSTANT VARCHAR2 (10)                                    := 'PROBATION';
          cst_expulsion  CONSTANT VARCHAR2 (10)                                    := 'EXPULSION';
          v_s_prg_outcome_type    igs_pr_ou_type.s_progression_outcome_type%TYPE;
          v_encumbrance_type      igs_pr_ou_type.encumbrance_type%TYPE;
          v_dummy                 VARCHAR2 (1);
          CURSOR c_pot IS
            SELECT pot.s_progression_outcome_type,
                   pot.encumbrance_type
            FROM   igs_pr_ou_type pot
            WHERE  pot.progression_outcome_type = pl_progression_outcome_type;
          CURSOR c_etde (cp_encumbrance_type igs_pr_ou_type.encumbrance_type%TYPE) IS
            SELECT 'X'
            FROM   igs_fi_enc_dflt_eft etde
            WHERE  encumbrance_type = cp_encumbrance_type
            AND    s_encmb_effect_type IN (cst_exc_course, cst_exc_crs_gp);
        BEGIN
          OPEN c_pot;
          FETCH c_pot INTO v_s_prg_outcome_type,
                           v_encumbrance_type;
          IF c_pot%FOUND THEN
            CLOSE c_pot;
            IF v_s_prg_outcome_type <> cst_nopenalty THEN
              IF v_s_prg_outcome_type IN (cst_probation, cst_manual) THEN
                v_probation := TRUE;
              ELSIF v_s_prg_outcome_type = cst_expulsion THEN
                IF prgpl_course_group_match (pl_encmb_course_group_cd)
                   OR prgpl_course_match (pl_spo_course_cd, pl_spo_sequence_number) THEN
                  v_expulsion := TRUE;
                END IF;
              ELSIF v_s_prg_outcome_type = cst_suspension THEN
                IF prgpl_course_match (pl_spo_course_cd, pl_spo_sequence_number) THEN
                  v_suspension := TRUE;
                END IF;
              ELSIF v_s_prg_outcome_type = cst_exclusion THEN
                OPEN c_etde (v_encumbrance_type);
                FETCH c_etde INTO v_dummy;
                IF c_etde%FOUND THEN
                  -- Determine if course group or course exclusion apply to
                  -- the students course
                  IF prgpl_course_group_match (pl_encmb_course_group_cd)
                     OR prgpl_course_match (pl_spo_course_cd, pl_spo_sequence_number) THEN
                    v_exclusion := TRUE;
                  END IF;
                END IF;
              END IF;
            END IF;
          ELSE
            CLOSE c_pot;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            IF c_pot%ISOPEN THEN
              CLOSE c_pot;
            END IF;
            IF c_etde%ISOPEN THEN
              CLOSE c_etde;
            END IF;
            RAISE;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_STATUS.PRGPL_DETERMINE_OUTCOME_LEVEL');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
      END prgpl_determine_outcome_level;
    BEGIN -- IGS_PR_get_prg_status
      -- Determine the latest period with pending/active outcomes
      OPEN c_spo_ci;
      FETCH c_spo_ci INTO v_latest_cal_type,
                          v_latest_sequence_number;
      IF c_spo_ci%NOTFOUND THEN
        CLOSE c_spo_ci;
        RETURN cst_goodstand;
      END IF;
      CLOSE c_spo_ci;
      FOR v_spo_rec IN c_spo (v_latest_cal_type, v_latest_sequence_number) LOOP
        IF v_spo_rec.decision_status = cst_pending THEN
          v_pending := TRUE;
        ELSE
          IF (v_spo_rec.show_cause_dt IS NOT NULL
              AND v_spo_rec.show_cause_outcome_dt IS NULL
             )
             OR (v_spo_rec.show_cause_expiry_dt IS NOT NULL
                 AND v_spo_rec.show_cause_expiry_dt > TRUNC (SYSDATE)
                ) THEN
            v_show_cause := TRUE;
          ELSE
            prgpl_determine_outcome_level (
              v_spo_rec.course_cd,
              v_spo_rec.sequence_number,
              v_spo_rec.progression_outcome_type,
              v_spo_rec.encmb_course_group_cd
            );
          END IF;
        END IF;
      END LOOP;
      IF v_show_cause THEN
        RETURN cst_showcause;
      ELSIF v_expulsion THEN
        RETURN cst_expulsion;
      ELSIF v_exclusion THEN
        RETURN cst_exclusion;
      ELSIF v_suspension THEN
        RETURN cst_suspension;
      ELSIF v_probation THEN
        RETURN cst_probation;
      ELSIF v_pending THEN
        RETURN cst_undconsid;
      ELSE
        RETURN cst_goodstand;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_spo_ci%ISOPEN THEN
          CLOSE c_spo_ci;
        END IF;
        IF c_spo%ISOPEN THEN
          CLOSE c_spo;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_PRG_STATUS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_prg_status;

  FUNCTION igs_pr_get_sca_appeal (
    p_person_id IN NUMBER,
    p_course_cd IN VARCHAR2
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_sca_appeal
    -- Get whether student course attempt currently has an appeal in progress
    DECLARE
      cst_approved CONSTANT VARCHAR2 (10) := 'APPROVED';
      v_dummy               VARCHAR2 (1);
      CURSOR c_spo IS
        SELECT 'X'
        FROM   igs_pr_stdnt_pr_ou spo
        WHERE  spo.person_id = p_person_id
        AND    spo.course_cd = p_course_cd
        AND    spo.decision_status = cst_approved
        AND    spo.appeal_dt IS NOT NULL
        AND    spo.appeal_outcome_dt IS NULL;
    BEGIN
      OPEN c_spo;
      FETCH c_spo INTO v_dummy;
      IF c_spo%FOUND THEN
        CLOSE c_spo;
        RETURN 'Y';
      ELSE
        CLOSE c_spo;
        RETURN 'N';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_spo%ISOPEN THEN
          CLOSE c_spo;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_SCA_APPEAL');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_sca_appeal;

  FUNCTION igs_pr_get_sca_appl (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version_number        IN     NUMBER,
    p_course_type                  IN     VARCHAR2,
    p_progression_rule_cat         IN     VARCHAR2,
    p_pra_sequence_number          IN     NUMBER,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_ci_sequence_number       IN     NUMBER,
    p_start_effective_period       IN     NUMBER,
    p_num_of_applications          IN     NUMBER,
    p_pra_s_relation_type          IN     VARCHAR2,
    p_pra_sca_person_id            IN     NUMBER,
    p_pra_sca_course_cd            IN     VARCHAR2,
    p_pra_crv_course_cd            IN     VARCHAR2,
    p_pra_crv_version_number       IN     NUMBER,
    p_pra_ou_org_unit_cd           IN     VARCHAR2,
    p_pra_ou_start_dt              IN     DATE,
    p_pra_course_type              IN     VARCHAR2
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_sca_appl
    -- Get whether a nominated student course attempt rule still applies to a
    -- nominated student course attempt. This routine factors in the
    -- progression_rule_cal_type.start_effective_period, num_of_applications.
    -- Note: this routine assumes that the start/end periods of the
    -- progression_rule_cal_type have already been checked.
    DECLARE
      cst_active    CONSTANT VARCHAR2 (10) := 'ACTIVE';
      cst_progress  CONSTANT VARCHAR2 (10) := 'PROGRESS';
      cst_enrolled  CONSTANT VARCHAR2 (10) := 'ENROLLED';
      cst_completed CONSTANT VARCHAR2 (10) := 'COMPLETED';
      cst_discontin CONSTANT VARCHAR2 (10) := 'DISCONTIN';
      v_count_of_records     INTEGER       DEFAULT 0;
      CURSOR c_sprc IS
        SELECT DISTINCT sprc.prg_cal_type,
                        sprc.prg_ci_sequence_number
        FROM            igs_pr_sdt_pr_ru_ck sprc,
                        igs_ca_inst ci1
        WHERE           sprc.person_id = p_person_id
        AND             sprc.course_cd = p_course_cd
        AND             sprc.progression_rule_cat = p_progression_rule_cat
        AND             sprc.pra_sequence_number = p_pra_sequence_number
        AND             sprc.prg_cal_type = ci1.cal_type
        AND             sprc.prg_ci_sequence_number = ci1.sequence_number
        AND             ci1.start_dt <= --gjha Changed to <= from <
                                       (SELECT ci2.start_dt
                                        FROM   igs_ca_inst ci2
                                        WHERE  ci2.cal_type = p_prg_cal_type
                                        AND    ci2.sequence_number = p_prg_ci_sequence_number);
      CURSOR c_ci_ct_cs IS
        SELECT ci1.cal_type,
               ci1.sequence_number
        FROM   igs_ca_inst ci1,
               igs_ca_type ct,
               igs_ca_stat cs
        WHERE  ct.cal_type = ci1.cal_type
        AND    ct.s_cal_cat = cst_progress
        AND    cs.cal_status = ci1.cal_status
        AND    cs.s_cal_status = cst_active
        AND    ci1.start_dt <= (SELECT ci2.start_dt
                                FROM   igs_ca_inst ci2
                                WHERE  ci2.cal_type = p_prg_cal_type
                                AND    ci2.sequence_number = p_prg_ci_sequence_number)
        AND    (-- Logic from CALP_GET_CAL_STREAM.
                EXISTS ( SELECT 'x'
                         FROM   igs_pr_s_prg_cal spc1,
                                igs_pr_s_prg_cal spc2
                         WHERE  spc1.s_control_num = 1
                         AND    spc2.s_control_num = 1
                         AND    spc1.prg_cal_type = p_prg_cal_type
                         AND    spc2.prg_cal_type = ci1.cal_type
                         AND    spc1.stream_num = spc2.stream_num)
                OR EXISTS ( SELECT 'x'
                            FROM   igs_pr_s_ou_prg_cal sopc1,
                                   igs_pr_s_ou_prg_cal sopc2
                            WHERE  igs_pr_gen_001.prgp_get_crv_cmt (
                                     p_course_cd,
                                     p_course_version_number,
                                     sopc1.org_unit_cd,
                                     sopc1.ou_start_dt
                                   ) = 'Y'
                            AND    sopc1.prg_cal_type = p_prg_cal_type
                            AND    sopc2.org_unit_cd = sopc1.org_unit_cd
                            AND    sopc2.ou_start_dt = sopc1.ou_start_dt
                            AND    sopc2.prg_cal_type = ci1.cal_type
                            AND    sopc1.stream_num = sopc2.stream_num)
                OR EXISTS ( SELECT 'x'
                            FROM   igs_pr_s_crv_prg_cal scpc1,
                                   igs_pr_s_crv_prg_cal scpc2
                            WHERE  scpc1.course_cd = p_course_cd
                            AND    scpc1.version_number = p_course_version_number
                            AND    scpc1.prg_cal_type = p_prg_cal_type
                            AND    scpc2.course_cd = scpc1.course_cd
                            AND    scpc2.version_number = scpc1.version_number
                            AND    scpc2.prg_cal_type = ci1.cal_type
                            AND    scpc1.stream_num = scpc2.stream_num)
               )
AND    EXISTS ( -- Units must exist within the progression calendar.
                       SELECT 'X'
                       FROM   igs_en_su_attempt sua,
                              igs_ca_inst_rel cir
                       WHERE  sua.person_id = p_person_id
                       AND    sua.course_cd = p_course_cd
                       AND    cir.sup_cal_type = ci1.cal_type
                       AND    cir.sup_ci_sequence_number = ci1.sequence_number
                       AND    cir.sub_cal_type = sua.cal_type
                       AND    cir.sub_ci_sequence_number = sua.ci_sequence_number
                       AND    sua.unit_attempt_status IN (cst_enrolled, cst_discontin, cst_completed));
    BEGIN
      -- Ensure that progression rule application matches the appropriate
      -- characteristics of the student being applied.
      IF p_pra_s_relation_type = 'SCA' THEN
        IF p_pra_sca_person_id <> p_person_id
           OR p_pra_sca_course_cd <> p_course_cd THEN
          RETURN 'N';
        END IF;
      ELSIF p_pra_s_relation_type = 'CRV' THEN
        IF p_course_cd <> p_pra_crv_course_cd
           OR p_course_version_number <> p_pra_crv_version_number THEN
          RETURN 'N';
        END IF;
      ELSIF p_pra_s_relation_type = 'OU' THEN
        IF igs_pr_gen_001.prgp_get_crv_cmt (
             p_course_cd,
             p_course_version_number,
             p_pra_ou_org_unit_cd,
             p_pra_ou_start_dt
           ) = 'N' THEN
          RETURN 'N';
        END IF;
      ELSIF p_pra_s_relation_type = 'CTY' THEN
        IF p_course_type <> p_pra_course_type THEN
          RETURN 'N';
        END IF;
      ELSE
        -- Not a relation type that applies at this level.
        RETURN 'N';
      END IF;
      IF p_num_of_applications IS NOT NULL THEN
        -- Check whether student has had the nominated number of applications
        FOR v_sprc_rec IN c_sprc LOOP
          v_count_of_records := v_count_of_records + 1;
        END LOOP;
        IF v_count_of_records >= p_num_of_applications THEN
          -- Already been applied the specified number of times
          RETURN 'N';
        END IF;
      END IF;
      IF p_start_effective_period IS NULL
         OR p_start_effective_period < 2 THEN
        -- Start immediately
        RETURN 'Y';
      ELSE
        v_count_of_records := 0;
        FOR v_ci_rec IN c_ci_ct_cs LOOP
          IF igs_pr_gen_001.prgp_get_drtn_efctv (
               v_ci_rec.cal_type,
               v_ci_rec.sequence_number,
               p_person_id,
               p_course_cd
             ) = 'Y' THEN
            v_count_of_records := v_count_of_records + 1;
          END IF;
        END LOOP;
        IF v_count_of_records < p_start_effective_period THEN
          -- Not yet enough records
          RETURN 'N';
        END IF;
      END IF;
      RETURN 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sprc%ISOPEN THEN
          CLOSE c_sprc;
        END IF;
        IF c_ci_ct_cs%ISOPEN THEN
          CLOSE c_ci_ct_cs;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_SCA_APPL');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_sca_appl;

  FUNCTION igs_pr_get_sca_cmt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_org_unit_cd                  IN     VARCHAR2,
    p_ou_start_dt                  IN     DATE
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_sca_cmt
    -- Get whether student course attempt is covered by the nominated
    -- committee structure
    DECLARE
      v_ou_rel_found BOOLEAN      DEFAULT FALSE;
      v_dummy        VARCHAR2 (1);
      CURSOR c_crv_cow IS
        SELECT crv.course_type,
               cow.org_unit_cd,
               cow.ou_start_dt
        FROM   igs_en_stdnt_ps_att sca,
               igs_ps_ver crv,
               igs_ps_own cow
        WHERE  sca.person_id = p_person_id
        AND    sca.course_cd = p_course_cd
        AND    (sca.version_number = p_version_number
                OR p_version_number IS NULL
               )
        AND    crv.course_cd = sca.course_cd
        AND    crv.version_number = sca.version_number
        AND    crv.course_cd = cow.course_cd
        AND    crv.version_number = cow.version_number;
      CURSOR c_our (
        cp_cow_org_unit_cd                    igs_or_unit.org_unit_cd%TYPE,
        cp_cow_ou_start_dt                    igs_or_unit.start_dt%TYPE,
        cp_course_type                        igs_ps_ver.course_type%TYPE
      ) IS
        SELECT 'X'
        FROM   igs_or_unit_rel our
        WHERE  our.parent_org_unit_cd = p_org_unit_cd
        AND    our.parent_start_dt = p_ou_start_dt
        AND    our.child_org_unit_cd = cp_cow_org_unit_cd
        AND    our.child_start_dt = cp_cow_ou_start_dt
        AND    our.logical_delete_dt IS NULL
        AND    EXISTS ( SELECT 'X'
                        FROM   igs_or_rel_ps_type ourct
                        WHERE  our.parent_org_unit_cd = ourct.parent_org_unit_cd
                        AND    our.parent_start_dt = ourct.parent_start_dt
                        AND    our.child_org_unit_cd = ourct.child_org_unit_cd
                        AND    our.child_start_dt = ourct.child_start_dt
                        AND    our.create_dt = ourct.our_create_dt
                        AND    ourct.course_type = cp_course_type);
    BEGIN
      FOR v_crv_cow_rec IN c_crv_cow LOOP
        IF  v_crv_cow_rec.org_unit_cd = p_org_unit_cd
            AND v_crv_cow_rec.ou_start_dt = p_ou_start_dt THEN
          RETURN 'Y';
        END IF;
        -- Firstly search for a direct match to an organisational unit with the
        -- course type qualification, if doesn't THEN move onto a standard ou
        -- relationship test.
        OPEN c_our (v_crv_cow_rec.org_unit_cd, v_crv_cow_rec.ou_start_dt, v_crv_cow_rec.course_type);
        FETCH c_our INTO v_dummy;
        IF c_our%FOUND THEN
          CLOSE c_our;
          v_ou_rel_found := TRUE;
          EXIT;
        ELSE
          CLOSE c_our;
          IF igs_or_gen_001.orgp_get_within_ou (
               p_org_unit_cd,
               p_ou_start_dt,
               v_crv_cow_rec.org_unit_cd,
               v_crv_cow_rec.ou_start_dt,
               'N'
             ) = 'Y' THEN
            v_ou_rel_found := TRUE;
            EXIT;
          END IF;
        END IF;
      END LOOP;
      IF v_ou_rel_found THEN
        RETURN 'Y';
      END IF;
      RETURN 'N';
    EXCEPTION
      WHEN OTHERS THEN
        IF c_crv_cow%ISOPEN THEN
          CLOSE c_crv_cow;
        END IF;
        IF c_our%ISOPEN THEN
          CLOSE c_our;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_SCA_CMT');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_sca_cmt;

  FUNCTION igs_pr_get_sca_state (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_sequence_number          IN     NUMBER
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- IGS_PR_get_sca_state
    -- Routine to determine the state of unit attempts for a nominated
    -- IGS_EN_STDNT_PS_ATT that are applicable to a progression calendar.
    --This routine can return one of four outcomes :
    --NONE    There are no unit attempts within the calendar
    --FINAL   All required /entered grades are finalised
    --RECOMMEND There are recommended grades which will contribute to the calendar
    --MISSING There are required grades that are missing (ie. not recommended)
    DECLARE
      cst_enrolled  CONSTANT VARCHAR2 (10)                               := 'ENROLLED';
      cst_completed CONSTANT VARCHAR2 (10)                               := 'COMPLETED';
      cst_discontin CONSTANT VARCHAR2 (10)                               := 'DISCONTIN';
      cst_none      CONSTANT VARCHAR2 (10)                               := 'NONE';
      cst_missing   CONSTANT VARCHAR2 (10)                               := 'MISSING';
      cst_recommend CONSTANT VARCHAR2 (10)                               := 'RECOMMEND';
      cst_final     CONSTANT VARCHAR2 (10)                               := 'FINAL';
      v_finalised            BOOLEAN                                     DEFAULT FALSE;
      v_recommended          BOOLEAN                                     DEFAULT FALSE;
      v_missing              BOOLEAN                                     DEFAULT FALSE;
      v_not_incomplete       BOOLEAN                                     DEFAULT FALSE;
      v_dummy                VARCHAR2 (1);
      v_sua_found            BOOLEAN;
      v_result_type          igs_as_grd_sch_grade.s_result_type%TYPE;
      v_outcome_dt           igs_as_su_stmptout.outcome_dt%TYPE;
      v_grading_schema_cd    igs_as_su_stmptout.grading_schema_cd%TYPE;
      v_gs_version_number    igs_as_su_stmptout.version_number%TYPE;
      v_grade                igs_as_su_stmptout.grade%TYPE;
      v_mark                 igs_as_su_stmptout.mark%TYPE;
      v_original_course_cd   igs_en_stdnt_ps_att.course_cd%TYPE;
      --
      -- kdande; 22-Apr-2003; Bug# 2829262
      -- Added uoo_id field to the SELECT clause of cursor c_sua
      --
      CURSOR c_sua IS
        SELECT   sua.person_id,
                 sua.course_cd,
                 sua.unit_cd,
                 sua.cal_type,
                 sua.ci_sequence_number,
                 sua.unit_attempt_status,
                 sua.discontinued_dt,
                 sua.uoo_id
        FROM     igs_en_su_attempt sua,
                 igs_ca_inst_rel cir
        WHERE    sua.person_id = p_person_id
        AND      sua.course_cd = p_course_cd
        AND      sua.unit_attempt_status IN (cst_enrolled, cst_discontin, cst_completed)
        AND      cir.sup_cal_type = p_prg_cal_type
        AND      cir.sup_ci_sequence_number = p_prg_sequence_number
        AND      cir.sub_cal_type = sua.cal_type
        AND      cir.sub_ci_sequence_number = sua.ci_sequence_number
        AND      (sua.administrative_unit_status IS NULL
                  OR sua.administrative_unit_status IN (SELECT aus.administrative_unit_status
                                                        FROM   igs_ad_adm_unit_stat aus
                                                        WHERE  aus.effective_progression_ind = 'Y')
                 )
        ORDER BY DECODE (sua.unit_attempt_status, cst_enrolled, 1, cst_discontin, 2, cst_completed, 3);
    BEGIN
      v_sua_found := FALSE;
      FOR v_sua_rec IN c_sua LOOP
        v_sua_found := TRUE;
        --
        -- kdande; 22-Apr-2003; Bug# 2829262
        -- Added uoo_id parameter to the igs_pr_gen_002.prgp_get_sua_prg_prd FUNCTION call
        --
        IF igs_pr_gen_002.prgp_get_sua_prg_prd (
             p_prg_cal_type,
             p_prg_sequence_number,
             p_person_id,
             p_course_cd,
             v_sua_rec.unit_cd,
             v_sua_rec.cal_type,
             v_sua_rec.ci_sequence_number,
             'Y',
             v_sua_rec.unit_attempt_status,
             v_sua_rec.discontinued_dt,
             v_sua_rec.uoo_id
           ) = 'Y' THEN
          IF v_sua_rec.unit_attempt_status <> 'DISCONTIN' THEN
            --
            -- kdande; 22-Apr-2003; Bug# 2829262
            -- Added uoo_id parameter to the igs_as_gen_003.assp_get_sua_outcome FUNCTION call
            --
            v_result_type := igs_as_gen_003.assp_get_sua_outcome (
                               p_person_id,
                               p_course_cd,
                               v_sua_rec.unit_cd,
                               v_sua_rec.cal_type,
                               v_sua_rec.ci_sequence_number,
                               v_sua_rec.unit_attempt_status,
                               'N',
                               v_outcome_dt,
                               v_grading_schema_cd,
                               v_gs_version_number,
                               v_grade,
                               v_mark,
                               v_original_course_cd,
                               v_sua_rec.uoo_id,
--added by LKAKI---
			       'N');
            IF v_result_type <> 'INCOMP' THEN
              v_not_incomplete := TRUE;
            END IF;
          ELSE
            v_result_type := NULL;
            v_not_incomplete := TRUE;
          END IF;
          IF (v_sua_rec.unit_attempt_status = cst_completed
              AND v_result_type <> 'INCOMP'
             )
             OR v_sua_rec.unit_attempt_status = cst_discontin THEN
            v_finalised := TRUE;
            EXIT;
          END IF;
          IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
            IF v_result_type IS NOT NULL THEN
              v_recommended := TRUE;
            ELSE
              v_missing := TRUE;
              EXIT;
            END IF;
          END IF;
        END IF;
      END LOOP;
      IF v_sua_found = FALSE THEN
        -- sua not found
        RETURN cst_none;
      ELSE
        IF v_missing = TRUE THEN
          RETURN cst_missing;
        ELSIF v_not_incomplete = FALSE THEN
          -- No non-incomplete grade was matched.
          RETURN cst_missing;
        ELSIF v_recommended = TRUE THEN
          RETURN cst_recommend;
        ELSIF v_finalised = TRUE THEN
          RETURN cst_final;
        ELSE
          RETURN cst_none;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sua%ISOPEN THEN
          CLOSE c_sua;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_PR_GEN_005.IGS_PR_GET_SCA_STATE');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END igs_pr_get_sca_state;

  FUNCTION igs_pr_get_scpm_value (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_prg_cal_type                 IN     VARCHAR2,
    p_prg_ci_sequence_number       IN     NUMBER,
    p_s_prg_measure_type           IN     VARCHAR2
  ) RETURN NUMBER IS
  BEGIN -- IGS_PR_get_scpm_value
    -- Get the IGS_PR_SDT_PS_PR_MSR value for the student course attempt,
    -- progression period and system progression measure type supplied.
    DECLARE
      v_value NUMBER;
      CURSOR c_scpm IS
        SELECT scpm.VALUE
        FROM   igs_pr_sdt_ps_pr_msr scpm
        WHERE  scpm.person_id = p_person_id
        AND    scpm.course_cd = p_course_cd
        AND    scpm.prg_cal_type = p_prg_cal_type
        AND    scpm.prg_ci_sequence_number = p_prg_ci_sequence_number
        AND    scpm.s_prg_measure_type = p_s_prg_measure_type
        AND    scpm.calculation_dt = (SELECT MAX (scpm2.calculation_dt)
                                      FROM   igs_pr_sdt_ps_pr_msr scpm2
                                      WHERE  scpm2.person_id = scpm.person_id
                                      AND    scpm2.course_cd = scpm.course_cd
                                      AND    scpm2.prg_cal_type = scpm.prg_cal_type
                                      AND    scpm2.prg_ci_sequence_number = scpm.prg_ci_sequence_number
                                      AND    scpm2.s_prg_measure_type = scpm.s_prg_measure_type);
    BEGIN
      -- Set the default expiry date
      IF p_person_id IS NULL
         OR p_course_cd IS NULL
         OR p_prg_cal_type IS NULL
         OR p_prg_ci_sequence_number IS NULL
         OR p_s_prg_measure_type IS NULL THEN
        RETURN NULL;
      END IF;
      -- Select IGS_PR_SDT_PS_PR_MSR record
      OPEN c_scpm;
      FETCH c_scpm INTO v_value;
      IF c_scpm%NOTFOUND THEN
        CLOSE c_scpm;
        RETURN NULL;
      END IF;
      CLOSE c_scpm;
      RETURN v_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_scpm%ISOPEN THEN
          CLOSE c_scpm;
        END IF;
        RAISE;
    END;
  END igs_pr_get_scpm_value;
END igs_pr_gen_005;

/
