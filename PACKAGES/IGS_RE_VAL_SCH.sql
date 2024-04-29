--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_SCH" AUTHID CURRENT_USER AS
/* $Header: IGSRE12S.pls 115.4 2002/11/29 03:29:38 nsidana ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  -------------------------------------------------------------------------------------------
    -- To validate IGS_RE_SCHL_TYPE closed indicator
  FUNCTION RESP_VAL_SCHT_CLOSED(
  p_scholarship_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  -- To validate IGS_RE_SCHOLARSHIP date overlaps
  FUNCTION RESP_VAL_SCH_OVRLP(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_scholarship_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;


END IGS_RE_VAL_SCH;

 

/
