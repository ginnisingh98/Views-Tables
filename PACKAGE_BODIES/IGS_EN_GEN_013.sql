--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_013" AS
/* $Header: IGSEN13B.pls 120.1 2005/09/23 03:10:32 appldev ship $ */

-- Modification By : jbegum
-- Modification    : Removed the following 3 functions:
--                   Enrp_Val_Sca_Fs , Enrp_Val_Sua_Excld , Enrp_Val_Sua_Pre
--                   The functions  Enrp_Val_Sca_Fs , Enrp_Val_Sua_Excld were not being called from anywhere .
--                   Also identical functions were present in the packages of IGSEN61B.pls and IGSEN68B.pls .
--           Hence these two functions were removed
--                   The function Enrp_Val_Sua_Pre was being called from the package in IGSEN09B.pls.But the
--                   exact replica of it was found in IGSEN68B.pls.Hence it was removed and the call to
--           this function from IGSEN09B.pls was replaced with the call to its replica in IGSEN68B.pls

-- Modified For : Enhancement Bug #1832130
-- Modified By  : jbegum
-- Modification : The function Enrp_Upd_Sci_Ua was modified as part of the Enrollments Process build.
--                In the call to the update row of the table IGS_EN_SU_ATTEMPT the following columns were added:
--                GS_VERSION_NUMBER , ENR_METHOD_TYPE , FAILED_UNIT_RULE , CART , RSV_SEAT_EXT_ID .
--                In the call to the functions IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD and IGS_EN_GEN_008.ENRP_GET_UDDC_AUS
--                parameter UOO_ID has been added.
--                Also when the function IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD returns 'Y' the existing code use to have
--            a call to the delete row of the table IGS_EN_SU_ATTEMPT.This has been replaced with a call to update row
--                of the table IGS_EN_SU_ATTEMPT with the unit_attempt_status updated to 'DROPPED'
--Added refernces to column ORG_UNIT_CD incall to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
--
--nalkumar  12-Oct-2001     Added CATALOG_CAL_TYPE and CATALOG_SEQ_NUM parameters to call IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW as per the
--                          Career impact Build Bug# 2027984.
--kkillams    20-12-2001    Added attribute_category to attribute20 parameters are added to call IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW as per the
--                          YOP-EN build Bug No: 2156956.
--svenkata   20-Dec-2001    Added columns student_career_transcript and Student_career_statistics as part of build Career
--                          Impact Part2 . Bug #2158626
--svenkata   7-JAN-2002     Bug No. 2172405  Standard Flex Field columns have been added to table handler
--                          procedure calls as part of CCR - ENCR022.
--Nishikant  29-jan-2002    Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
--                          as a part of the bug 2172380.
--Nishikant  15-may-2002    Condition in an IF clause in the function Enrp_Upd_Sci_Ua modified as part of the bug#2364216.
--Who         When            What
--mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in update row of IGS_EN_SU_ATTEMPT
--                            for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
--amuthu     03-OCT-2002    Modified Enrp_Upd_Sci_Ua to invoke workflow when a unit is dropped or discontinued
--                          To do this created a new procedure invoke_drop_workflow. This was done as part of
--                          Drop Transfer Workflow Build. Bug number 2599925.
-- pradhakr    16-Dec-2002  Changed the call to the update_row of igs_en_su_attempt
--                          table to igs_en_sua_api.update_unit_attempt. |
--                          Changes wrt ENCR031 build. Bug#2643207       |
--svanukur   26-jun-2003    Passing discontinued date with a nvl substitution of sysdate in the call to the update_row api of
  --                          ig_en_su_attmept in case of a "dropped" unit attempt status as part of bug 2898213.
--rvivekan    3-SEP-2003     Waitlist Enhacements build # 3052426. 2 new columns added to
--                           IGS_EN_SU_ATTEMPT_PKG procedures and consequently to IGS_EN_SUA_API procedures
--rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
--                          added as part of Prevent Dropping Core Units. Enh Bug# 3052432

  PROCEDURE invoke_drop_workflow(p_uoo_ids IN VARCHAR2,
                               p_unit_cds IN VARCHAR2,
                               p_teach_cal_type IN VARCHAR2,
                               p_teach_ci_sequence_number IN NUMBER,
                               p_person_id IN NUMBER,
                               p_course_cd IN VARCHAR2,
                               p_message_name IN OUT NOCOPY VARCHAR2)
  AS
    CURSOR c_tl IS
      SELECT load_cal_type, load_ci_sequence_number
      FROM IGS_CA_TEACH_TO_LOAD_V
      WHERE teach_cal_type = p_teach_cal_type
      AND   teach_ci_sequence_number = p_teach_ci_sequence_number
      ORDER BY LOAD_START_DT ASC;

    CURSOR c_reason IS
     SELECT meaning
     FROM IGS_LOOKUPS_VIEW
     WHERE lookup_type = 'CRS_ATTEMPT_STATUS'
     AND   lookup_CODE = 'INTERMIT';

    l_load_cal_type            IGS_CA_INST.CAL_TYPE%TYPE;
    l_load_ci_sequence_number  IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    l_return_status            VARCHAR2(10);
    l_meaning                  IGS_LOOKUPS_VIEW.MEANING%TYPE;

  BEGIN

    OPEN c_tl;
    FETCH c_tl INTO l_load_cal_type, l_load_ci_sequence_number;
    CLOSE c_tl;

    OPEN c_reason;
    FETCH c_reason INTO l_meaning;
    CLOSE c_reason;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_REASON_DRP_UNIT');
    FND_MESSAGE.SET_TOKEN('UNIT',p_unit_cds);
    FND_MESSAGE.SET_TOKEN('REASON',l_meaning);
    igs_ss_en_wrappers.drop_notif_variable(FND_MESSAGE.GET(),'PROGRAM_INTERMISSION' );

  END invoke_drop_workflow;


