--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SPRGC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SPRGC" AS
/* $Header: IGSPR15B.pls 115.4 2002/11/29 02:47:42 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_APPEAL_DA removed
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_CAUSE_DA removed
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function PRGP_VAL_DA_CLOSED removed
  -------------------------------------------------------------------------------------------
  -- Validate the appeal indicator being set
  FUNCTION prgp_val_sprgc_apl(
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_sprgc_apl
  	-- Validate if appeal indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set
  	-- OR s_ou_prg_conf records with appeal_ind set to Y
  	-- OR s_crv_prg_conf records with appeal_ind set to Y
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_spca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_PRG_CAL
  	WHERE	appeal_length IS NOT NULL;
  	CURSOR	c_sopc IS
  	SELECT	'X'
  	FROM	IGS_PR_S_OU_PRG_CONF
  	WHERE	appeal_ind = 'Y';
  	CURSOR	c_scpc IS
  	SELECT	'X'
  	FROM	IGS_PR_S_CRV_PRG_CON
  	WHERE	appeal_ind = 'Y';
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_appeal_ind = 'N' THEN
  		OPEN	c_spca;
  		FETCH	c_spca INTO v_dummy;
  		IF c_spca%FOUND THEN
  			p_message_name := 'IGS_PR_APPEAL_NOT_AVAILABLE';
  			CLOSE	c_spca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_spca;
  		OPEN	c_sopc;
  		FETCH	c_sopc INTO v_dummy;
  		IF c_sopc%FOUND THEN
  			p_message_name := 'IGS_PR_REL_ORG_UNIT_PRG_AVAIL';
  			CLOSE	c_sopc;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sopc;
  		OPEN	c_scpc;
  		FETCH	c_scpc INTO v_dummy;
  		IF c_scpc%FOUND THEN
  			p_message_name := 'IGS_PR_REL_COUR_VER_PRG_AVAIL';
  			CLOSE	c_scpc;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_scpc;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_spca%ISOPEN THEN
  			CLOSE c_spca;
  		END IF;
  		IF c_sopc%ISOPEN THEN
  			CLOSE c_sopc;
  		END IF;
  		IF c_scpc%ISOPEN THEN
  			CLOSE c_scpc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SPRGC.PRGP_VAL_SPRGC_APL');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sprgc_apl;
  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_sprgc_cause(
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_sprgc_cause
  	-- Validate if show cause indicator is set to 'N' that no related
  	-- progression calendars have appeal lengths set
  	-- OR s_ou_prg_conf records with show_cause_ind set to Y
  	-- OR s_crv_prg_conf records with show_cause_ind set to Y
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_spca IS
  	SELECT	'X'
  	FROM	IGS_PR_S_PRG_CAL
  	WHERE	show_cause_length IS NOT NULL;
  	CURSOR	c_sopc IS
  	SELECT	'X'
  	FROM	IGS_PR_S_OU_PRG_CONF
  	WHERE	show_cause_ind = 'Y';
  	CURSOR	c_scpc IS
  	SELECT	'X'
  	FROM	IGS_PR_S_CRV_PRG_CON
  	WHERE	show_cause_ind = 'Y';
  BEGIN
  	-- Set the default message name
  	p_message_name := Null;
  	IF p_show_cause_ind = 'N' THEN
  		OPEN	c_spca;
  		FETCH	c_spca INTO v_dummy;
  		IF c_spca%FOUND THEN
  			p_message_name := 'IGS_PR_SHOW_CAUSE_NOT_AVAILAB';
  			CLOSE	c_spca;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_spca;
  		OPEN	c_sopc;
  		FETCH	c_sopc INTO v_dummy;
  		IF c_sopc%FOUND THEN
  			p_message_name := 'IGS_PR_ORG_UNIT_PRG_CONFIG';
  			CLOSE	c_sopc;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_sopc;
  		OPEN	c_scpc;
  		FETCH	c_scpc INTO v_dummy;
  		IF c_scpc%FOUND THEN
  			p_message_name := 'IGS_PR_COURS_VER_PRG_CONFIG';
  			CLOSE	c_scpc;
  			RETURN FALSE;
  		END IF;
  		CLOSE	c_scpc;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_spca%ISOPEN THEN
  			CLOSE c_spca;
  		END IF;
  		IF c_sopc%ISOPEN THEN
  			CLOSE c_sopc;
  		END IF;
  		IF c_scpc%ISOPEN THEN
  			CLOSE c_scpc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
   	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_SPRGC.PRGP_VAL_SPRGC_CAUSE');
                IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END prgp_val_sprgc_cause;
END IGS_PR_VAL_SPRGC;

/
