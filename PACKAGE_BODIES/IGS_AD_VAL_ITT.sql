--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ITT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ITT" AS
/* $Header: IGSAD63B.pls 115.4 2003/06/14 02:07:54 knag ship $ */

  --
  -- Validate if system intake target type is closed.
  FUNCTION admp_val_sitt_closed(
  p_s_intake_target_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_sitt_closed
  	-- Validate if s_intake_target_type.s_intake_target_type is closed.
  DECLARE
  	v_closed_ind	IGS_LOOKUPS_VIEW.closed_ind%TYPE;
  	CURSOR	c_sitt IS
  		SELECT	closed_ind
  		FROM	IGS_LOOKUP_VALUES
  		WHERE	lookup_type = 'INTAKE_TARGET_TYPE'
                AND     lookup_code = p_s_intake_target_type;
  BEGIN
  	OPEN c_sitt;
  	FETCH c_sitt INTO v_closed_ind;
  	IF (c_sitt%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_sitt;
			p_message_name := 'IGS_AD_SYSINTAKE_TRGT_TYPECLS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_sitt;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sitt%ISOPEN) THEN
  			CLOSE c_sitt;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ITT.admp_val_sitt_closed');
  	     IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_sitt_closed;
  --
  -- Validate unique system values for intake target type.
  FUNCTION admp_val_sitt_uniq(
  p_intake_target_type IN VARCHAR2 ,
  p_s_intake_target_type IN VARCHAR2 ,
  p_s_amount_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_sitt_uniq
  	-- This module validates that the combination of s_intake_target_type and
  	-- s_amount_type is unique within intake_target_type with the exception of
  	-- records with a s_intake_target_type = 'USER-DEF'
  DECLARE
  	cst_user_def	CONSTANT	VARCHAR2(8) := 'USER-DEF';
  	v_dummy		VARCHAR2(1);
  	CURSOR	c_itt IS
  		SELECT	'x'
  		FROM	IGS_AD_INTAK_TRG_TYP itt
  		WHERE	itt.intake_target_type 	<> p_intake_target_type 	AND
  			itt.s_intake_target_type 	= p_s_intake_target_type 	AND
  			itt.s_amount_type 		= p_s_amount_type	AND
  			itt.closed_ind		= 'N';
  BEGIN
  	p_message_name := null;
  	IF p_s_intake_target_type = cst_user_def THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_itt;
  	FETCH c_itt INTO v_dummy;
  	IF c_itt%FOUND THEN
  		CLOSE c_itt;
		p_message_name := 'IGS_AD_STUD_INTAKE_TRGT_TYPE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_itt;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_itt%ISOPEN) THEN
  			CLOSE c_itt;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
  	     FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_ITT.admp_val_sitt_uniq');
  	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
  END admp_val_sitt_uniq;
  --

END IGS_AD_VAL_ITT;

/
