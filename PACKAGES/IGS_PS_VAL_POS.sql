--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_POS" AUTHID CURRENT_USER AS
/* $Header: IGSPS50S.pls 115.5 2002/11/29 03:06:15 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_am_closed"
  -- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
  -- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_crs_ci"
  -------------------------------------------------------------------------------------------
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd

  --
  -- Validate the admission category is not closed.
  FUNCTION crsp_val_ac_closed(
  p_admission_cat IN IGS_AD_CAT.admission_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate the calendar type is categorised admission and is not closed.
  FUNCTION crsp_val_pos_cat(
  p_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Warn if no IGS_PS_COURSE offering exists for the specified options.
  FUNCTION crsp_val_pos_coo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Warn if no IGS_PS_COURSE offering IGS_PS_UNIT set record exists.
  FUNCTION crsp_val_pos_cous(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate pattern of study record is not ambiguous.
  FUNCTION crsp_val_pos_iu(
  p_course_cd IN IGS_PS_PAT_OF_STUDY.course_cd%TYPE ,
  p_version_number IN IGS_PS_PAT_OF_STUDY.version_number%TYPE ,
  p_cal_type IN IGS_PS_PAT_OF_STUDY.cal_type%TYPE ,
  p_sequence_number IN IGS_PS_PAT_OF_STUDY.sequence_number%TYPE ,
  p_location_cd IN IGS_PS_PAT_OF_STUDY.location_cd%TYPE ,
  p_attendance_mode IN IGS_PS_PAT_OF_STUDY.attendance_mode%TYPE ,
  p_attendance_type IN IGS_PS_PAT_OF_STUDY.attendance_type%TYPE ,
  p_unit_set_cd IN IGS_PS_PAT_OF_STUDY.unit_set_cd%TYPE ,
  p_admission_cal_type IN IGS_PS_PAT_OF_STUDY.admission_cal_type%TYPE ,
  p_admission_cat IN IGS_PS_PAT_OF_STUDY.admission_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate a least one version of the IGS_PS_UNIT set is active.
  FUNCTION crsp_val_us_active(
  p_unit_set_cd IN IGS_EN_UNIT_SET_ALL.unit_set_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_POS;

 

/
