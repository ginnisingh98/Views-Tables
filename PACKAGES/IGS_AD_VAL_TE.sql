--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_TE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_TE" AUTHID CURRENT_USER AS
/* $Header: IGSAD72S.pls 115.3 2002/11/28 21:40:25 nsidana ship $ */

  --
  -- Validate tertiary education IGS_OR_INSTITUTION details.
  FUNCTION admp_val_te_inst(
  p_institution_cd IN VARCHAR2 ,
  p_institution_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate tertiary education enrolment years.
  FUNCTION admp_val_te_enr_yr(
  p_enrolment_first_yr IN NUMBER ,
  p_enrolment_latest_yr IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if IGS_AD_TER_EDU_LV_COM.tertiary_edu_lvl_comp is closed.
  FUNCTION admp_val_telocclosed(
  p_tertiary_edu_lvl_comp IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if IGS_AD_TER_EDU_LVL_QF.tertiary_edu_lvl_qual is closed.
  FUNCTION admp_val_teloqclosed(
  p_tertiary_edu_lvl_qual IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_TE;

 

/
