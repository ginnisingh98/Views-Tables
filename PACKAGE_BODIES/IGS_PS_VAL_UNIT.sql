--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UNIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UNIT" AS
/* $Header: IGSPS63B.pls 115.4 2002/11/29 03:09:21 nsidana ship $ */

  --
  -- Validate if insert/updates/deletes can be made to IGS_PS_UNIT version details
  FUNCTION crsp_val_iud_uv_dtl(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR c_get_s_unit_status IS
  		SELECT	s_unit_status
  		FROM	IGS_PS_UNIT_VER,
  			IGS_PS_UNIT_STAT
  		WHERE	unit_cd				= p_unit_cd		AND
  			version_number			= p_version_number	AND
  			IGS_PS_UNIT_VER.unit_status	= IGS_PS_UNIT_STAT.unit_status;
  BEGIN
  	-- validate whether or not inserts and updates can be made
  	-- to IGS_PS_UNIT version detail record.
  	p_message_name := NULL;
  	OPEN c_get_s_unit_status;
  	FETCH c_get_s_unit_status INTO v_s_unit_status;
  	IF (c_get_s_unit_status%NOTFOUND) THEN
  		CLOSE c_get_s_unit_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_unit_status;
  	IF (v_s_unit_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	END IF;
  	p_message_name := 'IGS_PS_NOCHG_UNITVER_DETAILS';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_iud_uv_dtl;
END IGS_PS_VAL_UNIT;

/
