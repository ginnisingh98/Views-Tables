--------------------------------------------------------
--  DDL for Package Body IGS_EN_REINSTATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_REINSTATE_PKG" AS
/* $Header: IGSENB4B.pls 120.3 2006/02/21 00:55:56 svanukur noship $ */

 PROCEDURE reinstate_stdnt_unit_attempt(
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_course_version               IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_person_type                  IN     VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_message                      OUT NOCOPY VARCHAR2,
    p_deny_warn                    OUT NOCOPY VARCHAR2)

  ------------------------------------------------------------------
  --Created by  : Somasekar, Oracle IDC
  --Date created: 11-AUG-2005
  --
  --Purpose: This procedure validates the unit attempt and program attempt
  --           while renistating the discontinued unit.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

 AS
  --  Cursor to find unit attempt status
  CURSOR uoo_status   IS
    SELECT   unit_section_status
    FROM     igs_ps_unit_ofr_opt
    WHERE    uoo_id  = p_uoo_id;
--curosr to get student unit attempt status

CURSOR sua_status is
 Select unit_Attempt_Status
 FROM igs_En_su_Attempt
 where person_Id = p_person_id
 AND course_cd = p_course_cd
 AND uoo_id  = p_uoo_id;

  -- Cursor to get the Unit Attempt Details .
  CURSOR igs_en_su_attempt_cur IS
   SELECT igs_en_su_attempt.*
   FROM   igs_en_su_attempt
   WHERE  person_id       = p_person_id AND
          course_cd       = p_course_cd AND
          uoo_id          = p_uoo_id;

  igs_en_su_attempt_rec igs_en_su_attempt_cur%ROWTYPE;
  l_uoo_status  uoo_status%ROWTYPE;
  l_enr_meth_type igs_en_method_type.enr_method_type%TYPE;
  l_enr_cal_type VARCHAR2(20);
  l_enr_ci_seq NUMBER(20);
  l_enr_cat VARCHAR2(20);
  l_enr_comm VARCHAR2(2000);
  l_enr_categories                      VARCHAR2(255);
  l_acad_cal_type igs_ca_inst.cal_type%type;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%type;
  l_acad_start_dt igs_ca_inst.start_dt%type;
  l_acad_end_dt igs_ca_inst.end_dt%type;
  l_alternate_code igs_ca_inst.alternate_code%type;
  l_acad_message varchar2(100);
  l_message  VARCHAR2(1200);
  l_return_status           VARCHAR2(10);
  l_sua_Status igs_En_Su_Attempt.unit_Attempt_Status%TYPE;

 BEGIN
 --check if the unit is in discontinued state .
 OPEN sua_status;
