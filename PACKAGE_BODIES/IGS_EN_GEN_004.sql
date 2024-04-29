--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_004" AS
/* $Header: IGSEN04B.pls 120.2 2006/08/09 06:56:55 amuthu noship $ */

--Changes History:
-- knaraset    14-May-2003   Modified call to call_fee_ass to add uoo_id, as part of MUS build bug 2829262
-- prraj       10-Jan-2003   Replaced reference to view IGS_EN_NSTD_USEC_DL_V
--                           with base table IGS_EN_NSTD_USEC_DL Bug# 2750716
-- prraj       06-Jan-2003   Changed message for record cutoff in function Enrp_Get_Rec_Window
--                           as part of Bug# 2730025
-- pradhakr    16-Dec-2002   Changed the call to the update_row of igs_en_su_attempt
--                           table to igs_en_sua_api.update_unit_attempt.
--                           Changes wrt ENCR031 build. Bug#2643207
--ayedubat        02-JUL-2002     Changed the procedure, Enrp_Dropall_Unit for the bug Fix:2423605
--ayedubat        30-MAY-2002     Changed the function: Enrp_Get_Rec_Window for the bug fix:2337161
--amuthu          10-May-2002     Commented the exception section in
--                                 Enrp_Dropall_Unit, since the errors
--                                 were not getting propagated to the SS screen

--Updated by Sudhir.
--Update Date: 28-Feb-2002.
--Added a new parameter p_admin_unit_sta to the procedure enrp_dropall_unit and the logic for processing it.

--Added refernces to column ORG_UNIT_CD incall to IGS_EN_SU_ATTEMPT TBH call as a part of bug 1964697
--Aiyer     10-Oct-2001     Added the column grading schema code in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG as a part of the bug 2037897.
--svenkata  20-Dec-2001     Added the columns student_career_transcript,student_career_statistics  in all Tbh calls of
--                          IGS_EN_SU_ATTEMPT_PKG as a part of the bug # 2158626
--vvutukur  7-Jan-2002      Added primary_program_type,key_program as part of cursor c_sca_hist, for SFCR007 Build, bug 2162747
--svenkata  7-JAN-2002      Bug No. 2172405  Standard Flex Field columns have been added to table handler procedure calls as part of
--                          CCR - ENCR022.
--Nishikant  30-jan-2002    Added the column session_id  in the Tbh calls of IGS_EN_SU_ATTEMPT_PKG
--                          as a part of the bug 2172380.
--Nishikant  15-may-2002    Condition in an IF clause in the function Enrp_Dropall_Unit modified as part of the bug#2364216.
--sudhir     23-MAY-2002    Raise exception if multiple admin unit status found.
--amuthu     26-DEC-2002    when dropping a wailtisted unit added code to create a TODO rec
--svanukur   26-jun-2003    Passing discontinued date with a nvl substitution of sysdate in the call to the update_row api of
  --                          ig_en_su_attmept in case of a "dropped" unit attempt status as part of bug 2898213.
--rvivekan    3-SEP-2003     Waitlist Enhacements build # 3052426. 2 new columns added to
--                           IGS_EN_SU_ATTEMPT_PKG procedures and consequently to IGS_EN_SUA_API procedures
--rvangala    07-OCT-03     Passing core_indicator_code to IGS_EN_SUA-API.UPDATE_UNIT_ATTEMPT added as part of Prevent Dropping
--                          Core Units. Enh Bug# 3052432
-- gmaheswa   13-Nov-2003   Bug 3227107 address changes . stubbed Enrp_get_pa_gap.
-- amuthu     14-JUL-2004   Allowing the drop of duplicate unit attempt as
--                          part of IGS.M bug 3765628/ IGS.L.#R bug 3703889
--                          Modified the Cursor in enrp_dropall_unit to allow
--                          the dropping of duplicate unit attempts and add a
--                          call to delete row for duplicate unit attempts.
-- gmaheswa   25-Jan-05     Bug 3882788 - Added START_DT <> END_DT OR END_DT IS NULL condition inorder to ignore deleted person identifiers.
-- amuthu     09-Aug-2006   Modififed Enrp_Dropall_Unit.
-------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Enrp_Get_Pa_Gap(
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE )
RETURN VARCHAR2 AS
GV_OTHER_DETAIL VARCHAR2(250);

BEGIN
RETURN NULL;
END enrp_get_pa_gap;

FUNCTION Enrp_Get_Pei_Dt(p_person_id IN NUMBER )
RETURN DATE AS

BEGIN   -- enrp_get_pei_dt
    -- This module finds the date of the latest image
    -- for a IGS_PE_PERSON from the IGS_PE_PERSON image table.
DECLARE
    v_image_dt  IGS_PE_PERSON_IMAGE.image_dt%TYPE;
    CURSOR c_pei IS
        SELECT  pei.image_dt
        FROM    IGS_PE_PERSON_IMAGE pei
        WHERE   pei.person_id = p_person_id AND
            pei.PERSON_IMAGE IS NOT NULL
        ORDER BY pei.image_dt DESC;
BEGIN
    OPEN c_pei;
    FETCH c_pei INTO v_image_dt;
    IF (c_pei%NOTFOUND) THEN
        CLOSE c_pei;
        RETURN NULL;
    END IF;
    CLOSE c_pei;
    RETURN v_image_dt;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_pei%ISOPEN) THEN
            CLOSE c_pei;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_pei_dt');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END enrp_get_pei_dt;


PROCEDURE Enrp_Get_Pe_Exists(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_alternate IN BOOLEAN ,
  p_check_address IN BOOLEAN ,
  p_check_disability IN BOOLEAN ,
  p_check_visa IN BOOLEAN ,
  p_check_finance IN BOOLEAN ,
  p_check_notes IN BOOLEAN ,
  p_check_statistics IN BOOLEAN ,
  p_check_alias IN BOOLEAN ,
  p_alternate_exists OUT NOCOPY BOOLEAN ,
  p_address_exists OUT NOCOPY BOOLEAN ,
  p_disability_exists OUT NOCOPY BOOLEAN ,
  p_visa_exists OUT NOCOPY BOOLEAN ,
  p_finance_exists OUT NOCOPY BOOLEAN ,
  p_notes_exists OUT NOCOPY BOOLEAN ,
  p_statistics_exists OUT NOCOPY BOOLEAN ,
  p_alias_exists OUT NOCOPY BOOLEAN )
AS

BEGIN   -- enrp_get_pe_exists
    -- return output parameters indicating whether
    -- or not data exists on IGS_PE_PERSON detail tables
    -- for the specific IGS_PE_PERSON ID.
DECLARE
    v_record_exists VARCHAR2(1);
    CURSOR c_api IS
        SELECT  'x'
        FROM    IGS_PE_ALT_PERS_ID  api
        WHERE   pe_person_id    = p_person_id AND
            (api.start_dt   IS NULL OR
            api.start_dt    <= p_effective_dt) AND
            (api.end_dt     IS NULL OR
            api.end_dt  >= p_effective_dt) AND
	    (api.start_dt <> api.end_dt OR
	     api.end_dt IS NULL);
    CURSOR c_pa IS
        SELECT  'x'
        FROM    IGS_PE_ADDR_V
        WHERE   person_id       = p_person_id;
    CURSOR c_pd IS
        SELECT  'x'
        FROM    IGS_PE_PERS_DISABLTY
        WHERE   person_id = p_person_id;
    CURSOR c_iv IS
        SELECT  'x'
        FROM    IGS_PE_VISA iv
        WHERE   iv.person_id        = p_person_id AND
            (iv.visa_expiry_date    IS NULL OR
            iv.visa_expiry_date     > p_effective_dt);
    CURSOR c_pn IS
        SELECT  'x'
        FROM    IGS_PE_PERS_NOTE pn
        WHERE   pn.person_id = p_person_id;
    --modified the cursor for the performance  bug 3693713
    --this cursor is used to check statistics record which is created with person record
    CURSOR c_ps IS
        SELECT  'x'
        FROM    HZ_PARTIES  ps
        WHERE   ps.party_id    = p_person_id ;

    CURSOR c_pal IS
        SELECT  'x'
        FROM    IGS_PE_PERSON_ALIAS pal
        WHERE   pal.person_id   = p_person_id AND
            (pal.start_dt   IS NULL OR
            pal.start_dt    <= p_effective_dt) AND
            (pal.end_dt     IS NULL OR
            pal.end_dt  >= p_effective_dt);
