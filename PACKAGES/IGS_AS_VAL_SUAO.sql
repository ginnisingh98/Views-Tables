--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SUAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SUAO" AUTHID CURRENT_USER AS
/* $Header: IGSAS32S.pls 115.6 2004/01/29 09:32:29 ddey ship $ */

  -- To validate update of IGS_AS_SU_STMPTOUT record
  FUNCTION ASSP_VAL_SUAO_UPD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_new_finalised_outcome_ind IN VARCHAR2 ,
  p_new_s_grade_creation_mthd_tp IN VARCHAR2 ,
  p_new_mark IN NUMBER ,
  p_new_grading_schema_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_new_grade IN VARCHAR2 ,
  p_old_finalised_outcome_ind IN VARCHAR2 ,
  p_old_s_grade_creation_mthd_tp IN VARCHAR2 ,
  p_old_mark IN NUMBER ,
  p_old_grading_schema_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_old_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN boolean;


  --
  -- Validate the insert of a IGS_AS_SU_STMPTOUT record
  FUNCTION ASSP_VAL_SUAO_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN boolean;


  --
  -- Validate IGS_AS_SU_STMPTOUT outcome_dt field
  FUNCTION ASSP_VAL_SUAO_DT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd  VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN boolean;


  --
  -- Validate s_grade_creation_method_type closed indicator
  FUNCTION ASSP_VAL_SGCMT_CLSD(
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --
  -- To validate an assessment mark against a grade
  FUNCTION ASSP_VAL_MARK_GRADE(
  p_mark IN NUMBER ,
  p_grade IN VARCHAR2 ,
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

PROCEDURE assp_val_mark_grade_ss (
           p_mark IN NUMBER ,
           p_grade IN VARCHAR2 ,
           p_grading_schema_cd IN VARCHAR2 ,
           p_version_number IN NUMBER ,
           p_message_name OUT NOCOPY VARCHAR2,
           p_boolean OUT NOCOPY VARCHAR2 );

END IGS_AS_VAL_SUAO;

 

/
