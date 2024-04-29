--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FTG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FTG" AS
/* $Header: IGSFI35B.pls 115.3 2002/11/29 00:22:30 nsidana ship $ */
  --
  -- Ensure fee trigger group can be created.
  FUNCTION finp_val_ftg_ins(
  p_fee_type IN VARCHAR2 ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_ftg_ins
  	-- Validate IGS_FI_FEE_TRG_GRP IGS_FI_FEE_TYPE.s_fee_trigger_cat = COMPOSITE
  	-- otherwise fee trigger groups cannot be defined.
  DECLARE
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS
  		SELECT	s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	FEE_TYPE = cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  	cst_composite		CONSTANT VARCHAR2(10) := 'COMPOSITE';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Check parameters
  	IF p_fee_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system fee trigger category of the IGS_FI_FEE_TYPE.
  	OPEN c_ft (p_fee_type);
  	FETCH c_ft INTO v_ft_rec;
  	IF c_ft%NOTFOUND THEN
  		CLOSE c_ft;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ft;
  	IF v_ft_rec.s_fee_trigger_cat <> cst_composite THEN
  		p_message_name:= 'IGS_FI_FEETRG_GRPS_COMPOSITE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_ftg_ins;
  --
  -- Validate logical delete of the fee trigger group
  FUNCTION finp_val_ftg_lgl_del(
  p_fee_cat IN IGS_FI_FEE_TRG_GRP.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_FEE_TRG_GRP.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_FEE_TRG_GRP.FEE_TYPE%TYPE ,
  p_fee_trigger_group_num IN NUMBER ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_ftg_lgl_del
  	-- Validate that logical deletion of a IGS_FI_FEE_TRG_GRP record does
  	-- not orphan related IGS_PS_COURSE, IGS_PS_UNIT or IGS_PS_UNIT set fee triggers.
  DECLARE
  	CURSOR c_cft IS
  		SELECT	'x'
  		FROM	IGS_PS_FEE_TRG cft
  		WHERE	cft.FEE_CAT			= p_fee_cat AND
  			cft.fee_cal_type 		= p_fee_cal_type AND
  			cft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			cft.FEE_TYPE			= p_fee_type AND
  			NVL(cft.fee_trigger_group_number,0)	= p_fee_trigger_group_num AND
  			cft.logical_delete_dt IS NULL;
  	CURSOR c_uft IS
  		SELECT	'x'
  		FROM	IGS_FI_UNIT_FEE_TRG uft
  		WHERE	uft.FEE_CAT			= p_fee_cat AND
  			uft.fee_cal_type 		= p_fee_cal_type AND
  			uft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			uft.FEE_TYPE			= p_fee_type AND
  			NVL(uft.fee_trigger_group_number,0)	= p_fee_trigger_group_num AND
  			uft.logical_delete_dt IS NULL;
  	CURSOR c_usft IS
  		SELECT	'x'
  		FROM	IGS_EN_UNITSETFEETRG usft
  		WHERE	usft.FEE_CAT			= p_fee_cat AND
  			usft.fee_cal_type 		= p_fee_cal_type AND
  			usft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			usft.FEE_TYPE			= p_fee_type AND
  			NVL(usft.fee_trigger_group_number,0)	= p_fee_trigger_group_num AND
  			usft.logical_delete_dt IS NULL;
  	v_check 	CHAR;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	IF p_fee_cat IS NULL OR
  		p_fee_cal_type 		 IS NULL OR
  		p_fee_ci_sequence_number IS NULL OR
  		p_fee_type 		 IS NULL OR
  		p_fee_trigger_group_num	 IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_cft;
  	FETCH c_cft INTO v_check;
  	IF (c_cft%FOUND) THEN
  		CLOSE c_cft;
  		p_message_name:= 'IGS_FI_FEETRGGRP_PRG_FEETRG';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cft;
  	OPEN c_uft;
  	FETCH c_uft INTO v_check;
  	IF (c_uft%FOUND) THEN
  		CLOSE c_uft;
  		p_message_name:= 'IGS_FI_FEETRGGRP_UNT_FEETRG';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_uft;
  	OPEN c_usft;
  	FETCH c_usft INTO v_check;
  	IF (c_usft%FOUND) THEN
  		CLOSE c_usft;
  		p_message_name:= 'IGS_FI_FEETRGGRP_UNIT_SERTRG';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_usft;
  	RETURN TRUE;
  END;
  END finp_val_ftg_lgl_del;
END IGS_FI_VAL_FTG;

/
