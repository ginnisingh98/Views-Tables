--------------------------------------------------------
--  DDL for Package IGS_GE_VAL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_VAL_PARAM" AUTHID CURRENT_USER AS
/* $Header: IGSGE08S.pls 120.1 2005/09/30 04:12:32 appldev ship $ */

-- Module:      repp_val_unit_cd
-- Purpose:     validation for IGS_PS_UNIT code
--
-- MODIFICATION HISTORY
-- Person       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_unit_cd(p_unit_cd IN OUT NOCOPY IGS_PS_UNIT_VER_ALL.unit_cd%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_location
-- Purpose:     validation for IGS_AD_LOCATION codes
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_location(p_location_cd IN OUT NOCOPY IGS_AD_LOCATION_ALL.location_cd%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_att_mode
-- Purpose:     validation for attendance mode
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_att_mode(p_att_mode IN OUT NOCOPY IGS_EN_ATD_MODE_ALL.attendance_mode%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_att_type
-- Purpose:     validation for attendance type
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_att_type(p_att_type IN OUT NOCOPY IGS_EN_ATD_TYPE_ALL.attendance_type%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_unit_class
--  -- Purpose:     validation for location codes
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_unit_class(p_unit_class IN OUT NOCOPY IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_unit_mode
-- Purpose:     validation for IGS_PS_UNIT mode
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_unit_mode(p_unit_mode IN OUT NOCOPY IGS_AS_UNIT_MODE.unit_mode%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_crs_type
-- Purpose:     validation for IGS_PS_COURSE types
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_crs_type(p_crs_type IN OUT NOCOPY IGS_PS_TYPE_ALL.course_type%TYPE,
                       p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_enr_cat
-- Purpose:     validation for enrolment category
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_enr_cat(p_enr_cat IN OUT NOCOPY IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE,
                       p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_adm_cat
-- Purpose:     validation for admission categories
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_adm_cat(p_adm_cat IN OUT NOCOPY IGS_AD_CAT.admission_cat%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_fee_cat
-- Purpose:     validation for fee categories
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_fee_cat(p_fee_cat IN OUT NOCOPY IGS_FI_FEE_CAT_ALL.fee_cat%TYPE,
                       p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_unit_cal
--  -- Purpose:     validation for unit class
--              teaching calendars
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_unit_cal( p_unit_cd           IN      IGS_PS_UNIT_VER_ALL.unit_cd%TYPE,
                        p_ass_cal_type          IN      IGS_CA_INST_ALL.cal_type%TYPE,
                        p_ass_seq_num           IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                        p_teach_cal_type        IN      IGS_CA_INST_ALL.cal_type%TYPE,
                        p_teach_seq_num         IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                        p_msg_name 		OUT NOCOPY 	VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_unit_mode_class
-- Purpose:     validation for UNIT mode and class parameters
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
 FUNCTION repp_val_unit_mode_class( p_mode IN IGS_AS_UNIT_CLASS_ALL.unit_mode%TYPE,
                                 p_class IN IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
                                p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_course
-- Purpose:     validation for course types
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_course( p_course_cd IN OUT NOCOPY IGS_PS_VER_ALL.course_cd%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_val_ass
-- Purpose:     validation for assessment item
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      21/08/98        Initial creation of function
FUNCTION repp_val_ass(  p_ass_id IN VARCHAR2,
                        p_ass_desc OUT NOCOPY VARCHAR2,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_get_curr_cal
-- Purpose:     return of current calendar for given SI_CA_S_CA_CAT
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      27/08/98        Initial creation of function
 FUNCTION repp_get_curr_cal(     p_s_cal_cat     IN      IGS_CA_TYPE.s_cal_cat%TYPE,
                        p_cal           OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN;

-- Module:      repp_get_nomin_cal
-- Purpose:     return of nominated calendar for given IGS_CA_TYPE/sequence_number
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      27/08/98        Initial creation of function
 FUNCTION repp_get_nomin_cal(    p_cal_type      IN      IGS_CA_TYPE.cal_type%TYPE,
                        p_seq_num       IN      IGS_CA_INST_ALL.sequence_number%TYPE,
                        p_cal           OUT NOCOPY     VARCHAR2)
RETURN  BOOLEAN;
--pragma RESTRICT_REFERENCES (repp_get_nomin_cal,WNDS);

-- Module:      repp_get_cal_str
-- Purpose:     return of nominated calendar for given IGS_CA_TYPE/sequence_number
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      28/08/98        Initial creation of function
 FUNCTION repp_get_cal_str(p_cal_type    IN      IGS_CA_TYPE.cal_type%TYPE,
                        p_seq_num       IN      IGS_CA_INST_ALL.sequence_number%TYPE)
RETURN  VARCHAR2;

-- Module:      repp_val_org_cd
-- Purpose:     validation of org IGS_PS_UNITs
--
-- MODIFICATION HISTORY
-- PERSON       Date            Comments
-- ---------    --------        ------------------------------------------
-- MSONTER      28/08/98        Initial creation of function
FUNCTION repp_val_org_cd(p_org_cd       IN OUT NOCOPY  HZ_PARTIES.party_number%TYPE,
                        p_msg_name OUT NOCOPY VARCHAR2)
RETURN  BOOLEAN;

--
-- Pragma Declarations
--pragma RESTRICT_REFERENCES (repp_get_cal_str, WNDS);
END IGS_GE_VAL_PARAM;

 

/
