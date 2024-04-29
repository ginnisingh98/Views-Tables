--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_006" AS
/* $Header: IGSAS06B.pls 120.1 2006/01/18 22:52:59 swaghmar noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When    What
  -- lkaki    19-Nov-2004  Added one more parameter to the procedure 'assp_ins_admin_grds'
  --                       to assign the grades for audited unit attempts separately.
  --                       For this purpose,added one more cursor to handle audited grades
  --                       'c_grading_schema_audit_grade' and changed the existing cursor definition 'c_grading_schema_grade'
  --                       to exclude audited grades and retrieve only non-audited ones.
  -- kdande 23-Jan-2004 Removed app_exception.raise_exception since the message
  --                    being logged is a proper message and not an exception.
  -- ijeddy, Dec 3, 2003        Grade Book Enh build, bug no 3201661
  -- gmaheswa    13-nov-2003     Bug No. 3227107 . Address changes. Modified address related cursor to select active records only.
  -- smadathi    28-AUG-2001     Bug No. 1956374 .The call to igs_as_val_esvs.genp_val_staff_prsn
  --                            is changed to igs_ad_val_acai.genp_val_staff_prsn
  -- bayadav    28-DEC-2001     added code to include newly added columns in IGS_AS_GRD_GRADE as a part of bug 2162831
  -- svenkata   7-JAN-2002      Bug No. 2172405  Standard Flex Field columns have been added
  --                            to table handler procedure calls as part of CCR - ENCR022.
  -- Aiyer      08-APR-2002     Bug No. 2124034. The parameter p_reproduce was also added as a hidden parameter in the
  --                            concurrent job IGSASJ05 Produce Student Assignment Cover Sheet with a default value as 'NO'.
  --                            In the package body of porocedure too it was made to have a default value of 'NO'.
  --swaghmar    16-Jan-2006    Bug# 4951054  Added check for disabling UI's
  -------------------------------------------------------------------------------------------------------------------------
  -- As part of the bug# 1956374 prcodure assp_val_actv_stdnt is changed
  x_rowid VARCHAR2(25);
  l_AT_ID IGS_AS_DUE_DT_SUMRY.AT_ID%type;
  g_module_head CONSTANT VARCHAR2(40) := 'igs.plsql.igs_as_gen_006.';

 PROCEDURE assp_get_ese_key(
  p_exam_cal_type IN OUT NOCOPY VARCHAR2 ,
  p_exam_ci_sequence_number IN OUT NOCOPY NUMBER ,
  p_dt_alias IN OUT NOCOPY VARCHAR2 ,
  p_dai_sequence_number IN OUT NOCOPY NUMBER ,
  p_start_time IN OUT NOCOPY DATE ,
  p_end_time IN OUT NOCOPY DATE ,
  p_ese_id IN OUT NOCOPY NUMBER )
IS
BEGIN   --assp_get_ese_key
        --This module retrieves one of IGS_AS_EXAM_SESSION unique identifiers:
        --1. exam_cal_type, exam_ci_sequence_number, dt_alias, dai_sequence_number,
        --    start_time, end_time
        --2. ese_id
DECLARE
        v_exam_cal_type                 IGS_AS_EXAM_SESSION.exam_cal_type%TYPE;
        v_exam_ci_sequence_number       IGS_AS_EXAM_SESSION.exam_ci_sequence_number%TYPE;
        v_dt_alias                      IGS_AS_EXAM_SESSION.dt_alias%TYPE;
        v_dai_sequence_number           IGS_AS_EXAM_SESSION.dai_sequence_number%TYPE;
        v_start_time                    IGS_AS_EXAM_SESSION.start_time%TYPE;
        v_end_time                      IGS_AS_EXAM_SESSION.end_time%TYPE;
        v_ese_id                        IGS_AS_EXAM_SESSION.ese_id%TYPE;
        CURSOR c_ese IS
                SELECT  ese.ese_id
                FROM    IGS_AS_EXAM_SESSION ese
                WHERE   exam_cal_type           = p_exam_cal_type               AND
                        exam_ci_sequence_number = p_exam_ci_sequence_number     AND
                        dt_alias                = p_dt_alias                    AND
                        dai_sequence_number     = p_dai_sequence_number         AND
                        start_time              = p_start_time                  AND
                        end_time                = p_end_time;
        CURSOR c_ese2 IS
                SELECT  exam_cal_type,
                        exam_ci_sequence_number,
                        dt_alias,
                        dai_sequence_number,
                        start_time,
                        end_time
                FROM    IGS_AS_EXAM_SESSION ese
                WHERE   ese_id = p_ese_id;
BEGIN
        --Check if p_exam_cal_type has been passed
        IF (p_exam_cal_type IS NOT NULL) THEN
                OPEN c_ese;
                FETCH c_ese INTO v_ese_id;
                IF (c_ese%FOUND) THEN
                        p_ese_id := v_ese_id;
                END IF;
                CLOSE c_ese;
        --Check if p_ese_id has been passed
        ELSIF (p_ese_id IS NOT NULL) THEN
                        OPEN c_ese2;
                        FETCH c_ese2 INTO       v_exam_cal_type,
                                                v_exam_ci_sequence_number,
                                                v_dt_alias,
                                                v_dai_sequence_number,
                                                v_start_time,
                                                v_end_time;
                        IF (c_ese2%FOUND) THEN
                                p_exam_cal_type                 := v_exam_cal_type;
                                p_exam_ci_sequence_number       := v_exam_ci_sequence_number;
                                p_dt_alias                      := v_dt_alias;
                                p_dai_sequence_number           := v_dai_sequence_number;
                                p_start_time                    := v_start_time;
                                p_end_time                      := v_end_time;
                        END IF;
                        CLOSE c_ese2;
        ELSE
                p_exam_cal_type                 := NULL;
                p_exam_ci_sequence_number       := NULL;
                p_dt_alias                      := NULL;
                p_dai_sequence_number           := NULL;
                p_start_time                    := NULL;
                p_end_time                      := NULL;
                p_ese_id                        := NULL;
        END IF;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_get_ese_key');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END assp_get_ese_key;
  --
  -- Process to insert administrative grades against student unit attempts which
  -- have no grade recorded.
  -- This process can be used to either default grades for non-assessable unit
  -- attempts, or to insert 'holding' grades against unit attempts for which
  -- grades simply haven't yet been supplied. This may be done prior to result
  -- release to prevent the students being shown blank grades.
  --
  PROCEDURE assp_ins_admin_grds (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_assess_calendar              IN     VARCHAR2,
    p_teaching_calendar            IN     VARCHAR2,
    p_org_unt_cd                   IN     VARCHAR2,
    p_unt_cd                       IN     VARCHAR2,
    p_lctn_cd                      IN     VARCHAR2,
    p_unt_md                       IN     VARCHAR2,
    p_unt_cls                      IN     VARCHAR2,
    p_insert_default_ind           IN     VARCHAR2,
    p_grade                        IN     VARCHAR2,
    p_finalised_ind                IN     VARCHAR2,
    p_assble_type                  IN     VARCHAR2,
    p_no_assmnt_type               IN     VARCHAR2,
    p_org_id                       IN     NUMBER,
    --added by lkaki--
    p_audit_grade                  IN     VARCHAR2 DEFAULT NULL
  ) IS
    --
    p_assess_cal_type           igs_ca_inst.cal_type%TYPE;
    p_assess_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
    p_teach_cal_type            igs_ca_inst.cal_type%TYPE;
    p_teach_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
    p_org_unit_cd               igs_or_unit.org_unit_cd%TYPE;
    p_unit_cd                   igs_ps_unit.unit_cd%TYPE;
    p_location_cd               igs_ad_location.location_cd%TYPE;
    p_unit_mode                 igs_as_unit_mode.unit_mode%TYPE;
    p_unit_class                igs_as_unit_class.unit_class%TYPE;
    p_assessable_type           igs_lookups_view.lookup_code%TYPE;
    p_no_assessment_type        igs_lookups_view.lookup_code%TYPE;
    --
  BEGIN -- assp_ins_admin_grds
    --
    IGS_GE_GEN_003.set_org_id(); -- swaghmar, bug# 4951054

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure,
        g_module_head || 'assp_ins_admin_grds.begin',
        'In Params : p_assess_calendar => ' || p_assess_calendar || ';' ||
        'p_teaching_calendar => ' || p_teaching_calendar || ';' ||
        'p_org_unt_cd => ' || p_org_unt_cd || ';' ||
        'p_unt_cd => ' || p_unt_cd || ';' ||
        'p_lctn_cd => ' || p_lctn_cd || ';' ||
        'p_unt_md => ' || p_unt_md || ';' ||
        'p_unt_cls => ' || p_unt_cls || ';' ||
        'p_insert_default_ind => ' || p_insert_default_ind || ';' ||
        'p_grade => ' || p_grade || ';' ||
        'p_finalised_ind => ' || p_finalised_ind || ';' ||
        'p_assble_type => ' || p_assble_type || ';' ||
        'p_no_assmnt_type => ' || p_no_assmnt_type || ';' ||
        'p_org_id => ' || p_org_id || ';' ||
        'p_audit_grade => ' || p_audit_grade
      );
    END IF;
    --
    igs_ge_gen_003.set_org_id (p_org_id);
    --
    retcode := 0;
    p_org_unit_cd := NVL (p_org_unt_cd, '%');
    p_unit_cd := NVL (p_unt_cd, '%');
    p_location_cd := NVL (p_lctn_cd, '%');
    p_unit_mode := NVL (p_unt_md, '%');
    p_unit_class := NVL (p_unt_cls, '%');
    p_assessable_type := NVL (p_assble_type, '%');
    p_no_assessment_type := NVL (p_no_assmnt_type, '%');
    --
    DECLARE
      invalid_parameter EXCEPTION;
    BEGIN
      /*changed by lkaki*/
      --
      IF (p_insert_default_ind = 'N'
          AND (p_grade IS NULL
               AND p_audit_grade IS NULL)) THEN
        errbuf := fnd_message.get_string ('IGS', 'IGS_AS_GRD_SPECIFIED');
        RAISE invalid_parameter;
      END IF;
      --
      IF p_assess_calendar IS NULL THEN
        p_assess_cal_type := NULL;
        p_assess_ci_sequence_number := NULL;
      ELSE
        p_assess_cal_type := RTRIM (SUBSTR (p_assess_calendar, 101, 10));
        p_assess_ci_sequence_number := TO_NUMBER (RTRIM (SUBSTR (p_assess_calendar, 112, 6)));
      END IF;
      --
      IF p_teaching_calendar IS NULL THEN
        p_teach_cal_type := NULL;
        p_teach_ci_sequence_number := NULL;
      ELSE
        p_teach_cal_type := RTRIM (SUBSTR (p_teaching_calendar, 101, 10));
        p_teach_ci_sequence_number := TO_NUMBER (RTRIM (SUBSTR (p_teaching_calendar, 112, 6)));
      END IF;
      --
      IF ((p_assess_calendar IS NOT NULL) AND
          (p_teaching_calendar IS NOT NULL)) THEN
        IF (igs_en_gen_014.enrs_get_within_ci (
              p_assess_cal_type,
              p_assess_ci_sequence_number,
              p_teach_cal_type,
              p_teach_ci_sequence_number,
              'N'
            ) <> 'Y'
           ) THEN
          errbuf := fnd_message.get_string ('IGS', 'IGS_AS_TEACHCAL_NOT_EXIST');
          RAISE invalid_parameter;
        END IF;
      END IF;
      --
      IF (p_unit_mode <> '%'
          AND p_unit_class <> '%') THEN
        errbuf := fnd_message.get_string ('IGS', 'IGS_AS_UNITMODE_OR_UNITCLASS');
        RAISE invalid_parameter;
      END IF;
    EXCEPTION
      WHEN invalid_parameter THEN
        retcode := 2;
        RETURN;
    END;
    --
    --
    --
    DECLARE
      i                   BINARY_INTEGER                             DEFAULT 0;
      n                   BINARY_INTEGER                             DEFAULT 0;
      v_record_found      BOOLEAN                                    DEFAULT FALSE;
      v_grade             igs_as_grd_sch_grade.grade%TYPE;
      --added another variable to handle audit grades for audited attempts--
      v_audit_grade       igs_as_grd_sch_grade.grade%TYPE;
      v_grading_schema    igs_as_grd_schema.grading_schema_cd%TYPE;
      v_gs_version_number igs_as_grd_schema.version_number%TYPE;
      v_insert_grade      igs_as_grd_sch_grade.grade%TYPE;
      --
      -- Get all the Student Unit Attempts that do not have any Unit Attempt Outcome
      -- and match the criteria passed thru parameters
      --
      CURSOR c_stu_unit_atmpt (
        cp_assess_cal_type                    igs_ca_inst.cal_type%TYPE,
        cp_assess_sequence_number             igs_ca_inst.sequence_number%TYPE,
        cp_teach_cal_type                     igs_ca_inst.cal_type%TYPE,
        cp_teach_sequence_number              igs_ca_inst.sequence_number%TYPE,
        cp_org_unit_cd                        igs_or_unit.org_unit_cd%TYPE,
        cp_unit_cd                            igs_ps_unit.unit_cd%TYPE,
        cp_location_cd                        igs_ad_location.location_cd%TYPE,
        cp_unit_mode                          igs_as_unit_class.unit_mode%TYPE,
        cp_unit_class                         igs_as_unit_class.unit_class%TYPE,
        cp_assessable_type                    igs_as_assessmnt_typ.assessment_type%TYPE,
        cp_no_assessment_type                 igs_en_su_attempt.no_assessment_ind%TYPE
      ) IS
        SELECT sua.person_id,
               sua.course_cd,
               sua.unit_cd,
               sua.version_number,
               sua.cal_type,
               sua.ci_sequence_number,
               sua.location_cd,
               sua.unit_class,
               sua.ci_start_dt,
               sua.ci_end_dt,
               sua.uoo_id,
               sua.no_assessment_ind
        FROM   igs_en_su_attempt_all sua,
               igs_ps_unit_ver_all uv,
               igs_as_unit_class_all uc
        WHERE  ((cp_assess_cal_type IS NOT NULL
                 AND EXISTS (
                      SELECT 'x'
                      FROM   igs_ca_inst_rel
                      WHERE  sub_cal_type = sua.cal_type
                      AND    sub_ci_sequence_number = sua.ci_sequence_number
                      AND    sup_cal_type = cp_assess_cal_type
                      AND    sup_ci_sequence_number = cp_assess_sequence_number)
                )
                OR (cp_assess_cal_type IS NULL)
               )
        AND    ((cp_teach_cal_type IS NOT NULL
                 AND cp_teach_sequence_number IS NOT NULL
                 AND sua.cal_type = cp_teach_cal_type
                 AND sua.ci_sequence_number = cp_teach_sequence_number
                )
                OR (cp_teach_cal_type IS NULL)
               )
        AND    sua.unit_attempt_status = 'ENROLLED'
        AND    (((cp_no_assessment_type <> '%')
                 AND ((cp_no_assessment_type = 'A'
                       AND sua.no_assessment_ind <> 'Y')
                      OR (cp_no_assessment_type = 'N'
                          AND sua.no_assessment_ind <> 'N')
                     )
                )
                OR (cp_no_assessment_type = '%')
               )
        AND    sua.unit_cd LIKE cp_unit_cd
        AND    sua.location_cd LIKE cp_location_cd
        AND    sua.unit_class LIKE cp_unit_class
        AND    NOT EXISTS (
                      SELECT 1
                      FROM   igs_as_su_stmptout_all suao
                      WHERE  suao.person_id = sua.person_id
                      AND    suao.course_cd = sua.course_cd
                      AND    suao.uoo_id = sua.uoo_id)
        AND    uv.unit_cd = sua.unit_cd
        AND    uv.version_number = sua.version_number
        AND    uv.owner_org_unit_cd LIKE cp_org_unit_cd
        AND    (((cp_assessable_type <> '%')
                 AND ((cp_assessable_type = 'A'
                       AND uv.assessable_ind = 'Y')
                      OR (cp_assessable_type = 'N'
                          AND uv.assessable_ind = 'N')
                     )
                )
                OR (cp_assessable_type = '%')
               )
        AND    uc.unit_class = sua.unit_class
        AND    uc.unit_mode LIKE cp_unit_mode;
      --
      -- Changed the defn of this cursor to exclude audited grades
      --
      CURSOR c_grading_schema_grade (
        cp_grading_schema                     igs_as_grd_schema.grading_schema_cd%TYPE,
        cp_gs_version_number                  igs_as_grd_schema.version_number%TYPE
      ) IS
        SELECT gsg.grade
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = cp_grading_schema
        AND    gsg.version_number = cp_gs_version_number
        AND    gsg.dflt_outstanding_ind = 'Y'
        AND    gsg.s_result_type <> 'AUDIT'
        AND    gsg.closed_ind = 'N';
      --
      v_grading_schema_grade_rec c_grading_schema_grade%ROWTYPE;
      --
      -- Added one more cursor to handle audited grades
      --
      CURSOR c_grading_schema_audit_grade (
        cp_grading_schema                     igs_as_grd_schema.grading_schema_cd%TYPE,
        cp_gs_version_number                  igs_as_grd_schema.version_number%TYPE
      ) IS
        SELECT gsg.grade
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = cp_grading_schema
        AND    gsg.version_number = cp_gs_version_number
        AND    gsg.dflt_outstanding_ind = 'Y'
        AND    gsg.s_result_type = 'AUDIT'
        AND    gsg.closed_ind = 'N';
      --
      --
      --
      PROCEDURE assp_insertgrade (
        p_person_id                           igs_en_su_attempt.person_id%TYPE,
        p_course_cd                           igs_en_su_attempt.course_cd%TYPE,
        p_unit_cd                             igs_en_su_attempt.unit_cd%TYPE,
        p_cal_type                            igs_en_su_attempt.cal_type%TYPE,
        p_ci_sequence_number                  igs_en_su_attempt.ci_sequence_number%TYPE,
        p_ci_start_dt                         igs_en_su_attempt.ci_start_dt%TYPE,
        p_ci_end_dt                           igs_en_su_attempt.ci_end_dt%TYPE,
        p_outcome_dt                          igs_as_su_stmptout.outcome_dt%TYPE,
        p_s_grade_creation_method_type        igs_as_su_stmptout.s_grade_creation_method_type%TYPE,
        p_grading_schema_cd                   igs_as_su_stmptout.grading_schema_cd%TYPE,
        p_version_number                      igs_as_su_stmptout.version_number%TYPE,
        p_grade                               igs_as_su_stmptout.grade%TYPE,
        p_finalised_outcome_ind               igs_as_su_stmptout.finalised_outcome_ind%TYPE,
        p_uoo_id                              igs_en_su_attempt.uoo_id%TYPE
      ) IS
      --
        CURSOR cur_person_detail (cp_person_id NUMBER) IS
          SELECT party_number
          FROM   hz_parties
          WHERE  party_id = cp_person_id;
        rec_person_detail cur_person_detail%ROWTYPE;
      --
      BEGIN
        --
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_procedure,
            g_module_head || 'assp_ins_admin_grds.assp_insertgrade.begin',
            'In Params : p_person_id => ' || p_person_id || ';' ||
            'p_course_cd => ' || p_course_cd || ';' ||
            'p_unit_cd => ' || p_unit_cd || ';' ||
            'p_cal_type => ' || p_cal_type || ';' ||
            'p_ci_sequence_number => ' || p_ci_sequence_number || ';' ||
            'p_ci_start_dt => ' || p_ci_start_dt || ';' ||
            'p_ci_end_dt => ' || p_ci_end_dt || ';' ||
            'p_outcome_dt => ' || p_outcome_dt || ';' ||
            'p_s_grade_creation_method_type => ' || p_s_grade_creation_method_type || ';' ||
            'p_grading_schema_cd => ' || p_grading_schema_cd || ';' ||
            'p_version_number => ' || p_version_number || ';' ||
            'p_grade => ' || p_grade || ';' ||
            'p_finalised_outcome_ind => ' || p_finalised_outcome_ind || ';' ||
            'p_uoo_id => ' || p_uoo_id
          );
        END IF;
        --
        x_rowid := NULL;
        BEGIN
          --
          OPEN cur_person_detail (p_person_id);
          FETCH cur_person_detail INTO rec_person_detail;
          CLOSE cur_person_detail;
          --
          fnd_file.put_line (fnd_file.log, rec_person_detail.party_number || '; ' || p_course_cd || '; ' || p_uoo_id || '; ' || p_unit_cd || '; ' || p_cal_type || '; ' || p_ci_sequence_number);
          --
          SAVEPOINT s_before_suao_creation;
          igs_as_su_stmptout_pkg.insert_row (
            x_rowid                        => x_rowid,
            x_org_id                       => p_org_id,
            x_person_id                    => p_person_id,
            x_course_cd                    => p_course_cd,
            x_unit_cd                      => p_unit_cd,
            x_cal_type                     => p_cal_type,
            x_ci_sequence_number           => p_ci_sequence_number,
            x_outcome_dt                   => p_outcome_dt,
            x_ci_start_dt                  => p_ci_start_dt,
            x_ci_end_dt                    => p_ci_end_dt,
            x_grading_schema_cd            => p_grading_schema_cd,
            x_version_number               => p_version_number,
            x_grade                        => p_grade,
            x_s_grade_creation_method_type => p_s_grade_creation_method_type,
            x_finalised_outcome_ind        => p_finalised_outcome_ind,
            x_mark                         => NULL,
            x_number_times_keyed           => NULL,
            x_translated_grading_schema_cd => NULL,
            x_translated_version_number    => NULL,
            x_translated_grade             => NULL,
            x_translated_dt                => NULL,
            x_mode                         => 'R',
            x_attribute_category           => NULL,
            x_attribute1                   => NULL,
            x_attribute2                   => NULL,
            x_attribute3                   => NULL,
            x_attribute4                   => NULL,
            x_attribute5                   => NULL,
            x_attribute6                   => NULL,
            x_attribute7                   => NULL,
            x_attribute8                   => NULL,
            x_attribute9                   => NULL,
            x_attribute10                  => NULL,
            x_attribute11                  => NULL,
            x_attribute12                  => NULL,
            x_attribute13                  => NULL,
            x_attribute14                  => NULL,
            x_attribute15                  => NULL,
            x_attribute16                  => NULL,
            x_attribute17                  => NULL,
            x_attribute18                  => NULL,
            x_attribute19                  => NULL,
            x_attribute20                  => NULL,
            x_uoo_id                       => p_uoo_id,
            x_mark_capped_flag             => 'N',
            x_show_on_academic_histry_flag => 'Y',
            x_release_date                 => NULL,
            x_manual_override_flag         => 'N',
            x_incomp_deadline_date         => NULL,
            x_incomp_grading_schema_cd     => NULL,
            x_incomp_version_number        => NULL,
            x_incomp_default_grade         => NULL,
            x_incomp_default_mark          => NULL,
            x_comments                     => NULL,
            x_grading_period_cd            => 'FINAL'
          );
          --
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || 'assp_ins_admin_grds.assp_insertgrade.created_outcome',
              'Created Outcome for ' || p_person_id || ';' || p_course_cd || ';' || p_uoo_id
            );
          END IF;
          --
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO s_before_suao_creation;
            fnd_file.put_line (fnd_file.log, '  -> ' || SQLERRM);
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_exception,
                g_module_head || 'assp_ins_admin_grds.assp_insertgrade.insert_exception',
                'SQLERRM => ' || SQLERRM
              );
            END IF;
        END;
      EXCEPTION
        WHEN OTHERS THEN
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_exception,
              g_module_head || 'assp_ins_admin_grds.assp_insertgrade.exception',
              'SQLERRM => ' || SQLERRM
            );
          END IF;
      END assp_insertgrade;
      --
      --
      --
      PROCEDURE assp_findgrade (
        p_person_id                           igs_en_su_attempt.person_id%TYPE,
        p_course_cd                           igs_en_su_attempt.course_cd%TYPE,
        p_unit_cd                             igs_en_su_attempt.unit_cd%TYPE,
        p_cal_type                            igs_en_su_attempt.cal_type%TYPE,
        p_ci_sequence_number                  igs_en_su_attempt.ci_sequence_number%TYPE,
        p_ci_start_dt                         igs_en_su_attempt.ci_start_dt%TYPE,
        p_ci_end_dt                           igs_en_su_attempt.ci_end_dt%TYPE,
        p_outcome_dt                          igs_as_su_stmptout.outcome_dt%TYPE,
        p_s_grade_creation_method_type        igs_as_su_stmptout.s_grade_creation_method_type%TYPE,
        p_grading_schema_cd                   igs_as_su_stmptout.grading_schema_cd%TYPE,
        p_version_number                      igs_as_su_stmptout.version_number%TYPE,
        p_grade                               igs_as_su_stmptout.grade%TYPE,
        p_finalised_outcome_ind               igs_as_su_stmptout.finalised_outcome_ind%TYPE,
        j                                     BINARY_INTEGER,
        p_uoo_id                              igs_en_su_attempt.uoo_id%TYPE
      ) IS
        --
        CURSOR c_grading_schema_grade (
          cp_grading_schema                     igs_as_grd_sch_grade.grading_schema_cd%TYPE,
          cp_gs_version_number                  igs_as_grd_sch_grade.version_number%TYPE,
          cp_grade                              igs_as_grd_sch_grade.grade%TYPE
        ) IS
          SELECT gsg.grade
          FROM   igs_as_grd_sch_grade gsg
          WHERE  gsg.grading_schema_cd = cp_grading_schema
          AND    gsg.version_number = cp_gs_version_number
          AND    gsg.grade = cp_grade;
        --
      BEGIN
        --
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_procedure,
            g_module_head || 'assp_ins_admin_grds.assp_findgrade.begin',
            'In Params : p_person_id => ' || p_person_id || ';' ||
            'p_course_cd => ' || p_course_cd || ';' ||
            'p_unit_cd => ' || p_unit_cd || ';' ||
            'p_cal_type => ' || p_cal_type || ';' ||
            'p_ci_sequence_number => ' || p_ci_sequence_number || ';' ||
            'p_ci_start_dt => ' || p_ci_start_dt || ';' ||
            'p_ci_end_dt => ' || p_ci_end_dt || ';' ||
            'p_outcome_dt => ' || p_outcome_dt || ';' ||
            'p_s_grade_creation_method_type => ' || p_s_grade_creation_method_type || ';' ||
            'p_grading_schema_cd => ' || p_grading_schema_cd || ';' ||
            'p_version_number => ' || p_version_number || ';' ||
            'p_grade => ' || p_grade || ';' ||
            'p_finalised_outcome_ind => ' || p_finalised_outcome_ind || ';' ||
            'p_uoo_id => ' || p_uoo_id
          );
        END IF;
        --
        IF (p_grade IS NOT NULL) THEN
          OPEN c_grading_schema_grade (p_grading_schema_cd, p_version_number, p_grade);
          FETCH c_grading_schema_grade INTO v_grade;
          IF (c_grading_schema_grade%NOTFOUND) THEN
            CLOSE c_grading_schema_grade;
            --
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_statement,
                g_module_head || 'assp_ins_admin_grds.assp_findgrade.no_processing',
                'Grade to be inserted does not belong to the Grading Schema so skipping the outcome creation'
              );
            END IF;
            --
          ELSE
            CLOSE c_grading_schema_grade;
            --
            assp_insertgrade (
              p_person_id,
              p_course_cd,
              p_unit_cd,
              p_cal_type,
              p_ci_sequence_number,
              p_ci_start_dt,
              p_ci_end_dt,
              p_outcome_dt,
              p_s_grade_creation_method_type,
              p_grading_schema_cd,
              p_version_number,
              v_grade,
              p_finalised_outcome_ind,
              p_uoo_id
            );
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_exception,
              g_module_head || 'assp_ins_admin_grds.assp_findgrade.exception',
              'SQLERRM => ' || SQLERRM
            );
          END IF;
      END assp_findgrade;
      --
    BEGIN -- Main procedure
      --
      SAVEPOINT s_before_insert;
      --
      FOR v_stu_unit_atmpt_rec IN c_stu_unit_atmpt (
                                    p_assess_cal_type,
                                    p_assess_ci_sequence_number,
                                    p_teach_cal_type,
                                    p_teach_ci_sequence_number,
                                    p_org_unit_cd,
                                    p_unit_cd,
                                    p_location_cd,
                                    p_unit_mode,
                                    p_unit_class,
                                    p_assessable_type,
                                    p_no_assessment_type
                                  ) LOOP
        BEGIN
          --
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_statement,
              g_module_head || 'assp_ins_admin_grds.c_stu_unit_atmpt',
              v_stu_unit_atmpt_rec.person_id || ';' || v_stu_unit_atmpt_rec.course_cd || ';' ||
              v_stu_unit_atmpt_rec.unit_cd || ';' || v_stu_unit_atmpt_rec.version_number || ';' ||
              v_stu_unit_atmpt_rec.cal_type || ';' || v_stu_unit_atmpt_rec.ci_sequence_number || ';' ||
              v_stu_unit_atmpt_rec.location_cd || ';' || v_stu_unit_atmpt_rec.unit_class || ';' ||
              v_stu_unit_atmpt_rec.ci_start_dt || ';' || v_stu_unit_atmpt_rec.ci_end_dt || ';' ||
              v_stu_unit_atmpt_rec.uoo_id || ';' || v_stu_unit_atmpt_rec.no_assessment_ind
            );
          END IF;
          --
          -- Determine the relevant grading schema version for the student unit attempt
          --
          IF (igs_as_gen_003.assp_get_sua_gs (
                v_stu_unit_atmpt_rec.person_id,
                v_stu_unit_atmpt_rec.course_cd,
                v_stu_unit_atmpt_rec.unit_cd,
                v_stu_unit_atmpt_rec.version_number,
                v_stu_unit_atmpt_rec.cal_type,
                v_stu_unit_atmpt_rec.ci_sequence_number,
                v_stu_unit_atmpt_rec.location_cd,
                v_stu_unit_atmpt_rec.unit_class,
                v_grading_schema,
                v_gs_version_number
              )) THEN
            --
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_statement,
                g_module_head || 'assp_ins_admin_grds.grading_schema_derivation',
                v_stu_unit_atmpt_rec.person_id || ';' || v_stu_unit_atmpt_rec.course_cd || ';' ||
                v_stu_unit_atmpt_rec.uoo_id || ';' || v_grading_schema || ';' || v_gs_version_number
              );
            END IF;
            --
            IF (p_insert_default_ind = 'Y') THEN
              IF (v_stu_unit_atmpt_rec.no_assessment_ind = 'N') THEN -- Non-Audit Attempt
                v_record_found := FALSE;
                --
                -- Attempt to locate the default grade within the derived grading schema version
                --
                OPEN c_grading_schema_grade (v_grading_schema, v_gs_version_number);
                FETCH c_grading_schema_grade INTO v_grading_schema_grade_rec;
                IF (c_grading_schema_grade%FOUND) THEN
                  v_record_found := TRUE;
                  v_grade := v_grading_schema_grade_rec.grade;
                  --
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                    fnd_log.string (
                      fnd_log.level_statement,
                      g_module_head || 'assp_ins_admin_grds.derived_non_audit_grade',
                      v_stu_unit_atmpt_rec.person_id || ';' || v_stu_unit_atmpt_rec.course_cd || ';' ||
                      v_stu_unit_atmpt_rec.uoo_id || ';' || v_grading_schema || ';' ||
                      v_gs_version_number || ';' || v_grade
                    );
                  END IF;
                  --
                END IF;
                CLOSE c_grading_schema_grade;
                --
                IF (v_record_found = FALSE) THEN
                  IF (p_grade IS NOT NULL) THEN
                    assp_findgrade (
                      v_stu_unit_atmpt_rec.person_id,
                      v_stu_unit_atmpt_rec.course_cd,
                      v_stu_unit_atmpt_rec.unit_cd,
                      v_stu_unit_atmpt_rec.cal_type,
                      v_stu_unit_atmpt_rec.ci_sequence_number,
                      v_stu_unit_atmpt_rec.ci_start_dt,
                      v_stu_unit_atmpt_rec.ci_end_dt,
                      SYSDATE,
                      'SYSTEM',
                      v_grading_schema,
                      v_gs_version_number,
                      p_grade,
                      p_finalised_ind,
                      i,
                      v_stu_unit_atmpt_rec.uoo_id
                    );
                  END IF;
                ELSIF (v_record_found = TRUE) THEN
                  v_insert_grade := v_grade;
                  assp_insertgrade (
                    v_stu_unit_atmpt_rec.person_id,
                    v_stu_unit_atmpt_rec.course_cd,
                    v_stu_unit_atmpt_rec.unit_cd,
                    v_stu_unit_atmpt_rec.cal_type,
                    v_stu_unit_atmpt_rec.ci_sequence_number,
                    v_stu_unit_atmpt_rec.ci_start_dt,
                    v_stu_unit_atmpt_rec.ci_end_dt,
                    SYSDATE,
                    'SYSTEM',
                    v_grading_schema,
                    v_gs_version_number,
                    v_insert_grade,
                    p_finalised_ind,
                    v_stu_unit_atmpt_rec.uoo_id
                  );
                END IF;
              -- added the else condition to handle audit grades for audited attempts--
              ELSE -- Audit Attempt
                v_record_found := FALSE;
                OPEN c_grading_schema_audit_grade (v_grading_schema, v_gs_version_number);
                FETCH c_grading_schema_audit_grade INTO v_grading_schema_grade_rec;
                IF (c_grading_schema_audit_grade%FOUND) THEN
                  v_record_found := TRUE;
                  v_audit_grade := v_grading_schema_grade_rec.grade;
                  --
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                    fnd_log.string (
                      fnd_log.level_statement,
                      g_module_head || 'assp_ins_admin_grds.derived_audit_grade',
                      v_stu_unit_atmpt_rec.person_id || ';' || v_stu_unit_atmpt_rec.course_cd || ';' ||
                      v_stu_unit_atmpt_rec.uoo_id || ';' || v_grading_schema || ';' ||
                      v_gs_version_number || ';' || v_audit_grade
                    );
                  END IF;
                  --
                END IF;
                CLOSE c_grading_schema_audit_grade;
                --
                IF (v_record_found = FALSE) THEN
                  IF (p_audit_grade IS NOT NULL) THEN
                    assp_findgrade (
                      v_stu_unit_atmpt_rec.person_id,
                      v_stu_unit_atmpt_rec.course_cd,
                      v_stu_unit_atmpt_rec.unit_cd,
                      v_stu_unit_atmpt_rec.cal_type,
                      v_stu_unit_atmpt_rec.ci_sequence_number,
                      v_stu_unit_atmpt_rec.ci_start_dt,
                      v_stu_unit_atmpt_rec.ci_end_dt,
                      SYSDATE,
                      'SYSTEM',
                      v_grading_schema,
                      v_gs_version_number,
                      p_audit_grade,
                      p_finalised_ind,
                      i,
                      v_stu_unit_atmpt_rec.uoo_id
                    );
                  END IF;
                ELSIF (v_record_found = TRUE) THEN
                  v_insert_grade := v_audit_grade;
                  assp_insertgrade (
                    v_stu_unit_atmpt_rec.person_id,
                    v_stu_unit_atmpt_rec.course_cd,
                    v_stu_unit_atmpt_rec.unit_cd,
                    v_stu_unit_atmpt_rec.cal_type,
                    v_stu_unit_atmpt_rec.ci_sequence_number,
                    v_stu_unit_atmpt_rec.ci_start_dt,
                    v_stu_unit_atmpt_rec.ci_end_dt,
                    SYSDATE,
                    'SYSTEM',
                    v_grading_schema,
                    v_gs_version_number,
                    v_insert_grade,
                    p_finalised_ind,
                    v_stu_unit_atmpt_rec.uoo_id
                  );
                END IF;
              END IF;
            -- added by lkaki to check whether to get the grade from audit attempt or non-audit attempt---
            ELSIF (p_insert_default_ind = 'N') THEN
              IF (v_stu_unit_atmpt_rec.no_assessment_ind = 'N') THEN -- Non-Audit Attempt
                assp_findgrade (
                  v_stu_unit_atmpt_rec.person_id,
                  v_stu_unit_atmpt_rec.course_cd,
                  v_stu_unit_atmpt_rec.unit_cd,
                  v_stu_unit_atmpt_rec.cal_type,
                  v_stu_unit_atmpt_rec.ci_sequence_number,
                  v_stu_unit_atmpt_rec.ci_start_dt,
                  v_stu_unit_atmpt_rec.ci_end_dt,
                  SYSDATE,
                  'SYSTEM',
                  v_grading_schema,
                  v_gs_version_number,
                  p_grade,
                  p_finalised_ind,
                  i,
                  v_stu_unit_atmpt_rec.uoo_id
                );
              ELSE -- Audit Attempt
                assp_findgrade (
                  v_stu_unit_atmpt_rec.person_id,
                  v_stu_unit_atmpt_rec.course_cd,
                  v_stu_unit_atmpt_rec.unit_cd,
                  v_stu_unit_atmpt_rec.cal_type,
                  v_stu_unit_atmpt_rec.ci_sequence_number,
                  v_stu_unit_atmpt_rec.ci_start_dt,
                  v_stu_unit_atmpt_rec.ci_end_dt,
                  SYSDATE,
                  'SYSTEM',
                  v_grading_schema,
                  v_gs_version_number,
                  p_audit_grade,
                  p_finalised_ind,
                  i,
                  v_stu_unit_atmpt_rec.uoo_id
                );
              END IF;
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            --
            -- Log the error and skip to the next record
            --
            IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string (
                fnd_log.level_exception,
                g_module_head || 'assp_ins_admin_grds.assp_findgrade.exception',
                'Skipping to next record due to error => ' || SQLERRM
              );
            END IF;
        END;
      END LOOP;
      --
      COMMIT;
      --
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO s_before_insert;
        retcode := 2;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_exception,
            g_module_head || 'assp_ins_admin_grds.exception',
            'SQLERRM => ' || SQLERRM
          );
        END IF;
    END;
  END assp_ins_admin_grds;

