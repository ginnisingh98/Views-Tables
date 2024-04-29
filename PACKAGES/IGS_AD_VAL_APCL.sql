--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_APCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_APCL" AUTHID CURRENT_USER AS
/* $Header: IGSAD39S.pls 115.5 2002/11/28 21:31:33 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Added Pragma to Function "corp_val_slet_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Added Pragma to Function "corp_val_slet_slrt"
  -------------------------------------------------------------------------------------------

  -- Validate if System Letter is closed.
  FUNCTION corp_val_slet_closed(
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(corp_val_slet_closed,WNDS);

  -- Validate the System Letter is of a certain Letter Reference Type.
  FUNCTION CORP_VAL_SLET_SLRT(
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_s_letter_reference_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(CORP_VAL_SLET_SLRT,WNDS);
END IGS_AD_VAL_APCL;

 

/
