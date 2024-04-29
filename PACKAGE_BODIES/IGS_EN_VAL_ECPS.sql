--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ECPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ECPS" AS
/* $Header: IGSEN36B.pls 115.4 2003/05/21 10:09:12 ptandon ship $ */
  --
  -- Validate the enrolment cat procedure step system enrolment step type.
  /*---------------------------------------------------------------------------------------------------------------------------------------
  --Change History:
  --Who         When          What
  --ptandon    21-MAY-2003    Replaced usage of Message IGS_EN_ENRL_STEP_TYP_CLOSED with IGS_PR_SY_EN_STP_TYP_CLD. Bug#2755657
  -----------------------------------------------------------------------------------------------------------------------------------------*/

  FUNCTION enrp_val_ecps_sest(
  p_s_enrolment_step_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_s_enrolment_step_type IS
  		SELECT	closed_ind
  		FROM	IGS_LOOKUPS_VIEW
  		WHERE	lookup_type = 'ENROLMENT_STEP_TYPE' and
			lookup_code  = p_s_enrolment_step_type;
  BEGIN
  	-- Validate if the enrolment_cat_procedure_step is open
  	p_message_name := null;
  	OPEN c_s_enrolment_step_type;
  	FETCH c_s_enrolment_step_type INTO v_closed_ind;
  	IF (c_s_enrolment_step_type%NOTFOUND) THEN
  		CLOSE c_s_enrolment_step_type;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_s_enrolment_step_type;
  	IF (v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	-- s_enrolment_step_type is closed
  	p_message_name := 'IGS_PR_SY_EN_STP_TYP_CLD';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ECPS.enrp_val_ecps_sest');
			IGS_GE_MSG_STACK.ADD;
	       	        App_Exception.Raise_Exception;
  END;
  END enrp_val_ecps_sest;
END IGS_EN_VAL_ECPS;

/
