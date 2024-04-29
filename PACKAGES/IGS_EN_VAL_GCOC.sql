--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GCOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GCOC" AUTHID CURRENT_USER AS
/* $Header: IGSEN41S.pls 115.3 2002/11/28 23:59:19 nsidana ship $ */
  --
  -- Validate the update of a government country code record.
  FUNCTION enrp_val_gcoc_upd(
  p_govt_country_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_gcoc_upd,WNDS);
END IGS_EN_VAL_GCOC;

 

/
