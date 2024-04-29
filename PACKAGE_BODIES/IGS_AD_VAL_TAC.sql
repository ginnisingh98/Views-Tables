--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_TAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_TAC" AS
/* $Header: IGSAD71B.pls 115.3 2002/11/28 21:40:02 nsidana ship $ */

  --
  -- Validate the update of a TAC admission code record
  FUNCTION admp_val_tac_upd(
  p_tac_admission_cd IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_tac IS
  		SELECT	COUNT(*)
  		FROM	IGS_AD_CD
  		WHERE	tac_admission_cd = p_tac_admission_cd AND
  			closed_ind = 'N';
  	v_tac_count		NUMBER;
  BEGIN
  	-- Validate the update of a IGS_AD_TAC_AD_CD record. A record cannot be closed
   	-- if  there are records mapped onto it which are still open.
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_closed_ind = 'Y') THEN
  		-- Cursor handling
  		OPEN c_tac;
  		FETCH c_tac INTO v_tac_count;
  		IF c_tac%NOTFOUND THEN
  			CLOSE c_tac;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_tac;
  		IF (v_tac_count > 0) THEN
			p_message_name := 'IGS_AD_CANNOT_CLS_TAC_ADMCD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TAC.admp_val_tac_upd');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_tac_upd;
END IGS_AD_VAL_TAC;

/
