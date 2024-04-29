--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PCGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PCGE" AUTHID CURRENT_USER AS
/* $Header: IGSEN51S.pls 115.4 2002/11/29 00:02:39 nsidana ship $ */


  -- Validate that IGS_PE_PERSON doesn't already have an open crs grp exclusion.
  FUNCTION enrp_val_pcge_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_course_group_cd IN VARCHAR2 ,
  p_pcge_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_pcge_open,WNDS);

  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  -- removed FUNCTION enrp_val_crs_exclsn
  --
  -- Validate the IGS_PS_COURSE group closed indicator.
  FUNCTION enrp_val_crs_gp_clsd(
  p_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_crs_gp_clsd,WNDS);
  --
  -- Validate the IGS_PS_COURSE group on the IGS_PE_PERSON IGS_PS_COURSE group exclusion table.
  FUNCTION enrp_val_pcge_crs_gp(
  p_person_id IN NUMBER ,
  p_course_group_cd IN VARCHAR2 ,
  p_exclusion_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_pcge_crs_gp,WNDS);
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_crs_exclsn
  -- removed FUNCTION enrp_val_encmb_dts
END IGS_EN_VAL_PCGE;

 

/
