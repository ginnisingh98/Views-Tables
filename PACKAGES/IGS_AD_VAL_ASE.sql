--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ASE" AUTHID CURRENT_USER AS
/* $Header: IGSAD43S.pls 115.4 2002/11/28 21:32:57 nsidana ship $ */
  -- result_obtained_yr is not null then score and ass_type are not null.
  FUNCTION admp_val_ase_scoreat(
  p_result_obtained_yr IN NUMBER ,
  p_score IN NUMBER ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate state_cd = ass_type.state_cd or ass_type.state_cd is null
  FUNCTION ADMP_VAL_ASE_ATSTATE(
  p_state_cd IN VARCHAR2 ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate that state_cd = IGS_AD_AUS_SEC_EDU_SC .state_cd
  FUNCTION ADMP_VAL_ASE_SCSTATE(
  p_state_cd IN VARCHAR2 ,
  p_secondary_school_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate if aus_scndry_edu_ass_type is closed.
  FUNCTION ADMP_VAL_ASEATCLOSED(
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_ASE;

 

/
