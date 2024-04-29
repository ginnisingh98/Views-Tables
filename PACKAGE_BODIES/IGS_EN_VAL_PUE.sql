--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PUE" AS
/* $Header: IGSEN58B.pls 115.5 2002/11/29 00:04:26 nsidana ship $ */
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --
  --
  -- Validate that person doesn't already have an open unit exclusion.
  FUNCTION enrp_val_pue_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_cd IN VARCHAR2 ,
  p_pue_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pue_open
  	-- Validate that there are no other "open ended" pue records
  	-- for the nominated encumbrance effect type
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_person_unit_exclusion IS
  		SELECT 'x'
  		FROM	IGS_PE_PERS_UNT_EXCL
  		WHERE
  			person_id		= p_person_id		AND
  			encumbrance_type	= p_encumbrance_type	AND
  			pen_start_dt		= p_pen_start_dt	AND
  			s_encmb_effect_type	= p_s_encmb_effect_type	AND
  			pee_start_dt		= p_pee_start_dt	AND
  			unit_cd			= p_unit_cd		AND
  			expiry_dt	IS NULL				AND
  			pue_start_dt		 <>  p_pue_start_dt;
  BEGIN
  	p_message_name := null;
  	OPEN c_person_unit_exclusion;
  	FETCH c_person_unit_exclusion INTO v_check;
  	IF (c_person_unit_exclusion%FOUND) THEN
  		p_message_name := 'IGS_EN_PRSN_UNIT_EXCLUSION';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_person_unit_exclusion;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUE.enrp_val_pue_open');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_pue_open;
  --
  -- Validate if person is enrolled in an exluded unit.
  FUNCTION enrp_val_pue_unit(
  p_person_id IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_pue_unit
  	-- validate whether or not a person is enrolled
  	-- in a specified unit within a specified course
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR	c_person_exist IS
  		SELECT	'x'
  		FROM	IGS_EN_SU_ATTEMPT
  		WHERE	person_id = p_person_id	AND
  			course_cd = p_course_cd	AND
  			unit_cd = p_unit_cd	AND
  			unit_attempt_status = 'ENROLLED';
  BEGIN
  	p_message_name := null;
  	-- validate input parameters
  	IF (p_person_id IS NULL OR
  			p_course_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the person is enrolled in the specified unit
  	OPEN c_person_exist;
  	FETCH c_person_exist INTO v_check;
  	IF (c_person_exist%FOUND) THEN
  		-- person is enrolled in the specified unit
  		CLOSE c_person_exist;
  		p_message_name := 'IGS_EN_PERS_ENRL_EXCL_UNIT';
  		RETURN FALSE;
  	END IF;
  	-- person is not enrolled in the specified unit
  	CLOSE c_person_exist;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUE.enrp_val_pue_unit');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_pue_unit;
  --
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dts
END IGS_EN_VAL_PUE;

/
