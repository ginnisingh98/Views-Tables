--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAP" AUTHID CURRENT_USER AS
/* $Header: IGSCA13S.pls 115.3 2002/11/28 22:59:15 nsidana ship $ */
  -- Validate IGS_CA_DA_PAIR
  FUNCTION calp_val_dap_da(
  p_related_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(calp_val_dap_da , WNDS);
END IGS_CA_VAL_DAP;

 

/
