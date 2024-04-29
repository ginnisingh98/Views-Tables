--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_006" AS
/* $Header: IGSEN06B.pls 120.4 2006/04/13 01:51:56 smaddali ship $ */

 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  --pradhakr   15-Jan-03        Modified the call to the function enrp_get_load_incur to add
  --                            a parameter no_assessment_ind. Changes wrt Bug# 2743459.
  --smvk       09-Jul-2004      Bug # 3676145. Modified the cursors c_sua_um and c_suaeh to select active (not closed) unit classes.
  -- rnirwani   13-Sep-2004    changed cursor c_sci (Enrp_Get_Sca_Elgbl) to not consider logically deleted records and
  --				also to avoid un-approved intermission records. Bug# 3885804
  -- ctyagi     20-feb-2005      Removed the function Enrp_Get_Sca_Hist_Am. Bug# 3712531
  -- smaddali  10-apr-06         Added new column for bug#5091858 BUILD EN324
  -------------------------------------------------------------------------------------------

Function Enrp_Get_Sca_Acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS

BEGIN   -- enrp_get_sca_acad
    -- Determine the academic calendar type and sequence number for the
    -- IGS_PS_COURSE offering option calendar type.
    -- This is required for validation purposes during a IGS_PS_COURSE transfer.
DECLARE
    v_cal_type          IGS_CA_INST.cal_type%TYPE;
    v_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE;
    v_acad_cal_type         IGS_CA_INST.cal_type%TYPE;
    v_acad_ci_sequence_number   IGS_CA_INST.sequence_number%TYPE;
    v_acad_ci_start_dt      IGS_CA_INST.start_dt%TYPE;
    v_acad_ci_end_dt        IGS_CA_INST.end_dt%TYPE;
    v_message_name          VARCHAR2(30);
    v_alternate_code        IGS_CA_INST.alternate_code%TYPE;
    v_enrolment_cat         IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
    CURSOR  c_scae_ci IS
        SELECT  scae.cal_type,
            scae.ci_sequence_number,
            scae.enrolment_cat
        FROM    IGS_AS_SC_ATMPT_ENR scae,
            IGS_CA_INST     ci
        WHERE   scae.person_id      = p_person_id AND
            scae.course_cd      = p_course_cd AND
            scae.cal_type       = ci.cal_type AND
            scae.ci_sequence_number = ci.sequence_number
        ORDER BY ci.start_dt DESC;
BEGIN
    p_message_name := null;
    -- Check parameters
    IF p_person_id IS NULL OR
            p_course_cd     IS NULL OR
            p_cal_type  IS NULL THEN
        RETURN TRUE;
    END IF;
    -- Get the enrolment period from the latest student IGS_PS_COURSE
    -- attempt enrolment period.
    OPEN c_scae_ci;
    FETCH c_scae_ci INTO v_cal_type,
                v_ci_sequence_number,
                v_enrolment_cat;
    IF (c_scae_ci%NOTFOUND) THEN
        CLOSE c_scae_ci;
        p_ci_sequence_number := NULL;
        p_enrolment_cat := NULL;
        p_message_name := 'IGS_EN_NO_SPA_ENR_EXISTS';
        RETURN FALSE;
    END IF;
    CLOSE c_scae_ci;
    p_enrolment_cat := v_enrolment_cat;
    -- Check if a link exists for the teaching period to the
    -- academic calendar of the new IGS_PS_COURSE offering option.
    v_alternate_code := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD (
                        v_cal_type,
                        v_ci_sequence_number,
                        v_acad_cal_type,
                        v_acad_ci_sequence_number,
                        v_acad_ci_start_dt,
                        v_acad_ci_end_dt,
                        v_message_name);
    IF v_acad_cal_type <> p_cal_type THEN
        p_message_name := 'IGS_EN_NOLINK_EXISTS_STUDENR';
        RETURN FALSE;
    END IF;
    -- complete execution
    IF v_message_name IS NOT NULL THEN
        p_ci_sequence_number := v_ci_sequence_number;
    ELSE
        p_ci_sequence_number := v_acad_ci_sequence_number;
    END IF;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_scae_ci%ISOPEN) THEN
            CLOSE c_scae_ci;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_006.enrp_get_sca_acad');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_get_sca_acad;


Function Enrp_Get_Sca_Am(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
RETURN VARCHAR2 AS

BEGIN   --enrp_get_sca_am
    --This module gets the attendance mode for a nominated
    --student IGS_PS_COURSE attempt within a load calendar instance.
    --This routine checks the 'incurred' status of student IGS_PS_UNIT
    --attempts prior to including them in the calculations.
    --If the student is not enrolled in any applicable units
    --the routine will return NULL.
DECLARE
    cst_composite   CONSTANT    VARCHAR2(10)    := 'COMPOSITE';
    cst_on      CONSTANT    VARCHAR2(2) := 'ON';
    cst_off     CONSTANT    VARCHAR2(3) := 'OFF';
    cst_academic    CONSTANT    VARCHAR2(10)    := 'ACADEMIC';
    cst_active  CONSTANT    VARCHAR2(10)    := 'ACTIVE';
    cst_enrolled    CONSTANT    VARCHAR2(10)    := 'ENROLLED';
    cst_completed   CONSTANT    VARCHAR2(10)    := 'COMPLETED';
    cst_discontin   CONSTANT    VARCHAR2(10)    := 'DISCONTIN';
    v_on_campus BOOLEAN DEFAULT FALSE;
    v_off_campus    BOOLEAN DEFAULT FALSE;
    v_retval    VARCHAR2(10) DEFAULT NULL;
    CURSOR c_ci1 IS
        SELECT  ci1.cal_type,
            ci1.sequence_number
        FROM    IGS_CA_INST ci1,
            IGS_CA_TYPE cat,
            IGS_CA_STAT cs
        WHERE   cat.cal_type    = ci1.cal_type          AND
            cat.s_cal_cat   = cst_academic          AND
            ci1.cal_status  = cs.cal_status         AND
            cs.s_cal_status = cst_active            AND
            IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                    ci1.cal_type,
                    ci1.sequence_number,
                    p_load_cal_type,
                    p_load_sequence_number,
                    'Y') = 'Y';
    CURSOR c_sua_um (
        cp_ci_cal_type      IGS_CA_INST.cal_type%TYPE,
        cp_ci_sequence_number   IGS_CA_INST.sequence_number%TYPE) IS
        SELECT  um.s_unit_mode
        FROM    IGS_EN_SU_ATTEMPT   sua,
                IGS_AS_UNIT_CLASS       ucl,
                IGS_AS_UNIT_MODE        um
        WHERE   sua.person_id       = p_person_id AND
                sua.course_cd       = p_course_cd AND
                sua.unit_attempt_status IN (
                            cst_enrolled,
                            cst_completed,
                            cst_discontin) AND
                IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
                    cp_ci_cal_type,
                    cp_ci_sequence_number,
                    sua.cal_type,
                    sua.ci_sequence_number,
                    'Y')    = 'Y' AND
                IGS_EN_PRC_LOAD.enrp_get_load_incur(
                            sua.cal_type,
                            sua.ci_sequence_number,
                            sua.discontinued_dt,
                            sua.administrative_unit_status,
                            sua.unit_attempt_status,
                            sua.no_assessment_ind,
                            p_load_cal_type,
                            p_load_sequence_number,
                            NULL,
			    -- anilk, Audit special fee build
			    'N') = 'Y' AND
                ucl.unit_class  = sua.unit_class AND
		ucl.closed_ind  = 'N' AND
                um.unit_mode    = ucl.unit_mode;
