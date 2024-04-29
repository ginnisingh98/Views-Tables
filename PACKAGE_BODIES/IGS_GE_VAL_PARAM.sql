--------------------------------------------------------
--  DDL for Package Body IGS_GE_VAL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_VAL_PARAM" 
/* $Header: IGSGE08B.pls 120.0 2005/06/01 15:52:59 appldev noship $ */

AS
-- Global Variables
gv_other_detail VARCHAR2(256)   := NULL;
-- Module:      repp_val_unit_cd
-- Purpose:     validation for unit code
--
-- MODIFICATION HISTORY
-- IGS_PE_PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
-- smvk         09-Jul-2004     Bug # 3676145. Modified the cursors c_uc and c_mode to select active (not closed) unit classes.
FUNCTION repp_val_unit_cd( p_unit_cd IN OUT NOCOPY IGS_PS_UNIT_VER_all.unit_cd%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_unit(cp_unit_cd IGS_PS_UNIT_VER.unit_cd%TYPE)
IS
SELECT
        'x'
FROM    IGS_PS_UNIT_VER    UV,
        IGS_PS_UNIT_STAT     UNS
WHERE
        uv.unit_cd              LIKE    cp_unit_cd
AND     uns.unit_status         =       uv.unit_status
AND     uns.s_unit_status       =       'ACTIVE';
--
-- Local Variables
v_unit_ok       VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('UNIT_CD','IGS_PS_UNIT_VER')
        THEN
                p_unit_cd := UPPER(p_unit_cd);
        END IF;
        --
        -- validate IGS_PS_UNIT entered
        IF c_unit%ISOPEN
        THEN
                CLOSE c_unit;
        END IF;
        OPEN c_unit(p_unit_cd);
        FETCH c_unit INTO v_unit_ok;
        IF c_unit%NOTFOUND
        THEN
                CLOSE c_unit;
                p_msg_name := 'IGS_GE_VAL_DOES_NOT_XS';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_unit%ISOPEN
                THEN
                        CLOSE c_unit;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_unit_cd
-- Module:      repp_val_location
-- Purpose:     validation for unit code
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_location( p_location_cd IN OUT NOCOPY IGS_AD_LOCATION_ALL.location_cd%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_loc(cp_loc_cd IGS_AD_LOCATION.location_cd%TYPE)
IS
SELECT
        'x'
FROM    IGS_AD_LOCATION        LOC
WHERE
        loc.location_cd LIKE    cp_loc_cd
AND     loc.closed_ind  =       'N';
--
-- Local Variables
v_loc_ok        VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('LOCATION_CD','LOCATION')
        THEN
                p_location_cd := UPPER(p_location_cd);
        END IF;
        --
         -- validate unit entered
        IF c_loc%ISOPEN
        THEN
                CLOSE c_loc;
        END IF;
        OPEN c_loc(p_location_cd);
        FETCH c_loc INTO v_loc_ok;
        IF c_loc%NOTFOUND
        THEN
                CLOSE c_loc;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_loc%ISOPEN
                THEN
                        CLOSE c_loc;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_location_cd
-- Module:      repp_val_att_mode
-- Purpose:     validation for attendance modes
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_att_mode( p_att_mode IN OUT NOCOPY IGS_EN_ATD_MODE_ALL.ATTENDANCE_MODE%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_att(cp_att_mode IGS_EN_ATD_MODE.ATTENDANCE_MODE%TYPE)
IS
SELECT
        'x'
FROM    IGS_EN_ATD_MODE atm
WHERE
        atm.attendance_mode     LIKE    cp_att_mode
AND     atm.closed_ind          =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_EN_ATD_MODE','IGS_EN_ATD_MODE')
        THEN
                p_att_mode := UPPER(p_att_mode);
        END IF;
        --
         -- validate unit entered
        IF c_att%ISOPEN
        THEN
                CLOSE c_att;
        END IF;
        OPEN c_att(p_att_mode);
        FETCH c_att INTO v_ok;
        IF c_att%NOTFOUND
        THEN
                CLOSE c_att;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_att%ISOPEN
                THEN
                        CLOSE c_att;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_att_mode
-- Module:      repp_val_att_type
-- Purpose:     validation for attendance types
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_att_type( p_att_type IN OUT NOCOPY IGS_EN_ATD_TYPE_ALL.attendance_type%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_att(cp_att_type IGS_EN_ATD_TYPE.ATTENDANCE_TYPE%TYPE)
IS
SELECT
        'x'
FROM    IGS_EN_ATD_TYPE att
WHERE
        att.attendance_type     LIKE    cp_att_type
AND     att.closed_ind          =       'N';
--
-- Local Variables
v_att_ok        VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('ATTEDANCE_TYPE','IGS_EN_ATD_TYPE')
        THEN
                p_att_type := UPPER(p_att_type);
        END IF;
        --
         -- validate unit entered
        IF c_att%ISOPEN
        THEN
                CLOSE c_att;
        END IF;
        OPEN c_att(p_att_type);
        FETCH c_att INTO v_att_ok;
        IF c_att%NOTFOUND
        THEN
                CLOSE c_att;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_att%ISOPEN
                THEN
                        CLOSE c_att;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_att_type
-- Module:      repp_val_unit_class
 -- Purpose:     validation for unit class
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_unit_class( p_unit_class IN OUT NOCOPY IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_uc(cp_unit_class IGS_AS_UNIT_CLASS.UNIT_CLASS%TYPE)
IS
SELECT
        'x'
FROM    IGS_AS_UNIT_CLASS              UC
WHERE
         uc.unit_class   LIKE    cp_unit_class
AND     uc.closed_ind   =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_AS_UNIT_CLASS','IGS_AS_UNIT_CLASS')
        THEN
                p_unit_class := UPPER(p_unit_class);
        END IF;
        --
         -- validate unit entered
        IF c_uc%ISOPEN
        THEN
                CLOSE c_uc;
        END IF;
        OPEN c_uc(p_unit_class);
        FETCH c_uc INTO v_ok;
        IF c_uc%NOTFOUND
        THEN
                CLOSE c_uc;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_uc%ISOPEN
                THEN
                        CLOSE c_uc;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_unit_class
-- Module:      repp_val_unit_mode
 -- Purpose:     validation for unit mode
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_unit_mode( p_unit_mode IN OUT NOCOPY IGS_AS_UNIT_MODE.unit_mode%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_um(cp_unit_mode IGS_AS_UNIT_MODE.UNIT_MODE%TYPE)
IS
SELECT
        'x'
FROM    IGS_AS_UNIT_MODE       um
WHERE
         um.unit_mode    LIKE    cp_unit_mode
AND     um.closed_ind   =       'N';
--
-- Local Variables
v_um_ok VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_AS_UNIT_MODE','IGS_AS_UNIT_MODE')
        THEN
                p_unit_mode := UPPER(p_unit_mode);
        END IF;
        --
         -- validate unit entered
        IF c_um%ISOPEN
        THEN
                CLOSE c_um;
        END IF;
        OPEN c_um(p_unit_mode);
        FETCH c_um INTO v_um_ok;
        IF c_um%NOTFOUND
        THEN
                CLOSE c_um;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_um%ISOPEN
                THEN
                        CLOSE c_um;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_unit_mode
-- Module:      repp_val_crs_type
-- Purpose:     validation for IGS_PS_TYPEs
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_crs_type( p_crs_type IN OUT NOCOPY IGS_PS_TYPE_ALL.COURSE_TYPE%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_crs(cp_crs_type IGS_PS_TYPE.course_type%TYPE)
IS
SELECT
        'x'
FROM    IGS_PS_TYPE     CT
WHERE
         ct.course_type  LIKE    cp_crs_type
AND     ct.closed_ind   =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_PS_TYPE','IGS_PS_TYPE')
        THEN
                p_crs_type := UPPER(p_crs_type);
        END IF;
        --
         -- validate unit entered
        IF c_crs%ISOPEN
        THEN
                CLOSE c_crs;
        END IF;
        OPEN c_crs(p_crs_type);
        FETCH c_crs INTO v_ok;
        IF c_crs%NOTFOUND
        THEN
                CLOSE c_crs;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_crs%ISOPEN
                THEN
                        CLOSE c_crs;
                END IF;
          	    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
          	    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_crs_type
-- Module:      repp_val_enr_cat
-- Purpose:     validation for enrolment categories
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_enr_cat( p_enr_cat IN OUT NOCOPY IGS_EN_ENROLMENT_CAT.ENROLMENT_CAT%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
 CURSOR c_crs(cp_enr_cat IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE)
IS
SELECT
        'x'
FROM    IGS_EN_ENROLMENT_CAT   EC
WHERE
         ec.enrolment_cat        LIKE    cp_enr_cat
AND     ec.closed_ind   =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_EN_ENROLMENT_CAT','IGS_EN_ENROLMENT_CAT')
        THEN
                p_enr_cat := UPPER(p_enr_cat);
        END IF;
        --
         -- validate unit entered
        IF c_crs%ISOPEN
        THEN
                CLOSE c_crs;
        END IF;
        OPEN c_crs(p_enr_cat);
        FETCH c_crs INTO v_ok;
        IF c_crs%NOTFOUND
        THEN
                CLOSE c_crs;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_crs%ISOPEN
                THEN
                        CLOSE c_crs;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_enr_cat
-- Module:      repp_val_adm_cat
-- Purpose:     validation for admission categories
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_adm_cat( p_adm_cat IN OUT NOCOPY IGS_AD_CAT.ADMISSION_CAT%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_crs(cp_adm_cat IGS_AD_CAT.admission_cat%TYPE)
IS
SELECT
        'x'
FROM    IGS_AD_CAT   ADC
WHERE
         adc.admission_cat       LIKE    cp_adm_cat
AND     adc.closed_ind  =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_AD_CAT','IGS_AD_CAT')
        THEN
                p_adm_cat := UPPER(p_adm_cat);
        END IF;
        --
         -- validate unit entered
        IF c_crs%ISOPEN
        THEN
                CLOSE c_crs;
        END IF;
        OPEN c_crs(p_adm_cat);
        FETCH c_crs INTO v_ok;
        IF c_crs%NOTFOUND
        THEN
                CLOSE c_crs;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_crs%ISOPEN
                THEN
                        CLOSE c_crs;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_adm_cat
-- Module:      repp_val_fee_cat
-- Purpose:     validation for fee categories
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_fee_cat( p_fee_cat IN OUT NOCOPY IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_crs(cp_fee_cat IGS_FI_FEE_CAT.fee_cat%TYPE)
IS
SELECT
        'x'
FROM    IGS_FI_FEE_CAT fc
WHERE
         fc.fee_cat      LIKE    cp_fee_cat
AND     fc.closed_ind   =       'N';
--
-- Local Variables
v_ok    VARCHAR2(1)     := NULL;
BEGIN
        --
        -- check for uppper case requirement
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('IGS_FI_FEE_CAT','IGS_FI_FEE_CAT')
        THEN
                p_fee_cat := UPPER(p_fee_cat);
        END IF;
        --
         -- validate unit entered
        IF c_crs%ISOPEN
        THEN
                CLOSE c_crs;
        END IF;
        OPEN c_crs(p_fee_cat);
        FETCH c_crs INTO v_ok;
        IF c_crs%NOTFOUND
        THEN
                CLOSE c_crs;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_crs%ISOPEN
                THEN
                        CLOSE c_crs;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_adm_cat
-- Module:      repp_val_unit_cal
 -- Purpose:     validation for unit code against a specific calendar
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      28/08/98        Initial creation of function
FUNCTION repp_val_unit_cal( p_unit_cd   IN      IGS_PS_UNIT_VER_ALL.unit_cd%TYPE,
                             p_ass_cal_type      IN      IGS_CA_INST_ALL.CAL_TYPE%TYPE,
                            p_ass_seq_num       IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                            p_teach_cal_type    IN      IGS_CA_INST_ALL.cal_type%TYPE,
                            p_teach_seq_num     IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                            p_msg_name           OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
--
-- Local Variables
BEGIN
/*
** complete this later
*/
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                RETURN TRUE;
END;    -- repp_unit_cal_val
-- Module:      repp_val_unit_mode_class
-- Purpose:     validation for unit mode and class parameters
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
  FUNCTION repp_val_unit_mode_class
      ( p_mode IN IGS_AS_UNIT_CLASS_ALL.unit_mode%TYPE,
      p_class IN IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
       p_msg_name OUT NOCOPY 	VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
 CURSOR c_mode(cp_unit_class IGS_AS_UNIT_CLASS.unit_class%TYPE,
                 cp_unit_mode IGS_AS_UNIT_MODE.unit_mode%TYPE)
IS
SELECT
        'x'
FROM    IGS_AS_UNIT_CLASS uc
WHERE   uc.unit_class   LIKE    cp_unit_class
AND     uc.unit_mode    LIKE    cp_unit_mode
AND     uc.closed_ind = 'N';
--
-- Local Variables
v_found VARCHAR2(1)     := NULL;
BEGIN
        IF c_mode%ISOPEN
        THEN
                CLOSE c_mode;
        END IF;
        OPEN c_mode(p_class, p_mode);
        FETCH c_mode INTO v_found;
        IF c_mode%NOTFOUND
        THEN
                CLOSE c_mode;
                p_msg_name := 'IGS_AD_UC_UM_INCOMPLATIBLE';
                RETURN FALSE;
        END IF;
        CLOSE c_mode;
        p_msg_name := NULL;
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_mode%ISOPEN
                THEN
                        CLOSE c_mode;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END;    -- repp_val_unit_mode_class
-- Module:      repp_val_course
 -- Purpose:     validation for course code
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_course(       p_course_cd     IN OUT NOCOPY  IGS_PS_VER_ALL.course_cd%TYPE,
                                p_msg_name       OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_cv(cp_course_cd IGS_PS_VER.course_cd%TYPE)
IS
SELECT  'x'
FROM    IGS_PS_VER  cv,
        IGS_PS_STAT   cs
WHERE   course_cd LIKE cp_course_cd
AND     cs.course_status        =       cv.course_status
AND     cs.s_course_status      =       'ACTIVE';
--
-- Local Variables
v_cv_exists             VARCHAR2(1) := NULL;
BEGIN
        -- null test
        IF p_course_cd IS NULL THEN
                p_course_cd := '%';
        END IF;
        -- upper case test
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('COURSE_CD','COURSE')
        THEN
                p_course_cd := UPPER(p_course_cd);
        END IF;
        -- start of main loop
        IF p_course_cd <> '%' THEN
                IF c_cv%ISOPEN
                THEN
                        CLOSE c_cv;
                END IF;
                OPEN c_cv(p_course_cd);
                FETCH c_cv INTO v_cv_exists;
                IF c_cv%NOTFOUND THEN
                        CLOSE c_cv;
                        p_msg_name := 'IGS_GE_INVALID_VALUE';
                        RETURN FALSE;
                END IF; --IF c_cv%NOTFOUND
                CLOSE c_cv;
                p_msg_name := NULL;
        END IF; --IF p_course_cd <> '%'
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_cv%ISOPEN
                THEN
                        CLOSE c_cv;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
END; --repp_val_course
-- Module:      repp_val_ass
-- Purpose:     validation for assessment item
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_ass(  p_ass_id        IN      VARCHAR2,
                        p_ass_desc      OUT NOCOPY     VARCHAR2,
                        p_msg_name       OUT NOCOPY    VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_ass(cp_ass_id IGS_AS_ASSESSMNT_ITM.ass_id%TYPE)
IS
SELECT
        TO_CHAR(asi.ass_id) || ' - ' ||
        asi.description
FROM    IGS_AS_ASSESSMNT_ITM asi
WHERE   asi.ass_id      =       cp_ass_id;
--
-- Local Variables
v_ass_desc      VARCHAR2(256)   := NULL;
v_ass_id        NUMBER          := 0;
--
-- Local IGS_GE_EXCEPTIONS
begin
        --
        -- validation
        IF p_ass_id <> '%'
        THEN
                IF c_ass%ISOPEN
                THEN
                        CLOSE c_ass;
                END IF;
                --
                -- convert to numeric value - error not expected
                v_ass_id := TO_NUMBER(p_ass_id);
                OPEN c_ass(v_ass_id);
                FETCH c_ass INTO v_ass_desc;
                IF c_ass%NOTFOUND
                THEN
                        CLOSE c_ass;
                        p_msg_name := 'IGS_GE_VAL_DOES_NOT_XS';
                        RETURN FALSE;
                END IF;
                CLOSE c_ass;
                p_ass_desc := v_ass_desc;
        ELSE
                p_ass_desc := p_ass_id;
        END IF;
        return (TRUE);
EXCEPTION
        WHEN INVALID_NUMBER THEN
		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception ;
                p_msg_name := 'IGS_GE_INVALID_VALUE';
                RETURN FALSE;
        WHEN OTHERS THEN
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                p_msg_name := 'IGS_AS_USER_EXCEPTION_RAISED';
                RETURN FALSE;
end; --repp_val_ass
-- Module:      repp_get_curr_cal
-- Purpose:     return of current calendar for given SI_CA_S_CA_CAT
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      27/08/98        Initial creation of function
 FUNCTION repp_get_curr_cal(     p_s_cal_cat     IN      IGS_CA_TYPE.s_cal_cat%TYPE,
                        p_cal           OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
 CURSOR c_cal(cp_s_cal_cat IN IGS_CA_TYPE.s_cal_cat%TYPE)
IS
 SELECT  RPAD(RPAD(NVL(ci.alternate_code, ci.cal_type), 10) || ' ' ||
        IGS_GE_DATE.igschar(ci.start_dt) || ' - ' ||
        IGS_GE_DATE.igschar(ci.end_dt) || ' ' || ct.abbreviation, 100) ||
        RPAD(ci.cal_type, 10) ||
        TO_CHAR(ci.sequence_number, '999990')   cal_desc
FROM    IGS_CA_TYPE        ct,
        IGS_CA_INST    ci,
        IGS_CA_STAT      cs
WHERE   ct.s_cal_cat    = cp_s_cal_cat  AND
        ci.cal_type     = ct.cal_type   AND
        cs.cal_status   = ci.cal_status AND
        cs.s_cal_status	= 'ACTIVE'	AND
        ci.start_dt     < SYSDATE       AND
        ci.end_dt       > SYSDATE;
--
-- Local Variables
v_cal   VARCHAR2(120)   := NULL;
BEGIN
        IF c_cal%ISOPEN THEN
                CLOSE c_cal;
        END IF;
        OPEN c_cal(p_s_cal_cat);
        FETCH c_cal INTO v_cal;
        IF c_cal%NOTFOUND
        THEN
                CLOSE c_cal;
                p_cal := v_cal;
                RETURN TRUE;
        END IF;
        CLOSE c_cal;
        p_cal := v_cal;
        RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
    IF c_cal%ISOPEN THEN
       CLOSE c_cal;
    END IF;
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
         P_cal := v_cal;
        RETURN TRUE;
END; --repp_get_curr_cal
-- Module:      repp_get_nomin_cal
-- Purpose:     return of nominated calendar for given IGS_CA_TYPE/sequence_number
--
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      27/08/98        Initial creation of function
 FUNCTION repp_get_nomin_cal(    p_cal_type      IN      IGS_CA_TYPE.cal_type%TYPE,
                        p_seq_num       IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                        p_cal           OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN
AS
--
-- Local Cursors
 CURSOR c_cal(cp_cal_type IN IGS_CA_TYPE.cal_type%TYPE,
        cp_seq_num IN IGS_CA_INST.sequence_number%TYPE)
IS
 SELECT  RPAD(RPAD(NVL(ci.alternate_code, ci.cal_type), 10) || ' ' ||
        IGS_GE_DATE.igschar(ci.start_dt) || ' - ' ||
        IGS_GE_DATE.igschar(ci.end_dt) || ' ' || ct.abbreviation, 100) ||
         RPAD(ci.cal_type, 10) ||
        TO_CHAR(ci.sequence_number, '999990')   cal_desc
FROM    IGS_CA_TYPE        ct,
        IGS_CA_INST    ci
WHERE   ct.cal_type             =       cp_cal_type     AND
        ci.cal_type             =       ct.cal_type     AND
        ci.sequence_number      =       cp_seq_num;
--
-- Local Variables
v_cal   VARCHAR2(120)   := NULL;
BEGIN
        FOR c_rec IN c_cal(p_cal_type, p_seq_num) LOOP
            v_cal := c_rec.cal_desc;
        END LOOP;
        p_cal := v_cal;
        RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
	  Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
	  IGS_GE_MSG_STACK.ADD;
	  p_cal := v_cal;
        RETURN TRUE;
END; --repp_get_nomin_cal
-- Module:      repp_get_cal_str
-- Purpose:     return of nominated calendar for given IGS_CA_TYPE/sequence_number
--              used in select statements
-- MODIFICATION HISTORY
 -- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      27/08/98        Initial creation of function
 FUNCTION repp_get_cal_str(      p_cal_type      IN      IGS_CA_TYPE.cal_type%TYPE,
                        p_seq_num       IN      IGS_CA_INST_ALL.sequence_number%TYPE)
RETURN  VARCHAR2
AS
--
-- Local Cursors
 CURSOR c_cal(cp_cal_type IN IGS_CA_TYPE.cal_type%TYPE,
        cp_seq_num IN IGS_CA_INST.sequence_number%TYPE)
IS
 SELECT  RPAD(RPAD(NVL(ci.alternate_code, ci.cal_type), 10) || ' ' ||
        IGS_GE_DATE.igschar(ci.start_dt) || ' - ' ||
        IGS_GE_DATE.igschar(ci.end_dt) || ' ' || ct.abbreviation, 100) ||
        RPAD(ci.cal_type, 10) ||
        TO_CHAR(ci.sequence_number, '999990')   cal_desc
FROM    IGS_CA_TYPE        ct,
        IGS_CA_INST    ci
WHERE   ct.cal_type             =       cp_cal_type     AND
        ci.cal_type             =       ct.cal_type     AND
        ci.sequence_number      =       cp_seq_num;
--
-- Local Variables
v_cal   VARCHAR2(120)   := NULL;
BEGIN
        FOR c_rec IN c_cal(p_cal_type, p_seq_num) LOOP
            v_cal := c_rec.cal_desc;
        END LOOP;
        RETURN v_cal;
EXCEPTION
   WHEN OTHERS THEN
        RETURN v_cal;
END; --repp_get_cal_str
-- Module:      repp_val_org_cd
-- Purpose:     validation of org units
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      28/08/98        Initial creation of function
FUNCTION repp_val_org_cd(p_org_cd       IN OUT NOCOPY  HZ_PARTIES.PARTY_NUMBER%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2 )
RETURN  BOOLEAN
AS
--
-- Local Cursors
CURSOR c_cv(cp_org_cd IGS_OR_UNIT.org_unit_cd%TYPE)
IS
SELECT  'x'
FROM    IGS_OR_UNIT        ou,
        IGS_OR_STATUS      ous
WHERE   org_unit_cd LIKE cp_org_cd
AND     ous.org_status  =       ou.org_status
AND     ous.s_org_status        =       'ACTIVE';
--
-- Local Variables
v_exists                VARCHAR2(1) := NULL;
BEGIN
        -- null test
        IF p_org_cd IS NULL THEN
                p_org_cd := '%';
        END IF;
        -- upper case test
        IF IGS_GE_GEN_001.GENP_CHK_COL_UPPER('ORG_UNIT_CD','IGS_OR_UNIT')
        THEN
                p_org_cd := UPPER(p_org_cd);
        END IF;
        -- start of main loop
        IF p_org_cd <> '%' THEN
                IF c_cv%ISOPEN
                THEN
                        CLOSE c_cv;
                END IF;
                OPEN c_cv(p_org_cd);
                FETCH c_cv INTO v_exists;
                IF c_cv%NOTFOUND THEN
                        CLOSE c_cv;
                        p_msg_name := 'IGS_GE_INVALID_VALUE';
                        RETURN FALSE;
                END IF; --IF c_cv%NOTFOUND
                CLOSE c_cv;
                p_msg_name := NULL;
        END IF; --IF p_org_cd <> '%'
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
                IF c_cv%ISOPEN
                THEN
                        CLOSE c_cv;
                END IF;
		    Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
		    IGS_GE_MSG_STACK.ADD;
                RETURN FALSE;
END; --repp_val_org_cd
END IGS_GE_VAL_PARAM;

/
