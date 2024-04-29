--------------------------------------------------------
--  DDL for Package Body IGS_ST_VAL_ULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_VAL_ULA" AS
/* $Header: IGSST16B.pls 115.5 2002/11/29 04:13:04 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (STAP_VAL_CI_STATUS) - from the spec and body. -- kdande
*/
  --
  -- Validate the unit load apportion unit version status.
  FUNCTION stap_val_ula_uv_sts(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR c_uv IS
  		SELECT	us.s_unit_status
  		FROM	IGS_PS_UNIT_VER	uv,
  			IGS_PS_UNIT_STAT	us
  		WHERE	uv.unit_cd = p_unit_cd AND
  			uv.version_number = p_version_number AND
  			us.unit_status = uv.unit_status;
  BEGIN
  	--Validate the unit load apportion unit version status.  The unit
  	-- version must have a system status of Planned or Active.
  	OPEN c_uv;
  	FETCH c_uv INTO v_s_unit_status;
  	IF(c_uv%FOUND) THEN
  		CLOSE c_uv;
  		--Validate the unit status.
  		IF	(v_s_unit_status <> 'ACTIVE' AND
  				v_s_unit_status <> 'PLANNED') THEN
  			--p_message_num := 1988;
			p_message_name := 'IGS_ST_UNT_OFF_BE_ACTIVE_PLAN';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_uv;
  	END IF;
  	--- Set the default message number
  	p_message_name := null;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_VAL_ULA.stap_val_ula_uv_sts');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END stap_val_ula_uv_sts;
END IGS_ST_VAL_ULA;

/
