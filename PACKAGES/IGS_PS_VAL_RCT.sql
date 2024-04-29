--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_RCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_RCT" AUTHID CURRENT_USER AS
/* $Header: IGSPS53S.pls 115.3 2002/11/29 03:07:02 nsidana ship $ */
  --
  -- Validate the system reference code type for reference code type.
  FUNCTION crsp_val_rct_srct(
  p_s_reference_cd_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
END IGS_PS_VAL_RCT;

 

/
