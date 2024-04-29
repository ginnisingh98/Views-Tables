--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_SLET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_SLET" AUTHID CURRENT_USER AS
/* $Header: IGSCO19S.pls 115.5 2002/11/28 23:06:51 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if System Letter Object is closed.
  FUNCTION corp_val_slo_closed(
  p_s_letter_object IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_slo_closed,WNDS);
  --
  --  Validate if the IGS_CO_TYPE is a system generated type.
  FUNCTION corp_val_cort_sysgen(
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_cort_sysgen,WNDS);
END IGS_CO_VAL_SLET;

 

/