BEGIN
    FOR v_ci1_rec IN c_ci1 LOOP
        FOR v_sua_um_rec IN c_sua_um(
                        v_ci1_rec.cal_type,
                        v_ci1_rec.sequence_number) LOOP
            --Set flags depending on the mode of the IGS_PS_UNIT attempt
            IF v_sua_um_rec.s_unit_mode = cst_on THEN
                v_on_campus := TRUE;
            ELSIF v_sua_um_rec.s_unit_mode = cst_off THEN
                v_off_campus := TRUE;
            ELSIF v_sua_um_rec.s_unit_mode = cst_composite THEN
                v_on_campus := TRUE;
                v_off_campus := TRUE;
            END IF;
            --If the student is multi modal there is no need to continue
            IF v_on_campus AND
                    v_off_campus THEN
                EXIT;
            END IF;
        END LOOP;   -- v_sua_um_rec
        IF v_on_campus AND
                v_off_campus THEN
            EXIT;
        END IF;
    END LOOP;   -- v_ci1_rec
    IF v_on_campus AND
            v_off_campus THEN
        v_retval := cst_composite;
    ELSIF v_on_campus THEN
        v_retval := cst_on;
    ELSIF v_off_campus THEN
        v_retval := cst_off;
    END IF;
    RETURN v_retval;
EXCEPTION
    WHEN OTHERS THEN
        IF c_ci1%ISOPEN THEN
            CLOSE c_ci1;
        END IF;
        IF c_sua_um%ISOPEN THEN
            CLOSE c_sua_um;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE <>-20001 THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_006.enrp_get_sca_am');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception(NULL,NULL,FND_MESSAGE.GET);
      ELSE
     RAISE;
    END IF;
END enrp_get_sca_am;


Function Enrp_Get_Sca_Att(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN VARCHAR2 AS
BEGIN
DECLARE
    NO_SECC_RECORD_FOUND        EXCEPTION;
    cst_active          CONSTANT VARCHAR2(10) := 'ACTIVE';
    cst_load            CONSTANT VARCHAR2(10) := 'LOAD';
    v_daiv_rec_found        BOOLEAN;
    v_cal_type          IGS_EN_STDNT_PS_ATT.cal_type%TYPE;
    v_load_effect_dt_alias      IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE;
    v_attendance_type       IGS_EN_ATD_TYPE.attendance_type%TYPE;
    v_period_load           IGS_EN_ATD_TYPE_LOAD.lower_enr_load_range%TYPE;
    v_period_credit_points  NUMBER;
    v_current_load_cal_type     IGS_CA_INST.cal_type%TYPE;
    v_current_load_sequence_number  IGS_CA_INST.sequence_number%TYPE;
    v_current_acad_cal_type     IGS_CA_INST.cal_type%TYPE;
    v_current_acad_sequence_number  IGS_CA_INST.sequence_number%TYPE;
    CURSOR  c_stu_crs_atmpt(
                cp_person_id IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd IGS_EN_STDNT_PS_ATT.course_cd%TYPE)IS
        SELECT  SCA.cal_type
        FROM    IGS_EN_STDNT_PS_ATT SCA
        WHERE   SCA.person_id = cp_person_id AND
            SCA.course_cd = cp_course_cd;
    CURSOR  c_s_enr_cal_conf IS
        SELECT  SECC.load_effect_dt_alias
        FROM    IGS_EN_CAL_CONF SECC
        WHERE   SECC.s_control_num = 1;
    CURSOR  c_cal_instance(
                cp_cal_type IGS_CA_INST.cal_type%TYPE,
                cp_effective_dt IGS_CA_INST.start_dt%TYPE)IS
        SELECT  CI.cal_type,
            CI.sequence_number
        FROM    IGS_CA_INST CI,
            IGS_CA_STAT CS
        WHERE   CI.cal_type = cp_cal_type AND
            CI.start_dt <= cp_effective_dt AND
            CI.end_dt >= cp_effective_dt AND
            CS.cal_status = CI.cal_status AND
            CS.s_cal_status = cst_active
        ORDER BY CI.start_dt desc;
    CURSOR  c_cal_type_instance(
                cp_cal_type IGS_CA_INST.cal_type%TYPE,
                cp_sequence_number IGS_CA_INST.sequence_number%TYPE)IS
        SELECT  CI.cal_type,
            CI.sequence_number,
            CI.start_dt,
            CI.end_dt
        FROM    IGS_CA_TYPE CT,
            IGS_CA_INST CI,
            IGS_CA_STAT CS
        WHERE   CT.closed_ind = 'N' AND
            CS.s_cal_status = cst_active AND
            CI.cal_status = CS.cal_status AND
            CT.s_cal_cat = cst_load AND
            CI.cal_type = CT.cal_type AND
            (IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(cp_cal_type,
                        cp_sequence_number,
                        CI.cal_type,
                        CI.sequence_number,
                        'N') = 'Y')
        ORDER BY CI.start_dt asc;
    CURSOR  c_dai_v(
            cp_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
            cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
            cp_load_effect_dt_alias IGS_EN_CAL_CONF.load_effect_dt_alias%TYPE) IS
        SELECT  DAIV.alias_val
        FROM    IGS_CA_DA_INST_V DAIV
        WHERE   DAIV.cal_type = cp_cal_type AND
            DAIV.ci_sequence_number = cp_ci_sequence_number AND
                DAIV.dt_alias = cp_load_effect_dt_alias;
    v_other_detail  VARCHAR(255);
BEGIN
    -- Get the current attendance type for a student IGS_PS_COURSE attempt as at the
    -- effective date. Typically the effective date will be the current date.
    -- The attendance type is derived based on load calendar instances, using
    -- the 'load effective' date alias as the reference point for determining
    -- which calendar is the current load calendar.
    -- Load the student IGS_PS_COURSE attempt details.
    OPEN    c_stu_crs_atmpt(
            p_person_id,
            p_course_cd);
    FETCH   c_stu_crs_atmpt INTO v_cal_type;
    IF(c_stu_crs_atmpt%NOTFOUND) THEN
        CLOSE c_stu_crs_atmpt;
        RETURN NULL;
    END IF;
    CLOSE c_stu_crs_atmpt;
    -- Determine the 'current' load calendar instance based on the 'load effective'
    --  date alias from the enrolment calendar configuration. If this date alias
    -- can't be located then the latest calendar instance where start_dt/end_dt
    -- encompass the effective dt is deemed current.
    OPEN    c_s_enr_cal_conf;
    FETCH   c_s_enr_cal_conf INTO v_load_effect_dt_alias;
    IF (c_s_enr_cal_conf%NOTFOUND) THEN
        CLOSE   c_s_enr_cal_conf;
        RAISE NO_SECC_RECORD_FOUND;
    END IF;
    CLOSE   c_s_enr_cal_conf;
    v_current_load_cal_type := NULL;
    v_current_load_sequence_number := NULL;
    v_current_acad_cal_type := NULL;
    v_current_acad_sequence_number := NULL;
    FOR v_cal_instance_rec IN c_cal_instance(
                        v_cal_type,
                        p_effective_dt)
    LOOP
         FOR v_cal_type_instance_rec IN c_cal_type_instance(
                v_cal_instance_rec.cal_type,
                v_cal_instance_rec.sequence_number)
         LOOP
        -- Attempt to find 'load effective' dt alias against the
        -- calendar instance.
        v_daiv_rec_found := FALSE;
        FOR v_daiv_rec IN c_dai_v(
                v_cal_type_instance_rec.cal_type,
                v_cal_type_instance_rec.sequence_number,
                v_load_effect_dt_alias)
        LOOP
          v_daiv_rec_found := TRUE;
          IF(p_effective_dt >= v_daiv_rec.alias_val) THEN
            v_current_load_cal_type := v_cal_type_instance_rec.cal_type;
            v_current_load_sequence_number := v_cal_type_instance_rec.sequence_number;
            v_current_acad_cal_type := v_cal_instance_rec.cal_type;
            v_current_acad_sequence_number := v_cal_instance_rec.sequence_number;
          END IF;
        END LOOP;
        IF(v_daiv_rec_found = FALSE) THEN
          IF(p_effective_dt >= v_cal_type_instance_rec.start_dt AND
             p_effective_dt <= v_cal_type_instance_rec.end_dt) THEN
            v_current_load_cal_type := v_cal_type_instance_rec.cal_type;
            v_current_load_sequence_number := v_cal_type_instance_rec.sequence_number;
            v_current_acad_cal_type := v_cal_instance_rec.cal_type;
            v_current_acad_sequence_number := v_cal_instance_rec.sequence_number;
          END IF;
        END IF;
         END LOOP;
         IF(v_current_load_cal_type IS NOT NULL) THEN
            EXIT;
         END IF;
    END LOOP;
    IF(v_current_load_cal_type IS NULL) THEN
        RETURN NULL;
    END IF;
    -- Call ENRP_CLC_LOAD_TOTAL routine to get the load incurred within the
    -- current load period
    v_period_load := IGS_EN_PRC_LOAD.ENRP_CLC_EFTSU_TOTAL(
                    p_person_id,
                    p_course_cd,
                    v_current_acad_cal_type,
                    v_current_acad_sequence_number,
                    v_current_load_cal_type,
                    v_current_load_sequence_number,
                    'Y',
                    'Y',
                                        NULL,
                                        NULL,
                    v_period_credit_points);
    -- Call routine to determine the attendance type for the calculated load
    -- figure within the current load calendar
    v_attendance_type := IGS_EN_PRC_LOAD.ENRP_GET_LOAD_ATT(
                    v_current_load_cal_type,
                    v_period_load);
    RETURN v_attendance_type;
EXCEPTION
    WHEN NO_SECC_RECORD_FOUND THEN
        Fnd_Message.Set_name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_006.enrp_get_sca_att');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END;
END enrp_get_sca_att;


Function Enrp_Get_Sca_Comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_effective_date IN DATE )
RETURN boolean AS
BEGIN
DECLARE
    v_commence_cutoff_dt_alias  IGS_EN_CAL_CONF.commence_cutoff_dt_alias%TYPE;
    v_cal_type          IGS_CA_INST.cal_type%TYPE;
    v_sequence_number       IGS_CA_INST.sequence_number%TYPE;
    v_sua_ci_rec_found      BOOLEAN;
    v_dai_rec_found         BOOLEAN;
    CURSOR  c_s_enr_cal_conf IS
        SELECT  commence_cutoff_dt_alias
        FROM    IGS_EN_CAL_CONF
        WHERE   s_control_num = 1;
    CURSOR  c_sua_ci(
            cp_person_id IGS_EN_SU_ATTEMPT.person_id%TYPE,
            cp_course_cd IGS_EN_SU_ATTEMPT.course_cd%TYPE) IS
        SELECT  IGS_EN_SU_ATTEMPT.cal_type,
            IGS_EN_SU_ATTEMPT.ci_sequence_number,
            IGS_CA_INST.start_dt
        FROM    IGS_EN_SU_ATTEMPT,
            IGS_CA_INST
        WHERE   IGS_EN_SU_ATTEMPT.person_id = cp_person_id AND
            IGS_EN_SU_ATTEMPT.course_cd = cp_course_cd AND
            IGS_EN_SU_ATTEMPT.cal_type = IGS_CA_INST.cal_type AND
            IGS_EN_SU_ATTEMPT.ci_sequence_number = IGS_CA_INST.sequence_number
        ORDER BY IGS_CA_INST.start_dt;

    CURSOR  c_dai_v(cp_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
            cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
            cp_dt_alias IGS_CA_DA_INST_V.dt_alias%TYPE) IS
        SELECT  IGS_CA_GEN_001.calp_set_alias_value
                (
                 absolute_val,
                 IGS_CA_GEN_002.cals_clc_dt_from_dai
                    (
                     ci_sequence_number,
                     CAL_TYPE,
                     DT_ALIAS,
                     sequence_number
                    )
                ) alias_val
        FROM    IGS_CA_DA_INST
        WHERE   cal_type = cp_cal_type AND
            ci_sequence_number = cp_ci_sequence_number AND
                dt_alias = cp_dt_alias
        ORDER BY alias_val;
    v_other_detail  VARCHAR(255);
