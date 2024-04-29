--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SPCA" AS
/* $Header: IGSPR14B.pls 115.4 2002/11/29 02:47:24 nsidana ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function prgp_val_cfg_cat removed
  -------------------------------------------------------------------------------------------
  -- Validate the appeal length field.
  FUNCTION prgp_val_spca_appeal(
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_spca_appeal
  	-- Validate the appeal length field checking for,
  	-- * Cannot be set if s_prg_conf.appeal_ind is N
  	-- * Warn if not set if s_prg_conf.appeal_ind is Y
  DECLARE
  	v_appeal_ind		IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
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
  		IF v_appeal_ind = 'Y' AND
  				p_appeal_length IS NULL THEN
  			p_message_name := 'IGS_PR_SET_APPEAL_LEN';
  			RETURN TRUE;
  		END IF;
  		IF v_appeal_ind = 'N' AND
  				p_appeal_length IS NOT NULL THEN
  			p_message_name := 'IGS_PR_CANT_SET_APPEAL_LEN';
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
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SPCA.PRGP_VAL_SPCA_APPEAL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_spca_appeal;
  --
  -- Validate the show cause length field.
  FUNCTION prgp_val_spca_cause(
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_spca_cause
  	-- Validate the show cause length field checking for,
  	-- * Cannot be set if s_prg_conf.show_cause_ind is N
  	-- * Warn if not set if s_prg_conf.show_cause_ind is Y
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
  		IF v_show_cause_ind = 'Y' AND
  				p_show_cause_length IS NULL THEN
  			p_message_name := 'IGS_PR_SET_SHOW_CAUSE_LEN';
  			RETURN TRUE;
  		END IF;
  		IF v_show_cause_ind = 'N' AND
  				p_show_cause_length IS NOT NULL THEN
  			p_message_name := 'IGS_PR_CANT_SET_SHOW_CAUS_LEN';
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
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SPCA.PRGP_VAL_SPCA_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_spca_cause;
END IGS_PR_VAL_SPCA;

/
