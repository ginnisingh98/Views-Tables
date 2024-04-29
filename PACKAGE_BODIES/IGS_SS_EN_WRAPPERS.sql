--------------------------------------------------------
--  DDL for Package Body IGS_SS_EN_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SS_EN_WRAPPERS" AS
/* $Header: IGSSS09B.pls 120.31 2006/08/24 07:33:57 bdeviset noship $ */
--package variables
pkg_coreq_failed_uooids VARCHAR2(2000);
pkg_prereq_failed_uooids VARCHAR2(2000);
  PROCEDURE validate_prog_pro(
                              p_person_id               igs_en_su_attempt.person_id%TYPE,
                              p_cal_type                igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number      igs_ca_inst.sequence_number%TYPE,
                              p_uoo_id                  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                              p_course_cd               igs_en_su_attempt.course_cd%TYPE,
                              p_enr_method_type         igs_en_su_attempt.enr_method_type%TYPE,
                              p_message_name            OUT NOCOPY VARCHAR2,
                              p_deny_warn               OUT NOCOPY VARCHAR2,
                              p_return_status           OUT NOCOPY VARCHAR2
                             ) AS

    l_message_name VARCHAR2(2000);
    l_deny_warn    VARCHAR2(2000);
  BEGIN NULL;
    IF igs_en_enroll_wlst.validate_prog
    (
      p_person_id => p_person_id,
      p_cal_type => p_cal_type,
      p_ci_sequence_number => p_ci_sequence_number,
      p_uoo_id => p_uoo_id,
      p_course_cd => p_course_cd,
      p_enr_method_type => p_enr_method_type,
      p_message_name => l_message_name,
      p_deny_warn => l_deny_warn
    ) THEN
      p_return_status := 'TRUE';
    ELSE
      p_return_status := 'FALSE';
    END IF;
    p_deny_warn := l_deny_warn;
    p_message_name := l_message_name;
  END validate_prog_pro;

-----------------------------------------------------------------------------------
--Created by  : prgoyal ( Oracle IDC)
--Date created: 08-OCT-2001
--
--Purpose:  This is a wrapper procedure to evaluate the person steps.
-- It is will be called fom SS screens. the enrollment category, method and
-- commencement type would be calcualted and the function to evaluate
-- person step would be called.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------------
PROCEDURE enrp_ss_val_person_step
(
p_person_id                     IN      NUMBER,
p_person_type                   IN      VARCHAR2,
p_load_cal_type                 IN      VARCHAR2,
p_load_ci_sequence_number       IN      NUMBER,
p_program_cd                    IN      VARCHAR2,
p_program_version               IN      NUMBER,
p_message_name                  OUT NOCOPY     VARCHAR2,
p_deny_warn                     OUT NOCOPY     VARCHAR2,
p_step_eval_result              OUT NOCOPY     VARCHAR2,
p_calling_obj                   IN VARCHAR2,
p_create_warning                IN VARCHAR2,
p_ss_session_id                 IN NUMBER
)
AS
/*  HISTORY
  WHO      WHEN          WHAT
 ayedubat 07-JUN-2002   The function call,Igs_En_Gen_015.get_academic_cal is replaced with
                        Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the
                        given load calendar rather than current academic calendar for the bug fix:2381603
*/

l_commencement_type       VARCHAR2(10);
l_enr_method              IGS_EN_METHOD_TYPE.enr_method_type%TYPE;
l_enrollment_category     igs_en_cat_prc_dtl.enrolment_cat%TYPE;
l_step_eval_result        BOOLEAN;
l_message                 VARCHAR2(2000);
l_deny_warn               VARCHAR2(10);
l_enrol_cal_type          igs_ca_type.cal_type%TYPE;
l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
lv_message                fnd_new_messages.message_name%TYPE;
l_acad_start_dt           IGS_CA_INST.start_dt%TYPE;
l_acad_end_dt             IGS_CA_INST.end_dt%TYPE;
l_alternate_code          IGS_CA_INST.alternate_code%TYPE;
l_return_status           VARCHAR2(10);
l_dummy                   VARCHAR2(200);


BEGIN

  igs_en_add_units_api.g_ss_session_id := p_ss_session_id;
   -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
   igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_method,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);

   IF l_return_status='FALSE' THEN
        p_message_name := 'IGS_SS_EN_NOENR_METHOD' ;
        p_step_eval_result := 'FALSE';
        p_deny_warn := 'DENY';
   ELSE

     l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                            p_cal_type                => p_load_cal_type,
                            p_ci_sequence_number      => p_load_ci_sequence_number,
                            p_acad_cal_type           => l_acad_cal_type,
                            p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                            p_acad_ci_start_dt        => l_acad_start_dt,
                            p_acad_ci_end_dt          => l_acad_end_dt,
                            p_message_name            => lv_message );

      IF lv_message IS NOT NULL THEN
        p_message_name := lv_message;
        p_deny_warn := 'DENY';
        p_step_eval_result := 'FALSE';
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
      END IF;

      /* get the enrollment category and commencement type */
      l_enrollment_category := igs_en_gen_003.enrp_get_enr_cat
                                  ( p_person_id => p_person_id,
                                    p_course_cd => p_program_cd,
                                    p_cal_type => l_acad_cal_type,
                                    p_ci_sequence_number => l_acad_ci_sequence_number,
                                    p_session_enrolment_cat =>NULL,
                                    p_enrol_cal_type => l_enrol_cal_type        ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type => l_commencement_type,
                                    p_enr_categories  => l_dummy );

      IF l_commencement_type = 'BOTH' THEN
     /* if both is returned we have to treat it as all */
          l_commencement_type := 'ALL';
      END IF;
      IF   igs_en_elgbl_person.eval_person_steps
                                  (
                                   p_person_id => p_person_id ,
                                   p_person_type => p_person_type,
                                   p_load_calendar_type => p_load_cal_type      ,
                                   p_load_cal_sequence_number => p_load_ci_sequence_number,
                                   p_program_cd => p_program_cd,
                                   p_program_version => p_program_version,
                                   p_enrollment_category => l_enrollment_category,
                                   p_comm_type => l_commencement_type,
                                   p_enrl_method =>  l_enr_method,
                                   p_message => l_message,
                                   p_deny_warn =>  l_deny_warn,
                                   p_calling_obj => p_calling_obj,
                                   p_create_warning => p_create_warning) THEN
   /* the step evaluation has succeded*/
                                   p_message_name := l_message;
                                   p_deny_warn := l_deny_warn;
                                   p_step_eval_result := 'TRUE';
    ELSE
   /* the step evaluation has failed */
                                   p_message_name := l_message;
                                   p_deny_warn := l_deny_warn;
                                   p_step_eval_result := 'FALSE';
    END IF;
  END IF;

  igs_en_add_units_api.g_ss_session_id := NULL;

EXCEPTION
  WHEN OTHERS THEN
    igs_en_add_units_api.g_ss_session_id := NULL;
    RAISE;

END  enrp_ss_val_person_step;


  PROCEDURE validate_unit_steps(
                               p_person_id          IN  igs_en_su_attempt.person_id%TYPE,
                               p_cal_type           IN  igs_ca_inst.cal_type%TYPE,
                               p_ci_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
                               p_uoo_id             IN  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                               p_course_cd          IN  igs_en_su_attempt.course_cd%TYPE,
                               p_return_status      OUT NOCOPY VARCHAR2,
                               p_message_name       OUT NOCOPY VARCHAR2,
                               p_deny_warn          OUT NOCOPY VARCHAR2
                              ) AS
    ------------------------------------------------------------------------------------
    --Created by  : brajendr ( Oracle IDC)
    --Date created: 08-OCT-2001
    --
    --Purpose:
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------
    l_enr_method            IGS_EN_METHOD_TYPE.enr_method_type%TYPE;
    l_message               VARCHAR2(2000);
    l_return_status         VARCHAR2(10);

  BEGIN
    -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
    igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_method,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);
    IF igs_en_enroll_wlst.validate_unit_steps ( p_person_id,
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                p_uoo_id,
                                                p_course_cd,
                                                l_enr_method,
                                                p_message_name,
                                                p_deny_warn,
                                                'JOB') THEN


      p_return_status := 'TRUE';
    ELSE
      p_return_status := 'FALSE';
    END IF;
  END validate_unit_steps;

  PROCEDURE get_person_type_by_rank(
                                    p_person_id         IN  NUMBER,
                                    p_person_type       OUT NOCOPY VARCHAR2
                                   ) AS
    ------------------------------------------------------------------------------------
    --Created by  : brajendr ( Oracle IDC)
    --Date created: 30-OCT-2001
    --
    --Purpose:
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -- kamohan    01-NOV-2001    Modified to get the person_type for the admin person
    --                           type only
    -------------------------------------------------------------------------------------
    CURSOR cur_get_person_type_by_rank( p_person_id NUMBER) IS
      SELECT person_type_code
        FROM igs_pe_person_types
        WHERE  rank = ( SELECT MIN(rank)
                          FROM igs_pe_person_types
                         WHERE person_type_code IN ( SELECT person_type_code
                                                       FROM igs_pe_typ_instances_all
                                                      WHERE person_id = p_person_id
                                                    )
                           AND system_type = 'SS_ENROLL_STAFF'
                           AND closed_ind = 'N'
                       );
  BEGIN
    p_person_type := NULL;
    OPEN cur_get_person_type_by_rank(p_person_id);
      FETCH cur_get_person_type_by_rank INTO p_person_type;
    CLOSE cur_get_person_type_by_rank;
  EXCEPTION
        WHEN OTHERS THEN
         p_person_type := NULL;
  END get_person_type_by_rank;

  PROCEDURE call_fee_ass (
                p_person_id             IN NUMBER,
                p_cal_type              IN VARCHAR2,
                p_sequence_number       IN NUMBER,
                p_course_cd             IN VARCHAR2,
                p_unit_cd               IN VARCHAR2,
                p_uoo_id                IN igs_en_su_attempt.uoo_id%TYPE
                ) IS

  l_row_id VARCHAR2(25);
  l_return_val NUMBER;
  CURSOR c1 IS
        SELECT
                igs_pe_std_todo_ref_rf_num_s.NEXTVAL
        FROM
                dual;
  l_reference_number NUMBER;
  CURSOR c2 ( c_return_val NUMBER) IS
        SELECT
                person_id
        FROM
                igs_pe_std_todo_ref
        WHERE
                person_id = p_person_id AND
                s_student_todo_type = 'FEE_RECALC' AND
                sequence_number = c_return_val AND
                cal_type = p_cal_type AND
                ci_sequence_number = p_sequence_number AND
                logical_delete_dt IS NULL; -- This condition is newly added by Nishikant - 20JUN2002 - bug#2420442.
  c2_rec NUMBER;
  BEGIN
        l_return_val := IGS_GE_GEN_003.genp_ins_stdnt_todo( p_person_id, 'FEE_RECALC', SYSDATE, 'Y');
        OPEN c2( l_return_val);
        FETCH c2 INTO c2_rec;
        IF c2%NOTFOUND THEN
                OPEN c1;
                FETCH c1 INTO l_reference_number;
                igs_pe_std_todo_ref_pkg.insert_row (
                        X_ROWID         => l_row_id,
                        X_PERSON_ID     => p_person_id,
                        X_S_STUDENT_TODO_TYPE => 'FEE_RECALC',
                        X_SEQUENCE_NUMBER => l_return_val,
                        X_REFERENCE_NUMBER => l_reference_number,
                        X_CAL_TYPE      => p_cal_type,
                        X_CI_SEQUENCE_NUMBER => p_sequence_number,
                        X_COURSE_CD     => p_course_cd,
                        X_UNIT_CD       => p_unit_cd,
                        X_OTHER_REFERENCE       => NULL,
                        X_LOGICAL_DELETE_DT => NULL,
                        X_MODE => 'R',
                        X_UOO_ID => p_uoo_id
                        );
        END IF;
        CLOSE c2;
  END call_fee_ass;


  PROCEDURE enroll_cart_unit(
                            p_person_id                 IN NUMBER,
                            p_uoo_id                    IN NUMBER,
                            p_unit_cd                   IN VARCHAR2,
                            p_version_number            IN NUMBER,
                            p_course_cd                 IN VARCHAR2,
                            p_unit_attempt_status       IN VARCHAR2,
                            p_enrolled_dt               IN DATE
                            ) AS
    ------------------------------------------------------------------------------------
    --Created by  : kamohan ( Oracle IDC)
    --Date created: 10-NOV-2001
    --
    --Purpose:
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --stutta      11-FEB-2004     Added new parameter p_enrolled_dt. Replace the code to
    --                            populate enrolled date with SYSDATE always to consider the
    --                            value passed in.
    --mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in TBH call of IGS_EN_SU_ATTEMPT
    --                            for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
    -- kamohan    10-NOV-2001    Added this procedure for the Enrollment Worksheet
    --
    -------------------------------------------------------------------------------------
    CURSOR cart_cur IS
    SELECT sua.*
     FROM
        igs_en_su_attempt   sua
     WHERE
        person_id = p_person_id AND
        course_cd = p_course_cd AND
        unit_cd = p_unit_cd AND
        version_number = p_version_number AND
        uoo_id = p_uoo_id;
    cart_rec cart_cur%ROWTYPE;
    l_enrolled_dt DATE;
BEGIN
        OPEN cart_cur;
        FETCH cart_cur INTO cart_rec;
        CLOSE cart_cur;
        IF p_unit_attempt_status = 'ENROLLED' THEN
                l_enrolled_dt := NVL(p_enrolled_dt,SYSDATE);
        ELSE
                l_enrolled_dt := cart_rec.enrolled_dt;
        END IF;
        igs_en_sua_api.update_unit_attempt(
                                    X_ROWID                         => cart_rec.ROW_ID,
                                    X_PERSON_ID                     => cart_rec.PERSON_ID,
                                    X_COURSE_CD                     => cart_rec.COURSE_CD,
                                    X_UNIT_CD                       => cart_rec.UNIT_CD,
                                    X_CAL_TYPE                      => cart_rec.CAL_TYPE,
                                    X_CI_SEQUENCE_NUMBER            => cart_rec.CI_SEQUENCE_NUMBER,
                                    X_VERSION_NUMBER                => cart_rec.VERSION_NUMBER,
                                    X_LOCATION_CD                   => cart_rec.LOCATION_CD,
                                    X_UNIT_CLASS                    => cart_rec.UNIT_CLASS,
                                    X_CI_START_DT                   => cart_rec.CI_START_DT,
                                    X_CI_END_DT                     => cart_rec.CI_END_DT,
                                    X_UOO_ID                        => cart_rec.UOO_ID,
                                    X_ENROLLED_DT                   => l_enrolled_dt,
                                    X_UNIT_ATTEMPT_STATUS           => p_unit_attempt_status,
                                    X_ADMINISTRATIVE_UNIT_STATUS    => cart_rec.ADMINISTRATIVE_UNIT_STATUS,
                                    X_DISCONTINUED_DT               => cart_rec.DISCONTINUED_DT,
                                    X_RULE_WAIVED_DT                => cart_rec.RULE_WAIVED_DT,
                                    X_RULE_WAIVED_PERSON_ID         => cart_rec.RULE_WAIVED_PERSON_ID,
                                    X_NO_ASSESSMENT_IND             => cart_rec.NO_ASSESSMENT_IND,
                                    X_SUP_UNIT_CD                   => cart_rec.SUP_UNIT_CD,
                                    X_SUP_VERSION_NUMBER            => cart_rec.SUP_VERSION_NUMBER,
                                    X_EXAM_LOCATION_CD              => cart_rec.EXAM_LOCATION_CD,
                                    X_ALTERNATIVE_TITLE             => cart_rec.ALTERNATIVE_TITLE,
                                    X_OVERRIDE_ENROLLED_CP          => cart_rec.OVERRIDE_ENROLLED_CP,
                                    X_OVERRIDE_EFTSU                => cart_rec.OVERRIDE_EFTSU,
                                    X_OVERRIDE_ACHIEVABLE_CP        => cart_rec.OVERRIDE_ACHIEVABLE_CP,
                                    X_OVERRIDE_OUTCOME_DUE_DT       => cart_rec.OVERRIDE_OUTCOME_DUE_DT,
                                    X_OVERRIDE_CREDIT_REASON        => cart_rec.OVERRIDE_CREDIT_REASON,
                                    X_ADMINISTRATIVE_PRIORITY       => cart_rec.ADMINISTRATIVE_PRIORITY,
                                    X_WAITLIST_DT                   => cart_rec.WAITLIST_DT,
                                    X_DCNT_REASON_CD                => cart_rec.DCNT_REASON_CD,
                                    X_MODE                          => 'R',
                                    X_GS_VERSION_NUMBER             => cart_rec.GS_VERSION_NUMBER,
                                    X_ENR_METHOD_TYPE               => cart_rec.ENR_METHOD_TYPE,
                                    X_FAILED_UNIT_RULE              => cart_rec.FAILED_UNIT_RULE,
                                    X_CART                          => 'N',
                                    X_RSV_SEAT_EXT_ID               => cart_rec.RSV_SEAT_EXT_ID,
                                    X_ORG_UNIT_CD                   => cart_rec.ORG_UNIT_CD,
                                    X_GRADING_SCHEMA_CODE           => cart_rec.GRADING_SCHEMA_CODE,
                                    X_SUBTITLE                      => cart_rec.SUBTITLE,
                                    X_SESSION_ID                    => cart_rec.SESSION_ID,
                                    X_DEG_AUD_DETAIL_ID             => cart_rec.DEG_AUD_DETAIL_ID,
                                    X_STUDENT_CAREER_TRANSCRIPT     => cart_rec.STUDENT_CAREER_TRANSCRIPT,
                                    X_STUDENT_CAREER_STATISTICS     => cart_rec.STUDENT_CAREER_STATISTICS,
                                    X_ATTRIBUTE_CATEGORY            => cart_rec.ATTRIBUTE_CATEGORY,
                                    X_ATTRIBUTE1                    => cart_rec.ATTRIBUTE1,
                                    X_ATTRIBUTE2                    => cart_rec.ATTRIBUTE2,
                                    X_ATTRIBUTE3                    => cart_rec.ATTRIBUTE3,
                                    X_ATTRIBUTE4                    => cart_rec.ATTRIBUTE4,
                                    X_ATTRIBUTE5                    => cart_rec.ATTRIBUTE5,
                                    X_ATTRIBUTE6                    => cart_rec.ATTRIBUTE6,
                                    X_ATTRIBUTE7                    => cart_rec.ATTRIBUTE7,
                                    X_ATTRIBUTE8                    => cart_rec.ATTRIBUTE8,
                                    X_ATTRIBUTE9                    => cart_rec.ATTRIBUTE9,
                                    X_ATTRIBUTE10                   => cart_rec.ATTRIBUTE10,
                                    X_ATTRIBUTE11                   => cart_rec.ATTRIBUTE11,
                                    X_ATTRIBUTE12                   => cart_rec.ATTRIBUTE12,
                                    X_ATTRIBUTE13                   => cart_rec.ATTRIBUTE13,
                                    X_ATTRIBUTE14                   => cart_rec.ATTRIBUTE14,
                                    X_ATTRIBUTE15                   => cart_rec.ATTRIBUTE15,
                                    X_ATTRIBUTE16                   => cart_rec.ATTRIBUTE16,
                                    X_ATTRIBUTE17                   => cart_rec.ATTRIBUTE17,
                                    X_ATTRIBUTE18                   => cart_rec.ATTRIBUTE18,
                                    X_ATTRIBUTE19                   => cart_rec.ATTRIBUTE19,
                                    X_ATTRIBUTE20                   => cart_rec.ATTRIBUTE20,
                                    X_WAITLIST_MANUAL_IND           => cart_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                    X_WLST_PRIORITY_WEIGHT_NUM      => cart_rec.wlst_priority_weight_num,
                                    X_WLST_PREFERENCE_WEIGHT_NUM    => cart_rec.wlst_preference_weight_num,
                                    X_CORE_INDICATOR_CODE           => cart_rec.core_indicator_code
        );
END enroll_cart_unit;
PROCEDURE Validate_enroll_validate (
p_person_id               IN igs_en_su_attempt.person_id%TYPE,
p_load_cal_type           IN igs_ca_inst.cal_type%TYPE,
p_load_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
p_uoo_ids                 IN VARCHAR2,
p_program_cd              IN igs_en_su_attempt.course_cd%TYPE,
p_message_name            OUT NOCOPY VARCHAR2,
p_deny_warn               OUT NOCOPY VARCHAR2,
p_return_status           OUT NOCOPY VARCHAR2,
p_enr_method              IN  igs_en_cat_prc_dtl.enr_method_type%TYPE,
p_enrolled_dt             IN  DATE) AS
  ------------------------------------------------------------------------------------
    --Created by  : amuthu
    --Date created: 28-May-2002
    --
    --Purpose:
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --amuthu      28-Mar-2003     The return_type out parameter from ENRP_VAL_ENR_ENCMB
    --                            was returned with a value only for required units
    --                            validation and this was being used in setting the
    --                            return_status and hence only if the return type was 'E'
    --                            the status was set to Deny. now modified the code to
    --                            checking the return value and messages to set the return status
    --amuthu      03-Jun-2002     The Program step validations were returning status as
    --                            FALSE even when a Warning was to be shown.
    --                            Hence 'RETURN' is being done only when the status
    --                            FALSE and the messages type is DENY
    --                            At the end if the messages is not null then type is
    --                            being set as WARN
    --svanukur    04-dec-2003     Passing the load calendar details to the procedure
    --                            IGS_EN_VAL_ENCMB.enrp_val_enr_encmb as part of holds bug 3227399
    --stutta      11-Feb-2004     Added new parameter p_enrolled_dt, passing the same to
    --                            enrol_cart_unit
    -------------------------------------------------------------------------------------

    l_drop_uoo_ids  VARCHAR2(255);
    l_uoo_id        igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_unit_cd       igs_ps_unit_ver.unit_cd%TYPE;
    l_unit_version  igs_ps_unit_ver.version_number%TYPE;
    lv_message_name VARCHAR2(2000);
    lv_message_name2  VARCHAR2(2000);
    lv_return_type  VARCHAR2(2);
    l_enr_method    IGS_EN_METHOD_TYPE.enr_method_type%TYPE;
    l_message                 VARCHAR2(2000);
    l_return_status           VARCHAR2(10);

        CURSOR c_uv (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
          SELECT unit_cd, version_number
          FROM   igs_ps_unit_ofr_opt
          WHERE  uoo_id = cp_uoo_id;



  BEGIN
/********************************************************************************************
  what are we trying to do in this procedure.
        1. Loop thru all uoo_id's and Check for the Max CP ,if it suceeds then enroll the unit section
        2. For a second time loop thru all uoo_id's and check for Min CP.
        3. For a third time loop thru all uoo_id's and validate the other program
           steps other than Min and Max cp. And if it succeeds then call the call_fee_ass (SFCR019)

        Why are we doing it like this?
        The validation written for Max CP first calculates the  CP for all the Enrolled
        units under the context program. Then added the CP of the current unit section
        being enrolled and checks if the maximum has been reached. hence we check for the
        Max CP first and then enroll the unit.

        Why are we checking for Min CP seperately, this needs to be done because all the units
        have already been enrolled, so if we pass the Credit point value as either null and dont
        pass the parameter ifself internally the procedure calculates the CP, hence we have
        to explicitly call the eval_min_cp with zero credit points as parameter.

        Now after all this has been done we need to call the validate_program_step to
        evaluate the other program steps
        And also validates the holds, if the person have to enroll some required units, etc
********************************************************************************************/


    IF p_enr_method IS NULL THEN
            -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
            igs_en_gen_017.enrp_get_enr_method(
               p_enr_method_type => l_enr_method,
               p_error_message   => l_message,
               p_ret_status      => l_return_status);
            IF l_return_status = 'FALSE' THEN
                p_message_name := 'IGS_SS_EN_NOENR_METHOD' ;
                p_return_status := 'FALSE';
                p_deny_warn := 'DENY';
            END IF;
    ELSE
       l_enr_method := p_enr_method;
    END IF;

    l_drop_uoo_ids := p_uoo_ids;

    WHILE l_drop_uoo_ids IS NOT NULL LOOP

      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_uoo_id := TO_NUMBER(l_drop_uoo_ids);
      ELSE
        l_uoo_id := TO_NUMBER(substr(l_drop_uoo_ids,0,instr(l_drop_uoo_ids,',',1)-1)) ;
      END IF;


          -- check for Max cp by passing the null value to credit points
          --so that the default calculation are done for the CP of this unit section
      igs_en_enroll_wlst.ss_eval_min_or_max_cp(p_person_id               => p_person_id,
                                               p_load_cal_type           => p_load_cal_type,
                                               p_load_ci_sequence_number => p_load_ci_sequence_number,
                                               p_uoo_id                  => l_uoo_id,
                                               p_program_cd              => p_program_cd,
                                               p_step_type               => 'FMAX_CRDT',
                                               p_credit_points           => NULL, -- deliberately passing null, this value will be internally calculated
                                               p_message_name            => lv_message_name,
                                               p_deny_warn               => p_deny_warn,
                                               p_return_status           => p_return_status,
                                               p_enr_method              => l_enr_method);

      IF lv_message_name IS NOT NULL AND instr(NVL(p_message_name,' '),lv_message_name) = 0 THEN
            IF p_message_name IS NOT NULL THEN
                  p_message_name := p_message_name || ';' ||lv_message_name;
                ELSE
                  p_message_name := lv_message_name;
                END IF;
          END IF;

          IF p_return_status = 'FALSE' AND p_deny_warn = 'DENY' THEN
            RETURN;
          END IF;

          OPEN c_uv(l_uoo_id);
          FETCH c_uv INTO l_unit_cd, l_unit_version;
          CLOSE c_uv;

          -- call the procedure to enroll the unconfirmed or invalid unit
          IGS_SS_EN_WRAPPERS.enroll_cart_unit (
                       P_PERSON_ID                      => p_person_id ,
                       P_COURSE_CD                      => p_program_cd ,
                       P_UNIT_CD                        => l_unit_Cd,
                       P_VERSION_NUMBER         => l_unit_version,
                       P_UOO_ID                     => l_uoo_id,
                       P_UNIT_ATTEMPT_STATUS => 'ENROLLED',
                       P_ENROLLED_DT         => NVL(p_enrolled_dt,SYSDATE));

      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_drop_uoo_ids := NULL;
      ELSE
        l_drop_uoo_ids := substr(l_drop_uoo_ids,instr(l_drop_uoo_ids,',',1)+1);
      END IF;

    END LOOP;


    l_drop_uoo_ids := p_uoo_ids;

    WHILE l_drop_uoo_ids IS NOT NULL LOOP
  l_uoo_id := null;
      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_uoo_id := TO_NUMBER(l_drop_uoo_ids);
      ELSE
        l_uoo_id := TO_NUMBER(substr(l_drop_uoo_ids,0,instr(l_drop_uoo_ids,',',1)-1)) ;
      END IF;

          lv_message_name := null;

      -- call the procedure to evaluate the Min CP by passing ZERO to the
          -- credit points parameter
      igs_en_enroll_wlst.ss_eval_min_or_max_cp(p_person_id               => p_person_id,
                                               p_load_cal_type           => p_load_cal_type,
                                               p_load_ci_sequence_number => p_load_ci_sequence_number,
                                               p_uoo_id                  => l_uoo_id,
                                               p_program_cd              => p_program_cd,
                                               p_step_type               => 'FMIN_CRDT',
                                               p_credit_points           => 0.0, -- deliberately passing the value zero since the cp has already been enrolled
                                               p_message_name            => lv_message_name,
                                               p_deny_warn               => p_deny_warn,
                                               p_return_status           => p_return_status,
                                               p_enr_method              => l_enr_method);

      IF lv_message_name IS NOT NULL AND instr(NVL(p_message_name,' '),lv_message_name) = 0 THEN
            IF p_message_name IS NOT NULL THEN
                  p_message_name := p_message_name || ';' ||lv_message_name;
                ELSE
                  p_message_name := lv_message_name;
                END IF;
          END IF;


          IF p_return_status = 'FALSE' AND p_deny_warn = 'DENY' THEN
            RETURN;
          END IF;


      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_drop_uoo_ids := NULL;
      ELSE
        l_drop_uoo_ids := substr(l_drop_uoo_ids,instr(l_drop_uoo_ids,',',1)+1);
      END IF;

    END LOOP;

    -- Added the following code as part of the bug 2385096, pmarada
    -- Validating the holds
       l_drop_uoo_ids := p_uoo_ids;
       WHILE l_drop_uoo_ids IS NOT NULL LOOP
         IF(INSTR(l_drop_uoo_ids,',',1) = 0) THEN
           l_uoo_id := TO_NUMBER(l_drop_uoo_ids);
         ELSE
           l_uoo_id := TO_NUMBER(SUBSTR(l_drop_uoo_ids,0,INSTR(l_drop_uoo_ids,',',1)-1)) ;
         END IF;
           lv_message_name := NULL;
           lv_message_name2 :=NULL;


            IF IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id,
                                         p_program_cd ,
                                         p_load_cal_type,
                                         p_load_ci_sequence_number,
                                         lv_message_name,
                                         lv_message_name2,
                                         lv_return_type,
                                         NULL -- default value, it will be calculated internally based on the census date
                                         )  THEN
                p_return_status := 'TRUE';
             ELSE
                p_return_status := 'FALSE';
             END IF;

             IF lv_message_name IS NOT NULL AND INSTR(NVL(p_message_name,' '),lv_message_name) = 0 THEN
               IF p_message_name IS NOT NULL THEN
                 p_message_name := p_message_name || ';' || lv_message_name;
               ELSE
                 p_message_name := lv_message_name;
               END IF;
             END IF;
             IF lv_message_name2 IS NOT NULL AND INSTR(NVL(p_message_name,' '),lv_message_name2) = 0 THEN
               IF p_message_name IS NOT NULL THEN
                 p_message_name := p_message_name || ';' || lv_message_name2;
               ELSE
                 p_message_name := lv_message_name2;
               END IF;
             END IF;

           IF p_return_status = 'FALSE' AND (lv_message_name IS NOT NULL OR lv_message_name2 IS NOT NULL )  THEN
              p_deny_warn := 'DENY';
              RETURN;
           END IF;

           IF(INSTR(l_drop_uoo_ids,',',1) = 0) THEN
              l_drop_uoo_ids := NULL;
           ELSE
              l_drop_uoo_ids := SUBSTR(l_drop_uoo_ids,INSTR(l_drop_uoo_ids,',',1)+1);
           END IF;
       END LOOP ;
      -- End of the code added by pmarada, bug 2385096.

    l_drop_uoo_ids := p_uoo_ids;
    WHILE l_drop_uoo_ids IS NOT NULL LOOP

      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_uoo_id := TO_NUMBER(l_drop_uoo_ids);
      ELSE
        l_uoo_id := TO_NUMBER(substr(l_drop_uoo_ids,0,instr(l_drop_uoo_ids,',',1)-1)) ;
      END IF;

          lv_message_name := null;

          -- call the procedure to evaluate all program steps except Min and Max CP
      IF igs_en_enroll_wlst.validate_prog (
              p_person_id          => p_person_id,
              p_cal_type           => p_load_cal_type,
              p_ci_sequence_number => p_load_ci_sequence_number,
              p_uoo_id             => l_uoo_id,
              p_course_cd          => p_program_cd,
              p_enr_method_type    => l_enr_method,
              p_message_name       => lv_message_name,
              p_deny_warn          => p_deny_warn
            ) THEN
            p_return_status := 'TRUE';
      ELSE
            p_return_status := 'FALSE';
          END IF;

      IF lv_message_name IS NOT NULL AND instr(NVL(p_message_name,' '),lv_message_name) = 0 THEN
            IF p_message_name IS NOT NULL THEN
                  p_message_name := p_message_name || ';' ||lv_message_name;
                ELSE
                  p_message_name := lv_message_name;
                END IF;
          END IF;


          IF p_return_status = 'FALSE' AND p_deny_warn = 'DENY' THEN
            RETURN;
          END IF;

          OPEN c_uv(l_uoo_id);
          FETCH c_uv INTO l_unit_cd, l_unit_version;
          CLOSE c_uv;

          -- call the procedure to insert a student todo record for fee recalculation (SFCR019)
      IGS_SS_EN_WRAPPERS.call_fee_ass (
                 p_person_id       => p_person_id,
                 p_cal_type        => p_load_cal_type,
                 p_sequence_number => p_load_ci_sequence_number,
                 p_course_cd       => p_program_cd,
                 p_unit_cd         => l_unit_Cd,
                 p_uoo_id          => l_uoo_id);

      IF(instr(l_drop_uoo_ids,',',1) = 0) THEN
        l_drop_uoo_ids := NULL;
      ELSE
        l_drop_uoo_ids := substr(l_drop_uoo_ids,instr(l_drop_uoo_ids,',',1)+1);
      END IF;

    END LOOP;

        -- if the code has reached this point then ther either warnings only  or  everything went through
    IF p_message_name IS NULL THEN
      p_deny_warn := NULL;
        ELSE
          p_deny_warn := 'WARN';
        END IF;

    p_return_status := 'TRUE';

    RETURN ;

  END Validate_enroll_validate;