BEGIN
    -- This module gets whether the student is considered commencing in their
    -- IGS_PS_COURSE  for the purposes of enrolment. IGS_GE_NOTE: There may be other
    -- commencing calculations in the system which apply for other purposes. Eg.
    -- Statistics sub-system has a much more complicated definition of a
    -- commencing student. This calculation will derive whether as at a
    -- nominated effective date the student should still be considered
    -- commencing within the nominated IGS_PS_COURSE attempt. A student is considered a
    -- commencing student until a given date alias within their first teaching
    -- period has been reached
    v_sua_ci_rec_found := FALSE;
    v_dai_rec_found := FALSE;
    -- if IGS_PS_COURSE isn't confirmed, student is considered commencing.
    IF   p_student_confirmed_ind = 'N'  THEN
        RETURN TRUE;
    END IF;
    OPEN    c_s_enr_cal_conf;
    FETCH   c_s_enr_cal_conf INTO v_commence_cutoff_dt_alias;
    IF(c_s_enr_cal_conf%NOTFOUND) THEN
        CLOSE   c_s_enr_cal_conf;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE   c_s_enr_cal_conf;
    FOR v_sua_ci_rec IN c_sua_ci(
                p_person_id,
                p_course_cd)
    LOOP
        v_sua_ci_rec_found := TRUE;
        v_cal_type := v_sua_ci_rec.cal_type;
        v_sequence_number := v_sua_ci_rec.ci_sequence_number;
        EXIT;
    END LOOP;
    IF(v_sua_ci_rec_found = FALSE) THEN
        RETURN TRUE;
    END IF;
    FOR v_dai_rec IN c_dai_v(
            v_cal_type,
            v_sequence_number,
            v_commence_cutoff_dt_alias)
    LOOP
        v_dai_rec_found := TRUE;
        IF(p_effective_date <= v_dai_rec.alias_val) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END LOOP;
    IF(v_dai_rec_found = FALSE) THEN
        RETURN FALSE;
    END IF;
/*
EXCEPTION

    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    App_Exception.Raise_Exception;
*/
END;
END enrp_get_sca_comm;


