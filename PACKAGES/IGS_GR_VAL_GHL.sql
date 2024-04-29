--------------------------------------------------------
--  DDL for Package IGS_GR_VAL_GHL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_VAL_GHL" AUTHID CURRENT_USER AS
/* $Header: IGSGR09S.pls 115.4 2002/11/29 00:41:16 nsidana ship $ */
  --
  -- Validate if government honours level is closed.
  FUNCTION grdp_val_ghl_closed(
  p_govt_honours_level IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate no open honours level using govt honours level to be closed.
  FUNCTION grdp_val_ghl_upd(
  p_govt_honours_level IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_GR_VAL_GHL;

 

/
