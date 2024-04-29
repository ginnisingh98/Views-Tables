--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAOC" AUTHID CURRENT_USER AS
/* $Header: IGSCA12S.pls 115.4 2002/11/28 22:59:01 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_sdoct_clsd"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_sdoct_clash"
  -------------------------------------------------------------------------------------------

--
  -- Validate if date alias offset constraints exist.
  FUNCTION calp_val_daoc_exist(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(calp_val_daoc_exist, WNDS);
END IGS_CA_VAL_DAOC;

 

/