Function Enrp_Get_Sca_Elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_comm_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_dflt_confirmed_course_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean AS
    /*
      ||  Created By :
      ||  Created On :
      ||  Purpose : This procedure process the Application
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  pkpatel       09-SEP-2001      Bug no.1960126 :For Academic Record Maintenance
      ||                                 Modified the defination of Cursor 'c_sci' to include
      ||                                 the logic for INtermission Type Approval
      ||  pradhakr      29-Jan-2003      Added a message IGS_EN_CAL_CONF_NOT_SET.
      ||                                 Changes wrt bug# 2675905
      ||  (reverse chronological order - newest change first)
        */
    gv_other_detail VARCHAR2(255);
    gv_extra_detail VARCHAR2(255) DEFAULT NULL;
BEGIN
    -- Validate whether the nominated IGS_PE_PERSON is eligible to enrol in the nominated
    -- IGS_PS_COURSE in an nominated academic period. This routine performs the same
    -- logic for both new and returning students, due to the requirements of
    -- re-admission and IGS_PS_COURSE transfer which blur the strict lines between the
    -- two. The following checks are performed:
    --  * The deceased_ind for the IGS_PE_PERSON is not set
    --  * Student has no exclusions/encumbrances preventing them from enrolling.
    --      The student must be excluded from all teaching periods linked to the
    --      academic year to be ineligible.
    --  * Student has an offer in the IGS_PS_COURSE within the nominated academic period,
    --      or an existing student IGS_PS_COURSE attempt record which is of a status which
    --      is ongoing (ie. ENROLLED, COMPLETED or INACTIVE).
    --  * Student has a conditional offer that is satisfactory or waived, or
    --      pending and it is not a requirement for it to be satisfied on
    --      confirmation.
    --  * Student has research IGS_RE_CANDIDATURE details if the IGS_PS_COURSE attempt is
    --      defined as a research IGS_PS_COURSE.
    --  * A IGS_EN_STDNT_PS_ATT record exists with a course_attempt_status of
    --      INTERMIT and student_intermission record exists with an end_dt within the
    --      academic period.
    --
    -- The routine will return TRUE if the student is eligible to enrol/re-enrol,
    -- and FALSE if not. The message number will be set in the case that they are
    -- ineligible  and will contain the message number of the reason
    -- for ineligibility.

DECLARE
    cst_teaching            CONSTANT VARCHAR2(8)    := 'TEACHING';
    cst_new_student         CONSTANT VARCHAR2(3)    := 'NEW';
    cst_deleted             CONSTANT VARCHAR2(10)   := 'DELETED';
    cst_active              CONSTANT VARCHAR2(10)   := 'ACTIVE';
    cst_lapsed              CONSTANT VARCHAR2(10)   := 'LAPSED';
    cst_intermit            CONSTANT VARCHAR2(10)   := 'INTERMIT';
    cst_discontin           CONSTANT VARCHAR2(10)   := 'DISCONTIN';
    cst_unconfirm           CONSTANT VARCHAR2(10)   := 'UNCONFIRM';

    v_deceased_ind          IGS_PE_PERSON.deceased_ind%TYPE;
    v_instance_start_dt     IGS_CA_INST.start_dt%TYPE;
    v_instance_end_dt       IGS_CA_INST.end_dt%TYPE;
    v_intrmsn_start_dt      IGS_EN_STDNT_PS_INTM.start_dt%TYPE;
    v_intrmsn_end_dt        IGS_EN_STDNT_PS_INTM.end_dt%TYPE;
    v_census_dt_alias       IGS_GE_S_GEN_CAL_CON.census_dt_alias%TYPE;
    v_course_status
                    IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE DEFAULT NULL;
    v_sca_version_number        IGS_EN_STDNT_PS_ATT.version_number%TYPE;

    v_valid_enrolment       BOOLEAN;
    v_daiv_rec_found        BOOLEAN;
    v_valid_pre_sysdate     BOOLEAN;
    v_valid_post_sysdate        BOOLEAN;
    v_excluded          BOOLEAN;

    v_message_name          VARCHAR2(30);

    v_acaiv_offer_dt        IGS_AD_PS_APPL_INST_APLINST_V.offer_dt%TYPE DEFAULT NULL;
    v_adm_cndtnl_offer_status   IGS_AD_PS_APPL_INST_APLINST_V.ADM_CNDTNL_OFFER_STATUS%TYPE;
    v_cndtnl_off_must_be_stsfd_ind  IGS_AD_PS_APPL_INST_APLINST_V.cndtnl_offer_must_be_stsfd_ind%TYPE;
    v_discontinued_dt       IGS_EN_STDNT_PS_ATT.discontinued_dt%TYPE;
    v_lapsed_dt         IGS_EN_STDNT_PS_ATT.lapsed_dt%TYPE;
    v_cop_offered_ind       IGS_PS_OFR_PAT.offered_ind%TYPE;
    v_s_adm_cndtnl_offer_status IGS_LOOKUPS_view.lookup_code%TYPE DEFAULT NULL;