FUNCTION Enrp_Upd_Sci_Ua(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean  AS
  -------------------------------------------------------------------------------------------
  -- Update the IGS_EN_SU_ATTEMPT records as appropriate for the
  -- student_intermission detail which has been entered.
  -- Where the intermission start date is before the census date AND
  -- intermission end date is after the census date,
  -- REVISION (23/07/97): AND where the intermission start
  -- date is AFTER the census date and before the variation cutoff date
  -- (and if the variation cutoff date is not set the end date of
  -- the calendar instance) (END REVISION)
  -- the process will attempt to discontinue/remove the IGS_PS_UNIT attempts.
  -- Whether to discontinue or remove IGS_PS_UNIT attempts is dependent on the
  -- "IGS_PS_UNIT discontinuation criteria" within the teaching period calendar;
  -- if the intermission start date is prior to this date, the IGS_PS_UNIT attempts
  -- are removed, otherwise they are discontinued.
  -- If there are problems the routine will set the message number
  -- and return FALSE.
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Modified cursor igs_en_su_attempt_cur due to change in pk of
  --                            student unit attempt w.r.t. bug number 2829262
  --vangala    07-OCT-2003      Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                            added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  --bdeviset    13-SEP-2004     Added cursor c_sua_grade w.r.t bug no 3885804
  -------------------------------------------------------------------------------------------
BEGIN
DECLARE
    NO_S_GEN_CAL_CONF_REC_FOUND EXCEPTION;
    v_message_name          VARCHAR2(30);
    v_administrative_unit_status    IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
    v_discontinuation_dt        IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;
    v_census_dt_alias       IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
    v_do_remove         BOOLEAN:=FALSE;
    -- Revision 23/07/97
    e_vrn_cutoff_dt_alias_notfound  EXCEPTION;
    v_variation_cutoff_dt_alias IGS_EN_CAL_CONF.variation_cutoff_dt_alias%TYPE;
    v_after_cutoff_warning      BOOLEAN;
    v_dummy_date            DATE;
    v_admin_unit_status_str     VARCHAR2(2000);
    v_alias_val             IGS_CA_DA_INST_V.alias_val%TYPE;
    v_max_alias_val         IGS_CA_DA_INST_V.alias_val%TYPE;

    CURSOR c_s_enr_cal_conf IS
        SELECT  variation_cutoff_dt_alias
        FROM    IGS_EN_CAL_CONF
        WHERE   s_control_num = 1;

    CURSOR c_get_max_alias_val (
            cp_cal_type         IGS_CA_DA_INST_V.cal_type%TYPE,
            cp_ci_sequence_number   IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
            cp_dt_alias     IGS_CA_DA_INST_V.dt_alias%TYPE) IS
        SELECT
            MAX(alias_val)
        FROM
            IGS_CA_DA_INST_V
        WHERE   cal_type    = cp_cal_type       AND
            ci_sequence_number  = cp_ci_sequence_number AND
            dt_alias    = cp_dt_alias       AND
            alias_val IS NOT NULL;

    CURSOR  c_s_gen_cal_conf IS
        SELECT  census_dt_alias
        FROM    IGS_GE_S_GEN_CAL_CON
        WHERE   s_control_num = 1;

    CURSOR  c_student_unit_attempt(
            cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
            cp_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
        SELECT DISTINCT sua.cal_type,
                sua.ci_sequence_number,
                ci.end_dt
        FROM
            IGS_EN_SU_ATTEMPT   sua,
            IGS_CA_INST     ci
        WHERE
            sua.person_id   = cp_person_id  AND
            sua.course_cd   = cp_course_cd  AND
            sua.unit_attempt_status IN ('UNCONFIRM', 'ENROLLED') AND
            ci.cal_type = sua.cal_type  AND
            ci.sequence_number = sua.ci_sequence_number;

    CURSOR  c_student_unit_attempt_ci(
            cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
            cp_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE,
            cp_cal_type     IGS_EN_SU_ATTEMPT.cal_type%TYPE,
            cp_ci_sequence_number     IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
        SELECT  unit_cd,
            version_number,
            cal_type,
            ci_sequence_number,
            ci_start_dt,
            ci_end_dt,
            enrolled_dt,
            uoo_id,
            unit_attempt_status
        FROM    IGS_EN_SU_ATTEMPT
        WHERE   person_id   = cp_person_id AND
            course_cd   = cp_course_cd AND
            cal_type    = cp_cal_type AND
            ci_sequence_number = cp_ci_sequence_number AND
            unit_attempt_status = 'ENROLLED';

    CURSOR  c_dai_v(cp_cal_type         IGS_CA_DA_INST_V.cal_type%TYPE,
            cp_ci_sequence_number   IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
            cp_dt_alias     IGS_CA_DA_INST_V.dt_alias%TYPE) IS
        SELECT  alias_val
        FROM    IGS_CA_DA_INST_V
        WHERE
            cal_type        = cp_cal_type       AND
            ci_sequence_number  = cp_ci_sequence_number AND
                dt_alias        = cp_dt_alias       AND
            alias_val IS NOT NULL
        ORDER BY alias_val ASC;

    -- cursor to determine of a unit attempt exists which has a finalized
    -- or un-finalised mid-term grade or an un-finalized final grade.
    CURSOR c_sua_grade IS
	SELECT 'x' FROM IGS_AS_SU_STMPTOUT ou, igs_en_su_attempt sua
	where sua . person_id = p_person_id
	and sua .course_cd = p_course_cd
	AND sua .unit_attempt_status = 'ENROLLED'
	AND sua.person_id = ou.person_id
	AND sua.course_cd = ou.course_cd
	AND sua.uoo_id = ou.uoo_id;



    v_other_detail  VARCHAR(255);
    v_unit_att_exists VARCHAR2(1);

BEGIN
    p_message_name := null;
    v_after_cutoff_warning := FALSE;

    -- Get the census date alias
    OPEN    c_s_gen_cal_conf;
    FETCH   c_s_gen_cal_conf INTO v_census_dt_alias;
    IF (c_s_gen_cal_conf%NOTFOUND) THEN
        CLOSE   c_s_gen_cal_conf;
        RAISE NO_S_GEN_CAL_CONF_REC_FOUND;
    END IF;

    CLOSE   c_s_gen_cal_conf;

    -- Get the variation cutoff date alias
    OPEN c_s_enr_cal_conf;
    FETCH c_s_enr_cal_conf INTO v_variation_cutoff_dt_alias;
    IF (c_s_enr_cal_conf%NOTFOUND) THEN
        CLOSE c_s_enr_cal_conf;
        RAISE e_vrn_cutoff_dt_alias_notfound;
    END IF;
    CLOSE c_s_enr_cal_conf;

    --if any unit attempt exists which has a finalized or un-finalised mid-term grade
    -- or an un-finalized final grade then cannot drop/discontinue.
    OPEN c_sua_grade;
    FETCH c_sua_grade INTO v_unit_att_exists;
    IF c_sua_grade%FOUND THEN
        CLOSE c_sua_grade;
	P_message_name := 'IGS_EN_GRD_EXST_INTM';
	Return false;
    ELSE
       CLOSE c_sua_grade;
    END IF;


    FOR v_sua_rec IN c_student_unit_attempt(p_person_id,
                        p_course_cd)
    LOOP

       v_do_remove := FALSE;
       v_alias_val := NULL;

       FOR v_daiv_rec IN c_dai_v(v_sua_rec.cal_type,
                     v_sua_rec.ci_sequence_number,
                     v_census_dt_alias)
       LOOP
        v_alias_val := v_daiv_rec.alias_val;
        IF (v_alias_val BETWEEN p_start_dt AND p_end_dt) THEN
            v_do_remove := TRUE;
            EXIT;
        END IF;
       END LOOP;

       IF (v_alias_val is not null AND
           v_do_remove = FALSE     AND
           p_start_dt >= v_alias_val) THEN

         IF (v_variation_cutoff_dt_alias IS NOT NULL) THEN

            OPEN c_get_max_alias_val(v_sua_rec.cal_type,
                         v_sua_rec.ci_sequence_number,
                         v_variation_cutoff_dt_alias);
            FETCH c_get_max_alias_val INTO v_max_alias_val;

            IF (c_get_max_alias_val%FOUND AND
                v_max_alias_val IS NOT NULL) THEN

                IF (SYSDATE <= v_max_alias_val) THEN
                    IF (p_start_dt <= v_sua_rec.end_dt) THEN
                        v_do_remove := TRUE;
                    END IF;
                ELSE
                    v_after_cutoff_warning := TRUE;
                END IF;

            ELSIF (p_start_dt <= v_sua_rec.end_dt) THEN

                    v_do_remove := TRUE;

            END IF;

            CLOSE c_get_max_alias_val;

           ELSE

            IF (p_start_dt <= v_sua_rec.end_dt) THEN
                v_do_remove := TRUE;
                END IF;

           END IF;

       END IF;
       IF (v_do_remove = TRUE) THEN

            FOR v_suaci_rec IN c_student_unit_attempt_ci(p_person_id,
                                     p_course_cd,
                                 v_sua_rec.cal_type,
                                 v_sua_rec.ci_sequence_number)
        LOOP

           IF (p_start_dt < SYSDATE) THEN
              v_discontinuation_dt := p_start_dt;
           ELSE
              v_discontinuation_dt := SYSDATE;
           END IF;

           IF (TRUNC(v_discontinuation_dt) < TRUNC(v_suaci_rec.enrolled_dt)) THEN
            p_message_name := 'IGS_EN_ENRDT_EFFECT_UA';
            RETURN FALSE;
           END IF;

      -- Added the AND clause in the below If condtion AND unit_attempt status is not WAITLISTED
      -- Added by Nishikant - bug#2364216. If the unit attempt cannot be deleted and the unit attempt status is not WAITLISTED
      -- then proceed to discontinue the student unit attempt. Otherwise Proceed to drop the unit attempt.
           IF (IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD(v_suaci_rec.cal_type,
                                       v_suaci_rec.ci_sequence_number,
                                       v_discontinuation_dt,
                                       v_suaci_rec.uoo_id)= 'N'
                    AND v_suaci_rec.unit_attempt_status <> 'WAITLISTED' ) THEN
               v_administrative_unit_status := IGS_EN_GEN_008.ENRP_GET_UDDC_AUS(v_discontinuation_dt,
                                                v_suaci_rec.cal_type,
                                                v_suaci_rec.ci_sequence_number,
                                                v_admin_unit_status_str,
                                                v_dummy_date,
                                                v_suaci_rec.uoo_id);

               -- IGS_GE_NOTE: If  there is more than one possible administrative IGS_PS_UNIT status
               -- then the v_administrative_unit_status will be NULL and the possible
               -- statuses will be concatenated in the v_admin_unit_status_str OUT NOCOPY
               -- parameter. If this is the case the first possible status is used. This
               -- may be revised in the future when full 'default' admin IGS_PS_UNIT statuses
               -- come into effect.

               IF (v_administrative_unit_status IS NULL) THEN
                  p_message_name := 'IGS_EN_CANT_DISCONTINUE';
                  RETURN FALSE;
         END IF;

         DECLARE
           v_unit_cds    VARCHAR2(4000);
           v_uoo_ids     VARCHAR2(4000);

           CURSOR igs_en_su_attempt_cur IS
             SELECT igs_en_su_attempt.*
             FROM   igs_en_su_attempt
             WHERE  person_id       = p_person_id AND
                    course_cd       = p_course_cd AND
                    uoo_id          = v_suaci_rec.uoo_id;

         BEGIN
           v_uoo_ids := null;
           v_unit_cds := null;


           FOR IGS_EN_SU_ATTEMPT_rec IN IGS_EN_SU_ATTEMPT_cur LOOP
             -- Call the API to update the student unit attempt. This API is a
             -- wrapper to the update row of the TBH.
             invoke_drop_workflow(
               p_uoo_ids                  => v_uoo_ids,
               p_unit_cds                 => v_unit_cds,
               p_teach_cal_type           => v_suaci_rec.cal_type,
               p_teach_ci_sequence_number => v_suaci_rec.ci_sequence_number,
               p_person_id                => p_person_id,
               p_course_cd                => p_course_cd,
               p_message_name             => v_message_name
             );
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
               X_UNIT_ATTEMPT_STATUS           =>   igs_en_su_attempt_rec.unit_attempt_status,
               X_ADMINISTRATIVE_UNIT_STATUS    =>   v_administrative_unit_status,
               X_ADMINISTRATIVE_PRIORITY       =>   igs_en_su_attempt_rec.administrative_PRIORITY,
               X_DISCONTINUED_DT               =>   v_discontinuation_dt,
               X_DCNT_REASON_CD                =>   NULL, -- unable to insert value in to this field
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
               X_GS_VERSION_NUMBER             =>    igs_en_su_attempt_rec.GS_VERSION_NUMBER,
               X_ENR_METHOD_TYPE               =>    igs_en_su_attempt_rec.ENR_METHOD_TYPE,
               X_FAILED_UNIT_RULE              =>    igs_en_su_attempt_rec.FAILED_UNIT_RULE,
               X_CART                          =>    igs_en_su_attempt_rec.CART,
               X_RSV_SEAT_EXT_ID               =>    igs_en_su_attempt_rec.RSV_SEAT_EXT_ID,
               X_ORG_UNIT_CD                   =>    igs_en_su_attempt_rec.ORG_UNIT_CD,
               -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
               X_SESSION_ID                    =>    igs_en_su_attempt_rec.SESSION_ID,
               X_GRADING_SCHEMA_CODE           =>    igs_en_su_attempt_rec.GRADING_SCHEMA_CODE,
               X_DEG_AUD_DETAIL_ID             =>    igs_en_su_attempt_rec.DEG_AUD_DETAIL_ID,
               X_SUBTITLE                      =>    igs_en_su_attempt_rec.subtitle,
               X_STUDENT_CAREER_TRANSCRIPT     =>    igs_en_su_attempt_rec.student_career_transcript,
               X_STUDENT_CAREER_STATISTICS     =>    igs_en_su_attempt_rec.student_career_statistics,
               X_ATTRIBUTE_CATEGORY            =>    igs_en_su_attempt_rec.attribute_category,
               X_ATTRIBUTE1                    =>    igs_en_su_attempt_rec.attribute1,
               X_ATTRIBUTE2                    =>    igs_en_su_attempt_rec.attribute2,
               X_ATTRIBUTE3                    =>    igs_en_su_attempt_rec.attribute3,
               X_ATTRIBUTE4                    =>    igs_en_su_attempt_rec.attribute4,
               X_ATTRIBUTE5                    =>    igs_en_su_attempt_rec.attribute5,
               X_ATTRIBUTE6                    =>    igs_en_su_attempt_rec.attribute6,
               X_ATTRIBUTE7                    =>    igs_en_su_attempt_rec.attribute7,
               X_ATTRIBUTE8                    =>    igs_en_su_attempt_rec.attribute8,
               X_ATTRIBUTE9                    =>    igs_en_su_attempt_rec.attribute9,
               X_ATTRIBUTE10                   =>    igs_en_su_attempt_rec.attribute10,
               X_ATTRIBUTE11                   =>    igs_en_su_attempt_rec.attribute11,
               X_ATTRIBUTE12                   =>    igs_en_su_attempt_rec.attribute12,
               X_ATTRIBUTE13                   =>    igs_en_su_attempt_rec.attribute13,
               X_ATTRIBUTE14                   =>    igs_en_su_attempt_rec.attribute14,
               X_ATTRIBUTE15                   =>    igs_en_su_attempt_rec.attribute15,
               X_ATTRIBUTE16                   =>    igs_en_su_attempt_rec.attribute16,
               X_ATTRIBUTE17                   =>    igs_en_su_attempt_rec.attribute17,
               X_ATTRIBUTE18                   =>    igs_en_su_attempt_rec.attribute18,
               X_ATTRIBUTE19                   =>    igs_en_su_attempt_rec.attribute19,
               X_ATTRIBUTE20                   =>    igs_en_su_attempt_rec.attribute20,
               X_WAITLIST_MANUAL_IND           =>    igs_en_su_attempt_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.
               X_WLST_PRIORITY_WEIGHT_NUM      =>    igs_en_su_attempt_rec.wlst_priority_weight_num,
               X_WLST_PREFERENCE_WEIGHT_NUM    =>    igs_en_su_attempt_rec.wlst_preference_weight_num,
	       -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
	       X_CORE_INDICATOR_CODE           =>    igs_en_su_attempt_rec.core_indicator_code
            );
             IF v_unit_cds IS NULL THEN
               v_unit_cds := v_suaci_rec.unit_Cd;
             ELSE
               v_unit_cds := v_unit_Cds || ',' || v_suaci_rec.unit_Cd;
             END IF;


             IF v_uoo_ids IS NULL THEN
               v_uoo_ids := to_char(IGS_EN_SU_ATTEMPT_rec.uoo_id);
             ELSE
               v_uoo_ids := v_uoo_ids || ',' || to_char(IGS_EN_SU_ATTEMPT_rec.uoo_id);
             END IF;
           END LOOP;

         END;


           ELSE
           -- Modified For : Enhancement Bug #1832130
           -- Modified By  : jbegum
           -- When the function IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD returns 'Y' the existing code use to have
           -- a call to the delete row of the table IGS_EN_SU_ATTEMPT.This has been replaced with a call to update row
           -- of the table IGS_EN_SU_ATTEMPT with the unit_attempt_status updated to 'DROPPED'

         DECLARE
           v_unit_cds VARCHAR2(4000);
           v_uoo_ids  VARCHAR2(4000);
           CURSOR igs_en_su_attempt_cur IS
             SELECT igs_en_su_attempt.*
             FROM   igs_en_su_attempt
             WHERE  person_id       = p_person_id AND
                    course_cd       = p_course_cd AND
                    uoo_id          = v_suaci_rec.uoo_id;

         BEGIN

           v_uoo_ids := null;
           v_unit_cds := null;

           FOR igs_en_su_attempt_rec IN igs_en_su_attempt_cur LOOP
            -- Call the API to update the student unit attempt. This API is a
            -- wrapper to the update row of the TBH.

             invoke_drop_workflow(
               p_uoo_ids                  => v_uoo_ids,
               p_unit_cds                 => v_unit_cds,
               p_teach_cal_type           => v_suaci_rec.cal_type,
               p_teach_ci_sequence_number => v_suaci_rec.ci_sequence_number,
               p_person_id                => p_person_id,
               p_course_cd                => p_course_cd,
               p_message_name             => v_message_name);

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
               X_UNIT_ATTEMPT_STATUS           =>   'DROPPED',
               X_ADMINISTRATIVE_UNIT_STATUS    =>   igs_en_su_attempt_rec.administrative_unit_status,
               X_ADMINISTRATIVE_PRIORITY       =>   igs_en_su_attempt_rec.administrative_priority,
               X_DISCONTINUED_DT               =>   nvl(igs_en_su_attempt_rec.discontinued_dt,trunc(sysdate)),
               X_DCNT_REASON_CD                =>   igs_en_su_attempt_rec.dcnt_reason_cd,
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
               -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
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
               X_WAITLIST_MANUAL_IND           =>   igs_en_su_attempt_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
               X_WLST_PRIORITY_WEIGHT_NUM      =>   igs_en_su_attempt_rec.wlst_priority_weight_num,
               X_WLST_PREFERENCE_WEIGHT_NUM    =>   igs_en_su_attempt_rec.wlst_preference_weight_num,
	       -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
	       X_CORE_INDICATOR_CODE           =>    igs_en_su_attempt_rec.core_indicator_code);

            IF v_unit_cds IS NULL THEN
              v_unit_cds := v_suaci_rec.unit_Cd;
            ELSE
              v_unit_cds := v_unit_Cds || ',' || v_suaci_rec.unit_Cd;
            END IF;


            IF v_uoo_ids IS NULL THEN
              v_uoo_ids := to_char(IGS_EN_SU_ATTEMPT_rec.uoo_id);
            ELSE
              v_uoo_ids := v_uoo_ids || ',' || to_char(IGS_EN_SU_ATTEMPT_rec.uoo_id);
            END IF;


           END LOOP;
         END;

           END IF;/* For the IGS_EN_GEN_008.ENRP_GET_UA_DEL_ALWD IF condition */

        END LOOP;

       END IF; /* End If for IF (v_do_remove = TRUE) */

    END LOOP;


    IF v_after_cutoff_warning = TRUE THEN
        p_message_name := 'IGS_EN_MORE_UA_BEEN_ROLLED';
    END IF;
    RETURN TRUE;

EXCEPTION

    WHEN NO_S_GEN_CAL_CONF_REC_FOUND THEN
        Fnd_Message.Set_name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

    WHEN e_vrn_cutoff_dt_alias_notfound THEN
        Fnd_Message.Set_name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

    WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_013.enrp_upd_sci_ua');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_upd_sci_ua;

Function Enrp_Upd_Susa_End_Dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_end_dt IN DATE ,
  p_voluntary_end_ind IN VARCHAR2 := 'N',
  p_authorised_person_id IN NUMBER ,
  p_authorised_on IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  AS

    resource_busy_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy_exception, -54);
