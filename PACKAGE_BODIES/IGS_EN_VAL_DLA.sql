--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_DLA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_DLA" AS
/* $Header: IGSEN32B.pls 115.4 2002/11/28 23:57:01 nsidana ship $ */
  --
  -- Validate the calendar instance status has a system status of Active.
  FUNCTION stap_val_ci_status(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	cst_active		IGS_CA_STAT.s_cal_status%TYPE DEFAULT 'ACTIVE';
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR c_chk_scc IS
  		SELECT	s_cal_status
  		FROM	IGS_CA_STAT cs,
  			IGS_CA_INST ci
  		WHERE	ci.cal_type = p_cal_type			AND
  			ci.sequence_number = p_ci_sequence_number	AND
  			cs.cal_status = ci.cal_status;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	--- Retrieve the calendar data.
  	OPEN c_chk_scc;
  	FETCH c_chk_scc INTO v_s_cal_status;
  	IF c_chk_scc%FOUND THEN
  		--- Validate the calendar.
  		IF v_s_cal_status <> 'ACTIVE' then
  			CLOSE c_chk_scc;
  			p_message_name := 'IGS_ST_CAL_INST_NOT_ACTIVE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_chk_scc;
  	--- Return the default value
  	RETURN TRUE;
  END;
  END stap_val_ci_status;
  --
  -- Validate the DLA calendar instance status is ACTIVE or PLANNED
  FUNCTION enrp_val_dla_status(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_cal_status		IGS_CA_INST.cal_status%TYPE;
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR c_ci IS
  		SELECT	cal_status
  		FROM	IGS_CA_INST
  		WHERE	cal_type = p_cal_type AND
  			sequence_number = p_ci_sequence;
  	CURSOR c_cs (cp_cal_status IGS_CA_STAT.cal_status%TYPE) IS
  		SELECT	s_cal_status
  		FROM	IGS_CA_STAT
  		WHERE	cal_status = cp_cal_status;
  BEGIN
  	-- This function validates the IGS_CA_INST calendar status
  	-- for a IGS_ST_DFT_LOAD_APPO record being inserted.
  	--- Set the default message number
  	p_message_name := null;
  	OPEN 	c_ci;
  	FETCH	c_ci	INTO	v_cal_status;
  	IF (c_ci%NOTFOUND) THEN
  		-- no records found
  		CLOSE c_ci;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ci;
  	OPEN 	c_cs (v_cal_status);
  	FETCH	c_cs	INTO	v_s_cal_status;
  	IF (c_cs%NOTFOUND) THEN
  		-- no records found
  		CLOSE c_cs;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cs;
  	IF (v_s_cal_status  <>  'ACTIVE') AND
  		(v_s_cal_status  <>  'PLANNED') THEN
  		-- Calendar instance system calendar status
  		-- must be 'ACTIVE' or 'PLANNED'
  		p_message_name := 'IGS_CA_CALINST_ACTIVE_PLANNED';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DLA.enrp_val_dla_status');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dla_status;
  --
  -- Validate the DLA calendar type s_cal_cat = 'LOAD' and closed_ind
  FUNCTION enrp_val_dla_cat_ld(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_closed_ind		IGS_CA_TYPE.closed_ind%TYPE;
  	v_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_ct IS
  		SELECT	closed_ind,
  			s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = p_cal_type;
  BEGIN
  	-- This function checks that the cal_type calendar category
  	-- is 'LOAD' and validates the closed indicator for an
  	-- IGS_ST_DFT_LOAD_APPO record being inserted with each cal_type.
  	--- Set the default message number
  	p_message_name := null;
  	OPEN 	c_ct;
  	FETCH	c_ct	INTO	v_closed_ind,
  				v_s_cal_cat;
  	IF (c_ct%NOTFOUND) THEN
  		-- no records found
  		CLOSE c_ct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ct;
  	IF (v_closed_ind = 'Y') THEN
  		-- calandar type is closed
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_cal_cat  <>  'LOAD') THEN
  		-- calandar type must be a load period calendar
  		p_message_name := 'IGS_EN_CALTYPE_LOAD_PRDCAL';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DLA.enrp_val_dla_cat_ld');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dla_cat_ld;
  --
  -- Validate the DLA calendar type s_cal_cat = 'TEACHING' and closed_ind
  FUNCTION enrp_val_dla_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN
  DECLARE
  	v_closed_ind		IGS_CA_TYPE.closed_ind%TYPE;
  	v_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_ct IS
  		SELECT	closed_ind,
  			s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = p_cal_type;
  BEGIN
  	-- This function checks that the cal_type calendar category
  	-- is 'TEACHING' and validates the closed indicator for an
  	-- IGS_ST_DFT_LOAD_APPO record being inserted with each
  	-- teach_cal_type.
  	--- Set the default message number
  	p_message_name := null;
  	OPEN 	c_ct;
  	FETCH	c_ct	INTO	v_closed_ind,
  				v_s_cal_cat;
  	IF (c_ct%NOTFOUND) THEN
  		-- no records found
  		CLOSE c_ct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ct;
  	IF (v_closed_ind = 'Y') THEN
  		-- calandar type is closed
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_cal_cat  <>  'TEACHING') THEN
  		-- calandar type must be a teaching period calendar
  		p_message_name := 'IGS_EN_CAL_TYPE_MUST_BE_TEACH';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_DLA.enrp_val_dla_cat');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_dla_cat;
END IGS_EN_VAL_DLA;

/