BEGIN
    -- initialise output parameters
    p_alternate_exists := FALSE;
    p_address_exists := FALSE;
    p_disability_exists := FALSE;
    p_visa_exists := FALSE;
    p_finance_exists := FALSE;
    p_notes_exists := FALSE;
    p_statistics_exists := FALSE;
    p_alias_exists := FALSE;
    IF p_check_alternate = TRUE THEN
        -- check for the exsistence of an alternate IGS_PE_PERSON ID record
        OPEN c_api;
        FETCH c_api INTO v_record_exists;
        IF (c_api%FOUND) THEN
            p_alternate_exists := TRUE;
        END IF;
        CLOSE c_api;
    END IF;
    IF p_check_address = TRUE THEN
        -- check for the exsistence of an address record(correspondence)
        OPEN c_pa;
        FETCH c_pa INTO v_record_exists;
        IF (c_pa%FOUND) THEN
            p_address_exists := TRUE;
        END IF;
        CLOSE c_pa;
    END IF;
    IF p_check_disability = TRUE THEN
        -- check for the exsistence of a IGS_PE_PERSON disability record
        OPEN c_pd;
        FETCH c_pd INTO v_record_exists;
        IF (c_pd%FOUND) THEN
            p_disability_exists := TRUE;
        END IF;
        CLOSE c_pd;
    END IF;
    IF p_check_visa = TRUE THEN
        -- check for the exsistence of a international visa record
        OPEN c_iv;
        FETCH c_iv INTO v_record_exists;
        IF (c_iv%FOUND) THEN
            p_visa_exists := TRUE;
        END IF;
        CLOSE c_iv;
    END IF;
    IF p_check_finance = TRUE THEN
        -- check for the exsistence of a IGS_PE_PERSON finance record
        -- table does no exist yet
        NULL;
    END IF;
    IF p_check_notes = TRUE THEN
        -- check for the exsistence of a IGS_PE_PERSON notes record
        OPEN c_pn;
        FETCH c_pn INTO v_record_exists;
        IF (c_pn%FOUND) THEN
            p_notes_exists := TRUE;
        END IF;
        CLOSE c_pn;
    END IF;
    IF p_check_statistics = TRUE THEN
        -- check for the exsistence of a IGS_PE_PERSON statistics record
        OPEN c_ps;
        FETCH c_ps INTO v_record_exists;
        IF (c_ps%FOUND) THEN
            p_statistics_exists := TRUE;
        END IF;
        CLOSE c_ps;
    END IF;
    IF p_check_alias = TRUE THEN
        -- check for the exsistence of a IGS_PE_PERSON alias record
        OPEN c_pal;
        FETCH c_pal INTO v_record_exists;
        IF (c_pal%FOUND) THEN
            p_alias_exists := TRUE;
        END IF;
        CLOSE c_pal;
    END IF;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
    IF (c_api%ISOPEN) THEN
        CLOSE c_api;
    END IF;
    IF (c_pa%ISOPEN) THEN
        CLOSE c_pa;
    END IF;
    IF (c_pd%ISOPEN) THEN
        CLOSE c_pd;
    END IF;
    IF (c_iv%ISOPEN) THEN
        CLOSE c_iv;
    END IF;
    IF (c_pn%ISOPEN) THEN
        CLOSE c_pn;
    END IF;
    IF (c_ps%ISOPEN) THEN
        CLOSE c_ps;
    END IF;
    IF (c_pal%ISOPEN) THEN
        CLOSE c_api;
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_pe_exists');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END enrp_get_pe_exists;


FUNCTION Enrp_Get_Rule_Cutoff(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_date_type IN VARCHAR2 )
RETURN DATE AS

BEGIN   -- enrp_get_rule_cutoff
    -- Get one of the IGS_RU_RULE cutoff dates from the nominated teaching calendar.
    -- The date type parameter indicates whether to get the enrolled or invalid
    -- cut off dates.
DECLARE
    v_alias_val     IGS_CA_DA_INST_V.alias_val%TYPE;
    CURSOR c_alias_val IS
        SELECT  daiv.alias_val
        FROM    IGS_EN_CAL_CONF secc,
            IGS_CA_DA_INST_V daiv
        WHERE   secc.s_control_num  = 1 AND
            daiv.dt_alias       = DECODE(p_date_type,
                             'ENROLLED',NVL(secc.enrolled_rule_cutoff_dt_alias, 'NULL'),
                             'INVALID', NVL(secc.invalid_rule_cutoff_dt_alias,'NULL'),
                             'NULL' ) AND
            daiv.cal_type       = p_cal_type AND
            daiv.ci_sequence_number = p_ci_sequence_number;
BEGIN
    -- Validate IGS_PS_UNIT version
    OPEN c_alias_val;
    FETCH c_alias_val INTO v_alias_val;
    -- * Get the earliest date alias instance value within the
    -- specified teaching calendar. If no records found (in either
    -- secc or daiv) or the invalid_rule_cutoff_dt_alias is null
    -- then NULL will be returned.
    IF (c_alias_val%NOTFOUND) THEN
        CLOSE c_alias_val;
        RETURN NULL;
    ELSE
        CLOSE c_alias_val;
        RETURN v_alias_val;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF c_alias_val%ISOPEN THEN
            CLOSE c_alias_val;
        END IF;
        RAISE;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_rule_cutoff');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
*/
END enrp_get_rule_cutoff;

