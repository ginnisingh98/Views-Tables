--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SOPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SOPC" AS
/* $Header: IGSPR12B.pls 115.5 2002/11/29 02:46:45 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_APPEAL_DA removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_CAUSE_DA removed
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_DA_CLOSED removed
  -------------------------------------------------------------------------------------------
  -- Validate the appeal indicator being set
  FUNCTION prgp_val_sopc_apl(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_sopc_apl
  	-- Validate if appeal indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_sopca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_OU_PRG_CAL
  	WHERE	org_unit_cd = p_org_unit_cd
  	AND	ou_start_dt = p_ou_start_dt
  	AND	appeal_length IS NOT NULL;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_appeal_ind = 'N' THEN
  		OPEN	c_sopca;
  		FETCH	c_sopca INTO v_dummy;
  		IF c_sopca%FOUND THEN
  			p_message_name := 'IGS_PR_APPEAL_NOT_AVAILABLE';
  			CLOSE	c_sopca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sopca;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sopca%ISOPEN THEN
  			CLOSE c_sopca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPC.PRGP_VAL_SOPC_APL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sopc_apl;
  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_sopc_cause(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_sopc_cause
  	-- Validate if show cause indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_sopca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_OU_PRG_CAL
  	WHERE	org_unit_cd = p_org_unit_cd
  	AND	ou_start_dt = p_ou_start_dt
  	AND	show_cause_length IS NOT NULL;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_show_cause_ind = 'N' THEN
  		OPEN	c_sopca;
  		FETCH	c_sopca INTO v_dummy;
  		IF c_sopca%FOUND THEN
  			p_message_name := 'IGS_PR_SHOW_CAUSE_NOT_AVAILAB';
  			CLOSE	c_sopca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sopca;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sopca%ISOPEN THEN
  			CLOSE c_sopca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPC.PRGP_VAL_SOPC_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sopc_cause;
  --
  -- Validate the {s_ou_conf,s_crv_conf}.appeal_ind
  FUNCTION prgp_val_appeal_ind(
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_appeal_ind
  	-- Validate the {s_ou_conf,s_crv_conf}.appeal_ind, checking for:
  	-- * Cannot be set if parent s_prg_conf.appeal_ind is N
  DECLARE
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	CURSOR c_sprgc IS
  		SELECT	sprgc.appeal_ind
  		FROM	IGS_PR_S_PRG_CONF 		sprgc
  		WHERE	sprgc.s_control_num 	= 1;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_sprgc;
  	FETCH c_sprgc INTO v_appeal_ind;
  	IF c_sprgc%FOUND THEN
  		CLOSE c_sprgc;
  		IF v_appeal_ind = 'N' AND
  				p_appeal_ind = 'Y' THEN
  			p_message_name := 'IGS_PR_CANT_SET_APPEAL_IND';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_sprgc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sprgc%ISOPEN THEN
  			CLOSE c_sprgc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPC.PRGP_VAL_APPEAL_IND');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_appeal_ind;
  --
  -- Validate the {s_ou_conf,s_crv_conf}.show_cause_ind.
  FUNCTION prgp_val_cause_ind(
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_cause_ind
  	-- Validate the {s_ou_conf,s_crv_conf}.show_cause_ind, checking for:
  	-- * Cannot be set if parent s_prg_conf.show_cause_ind is N
  DECLARE
  	v_show_cause_ind		IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	CURSOR c_sprgc IS
  		SELECT	sprgc.show_cause_ind
  		FROM	IGS_PR_S_PRG_CONF 		sprgc
  		WHERE	sprgc.s_control_num 	= 1;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_sprgc;
  	FETCH c_sprgc INTO v_show_cause_ind;
  	IF c_sprgc%FOUND THEN
  		CLOSE c_sprgc;
  		IF v_show_cause_ind = 'N' AND
  				p_show_cause_ind = 'Y' THEN
  			p_message_name := 'IGS_PR_CANT_SET_SHOW_CAUS_IND';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_sprgc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sprgc%ISOPEN THEN
  			CLOSE c_sprgc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPC.PRGP_VAL_CAUSE_IND');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_cause_ind;
  --
  --
  -- Validate that the IGS_OR_UNIT is active.
  FUNCTION prgp_val_ou_active(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_ou_active
  	-- Validate that the IGS_OR_UNIT is active.
  DECLARE
  	cst_active	CONSTANT	VARCHAR2(10) := 'ACTIVE';
  	v_s_org_status			IGS_OR_STATUS.s_org_status%TYPE;
  	CURSOR c_os_ou IS
  		SELECT	os.s_org_status
  		FROM	IGS_OR_UNIT			 ou,
  			IGS_OR_STATUS		 os
  		WHERE	ou.org_unit_cd		= p_org_unit_cd AND
  			ou.start_dt 		= p_start_dt AND
  			os.org_status		= ou.org_status;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_org_unit_cd IS NULL OR
  			p_start_dt IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_os_ou;
  	FETCH c_os_ou INTO v_s_org_status;
  	IF c_os_ou%FOUND THEN
  		CLOSE c_os_ou;
  		If v_s_org_status <> cst_active THEN
  			p_message_name := 'IGS_PR_ORG_UNIT_MUST_BE_ACTIV';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_os_ou;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_os_ou%ISOPEN THEN
  			CLOSE c_os_ou;
  		END IF;
  		RAISE;
  END;
  END prgp_val_ou_active;
END IGS_PR_VAL_SOPC;

/
