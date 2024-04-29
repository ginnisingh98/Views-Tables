--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ETDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ETDE" AS
/* $Header: IGSEN38B.pls 115.7 2002/11/28 23:58:30 nsidana ship $ */
  --
  -- Validate the encumbrance type closed indicator.
  FUNCTION enrp_val_et_closed(
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		IGS_FI_ENCMB_TYPE.closed_ind%TYPE;
  	CURSOR c_encum_type_ind IS
  		SELECT 	closed_ind
  		FROM	IGS_FI_ENCMB_TYPE
  		WHERE	encumbrance_type = p_encumbrance_type;
  BEGIN
  	-- This module checks if the IGS_FI_ENCMB_TYPE
  	-- is closed
  	p_message_name := null;
  	OPEN  c_encum_type_ind;
  	FETCH c_encum_type_ind INTO v_closed_ind;
  	IF (c_encum_type_ind%NOTFOUND) THEN
  		CLOSE c_encum_type_ind;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_encum_type_ind;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_ENCUMB_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ETDE.enrp_val_et_closed');
		IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;

  END;
  END enrp_val_et_closed;
  --
  -- Validate the system encumbrance effect type closed indicator.
  FUNCTION enrp_val_seet_closed(
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
  DECLARE

  	v_closed_ind		IGS_EN_ENCMB_EFCTTYP_V.closed_ind%TYPE;
  	CURSOR c_s_encmb_type_ind IS
  		SELECT 	closed_ind
  		FROM	IGS_EN_ENCMB_EFCTTYP_V
  		WHERE	s_encmb_effect_type = p_s_encmb_effect_type;
  BEGIN
  	-- This module checks if the IGS_FI_ENCMB_TYPE
  	-- is closed
  	p_message_name := null;
  	OPEN  c_s_encmb_type_ind;
  	FETCH c_s_encmb_type_ind INTO v_closed_ind;
  	IF (c_s_encmb_type_ind%NOTFOUND) THEN
  		CLOSE c_s_encmb_type_ind;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_s_encmb_type_ind;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_EN_SYS_ENCUMB_EFTYPE_CLOS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ETDE.enrp_val_seet_closed');
		IGS_GE_MSG_STACK.ADD;
      	        App_Exception.Raise_Exception;


  END;
  END enrp_val_seet_closed;
    -- Validate the s_progression_outcome_type.
  FUNCTION enrp_val_et_pot(
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name1 OUT NOCOPY VARCHAR2 ,
  p_message_name2 OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- enrp_val_et_pot
  	-- Validate the s_progression_outcome_type for an encumbrance_type which
  	-- has been entered.
  DECLARE
  	v_message_name			fnd_new_messages.message_name%TYPE;
  	v_validation_failed			BOOLEAN DEFAULT FALSE;
  	CURSOR c_pot IS
  		SELECT	pot.s_progression_outcome_type
  		FROM	IGS_PR_OU_TYPE 	pot
  		WHERE	NVL(pot.encumbrance_type,' ')	= p_encumbrance_type;
  BEGIN
  	-- Set the default message names
  	p_message_name1 := NULL;
  	p_message_name2 := NULL;
  	FOR v_pot_rec IN c_pot LOOP
  		IF NOT IGS_PR_VAL_POT.prgp_val_pot_et (
  						v_pot_rec.s_progression_outcome_type,
  						p_encumbrance_type,
  						v_message_name) THEN
  			v_validation_failed := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_validation_failed THEN
  		p_message_name1 := 'IGS_PR_CHNG_CAUSED_ERR';
  		p_message_name2 := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ETDE.enrp_val_et_pot');
		IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
  		RAISE;
  END enrp_val_et_pot;
END IGS_EN_VAL_ETDE;

/
