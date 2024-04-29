--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_FDFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_FDFR" AS
/* $Header: IGSRU06B.pls 115.5 2002/02/12 17:30:50 pkm ship    $ */

  /* call stub to rule engine for fee disbursement */
  FUNCTION rulp_val_disb_frml(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_fee_call_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_formula_number IN NUMBER )
  RETURN BOOLEAN IS
/*
fee disbursement call stub to senna
*/
  v_message	VARCHAR2(2000);
/*
  rulp_val_disb_frml
*/
  BEGIN
  	IF IGS_RU_GEN_001.RULP_VAL_SENNA(p_message=>v_message,
  		p_rule_call_name=>'FDFR-1',
  		p_person_id=>p_person_id,
  		p_course_cd=>p_course_cd,
  		p_param_1=>p_fee_type,
  		p_param_2=>p_fee_call_type,
  		p_param_3=>p_fee_ci_sequence_number,
  		p_param_4=>p_formula_number ) = 'true'
  	THEN
  		RETURN TRUE;
  	END IF;
  	RETURN FALSE;
  END rulp_val_disb_frml;

END IGS_RU_VAL_FDFR;

/