PROCEDURE assp_ins_aia(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_person_id IN IGS_AS_ITEM_ASSESSOR.person_id%TYPE ,
  p_ass_assessor_type IN IGS_AS_ITEM_ASSESSOR.ASS_ASSESSOR_TYPE%TYPE ,
  p_primary_assessor_ind IN IGS_AS_ITEM_ASSESSOR.primary_assessor_ind%TYPE ,
  p_item_limit IN IGS_AS_ITEM_ASSESSOR.item_limit%TYPE ,
  p_location_cd IN IGS_AS_ITEM_ASSESSOR.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_ITEM_ASSESSOR.UNIT_MODE%TYPE ,
  p_unit_class IN IGS_AS_ITEM_ASSESSOR.UNIT_CLASS%TYPE ,
  p_comments IN IGS_AS_ITEM_ASSESSOR.comments%TYPE )
IS
        V_SEQUeNCE_NUMBER       number;
BEGIN   -- assp_ins_aia
        -- Insert a record into the IGS_AS_ITEM_ASSESSOR table
--DECLARE
--BEGIN
        select IGS_AS_ITEM_ASSESSOR_SEQ_NUM_S.NEXTVAL into V_SEQUENCE_NUMBER FROM DUAL;
        x_rowid :=      NULL ;
        IGS_AS_ITEM_ASSESSOR_PKG.INSERT_ROW(
                X_ROWID                     =>  x_rowid,
                X_ASS_ID                    =>          p_ass_id,
                X_PERSON_ID                 =>          p_person_id,
                X_SEQUENCE_NUMBER           =>          V_SEQUENCE_NUMBER,
                X_ASS_ASSESSOR_TYPE         =>          p_ass_assessor_type,
                X_PRIMARY_ASSESSOR_IND      =>          p_primary_assessor_ind,
                X_ITEM_LIMIT                =>          p_item_limit,
                X_LOCATION_CD               =>          p_location_cd,
                X_UNIT_MODE                 =>          p_unit_mode,
                X_UNIT_CLASS                =>          p_unit_class,
                X_COMMENTS                  =>          p_comments,
                X_MODE                      =>  'R'
                );
