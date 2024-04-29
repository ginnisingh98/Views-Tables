--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_APCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_APCL" AS
/* $Header: IGSAD39B.pls 115.6 2002/11/28 21:31:26 nsidana ship $ */
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
  RETURN BOOLEAN IS
    	gv_other_detail		VARCHAR2(255);
  BEGIN	-- corp_val_slet_closed
  	-- Validate if IGS_CO_S_LTR is closed.
  DECLARE

  	v_closed_ind	IGS_CO_S_LTR.closed_ind%TYPE DEFAULT NULL;
  	CURSOR c_s_letter IS
  		SELECT	closed_ind
  		FROM	IGS_CO_S_LTR
  		WHERE	correspondence_type	= p_correspondence_type AND
  			letter_reference_number	= p_letter_reference_number;

  BEGIN

     	p_message_name := Null;
  	OPEN c_s_letter;
  	FETCH c_s_letter INTO v_closed_ind;
  	CLOSE c_s_letter;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_CO_LETTER_IS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;

  END;

  END corp_val_slet_closed;
  --
  -- Validate the System Letter is of a certain Letter Reference Type.
  FUNCTION CORP_VAL_SLET_SLRT(
  p_correspondence_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_s_letter_reference_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- corp_val_slet_slrt
  	-- This module validates that the passed IGS_CO_S_LTR has the passed
  	-- IGS_CO_S_LTR_REF_TYPE
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_sl IS
  		SELECT	'x'
  		FROM	IGS_CO_S_LTR	sl
  		WHERE	sl.correspondence_type		= p_correspondence_type		AND
  			sl.letter_reference_number 	= p_letter_reference_number	AND
  			sl.s_letter_reference_type	= p_s_letter_reference_type;

  BEGIN

  	-- Set the default message number
  	p_message_name := Null;
  	OPEN c_sl;
  	FETCH c_sl INTO v_dummy;
  	IF c_sl%NOTFOUND THEN
  		CLOSE c_sl;
  		p_message_name := 'IGS_CO_LETTER_NOTAVAIL_SUBSYS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sl;
  	RETURN TRUE;

  EXCEPTION

 	WHEN OTHERS THEN
  		IF c_sl%ISOPEN THEN
  			CLOSE c_sl;
  		END IF;
  		RAISE;

  END;
  END corp_val_slet_slrt;

END IGS_AD_VAL_APCL;

/
