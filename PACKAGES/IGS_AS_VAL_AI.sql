--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_AI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_AI" AUTHID CURRENT_USER AS
/* $Header: IGSAS11S.pls 115.4 2002/11/28 22:42:07 nsidana ship $ */
  --
  --
  -- Validate the appropriate assessment item details set and are not set
  FUNCTION assp_val_ai_details(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.ASSESSMENT_TYPE%TYPE ,
  p_exam_scheduled_ind IN IGS_AS_ASSESSMNT_ITM_ALL.exam_scheduled_ind%TYPE ,
  p_exam_working_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_working_time%TYPE ,
  p_exam_announcements IN IGS_AS_ASSESSMNT_ITM_ALL.exam_announcements%TYPE ,
  p_exam_short_paper_name IN IGS_AS_ASSESSMNT_ITM_ALL.exam_short_paper_name%TYPE ,
  p_exam_paper_name IN IGS_AS_ASSESSMNT_ITM_ALL.exam_paper_name%TYPE ,
  p_exam_perusal_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_perusal_time%TYPE ,
  p_exam_supervisor_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_supervisor_instrctn%TYPE ,
  p_exam_allowable_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_allowable_instrctn%TYPE ,
  p_exam_non_allowed_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_non_allowed_instrctn%TYPE ,
  p_exam_supplied_instrctn IN IGS_AS_ASSESSMNT_ITM_ALL.exam_supplied_instrctn%TYPE ,
  p_question_or_title IN IGS_AS_ASSESSMNT_ITM_ALL.question_or_title%TYPE ,
  p_ass_length_or_duration IN IGS_AS_ASSESSMNT_ITM_ALL.ass_length_or_duration%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate exam times
  FUNCTION assp_val_ai_ex_times(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.ASSESSMENT_TYPE%TYPE ,
  p_exam_working_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_working_time%TYPE ,
  p_exam_perusal_time IN IGS_AS_ASSESSMNT_ITM_ALL.exam_perusal_time%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate assessment type closed indicator.
  FUNCTION assp_val_atyp_closed(
  p_assessment_type IN IGS_AS_ASSESSMNT_TYP.ASSESSMENT_TYPE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate updating ass type, does not cause non-unique uai.reference
  FUNCTION ASSP_VAL_AI_TYPE(
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_old_assessment_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_AI;

 

/
