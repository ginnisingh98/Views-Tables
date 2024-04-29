--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_TELOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_TELOC" AS
/* $Header: IGSAD73B.pls 115.3 2002/11/28 21:40:33 nsidana ship $ */

  --
  -- Validate the Tertiary Admissions Centre level of completion closed ind
  FUNCTION admp_val_tloc_closed(
  p_tac_level_of_comp IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_tloc IS
  		SELECT	closed_ind
  		FROM	IGS_AD_TAC_LV_OF_COM
  		WHERE	tac_level_of_comp = p_tac_level_of_comp;
  	v_tloc_rec			c_tloc%ROWTYPE;
  BEGIN
  	-- Check if the tac_level_of_comp is closed.
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_tloc;
  	FETCH c_tloc INTO v_tloc_rec;
  	IF c_tloc%NOTFOUND THEN
  		CLOSE c_tloc;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tloc;
  	IF (v_tloc_rec.closed_ind = 'Y') THEN
		p_message_name := 'IGS_AD_TRTYADM_CENTER_LOC_CLS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TELOC.admp_val_tloc_closed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_tloc_closed;
END IGS_AD_VAL_TELOC;

/
