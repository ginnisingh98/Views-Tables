--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UCL" AS
/* $Header: IGSPS60B.pls 115.3 2002/11/29 03:08:39 nsidana ship $ */

  --
  -- Validate the IGS_PS_UNIT mode for IGS_PS_UNIT class.
  FUNCTION crsp_val_ucl_um(
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_AS_UNIT_MODE.closed_ind%TYPE;
  	CURSOR	c_unit_mode_closed_ind IS
  	SELECT	closed_ind
  	FROM	IGS_AS_UNIT_MODE
  	WHERE	unit_mode = p_unit_mode AND
  		closed_ind = 'Y';
  BEGIN
  	OPEN c_unit_mode_closed_ind;
  	FETCH c_unit_mode_closed_ind INTO v_closed_ind;
  	--- If a record was not found, then return TRUE, else return FALSE
  	IF c_unit_mode_closed_ind%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_unit_mode_closed_ind;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_UNIT_MODE_CLOSED';
  		CLOSE c_unit_mode_closed_ind;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UCl.crsp_val_ucl_um');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_ucl_um;
  --
  -- Validate the start and end times when set for the IGS_PS_UNIT class.
  FUNCTION crsp_val_ucl_st_end(
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- Validate the IGS_PS_UNIT class start and end times
  	IF ((p_start_time IS NULL AND p_end_time IS NOT NULL) OR
  	    (p_start_time IS NOT NULL AND p_end_time IS NULL)) THEN
  		p_message_name := 'IGS_PS_STDT_ENDDT_BOTH_SET_UN';
  		RETURN FALSE;
  	END IF;
  	IF (p_start_time IS NOT NULL AND p_end_time IS NOT NULL) THEN
  		IF (p_end_time <= p_start_time) THEN
  			p_message_name := 'IGS_PS_ENDDT_AFTER_STDT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UCl.crsp_val_ucl_st_end');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_ucl_st_end;
END IGS_PS_VAL_UCl;

/
