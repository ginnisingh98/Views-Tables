--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SCPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SCPCA" AS
/* $Header: IGSPR11B.pls 115.4 2002/11/29 02:46:24 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The exception part for crgp_val_cfg_cat removed

  -------------------------------------------------------------------------------------------
  -- Validate the calendar type.
  FUNCTION prgp_val_cfg_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_cfg_cat
  	-- Validate the calendar type used in the s_prg_cal, s_crv_prg_cal and
  	-- s_ou_prg_cal record:
  	-- * Must be a progression calendar
  	-- * Must be open
  DECLARE
  	cst_progress	CONSTANT	VARCHAR2(10) := 'PROGRESS';
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_closed_ind			IGS_CA_TYPE.closed_ind%TYPE;
  	CURSOR c_cat IS
  		SELECT	cat.s_cal_cat,
  			cat.closed_ind
  		FROM	IGS_CA_TYPE 		cat
  		WHERE	cat.cal_type	= p_cal_type;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_cat;
  	FETCH c_cat INTO
  			v_s_cal_cat,
  			v_closed_ind;
  	IF c_cat%FOUND THEN
  		CLOSE c_cat;
  		IF v_s_cal_cat <> cst_progress THEN
  			p_message_name := 'IGS_PR_PRG_CAL_TYPE_USED';
  			RETURN FALSE;
  		END IF;
  		IF v_closed_ind = 'Y' THEN
  			p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_cat;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cat%ISOPEN THEN
  			CLOSE c_cat;
  		END IF;
  		RAISE;
  END;

  END prgp_val_cfg_cat;
  --
  -- Validate the show cause period length of the s_crv_prg_cal record.
  FUNCTION prgp_val_scpca_cause(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_scpca_cause
  	-- Validate the show cause period length of the s_crv_prg_cal record,
  	-- checking for :
  	-- * Cannot be set if s_crv_prg_conf.show_cause_ind is N
  	-- * Warn if not set if s_crv_prg_conf.show_cause_ind is Y
  DECLARE
  	v_show_cause_ind		IGS_PR_S_CRV_PRG_CON.show_cause_ind%TYPE;
  	CURSOR c_scpc IS
  		SELECT	scpc.show_cause_ind
  		FROM	IGS_PR_S_CRV_PRG_CON 		scpc
  		WHERE	scpc.course_cd		= p_course_cd AND
  			scpc.version_number 	= p_version_number;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_scpc;
  	FETCH c_scpc INTO v_show_cause_ind;
  	IF c_scpc%FOUND THEN
  		CLOSE c_scpc;
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
  		CLOSE c_scpc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scpc%ISOPEN THEN
  			CLOSE c_scpc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPCA.PRGP_VAL_SCPCA_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_scpca_cause;
  --
  -- Validate the appeal period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_scpca_apl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_scpca_apl
  	-- Validate the appeal length of the s_crv_prg_cal record, checking for :
  	-- * Cannot be set if s_crv_prg_conf.appeal_ind is N
  	-- * Warn if not set if s_crv_prg_conf.appeal_ind is Y
  DECLARE
  	v_appeal_ind			IGS_PR_S_CRV_PRG_CON.appeal_ind%TYPE;
  	CURSOR c_scpc IS
  		SELECT	scpc.appeal_ind
  		FROM	IGS_PR_S_CRV_PRG_CON 		scpc
  		WHERE	scpc.course_cd		= p_course_cd AND
  			scpc.version_number 	= p_version_number;
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	OPEN c_scpc;
  	FETCH c_scpc INTO v_appeal_ind;
  	IF c_scpc%FOUND THEN
  		CLOSE c_scpc;
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
  		CLOSE c_scpc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_scpc%ISOPEN THEN
  			CLOSE c_scpc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SCPCA.PRGP_VAL_SCPCA_APL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_scpca_apl;
END IGS_PR_VAL_SCPCA;

/
