--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FDFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FDFR" AUTHID CURRENT_USER AS
/* $Header: IGSFI28S.pls 115.4 2002/11/29 00:20:57 nsidana ship $ */
  --
  -- Validate if the IGS_RU_CALL.s_rule_call_cd and s_rule_type_cd
  FUNCTION rulp_val_rul_src(
  p_s_rule_call_cd IN IGS_RU_CALL.s_rule_call_cd%TYPE ,
  p_s_rule_type_cd IN IGS_RU_CALL.s_rule_type_cd%TYPE ,
  p_sequence_number IN IGS_RU_RULE.sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(rulp_val_rul_src,WNDS);
END IGS_FI_VAL_FDFR;

 

/
