--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACCT" AUTHID CURRENT_USER AS
/* $Header: IGSAD26S.pls 115.5 2002/11/28 21:28:40 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------

  -- Validate if IGS_AD_CAT.admission_cat is closed.
  FUNCTION admp_val_ac_closed(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_ACCT;

 

/
