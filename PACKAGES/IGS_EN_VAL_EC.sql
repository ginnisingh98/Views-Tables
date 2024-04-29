--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_EC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_EC" AUTHID CURRENT_USER AS
/* $Header: IGSEN34S.pls 115.4 2002/11/28 23:57:36 nsidana ship $ */
  --
  -- Validate update of enrolment category closed indicator.
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- remove FUNCTION enrp_val_ec_closed
  --
  FUNCTION enrp_val_ec_clsd_upd(
  p_enrolment_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_ec_clsd_upd,WNDS);

END IGS_EN_VAL_EC;

 

/
