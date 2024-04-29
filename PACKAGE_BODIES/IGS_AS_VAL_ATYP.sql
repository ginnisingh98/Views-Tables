--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_ATYP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_ATYP" AS
/* $Header: IGSAS15B.pls 115.4 2002/11/28 22:43:10 nsidana ship $ */
  --
  -- Validate system assessment type closed indicator
  FUNCTION assp_val_sat_closed(
  p_s_assessment_type IN IGS_AS_SASSESS_TYPE.s_assessment_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN 	-- assp_val_sat_closed
  	-- Validate the System Assessment Type closed indicator
  DECLARE
  	CURSOR c_sat(
  			cp_s_assessment_type		IGS_AS_SASSESS_TYPE.s_assessment_type%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AS_SASSESS_TYPE
  		WHERE	s_assessment_type = cp_s_assessment_type ;
  	v_sat_rec			c_sat%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Cursor handling
  	OPEN c_sat(
  			p_s_assessment_type);
  	FETCH c_sat INTO v_sat_rec;
  	IF c_sat%NOTFOUND THEN
  		CLOSE c_sat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sat;
  	IF (v_sat_rec.closed_ind = cst_yes) THEN
  		P_MESSAGE_NAME := 'IGS_AS_SYSASSTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_015.assp_val_sat_closed');
	IGS_GE_MSG_STACK.ADD;
	--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_sat_closed;
  --
  -- Validate assessment items exist for assessment type
  FUNCTION assp_val_ai_exist2(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.assessment_type%TYPE ,
  P_MESSAGE_NAME OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  BEGIN	-- assp_val_ai_exist2
  	-- Validate assessment items exist for a particular assessment type.
  DECLARE
  	CURSOR c_ai IS
  		SELECT	'x'
  		FROM	IGS_AS_ASSESSMNT_ITM	ai
  		WHERE	assessment_type = p_assessment_type;
  	v_ai_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	P_MESSAGE_NAME := NULL;
  	-- Validate that an assessment_item records for the given assessment type
  	-- does not exist
  	OPEN c_ai;
  	FETCH c_ai INTO v_ai_exists;
  	IF c_ai%NOTFOUND THEN
  		CLOSE c_ai;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ai;
  	P_MESSAGE_NAME := 'IGS_AS_EXAMIND_NOT_CHG';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ai%ISOPEN THEN
  			CLOSE c_ai;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_015.assp_val_ai_exist2');
	IGS_GE_MSG_STACK.ADD;
--APP_EXCEPTION.RAISE_EXCEPTION;
  END assp_val_ai_exist2;
END IGS_AS_VAL_ATYP;

/
