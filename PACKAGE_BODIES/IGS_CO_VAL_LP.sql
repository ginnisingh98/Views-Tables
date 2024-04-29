--------------------------------------------------------
--  DDL for Package Body IGS_CO_VAL_LP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_VAL_LP" AS
/* $Header: IGSCO11B.pls 115.7 2002/11/28 23:05:30 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_cort_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "corp_val_lpt_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "corp_val_slet_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if Letter Parameter Type Restriction exist.
  FUNCTION corp_val_lptr_rstrn(
  p_letter_parameter_type IN VARCHAR2 ,
  p_correspondence_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN	-- corp_val_lptr_rstrn
  	-- Validates that the IGS_CO_LTR_PARM_TYPE is able to be used
  	-- within the IGS_CO_TYPE and that no restrictions exist
  	-- that deny the IGS_CO_LTR_PARM_TYPE being able to be assigned
  	-- within the IGS_CO_TYPE.
  DECLARE
  	CURSOR c_lptr IS
  		SELECT	CORRESPONDENCE_TYPE
  		FROM	IGS_CO_LTR_PR_RSTCN
  		WHERE	letter_parameter_type = p_letter_parameter_type;
  	CURSOR c_lpt IS
  		SELECT	s_letter_parameter_type
  		FROM	IGS_CO_LTR_PARM_TYPE
  		WHERE	letter_parameter_type = p_letter_parameter_type;
  	v_lpt_rec			c_lpt%ROWTYPE;
  	v_valid_correspondence_type	BOOLEAN DEFAULT TRUE;
  	v_message_name			varchar2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- loop through all records found to check
  	-- whether p_correspondence_type is in the list.
  	FOR v_lptr_rec IN c_lptr LOOP
  		v_valid_correspondence_type := FALSE;
  		IF v_lptr_rec.CORRESPONDENCE_TYPE = p_correspondence_type THEN
  			v_valid_correspondence_type := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF NOT v_valid_correspondence_type THEN
  		p_message_name := 'IGS_CO_LETTER_EXIST_CORTYPE';
  		RETURN FALSE;
  	END IF;
  	-- Cursor handling
  	OPEN c_lpt;
  	FETCH c_lpt INTO v_lpt_rec;
  	CLOSE c_lpt;
  	IF NOT IGS_CO_VAL_LPTR.corp_val_slptr_rstrn(
  					v_lpt_rec.s_letter_parameter_type,
  					p_correspondence_type,
  					v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_lpt%ISOPEN THEN
  			CLOSE c_lpt;
  		END IF;
  		IF c_lptr%ISOPEN THEN
  			CLOSE c_lptr;
  		END IF;
  		RAISE;
  END;
  END corp_val_lptr_rstrn;
END IGS_CO_VAL_LP;

/