--END;
EXCEPTION
        WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_ins_aia');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_ins_aia;
 PROCEDURE assp_ins_aia_default(
  p_ass_id IN IGS_AS_ITEM_ASSESSOR.ass_id%TYPE ,
  p_unit_cd IN IGS_PS_UNIT_VER_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_PS_UNIT_VER_ALL.version_number%TYPE )
IS
BEGIN   -- assp_ins_aia_default
        -- Insert a default record into the IGS_AS_ITEM_ASSESSOR table
DECLARE
        cst_yes                 CONSTANT CHAR := 'Y';
        cst_no                  CONSTANT CHAR := 'N';
        cst_unit_coord          CONSTANT VARCHAR2(20) := 'unit CO-ORDINATOR.';
        CURSOR c_aia(
                        cp_ass_id               IGS_AS_ITEM_ASSESSOR.ass_id%TYPE) IS
                SELECT  COUNT(*)
                FROM    IGS_AS_ITEM_ASSESSOR
                WHERE   ass_id = cp_ass_id;
        CURSOR c_uv(
                        cp_unit_cd              IGS_PS_UNIT_VER.unit_cd%TYPE,
                        cp_version_number       IGS_PS_UNIT_VER.version_number%TYPE) IS
                SELECT  coord_person_id
                FROM    IGS_PS_UNIT_VER
                WHERE   unit_cd = cp_unit_cd AND
                        version_number = cp_version_number;
        CURSOR c_asst IS
                SELECT  ASS_ASSESSOR_TYPE
                FROM    IGS_AS_ASSESSOR_TYPE
                WHERE   dflt_ind = cst_yes and
                        closed_ind = cst_no;
        v_aia_count     NUMBER;
        v_uv_rec                c_uv%ROWTYPE;
        v_asst_rec              c_asst%ROWTYPE;
        v_ass_id                IGS_AS_ITEM_ASSESSOR.ass_id%TYPE;
        v_unit_cd               IGS_PS_UNIT_VER.unit_cd%TYPE;
        v_version_number        IGS_PS_UNIT_VER.version_number%TYPE;
BEGIN
        -- Initialise all the variables
        v_ass_id := p_ass_id;
        v_unit_cd := p_unit_cd;
        v_version_number := p_version_number;
        -- Check that an assessor does not already exist for the item
        OPEN c_aia(
                        v_ass_id);
        FETCH c_aia INTO v_aia_count;
        CLOSE c_aia;
        IF (v_aia_count > 0) THEN
                RETURN;
        END IF;
        -- Fetch the unit coordinator
        OPEN c_uv(
                        v_unit_cd,
                        v_version_number);
        FETCH c_uv INTO v_uv_rec;
        CLOSE c_uv;
        -- Fetch the default assessor type
        OPEN c_asst;
        FETCH c_asst INTO v_asst_rec;
        CLOSE c_asst;
        -- Call the generic IGS_AS_GEN_006.assp_ins_aia routine
        IGS_AS_GEN_006.assp_ins_aia (
                v_ass_id,
                v_uv_rec.coord_person_id,
                v_asst_rec.ASS_ASSESSOR_TYPE,
                cst_yes,
                NULL,
                NULL,
                NULL,
                NULL,
                cst_unit_coord);
END;
EXCEPTION
        WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_ins_aia_default');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_ins_aia_default;

