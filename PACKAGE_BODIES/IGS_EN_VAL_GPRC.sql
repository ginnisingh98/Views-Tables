--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GPRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GPRC" AS
/* $Header: IGSEN44B.pls 115.3 2002/11/28 23:59:53 nsidana ship $ */
  --
  -- Validate the update of a government permanent resident code record.
  FUNCTION enrp_val_gprc_upd(
  p_govt_perm_resident_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_perm_resident_cd	IGS_PE_PERM_RES_CD%ROWTYPE;
  	CURSOR	c_perm_resident_cd IS
  		SELECT 	*
  		FROM	IGS_PE_PERM_RES_CD
  		WHERE	govt_perm_resident_cd = p_govt_perm_resident_cd and
  			closed_ind = 'N';
  BEGIN
  	-- Validate the update on a IGS_PE_GOV_PER_RESCD record.
  	-- A IGS_PE_GOV_PER_RESCD record cannot be closed if
  	-- there are IGS_PE_LANGUAGE_CD records mapped to it that
  	-- are still open
  	IF (p_closed_ind = 'Y') THEN
  		-- check if open IGS_PE_PERM_RES_CD records exist
  		OPEN  c_perm_resident_cd;
  		FETCH c_perm_resident_cd INTO v_perm_resident_cd;
  		IF (c_perm_resident_cd%FOUND) THEN
  			CLOSE c_perm_resident_cd;
  			p_message_name := 'IGS_EN_CANT_CLOSE_GOV_PERM_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GPRC.enrp_val_gprc_upd');
		IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;


  END;
  END enrp_val_gprc_upd;
END IGS_EN_VAL_GPRC;

/