BEGIN   -- enrp_upd_susa_end_dt
    -- This module is called when a IGS_AS_SU_SETATMPT is ended (end_dt set).
    -- This module will check if the IGS_PS_UNIT set has any child IGS_PS_UNIT sets and attempt
    -- to set the end_dt and associated authorisation details for all children.
DECLARE
    v_unit_set_cd           IGS_AS_SU_SETATMPT.unit_set_cd%TYPE;
    v_us_version_number     IGS_AS_SU_SETATMPT.us_version_number%TYPE;
    v_sequence_number       IGS_AS_SU_SETATMPT.sequence_number%TYPE;
    v_authorised_person_id      IGS_AS_SU_SETATMPT.authorised_person_id%TYPE;
    v_authorised_on         IGS_AS_SU_SETATMPT.authorised_on%TYPE;
    v_selection_dt          IGS_AS_SU_SETATMPT.selection_dt%TYPE;
    v_end_dt            IGS_AS_SU_SETATMPT.end_dt%TYPE;
    v_rqrmnts_complete_dt       IGS_AS_SU_SETATMPT.rqrmnts_complete_dt%TYPE;
    v_parent_unit_set_cd        IGS_AS_SU_SETATMPT.parent_unit_set_cd%TYPE;
    v_parent_sequence_number    IGS_AS_SU_SETATMPT.parent_sequence_number%TYPE;
    v_student_confirmed_ind     IGS_AS_SU_SETATMPT.student_confirmed_ind%TYPE;
    v_primary_set_ind       IGS_AS_SU_SETATMPT.primary_set_ind%TYPE;
    v_voluntary_end_ind     IGS_AS_SU_SETATMPT.voluntary_end_ind%TYPE;
    v_override_title        IGS_AS_SU_SETATMPT.override_title%TYPE;
    v_rqrmnts_complete_ind      IGS_AS_SU_SETATMPT.rqrmnts_complete_ind%TYPE;
    v_s_completed_source_type   IGS_AS_SU_SETATMPT.s_completed_source_type%TYPE;
    v_catalog_cal_type      IGS_AS_SU_SETATMPT.catalog_cal_type%TYPE;
    v_catalog_seq_num       IGS_AS_SU_SETATMPT.catalog_seq_num%TYPE;
            --kkillams attribute_category to attribute20 variables are added w.r.t to YOP-EN bug id :2156956
    v_attribute_category         IGS_AS_SU_SETATMPT.attribute_category%TYPE;
    v_attribute1                      IGS_AS_SU_SETATMPT.attribute1%TYPE;
    v_attribute2                      IGS_AS_SU_SETATMPT.attribute2%TYPE;
    v_attribute3                      IGS_AS_SU_SETATMPT.attribute3%TYPE;
    v_attribute4                      IGS_AS_SU_SETATMPT.attribute4%TYPE;
    v_attribute5                      IGS_AS_SU_SETATMPT.attribute5%TYPE;
    v_attribute6                      IGS_AS_SU_SETATMPT.attribute6%TYPE;
    v_attribute7                      IGS_AS_SU_SETATMPT.attribute7%TYPE;
    v_attribute8                      IGS_AS_SU_SETATMPT.attribute8%TYPE;
    v_attribute9                      IGS_AS_SU_SETATMPT.attribute9%TYPE;
    v_attribute10                    IGS_AS_SU_SETATMPT.attribute10%TYPE;
    v_attribute11                    IGS_AS_SU_SETATMPT.attribute11%TYPE;
    v_attribute12                    IGS_AS_SU_SETATMPT.attribute12%TYPE;
    v_attribute13                    IGS_AS_SU_SETATMPT.attribute13%TYPE;
    v_attribute14                    IGS_AS_SU_SETATMPT.attribute14%TYPE;
    v_attribute15                    IGS_AS_SU_SETATMPT.attribute15%TYPE;
    v_attribute16                    IGS_AS_SU_SETATMPT.attribute16%TYPE;
    v_attribute17                    IGS_AS_SU_SETATMPT.attribute17%TYPE;
    v_attribute18                    IGS_AS_SU_SETATMPT.attribute18%TYPE;
    v_attribute19                    IGS_AS_SU_SETATMPT.attribute19%TYPE;
    v_attribute20                    IGS_AS_SU_SETATMPT.attribute20%TYPE;
    v_message_name          VARCHAR2(30);
    v_message_text          VARCHAR2(2000);
        v_rowid             ROWID;

    CURSOR c_susa IS
    SELECT  susa.ROWID,
        susa.unit_set_cd,
        susa.us_version_number,
        susa.sequence_number,
        susa.authorised_person_id,
        susa.authorised_on,
        susa.selection_dt,
        susa.end_dt,
        susa.rqrmnts_complete_dt,
        susa.parent_unit_set_cd,
        susa.parent_sequence_number,
        susa.student_confirmed_ind,
        susa.primary_set_ind,
        susa.voluntary_end_ind,
        susa.override_title,
        susa.rqrmnts_complete_ind,
        susa.s_completed_source_type,
        susa.catalog_cal_type,
        susa.catalog_seq_num,
        susa.attribute_category,            --kkillams columns attribute_category to attribute20 added to  cursor w.r.t to YOP-EN bug id :2156956
        susa.attribute1,
        susa.attribute2,
        susa.attribute3,
        susa.attribute4,
        susa.attribute5,
        susa.attribute6,
        susa.attribute7,
        susa.attribute8,
        susa.attribute9,
        susa.attribute10,
        susa.attribute11,
        susa.attribute12,
        susa.attribute13,
        susa.attribute14,
        susa.attribute15,
        susa.attribute16,
        susa.attribute17,
        susa.attribute18,
        susa.attribute19,
        susa.attribute20
    FROM    IGS_AS_SU_SETATMPT susa
    START WITH  susa.person_id          = p_person_id   AND
            susa.course_cd          = p_course_cd   AND
            susa.parent_unit_set_cd     = p_unit_set_cd AND
            susa.parent_sequence_number     = p_sequence_number
    CONNECT BY
    PRIOR   susa.person_id      = susa.person_id        AND
    PRIOR   susa.course_cd      = susa.course_cd        AND
    PRIOR   susa.unit_set_cd    = susa.parent_unit_set_cd   AND
    PRIOR   susa.sequence_number    = susa.parent_sequence_number
    FOR UPDATE OF   end_dt,
            voluntary_end_ind,
            authorised_person_id,
            authorised_on NOWAIT;
    L_ROWID VARCHAR2(25);
