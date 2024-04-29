--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_007" AS
/* $Header: IGSEN07B.pls 120.1 2005/09/29 22:11:19 appldev ship $ */
/*    Who            When                               What
      pkpatel        26-MAR-2003                        Bug 2261717
                                                            Tuned the Function Enrp_Get_Student_Ind
      jbegum         21 Mar 02                          As part of big fix of bug #2192616
                                                        Removed the exception handling part of the
                                                        function enrp_get_sua_incur.This was done in order
                                                        to allow the user defined exception NO_AUSL_RECORD_FOUND
                                                        coming from IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR
                                                        to propagate to the form IGSPS047 and be handled accordingly
                                                        instead of coming as an unhandled exception.

      nalkumar       06 May 2002                        Added p_waitlisted_dt parameter (and code logic related to it) in the Enrp_Get_Sua_Status procedure.
                                                        This is as per the Bug# 2335455.
*/

Function Enrp_Get_Student_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
/* change history
   WHO       WHEN         WHAT
   pkpatel   26-MAR-2003  Bug 2261717
                          Filter the query for efficiency. Removed the COUNT(*) and
                                                  replaced igs_pe_typ_instances with igs_pe_typ_instances_all.
   stutta    31-MAR-2004  Bug 3518606, Changed cursor c_aa by not truncating the sysdate
                          for checking if the person is valid on the current day.

 */
        cst_yes         CONSTANT VARCHAR2(1) := 'Y';
        cst_no          CONSTANT VARCHAR2(1) := 'N';
        --v_other_detail        VARCHAR2(255);
        v_count         NUMBER;
        v_output        VARCHAR2(1);

        -- (pathipat) Cursor c_aa modified for performance issues, Bug No: 2432563

        CURSOR  c_aa (cp_person_id   IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  1
                FROM    igs_pe_typ_instances_all pti, igs_pe_person_types pty
                WHERE   pti.person_type_code = pty.person_type_code AND
                        pty.system_type = 'STUDENT' AND
                        pti.person_id = cp_person_id AND
                        sysdate BETWEEN start_date AND NVL(end_date,sysdate);
BEGIN
        -- This module determines whether or not a Person is a student
        -- and returns the appropriate indicator.

        OPEN  c_aa (p_person_id);
        FETCH c_aa INTO v_count;
        IF c_aa%FOUND THEN

                CLOSE c_aa;
                v_output := cst_yes;
                RETURN v_output;

        END IF;
        CLOSE c_aa;

        v_output := cst_no;
        RETURN v_output;

END enrp_get_student_ind;

FUNCTION Enrp_Get_Suah_Col(
  p_column_name         IN user_tab_columns.column_name%TYPE ,
  p_person_id           IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd           IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd             IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type            IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_number  IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_end_dt         IN IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE,
  p_uoo_id              IN IGS_EN_SU_ATTEMPT_H_ALL.UOO_ID%TYPE)
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    25-04-2003      New paramater p_uoo_id is added to the function and c_suah cursor modified.
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
RETURN VARCHAR2 AS
        gv_other_detail         Varchar2(255);
BEGIN
DECLARE
        CURSOR c_suah(
                        cp_column_name          user_tab_columns.column_name%TYPE,
                        cp_person_id            IGS_EN_SU_ATTEMPT_H.person_id%TYPE,
                        cp_course_cd            IGS_EN_SU_ATTEMPT_H.course_cd%TYPE,
                        cp_uoo_id               IGS_EN_SU_ATTEMPT_H.uoo_id%TYPE,
                        cp_hist_end_dt          IGS_EN_SU_ATTEMPT_H.hist_end_dt%TYPE) IS
                SELECT  DECODE ( cp_column_name,
                                'VERSION_NUMBER',               TO_CHAR(suah.version_number),
                                'LOCATION_CD',                  suah.location_cd,
                                'UNIT_CLASS',                   suah.unit_class,
                                'ENROLLED_DT',                  igs_ge_date.igscharDT(suah.enrolled_dt),
                                'UNIT_ATTEMPT_STATUS',          suah.unit_attempt_status,
                                'ADMINISTRATIVE_UNIT_STATUS',   suah.ADMINISTRATIVE_UNIT_STATUS,
                                'DISCONTINUED_DT',              igs_ge_date.igscharDT(suah.discontinued_dt),
                                'RULE_WAIVED_DT',               igs_ge_date.igscharDT(suah.rule_waived_dt),
                                'RULE_WAIVED_PERSON_ID',        TO_CHAR(suah.rule_waived_person_id),
                                'NO_ASSESSMENT_IND',            suah.no_assessment_ind,
                                'EXAM_LOCATION_CD',             suah.exam_location_cd,
                                'SUP_VERSION_NUMBER',           TO_CHAR(suah.sup_version_number),
                                'ALTERNATIVE_TITLE',            suah.alternative_title,
                                'OVERRIDE_ENROLLED_CP',         TO_CHAR(suah.override_enrolled_cp),
                                'OVERRIDE_EFTSU',               TO_CHAR(suah.override_eftsu),
                                'OVERRIDE_ACHIEVABLE_CP',       TO_CHAR(suah.override_achievable_cp),
                                'OVERRIDE_OUTCOME_DUE_DT',      igs_ge_date.igscharDT(suah.override_outcome_due_dt),
                                'OVERRIDE_CREDIT_REASON',       suah.override_credit_reason)
                FROM    IGS_EN_SU_ATTEMPT_H suah
                WHERE   suah.person_id          =       cp_person_id AND
                        suah.course_cd          =       cp_course_cd AND
                        suah.uoo_id             =       cp_uoo_id AND
                        suah.hist_start_dt      >=      cp_hist_end_dt
                ORDER BY
                        suah.hist_start_dt ASC;
        v_column_value                  VARCHAR2(2000);
BEGIN
        OPEN c_suah (p_column_name,
                     p_person_id,
                     p_course_cd,
                     p_uoo_id,
                     p_hist_end_dt);
        LOOP
                FETCH c_suah INTO v_column_value;
                IF c_suah%NOTFOUND THEN
                        CLOSE c_suah;
                        RETURN NULL;
                END IF;
                IF NVL(v_column_value,'NULL') <> 'NULL' THEN
                        CLOSE c_suah;
                        RETURN v_column_value;
                END IF;
        END LOOP;
        CLOSE c_suah;
        RETURN NULL;
END;
EXCEPTION
        WHEN OTHERS THEN
                gv_other_detail := 'Parm: p_column_name - ' || p_column_name
                        || ', p_person_id - ' || TO_CHAR(p_person_id)
                        || ', p_course_cd - ' || p_course_cd
                        || ', p_unit_cd - ' || p_unit_cd
                        || ', p_cal_type - ' || p_cal_type
                        || ', p_ci_sequence_number - ' || TO_CHAR(p_ci_sequence_number)
                        || ', p_hist_end_dt - ' || igs_ge_date.igscharDT(p_hist_end_dt)
                        || ', p_uoo_id - ' || TO_CHAR(p_uoo_id);

                RAISE;
END enrp_get_suah_col;

FUNCTION Enrp_Get_Sua_Incur(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_unit_cd                     IN VARCHAR2 ,
  p_unit_version_number         IN NUMBER ,
  p_cal_type                    IN VARCHAR2 ,
  p_ci_sequence_number          IN NUMBER ,
  p_unit_attempt_status         IN VARCHAR2 ,
  p_discontinued_dt             IN DATE ,
  p_administrative_unit_status  IN VARCHAR2,
  p_uoo_id                      IN NUMBER)
  -------------------------------------------------------------------------------------------
  -- enrp_get_sua_incur
  -- Returbs whether a IGS_PS_UNIT attempt has incurred load.  This routine
  -- is not specidic to a load calendar, but rather only looks to see
  -- if the attempt has incurred load in its first load period.
  --Change History:
  --Who         When            What
  --jbegum      21 Mar 02       As part of big fix of bug #2192616
  --                            Removed the exception handling part of the
  --                            function enrp_get_sua_incur.This was done in order
  --                            to allow the user defined exception NO_AUSL_RECORD_FOUND
  --                            coming from IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR
  --                            to propagate to the form IGSPS047 and be handled accordingly
  --                            instead of coming as an unhandled exception.
  --kkillams    25-04-2003      New paramater p_uoo_id is added to the function and cur_sua cursor modified.
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
RETURN VARCHAR2 AS
BEGIN
DECLARE
        v_acad_cal_type                 IGS_CA_INST.cal_type%TYPE;
        v_acad_ci_sequence_number       IGS_CA_INST.sequence_number%TYPE;
        v_acad_start_dt                 IGS_CA_INST.start_dt%TYPE;
        v_acad_end_dt                   IGS_CA_INST.end_dt%TYPE;
        v_message_name                  Varchar2(30);
        v_alternate_code                IGS_CA_INST.alternate_code%TYPE;
        v_return_type                   VARCHAR2(1);
        cst_load                        CONSTANT        VARCHAR2(10) := 'LOAD';
        cst_active                      CONSTANT        VARCHAR2(10) := 'ACTIVE';
        cst_yes                         CONSTANT        VARCHAR2(1) := 'Y';
        cst_no                          CONSTANT        VARCHAR2(1) := 'N';
        CURSOR  c_ci_cat_cs (cp_acad_cal_type   IGS_CA_INST.cal_type%TYPE,
                             cp_acad_ci_sequence_number
                             IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  ci.cal_type,
                        ci.sequence_number
                FROM    IGS_CA_INST     ci,
                        IGS_CA_TYPE     cat,
                        IGS_CA_STAT     cs
                WHERE   cat.cal_type    = ci.cal_type AND
                        cat.s_cal_cat   = cst_load AND
                        cs.cal_status   = ci.cal_status AND
                        cs.s_cal_status = cst_active AND
                        IGS_EN_GEN_014.enrs_get_within_ci (
                                                cp_acad_cal_type,
                                                cp_acad_ci_sequence_number,
                                                ci.cal_type,
                                                ci.sequence_number,
                                                cst_yes) = cst_yes
                ORDER BY ci.start_dt;

        -- cursor added as a part of impact objects of Enrollment Process DLD (BUG No:1832130)
        -- analysis to get uoo_id for the parameters
        -- passed into the function, parameter uoo_id is added to the function
        -- igs_en_prc_load.enrp_get_load_incur, inturn will use it in calling
        -- igs_en_gen_008.enrp_get_uddc_aus function
        CURSOR cur_sua
        IS
        SELECT no_assessment_ind
        FROM  igs_en_su_attempt
        WHERE person_id          = p_person_id
        AND   course_cd          = p_course_cd
        AND   uoo_id             = p_uoo_id;

        l_cur_sua  cur_sua%ROWTYPE;  -- cursor rowtype variable

BEGIN
        -- Get the academic period in which the teaching calendar commences
        v_alternate_code := IGS_EN_GEN_002.enrp_get_acad_alt_cd (
                                                p_cal_type,
                                                p_ci_sequence_number,
                                                v_acad_cal_type,
                                                v_acad_ci_sequence_number,
                                                v_acad_start_dt,
                                                v_acad_end_dt,
                                                v_message_name);
        IF v_acad_cal_type IS NULL THEN
                RETURN cst_no;
        END IF;

        -- cursor is opened to get a uoo_id for the parameters passed
        OPEN  cur_sua;
        FETCH cur_sua INTO l_cur_sua;
        CLOSE cur_sua;

        -- Loop through all load calendars in the academic year.  If the
        -- student incurs load within any of them return Y.
        FOR v_ci_cat_cs_rec IN c_ci_cat_cs (v_acad_cal_type,
                                            v_acad_ci_sequence_number) LOOP

                -- As part of the bug# 1956374 changed to the below call from  IGS_EN_GEN_005.ENRP_GET_LOAD_INCUR
                IF IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR (p_cal_type,
                                                        p_ci_sequence_number,
                                                        p_discontinued_dt,
                                                        p_administrative_unit_status,
                                                        p_unit_attempt_status,
                                                        l_cur_sua.no_assessment_ind,
                                                        v_ci_cat_cs_rec.cal_type,
                                                        v_ci_cat_cs_rec.sequence_number,
                                                        p_uoo_id,
							-- anilk, Audit special fee build
							'N'
                                                      ) = cst_yes THEN
                        v_return_type := cst_yes;
                        EXIT;
                END IF;
        END LOOP;
        IF v_return_type = cst_yes THEN
                RETURN cst_yes;
        END IF;
        RETURN cst_no;
END;
END enrp_get_sua_incur;

FUNCTION Enrp_Get_Sua_Status(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_version_number      IN NUMBER ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_enrolled_dt         IN DATE ,
  p_rule_waived_dt      IN DATE ,
  p_discontinued_dt     IN DATE ,
  p_waitlisted_dt       IN DATE DEFAULT NULL, -- Added p_waitlist_dt parameter as per the Bug# 2335455.
  p_uoo_id              IN NUMBER)
 -------------------------------------------------------------------------------------------
 -- Added for Enhancement, Enrollments: Registration Enhancements and Class Lists
 -- Modified the c_chk_suao_exists cursor, If the grading_period is FINAL then only returning the unit_attempt_status COMPLETED. pmarada,bug 2395762
 --Who         When            What
 --kkillams    25-04-2003      New paramater p_uoo_id is added to the function.c_get_db_param_values,
 --                            c_chk_suao_exists and c_sut cursors modified. w.r.t. bug number 2829262
 -- ctyagi     29-Sept-2005    Modified cursor c_sut for bug number 4488779
 -------------------------------------------------------------------------------------------
RETURN VARCHAR2 AS

BEGIN
DECLARE

        cst_dropped             CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DROPPED';
        cst_unconfirm           CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'UNCONFIRM';
        cst_waitlisted          CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'WAITLISTED';
        cst_discontin           CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DISCONTIN';
        cst_enrolled            CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'ENROLLED';
        cst_completed           CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'COMPLETED';
        cst_invalid             CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'INVALID';
        cst_duplicate           CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DUPLICATE';
        cst_no                  CONSTANT IGS_AS_SU_STMPTOUT.finalised_outcome_ind%TYPE := 'N';
        cst_yes                 CONSTANT IGS_AS_SU_STMPTOUT.finalised_outcome_ind%TYPE := 'Y';
        cst_grading_period_cd   igs_as_su_stmptout.grading_period_cd%TYPE := 'FINAL';
        v_exists_flag           VARCHAR2(1);
        v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        v_enrolled_dt           IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE;
        v_rule_waived_dt        IGS_EN_SU_ATTEMPT.rule_waived_dt%TYPE;
        v_discontinued_dt       IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;

        CURSOR c_get_db_param_values IS
                SELECT  unit_attempt_status,
                        enrolled_dt,
                        rule_waived_dt,
                        discontinued_dt
                FROM    IGS_EN_SU_ATTEMPT
                WHERE   person_id = p_person_id                 AND
                        course_cd = p_course_cd                 AND
                        uoo_id    = p_uoo_id;
        CURSOR c_chk_suao_exists IS
                SELECT  'x'
                FROM    sys.dual
                WHERE   EXISTS (
                        SELECT  'x'
                        FROM    IGS_AS_SU_STMPTOUT
                        WHERE   person_id = p_person_id                         AND
                                course_cd = p_course_cd                         AND
                                uoo_id    = p_uoo_id                            AND
                                finalised_outcome_ind = cst_yes                 AND
                                s_grade_creation_method_type <> cst_discontin   AND
                                grading_period_cd = cst_grading_period_cd
                        );
        CURSOR c_sut IS
                SELECT  sua.unit_attempt_status
                FROM    IGS_PS_STDNT_UNT_TRN sut1, IGS_EN_SU_ATTEMPT sua
                WHERE   sut1.person_id = p_person_id AND
                        sut1.course_cd = p_course_cd AND
                        sua.person_id = sut1.person_id AND
                        sua.course_cd = sut1.transfer_course_cd AND
                        sua.uoo_id = sut1.uoo_id AND
                        sut1.uoo_id = p_uoo_id AND
                        sut1.transfer_dt = ( SELECT max(sut2.transfer_dt)
                                      FROM IGS_PS_STDNT_UNT_TRN sut2
                                      where sut2.person_id = sut1.person_id
                                      and sut2.course_cd = sut1.course_cd
                                      and sut2.uoo_id = sut1.uoo_id)
                        AND sut1.transfer_dt > (SELECT NVL(max(sut3.transfer_dt),(sut1.transfer_dt-1))
                                      FROM IGS_PS_STDNT_UNT_TRN sut3
                                      where sut3.person_id = sut1.person_id
                                      and sut3.transfer_course_cd = sut1.course_cd
                                      and sut3.uoo_id = sut1.uoo_id);
       v_sut_rec c_sut%ROWTYPE;
BEGIN
        IF p_unit_attempt_status IS NULL THEN
                OPEN c_get_db_param_values;
                FETCH c_get_db_param_values INTO v_unit_attempt_status,
                        v_enrolled_dt,
                        v_rule_waived_dt,
                        v_discontinued_dt;
                IF c_get_db_param_values%NOTFOUND THEN
                        CLOSE c_get_db_param_values;
                        RETURN NULL;
                END IF;
                CLOSE c_get_db_param_values;
        ELSE
                -- Use parameters instead of selected student IGS_PS_UNIT attempt
                -- information to set v_ values.
                v_unit_attempt_status := p_unit_attempt_status;
                v_enrolled_dt := p_enrolled_dt;
                v_rule_waived_dt := p_rule_waived_dt;
                v_discontinued_dt := p_discontinued_dt;
        END IF;
-- Added for Enhancement, Enrollments: Registration Enhancements and Class Lists
-- Unit is Discontinued prior to the date specified in Unit Discontinuation Criteria, So Dropping the Unit
        IF v_unit_attempt_status  = cst_dropped THEN
                RETURN cst_dropped;
        END IF;

        --
        -- Added the next If condition to fix Bug# 2335455.
        -- If the waitlisted date is not null then the Unit Attempt Status is 'WAITLISTED'.
        IF p_waitlisted_dt IS NOT NULL THEN
          RETURN cst_waitlisted;
        END IF;


        -- Status of invalid is not altered by this routine unless the
        -- IGS_RU_RULE waived date has been set
        IF v_unit_attempt_status  = cst_invalid AND
                         v_rule_waived_dt IS NULL THEN
                RETURN cst_invalid;
        END IF;
        -- Status is unconfirmed if enrolled date is not set
        IF v_enrolled_dt IS NULL THEN
                RETURN cst_unconfirm;
        END IF;
        -- Status is duplicate if IGS_PS_STDNT_UNT_TRN detail exists
        IF v_unit_attempt_status IN (cst_completed,cst_discontin, cst_duplicate) THEN
            OPEN c_sut;
            FETCH c_sut INTO v_sut_rec;
            IF c_sut%FOUND THEN
                    CLOSE c_sut;
                    IF v_sut_rec.unit_attempt_status = v_unit_attempt_status THEN
                      RETURN v_unit_attempt_status;
                    ELSIF v_unit_attempt_status = cst_duplicate THEN
                      RETURN cst_duplicate;
                    END IF;
            END IF;
            IF c_sut%ISOPEN THEN
              CLOSE c_sut;
            END IF;
        END IF;
        -- Status is discontinued if discontinued date is set
        IF  v_discontinued_dt IS NOT NULL THEN
                RETURN cst_discontin;
        END IF;
        -- Status is completed when one student IGS_PS_UNIT attempt outcome exists
        -- with finalised outcome indicator set and not created by discontinuation
        OPEN c_chk_suao_exists;
        FETCH c_chk_suao_exists INTO v_exists_flag;
        IF c_chk_suao_exists%FOUND THEN
                CLOSE c_chk_suao_exists;
                RETURN cst_completed;
        END IF;
        CLOSE c_chk_suao_exists;
        -- Status must be enrolled
        RETURN cst_enrolled;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_get_db_param_values%ISOPEN) THEN
                        CLOSE c_get_db_param_values;
                END IF;
                IF (c_chk_suao_exists%ISOPEN) THEN
                        CLOSE c_chk_suao_exists;
                END IF;
                IF (c_sut%ISOPEN) THEN
                        CLOSE c_sut;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_007.enrp_get_sua_status');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_sua_status;

Function Enrp_Get_Susa_Status(
  p_selection_dt IN DATE ,
  p_student_confirmed_ind IN VARCHAR2 ,
  p_end_dt IN DATE ,
  p_rqrmnts_complete_ind IN VARCHAR2 )
RETURN VARCHAR2 AS

BEGIN   -- enrp_get_susa_status
        -- Get logical status of IGS_AS_SU_SETATMPT, being one of:
        --      * UNCONFIRM, ACTIVE, COMPLETED OR ENDED.
DECLARE
        cst_unconfirm   CONSTANT        VARCHAR2(10) := 'UNCONFIRM';
        cst_active      CONSTANT        VARCHAR2(10) := 'ACTIVE';
        cst_completed   CONSTANT        VARCHAR2(10) := 'COMPLETED';
        cst_ended       CONSTANT        VARCHAR2(5) := 'ENDED';
BEGIN
        IF p_student_confirmed_ind = 'N' OR
                        p_selection_dt IS NULL THEN
                RETURN cst_unconfirm;
        ELSE
                IF p_end_dt IS NULL AND
                                p_rqrmnts_complete_ind = 'N' THEN
                        RETURN cst_active;
                ELSIF p_end_dt IS NOT NULL THEN
                        RETURN cst_ended;
                ELSE
                        RETURN cst_completed;
                END IF;
        END IF;
END;
/*
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        App_Exception.Raise_Exception;
*/
END enrp_get_susa_status;

END IGS_EN_GEN_007;

/