FUNCTION Enrp_Get_Scah_Col(
  p_column_name IN VARCHAR2 ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN IGS_AS_SC_ATTEMPT_H_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS
    gv_other_detail         VARCHAR2(255);
BEGIN
DECLARE
    CURSOR c_sca_hist (cp_column_name   user_tab_columns.column_name%TYPE,
                cp_person_id    IGS_AS_SC_ATTEMPT_H.person_id%TYPE,
                cp_course_cd    IGS_AS_SC_ATTEMPT_H.course_cd%TYPE,
                cp_hist_end_dt  IGS_AS_SC_ATTEMPT_H.hist_end_dt%TYPE) IS
        SELECT  DECODE(cp_column_name,  'VERSION_NUMBER', TO_CHAR(scah.version_number),
                        'cal_type', scah.cal_type,
                        'LOCATION_CD', scah.location_cd,
                        'attendance_mode', scah.attendance_mode,
                        'attendance_type', scah.attendance_type,
                        'STUDENT_CONFIRMED_IND', scah.student_confirmed_ind,
                        'COMMENCEMENT_DT', igs_ge_date.igscharDT(scah.commencement_dt),
                        'COURSE_ATTEMPT_STATUS', scah.course_attempt_status,
                        'DERIVED_ATT_TYPE', scah.derived_att_type,
                        'DERIVED_ATT_MODE', scah.derived_att_mode,
                        'PROVISIONAL_IND', scah.provisional_ind,
                        'DISCONTINUED_DT', igs_ge_date.igschar(scah.discontinued_dt),
                        'DISCONTINUATION_REASON_CD', scah.DISCONTINUATION_REASON_CD,
                        'FUNDING_SOURCE', scah.FUNDING_SOURCE,
                        'EXAM_LOCATION_CD', scah.exam_location_cd,
                        'DERIVED_COMPLETION_YR', TO_CHAR(scah.derived_completion_yr),
                        'DERIVED_COMPLETION_PERD', scah.derived_completion_perd,
                        'NOMINATED_COMPLETION_YR', TO_CHAR(scah.nominated_completion_yr),
                        'NOMINATED_COMPLETION_PERD', scah.nominated_completion_perd,
                        'RULE_CHECK_IND', scah.rule_check_ind,
                        'WAIVE_OPTION_CHECK_IND', scah.waive_option_check_ind,
                        'LAST_RULE_CHECK_DT', igs_ge_date.igschar(scah.last_rule_check_dt),
                        'PUBLISH_OUTCOMES_IND', scah.publish_outcomes_ind,
                        'COURSE_RQRMNT_COMPLETE_IND', scah.course_rqrmnt_complete_ind,
                        'OVERRIDE_TIME_LIMITATION', TO_CHAR(scah.override_time_limitation),
                        'ADVANCED_STANDING_IND', scah.advanced_standing_ind,
                        'FEE_CAT', scah.FEE_CAT,
                        'IGS_CO_CAT', scah.CORRESPONDENCE_CAT,
                        'SELF_HELP_GROUP_IND', scah.self_help_group_ind,
                        'PRIMARY_PROGRAM_TYPE', primary_program_type,      --Bug 2162747 by vvutukur
                        'KEY_PROGRAM', key_program)                        --Bug 2162747 by vvutukur
        FROM    IGS_AS_SC_ATTEMPT_H scah
        WHERE   scah.person_id = cp_person_id AND
            scah.course_cd = cp_course_cd AND
            scah.hist_start_dt >= cp_hist_end_dt
        ORDER BY
            scah.hist_start_dt ASC;
    v_column_value  VARCHAR2(2000);
    BEGIN
        OPEN    c_sca_hist(p_column_name,
                p_person_id,
                p_course_cd,
                p_hist_end_dt);
        LOOP
            FETCH   c_sca_hist  INTO    v_column_value;
            IF (c_sca_hist%NOTFOUND) THEN
                CLOSE c_sca_hist;
                RETURN NULL;
            END IF;
            IF NVL(v_column_value,'NULL') <> 'NULL' THEN
                CLOSE c_sca_hist;
                RETURN v_column_value;
            END IF;
        END LOOP;
        CLOSE c_sca_hist;
        RETURN NULL;
    END;
EXCEPTION
    WHEN OTHERS THEN
        gv_other_detail := 'Parm: p_column_name - ' || p_column_name
            || ' p_person_id - ' || TO_CHAR(p_person_id)
            || ' p_course_cd - ' || p_course_cd
            || ' p_hist_end_dt - ' || igs_ge_date.igschar(p_hist_end_dt);

        RAISE;
END enrp_get_scah_col;

FUNCTION Enrp_Get_Scae_Due(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_passing_due_date_ind IN VARCHAR2 ,
  p_enr_form_due_dt IN DATE )
RETURN DATE AS

BEGIN   -- enrp_get_scae_due
    -- Get the enrolment form due date for a nominated student IGS_PS_COURSE attempt
    -- enrolment record. The logic is,
    -- If a student has the IGS_AS_SC_ATMPT_ENR.enr_form_due_dt set, then this
    -- is used. Else, it is search for in the enrolment period matching the
    -- IGS_EN_CAL_CONF. enr_form_due_dt_alias (the latest date is selected)
DECLARE
    v_enr_form_due_dt       IGS_AS_SC_ATMPT_ENR.enr_form_due_dt%TYPE;
    v_alias_val         IGS_CA_DA_INST_V.alias_val%TYPE;
    CURSOR c_scae IS
        SELECT  scae.enr_form_due_dt
        FROM    IGS_AS_SC_ATMPT_ENR scae
        WHERE   scae.person_id      = p_person_id       AND
            scae.course_cd      = p_course_cd       AND
            scae.cal_type       = p_cal_type        AND
            scae.ci_sequence_number = p_ci_sequence_number  AND
            scae.enr_form_due_dt    IS NOT NULL;

    CURSOR c_latest_alias_val IS
        SELECT  IGS_CA_GEN_001.calp_set_alias_value(
                daiv.absolute_val,
                IGS_CA_GEN_002.cals_clc_dt_from_dai(
                    daiv.ci_sequence_number,
                    daiv.CAL_TYPE,
                    daiv.DT_ALIAS,
                    daiv.sequence_number) ) alias_val
        FROM    IGS_EN_CAL_CONF     secc,
            IGS_CA_DA_INST      daiv
        WHERE   secc.s_control_num  = 1         AND
            daiv.cal_type       = p_cal_type        AND
            daiv.ci_sequence_number = p_ci_sequence_number  AND
            daiv.dt_alias       = secc.enr_form_due_dt_alias AND
            IGS_CA_GEN_001.calp_set_alias_value(
                daiv.absolute_val,
                IGS_CA_GEN_002.cals_clc_dt_from_dai(
                    daiv.ci_sequence_number,
                    daiv.CAL_TYPE,
                    daiv.DT_ALIAS,
                    daiv.sequence_number) ) IS NOT NULL
        ORDER BY 1 DESC; -- gives latest date first

BEGIN
    -- If the parameter enrolment form due date is passed
    IF p_passing_due_date_ind = 'Y' AND
            p_enr_form_due_dt IS NOT NULL THEN
        RETURN p_enr_form_due_dt;
    END IF;
    -- If the date was not passed, then query the scae record for the date.
    -- The scae record should not have a null enr_form_due_dt.
    IF p_passing_due_date_ind = 'N' THEN
        OPEN c_scae;
        FETCH c_scae INTO v_enr_form_due_dt;
        IF (c_scae%FOUND) THEN
            CLOSE c_scae;
            RETURN v_enr_form_due_dt;
        END IF;
        CLOSE c_scae;
    END IF;
    -- Query the latest IGS_CA_DA_INST_V from the enrolment calendar instance
    OPEN c_latest_alias_val;
    FETCH c_latest_alias_val INTO v_alias_val;
    IF (c_latest_alias_val%FOUND) THEN
        CLOSE c_latest_alias_val;
        RETURN v_alias_val;
    END IF;
    CLOSE c_latest_alias_val;
    RETURN NULL;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_scae%ISOPEN) THEN
            CLOSE c_scae;
        END IF;
        IF (c_latest_alias_val%ISOPEN) THEN
            CLOSE c_latest_alias_val;
        END IF;
        RAISE;
END;
/*
EXCEPTION
    WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_scae_due');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
*/
END enrp_get_scae_due;

-- Following function modified as part of the Enrollments Process build - Bug #1832130
-- Created By : jbegum
-- This function will determine whether it is possible at the effective date to record new unit attempts in the nominated teaching period calendar instance
-- Validation is done at 3 levels ie person_type level , unit_section level and institutional level

-- Function modified by Nishikant - 21MAR2002 - Bug#2274500
-- Function was not returning TRUE if no date alias instances found at Person level or Unit section level or institution level, It was returning FALSE.

