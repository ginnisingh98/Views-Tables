--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_UAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_UAI" AUTHID CURRENT_USER AS
/* $Header: IGSAS34S.pls 120.0 2005/07/05 11:31:20 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- DDEY       02-Jan-2001    Bug # 2162831 . FUNCTION assp_val_unit_sec_uniqref is added.
  --smadathi    24-AUG-2001     Bug No. 1956374 .Removed references to duplicate
  --                            function GENP_VAL_SDTT_SESS
  -------------------------------------------------------------------------------------------
  -- As part of the bug# 1956374 removed the function crsp_val_loc_closed
   -- Bug No. 1956374 Procedure assp_val_optnl_links is removed
  -- Validate assessment item exists
  FUNCTION assp_val_ai_exists(
  p_ass_id IN IGS_AS_ASSESSMNT_ITM_ALL.ass_id%TYPE,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
-- Commented out NOCOPY By DDEY
PRAGMA RESTRICT_REFERENCES (assp_val_ai_exists,WNDS);
  --
  -- Validate IGS_PS_UNIT mode closed indicator.
  FUNCTION crsp_val_um_closed(
  p_unit_mode IN  IGS_AS_UNIT_MODE.unit_mode%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (crsp_val_um_closed,WNDS);

  --
  -- Validate IGS_PS_UNIT class closed indicator.
  FUNCTION crsp_val_ucl_closed(
  p_unit_class IN  IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (crsp_val_ucl_closed,WNDS);
  --
  -- Validate IGS_PS_UNIT assessment item links for invalid combinations.
  FUNCTION assp_val_uai_links(
  p_unit_cd IN IGS_AS_UNITASS_ITEM_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_AS_UNITASS_ITEM_ALL.version_number%TYPE ,
  p_cal_type IN IGS_AS_UNITASS_ITEM_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_AS_UNITASS_ITEM_ALL.ci_sequence_number%TYPE ,
  p_ass_id IN IGS_AS_UNITASS_ITEM_ALL.ass_id%TYPE ,
  p_sequence_number IN IGS_AS_UNITASS_ITEM_ALL.sequence_number%TYPE ,
--ijeddy, Bug 3201661, Grade Book.
  p_location_cd IN VARCHAR2,
  p_unit_mode IN IGS_AS_UNIT_MODE.unit_mode%TYPE,
  p_unit_class IN  IGS_AS_UNIT_CLASS_ALL.unit_class%TYPE,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --

  --
  -- Validate that date is not after the assessment variation cutoff date.
  FUNCTION ASSP_VAL_CUTOFF_DT(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_CUTOFF_DT,WNDS);




  --
  -- Validate Calendar Instance for IGS_PS_COURSE Information.
  FUNCTION CRSP_VAL_CRS_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (CRSP_VAL_CRS_CI,WNDS);

  --
  -- Validate IGS_PS_UNIT Offering Calendar Type.
  FUNCTION crsp_val_uo_cal_type(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (crsp_val_uo_cal_type,WNDS);
  --
  -- Retrofitted
  FUNCTION assp_val_uai_uniqref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (assp_val_uai_uniqref,WNDS);
  --
  -- Retrofitted
  FUNCTION assp_val_uai_opt_ref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (assp_val_uai_opt_ref,WNDS);
 --
-- w.r.t Bug  # 1956374 procedure assp_val_ai_exmnbl is removed
  --
  -- To validate the examination calendar type/sequence number of the uai
  FUNCTION ASSP_VAL_UAI_CAL(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_sequence_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_UAI_CAL,WNDS);
  --
  -- Retrofitted
  FUNCTION assp_val_uai_sameref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (assp_val_uai_sameref,WNDS);
 --
  --
  -- Val IGS_PS_UNIT assess item applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_SUA_UAI(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 )
RETURN CHAR;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_SUA_UAI,WNDS,WNPS);
  --
  -- Validate the IGS_PS_COURSE type for an assessment item against student IGS_PS_COURSE
  FUNCTION ASSP_VAL_SUA_AI_ACOT(
  p_ass_id IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_SUA_AI_ACOT,WNDS,WNPS);
  --
  -- Validate modification of IGS_PS_UNIT ass item does not conflict with uapi.
  FUNCTION ASSP_VAL_UAI_UAPI(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_location_cd IN VARCHAR2 ,
  p_old_unit_class IN VARCHAR2 ,
  p_old_unit_mode IN VARCHAR2 ,
  p_old_logical_delete_dt IN DATE ,
  p_new_location_cd IN VARCHAR2 ,
  p_new_unit_class IN VARCHAR2 ,
  p_new_unit_mode IN VARCHAR2 ,
  p_new_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_UAI_UAPI,WNDS);

FUNCTION assp_val_unit_sec_uniqref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN ;
PRAGMA RESTRICT_REFERENCES (assp_val_unit_sec_uniqref,WNDS);
END IGS_AS_VAL_UAI;

 

/
