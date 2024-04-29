--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACCT" AS
/* $Header: IGSAD26B.pls 115.5 2002/11/28 21:28:32 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.
  FUNCTION admp_val_ac_closed(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ac_closed
  	-- Validate if IGS_AD_CAT.admission_cat is closed.
  DECLARE
  	v_closed_ind		IGS_AD_CAT.closed_ind%type;
  	CURSOR c_ac IS
  		SELECT ac.closed_ind
  		FROM	IGS_AD_CAT ac
  		WHERE	ac.admission_cat = p_admission_cat;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_ac;
  	FETCH c_ac INTO v_closed_ind;
  	IF (c_ac%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_AD_ADM_CATEGORY_CLOSED';
  			CLOSE c_ac;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_ac;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACCT.admp_val_ac_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_ac_closed;

END IGS_AD_VAL_ACCT;

/
