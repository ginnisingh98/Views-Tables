--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_PRA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_PRA" AUTHID CURRENT_USER AS
/* $Header: IGSPR04S.pls 115.5 2002/11/29 02:44:39 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_OU_ACTIVE) - from the spec and body. -- kdande
*/
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_att_closed
  --
  --
  -- Validate the IGS_PR_RU_APPL record.
  FUNCTION prgp_val_pra_rqrd(
  p_s_relation_type IN VARCHAR2 ,
  p_progression_rule_cd IN VARCHAR2 ,
  p_rul_sequence_number IN NUMBER ,
  p_ou_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_course_type IN VARCHAR2 ,
  p_crv_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_sca_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_pro_progression_rule_cat IN VARCHAR2 ,
  p_pro_pra_sequence_number IN NUMBER ,
  p_pro_sequence_number IN NUMBER ,
  p_spo_person_id IN NUMBER ,
  p_spo_course_cd IN VARCHAR2 ,
  p_spo_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pra_rqrd, WNDS);
  --
  -- Validate that the IGS_PR_RU_CAT is not closed.
  FUNCTION prgp_val_prgc_closed(
  p_progression_rule_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_prgc_closed, WNDS);
  --
  -- Validate that the IGS_PR_RULE is not closed.
  FUNCTION prgp_val_prr_closed(
  p_progression_rule_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_prr_closed, WNDS);
  --
  -- Validate the IGS_PS_COURSE version is active.
  FUNCTION crsp_val_crv_active(
  p_course_cd IN IGS_PS_VER_ALL.course_cd%TYPE ,
  p_version_number IN IGS_PS_VER_ALL.version_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(crsp_val_crv_active, WNDS);
END IGS_PR_VAL_PRA;

 

/