PROCEDURE get_cart_details
(       p_person_id       IN NUMBER,
        p_program_cd       IN VARCHAR2,
        p_load_cal_type   IN VARCHAR2,
        p_load_ci_seq_num IN NUMBER,
                p_total_units_cart OUT NOCOPY NUMBER,
                p_total_cp_cart OUT NOCOPY NUMBER
) AS
 /*------------------------------------------------------------------------------------
  --Created by  : Kamal ( Oracle IDC)
  --Date created: 13-Jan-2003
  --
  -- Purpose: To get the total number of units in Cart and the total CP of the units in
  --          cart, for the given student in a Term.
  --          The criteria is inline with the VO 'EnrWrkshtVO.xml', which is used in
  --          Enrollment Cart Page
  --
  --Change History:
  --Who           When            What
  --sarakshi     27-Jun-2003    Enh#2930935,modified the cursor cur_cart_credit_pts such that it pick up
  --                            usec level enroled crdit points if exist else unit level
  --myoganat      16-Jun-2003   Removed the reference to the profile IGS_EN_INCL_AUDIT_CP
  --                            in Cursor CUR_CART_CREDIT_PTS as part of Bug  #2855870 (ENCR032 Build)
  -- rvangala     11-Dec-2003   Bug #3112107, replaced IN clause in queries of cursors cur_units_cart
  --                            and cur_cart_credit_pts with direct join
  -------------------------------------------------------------------------------------*/
   CURSOR cur_units_cart(cp_person_id NUMBER,cp_course_cd VARCHAR2,cp_load_cal_type VARCHAR2,cp_load_ci_seq_num NUMBER ) IS
   SELECT count(*) UNITS_IN_CART
   FROM
       IGS_EN_SU_ATTEMPT SUA,
       IGS_EN_USEC_STAT_DSP_V ENUSECSTAT,
       IGS_PS_UNIT_OFR_OPT UOO
   WHERE sua.person_id                  = cp_person_id
   AND   sua.course_cd                  = cp_course_cd
   AND   sua.uoo_id                     = uoo.uoo_id
   AND   enusecstat.unit_section_status =  uoo.unit_section_status
   AND   enusecstat.displayed           = 'Y'
   AND   sua.unit_attempt_status IN ( 'UNCONFIRM','INVALID'  )
   AND   0< (SELECT 1 FROM igs_ca_load_to_teach_v vt
             WHERE vt.load_cal_type          =cp_load_cal_type
             AND   vt.load_ci_sequence_number=cp_load_ci_seq_num
             AND   sua.cal_type              = vt.teach_cal_type
             AND   sua.ci_sequence_number    = vt.teach_ci_sequence_number)   ;

   -- get the total credit points in the cart
   CURSOR cur_cart_credit_pts(cp_person_id NUMBER,cp_course_cd VARCHAR2,cp_load_cal_type VARCHAR2,cp_load_ci_seq_num NUMBER ) IS
    SELECT SUM(NVL(sua.override_enrolled_cp,NVL(cps.enrolled_credit_points,
                  uv.enrolled_credit_points))) total_credit_points
    FROM    igs_en_su_attempt     sua,
                igs_en_usec_stat_dsp_v enusecstat,
                igs_ps_unit_ofr_opt uoo,
                igs_ps_usec_cps  cps,
                igs_ps_unit_ver uv
    WHERE   sua.person_id = cp_person_id AND
                 sua.course_cd = cp_course_cd AND
                 sua.uoo_id = uoo.uoo_id AND
                uoo.uoo_id = cps.uoo_id(+)  AND
                enusecstat.unit_section_status = uoo.unit_section_status AND
                enusecstat.displayed = 'Y' AND
                sua.unit_attempt_status IN ('UNCONFIRM','INVALID') AND
                sua.no_assessment_ind = 'N' AND
               0< (SELECT 1 FROM igs_ca_load_to_teach_v vt
                   WHERE vt.load_cal_type=cp_load_cal_type
                   AND vt.load_ci_sequence_number=cp_load_ci_seq_num
                   AND sua.cal_type=vt.teach_cal_type
                   AND sua.ci_sequence_number=vt.teach_ci_sequence_number)
                   AND uv.unit_cd= sua.unit_cd
                   AND uv.version_number = sua.version_number;


  BEGIN
   -- initialize the values to zero
   p_total_units_cart := 0;
   p_total_cp_cart := 0;
   -- fetch the units in cart and the total credit points of the units in cart
   OPEN cur_units_cart(p_person_id,p_program_cd,p_load_cal_type,p_load_ci_seq_num);
   FETCH cur_units_cart INTO p_total_units_cart;
   CLOSE cur_units_cart;
   -- fetch the units in cart and the total credit points of the units in cart
   OPEN cur_cart_credit_pts(p_person_id,p_program_cd,p_load_cal_type,p_load_ci_seq_num);
   FETCH cur_cart_credit_pts INTO p_total_cp_cart;
   CLOSE cur_cart_credit_pts;

  END get_cart_details;

PROCEDURE insert_into_enr_worksheet(
p_person_number         IN VARCHAR2,
p_course_cd             IN VARCHAR2,
p_uoo_id                IN NUMBER,
p_waitlist_ind          IN VARCHAR2,
p_session_id            IN NUMBER,
p_return_status         OUT NOCOPY VARCHAR2,
p_message               OUT NOCOPY VARCHAR2,
p_cal_type              IN VARCHAR2,
p_ci_sequence_number    IN NUMBER,
p_audit_requested       IN VARCHAR2,
p_enr_method            IN igs_en_cat_prc_dtl.enr_method_type%TYPE,
p_override_cp           IN NUMBER,
p_subtitle              IN VARCHAR2,
p_gradsch_cd            IN VARCHAR2,
p_gs_version_num        IN NUMBER,
p_core_indicator_code   IN VARCHAR2,
p_calling_obj           IN VARCHAR2) AS



l_enr_method_type       igs_en_method_type.enr_method_type%TYPE;
l_deny_warn             VARCHAR2(10);
l_message               VARCHAR2(2000);
l_return_status         BOOLEAN;


BEGIN


     IF p_enr_method IS NULL THEN
             -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
             igs_en_gen_017.enrp_get_enr_method(
               p_enr_method_type => l_enr_method_type,
               p_error_message   => p_message,
               p_ret_status      => p_return_status);
             IF p_return_status = 'FALSE' THEN
                        p_message := 'IGS_SS_EN_NOENR_METHOD';
                        fnd_message.set_name('IGS','IGS_SS_EN_NOENR_METHOD');
                        fnd_msg_pub.add;
                        p_return_status :=  fnd_api.g_ret_sts_error;
             END IF;
      ELSE
           l_enr_method_type:= p_enr_method;
      END IF;


        l_return_status := igs_en_ofr_wlst_opt.ofr_enrollment_or_waitlist (
                                               p_uoo_id => p_uoo_id,
                                               p_waitlist_ind  => p_waitlist_ind,
                                               p_person_number => p_person_number,
                                               p_course_cd => p_course_cd,
                                               p_enr_method_type => l_enr_method_type,
                                               p_session_id => p_session_id,
                                               p_deny_or_warn => l_deny_warn,
                                               p_message  => p_message,
                                               p_cal_type => p_cal_type,  -- load calendar
                                               p_ci_sequence_number => p_ci_sequence_number,  -- load calendar
                                               p_audit_requested => p_audit_requested,
                                               p_override_cp =>p_override_cp    ,
                                               p_subtitle =>p_subtitle  ,
                                               p_gradsch_cd =>p_gradsch_cd      ,
                                               p_gs_version_num=>p_gs_version_num ,
                                               p_core_indicator_code=>p_core_indicator_code ,
                                               p_calling_obj => p_calling_obj
                                               ); -- ptandon, Prevent Dropping Core Units build


        IF l_return_status and l_deny_warn is null THEN
          p_return_status := 'S';
    ELSE
      IF l_deny_warn = 'WARN' THEN
            p_return_status := 'W';
      ELSE
            p_return_status := 'D';
      END IF;
    END IF;
END insert_into_enr_worksheet;

PROCEDURE  drop_selected_units (
  p_uoo_ids IN VARCHAR2,
  p_person_id IN NUMBER,
  p_person_type IN VARCHAR2,
  p_load_cal_type IN VARCHAR2,
  p_load_sequence_number IN NUMBER,
  p_program_cd IN VARCHAR2,
  p_program_version IN NUMBER ,
  p_dcnt_reason_cd IN VARCHAR2 ,
  p_admin_unit_status IN VARCHAR2 ,
  p_effective_date IN DATE ,
  p_failed_uoo_ids OUT NOCOPY VARCHAR2,
  p_failed_unit_cds OUT NOCOPY VARCHAR2,
  p_return_status OUT NOCOPY VARCHAR2,
  p_message OUT NOCOPY VARCHAR2,
  p_ovrrd_min_cp_chk IN VARCHAR2 ,
  p_ovrrd_crq_chk    IN VARCHAR2 , --msrinivi , added new param 2-may-2002
  p_ovrrd_prq_chk    IN VARCHAR2 , --msrinivi  added new param 2-may-2002
  p_ovrrd_att_typ_chk   IN VARCHAR2
) AS
/* History
  WHO          WHEN          WHAT
  smanglm     03-02-2003     call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  svenkata    28-Jan-03      Modified the manner in which the string of unit codes that failed the co-req / pre-req valdns are created.
  svenkata    7-Jan-03        Incorporated the logic for 'When first Reach Attendance Type'. The routine enrp_val_coo_att is being called to get the
                              Att Typ before updating the CP.The  routine eval_unit_forced_type is then called called to evaluate with the fetched value-Bug#2737263
  svenkata    20-Dec-02     Added a new parameter p_ovrrd_att_type for attendance Type validation. Incorporated Att Type
                            validation when dropping a Unit section.Bug# 2686793
  Nishikant  01-NOV-2002     SEVIS Build Bug#2641905. parameters p_person_id and p_message added in the calls
                             get_notification.
  svenkata      21-oct-02   Bug 2616692 - The call to the fucntion eval_min_cp has been modified to add
                            4 new parameters .
  ayedubat    3-JUL-2002    1.Changed the dynamic sql creation of the cursor,c_ref_cur_inst to conside the 'WAITLISTED' unit attempt status
                            2.Added a validation to check the existence of records in the table,lData before
                              looping through the records while doing the prereq validations for the bug fix:2443876
  svanukur    04-dec-2003     Passing the load calendar details to the procedure
                              IGS_EN_VAL_ENCMB.enrp_val_enr_encmb as part of holds bug 3227399
  ptandon     16-Feb-2004     Added Exception handling section and handled the exception NO_AUSL_RECORD_FOUND to
                              return a meaningful error message. Bug# 3418087.
  stutta      16-Nov-2004    Validate coreq/prereq rules for all sua before drop operation so as to suppress the rules
                             which failed even before the drop. Bug # 3926541
*/


l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
l_deny_warn_min_cp VARCHAR2(10) := NULL ;
l_deny_warn_coreq  VARCHAR2(10) := NULL ;
l_deny_warn_prereq  VARCHAR2(10) := NULL ;
l_deny_warn_att_type VARCHAR2(100) := NULL ;

l_message VARCHAR2(2000);
l_min_cp_message VARCHAR2(2000);
l_att_type_message VARCHAR2(2000) := NULL ;

l_min_cp_failed BOOLEAN := FALSE;
l_att_typ_failed BOOLEAN := FALSE;
l_coreq_failed BOOLEAN := FALSE;
l_prereq_failed BOOLEAN := FALSE;

l_all_units_for_drop BOOLEAN := FALSE;
l_failed_unit_codes  VARCHAR2(2000);
l_failed_uoo_ids  VARCHAR2(2000);
l_coreq_failed_units VARCHAR2(2000);
l_prereq_failed_units VARCHAR2(2000);
l_drop_uoo_ids VARCHAR2(2000);

l_unit_cd      igs_ps_unit_ver.unit_cd%TYPE;
l_unit_version_number igs_ps_unit_ver.VERSION_NUMBER%TYPE;

l_enr_meth_type igs_en_method_type.enr_method_type%TYPE;
l_enr_cal_type VARCHAR2(20);
l_enr_ci_seq NUMBER(20);
l_enr_cat VARCHAR2(20);
l_enr_comm VARCHAR2(2000);

l_acad_cal_type igs_ca_inst.cal_type%type;
l_acad_ci_sequence_number igs_ca_inst.sequence_number%type;
l_acad_start_dt igs_ca_inst.start_dt%type;
l_acad_end_dt igs_ca_inst.end_dt%type;
l_alternate_code igs_ca_inst.alternate_code%type;
l_acad_message varchar2(100);

-- Added as part of Enrollment Eligibility and validations
l_eftsu_total          igs_en_su_attempt.override_eftsu%type;
l_total_credit_points  igs_en_su_attempt.override_enrolled_cp%TYPE ;
l_credit_points        igs_en_su_attempt.override_enrolled_cp%TYPE := 0;
l_dummy                   VARCHAR2(200);
l_return_status           VARCHAR2(10);

l_sub_uoo_ids VARCHAR2(2000);
l_nonsub_uoo_ids  VARCHAR2(2000);
l_sub_unit VARCHAR2(1);
l_chk_sub VARCHAR2(1);
l_sub_drop_uoo_ids VARCHAR2(2000);
L_DROP_ALLUOO_IDS VARCHAR2(2000);

NO_AUSL_RECORD_FOUND EXCEPTION;
pragma exception_init(NO_AUSL_RECORD_FOUND,-20010);

CURSOR cur_uoo_id (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT unit_cd, version_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;


CURSOR c_dcnt_rsn IS
 SELECT DISCONTINUATION_REASON_CD
 FROM igs_en_dcnt_reasoncd
 WHERE  NVL(closed_ind,'N')     ='N'
 AND  dflt_ind                  ='Y'
 AND dcnt_unit_ind              ='Y';


  lv_message_name VARCHAR2(2000);
  lv_message_name2 VARCHAR2(100);
  lv_return_type  VARCHAR2(2);
  l_req_unit_failed BOOLEAN;

 l_dcnt_reason_cd igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE;

  -- Cursor to get the coo_id of the student.
  CURSOR cur_coo_id IS
  SELECT coo_id coo_id
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd ;

  l_attendance_type_reach BOOLEAN := TRUE;
  l_cur_coo_id  cur_coo_id%ROWTYPE;
  l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att

 TYPE c_ref_cursor IS REF CURSOR;
  c_ref_cur_inst c_ref_cursor;
  c_ref_only_dup c_ref_cursor;
  c_chk_sub c_ref_cursor;
  v_ref_cur_rec igs_en_su_attempt%ROWTYPE;

 TYPE tDataBuff IS
 TABLE OF igs_en_su_attempt%ROWTYPE
 INDEX BY BINARY_INTEGER;

   lData tDataBuff;
   lDataEmpty tDataBuff;
   t1_idx BINARY_INTEGER := 0;
l_prereq_failed_uoo_ids VARCHAR2(2000);
l_coreq_failed_uoo_ids VARCHAR2(2000);
l_person_id_found igs_en_su_attempt_all.person_id%TYPE;
BEGIN
  lData := lDataEmpty; --Initializing the array

  -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_meth_type,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);

  IF p_dcnt_reason_cd IS NULL THEN
    OPEN c_dcnt_rsn;
    FETCH c_dcnt_rsn INTO l_dcnt_reason_cd;
    CLOSE c_dcnt_rsn;
  END IF;

  -- added below logic to get the Academic Calendar which is used by method enrp_get_enr_cat
  --
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
    RETURN;
  END IF;


  l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                        p_person_id,
                        p_program_cd,
                        l_acad_cal_type,
                        l_acad_ci_sequence_number,
                        NULL,
                        l_enr_cal_type,
                        l_enr_ci_seq,
                        l_enr_comm,
                        l_dummy);

  IF l_enr_comm = 'BOTH' THEN
     l_enr_comm :='ALL';
  END IF;

  l_message:= NULL;
  l_deny_warn_min_cp  := igs_ss_enr_details.get_notification(
    p_person_type            => p_person_type,
    p_enrollment_category    => l_enr_cat,
    p_comm_type              => l_enr_comm,
    p_enr_method_type        => l_enr_meth_type,
    p_step_group_type        => 'PROGRAM',
    p_step_type              => 'FMIN_CRDT',
    p_person_id              => p_person_id,
    p_message                => l_message
    ) ;
    IF l_message IS NOT NULL THEN
          p_message := l_message;
          p_return_status := 'FALSE';
          RETURN;
    END IF;

  l_deny_warn_att_type  := igs_ss_enr_details.get_notification(
    p_person_type            => p_person_type,
    p_enrollment_category    => l_enr_cat,
    p_comm_type              => l_enr_comm,
    p_enr_method_type        => l_enr_meth_type,
    p_step_group_type        => 'PROGRAM',
    p_step_type              => 'FATD_TYPE',
    p_person_id              => p_person_id,
    p_message                => l_message
    ) ;
    IF l_message IS NOT NULL THEN
          p_message := l_message;
          p_return_status := 'FALSE';
          RETURN;
    END IF;

    IF l_deny_warn_att_type  IS NOT NULL THEN
        OPEN  cur_coo_id;
        FETCH cur_coo_id INTO l_cur_coo_id;
        CLOSE cur_coo_id;

        -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
        l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(
            p_person_id          => p_person_id,
            p_coo_id             => l_cur_coo_id.coo_id,
            p_cal_type           => l_acad_cal_type,
            p_ci_sequence_number => l_acad_ci_sequence_number,
            p_message_name       => l_message,
            p_attendance_types   => l_attendance_types,
            p_load_or_teach_cal_type => p_load_cal_type,
            p_load_or_teach_seq_number => p_load_sequence_number);

            -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
        IF l_attendance_type_reach THEN
            l_deny_warn_att_type  := 'AttTypReached' ;
        ELSE
            l_deny_warn_att_type  := 'AttTypNotReached' ;
        END IF ;

    END IF ;

  l_deny_warn_coreq  := igs_ss_enr_details.get_notification(
    p_person_type            => p_person_type,
    p_enrollment_category    => l_enr_cat,
    p_comm_type              => l_enr_comm,
    p_enr_method_type        => l_enr_meth_type,
    p_step_group_type        => 'UNIT',
    p_step_type              => 'COREQ',
    p_person_id              => p_person_id,
    p_message                => l_message
    ) ;
    IF l_message IS NOT NULL THEN
          p_message := l_message;
          p_return_status := 'FALSE';
          RETURN;
    END IF;

  l_deny_warn_prereq := igs_ss_enr_details.get_notification(
    p_person_type            => p_person_type,
    p_enrollment_category    => l_enr_cat,
    p_comm_type              => l_enr_comm,
    p_enr_method_type        => l_enr_meth_type,
    p_step_group_type        => 'UNIT',
    p_step_type              => 'PREREQ',
    p_person_id              => p_person_id,
    p_message                => l_message
    ) ;
    IF l_message IS NOT NULL THEN
          p_message := l_message;
          p_return_status := 'FALSE';
          RETURN;
    END IF;


  --Decode the concatenated string and check that all units are not selected,
  --in which case, just delete all units w/o checking cp or coreq requirements.
  l_drop_uoo_ids := p_uoo_ids;

  OPEN c_ref_cur_inst FOR '
  SELECT DISTINCT u.person_id
  FROM  IGS_EN_SU_ATTEMPT U, IGS_CA_LOAD_TO_TEACH_V
  WHERE person_id =:1
  AND   course_cd = :2
  AND   unit_attempt_status IN  (''ENROLLED'',''INVALID'',''WAITLISTED'')
  AND   cal_type = teach_cal_type
  AND   ci_sequence_number = teach_ci_sequence_number
  AND   load_cal_type = :3
  AND   load_ci_sequence_number =:4
  AND   uoo_id NOT IN('||l_drop_uoo_ids||')'
  USING p_person_id, p_program_cd, p_load_cal_type, p_load_sequence_number ;

  FETCH c_ref_cur_inst INTO l_person_id_found ;
  IF c_ref_cur_inst%NOTFOUND THEN
      l_all_units_for_drop := TRUE;
  END IF;
  ClOSE c_ref_cur_inst;

  IF NOT l_all_units_for_drop THEN
      -- Even if only duplicate unit attempt are selected for drop then do
      -- not perform any validations. So that we do not get any min cp or
      -- attendance type validation fialures.
      OPEN c_ref_only_dup FOR '
      SELECT U.*
      FROM  IGS_EN_SU_ATTEMPT U
      WHERE person_id =:1  AND
        unit_attempt_status <> ''DUPLICATE'' AND
        (cal_type,ci_sequence_number) IN
          (SELECT teach_cal_type,teach_ci_sequence_number
           FROM igs_ca_load_to_teach_v
           WHERE load_cal_type = :2
           AND load_ci_sequence_number =:3 )
           AND uoo_id IN('||l_drop_uoo_ids||')'
           USING p_person_id, p_load_cal_type, p_load_sequence_number;
      FETCH c_ref_only_dup INTO v_ref_cur_rec ;
      IF c_ref_only_dup%NOTFOUND THEN
          l_all_units_for_drop := TRUE;
      END IF;
      CLOSE c_ref_only_dup;
  END IF;

 --call procedure to reorder the unts such that subordinate units are processed first.
 -- the list of units are reordered and returned in l_drop_alluoo_ids.

  enrp_chk_del_sub_units (
      p_person_id => p_person_id ,
      p_course_cd => p_program_cd,
      p_load_cal_type => p_load_cal_type,
      p_load_ci_seq_num => p_load_sequence_number,
      p_selected_uoo_ids => p_uoo_ids,
      p_ret_all_uoo_ids => l_drop_alluoo_ids,
      p_ret_sub_uoo_ids => l_sub_drop_uoo_ids,
      p_ret_nonsub_uoo_ids => l_nonsub_uoo_ids,
      p_delete_flag => 'N'
      );

