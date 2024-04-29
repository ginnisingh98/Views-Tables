--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_CRS_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_CRS_RULE" AS
/* $Header: IGSRU05B.pls 115.6 2002/11/29 03:39:56 nsidana ship $ */

/*
 Validate that core unit rules are satisfied for a student crs attempt
*/
  FUNCTION RULP_VAL_CRS_CORE(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	v_return_val	VARCHAR2(30);
  BEGIN
  	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA('CORE',
  				p_person_id,
  				p_course_cd,
  				p_course_version,
  				NULL,
  				NULL,
  				p_cal_type,
  				p_ci_sequence_number,
  				p_message_text);
  	IF v_return_val = 'false' OR
           v_return_val IS NULL /*ERROR*/
  	THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END rulp_val_crs_core;
/*
  Determine if two courses are articulate.
*/
  FUNCTION rulp_val_crs_artcltn(
  p_rule_course_cd IN VARCHAR2 ,
  p_rule_crv_version_number IN NUMBER ,
  p_member_course_cd IN VARCHAR2 ,
  p_member_crv_version_number IN NUMBER )
  RETURN BOOLEAN IS
  	v_return_val	VARCHAR2(30);
  	v_message	VARCHAR2(2000);
  BEGIN
  	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA('CRS-ARTCLT',
  				p_course_cd=>p_rule_course_cd,
  				p_course_version=>p_rule_crv_version_number,
  				p_param_1=>p_member_course_cd,
  				p_param_2=>p_member_crv_version_number,
  				p_message=>v_message );
  	IF v_return_val = 'false' OR
               v_return_val IS NULL
  	THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END rulp_val_crs_artcltn;

END IGS_RU_VAL_CRS_RULE;

/
