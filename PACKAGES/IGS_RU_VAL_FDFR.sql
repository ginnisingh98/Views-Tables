--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_FDFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_FDFR" AUTHID CURRENT_USER AS
/* $Header: IGSRU06S.pls 115.4 2002/02/12 17:30:51 pkm ship    $ */

  --
  -- call stub to rule engine for fee disbursement
  FUNCTION rulp_val_disb_frml(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_fee_call_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_formula_number IN NUMBER )
RETURN BOOLEAN;

END IGS_RU_VAL_FDFR;

 

/