BEGIN
    -- Set the default message number
    p_message_name := null;

    OPEN c_susa;
    FETCH c_susa INTO   v_rowid,
                v_unit_set_cd,
                v_us_version_number,
                v_sequence_number,
                v_authorised_person_id,
                v_authorised_on,
                v_selection_dt,
                v_end_dt,
                v_rqrmnts_complete_dt,
                v_parent_unit_set_cd,
                v_parent_sequence_number,
                v_student_confirmed_ind,
                v_primary_set_ind,
                v_voluntary_end_ind,
                v_override_title,
                v_rqrmnts_complete_ind,
                v_s_completed_source_type,
                v_catalog_cal_type,
                v_catalog_seq_num,
                v_attribute_category,                       --kkillams variables attribute_category to attribute20  are added  w.r.t to YOP-EN bug id :2156956
                v_attribute1,
                v_attribute2,
                v_attribute3,
                v_attribute4,
                v_attribute5,
                v_attribute6,
                v_attribute7,
                v_attribute8,
                v_attribute9,
                v_attribute10,
                v_attribute11,
                v_attribute12,
                v_attribute13,
                v_attribute14,
                v_attribute15,
                v_attribute16,
                v_attribute17,
                v_attribute18,
                v_attribute19,
                v_attribute20;

    LOOP
        EXIT WHEN (c_susa%NOTFOUND);
        -- For each descendant record found, validate and then end the IGS_PS_UNIT set.
        IF (v_end_dt IS NULL AND
                    v_rqrmnts_complete_dt IS NULL) THEN
            -- Determine if authorised IGS_PE_PERSON id required to be updated (That is, if
            -- authorise parameter fields null then do not alter fields.)
            IF (p_authorised_person_id IS NOT NULL OR
                        p_authorised_on IS NOT NULL) THEN
                v_authorised_person_id  := p_authorised_person_id;
                v_authorised_on     := p_authorised_on;
            END IF;
            -- Validate that able to update the record.
            IF IGS_EN_VAL_SUSA.enrp_val_susa(
                        p_person_id,
                        p_course_cd,
                        v_unit_set_cd,
                        v_sequence_number,
                        v_us_version_number,
                        v_selection_dt,
                        v_student_confirmed_ind,
                        p_end_dt,
                        v_parent_unit_set_cd,
                        v_parent_sequence_number,
                        v_primary_set_ind,
                        p_voluntary_end_ind,
                        v_authorised_person_id,
                        v_authorised_on,
                        v_override_title,
                        v_rqrmnts_complete_ind,
                        v_rqrmnts_complete_dt,
                        v_s_completed_source_type,
                        'UPDATE',
                        v_message_name,
                        v_message_text) = FALSE THEN
                -- IGS_GE_NOTE: The IGS_RU_RULE check will only be called when confirming the IGS_PS_UNIT set.
                -- Hence no need to check and handle if v_message_text returned.
                CLOSE c_susa;
                p_message_name := v_message_name;
                RETURN FALSE;
            END IF;
            -- Disable triggers for the session  as this is a cascading update and as
            -- such creates problems accessing the PL/SQL table when called in the
            -- after statement trigger.

            -- Inserts a record into the s_disable_table_trigger
            -- database table.
            IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
                X_ROWID => L_ROWID ,
                X_TABLE_NAME =>'IGS_AS_SU_SETATMPT',
                X_SESSION_ID => userenv('SESSIONID'),
                x_mode => 'R'
                );

            -- If valid, then end the IGS_PS_UNIT set attempt.

            -- Added CATALOG_CAL_TYPE and CATALOG_SEQ_NUM parameters
            -- to call IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW as per the
            -- Career impact Build Bug# 2027984.

                IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW(
                                X_ROWID             => V_ROWID,
                            X_PERSON_ID             => P_PERSON_ID,
                            X_COURSE_CD             => P_COURSE_CD,
                            X_UNIT_SET_CD           => V_UNIT_SET_CD,
                            X_SEQUENCE_NUMBER       => V_SEQUENCE_NUMBER,
                            X_US_VERSION_NUMBER         => V_US_VERSION_NUMBER,
                            X_SELECTION_DT          => V_SELECTION_DT,
                            X_STUDENT_CONFIRMED_IND     => V_STUDENT_CONFIRMED_IND,
                            X_END_DT            => P_END_DT,
                            X_PARENT_UNIT_SET_CD        => V_PARENT_UNIT_SET_CD,
                            X_PARENT_SEQUENCE_NUMBER    => V_PARENT_SEQUENCE_NUMBER,
                            X_PRIMARY_SET_IND       => V_PRIMARY_SET_IND,
                            X_VOLUNTARY_END_IND         => P_VOLUNTARY_END_IND,
                            X_AUTHORISED_PERSON_ID      => V_AUTHORISED_PERSON_ID,
                            X_AUTHORISED_ON         => V_AUTHORISED_ON,
                            X_OVERRIDE_TITLE        => V_OVERRIDE_TITLE,
                            X_RQRMNTS_COMPLETE_IND      => V_RQRMNTS_COMPLETE_IND,
                            X_RQRMNTS_COMPLETE_DT       => V_RQRMNTS_COMPLETE_DT,
                            X_S_COMPLETED_SOURCE_TYPE   => V_S_COMPLETED_SOURCE_TYPE,
                            X_CATALOG_CAL_TYPE          => V_CATALOG_CAL_TYPE,
                            X_CATALOG_SEQ_NUM       => V_CATALOG_SEQ_NUM,
                            X_ATTRIBUTE_CATEGORY          => V_ATTRIBUTE_CATEGORY,          --kkillams attribute_category to attribute20  parameters are added to
                            X_ATTRIBUTE1                               => V_ATTRIBUTE1,                 --IGS_AS_SU_SETATMPT_PKG.update_row call  w.r.t to YOP-EN bug id :2156956
                            X_ATTRIBUTE2                               => V_ATTRIBUTE2,
                            X_ATTRIBUTE3                               => V_ATTRIBUTE3,
                            X_ATTRIBUTE4                               => V_ATTRIBUTE4,
                            X_ATTRIBUTE5                               => V_ATTRIBUTE5,
                            X_ATTRIBUTE6                               => V_ATTRIBUTE6,
                            X_ATTRIBUTE7                               => V_ATTRIBUTE7,
                            X_ATTRIBUTE8                               => V_ATTRIBUTE8,
                            X_ATTRIBUTE9                               => V_ATTRIBUTE9,
                            X_ATTRIBUTE10                             => V_ATTRIBUTE10,
                            X_ATTRIBUTE11                             => V_ATTRIBUTE11,
                            X_ATTRIBUTE12                             => V_ATTRIBUTE12,
                            X_ATTRIBUTE13                             => V_ATTRIBUTE13,
                            X_ATTRIBUTE14                             => V_ATTRIBUTE14,
                            X_ATTRIBUTE15                             => V_ATTRIBUTE15,
                            X_ATTRIBUTE16                             => V_ATTRIBUTE16,
                            X_ATTRIBUTE17                             => V_ATTRIBUTE17,
                            X_ATTRIBUTE18                             => V_ATTRIBUTE18,
                            X_ATTRIBUTE19                             => V_ATTRIBUTE19,
                            X_ATTRIBUTE20                             => V_ATTRIBUTE20,
                            X_MODE                        => 'R');



            -- Re-enable triggers for the session.
            IGS_GE_MNT_SDTT.genp_del_sdtt('IGS_AS_SU_SETATMPT');
        END IF;
        FETCH c_susa INTO   v_rowid,
                    v_unit_set_cd,
                    v_us_version_number,
                    v_sequence_number,
                    v_authorised_person_id,
                    v_authorised_on,
                    v_selection_dt,
                    v_end_dt,
                    v_rqrmnts_complete_dt,
                    v_parent_unit_set_cd,
                    v_parent_sequence_number,
                    v_student_confirmed_ind,
                    v_primary_set_ind,
                    v_voluntary_end_ind,
                    v_override_title,
                    v_rqrmnts_complete_ind,
                    v_s_completed_source_type,
                    v_catalog_cal_type,
                    v_catalog_seq_num,
                    v_attribute_category,                       --kkillams variables attribute_category to attribute20  are added  w.r.t to YOP-EN bug id :2156956
                        v_attribute1,
                        v_attribute2,
                        v_attribute3,
                        v_attribute4,
                        v_attribute5,
                        v_attribute6,
                        v_attribute7,
                        v_attribute8,
                        v_attribute9,
                        v_attribute10,
                        v_attribute11,
                        v_attribute12,
                        v_attribute13,
                        v_attribute14,
                        v_attribute15,
                        v_attribute16,
                        v_attribute17,
                        v_attribute18,
                        v_attribute19,
                        v_attribute20;
    END LOOP;
    CLOSE c_susa;
    -- If processing successful then
    RETURN TRUE;
