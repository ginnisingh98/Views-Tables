--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_PRR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_PRR" AUTHID CURRENT_USER AS
/* $Header: IGSPR07S.pls 115.4 2002/11/29 02:45:31 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_PRGC_CLOSED) - from the spec and body. -- kdande
*/
  --
  -- Validate that a IGS_PR_RULE can be changed.
  FUNCTION prgp_val_prr_upd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_progression_rule_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_prr_upd, WNDS);

END IGS_PR_VAL_PRR;

 

/
