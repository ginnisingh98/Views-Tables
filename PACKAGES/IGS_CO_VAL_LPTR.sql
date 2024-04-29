--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_LPTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_LPTR" AUTHID CURRENT_USER AS
/* $Header: IGSCO14S.pls 115.5 2002/11/28 23:06:13 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_lpt_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if System Letter Parameter Type Restriction exist.
  FUNCTION corp_val_slptr_rstrn(
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_slptr_rstrn,WNDS);
END IGS_CO_VAL_LPTR;

 

/