PROCEDURE assp_ins_ai_cvr_sht(
                                        errbuf           OUT NOCOPY VARCHAR2,
                                        retcode          OUT NOCOPY NUMBER,
                                        p_acad_calendar  IN VARCHAR2,
                                        p_teach_calendar IN VARCHAR2,
                                        p_crs_cd         IN VARCHAR2 ,
                                        p_unt_cd         IN VARCHAR2 ,
                                        p_lctn_cd        IN VARCHAR2 ,
                                        p_unt_cls        IN VARCHAR2 ,
                                        p_unt_md         IN VARCHAR2 ,
                                        p_person_id      IN NUMBER ,
                                        p_ass_id         IN NUMBER ,
                                        p_reprdc         IN VARCHAR2 DEFAULT 'N',
                                        p_org_id         IN NUMBER
                              )
  IS
    p_acad_cal_type               IGS_CA_INST.CAL_TYPE%TYPE;
    p_acad_ci_sequence_number     IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    p_teach_cal_type              IGS_CA_INST.CAL_TYPE%TYPE;
    p_teach_ci_sequence_number    IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    p_course_cd                   IGS_PS_COURSE.COURSE_CD%TYPE;
    p_unit_cd                     IGS_PS_UNIT.UNIT_CD%TYPE;
    p_location_cd                 IGS_AD_LOCATION.LOCATION_CD%TYPE;
    p_unit_class                  IGS_AS_UNIT_CLASS.UNIT_CLASS%TYPE;
    p_unit_mode                   IGS_AS_UNIT_MODE.UNIT_MODE%TYPE;
    p_reproduce                   IGS_LOOKUPS_VIEW.LOOKUP_CODE%TYPE ;
  --------------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --Aiyer    08-APR-2002        Bug No. 2124034. The parameter p_reproduce was also added as a hidden parameter in the
  --                            concurrent job IGSASJ05 Produce Student Assignment Cover Sheet with a default value as 'NO'.
  --                            In the package body of porocedure too it was made to have a default value of 'NO'.
  -------------------------------------------------------------------------------------------------------------------------

BEGIN
  -- assp_ins_ai_cvr_sht
  -- This module will create extraction records that will be used for the
  -- production of Assignment Coversheets (Attachments).
  -- Coversheet details will be produced for all students with the following
  -- criteria:
  -- * A tracking item assigned to their IGS_AS_SU_ATMPT_ITM record.
  -- * The assignment must be valid for the student.
  -- * The student is ENROLLED in the unit.
  -- * If not re-producing, then student cannot have had a coversheet produced
  --   previously for the assignment in this unit and teaching period.
  -- * If re-producing, student must already have a tracking item assigned for
  --   the assignment.
  -- This module will have a mandatory relationship with ASSR3610
  -- (assp_ins_suaai_tri), which assign tracking items to assignments. It
  -- will require the re-production parameter to be set to 'N'.
  -- A second definition in the Job Scheduling facility will allow this process
  -- to be called independently with the re-production parameter set to 'Y'.
  -- set org id

   igs_ge_gen_003.set_org_id(p_org_id);

   p_course_cd   :=     NVL(p_crs_cd, '%');
   p_unit_cd     :=     NVL(p_unt_cd,'%');
   p_location_cd :=     NVL(p_lctn_cd,'%');
   p_unit_class  :=     NVL(p_unt_cls,'%');
   p_unit_mode   :=     NVL(p_unt_md,'%');
   p_reproduce   :=     p_reprdc;


  --Block for Parameter Validation/Splitting of Parameters

   retcode:=0;
   DECLARE
      invalid_parameter         EXCEPTION;

   BEGIN

  /************************* Validation 1 ***************************************************************************/

  IF p_acad_calendar IS NULL THEN
    p_acad_cal_type           := NULL;
    p_acad_ci_sequence_number := NULL;
  ELSE
    p_acad_cal_type           := RTRIM(SUBSTR(p_acad_calendar, 101, 10));
    p_acad_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_acad_calendar, 112,6)));
  END IF;


  /************************* Validation 2 ***************************************************************************/

  IF p_teach_calendar IS NULL  THEN
    p_teach_cal_type           := NULL;
    p_teach_ci_sequence_number := NULL;
  ELSE
    p_teach_cal_type           := RTRIM(SUBSTR(p_teach_calendar, 101, 10));
    p_teach_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_teach_calendar, 112,6)));
  END IF;

  /************************* Validation 3 ****************************************************************************/

   -- Validate that the Teaching Calendar parameter passed is subordinate to the Academic Calendar passed

  IF  ( IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(  p_acad_cal_type,
                                            p_acad_ci_sequence_number,
                                            p_teach_cal_type,
                                            p_teach_ci_sequence_number,
                                            'N'
                                          )  <> 'Y'
      )   THEN
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS', 'IGS_AS_TEACHCAL_NOT_EXIST');
    RAISE invalid_parameter;
  END IF;

EXCEPTION
  WHEN INVALID_PARAMETER  THEN
    retcode:=2;
  RETURN;
END;

