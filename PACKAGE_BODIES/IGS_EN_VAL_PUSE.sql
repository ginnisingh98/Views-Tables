--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PUSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PUSE" AS
/* $Header: IGSEN60B.pls 115.4 2002/11/29 00:05:09 nsidana ship $ */
  --
  -- bug id  :  1956374
  -- sjadhav, 28-aug-2001
  -- removed  FUNCTION enrp_val_encmb_dt
  -- removed  FUNCTION enrp_val_encmb_dts
  --
  --
  -- Validate if person is enrolled in an excluded unit set.
  FUNCTION enrp_val_puse_us(
  p_person_id IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_puse_us
  	-- validate whether or not a person is enrolled
  	-- in a specified unit set within a specified COURSE
  DECLARE
  	v_check		VARCHAR2(1);
  	CURSOR	c_person_exist IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_SETATMPT susa
  		WHERE	susa.person_id = p_person_id	AND
  			susa.course_cd = p_course_cd	AND
  			susa.unit_set_cd = p_unit_set_cd	AND
  			susa.us_version_number = p_us_version_number	AND
  			susa.student_confirmed_ind = 'Y'	AND
  			susa.end_dt IS NULL;
  BEGIN
  	p_message_name := null;
  	-- validate input parameters
  	IF (p_person_id IS NULL OR
  			p_course_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check if the person is enrolled in the specified unit set
  	OPEN c_person_exist;
  	FETCH c_person_exist INTO v_check;
  	IF (c_person_exist%FOUND) THEN
  		-- person is enrolled in the specified unit set
  		CLOSE c_person_exist;
  		p_message_name := 'IGS_EN_PRSN_CURR_ENROLLED';
  		RETURN FALSE;
  	END IF;
  	-- person is not enrolled in the specified unit set
  	CLOSE c_person_exist;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUSE.enrp_val_puse_us');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_puse_us;
  --
  -- Validate that person doesn't already have an open unit set exclusion.
  FUNCTION enrp_val_puse_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_puse_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_puse_open
  	-- Validate that there are no other "open ended" puse records
  	-- for the nominated encumbrance effect type
  DECLARE
  	v_check		VARCHAR2(1);
  	v_ret_val	BOOLEAN DEFAULT TRUE;
  	CURSOR c_person_unit_set_exclusion IS
  		SELECT 'x'
  		FROM	IGS_PE_UNT_SET_EXCL
  		WHERE
  			person_id		= p_person_id	AND
  			encumbrance_type	= p_encumbrance_type	AND
  			pen_start_dt		= p_pen_start_dt	AND
  			s_encmb_effect_type	= p_s_encmb_effect_type	AND
  			pee_start_dt		= p_pee_start_dt	AND
  			unit_set_cd		= p_unit_set_cd	AND
  			us_version_number	= p_us_version_number	AND
  			expiry_dt	IS NULL				AND
  			puse_start_dt		 <>  p_puse_start_dt;
  BEGIN
  	p_message_name := null;
  	OPEN c_person_unit_set_exclusion;
  	FETCH c_person_unit_set_exclusion INTO v_check;
  	IF (c_person_unit_set_exclusion%FOUND) THEN
  		p_message_name := 'IGS_EN_PRSN_UNIT_SET_EXCLUSIO';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_person_unit_set_exclusion;
  	RETURN v_ret_val;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUSE.enrp_val_puse_open');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_puse_open;
  --
  -- Validate unit set exists
  FUNCTION crsp_val_us_exists(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- crsp_val_us_exists
  	-- This module validates the unit set exists.
  DECLARE
  	v_unit_set_cd			IGS_EN_UNIT_SET.unit_set_cd%TYPE;
  	CURSOR c_us IS
  		SELECT	us.unit_set_cd
  		FROM	IGS_EN_UNIT_SET us
  		WHERE	us.unit_set_cd    = p_unit_set_cd AND
  			us.version_number = p_version_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_us;
  	FETCH c_us INTO v_unit_set_cd;
  	IF (c_us%NOTFOUND) THEN
  		CLOSE c_us;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_us;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_us%NOTFOUND) THEN
  			CLOSE c_us;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_PUSE.crsp_val_us_exists');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END crsp_val_us_exists;

  --
  -- bug id : 1956374
  -- removed FUNCTION enrp_val_encmb_dt
  --
  -- removed FUNCTION enrp_val_encmb_dts
  --
END IGS_EN_VAL_PUSE;

/
