--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_USET_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_USET_RULE" AUTHID CURRENT_USER AS
/* $Header: IGSRU10S.pls 115.6 2002/11/29 03:40:52 nsidana ship $ */

  --
  -- Validate the enrolment rules for a student IGS_PS_UNIT set attempt.
  FUNCTION RULP_VAL_ENROL_USET(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- Determine if a student has completed a IGS_PS_UNIT set.
  FUNCTION RULP_VAL_SUSA_COMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RU_VAL_USET_RULE;

 

/
