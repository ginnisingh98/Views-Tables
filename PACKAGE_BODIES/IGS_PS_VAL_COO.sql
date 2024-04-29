--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COO" AS
/* $Header: IGSPS25B.pls 115.7 2002/11/29 02:59:51 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
  --

  -- Validate IGS_PS_COURSE offering option attendance mode.
  FUNCTION crsp_val_coo_am(
  p_attendance_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_EN_ATD_MODE.closed_ind%TYPE;
  	CURSOR 	c_attendance_mode(
  			cp_attendance_mode IGS_EN_ATD_MODE.attendance_mode%TYPE)IS
  		SELECT 	closed_ind
  		FROM	IGS_EN_ATD_MODE
  		WHERE	attendance_mode = cp_attendance_mode;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_attendance_mode(
  			p_attendance_mode);
  	FETCH c_attendance_mode INTO v_closed_ind;
  	IF(c_attendance_mode%NOTFOUND) THEN
  		CLOSE c_attendance_mode;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_attendance_mode;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_ATTEND_MODE_CLOSED';
  		RETURN FALSE;
  	END IF;
  END crsp_val_coo_am;
  --
  -- Validate that IGS_PS_COURSE offering option attendance type.
  FUNCTION crsp_val_coo_att(
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind	IGS_EN_ATD_TYPE.closed_ind%TYPE;
  	CURSOR 	c_attendance_type(
  			cp_attendance_type IGS_EN_ATD_TYPE.attendance_type%TYPE)IS
  		SELECT 	closed_ind
  		FROM	IGS_EN_ATD_TYPE
  		WHERE	attendance_type = cp_attendance_type;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_attendance_type(
  			p_attendance_type);
  	FETCH c_attendance_type INTO v_closed_ind;
  	IF(c_attendance_type%NOTFOUND) THEN
  		CLOSE c_attendance_type;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_attendance_type;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_ATTEND_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  END crsp_val_coo_att;
END IGS_PS_VAL_COo;

/
