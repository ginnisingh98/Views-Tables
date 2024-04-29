--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_APCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_APCS" AUTHID CURRENT_USER AS
/* $Header: IGSAD42S.pls 115.6 2002/11/28 21:32:34 nsidana ship $ */
  -- Validate the IGS_AD_PRCS_CAT_STEP.mandatory_step_ind.
  FUNCTION admp_val_apcs_mndtry(
  p_s_admission_step_type IN VARCHAR2 ,
  p_mandatory_step_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_PRCS_CAT_STEP.step_order_num.
  FUNCTION admp_val_apcs_order(
  p_s_admission_step_type IN VARCHAR2 ,
  p_step_order_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_PRCS_CAT_STEP.step_type_restriction_num.
  FUNCTION admp_val_apcs_rstrct(
  p_s_admission_step_type IN VARCHAR2 ,
  p_step_type_restriction_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if IGS_AD_CAT.admission_cat is closed.


  -- Validate if s_admission_step_type.s_admission_step_type is closed.
  FUNCTION admp_val_sasty_clsd(
  p_s_admission_step_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_APCS;

 

/
