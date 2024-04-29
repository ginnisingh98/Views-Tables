--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_SIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_SIT" AS
/* $Header: IGSAD70B.pls 115.3 2002/11/28 21:39:46 nsidana ship $ */

  --
  -- Validate override amount type <> amount type
  FUNCTION admp_val_trgt_amttyp(
  p_s_amount_type IN VARCHAR2 ,
  p_overrride_s_amount_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_trgt_amttyp
  	-- Description: This module validates that an intake target override
  	-- amount type is not equal to the intake target type
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF p_overrride_s_amount_type IS NOT NULL THEN
  		IF p_s_amount_type = p_overrride_s_amount_type THEN
			p_message_name := 'IGS_AD_AMT_CANNOTBE_EQUAL';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SIT.admp_val_trgt_amttyp');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_trgt_amttyp;
  --
  -- Validate if intake target type is closed.
  FUNCTION admp_val_itt_closed(
  p_intake_target_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_itt_closed
  	-- Description: This module checks if an IGS_AD_INTAK_TRG_TYP is closed.
  DECLARE
  	v_itt_rec	IGS_AD_INTAK_TRG_TYP.intake_target_type%TYPE;
  	CURSOR	c_itt IS
  		SELECT	itt.closed_ind
  		FROM 	IGS_AD_INTAK_TRG_TYP	itt
  		WHERE	itt.intake_target_type 	= p_intake_target_type;
  BEGIN
  	p_message_name := null;
  	OPEN c_itt;
  	FETCH c_itt INTO v_itt_rec;
  	IF (c_itt%FOUND) THEN
  		IF (v_itt_rec = 'Y') THEN
  			CLOSE c_itt;
			p_message_name := 'IGS_AD_INTAKE_TRGTTYPE_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_itt;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SIT.admp_val_itt_closed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_itt_closed;
  --
  -- Validate target type amounts are in correct ranges.
  FUNCTION admp_val_trgt_amt(
  p_s_amount_type IN VARCHAR2 ,
  p_target IN NUMBER ,
  p_max_target IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_trgt_amt
  	-- Description: This module performs several validations between
  	-- the amount type and the values of the target and max target fields.
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF p_max_target IS NOT NULL THEN
  		IF p_s_amount_type = 'PERSON' AND
  			((MOD (p_target, 0.5) <> 0) OR
  	   				(MOD (p_max_target, 0.5) <> 0)) THEN
				p_message_name := 'IGS_AD_AMTTYPE_PRSN_INCR_0.5';
  				RETURN FALSE;
  		END IF;
  		IF p_s_amount_type = 'PERCENTAGE' AND
  			(p_target > 100 OR p_max_target > 100) THEN
				p_message_name := 'IGS_AD_AMTTYPE_PRC_TRGT_LE100';
  				RETURN FALSE;
  		END IF;
  		IF p_max_target <= p_target THEN
			p_message_name := 'IGS_AD_MAXIMUM_GT_TARGET';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF p_s_amount_type = 'PERSON' AND
  			MOD (p_target, 0.5) <> 0 THEN
		p_message_name := 'IGS_AD_AMTTYPE_PRSN_INCR_0.5';
  				RETURN FALSE;
  		END IF;
  		IF p_s_amount_type = 'PERCENTAGE' AND
  			p_target > 100 THEN
				p_message_name := 'IGS_AD_AMTTYPE_PRC_TRGT_LE100';
  				RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_SIT.admp_val_trgt_amt');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_trgt_amt;
END IGS_AD_VAL_SIT;

/
