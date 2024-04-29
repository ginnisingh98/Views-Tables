--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_AUSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_AUSG" AUTHID CURRENT_USER AS
/* $Header: IGSEN26S.pls 115.4 2002/11/28 23:55:37 nsidana ship $ */

  --
  -- Bug ID : 1956374
  -- sjadhav,28-aug-2001
  -- removed function ENRP_VAL_AUS_DISCONT
  -- removed function enrp_val_aus_closed
  --
  -- Validate the administrative unit status grade against grading schema
  FUNCTION enrp_val_ausg_gs(
  p_grading_schema_code IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ausg_gs,WNDS);
END IGS_EN_VAL_AUSG;

 

/
