--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_GAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_GAM" AS
 /* $Header: IGSPS44B.pls 115.3 2002/11/29 03:04:15 nsidana ship $ */

  --
  -- To validate the update of a Govt attendance mode record
  FUNCTION CRSP_VAL_GAM_UPD(
  p_govt_attendance_mode IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_check		CHAR;
  	CURSOR c_check_am_rec IS
  		SELECT 'x'
  		FROM IGS_EN_ATD_MODE
  		WHERE	govt_attendance_mode	= p_govt_attendance_mode AND
  			closed_ind	= 'N';
  BEGIN
  	IF p_closed_ind = 'Y' THEN
  		OPEN c_check_am_rec;
  		FETCH c_check_am_rec INTO v_check;
  		IF c_check_am_rec%FOUND THEN
  			CLOSE c_check_am_rec;
  			p_message_name := 'IGS_PS_CANNOTCLS_GOVT_ATTEND';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_am_rec;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_GAM.crsp_val_gam_upd');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_gam_upd;
END IGS_PS_VAL_GAM;

/
