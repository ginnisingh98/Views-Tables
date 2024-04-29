--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_ATT" AS
/* $Header: IGSPS11B.pls 115.4 2002/11/29 02:56:14 nsidana ship $ */

  -- Validate Govt Attendance Type is not closed.
  FUNCTION CRSP_VAL_ATT_GOVT(
  p_govt_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_PS_GOVT_ATD_TYPE.closed_ind%TYPE;
  	CURSOR 	c_govt_attendance_type(
  			cp_govt_attendance_type IGS_PS_GOVT_ATD_TYPE.govt_attendance_type%TYPE)IS
  		SELECT 	closed_ind
  		FROM	IGS_PS_GOVT_ATD_TYPE
  		WHERE	govt_attendance_type = cp_govt_attendance_type;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_govt_attendance_type(
  			p_govt_attendance_type);
  	FETCH c_govt_attendance_type INTO v_closed_ind;
  	IF(c_govt_attendance_type%NOTFOUND) THEN
  		CLOSE c_govt_attendance_type;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_govt_attendance_type;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_ATTEND_TYPE_CLOSE';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_ATT.crsp_val_att_govt');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_att_govt;

  -- To validate the attendance type load ranges
  FUNCTION crsp_val_att_rng(
  p_lower_enr_load_range IN NUMBER ,
  p_upper_enr_load_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  BEGIN
  	-- Set default message
  	p_message_name := NULL;
  	-- Perform validation (check values passed are valid and in the correct range
  	IF p_lower_enr_load_range IS NOT NULL
  	AND p_upper_enr_load_range IS NOT NULL
  	AND p_lower_enr_load_range > p_upper_enr_load_range THEN
  		p_message_name := 'IGS_PS_LOWER_ENRLOAD_LE_UPPER';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END crsp_val_att_rng;

END IGS_PS_VAL_ATT;

/
