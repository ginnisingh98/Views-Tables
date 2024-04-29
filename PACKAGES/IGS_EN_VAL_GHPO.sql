--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GHPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GHPO" AUTHID CURRENT_USER AS
/* $Header: IGSEN42S.pls 115.3 2002/11/28 23:59:32 nsidana ship $ */
  --
  -- Validate update of government hecs payment option
  FUNCTION enrp_val_ghpo_upd(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ghpo_upd,WNDS);
END IGS_EN_VAL_GHPO;

 

/
