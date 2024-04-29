--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CRS" AS
 /* $Header: IGSPS33B.pls 115.3 2002/11/29 03:01:52 nsidana ship $ */

  --
  -- Validate if inserts/updates/deletes can be made to IGS_PS_COURSE version dtls
  FUNCTION crsp_val_iud_crv_dtl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	CURSOR	c_get_s_course_status IS
  		SELECT	s_course_status
  		FROM	IGS_PS_VER,
  			IGS_PS_STAT
  		WHERE	course_cd			= p_course_cd		AND
  			version_number			= p_version_number	AND
  			IGS_PS_VER.course_status	= IGS_PS_STAT.course_status;
  BEGIN
  	-- Validate the IGS_PS_COURSE version system status to determine if
  	-- updates or inserts can be made to IGS_PS_COURSE detail records.
  	p_message_name := NULL;
  	OPEN c_get_s_course_status;
  	FETCH c_get_s_course_status INTO v_s_course_status;
  	IF (c_get_s_course_status%NOTFOUND) THEN
  		CLOSE c_get_s_course_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_course_status;
  	IF (v_s_course_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	END IF;
  	p_message_name := 'IGS_PS_CHG_CANNOT_BEMADE_PRG';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_iud_crv_dtl;
END IGS_PS_VAL_CRS;

/
