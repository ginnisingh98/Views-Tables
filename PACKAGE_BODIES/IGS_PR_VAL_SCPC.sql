--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SCPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SCPC" AS
/* $Header: IGSPR10B.pls 115.5 2002/11/29 02:46:08 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function prgp_val_appeal_ind removed
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function prgp_val_cause_ind removed
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  -------------------------------------------------------------------------------------------
  -- Validate the appeal indicator being set
  FUNCTION prgp_val_scpc_apl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_scpc_apl
  	-- Validate if appeal indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_scpca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_CRV_PRG_CAL
  	WHERE	course_cd = p_course_cd
  	AND	version_number = p_version_number
  	AND	appeal_length IS NOT NULL;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_appeal_ind = 'N' THEN
  		OPEN	c_scpca;
  		FETCH	c_scpca INTO v_dummy;
  		IF c_scpca%FOUND THEN
  			p_message_name := 'IGS_PR_APPEAL_NOT_AVAILABLE';
  			CLOSE	c_scpca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_scpca;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scpca%ISOPEN THEN
  			CLOSE c_scpca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPC.PRGP_VAL_SCPC_APL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END prgp_val_scpc_apl;
  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_scpc_cause(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_scpc_cause
  	-- Validate if show cause indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_scpca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_CRV_PRG_CAL
  	WHERE	course_cd = p_course_cd
  	AND	version_number = p_version_number
  	AND	show_cause_length IS NOT NULL;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_show_cause_ind = 'N' THEN
  		OPEN	c_scpca;
  		FETCH	c_scpca INTO v_dummy;
  		IF c_scpca%FOUND THEN
  			p_message_name := 'IGS_PR_SHOW_CAUSE_NOT_AVAILAB';
  			CLOSE	c_scpca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_scpca;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scpca%ISOPEN THEN
  			CLOSE c_scpca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPC.PRGP_VAL_SCPC_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_scpc_cause;
  --
  -- Validate the appeal period length of the s_prg_cal record.
  FUNCTION prgp_val_appeal_da(
  p_appeal_ind IN VARCHAR2 ,
  p_appeal_cutoff_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_appeal_da
  	-- Validate the appeal indicator / date alias against one another ;
  	-- designed as a record level validation
  DECLARE
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_appeal_ind = 'Y' AND
  			p_appeal_cutoff_dt_alias IS NULL THEN
  		p_message_name := 'IGS_PR_SET_DA_IF_APPEAL';
  		RETURN FALSE;
  	END IF;
  	IF p_appeal_ind = 'N' AND
  			p_appeal_cutoff_dt_alias IS NOT NULL THEN
  		p_message_name := 'IGS_PR_CANT_SET_DA_IF_APP_NA';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPC.PRGP_VAL_APPEAL_DA');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_appeal_da;
  --
  -- Validate the show cause period length of the s_prg_cal record.
  FUNCTION prgp_val_cause_da(
  p_show_cause_ind IN VARCHAR2 ,
  p_show_cause_cutoff_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_cause_da
  	-- Validate the show cause indicator / date alias against one another ;
  	-- designed as a record level validation.
  DECLARE
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_show_cause_ind = 'Y' AND
  			p_show_cause_cutoff_dt_alias IS NULL THEN
  		p_message_name := 'IGS_PR_DA_MUST_BE_SET';
  		RETURN FALSE;
  	END IF;
  	IF p_show_cause_ind = 'N' AND
  			p_show_cause_cutoff_dt_alias IS NOT NULL THEN
  		p_message_name := 'IGS_PR_DA_CANT_BE_SET';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE ;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPC.PRGP_VAL_CAUSE_DA');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_cause_da;
  --
  -- Validate that IGS_CA_DA.IGS_CA_DA is not closed.
  FUNCTION prgp_val_da_closed(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_da_closed
  	-- Validate if IGS_CA_DA.IGS_CA_DA is closed.
  DECLARE
  	v_closed_ind			VARCHAR2(1);
  	CURSOR c_da IS
  		SELECT	da.closed_ind
  		FROM	IGS_CA_DA	da
  		WHERE	da.dt_alias	= p_dt_alias;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_dt_alias IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_da;
  	FETCH c_da INTO v_closed_ind;
  	IF c_da%FOUND THEN
  		CLOSE c_da;
  		IF v_closed_ind = 'Y' THEN
  			p_message_name := 'IGS_CA_DTALIAS_IS_CLOSED';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_da;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_da%ISOPEN THEN
  			CLOSE c_da;
  		END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPC.PRGP_VAL_DA_CLOSED');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_da_closed;
END IGS_PR_VAL_SCPC;

/
