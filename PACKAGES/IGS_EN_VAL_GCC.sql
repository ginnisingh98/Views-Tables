--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GCC" AUTHID CURRENT_USER AS
/* $Header: IGSEN40S.pls 115.3 2002/11/28 23:59:05 nsidana ship $ */
  --
  -- Validate the update of a government citizenship code record.
  FUNCTION enrp_val_gcc_upd(
  p_govt_citizenship_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_gcc_upd,WNDS);
END IGS_EN_VAL_GCC;

 

/