IF l_all_units_for_drop THEN
   WHILE l_drop_alluoo_ids IS NOT NULL LOOP
      l_credit_points := 0;
     --extract the uoo_id
      IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN
        l_uoo_id :=TO_NUMBER(l_drop_alluoo_ids);
      ELSE

        l_uoo_id := TO_NUMBER(substr(l_drop_alluoo_ids,0,instr(l_drop_alluoo_ids,',',1)-1)) ;
      END IF;

     --param indication if unit is sub or not
      l_sub_unit := 'N';
      --cursor to
       IF l_sub_drop_uoo_ids IS NOT NULL THEN

       OPEN c_chk_sub FOR 'Select ''X'' from igs_en_su_attempt sua where sua.uoo_id in ('||l_sub_drop_uoo_ids||') AND sua.person_id =
       '||p_person_id|| 'AND sua.course_cd = '''|| p_program_cd|| '''AND exists (SELECT ''X'' from igs_ps_unit_ofr_opt uoo
        WHERE uoo.sup_uoo_id IN (' ||l_drop_alluoo_ids||') AND uoo.relation_type = ''SUBORDINATE'' AND uoo.uoo_id = sua.uoo_id)';

         FETCH c_chk_sub INTO l_chk_sub;
         IF c_chk_sub%FOUND THEN
            l_sub_unit := 'Y';
         END IF;
         CLOSE c_chk_sub;
       END IF;

  --IF l_all_units_for_drop THEN
    --Call enrp_dropall_units
    igs_en_gen_004.enrp_dropall_unit(
      p_person_id          => p_person_id,
      p_cal_type   => p_load_cal_type,
      p_ci_sequence_number => p_load_sequence_number,
      p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
      p_admin_unit_sta     => p_admin_unit_status,
      p_effective_date     => p_effective_date,
      p_program_cd         => p_program_cd,
      p_uoo_id             => l_uoo_id,
      p_sub_unit           => l_sub_unit);
 IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN
        l_drop_alluoo_ids := NULL;
      ELSE
        l_drop_alluoo_ids := substr(l_drop_alluoo_ids,instr(l_drop_alluoo_ids,',',1)+1);
      END IF;
END LOOP;
  ELSE

OPEN   c_ref_cur_inst FOR ' SELECT U.* FROM  IGS_EN_SU_ATTEMPT U     WHERE person_id
      = :1  AND unit_attempt_status IN  (''ENROLLED'',''INVALID'') AND
      uoo_id NOT IN('||p_uoo_ids||')'
      USING p_person_id;

      LOOP

        FETCH c_ref_cur_inst INTO v_ref_cur_rec ;

        EXIT WHEN c_ref_cur_inst%NOTFOUND;

        IF p_ovrrd_crq_chk = 'N' AND l_deny_warn_coreq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_coreq( --Do a coreq check only if l_deny_warn_coreq is defined
              p_person_id                =>  p_person_id,
              p_load_cal_type            =>  p_load_cal_type,
              p_load_sequence_number     =>  p_load_sequence_number,
              p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
              p_course_cd                =>  p_program_cd,
              p_course_version           =>  p_program_version,
              p_message                  =>  l_message,
              p_deny_warn                =>  l_deny_warn_coreq,
              p_calling_obj                          =>  'JOB') THEN

            -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
            -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
                l_coreq_failed_units  := l_coreq_failed_units || ',' || v_ref_cur_rec.unit_cd;
                l_coreq_failed_uoo_ids:= l_coreq_failed_uoo_ids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);

        ELSE
           -- Since the coreq rule has passed, store these passed uoo_ids
           -- into a temp table so that the prereq check can be run for these uoo_ids
           -- instead of opening the cursor again

           lData(t1_idx).uoo_id := v_ref_cur_rec.uoo_id;
           lData(t1_idx).unit_cd := v_ref_cur_rec.unit_cd;
           t1_idx        :=t1_idx+1;

        END IF;
      END LOOP;
      ClOSE c_ref_cur_inst;

      -- Instead of opening the cursor again, we are storing the passed uoo_ids
      -- values into a Table
        -- Check whether records exist in the temparary table,lDATA.
        IF lData.COUNT > 0 THEN
          FOR i IN lData.FIRST ..  lData.LAST  LOOP
            IF p_ovrrd_prq_chk = 'N' AND l_deny_warn_prereq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_prereq( --Do a coreq check only if l_deny_warn_prereq is defined
              p_person_id                =>  p_person_id,
              p_load_cal_type            =>  p_load_cal_type,
              p_load_sequence_number     =>  p_load_sequence_number,
              p_uoo_id                   =>  lData(i).uoo_id,
              p_course_cd                =>  p_program_cd,
              p_course_version           =>  p_program_version,
              p_message                  =>  l_message,
              p_deny_warn                =>  l_deny_warn_prereq,
              p_calling_obj              =>  'JOB') THEN

            -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
            -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
                l_prereq_failed_units  := l_prereq_failed_units || ',' || lData(i).unit_cd;
                l_prereq_failed_uoo_ids     := l_prereq_failed_uoo_ids  ||','|| TO_CHAR(lData(i).uoo_id);

            END IF;
          END LOOP;

      END IF;
      t1_idx := 0;

    --Only some of the units have been selected for drop. so, loop thru them and drop them


       --check if the unit being deleted is a subordiante unit before calling drop_all_units.
       --initialize l_sub_unit to 'N'
       --check if the unit attmepted is in the list of sub units being dropped, then check if the
       --superior unit of that unit is in the list of the units being dropped, if yes set the l_sub_unit to 'Y'.
       WHILE l_drop_alluoo_ids IS NOT NULL LOOP
      l_credit_points := 0;
     --extract the uoo_id
      IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN
        l_uoo_id :=TO_NUMBER(l_drop_alluoo_ids);
      ELSE

        l_uoo_id := TO_NUMBER(substr(l_drop_alluoo_ids,0,instr(l_drop_alluoo_ids,',',1)-1)) ;
      END IF;

     --param indication if unit is sub or not
      l_sub_unit := 'N';
      --cursor to
       IF l_sub_drop_uoo_ids IS NOT NULL THEN

       OPEN c_chk_sub FOR 'Select ''X'' from igs_en_su_attempt sua where sua.uoo_id in ('||l_sub_drop_uoo_ids||') AND sua.person_id =
       '||p_person_id|| 'AND sua.course_cd = '''|| p_program_cd|| '''AND exists (SELECT ''X'' from igs_ps_unit_ofr_opt uoo
        WHERE uoo.sup_uoo_id IN (' ||l_drop_alluoo_ids||') AND uoo.relation_type = ''SUBORDINATE'' AND uoo.uoo_id = sua.uoo_id)';

         FETCH c_chk_sub INTO l_chk_sub;
         IF c_chk_sub%FOUND THEN
            l_sub_unit := 'Y';
         END IF;
         CLOSE c_chk_sub;
       END IF;
      -- If min cp validation fails, error out
      IF p_ovrrd_min_cp_chk  = 'Y' OR NOT l_min_cp_failed THEN
        OPEN cur_uoo_id(l_uoo_id);
        FETCH cur_uoo_id INTO l_unit_cd,l_unit_version_number;
        CLOSE cur_uoo_id ;

        IF l_deny_warn_min_cp  IS NOT NULL THEN  -- Min CP validation step is defined

          -- A call to igs_en_prc_load.enrp_clc_eftsu_total as part of- Enrollment Eligibility and validations .
          -- The Total enrolled CP of the student has to be determined before the unit is dropped(l_total_credit_points) .
          -- The unit is then dropped , and eval_min_cp is called with the value of l_total_enrolled_cp.
          -- The value of l_total_enrolled_cp is essential to determine if the Min Credit Points is already reached
          -- by the student before that Unit is dropped.

          l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(
              p_person_id             => p_person_id,
              p_course_cd             => p_program_cd ,
              p_acad_cal_type         => l_acad_cal_type,
              p_acad_sequence_number  => l_acad_ci_sequence_number,
              p_load_cal_type         => p_load_cal_type,
              p_load_sequence_number  => p_load_sequence_number,
              p_truncate_ind          => 'N',
              p_include_research_ind  => 'Y'  ,
              p_key_course_cd         => NULL ,
              p_key_version_number    => NULL ,
              p_credit_points         => l_total_credit_points );


          --Call enrp_dropall_units
          -- Dropping the unit before Min CP check, moved to here as part of bug 2401891
          --pass the p_sub_unit parameter to indicate if the unit being dropped is a subordinate(placements build)
          igs_en_gen_004.enrp_dropall_unit(
              p_person_id          => p_person_id,
              p_cal_type           => p_load_cal_type,
              p_ci_sequence_number => p_load_sequence_number,
              p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
              p_admin_unit_sta     => p_admin_unit_status,
              p_effective_date     => p_effective_date,
              p_program_cd         => p_program_cd,
              p_uoo_id             => l_uoo_id,
              p_sub_unit           => l_sub_unit);

          IF p_ovrrd_min_cp_chk = 'Y' OR igs_en_elgbl_program.eval_min_cp(
                                             p_person_id                 =>  p_person_id,
                                             p_load_calendar_type        =>  p_load_cal_type,
                                             p_load_cal_sequence_number  =>  p_load_sequence_number,
                                             p_uoo_id                    =>  l_uoo_id,
                                             p_program_cd                =>  p_program_cd,
                                             p_program_version           =>  p_program_version,
                                             p_message                   =>  l_min_cp_message,
                                             p_deny_warn                 =>  l_deny_warn_min_cp,
                                             p_credit_points             =>  l_credit_points ,
                                             p_enrollment_category       =>  l_enr_cat,
                                             p_comm_type                 =>  l_enr_comm,
                                             p_method_type               =>  l_enr_meth_type,
                                             p_min_credit_point          =>  l_total_credit_points,
                                             p_calling_obj               =>  'JOB') THEN

             -- validate the holds when droping an unit, pmarada, 2385096

             IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id,
                 p_program_cd ,
                 p_load_cal_type,
                 p_load_sequence_number,
                 lv_message_name,
                 lv_message_name2,
                 lv_return_type,
                 NULL -- default value, it will be calculated internally based on the census date
                 )   THEN
               l_req_unit_failed := TRUE;
               EXIT;
             END IF;
             -- End of the code added by pmarada,  2385096

          ELSE
            l_min_cp_failed := TRUE;
          END IF; -- ens of p_ovrrd_min_cp_chk

    ELSE

          --Call enrp_dropall_units
          igs_en_gen_004.enrp_dropall_unit(
            p_person_id          => p_person_id,
            p_cal_type   => p_load_cal_type,
            p_ci_sequence_number => p_load_sequence_number,
            p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
            p_admin_unit_sta     => p_admin_unit_status,
            p_effective_date     => p_effective_date,
            p_program_cd         => p_program_cd,
            p_uoo_id             => l_uoo_id,
            p_sub_unit           => l_sub_unit);

          -- validate the holds when droping an unit, pmarada, 2385096

          IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id,
                   p_program_cd ,
                   p_load_cal_type,
                   p_load_sequence_number,
                   lv_message_name,
                   lv_message_name2,
                   lv_return_type,
                   NULL  -- default value, it will be calculated internally based on the census date
                   )   THEN
            l_req_unit_failed := TRUE;
            EXIT;

          END IF;
          -- End of the code added by pmarada,  2385096
        END IF;
      END IF;

      IF p_ovrrd_min_cp_chk = 'Y' OR NOT l_min_cp_failed  THEN
         IF p_ovrrd_att_typ_chk  = 'Y' OR NOT l_att_typ_failed THEN

                    -- If the Att Type validation step has been setup , continue validating.
                IF  l_deny_warn_att_type IS NOT NULL THEN
                    IF NOT (igs_en_elgbl_program.eval_unit_forced_type(  p_person_id                 => p_person_id,
                                                             p_load_calendar_type        => p_load_cal_type,
                                                             p_load_cal_sequence_number  => p_load_sequence_number,
                                                             p_uoo_id                    => l_uoo_id          ,
                                                             p_course_cd                 => p_program_cd,
                                                             p_course_version            => p_program_version,
                                                             p_message                   => l_att_type_message,
                                                             p_deny_warn                 => l_deny_warn_att_type ,
                                                             p_enrollment_category       => l_enr_cat,
                                                             p_comm_type                 => l_enr_comm,
                                                             p_method_type               => l_enr_meth_type,
                                                             p_calling_obj               =>  'JOB') ) THEN

                             l_att_typ_failed := TRUE;
                        END IF ;

                END IF ;

         END IF; -- p_ovrrd_att_typ_chk  = 'Y' OR NOT l_att_typ_failed
      END IF; -- p_ovrrd_min_cp_chk = 'Y' OR NOT l_min_cp_failed

      IF(instr(l_drop_alluoo_ids,',',1) = 0) THEN
        l_drop_alluoo_ids := NULL;
      ELSE
        l_drop_alluoo_ids := substr(l_drop_alluoo_ids,instr(l_drop_alluoo_ids,',',1)+1);
      END IF;

    END LOOP;  -- End of while loop dropping the selected units
--IF NOT l_all_units_for_drop THEN
    IF p_ovrrd_min_cp_chk = 'Y' OR NOT l_min_cp_failed  THEN

      -- check if any prereq/coreq rules are failing before the drop so that these rule failures
      -- can be ignored later.
      OPEN   c_ref_cur_inst FOR ' SELECT U.* FROM  IGS_EN_SU_ATTEMPT U     WHERE person_id
      = :1  AND unit_attempt_status IN  (''ENROLLED'',''INVALID'') AND
      uoo_id NOT IN('||p_uoo_ids||')'
      USING p_person_id;

      LOOP

        FETCH c_ref_cur_inst INTO v_ref_cur_rec ;

        EXIT WHEN c_ref_cur_inst%NOTFOUND;

        IF p_ovrrd_crq_chk = 'N' AND l_deny_warn_coreq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_coreq( --Do a coreq check only if l_deny_warn_coreq is defined
              p_person_id                =>  p_person_id,
              p_load_cal_type            =>  p_load_cal_type,
              p_load_sequence_number     =>  p_load_sequence_number,
              p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
              p_course_cd                =>  p_program_cd,
              p_course_version           =>  p_program_version,
              p_message                  =>  l_message,
              p_deny_warn                =>  l_deny_warn_coreq,
              p_calling_obj              =>  'JOB') THEN

            -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
            -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
            -- if the unit has failed the coreq rule before drop operation, dont consider the rule to have
            -- failed due to the drop.
           IF  (l_coreq_failed_uoo_ids IS NULL OR INSTR(l_coreq_failed_uoo_ids,TO_CHAR(v_ref_cur_rec.uoo_id)) = 0) THEN
              IF (l_failed_unit_codes IS NULL OR INSTR(l_failed_unit_codes,v_ref_cur_rec.unit_cd ) = 0) THEN
                l_failed_unit_codes  := l_failed_unit_codes || ',' || v_ref_cur_rec.unit_cd;
              END IF;
              l_failed_uoo_ids      := l_failed_uoo_ids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);
              l_coreq_failed := TRUE;
           END IF ;


        ELSE
           -- Since the coreq rule has passed, store these passed uoo_ids
           -- into a temp table so that the prereq check can be run for these uoo_ids
           -- instead of opening the cursor again

           lData(t1_idx).uoo_id := v_ref_cur_rec.uoo_id;
           lData(t1_idx).unit_cd := v_ref_cur_rec.unit_cd;
           t1_idx        :=t1_idx+1;

        END IF;
      END LOOP;
      ClOSE c_ref_cur_inst;

      -- Instead of opening the cursor again, we are storing the passed uoo_ids
      -- values into a Table so that a prereq check can now be run since
      -- the min_cp and coreq checks have passed
      IF (p_ovrrd_min_cp_chk = 'Y' OR NOT l_min_cp_failed) AND NOT l_coreq_failed THEN
        -- Run prereq check since coreq has passed
        -- Check whether records exist in the temparary table,lDATA.
        IF lData.COUNT > 0 THEN
          FOR i IN lData.FIRST ..  lData.LAST  LOOP
            IF p_ovrrd_prq_chk = 'N' AND l_deny_warn_prereq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_prereq( --Do a coreq check only if l_deny_warn_prereq is defined
              p_person_id                =>  p_person_id,
              p_load_cal_type            =>  p_load_cal_type,
              p_load_sequence_number     =>  p_load_sequence_number,
              p_uoo_id                   =>  lData(i).uoo_id,
              p_course_cd                =>  p_program_cd,
              p_course_version           =>  p_program_version,
              p_message                  =>  l_message,
              p_deny_warn                =>  l_deny_warn_prereq,
              p_calling_obj              =>  'JOB') THEN

            -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
            -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
            -- if the unit has failed the prereq rule before drop operation, dont consider the rule to have
            -- failed due to the drop.
              IF   (l_prereq_failed_uoo_ids IS NULL OR INSTR(l_prereq_failed_uoo_ids,TO_CHAR(lData(i).uoo_id) ) = 0) THEN
                    IF (l_failed_unit_codes IS NULL OR INSTR(l_failed_unit_codes,lData(i).unit_cd ) = 0) THEN
                       l_failed_unit_codes  := l_failed_unit_codes || ',' || lData(i).unit_cd;
                    END IF;
                    l_failed_uoo_ids      := l_failed_uoo_ids  ||','|| TO_CHAR(lData(i).uoo_id);
                    l_prereq_failed := TRUE;
              END IF ;

            END IF;
          END LOOP;
        END IF;

      END IF;
    END IF;

    --Format the returned fields for redundant commas etc.
    IF INSTR(l_failed_unit_codes,',') = 1 THEN
      l_failed_unit_codes := SUBSTR(l_failed_unit_codes,2);
    END IF;

    IF INSTR(l_failed_uoo_ids,',') = 1 THEN
      l_failed_uoo_ids := SUBSTR(l_failed_uoo_ids,2);
    END IF;

    IF INSTR(l_failed_unit_codes,',') = length(l_failed_unit_codes) THEN
      l_failed_unit_codes := substr(l_failed_unit_codes,0,length(l_failed_unit_codes)-1) ;
    END IF;

    IF INSTR(l_failed_uoo_ids,',') = length(l_failed_uoo_ids) THEN
      l_failed_uoo_ids := substr(l_failed_uoo_ids,0,length(l_failed_uoo_ids)-1) ;
    END IF;

  END IF; -- end of l_all_units_for_drop comparison

  --Return the status and error msg to calling procedure
    IF l_coreq_failed THEN

      p_return_status := 'FALSE';
      IF l_deny_warn_coreq  = 'WARN' THEN
         p_message         := 'IGS_SS_EN_CRQ_DRP_WARN';
      ELSE
         p_message       :=   'IGS_SS_EN_CRQ_DRP_DENY';
         p_failed_uoo_ids :=  l_failed_uoo_ids;
      END IF;
      p_failed_unit_cds := l_failed_unit_codes;


  ELSIF p_ovrrd_min_cp_chk = 'N' AND l_min_cp_failed THEN
      p_return_status := 'FALSE';
      -- set the appropriate message name based on the message returned from eval_min_cp call.
      -- if WARN message is returned

      IF l_min_cp_message = 'IGS_SS_WARN_MIN_CP_REACHED' THEN
         p_message       := 'IGS_SS_EN_MIN_CP_WARN';
      ELSE
         p_message       := 'IGS_SS_EN_MIN_CP_DENY';
      END IF;
  ELSIF p_ovrrd_att_typ_chk  = 'N' AND l_att_typ_failed THEN
        p_return_status := 'FALSE';

      -- set the appropriate message name based on the message returned from  call.
      -- if WARN message is returned
      IF l_att_type_message = 'IGS_SS_WARN_ATTYPE_CHK' THEN
         p_message       := 'IGS_SS_EN_ATT_TYP_WARN';
      ELSE
         p_message       := 'IGS_SS_EN_ATT_TYP_DENY';
      END IF;

  ELSIF l_prereq_failed THEN
       p_return_status := 'FALSE';

      IF   l_deny_warn_prereq = 'WARN' THEN
         p_message       := 'IGS_SS_EN_PRQ_DRP_WARN';
      ELSE
         p_message       := 'IGS_SS_EN_PRQ_DRP_DENY';
         p_failed_uoo_ids :=  l_failed_uoo_ids ;
      END IF;

      p_failed_unit_cds := l_failed_unit_codes;

  ELSIF l_req_unit_failed THEN       -- for required units message handing, pmarada
       IF lv_message_name2 = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
          lv_message_name2 := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
       END IF;
       IF lv_message_name = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
          lv_message_name := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
       END IF;
       p_return_status := 'FALSE';
       IF lv_message_name IS NOT NULL
        AND INSTR(NVL(p_message,' '),lv_message_name) = 0
        AND lv_return_type ='E' THEN
            p_message := lv_message_name;
      END IF;
       IF lv_message_name2 IS NOT NULL
        AND INSTR(NVL(p_message,' '),lv_message_name2) = 0
        AND lv_return_type ='E' THEN
            p_message := lv_message_name2;
       END IF;
  ELSE
    p_return_status := 'TRUE';
  END IF;

 EXCEPTION
   WHEN NO_AUSL_RECORD_FOUND THEN
       p_message := 'IGS_EN_AUS_NOT_DEFINED';
       p_return_status := 'FALSE';
       RETURN;
 END drop_selected_units;

--BEGIN DROP ALL UNITS CODE
-- Added the following two parameters p_reason, p_source_of_drop
-- as part of Drop/ Transfer Workflow Notification DLD.
-- pradhakr; 30-Sep-2002; Bug# 2599925.
PROCEDURE drop_all_workflow (
p_uoo_ids               IN VARCHAR2,
p_person_id             IN NUMBER,
p_load_cal_type         IN VARCHAR2,
p_load_sequence_number  IN NUMBER,
p_program_cd            IN VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2,
p_drop_date             IN DATE DEFAULT NULL,
p_old_cp                IN NUMBER DEFAULT NULL,
p_new_cp                IN NUMBER DEFAULT NULL
) AS
------------------------------------------------------------------------------
--Created by  :
--Date created:
--
-- Purpose:

-- Known limitations/enhancements and/or remarks:
--
-- Change History:
-- Who         When            What
-- kkillams    13-OCT-2003     Three new paramters are added to the procedure w.r.t bug#3160856
------------------------------------------------------------------------------

  CURSOR cur_seq_val
  IS
  SELECT igs_en_status_mail_req_s.nextval seq_val
  FROM DUAL;

  CURSOR cur_user_name IS SELECT user_name FROM fnd_user WHERE user_id = fnd_global.user_id;

  CURSOR cur_cal_desc  IS SELECT description FROM igs_ca_inst WHERE cal_type = p_load_cal_type
                                                              AND   sequence_number = p_load_sequence_number;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T := wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;
  l_wf_role             VARCHAR2(100);
  l_cal_desc            IGS_CA_INST.DESCRIPTION%TYPE;

  BEGIN
    -- get the profile value that is set for checking if workflow is installed
    fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

    -- if workflow is installed then carry on with the raising an event
    IF (RTRIM(l_wf_installed) ='Y') THEN
      -- get the next value of the sequence
      OPEN cur_seq_val;
      FETCH cur_seq_val INTO l_cur_seq_val;
      CLOSE cur_seq_val;

      --Get the login user name.
      OPEN cur_user_name;
      FETCH cur_user_name INTO l_wf_role;
      CLOSE cur_user_name;

      --Get load calendar descriptin.
      OPEN cur_cal_desc;
      FETCH cur_cal_desc INTO l_cal_desc;
      CLOSE cur_cal_desc;
      -- set the event parameters
      wf_event.addparametertolist(P_NAME  => 'STUDENT_ID'          ,P_VALUE  => p_person_id            ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'UOO_IDS'             ,P_VALUE  => p_uoo_ids              ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'CAL_TYPE'            ,P_VALUE  => p_load_cal_type        ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'CAL_SEQUENCE_NUMBER' ,P_VALUE  => p_load_sequence_number ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'PROGRAM_CD'          ,P_VALUE  => p_program_cd           ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'DROP_DATE'           ,P_VALUE  => p_drop_date            ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'OLD_CP'              ,P_VALUE  => NVL(p_old_cp,0)        ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'NEW_CP'              ,P_VALUE  => NVL(p_new_cp,0)        ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'P_WF_ROLE'           ,P_VALUE  => l_wf_role              ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'CAL_DESC'            ,P_VALUE  => l_cal_desc             ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'REASON'              ,P_VALUE  => igs_en_su_attempt_pkg.pkg_reason         ,P_PARAMETERLIST  => l_wf_parameter_list_t);
      wf_event.addparametertolist(P_NAME  => 'SOURCE_OF_DROP'      ,P_VALUE  => igs_en_su_attempt_pkg.pkg_source_of_drop ,P_PARAMETERLIST  => l_wf_parameter_list_t);

      -- raise the event
      WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.dropnotification',
                     p_event_key =>'oracle.apps.igs.en.dropnotification'||l_cur_seq_val.seq_val,
                     p_event_data=>NULL,
                     p_parameters=>l_wf_parameter_list_t);
    END IF;
    p_return_status := 'TRUE';
END drop_all_workflow;


PROCEDURE transfer_workflow (
p_source_uoo_ids        IN VARCHAR2,
p_dest_uoo_ids          IN VARCHAR2,
p_person_id             IN NUMBER,
p_load_cal_type         IN VARCHAR2,
p_load_sequence_number  IN NUMBER,
p_program_cd            IN VARCHAR2,
p_unit_attempt_status   IN VARCHAR2,
p_reason                IN VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2,
p_message               OUT NOCOPY VARCHAR2
) AS
 ------------------------------------------------------------------------------------
  --Created by  : pradhakr
  --Date created: 30-Sep-2002
  --
  -- Purpose: Whenever there is a transfer of students from one unit section to another
  --          this procedure is called which raises a business event.
  --          Added as part of Drop / Transfer Workflow Notification DLD.
  --          Bug# 2599925.
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  ------------------------------------------------------------------------------

CURSOR cur_seq_val
  IS
  SELECT igs_en_wf_trans_notif_s.nextval seq_val
  FROM DUAL;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T:=wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;
BEGIN
  -- get the profile value that is set for checking if workflow is installed
  fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

  -- if workflow is installed then carry on with the raising an event
  IF (RTRIM(l_wf_installed) = 'Y' ) THEN

     OPEN cur_seq_val;
     FETCH cur_seq_val INTO l_cur_seq_val;
     CLOSE cur_seq_val;

     -- set the event parameters
     wf_event.addparametertolist(p_Name=>'SOURCE_UOO_IDS'       ,p_Value=>p_source_uoo_ids       ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'DEST_UOO_IDS'         ,p_Value=>p_dest_uoo_ids         ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'STUDENT_ID'           ,p_Value=>p_person_id            ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'CAL_TYPE'             ,p_Value=>p_load_cal_type        ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'CAL_SEQUENCE_NUMBER'  ,p_Value=>p_load_sequence_number ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'PROGRAM_CD'           ,p_Value=>p_program_cd           ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'UNIT_ATTEMPT_STATUS'  ,p_Value=>p_unit_attempt_status  ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'REASON'               ,p_Value=>p_reason               ,p_Parameterlist =>l_wf_parameter_list_t);

     -- raise the event
     WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.transfernotification',
                    p_event_key =>'oracle.apps.igs.en.transfernotification'||l_cur_seq_val.seq_val,
                    p_event_data=>NULL,
                    p_parameters=>l_wf_parameter_list_t);
  END IF;
  p_return_status := 'TRUE';
END transfer_workflow;

