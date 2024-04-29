--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PIT" AUTHID CURRENT_USER AS
/* $Header: IGSEN55S.pls 115.3 2002/11/29 00:03:41 nsidana ship $ */
  --
  -- Validate the person id type INSTITUTION code is active.
  FUNCTION enrp_val_pit_inst_cd(
  p_institution_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_pit_inst_cd , WNDS);
END IGS_EN_VAL_PIT;

 

/
