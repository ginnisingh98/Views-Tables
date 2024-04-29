--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_STMPTOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_STMPTOUT_PKG" AS
/* $Header: IGSDI26B.pls 120.3 2006/05/26 11:52:41 ijeddy ship $ */
  l_rowid        VARCHAR2 (25);
  old_references igs_as_su_stmptout_all%ROWTYPE;
  new_references igs_as_su_stmptout_all%ROWTYPE;
  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_outcome_dt                   IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_number_times_keyed           IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_as_su_stmptout_all
      WHERE  ROWID = x_rowid;

    CURSOR c_grade_type (l_grading_schema_cd igs_as_grd_sch_grade.grading_schema_cd%TYPE,
                         l_version_number igs_as_grd_sch_grade.version_number%TYPE,
                         l_grade igs_as_grd_sch_grade.grade%TYPE) IS
           SELECT   'X'
                  FROM igs_as_grd_sch_grade
                 WHERE grading_schema_cd = l_grading_schema_cd
                   AND version_number = l_version_number
                   and grade = l_grade
                   and s_result_type = 'INCOMP';
    CURSOR  c_org_unit_cd (L_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
       SELECT owner_org_unit_cd FROM igs_ps_unit_ofr_opt_all WHERE uoo_id = l_uoo_id;
    v_org_unit_cd  igs_ps_unit_ofr_opt_all.owner_org_unit_cd%type;

    CURSOR c_dead_line_with_org(l_incomplete_grade igs_as_inc_grd_cprof.incomplete_grade%TYPE,
                        l_org_unit_cd igs_as_inc_grd_cprof.org_unit_cd%TYPE,
                        l_grading_schema_cd igs_as_inc_grd_cprof.grading_schema_cd%TYPE,
                        l_version_number igs_as_inc_grd_cprof.version_number%TYPE) IS
          SELECT incomplete_grade, org_unit_cd, comp_after_dt_alias, default_grade,
               default_mark
            FROM igs_as_inc_grd_cprof_v
          WHERE incomplete_grade = l_incomplete_grade
           AND org_unit_cd = l_org_unit_cd
           AND grading_schema_cd = l_grading_schema_cd
           AND version_number = l_version_number;

    CURSOR c_dead_line(l_incomplete_grade igs_as_inc_grd_cprof.incomplete_grade%TYPE,
                        l_grading_schema_cd igs_as_inc_grd_cprof.grading_schema_cd%TYPE,
                        l_version_number igs_as_inc_grd_cprof.version_number%TYPE) IS
          SELECT incomplete_grade, org_unit_cd, comp_after_dt_alias, default_grade,
               default_mark
            FROM igs_as_inc_grd_cprof_v
          WHERE incomplete_grade = l_incomplete_grade
           AND grading_schema_cd = l_grading_schema_cd
           AND version_number = l_version_number;

    CURSOR c_dt_alias_val(l_dt_alias igs_ca_da_inst.dt_alias%TYPE,
                          l_cal_type igs_ca_da_inst.cal_type%TYPE,
                          l_ci_sequence_number  igs_ca_da_inst.ci_sequence_number%TYPE) IS
         SELECT max(IGS_CA_GEN_001.calp_get_alias_val(dt_alias, sequence_number, cal_type, ci_sequence_number))
           FROM igs_ca_da_inst
         WHERE dt_alias         = l_dt_alias
           AND cal_type           = l_cal_type
           AND ci_sequence_number = l_ci_sequence_number;

    v_dead_line  c_dead_line%ROWTYPE;
    temp         VARCHAR2(1);

  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF  (cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE cur_old_ref_values;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.



    new_references.org_id := x_org_id;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ci_start_dt := x_ci_start_dt;
    new_references.ci_end_dt := x_ci_end_dt;
    new_references.outcome_dt := x_outcome_dt;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.grade := x_grade;
    new_references.s_grade_creation_method_type := x_s_grade_creation_method_type;
    new_references.finalised_outcome_ind := x_finalised_outcome_ind;
    new_references.mark := x_mark;
    new_references.translated_grading_schema_cd := x_translated_grading_schema_cd;
    new_references.translated_version_number := x_translated_version_number;
    new_references.translated_grade := x_translated_grade;
    new_references.translated_dt := x_translated_dt;
    new_references.number_times_keyed := x_number_times_keyed;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.grading_period_cd := x_grading_period_cd;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.comments := x_comments;
    new_references.uoo_id := x_uoo_id;
    new_references.mark_capped_flag := x_mark_capped_flag;
    new_references.release_date := x_release_date;
    new_references.manual_override_flag := x_manual_override_flag;
    new_references.show_on_academic_histry_flag := x_show_on_academic_histry_flag;

   OPEN c_grade_type(x_grading_schema_cd,x_version_number,x_grade);
    FETCH c_grade_type INTO temp;
    IF c_grade_type%FOUND
          AND x_incomp_deadline_date IS NULL
          AND x_incomp_default_grade IS NULL
    THEN
              OPEN c_org_unit_cd (x_uoo_id);
              FETCH c_org_unit_cd INTO v_org_unit_cd;
              CLOSE c_org_unit_cd;
              IF v_org_unit_cd IS NULL THEN
                  OPEN c_dead_line(x_grade, x_grading_schema_cd,x_version_number);
                  FETCH c_dead_line INTO v_dead_line;
                  CLOSE c_dead_line;
              ELSE
                  OPEN c_dead_line_with_org(x_grade, v_org_unit_cd,x_grading_schema_cd,x_version_number);
                  FETCH c_dead_line_with_org INTO v_dead_line;
                  CLOSE c_dead_line_with_org;
              END IF;
              OPEN c_dt_alias_val(v_dead_line.comp_after_dt_alias, x_cal_type, x_ci_sequence_number);
              FETCH c_dt_alias_val INTO new_references.incomp_deadline_date ;
              CLOSE c_dt_alias_val ;
              new_references.incomp_grading_schema_cd := x_grading_schema_cd;
              new_references.incomp_version_number := x_version_number;
              new_references.incomp_default_grade := v_dead_line.default_grade;
              new_references.incomp_default_mark := v_dead_line.default_mark;
    ELSIF  c_grade_type%NOTFOUND THEN
              new_references.incomp_deadline_date := NULL;
              new_references.incomp_grading_schema_cd := NULL;
              new_references.incomp_version_number := NULL;
              new_references.incomp_default_grade := NULL;
              new_references.incomp_default_mark := NULL;
    ELSE
              new_references.incomp_deadline_date := x_incomp_deadline_date;
              new_references.incomp_grading_schema_cd := x_incomp_grading_schema_cd;
              new_references.incomp_version_number := x_incomp_version_number;
              new_references.incomp_default_grade := x_incomp_default_grade;
              new_references.incomp_default_mark := x_incomp_default_mark;
    END IF;
    CLOSE c_grade_type;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END set_column_values;

  PROCEDURE beforerowinsertupdate1 (p_inserting IN BOOLEAN, p_updating IN BOOLEAN, p_deleting IN BOOLEAN) AS
    v_sequence_number NUMBER;
  BEGIN
    -- If a finalised outcome has been altered by either an insert,update or delete
    -- then flag the student as requiring a IGS_RU_RULE check. IGS_GE_NOTE: Discontinuation
    -- grades are not processed as they are handled by the SUA trigger.
    IF (p_inserting
        AND new_references.finalised_outcome_ind = 'Y'
       )
       OR (p_updating
           AND (old_references.finalised_outcome_ind = 'Y'
                OR new_references.finalised_outcome_ind = 'Y'
               )
          ) THEN
      IF p_inserting
         OR p_updating THEN
        IF new_references.s_grade_creation_method_type <> 'DISCONTIN' THEN
          v_sequence_number := igs_ge_gen_003.genp_ins_stdnt_todo (new_references.person_id, 'UNIT-RULES', NULL, 'Y');
          IF p_inserting THEN
            igs_pr_gen_004.igs_pr_ins_suao_todo (
              new_references.person_id,
              new_references.course_cd,
              NULL, --new_references.version_number,
              new_references.unit_cd,
              new_references.cal_type,
              new_references.ci_sequence_number,
              new_references.grading_schema_cd,
              new_references.grading_schema_cd,
              new_references.version_number,
              new_references.version_number,
              new_references.grade,
              new_references.grade,
              new_references.mark,
              new_references.mark,
              new_references.finalised_outcome_ind,
              new_references.finalised_outcome_ind,
              new_references.uoo_id
            );
          ELSIF p_updating THEN
            igs_pr_gen_004.igs_pr_ins_suao_todo (
              new_references.person_id,
              new_references.course_cd,
              NULL, --new_references.version_number,
              new_references.unit_cd,
              new_references.cal_type,
              new_references.ci_sequence_number,
              old_references.grading_schema_cd,
              new_references.grading_schema_cd,
              old_references.version_number,
              new_references.version_number,
              old_references.grade,
              new_references.grade,
              old_references.mark,
              new_references.mark,
              old_references.finalised_outcome_ind,
              new_references.finalised_outcome_ind,
              new_references.uoo_id
            );
          END IF;
        END IF;
      ELSE
        IF old_references.s_grade_creation_method_type <> 'DISCONTIN' THEN
          v_sequence_number := igs_ge_gen_003.genp_ins_stdnt_todo (new_references.person_id, 'UNIT-RULES', NULL, 'Y');
          IF p_inserting THEN
            igs_pr_gen_004.igs_pr_ins_suao_todo (
              new_references.person_id,
              new_references.course_cd,
              NULL, --new_references.version_number,
              old_references.unit_cd,
              old_references.cal_type,
              old_references.ci_sequence_number,
              old_references.grading_schema_cd,
              old_references.grading_schema_cd,
              old_references.version_number,
              old_references.version_number,
              old_references.grade,
              old_references.grade,
              old_references.mark,
              old_references.mark,
              old_references.finalised_outcome_ind,
              old_references.finalised_outcome_ind,
              old_references.uoo_id
            );
          END IF;
        END IF;
      END IF;
    END IF;
    IF p_inserting THEN
      -- Get the calendar start/end dates.
      igs_ca_gen_001.calp_get_ci_dates (
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.ci_start_dt,
        new_references.ci_end_dt
      );
    END IF;
  END beforerowinsertupdate1;

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Passed uoo_id to IGS_EN_GEN_007.ENRP_GET_SUA_STATUS , IGS_AS_GEN_005.ASSP_SET_SUAO_TRANS,
  --                           IGS_AS_GEN_007.ASSP_INS_SUAO_HIST, IGS_AS_GEN_005.ASSP_SET_SUAO_TRANS as part of MUS build, # 2829262
  --rvangala    07-OCT-03    Passing core_indicator_code to IGS_EN_SUA-API.UPDATE_UNIT_ATTEMPT added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  --IJEDDY      5/26/2006    Bug 5243080, put in a check to retain atleast one finalized outcome for a completed transfered unit.
  -------------------------------------------------------------------------------------------
  PROCEDURE afterrowinsertupdate2 (p_inserting IN BOOLEAN, p_updating IN BOOLEAN, p_deleting IN BOOLEAN) AS
    v_message_name                 VARCHAR2 (30);
    v_rowid_saved                  BOOLEAN                                                := FALSE;
    v_grade                        igs_as_su_stmptout_all.grade%TYPE;
    CURSOR c_sua (
      cp_person_id                          igs_en_su_attempt.person_id%TYPE,
      cp_course_cd                          igs_en_su_attempt.course_cd%TYPE,
      cp_uoo_id                             igs_en_su_attempt.uoo_id%TYPE
    ) IS
      SELECT sua.*,
             sua.ROWID
      FROM   igs_en_su_attempt sua
      WHERE  sua.person_id = cp_person_id
      AND    sua.course_cd = cp_course_cd
      AND    sua.uoo_id = cp_uoo_id;
    v_sua_rec                      c_sua%ROWTYPE;
    v_person_id                    igs_as_su_stmptout_all.person_id%TYPE;
    v_course_cd                    igs_as_su_stmptout_all.course_cd%TYPE;
    v_unit_cd                      igs_as_su_stmptout_all.unit_cd%TYPE;
    v_cal_type                     igs_as_su_stmptout_all.cal_type%TYPE;
    v_ci_sequence_number           igs_as_su_stmptout_all.ci_sequence_number%TYPE;
    v_translated_grading_schema_cd igs_as_su_stmptout_all.translated_grading_schema_cd%TYPE;
    v_translated_version_number    igs_as_su_stmptout_all.translated_version_number%TYPE;
    v_translated_grade             igs_as_su_stmptout_all.translated_grade%TYPE;
    v_translated_dt                igs_as_su_stmptout_all.translated_dt%TYPE;
    v_sua_status                   igs_en_su_attempt.unit_attempt_status%TYPE;

    --
    -- Check if there is a transfer for Unit
    --
    CURSOR cur_sut (
             cp_person_id IN NUMBER,
             cp_course_cd IN VARCHAR2,
             cp_uoo_id IN VARCHAR2
           ) IS
        SELECT 'Y' transfer_exists
          FROM igs_ps_stdnt_unt_trn sut1
         WHERE sut1.person_id = cp_person_id
           AND sut1.transfer_course_cd = cp_course_cd
           AND sut1.uoo_id = cp_uoo_id
           AND EXISTS ( SELECT 'X'
                          FROM igs_en_su_attempt_all sua
                         WHERE sua.person_id = sut1.person_id
                           AND sua.course_cd = sut1.transfer_course_cd
                           AND sua.uoo_id = sut1.uoo_id
                           AND sua.unit_attempt_status IN ('COMPLETED', 'DISCONTIN')
                           AND EXISTS (SELECT 'X'
                                      FROM igs_en_su_attempt_all sua
                                      WHERE sua.person_id = sut1.person_id
                                      AND sua.course_cd = sut1.course_cd
                                      AND sua.uoo_id = sut1.uoo_id
                                      AND sua.unit_attempt_status = 'DUPLICATE'))
           AND sut1.transfer_dt = (SELECT MAX (sut2.transfer_dt)
                                     FROM igs_ps_stdnt_unt_trn sut2
                                    WHERE sut2.person_id = sut1.person_id
                                      AND sut2.transfer_course_cd = sut1.transfer_course_cd
                                      AND sut2.uoo_id = sut1.uoo_id)
           AND sut1.transfer_dt > (SELECT NVL (MAX (sut3.transfer_dt),(  sut1.transfer_dt - 1))
                                     FROM igs_ps_stdnt_unt_trn sut3
                                    WHERE sut3.person_id = sut1.person_id
                                      AND sut3.course_cd = sut1.transfer_course_cd
                                      AND sut3.uoo_id = sut1.uoo_id);
    --
    rec_sut cur_sut%ROWTYPE;

  BEGIN
    --
    -- Update of student Course Attempt after Student Unit Attempt is posted
    -- to the database
    --
    IF v_rowid_saved = FALSE THEN
      v_grade := new_references.grade;
      IF  p_updating
          AND (new_references.grade = old_references.grade)
          AND (new_references.grading_schema_cd = old_references.grading_schema_cd)
          AND (new_references.version_number = old_references.version_number) THEN
        --
        -- Clear the grade to indicate not to perform translation in
        -- assp_prc_suao_rowids as the grade has not altered.
        --
        v_grade := NULL;
      END IF;
      IF p_deleting THEN
        OPEN c_sua (old_references.person_id, old_references.course_cd, old_references.uoo_id);
      ELSE
        OPEN c_sua (new_references.person_id, new_references.course_cd, new_references.uoo_id);
      END IF;
      FETCH c_sua INTO v_sua_rec;
      IF (c_sua%NOTFOUND) THEN
        CLOSE c_sua;
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      CLOSE c_sua;
      --
      -- Added 'waitlist_dt' as a parameter to call IGS_EN_GEN_007.ENRP_GET_SUA_STATUS.
      -- This is as per the Bug# 2335455
      --
      v_sua_status := igs_en_gen_007.enrp_get_sua_status (
                        v_sua_rec.person_id,
                        v_sua_rec.course_cd,
                        v_sua_rec.unit_cd,
                        v_sua_rec.version_number,
                        v_sua_rec.cal_type,
                        v_sua_rec.ci_sequence_number,
                        v_sua_rec.unit_attempt_status,
                        v_sua_rec.enrolled_dt,
                        v_sua_rec.rule_waived_dt,
                        v_sua_rec.discontinued_dt,
                        v_sua_rec.waitlist_dt,
                        v_sua_rec.uoo_id
                      );
      --
      -- Update the Student Unit Attempt status only if it has changed.
      --
      IF (v_sua_status <> v_sua_rec.unit_attempt_status) THEN
        IF  v_sua_status <> 'COMPLETED' AND v_sua_rec.unit_attempt_status = 'COMPLETED' THEN
          OPEN cur_sut (v_sua_rec.person_id,
                        v_sua_rec.course_cd,
                        v_sua_rec.uoo_id);
          FETCH cur_sut INTO rec_sut;
          CLOSE cur_sut;
          IF (NVL (rec_sut.transfer_exists, 'N') = 'Y') THEN
            -- Error.
            fnd_message.set_name ('IGS', 'IGS_AS_COMPL_UAO_NOTUPD');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
          END IF;
        END IF;
        igs_en_sua_api.update_unit_attempt (
          x_mode                         => 'R',
          x_rowid                        => v_sua_rec.ROWID,
          x_person_id                    => v_sua_rec.person_id,
          x_course_cd                    => v_sua_rec.course_cd,
          x_unit_cd                      => v_sua_rec.unit_cd,
          x_cal_type                     => v_sua_rec.cal_type,
          x_ci_sequence_number           => v_sua_rec.ci_sequence_number,
          x_version_number               => v_sua_rec.version_number,
          x_location_cd                  => v_sua_rec.location_cd,
          x_unit_class                   => v_sua_rec.unit_class,
          x_ci_start_dt                  => v_sua_rec.ci_start_dt,
          x_ci_end_dt                    => v_sua_rec.ci_end_dt,
          x_uoo_id                       => v_sua_rec.uoo_id,
          x_enrolled_dt                  => v_sua_rec.enrolled_dt,
          x_unit_attempt_status          => v_sua_status,
          x_administrative_unit_status   => v_sua_rec.administrative_unit_status,
          x_administrative_priority      => v_sua_rec.administrative_priority,
          x_discontinued_dt              => v_sua_rec.discontinued_dt,
          x_dcnt_reason_cd               => v_sua_rec.dcnt_reason_cd,
          x_rule_waived_dt               => v_sua_rec.rule_waived_dt,
          x_rule_waived_person_id        => v_sua_rec.rule_waived_person_id,
          x_no_assessment_ind            => v_sua_rec.no_assessment_ind,
          x_sup_unit_cd                  => v_sua_rec.sup_unit_cd,
          x_sup_version_number           => v_sua_rec.sup_version_number,
          x_exam_location_cd             => v_sua_rec.exam_location_cd,
          x_alternative_title            => v_sua_rec.alternative_title,
          x_override_enrolled_cp         => v_sua_rec.override_enrolled_cp,
          x_override_eftsu               => v_sua_rec.override_eftsu,
          x_override_achievable_cp       => v_sua_rec.override_achievable_cp,
          x_override_outcome_due_dt      => v_sua_rec.override_outcome_due_dt,
          x_override_credit_reason       => v_sua_rec.override_credit_reason,
          x_waitlist_dt                  => v_sua_rec.waitlist_dt,
          x_gs_version_number            => v_sua_rec.gs_version_number,
          x_enr_method_type              => v_sua_rec.enr_method_type,
          x_failed_unit_rule             => v_sua_rec.failed_unit_rule,
          x_cart                         => v_sua_rec.cart,
          x_rsv_seat_ext_id              => v_sua_rec.rsv_seat_ext_id,
          x_org_unit_cd                  => v_sua_rec.org_unit_cd,
          x_session_id                   => v_sua_rec.session_id,
          x_grading_schema_code          => v_sua_rec.grading_schema_code,
          x_deg_aud_detail_id            => v_sua_rec.deg_aud_detail_id,
          x_subtitle                     => v_sua_rec.subtitle,
          x_student_career_transcript    => v_sua_rec.student_career_transcript,
          x_student_career_statistics    => v_sua_rec.student_career_statistics,
          x_waitlist_manual_ind          => v_sua_rec.waitlist_manual_ind,
          x_attribute_category           => v_sua_rec.attribute_category,
          x_attribute1                   => v_sua_rec.attribute1,
          x_attribute2                   => v_sua_rec.attribute2,
          x_attribute3                   => v_sua_rec.attribute3,
          x_attribute4                   => v_sua_rec.attribute4,
          x_attribute5                   => v_sua_rec.attribute5,
          x_attribute6                   => v_sua_rec.attribute6,
          x_attribute7                   => v_sua_rec.attribute7,
          x_attribute8                   => v_sua_rec.attribute8,
          x_attribute9                   => v_sua_rec.attribute9,
          x_attribute10                  => v_sua_rec.attribute10,
          x_attribute11                  => v_sua_rec.attribute11,
          x_attribute12                  => v_sua_rec.attribute12,
          x_attribute13                  => v_sua_rec.attribute13,
          x_attribute14                  => v_sua_rec.attribute14,
          x_attribute15                  => v_sua_rec.attribute15,
          x_attribute16                  => v_sua_rec.attribute16,
          x_attribute17                  => v_sua_rec.attribute17,
          x_attribute18                  => v_sua_rec.attribute18,
          x_attribute19                  => v_sua_rec.attribute19,
          x_attribute20                  => v_sua_rec.attribute20,
          x_wlst_priority_weight_num     => v_sua_rec.wlst_priority_weight_num,
          x_wlst_preference_weight_num   => v_sua_rec.wlst_preference_weight_num,
          -- core_indicator_code added by rvangala 07-OCT-2003. Enh Bug# 3052432
          x_core_indicator_code          => v_sua_rec.core_indicator_code
        );
      END IF;
      -- Determine if the translation fields are to be updated.
      -- If grade has been altered, then the pl/sql table grade will be set.
      IF v_grade IS NOT NULL THEN
        v_translated_grading_schema_cd := new_references.translated_grading_schema_cd;
        v_translated_version_number := new_references.translated_version_number;
        v_translated_grade := new_references.translated_grade;
        v_translated_dt := new_references.translated_dt;
        -- Determine if translation has been done and set the fields accordingly.
        IF igs_as_gen_005.assp_set_suao_trans (
             new_references.person_id,
             new_references.course_cd,
             new_references.unit_cd,
             new_references.cal_type,
             new_references.ci_sequence_number,
             new_references.outcome_dt,
             new_references.grade,
             new_references.grading_schema_cd,
             new_references.version_number,
             v_translated_grading_schema_cd,
             v_translated_version_number,
             v_translated_grade,
             v_translated_dt,
             v_message_name,
             new_references.uoo_id
           ) = FALSE THEN
          -- Error.
          fnd_message.set_name ('IGS', v_message_name);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
        END IF;
        -- Not necessary to check for lock as in the process of insert/updating
        -- anyway, so will already have a lock.
  UPDATE igs_as_su_stmptout_all
           SET translated_grading_schema_cd = v_translated_grading_schema_cd,
               translated_version_number = v_translated_version_number,
               translated_grade = v_translated_grade,
               translated_dt = v_translated_dt
         WHERE person_id = new_references.person_id
         AND   course_cd = new_references.course_cd
         AND   outcome_dt = new_references.outcome_dt
         AND   grading_period_cd = new_references.grading_period_cd
         AND   uoo_id = new_references.uoo_id;
      END IF;
    END IF;
    IF p_updating THEN
      igs_as_gen_007.assp_ins_suao_hist (
        old_references.person_id,
        old_references.course_cd,
        old_references.unit_cd,
        old_references.cal_type,
        old_references.ci_sequence_number,
        old_references.outcome_dt,
        new_references.grading_schema_cd,
        new_references.version_number,
        new_references.grade,
        new_references.s_grade_creation_method_type,
        new_references.finalised_outcome_ind,
        new_references.mark,
        new_references.number_times_keyed,
        new_references.translated_grading_schema_cd,
        new_references.translated_version_number,
        new_references.translated_grade,
        new_references.translated_dt,
        new_references.last_updated_by,
        new_references.last_update_date,
        old_references.grading_schema_cd,
        old_references.version_number,
        old_references.grade,
        old_references.s_grade_creation_method_type,
        old_references.finalised_outcome_ind,
        old_references.mark,
        old_references.number_times_keyed,
        old_references.translated_grading_schema_cd,
        old_references.translated_version_number,
        old_references.translated_grade,
        old_references.translated_dt,
        old_references.last_updated_by,
        old_references.last_update_date,
        old_references.uoo_id
      );
    END IF;
  END afterrowinsertupdate2;
  --
  PROCEDURE check_parent_existance AS
  BEGIN
    IF (((old_references.cal_type = new_references.cal_type)
         AND (old_references.ci_sequence_number = new_references.ci_sequence_number)
         AND (old_references.ci_start_dt = new_references.ci_start_dt)
         AND (old_references.ci_end_dt = new_references.ci_end_dt)
        )
        OR ((new_references.cal_type IS NULL)
            OR (new_references.ci_sequence_number IS NULL)
            OR (new_references.ci_start_dt IS NULL)
            OR (new_references.ci_end_dt IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (new_references.cal_type, new_references.ci_sequence_number) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd)
         OR (old_references.version_number = new_references.version_number)
         OR (old_references.grade = new_references.grade)
        )
        OR ((new_references.grading_schema_cd IS NULL)
            OR (new_references.version_number IS NULL)
            OR (new_references.grade IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.version_number,
                new_references.grade
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.s_grade_creation_method_type = new_references.s_grade_creation_method_type))
        OR ((new_references.s_grade_creation_method_type IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'GRADE_CREATION_METHOD_TYPE',
                new_references.s_grade_creation_method_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.person_id = new_references.person_id)
         OR (old_references.course_cd = new_references.course_cd)
         OR (old_references.uoo_id = new_references.uoo_id)
        )
        OR ((new_references.person_id IS NULL)
            OR (new_references.course_cd IS NULL)
            OR (new_references.uoo_id IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_en_su_attempt_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd,
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.translated_grading_schema_cd = new_references.translated_grading_schema_cd)
         OR (old_references.translated_version_number = new_references.translated_version_number)
         OR (old_references.translated_grade = new_references.translated_grade)
        )
        OR ((new_references.translated_grading_schema_cd IS NULL)
            OR (new_references.translated_version_number IS NULL)
            OR (new_references.translated_grade IS NULL)
           )
       ) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                new_references.translated_grading_schema_cd,
                new_references.translated_version_number,
                new_references.translated_grade
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION get_pk_for_validation (
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_outcome_dt                   IN     DATE,
    x_grading_period_cd            IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER
  )
    RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_as_su_stmptout_all
      WHERE      person_id = x_person_id
      AND        course_cd = x_course_cd
      AND        outcome_dt = x_outcome_dt
      AND        grading_period_cd = x_grading_period_cd
      AND        uoo_id = x_uoo_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
  END get_pk_for_validation;

  PROCEDURE get_ufk_igs_ca_inst (x_cal_type IN VARCHAR2, x_sequence_number IN NUMBER, x_start_dt IN DATE, x_end_dt IN DATE) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  cal_type = x_cal_type
      AND    ci_sequence_number = x_sequence_number
      AND    ci_start_dt = x_start_dt
      AND    ci_end_dt = x_end_dt;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAO_CI_UFK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_ufk_igs_ca_inst;

  PROCEDURE get_fk_igs_lookups_view (x_s_grade_creation_method_type IN VARCHAR2) IS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  s_grade_creation_method_type = x_s_grade_creation_method_type;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAO_SLV_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_lookups_view;

  PROCEDURE get_fk_igs_en_su_attempt (x_person_id IN NUMBER, x_course_cd IN VARCHAR2, x_uoo_id IN NUMBER) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    uoo_id = x_uoo_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      -- Changed '<FORM_RECORD_PRESENT>' to 'IGS_AS_SUAO_SUA_FK',anilk Bug#2413841
      fnd_message.set_name ('IGS', 'IGS_AS_SUAO_SUA_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_en_su_attempt;

  PROCEDURE get_fk_igs_as_grd_sch_grade (x_grading_schema_cd IN VARCHAR2, x_version_number IN NUMBER, x_grade IN VARCHAR2) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  translated_grading_schema_cd = x_grading_schema_cd
             AND translated_version_number = x_version_number
             AND translated_grade = x_grade
             OR  (grading_schema_cd = x_grading_schema_cd
              AND version_number = x_version_number
              AND grade = x_grade
             );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAO_SUA_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_grd_sch_grade;

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_outcome_dt                   IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_number_times_keyed           IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_creation_date                IN     DATE,
    x_created_by                   IN     NUMBER,
    x_last_update_date             IN     DATE,
    x_last_updated_by              IN     NUMBER,
    x_last_update_login            IN     NUMBER,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    CURSOR c_sua_ass_ind IS
      SELECT sua.no_assessment_ind
      FROM   igs_en_su_attempt sua
      WHERE  sua.person_id = x_person_id
      AND    sua.course_cd = x_course_cd
      AND    sua.uoo_id = x_uoo_id;
    l_sua_ass_ind     igs_en_su_attempt.no_assessment_ind%TYPE;
    CURSOR c_gsg_result_type IS
      SELECT gsg.s_result_type
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = x_grading_schema_cd
      AND    gsg.version_number = x_version_number
      AND    gsg.grade = x_grade;
    l_gsg_result_type igs_as_grd_sch_grade.s_result_type%TYPE;
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_org_id,
      x_cal_type,
      x_ci_sequence_number,
      x_ci_start_dt,
      x_ci_end_dt,
      x_outcome_dt,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_s_grade_creation_method_type,
      x_finalised_outcome_ind,
      x_mark,
      x_translated_grading_schema_cd,
      x_translated_version_number,
      x_translated_grade,
      x_translated_dt,
      x_number_times_keyed,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_grading_period_cd,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_incomp_deadline_date,
      x_incomp_grading_schema_cd,
      x_incomp_version_number,
      x_incomp_default_grade,
      x_incomp_default_mark,
      x_comments,
      x_uoo_id,
      x_mark_capped_flag,
      x_release_date,
      x_manual_override_flag,
      x_show_on_academic_histry_flag
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforerowinsertupdate1 (p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE);
      IF get_pk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.outcome_dt,
           NVL (new_references.grading_period_cd, 'FINAL'),
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdate1 (p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.outcome_dt,
           NVL (new_references.grading_period_cd, 'FINAL'),
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    END IF;
    --The below code added as part of the bug#2597204
    --Opens the cursor to get the no_assessment_ind of a unit Attempt
    --The value of no_assesment_ind says whether the unit attempt is Audit or not
    OPEN c_sua_ass_ind;
    FETCH c_sua_ass_ind INTO l_sua_ass_ind;
    CLOSE c_sua_ass_ind;
    --Opens the cursor to get the system result type of the Grading Scema Grade
    --If the system result type is of AUDIT then the grading schema grade is of audit type
    OPEN c_gsg_result_type;
    FETCH c_gsg_result_type INTO l_gsg_result_type;
    CLOSE c_gsg_result_type;
    --If user tries to assign an audit grade to a student who is not taking the unit as an
    --audit, an error is thrown
    IF  l_sua_ass_ind = 'N'
        AND l_gsg_result_type = 'AUDIT' THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SS_UNT_NT_ADT_GRD');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    --If user tries to assign a non-audit grade to a student who is taking the unit attempt
    --as an audit, an error is thrown
    ELSIF  l_sua_ass_ind = 'Y'
           AND l_gsg_result_type <> 'AUDIT' THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SS_UNT_ADT_GRD');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END before_dml;

  PROCEDURE after_dml (p_action IN VARCHAR2, x_rowid IN VARCHAR2) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      afterrowinsertupdate2 (p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      afterrowinsertupdate2 (p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Update.
      afterrowinsertupdate2 (p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE);
    END IF;
  END after_dml;
  --
  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    CURSOR c IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    outcome_dt = x_outcome_dt
      AND    grading_period_cd = x_grading_period_cd
      AND    uoo_id = x_uoo_id;
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := NULL;
        x_program_id := NULL;
        x_program_application_id := NULL;
        x_program_update_date := NULL;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_org_id                       => igs_ge_gen_003.get_org_id,
      x_cal_type                     => x_cal_type,
      x_ci_end_dt                    => x_ci_end_dt,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_ci_start_dt                  => x_ci_start_dt,
      x_course_cd                    => x_course_cd,
      x_finalised_outcome_ind        => NVL (x_finalised_outcome_ind, 'N'),
      x_grade                        => x_grade,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_mark                         => x_mark,
      x_number_times_keyed           => x_number_times_keyed,
      x_outcome_dt                   => x_outcome_dt,
      x_person_id                    => x_person_id,
      x_s_grade_creation_method_type => x_s_grade_creation_method_type,
      x_translated_dt                => x_translated_dt,
      x_translated_grade             => x_translated_grade,
      x_translated_grading_schema_cd => x_translated_grading_schema_cd,
      x_translated_version_number    => x_translated_version_number,
      x_unit_cd                      => x_unit_cd,
      x_version_number               => x_version_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_period_cd            => x_grading_period_cd,
      x_attribute_category           => x_attribute_category,
      x_attribute1                   => x_attribute1,
      x_attribute2                   => x_attribute2,
      x_attribute3                   => x_attribute3,
      x_attribute4                   => x_attribute4,
      x_attribute5                   => x_attribute5,
      x_attribute6                   => x_attribute6,
      x_attribute7                   => x_attribute7,
      x_attribute8                   => x_attribute8,
      x_attribute9                   => x_attribute9,
      x_attribute10                  => x_attribute10,
      x_attribute11                  => x_attribute11,
      x_attribute12                  => x_attribute12,
      x_attribute13                  => x_attribute13,
      x_attribute14                  => x_attribute14,
      x_attribute15                  => x_attribute15,
      x_attribute16                  => x_attribute16,
      x_attribute17                  => x_attribute17,
      x_attribute18                  => x_attribute18,
      x_attribute19                  => x_attribute19,
      x_attribute20                  => x_attribute20,
      x_incomp_deadline_date         => x_incomp_deadline_date,
      x_incomp_grading_schema_cd     => x_incomp_grading_schema_cd,
      x_incomp_version_number        => x_incomp_version_number,
      x_incomp_default_grade         => x_incomp_default_grade,
      x_incomp_default_mark          => x_incomp_default_mark,
      x_comments                     => x_comments,
      x_uoo_id                       => x_uoo_id,
      x_mark_capped_flag             => x_mark_capped_flag,
      x_release_date                 => x_release_date,
      x_manual_override_flag         => x_manual_override_flag,
      x_show_on_academic_histry_flag => x_show_on_academic_histry_flag
    );
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO igs_as_su_stmptout_all
                (org_id, person_id, course_cd, unit_cd,
                 cal_type, ci_sequence_number, ci_start_dt,
                 ci_end_dt, outcome_dt, grading_schema_cd,
                 version_number, grade, s_grade_creation_method_type,
                 finalised_outcome_ind, mark, number_times_keyed,
                 translated_grading_schema_cd, translated_version_number,
                 translated_grade, translated_dt, creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login, request_id, program_id,
                 program_application_id, program_update_date, grading_period_cd,
                 attribute_category, attribute1, attribute2,
                 attribute3, attribute4, attribute5,
                 attribute6, attribute7, attribute8,
                 attribute9, attribute10, attribute11,
                 attribute12, attribute13, attribute14,
                 attribute15, attribute16, attribute17,
                 attribute18, attribute19, attribute20,
                 incomp_deadline_date, incomp_grading_schema_cd,
                 incomp_version_number, incomp_default_grade,
                 incomp_default_mark, comments, uoo_id,
                 mark_capped_flag, release_date, manual_override_flag,
                 show_on_academic_histry_flag)
         VALUES (new_references.org_id, new_references.person_id, new_references.course_cd, new_references.unit_cd,
                 new_references.cal_type, new_references.ci_sequence_number, new_references.ci_start_dt,
                 new_references.ci_end_dt, new_references.outcome_dt, new_references.grading_schema_cd,
                 new_references.version_number, new_references.grade, new_references.s_grade_creation_method_type,
                 new_references.finalised_outcome_ind, new_references.mark, new_references.number_times_keyed,
                 new_references.translated_grading_schema_cd, new_references.translated_version_number,
                 new_references.translated_grade, new_references.translated_dt, x_last_update_date, x_last_updated_by,
                 x_last_update_date, x_last_updated_by, x_last_update_login, x_request_id, x_program_id,
                 x_program_application_id, x_program_update_date, new_references.grading_period_cd,
                 new_references.attribute_category, new_references.attribute1, new_references.attribute2,
                 new_references.attribute3, new_references.attribute4, new_references.attribute5,
                 new_references.attribute6, new_references.attribute7, new_references.attribute8,
                 new_references.attribute9, new_references.attribute10, new_references.attribute11,
                 new_references.attribute12, new_references.attribute13, new_references.attribute14,
                 new_references.attribute15, new_references.attribute16, new_references.attribute17,
                 new_references.attribute18, new_references.attribute19, new_references.attribute20,
                 new_references.incomp_deadline_date, new_references.incomp_grading_schema_cd,
                 new_references.incomp_version_number, new_references.incomp_default_grade,
                 new_references.incomp_default_mark, new_references.comments, new_references.uoo_id,
                 new_references.mark_capped_flag, new_references.release_date, new_references.manual_override_flag,
                 new_references.show_on_academic_histry_flag);
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml (p_action => 'INSERT', x_rowid => x_rowid);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    CURSOR c1 IS
      SELECT     ci_start_dt,
                 ci_end_dt,
                 grading_schema_cd,
                 version_number,
                 grade,
                 s_grade_creation_method_type,
                 finalised_outcome_ind,
                 mark,
                 number_times_keyed,
                 translated_grading_schema_cd,
                 translated_version_number,
                 translated_grade,
                 translated_dt,
                 grading_period_cd,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 incomp_deadline_date,
                 incomp_grading_schema_cd,
                 incomp_version_number,
                 incomp_default_grade,
                 incomp_default_mark,
                 comments,
                 uoo_id,
                 mark_capped_flag,
                 release_date,
                 manual_override_flag,
                 show_on_academic_histry_flag
      FROM       igs_as_su_stmptout_all
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      CLOSE c1;
      RETURN;
    END IF;
    CLOSE c1;
    IF ((TRUNC (tlinfo.ci_start_dt) = TRUNC (x_ci_start_dt))
        AND (TRUNC (tlinfo.ci_end_dt) = TRUNC (x_ci_end_dt))
        AND (tlinfo.grading_schema_cd = x_grading_schema_cd)
        AND (tlinfo.version_number = x_version_number)
        AND (tlinfo.grade = x_grade)
        AND (tlinfo.s_grade_creation_method_type = x_s_grade_creation_method_type)
        AND (tlinfo.finalised_outcome_ind = x_finalised_outcome_ind)
        AND ((tlinfo.mark = x_mark)
             OR ((tlinfo.mark IS NULL)
                 AND (x_mark IS NULL)
                )
            )
        AND ((tlinfo.number_times_keyed = x_number_times_keyed)
             OR ((tlinfo.number_times_keyed IS NULL)
                 AND (x_number_times_keyed IS NULL)
                )
            )
        AND ((tlinfo.translated_grading_schema_cd = x_translated_grading_schema_cd)
             OR ((tlinfo.translated_grading_schema_cd IS NULL)
                 AND (x_translated_grading_schema_cd IS NULL)
                )
            )
        AND ((tlinfo.translated_version_number = x_translated_version_number)
             OR ((tlinfo.translated_version_number IS NULL)
                 AND (x_translated_version_number IS NULL)
                )
            )
        AND ((tlinfo.translated_grade = x_translated_grade)
             OR ((tlinfo.translated_grade IS NULL)
                 AND (x_translated_grade IS NULL)
                )
            )
        AND ((TRUNC (tlinfo.translated_dt) = TRUNC (x_translated_dt)) -- The translated_dt is made truncated to get the correctly. This is done as a part of bug #2310804
             OR ((tlinfo.translated_dt IS NULL)
                 AND (x_translated_dt IS NULL)
                )
            )
        AND (tlinfo.grading_period_cd = x_grading_period_cd)
        AND ((tlinfo.attribute_category = x_attribute_category)
             OR ((tlinfo.attribute_category IS NULL)
                 AND (x_attribute_category IS NULL)
                )
            )
        AND ((tlinfo.attribute1 = x_attribute1)
             OR ((tlinfo.attribute1 IS NULL)
                 AND (x_attribute1 IS NULL)
                )
            )
        AND ((tlinfo.attribute2 = x_attribute2)
             OR ((tlinfo.attribute2 IS NULL)
                 AND (x_attribute2 IS NULL)
                )
            )
        AND ((tlinfo.attribute3 = x_attribute3)
             OR ((tlinfo.attribute3 IS NULL)
                 AND (x_attribute3 IS NULL)
                )
            )
        AND ((tlinfo.attribute4 = x_attribute4)
             OR ((tlinfo.attribute4 IS NULL)
                 AND (x_attribute4 IS NULL)
                )
            )
        AND ((tlinfo.attribute5 = x_attribute5)
             OR ((tlinfo.attribute5 IS NULL)
                 AND (x_attribute5 IS NULL)
                )
            )
        AND ((tlinfo.attribute6 = x_attribute6)
             OR ((tlinfo.attribute6 IS NULL)
                 AND (x_attribute6 IS NULL)
                )
            )
        AND ((tlinfo.attribute7 = x_attribute7)
             OR ((tlinfo.attribute7 IS NULL)
                 AND (x_attribute7 IS NULL)
                )
            )
        AND ((tlinfo.attribute8 = x_attribute8)
             OR ((tlinfo.attribute8 IS NULL)
                 AND (x_attribute8 IS NULL)
                )
            )
        AND ((tlinfo.attribute9 = x_attribute9)
             OR ((tlinfo.attribute9 IS NULL)
                 AND (x_attribute9 IS NULL)
                )
            )
        AND ((tlinfo.attribute10 = x_attribute10)
             OR ((tlinfo.attribute10 IS NULL)
                 AND (x_attribute10 IS NULL)
                )
            )
        AND ((tlinfo.attribute11 = x_attribute11)
             OR ((tlinfo.attribute11 IS NULL)
                 AND (x_attribute11 IS NULL)
                )
            )
        AND ((tlinfo.attribute12 = x_attribute12)
             OR ((tlinfo.attribute12 IS NULL)
                 AND (x_attribute12 IS NULL)
                )
            )
        AND ((tlinfo.attribute13 = x_attribute13)
             OR ((tlinfo.attribute13 IS NULL)
                 AND (x_attribute13 IS NULL)
                )
            )
        AND ((tlinfo.attribute14 = x_attribute14)
             OR ((tlinfo.attribute14 IS NULL)
                 AND (x_attribute14 IS NULL)
                )
            )
        AND ((tlinfo.attribute15 = x_attribute15)
             OR ((tlinfo.attribute15 IS NULL)
                 AND (x_attribute15 IS NULL)
                )
            )
        AND ((tlinfo.attribute16 = x_attribute16)
             OR ((tlinfo.attribute16 IS NULL)
                 AND (x_attribute16 IS NULL)
                )
            )
        AND ((tlinfo.attribute17 = x_attribute17)
             OR ((tlinfo.attribute17 IS NULL)
                 AND (x_attribute17 IS NULL)
                )
            )
        AND ((tlinfo.attribute18 = x_attribute18)
             OR ((tlinfo.attribute18 IS NULL)
                 AND (x_attribute18 IS NULL)
                )
            )
        AND ((tlinfo.attribute19 = x_attribute19)
             OR ((tlinfo.attribute19 IS NULL)
                 AND (x_attribute19 IS NULL)
                )
            )
        AND ((tlinfo.attribute20 = x_attribute20)
             OR ((tlinfo.attribute20 IS NULL)
                 AND (x_attribute20 IS NULL)
                )
            )
        AND ((TRUNC (tlinfo.incomp_deadline_date) = TRUNC (x_incomp_deadline_date))
             OR ((tlinfo.incomp_deadline_date IS NULL)
                 AND (x_incomp_deadline_date IS NULL)
                )
            )
        AND ((tlinfo.incomp_grading_schema_cd = x_incomp_grading_schema_cd)
             OR ((tlinfo.incomp_grading_schema_cd IS NULL)
                 AND (x_incomp_grading_schema_cd IS NULL)
                )
            )
        AND ((tlinfo.incomp_version_number = x_incomp_version_number)
             OR ((tlinfo.incomp_version_number IS NULL)
                 AND (x_incomp_version_number IS NULL)
                )
            )
        AND ((tlinfo.incomp_default_grade = x_incomp_default_grade)
             OR ((tlinfo.incomp_default_grade IS NULL)
                 AND (x_incomp_default_grade IS NULL)
                )
            )
        AND ((tlinfo.incomp_default_mark = x_incomp_default_mark)
             OR ((tlinfo.incomp_default_mark IS NULL)
                 AND (x_incomp_default_mark IS NULL)
                )
            )
        AND ((tlinfo.comments = x_comments)
             OR ((tlinfo.comments IS NULL)
                 AND (x_comments IS NULL)
                )
            )
        AND ((tlinfo.mark_capped_flag = x_mark_capped_flag)
             OR ((tlinfo.mark_capped_flag IS NULL)
                 AND (x_mark_capped_flag IS NULL)
                )
            )
        AND ((tlinfo.release_date = x_release_date)
             OR ((tlinfo.release_date IS NULL)
                 AND (x_release_date IS NULL)
                )
            )
        AND ((tlinfo.manual_override_flag = x_manual_override_flag)
             OR ((tlinfo.manual_override_flag IS NULL)
                 AND (x_manual_override_flag IS NULL)
                )
            )
        AND ((tlinfo.show_on_academic_histry_flag = x_show_on_academic_histry_flag)
             OR ((tlinfo.show_on_academic_histry_flag IS NULL)
                 AND (x_show_on_academic_histry_flag IS NULL)
                )
            )
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_cal_type                     => x_cal_type,
      x_ci_end_dt                    => x_ci_end_dt,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_ci_start_dt                  => x_ci_start_dt,
      x_course_cd                    => x_course_cd,
      x_finalised_outcome_ind        => x_finalised_outcome_ind,
      x_grade                        => x_grade,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_mark                         => x_mark,
      x_number_times_keyed           => x_number_times_keyed,
      x_outcome_dt                   => x_outcome_dt,
      x_person_id                    => x_person_id,
      x_s_grade_creation_method_type => x_s_grade_creation_method_type,
      x_translated_dt                => x_translated_dt,
      x_translated_grade             => x_translated_grade,
      x_translated_grading_schema_cd => x_translated_grading_schema_cd,
      x_translated_version_number    => x_translated_version_number,
      x_unit_cd                      => x_unit_cd,
      x_version_number               => x_version_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_period_cd            => x_grading_period_cd,
      x_attribute_category           => x_attribute_category,
      x_attribute1                   => x_attribute1,
      x_attribute2                   => x_attribute2,
      x_attribute3                   => x_attribute3,
      x_attribute4                   => x_attribute4,
      x_attribute5                   => x_attribute5,
      x_attribute6                   => x_attribute6,
      x_attribute7                   => x_attribute7,
      x_attribute8                   => x_attribute8,
      x_attribute9                   => x_attribute9,
      x_attribute10                  => x_attribute10,
      x_attribute11                  => x_attribute11,
      x_attribute12                  => x_attribute12,
      x_attribute13                  => x_attribute13,
      x_attribute14                  => x_attribute14,
      x_attribute15                  => x_attribute15,
      x_attribute16                  => x_attribute16,
      x_attribute17                  => x_attribute17,
      x_attribute18                  => x_attribute18,
      x_attribute19                  => x_attribute19,
      x_attribute20                  => x_attribute20,
      x_incomp_deadline_date         => x_incomp_deadline_date,
      x_incomp_grading_schema_cd     => x_incomp_grading_schema_cd,
      x_incomp_version_number        => x_incomp_version_number,
      x_incomp_default_grade         => x_incomp_default_grade,
      x_incomp_default_mark          => x_incomp_default_mark,
      x_comments                     => x_comments,
      x_uoo_id                       => x_uoo_id,
      x_mark_capped_flag             => x_mark_capped_flag,
      x_release_date                 => x_release_date,
      x_manual_override_flag         => x_manual_override_flag,
      x_show_on_academic_histry_flag => x_show_on_academic_histry_flag
    );
    IF (X_MODE IN ('R', 'S')) THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;
    IF (x_mode = 'S') THEN
          igs_sc_gen_001.set_ctx('R');
    END IF;
    UPDATE igs_as_su_stmptout_all
       SET ci_start_dt = new_references.ci_start_dt,
           ci_end_dt = new_references.ci_end_dt,
           grading_schema_cd = new_references.grading_schema_cd,
           version_number = new_references.version_number,
           grade = new_references.grade,
           s_grade_creation_method_type = new_references.s_grade_creation_method_type,
           finalised_outcome_ind = new_references.finalised_outcome_ind,
           mark = new_references.mark,
           number_times_keyed = new_references.number_times_keyed,
           translated_grading_schema_cd = new_references.translated_grading_schema_cd,
           translated_version_number = new_references.translated_version_number,
           translated_grade = new_references.translated_grade,
           translated_dt = new_references.translated_dt,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           request_id = x_request_id,
           program_id = x_program_id,
           program_application_id = x_program_application_id,
           program_update_date = x_program_update_date,
           grading_period_cd = x_grading_period_cd,
           attribute_category = new_references.attribute_category,
           attribute1 = new_references.attribute1,
           attribute2 = new_references.attribute2,
           attribute3 = new_references.attribute3,
           attribute4 = new_references.attribute4,
           attribute5 = new_references.attribute5,
           attribute6 = new_references.attribute6,
           attribute7 = new_references.attribute7,
           attribute8 = new_references.attribute8,
           attribute9 = new_references.attribute9,
           attribute10 = new_references.attribute10,
           attribute11 = new_references.attribute11,
           attribute12 = new_references.attribute12,
           attribute13 = new_references.attribute13,
           attribute14 = new_references.attribute14,
           attribute15 = new_references.attribute15,
           attribute16 = new_references.attribute16,
           attribute17 = new_references.attribute17,
           attribute18 = new_references.attribute18,
           attribute19 = new_references.attribute19,
           attribute20 = new_references.attribute20,
           incomp_deadline_date = new_references.incomp_deadline_date,
           incomp_grading_schema_cd = new_references.incomp_grading_schema_cd,
           incomp_version_number = new_references.incomp_version_number,
           incomp_default_grade = new_references.incomp_default_grade,
           incomp_default_mark = new_references.incomp_default_mark,
           comments = new_references.comments,
           mark_capped_flag = new_references.mark_capped_flag,
           release_date = new_references.release_date,
           manual_override_flag = new_references.manual_override_flag,
           show_on_academic_histry_flag = new_references.show_on_academic_histry_flag
     WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    after_dml (p_action => 'UPDATE', x_rowid => x_rowid);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2,
    x_grading_period_cd            IN     VARCHAR2,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_incomp_deadline_date         IN     DATE,
    x_incomp_grading_schema_cd     IN     VARCHAR2,
    x_incomp_version_number        IN     NUMBER,
    x_incomp_default_grade         IN     VARCHAR2,
    x_incomp_default_mark          IN     NUMBER,
    x_comments                     IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2,
    x_release_date                 IN     DATE,
    x_manual_override_flag         IN     VARCHAR2,
    x_show_on_academic_histry_flag IN     VARCHAR2
  ) AS
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_as_su_stmptout_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    outcome_dt = x_outcome_dt
      AND    grading_period_cd = x_grading_period_cd
      AND    uoo_id = x_uoo_id;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_org_id,
        x_person_id,
        x_course_cd,
        x_unit_cd,
        x_cal_type,
        x_ci_sequence_number,
        x_outcome_dt,
        x_ci_start_dt,
        x_ci_end_dt,
        x_grading_schema_cd,
        x_version_number,
        x_grade,
        x_s_grade_creation_method_type,
        x_finalised_outcome_ind,
        x_mark,
        x_number_times_keyed,
        x_translated_grading_schema_cd,
        x_translated_version_number,
        x_translated_grade,
        x_translated_dt,
        x_mode,
        x_grading_period_cd,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_incomp_deadline_date,
        x_incomp_grading_schema_cd,
        x_incomp_version_number,
        x_incomp_default_grade,
        x_incomp_default_mark,
        x_comments,
        x_uoo_id,
        x_mark_capped_flag,
        x_release_date,
        x_manual_override_flag,
        x_show_on_academic_histry_flag
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_outcome_dt,
      x_ci_start_dt,
      x_ci_end_dt,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_s_grade_creation_method_type,
      x_finalised_outcome_ind,
      x_mark,
      x_number_times_keyed,
      x_translated_grading_schema_cd,
      x_translated_version_number,
      x_translated_grade,
      x_translated_dt,
      x_mode,
      x_grading_period_cd,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_incomp_deadline_date,
      x_incomp_grading_schema_cd,
      x_incomp_version_number,
      x_incomp_default_grade,
      x_incomp_default_mark,
      x_comments,
      x_uoo_id,
      x_mark_capped_flag,
      x_release_date,
      x_manual_override_flag,
      x_show_on_academic_histry_flag
    );
  END add_row;

  PROCEDURE delete_row (x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2) AS
  BEGIN
    before_dml (p_action => 'DELETE', x_rowid => x_rowid);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  DELETE FROM igs_as_su_stmptout_all
          WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    after_dml (p_action => 'DELETE', x_rowid => x_rowid);
  END delete_row;

  PROCEDURE check_constraints (column_name IN VARCHAR2, column_value IN VARCHAR2) AS
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER (column_name) = 'PERSON_ID' THEN
      new_references.person_id := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'VERSION_NUMBER' THEN
      new_references.version_number := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'MARK' THEN
      new_references.mark := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'FINALISED_OUTCOME_IND' THEN
      new_references.finalised_outcome_ind := column_value;
    ELSIF UPPER (column_name) = 'TRANSLATED_VERSION_NUMBER' THEN
      new_references.translated_version_number := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'NUMBER_TIMES_KEYED' THEN
      new_references.number_times_keyed := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'CI_SEQUENCE_NUMBER' THEN
      new_references.ci_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF UPPER (column_name) = 'CAL_TYPE' THEN
      new_references.cal_type := column_value;
    ELSIF UPPER (column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
    ELSIF UPPER (column_name) = 'FINALISED_OUTCOME_IND' THEN
      new_references.finalised_outcome_ind := column_value;
    ELSIF UPPER (column_name) = 'GRADE' THEN
      new_references.grade := column_value;
    ELSIF UPPER (column_name) = 'GRADING_SCHEMA_CD' THEN
      new_references.grading_schema_cd := column_value;
    ELSIF UPPER (column_name) = 'S_GRADE_CREATION_METHOD_TYPE' THEN
      new_references.s_grade_creation_method_type := column_value;
    ELSIF UPPER (column_name) = 'TRANSLATED_GRADE' THEN
      new_references.translated_grade := column_value;
    ELSIF UPPER (column_name) = 'TRANSLATED_GRADING_SCHEMA_CD' THEN
      new_references.translated_grading_schema_cd := column_value;
    ELSIF UPPER (column_name) = 'UNIT_CD' THEN
      new_references.unit_cd := column_value;
    ELSIF UPPER (column_name) = 'GRADING_PERIOD_CD' THEN
      new_references.grading_period_cd := column_value;
    END IF;
    IF UPPER (column_name) = 'PERSON_ID'
       OR column_name IS NULL THEN
      IF new_references.person_id < 0
         OR new_references.person_id > 9999999999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'VERSION_NUMBER'
       OR column_name IS NULL THEN
      IF new_references.version_number < 0
         OR new_references.version_number > 999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'MARK'
       OR column_name IS NULL THEN
      IF new_references.mark < 0
         OR new_references.mark > 999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'FINALISED_OUTCOME_IND'
       OR column_name IS NULL THEN
      IF new_references.finalised_outcome_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'TRANSLATED_VERSION_NUMBER'
       OR column_name IS NULL THEN
      IF new_references.translated_version_number < 0
         OR new_references.translated_version_number > 999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'NUMBER_TIMES_KEYED'
       OR column_name IS NULL THEN
      IF new_references.number_times_keyed < 0
         OR new_references.number_times_keyed > 99 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'CI_SEQUENCE_NUMBER'
       OR column_name IS NULL THEN
      IF new_references.ci_sequence_number < 0
         OR new_references.ci_sequence_number > 999999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'CAL_TYPE'
       OR column_name IS NULL THEN
      IF new_references.cal_type <> UPPER (new_references.cal_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'COURSE_CD'
       OR column_name IS NULL THEN
      IF new_references.course_cd <> UPPER (new_references.course_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'GRADE'
       OR column_name IS NULL THEN
      IF new_references.grade <> UPPER (new_references.grade) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'GRADING_SCHEMA_CD'
       OR column_name IS NULL THEN
      IF new_references.grading_schema_cd <> UPPER (new_references.grading_schema_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'S_GRADE_CREATION_METHOD_TYPE'
       OR column_name IS NULL THEN
      IF new_references.s_grade_creation_method_type <> UPPER (new_references.s_grade_creation_method_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'TRANSLATED_GRADE'
       OR column_name IS NULL THEN
      IF new_references.translated_grade <> UPPER (new_references.translated_grade) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'TRANSLATED_GRADING_SCHEMA_CD'
       OR column_name IS NULL THEN
      IF new_references.translated_grading_schema_cd <> UPPER (new_references.translated_grading_schema_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UNIT_CD'
       OR column_name IS NULL THEN
      IF new_references.unit_cd <> UPPER (new_references.unit_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'GRADING_PERIOD_CD'
       OR column_name IS NULL THEN
      IF new_references.grading_period_cd <> UPPER (new_references.grading_period_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_constraints;
END igs_as_su_stmptout_pkg;

/
