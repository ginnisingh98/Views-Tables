--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_USET_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_USET_RULE" AS
/* $Header: IGSRU10B.pls 115.7 2002/11/29 03:40:45 nsidana ship $ */

/*
  Validate the enrolment rules for a student IGS_PS_UNIT set attempt.
*/
  FUNCTION RULP_VAL_ENROL_USET(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	v_return_val	VARCHAR2(30);
  BEGIN
  	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA('ENROL_USET',
  				p_person_id,
  				p_course_cd,
  				p_course_version,
  				p_param_1=>p_unit_set_cd,
  				p_param_2=>p_unit_set_version,
  				p_message=>p_message_text);
  	IF v_return_val = 'false' OR v_return_val IS NULL
  	THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
/*
  Determine if a student has completed a IGS_PS_UNIT set.
*/
  FUNCTION RULP_VAL_SUSA_COMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_unit_set_version  NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	v_return_val	VARCHAR2(30);
  BEGIN
  	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA('USET_COMP',
  				p_person_id,
  				p_course_cd,
  				p_course_version,
  				p_unit_set_cd,
  				p_unit_set_version,
  				p_message=>p_message_text);
  	IF v_return_val = 'false' OR v_return_val IS NULL
  	THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;

END IGS_RU_VAL_USET_RULE;

/