FUNCTION Enrp_Get_Rec_Window(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER,
  p_effective_date IN DATE,
  p_uoo_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS
/*******************************************************************************************************************************************************
   Created By         :Syam
   Date Created By    :
   Purpose            :-- Enrp_Get_Rec_Window
   -- Function will determine whether it is possible at the effective date to record new unit attempts in the nominated teaching period calendar
   -- instance at 3 levels ie person_type level , unit_section level and institutional level.
   -- If the effective date lies between the absolute values of Record open and Record cutoff date aliases defined at person level the function
   -- returns true else returns false .
   -- If no date aliases defined at person level then check at unit section level
   -- If the effective date lies between the absolute values of Record open date alias defined at institutional level and Record cutoff date alias
   -- defined at unit section level the function returns true else returns false .
   -- If no Record cutoff date alias defined at unit section level then check at institutional level
   -- If the effective date lies between the absolute values of Record open and Record cutoff date aliases defined at institutional level the function
   -- returns true else returns false .
   -- If no date aliases defined at any level then fuction returns true
    Change History
    Who       When         What
    ayedubat  30-MAY-2002  Added a new parameter,p_message_name for the bug fix:2337161
    kkillams  23-12-2002   Modified Function, Current function is not returning FALSE when both Record Cutoff date alias and Record Open date alias are past dates
                           and Record Cutoff date alias value is less than Record Open date alias value for Institution setup , w.r.t. bug 2660310
**********************************************************************************************************************************************************/
BEGIN
DECLARE
  l_person_type                   IGS_PE_USR_ARG.person_type%TYPE;
  l_record_open_dt_alias          IGS_EN_CAL_CONF.record_open_dt_alias%TYPE;
  l_record_cutoff_dt_alias        IGS_EN_CAL_CONF.record_cutoff_dt_alias%TYPE;
  l_daiv_rec_found                BOOLEAN;
  l_rec_open_dt_pass              BOOLEAN;
  l_open_dt                       IGS_CA_DA_INST_V.alias_val%TYPE;
  l_rec_cutt_off_dt               IGS_CA_DA_INST_V.alias_val%TYPE;
  l_effective_date                DATE;

  --modified cursor for performance bug 3696424
  CURSOR  c_recdt_alias_per_lvl( cp_person_type  IGS_PE_USR_ARG.person_type%TYPE ) IS
    SELECT  record_open_dt_alias,
            record_cutoff_dt_alias
    FROM  IGS_PE_USR_ARG_ALL
    WHERE person_type = cp_person_type;

  --Cursor is to get the all open date alias values for a calendar instance in ascending order.
  CURSOR  c_alias_val_op_dt(cp_cal_type            IGS_CA_DA_INST_V.cal_type%TYPE,
                             cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
                             cp_dt_alias           IGS_CA_DA_INST_V.dt_alias%TYPE) IS
    SELECT  alias_val FROM  IGS_CA_DA_INST_V
                      WHERE cal_type           = cp_cal_type
                      AND   ci_sequence_number = cp_ci_sequence_number
                      AND   dt_alias           = cp_dt_alias
                      AND   alias_val IS NOT NULL
                      ORDER BY alias_val ASC;

  --Cursor is to get the all Record Cutt-off alias values for a calendar instance in descending order.
  CURSOR  c_alias_val_rec_dt(cp_cal_type           IGS_CA_DA_INST_V.cal_type%TYPE,
                             cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
                             cp_dt_alias           IGS_CA_DA_INST_V.dt_alias%TYPE) IS
    SELECT alias_val FROM  IGS_CA_DA_INST_V
                     WHERE cal_type           = cp_cal_type
                     AND   ci_sequence_number = cp_ci_sequence_number
                     AND   dt_alias           = cp_dt_alias
                     AND   alias_val IS NOT NULL
                     ORDER BY alias_val DESC;

  -- Cursor to check the Non-Standard Unit Section
  CURSOR cur_non_std_usec_ind(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
    SELECT non_std_usec_ind  FROM IGS_PS_UNIT_OFR_OPT
                             WHERE uoo_id = p_uoo_id;

  CURSOR  c_recdt_alias_usec_lvl1( cp_uoo_id  IGS_EN_NSTD_USEC_DL.uoo_id%TYPE ) IS
    SELECT  enr_dl_date
    FROM  IGS_EN_NSTD_USEC_DL
    WHERE function_name = 'RECORD_CUTOFF'
    AND   uoo_id = cp_uoo_id;

  CURSOR  c_recdt_alias_usec_lvl2 IS
    SELECT  record_open_dt_alias
    FROM  IGS_EN_CAL_CONF
    WHERE s_control_num = 1;

  CURSOR  c_recdt_alias_inst_lvl IS
    SELECT  record_open_dt_alias,
            record_cutoff_dt_alias
    FROM  IGS_EN_CAL_CONF
    WHERE s_control_num = 1;

  l_non_std_usec_ind  IGS_PS_UNIT_OFR_OPT.non_std_usec_ind%TYPE;

BEGIN

   -- initialize the message parameter with NULL
   p_message_name := NULL;
   l_effective_date := TRUNC(p_effective_date);
   -- Validation at person_type level
   l_person_type := IGS_EN_GEN_008.enrp_get_person_type;

   IF l_person_type IS NOT NULL THEN

     OPEN    c_recdt_alias_per_lvl(l_person_type);
     FETCH   c_recdt_alias_per_lvl INTO l_record_open_dt_alias,
                                        l_record_cutoff_dt_alias;
       -- If no date aliases defined at person_type level go to unit_section level
       IF (c_recdt_alias_per_lvl%FOUND) THEN
         CLOSE c_recdt_alias_per_lvl;
         -- If both date alias values are null at person_type level go to unit_section level
         IF (l_record_open_dt_alias IS NOT NULL OR l_record_cutoff_dt_alias IS NOT NULL) THEN
               l_open_dt := NULL;
               l_rec_cutt_off_dt := NULL;
               IF l_record_open_dt_alias IS NOT NULL THEN
                  OPEN c_alias_val_op_dt (p_cal_type,
                                          p_ci_sequence_number,
                                          l_record_open_dt_alias);
                  FETCH c_alias_val_op_dt INTO l_open_dt;
                  CLOSE c_alias_val_op_dt;
               END IF; -- l_record_open_dt_alias IS NOT NULL

               IF l_record_cutoff_dt_alias IS NOT NULL THEN
                  OPEN c_alias_val_rec_dt(p_cal_type,
                                          p_ci_sequence_number,
                                          l_record_cutoff_dt_alias);
                  FETCH c_alias_val_rec_dt INTO l_rec_cutt_off_dt;
                  CLOSE c_alias_val_rec_dt;
               END IF; --l_record_cutoff_dt_alias IS NOT NULL

               --Return true if open date is defined and effective date is greater than open date and
               --record cut-off date is defined and effective date is less than or equal to the record
               --cut-off date else return false along error message.
               IF (l_open_dt IS NULL OR l_open_dt <= l_effective_date) AND
                  (l_rec_cutt_off_dt IS NULL OR l_effective_date <= l_rec_cutt_off_dt)  THEN
                  RETURN TRUE;
               ELSE
                 p_message_name := 'IGS_EN_SUA_NOTENR_OUTS_REC_PT';
                 RETURN FALSE;
               END IF;
         END IF; -- For the IF checking whether l_record_open_dt_alias IS NOT NULL OR l_record_cutoff_dt_alias IS NOT NULL
      END IF;  -- For the IF checking whether c_recdt_alias_per_lvl%FOUND
   END IF; -- For the IF checking whether l_person_type IS NOT NULL

   -- Validation at unit_section level

   l_record_open_dt_alias := NULL;
   l_record_cutoff_dt_alias := NULL;
   l_rec_cutt_off_dt := NULL;
   l_open_dt := NULL;

   OPEN    c_recdt_alias_usec_lvl1(p_uoo_id);
   OPEN    c_recdt_alias_usec_lvl2;
   -- record cutoff date is being fetched from Unit Section level and record open date alias
   -- is being fetched from Institution level
   FETCH      c_recdt_alias_usec_lvl1 INTO  l_rec_cutt_off_dt;
   FETCH      c_recdt_alias_usec_lvl2 INTO  l_record_open_dt_alias;
   IF c_recdt_alias_usec_lvl1%FOUND THEN
      CLOSE    c_recdt_alias_usec_lvl1;
      CLOSE    c_recdt_alias_usec_lvl2;
      IF l_record_open_dt_alias IS NOT NULL THEN
         OPEN c_alias_val_op_dt (p_cal_type,
                                 p_ci_sequence_number,
                                 l_record_open_dt_alias);
         FETCH c_alias_val_op_dt INTO l_open_dt;
         CLOSE c_alias_val_op_dt;
       END IF; -- l_record_open_dt_alias IS NOT NULL
       IF (l_open_dt IS NULL OR l_open_dt <= l_effective_date) AND
          (l_rec_cutt_off_dt IS NULL OR l_effective_date <= l_rec_cutt_off_dt)  THEN
           RETURN TRUE;
       ELSE
             OPEN cur_non_std_usec_ind(p_uoo_id);
             FETCH cur_non_std_usec_ind INTO l_non_std_usec_ind;
             CLOSE cur_non_std_usec_ind;

             -- Check weather the Unit Section is Standard or Non Standard as assign the message accordingly.
             IF l_non_std_usec_ind = 'Y' THEN
               p_message_name := 'IGS_EN_SUA_NOTENR_OUTS_REC_NSU';
             ELSE
               p_message_name := 'IGS_EN_SUA_NOTENR_OUTS_REC_SU';
             END IF;
             RETURN FALSE;
       END IF;
   ELSE
       CLOSE    c_recdt_alias_usec_lvl1;
       CLOSE    c_recdt_alias_usec_lvl2;
   END IF;

   -- Validation at Institutional level

   l_record_open_dt_alias := NULL;
   l_record_cutoff_dt_alias := NULL;
   OPEN c_recdt_alias_inst_lvl;
   FETCH  c_recdt_alias_inst_lvl INTO l_record_open_dt_alias,
                                      l_record_cutoff_dt_alias;

   -- If no dates defined at any level then the function returns true
   IF (c_recdt_alias_inst_lvl%NOTFOUND) THEN
     CLOSE c_recdt_alias_inst_lvl;
     RETURN TRUE;
   END IF;
   -- If date aliases defined at institution level
   CLOSE  c_recdt_alias_inst_lvl;

   -- If both date alias values are NULL then return TRUE in ELSE part
   IF (l_record_cutoff_dt_alias IS NOT NULL OR l_record_open_dt_alias IS NOT NULL) THEN

      l_daiv_rec_found := FALSE;
      -- This variable helps for checking when cut-off date alias or cut off date alias instances are not defined
      l_rec_open_dt_pass := FALSE;

      l_open_dt := NULL;
      l_rec_cutt_off_dt := NULL;
      IF l_record_open_dt_alias IS NOT NULL THEN
         OPEN c_alias_val_op_dt (p_cal_type,
                                 p_ci_sequence_number,
                                 l_record_open_dt_alias);
         FETCH c_alias_val_op_dt INTO l_open_dt;
         CLOSE c_alias_val_op_dt;
      END IF; -- l_record_open_dt_alias IS NOT NULL

      IF l_record_cutoff_dt_alias IS NOT NULL THEN
         OPEN c_alias_val_rec_dt(p_cal_type,
                                 p_ci_sequence_number,
                                 l_record_cutoff_dt_alias);
         FETCH c_alias_val_rec_dt INTO l_rec_cutt_off_dt;
         CLOSE c_alias_val_rec_dt;
      END IF; --l_record_cutoff_dt_alias IS NOT NULL

      --Return true if open date is defined and effective date is greater than open date and
      --record cut-off date is defined and effective date is less than or equal to the record
      --cut-off date else return false along error message.
      IF (l_open_dt IS NULL OR l_open_dt <= l_effective_date) AND
         (l_rec_cutt_off_dt IS NULL OR l_effective_date <= l_rec_cutt_off_dt)  THEN
         RETURN TRUE;
      ELSE
        p_message_name := 'IGS_EN_SUA_NOTENR_RECENR_WIN';
        RETURN FALSE;
      END IF;
   END IF;
   -- If both date alises are not defined at any level then the function returns true
   RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_rec_window');
     IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

 END;

END enrp_get_rec_window;

FUNCTION Enrp_Get_Perd_Num(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_acad_start_dt IN DATE )
RETURN NUMBER AS

BEGIN   -- enrp_get_perd_num
    -- Get the academic period number of the students enrolment. This is done by
    -- looping through the academic periods within which the student has studied
    -- IGS_PS_UNIT attempts.
DECLARE
    cst_unconfirm       CONSTANT VARCHAR2(10) := 'UNCONFIRM';
    cst_academic        CONSTANT VARCHAR2(10) := 'ACADEMIC';
    cst_active      CONSTANT VARCHAR2(10) := 'ACTIVE';
    v_record_count      NUMBER;
    CURSOR  c_sua_cir_ci_cat_cs IS
        SELECT DISTINCT     cir.sup_cal_type,
                    cir.sup_ci_sequence_number
        FROM    IGS_EN_SU_ATTEMPT       sua,
            IGS_CA_INST_REL cir,
            IGS_CA_INST         ci,
            IGS_CA_TYPE         cat,
            IGS_CA_STAT         cs
        WHERE   sua.person_id           = p_person_id AND
            sua.course_cd           = p_course_cd AND
            sua.unit_attempt_status     <> cst_unconfirm AND
            cir.sub_cal_type        = sua.cal_type AND
            cir.sub_ci_sequence_number  = sua.ci_sequence_number AND
            ci.cal_type             = cir.sup_cal_type AND
            ci.sequence_number      = cir.sup_ci_sequence_number AND
            cat.cal_type            = ci.cal_type AND
            cat.S_CAL_CAT           = cst_academic AND
            cs.CAL_STATUS           = ci.CAL_STATUS AND
            ci.start_dt             < p_acad_start_dt;
BEGIN
    v_record_count := 0;
    FOR v_sua_cir_ci_cat_cs_rec IN c_sua_cir_ci_cat_cs LOOP
        v_record_count := v_record_count+1;
    END LOOP;
    RETURN v_record_count+1;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_sua_cir_ci_cat_cs%ISOPEN) THEN
            CLOSE c_sua_cir_ci_cat_cs;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.enrp_get_perd_num');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END enrp_get_perd_num;

-- Following procedure added as part of the Enrollments Process build - Bug #1832130
-- Created By : jbegum
-- This procedure when invoked will discontinue/drop all unit attempts of a student within a given term calendar

PROCEDURE Enrp_Dropall_Unit(
  p_person_id IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_dcnt_reason_cd IN VARCHAR2 ,
  p_admin_unit_sta IN VARCHAR2 ,
  p_effective_date IN DATE ,
  p_program_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_sub_unit IN VARCHAR2
  )

AS

BEGIN   -- Enrp_Dropall_Unit
    -- Update all the unit attempt records of a student in the table IGS_EN_SU_ATTEMPT with
    -- unit_attempt_status as 'DROPPED' or 'DISCONTIN'
/* HISTORY
  WHO         WHEN         WHAT
  mesriniv    12-sep-2002  Added a new parameter waitlist_manual_ind in update row of IGS_EN_SU_ATTEMPT
                           for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
  ayedubat    02-JUL-2002  Added a new validation to check the Variation Window Cutoff Date
                           for the bug Fix:2423605
  ayedubat    26-JUN-2002  Changed the width of the variable,l_adm_unit_status_ret to VARCHAR2(255)
                           and also removed the exception handler for the bug fix:2423605
  rvangala    07-OCT-03    Passing core_indicator_code to IGS_EN_SUA-API.UPDATE_UNIT_ATTEMPT added as part of Prevent Dropping
                           Core Units. Enh Bug# 3052432
  amuthu      9-Aug-2006      If the default drop reason cannot be determined then
  --                            stopping the further processing and showing a newly added message*/

DECLARE

       l_unit_attempt VARCHAR2(1);
       l_adm_unit_status_ret VARCHAR2(255);
       l_adm_unit_status VARCHAR2(2000);
       l_alias_val DATE;
       l_first_char NUMBER;
       l_current_string VARCHAR2(10);
       l_val VARCHAR2(1);
  --modified cursor for performance bug 3693713
  CURSOR c_unit_attempt IS
         SELECT  U.*
         FROM    IGS_EN_SU_ATTEMPT U
         WHERE   person_id = p_person_id
         AND ((unit_attempt_status IN ('ENROLLED','INVALID','WAITLISTED'))
               OR (unit_attempt_status = 'DUPLICATE' AND P_UOO_ID IS NOT NULL))
         AND course_cd = p_program_cd AND ((p_uoo_id IS NULL) OR (uoo_id =  p_uoo_id));

-- Added new cursor for performance bug  3693713
CURSOR   c_is_unit_exists(p_load_cal_type IGS_CA_INST.cal_type%TYPE,
                           p_load_ci_seq_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                           p_tch_cal_type IGS_CA_INST.cal_type%TYPE,
                           p_tch_ci_seq_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
          SELECT 'x'
          FROM   igs_ca_load_to_teach_v
          WHERE  load_cal_type = p_load_cal_type
          AND load_ci_sequence_number = p_load_ci_seq_number
          AND teach_cal_type = p_tch_cal_type
          AND teach_ci_sequence_number = p_tch_ci_seq_number;

BEGIN

  -- check if all the parameters are specified ie they are not null
  IF p_dcnt_reason_cd IS NULL  THEN
    Fnd_Message.Set_Name('IGS' , 'IGS_EN_DFLT_DCNT_RSN_NOT_SETUP');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END IF;

  IF  p_person_id IS NULL OR
    p_cal_type  IS NULL OR
    p_ci_sequence_number IS NULL THEN

    Fnd_Message.Set_Name('IGS' , 'IGS_GE_INSUFFICIENT_PARAMETER');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;

  END IF;

    -- Checking whether dropping of the 'unit attempt BY a student ' is allowed within the nominated teaching calendar instance
    -- at the nominated effective date

  FOR c_unit_attempt_rec IN  c_unit_attempt     LOOP
    OPEN c_is_unit_exists(p_cal_type,
                          p_ci_sequence_number,
                          c_unit_attempt_rec.cal_type,
                          c_unit_attempt_rec.ci_sequence_number);
    FETCH c_is_unit_exists INTO l_val;

    IF  c_is_unit_exists%FOUND THEN

      IF p_sub_unit = 'Y' THEN
      l_unit_attempt := 'Y';
      ELSE
      l_unit_attempt := IGS_EN_GEN_008.Enrp_Get_Ua_Del_Alwd(P_CAL_TYPE => c_unit_attempt_rec.cal_type,
                                                            P_CI_SEQUENCE_NUMBER => c_unit_attempt_rec.ci_sequence_number,
                                                            P_EFFECTIVE_DT => p_effective_date,
                                                            P_UOO_ID => c_unit_attempt_rec.uoo_id );

    END IF;
    -- Validate the variation window dead limits if the Unit Attempt Status is not 'WAITLISTED'
    IF c_unit_attempt_rec.unit_attempt_status NOT IN ('WAITLISTED','DUPLICATE')  THEN

      -- If the Dropped/Discontinued Date is not with in the Variation window boundary, Raise the Error
      -- Otherwise Continue the Processing
      IF NOT igs_en_gen_008.enrp_get_var_window(
                c_unit_attempt_rec.cal_type,
                c_unit_attempt_rec.ci_sequence_number,
                p_effective_date,
                c_unit_attempt_rec.uoo_id )  THEN

        Fnd_Message.Set_Name('IGS','IGS_EN_SUA_NOTENR_DISCONT');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

      END IF;
    END IF;

    -- if it is a duplicate unit attempt then delete the unit attempt instead of dropping it.

    IF c_unit_attempt_rec.unit_attempt_status = 'DUPLICATE' THEN
      IGS_EN_SU_ATTEMPT_PKG.DELETE_ROW(X_ROWID => c_unit_attempt_rec.row_id);
      RETURN;
    END If;

      -- If dropping of the 'unit attempt BY a student ' is allowed within the nominated teaching calendar instance at the nominated
      -- effective date then update the unit_attempt_status to 'DROPPED'

          -- Added the OR clause in the below If condtion OR unit_attempt status is WAITLISTED
      -- Added by Nishikant - bug#2364216. If the status is WAITLISTED then no need to check whether the unit attempt can be deleted
    IF (l_unit_attempt = 'Y' OR c_unit_attempt_rec.unit_attempt_status = 'WAITLISTED') THEN

      -- Call the API to update the student unit attempt. This API is a
      -- wrapper to the update row of the TBH.
      igs_en_sua_api.update_unit_attempt (
        X_ROWID => c_unit_attempt_rec.row_id,
        X_PERSON_ID  => c_unit_attempt_rec.person_id,
        X_COURSE_CD  => c_unit_attempt_rec.course_cd,
        X_UNIT_CD  => c_unit_attempt_rec.unit_cd,
        X_CAL_TYPE  => c_unit_attempt_rec.cal_type,
        X_CI_SEQUENCE_NUMBER  => c_unit_attempt_rec.ci_sequence_number,
        X_VERSION_NUMBER  => c_unit_attempt_rec.version_number,
        X_LOCATION_CD  => c_unit_attempt_rec.location_cd,
        X_UNIT_CLASS  => c_unit_attempt_rec.unit_class,
        X_CI_START_DT  => c_unit_attempt_rec.ci_start_dt,
        X_CI_END_DT  => c_unit_attempt_rec.ci_end_dt,
        X_UOO_ID  => c_unit_attempt_rec.uoo_id,
        X_ENROLLED_DT  => c_unit_attempt_rec.enrolled_dt,
        X_UNIT_ATTEMPT_STATUS  => 'DROPPED',
        X_ADMINISTRATIVE_UNIT_STATUS  => NULL,
        X_DISCONTINUED_DT  => nvl(p_effective_date,trunc(SYSDATE)),
        X_RULE_WAIVED_DT  =>c_unit_attempt_rec.rule_waived_dt,
        X_RULE_WAIVED_PERSON_ID  =>c_unit_attempt_rec.rule_waived_person_id,
        X_NO_ASSESSMENT_IND  => c_unit_attempt_rec.no_assessment_ind,
        X_SUP_UNIT_CD  => c_unit_attempt_rec.sup_unit_cd,
        X_SUP_VERSION_NUMBER  => c_unit_attempt_rec.sup_version_number,
        X_EXAM_LOCATION_CD  => c_unit_attempt_rec.exam_location_cd,
        X_ALTERNATIVE_TITLE  => c_unit_attempt_rec.alternative_title,
        X_OVERRIDE_ENROLLED_CP  => c_unit_attempt_rec.override_enrolled_cp,
        X_OVERRIDE_EFTSU  => c_unit_attempt_rec.override_eftsu,
        X_OVERRIDE_ACHIEVABLE_CP  => c_unit_attempt_rec.override_achievable_cp,
        X_OVERRIDE_OUTCOME_DUE_DT  => c_unit_attempt_rec.override_outcome_due_dt,
        X_OVERRIDE_CREDIT_REASON  => c_unit_attempt_rec.override_credit_reason,
        X_ADMINISTRATIVE_PRIORITY  => c_unit_attempt_rec.administrative_priority,
        X_WAITLIST_DT  => c_unit_attempt_rec.waitlist_dt,
        X_DCNT_REASON_CD  => p_dcnt_reason_cd,
        X_MODE            => 'R',
        X_GS_VERSION_NUMBER => c_unit_attempt_rec.gs_version_number,
        X_ENR_METHOD_TYPE   => c_unit_attempt_rec.enr_method_type,
        X_FAILED_UNIT_RULE  => c_unit_attempt_rec.failed_unit_rule,
        X_CART              => c_unit_attempt_rec.cart,
        X_RSV_SEAT_EXT_ID   => c_unit_attempt_rec.rsv_seat_ext_id,
        X_ORG_UNIT_CD   =>  c_unit_attempt_rec.org_unit_cd,
        -- Added the column grading schema code as a part of the bug 2037897. - aiyer
        X_GRADING_SCHEMA_CODE => c_unit_attempt_rec.grading_schema_code,
        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
        X_SESSION_ID         =>  c_unit_attempt_rec.session_id,
        --Added the column deg_aud_detail_id as part of Degree Audit Interface build. Bug# 2033208 - pradhakr
        X_DEG_AUD_DETAIL_ID   => c_unit_attempt_rec.deg_aud_detail_id,
        X_SUBTITLE       =>  c_unit_attempt_rec.subtitle,
        --Added the columns student_career_transcript,student_career_statistics as part of Career Impact DLD
        -- part 2 . Bug # svenkata
        X_STUDENT_CAREER_TRANSCRIPT =>  c_unit_attempt_rec.student_career_transcript,
        X_STUDENT_CAREER_STATISTICS =>  c_unit_attempt_rec.student_career_statistics,
        X_ATTRIBUTE_CATEGORY        =>  c_unit_attempt_rec.attribute_category,
        X_ATTRIBUTE1                =>  c_unit_attempt_rec.attribute1,
        X_ATTRIBUTE2                =>  c_unit_attempt_rec.attribute2,
        X_ATTRIBUTE3                =>  c_unit_attempt_rec.attribute3,
        X_ATTRIBUTE4                =>  c_unit_attempt_rec.attribute4,
        X_ATTRIBUTE5                =>  c_unit_attempt_rec.attribute5,
        X_ATTRIBUTE6                =>  c_unit_attempt_rec.attribute6,
        X_ATTRIBUTE7                =>  c_unit_attempt_rec.attribute7,
        X_ATTRIBUTE8                =>  c_unit_attempt_rec.attribute8,
        X_ATTRIBUTE9                =>  c_unit_attempt_rec.attribute9,
        X_ATTRIBUTE10               =>  c_unit_attempt_rec.attribute10,
        X_ATTRIBUTE11               =>  c_unit_attempt_rec.attribute11,
        X_ATTRIBUTE12               =>  c_unit_attempt_rec.attribute12,
        X_ATTRIBUTE13               =>  c_unit_attempt_rec.attribute13,
        X_ATTRIBUTE14               =>  c_unit_attempt_rec.attribute14,
        X_ATTRIBUTE15               =>  c_unit_attempt_rec.attribute15,
        X_ATTRIBUTE16               =>  c_unit_attempt_rec.attribute16,
        X_ATTRIBUTE17               =>  c_unit_attempt_rec.attribute17,
        X_ATTRIBUTE18               =>  c_unit_attempt_rec.attribute18,
        X_ATTRIBUTE19               =>  c_unit_attempt_rec.attribute19,
        X_ATTRIBUTE20               =>  c_unit_attempt_rec.attribute20,
        X_WAITLIST_MANUAL_IND       =>  c_unit_attempt_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109.,
        X_WLST_PRIORITY_WEIGHT_NUM  =>  c_unit_attempt_rec.wlst_priority_weight_num,
        X_WLST_PREFERENCE_WEIGHT_NUM=>  c_unit_attempt_rec.wlst_preference_weight_num,
	-- CORE_INDICATOR_CODE --added by rvangala 07-OCT-2003. Enh Bug# 3052432
	x_CORE_INDICATOR_CODE       =>  c_unit_attempt_rec.core_indicator_code
      );

      -- since a waitlisetd unit could have contributed to the fee we need
      -- to create a TODO record to recalculate the fee when a waitlisted unit
      -- is dropped. The unit would contribute towards the CP or fee based on the
      -- profile IGS_EN_INCL_WLST_CP
      IF c_unit_attempt_rec.unit_attempt_status = 'WAITLISTED' THEN
        IGS_SS_EN_WRAPPERS.call_fee_ass (
          p_person_id => p_person_id,
          p_cal_type => p_cal_type, -- load
          p_sequence_number => p_ci_sequence_number, -- load
          p_course_cd => c_unit_attempt_rec.course_cd,
          p_unit_cd => c_unit_attempt_rec.unit_cd,
          p_uoo_id => c_unit_attempt_rec.uoo_id
        );
      END IF;

    ELSE

      -- If dropping of the 'unit attempt BY a student ' is NOT allowed within the nominated teaching calendar instance at the nominated
      -- effective date then update the unit_attempt_status to 'DISCONTIN' also get the  administrative unit

      IF p_admin_unit_sta is NOT NULL THEN
        l_adm_unit_status_ret := p_admin_unit_sta;
      ELSE
        l_adm_unit_status_ret :=IGS_EN_GEN_008.Enrp_Get_Uddc_Aus  (
                                          P_DISCONTINUED_DT => p_effective_date,
                                          P_CAL_TYPE => c_unit_attempt_rec.cal_type,
                                          P_CI_SEQUENCE_NUMBER => c_unit_attempt_rec.ci_sequence_number,
                                          P_ADMIN_UNIT_STATUS_STR => l_adm_unit_status,
                                          P_ALIAS_VAL => l_alias_val,
                                          P_UOO_ID => c_unit_attempt_rec.uoo_id );
        IF l_adm_unit_status_ret IS NULL THEN
          --l_adm_unit_status_ret := SUBSTR(l_adm_unit_status,1,10);sudhir
          l_adm_unit_status_ret := NULL;
          l_first_char := 1;
          LOOP
              -- exit when the end of the string is reached
              EXIT WHEN l_first_char >= LENGTH(l_adm_unit_status);
              -- put 10 characters at a a time into a string for comparison
              l_current_string := (SUBSTR(l_adm_unit_status, l_first_char, 10));
              -- don't do anything if the string is null
              IF (l_current_string IS NULL) THEN
                  EXIT;
              ELSE
                  IF l_adm_unit_status_ret IS NULL THEN
                     l_adm_unit_status_ret := RTRIM(RPAD(l_current_string,10,' '));
                  ELSE
                     l_adm_unit_status_ret := l_adm_unit_status_ret||','||RTRIM(RPAD(l_current_string,10,' '));
                  END IF;
                  l_first_char := l_first_char + 11;
              END IF;
          END LOOP;
          Fnd_Message.Set_Name('IGS','IGS_SS_EN_MANY_ADMIN_UNSTA');
          FND_MESSAGE.SET_TOKEN('LIST',l_adm_unit_status_ret);
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
      END IF;

      -- Call the API to update the student unit attempt. This API is a
      -- wrapper to the update row of the TBH.
      igs_en_sua_api.update_unit_attempt(
        X_ROWID => c_unit_attempt_rec.row_id,
        X_PERSON_ID  => c_unit_attempt_rec.person_id,
        X_COURSE_CD  => c_unit_attempt_rec.course_cd,
        X_UNIT_CD  => c_unit_attempt_rec.unit_cd,
        X_CAL_TYPE  => c_unit_attempt_rec.cal_type,
        X_CI_SEQUENCE_NUMBER  => c_unit_attempt_rec.ci_sequence_number,
        X_VERSION_NUMBER  => c_unit_attempt_rec.version_number,
        X_LOCATION_CD  => c_unit_attempt_rec.location_cd,
        X_UNIT_CLASS  => c_unit_attempt_rec.unit_class,
        X_CI_START_DT  => c_unit_attempt_rec.ci_start_dt,
        X_CI_END_DT  => c_unit_attempt_rec.ci_end_dt,
        X_UOO_ID  => c_unit_attempt_rec.uoo_id,
        X_ENROLLED_DT  => c_unit_attempt_rec.enrolled_dt,
        X_UNIT_ATTEMPT_STATUS  => 'DISCONTIN',
        X_ADMINISTRATIVE_UNIT_STATUS  => l_adm_unit_status_ret,
        X_DISCONTINUED_DT  => p_effective_date,
        X_RULE_WAIVED_DT  =>c_unit_attempt_rec.rule_waived_dt,
        X_RULE_WAIVED_PERSON_ID  =>c_unit_attempt_rec.rule_waived_person_id,
        X_NO_ASSESSMENT_IND  => c_unit_attempt_rec.no_assessment_ind,
        X_SUP_UNIT_CD  => c_unit_attempt_rec.sup_unit_cd,
        X_SUP_VERSION_NUMBER  => c_unit_attempt_rec.sup_version_number,
        X_EXAM_LOCATION_CD  => c_unit_attempt_rec.exam_location_cd,
        X_ALTERNATIVE_TITLE  => c_unit_attempt_rec.alternative_title,
        X_OVERRIDE_ENROLLED_CP  => c_unit_attempt_rec.override_enrolled_cp,
        X_OVERRIDE_EFTSU  => c_unit_attempt_rec.override_eftsu,
        X_OVERRIDE_ACHIEVABLE_CP  => c_unit_attempt_rec.override_achievable_cp,
        X_OVERRIDE_OUTCOME_DUE_DT  => c_unit_attempt_rec.override_outcome_due_dt,
        X_OVERRIDE_CREDIT_REASON  => c_unit_attempt_rec.override_credit_reason,
        X_ADMINISTRATIVE_PRIORITY  => c_unit_attempt_rec.administrative_priority,
        X_WAITLIST_DT  => c_unit_attempt_rec.waitlist_dt,
        X_DCNT_REASON_CD  => p_dcnt_reason_cd,
        X_MODE              => 'R',
        X_GS_VERSION_NUMBER => c_unit_attempt_rec.gs_version_number,
        X_ENR_METHOD_TYPE   => c_unit_attempt_rec.enr_method_type,
        X_FAILED_UNIT_RULE  => c_unit_attempt_rec.failed_unit_rule,
        X_CART              => c_unit_attempt_rec.cart,
        X_RSV_SEAT_EXT_ID   => c_unit_attempt_rec.rsv_seat_ext_id,
        X_ORG_UNIT_CD   => c_unit_attempt_rec.org_unit_cd,
        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
        X_SESSION_ID        => c_unit_attempt_rec.session_id,
        -- Added the column grading schema code as a part of the bug 2037897. - aiyer
        X_GRADING_SCHEMA_CODE => c_unit_attempt_rec.grading_schema_code,
        --Added the column deg_aud_detail_id as part of Degree Audit Interface build. Bug# 2033208 - pradhakr
        X_DEG_AUD_DETAIL_ID   => c_unit_attempt_rec.deg_aud_detail_id,
        X_SUBTITLE       =>  c_unit_attempt_rec.subtitle,
        --Added the columns student_career_transcript,student_career_statistics as part of Career Impact DLD
        -- part 2 . Bug # svenkata
        X_STUDENT_CAREER_TRANSCRIPT =>  c_unit_attempt_rec.student_career_transcript,
        X_STUDENT_CAREER_STATISTICS =>  c_unit_attempt_rec.student_career_statistics,
        X_ATTRIBUTE_CATEGORY        =>  c_unit_attempt_rec.attribute_category,
        X_ATTRIBUTE1                =>  c_unit_attempt_rec.attribute1,
        X_ATTRIBUTE2                =>  c_unit_attempt_rec.attribute2,
        X_ATTRIBUTE3                =>  c_unit_attempt_rec.attribute3,
        X_ATTRIBUTE4                =>  c_unit_attempt_rec.attribute4,
        X_ATTRIBUTE5                =>  c_unit_attempt_rec.attribute5,
        X_ATTRIBUTE6                =>  c_unit_attempt_rec.attribute6,
        X_ATTRIBUTE7                =>  c_unit_attempt_rec.attribute7,
        X_ATTRIBUTE8                =>  c_unit_attempt_rec.attribute8,
        X_ATTRIBUTE9                =>  c_unit_attempt_rec.attribute9,
        X_ATTRIBUTE10               =>  c_unit_attempt_rec.attribute10,
        X_ATTRIBUTE11               =>  c_unit_attempt_rec.attribute11,
        X_ATTRIBUTE12               =>  c_unit_attempt_rec.attribute12,
        X_ATTRIBUTE13               =>  c_unit_attempt_rec.attribute13,
        X_ATTRIBUTE14               =>  c_unit_attempt_rec.attribute14,
        X_ATTRIBUTE15               =>  c_unit_attempt_rec.attribute15,
        X_ATTRIBUTE16               =>  c_unit_attempt_rec.attribute16,
        X_ATTRIBUTE17               =>  c_unit_attempt_rec.attribute17,
        X_ATTRIBUTE18               =>  c_unit_attempt_rec.attribute18,
        X_ATTRIBUTE19               =>  c_unit_attempt_rec.attribute19,
        X_ATTRIBUTE20               =>  c_unit_attempt_rec.attribute20,
        X_WAITLIST_MANUAL_IND       =>  c_unit_attempt_rec.waitlist_manual_ind, --Added by mesriniv for Bug 2554109.
        X_WLST_PRIORITY_WEIGHT_NUM  =>  c_unit_attempt_rec.wlst_priority_weight_num,
        X_WLST_PREFERENCE_WEIGHT_NUM=>  c_unit_attempt_rec.wlst_preference_weight_num,
	-- CORE_INDICATOR_CODE --added by rvangala 07-OCT-2003. Enh Bug# 3052432
	X_CORE_INDICATOR_CODE       =>  c_unit_attempt_rec.core_indicator_code
        );
    END IF;

    IGS_SS_EN_WRAPPERS.call_fee_ass (
      p_person_id => p_person_id,
      p_cal_type => p_cal_type, -- load
      p_sequence_number => p_ci_sequence_number, -- load
      p_course_cd => c_unit_attempt_rec.course_cd,
      p_unit_cd => c_unit_attempt_rec.unit_cd,
      p_uoo_id => c_unit_attempt_rec.uoo_id
    );

    END IF; --END of c_is_unit_exists%FOUND
    CLOSE c_is_unit_exists;

  END LOOP;

END;

/* Removing the exception since the real error message is not getting propagated to the SS Drop Screens
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_004.Enrp_Dropall_Unit');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
*/

END enrp_dropall_unit;

END IGS_EN_GEN_004;

/
