--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_CC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_CC" AUTHID CURRENT_USER AS
/* $Header: IGSCO05S.pls 115.4 2002/11/28 23:04:02 nsidana ship $ */
  -- Validate update of correspondence category closed indicator.
  FUNCTION corp_val_cc_clsd_upd(
  p_correspondence_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cc_clsd_upd,WNDS);
END IGS_CO_VAL_CC;

 

/