FETCH sua_status INTO l_sua_Status;
close sua_status;
IF l_sua_Status <> 'DISCONTIN'
THEN p_message := 'IGS_GE_RECORD_CHANGED';
  p_return_status := 'FALSE';
  p_deny_warn := 'DENY';
  RETURN;
  END IF;

  OPEN uoo_status;
  FETCH uoo_status INTO l_uoo_status;
  CLOSE uoo_status;
  IF l_uoo_status.unit_section_status IN ('CANCELLED', 'PLANNED', 'NOT_OFFERED') THEN
  p_message := 'IGS_EN_SS_CANNOT_WAITLIST';
  p_return_status := 'FALSE';
  p_deny_warn := 'DENY';
  RETURN;
  END IF;

  -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_meth_type,
       p_error_message   => p_message,
       p_ret_status      => p_return_status);

    -- added below logic to get the Academic Calendar which is used by method enrp_get_enr_cat    --
    -- get the academic calendar of the given Load Calendar
    --
  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                          p_cal_type                => p_load_cal_type,
                          p_ci_sequence_number      => p_load_sequence_number,
                          p_acad_cal_type           => l_acad_cal_type,
                          p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                          p_acad_ci_start_dt        => l_acad_start_dt,
                          p_acad_ci_end_dt          => l_acad_end_dt,
                          p_message_name            => l_acad_message );

  IF l_acad_message IS NOT NULL THEN
     p_message := l_acad_message;
     p_return_status := 'FALSE';
     p_deny_warn := 'DENY';
  END IF;

  l_enr_cat := igs_en_gen_003.enrp_get_enr_cat( p_person_id               =>    p_person_id,
                                                p_course_cd               =>    p_course_cd ,
                                                p_cal_type                =>    l_acad_cal_type ,
                                                p_ci_sequence_number      =>    l_acad_ci_sequence_number,
                                                p_session_enrolment_cat   =>    NULL,
                                                p_enrol_cal_type          =>    l_enr_cal_type,
                                                p_enrol_ci_sequence_number=>    l_enr_ci_seq,
                                                p_commencement_type       =>    l_enr_comm,
                                                p_enr_categories          =>    l_enr_categories );

  IF l_enr_comm = 'BOTH' THEN
     l_enr_comm :='ALL';
  END IF;

  OPEN igs_en_su_attempt_cur;
  FETCH igs_en_su_attempt_cur INTO igs_en_su_attempt_rec;
  CLOSE igs_en_su_attempt_cur;

  igs_en_sua_api.update_unit_attempt(
               X_ROWID                         =>   igs_en_su_attempt_rec.row_id,
               X_PERSON_ID                     =>   igs_en_su_attempt_rec.person_id,
               X_COURSE_CD                     =>   igs_en_su_attempt_rec.course_cd,
               X_UNIT_CD                       =>   igs_en_su_attempt_rec.unit_cd,
               X_CAL_TYPE                      =>   igs_en_su_attempt_rec.cal_type,
               X_CI_SEQUENCE_NUMBER            =>   igs_en_su_attempt_rec.ci_sequence_number,
               X_VERSION_NUMBER                =>   igs_en_su_attempt_rec.version_number,
               X_LOCATION_CD                   =>   igs_en_su_attempt_rec.location_cd,
               X_UNIT_CLASS                    =>   igs_en_su_attempt_rec.unit_class,
               X_CI_START_DT                   =>   igs_en_su_attempt_rec.ci_start_dt,
               X_CI_END_DT                     =>   igs_en_su_attempt_rec.ci_end_dt,
               X_UOO_ID                        =>   igs_en_su_attempt_rec.uoo_id,
               X_ENROLLED_DT                   =>   igs_en_su_attempt_rec.enrolled_dt,
               X_UNIT_ATTEMPT_STATUS           =>   'ENROLLED',
               X_ADMINISTRATIVE_UNIT_STATUS    =>   NULL,
               X_ADMINISTRATIVE_PRIORITY       =>   igs_en_su_attempt_rec.administrative_PRIORITY,
               X_DISCONTINUED_DT               =>   NULL,
               X_DCNT_REASON_CD                =>   NULL,
               X_RULE_WAIVED_DT                =>   igs_en_su_attempt_rec.rule_waived_dt,
               X_RULE_WAIVED_PERSON_ID         =>   igs_en_su_attempt_rec.rule_waived_person_id,
               X_NO_ASSESSMENT_IND             =>   igs_en_su_attempt_rec.no_assessment_ind,
               X_SUP_UNIT_CD                   =>   igs_en_su_attempt_rec.sup_unit_cd,
               X_SUP_VERSION_NUMBER            =>   igs_en_su_attempt_rec.SUP_VERSION_NUMBER,
               X_EXAM_LOCATION_CD              =>   igs_en_su_attempt_rec.exam_location_cd,
               X_ALTERNATIVE_TITLE             =>   igs_en_su_attempt_rec.alternative_title,
               X_OVERRIDE_ENROLLED_CP          =>   igs_en_su_attempt_rec.OVERRIDE_ENROLLED_CP,
               X_OVERRIDE_EFTSU                =>   igs_en_su_attempt_rec.OVERRIDE_EFTSU,
               X_OVERRIDE_ACHIEVABLE_CP        =>   igs_en_su_attempt_rec.OVERRIDE_ACHIEVABLE_CP,
               X_OVERRIDE_OUTCOME_DUE_DT       =>   igs_en_su_attempt_rec.OVERRIDE_OUTCOME_DUE_DT,
               X_OVERRIDE_CREDIT_REASON        =>   igs_en_su_attempt_rec.OVERRIDE_CREDIT_REASON,
               X_WAITLIST_DT                   =>   igs_en_su_attempt_rec.WAITLIST_DT,
               X_MODE                          =>   'R',
               X_GS_VERSION_NUMBER             =>   igs_en_su_attempt_rec.GS_VERSION_NUMBER,
               X_ENR_METHOD_TYPE               =>   igs_en_su_attempt_rec.ENR_METHOD_TYPE,
               X_FAILED_UNIT_RULE              =>   igs_en_su_attempt_rec.FAILED_UNIT_RULE,
               X_CART                          =>   igs_en_su_attempt_rec.CART,
               X_RSV_SEAT_EXT_ID               =>   igs_en_su_attempt_rec.RSV_SEAT_EXT_ID,
               X_ORG_UNIT_CD                   =>   igs_en_su_attempt_rec.ORG_UNIT_CD,
               X_SESSION_ID                    =>   igs_en_su_attempt_rec.SESSION_ID,
               X_GRADING_SCHEMA_CODE           =>   igs_en_su_attempt_rec.GRADING_SCHEMA_CODE,
               X_DEG_AUD_DETAIL_ID             =>   igs_en_su_attempt_rec.DEG_AUD_DETAIL_ID,
               X_SUBTITLE                      =>   igs_en_su_attempt_rec.subtitle,
               X_STUDENT_CAREER_TRANSCRIPT     =>   igs_en_su_attempt_rec.student_career_transcript,
               X_STUDENT_CAREER_STATISTICS     =>   igs_en_su_attempt_rec.student_career_statistics,
               X_ATTRIBUTE_CATEGORY            =>   igs_en_su_attempt_rec.attribute_category,
               X_ATTRIBUTE1                    =>   igs_en_su_attempt_rec.attribute1,
               X_ATTRIBUTE2                    =>   igs_en_su_attempt_rec.attribute2,
               X_ATTRIBUTE3                    =>   igs_en_su_attempt_rec.attribute3,
               X_ATTRIBUTE4                    =>   igs_en_su_attempt_rec.attribute4,
               X_ATTRIBUTE5                    =>   igs_en_su_attempt_rec.attribute5,
               X_ATTRIBUTE6                    =>   igs_en_su_attempt_rec.attribute6,
               X_ATTRIBUTE7                    =>   igs_en_su_attempt_rec.attribute7,
               X_ATTRIBUTE8                    =>   igs_en_su_attempt_rec.attribute8,
               X_ATTRIBUTE9                    =>   igs_en_su_attempt_rec.attribute9,
               X_ATTRIBUTE10                   =>   igs_en_su_attempt_rec.attribute10,
               X_ATTRIBUTE11                   =>   igs_en_su_attempt_rec.attribute11,
               X_ATTRIBUTE12                   =>   igs_en_su_attempt_rec.attribute12,
               X_ATTRIBUTE13                   =>   igs_en_su_attempt_rec.attribute13,
               X_ATTRIBUTE14                   =>   igs_en_su_attempt_rec.attribute14,
               X_ATTRIBUTE15                   =>   igs_en_su_attempt_rec.attribute15,
               X_ATTRIBUTE16                   =>   igs_en_su_attempt_rec.attribute16,
               X_ATTRIBUTE17                   =>   igs_en_su_attempt_rec.attribute17,
               X_ATTRIBUTE18                   =>   igs_en_su_attempt_rec.attribute18,
               X_ATTRIBUTE19                   =>   igs_en_su_attempt_rec.attribute19,
               X_ATTRIBUTE20                   =>   igs_en_su_attempt_rec.attribute20,
               X_WAITLIST_MANUAL_IND           =>   igs_en_su_attempt_rec.waitlist_manual_ind ,
               X_WLST_PRIORITY_WEIGHT_NUM      =>   igs_en_su_attempt_rec.wlst_priority_weight_num,
               X_WLST_PREFERENCE_WEIGHT_NUM    =>   igs_en_su_attempt_rec.wlst_preference_weight_num,
               X_CORE_INDICATOR_CODE           =>   igs_en_su_attempt_rec.core_indicator_code );

  IF NOT igs_en_enroll_wlst.validate_unit(   p_unit_cd            =>    igs_en_su_attempt_rec.unit_cd,
                                             p_version_number     =>    igs_en_su_attempt_rec.version_number,
                                             p_cal_type           =>    igs_en_su_attempt_rec.cal_type,
                                             p_ci_sequence_number =>    igs_en_su_attempt_rec.ci_sequence_number,
                                             p_location_cd        =>    igs_en_su_attempt_rec.location_cd,
                                             p_person_id          =>    igs_en_su_attempt_rec.person_id,
                                             p_unit_class         =>    igs_en_su_attempt_rec.unit_class,
                                             p_uoo_id             =>    igs_en_su_attempt_rec.uoo_id,
                                             p_message_name       =>    p_message,
                                             p_deny_warn          =>    p_deny_warn,
                                             p_course_cd          =>    igs_en_su_attempt_rec.course_cd ) THEN
    p_return_status := 'FALSE';
    RETURN;
  END IF; --END OF igs_en_enroll_wlst.validate_unit

  IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps(
                                                p_person_id             => p_person_id,
                                                p_person_type           => p_person_type,
                                                p_load_cal_type         => p_load_cal_type,
                                                p_load_sequence_number  => p_load_sequence_number,
                                                p_uoo_id                => p_uoo_id ,
                                                p_course_cd             => p_course_cd,
                                                p_course_version        => p_course_version,
                                                p_enrollment_category   => l_enr_cat,
                                                p_enr_method_type       => l_enr_meth_type,
                                                p_comm_type             => l_enr_comm,
                                                p_message               => p_message,
                                                p_deny_warn             => p_deny_warn,
                                                p_calling_obj           => 'REINSTATE'
                                                ) THEN
    IF p_message IS NOT NULL THEN
        p_return_status := 'FALSE';
        RETURN;
     END IF;
  END IF; -- IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps

    -- Evaluate  program steps

  IF NOT igs_en_elgbl_program.eval_program_steps(
                                                    p_person_id                 => p_person_id,
                                                    p_person_type               => p_person_type,
                                                    p_load_calendar_type        => p_load_cal_type,
                                                    p_load_cal_sequence_number  => p_load_sequence_number,
                                                    p_uoo_id                    => p_uoo_id,
                                                    p_program_cd                => p_course_cd,
                                                    p_program_version           => p_course_version,
                                                    p_enrollment_category       => l_enr_cat,
                                                    p_comm_type                 => l_enr_comm,
                                                    p_method_type               => l_enr_meth_type,
                                                    p_message                   => p_message,
                                                    p_deny_warn                 => p_deny_warn,
                                                    p_calling_obj               => 'REINSTATE') THEN
    IF p_message IS NOT NULL THEN
       p_return_status := 'FALSE';
       RETURN;
    END IF; --end of eval_program_steps

  END IF;
   -- check for Max cp by passing the 0.0 value to credit points
    --since the cp has already been enrolled.
  igs_en_enroll_wlst.ss_eval_min_or_max_cp(    p_person_id               => p_person_id,
                                               p_load_cal_type           => p_load_cal_type,
                                               p_load_ci_sequence_number => p_load_sequence_number,
                                               p_uoo_id                  => p_uoo_id,
                                               p_program_cd              => p_course_cd,
                                               p_step_type               => 'FMAX_CRDT',
                                               p_credit_points           => 0.0,  --deliberately passing  the value zero since the cp has already been enrolled.
                                               p_message_name            => p_message,
                                               p_deny_warn               => p_deny_warn,
                                               p_return_status           => p_return_status,
                                               p_enr_method              => l_enr_meth_type);
    IF p_return_status = 'FALSE' OR p_deny_warn = 'DENY' THEN
       p_return_status := 'FALSE';
    ELSE
       p_return_status := 'TRUE';
    END IF; --end of ss_eval_min_or_max_cp

  RETURN;
 END reinstate_stdnt_unit_attempt;

END IGS_EN_REINSTATE_PKG;

/
