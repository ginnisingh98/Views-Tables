--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_GCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_GCC" AS
/* $Header: IGSEN40B.pls 115.3 2002/11/28 23:58:58 nsidana ship $ */
  --
  -- Validate the update of a government citizenship code record.
  FUNCTION enrp_val_gcc_upd(
  p_govt_citizenship_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_citizenship_cd	IGS_ST_CITIZENSHP_CD%ROWTYPE;
  	CURSOR	c_citizenship_cd IS
  		SELECT 	*
  		FROM	IGS_ST_CITIZENSHP_CD
  		WHERE	govt_citizenship_cd = p_govt_citizenship_cd and
  			closed_ind = 'N';
  BEGIN
  	-- Validate the update on a govt_citizenshhip_record.
  	-- A IGS_PE_GOVCITIZEN_CD record cannot be closed if
  	-- there are IGS_ST_CITIZENSHP_CD records mapped to it that
  	-- are still open
  	IF (p_closed_ind = 'Y') THEN
  		-- check if open IGS_ST_CITIZENSHP_CD records exist
  		OPEN  c_citizenship_cd;
  		FETCH c_citizenship_cd INTO v_citizenship_cd;
  		IF (c_citizenship_cd%FOUND) THEN
  			CLOSE c_citizenship_cd;
  			p_message_name := 'IGS_EN_CANT_CLOSE_GOV_CITZ_CD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_GCC.enrp_val_gcc_upd');
		IGS_GE_MSG_STACK.ADD;
       	        App_Exception.Raise_Exception;


  END;
  END enrp_val_gcc_upd;
END IGS_EN_VAL_GCC;

/
