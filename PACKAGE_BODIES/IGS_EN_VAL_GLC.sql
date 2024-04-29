--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GLC" AS
/* $Header: IGSEN43B.pls 115.3 2002/11/28 23:59:39 nsidana ship $ */
  --
  -- Validate the update of a government language code record.
  FUNCTION enrp_val_glc_upd(
  p_govt_language_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_language_cd		IGS_PE_LANGUAGE_CD%ROWTYPE;
  	CURSOR	c_language_cd IS
  		SELECT 	*
  		FROM	IGS_PE_LANGUAGE_CD
  		WHERE	govt_language_cd = p_govt_language_cd and
  			closed_ind = 'N';
  BEGIN
  	-- Validate the update on a govt_language_record.
  	-- A IGS_PE_GOV_COUNTRYCD record cannot be closed if
  	-- there are IGS_PE_LANGUAGE_CD records mapped to it that
  	-- are still open
  	IF (p_closed_ind = 'Y') THEN
  		-- check if open IGS_PE_LANGUAGE_CD records exist
  		OPEN  c_language_cd;
  		FETCH c_language_cd INTO v_language_cd;
  		IF (c_language_cd%FOUND) THEN
  			CLOSE c_language_cd;
  			p_message_name := 'IGS_EN_CANT_CLOS_GOV_LANG_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GLC.enrp_val_glc_upd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_glc_upd;
END IGS_EN_VAL_GLC;

/
