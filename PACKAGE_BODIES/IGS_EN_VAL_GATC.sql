--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GATC" AS
/* $Header: IGSEN39B.pls 115.3 2002/11/28 23:58:45 nsidana ship $ */
  --
  -- Validate the update of a government aboriginal torres code record.
  FUNCTION enrp_val_gatc_upd(
  p_govt_aborig_torres_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_aborig_torres_cd	IGS_PE_ABORG_TORESCD%ROWTYPE;
  	CURSOR	c_aborig_torres_cd IS
  		SELECT 	*
  		FROM	IGS_PE_ABORG_TORESCD
  		WHERE	govt_aborig_torres_cd = p_govt_aborig_torres_cd and
  			closed_ind = 'N';
  BEGIN
  	-- Validate the update on a govt_aborig_torres_cd record.
  	-- A IGS_PE_GOV_ABRGRESCD record cannot be closed if
  	-- there are IGS_PE_LANGUAGE_CD records mapped to it that
  	-- are still open
  	IF (p_closed_ind = 'Y') THEN
  		-- check if open IGS_PE_ABORG_TORESCD records exist
  		OPEN  c_aborig_torres_cd;
  		FETCH c_aborig_torres_cd INTO v_aborig_torres_cd;
  		IF (c_aborig_torres_cd%FOUND) THEN
  			CLOSE c_aborig_torres_cd;
  			p_message_name := 'IGS_EN_CANT_CLOSE_GOV_ISL_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GATC.enrp_val_gatc_upd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_gatc_upd;
END IGS_EN_VAL_GATC;

/
