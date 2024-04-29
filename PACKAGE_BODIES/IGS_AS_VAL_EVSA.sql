--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_EVSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_EVSA" AS
/* $Header: IGSAS22B.pls 115.5 2002/11/28 22:44:55 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "assp_val_ve_closed"
  -------------------------------------------------------------------------------------------

  --
  -- Validate delete of exam_venue_session_availability
  FUNCTION ASSP_VAL_EVSA_DEL(
  p_ese_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_evsa_del
  	-- Validate the deletion of an exam venue session availability record.
  	-- Check that the availability is not being removed where sessions
  	-- have already been timetabled.
  DECLARE
  	v_x		VARCHAR2(1) DEFAULT NULL;
  	CURSOR	c_ei IS
  		SELECT	'x'
  		From	IGS_AS_EXAM_INSTANCE
  		WHERE	ese_id 	 = p_ese_id AND
  			venue_cd = p_venue_cd;
  BEGIN
  	-- 1. Check whether exam instance records exist.
  	OPEN c_ei;
  	FETCH c_ei INTO v_x;
  	IF (c_ei%FOUND) THEN
  		-- Warning only
  		CLOSE c_ei;
  		p_message_name := 'IGS_AS_VENUE_SCHEDULED';
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ei;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EVSA.assp_val_evsa_del');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_evsa_del;
  --
  -- To validate the calendar instance system cal status is not 'INACTIVE'
  FUNCTION ASSP_VAL_CI_STATUS(
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN boolean IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_ci_status
  	-- Validate the ci s_cal_status
  DECLARE
  	v_s_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR	c_cics (cp_cal_type		IGS_CA_INST.cal_type%TYPE,
  			cp_sequence_number	IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	s_cal_status
  		FROM	IGS_CA_STAT	cs,
  			IGS_CA_INST	ci
  		WHERE	cs.cal_status		= ci.cal_status AND
  			ci.sequence_number	= cp_sequence_number AND
  			ci.cal_type		= cp_cal_type;
  BEGIN
  	p_message_name := null;
  	OPEN c_cics (	p_cal_type,
  			p_sequence_number);
  	FETCH c_cics INTO v_s_cal_status;
  	IF (c_cics%FOUND) THEN
  		IF (v_s_cal_status = 'INACTIVE') THEN
  			p_message_name := 'IGS_AS_CALNST_INACTIVE';
  			v_ret_val := FALSE;
  		END IF;
  	END IF;
  	CLOSE c_cics;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       	       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_VAL_EVSA.assp_val_ci_status');
	       IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  END assp_val_ci_status;
END IGS_AS_VAL_EVSA;

/
