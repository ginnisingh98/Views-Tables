--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SOPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SOPCA" AS
/* $Header: IGSPR13B.pls 115.4 2002/11/29 02:47:05 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function prgp_val_cfg_cat removed
  -------------------------------------------------------------------------------------------
  --
  --
  -- Validate the show cause period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_sopca_cause(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_sopca_cause
  	-- Validate the show cause period length of the s_ou_prg_cal record, checking
  	-- for :
  	-- * Cannot be set if s_ou_prg_conf.show_cause_ind is N
  	-- * Warn if not set if s_ou_prg_conf.show_cause_ind is Y
  DECLARE
  	v_show_cause_ind		IGS_PR_S_OU_PRG_CONF.show_cause_ind%TYPE;
  	CURSOR c_sopc IS
  		SELECT	sopc.show_cause_ind
  		FROM	IGS_PR_S_OU_PRG_CONF 		sopc
  		WHERE	sopc.org_unit_cd	= p_org_unit_cd AND
  			sopc.ou_start_dt	= p_ou_start_dt;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_sopc;
  	FETCH c_sopc INTO v_show_cause_ind;
  	IF c_sopc%FOUND THEN
  		CLOSE c_sopc;
  		IF v_show_cause_ind = 'Y' AND
  				p_show_cause_length IS NULL THEN
  			p_message_name := 'IGS_PR_SET_SHOW_CAUSE_LEN';
  			-- warning only
  			RETURN TRUE;
  		END IF;
  		IF v_show_cause_ind = 'N' AND
  				p_show_cause_length IS NOT NULL THEN
  			p_message_name := 'IGS_PR_CANT_SET_SHOW_CAUS_LEN';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_sopc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sopc%ISOPEN THEN
  			CLOSE c_sopc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPCA.PRGP_VAL_SOPCA_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sopca_cause;
  --
  -- Validate the appeal period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_sopca_apl(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_sopca_apl
  	-- Validate the appeal period length of the s_ou_prg_cal record, checking for:
  	-- * Cannot be set if s_ou_prg_conf.appeal_ind is N
  	-- * Warn if not set if s_ou_prg_conf.appeal_ind is Y
  DECLARE
  	v_appeal_ind			IGS_PR_S_OU_PRG_CONF.appeal_ind%TYPE;
  	CURSOR c_sopc IS
  		SELECT	sopc.appeal_ind
  		FROM	IGS_PR_S_OU_PRG_CONF 		sopc
  		WHERE	sopc.org_unit_cd		= p_org_unit_cd AND
  			sopc.ou_start_dt		= p_ou_start_dt;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_sopc;
  	FETCH c_sopc INTO v_appeal_ind;
  	IF c_sopc%FOUND THEN
  		CLOSE c_sopc;
  		IF v_appeal_ind = 'Y' AND
  				p_appeal_length IS NULL THEN
  			p_message_name := 'IGS_PR_SET_APPEAL_LEN';
  			-- warning only
  			RETURN TRUE;
  		END IF;
  		IF v_appeal_ind = 'N' AND
  				p_appeal_length IS NOT NULL THEN
  			p_message_name := 'IGS_PR_CANT_SET_APPEAL_LEN';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_sopc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sopc%ISOPEN THEN
  			CLOSE c_sopc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SOPCA.PRGP_VAL_SOPCA_APL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sopca_apl;
END IGS_PR_VAL_SOPCA;

/