--modified cursor for performance bug 4968380
    CURSOR c_person IS
        SELECT  DECODE(Pbv.DATE_OF_DEATH,NULL,NVL(PE.DECEASED_IND,'N'),'Y') DECEASED_IND
        FROM    IGS_PE_HZ_PARTIES   pe,
                IGS_PE_PERSON_BASE_V pbv
        WHERE   pe.party_id    = p_person_id AND
                pbv.person_id = pe.party_id;

    CURSOR c_ci IS
        SELECT  ci.start_dt,
            ci.end_dt
        FROM    IGS_CA_INST ci
        WHERE   ci.cal_type     = p_acad_cal_type AND
            ci.sequence_number  = p_acad_ci_sequence_number;

    CURSOR c_s_gen_cal_conf IS
        SELECT  sgcc.census_dt_alias
        FROM    IGS_GE_S_GEN_CAL_CON    sgcc
        WHERE   sgcc.s_control_num  = 1;

    CURSOR c_ct_ci IS
        SELECT  ci.cal_type,
            ci.sequence_number
        FROM    IGS_CA_INST_REL cir,
            IGS_CA_TYPE         cat,
            IGS_CA_INST         ci,
            IGS_CA_STAT         cs
        WHERE   cir.sup_cal_type        = p_acad_cal_type AND
            cir.sup_ci_sequence_number  = p_acad_ci_sequence_number AND
            cat.cal_type            = cir.sub_cal_type AND
            cat.closed_ind          = 'N' AND
            cat.s_cal_cat           = cst_teaching AND
            ci.cal_type         = cir.sub_cal_type AND
            ci.sequence_number      = cir.sub_ci_sequence_number AND
            ci.cal_type         = cat.cal_type AND
            ci.cal_status           = cs.cal_status AND
            cs.s_cal_status         = cst_active;
    CURSOR c_daiv(
        cp_cal_type     IGS_CA_DA_INST_V.cal_type%TYPE,
        cp_ci_sequence_number   IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
        cp_dt_alias     IGS_CA_DA_INST_V.dt_alias%TYPE) IS

        SELECT  IGS_CA_GEN_001.calp_set_alias_value
                (
                 absolute_val,
                 IGS_CA_GEN_002.cals_clc_dt_from_dai
                    (
                     ci_sequence_number,
                     CAL_TYPE,
                     DT_ALIAS,
                     sequence_number
                    )
                ) alias_val
        FROM    IGS_CA_DA_INST  dai
        WHERE   dai.cal_type        = cp_cal_type AND
            dai.ci_sequence_number  = cp_ci_sequence_number AND
            dai.dt_alias        = cp_dt_alias;

    CURSOR c_sca IS
        SELECT  sca.course_attempt_status,
            sca.discontinued_dt,
            sca.lapsed_dt,
            sca.version_number
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.person_id       = p_person_id AND
            sca.course_cd       = p_course_cd;

    CURSOR c_cop(
        cp_coo_id       IGS_PS_OFR_PAT.coo_id%TYPE,
        cp_ci_sequence_number   IGS_PS_OFR_PAT.ci_sequence_number%TYPE) IS

        SELECT  cop.offered_ind
        FROM    IGS_PS_OFR_PAT  cop
        WHERE   cop.coo_id      = cp_coo_id AND
            cop.ci_sequence_number  = cp_ci_sequence_number;

    CURSOR c_sci IS
        SELECT  sci.end_dt
        FROM    IGS_EN_STDNT_PS_INTM    sci,
                IGS_EN_INTM_TYPES  eit
        WHERE   sci.person_id   = p_person_id AND
            sci.course_cd   = p_course_cd AND
            eit.intermission_type(+) = sci.intermission_type AND
            ((eit.appr_reqd_ind = 'Y' AND sci.approved = 'Y') OR (eit.appr_reqd_ind = 'N'))
            AND sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
        ORDER BY sci.start_dt;
   -- replaced as pragma solution - view replaced by view query.
    CURSOR c_acaiv IS
        SELECT  acaiv.offer_dt,
            acaiv.ADM_CNDTNL_OFFER_STATUS,
            acaiv.cndtnl_offer_must_be_stsfd_ind
        FROM
             (
                SELECT
                    acai.person_id PERSON_ID,
                    aa.acad_cal_type ACAD_CAL_TYPE,
                    DECODE(acai.adm_cal_type, NULL, aa.acad_ci_sequence_number,
                        IGS_CA_GEN_001.calp_get_sup_inst (
                            aa.acad_cal_type,
                            acai.adm_cal_type,
                            acai.adm_ci_sequence_number))ACAD_CI_SEQUENCE_NUMBER,
                    acai.course_cd COURSE_CD,
                    acai.adm_outcome_status ADM_OUTCOME_STATUS,
                    acai.offer_dt OFFER_DT,
                acai.adm_cndtnl_offer_status ADM_CNDTNL_OFFER_STATUS,
                    acai.cndtnl_offer_must_be_stsfd_ind CNDTNL_OFFER_MUST_BE_STSFD_IND,
                    acai.adm_offer_resp_status  ADM_OFFER_RESP_STATUS
                FROM
                    IGS_AD_PS_APPL_INST acai,
                    IGS_AD_APPL aa,
                    IGS_CA_INST ci,
                    IGS_AD_PS_APPL aca,
                    IGS_PS_VER crv
                WHERE
                    aa.person_id = acai.person_id AND
                    aa.admission_appl_number = acai.admission_appl_number AND
                    ci.cal_type (+) = acai.deferred_adm_cal_type AND
                    ci.sequence_number (+) = acai.deferred_adm_ci_sequence_num AND
                    aca.person_id = acai.person_id AND
                    aca.admission_appl_number = acai.admission_appl_number AND
                    aca.nominated_course_cd = acai.nominated_course_cd AND
                    crv.course_cd = acai.course_cd AND
                    crv.version_number = acai.crv_version_number
             ) acaiv

        WHERE   acaiv.person_id         = p_person_id AND
            acaiv.course_cd         = p_course_cd AND
            IGS_EN_GEN_002.enrp_get_acai_offer(acaiv.ADM_OUTCOME_STATUS,
                    acaiv.ADM_OFFER_RESP_STATUS) = 'Y' AND
            acaiv.acad_cal_type     = p_acad_cal_type AND
            acaiv.acad_ci_sequence_number   = p_acad_ci_sequence_number
        ORDER BY acaiv.offer_dt DESC; -- use latest offer date