FUNCTION enr_val_grad_usec
(
  p_uoo_ids IN VARCHAR2,
  p_grading_schema_code IN VARCHAR2,
  p_gs_version_number IN NUMBER
) RETURN BOOLEAN
IS

  ------------------------------------------------------------------------------------
  --Created by  : pradhakr
  --Date created: 30-Sep-2002
  --
  -- Purpose: Procedure to check whether Grading Schema exists in the Unit Section Level /
  --          Unit level. Added as part of Drop / Transfer Workflow Notification DLD.
  --          Bug# 2599925.
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  ------------------------------------------------------------------------------------

-- Cursor to check the existance of grading schema in Unit Section level.
CURSOR c_grad_schema IS
  SELECT grading_schema_code, grd_schm_version_number
  FROM igs_ps_usec_grd_schm
  WHERE uoo_id = p_uoo_ids;

-- Cursor to check the existance of grading schema in Unit level.
CURSOR c_grad_schema_cd(l_unit_cd VARCHAR2, l_unit_version NUMBER) IS
  SELECT grading_schema_code, grd_schm_version_number
  FROM igs_ps_unit_grd_schm
  WHERE unit_code = l_unit_cd
  AND unit_version_number = l_unit_version ;

CURSOR c_unit_cd IS
  SELECT unit_cd, version_number
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_ids ;

l_unit_cd c_unit_cd%ROWTYPE;
l_grad_schema c_grad_schema%ROWTYPE;
l_grad_schema_cd c_grad_schema_cd%ROWTYPE;


BEGIN

  OPEN c_grad_schema;
  FETCH c_grad_schema INTO l_grad_schema;

  -- Check whether the grading schema exists in Unit Section level. If exists,
  -- return True.
  IF c_grad_schema%FOUND THEN
     LOOP
        IF (p_grading_schema_code = l_grad_schema.grading_schema_code AND
            p_gs_version_number = l_grad_schema.grd_schm_version_number) THEN
            CLOSE c_grad_schema;
            RETURN TRUE;
        ELSE
            FETCH c_grad_schema INTO l_grad_schema;
            EXIT WHEN c_grad_schema%NOTFOUND;
        END IF;
     END LOOP;
     CLOSE c_grad_schema;
     RETURN FALSE;
  ELSE
    CLOSE c_grad_schema;
    -- Get the unit code and version number for the passed uoo_id.
    OPEN c_unit_cd;
    FETCH c_unit_cd INTO l_unit_cd;
    CLOSE c_unit_cd;

    OPEN c_grad_schema_cd (l_unit_cd.unit_cd, l_unit_cd.version_number);
    FETCH c_grad_schema_cd INTO l_grad_schema_cd;

     -- Check whether the grading schema exists in Unit level.
    IF c_grad_schema_cd%FOUND THEN
         LOOP
             IF (p_grading_schema_code = l_grad_schema_cd.grading_schema_code AND
                 p_gs_version_number = l_grad_schema_cd.grd_schm_version_number) THEN
                 CLOSE c_grad_schema_cd;
                 RETURN TRUE;
             ELSE
                 FETCH c_grad_schema_cd INTO l_grad_schema_cd;
                 EXIT WHEN c_grad_schema_cd%NOTFOUND;
             END IF;
          END LOOP;
          CLOSE c_grad_schema_cd;
          RETURN FALSE;
    ELSE
      CLOSE c_grad_schema_cd;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
 END IF;

END enr_val_grad_usec;

--Call from SS to valdiate if min or max cp has been breached
PROCEDURE validate_upd_cp(
             x_person_id IN NUMBER,
             x_person_type IN VARCHAR2,
             x_load_cal_type IN VARCHAR2,
             x_load_sequence_number IN NUMBER,
             x_uoo_id IN NUMBER,
             x_program_cd IN VARCHAR2,
             x_program_version IN NUMBER,
             x_override_enrolled_cp IN NUMBER,
             x_message OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2
           )  AS
-- Change History
-- Who          When            What
-- rvivekan       18-jun-2003      Reenrollment and repeat build #2881363 added
--                                 reenroll step to validate_upd_cp
-- smanglm     03-02-2003      call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
-- amuthu      20-JAN-2003     moved the savepoint to the begining of the procedure
-- svenkata    7-Jan-03        Incorporated the logic for 'When first Reach Attendance Type'. The routine enrp_val_coo_att is being called to get the
--                              Att Typ before updating the CP.The CP is updated and the routine eval_unit_forced_type is called to evaluate. A call to
--                              SUA Update row is made intentinally 'cos the post validation cannot be carried out in the SS screen from where this routine is called.Bug#2737263
-- svenkata    20-Dec-02        Incorporated Att Type validation when updating the Credit Points for a Student Unit section.Bug# 2686793
--Nishikant     01-NOV-2002     SEVIS Build Bug#2641905. parameters p_person_id and p_message added in the calls
--                              get_notification.
--svenkata      21-oct-02       Bug 2616692 - The call to the fucntion eval_min_cp has been modified to add
--                              4 new parameters .
--kkillams      27-Mar-03       Modified cur_su Cursor, replaced * with relevant columns w.r.t. bug 2749648
--svenkata      6-Jun-2003      Added new validations for checking Cross element Restrictions. The validations Cross location, cross faculty amd cross mode are introduced
--                              as part of deny/ warn build. Bug 2829272.Modifications have been made in such a way that only DENY OR only WARN messages will be returned.
--myoganat   16-Jun-2003  Removed the reference to profile IGS_EN_INCL_AUDIT_CP.
--sarakshi   27-Jun-2003  Enh#2930935,added p_uoo_id parameter to IGS_EN_PRC_LOAD.ENRP_CLC_SUA_LOAD
--vkarthik     22-Jul-2004   Added three dummy variables l_audit_cp, l_billing_cp, l_enrolled_cp for all the calls to
--                                            igs_en_prc_load.enrp_clc_sua_load towards EN308 Billable credit points build Enh#3782329

  CURSOR cur_su  IS
  SELECT unit_cd,
         version_number,
         cal_type,
         ci_sequence_number,
         discontinued_dt,
         administrative_unit_status ,
         unit_attempt_status,
         no_assessment_ind
  FROM   igs_en_su_attempt
  WHERE  person_id = x_person_id AND
         course_cd = x_program_cd AND
         uoo_id = x_uoo_id;

  -- Cursor to get the coo_id of the student.
  CURSOR cur_coo_id IS
  SELECT coo_id coo_id
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = x_person_id
  AND    course_cd = x_program_cd;

  -- Cursor to get the Unit Attempt Details .
  CURSOR get_sua_dtls IS
  SELECT sua.rowid , sua.*
  FROM igs_en_su_attempt_all sua
  WHERE person_id = x_person_id AND
  course_cd = x_program_cd AND
  uoo_id = x_uoo_id FOR UPDATE NOWAIT;

  -- Cursor to get the assessment indicator value.
  CURSOR c_assessment IS
  SELECT no_assessment_ind
  FROM   igs_en_su_attempt
  WHERE  person_id = x_person_id
  AND    course_cd = x_program_cd
  AND    uoo_id = x_uoo_id;

  l_sua_dtls_rec get_sua_dtls%ROWTYPE;
  l_attendance_type_reach BOOLEAN := TRUE;
  l_cur_coo_id  cur_coo_id%ROWTYPE;
  l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att

  l_deny_warn_min_cp VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_max_cp VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_loc  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_fac  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_mod  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_att_type VARCHAR2(100) DEFAULT NULL;
  l_deny_warn_reenroll VARCHAR2(100) DEFAULT NULL;

  l_enr_meth_type igs_en_method_type.enr_method_type%TYPE;
  l_enr_cal_type VARCHAR2(20);
  l_enr_ci_seq NUMBER(20);
  l_enr_cat VARCHAR2(20);
  l_enr_comm VARCHAR2(2000);

  l_calc_cp igs_en_su_attempt.override_enrolled_cp%TYPE;
  l_calc_min_cp igs_en_su_attempt.override_enrolled_cp%TYPE;
  l_eftsu_total igs_en_su_attempt.override_enrolled_cp%TYPE;

  l_su_rec   cur_su%ROWTYPE;
  l_total_credit_points igs_en_su_attempt.override_enrolled_cp%TYPE := NULL ;

  l_enr_incurred_cp NUMBER DEFAULT 0;
  l_over_incurred_cp NUMBER DEFAULT 0;
  l_current_cp NUMBER DEFAULT 0;
  l_dummy NUMBER;
  l_acad_cal_type igs_ca_inst.cal_type%type;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%type;
  l_acad_start_dt igs_ca_inst.start_dt%type;
  l_acad_end_dt igs_ca_inst.end_dt%type;
  l_alternate_code igs_ca_inst.alternate_code%type;
  l_acad_message varchar2(100);
  l_message  VARCHAR2(1200);
  l_return_status           VARCHAR2(10);
  l_dummy1                  VARCHAR2(200);
  --dummy variables to pick up audit, billing, enrolled credit points
  --due to signature change by EN308 Billing credit hours Bug 3782329
  l_audit_cp IGS_PS_USEC_CPS.billing_credit_points%TYPE;
  l_billing_cp IGS_PS_USEC_CPS.billing_hrs%TYPE;
  l_enrolled_cp IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

BEGIN

   SAVEPOINT upd_sua_cp;


    -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
    igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_meth_type,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);

    OPEN cur_su;
    FETCH cur_su INTO l_su_rec;
    CLOSE cur_su ;

    -- added below logic to get the Academic Calendar which is used by method enrp_get_enr_cat
    --
    -- get the academic calendar of the given Load Calendar
    --
    l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                          p_cal_type                => x_load_cal_type,
                          p_ci_sequence_number      => x_load_sequence_number,
                          p_acad_cal_type           => l_acad_cal_type,
                          p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                          p_acad_ci_start_dt        => l_acad_start_dt,
                          p_acad_ci_end_dt          => l_acad_end_dt,
                          p_message_name            => l_acad_message );

      IF l_acad_message IS NOT NULL THEN
        x_message := l_acad_message;
        x_return_status := 'DENY';
      END IF;

     l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                    x_person_id,     x_program_cd,
                    l_acad_cal_type, l_acad_ci_sequence_number,
                    NULL,            l_enr_cal_type,
                    l_enr_ci_seq,    l_enr_comm,
                    l_dummy1);

    IF l_enr_comm = 'BOTH' THEN
      l_enr_comm :='ALL';
    END IF;
    --
    -- Below code is added as part of Bug 2401891
    -- Checking Load Incurred as user can re-instate a discontinued unit and change CP in one transaction
    --
    -- Getting the current cp and passing this against parameter  p_override_enrolled_cp to get Incurred CP.
    -- (As the current CP can be from igs_ps_unit_ver or from igs_en_su_attempt)
    l_current_cp := igs_ss_enr_details.get_credit_points(x_person_id,x_uoo_id,l_su_rec.unit_cd,l_su_rec.version_number,x_program_cd);
    IF Igs_En_Prc_Load.ENRP_GET_LOAD_INCUR(
                                  l_su_rec.cal_type,
                                  l_su_rec.ci_sequence_number,
                                  l_su_rec.discontinued_dt,
                                  l_su_rec.administrative_unit_status ,
                                  l_su_rec.unit_attempt_status,
                                  l_su_rec.no_assessment_ind,
                                  x_load_cal_type,
                                  x_load_sequence_number,
                                  -- anilk, Audit special fee build
                                  NULL, -- for p_uoo_id
                                  'N') = 'Y' THEN
                    -- calculate CP incurred in the given Load calendar for Enrolled credit points.

                    l_enr_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                                    p_unit_cd => l_su_rec.unit_cd,
                                                                    p_version_number => l_su_rec.version_number,
                                                                    p_cal_type => l_su_rec.cal_type,
                                                                    p_ci_sequence_number => l_su_rec.ci_sequence_number,
                                                                    p_load_cal_type => x_load_cal_type,
                                                                    p_load_ci_sequence_number => x_load_sequence_number,
                                                                    p_override_enrolled_cp => l_current_cp,
                                                                    p_override_eftsu => NULL,
                                                                    p_return_eftsu => l_dummy1,
                                                                    p_uoo_id => x_uoo_id,
                                                                    -- anilk, Audit special fee build
                                                                    p_include_as_audit => 'N',
                                                                    p_audit_cp => l_audit_cp,
                                                                    p_billing_cp => l_billing_cp,
                                                                    p_enrolled_cp => l_enrolled_cp);

    END IF;
    --
    -- calculate CP incurred in the given Load calendar for Override Enrolled credit points.
    l_over_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                    p_unit_cd => l_su_rec.unit_cd,
                                                    p_version_number => l_su_rec.version_number,
                                                    p_cal_type => l_su_rec.cal_type,
                                                    p_ci_sequence_number => l_su_rec.ci_sequence_number,
                                                    p_load_cal_type => x_load_cal_type,
                                                    p_load_ci_sequence_number => x_load_sequence_number,
                                                    p_override_enrolled_cp => x_override_enrolled_cp,
                                                    p_override_eftsu => NULL,
                                                    p_return_eftsu => l_dummy1,
                                                    p_uoo_id =>x_uoo_id,
                                                    -- anilk, Audit special fee build
                                                    p_include_as_audit => 'N',
                                                    p_audit_cp => l_audit_cp,
                                                    p_billing_cp => l_billing_cp,
                                                    p_enrolled_cp => l_enrolled_cp);
      --
      -- Summing the incurred override CP and negative value of incurred current CP
      -- which is passed to Min and Max CP validations.
      l_calc_cp := l_over_incurred_cp - l_enr_incurred_cp;

      l_message := NULL;
      l_deny_warn_max_cp  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'FMAX_CRDT',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;
      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;
--------------------------------------------------------------------------------------------------------------------------------------------
      l_deny_warn_reenroll  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'UNIT',
      p_step_type                 => 'REENROLL',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;
      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

      l_deny_warn_min_cp  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'FMIN_CRDT',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;
      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

      l_deny_warn_att_type  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'FATD_TYPE',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;

      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

      l_deny_warn_cross_loc  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'CROSS_LOC',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;

      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

      l_deny_warn_cross_mod  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'CROSS_MOD',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;

      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

      l_deny_warn_cross_fac  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'CROSS_FAC',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;

      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'DENY';
            RETURN;
      END IF;

            -- A call to igs_en_prc_load.enrp_clc_eftsu_total as part of- Enrollment Eligibility and validations .The Total enrolled CP
            -- of the student has to be determined before the credit points of the unit is changed.The Credit Points of the unit is then
            -- changed, and eval_min_cp is called with the value l_total_credit_points passed to the parameter l_total_enrolled_cp.The
            -- value of l_total_enrolled_cp is essential to determine if the Min Credit Points is already reached by the student before
            -- the Credit points are changed.

      IF l_deny_warn_min_cp ='DENY' THEN

            l_eftsu_total := igs_en_prc_load.enrp_clc_eftsu_total(
                p_person_id             => x_person_id,
                p_course_cd             => x_program_cd ,
                p_acad_cal_type         => l_acad_cal_type,
                p_acad_sequence_number  => l_acad_ci_sequence_number,
                p_load_cal_type         => x_load_cal_type,
                p_load_sequence_number  => x_load_sequence_number,
                p_truncate_ind          => 'N',
                p_include_research_ind  => 'Y'  ,
                p_key_course_cd         => NULL ,
                p_key_version_number    => NULL ,
                p_credit_points         => l_total_credit_points );

                -- The value of l_calc_min_cp is assigned the value of l_calc_cp as the parameter
                -- p_credit_points is an  IN OUT parameter , that will modify the value in l_calc_cp.
                l_calc_min_cp := l_calc_cp ;
      END IF;
    x_return_status:='WARN';

    --  The call to the fucntion eval_min_cp has been modified to add 4 new parameters .
    IF l_deny_warn_min_cp ='DENY' AND NOT igs_en_elgbl_program.eval_min_cp(
             p_person_id                 =>  x_person_id,
             p_load_calendar_type        =>  x_load_cal_type,
             p_load_cal_sequence_number  =>  x_load_sequence_number,
             p_uoo_id                    =>  x_uoo_id,
             p_program_cd                =>  x_program_cd,
             p_program_version           =>  x_program_version,
             p_message                   =>  l_message,
             p_deny_warn                 =>  l_deny_warn_min_cp,
             p_credit_points             =>  l_calc_min_cp ,
             p_enrollment_category       =>  l_enr_cat,
             p_comm_type                 =>  l_enr_comm,
             p_method_type               =>  l_enr_meth_type,
             p_min_credit_point          =>  l_total_credit_points,
             p_calling_obj               =>  'SCH_UPD' ) THEN

                x_message := l_message ;
                x_return_status := 'DENY';
                RETURN;

    END IF ;

    IF  l_deny_warn_max_cp ='DENY' AND  NOT igs_en_elgbl_program.eval_max_cp (
             p_person_id                 =>  x_person_id,
             p_load_calendar_type        =>  x_load_cal_type,
             p_load_cal_sequence_number  =>  x_load_sequence_number,
             p_uoo_id                    =>  x_uoo_id,
             p_program_cd                =>  x_program_cd,
             p_program_version           =>  x_program_version,
             p_message                   =>  l_message,
             p_deny_warn                 =>  l_deny_warn_max_cp,
             p_upd_cp                    =>  l_calc_cp,
             p_calling_obj               => 'SCH_UPD') THEN

                x_return_status := 'DENY';
                x_message := l_message ;
                 RETURN;

    END IF ;

    IF  l_deny_warn_reenroll ='DENY' AND  NOT igs_en_elgbl_unit.eval_unit_reenroll (
             p_person_id                 =>  x_person_id,
             p_load_cal_type        =>  x_load_cal_type,
             p_load_cal_seq_number  =>  x_load_sequence_number,
             p_uoo_id                    =>  x_uoo_id,
             p_program_cd                =>  x_program_cd,
             p_program_version           =>  x_program_version,
             p_message                   =>  l_message,
             p_deny_warn                 =>  l_deny_warn_reenroll,
             p_upd_cp                    =>  x_override_enrolled_cp-l_current_cp,
             p_val_level                 =>  'CREDIT_POINT',
             p_calling_obj               => 'SCH_UPD' ) THEN

                x_return_status := 'DENY';
                x_message := l_message ;
                 RETURN;
    END IF ;

    IF l_deny_warn_att_type ='DENY'  THEN

          OPEN  cur_coo_id;
          FETCH cur_coo_id INTO l_cur_coo_id;
          CLOSE cur_coo_id;

          -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
          l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(p_person_id          => x_person_id,
              p_coo_id             => l_cur_coo_id.coo_id,
              p_cal_type           => l_acad_cal_type,
              p_ci_sequence_number => l_acad_ci_sequence_number,
              p_message_name       => l_message,
              p_attendance_types   => l_attendance_types,
              p_load_or_teach_cal_type => x_load_cal_type,
              p_load_or_teach_seq_number => x_load_sequence_number);


              -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
          IF l_attendance_type_reach THEN
              l_deny_warn_att_type  := 'AttTypReached' ;
          ELSE
              l_deny_warn_att_type  := 'AttTypNotReached' ;
          END IF ;

          BEGIN
              OPEN get_sua_dtls;
              FETCH get_sua_dtls INTO l_sua_dtls_rec;
              CLOSE get_sua_dtls;

             Igs_En_Su_Attempt_Pkg.update_row
                      (x_rowid                => l_sua_dtls_rec.ROWID,
                       x_person_id            =>l_sua_dtls_rec.person_id,
                       x_course_cd            =>l_sua_dtls_rec.course_cd,
                       x_unit_cd              =>l_sua_dtls_rec.unit_cd,
                       x_cal_type             =>l_sua_dtls_rec.cal_type,
                       x_ci_sequence_number   =>l_sua_dtls_rec.ci_sequence_number,
                       x_version_number       =>l_sua_dtls_rec.version_number,
                       x_location_cd          =>l_sua_dtls_rec.location_cd,
                       x_unit_class           =>l_sua_dtls_rec.unit_class,
                       x_ci_start_dt          =>l_sua_dtls_rec.ci_start_dt,
                       x_ci_end_dt            =>l_sua_dtls_rec.ci_end_dt,
                       x_uoo_id               =>l_sua_dtls_rec.uoo_id,
                       x_enrolled_dt          =>l_sua_dtls_rec.enrolled_dt,
                       x_unit_attempt_status  => l_sua_dtls_rec.unit_attempt_status,
                       x_administrative_unit_status   =>l_sua_dtls_rec.administrative_unit_status,
                       x_discontinued_dt              =>l_sua_dtls_rec.discontinued_dt,
                       x_dcnt_reason_cd               =>l_sua_dtls_rec.dcnt_reason_cd ,
                       x_rule_waived_dt               =>l_sua_dtls_rec.rule_waived_dt,
                       x_rule_waived_person_id        =>l_sua_dtls_rec.rule_waived_person_id,
                       x_no_assessment_ind            =>l_sua_dtls_rec.no_assessment_ind,
                       x_sup_unit_cd                  =>l_sua_dtls_rec.sup_unit_cd,
                       x_sup_version_number           =>l_sua_dtls_rec.sup_version_number,
                       x_exam_location_cd             =>l_sua_dtls_rec.exam_location_cd,
                       x_alternative_title            =>l_sua_dtls_rec.alternative_title,
                       x_override_enrolled_cp         =>x_override_enrolled_cp ,
                       x_override_eftsu               =>l_sua_dtls_rec.override_eftsu,
                       x_override_achievable_cp       =>l_sua_dtls_rec.override_achievable_cp,
                       x_override_outcome_due_dt      =>l_sua_dtls_rec.override_outcome_due_dt,
                       x_override_credit_reason       =>l_sua_dtls_rec.override_credit_reason,
                       x_administrative_priority      =>l_sua_dtls_rec.administrative_priority,
                       x_waitlist_dt                  =>l_sua_dtls_rec.waitlist_dt,
                       x_gs_version_number            => l_sua_dtls_rec.gs_version_number,
                       x_enr_method_type              => l_sua_dtls_rec.enr_method_type,
                       x_failed_unit_rule             => l_sua_dtls_rec.failed_unit_rule,
                       x_cart                         => l_sua_dtls_rec.cart,
                       x_rsv_seat_ext_id              => l_sua_dtls_rec.rsv_seat_ext_id,
                       x_mode                         =>'R',
                       x_org_unit_cd                  => l_sua_dtls_rec.org_unit_cd,
                       x_session_id                   => l_sua_dtls_rec.session_id,
                       x_grading_schema_code          => l_sua_dtls_rec.grading_schema_code,
                       x_deg_aud_detail_id            => l_sua_dtls_rec.deg_aud_detail_id,
                       x_student_career_transcript =>  l_sua_dtls_rec.student_career_transcript,
                       x_student_career_statistics =>  l_sua_dtls_rec.student_career_statistics,
                       x_subtitle                  =>  l_sua_dtls_rec.subtitle,
                       x_waitlist_manual_ind       =>  l_sua_dtls_rec.waitlist_manual_ind,
                       x_attribute_category        =>  l_sua_dtls_rec.attribute_category,
                       x_attribute1                =>  l_sua_dtls_rec.attribute1,
                       x_attribute2                =>  l_sua_dtls_rec.attribute2,
                       x_attribute3                =>  l_sua_dtls_rec.attribute3,
                       x_attribute4                =>  l_sua_dtls_rec.attribute4,
                       x_attribute5                =>  l_sua_dtls_rec.attribute5,
                       x_attribute6                =>  l_sua_dtls_rec.attribute6,
                       x_attribute7                =>  l_sua_dtls_rec.attribute7,
                       x_attribute8                =>  l_sua_dtls_rec.attribute8,
                       x_attribute9                =>  l_sua_dtls_rec.attribute9,
                       x_attribute10               =>  l_sua_dtls_rec.attribute10,
                       x_attribute11               =>  l_sua_dtls_rec.attribute11,
                       x_attribute12               =>  l_sua_dtls_rec.attribute12,
                       x_attribute13               =>  l_sua_dtls_rec.attribute13,
                       x_attribute14               =>  l_sua_dtls_rec.attribute14,
                       x_attribute15               =>  l_sua_dtls_rec.attribute15,
                       x_attribute16               =>  l_sua_dtls_rec.attribute16,
                       x_attribute17               =>  l_sua_dtls_rec.attribute17,
                       x_attribute18               =>  l_sua_dtls_rec.attribute18,
                       x_attribute19               =>  l_sua_dtls_rec.attribute19,
                       x_attribute20               =>  l_sua_dtls_rec.attribute20,
                       X_WLST_PRIORITY_WEIGHT_NUM  =>  l_sua_dtls_rec.wlst_priority_weight_num,
                       X_WLST_PREFERENCE_WEIGHT_NUM=>  l_sua_dtls_rec.wlst_preference_weight_num,
                       X_CORE_INDICATOR_CODE       =>  l_sua_dtls_rec.core_indicator_code,
                       X_UPD_AUDIT_FLAG            =>  l_sua_dtls_rec.upd_audit_flag,
                       X_SS_SOURCE_IND             =>  l_sua_dtls_rec.ss_source_ind
                       );
          EXCEPTION
              WHEN OTHERS THEN
                  ROLLBACK TO upd_sua_cp ;
          END ;

        IF NOT igs_en_elgbl_program.eval_unit_forced_type(
              p_person_id                 => x_person_id,
              p_load_calendar_type        => x_load_cal_type,
              p_load_cal_sequence_number  => x_load_sequence_number,
              p_uoo_id                    => x_uoo_id,
              p_course_cd                 => x_program_cd,
              p_course_version            => x_program_version,
              p_message                   => l_message,
              p_deny_warn                 => l_deny_warn_att_type ,
              p_enrollment_category       => l_enr_cat,
              p_comm_type                 => l_enr_comm,
              p_method_type               => l_enr_meth_type,
              p_calling_obj               => 'SCH_UPD' ) THEN

                x_return_status := 'DENY';
                x_message := l_message ;
                 RETURN;
        END IF ;
    END IF ;


    IF l_deny_warn_cross_fac ='DENY' AND  NOT igs_en_elgbl_program.eval_cross_validation (
                                         p_person_id                 =>  x_person_id,
                                         p_load_cal_type             =>  x_load_cal_type,
                                         p_load_ci_sequence_number   =>  x_load_sequence_number,
                                         p_uoo_id                    =>  x_uoo_id,
                                         p_course_cd                 =>  x_program_cd,
                                         p_program_version           =>  x_program_version,
                                         p_message                   =>  l_message,
                                         p_deny_warn                 =>  l_deny_warn_cross_fac,
                                         p_upd_cp                    =>  l_total_credit_points ,
                                         p_eligibility_step_type     => 'CROSS_FAC',
                                         p_calling_obj               => 'SCH_UPD' ) THEN

                    x_return_status := 'DENY';
                    x_message := l_message ;
                     RETURN;
    END IF ;


    IF l_deny_warn_cross_mod ='DENY' AND NOT igs_en_elgbl_program.eval_cross_validation (
                                     p_person_id                 =>  x_person_id,
                                     p_load_cal_type             =>  x_load_cal_type,
                                     p_load_ci_sequence_number   =>  x_load_sequence_number,
                                     p_uoo_id                    =>  x_uoo_id,
                                     p_course_cd                 =>  x_program_cd,
                                     p_program_version           =>  x_program_version,
                                     p_message                   =>  l_message,
                                     p_deny_warn                 =>  l_deny_warn_cross_mod,
                                     p_upd_cp                    =>  l_total_credit_points ,
                                     p_eligibility_step_type     => 'CROSS_MOD',
                                     p_calling_obj               => 'SCH_UPD' ) THEN

                x_return_status := 'DENY';
                x_message := l_message ;
                 RETURN;
    END IF ;

    IF l_deny_warn_cross_loc ='DENY' AND NOT igs_en_elgbl_program.eval_cross_validation (
                                     p_person_id                 =>  x_person_id,
                                     p_load_cal_type             =>  x_load_cal_type,
                                     p_load_ci_sequence_number   =>  x_load_sequence_number,
                                     p_uoo_id                    =>  x_uoo_id,
                                     p_course_cd                 =>  x_program_cd,
                                     p_program_version           =>  x_program_version,
                                     p_message                   =>  l_message,
                                     p_deny_warn                 =>  l_deny_warn_cross_loc,
                                     p_upd_cp                    =>  l_total_credit_points ,
                                     p_eligibility_step_type     => 'CROSS_LOC' ,
                                     p_calling_obj               => 'SCH_UPD') THEN

                x_return_status := 'DENY';
                x_message := l_message ;
                 RETURN;
    END IF ;

    IF  x_message IS NOT NULL THEN
        x_return_status := 'DENY' ;
    ELSE
           x_return_status := 'WARN';
    END IF;

    ROLLBACK TO upd_sua_cp ;
    RETURN;