--End of Block for Parameter Validation/Splitting of Parameters

 DECLARE
   cst_enrolled         CONSTANT VARCHAR2(10)   := 'ENROLLED';
   cst_assignment       CONSTANT VARCHAR2(15)   := 'ASSIGNMENT';
   cst_ass_cover        CONSTANT VARCHAR2(9)    := 'ASS_COVER';
   cst_coversheet       CONSTANT VARCHAR2(10)   := 'COVERSHEET';
   cst_sysdate          DATE                    := SYSDATE;


  -- Fetch those records which satisfy the foloowing conditions
  --   1. Consider Student Unit Attempt Assessment records for only the latest attempt of a student
  --   2. Student is enrolled
  --   3. Parameters passed are either null or records exist for the passed parameters ( if not null )
  --   4. If Assessment Item Id is passed then the system  assessment item type (s_assessment_type)
  --      should be equal to ASSIGNMENT .
  --   5. Correspondence Outcome References of 'COVERSHEET'  should  not exist for the person , unit ,course
  --      and assessment

   CURSOR c_enrolled_students (
                                     cp_acad_cal_type                IGS_CA_INST.CAL_TYPE%TYPE,
                                     cp_acad_ci_sequence_number      IGS_CA_INST.sequence_number%TYPE,
                                     cp_teach_cal_type               IGS_EN_SU_ATTEMPT.CAL_TYPE%TYPE,
                                     cp_teach_ci_sequence_number     IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
                                     cp_course_cd                    IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                                     cp_unit_cd                      IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                                     cp_location_cd                  IGS_EN_SU_ATTEMPT.location_cd%TYPE,
                                     cp_unit_class                   IGS_EN_SU_ATTEMPT.UNIT_CLASS%TYPE,
                                     cp_unit_mode                    IGS_AS_UNIT_CLASS.UNIT_MODE%TYPE,
                                     cp_person_id                    IGS_EN_SU_ATTEMPT.person_id%TYPE,
                                     cp_ass_id                       IGS_AS_SU_ATMPT_ITM.ass_id%TYPE,
                                     cp_reproduce                    VARCHAR2
                             )
   IS
   SELECT
           suaai.person_id,
           suaai.course_cd,
           suaai.unit_cd,
           suaai.cal_type,
           suaai.ci_sequence_number,
           suaai.ass_id,
           ai.description,
           suaai.creation_dt,
           suaai.override_due_dt,
           sua.version_number,
           sua.location_cd,
           sua.unit_class,
           uc.unit_mode,
           suaai.tracking_id,
           sua.uoo_id
   FROM
           igs_as_su_atmpt_itm  suaai,
           igs_en_su_attempt    sua,
           igs_as_assessmnt_itm ai,
           igs_as_unit_class    uc
  WHERE
          (cp_person_id  IS NULL OR suaai.person_id = cp_person_id)
           AND
           suaai.logical_delete_dt IS NULL
           AND
           suaai.attempt_number
           =
             ( SELECT
                       MAX(attempt_number)
               FROM
                       IGS_AS_SU_ATMPT_ITM suaai2
               WHERE
                       suaai2.person_id = suaai.person_id                   AND
                       suaai2.course_cd = suaai.course_cd                   AND
                       suaai2.uoo_id = suaai.uoo_id                         AND
                       suaai2.ass_id    = suaai.ass_id
              )                                               AND
          suaai.person_id  = sua.person_id                    AND
          suaai.course_cd  = sua.course_cd                    AND
          suaai.uoo_id = sua.uoo_id                           AND
          sua.course_cd    LIKE cp_course_cd                  AND
          sua.unit_cd      LIKE cp_unit_cd                    AND
          sua.location_cd  LIKE cp_location_cd                AND
          sua.unit_class   LIKE cp_unit_class                 AND
          sua.unit_class   = uc.unit_class                    AND
          uc.unit_mode  LIKE cp_unit_mode                     AND
          sua.unit_attempt_status = cst_enrolled              AND
          (
            cp_teach_cal_type IS NULL
            OR
           suaai.cal_type = cp_teach_cal_type
          )                                                   AND
          (
            cp_ass_id IS NULL
           OR
           suaai.ass_id = cp_ass_id
          )                                                   AND
          (
            cp_teach_ci_sequence_number IS NULL
           OR
           suaai.ci_sequence_number = cp_teach_ci_sequence_number
          )                                                   AND
          -- check for teaching calendar being passed is subordinate to the academic calendar passed
          igs_en_gen_014.enrs_get_within_ci ( cp_acad_cal_type,
                                              cp_acad_ci_sequence_number,
                                              sua.cal_type,
                                              sua.ci_sequence_number,
                                              'Y'
                                                  )  = 'Y'          AND
          suaai.ass_id = ai.ass_id                            AND
          /* If Assessment Item Id is passed then the system  assessment item type (s_assessment_type) should be ASSIGNMENT */
          igs_as_gen_002.assp_get_ai_s_type(ai.ass_id) = cst_assignment AND
          (
              (
                 (cp_reproduce = 'Y'           )
                  AND
                 (suaai.tracking_id IS NOT NULL)
              )
              OR
              (
               (cp_reproduce = 'N')
                AND
                 (suaai.tracking_id IS NOT NULL)
              )
              AND
              (
                  NOT EXISTS (  SELECT
                                         'X'
                                FROM
                                         IGS_CO_OU_CO_REF ocr
                                WHERE
                                         ocr.person_id            = suaai.person_id            AND
                                          ocr.correspondence_type = cst_coversheet             AND
                                          ocr.cal_type            = suaai.cal_type             AND
                                          ocr.ci_sequence_number  = suaai.ci_sequence_number   AND
                                          ocr.course_cd           = suaai.course_cd            AND
                                          ocr.unit_cd             = suaai.unit_cd              AND
                                          ocr.other_reference     = TO_CHAR(suaai.ass_id) || '|' || IGS_GE_DATE.IGSCHARDT(suaai.creation_dt)
                               )
              )
          )
        ORDER BY suaai.person_id, suaai.unit_cd;

        -- Fetch all those records
        CURSOR c_suv (
                cp_course_cd            IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                cp_unit_cd              IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                cp_person_id            IGS_EN_SU_ATTEMPT.person_id%TYPE,
                cp_cal_type             IGS_AS_SU_ATMPT_ITM.CAL_TYPE%TYPE,
                cp_ci_sequence_number   IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE,
                cp_ass_id               IGS_AS_SU_ATMPT_ITM.ass_id%TYPE,
                cp_uoo_id               IGS_AS_SU_ATMPT_ITM.uoo_id%TYPE)
        IS
        SELECT
                uai_due_dt,
                uai_reference
        FROM
                igs_as_uai_sua_v
       WHERE
                person_id              = cp_person_id          AND
                course_cd              = cp_course_cd          AND
                uoo_id                 = cp_uoo_id             AND
                ass_id                 = cp_ass_id             AND
                uai_logical_delete_dt   IS NULL;

        CURSOR c_pe (cp_person_id  IGS_AS_SU_ATMPT_ITM.person_id%TYPE)
        IS
        SELECT
                   title,
                   surname,
                   given_names,
                   preferred_given_name
        FROM
                   igs_pe_person
        WHERE
                   person_id = cp_person_id;

        -- Retrieve the  record only if the person has a valid person address (exists in table and igs_pe_person_addr)
        -- and current date (sysdate) is :-
        --    Greater than start date and end date is null
        --  OR
        --    Between the start date and end date

        CURSOR c_pa (cp_person_id    IGS_AS_SU_ATMPT_ITM.person_id%TYPE)
        IS
        SELECT
                   pa.addr_line_1,
                   pa.addr_line_2,
                   pa.addr_line_3,
                   pa.addr_line_4,
                   pa.postal_code,
                   pa.correspondence_ind
        FROM
                   igs_pe_person_addr pa
        WHERE
                    pa.person_id = cp_person_id
        AND
                    ( pa.status = 'A'
                      AND
                      (
                        SYSDATE BETWEEN NVL(pa.start_dt,SYSDATE) AND NVL(pa.end_dt,SYSDATE+1)
                      )
                    )
        ORDER BY
                    pa.correspondence_ind DESC;

        -- Ordering by correspondence indicator (desc) means that if a
        -- correspondence type address exists, then it will be selected first.)

        CURSOR c_crv (
                        cp_person_id                IGS_AS_SU_ATMPT_ITM.person_id%TYPE,
                        cp_course_cd                IGS_AS_SU_ATMPT_ITM.course_cd%TYPE
                     )
         IS
         SELECT
                  crv.version_number,
                  crv.short_title
         FROM
                  IGS_EN_STDNT_PS_ATT sca,
                  IGS_PS_VER crv
         WHERE
                  sca.person_id       = cp_person_id AND
                  sca.course_cd       = cp_course_cd AND
                  sca.course_cd       = crv.course_cd AND
                  sca.version_number  = crv.version_number;

        CURSOR c_uv (
                           cp_person_id                 IGS_AS_SU_ATMPT_ITM.person_id%TYPE,
                           cp_course_cd                 IGS_AS_SU_ATMPT_ITM.course_cd%TYPE,
                           cp_unit_cd                   IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE,
                           cp_cal_type                  IGS_AS_SU_ATMPT_ITM.CAL_TYPE%TYPE,
                           cp_ci_sequence_number        IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE,
                           cp_uoo_id                    IGS_AS_SU_ATMPT_ITM.uoo_id%TYPE
                   )
         IS
         SELECT
                    uv.version_number,
                    uv.short_title
         FROM
                    IGS_EN_SU_ATTEMPT   sua,
                    IGS_PS_UNIT_VER     uv
         WHERE
                        sua.person_id          = cp_person_id          AND
                        sua.course_cd          = cp_course_cd          AND
                        sua.uoo_id             = cp_uoo_id             AND
                        uv.unit_cd             = sua.unit_cd           AND
                        uv.version_number      = sua.version_number;
        CURSOR c_um(
                cp_unit_mode                  IGS_AS_UNIT_CLASS.UNIT_MODE%TYPE) IS
                SELECT          s_unit_mode
                FROM            IGS_AS_UNIT_MODE
                WHERE           UNIT_MODE = cp_unit_mode;

        CURSOR c_suaav(
                cp_person_id            IGS_AS_SU_ATMPT_ITM.person_id%TYPE,
                cp_course_cd            IGS_AS_SU_ATMPT_ITM.course_cd%TYPE,
                cp_unit_cd              IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE,
                cp_cal_type             IGS_AS_SU_ATMPT_ITM.CAL_TYPE%TYPE,
                cp_ci_sequence_number   IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE,
                cp_uoo_id               IGS_AS_SU_ATMPT_ITM.uoo_id%TYPE)
        IS
        SELECT
                acad_alternate_code,  -- Year
                teach_alternate_code  -- Semester
        FROM
                igs_as_sua_ass_v
        WHERE
                person_id               = cp_person_id AND
                course_cd               = cp_course_cd AND
                uoo_id                  = cp_uoo_id;

        CURSOR c_ai(
                cp_ass_id                   IGS_AS_SU_ATMPT_ITM.ass_id%TYPE) IS
                SELECT  description
                FROM    IGS_AS_ASSESSMNT_ITM
                WHERE   ass_id = cp_ass_id;

        v_last_person_id        IGS_EN_SU_ATTEMPT.PERSON_ID%TYPE := 0;
        v_last_course_cd        IGS_EN_SU_ATTEMPT.COURSE_CD%TYPE := NULL;
        v_last_unit_cd          IGS_EN_SU_ATTEMPT.UNIT_CD%TYPE   := NULL;
        v_first_record          BOOLEAN := TRUE;
        v_ignore_rec            BOOLEAN DEFAULT TRUE;
        v_log_dt                DATE := NULL;
        v_suv_rec               c_suv%ROWTYPE;
        v_suaav_rec             c_suaav%ROWTYPE;
        v_pe_rec                c_pe%ROWTYPE;
        v_pa_rec                c_pa%ROWTYPE;
        v_crv_rec               c_crv%ROWTYPE;
        v_uv_rec                c_uv%ROWTYPE;
        v_um_rec                c_um%ROWTYPE;
        v_ai_rec                c_ai%ROWTYPE;
        v_record                VARCHAR2(2000);
        v_message_name          VARCHAR2(30);
        v_cori_sequence_number  IGS_CO_ITM.reference_number%TYPE;
        v_ocr_sequence_number  IGS_CO_OU_CO_REF.sequence_number%TYPE;
   BEGIN
     -- Select students who are enrolled and have an assignment assessment type.
     -- If p_reproduce = 'Y' then are interested only in the records that have had
     -- a sheet produced previously, otherwise if 'N', then only want records where
     -- sheet not produced yet.

     /*********************************** Validation 4 ***********************************************************************/

        -- Pass the parameters to the current procedure as parameters to this cursor
        FOR v_enrolled_rec IN c_enrolled_students(     p_acad_cal_type,
                                                       p_acad_ci_sequence_number,
                                                       p_teach_cal_type,
                                                       p_teach_ci_sequence_number,
                                                       p_course_cd,
                                                       p_unit_cd,
                                                       p_location_cd,
                                                       p_unit_class,
                                                       p_unit_mode,
                                                       p_person_id,
                                                       p_ass_id,
                                                       p_reproduce
                                                 )
        LOOP
          v_ignore_rec := FALSE;

          /*************************************************** Validation 4.1 *******************************************************/

          -- Validate that the assessment item is still valid for the student and get the due date for the item.
          -- Select from IGS_AS_UAI_SUA_V.
          OPEN c_suv(
                         v_enrolled_rec.course_cd,
                         v_enrolled_rec.unit_cd,
                         v_enrolled_rec.person_id,
                         v_enrolled_rec.cal_type,
                         v_enrolled_rec.ci_sequence_number,
                         v_enrolled_rec.ass_id,
                         v_enrolled_rec.uoo_id
                    );

          FETCH c_suv INTO v_suv_rec;

          -- Only produce an attachment if the assessment item is still valid for the IGS_PE_PERSON.
          IF c_suv%NOTFOUND THEN   -- Start of if 1

           /************************************* Validation 4.1.1 **************************************************************/

            CLOSE c_suv;

          ELSE

           /************************************* Validation 4.2 **************************************************************/

            CLOSE c_suv;

            -- If the record is the first record then insert an entry of 'ASS_COVER' into the system Log
            IF v_first_record THEN        -- Start of if 2
               -- Create log entry and returns the creation date, creation date is the system date
               IGS_GE_GEN_003.GENP_INS_LOG(cst_ass_cover,FND_GLOBAL.CONC_REQUEST_ID,v_log_dt);
               v_first_record := FALSE;
            END IF;                  -- End of if 2




           /************************************* Validation 4.3 **************************************************************/

            -- If the person id is not the last person id then get the details of the person such as title ,surname given_names,preferred_given_name
            -- Get the IGS_PE_PERSON name and address details if processing a new id.
            IF v_last_person_id <> v_enrolled_rec.person_id THEN    --Start of if 3

              OPEN c_pe(v_enrolled_rec.person_id);
              FETCH c_pe INTO v_pe_rec;
              IF c_pe%NOTFOUND THEN          -- Start of if 4
                CLOSE c_pe;
                Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
              END IF;                     -- End of if 4


              CLOSE c_pe;

              -- For the current person retrieve the person address details only if
              -- current date (sysdate) is :-
              --    Greater than start date and end date is null
              --  OR
              --    Between the start date and end date
              OPEN c_pa(v_enrolled_rec.person_id);
              FETCH c_pa INTO v_pa_rec;

              -- If Person Address details are not found then do not produce any Assignment cover sheet data
              -- Set the v_ignore_rec flag to TRUE
              -- If this flag is set to true then the current would get ignored and no cover sheet would be produced
              -- for the current record.

              IF c_pa%NOTFOUND THEN           -- Start of if 5

               CLOSE c_pa;
                v_ignore_rec := TRUE;
              ELSE
                CLOSE c_pa;
                v_last_person_id := v_enrolled_rec.person_id;
                -- Reset the last IGS_PS_COURSE and IGS_PS_UNIT codes so that if it is a new IGS_PE_PERSON,
                -- then the appropriate IGS_PS_COURSE and unit version is retrieved.
                v_last_course_cd := NULL;
                v_last_unit_cd := NULL;

              END IF;                     -- End of if 5
            END IF;                       -- End of if 3

            /************************************* Validation 4.4 **************************************************************/

            -- v_last_person_id <> v_enrolled_rec.person_id

            IF v_ignore_rec = FALSE THEN        -- Start of if 6

               v_record := TO_CHAR(v_enrolled_rec.person_id) || '|' || v_pe_rec.TITLE || '|' || v_pe_rec.surname || '|';

               IF v_pe_rec.preferred_given_name IS NULL THEN   -- Start of if 7
                  v_record := v_record || v_pe_rec.given_names || '|';
               ELSE
                 v_record := v_record || v_pe_rec.preferred_given_name || '|';
               END IF;                        -- End of if 7

               v_record := v_record ||
                           v_pa_rec.addr_line_1 || '|' ||
                           v_pa_rec.addr_line_2 || '|' ||
                           v_pa_rec.addr_line_3 || '|' ||
                           v_pa_rec.addr_line_4 || '|' ||
                           v_pa_rec.postal_code || '|' ||
                           v_pa_rec.correspondence_ind || '|';


                -- Get the IGS_PS_COURSE version and description (Short IGS_PE_TITLE)
                -- Only if different to the previous IGS_PS_COURSE cd processed.

                IF NVL(v_last_course_cd, 'NULL') <> v_enrolled_rec.course_cd THEN    -- Start of if 8
                  OPEN c_crv(
                   v_enrolled_rec.person_id,
                  v_enrolled_rec.course_cd);
                  FETCH c_crv INTO v_crv_rec;

                  IF c_crv%NOTFOUND THEN                                           -- Start of if 9
                    CLOSE c_crv;
                    RAISE NO_DATA_FOUND;
                    Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                  END IF;                                                           -- End of if 9

                  CLOSE c_crv;

                END IF;                                                              -- End of if 8


                -- Get unit description (Short IGS_PE_TITLE)
                -- Only if different to the previous unit processed.
                IF NVL(v_last_unit_cd, 'NULL') <> v_enrolled_rec.unit_cd THEN        -- Start Of if 10
                  OPEN c_uv(
                               v_enrolled_rec.person_id,
                               v_enrolled_rec.course_cd,
                               v_enrolled_rec.unit_cd,
                               v_enrolled_rec.CAL_TYPE,
                               v_enrolled_rec.ci_sequence_number,
                               v_enrolled_rec.uoo_id
                            );

                  FETCH c_uv INTO v_uv_rec;

                  IF c_uv%NOTFOUND THEN                                               -- Start Of if 11
                    CLOSE c_uv;
                    Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
                  END IF;                                                              -- End Of if 11

                  CLOSE c_uv;
                END IF;                                                              -- End Of if 10

                -- Determine the system unit mode
                OPEN c_um(v_enrolled_rec.UNIT_MODE);
                FETCH c_um INTO v_um_rec;

                IF c_um%NOTFOUND THEN                                                     -- Start Of if 12
                  CLOSE c_um;
                  Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
                END IF;                                                                   -- End Of if 12

                CLOSE c_um;
                v_record := v_record ||
                            v_enrolled_rec.course_cd          || '|' ||
                            TO_CHAR(v_crv_rec.version_number) || '|' ||
                            v_crv_rec.short_title             || '|' ||
                            v_enrolled_rec.unit_cd            || '|' ||
                            TO_CHAR(v_uv_rec.version_number)  || '|' ||
                            v_uv_rec.short_title              || '|' ||
                            v_enrolled_rec.CAL_TYPE           || '|' ||
                            v_enrolled_rec.ci_sequence_number || '|' ||
                            v_enrolled_rec.location_cd        || '|' ||
                            v_enrolled_rec.UNIT_CLASS         || '|' ||
                            v_enrolled_rec.UNIT_MODE          || '|' ||
                            v_um_rec.s_unit_mode              || '|';

                                -- Determine the year and semester.
                OPEN c_suaav(
                v_enrolled_rec.person_id,
                v_enrolled_rec.course_cd,
                v_enrolled_rec.unit_cd,
                v_enrolled_rec.CAL_TYPE,
                v_enrolled_rec.ci_sequence_number,
                v_enrolled_rec.uoo_id );

                FETCH c_suaav INTO v_suaav_rec;


                IF c_suaav%NOTFOUND THEN                                                               -- Start Of if 13
                  CLOSE c_suaav;
                  Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
                END IF;                                                                                -- End Of if 13

                CLOSE c_suaav;
                v_record := v_record ||
                v_suaav_rec.acad_alternate_code || '|' ||
                v_suaav_rec.teach_alternate_code || '|';

                -- Get the assignment details.
                OPEN c_ai(v_enrolled_rec.ass_id);
                FETCH c_ai INTO v_ai_rec;

                IF c_ai%NOTFOUND THEN                                                              --Start Of if 14
                  CLOSE c_ai;
                  Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
                  IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
                END IF;                                                               -- End Of if 14

                CLOSE c_ai;
                v_record := v_record ||
                            TO_CHAR(v_enrolled_rec.ass_id)                    || '|'  ||
                            IGS_GE_DATE.IGSCHARDT(v_enrolled_rec.creation_dt) || '|' ||
                            v_suv_rec.uai_reference                           || '|' ||
                            v_ai_rec.description                              || '|';


                -- If Student Assessment Due date is less than the override_due_dt then take the override_due_dt
                -- else take the uai_due_dt
                IF v_suv_rec.uai_due_dt < NVL(v_enrolled_rec.override_due_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) THEN           -- Start Of if 15

                  v_record := v_record || IGS_GE_DATE.IGSCHAR(v_enrolled_rec.override_due_dt) || '|';
                ELSE
                  v_record := v_record || IGS_GE_DATE.IGSCHAR(v_suv_rec.uai_due_dt) || '|';
                END IF;                                                                                                         -- End  Of if 15

                v_record := v_record || TO_CHAR(v_enrolled_rec.tracking_id);

                -- Create the log entry for the assignment cover sheet.
                IGS_GE_GEN_003.genp_ins_log_entry( cst_ass_cover,
                                                   v_log_dt,
                                                   FND_GLOBAL.CONC_REQUEST_ID,
                                                   NULL,
                                                   v_record
                                                  );
               END IF;                                                                                           -- End Of if 6
             END IF;                                                                                             -- End Of if 1

           END LOOP;

           -- v_enrolled_rec IN c_enrolled_students
           -- Commit only after processing all records.
           COMMIT;

           IF NOT IGS_EN_GEN_002.ENRP_EXT_ENRL_FORM(FND_GLOBAL.CONC_REQUEST_ID,'ASS_COVER',v_message_name) THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS',v_message_name));
           END IF;
  END;

  EXCEPTION
    WHEN OTHERS THEN
      Retcode := 2;
      errbuf  :=  fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END assp_ins_ai_cvr_sht;

 PROCEDURE assp_ins_asr1020_tmp(
  p_ass_perd_cal_type IN VARCHAR2 ,
  p_ass_perd_sequence_number IN NUMBER ,
  p_owner_org_unit_cd IN VARCHAR2 ,
  p_owner_ou_start_dt IN DATE ,
  p_unit_mode IN VARCHAR2 )
IS
BEGIN   -- assp_ins_asr1020_tmp
        -- This routine will process all unit offering options for an
        -- assessment period and determine the counts of assessment items
        -- due and recieved from student. It will insert the information
        -- into a temporary table that will be used by the report ASSR1020
        -- Assignment Due Date Summary Report.
