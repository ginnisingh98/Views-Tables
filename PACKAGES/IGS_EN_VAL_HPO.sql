--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_HPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_HPO" AUTHID CURRENT_USER AS
/* $Header: IGSEN45S.pls 115.3 2002/11/29 00:00:36 nsidana ship $ */
  --
  -- Validate the government hecs payment option closed ind
  FUNCTION enrp_val_hpo_govt(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_hpo_govt,WNDS);
END IGS_EN_VAL_HPO;

 

/
