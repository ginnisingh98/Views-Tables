--------------------------------------------------------
--  DDL for Package IGS_CA_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSCA01S.pls 115.3 2002/11/28 22:56:16 nsidana ship $ */
FUNCTION calp_get_alias_val(
  p_dt_alias IN IGS_CA_DA_INST.DT_ALIAS%TYPE ,
  p_sequence_num  IGS_CA_DA_INST.sequence_number%TYPE ,
  p_cal_type IN IGS_CA_DA_INST.CAL_TYPE%TYPE ,
  p_ci_sequence_num IN IGS_CA_DA_INST.ci_sequence_number%TYPE )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(calp_get_alias_val,WNDS,WNPS);
--
FUNCTION CALP_GET_ALT_CD(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(CALP_GET_ALT_CD,WNDS,WNPS);
--
FUNCTION calp_get_cat_closed(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(calp_get_cat_closed,WNDS);
--
PROCEDURE CALP_GET_CI_DATES(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE );
--
FUNCTION calp_get_ci_start_dt(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(calp_get_ci_start_dt,WNDS);
--
FUNCTION CALP_GET_RLTV_TIME(
  p_source_cal_type IN VARCHAR2 ,
  p_source_ci_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(CALP_GET_RLTV_TIME,WNDS);
--
FUNCTION calp_get_sup_inst(
  p_sup_cal_type IN VARCHAR2 ,
  p_sub_cal_type IN VARCHAR2 ,  p_sub_ci_sequence_number IN NUMBER )
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(calp_get_sup_inst,WNDS,WNPS);
--
FUNCTION calp_set_alias_value(
  p_absolute_val IN DATE ,
  p_derived_val IN DATE )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(calp_set_alias_value,WNDS,WNPS);
--
FUNCTION calp_set_alt_code(
  p_cal_type IN VARCHAR2 ,
  p_alternate_code IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(calp_set_alt_code,WNDS);
--
END IGS_CA_GEN_001;

 

/
