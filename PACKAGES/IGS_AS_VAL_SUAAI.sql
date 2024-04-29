--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SUAAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SUAAI" AUTHID CURRENT_USER AS
/* $Header: IGSAS30S.pls 115.7 2003/05/27 16:47:23 anilk ship $ */
-- Val IGS_PS_UNIT assess item applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
 -- BUG #1956374 , Procedure assp_val_cutoff_dt, assp_val_suaai_ins ,assp_val_ai_exmnblare  removed
  FUNCTION ASSP_VAL_UAI_LOC_UC(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(ASSP_VAL_UAI_LOC_UC,WNDS,WNPS);
  --


  --
  -- Validate Assessment Item IGS_PS_COURSE Type restrictions.
  FUNCTION ASSP_VAL_AI_ACOT(
  p_ass_id IN NUMBER ,
  p_course_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
pragma restrict_references (assp_val_ai_acot,wnds,WNPS,WNDS);

  --
  -- Validate if assessment item completed for discontinued IGS_PS_UNIT.
  FUNCTION ASSP_VAL_ASS_COUNT(
  p_unit_attempt_status IN VARCHAR2 ,
  p_tracking_id IN NUMBER )
RETURN VARCHAR2;

  --
  -- Validate the attempt number is unique within the student assigment.
  FUNCTION assp_val_suaai_atmpt(
  p_person_id  IGS_AS_SU_ATMPT_ITM.person_id%TYPE ,
  p_course_cd  IGS_AS_SU_ATMPT_ITM.course_cd%TYPE ,
  p_unit_cd  IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE ,
  p_cal_type  IGS_AS_SU_ATMPT_ITM.cal_type%TYPE ,
  p_ci_sequence_number  IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_creation_dt IN DATE ,
  p_attempt_number  NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(assp_val_suaai_atmpt,WNDS);
  --
  -- Validate item still applies to student as a uai or part of a pattern.
  FUNCTION ASSP_VAL_SUAAI_VALID(
  p_person_id IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_id IN NUMBER ,
  p_suaai_logical_delete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )

RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (ASSP_VAL_SUAAI_VALID,WNDS,WNPS);  --
END IGS_AS_VAL_SUAAI;

 

/
