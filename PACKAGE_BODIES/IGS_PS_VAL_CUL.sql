--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CUL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CUL" AS
 /* $Header: IGSPS38B.pls 115.5 2003/12/05 06:06:10 nalkumar ship $ */
  --
  -- Validate IGS_PS_COURSE Code.
  FUNCTION crsp_val_crs_type(
    p_course_cd IN VARCHAR2 ,
    p_course_version_number IN NUMBER,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_TYPE.closed_ind%TYPE;
  	CURSOR c_get_closed_ind IS
  		SELECT 'x'
  		FROM	igs_ps_ver_all
  		WHERE	course_cd = p_course_cd
      AND   version_number = p_course_version_number
      AND   SYSDATE BETWEEN start_dt AND NVL(end_dt, SYSDATE);
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_closed_ind;
  	FETCH c_get_closed_ind INTO v_closed_ind;
  	IF c_get_closed_ind%FOUND THEN
  		CLOSE c_get_closed_ind;
  		RETURN TRUE;
    ELSE
  		CLOSE c_get_closed_ind;
  		p_message_name := 'IGS_PR_PRG_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_get_closed_ind;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CUL.crsp_val_crs_type');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crs_type;
  --

END IGS_PS_VAL_CUL;

/
