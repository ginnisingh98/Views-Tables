--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COI" AUTHID CURRENT_USER AS
/* $Header: IGSPS24S.pls 115.4 2002/11/29 02:59:43 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_Val_crs_ci"
  -------------------------------------------------------------------------------------------


   --
  -- Validate IGS_PS_COURSE entry assessment scores.
  FUNCTION crsp_val_ent_ass_scr(
  p_min_entry_ass_score IN NUMBER ,
  p_guaranteed_entry_ass_scr IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END IGS_PS_VAL_COi;

 

/
