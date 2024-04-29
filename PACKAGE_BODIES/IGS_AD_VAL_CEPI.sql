--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_CEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_CEPI" AS
/* $Header: IGSAD49B.pls 115.3 2002/11/28 21:34:50 nsidana ship $ */
  -- Validate that the course version exists.
  FUNCTION crsp_val_crv_exists(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	v_other_detail	VARCHAR2(255);
  	v_check		CHAR;
  	CURSOR c_sel_course_version IS
  		SELECT	'x'
  		FROM	IGS_PS_VER
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  BEGIN
  	OPEN c_sel_course_version;
  	FETCH c_sel_course_version INTO v_check;
  	-- validate the course version exists
  	IF (c_sel_course_version%NOTFOUND) THEN
  		CLOSE c_sel_course_version;
  		--p_message_num := 411;
		p_message_name := 'IGS_PS_PRGCD_PRGVERNUM_NOTEXI';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sel_course_version;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_CEPI.crsp_val_crv_exists');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END crsp_val_crv_exists;
  --
  -- Validate unit version system status.
  FUNCTION crsp_val_crv_sys_sts(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name	OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	v_other_detail		VARCHAR2(255);
  	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	CURSOR c_get_s_course_status IS
  		SELECT	s_course_status
  		FROM	IGS_PS_VER,
  			IGS_PS_STAT
  		WHERE	course_cd		= p_course_cd		AND
  			version_number		= p_version_number	AND
  			IGS_PS_VER.course_status	= IGS_PS_STAT.course_status;
  BEGIN
  	p_message_name := null;
  	OPEN c_get_s_course_status;
  	FETCH c_get_s_course_status INTO v_s_course_status;
  	IF c_get_s_course_status%NOTFOUND THEN
  		CLOSE c_get_s_course_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_course_status;
  	-- Validate the system status of the course version
  	IF (v_s_course_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	END IF;
  	--p_message_num := 412;
	p_message_name := 'IGS_PS_PRGVER_NOSTAUS_ACTPLAN';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_CEPI.crsp_val_crv_sys_sts');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END crsp_val_crv_sys_sts;

END IGS_AD_VAL_CEPI;

/