EXCEPTION
    -- If an exception is raised indicating a lock on the current record,
    -- return false and an error.
    WHEN resource_busy_exception THEN
        IF c_susa%ISOPEN THEN
            CLOSE c_susa;
        END IF;
        p_message_name := 'IGS_EN_DESCENDANT_UNIT_SET';
        RETURN FALSE;
    WHEN OTHERS THEN
        IF c_susa%ISOPEN THEN
            CLOSE c_susa;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_013.enrp_upd_susa_end_dt');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_upd_susa_end_dt;

Function Enrp_Upd_Susa_Sci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_student_confirmed_ind IN VARCHAR2 := 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN  AS

    resource_busy_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy_exception, -54);
BEGIN   -- enrp_upd_susa_sci
    -- This module is called when the student_confimed_ind is unset.
    -- This module will check if the IGS_PS_UNIT set has any child IGS_PS_UNIT sets and
    -- attempt to unset the the student_confirmed_ind for all children.
DECLARE
    v_enrp_val_susa_sci BOOLEAN := TRUE;
    v_susa_rec_found    BOOLEAN := FALSE;
    v_message_name      VARCHAR2(30);
    v_message_text      VARCHAR2 (2000);
    v_rowid         ROWID;
    CURSOR c_susa IS
    SELECT  susa.ROWID,
        susa.unit_set_cd,
        susa.us_version_number,
        susa.sequence_number,
        susa.authorised_person_id,
        susa.authorised_on,
        susa.selection_dt,
        susa.end_dt,
        susa.rqrmnts_complete_dt,
        susa.parent_unit_set_cd,
        susa.parent_sequence_number,
        susa.student_confirmed_ind,
        susa.primary_set_ind,
        susa.voluntary_end_ind,
        susa.override_title,
        susa.rqrmnts_complete_ind,
        susa.s_completed_source_type,
        susa.catalog_cal_type,
        susa.catalog_seq_num,
        susa.attribute_category,            --kkillams columns attribute_category to attribute20 added to cursor w.r.t to YOP-EN bug id :2156956
        susa.attribute1,
        susa.attribute2,
        susa.attribute3,
        susa.attribute4,
        susa.attribute5,
        susa.attribute6,
        susa.attribute7,
        susa.attribute8,
        susa.attribute9,
        susa.attribute10,
        susa.attribute11,
        susa.attribute12,
        susa.attribute13,
        susa.attribute14,
        susa.attribute15,
        susa.attribute16,
        susa.attribute17,
        susa.attribute18,
        susa.attribute19,
        susa.attribute20
    FROM    IGS_AS_SU_SETATMPT susa
    START WITH  susa.person_id          = p_person_id   AND
            susa.course_cd          = p_course_cd   AND
            susa.parent_unit_set_cd     = p_unit_set_cd AND
            susa.parent_sequence_number     = p_sequence_number
    CONNECT BY
    PRIOR   susa.person_id      = susa.person_id        AND
    PRIOR   susa.course_cd      = susa.course_cd        AND
    PRIOR   susa.unit_set_cd    = susa.parent_unit_set_cd   AND
    PRIOR   susa.sequence_number    = susa.parent_sequence_number
    FOR UPDATE OF student_confirmed_ind,
                  selection_dt NOWAIT;
    L_ROWID VARCHAR2(25);