DECLARE
        cst_teaching                    CONSTANT VARCHAR2 (8)   := 'TEACHING';
        cst_assessment                  CONSTANT VARCHAR2 (10)  := 'ASSESSMENT';
        cst_assignment                  CONSTANT VARCHAR2 (10)  := 'ASSIGNMENT';
        cst_assign_due                  CONSTANT VARCHAR2 (10)  := 'ASSIGN-DUE';
        cst_true                        CONSTANT VARCHAR2 (4)   := 'TRUE';
        cst_none                        CONSTANT VARCHAR2 (4)   := 'NONE';
        cst_yes                         CONSTANT CHAR           := 'Y';
        cst_no                          CONSTANT CHAR           := 'N';
        v_session_id                    NUMBER;
        CURSOR c_sess_id IS
                SELECT  userenv('SESSIONID')
                FROM    dual;
        -- Cursor to select teaching periods under the assessment period.
        CURSOR c_teach_perd (
                        cp_ass_cal_type         IGS_CA_INST.CAL_TYPE%TYPE,
                        cp_ass_sequence_number  IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  ci2.CAL_TYPE,
                        ci2.sequence_number
                FROM    IGS_CA_INST     ci,
                        IGS_CA_INST     ci2,
                        IGS_CA_TYPE     ct,
                        IGS_CA_TYPE     ct2
                WHERE   ci.CAL_TYPE             = cp_ass_cal_type               AND
                        ci.sequence_number      = cp_ass_sequence_number        AND
                        ci.CAL_TYPE             = ct.CAL_TYPE                   AND
                        ct.S_CAL_CAT            = cst_assessment                AND
                        ci2.CAL_TYPE            = ct2.CAL_TYPE                  AND
                        ct2.S_CAL_CAT           = cst_teaching                  AND
                        IGS_EN_GEN_014.enrs_get_within_ci(
                                        cp_ass_cal_type,
                                        cp_ass_sequence_number,
                                        ci2.CAL_TYPE,
                                        ci2.sequence_number,
                                        cst_no) = cst_yes;
        -- Cursor to get the relevant unit offering option and assessment item
        -- within the nominated teaching period, org unit and mode.
        CURSOR c_uoo(
                        cp_teach_cal_type               IGS_PS_UNIT_OFR_OPT.CAL_TYPE%TYPE,
                        cp_teach_ci_sequence_number     IGS_PS_UNIT_OFR_OPT.ci_sequence_number%TYPE,
                        cp_owner_org_unit_cd            IGS_PS_UNIT_VER.owner_org_unit_cd%TYPE,
                        cp_owner_ou_start_dt            IGS_PS_UNIT_VER.owner_ou_start_dt%TYPE,
                        cp_unit_mode                    IGS_AS_UNIT_CLASS.UNIT_MODE%TYPE) IS
                SELECT  uv.owner_org_unit_cd,
                        uv.owner_ou_start_dt,
                        uc.UNIT_MODE,
                        uv.unit_cd,
                        uv.version_number,
                        uoo.uoo_id
                FROM    IGS_PS_UNIT_OFR_OPT     uoo,
                        IGS_PS_UNIT_VER                 uv,
                        IGS_AS_UNIT_CLASS               uc
                WHERE   uoo.unit_cd             = uv.unit_cd                            AND
                        uoo.version_number      = uv.version_number                     AND
                        uoo.UNIT_CLASS          = uc.UNIT_CLASS                         AND
                        uoo.CAL_TYPE            = cp_teach_cal_type                     AND
                        uoo.ci_sequence_number  = cp_teach_ci_sequence_number           AND
                        uv.owner_org_unit_cd    LIKE cp_owner_org_unit_cd                       AND
                        uv.owner_ou_start_dt    = NVL(cp_owner_ou_start_dt, uv.owner_ou_start_dt)AND
                        uc.UNIT_MODE            LIKE cp_unit_mode;
        -- Cursor to get the relevant assessment item
        -- within the nominated unit offering option,
        -- teaching period, org unit and mode.
        CURSOR c_uai(
                        cp_uoo_id               IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
                SELECT  uai.ass_id,
                        uai.due_dt,
                        IGS_GE_GEN_001.genp_clc_week_end_dt(uai.due_dt) uai_week_ending_dt
                FROM    IGS_PS_UNIT_OFR_OPT     uoo,
--                      IGS_AS_UNIT_CLASS               uc,
                        IGS_AS_UNITASS_ITEM     uai,
                        IGS_AS_ASSESSMNT_ITM            ai,
                        IGS_AS_ASSESSMNT_TYP            atyp
                WHERE   uoo.uoo_id              = cp_uoo_id                     AND
--                      uoo.UNIT_CLASS          = uc.UNIT_CLASS                 AND
                        uoo.unit_cd             = uai.unit_cd                   AND
                        uoo.version_number      = uai.version_number            AND
                        uoo.CAL_TYPE            = uai.CAL_TYPE                  AND
                        uoo.ci_sequence_number  = uai.ci_sequence_number        AND
--                      uoo.UNIT_CLASS          = uc.UNIT_CLASS                 AND
--                      IGS_AS_VAL_UAI.assp_val_sua_uai(
--                                              uoo.location_cd,
--                                              uoo.UNIT_CLASS,
--                                              uc.UNIT_MODE,
--                                              uai.location_cd,
--                                              uai.UNIT_CLASS,
--                                              uai.UNIT_MODE) = cst_true       AND
                        uai.ass_id              = ai.ass_id                     AND
                        uai.logical_delete_dt   IS NULL                         AND
                        atyp.ASSESSMENT_TYPE    = ai.ASSESSMENT_TYPE            AND
                        NVL(atyp.s_assessment_type, cst_none) = cst_assignment;
        CURSOR c_suaai(
                        cp_uoo_id               IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE,
                        cp_ass_id               IGS_AS_SU_ATMPT_ITM.ass_id%TYPE) IS
                SELECT  suaai.override_due_dt,
                        trst.completion_dt
                FROM    IGS_AS_SU_ATMPT_ITM     suaai,
                        IGS_TR_STEP                     trst,
                        IGS_EN_SU_ATTEMPT               sua
                WHERE   sua.uoo_id      = cp_uoo_id                             AND
                        sua.person_id   = suaai.person_id                       AND
                        sua.course_cd   = suaai.course_cd                       AND
                        sua.uoo_id      = suaai.uoo_id                          AND
                        suaai.ass_id    = cp_ass_id                             AND
                        suaai.logical_delete_dt IS NULL                         AND
                        suaai.tracking_id IS NOT NULL                           AND
                        suaai.tracking_id = trst.tracking_id                    AND
                        trst.s_tracking_step_type = cst_assign_due              AND
                        IGS_AS_VAL_SUAAI.assp_val_ass_count(sua.unit_attempt_status,
                                                                suaai.tracking_id) = cst_yes;
        v_base_count                    NUMBER;
        v_one_week_extension_count      NUMBER;
        v_two_week_extension_count      NUMBER;
        v_three_week_plus_extnsn_count  NUMBER;
        v_received_count                NUMBER;
        v_completion_week_ending_dt     DATE;
        v_override_week_ending_dt       DATE;
BEGIN
        -- Determine the session id.
        OPEN c_sess_id;
        FETCH c_sess_id INTO  v_session_id;
        IF c_sess_id%NOTFOUND THEN
                CLOSE c_sess_id;
                RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_sess_id;
        -- Get the teaching periods for the assessment period.
        FOR c_teach_perd_rec IN c_teach_perd(
                        p_ass_perd_cal_type,
                        p_ass_perd_sequence_number) LOOP
                -- Determine the unit offering options within the teaching periods.
                FOR c_uoo_rec IN c_uoo(
                                c_teach_perd_rec.CAL_TYPE,
                                c_teach_perd_rec.sequence_number,
                                p_owner_org_unit_cd,
                                p_owner_ou_start_dt,
                                p_unit_mode) LOOP
                        -- Determine the assessment items within unit offering options within
                        -- the teaching periods.
                        FOR c_uai_rec IN c_uai(
                                        c_uoo_rec.uoo_id) LOOP
                                -- Initialise counters for the unit offering option.
                                v_base_count                    := 0;
                                v_one_week_extension_count      := 0;
                                v_two_week_extension_count      := 0;
                                v_three_week_plus_extnsn_count  := 0;
                                v_received_count                := 0;
                                -- Process the students within the assessment items,
                                -- unit offering options and the teaching periods.
                                FOR c_suaai_rec IN c_suaai(
                                                        c_uoo_rec.uoo_id,
                                                        c_uai_rec.ass_id) LOOP
                                        -- For each record found, increment the base count.
                                        v_base_count := v_base_count + 1;
                                        -- Determine if any extensions apply and the length of the extension.
                                        -- Increment the appropriate counter.
                                        IF c_suaai_rec.override_due_dt IS NOT NULL THEN
                                                v_override_week_ending_dt :=
                                                        IGS_GE_GEN_001.genp_clc_week_end_dt(c_suaai_rec.override_due_dt);
                                                IF (c_suaai_rec.override_due_dt > c_uai_rec.uai_week_ending_dt) THEN
                                                        IF IGS_AS_GEN_001.assp_clc_week_extnsn(c_uai_rec.uai_week_ending_dt,
                                                                                c_suaai_rec.override_due_dt, 1) > 0 THEN
                                                                v_one_week_extension_count := v_one_week_extension_count + 1;
                                                        ELSIF IGS_AS_GEN_001.assp_clc_week_extnsn(c_uai_rec.uai_week_ending_dt,
                                                                                c_suaai_rec.override_due_dt, 2) > 0 THEN
                                                                v_two_week_extension_count := v_two_week_extension_count + 1;
                                                        ELSIF IGS_AS_GEN_001.assp_clc_week_extnsn(c_uai_rec.uai_week_ending_dt,
                                                                                c_suaai_rec.override_due_dt, 3) > 0 THEN
                                                                v_three_week_plus_extnsn_count := v_three_week_plus_extnsn_count + 1;
                                                        END IF;
                                                        -- Insert into SI_AS_ASSR1020 table for the actual week ending date
                                                        -- that the item is now due (override due date).
                                                        x_rowid :=      NULL;
                                                        IGS_AS_DUE_DT_SUMRY_PKG.INSERT_ROW(
                                                                X_ROWID                                         =>      x_rowid,
                                                                X_SESSION_ID                    =>      v_session_id,
                                                                X_AT_ID                             =>  l_AT_ID,
                                                                X_UNIT_CD                       =>      c_uoo_rec.unit_cd,
                                                                X_VERSION_NUMBER                =>      c_uoo_rec.version_number,
                                                                X_CAL_TYPE                      =>      c_teach_perd_rec.CAL_TYPE,
                                                                X_CI_SEQUENCE_NUMBER            =>      c_teach_perd_rec.sequence_number,
                                                                X_OWNER_ORG_UNIT_CD             =>      c_uoo_rec.owner_org_unit_cd,
                                                                X_OWNER_OU_START_DT             =>      c_uoo_rec.owner_ou_start_dt,
                                                                X_UNIT_MODE                     =>      c_uoo_rec.UNIT_MODE,
                                                                X_ASS_ID                        =>      c_uai_rec.ass_id,
                                                                X_WEEK_ENDING_DT                =>      v_override_week_ending_dt,
                                                                X_BASE_COUNT                    =>      NULL,
                                                                X_EXPECTED_OVERDUE_COUNT        =>      1,
                                                                X_ONE_WEEK_EXTENSION_COUNT      =>      NULL,
                                                                X_TWO_WEEK_EXTENSION_COUNT      =>      NULL,
                                                                X_THREE_WEEK_PLUS_EXTNSN_COUNT  =>      NULL,
                                                                X_RECEIVED_COUNT                =>      NULL,
                                                                X_MODE                          =>      'R'
                                                                );
                                                END IF;
                                        END IF;
                                        -- Determine if the item has been received from the student.
                                        IF c_suaai_rec.completion_dt IS NOT NULL THEN
                                                v_completion_week_ending_dt
                                                                := IGS_GE_GEN_001.genp_clc_week_end_dt(c_suaai_rec.completion_dt);
                                                -- If the date received is the same week due then increment the counter.
                                                IF c_uai_rec.uai_week_ending_dt = v_completion_week_ending_dt THEN
                                                        v_received_count := v_received_count + 1;
                                                ELSE
                                                        -- Insert into SI_AS_ASSR1020 table for the actual week ending date
                                                        -- that the item was received (completion date of the tracking step.).
                                                        x_rowid :=      NULL;
                                                        IGS_AS_DUE_DT_SUMRY_PKG.INSERT_ROW(
                                                                X_ROWID                                         =>      x_rowid,
                                                                X_SESSION_ID                    =>      v_session_id,
                                                                X_AT_ID                             =>    l_AT_ID,
                                                                X_UNIT_CD                       =>      c_uoo_rec.unit_cd,
                                                                X_VERSION_NUMBER                =>      c_uoo_rec.version_number,
                                                                X_CAL_TYPE                      =>      c_teach_perd_rec.CAL_TYPE,
                                                                X_CI_SEQUENCE_NUMBER            =>      c_teach_perd_rec.sequence_number,
                                                                X_OWNER_ORG_UNIT_CD             =>      c_uoo_rec.owner_org_unit_cd,
                                                                X_OWNER_OU_START_DT             =>      c_uoo_rec.owner_ou_start_dt,
                                                                X_UNIT_MODE                     =>      c_uoo_rec.UNIT_MODE,
                                                                X_ASS_ID                        =>      c_uai_rec.ass_id,
                                                                X_WEEK_ENDING_DT                =>      v_completion_week_ending_dt,
                                                                X_BASE_COUNT                    =>      NULL,
                                                                X_EXPECTED_OVERDUE_COUNT        =>      1,
                                                                X_ONE_WEEK_EXTENSION_COUNT      =>      NULL,
                                                                X_TWO_WEEK_EXTENSION_COUNT      =>      NULL,
                                                                X_THREE_WEEK_PLUS_EXTNSN_COUNT  =>      NULL,
                                                                X_RECEIVED_COUNT                =>      NULL,
                                                                X_MODE                          =>      'R'
                                                                );
                                                END IF;
                                        END IF;
                                END LOOP;
                                IF v_base_count > 0 THEN
                                        -- If assessment item records exist, then insert counts
                                        -- for the unit and assessment items processed.
                                                        x_rowid :=      NULL;
                                END IF;
                        END LOOP;
                END LOOP;
        END LOOP;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_sess_id%ISOPEN) THEN
                        CLOSE c_sess_id;
                END IF;
                IF (c_teach_perd%ISOPEN) THEN
                        CLOSE c_teach_perd;
                END IF;
                IF (c_uoo%ISOPEN) THEN
                        CLOSE c_uoo;
                END IF;
                IF (c_uai%ISOPEN) THEN
                        CLOSE c_uai;
                END IF;
                IF (c_suaai%ISOPEN) THEN
                        CLOSE c_suaai;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_ins_asr1020_tmp');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_ins_asr1020_tmp;
 PROCEDURE assp_ins_dflt_evsa_a(
 errbuf  out NOCOPY  varchar2,
retcode out NOCOPY  number,
p_exam_cal in VARCHAR2,
p_org_id in NUMBER
 )
IS
p_exam_cal_type                 igs_ca_inst.cal_type%type;
p_exam_ci_sequence_number       igs_ca_inst.sequence_number%type;

BEGIN   -- assp_ins_dflt_evsa_a
        -- Default the IGS_AS_EXMVNU_SESAVL records for all venues within an
        -- examination period.
        -- It will set all open venues to be available for all sessions.
 --set the org id
 igs_ge_gen_003.set_org_id(p_org_id);
--Block for Parameter Validation/Splitting of Parameters
retcode:=0;
BEGIN
IF  p_exam_cal  IS NULL THEN
                         p_exam_cal_type:=NULL;
           p_exam_ci_sequence_number:=NULL;
ELSE
                          p_exam_cal_type := RTRIM(SUBSTR(p_exam_cal, 101, 10));
            p_exam_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_exam_cal, 112,6)));
