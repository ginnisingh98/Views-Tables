--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_TELOQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_TELOQ" AS
/* $Header: IGSAD74B.pls 115.4 2002/11/28 21:40:48 nsidana ship $ */

  --
  -- Validate the TAC level of qualification closed ind
  FUNCTION admp_val_tloq_closed(
  p_tac_level_of_qual IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	CURSOR c_tloq IS
  		SELECT	closed_ind
  		FROM	IGS_AD_TAC_LVL_OF_QF
  		WHERE	tac_level_of_qual = p_tac_level_of_qual;
  	v_tloq_rec			c_tloq%ROWTYPE;
  BEGIN
  	-- Check if the tac_level_of_qual is closed.
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_tloq;
  	FETCH c_tloq INTO v_tloq_rec;
  	IF c_tloq%NOTFOUND THEN
  		CLOSE c_tloq;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tloq;
  	IF (v_tloq_rec.closed_ind = 'Y') THEN
		p_message_name := 'IGS_AD_TRTYADM_CENTER_LOQ_CLS';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_TELOQ.admp_val_tloq_closed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_tloq_closed;
END IGS_AD_VAL_TELOQ;

/
