--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_FS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_FS" AS
 /* $Header: IGSPS42B.pls 115.3 2002/11/29 03:03:45 nsidana ship $ */

  --
  -- Validate the funding source government funding source.
  FUNCTION crsp_val_fs_govt(
  p_govt_funding_source IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_FI_FUND_SRC.closed_ind%TYPE;
  	CURSOR	c_govt_funding_source IS
  		SELECT closed_ind
  		FROM   IGS_FI_GOVT_FUND_SRC
  		WHERE  govt_funding_source = p_govt_funding_source;
  BEGIN
  	OPEN c_govt_funding_source;
  	FETCH c_govt_funding_source INTO v_closed_ind;
  	IF c_govt_funding_source%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_govt_funding_source;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_govt_funding_source;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_FUNDSRC_CLOSED';
  		CLOSE c_govt_funding_source;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FS.crsp_val_fs_govt');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_fs_govt;
END IGS_PS_VAL_FS ;

/