END IF;
END;
--End of Block for Parameter Validation/Splitting of Parameters


DECLARE
        CURSOR  c_ve IS
                SELECT  venue_cd
                FROM    IGS_GR_VENUE
                WHERE   closed_ind = 'N';
        CURSOR  c_es (
                        cp_venue_cd     IGS_GR_VENUE.venue_cd%TYPE) IS
                SELECT  exam_cal_type,
                        exam_ci_sequence_number,
                        dt_alias,
                        dai_sequence_number,
                        ci_start_dt,
                        ci_end_dt,
                        start_time,
                        end_time,
                        ese_id
                FROM    IGS_AS_EXAM_SESSION             es
                WHERE   exam_cal_type           = p_exam_cal_type               AND
                        exam_ci_sequence_number = p_exam_ci_sequence_number     AND
                        NOT EXISTS (
                                SELECT  'x'
                                FROM    IGS_AS_EXMVNU_SESAVL    evsa
                                WHERE   evsa.ese_id     = es.ese_id AND
                                        evsa.venue_cd   = cp_venue_cd
                        );
BEGIN
        FOR v_ve_rec IN c_ve LOOP
                FOR v_es_rec IN c_es(
                                v_ve_rec.venue_cd) LOOP
                        x_rowid :=      NULL;
                        IGS_AS_EXMVNU_SESAVL_PKG.INSERT_ROW(
                                X_ROWID                         =>    x_rowid,
                                X_ORG_ID                      =>        p_org_id,
                                X_VENUE_CD                    =>        v_ve_rec.venue_cd,
                                X_EXAM_CAL_TYPE               =>        v_es_rec.exam_cal_type,
                                X_EXAM_CI_SEQUENCE_NUMBER     =>        v_es_rec.exam_ci_sequence_number,
                                X_DT_ALIAS                    =>        v_es_rec.dt_alias,
                                X_DAI_SEQUENCE_NUMBER         =>        v_es_rec.dai_sequence_number,
                                X_START_TIME                  =>        v_es_rec.start_time,
                                X_END_TIME                    =>        v_es_rec.end_time,
                                X_ESE_ID                      =>        v_es_rec.ese_id,
                                X_COMMENTS                    =>        NULL,
                                X_MODE                        =>        'R'
                                );
                END LOOP;
        END LOOP;
        COMMIT;
