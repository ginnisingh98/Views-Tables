--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_CRS_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_CRS_RULE" AUTHID CURRENT_USER AS
/* $Header: IGSRU05S.pls 115.5 2002/11/29 03:40:05 nsidana ship $ */

  --
  -- Validate that core unit  rules are satisfied for a student crs attempt
  FUNCTION RULP_VAL_CRS_CORE(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
RETURN boolean;
  -- Determine if two courses are articulate.
  FUNCTION rulp_val_crs_artcltn(
  p_rule_course_cd IN VARCHAR2 ,
  p_rule_crv_version_number IN NUMBER ,
  p_member_course_cd IN VARCHAR2 ,
  p_member_crv_version_number IN NUMBER )
RETURN BOOLEAN;

END IGS_RU_VAL_CRS_RULE;

 

/