END validate_upd_cp;

PROCEDURE blk_drop_units(
  p_uoo_id               IN NUMBER,
  p_person_id            IN NUMBER,
  p_person_type          IN VARCHAR2,
  p_load_cal_type        IN VARCHAR2,
  p_load_sequence_number IN NUMBER,
  p_acad_cal_type        IN VARCHAR2,
  p_acad_sequence_number IN NUMBER,
  p_program_cd           IN VARCHAR2,
  p_program_version      IN NUMBER ,
  p_dcnt_reason_cd       IN VARCHAR2,
  p_admin_unit_status    IN VARCHAR2,
  p_effective_date       IN DATE ,
  p_enrolment_cat        IN VARCHAR2,
  p_comm_type            IN VARCHAR2,
  p_enr_meth_type        IN VARCHAR2,
  p_total_credit_points  IN NUMBER,
  p_force_att_type       IN VARCHAR2,
  p_val_ovrrd_chk        IN VARCHAR2,
  p_ovrrd_drop           IN VARCHAR2,
  p_return_status        OUT NOCOPY BOOLEAN,
  p_message              OUT NOCOPY VARCHAR2,
   p_sub_unit             IN VARCHAR2
)AS
 ------------------------------------------------------------------
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
   --svanukur     04-dec-2003     passing the load calendar details to the procedure enrp_val_enr_encmb
  --                             instead of the academic calendar details as part of bug 3227399
  -- stutta       21-Feb-2006   Modified ref cursor c_ref_cur_inst for perf bug #5054297
  -------------------------------------------------------------------


l_deny_warn_min_cp     VARCHAR2(100) := NULL ;
l_deny_warn_coreq      VARCHAR2(100) := NULL ;
l_deny_warn_prereq     VARCHAR2(100) := NULL ;
l_deny_warn_att_type   VARCHAR2(100) := NULL ;
l_message              VARCHAR2(2000);
l_min_cp_message       VARCHAR2(2000);
l_att_type_message     VARCHAR2(2000) := NULL ;
l_coreq_failed         BOOLEAN := FALSE;
l_prereq_failed        BOOLEAN := FALSE;
l_all_units_for_drop   BOOLEAN := FALSE;
l_enr_cal_type         VARCHAR2(20);
l_enr_ci_seq           NUMBER(20);
l_enr_comm             VARCHAR2(2000);
l_return_status        VARCHAR2(10);
-- Added as part of Enrollment Eligibility and validations
l_eftsu_total          igs_en_su_attempt.override_eftsu%type;
l_total_credit_points  NUMBER;
l_credit_points        igs_en_su_attempt.override_enrolled_cp%TYPE := 0;
l_unit_version_number  igs_ps_unit_ver.VERSION_NUMBER%TYPE;
l_unit_cd              igs_ps_unit_ofr_opt.unit_cd%TYPE;
l_acad_start_dt        igs_ca_inst.start_dt%type;
l_acad_end_dt          igs_ca_inst.end_dt%type;
l_alternate_code       igs_ca_inst.alternate_code%type;


CURSOR cur_uoo_id (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT version_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;


CURSOR c_dcnt_rsn IS
 SELECT DISCONTINUATION_REASON_CD
 FROM igs_en_dcnt_reasoncd
 WHERE  NVL(closed_ind,'N')     ='N'
 AND  dflt_ind                  ='Y'
 AND dcnt_unit_ind              ='Y';


  lv_message_name VARCHAR2(2000);
  lv_message_name2 VARCHAR2(100);
  lv_return_type  VARCHAR2(2);
  l_req_unit_failed BOOLEAN;

 l_dcnt_reason_cd igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE;

  -- Cursor to get the coo_id of the student.
  CURSOR cur_coo_id IS
  SELECT coo_id coo_id
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id
  AND    course_cd = p_program_cd ;

  l_attendance_type_reach BOOLEAN := TRUE;
  l_cur_coo_id  cur_coo_id%ROWTYPE;
  l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att
  l_core_indicator_code         igs_en_su_attempt.core_indicator_code%TYPE;
  l_deny_warn                   VARCHAR2(10);

  --
  --  Cursor to find the Core Indicator associated with a Unit Attempt - ptandon, Enh Bug# 3052432
  --
 CURSOR cur_get_core_ind(cp_person_id          igs_en_su_attempt.person_id%TYPE,
                         cp_course_cd          igs_en_su_attempt.course_cd%TYPE,
                         cp_uoo_id             igs_en_su_attempt.uoo_id%TYPE)
 IS
    SELECT   core_indicator_code
    FROM     igs_en_su_attempt
    WHERE    person_id = cp_person_id
    AND      course_cd = cp_course_cd
    AND      uoo_id    = cp_uoo_id;

--
--  Cursor to find the Unit Code - ptandon, Enh Bug# 3052432
--
CURSOR cur_unit_cd (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT unit_cd
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

 TYPE c_ref_cursor IS REF CURSOR;
  c_ref_cur_inst c_ref_cursor;
  v_ref_cur_rec igs_en_su_attempt%ROWTYPE;
  l_person_id_found igs_en_su_attempt_all.person_id%TYPE;
 TYPE tDataBuff IS
 TABLE OF igs_en_su_attempt%ROWTYPE
 INDEX BY BINARY_INTEGER;

   lData tDataBuff;
   lDataEmpty tDataBuff;
   t1_idx BINARY_INTEGER := 0;


BEGIN --blk_drop_units
    OPEN cur_unit_cd(p_uoo_id);
     FETCH cur_unit_cd INTO l_unit_cd;
     CLOSE cur_unit_cd;
  -- Get the value of core indicator for unit attempt
  OPEN cur_get_core_ind(p_person_id,p_program_cd,p_uoo_id);
  FETCH cur_get_core_ind INTO l_core_indicator_code;
  CLOSE cur_get_core_ind;

  -- Get the value of core indicator for unit attempt
  IF l_core_indicator_code = 'CORE' THEN
    -- If the unit attempt being dropped is Core check whether user can
    -- drop/discontinue core unit attempt. If Yes then only proceed
    -- otherwise log an error and return from the procedure.
    IF igs_en_gen_015.eval_core_unit_drop
                       (
                        p_person_id,
                        p_program_cd,
                        p_uoo_id,
                        'DROP_CORE',
                        p_load_cal_type,
                        p_load_sequence_number,
                        l_deny_warn,
			p_enr_meth_type
                        ) = 'FALSE'
    THEN
     -- Get the Unit Code


      IF l_deny_warn = 'DENY' THEN
         -- Log the error and return
         p_message:='IGS_EN_CORE_DROP_DENY*'||l_unit_cd;
         p_return_status := FALSE;
         RETURN;
      ELSE
        p_message:='IGS_EN_CORE_DROP_WARN*'||l_unit_cd;
      END IF;
    END IF;
  END IF;

  lData := lDataEmpty; --Initializing the array
  l_enr_comm := p_comm_type;

  IF p_dcnt_reason_cd IS NULL THEN
    OPEN c_dcnt_rsn;
    FETCH c_dcnt_rsn INTO l_dcnt_reason_cd;
    CLOSE c_dcnt_rsn;
  END IF;
  IF l_enr_comm = 'BOTH' THEN
     l_enr_comm :='ALL';
  END IF;
  IF p_val_ovrrd_chk ='N' THEN
          l_message:= NULL;
          l_deny_warn_min_cp:= igs_ss_enr_details.get_notification(p_person_type            => p_person_type,
                                                                   p_enrollment_category    => p_enrolment_cat,
                                                                   p_comm_type              => l_enr_comm,
                                                                   p_enr_method_type        => p_enr_meth_type,
                                                                   p_step_group_type        => 'PROGRAM',
                                                                   p_step_type              => 'FMIN_CRDT',
                                                                   p_person_id              => p_person_id,
                                                                   p_message                => l_message) ;
            IF l_message IS NOT NULL THEN
                  p_message := l_message;
                  p_return_status := FALSE;
                  RETURN;
            END IF;
   END IF;
   IF p_val_ovrrd_chk ='N' THEN
           l_message:= NULL;
           l_deny_warn_att_type  := igs_ss_enr_details.get_notification(p_person_type            => p_person_type,
                                                                        p_enrollment_category    => p_enrolment_cat,
                                                                        p_comm_type              => l_enr_comm,
                                                                        p_enr_method_type        => p_enr_meth_type,
                                                                        p_step_group_type        => 'PROGRAM',
                                                                        p_step_type              => 'FATD_TYPE',
                                                                        p_person_id              => p_person_id,
                                                                        p_message                => l_message) ;
            IF l_message IS NOT NULL THEN
                  p_message := l_message;
                  p_return_status := FALSE;
                  RETURN;
            END IF;
            l_deny_warn_att_type :=p_force_att_type;
    END IF;
    IF p_val_ovrrd_chk = 'N' THEN
            l_message:= NULL;
            l_deny_warn_coreq  := igs_ss_enr_details.get_notification( p_person_type            => p_person_type,
                                                                       p_enrollment_category    => p_enrolment_cat,
                                                                       p_comm_type              => l_enr_comm,
                                                                       p_enr_method_type        => p_enr_meth_type,
                                                                       p_step_group_type        => 'UNIT',
                                                                       p_step_type              => 'COREQ',
                                                                       p_person_id              => p_person_id,
                                                                       p_message                => l_message) ;
            IF l_message IS NOT NULL THEN
                  p_message := l_message;
                  p_return_status := FALSE;
                  RETURN;
            END IF;
     END IF;
     IF p_val_ovrrd_chk ='N' THEN
            l_message:= NULL;
            l_deny_warn_prereq := igs_ss_enr_details.get_notification( p_person_type            => p_person_type,
                                                                       p_enrollment_category    => p_enrolment_cat,
                                                                       p_comm_type              => l_enr_comm,
                                                                       p_enr_method_type        => p_enr_meth_type,
                                                                       p_step_group_type        => 'UNIT',
                                                                       p_step_type              => 'PREREQ',
                                                                       p_person_id              => p_person_id,
                                                                       p_message                => l_message ) ;
            IF l_message IS NOT NULL THEN
                  p_message := l_message;
                  p_return_status := FALSE;
                  RETURN;
            END IF;
     END IF;
  --Decode the concatenated string and check that all units are not selected,
  --in which case, just delete all units w/o checking cp or coreq requirements.

  OPEN c_ref_cur_inst FOR 'SELECT DISTINCT U.PERSON_ID FROM IGS_EN_SU_ATTEMPT U, igs_ca_load_to_teach_v  WHERE person_id =:1 AND course_cd = :2 '||
                          'AND unit_attempt_status IN  (''ENROLLED'',''INVALID'',''WAITLISTED'') '||
                          'AND cal_type = teach_cal_type AND ci_sequence_number= teach_ci_sequence_number '||
                          'AND load_cal_type = :3 AND load_ci_sequence_number =:4 '||
                          'AND uoo_id <> :5 '
                          USING p_person_id, p_program_cd, p_load_cal_type, p_load_sequence_number,p_uoo_id ;
  FETCH c_ref_cur_inst INTO l_person_id_found;
  IF c_ref_cur_inst%NOTFOUND THEN
      l_all_units_for_drop := TRUE;
  END IF;
  ClOSE c_ref_cur_inst;
  IF l_all_units_for_drop AND p_ovrrd_drop ='N' THEN
    --Call enrp_dropall_units
    igs_en_gen_004.enrp_dropall_unit( p_person_id          => p_person_id,
                                      p_cal_type           => p_load_cal_type,
                                      p_ci_sequence_number => p_load_sequence_number,
                                      p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
                                      p_admin_unit_sta     => p_admin_unit_status,
                                      p_effective_date     => p_effective_date,
                                      p_program_cd         => p_program_cd,
                                      p_uoo_id             => NULL,
                                      p_sub_unit           => p_sub_unit);

  ELSE

    --Only some of the units have been selected for drop. so, loop thru them and drop them
      l_credit_points := 0;
        OPEN cur_uoo_id(p_uoo_id);
        FETCH cur_uoo_id INTO l_unit_version_number;
        CLOSE cur_uoo_id ;
        IF p_ovrrd_drop = 'N' THEN
            -- Check for rule failure prior to dropping the unit, so that such failures can be ignored.
            -- The list of failed uoo_ids is stored in package variables pkg_coreq_failed_uooids, pkg_prereq_failed_uooids
              OPEN   c_ref_cur_inst FOR 'SELECT U.* FROM  IGS_EN_SU_ATTEMPT U   WHERE person_id = :1  '||
                                        'AND unit_attempt_status IN  (''ENROLLED'',''INVALID'') AND ' ||
                                        '  uoo_id <> :2'
                                    USING p_person_id, p_uoo_id;


              LOOP

                FETCH c_ref_cur_inst INTO v_ref_cur_rec ;

                EXIT WHEN c_ref_cur_inst%NOTFOUND;

                IF NOT IGS_EN_ELGBL_UNIT.eval_coreq( --Do a coreq check only if l_deny_warn_coreq is defined
                      p_person_id                =>  p_person_id,
                      p_load_cal_type            =>  p_load_cal_type,
                      p_load_sequence_number     =>  p_load_sequence_number,
                      p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                      p_course_cd                =>  p_program_cd,
                      p_course_version           =>  p_program_version,
                      p_message                  =>  l_message,
                      p_deny_warn                =>  l_deny_warn_coreq,
                      p_calling_obj              =>  'JOB') THEN

                    -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
                    -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
                         pkg_coreq_failed_uooids:= pkg_coreq_failed_uooids  ||','|| TO_CHAR(v_ref_cur_rec.uoo_id);



                ELSE
                   -- Since the coreq rule has passed, store these passed uoo_ids
                   -- into a temp table so that the prereq check can be run for these uoo_ids
                   -- instead of opening the cursor again

                   lData(t1_idx).uoo_id := v_ref_cur_rec.uoo_id;
                   lData(t1_idx).unit_cd := v_ref_cur_rec.unit_cd;
                   t1_idx        :=t1_idx+1;

                END IF;
              END LOOP;
              ClOSE c_ref_cur_inst;

              -- Instead of opening the cursor again, we are storing the passed uoo_ids
              -- values into a Table
                -- Check whether records exist in the temparary table,lDATA.
                IF lData.COUNT > 0 THEN
                  FOR i IN lData.FIRST ..  lData.LAST  LOOP
                    IF NOT IGS_EN_ELGBL_UNIT.eval_prereq( --Do a coreq check only if l_deny_warn_prereq is defined
                      p_person_id                =>  p_person_id,
                      p_load_cal_type            =>  p_load_cal_type,
                      p_load_sequence_number     =>  p_load_sequence_number,
                      p_uoo_id                   =>  lData(i).uoo_id,
                      p_course_cd                =>  p_program_cd,
                      p_course_version           =>  p_program_version,
                      p_message                  =>  l_message,
                      p_deny_warn                =>  l_deny_warn_prereq,
                      p_calling_obj              =>  'JOB') THEN

                    -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
                    -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
                       pkg_prereq_failed_uooids     := pkg_prereq_failed_uooids  ||','|| TO_CHAR(lData(i).uoo_id);


                    END IF;
                  END LOOP;
                END IF;
                   t1_idx := 0;
        END IF;

        IF l_deny_warn_min_cp  IS NOT NULL THEN  -- Min CP validation step is defined

          -- A call to igs_en_prc_load.enrp_clc_eftsu_total as part of- Enrollment Eligibility and validations .
          -- The Total enrolled CP of the student has to be determined before the unit is dropped(l_total_credit_points) .
          -- The unit is then dropped , and eval_min_cp is called with the value of l_total_enrolled_cp.
          -- The value of l_total_enrolled_cp is essential to determine if the Min Credit Points is already reached
          -- by the student before that Unit is dropped.
          IF p_ovrrd_drop = 'N' THEN
                  --Call enrp_dropall_units
                  -- Dropping the unit before Min CP check, moved to here as part of bug 2401891
                  igs_en_gen_004.enrp_dropall_unit(p_person_id          => p_person_id,
                                                   p_cal_type           => p_load_cal_type,
                                                   p_ci_sequence_number => p_load_sequence_number,
                                                   p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
                                                   p_admin_unit_sta     => p_admin_unit_status,
                                                   p_effective_date     => p_effective_date,
                                                   p_program_cd         => p_program_cd,
                                                   p_uoo_id             => p_uoo_id,
                                                   p_sub_unit           =>p_sub_unit);
          END IF;
          l_total_credit_points := p_total_credit_points;
          IF igs_en_elgbl_program.eval_min_cp(p_person_id                 =>  p_person_id,
                                              p_load_calendar_type        =>  p_load_cal_type,
                                              p_load_cal_sequence_number  =>  p_load_sequence_number,
                                              p_uoo_id                    =>  p_uoo_id,
                                              p_program_cd                =>  p_program_cd,
                                              p_program_version           =>  p_program_version,
                                              p_message                   =>  l_min_cp_message,
                                              p_deny_warn                 =>  l_deny_warn_min_cp,
                                              p_credit_points             =>  l_credit_points ,
                                              p_enrollment_category       =>  p_enrolment_cat,
                                              p_comm_type                 =>  l_enr_comm,
                                              p_method_type               =>  p_enr_meth_type,
                                              p_min_credit_point          =>  l_total_credit_points,
                                              p_calling_obj               =>  'JOB') THEN
                     -- validate the holds when droping an unit, pmarada, 2385096

                     IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb( p_person_id,
                                                                 p_program_cd ,
                                                                 p_load_cal_type,
                                                                 p_load_sequence_number,
                                                                 lv_message_name,
                                                                 lv_message_name2,
                                                                 lv_return_type,
                                                                 NULL -- default value, it will be calculated internally based on the census date
                                                                 )   THEN
                               IF lv_message_name2 = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
                                  lv_message_name2 := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
                               END IF;
                               IF lv_message_name = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
                                  lv_message_name := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
                               END IF;
                              IF lv_message_name IS NOT NULL AND INSTR(NVL(p_message,' '),lv_message_name) = 0 THEN
                                  p_message := p_message||lv_message_name||';';
                              END IF;
                              IF lv_message_name2 IS NOT NULL AND INSTR(NVL(p_message,' '),lv_message_name2) = 0 THEN
                                  p_message := p_message||lv_message_name2||';';
                              END IF;
                              p_return_status := FALSE;
                              RETURN;
                    END IF;
          ELSE
                    IF l_min_cp_message ='IGS_SS_DENY_MIN_CP_REACHED' THEN
                       p_return_status := FALSE;
                       p_message := p_message||l_min_cp_message||';';
                       RETURN;
                    ELSE
                       p_message := p_message||l_min_cp_message||';';
                    END IF;
         END IF; --igs_en_elgbl_program.eval_min_cp
    ELSE
          IF p_ovrrd_drop ='N' THEN
             --Call enrp_dropall_units
             igs_en_gen_004.enrp_dropall_unit(
               p_person_id          => p_person_id,
               p_cal_type           => p_load_cal_type,
               p_ci_sequence_number => p_load_sequence_number,
               p_dcnt_reason_cd     => NVL(p_dcnt_reason_cd,l_dcnt_reason_cd),
               p_admin_unit_sta     => p_admin_unit_status,
               p_effective_date     => p_effective_date,
               p_program_cd         => p_program_cd,
               p_uoo_id             => p_uoo_id,
               p_sub_unit           =>p_sub_unit
               );
          END IF;
          -- validate the holds when droping an unit, pmarada, 2385096

          IF p_ovrrd_drop ='N' THEN
                  IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id,
                                                             p_program_cd ,
                                                             p_load_cal_type,
                                                             p_load_sequence_number,
                                                             lv_message_name,
                                                             lv_message_name2,
                                                             lv_return_type,
                                                             NULL -- default value, it will be calculated internally based on the census date
                                                             )   THEN
                       IF lv_message_name2 = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
                          lv_message_name2 := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
                       END IF;
                       IF lv_message_name = 'IGS_EN_PRSN_NOTENR_REQUIRE' THEN
                          lv_message_name := 'IGS_EN_REQ_UNIT_CANNOT_DROP';
                       END IF;
                      IF lv_message_name IS NOT NULL AND INSTR(NVL(p_message,' '),lv_message_name) = 0 THEN
                          p_message := p_message||lv_message_name||';';
                      END IF;
                      IF lv_message_name2 IS NOT NULL AND INSTR(NVL(p_message,' '),lv_message_name2) = 0 THEN
                          p_message := p_message||lv_message_name2||';';
                      END IF;
                      p_return_status := FALSE;
                      RETURN;
                  END IF;
          END IF;
      END IF; --l_deny_warn_min_cp
      -- If the Att Type validation step has been setup , continue validating.
      IF  l_deny_warn_att_type IS NOT NULL THEN
            IF NOT (igs_en_elgbl_program.eval_unit_forced_type(p_person_id                 => p_person_id,
                                                               p_load_calendar_type        => p_load_cal_type,
                                                               p_load_cal_sequence_number  => p_load_sequence_number,
                                                               p_uoo_id                    => p_uoo_id          ,
                                                               p_course_cd                 => p_program_cd,
                                                               p_course_version            => p_program_version,
                                                               p_message                   => l_att_type_message,
                                                               p_deny_warn                 => l_deny_warn_att_type ,
                                                               p_enrollment_category       => p_enrolment_cat,
                                                               p_comm_type                 => l_enr_comm,
                                                               p_method_type               => p_enr_meth_type,
                                                               p_calling_obj               => 'JOB') ) THEN
                     IF l_att_type_message ='IGS_SS_DENY_ATTYPE_CHK' THEN
                        p_return_status := FALSE;
                        p_message := p_message||l_att_type_message||';';
                        RETURN;
                     ELSE
                        p_message := p_message||l_att_type_message||';';
                     END IF;
                END IF ;
      END IF; --l_deny_warn_att_type IS NOT NULL
      -- Only if min_cp validation passed, need to check for coreq validation
      l_message:= NULL;
      OPEN   c_ref_cur_inst FOR 'SELECT U.* FROM  IGS_EN_SU_ATTEMPT U   WHERE person_id = :1  '||
                                'AND unit_attempt_status IN  (''ENROLLED'',''INVALID'') AND ' ||
                                ' uoo_id <> :2'
                            USING p_person_id, p_uoo_id;
      LOOP
        FETCH c_ref_cur_inst INTO v_ref_cur_rec ;
        EXIT WHEN c_ref_cur_inst%NOTFOUND;
        IF l_deny_warn_coreq IS NOT NULL THEN
           IF NOT igs_en_elgbl_unit.eval_coreq( --Do a coreq check only if l_deny_warn_coreq is defined
                                              p_person_id                =>  p_person_id,
                                              p_load_cal_type            =>  p_load_cal_type,
                                              p_load_sequence_number     =>  p_load_sequence_number,
                                              p_uoo_id                   =>  v_ref_cur_rec.uoo_id,
                                              p_course_cd                =>  p_program_cd,
                                              p_course_version           =>  p_program_version,
                                              p_message                  =>  l_message,
                                              p_deny_warn                =>  l_deny_warn_coreq,
                                              p_calling_obj              =>  'JOB') THEN
                -- if the rule has not failed before the drop, only then consider coreq rule to have failed.
                IF pkg_coreq_failed_uooids IS NULL OR INSTR(pkg_coreq_failed_uooids,v_ref_cur_rec.uoo_id ) = 0 THEN
                    l_coreq_failed := TRUE;
                END IF;

           ELSE
                -- Since the coreq rule has passed, store these passed uoo_ids
                -- into a temp table so that the prereq check can be run for these uoo_ids
                -- instead of opening the cursor again
                lData(t1_idx).uoo_id  :=v_ref_cur_rec.uoo_id;
                lData(t1_idx).unit_cd :=v_ref_cur_rec.unit_cd;
                t1_idx                :=t1_idx+1;
           END IF;

        END IF;
      END LOOP;
      ClOSE c_ref_cur_inst;
      IF l_coreq_failed THEN
         IF l_deny_warn_coreq ='DENY' THEN
            p_return_status := FALSE;
            p_message := p_message||'IGS_EN_COREQ_DENY*'||l_unit_cd||';';
            RETURN;
         ELSE
            p_message := p_message||'IGS_EN_COREQ_WARN*'||l_unit_cd||';';
         END IF;
      END IF; --l_coreq_failed

        -- Run prereq check since coreq has passed
        -- Check whether records exist in the temparary table,lDATA.
        l_message := NULL;
        IF lData.COUNT > 0 AND l_deny_warn_prereq IS NOT NULL THEN
          FOR i IN lData.FIRST ..  lData.LAST  LOOP
            IF NOT IGS_EN_ELGBL_UNIT.eval_prereq( --Do a coreq check only if l_deny_warn_prereq is defined
                                                 p_person_id                =>  p_person_id,
                                                 p_load_cal_type            =>  p_load_cal_type,
                                                 p_load_sequence_number     =>  p_load_sequence_number,
                                                 p_uoo_id                   =>  lData(i).uoo_id,
                                                 p_course_cd                =>  p_program_cd,
                                                 p_course_version           =>  p_program_version,
                                                 p_message                  =>  l_message,
                                                 p_deny_warn                =>  l_deny_warn_prereq,
                                                 p_calling_obj              =>  'JOB') THEN
              -- If the Unit code has already been concatenated,it should not be repeated again. This condition will arise when the student is
              -- enrolled in the same unit in 2 diff programs. Pre-req and Co-req validate across Programs.
              -- if the rule has not failed before the drop, only then consider coreq rule to have failed.
                IF pkg_prereq_failed_uooids IS NULL OR INSTR(pkg_prereq_failed_uooids,TO_CHAR(lData(i).uoo_id) ) = 0 THEN
                    l_prereq_failed := TRUE;
                END IF;

            END IF;
          END LOOP;
        END IF; --lData.COUNT > 0
        IF l_prereq_failed THEN
           IF l_deny_warn_prereq ='DENY' THEN
              p_return_status := FALSE;
              p_message := p_message||'IGS_EN_PREREQ_DENY*'||l_unit_cd||';';
              RETURN;
           ELSE

              p_message := p_message||'IGS_EN_PREREQ_WARN*'||l_unit_cd||';';
           END IF;
        END IF; --l_prereq_failed
  END IF; -- end of l_all_units_for_drop comparison
  p_return_status := TRUE;
END blk_drop_units;

PROCEDURE enrp_switch_core_section(
  p_person_id             IN NUMBER,
  p_program_cd            IN VARCHAR2,
  p_source_uoo_id         IN NUMBER,
  p_dest_uoo_id           IN NUMBER,
  p_session_id            IN NUMBER,
  p_cal_type              IN VARCHAR2,
  p_ci_sequence_number    IN NUMBER,
  p_audit_requested       IN VARCHAR2,
  p_core_indicator_code   IN VARCHAR2,
  p_waitlist_ind          IN VARCHAR2,
  p_return_status         OUT NOCOPY VARCHAR2,
  p_message_name          OUT NOCOPY VARCHAR2)

  ------------------------------------------------------------------
  --Created by  : Parul Tandon, Oracle IDC
  --Date created: 01-OCT-2003
  --
  --Purpose: This procedure is to switch the core unit sections selected,
  -- i.e. drop the source unit attempt and then add the destination unit section to cart.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

AS

  --
  --  Cursor to find the Rowid associated with a Unit Attempt
  --
  CURSOR cur_get_source_rowid(cp_person_id          igs_en_su_attempt.person_id%TYPE,
                              cp_course_cd          igs_en_su_attempt.course_cd%TYPE,
                              cp_uoo_id             igs_en_su_attempt.uoo_id%TYPE)
  IS
    SELECT   rowid
    FROM     igs_en_su_attempt
    WHERE    person_id = cp_person_id
    AND      course_cd = cp_course_cd
    AND      uoo_id    = cp_uoo_id;

  --
  --  Cursor to find the Person Number associated with a Person Id
  --
  CURSOR cur_get_person_num(cp_person_id          igs_pe_person.person_id%TYPE)
  IS
    SELECT   party_number
    FROM     hz_parties
    WHERE    party_id = cp_person_id;



l_source_rowid          VARCHAR2(20);
l_person_number         igs_pe_person.person_number%TYPE;
l_enr_method            igs_en_cat_prc_step.enr_method_type%TYPE;
l_message               VARCHAR2(100);
l_return_status         VARCHAR2(10);

BEGIN
    -- Get the Rowid of Source Unit Attempt
    OPEN cur_get_source_rowid(p_person_id,p_program_cd,p_source_uoo_id);
    FETCH cur_get_source_rowid INTO l_source_rowid;
    CLOSE cur_get_source_rowid;

    -- Delete the source unit attempt
    IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW(l_source_rowid);

    -- Get the Person Number
    OPEN cur_get_person_num(p_person_id);
    FETCH cur_get_person_num INTO l_person_number;
    CLOSE cur_get_person_num;


    --- Get the enrollment method
    igs_en_gen_017.enrp_get_enr_method(l_enr_method,l_message,l_return_status);

    -- Add Destination Unit Section to Cart
    insert_into_enr_worksheet(
                p_person_number         =>  l_person_number,
                p_course_cd             =>  p_program_cd,
                p_uoo_id                =>  p_dest_uoo_id,
                p_waitlist_ind          =>  p_waitlist_ind,
                p_session_id            =>  p_session_id,
                p_return_status         =>  p_return_status,
                p_message               =>  p_message_name,
                p_cal_type              =>  p_cal_type,
                p_ci_sequence_number    =>  p_ci_sequence_number,
                p_audit_requested       =>  p_audit_requested,
                p_enr_method            =>  l_enr_method,
                p_core_indicator_code   =>  p_core_indicator_code,
                p_calling_obj           =>  'JOB');

END enrp_switch_core_section;

--
PROCEDURE drop_notif_variable(
  p_reason                IN VARCHAR2,
  p_source_of_drop        IN VARCHAR2) AS
/*
  ||  Created By : kkillams
  ||  Created On : 27-SEP-2002
  ||  Purpose : This procedure is created for self service application to set the
  ||            student unit attempt package variables
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
*/
BEGIN
    igs_en_su_attempt_pkg.pkg_reason := NULL;
     igs_en_su_attempt_pkg.pkg_source_of_drop :=NULL;
     igs_en_su_attempt_pkg.pkg_reason := p_reason;
     igs_en_su_attempt_pkg.pkg_source_of_drop := p_source_of_drop;
     NULL;
END drop_notif_variable;

PROCEDURE ENRP_CHK_DEL_SUB_UNITS(
p_person_id IN NUMBER,
p_course_cd IN VARCHAR2,
p_load_cal_type IN VARCHAR2,
p_load_ci_seq_num IN NUMBER,
p_selected_uoo_ids IN VARCHAR2,
p_ret_all_uoo_ids OUT NOCOPY VARCHAR2,
p_ret_sub_uoo_ids OUT NOCOPY VARCHAR2,
p_ret_nonsub_uoo_ids OUT NOCOPY VARCHAR2,
p_delete_flag IN VARCHAR2 DEFAULT 'N'
) AS

------------------------------------------------------------------
  --Created by  : Satya Vanukuri, Oracle IDC
  --Date created: 10-OCT-2003
  --
  --Purpose: This procedure reorders the units selected for drop such that the subordinate
  -- units are processed before the superior units
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

TYPE t_uoo_ref_cur IS REF CURSOR;
c_sup_uoo_cur_inst t_uoo_ref_cur;
c_sub_sua_cur_inst t_uoo_ref_cur;

v_select_stmt VARCHAR2(2000);
v_sup_uoo_id  IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE;
v_sup_unit_cd     IGS_PS_UNIT_OFR_OPT.UNIT_CD%TYPE;

v_uoo_id      IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE;
v_row_id      VARCHAR2(25);


CURSOR c_plan_status IS
 SELECT plan_sht_status
 FROM igs_en_spa_terms
 WHERE person_id = p_person_id
 AND  program_cd =  p_course_cd
 AND  term_cal_type =  p_load_cal_type
 AND  term_sequence_number =  p_load_ci_seq_num
 AND plan_sht_status NOT IN ('SKIP' ,'SUB_CART' , 'NONE');

 l_plan_sht_status     igs_en_spa_terms.plan_sht_status%TYPE;

PROCEDURE L_UPD_DEL_SUA(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER) AS
--local procedure to update the unit attempt to drop
--fetch the unit attempts for the student and program  in context
CURSOR c_sua_rec IS
 SELECT sua.rowid,sua.* from igs_en_su_attempt sua
 WHERE person_id = p_person_id
 AND course_cd = p_course_cd
 AND uoo_id = p_uoo_id;


BEGIN

   FOR v_sua_rec IN c_sua_rec LOOP
   --phisically delelte if sua status is "unconfirm"
          IF v_sua_rec.unit_attempt_status = 'UNCONFIRM' THEN
            igs_en_su_attempt_pkg.delete_row(v_sua_rec.row_id);

   --update to dropped if status is invalid

          ELSIF v_sua_rec.unit_attempt_status = 'INVALID' THEN

            IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT(
                X_ROWID => V_SUA_REC.ROW_ID,
                   X_PERSON_ID => V_SUA_REC.PERSON_ID,
                   X_COURSE_CD =>V_SUA_REC.COURSE_CD ,
                   X_UNIT_CD =>V_SUA_REC.UNIT_CD,
                   X_CAL_TYPE =>V_SUA_REC.CAL_TYPE,
                   X_CI_SEQUENCE_NUMBER => V_SUA_REC.CI_SEQUENCE_NUMBER,
                   X_VERSION_NUMBER =>V_SUA_REC.VERSION_NUMBER ,
                   X_LOCATION_CD =>V_SUA_REC.LOCATION_CD,
                   X_UNIT_CLASS =>V_SUA_REC.UNIT_CLASS,
                   X_CI_START_DT =>V_SUA_REC.CI_START_DT,
                   X_CI_END_DT => V_SUA_REC.CI_END_DT,
                   X_UOO_ID =>V_SUA_REC.UOO_ID,
                   X_ENROLLED_DT =>V_SUA_REC.ENROLLED_DT ,
                   X_UNIT_ATTEMPT_STATUS => 'DROPPED',
                   X_ADMINISTRATIVE_UNIT_STATUS =>V_SUA_REC.ADMINISTRATIVE_UNIT_STATUS,
                   X_DISCONTINUED_DT =>V_SUA_REC.DISCONTINUED_DT,
                   X_RULE_WAIVED_DT =>V_SUA_REC.RULE_WAIVED_DT,
                   X_RULE_WAIVED_PERSON_ID =>V_SUA_REC.RULE_WAIVED_PERSON_ID,
                   X_NO_ASSESSMENT_IND =>V_SUA_REC.NO_ASSESSMENT_IND,
                   X_SUP_UNIT_CD =>V_SUA_REC.SUP_UNIT_CD,
                   X_SUP_VERSION_NUMBER =>V_SUA_REC.SUP_VERSION_NUMBER,
                   X_EXAM_LOCATION_CD =>V_SUA_REC.EXAM_LOCATION_CD,
                   X_ALTERNATIVE_TITLE =>V_SUA_REC.ALTERNATIVE_TITLE,
                   X_OVERRIDE_ENROLLED_CP =>V_SUA_REC.OVERRIDE_ENROLLED_CP,
                   X_OVERRIDE_EFTSU =>V_SUA_REC.OVERRIDE_EFTSU,
                   X_OVERRIDE_ACHIEVABLE_CP =>V_SUA_REC.OVERRIDE_ACHIEVABLE_CP,
                   X_OVERRIDE_OUTCOME_DUE_DT =>V_SUA_REC.OVERRIDE_OUTCOME_DUE_DT,
                   X_OVERRIDE_CREDIT_REASON =>V_SUA_REC.OVERRIDE_CREDIT_REASON,
                   X_ADMINISTRATIVE_PRIORITY =>V_SUA_REC.ADMINISTRATIVE_PRIORITY ,
                   X_WAITLIST_DT =>V_SUA_REC.WAITLIST_DT,
                   X_DCNT_REASON_CD =>V_SUA_REC.DCNT_REASON_CD,
                   X_MODE =>'R',
                   X_GS_VERSION_NUMBER =>V_SUA_REC.GS_VERSION_NUMBER,
                   X_ENR_METHOD_TYPE =>V_SUA_REC.ENR_METHOD_TYPE,
                   X_FAILED_UNIT_RULE =>V_SUA_REC.FAILED_UNIT_RULE,
                   X_CART      =>   V_SUA_REC.CART        ,
                   X_RSV_SEAT_EXT_ID  =>V_SUA_REC.RSV_SEAT_EXT_ID ,
                   X_ORG_UNIT_CD  =>V_SUA_REC.ORG_UNIT_CD ,
                   X_GRADING_SCHEMA_CODE  =>V_SUA_REC.GRADING_SCHEMA_CODE,
                   X_subtitle =>V_SUA_REC.subtitle,
                   x_session_id  =>V_SUA_REC.session_id ,
                   X_deg_aud_detail_id   =>V_SUA_REC.deg_aud_detail_id,
                   x_student_career_transcript  =>V_SUA_REC.student_career_transcript,
                   x_student_career_statistics  =>V_SUA_REC.student_career_statistics,
                   X_WAITLIST_MANUAL_IND  =>V_SUA_REC.WAITLIST_MANUAL_IND ,
                   X_ATTRIBUTE_CATEGORY  =>V_SUA_REC.ATTRIBUTE_CATEGORY,
                   X_ATTRIBUTE1  =>V_SUA_REC.ATTRIBUTE1,
                   X_ATTRIBUTE2  =>V_SUA_REC.ATTRIBUTE2,
                   X_ATTRIBUTE3 =>V_SUA_REC.ATTRIBUTE3,
                   X_ATTRIBUTE4 =>V_SUA_REC.ATTRIBUTE4,
                   X_ATTRIBUTE5 =>V_SUA_REC.ATTRIBUTE5,
                   X_ATTRIBUTE6 =>V_SUA_REC.ATTRIBUTE6,
                   X_ATTRIBUTE7 =>V_SUA_REC.ATTRIBUTE7,
                   X_ATTRIBUTE8 =>V_SUA_REC.ATTRIBUTE8,
                   X_ATTRIBUTE9 =>V_SUA_REC.ATTRIBUTE9,
                   X_ATTRIBUTE10 =>V_SUA_REC.ATTRIBUTE10,
                   X_ATTRIBUTE11 =>V_SUA_REC.ATTRIBUTE11,
                   X_ATTRIBUTE12 =>V_SUA_REC.ATTRIBUTE12,
                   X_ATTRIBUTE13 =>V_SUA_REC.ATTRIBUTE13,
                   X_ATTRIBUTE14 =>V_SUA_REC.ATTRIBUTE14,
                   X_ATTRIBUTE15 =>V_SUA_REC.ATTRIBUTE15,
                   X_ATTRIBUTE16 =>V_SUA_REC.ATTRIBUTE16,
                   X_ATTRIBUTE17 =>V_SUA_REC.ATTRIBUTE17,
                   X_ATTRIBUTE18 =>V_SUA_REC.ATTRIBUTE18,
                   X_ATTRIBUTE19 =>V_SUA_REC.ATTRIBUTE19,
                   X_ATTRIBUTE20 =>V_SUA_REC.ATTRIBUTE20,
                  X_WLST_PRIORITY_WEIGHT_NUM =>V_SUA_REC.WLST_PRIORITY_WEIGHT_NUM,
                  X_WLST_PREFERENCE_WEIGHT_NUM =>V_SUA_REC.WLST_PREFERENCE_WEIGHT_NUM

            );


          ELSE
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_BAD_SUB');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
    END LOOP;
END;


PROCEDURE delete_plansheet_subunit(
           P_PERSON_ID IN NUMBER,
           P_COURSE_CD IN VARCHAR2,
           P_UOOID IN NUMBER
           ) AS

     CURSOR cur_plan_unit IS
            SELECT pl.rowid, pl.term_cal_type, pl.term_ci_sequence_number,pl.uoo_id
            FROM igs_en_plan_units pl
            WHERE pl.person_id = p_person_id
            AND   pl.course_cd = p_course_cd
            AND   EXISTS ( SELECT 'X'
                          FROM IGS_PS_UNIT_OFR_OPT UOO
                           WHERE UOO.SUP_UOO_ID = P_UOOID
                               AND UOO.RELATION_TYPE = 'SUBORDINATE'
                              AND UOO.UOO_ID = pl.UOO_ID)

             ORDER BY pl.SUP_Uoo_id;

      cur_plan_unit_rec cur_plan_unit%ROWTYPE;

    CURSOR cur_permission_unit(cp_uoo_id IN NUMBER) IS
            SELECT spl.spl_perm_request_id
            FROM igs_en_spl_perm spl
            WHERE   spl.student_person_id= p_person_id
            AND      spl.uoo_id = cp_uoo_id
            AND    spl.transaction_type <> 'WITHDRAWN';

     cur_permission_unit_rec cur_permission_unit%ROWTYPE;
    l_enc_message_name VARCHAR2(2000);
    l_app_short_name VARCHAR2(10);
    l_msg_index NUMBER;

BEGIN
      FOR cur_plan_unit_rec IN cur_plan_unit  LOOP
        --call the TBH for the planning sheet to delete the unit
        --by passing the rowid
        igs_en_plan_units_pkg.delete_row (x_rowid => cur_plan_unit_rec.rowid);

            --call drop_permission_unit to drop the permission unit

        FOR cur_permission_unit_rec IN cur_permission_unit(cur_plan_unit_rec.uoo_id)  LOOP
                 igs_ss_en_wrappers.remove_permission_unit(cur_permission_unit_rec.spl_perm_request_id,cur_plan_unit_rec.term_cal_type,cur_plan_unit_rec.term_ci_sequence_number, p_course_cd);
        END LOOP;
     END LOOP;
END  ;



BEGIN

      p_ret_all_uoo_ids := NULL;
      p_ret_sub_uoo_ids := NULL;
      p_ret_nonsub_uoo_ids := NULL;

      --dynamic sql to select all the units that need to be dropped for the student in context
      --the records are ordered by the  superior unit code so that the
      --subordinate units are returned first since a superior unit will have a null value for SUP_UNIT_CD.

      v_select_stmt := ' SELECT SUA.UOO_ID, SUA.SUP_UNIT_CD '
                    || ' FROM IGS_EN_SU_ATTEMPT SUA '
                    || ' WHERE SUA.PERSON_ID = :1 '
                    || ' AND SUA.COURSE_CD = :2 '
                    || ' AND SUA.UNIT_ATTEMPT_STATUS NOT IN (''DROPPED'',''DISCONTIN'',''COMPLETED'') '
                    || ' AND (( SUA.UOO_ID IN (' || P_SELECTED_UOO_IDS || ') )'
                    || '        OR ( EXISTS ( SELECT ''X'' '
                    || '             FROM IGS_PS_UNIT_OFR_OPT UOO'
                    || '             WHERE UOO.SUP_UOO_ID IN (' || P_SELECTED_UOO_IDS || ')'
                    || '             AND UOO.RELATION_TYPE = ''SUBORDINATE'' '
                    || '             AND UOO.UOO_ID = SUA.UOO_ID ) ) ) '
                    || ' ORDER BY SUA.SUP_UNIT_CD ';

       IF P_SELECTED_UOO_IDS IS NULL THEN
        RETURN;
       END IF;

      OPEN c_sub_sua_cur_inst FOR v_select_stmt USING p_person_id, p_course_cd;

      LOOP
        v_sup_unit_cd := NULL;
        v_uoo_id := NULL;
        FETCH c_sub_sua_cur_inst INTO v_uoo_id, v_sup_unit_cd;
        EXIT WHEN c_sub_sua_cur_inst%NOTFOUND;

        --concatenate the uoo_ids to string that contains all the uooids with superiors first.
        IF p_ret_all_uoo_ids IS NULL THEN
          p_ret_all_uoo_ids :=  TO_CHAR(v_uoo_id);
        ELSE
          p_ret_all_uoo_ids :=  p_ret_all_uoo_ids || ',' || TO_CHAR(v_uoo_id);
        END IF;

        --append all subordinate units ; v_sup_unit_cd NOT NULL implies unit is subordinate
        IF v_sup_unit_cd IS NOT NULL THEN
                IF p_ret_sub_uoo_ids IS NULL THEN
                   p_ret_sub_uoo_ids :=  TO_CHAR(V_UOO_ID);
                  ELSE
                    p_ret_sub_uoo_ids :=  p_ret_sub_uoo_ids || ',' || TO_CHAR(v_uoo_id);
                END IF;
        ELSE
         --append nonsubordinate units
                  IF p_ret_nonsub_uoo_ids IS NULL THEN
                  p_ret_nonsub_uoo_ids :=  TO_CHAR(v_uoo_id);
                 ELSE
                   p_ret_nonsub_uoo_ids :=  p_ret_nonsub_uoo_ids || ',' || TO_CHAR(v_uoo_id);
                 END IF;
        END IF;

--if delete_flag is set, then delete/drop the unit attmept
        IF NVL(p_delete_flag,'N') = 'Y' THEN

          L_UPD_DEL_SUA(
            p_person_id,
            p_course_cd,
            v_uoo_id);

          OPEN c_plan_status;
          FETCH c_plan_status INTO l_plan_sht_status;
          IF  c_plan_status%FOUND THEN
               delete_plansheet_subunit(
                                      p_person_id  ,
                                      p_course_cd  ,
                                      v_uoo_id ) ;
          END IF;
          CLOSE c_plan_status;
        END IF;

      END LOOP;
      CLOSE c_sub_sua_cur_inst;

END enrp_chk_del_sub_units;

--To Get the UNIT status

FUNCTION get_unit_int_status(
             x_person_id IN NUMBER,
             x_person_type IN VARCHAR2,
             x_load_cal_type IN VARCHAR2,
             x_load_sequence_number IN NUMBER,
             x_program_cd IN VARCHAR2,
             x_message OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2
           )  RETURN VARCHAR2
                   AS


  l_deny_warn_val   VARCHAR2(10) := NULL ;
  l_enr_meth_type igs_en_method_type.enr_method_type%TYPE;
  l_enr_cal_type VARCHAR2(20);
  l_enr_ci_seq NUMBER(20);
  l_enr_cat VARCHAR2(20);
  l_enr_comm VARCHAR2(2000);

  l_dummy NUMBER;
  l_acad_cal_type igs_ca_inst.cal_type%type;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%type;
  l_acad_start_dt igs_ca_inst.start_dt%type;
  l_acad_end_dt igs_ca_inst.end_dt%type;
  l_alternate_code igs_ca_inst.alternate_code%type;
  l_acad_message varchar2(100);
  l_message  VARCHAR2(1200);
  l_no_assessment_ind igs_en_su_attempt.no_assessment_ind%TYPE;
  l_return_status           VARCHAR2(10);
  l_dummy1                  VARCHAR2(200);

BEGIN

   -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type

    igs_en_gen_017.enrp_get_enr_method(
       p_enr_method_type => l_enr_meth_type,
       p_error_message   => l_message,
       p_ret_status      => l_return_status);

    -- added below logic to get the Academic Calendar which is used by method enrp_get_enr_cat
    --
    -- get the academic calendar of the given Load Calendar
    --
    l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                          p_cal_type                => x_load_cal_type,
                          p_ci_sequence_number      => x_load_sequence_number,
                          p_acad_cal_type           => l_acad_cal_type,
                          p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                          p_acad_ci_start_dt        => l_acad_start_dt,
                          p_acad_ci_end_dt          => l_acad_end_dt,
                          p_message_name            => l_acad_message );

      IF l_acad_message IS NOT NULL THEN
        x_message := l_acad_message;
        x_return_status := 'FALSE';
      END IF;

     l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                    x_person_id,     x_program_cd,
                    l_acad_cal_type, l_acad_ci_sequence_number,
                    NULL,            l_enr_cal_type,
                    l_enr_ci_seq,    l_enr_comm,
                    l_dummy1);

    IF l_enr_comm = 'BOTH' THEN
      l_enr_comm :='ALL';
    END IF;


      l_message := NULL;

      l_deny_warn_val  := igs_ss_enr_details.get_notification(
      p_person_type               => x_person_type,
      p_enrollment_category       => l_enr_cat,
      p_comm_type                 => l_enr_comm,
      p_enr_method_type           => l_enr_meth_type,
      p_step_group_type           => 'PROGRAM',
      p_step_type                 => 'TIME_CFTP',
      p_person_id                 => x_person_id,
      p_message                   => l_message
      ) ;
      IF l_message IS NOT NULL THEN
            x_message := l_message;
            x_return_status := 'FALSE';
      END IF;