END;
EXCEPTION
        WHEN OTHERS THEN
   Retcode := 2;
   errbuf  :=  fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END assp_ins_dflt_evsa_a;
 PROCEDURE assp_ins_ese_sprvsr(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_exam_supervisor_type IN VARCHAR2 ,
  p_venue_cd IN VARCHAR2 ,
  p_session_venue_ind IN VARCHAR2 DEFAULT 'N',
  p_ignore_warnings_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
IS
BEGIN   --assp_ins_ese_sprvsr
        --This module will insert a supervisor to exam sessions at a
        --IGS_GR_VENUE within a calendar period.
        --The module will be called from ASSF4630 and with two scenarios:
        --1. Default a supervisor to sessions within a IGS_GR_VENUE. (p_person_id not null)
        --2. Default supervisors to Off-campus venues. (p_person_id is null)
        --It will provide the ability to enforce that if warnings exist
        --when validating the IGS_PE_PERSON, then either allocate (p_ignore_warnings = 'Y')
        --or do not allocate (p_ignore_warnings = 'N') the supervisor.
        --This module will return a general message indicating that warnings
        --or errors where encountered during the processing if that is the case.
DECLARE
        v_message_name          VARCHAR2(30);
        v_tmp_message_name      VARCHAR2(30);

        v_lr_exists             VARCHAR2(1);
        CURSOR  c_esvv IS
                SELECT  esvv.ese_id,
                        esvv.venue_cd,
                        ve.exam_location_cd
                FROM    IGS_AS_ESE_VENUE_V      esvv,
                        IGS_GR_VENUE                    ve
                WHERE   esvv.exam_cal_type              = p_exam_cal_type               AND
                        esvv.exam_ci_sequence_number    = p_exam_ci_sequence_number     AND
                        esvv.venue_cd                   = ve.venue_cd;
        CURSOR  c_lr(
                cp_exam_location_cd     IGS_GR_VENUE.exam_location_cd%TYPE) IS
                SELECT  'X'
                FROM    IGS_AD_LOCATION_REL     lr,
                        IGS_AD_LOCATION         loc,
                        IGS_AD_LOCATION_TYPE            lot
                WHERE   lr.sub_location_cd      = cp_exam_location_cd   AND
                        lr.location_cd          = loc.location_cd       AND
                        loc.LOCATION_TYPE       = lot.LOCATION_TYPE     AND
                        lot.s_location_type     = 'CAMPUS';
        CURSOR  c_els (
                        cp_venue_cd     IGS_AS_ESE_VENUE_V.venue_cd%TYPE) IS
                SELECT  els.person_id
                FROM    IGS_AS_EXM_LOC_SPVSR    els,
                        IGS_GR_VENUE                    ve
                WHERE   els.exam_location_cd    = ve.exam_location_cd AND
                        ve.venue_cd             = cp_venue_cd;
        CURSOR c_ve IS
                SELECT  esvv.ese_id,
                        esvv.venue_cd
                FROM    IGS_AS_ESE_VENUE_V esvv
                WHERE   esvv.exam_cal_type              = p_exam_cal_type               AND
                        esvv.exam_ci_sequence_number    = p_exam_ci_sequence_number     AND
                        esvv.venue_cd                   = p_venue_cd;
        FUNCTION asspl_val_sprvsr(
                                p_person_id             IGS_AS_EXM_INS_SPVSR.person_id%TYPE,
                                p_ese_id                IN OUT NOCOPY IGS_AS_ESE_VENUE_V.ese_id%TYPE,
                                p_venue_cd              IGS_AS_EXM_INS_SPVSR.venue_cd%TYPE,
                                p_exam_supervisor_type  IGS_AS_EXM_INS_SPVSR.EXAM_SUPERVISOR_TYPE%TYPE,
                                p_ignore_warnings       VARCHAR2,
                                p_message_name          OUT NOCOPY VARCHAR2)
        RETURN BOOLEAN
        IS
        BEGIN   --asspl_val_sprvsr
                --Local function to validate the supervisor
        DECLARE
                v_exam_cal_type                 IGS_AS_EXM_INS_SPVSR.exam_cal_type%TYPE;
                v_exam_ci_sequence_number       IGS_AS_EXM_INS_SPVSR.exam_ci_sequence_number%TYPE;
                v_dt_alias                      IGS_AS_EXM_INS_SPVSR.dt_alias%TYPE;
                v_dai_sequence_number           IGS_AS_EXM_INS_SPVSR.dai_sequence_number%TYPE;
                v_start_time                    IGS_AS_EXM_INS_SPVSR.start_time%TYPE;
                v_end_time                      IGS_AS_EXM_INS_SPVSR.end_time%TYPE;
                v_local_message_name            VARCHAR2(30);
                v_exam_supervisor_type  IGS_AS_EXM_SUPRVISOR.EXAM_SUPERVISOR_TYPE%TYPE;
                CURSOR c_esu IS
                        SELECT  esu.EXAM_SUPERVISOR_TYPE
                        FROM    IGS_AS_EXM_SUPRVISOR    esu
                        WHERE   esu.person_id   = p_person_id;
        BEGIN
                v_local_message_name := NULL;
                p_message_name := NULL;
                -- Validate that the supervisor type is not closed.
                IF (p_exam_supervisor_type IS NULL) THEN
                        OPEN  c_esu;
                        FETCH c_esu INTO v_exam_supervisor_type;
                        CLOSE c_esu;
                ELSE
                        v_exam_supervisor_type := p_exam_supervisor_type;
                END IF;
                IF (IGS_AS_VAL_ESU.assp_val_est_closed(
                                                v_exam_supervisor_type,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        RETURN FALSE;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                --Check the following warnings:
                -- Validate if the IGS_PE_PERSON is not an active student.
                -- Warning only.
                IF (IGS_AS_VAL_EIS.assp_val_actv_stdnt(
                                                p_person_id,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate the IGS_PE_PERSON is a staff member.
                -- Warning only.
                IF (igs_ad_val_acai.genp_val_staff_prsn(
                                                p_person_id,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Get the exam session key fields.
                assp_get_ese_key(
                                v_exam_cal_type,
                                v_exam_ci_sequence_number,
                                v_dt_alias,
                                v_dai_sequence_number,
                                v_start_time,
                                v_end_time,
                                p_ese_id);
                -- Validate if the IGS_PE_PERSON is allocated to different exam locations for the
                -- same day.
                -- Warning only.
                IF (IGS_AS_VAL_ESVS.assp_val_esu_ese_el(
                                                p_person_id,
                                                v_exam_cal_type,
                                                v_exam_ci_sequence_number,
                                                v_dt_alias,
                                                v_dai_sequence_number,
                                                v_start_time,
                                                v_end_time,
                                                p_venue_cd,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate if the limit exceeded for the session and IGS_GR_VENUE.
                -- Warning only.
                --w.r.t BUG #1956374 , Procedure assp_val_esu_ese_lmt reference is changed
                IF (IGS_AS_VAL_EIS.assp_val_esu_ese_lmt(
                                                p_person_id,
                                                v_exam_cal_type,
                                                v_exam_ci_sequence_number,
                                                v_dt_alias,
                                                v_dai_sequence_number,
                                                v_start_time,
                                                v_end_time,
                                                p_venue_cd,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate IGS_PE_PERSON cannot be allocated concurrent sessions at different
                -- venues.
                -- Warning only.
                IF (IGS_AS_VAL_ESVS.assp_val_esu_ese_ve(
                                                p_person_id,
                                                v_exam_cal_type,
                                                v_exam_ci_sequence_number,
                                                v_dt_alias,
                                                v_dai_sequence_number,
                                                v_start_time,
                                                v_end_time,
                                                NULL,
                                                NULL,
                                                p_venue_cd,
                                                v_local_message_name) = FALSE) THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate IGS_GR_VENUE is within supervisor's exam locations.
                -- Warning only.
                IF IGS_AS_VAL_ESVS.assp_val_els_venue(
                                                p_person_id,
                                                p_venue_cd,
                                                v_local_message_name) = FALSE THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate if more than one IGS_PE_PERSON in-charge at a session and IGS_GR_VENUE.
                -- Warning only.
                IF IGS_AS_VAL_EIS.assp_val_ese_inchrg(
                                                p_person_id,
                                                v_exam_cal_type,
                                                v_exam_ci_sequence_number,
                                                v_dt_alias,
                                                v_dai_sequence_number,
                                                v_start_time,
                                                v_end_time,
                                                p_venue_cd,
                                                v_exam_supervisor_type,
                                                v_local_message_name) = FALSE THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                -- Validate if IGS_PE_PERSON is allocated as in-charge when not normally.
                -- Warning only.
                IF IGS_AS_VAL_EIS.assp_val_est_inchrg(
                                                p_person_id,
                                                v_exam_supervisor_type,
                                                v_local_message_name) = FALSE THEN
                        p_message_name := v_local_message_name;
                        IF (p_ignore_warnings = 'N') THEN
                                RETURN FALSE;
                        END IF;
                        -- At a later date, this may insert an IGS_GE_S_LOG_ENTRY for a report.
                END IF;
                RETURN TRUE;
        END;
        END asspl_val_sprvsr;
        PROCEDURE asspl_ins_ve_sprvsr(
                                p_person_id             IGS_AS_EXM_INS_SPVSR.person_id%TYPE,
                                p_ese_id                IGS_AS_ESE_VENUE_V.ese_id%TYPE,
                                p_venue_cd              IGS_AS_EXM_INS_SPVSR.venue_cd%TYPE,
                                p_exam_supervisor_type  IGS_AS_EXM_INS_SPVSR.EXAM_SUPERVISOR_TYPE%TYPE,
                                p_session_venue_ind     VARCHAR2)
        IS
        BEGIN   --asspl_ins_ve_sprvsr
                --Local procedure to insert the supervisor
        DECLARE
                v_exam_supervisor_type          IGS_AS_EXM_SUPRVISOR.EXAM_SUPERVISOR_TYPE%TYPE;
                CURSOR c_esu IS
                        SELECT  esu.EXAM_SUPERVISOR_TYPE
                        FROM    IGS_AS_EXM_SUPRVISOR    esu
                        WHERE   esu.person_id   = p_person_id;
                CURSOR c_ei IS
                        SELECT  ei.ass_id
                        FROM    IGS_AS_EXAM_INSTANCE    ei
                        WHERE   ei.ese_id       = p_ese_id      AND
                                ei.venue_cd     = p_venue_cd;
        BEGIN
                --Determine the supervisor type to use
                IF (p_exam_supervisor_type IS NULL) THEN
                        OPEN c_esu;
                        FETCH c_esu INTO v_exam_supervisor_type;
                        CLOSE c_esu;
                ELSE
                        v_exam_supervisor_type := p_exam_supervisor_type;
                END IF;
                IF (p_session_venue_ind = 'Y') THEN
                        -- Insert IGS_PE_PERSON into the IGS_AS_EXM_SES_VN_SP table.
                        x_rowid :=      NULL;
                        IGS_AS_EXM_SES_VN_SP_PKG.INSERT_ROW(
                                X_ROWID                     =>  x_rowid,
                                X_PERSON_ID                 =>  p_person_id,
                                X_EXAM_CAL_TYPE             =>  NULL,
                                X_EXAM_CI_SEQUENCE_NUMBER   =>  NULL,
                                X_DT_ALIAS                  =>  NULL,
                                X_DAI_SEQUENCE_NUMBER       =>  NULL,
                                X_START_TIME                =>  NULL,
                                X_END_TIME                  =>  NULL,
                                X_VENUE_CD                  =>  p_venue_cd,
                                X_ESE_ID                    =>  p_ese_id,
                                X_EXAM_SUPERVISOR_TYPE      =>  v_exam_supervisor_type,
                                X_OVERRIDE_START_TIME       =>  NULL,
                                X_OVERRIDE_END_TIME         =>  NULL,
                                X_MODE => 'R'
                                );
                        -- At a later date, a IGS_GE_S_LOG_ENTRY may be created to indicate successful
                        -- insertion.
                ELSE
                        -- Insert IGS_PE_PERSON into the IGS_AS_EXM_INS_SPVSR table. Put them into all exams
                        -- for the IGS_GR_VENUE and session.
                        FOR v_ei_rec IN c_ei LOOP
                                BEGIN
                                        IGS_AS_EXM_INS_SPVSR_PKG.INSERT_ROW(
                                                X_ROWID                     =>  x_rowid,
                                                X_PERSON_ID                 =>  p_person_id,
                                                X_ASS_ID                    =>  v_ei_rec.ass_id,
                                                X_EXAM_CAL_TYPE             =>  NULL,
                                                X_EXAM_CI_SEQUENCE_NUMBER   =>  NULL,
                                                X_DT_ALIAS                  =>  NULL,
                                                X_DAI_SEQUENCE_NUMBER       =>  NULL,
                                                X_START_TIME                =>  NULL,
                                                X_END_TIME                  =>  NULL,
                                                X_VENUE_CD                  =>  p_venue_cd,
                                                X_ESE_ID                    =>  p_ese_id,
                                                X_EXAM_SUPERVISOR_TYPE      =>  v_exam_supervisor_type,
                                                X_OVERRIDE_START_TIME       =>  NULL,
                                                X_OVERRIDE_END_TIME         =>  NULL,
                                                X_MODE                      =>  'R'
                                                );
                                        -- At a later date, an IGS_GE_S_LOG_ENTRY may be created to indicate
                                        --successful insertion.
                                        -- Ignore IGS_GE_EXCEPTIONS indicating that the record has already been created
                                        -- and remain inside the loop
                                EXCEPTION
                                        WHEN DUP_VAL_ON_INDEX THEN
                                                NULL;
                                        WHEN OTHERS THEN
                                                RAISE;
                                END;
                        END LOOP;
                END IF;
        END;
        -- Ignore IGS_GE_EXCEPTIONS indicating that the record has already been created.
        EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                        NULL;
                WHEN OTHERS THEN
                        RAISE;
        END asspl_ins_ve_sprvsr;
BEGIN
        --Set default message number
        p_message_name          := NULL;
        v_message_name          := NULL;
        v_tmp_message_name      := NULL;
        IF (p_person_id IS NULL) THEN
                --Perform processing to default the supervisor's
                --to OFF-CAMPUS exam venues at sessions within the exam
                --period (p_exam_cal_type/p_exam_ci_sequence_number).
                --Select all exam session venues for the exam period
                --(IGS_AS_ESE_VENUE_V) where the IGS_GR_VENUE is not linked to a campus.
                FOR v_esvv_rec IN c_esvv LOOP
                        OPEN c_lr(
                                v_esvv_rec.exam_location_cd);
                        FETCH c_lr INTO v_lr_exists;
                        IF (c_lr%NOTFOUND) THEN
                                CLOSE c_lr;
                                --The exam IGS_AD_LOCATION is an off campus IGS_AD_LOCATION
                                --For each IGS_GR_VENUE, select the supervisors for which
                                -- the exam venues are within their nominated exam locations.
                                FOR v_els_rec IN c_els(
                                                        v_esvv_rec.venue_cd) LOOP
                                        --Call a local function to validate the IGS_PE_PERSON being allocated
                                        IF (asspl_val_sprvsr(
                                                                v_els_rec.person_id,
                                                                v_esvv_rec.ese_id,
                                                                v_esvv_rec.venue_cd,
                                                                p_exam_supervisor_type,
                                                                p_ignore_warnings_ind,
                                                                v_message_name)  = TRUE) THEN
                                                --Insert the supervisor
                                                asspl_ins_ve_sprvsr(
                                                                        v_els_rec.person_id,
                                                                        v_esvv_rec.ese_id,
                                                                        v_esvv_rec.venue_cd,
                                                                        p_exam_supervisor_type,
                                                                        p_session_venue_ind);
                                        END IF;
                                        IF v_message_name IS NOT NULL THEN
                                                v_tmp_message_name := v_message_name;
                                        END IF;
                                END LOOP;
                        END IF;
                        IF(c_lr%ISOPEN) THEN
                                CLOSE c_lr;
                        END IF;
                END LOOP;
        ELSE
                --p_person_id is not null so default the IGS_PE_PERSON for all sessions at the IGS_GR_VENUE.
                --Select all exam sessions for p_venue_cd within the exam period.
                FOR v_ve_rec IN c_ve LOOP
                         --Call a local function to validate the IGS_PE_PERSON being allocated.
                         IF (asspl_val_sprvsr(
                                        p_person_id,
                                        v_ve_rec.ese_id,
                                        v_ve_rec.venue_cd,
                                        p_exam_supervisor_type,
                                        p_ignore_warnings_ind,
                                        v_message_name)  = TRUE) THEN
                                -- Insert the supervisor.
                                asspl_ins_ve_sprvsr(
                                                p_person_id,
                                                v_ve_rec.ese_id,
                                                p_venue_cd,
                                                p_exam_supervisor_type,
                                                p_session_venue_ind);
                        END IF;
                        IF v_message_name IS NOT NULL THEN
                                v_tmp_message_name := v_message_name;
                        END IF;
                END LOOP;
        END IF;
        --If errors or warnings were encountered during processing,
        --return a message to indicate this.
        IF (v_tmp_message_name IS NOT NULL) THEN
                p_message_name := 'IGS_AS_ERROR_DFLT_SUPERVISOR';
        END IF;
END;
EXCEPTION
        WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_ins_ese_sprvsr');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_ins_ese_sprvsr;
 PROCEDURE assp_ins_gs_duprec(
  p_old_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_old_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_new_grading_schema_cd IN IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE ,
  p_new_version_number IN IGS_AS_GRD_SCHEMA.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
IS
BEGIN   -- assp_ins_gs_duprec
        -- This procedure is responsible for transferring all of the details for a
        -- nominated
        -- grading schema over into another grading schema.
        -- Get a record from IGS_AS_GRD_SCH_GRADE and make duplicates under the new
        -- IGS_AS_GRD_SCHEMA.
DECLARE
        cst_exist_ind           CONSTANT  CHAR := 'x';
        CURSOR c_gs_new (
                        cp_new_grading_schema_cd        IN      IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE,
                        cp_new_version_number   IN      IGS_AS_GRD_SCHEMA.version_number%TYPE) IS
                SELECT  cst_exist_ind
                FROM    IGS_AS_GRD_SCHEMA
                WHERE   grading_schema_cd       = cp_new_grading_schema_cd AND
                        version_number  = cp_new_version_number;
        CURSOR c_gs_old (
                        cp_old_grading_schema_cd        IN      IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE,
                        cp_old_version_number   IN      IGS_AS_GRD_SCHEMA.version_number%TYPE) IS
                SELECT  cst_exist_ind
                FROM    IGS_AS_GRD_SCHEMA
                WHERE   grading_schema_cd       = cp_old_grading_schema_cd AND
                        version_number  = cp_old_version_number;
        CURSOR c_gsg (
                        cp_old_grading_schema_cd        IN      IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE,
                        cp_old_version_number   IN      IGS_AS_GRD_SCH_GRADE.version_number%TYPE) IS
                SELECT  *
                FROM    IGS_AS_GRD_SCH_GRADE
                WHERE   grading_schema_cd       = cp_old_grading_schema_cd AND
                        version_number  = cp_old_version_number AND
                        closed_ind = 'N';
        v_gs_old_rec            c_gs_old%ROWTYPE;
        v_gs_new_rec            c_gs_new%ROWTYPE;
        v_gsg_rec                       c_gsg%ROWTYPE;
        v_copy_flag             BOOLEAN;
        v_grading_schema_cd             IGS_AS_GRD_SCHEMA.grading_schema_cd%TYPE;
        v_version_number                IGS_AS_GRD_SCHEMA.version_number%TYPE;
BEGIN
        -- Set the default message number
        p_message_name := NULL;
        OPEN c_gs_new(
                        p_new_grading_schema_cd,
                        p_new_version_number);
        FETCH c_gs_new INTO v_gs_new_rec;
        IF c_gs_new%NOTFOUND THEN
                CLOSE c_gs_new;
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN;
        END IF;
        CLOSE c_gs_new;
        OPEN c_gs_old(
                        p_old_grading_schema_cd,
                        p_old_version_number);
        FETCH c_gs_old INTO v_gs_old_rec;
        IF c_gs_old%NOTFOUND THEN
                CLOSE c_gs_old;
                p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN;
        END IF;
        CLOSE c_gs_old;
        v_copy_flag := TRUE;
        v_grading_schema_cd := p_new_grading_schema_cd;
        v_version_number := p_new_version_number;
        FOR v_gsg_rec IN c_gsg(
                        p_old_grading_schema_cd,
                        p_old_version_number) LOOP
                BEGIN
                        x_rowid :=      NULL;
                        IGS_AS_GRD_SCH_GRADE_PKG.INSERT_ROW(
                                X_ROWID                        =>       x_rowid,
                                X_GRADING_SCHEMA_CD            =>       p_new_grading_schema_cd,
                                X_VERSION_NUMBER               =>       p_new_version_number,
                                X_GRADE                        =>       v_gsg_rec.grade,
                                X_FULL_GRADE_NAME              =>       v_gsg_rec.full_grade_name,
                                X_S_RESULT_TYPE                =>       v_gsg_rec.s_result_type,
                                X_SHOW_ON_NOTICEBOARD_IND      =>       v_gsg_rec.show_on_noticeboard_ind,
                                X_SHOW_ON_OFFICIAL_NTFCTN_IND  =>       v_gsg_rec.show_on_official_ntfctn_ind,
                                X_S_SPECIAL_GRADE_TYPE         =>       NULL,
                                X_SHOW_IN_NEWSPAPER_IND        =>       v_gsg_rec.show_in_newspaper_ind,
                                X_SHOW_INTERNALLY_IND          =>       v_gsg_rec.show_internally_ind,
                                X_SYSTEM_ONLY_IND              =>       v_gsg_rec.system_only_ind,
                                X_DFLT_OUTSTANDING_IND         =>       v_gsg_rec.dflt_outstanding_ind,
                                X_EXTERNAL_GRADE               =>       v_gsg_rec.external_grade,
                                X_LOWER_MARK_RANGE             =>       v_gsg_rec.lower_mark_range,
                                X_UPPER_MARK_RANGE             =>       v_gsg_rec.upper_mark_range,
                                X_MIN_PERCENTAGE               =>       v_gsg_rec.min_percentage,
                                X_MAX_PERCENTAGE               =>       v_gsg_rec.max_percentage,
                                X_GPA_VAL                      =>       v_gsg_rec.gpa_val,
                                X_RANK                         =>       v_gsg_rec.rank,
                                X_SHOW_IN_EARNED_CRDT_IND      =>       v_gsg_rec.show_in_earned_crdt_ind,
                                X_INCL_IN_REPEAT_PROCESS_IND   =>       v_gsg_rec.incl_in_repeat_process_ind,
                                X_ADMIN_ONLY_IND               =>       v_gsg_rec.admin_only_ind,
                                X_GRADING_PERIOD_CD            =>       v_gsg_rec.grading_period_cd,
                                X_REPEAT_GRADE                 =>       v_gsg_rec.repeat_grade,
                                X_MODE                         =>       'R',
                                X_Attribute_Category           =>      v_gsg_rec.Attribute_Category,
                                X_Attribute1                   => v_gsg_rec.Attribute1,
                                X_Attribute2                      => v_gsg_rec.Attribute2,
                                X_Attribute3                      => v_gsg_rec.Attribute3,
                                X_Attribute4                      => v_gsg_rec.Attribute4,
                                X_Attribute5                      => v_gsg_rec.Attribute5,
                                X_Attribute6                      => v_gsg_rec.Attribute6,
                                X_Attribute7                      => v_gsg_rec.Attribute7,
                                X_Attribute8                      => v_gsg_rec.Attribute8,
                                X_Attribute9                      => v_gsg_rec.Attribute9,
                                X_Attribute10                     => v_gsg_rec.Attribute10,
                                X_Attribute11                     => v_gsg_rec.Attribute11,
                                X_Attribute12                     => v_gsg_rec.Attribute12,
                                X_Attribute13                     => v_gsg_rec.Attribute13,
                                X_Attribute14                     => v_gsg_rec.Attribute14,
                                X_Attribute15                     => v_gsg_rec.Attribute15,
                                X_Attribute16                     => v_gsg_rec.Attribute16,
                                X_Attribute17                     => v_gsg_rec.Attribute17,
                                X_Attribute18                     => v_gsg_rec.Attribute18,
                                X_Attribute19                     => v_gsg_rec.Attribute19,
                                X_Attribute20                     => v_gsg_rec.Attribute20,
                                X_CLOSED_IND                      => 'N');
                EXCEPTION
                        WHEN OTHERS THEN
                                v_copy_flag := FALSE;
                END;
        END LOOP;
        IF (v_copy_flag = FALSE) THEN
                p_message_name := 'IGS_AS_FAIL_COPY_ALL_GRDSCH';
        ELSE
                p_message_name := 'IGS_AS_SUCCESS_COPY_ALL_GRDSC';
        END IF;
END;
EXCEPTION
        WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_006.assp_ins_gs_duprec');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_ins_gs_duprec;

 PROCEDURE assp_upd_suao_trans(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_assess_calendar IN VARCHAR2 ,
  p_teaching_calendar IN VARCHAR2,
  p_crs_grp_cd IN VARCHAR2 ,
  p_crs_cd IN VARCHAR2 ,
  p_crs_org_unt_cd IN VARCHAR2 ,
  p_crs_lctn_cd IN VARCHAR2 ,
  p_crs_attd_md IN VARCHAR2 ,
  p_unt_cd IN VARCHAR2 ,
  p_unt_org_unt_cd IN VARCHAR2 ,
  p_unt_lctn_cd IN VARCHAR2 ,
  p_u_mode IN VARCHAR2 ,
  p_u_class IN VARCHAR2 ,
  p_allow_invalid_ind IN VARCHAR2 ,
  p_org_id IN NUMBER)
IS
BEGIN
  --
  retcode:=0;
  --
  -- As per 2239087, this concurrent program is obsolete and if the user
  -- tries to run this program then an error message should be logged into the log
  -- file that the concurrent program is obsolete and should not be run.
  --
  fnd_message.set_name ('IGS', 'IGS_GE_OBSOLETE_JOB');
  fnd_file.put_line (fnd_file.log, fnd_message.get);
  --
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf:=fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    igs_ge_msg_stack.conc_exception_hndl;
END assp_upd_suao_trans;
END IGS_AS_GEN_006 ;

/
