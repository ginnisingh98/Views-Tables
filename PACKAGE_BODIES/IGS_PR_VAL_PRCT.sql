--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_PRCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_PRCT" AS
/* $Header: IGSPR05B.pls 115.4 2002/11/29 02:44:46 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function prgp_val_cfg_cat removed
  -------------------------------------------------------------------------------------------
  -- Validate the IGS_PR_RU_CA_TYPE start and end sequence_numbers.
  FUNCTION prgp_val_prct_ci(
  p_prg_cal_type IN VARCHAR2 ,
  p_start_sequence_number IN NUMBER ,
  p_end_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- prgp_val_prct_ci
  	-- Validate the IGS_PR_RU_CA_TYPE start_sequence_number and
  	-- end_sequence_number.  Validate the IGS_CA_INST identified by prg_cal_type
  	-- and end_sequence_number does NOT have a start_dt before the start_dt of
  	-- the IGS_CA_INST identified by prg_cal_type and start_sequence_number.
  DECLARE
  	v_dummy				VARCHAR2(1);
  	CURSOR c_start_ci IS
  		SELECT	'X'
  		FROM	IGS_CA_INST 		ci,
  			IGS_CA_STAT 		cs
  		WHERE	ci.cal_type		= p_prg_cal_type AND
  			ci.sequence_number 	= p_start_sequence_number AND
  			ci.cal_status		= cs.cal_status AND
  			cs.s_cal_status		= 'ACTIVE';
  	CURSOR c_end_ci IS
  		SELECT	'X'
  		FROM	IGS_CA_INST 		ci,
  			IGS_CA_STAT 		cs
  		WHERE	ci.cal_type			= p_prg_cal_type AND
  			ci.sequence_number 	= p_end_sequence_number AND
  			ci.cal_status		= cs.cal_status AND
  			cs.s_cal_status		= 'ACTIVE';
  	CURSOR c_ci IS
  		SELECT	'X'
  		FROM	IGS_CA_INST 		start_ci,
  			IGS_CA_INST 		end_ci
  		WHERE	start_ci.cal_type			= p_prg_cal_type AND
  			start_ci.sequence_number 	= p_start_sequence_number AND
  			end_ci.cal_type			= p_prg_cal_type AND
  			end_ci.sequence_number 		= p_end_sequence_number AND
  			end_ci.end_dt 			< start_ci.start_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Check the start cal instance is active
  	If p_start_sequence_number IS NOT NULL THEN
  		OPEN c_start_ci;
  		FETCH c_start_ci INTO v_dummy;
  		IF c_start_ci%NOTFOUND THEN
  			CLOSE c_start_ci;
  			p_message_name := 'IGS_PR_PER_CAL_MUST_BE_ACTIVE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_start_ci;
  	END IF;
  	-- Check the end cal instance is active
  	If p_end_sequence_number IS NOT NULL THEN
  		OPEN c_end_ci;
  		FETCH c_end_ci INTO v_dummy;
  		IF c_end_ci%NOTFOUND THEN
  			CLOSE c_end_ci;
  			p_message_name := 'IGS_PR_PER_CAL_MUST_BE_ACTIVE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_end_ci;
  	END IF;
  	-- Check the end cal instance is not before the start cal instance
  	If p_prg_cal_type IS NOT NULL AND
  	   p_start_sequence_number IS NOT NULL AND
  	   p_end_sequence_number IS NOT NULL THEN
  		OPEN c_ci;
  		FETCH c_ci INTO v_dummy;
  		IF c_ci%FOUND THEN
  			CLOSE c_ci;
  			p_message_name := 'IGS_PR_CHK_PRG_RUL_CAL_PER';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ci;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_start_ci%ISOPEN THEN
  			CLOSE c_ci;
  		END IF;
  		IF c_end_ci%ISOPEN THEN
  			CLOSE c_ci;
  		END IF;
  		IF c_ci%ISOPEN THEN
  			CLOSE c_ci;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_PRCT.PRGP_VAL_PRCT_CI');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_prct_ci;
  --
END IGS_PR_VAL_PRCT;

/