BEGIN
    p_message_name := null;

    -- Check that student is still alive.
    OPEN c_person;
    FETCH c_person INTO v_deceased_ind;
    IF c_person%NOTFOUND THEN
        CLOSE c_person;
        p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
        RETURN FALSE;
    END IF;
    CLOSE c_person;

    IF v_deceased_ind = 'Y' THEN
        p_message_name := 'IGS_EN_STUD_INELIGIB_TO_ENROL';
        RETURN FALSE;
    END IF;

    -- Select the start and end date for the nominated calendar
    -- instance.
    OPEN c_ci;
    FETCH c_ci INTO v_instance_start_dt,
                v_instance_end_dt;

    IF c_ci%NOTFOUND THEN
        CLOSE c_ci;
        gv_extra_detail := ' -no IGS_CA_INST record was found';
        p_message_name := 'IGS_EN_CAL_CONF_NOT_SET';
        RETURN FALSE;
    END IF;
    CLOSE c_ci;

    -- Check that the student is not encumbered for every teaching period
    -- in the academic period.
    OPEN c_s_gen_cal_conf;
    FETCH c_s_gen_cal_conf INTO v_census_dt_alias;
    IF c_s_gen_cal_conf%NOTFOUND THEN
        CLOSE c_s_gen_cal_conf;
        gv_extra_detail := ' -no IGS_GE_S_GEN_CAL_CON record was found';
        p_message_name := 'IGS_EN_CAL_CONF_NOT_SET';
        RETURN FALSE;
    END IF;
    CLOSE c_s_gen_cal_conf;

    v_valid_enrolment   := FALSE;
    v_valid_pre_sysdate := FALSE;
    v_valid_post_sysdate    := FALSE;
    v_excluded      := FALSE;

    FOR v_cal_type_instance_rec IN c_ct_ci LOOP

        v_daiv_rec_found := FALSE;

        FOR v_daiv_rec IN c_daiv(
                    v_cal_type_instance_rec.cal_type,
                    v_cal_type_instance_rec.sequence_number,
                    v_census_dt_alias) LOOP

            v_daiv_rec_found := TRUE;

            IF v_daiv_rec.alias_val BETWEEN v_instance_start_dt AND
                            v_instance_end_dt THEN

                IF IGS_EN_VAL_ENCMB.enrp_val_excld_crs(
                                p_person_id,
                                p_course_cd,
                                v_daiv_rec.alias_val,
                                p_message_name) THEN

                    IF v_daiv_rec.alias_val >= SYSDATE THEN
                        v_valid_post_sysdate := TRUE;
                    ELSE
                        v_valid_pre_sysdate := TRUE;
                    END IF;
                ELSE

                v_excluded := TRUE;

                END IF; -- IGS_EN_VAL_ENCMB.enrp_val_excld_crs
            END IF;-- v_daiv_rec.alias_val
        END LOOP; -- c_dai_v

        IF NOT v_daiv_rec_found OR
                NOT v_excluded OR
                v_valid_post_sysdate THEN

            v_valid_enrolment := TRUE;
            EXIT;
        END IF;

    END LOOP; -- c_cal_type_instance

    -- If the student is excluded from all teaching periods in the
    -- academic period then ineligible.
    IF NOT v_valid_enrolment THEN
        p_message_name := 'IGS_EN_STUD_INELIBIBLE';
        RETURN FALSE;
    END IF;

    -- Attempt to select existing student IGS_PS_COURSE attempt details.
    OPEN c_sca;
    FETCH c_sca INTO v_course_status,
            v_discontinued_dt,
            v_lapsed_dt,
            v_sca_version_number;
    CLOSE c_sca;

    IF v_course_status = cst_unconfirm THEN
        -- Validate confirmation of research IGS_PS_COURSE attempt
        IF NOT IGS_EN_VAL_SCA.enrp_val_res_elgbl(
                        p_person_id,
                        p_course_cd,
                        v_sca_version_number,
                        p_message_name) THEN

            RETURN FALSE;
        END IF;
    END IF;

    IF v_course_status IS NULL OR
            v_course_status = cst_unconfirm THEN

        OPEN c_acaiv;
        FETCH c_acaiv INTO
                v_acaiv_offer_dt,
                v_adm_cndtnl_offer_status,
                v_cndtnl_off_must_be_stsfd_ind;

        IF c_acaiv%NOTFOUND THEN
            CLOSE c_acaiv;
            p_message_name := 'IGS_EN_STUD_NOT_HAVE_CURR_AFF';
            RETURN FALSE;
        ELSE
            CLOSE c_acaiv;

            IF p_dflt_confirmed_course_ind = 'Y' THEN
                -- Validate conditional offer
                IF NOT IGS_EN_VAL_SCA.enrp_val_acai_cndtnl (
                            v_adm_cndtnl_offer_status,
                            v_cndtnl_off_must_be_stsfd_ind,
                            v_s_adm_cndtnl_offer_status,
                            p_message_name) THEN

                RETURN FALSE;
                END IF;
            END IF;
        END IF; -- c_acaiv%NOTFOUND
    END IF; -- v_course_status = cst_unconfirm

    -- Only load the latest offer date for current offers in the IGS_PS_COURSE
    -- if IGS_PS_COURSE attempt status is 'DISCONTIN', 'LAPSED' or 'DELETED'
    IF v_course_status IN (
                cst_discontin,
                cst_lapsed,
                cst_deleted)    THEN

        OPEN c_acaiv;
        FETCH c_acaiv INTO
                v_acaiv_offer_dt,
                v_adm_cndtnl_offer_status,
                v_cndtnl_off_must_be_stsfd_ind;

        IF c_acaiv%FOUND THEN
            CLOSE c_acaiv;

            -- Validate conditional offer
            IF p_dflt_confirmed_course_ind = 'Y' AND
                    NOT IGS_EN_VAL_SCA.enrp_val_acai_cndtnl(
                                v_adm_cndtnl_offer_status,
                                v_cndtnl_off_must_be_stsfd_ind,
                                v_s_adm_cndtnl_offer_status,
                                p_message_name)  THEN
                RETURN FALSE;
            END IF;
        ELSE
            CLOSE c_acaiv;
        END IF;
    END IF;

    -- If IGS_PS_COURSE attempt is DISCONTIN then the admissions offer must have been
    -- made after the discontinuation date.
    IF v_course_status = cst_discontin THEN

        IF v_acaiv_offer_dt IS NULL OR
            v_acaiv_offer_dt <= v_discontinued_dt THEN
            p_message_name := 'IGS_EN_STUD_INELIG_TO_RE_ENR';
            RETURN FALSE;
        END IF;

    -- If IGS_PS_COURSE attempt is lapsed then the admissions offer must have been
    -- made after the lapsed was placed.
    ELSIF v_course_status = cst_lapsed THEN

        IF v_acaiv_offer_dt IS NULL THEN
            p_message_name := 'IGS_EN_INELIGBLE_DUE_TO_LAPSE';
            RETURN FALSE;
        ELSE
            IF v_acaiv_offer_dt <= v_lapsed_dt THEN
                p_message_name := 'IGS_EN_INELIGBLE_DUE_TO_LAPSE';
                RETURN FALSE;
            END IF;
        END IF;

    -- If the IGS_PS_COURSE attempt is DELETED then any current admissions offer will
    -- permit enrolment.
    ELSIF v_course_status = cst_deleted THEN

        IF v_acaiv_offer_dt IS NULL THEN
            p_message_name := 'IGS_EN_STUD_INELIGIBLE_RE_ENR';
            RETURN FALSE;
        END IF;

    -- If IGS_PS_COURSE attempt status is INTERMIT then only eligible if returning within
    -- the academic period.
    ELSIF v_course_status = cst_intermit THEN
        OPEN c_sci;
        FETCH c_sci INTO v_intrmsn_end_dt;

        IF c_sci%FOUND THEN
            IF v_intrmsn_end_dt IS NULL OR
                    v_intrmsn_end_dt > v_instance_end_dt THEN

                CLOSE c_sci;
                p_message_name := 'IGS_EN_INTERM_DOES_NOT_END';
                RETURN FALSE;
            END IF;
        END IF;
        CLOSE c_sci;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        IF c_acaiv%ISOPEN THEN
            CLOSE c_acaiv;
        END IF;

        IF c_sci%ISOPEN THEN
            CLOSE c_sci;
        END IF;

        IF c_ci%ISOPEN THEN
            CLOSE c_ci;
        END IF;

        IF c_ct_ci%ISOPEN THEN
            CLOSE c_ct_ci;
        END IF;

        IF c_sca%ISOPEN THEN
            CLOSE c_sca;
        END IF;

        IF c_daiv%ISOPEN THEN
            CLOSE c_daiv;
        END IF;

        IF c_person%ISOPEN THEN
            CLOSE c_person;
        END IF;

        IF c_s_gen_cal_conf%ISOPEN THEN
            CLOSE c_s_gen_cal_conf;
        END IF;

        RAISE;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    App_Exception.Raise_Exception;
*/
END enrp_get_sca_elgbl;




Function Enrp_Get_Sca_Latt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_sequence_number IN NUMBER )
RETURN VARCHAR2 AS

BEGIN
DECLARE
    v_dummy             VARCHAR2(10);
    v_acad_cal_type         VARCHAR2(10);
    v_acad_sequence_number      NUMBER;
    v_acad_ci_start_dt      DATE;
    v_acad_ci_end_dt        DATE;
    v_message_name          VARCHAR2(30);
    v_period_load           NUMBER;
    v_period_credit_points      NUMBER;
    v_attendance_type       VARCHAR2(2);
BEGIN
    -- Get the current attendance type for a student IGS_PS_COURSE attempt within a
    -- nominated load calendar instance.
    -- 1. Determine the academic calendar instance that the load calendar
    -- instance is within.
    v_dummy := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(
                    p_load_cal_type,
                    p_load_sequence_number,
                    v_acad_cal_type,
                    v_acad_sequence_number,
                    v_acad_ci_start_dt,
                    v_acad_ci_end_dt,
                    v_message_name);
    IF (v_acad_cal_type IS NULL) THEN
        RETURN NULL;
    END IF;
    -- 2. Call enrp_clc_load_total routine to get the load incurred within
    -- the current load period.
    v_period_load := IGS_EN_PRC_LOAD.enrp_clc_eftsu_total(
                    p_person_id,
                    p_course_cd,
                    v_acad_cal_type,
                    v_acad_sequence_number,
                    p_load_cal_type,
                    p_load_sequence_number,
                    'Y',
                    'Y',
                                        NULL,
                                        NULL,
                    v_period_credit_points);
    -- 3. Call routine to determine the attendance type for the calculated
    -- load figure within the current load calendar.
    v_attendance_type := IGS_EN_PRC_LOAD.enrp_get_load_att(
                        p_load_cal_type,
                        v_period_load);
    RETURN v_attendance_type;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    App_Exception.Raise_Exception;
*/
END enrp_get_sca_latt;


Function Enrp_Get_Sca_Perd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
    gv_other_detail         VARCHAR2(255);
