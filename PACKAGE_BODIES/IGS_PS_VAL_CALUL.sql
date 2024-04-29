--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CALUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CALUL" AS
/* $Header: IGSPS15B.pls 115.5 2002/11/29 02:57:01 nsidana ship $ */
  --
  -- Validate that the IGS_PS_UNIT version exists.
  FUNCTION crsp_val_uv_exists(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    	v_check		CHAR;
  	CURSOR c_sel_unit_version IS
  		SELECT	'x'
  		FROM	IGS_PS_UNIT_VER
  		WHERE	unit_cd		= p_unit_cd	AND
  			version_number	= p_version_number;
  BEGIN
  	OPEN c_sel_unit_version;
  	FETCH c_sel_unit_version INTO v_check;
  	-- validate the IGS_PS_UNIT version exists
  	IF (c_sel_unit_version%NOTFOUND) THEN
  		CLOSE c_sel_unit_version;
  		p_message_name := 'IGS_PS_UNITCODE_UNITVER_NE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sel_unit_version;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CALUL.crsp_val_uv_exists');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_uv_exists;
  --
  -- Validate IGS_PS_UNIT version system status.
  FUNCTION crsp_val_uv_sys_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_unit_status	IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR c_get_s_unit_status IS
  		SELECT	s_unit_status
  		FROM	IGS_PS_UNIT_VER,
  			IGS_PS_UNIT_STAT
  		WHERE	unit_cd			= p_unit_cd		AND
  			version_number		= p_version_number	AND
  			IGS_PS_UNIT_VER.unit_status	= IGS_PS_UNIT_STAT.unit_status;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_s_unit_status;
  	FETCH c_get_s_unit_status INTO v_s_unit_status;
  	IF c_get_s_unit_status%NOTFOUND THEN
  		CLOSE c_get_s_unit_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_unit_status;
  	-- Validate the system status of the IGS_PS_UNIT version
  	IF (v_s_unit_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	END IF;
  	p_message_name := 'IGS_PS_UNITVER_ST_ACTIVEPLANN';
  	RETURN FALSE;

  END crsp_val_uv_sys_sts;
END IGS_PS_VAL_CALul;

/
