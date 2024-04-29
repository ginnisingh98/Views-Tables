--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_SP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_SP" AUTHID CURRENT_USER AS
/* $Header: IGSEN67S.pls 115.3 2002/11/29 00:07:30 nsidana ship $ */
  --
  -- To validate the delete of suburb postcode
  FUNCTION enrp_val_sp_del(
  p_postcode IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_sp_del , WNDS);
END IGS_EN_VAL_SP;

 

/