--------------------------------------------------------------------------------------------------------------------------------------------

 RETURN l_deny_warn_val;

END get_unit_int_status;

--procedure to update the terms SPA planning sheet status for a student
PROCEDURE update_spa_plan_sts( p_n_person_id IN NUMBER,
                               p_c_program_cd IN VARCHAR2,
                               p_c_cal_type IN VARCHAR2,
                               p_n_seq_num IN NUMBER,
                               p_c_plan_sts    IN VARCHAR2) IS

 ------------------------------------------------------------------
  --Created by  : Somasekar, Oracle IDC
  --Date created: 17-May-2005
  --
  --Purpose: procedure to update the terms SPA
  --                            planning sheet status for a student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

CURSOR c_spa_terms (cp_n_person_id IN NUMBER,
                    cp_c_program_cd IN VARCHAR2,
                    cp_c_cal_type IN VARCHAR2,
                    cp_n_seq_num IN NUMBER) IS
     SELECT spa.ROWID ROW_ID, spa.*
     FROM    igs_en_spa_terms spa
     WHERE person_id = cp_n_person_id
     AND      program_cd = cp_c_program_cd
     AND      term_cal_type = cp_c_cal_type
     AND      term_sequence_number = cp_n_seq_num;

BEGIN
     FOR rec_spa_terms IN c_spa_terms(p_n_person_id, p_c_program_cd, p_c_cal_type, p_n_seq_num)
     LOOP
          igs_en_spa_terms_pkg.update_row(
                 x_rowid                =>rec_spa_terms.row_id,
                 x_term_record_id       =>rec_spa_terms.term_record_id,
                 x_person_id            =>rec_spa_terms.person_id,
                 x_program_cd           =>rec_spa_terms.program_cd,
                 x_program_version      =>rec_spa_terms.program_version,
                 x_acad_cal_type        =>rec_spa_terms.acad_cal_type,
                 x_term_cal_type        =>rec_spa_terms.term_cal_type,
                 x_term_sequence_number =>rec_spa_terms.term_sequence_number,
                 x_key_program_flag     =>rec_spa_terms.key_program_flag,
                 x_location_cd          =>rec_spa_terms.location_cd,
                 x_attendance_mode      =>rec_spa_terms.attendance_mode,
                 x_attendance_type      =>rec_spa_terms.attendance_type,
                 x_fee_cat              =>rec_spa_terms.fee_cat,
                 x_coo_id               =>rec_spa_terms.coo_id,
                 x_class_standing_id    =>rec_spa_terms.class_standing_id,
                 x_attribute_category   =>rec_spa_terms.attribute_category,
                 x_attribute1           =>rec_spa_terms.attribute1,
                 x_attribute2           =>rec_spa_terms.attribute2,
                 x_attribute3           =>rec_spa_terms.attribute3,
                 x_attribute4           =>rec_spa_terms.attribute4,
                 x_attribute5           =>rec_spa_terms.attribute5,
                 x_attribute6           =>rec_spa_terms.attribute6,
                 x_attribute7           =>rec_spa_terms.attribute7,
                 x_attribute8           =>rec_spa_terms.attribute8,
                 x_attribute9           =>rec_spa_terms.attribute9,
                 x_attribute10          =>rec_spa_terms.attribute10,
                 x_attribute11          =>rec_spa_terms.attribute11,
                 x_attribute12          =>rec_spa_terms.attribute12,
                 x_attribute13          =>rec_spa_terms.attribute13,
                 x_attribute14          =>rec_spa_terms.attribute14,
                 x_attribute15          =>rec_spa_terms.attribute15,
                 x_attribute16          =>rec_spa_terms.attribute16,
                 x_attribute17          =>rec_spa_terms.attribute17,
                 x_attribute18          =>rec_spa_terms.attribute18,
                 x_attribute19          =>rec_spa_terms.attribute19,
                 x_attribute20          =>rec_spa_terms.attribute20,
                 x_mode                 =>'R',
                 x_plan_sht_status      =>p_c_plan_sts);
     END LOOP;
END update_spa_plan_sts;

PROCEDURE update_grading_schema(
             p_person_id IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_grading_schema IN VARCHAR2,
             p_gs_version IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
           )  AS
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 8-JUN-2005
  --
  --Purpose: This procedure updates the override values of grading schema of an unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
Cursor cur_grading(cp_person_id NUMBER,
                   cp_course_cd VARCHAR2,
                   cp_uoo_id NUMBER) IS
      SELECT   su.ROWID , su.*
      FROM     IGS_EN_SU_ATTEMPT_ALL su
      WHERE    person_id = cp_person_id
      AND      course_cd = cp_course_cd
      AND      uoo_id = cp_uoo_id;

