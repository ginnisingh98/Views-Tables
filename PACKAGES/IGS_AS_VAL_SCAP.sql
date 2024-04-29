--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SCAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SCAP" AUTHID CURRENT_USER AS
/* $Header: IGSAS28S.pls 115.5 2003/05/27 18:44:42 anilk ship $ */

  --
  -- Validate special consideration category closed indicator.
  FUNCTION assp_val_spcc_closed(
  p_spcl_consideration_cat  IGS_AS_SPCL_CONS_CAT.spcl_consideration_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate special consideration outcome closed indicator.
  FUNCTION assp_val_spco_closed(
  p_spcl_consideration_outcome  IGS_AS_SPCL_CONS_OUT.spcl_consideration_outcome%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate SUAAI or SCAP can be created
  FUNCTION assp_val_suaai_ins(
  p_person_id  IGS_AS_SU_ATMPT_ITM.person_id%TYPE ,
  p_course_cd  IGS_AS_SU_ATMPT_ITM.course_cd%TYPE ,
  p_unit_cd  IGS_AS_SU_ATMPT_ITM.unit_cd%TYPE ,
  p_cal_type  IGS_AS_SU_ATMPT_ITM.cal_type%TYPE ,
  p_ci_sequence_number  IGS_AS_SU_ATMPT_ITM.ci_sequence_number%TYPE ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN BOOLEAN;

  -- Retrofitted
  FUNCTION assp_val_suaai_delet(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id  IGS_AS_SU_ATMPT_ITM.ass_id%TYPE ,
  p_creation_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN BOOLEAN;

END IGS_AS_VAL_SCAP;

 

/
