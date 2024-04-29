--------------------------------------------------------
--  DDL for Package IGS_RU_VAL_RUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_VAL_RUD" AUTHID CURRENT_USER AS
/* $Header: IGSRU08S.pls 115.5 2002/11/29 03:40:22 nsidana ship $ */

  --
  -- Validate the new IGS_RU_RULE description, compared with old
  FUNCTION RULP_VAL_RUD_DESC(
  p_old_sequence_number IN NUMBER ,
  p_old_return_type IN VARCHAR2 ,
  p_old_rule_description IN VARCHAR2 ,
  p_old_turing_function IN VARCHAR2 ,
  p_new_return_type IN VARCHAR2 ,
  p_new_rule_description IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
   PRAGMA RESTRICT_REFERENCES(RULP_VAL_RUD_DESC,WNDS);

END IGS_RU_VAL_RUD;

 

/