BEGIN
    -- Set the default message number
    p_message_name := null;
    -- If student confirmed indicator is NULL or 'Y' then
    -- not concerned with updating children
    IF p_student_confirmed_ind = 'Y' OR
            p_student_confirmed_ind IS NULL THEN
        p_message_name := null;
        RETURN TRUE;
    END IF;
    -- Process all descendants of the IGS_PS_UNIT set and attempt
    -- to unset the student confirmed indicator.
    -- For each descendant record found, unset the student confirmed indicator.
    FOR v_susa_rec IN c_susa LOOP
        v_susa_rec_found := TRUE;
        IF v_susa_rec.student_confirmed_ind = 'Y' THEN
            -- Validate that able to update the record.
             IF IGS_EN_VAL_SUSA.enrp_val_susa(
                        p_person_id,
                        p_course_cd,
                        v_susa_rec.unit_set_cd,
                        v_susa_rec.sequence_number,
                        v_susa_rec.us_version_number,
                        NULL,   -- selection_dt
                        'N',    -- student_confirmed_ind
                        v_susa_rec.end_dt,
                        v_susa_rec.parent_unit_set_cd,
                        v_susa_rec.parent_sequence_number,
                        v_susa_rec.primary_set_ind,
                        v_susa_rec.voluntary_end_ind,
                        v_susa_rec.authorised_person_id,
                        v_susa_rec.authorised_on,
                        v_susa_rec.override_title,
                        v_susa_rec.rqrmnts_complete_ind,
                        v_susa_rec.rqrmnts_complete_dt,
                        v_susa_rec.s_completed_source_type,
                        'UPDATE',
                        v_message_name,
                        v_message_text) = FALSE THEN
                -- IGS_GE_NOTE: The IGS_RU_RULE check will only be called when confirming the IGS_PS_UNIT set.
                -- Hence no need to check and handle if v_message_text returned.
                p_message_name := v_message_name;
                v_enrp_val_susa_sci := FALSE;
                EXIT;
            END IF;
            -- Disable triggers for the session  as this is a cascading update and as
            -- such creates problems accessing the PL/SQL table when called in the
            -- after statement trigger.

            -- Inserts a record into the s_disable_table_trigger
            -- database table.
            IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
                X_ROWID => L_ROWID ,
                X_TABLE_NAME =>'IGS_AS_SU_SETATMPT',
                X_SESSION_ID => userenv('SESSIONID'),
                x_mode => 'R'
                );

            -- If valid, then unset the student confirmed indicator.

            -- Added CATALOG_CAL_TYPE and CATALOG_SEQ_NUM parameters
            -- to call IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW as per the
            -- Career impact Build Bug# 2027984.

                IGS_AS_SU_SETATMPT_PKG.UPDATE_ROW(X_ROWID           => v_susa_rec.rowid,
                            X_PERSON_ID             => P_PERSON_ID,
                            X_COURSE_CD             => P_COURSE_CD,
                            X_UNIT_SET_CD           => v_susa_rec.unit_set_cd,
                            X_SEQUENCE_NUMBER       => v_susa_rec.sequence_number,
                            X_US_VERSION_NUMBER         => v_susa_rec.us_version_number,
                            X_SELECTION_DT          => NULL,
                            X_STUDENT_CONFIRMED_IND     => 'N',
                            X_END_DT            => v_susa_rec.end_dt,
                            X_PARENT_UNIT_SET_CD        => v_susa_rec.parent_unit_set_cd,
                            X_PARENT_SEQUENCE_NUMBER    => v_susa_rec.parent_sequence_number,
                            X_PRIMARY_SET_IND       => v_susa_rec.primary_set_ind,
                            X_VOLUNTARY_END_IND         => v_susa_rec.voluntary_end_ind,
                            X_AUTHORISED_PERSON_ID      => v_susa_rec.authorised_person_id,
                            X_AUTHORISED_ON         => v_susa_rec.authorised_on,
                            X_OVERRIDE_TITLE        => v_susa_rec.override_title,
                            X_RQRMNTS_COMPLETE_IND      => v_susa_rec.rqrmnts_complete_ind,
                            X_RQRMNTS_COMPLETE_DT       => v_susa_rec.rqrmnts_complete_dt,
                            X_S_COMPLETED_SOURCE_TYPE   => v_susa_rec.s_completed_source_type,
                            X_CATALOG_CAL_TYPE          => v_susa_rec.catalog_cal_type,
                            X_CATALOG_SEQ_NUM       => v_susa_rec.catalog_seq_num,
                            X_ATTRIBUTE_CATEGORY          => v_susa_rec.attribute_category,          --kkillams attribute_category to attribute20 parameters are added to
                            X_ATTRIBUTE1                               => v_susa_rec.attribute1,                --IGS_AS_SU_SETATMPT_PKG.update_row call  w.r.t to YOP-EN bug id :2156956
                            X_ATTRIBUTE2                               => v_susa_rec.attribute2,
                            X_ATTRIBUTE3                               => v_susa_rec.attribute3,
                            X_ATTRIBUTE4                               => v_susa_rec.attribute4,
                            X_ATTRIBUTE5                               => v_susa_rec.attribute5,
                            X_ATTRIBUTE6                               => v_susa_rec.attribute6,
                            X_ATTRIBUTE7                               => v_susa_rec.attribute7,
                            X_ATTRIBUTE8                               => v_susa_rec.attribute8,
                            X_ATTRIBUTE9                               => v_susa_rec.attribute9,
                            X_ATTRIBUTE10                             => v_susa_rec.attribute10,
                            X_ATTRIBUTE11                             => v_susa_rec.attribute11,
                            X_ATTRIBUTE12                             => v_susa_rec.attribute12,
                            X_ATTRIBUTE13                             => v_susa_rec.attribute13,
                            X_ATTRIBUTE14                             => v_susa_rec.attribute14,
                            X_ATTRIBUTE15                             => v_susa_rec.attribute15,
                            X_ATTRIBUTE16                             => v_susa_rec.attribute16,
                            X_ATTRIBUTE17                             => v_susa_rec.attribute17,
                            X_ATTRIBUTE18                             => v_susa_rec.attribute18,
                            X_ATTRIBUTE19                             => v_susa_rec.attribute19,
                            X_ATTRIBUTE20                             => v_susa_rec.attribute20,
                            X_MODE                        => 'R'
                            );


            -- Re-enable triggers for the session.
            IGS_GE_MNT_SDTT.genp_del_sdtt('IGS_AS_SU_SETATMPT');
        END IF;
    END LOOP;
    IF (v_susa_rec_found = TRUE AND
            v_enrp_val_susa_sci = FALSE) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
EXCEPTION
    -- If an exception raise indicating a lock on the current record,
    -- return false and errror message. Declare an exception
    WHEN resource_busy_exception THEN
        IF c_susa%ISOPEN THEN
            CLOSE c_susa;
        END IF;
        p_message_name := 'IGS_EN_DESCENDANT_UNITSET_LOC';
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
                Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_013.enrp_upd_susa_sci');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_upd_susa_sci;

END IGS_EN_GEN_013;

/
