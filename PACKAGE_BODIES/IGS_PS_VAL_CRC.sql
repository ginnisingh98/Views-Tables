--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CRC" AS
 /* $Header: IGSPS31B.pls 115.4 2002/11/29 03:01:23 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_exists"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_sys_sts"
  -------------------------------------------------------------------------------------------

  --
  -- Validate the IGS_PS_COURSE categorisation IGS_PS_COURSE category.
  FUNCTION crsp_val_crc_crs_cat(
  p_course_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_CAT.closed_ind%TYPE;
  	CURSOR	c_course_cat IS
  		SELECT closed_ind
  		FROM   IGS_PS_CAT
  		WHERE  course_cat = p_course_cat;
  BEGIN
  	OPEN c_course_cat;
  	FETCH c_course_cat INTO v_closed_ind;
  	IF c_course_cat%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_course_cat;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_course_cat;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_PRGCAT_CLOSED';
  		CLOSE c_course_cat;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRC.crsp_val_crc_crs_cat');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crc_crs_cat;
END IGS_PS_VAL_CRC;

/