l_rowid VARCHAR2(25);
l_data cur_grading%ROWTYPE;
l_enc_message_name VARCHAR2(2000);
l_app_short_name VARCHAR2(10);
l_msg_index NUMBER;
BEGIN
        -- select unit attempt and call update row using IGS_EN_SU_ATTEMPT_PKG
        OPEN cur_grading(p_person_id,p_course_cd,p_uoo_id);
        FETCH cur_grading INTO l_data;
        IF cur_grading%FOUND THEN
                igs_en_su_attempt_pkg.update_row (
                  x_rowid                       => l_data.rowid,
                  x_person_id                   => l_data.person_id,
                  x_course_cd                   => l_data.course_cd,
                  x_unit_cd                     => l_data.unit_cd,
                  x_cal_type                    => l_data.cal_type,
                  x_ci_sequence_number          => l_data.ci_sequence_number,
                  x_version_number              => l_data.version_number,
                  x_location_cd                 => l_data.location_cd,
                  x_unit_class                  => l_data.unit_class,
                  x_ci_start_dt                 => l_data.ci_start_dt,
                  x_ci_end_dt                   => l_data.ci_end_dt,
                  x_uoo_id                      => l_data.uoo_id,
                  x_enrolled_dt                 => l_data.enrolled_dt,
                  x_unit_attempt_status         => l_data.unit_attempt_status,
                  x_administrative_unit_status  => l_data.administrative_unit_status,
                  x_discontinued_dt                     => l_data.discontinued_dt,
                  x_rule_waived_dt                      => l_data.rule_waived_dt,
                  x_rule_waived_person_id           => l_data.rule_waived_person_id,
                  x_no_assessment_ind               => l_data.no_assessment_ind,
                  x_sup_unit_cd                         => l_data.sup_unit_cd,
                  x_sup_version_number              => l_data.sup_version_number,
                  x_exam_location_cd                => l_data.exam_location_cd,
                  x_alternative_title               => l_data.alternative_title,
                  x_override_enrolled_cp            => l_data.override_enrolled_cp,
                  x_override_eftsu                      => l_data.override_eftsu ,
                  x_override_achievable_cp          => l_data.override_achievable_cp,
                  x_override_outcome_due_dt         => l_data.override_outcome_due_dt,
                  x_override_credit_reason          => l_data.override_credit_reason,
                  x_administrative_priority         => l_data.administrative_priority,
                  x_waitlist_dt                         => l_data.waitlist_dt,
                  x_dcnt_reason_cd                      => l_data.dcnt_reason_cd,
                  x_mode                                    => 'R',
                  x_gs_version_number               => p_gs_version,
                  x_enr_method_type                     => l_data.enr_method_type,
                  x_failed_unit_rule                => l_data.failed_unit_rule,
                  x_cart                                    => l_data.cart,
                  x_rsv_seat_ext_id                     => l_data.rsv_seat_ext_id,
                  x_org_unit_cd                         => l_data.org_unit_cd,
                  x_grading_schema_code             => p_grading_schema,
                  x_subtitle                            => l_data.subtitle,
                  x_session_id                          => l_data.session_id,
                  x_deg_aud_detail_id               => l_data.deg_aud_detail_id,
                  x_student_career_transcript   => l_data.student_career_transcript,
                  x_student_career_statistics   => l_data.student_career_statistics,
                  x_waitlist_manual_ind             => l_data.waitlist_manual_ind,
                  x_attribute_category              => l_data.attribute_category,
                  x_attribute1                  => l_data.attribute1,
                  x_attribute2                  => l_data.attribute2,
                  x_attribute3                  => l_data.attribute3,
                  x_attribute4                  => l_data.attribute4,
                  x_attribute5                  => l_data.attribute5,
                  x_attribute6                  => l_data.attribute6,
                  x_attribute7                  => l_data.attribute7,
                  x_attribute8                  => l_data.attribute8,
                  x_attribute9                  => l_data.attribute9,
                  x_attribute10                 => l_data.attribute10,
                  x_attribute11                 => l_data.attribute11,
                  x_attribute12                 => l_data.attribute12,
                  x_attribute13                 => l_data.attribute13,
                  x_attribute14                 => l_data.attribute14,
                  x_attribute15                 => l_data.attribute15,
                  x_attribute16                 => l_data.attribute16,
                  x_attribute17                 => l_data.attribute17,
                  x_attribute18                 => l_data.attribute18,
                  x_attribute19                 => l_data.attribute19,
                  x_attribute20                 => l_data.attribute20,
                  x_wlst_priority_weight_num    => l_data.wlst_priority_weight_num,
                  x_wlst_preference_weight_num  => l_data.wlst_preference_weight_num,
                  x_core_indicator_code             => l_data.core_indicator_code     ,
          x_upd_audit_flag                      => l_data.upd_audit_flag,
                  x_ss_source_ind                           => l_data.ss_source_ind
                  );
        END IF;
        CLOSE cur_grading;
EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
             IF cur_grading%ISOPEN THEN
                   CLOSE cur_grading;
                 END IF;
                 --set the p_message out parameter
                 igs_ge_msg_stack.get(-1, 'T', l_enc_message_name, l_msg_index);
                 fnd_message.parse_encoded(l_enc_message_name,l_app_short_name,p_message);
                 p_return_status := 'DENY';
        WHEN OTHERS THEN
                p_message :='IGS_GE_UNHANDLED_EXCEPTION';
                p_return_status := 'DENY';
END update_grading_schema;

PROCEDURE update_credit_points(
             p_person_id IN NUMBER,
             p_person_type IN VARCHAR2,
             p_load_cal_type IN VARCHAR2,
             p_load_sequence_number IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_course_version IN NUMBER,
             p_override_enrolled_cp IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
             ) AS
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 9-JUN-2005
  --
  --Purpose: This procedure updates the override credit points of a unit attempt.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    CURSOR cur_credit(cp_person_id NUMBER,
                  cp_course_cd VARCHAR2,
                  cp_uoo_id NUMBER) IS
      SELECT   su.ROWID, su.*
      FROM     IGS_EN_SU_ATTEMPT_ALL su
      WHERE    person_id = cp_person_id
      AND      course_cd = cp_course_cd
      AND      uoo_id = cp_uoo_id;
    l_rowid VARCHAR2(25);
    l_data cur_credit%ROWTYPE;
    l_enc_message_name VARCHAR2(2000);
    l_app_short_name VARCHAR2(10);
    l_msg_index NUMBER;
BEGIN
    -- validate updated credit points
    validate_upd_cp(
             x_person_id                    => p_person_id,
             x_person_type                  => p_person_type,
             x_load_cal_type            => p_load_cal_type,
             x_load_sequence_number     => p_load_sequence_number,
             x_uoo_id                       => p_uoo_id,
             x_program_cd                   => p_course_cd,
             x_program_version          => p_course_version,
             x_override_enrolled_cp     => p_override_enrolled_cp,
             x_message                      => p_message,
             x_return_status            => p_return_status
           );
    IF p_message IS NOT NULL THEN
         p_return_status := 'DENY';
         RETURN;
    END IF;

    -- get the unit attempt information
    OPEN cur_credit(p_person_id,p_course_cd,p_uoo_id);
    FETCH cur_credit INTO l_data;

    IF cur_credit%FOUND THEN
                igs_en_su_attempt_pkg.update_row (
                  x_rowid                                   => l_data.rowid,
                  x_person_id                           => l_data.person_id,
                  x_course_cd                           => l_data.course_cd,
                  x_unit_cd                                 => l_data.unit_cd,
                  x_cal_type                            => l_data.cal_type,
                  x_ci_sequence_number              => l_data.ci_sequence_number,
                  x_version_number                      => l_data.version_number,
                  x_location_cd                         => l_data.location_cd,
                  x_unit_class                          => l_data.unit_class,
                  x_ci_start_dt                         => l_data.ci_start_dt,
                  x_ci_end_dt                           => l_data.ci_end_dt,
                  x_uoo_id                                  => l_data.uoo_id,
                  x_enrolled_dt                         => l_data.enrolled_dt,
                  x_unit_attempt_status             => l_data.unit_attempt_status,
                  x_administrative_unit_status  => l_data.administrative_unit_status,
                  x_discontinued_dt                     => l_data.discontinued_dt,
                  x_rule_waived_dt                      => l_data.rule_waived_dt,
                  x_rule_waived_person_id           => l_data.rule_waived_person_id,
                  x_no_assessment_ind               => l_data.no_assessment_ind,
                  x_sup_unit_cd                         => l_data.sup_unit_cd,
                  x_sup_version_number              => l_data.sup_version_number,
                  x_exam_location_cd                => l_data.exam_location_cd,
                  x_alternative_title               => l_data.alternative_title,
                  x_override_enrolled_cp            => p_override_enrolled_cp,
                  x_override_eftsu                      => l_data.override_eftsu ,
                  x_override_achievable_cp          => l_data.override_achievable_cp,
                  x_override_outcome_due_dt         => l_data.override_outcome_due_dt,
                  x_override_credit_reason          => l_data.override_credit_reason,
                  x_administrative_priority         => l_data.administrative_priority,
                  x_waitlist_dt                         => l_data.waitlist_dt,
                  x_dcnt_reason_cd                      => l_data.dcnt_reason_cd,
                  x_mode                                    => 'R',
                  x_gs_version_number               => l_data.gs_version_number,
                  x_enr_method_type                     => l_data.enr_method_type,
                  x_failed_unit_rule                => l_data.failed_unit_rule,
                  x_cart                                    => l_data.cart,
                  x_rsv_seat_ext_id                     => l_data.rsv_seat_ext_id,
                  x_org_unit_cd                         => l_data.org_unit_cd,
                  x_grading_schema_code             => l_data.grading_schema_code,
                  x_subtitle                            => l_data.subtitle,
                  x_session_id                          => l_data.session_id,
                  x_deg_aud_detail_id               => l_data.deg_aud_detail_id,
                  x_student_career_transcript   => l_data.student_career_transcript,
                  x_student_career_statistics   => l_data.student_career_statistics,
                  x_waitlist_manual_ind             => l_data.waitlist_manual_ind,
                  x_attribute_category              => l_data.attribute_category,
                  x_attribute1                  => l_data.attribute1,
                  x_attribute2                  => l_data.attribute2,
                  x_attribute3                  => l_data.attribute3,
                  x_attribute4                  => l_data.attribute4,
                  x_attribute5                  => l_data.attribute5,
                  x_attribute6                  => l_data.attribute6,
                  x_attribute7                  => l_data.attribute7,
                  x_attribute8                  => l_data.attribute8,
                  x_attribute9                  => l_data.attribute9,
                  x_attribute10                 => l_data.attribute10,
                  x_attribute11                 => l_data.attribute11,
                  x_attribute12                 => l_data.attribute12,
                  x_attribute13                 => l_data.attribute13,
                  x_attribute14                 => l_data.attribute14,
                  x_attribute15                 => l_data.attribute15,
                  x_attribute16                 => l_data.attribute16,
                  x_attribute17                 => l_data.attribute17,
                  x_attribute18                 => l_data.attribute18,
                  x_attribute19                 => l_data.attribute19,
                  x_attribute20                 => l_data.attribute20,
                  x_wlst_priority_weight_num    => l_data.wlst_priority_weight_num,
                  x_wlst_preference_weight_num  => l_data.wlst_preference_weight_num,
                  x_core_indicator_code             => l_data.core_indicator_code  ,
          x_upd_audit_flag                      =>  l_data.upd_audit_flag,
                  x_ss_source_ind                           =>  l_data.ss_source_ind
                  );
    END IF;
    CLOSE cur_credit;

EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
              IF cur_credit%ISOPEN THEN
                    CLOSE cur_credit;
                  END IF;
                 --set the p_message out parameter
                 IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                 FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,p_message);
                 p_return_status := 'DENY';
        WHEN OTHERS THEN
                p_message :='IGS_GE_UNHANDLED_EXCEPTION';
                p_return_status := 'DENY';
END update_credit_points;

PROCEDURE update_audit(
             p_person_id IN NUMBER,
             p_load_cal_type IN VARCHAR2,
             p_load_sequence_number IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_no_assessment_ind IN VARCHAR2,
             p_override_cp IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
           ) AS
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 9-JUN-2005
  --
  --Purpose: This procedure updates the no_assessment_indicator of a unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
    CURSOR   c_usec_audit_lim IS
  SELECT   NVL (usec.max_auditors_allowed, NVL(uv.max_auditors_allowed,999999) )
  FROM     igs_ps_usec_lim_wlst usec,
           igs_ps_unit_ver uv,
           igs_ps_unit_ofr_opt uoo
  WHERE    uoo.unit_cd          = uv.unit_cd
  AND      uoo.version_number   = uv.version_number
  AND      uoo.uoo_id           = usec.uoo_id (+)
  AND      uoo.uoo_id           = p_uoo_id;

    CURSOR c_audit_sua IS
  SELECT COUNT(*)
  FROM igs_en_su_attempt
  WHERE uoo_id=p_uoo_id
  AND  no_assessment_ind = 'Y'
  AND   unit_attempt_status IN ('ENROLLED', 'COMPLETED','INVALID','UNCONFIRM' )  ;


    CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM   igs_pe_person_types
  WHERE  system_type = 'OTHER';


    CURSOR c_approv_perm IS
  SELECT approval_status
  FROM Igs_En_Spl_Perm
  WHERE student_person_id = p_person_id
  AND uoo_id            = p_uoo_id
  AND request_type      = 'AUDIT_PERM'
  AND  transaction_type <> 'WITHDRAWN' ;

    CURSOR cur_chk_au_allowed IS
  SELECT NVL(auditable_ind, 'N'), unit_cd, unit_class, NVL(audit_permission_ind, 'N')
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

    CURSOR cur_step_def_var(cp_enr_cat igs_en_cpd_ext.enrolment_cat%TYPE,
                        cp_enr_method igs_en_cpd_ext.enr_method_type%TYPE,
                        cp_comm_type igs_en_cpd_ext.s_student_comm_type%TYPE,
                        cp_step_type igs_en_cpd_ext.s_enrolment_step_type%TYPE) IS
  SELECT eru.stud_audit_lim
  FROM igs_en_cpd_ext eru, igs_lookups_view lkv
  WHERE eru.s_enrolment_step_type =lkv.lookup_code
  AND lkv.lookup_type = 'ENROLMENT_STEP_TYPE_EXT'
  AND lkv.step_group_type = 'UNIT'
  AND eru.enrolment_cat = cp_enr_cat
  AND eru.enr_method_type = cp_enr_method
  AND ( eru.s_student_comm_type =  cp_comm_type OR eru.s_student_comm_type = 'ALL')
  AND  s_enrolment_step_type = cp_step_type
  ORDER BY eru.step_order_num;

    CURSOR c_crs_ver IS
  SELECT version_number
  FROM igs_en_stdnt_ps_att
  WHERE person_id=p_person_id
  AND course_cd= p_course_cd;

    CURSOR cur_grading(cp_person_id NUMBER,
                   cp_course_cd VARCHAR2,
                   cp_uoo_id NUMBER) IS
      SELECT   su.ROWID , su.*
      FROM     IGS_EN_SU_ATTEMPT_ALL su
      WHERE    person_id = cp_person_id
      AND      course_cd = cp_course_cd
      AND      uoo_id = cp_uoo_id;

    l_enr_method_type           igs_en_cpd_ext.enr_method_type%TYPE;
    l_cur_per_typ                       cur_per_typ%ROWTYPE;
    lv_person_type                      igs_pe_person_types.person_type_code%TYPE;
    l_alternate_code            igs_ca_inst.alternate_code%TYPE;
    l_notification_flag         igs_en_cpd_ext.notification_flag%TYPE;
    l_message                   fnd_new_messages.message_name%TYPE;
    l_acad_cal_type                     igs_ca_inst_rel.sub_cal_type%TYPE;
    l_approval_status           igs_en_spl_perm.approval_status%TYPE;
    l_audit_allowed                     igs_ps_unit_ofr_opt.auditable_ind%TYPE;
    l_unit_cd                   igs_ps_unit_ofr_opt.unit_cd%TYPE;
    l_unit_class                        igs_ps_unit_ofr_opt.unit_class%TYPE;
    l_au_perm_req                       igs_ps_unit_ofr_opt.audit_permission_ind%TYPE;
    l_acad_ci_sequence_number   igs_ca_inst.sequence_number%TYPE;
    l_enrol_sequence_number             igs_ca_inst.sequence_number%TYPE;
    l_enrol_cal_type            igs_ca_inst.cal_type%TYPE;
    l_usec_audit_lim            igs_ps_usec_lim_wlst.max_auditors_allowed%TYPE;
    l_commencement_type         igs_en_cpd_ext.s_student_comm_type%TYPE;
    l_step_override_limit               igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_stud_audit_lim            igs_en_cpd_ext.stud_audit_lim%TYPE;
    l_crs_ver                   igs_en_stdnt_ps_att.version_number%TYPE;
    l_data                              cur_grading%ROWTYPE;
    l_enrollment_category   VARCHAR2(200);
    l_audit_sua NUMBER;
    l_acad_start_dt             DATE;
    l_acad_end_dt       DATE;
    l_categories VARCHAR2(255);
    l_enc_message_name VARCHAR2(2000);
    l_app_short_name VARCHAR2(10);
    l_msg_index NUMBER;
    l_override_eftsu igs_en_su_attempt.override_eftsu%type;
    l_override_enrolled_cp igs_en_su_attempt.override_enrolled_cp%TYPE;
    l_override_credit_reason igs_en_su_attempt.override_outcome_due_dt%TYPE;
    l_override_cp igs_en_su_attempt.override_enrolled_cp%TYPE;

BEGIN
      IF p_no_assessment_ind = 'N' THEN
            l_override_cp := NULL ;
      ELSE
            l_override_cp := p_override_cp;
      END IF;

         /*** To get person type ***/
            OPEN cur_per_typ;
            FETCH cur_per_typ into l_cur_per_typ;
              lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_course_cd),l_cur_per_typ.person_type_code);
            CLOSE cur_per_typ;
         /*** To get person type ***/

  -- if student is auditing this unit attempt then check the following
    igs_en_gen_017.enrp_get_enr_method(
                       p_enr_method_type => l_enr_method_type,
                       p_error_message   => p_message,
                       p_ret_status      => p_return_status);
    IF p_return_status = 'FALSE' THEN
         p_message := 'IGS_SS_EN_NOENR_METHOD';
         p_return_status := 'DENY' ;
      RETURN;
    END IF;

    l_alternate_code := igs_en_gen_002.enrp_get_acad_alt_cd(
                                p_cal_type                => p_load_cal_type,
                                p_ci_sequence_number      => p_load_sequence_number,
                                p_acad_cal_type           => l_acad_cal_type,
                                p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                                p_acad_ci_start_dt        => l_acad_start_dt,
                                p_acad_ci_end_dt          => l_acad_end_dt,
                                p_message_name            => l_message );

    IF l_message IS NOT NULL THEN
       p_message:= l_message;
       p_return_status := 'DENY';
      RETURN;
     END IF;
      -- get the enrollment category and commencement type
    l_enrollment_category := igs_en_gen_003.enrp_get_enr_cat(
                                            p_person_id => p_person_id,
                                            p_course_cd => p_course_cd,
                                            p_cal_type => l_acad_cal_type,
                                            p_ci_sequence_number =>  l_acad_ci_sequence_number,
                                            p_session_enrolment_cat =>NULL,
                                            p_enrol_cal_type => l_enrol_cal_type    ,
                                            p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                            p_commencement_type => l_commencement_type,
                                            p_enr_categories  => l_categories );


IF p_no_assessment_ind = 'Y' THEN
        -- check if audit permission step is setup

         l_notification_flag  :=  igs_ss_enr_details.get_notification(
                                               p_person_type         => lv_person_type,
                                               p_enrollment_category => l_enrollment_category,
                                               p_comm_type           => l_commencement_type,
                                               p_enr_method_type     => l_enr_method_type,
                                               p_step_group_type     => 'UNIT',
                                               p_step_type           => 'AUDIT_PERM',
                                               p_person_id           => p_person_id,
                                               p_message             => l_message);
           IF l_message IS NOT NULL THEN
                p_return_status := 'DENY';
                p_message := l_message;
                RETURN;
           END IF;
              -- Check whether the Audit is allowed in the given unit section
              -- If audit is not allowed return error message.
              OPEN cur_chk_au_allowed;
              FETCH cur_chk_au_allowed INTO l_audit_allowed,l_unit_cd, l_unit_class,l_au_perm_req;
              CLOSE cur_chk_au_allowed;
              IF l_audit_allowed = 'N' THEN
             p_return_status := 'DENY';
             p_message := 'IGS_EN_CANNOT_AUDIT';
             RETURN;
              END IF;
            --   Check whether Special Permission step has setup and not been overridden.

       --  Check whether Audit Permission step has setup and not been overridden.
           IF l_notification_flag  ='DENY' AND
                   NOT Igs_En_Gen_015.validation_step_is_overridden (
                                'AUDIT_PERM',
                                 p_load_cal_type,
                                 p_load_sequence_number ,
                                 p_person_id ,
                                 p_uoo_id ,
                                 l_step_override_limit
                                ) AND l_au_perm_req = 'Y'   THEN
                   -- get the audit permission request
                       OPEN c_approv_perm;
                       FETCH c_approv_perm INTO l_approval_status ;
                       IF c_approv_perm%FOUND THEN
                        CLOSE c_approv_perm;
                         -- if the audit permission has not been approved then show error
                         IF l_approval_status <> 'A' THEN
                            p_return_status := 'DENY';
                            p_message := 'IGS_EN_DENY_AUDIT_PERM';
                            RETURN;
                         END IF;
                    ELSE
                        -- if student doesnt have any permission requests then take him to request audit permission page
                         p_return_status := 'N';
                         CLOSE c_approv_perm;
                         RETURN;
                    END IF;

            END IF;

        --call  igs_en_elgbl_unit. eval_student_audit_limit to validate audit limit for student
         l_notification_flag  :=  igs_ss_enr_details.get_notification(
                                           p_person_type         => lv_person_type,
                                           p_enrollment_category => l_enrollment_category,
                                           p_comm_type           => l_commencement_type,
                                           p_enr_method_type     => l_enr_method_type,
                                           p_step_group_type     => 'UNIT',
                                           p_step_type           => 'AUDIT_LIM',
                                           p_person_id           => p_person_id,
                                           p_message             => l_message);


        IF l_message IS NOT NULL THEN
                    p_return_status := 'DENY';
                    p_message := l_message;
                    RETURN;
        END IF;

        -- get the audit limit setup at the step level
                OPEN cur_step_def_var(l_enrollment_category,l_enr_method_type,l_commencement_type,'AUDIT_LIM');
                FETCH cur_step_def_var INTO  l_stud_audit_lim;
                CLOSE cur_step_def_var;
        -- if audit limit for student failed then show error
        IF l_notification_flag='DENY' AND
                   NOT igs_en_elgbl_unit.eval_student_audit_limit (
                                                 p_person_id            => p_person_id,
                                                 p_load_cal_type        => p_load_cal_type,
                                                 p_load_sequence_number => p_load_sequence_number,
                                                 p_uoo_id               => p_uoo_id,
                                                 p_course_cd            => p_course_cd,
                                                 p_course_version       => NULL,
                                                 p_message              => l_message,
                                                 p_deny_warn            => l_notification_flag,
                                                 p_stud_audit_lim       => l_stud_audit_lim,
                                                 p_calling_obj              => 'SCH_UPD'
                                                ) THEN
                                p_return_status := 'DENY';
                                p_message := l_message;
                                RETURN;
          END IF;

      -- check if the unit section audit limit is satisfied or not
          OPEN c_usec_audit_lim;
      FETCH c_usec_audit_lim INTO l_usec_audit_lim;
      CLOSE c_usec_audit_lim;
      OPEN c_audit_sua;
      FETCH c_audit_sua INTO l_audit_sua;
      CLOSE c_audit_sua;
      IF l_audit_sua  >= l_usec_audit_lim THEN
            p_message := 'IGS_EN_AUDIT_UPD_DENY';
            p_return_status := 'DENY' ;
            RETURN;
      END IF;
 END IF;  -- end of p_no_assessment_ind='Y'


   SAVEPOINT upd_audit_cp ;

    OPEN c_crs_ver;
    FETCH c_crs_ver INTO l_crs_ver;
    CLOSE c_crs_ver;
    -- select unit attempt and call update row using IGS_EN_SU_ATTEMPT_PKG
        OPEN cur_grading(p_person_id,p_course_cd,p_uoo_id);
        FETCH cur_grading INTO l_data;
        IF cur_grading%FOUND THEN

                IF p_no_assessment_ind = 'N' THEN
                  l_override_enrolled_cp := NULL;
                  l_override_eftsu := NULL;
                  l_override_credit_reason := NULL;
                ELSE
                  l_override_enrolled_cp := l_data.override_enrolled_cp;
                  l_override_eftsu := l_data.override_eftsu ;
                  l_override_credit_reason := l_data.override_credit_reason ;
                END IF;

                 igs_en_su_attempt_pkg.update_row (
                  x_rowid                               => l_data.rowid,
                  x_person_id                       => l_data.person_id,
                  x_course_cd                       => l_data.course_cd,
                  x_unit_cd                             => l_data.unit_cd,
                  x_cal_type                        => l_data.cal_type,
                  x_ci_sequence_number          => l_data.ci_sequence_number,
                  x_version_number          => l_data.version_number,
                  x_location_cd             => l_data.location_cd,
                  x_unit_class              => l_data.unit_class,
                  x_ci_start_dt             => l_data.ci_start_dt,
                  x_ci_end_dt               => l_data.ci_end_dt,
                  x_uoo_id                              => l_data.uoo_id,
                  x_enrolled_dt                     => l_data.enrolled_dt,
                  x_unit_attempt_status         => l_data.unit_attempt_status,
                  x_administrative_unit_status  => l_data.administrative_unit_status,
                  x_discontinued_dt                     => l_data.discontinued_dt,
                  x_rule_waived_dt                      => l_data.rule_waived_dt,
                  x_rule_waived_person_id           => l_data.rule_waived_person_id,
                  x_no_assessment_ind               => p_no_assessment_ind,
                  x_sup_unit_cd                         => l_data.sup_unit_cd,
                  x_sup_version_number          => l_data.sup_version_number,
                  x_exam_location_cd            => l_data.exam_location_cd,
                  x_alternative_title           => l_data.alternative_title,
                  x_override_enrolled_cp        => l_override_enrolled_cp,
                  x_override_eftsu                      => l_override_eftsu ,
                  x_override_achievable_cp      => NULL,
                  x_override_outcome_due_dt     => l_data.override_outcome_due_dt,
                  x_override_credit_reason      => l_override_credit_reason,
                  x_administrative_priority     => l_data.administrative_priority,
                  x_waitlist_dt                         => l_data.waitlist_dt,
                  x_dcnt_reason_cd                      => l_data.dcnt_reason_cd,
                  x_mode                                    => 'R',
                  x_gs_version_number               => l_data.gs_version_number,
                  x_enr_method_type                     => l_data.enr_method_type,
                  x_failed_unit_rule                => l_data.failed_unit_rule,
                  x_cart                                    => l_data.cart,
                  x_rsv_seat_ext_id                     => l_data.rsv_seat_ext_id,
                  x_org_unit_cd                         => l_data.org_unit_cd,
                  x_grading_schema_code         => l_data.grading_schema_code,
                  x_subtitle                            => l_data.subtitle,
                  x_session_id                          => l_data.session_id,
                  x_deg_aud_detail_id               => l_data.deg_aud_detail_id,
                  x_student_career_transcript   => l_data.student_career_transcript,
                  x_student_career_statistics   => l_data.student_career_statistics,
                  x_waitlist_manual_ind             => l_data.waitlist_manual_ind,
                  x_attribute_category              => l_data.attribute_category,
                  x_attribute1                  => l_data.attribute1,
                  x_attribute2                  => l_data.attribute2,
                  x_attribute3                  => l_data.attribute3,
                  x_attribute4                  => l_data.attribute4,
                  x_attribute5                  => l_data.attribute5,
                  x_attribute6                  => l_data.attribute6,
                  x_attribute7                  => l_data.attribute7,
                  x_attribute8                  => l_data.attribute8,
                  x_attribute9                  => l_data.attribute9,
                  x_attribute10                 => l_data.attribute10,
                  x_attribute11                 => l_data.attribute11,
                  x_attribute12                 => l_data.attribute12,
                  x_attribute13                 => l_data.attribute13,
                  x_attribute14                 => l_data.attribute14,
                  x_attribute15                 => l_data.attribute15,
                  x_attribute16                 => l_data.attribute16,
                  x_attribute17                 => l_data.attribute17,
                  x_attribute18                 => l_data.attribute18,
                  x_attribute19                 => l_data.attribute19,
                  x_attribute20                 => l_data.attribute20,
                  x_wlst_priority_weight_num    => l_data.wlst_priority_weight_num,
                  x_wlst_preference_weight_num  => l_data.wlst_preference_weight_num,
                  x_core_indicator_code             => l_data.core_indicator_code   ,
                  x_upd_audit_flag                      =>  'N',
                  x_ss_source_ind                           =>  l_data.ss_source_ind
                  );
                END IF;
                CLOSE cur_grading;

     -- perform validations for update of audit and credit points
    validate_upd_cp(
             x_person_id => p_person_id,
             x_person_type => lv_person_type,
             x_load_cal_type => p_load_cal_type,
             x_load_sequence_number => p_load_sequence_number,
             x_uoo_id => p_uoo_id,
             x_program_cd => p_course_cd,
             x_program_version => l_crs_ver,
             x_override_enrolled_cp => l_override_cp,
             x_message => p_message,
             x_return_status => p_return_status
           );

     IF p_message IS NOT NULL THEN
        p_return_status :='DENY';
        ROLLBACK TO upd_audit_cp ;
     ELSE
         p_return_status := 'WARN';
     END IF;
         RETURN;
EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                 --set the p_message out parameter
                 IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                 FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,p_message);
                 p_return_status := 'DENY';
        WHEN OTHERS THEN
                p_message :='IGS_GE_UNHANDLED_EXCEPTION';
                p_return_status := 'DENY';


END update_audit;

PROCEDURE remove_permission_unit(p_request_id IN NUMBER,
                                 p_load_cal IN VARCHAR2,
                                 p_load_seq_num IN NUMBER,
                                 p_course_cd IN VARCHAR2) AS
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 11-JUN-2005
  --
  --Purpose: This procedure drops a permission unit attempt
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR c_perm(cp_request_id NUMBER) IS
       SELECT spl.ROWID,spl.*
       FROM igs_en_spl_perm spl
       WHERE spl.spl_perm_request_id=cp_request_id;
    l_data c_perm%ROWTYPE;

BEGIN
     OPEN c_perm(p_request_id);
     FETCH c_perm INTO l_data;
    IF c_perm%FOUND  THEN
        igs_en_spl_perm_pkg.update_row(
                x_rowid                             => l_data.rowid,
                x_spl_perm_request_id       => l_data.spl_perm_request_id,
                x_student_person_id         => l_data.student_person_id,
                x_uoo_id                    => l_data.uoo_id,
                x_date_submission           => l_data.date_submission,
                x_audit_the_course          => l_data.audit_the_course,
                x_instructor_person_id      => l_data.instructor_person_id,
                x_approval_status           => 'W',
                x_reason_for_request        => l_data.reason_for_request,
                x_instructor_more_info      => l_data.instructor_more_info,
                x_instructor_deny_info      => l_data.instructor_deny_info,
                x_student_more_info         => l_data.student_more_info,
                x_transaction_type          => 'WITHDRAWN',
                x_request_type                  => l_data.request_type,
                x_mode                      => 'R'
              );

           -- raise business event to notify instructor
            igs_en_workflow.raise_withdraw_perm_evt(
                p_n_uoo_id              => l_data.UOO_ID,
                        p_c_load_cal    => p_load_cal,
                        p_n_load_seq_num        => p_load_seq_num,
                        p_n_person_id   => l_data.student_person_id,
                        p_c_course_cd   => p_course_cd,
                        p_c_approval_type       => l_data.request_type
            );

    END IF;
    CLOSE c_perm;

END  remove_permission_unit;


PROCEDURE update_core_indicator(
             p_person_id      IN NUMBER,
             p_uoo_id         IN NUMBER,
             p_program_cd     IN VARCHAR2,
             p_core_indicator IN VARCHAR2,
			 p_message        OUT NOCOPY VARCHAR2
           )  AS
  ------------------------------------------------------------------
  --Created by  : Siva Gurusamy, Oracle IDC
  --Date created: 12-Aug-05
  --
  --Purpose:
  --   This is a new function to update the core indicator code for a unit section
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who       When        What
  --sgurusam  12-Aug-05   Created
  ------------1-------------------------------------------------------

     --cursor to fetch the rowid and other attributes from the student unit attempt for the passed in information
      CURSOR cur_core_ind(p_person_id  NUMBER,
                          p_course_cd  VARCHAR2,
                          p_uoo_id     NUMBER) IS
      SELECT   su.ROWID, su.*
      FROM     IGS_EN_SU_ATTEMPT_ALL su
      WHERE    person_id = p_person_id
      AND      course_cd = p_course_cd
      AND      uoo_id    = p_uoo_id;

     l_rowid VARCHAR2(25);
     l_data cur_core_ind%ROWTYPE;
     l_core_indicator igs_en_su_attempt_all.core_indicator_code%TYPE;
	 l_enc_message_name VARCHAR2(2000);
     l_app_short_name VARCHAR2(10);
     l_msg_index NUMBER;
BEGIN
     SAVEPOINT update_core_indicator;

     l_core_indicator := p_core_indicator;

     -- select unit attempt and call update row using IGS_EN_SU_ATTEMPT_PKG
     OPEN cur_core_ind(p_person_id, p_program_cd, p_uoo_id);
     FETCH cur_core_ind INTO l_data;
     CLOSE cur_core_ind;

     -- IF length(l_core_indicator)=0 THEN
       -- l_core_indicator := p_core_indicator;
     -- END IF;

     -- make call to update_row of IGS_EN_SU_ATTEMPT_PKG to update core indicator code value l_core_indicator
     Igs_En_Su_Attempt_Pkg.update_row(
              x_rowid                =>l_data.ROWID,
              x_person_id            =>l_data.person_id,
              x_course_cd            =>l_data.course_cd,
              x_unit_cd              =>l_data.unit_cd,
              x_cal_type             =>l_data.cal_type,
              x_ci_sequence_number   =>l_data.ci_sequence_number,
              x_version_number       =>l_data.version_number,
              x_location_cd          =>l_data.location_cd,
              x_unit_class           =>l_data.unit_class,
              x_ci_start_dt          =>l_data.ci_start_dt,
              x_ci_end_dt            =>l_data.ci_end_dt,
              x_uoo_id               =>l_data.uoo_id,
              x_enrolled_dt          =>l_data.enrolled_dt,
              x_unit_attempt_status  => l_data.unit_attempt_status,
              x_administrative_unit_status   => l_data.administrative_unit_status,
              x_discontinued_dt              =>l_data.discontinued_dt,
              x_dcnt_reason_cd               =>l_data.dcnt_reason_cd ,
              x_rule_waived_dt               =>l_data.rule_waived_dt,
              x_rule_waived_person_id        =>l_data.rule_waived_person_id,
              x_no_assessment_ind            =>l_data.no_assessment_ind,
              x_sup_unit_cd                  =>l_data.sup_unit_cd,
              x_sup_version_number           =>l_data.sup_version_number,
              x_exam_location_cd             =>l_data.exam_location_cd,
              x_alternative_title            =>l_data.alternative_title,
              x_override_enrolled_cp         =>l_data.override_enrolled_cp ,
              x_override_eftsu               =>l_data.override_eftsu,
              x_override_achievable_cp       =>l_data.override_achievable_cp,
              x_override_outcome_due_dt      =>l_data.override_outcome_due_dt,
              x_override_credit_reason       =>l_data.override_credit_reason,
              x_administrative_priority      =>l_data.administrative_priority,
              x_waitlist_dt                  =>l_data.waitlist_dt,
              x_gs_version_number            => l_data.gs_version_number,
              x_enr_method_type              => l_data.enr_method_type,
              x_failed_unit_rule             => l_data.failed_unit_rule,
              x_cart                         => l_data.cart,
              x_rsv_seat_ext_id              => l_data.rsv_seat_ext_id,
              x_mode                         => 'R',
              x_org_unit_cd                  => l_data.org_unit_cd,
              x_session_id                   => l_data.session_id,
              x_grading_schema_code          => l_data.grading_schema_code,
              x_deg_aud_detail_id            => l_data.deg_aud_detail_id,
              x_student_career_transcript =>  l_data.student_career_transcript,
              x_student_career_statistics =>  l_data.student_career_statistics,
              x_subtitle                  =>  l_data.subtitle,
              x_waitlist_manual_ind       =>  l_data.waitlist_manual_ind,
              x_attribute_category        =>  l_data.attribute_category,
              x_attribute1                =>  l_data.attribute1,
              x_attribute2                =>  l_data.attribute2,
              x_attribute3                =>  l_data.attribute3,
              x_attribute4                =>  l_data.attribute4,
              x_attribute5                =>  l_data.attribute5,
              x_attribute6                =>  l_data.attribute6,
              x_attribute7                =>  l_data.attribute7,
              x_attribute8                =>  l_data.attribute8,
              x_attribute9                =>  l_data.attribute9,
              x_attribute10               =>  l_data.attribute10,
              x_attribute11               =>  l_data.attribute11,
              x_attribute12               =>  l_data.attribute12,
              x_attribute13               =>  l_data.attribute13,
              x_attribute14               =>  l_data.attribute14,
              x_attribute15               =>  l_data.attribute15,
              x_attribute16               =>  l_data.attribute16,
              x_attribute17               =>  l_data.attribute17,
              x_attribute18               =>  l_data.attribute18,
              x_attribute19               =>  l_data.attribute19,
              x_attribute20               =>  l_data.attribute20,
              X_WLST_PRIORITY_WEIGHT_NUM  =>  l_data.wlst_priority_weight_num,
              X_WLST_PREFERENCE_WEIGHT_NUM=>  l_data.wlst_preference_weight_num,
              X_CORE_INDICATOR_CODE       =>  l_core_indicator,
              X_UPD_AUDIT_FLAG            =>  l_data.upd_audit_flag,
              X_SS_SOURCE_IND             =>  l_data.ss_source_ind
        );
 EXCEPTION
 WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
            ROLLBACK TO update_core_indicator;
            --set the p_message out parameter
            IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
            FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,p_message);
 WHEN OTHERS THEN
            ROLLBACK TO update_core_indicator;
            p_message :='IGS_GE_UNHANDLED_EXCEPTION';
END update_core_indicator;


PROCEDURE check_en_security( p_person_id  IN NUMBER,
                             p_course_cd  IN VARCHAR2,
                             p_uoo_id     IN NUMBER,
                             p_table      IN VARCHAR2,
                             p_mode       IN VARCHAR2,
                             p_select_allowed  OUT NOCOPY VARCHAR2,
                             p_update_allowed  OUT NOCOPY VARCHAR2,
                             p_message         OUT NOCOPY VARCHAR2
                              )
  ------------------------------------------------------------------
  --Created by  : Siva Gurusamy, Oracle IDC
  --Date created: 12-Aug-05
  --
  --Purpose:
  --   This is a new function to check the securty levels for the schedule page
  --   Implementation
  --     1. Checks if logged in user has select/update access to the Student's program attempt object and update access to the Student's unit attempt object
  --     2. If p_mode is B, then checks if logged in user has select/update access to the Student's program attempt object
  --     3. If value of Out parameter p_select_allowed is 'Y', the user has select access to the student's program attempt object
  --     4. If value of Out parameter p_update_allowed is 'Y', the user has update access to the student's program/unit attempt object
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who       When        What
  --sgurusam  12-Aug-05   Created
  -------------------------------------------------------------------

AS
 --cursor to get the rowid for the program attempt of the student
  CURSOR cur_program(p_person_id NUMBER, p_course_cd VARCHAR2) IS
  SELECT spat.ROWID
  FROM   igs_en_stdnt_ps_att_all spat
  WHERE  spat.person_id = p_person_id
  AND    spat.course_cd = p_course_cd;

--cursor to get the rowid for the unit attempt of the student
  CURSOR cur_unit(p_person_id NUMBER, p_course_cd VARCHAR2, p_uoo_id IN NUMBER) IS
  SELECT sua.ROWID
  FROM   igs_en_su_attempt_all sua
  WHERE  sua.person_id = p_person_id
  AND    sua.course_cd = p_course_cd
  AND    sua.uoo_id    = p_uoo_id;

  l_program_rowid VARCHAR2(25);
  l_unit_rowid    VARCHAR2(25);
  l_msg_data      VARCHAR2(4000);
  l_sec_out       BOOLEAN;
BEGIN

   l_sec_out        := FALSE;
   p_select_allowed := 'N';
   p_update_allowed := 'N';
   l_program_rowid  := NULL;

    -- get the program attempt rowid
    IF p_table ='IGS_EN_STDNT_PS_ATT_ALL' THEN
        --get the rowid for program attempt
        OPEN cur_program(p_person_id,p_course_cd);
        FETCH cur_program INTO l_program_rowid;
        CLOSE cur_program;
    END IF;

   --if program attempt exists, check if logged in user has update access to the student's program attempt object
    IF (l_program_rowid IS NOT NULL) THEN
        IF p_mode = 'B' THEN
            -- check for query permission on the table
            l_sec_out := igs_sc_gen_001.check_sel_upd_del_security (
                                        p_tab_name => 'IGS_EN_STDNT_PS_ATT_SV',
                                        p_rowid    => l_program_rowid,
                                        p_action   => 'S',
                                        p_msg_data => l_msg_data);

            IF  NOT l_sec_out THEN
               p_message := 'IGS_SC_NO_ACCESS_PRIV';
               IF  l_msg_data IS NOT NULL THEN
                p_message := 'IGS_SC_PRE_CHECK_EXCEP*'||l_msg_data||'*IGS_EN_STDNT_PS_ATT_SV*S';
               END IF;
               RETURN;
            END IF;

            IF l_sec_out THEN
                p_select_allowed := 'Y';
            END IF;

            l_msg_data := NULL;

            -- check for update permission on the table
            l_sec_out := Igs_sc_gen_001.check_sel_upd_del_security(
                                        p_tab_name => p_table,
                                        p_rowid    => l_program_rowid,
                                        p_action   => 'U',
                                        p_msg_data => l_msg_data);

            IF  NOT l_sec_out THEN
               p_message := 'IGS_SC_NO_ACCESS_PRIV';
               IF  l_msg_data IS NOT NULL THEN
                p_message := 'IGS_SC_PRE_CHECK_EXCEP*'||l_msg_data||'*'||p_table||'*U';
               END IF;
               RETURN;
            END IF;

            IF l_sec_out THEN
                p_update_allowed := 'Y';
            END IF;

        ELSE
            -- check for mode permission on the table
            l_sec_out := Igs_sc_gen_001.check_sel_upd_del_security(
                                        p_tab_name => p_table,
                                        p_rowid    => l_program_rowid,
                                        p_action   => p_mode,
                                        p_msg_data => l_msg_data);

            IF  NOT l_sec_out THEN
               p_message := 'IGS_SC_NO_ACCESS_PRIV';
               IF  l_msg_data IS NOT NULL THEN
                p_message := 'IGS_SC_PRE_CHECK_EXCEP*'||l_msg_data||'*'||p_table||'*'||p_mode;
               END IF;
               RETURN;
            END IF;

            IF l_sec_out THEN
                IF p_mode = 'S' THEN
                    p_select_allowed := 'Y';
                ELSE
                    p_update_allowed := 'Y';
                END IF;
            END IF;

        END IF;
        RETURN;
    END IF;

    l_unit_rowid := NULL;

    -- get the unit attempt rowid
    IF p_uoo_id IS NOT NULL AND p_table = 'IGS_EN_SU_ATTEMPT_ALL' THEN
         -- get the row id for unit attempt
         OPEN cur_unit(p_person_id,p_course_cd,p_uoo_id);
         FETCH cur_unit INTO l_unit_rowid;
         CLOSE cur_unit;
    END IF;

    --if program attempt exists, check if logged in user has update access to the student's program attempt object
    --Checking for unit Updates
    IF (l_unit_rowid IS NOT NULL) THEN
        -- check for update permission on the table student unit attempt
        l_sec_out := Igs_sc_gen_001.check_sel_upd_del_security(
                              p_tab_name => 'IGS_EN_SU_ATTEMPT_ALL',
                              p_rowid    => l_unit_rowid,
                              p_action   => 'U',
                              p_msg_data => l_msg_data);

        IF  NOT l_sec_out THEN
           p_message := 'IGS_SC_NO_ACCESS_PRIV';
           IF  l_msg_data IS NOT NULL THEN
            p_message := 'IGS_SC_PRE_CHECK_EXCEP*'||l_msg_data||'*IGS_EN_SU_ATTEMPT_ALL*U';
           END IF;
           RETURN;
        END IF;

        IF l_sec_out THEN
            p_update_allowed := 'Y';
        END IF;
    END IF;

   --set the out parameter to specify if  update of program attempt object is allowed or not
 END check_en_security;

PROCEDURE update_audit_flag(p_person_id IN NUMBER,
                            p_course_cd  IN VARCHAR2,
                            p_uoo_id    IN NUMBER,
                            p_upd_audit_flag IN VARCHAR2)
AS
    CURSOR  c_sua (p_person_id IN NUMBER,
                  p_course_cd  IN VARCHAR2,
                  p_uoo_id    IN NUMBER)
    IS
           SELECT *
           FROM   igs_en_su_attempt
           WHERE person_id = p_person_id
           AND    course_cd = p_course_cd
           AND    uoo_id = p_uoo_id;

    l_sua_rec c_sua%ROWTYPE;
BEGIN

    OPEN c_sua(p_person_id, p_course_cd, p_uoo_id);
    FETCH c_sua INTO l_sua_rec;
    IF c_sua%FOUND THEN
     IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW( -- calling the TBH
          X_ROWID                      => l_sua_rec.ROW_ID,
          X_PERSON_ID                  => l_sua_rec.PERSON_ID,
          X_COURSE_CD                  => l_sua_rec.COURSE_CD ,
          X_UNIT_CD                    => l_sua_rec.UNIT_CD,
          X_CAL_TYPE                   => l_sua_rec.CAL_TYPE,
          X_CI_SEQUENCE_NUMBER         => l_sua_rec.CI_SEQUENCE_NUMBER ,
          X_VERSION_NUMBER             => l_sua_rec.VERSION_NUMBER ,
          X_LOCATION_CD                => l_sua_rec.LOCATION_CD,
          X_UNIT_CLASS                 => l_sua_rec.UNIT_CLASS ,
          X_CI_START_DT                => l_sua_rec.CI_START_DT,
          X_CI_END_DT                  => l_sua_rec.CI_END_DT,
          X_UOO_ID                     => l_sua_rec.UOO_ID ,
          X_ENROLLED_DT                => l_sua_rec.ENROLLED_DT,
          X_UNIT_ATTEMPT_STATUS        => l_sua_rec.UNIT_ATTEMPT_STATUS,
          X_ADMINISTRATIVE_UNIT_STATUS => l_sua_rec.administrative_unit_status,
          X_ADMINISTRATIVE_PRIORITY    => l_sua_rec.administrative_PRIORITY,
          X_DISCONTINUED_DT            => l_sua_rec.discontinued_dt,
          X_DCNT_REASON_CD             => l_sua_rec.DCNT_REASON_CD,
          X_RULE_WAIVED_DT             => l_sua_rec.RULE_WAIVED_DT ,
          X_RULE_WAIVED_PERSON_ID      => l_sua_rec.RULE_WAIVED_PERSON_ID ,
          X_NO_ASSESSMENT_IND          => l_sua_rec.NO_ASSESSMENT_IND,
          X_SUP_UNIT_CD                => l_sua_rec.SUP_UNIT_CD ,
          X_SUP_VERSION_NUMBER         => l_sua_rec.SUP_VERSION_NUMBER,
          X_EXAM_LOCATION_CD           => l_sua_rec.EXAM_LOCATION_CD,
          X_ALTERNATIVE_TITLE          => l_sua_rec.ALTERNATIVE_TITLE,
          X_OVERRIDE_ENROLLED_CP       => l_sua_rec.OVERRIDE_ENROLLED_CP,
          X_OVERRIDE_EFTSU             => l_sua_rec.OVERRIDE_EFTSU ,
          X_OVERRIDE_ACHIEVABLE_CP     => l_sua_rec.OVERRIDE_ACHIEVABLE_CP,
          X_OVERRIDE_OUTCOME_DUE_DT    => l_sua_rec.OVERRIDE_OUTCOME_DUE_DT,
          X_OVERRIDE_CREDIT_REASON     => l_sua_rec.OVERRIDE_CREDIT_REASON,
          X_WAITLIST_DT                => l_sua_rec.waitlist_dt,
          X_MODE                       => 'R',
          X_GS_VERSION_NUMBER          => l_sua_rec.gs_version_number,
          X_ENR_METHOD_TYPE            => l_sua_rec.enr_method_type,
          X_FAILED_UNIT_RULE           => l_sua_rec.FAILED_UNIT_RULE,
          X_CART                       => l_sua_rec.CART,
          X_RSV_SEAT_EXT_ID            => l_sua_rec.RSV_SEAT_EXT_ID ,
          X_ORG_UNIT_CD                => l_sua_rec.org_unit_cd    ,
          X_SESSION_ID                 => l_sua_rec.session_id,
          X_GRADING_SCHEMA_CODE        => l_sua_rec.grading_schema_code,
          X_DEG_AUD_DETAIL_ID          => l_sua_rec.deg_aud_detail_id,
          X_SUBTITLE                   =>  l_sua_rec.subtitle,
          X_STUDENT_CAREER_TRANSCRIPT  => l_sua_rec.student_career_transcript,
          X_STUDENT_CAREER_STATISTICS  => l_sua_rec.student_career_statistics,
          X_ATTRIBUTE_CATEGORY         => l_sua_rec.attribute_category,
          X_ATTRIBUTE1                 => l_sua_rec.attribute1,
          X_ATTRIBUTE2                 => l_sua_rec.attribute2,
          X_ATTRIBUTE3                 => l_sua_rec.attribute3,
          X_ATTRIBUTE4                 => l_sua_rec.attribute4,
          X_ATTRIBUTE5                 => l_sua_rec.attribute5,
          X_ATTRIBUTE6                 => l_sua_rec.attribute6,
          X_ATTRIBUTE7                 => l_sua_rec.attribute7,
          X_ATTRIBUTE8                 => l_sua_rec.attribute8,
          X_ATTRIBUTE9                 => l_sua_rec.attribute9,
          X_ATTRIBUTE10                => l_sua_rec.attribute10,
          X_ATTRIBUTE11                => l_sua_rec.attribute11,
          X_ATTRIBUTE12                => l_sua_rec.attribute12,
          X_ATTRIBUTE13                => l_sua_rec.attribute13,
          X_ATTRIBUTE14                => l_sua_rec.attribute14,
          X_ATTRIBUTE15                => l_sua_rec.attribute15,
          X_ATTRIBUTE16                => l_sua_rec.attribute16,
          X_ATTRIBUTE17                => l_sua_rec.attribute17,
          X_ATTRIBUTE18                => l_sua_rec.attribute18,
          X_ATTRIBUTE19                => l_sua_rec.attribute19,
          X_ATTRIBUTE20                => l_sua_rec.attribute20,
          X_WAITLIST_MANUAL_IND        => l_sua_rec.waitlist_manual_ind ,
          X_WLST_PRIORITY_WEIGHT_NUM   => l_sua_rec.wlst_priority_weight_num,
          X_WLST_PREFERENCE_WEIGHT_NUM => l_sua_rec.wlst_preference_weight_num,
          X_CORE_INDICATOR_CODE        => l_sua_rec.core_indicator_code,
          X_UPD_AUDIT_FLAG             => p_upd_audit_flag,  -- updating audit flag
          X_SS_SOURCE_IND              => l_sua_rec.ss_source_ind
          );
    END IF;
    CLOSE c_sua;

END update_audit_flag;

FUNCTION check_perm_exists(p_person_id IN NUMBER,
                           p_uoo_id    IN NUMBER,
                           p_request_type IN VARCHAR2) return varchar2 as


CURSOR cur_perm_exists is
SELECT 'X' FROM igs_en_spl_perm perm
WHERE perm.uoo_id = p_uoo_id
AND perm.student_person_id = p_person_id
AND perm.approval_status <> 'A'
AND perm.request_type <> p_request_type;

l_perm_exists varchar2(1);
begin
l_perm_exists := null;

OPEN cur_perm_exists;
FETCH cur_perm_exists into l_perm_exists;
CLOSE cur_perm_exists;

IF l_perm_exists is NOT NULL THEN
RETURN 'Y';
ELSE
RETURN 'N';
END IF;
END check_perm_exists;

FUNCTION check_sua_exists(p_person_id IN NUMBER,
                           p_uoo_id    IN NUMBER,
                           p_course_cd IN VARCHAR2) return varchar2     as
CURSOR cur_sua_exists is
SELECT 'X' FROM igs_en_su_attempt sua
WHERE sua.person_id = p_person_id
AND sua.course_Cd = p_course_cd
AND sua.uoo_id = p_uoo_id;

l_sua_exists varchar2(1);
begin
l_sua_exists := null;

OPEN cur_sua_exists;
FETCH cur_sua_exists into l_sua_exists;
CLOSE cur_sua_exists;

IF l_sua_exists is NOT NULL THEN
RETURN 'Y';
ELSE
RETURN 'N';
END IF;
END check_sua_exists;


PROCEDURE chk_cart_units(p_person_id IN NUMBER,
                         p_course_cd  IN VARCHAR2,
                         p_load_cal_type  IN VARCHAR2,
                         p_load_sequence_number IN NUMBER,
                         p_cart_exists OUT NOCOPY VARCHAR2
                         ) AS

  ------------------------------------------------------------------
  --Created by  : Basanth Devisetty, Oracle IDC
  --Date created: 12-Feb-06
  --
  --Purpose: To check if any unconfirm unit attempts exists in the cart
  --
  --Change History:
  --Who       When        What
  --bdeviset  09-MAR-06   Created for Bug# 5072814
  -------------------------------------------------------------------

CURSOR c_chk_cart_units IS
  SELECT 'x'
  FROM igs_en_su_attempt sua,
       igs_ca_teach_to_load_v ltt
  WHERE sua.person_id = p_person_id
  AND sua.course_cd = p_course_cd
  AND sua.unit_attempt_status = 'UNCONFIRM'
  AND NVL(sua.SS_SOURCE_IND,'N') <> 'S'
  AND ltt.load_cal_type = p_load_cal_type
  AND ltt.load_ci_sequence_number = p_load_sequence_number
  AND ltt.teach_cal_type = sua.cal_type
  AND ltt.teach_ci_sequence_number = sua.ci_sequence_number;


l_dummy VARCHAR2(1);
BEGIN
p_cart_exists := 'FALSE';
OPEN c_chk_cart_units;
FETCH c_chk_cart_units INTO l_dummy;
  IF c_chk_cart_units%FOUND THEN
    p_cart_exists := 'TRUE';
  END IF;
CLOSE c_chk_cart_units;

END chk_cart_units;

END igs_ss_en_wrappers;

/
