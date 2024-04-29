--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_PRGC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_PRGC" AUTHID CURRENT_USER AS
/* $Header: IGSPR06S.pls 115.3 2002/11/29 02:45:10 nsidana ship $ */
  --
  -- Validate the IGS_PR_RU_CAT.s_rule_call_cd field.
  FUNCTION prgp_val_src_prg(
  p_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_src_prg, WNDS);
  --
  -- Validate the IGS_PR_RU_CAT.s_rule_call_cd.
  FUNCTION prgp_val_prgc_upd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_old_s_rule_call_cd IN VARCHAR2 ,
  p_new_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_prgc_upd, WNDS);
END IGS_PR_VAL_PRGC;

 

/
