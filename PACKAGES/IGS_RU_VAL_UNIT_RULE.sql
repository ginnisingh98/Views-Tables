--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_UNIT_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_UNIT_RULE" AUTHID CURRENT_USER AS
/* $Header: IGSRU09S.pls 120.1 2005/09/30 06:50:50 appldev ship $ */
/* smaddali added new parameters to all the functions for
   enrollment processes  bug# 1832130 */
  --
  -- Validate co-requisite rules for a student IGS_PS_UNIT attempt
  FUNCTION RULP_VAL_COREQ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate for incompatible student IGS_PS_UNIT attempts
  FUNCTION RULP_VAL_INCOMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- Validate the pre-requisite rules for a student IGS_PS_UNIT attempt
  FUNCTION RULP_VAL_PREREQ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- Validate the enrolment rules for a student IGS_PS_UNIT attempt
  FUNCTION RULP_VAL_ENROL_UNIT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER DEFAULT NULL,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2 )
RETURN boolean;

END IGS_RU_VAL_UNIT_RULE;

 

/
