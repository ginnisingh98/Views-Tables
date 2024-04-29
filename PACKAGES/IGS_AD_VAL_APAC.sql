--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_APAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_APAC" AUTHID CURRENT_USER AS
/* $Header: IGSAD37S.pls 115.7 2003/09/29 06:36:58 nsinha ship $ */
  -- Validate that admission period admission category can be duplicated.
  FUNCTION admp_val_apac_dup(
  p_old_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_old_admission_cat IN VARCHAR2 ,
  p_new_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(admp_val_apac_dup, WNDS) ;
  --
  -- Validate admission period admission category calendar instance.
  FUNCTION admp_val_apac_ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(admp_val_apac_ci, WNDS) ;
  --
  -- Insert admission period admission process category
  -- Enhancement: 3132406 nsinha 9/25/2003 added new parameter p_prior_adm_ci_seq_number
  FUNCTION admp_ins_dflt_apapc(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_prior_adm_ci_seq_number IN NUMBER DEFAULT NULL
  )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(admp_ins_dflt_apapc, WNDS) ;
  --
  -- Validate admission period calendar instance
  FUNCTION admp_val_adm_ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_alternate_code OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(admp_val_adm_ci, WNDS) ;
  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.

RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(admp_val_ac_closed,WNDS) ;

END IGS_AD_VAL_APAC;

 

/
