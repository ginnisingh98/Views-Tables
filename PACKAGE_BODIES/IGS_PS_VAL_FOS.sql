--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_FOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_FOS" AS
 /* $Header: IGSPS41B.pls 115.3 2002/11/29 03:03:28 nsidana ship $ */
  --
  -- Validate the field of study government field of study.
  FUNCTION crsp_val_fos_govt(
  p_govt_field_of_study IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_RE_GV_FLD_OF_SDY.closed_ind%TYPE;
  	CURSOR	c_govt_field_of_study IS
  		SELECT closed_ind
  		FROM  IGS_RE_GV_FLD_OF_SDY
  		WHERE  govt_field_of_study = p_govt_field_of_study;
  BEGIN
  	OPEN c_govt_field_of_study;
  	FETCH c_govt_field_of_study INTO v_closed_ind;
  	IF c_govt_field_of_study%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_govt_field_of_study;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_govt_field_of_study;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_FIELDOF_STUDY_CLS';
  		CLOSE c_govt_field_of_study;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_FOS.crsp_val_fos_govt');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_fos_govt;
END IGS_PS_VAL_FOS;

/
