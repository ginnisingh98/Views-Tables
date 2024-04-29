--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_LPTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_LPTR" AS
/* $Header: IGSCO14B.pls 115.5 2002/11/28 23:06:06 nsidana ship $ */
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
  RETURN BOOLEAN AS

  BEGIN	-- corp_val_slptr_rstrn
  	-- Validates that the s_letter_parameter_type is able to be used within
  	-- the IGS_CO_TYPE and that no restrictions exist that deny the
  	-- s_letter_parameter_type being able to be assigned within the
  	-- IGS_CO_TYPE.
  DECLARE
  	CURSOR c_slptr IS
  		SELECT	CORRESPONDENCE_TYPE
  		FROM	IGS_CO_S_LTR_PR_RSTN
  		WHERE	s_letter_parameter_type= p_s_letter_parameter_type;
  	v_valid_correspondence_type 	BOOLEAN DEFAULT TRUE;
  BEGIN
  	-- Set the default message number
  	p_message_name   := Null;
  	-- loop through all the records found to check
  	-- whether p_correspondence_type is in the list.
  	FOR v_slptr_rec IN c_slptr LOOP
  		v_valid_correspondence_type := FALSE;
  		IF v_slptr_rec.CORRESPONDENCE_TYPE = p_correspondence_type THEN
  			-- Set a flag to indicate that the s_letter_parameter_type
  			-- can be assigned within the correspondence type and exit the loop.
  			v_valid_correspondence_type := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF NOT v_valid_correspondence_type THEN
  		p_message_name   := 'IGS_CO_SYSLETTER_EXIST_CORTYP';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_slptr%ISOPEN THEN
  			CLOSE c_slptr;
  		END IF;
  		RAISE;
  END;

  END corp_val_slptr_rstrn;
END IGS_CO_VAL_LPTR;

/
