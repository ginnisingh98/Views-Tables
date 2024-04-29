--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ESU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ESU" AS
/* $Header: IGSAS20B.pls 115.5 2002/11/28 22:44:25 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
  --
  -- Validate if the exam supervisor type is not closed.
  FUNCTION ASSP_VAL_EST_CLOSED(
  p_exam_supervisor_type IN VARCHAR2 ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- assp_val_est_closed
  	-- Validates the exam supervisor type closed indicator
  DECLARE
  	v_closed_ind		IGS_AS_EXM_SPRVSRTYP.closed_ind%TYPE;
  	CURSOR c_est (
  			cp_exam_supervisor_type	IGS_AS_EXM_SPRVSRTYP.exam_supervisor_type%TYPE) IS
  		SELECT	est.closed_ind
  		FROM	IGS_AS_EXM_SPRVSRTYP est
  		WHERE	est.exam_supervisor_type = cp_exam_supervisor_type;
  BEGIN
  	P_MESSAGE_NAME := NULL;
  	OPEN	c_est(
  			p_exam_supervisor_type);
  	FETCH	c_est INTO v_closed_ind;
  	IF(c_est%FOUND AND v_closed_ind = 'Y') THEN
  		CLOSE c_est;
  		P_MESSAGE_NAME := 'IGS_AS_EXAM_SUPVTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_est;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	  	FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_ESU.assp_val_est_closed');
		IGS_GE_MSG_STACK.ADD;
  END assp_val_est_closed;
  --

END IGS_AS_VAL_ESU;

/