BEGIN
DECLARE
    v_cal_type          IGS_EN_SU_ATTEMPT.cal_type%TYPE;
    v_ci_sequence_number        IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
    v_alternate_code        IGS_CA_INST.alternate_code%TYPE;
    v_academic_cal_type     IGS_EN_SU_ATTEMPT.cal_type%TYPE;
    v_academic_ci_sequence_number   IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
    v_academic_ci_start_dt      IGS_EN_SU_ATTEMPT.ci_start_dt%TYPE;
    v_academic_ci_end_dt        IGS_EN_SU_ATTEMPT.ci_end_dt%TYPE;
    v_message_name          VARCHAR2(30);
    CURSOR c_sua_ci (
        cp_person_id        IGS_EN_SU_ATTEMPT.person_id%TYPE,
        cp_course_cd        IGS_EN_SU_ATTEMPT.course_cd%TYPE)IS
        SELECT      sua.cal_type,
                sua.ci_sequence_number,
                ci.alternate_code
        FROM        IGS_EN_SU_ATTEMPT   sua,
                IGS_CA_INST     ci
        WHERE       sua.person_id = cp_person_id AND
                sua.course_cd = cp_course_cd AND
                sua.cal_type = ci.cal_type AND
                sua.ci_sequence_number = ci.sequence_number AND
                (sua.unit_attempt_status = 'ENROLLED' OR
                sua.unit_attempt_status = 'COMPLETED')
        ORDER BY    ci.start_dt;
BEGIN
    -- Get the commencement period of a student IGS_PS_COURSE attempt. This is the first
    -- teaching period with a ENROLLED or COMPLETED student IGS_PS_UNIT attempt.
    -- The routine is expected to be mostly used by reporting as the result
    -- is a concatenated string of <teaching alt code>/<academic alternate code>.
    -- IGS_GE_NOTE: may need to be expanded to include IGS_PS_UNIT attempts which discontinued
    -- late once assessments is on board.
    -- 1. Find earliest student IGS_PS_UNIT attempt record matching the criteria.
    OPEN    c_sua_ci(
            p_person_id,
            p_course_cd);
    FETCH   c_sua_ci    INTO    v_cal_type,
                    v_ci_sequence_number,
                    v_alternate_code;
    IF (c_sua_ci%NOTFOUND) THEN
        CLOSE   c_sua_ci;
        RETURN NULL;
    END IF;
    CLOSE   c_sua_ci;
    v_academic_cal_type := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(
                        v_cal_type,
                        v_ci_sequence_number,
                        v_academic_cal_type,
                        v_academic_ci_sequence_number,
                        v_academic_ci_start_dt,
                        v_academic_ci_end_dt,
                        v_message_name);
    RETURN (v_alternate_code || ',' || v_academic_cal_type);
END;
EXCEPTION
    WHEN OTHERS THEN
            Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_006.enrp_get_sca_perd');
            IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_get_sca_perd;


Function Enrp_Get_Sca_Status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_discontinued_dt IN DATE ,
  p_lapsed_dt IN DATE ,
  p_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_logical_delete_dt IN DATE )
RETURN VARCHAR2 AS
    /*
      ||  Created By :
      ||  Created On :
      ||  Purpose : This procedure process the Application
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  pkpatel       09-SEP-2001      Bug no.1960126 :For Academic Record Maintenance
      ||                                 Modified the defination of Cursor 'c_sci' to include
      ||                                 the logic for INtermission Type Approval
      ||  (reverse chronological order - newest change first)
      -- rnirwani   13-Sep-2004    changed cursor c_intmsn_details  to not consider logically deleted records and
      --                           also to avoid un-approved intermission records. Bug# 3885804
      -- smaddali   10-mar-06      Modified cursor c_sci for build EN324 - bug#5091858
        */
BEGIN   -- enrp_get_sca_status
    -- Get the IGS_PS_COURSE attempt status of a nominated student IGS_PS_COURSE attempt.
    -- This routine checks attributes of the students enrolment to ascertain
    -- what their enrolled student IGS_PS_COURSE attempt status should be.
DECLARE
    cst_deleted         CONSTANT VARCHAR2(10) := 'DELETED';
    cst_unconfirm       CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_discontin       CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_lapsed      CONSTANT VARCHAR2(10) := 'LAPSED';
    cst_enrolled        CONSTANT VARCHAR2(10) := 'ENROLLED';
    cst_intermit        CONSTANT VARCHAR2(10) := 'INTERMIT';
    cst_completed       CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_inactive        CONSTANT VARCHAR2(10) := 'INACTIVE';
    v_course_attempt_status     IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    v_student_confirmed_ind     IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
    v_discontinued_dt       IGS_EN_STDNT_PS_ATT.discontinued_dt%TYPE;
    v_lapsed_dt         IGS_EN_STDNT_PS_ATT.lapsed_dt%TYPE;
    v_course_rqrmnt_complete_ind    IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE;
    v_logical_delete_dt     IGS_EN_STDNT_PS_ATT.logical_delete_dt%TYPE;
    v_cal_type          IGS_CA_INST.cal_type%TYPE;
    v_ci_sequence_number        IGS_CA_INST.sequence_number%TYPE;
    v_enr_form_due_dt       IGS_AS_SC_ATMPT_ENR.enr_form_due_dt%TYPE;
    v_exists_flag           VARCHAR2(1);
    CURSOR c_sca IS
        SELECT  sca.course_attempt_status,
            sca.student_confirmed_ind,
            sca.discontinued_dt,
            sca.lapsed_dt,
            sca.course_rqrmnt_complete_ind,
            sca.logical_delete_dt
        FROM    IGS_EN_STDNT_PS_ATT sca
        WHERE   sca.person_id   = p_person_id AND
            sca.course_cd   = p_course_cd;
    CURSOR c_sua IS
        SELECT  'x'
        FROM    sys.dual
        WHERE   EXISTS (
            SELECT  'x'
            FROM    IGS_EN_SU_ATTEMPT   sua
            WHERE   sua.person_id       = p_person_id AND
                sua.course_cd       = p_course_cd AND
                sua.unit_attempt_status = cst_enrolled AND
                sua.ci_start_dt     <= SYSDATE);

    -- smaddali  Modified cursor c_sci for build EN324 - bug#5091858
    CURSOR c_sci IS
            SELECT  'X'
            FROM    IGS_EN_STDNT_PS_INTM    sci,
                    IGS_EN_INTM_TYPES   eit
            WHERE   sci.person_id   = p_person_id AND
                sci.course_cd   = p_course_cd AND
                sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
                eit.intermission_type = sci.intermission_type AND
                ((eit.appr_reqd_ind = 'Y' AND sci.approved = 'Y')  OR
                         (eit.appr_reqd_ind = 'N')) AND
                sci.start_dt    <= trunc(SYSDATE) AND
                ( sci.end_dt      >= trunc(SYSDATE) OR
                  ( sci.end_dt     <  trunc(SYSDATE) AND
                    sci.cond_return_flag = 'Y' AND
                    EXISTS (select 'x' from igs_en_spi_rconds rc
                                            where sci.person_id = rc.person_id
                                            and  sci.course_cd = rc.course_cd
                                            and  sci.start_dt = rc.start_dt
                                            and  sci.logical_delete_date = rc.logical_delete_date
                                            and  status_code IN ('FAILED','PENDING')
                              )
                   )
                );
    CURSOR c_scae IS
        SELECT  ci.cal_type,
            scae.ci_sequence_number,
            scae.enr_form_due_dt
        FROM    IGS_AS_SC_ATMPT_ENR scae,
            IGS_CA_INST ci
        WHERE   scae.person_id      = p_person_id AND
            scae.course_cd      = p_course_cd AND
            ci.cal_type         = scae.cal_type AND
            ci.sequence_number  = scae.ci_sequence_number
        ORDER BY ci.end_dt DESC;
    CURSOR c_secc (
        cp_cal_type     IGS_CA_INST.cal_type%TYPE,
        cp_ci_sequence_number   IGS_CA_INST.sequence_number%TYPE ) IS
        SELECT  'x'
        FROM    sys.dual
        WHERE   EXISTS (
            SELECT  'x'
            FROM    IGS_EN_CAL_CONF secc,
                IGS_CA_DA_INST_V daiv
            WHERE   secc.s_control_num      = 1 AND
                secc.enr_form_due_dt_alias  IS NOT NULL AND
                daiv.cal_type           = cp_cal_type AND
                daiv.ci_sequence_number     = cp_ci_sequence_number AND
                daiv.dt_alias           = secc.enr_form_due_dt_alias AND
                daiv.alias_val          >= SYSDATE);
