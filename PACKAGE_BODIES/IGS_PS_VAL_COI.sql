--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COI" AS
/* $Header: IGSPS24B.pls 115.5 2002/11/29 02:59:36 nsidana ship $ */
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
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	--- Validate that IGS_PS_OFR_INST and IGS_PS_OFR_PAT
  	--- minimum entry assessment score <= guaranteed entry assessment score.
  DECLARE
  BEGIN
  	--- Set the default message.
  	p_message_name := NULL;
  	--- Check that both parameters exist.
  	IF p_min_entry_ass_score IS NULL
  	OR p_guaranteed_entry_ass_scr IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_min_entry_ass_score > p_guaranteed_entry_ass_scr THEN
  		p_message_name := 'IGS_PS_GUARANTEE_ENTRY_ASSESS';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value.
  	RETURN TRUE;
  END;
  END crsp_val_ent_ass_scr;
END IGS_PS_VAL_COi;

/
