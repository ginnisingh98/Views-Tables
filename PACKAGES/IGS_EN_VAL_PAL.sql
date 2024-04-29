--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PAL" AUTHID CURRENT_USER AS
/* $Header: IGSEN49S.pls 115.4 2002/11/29 00:02:00 nsidana ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_STRT_END_DT
  --                            Removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            Removed .
  -------------------------------------------------------------------------------------------
   -- Validate the IGS_PE_PERSON alias name and IGS_PE_TITLE
  FUNCTION enrp_val_pal_alias(
  p_person_id IN NUMBER ,
  p_surname IN VARCHAR2 ,
  p_given_names IN VARCHAR2 ,
  p_title IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_pal_alias,WNDS);
  --
  -- Validate the alternate IGS_PE_PERSON id end date.
  FUNCTION enrp_val_api_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_api_end_dt,WNDS);
  --
  -- Validate the IGS_PE_PERSON alias names
  FUNCTION enrp_val_pal_names(
  p_given_names IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_pal_names,WNDS);
  --
END IGS_EN_VAL_PAL;

 

/