BEGIN
    -- If the values have not been passed in, load them.
    IF p_course_attempt_status IS NULL THEN
        OPEN c_sca;
        FETCH c_sca INTO v_course_attempt_status,
                v_student_confirmed_ind,
                v_discontinued_dt,
                v_lapsed_dt,
                v_course_rqrmnt_complete_ind,
                v_logical_delete_dt;
        IF (c_sca%NOTFOUND) THEN
            CLOSE c_sca;
            RETURN NULL;
        END IF;
        CLOSE c_sca;
    ELSE
        -- Use parameters instead of selected student IGS_PS_COURSE attempt
        -- information to set v_ values.
        v_course_attempt_status := p_course_attempt_status;
        v_student_confirmed_ind := p_student_confirmed_ind;
        v_discontinued_dt := p_discontinued_dt;
        v_lapsed_dt := p_lapsed_dt;
        v_course_rqrmnt_complete_ind := p_course_rqrmnt_complete_ind;
        v_logical_delete_dt := p_logical_delete_dt;
    END IF;
    -- If logical delete dt is not null then return deleted
    IF v_logical_delete_dt IS NOT NULL THEN
        RETURN cst_deleted;
    END IF;
    -- If IGS_PS_COURSE attempt is unconfirmed then return unconfirm
    IF v_student_confirmed_ind = 'N' THEN
        RETURN cst_unconfirm;
    END IF;
    -- If there is a current discontinuation date then return discontin
    IF v_discontinued_dt IS NOT NULL AND
            v_discontinued_dt <= SYSDATE THEN
        RETURN cst_discontin;
    END IF;
    -- If there is a current student IGS_PS_COURSE lapse then return lapsed
    IF (v_lapsed_dt IS NOT NULL) THEN
        OPEN c_sua;
        FETCH c_sua INTO v_exists_flag;
        IF (c_sua%NOTFOUND) THEN
            CLOSE c_sua;
            RETURN cst_lapsed;
        END IF;
        CLOSE c_sua;
    END IF;
    -- If there is a current intermission then return intermit
    OPEN c_sci;
    FETCH c_sci INTO v_exists_flag;
    IF (c_sci%FOUND) THEN
        CLOSE c_sci;
        RETURN cst_intermit;
    END IF;
    CLOSE c_sci;
    -- If there are any enrolled IGS_PS_UNIT attempts within the IGS_PS_COURSE then return
    -- enrolled
    OPEN c_sua;
    FETCH c_sua INTO v_exists_flag;
    IF (c_sua%FOUND) THEN
        CLOSE c_sua;
        RETURN cst_enrolled;
    END IF;
    CLOSE c_sua;
    -- If the IGS_PS_COURSE requirements are complete then return completed
    IF v_course_rqrmnt_complete_ind = 'Y' THEN
        RETURN cst_completed;
    END IF;
    -- If the student has not yet reached their enrolment form due date
    -- then return enrolled, else they are inactive. This checks both the student
    -- IGS_PS_COURSE attempt enrolment due date (which is an override) and the values
    -- in the pre-enrolled enrolment periods.
     OPEN c_scae;
    FETCH c_scae INTO v_cal_type,
            v_ci_sequence_number,
            v_enr_form_due_dt;
    IF (c_scae%NOTFOUND) THEN
        CLOSE c_scae;
        RETURN cst_inactive;
    END IF;
    CLOSE c_scae;
    -- If records found, using the last record (ie. The latest record)
    IF v_enr_form_due_dt IS NOT NULL THEN
        IF v_enr_form_due_dt > SYSDATE THEN
-- commented for bug 1510921
        --  RETURN cst_enrolled;
        RETURN cst_inactive;
        ELSE
            RETURN cst_inactive;
        END IF;
    ELSE
        -- IGS_GE_NOTE: This query is designed to return no records if the
        -- secc.enr_form_due_dt_alias is set to NULL, which means the functionality
        -- is not enabled.
        OPEN c_secc( v_cal_type, v_ci_sequence_number );
        FETCH c_secc INTO v_exists_flag;
        IF (c_secc%NOTFOUND) THEN
            CLOSE c_secc;
            RETURN cst_inactive;
        ELSE
            CLOSE c_secc;
-- commented for bug 1510921
            --RETURN cst_enrolled;
        RETURN cst_inactive;
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (c_sca%ISOPEN) THEN
            CLOSE c_sca;
        END IF;
        IF (c_sua%ISOPEN) THEN
            CLOSE c_sua;
        END IF;
        IF (c_sci%ISOPEN) THEN
            CLOSE c_sci;
        END IF;
        IF (c_scae%ISOPEN) THEN
            CLOSE c_scae;
        END IF;
        IF (c_secc%ISOPEN) THEN
            CLOSE c_secc;
        END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_006.enrp_get_sca_status');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
END enrp_get_sca_status;


Function Enrp_Get_Sca_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS

BEGIN   -- enrp_get_sca_trnsfr
    -- This module determines if the student IGS_PS_COURSE attenmpt has been transferred
    --This is determined by the existence of one or nore student IGS_PS_COURSE transfer
    -- details where the latest is a transfer 'from' the IGS_PS_COURSE attempt
DECLARE
    v_trnsfr_crs_cd         IGS_PS_STDNT_TRN.transfer_course_cd%TYPE;
    CURSOR c_sct IS
        SELECT  sct.transfer_course_cd
        FROM    IGS_PS_STDNT_TRN sct
        WHERE   sct.person_id       = p_person_id AND
            (sct.course_cd      = p_course_cd OR
            sct.transfer_course_cd  = p_course_cd)
        ORDER BY transfer_dt desc;
BEGIN
    p_message_name := null;
    -- Determine  that if student IGS_PS_COURSE transfer details exist, then the last
    -- was a transfer  from the IGS_PS_COURSE attempt
    OPEN c_sct;
    FETCH c_sct INTO v_trnsfr_crs_cd;
    IF (c_sct%NOTFOUND) THEN
        CLOSE c_sct;
        RETURN FALSE;
    END IF;
    CLOSE c_sct;
    IF (v_trnsfr_crs_cd <> p_course_cd) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_sct%ISOPEN) THEN
            CLOSE c_sct;
        END IF;
        RAISE;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    App_Exception.Raise_Exception;
*/
END enrp_get_sca_trnsfr;

END IGS_EN_GEN_006;

/
