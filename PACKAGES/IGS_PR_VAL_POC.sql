--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_POC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_POC" AUTHID CURRENT_USER AS
/* $Header: IGSPR16S.pls 115.7 2002/11/29 02:48:05 nsidana ship $ */

  --

  -- Warn if the course does not have an active course version

  FUNCTION prgp_val_crv_active(

  p_course_cd IN CHAR ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;


  --

  -- Validate that a prg_outcome_course record can be created

  FUNCTION prgp_val_poc_pro(

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER ,

  p_sequence_number IN NUMBER ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN;

END IGS_PR_VAL_POC;

 

/
