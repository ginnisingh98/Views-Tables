--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PUR" AS
/* $Header: IGSEN59B.pls 115.4 2002/11/29 00:04:47 nsidana ship $ */
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --
  --
  -- Validate that PERSON doesn't already have an open UNIT requirement.
  FUNCTION enrp_val_pur_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_cd IN VARCHAR2 ,
  p_pur_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pur_open
  	-- Validate that there are no other "open ended" pur records
  	-- for the nominated encumbrance effect type
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_person_unit_requirement IS
  		SELECT 'x'
  		FROM	IGS_PE_UNT_REQUIRMNT
  		WHERE
  			person_id		= p_person_id		AND
  			encumbrance_type	= p_encumbrance_type	AND
  			pen_start_dt		= p_pen_start_dt	AND
  			s_encmb_effect_type	= p_s_encmb_effect_type	AND
  			pee_start_dt		= p_pee_start_dt	AND
  			unit_cd			= p_unit_cd		AND
  			expiry_dt	IS NULL				AND
  			pur_start_dt		 <>  p_pur_start_dt;
  BEGIN
  	p_message_name := null;
  	OPEN c_person_unit_requirement;
  	FETCH c_person_unit_requirement INTO v_check;
  	IF (c_person_unit_requirement%FOUND) THEN
  		p_message_name := 'IGS_EN_PRSN_UNIT_REQUIREMENT';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_person_unit_requirement;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUR.enrp_val_pur_open');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_pur_open;

  --
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dts
END IGS_EN_VAL_PUR;

/
