--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_USFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_USFT" AS
/* $Header: IGSEN72B.pls 115.4 2002/11/29 00:08:55 nsidana ship $ */
  --

  -- Ensure IGS_PS_UNIT set fee triggers can be created.

  FUNCTION finp_val_usft_ins(

  p_fee_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2)

  RETURN BOOLEAN AS



  BEGIN	-- finp_val_usft_ins

  	-- Validate IGS_EN_UNITSETFEETRG IGS_FI_FEE_TYPE.s_fee_trigger_cat = UNITSET or COMPOSITE

  	-- otherwise IGS_PS_UNIT set fee triggers cannot be defined.

  DECLARE

  	CURSOR c_ft(

  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS

  		SELECT	s_fee_trigger_cat

  		FROM	IGS_FI_FEE_TYPE

  		WHERE	fee_type = cp_fee_type;

  	v_ft_rec		c_ft%ROWTYPE;

  	cst_unitset		CONSTANT VARCHAR2(10) := 'UNITSET';

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

  	IF v_ft_rec.s_fee_trigger_cat <> cst_unitset AND

  		v_ft_rec.s_fee_trigger_cat <> cst_composite THEN

  		p_message_name := 'IGS_FI_UNIT_SET_FEETRG_UNIT';

  		RETURN FALSE;

  	END IF;

  	-- Return the default value

  	RETURN TRUE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN

 			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_USFT.finp_val_usft_ins');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END finp_val_usft_ins;

  --

  -- Validate IGS_PS_UNIT set fee trigger can belong to a fee trigger group.

  FUNCTION finp_val_usft_ftg(

  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,

  p_fee_trigger_group_num IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2)

  RETURN BOOLEAN AS

  	gv_other_detail			VARCHAR2(255);

  BEGIN 	-- finp_val_usft_ftg

  	-- Validate IGS_EN_UNITSETFEETRG can belong to a IGS_FI_FEE_TRG_GRP

  DECLARE

  	CURSOR c_ft(

  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS

  		SELECT	s_fee_trigger_cat

  		FROM	IGS_FI_FEE_TYPE

  		WHERE	fee_type = cp_fee_type;

  	v_ft_rec		c_ft%ROWTYPE;

  	cst_composite		CONSTANT VARCHAR2(10) := 'COMPOSITE';

  BEGIN

  	p_message_name := null;

  	IF(p_fee_type IS NULL OR

  		p_fee_trigger_group_num IS NULL) THEN

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

  		p_message_name := 'IGS_FI_UNITSET_FEETRG_COMPOSI';

  		RETURN FALSE;

  	END IF;

  	RETURN TRUE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN

			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_USFT.finp_val_usft_ftg');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END finp_val_usft_ftg;

  --

  -- Ensure only one open IGS_EN_UNITSETFEETRG record exists.

  FUNCTION finp_val_usft_open(

  p_fee_cat IN IGS_EN_UNITSETFEETRG.fee_cat%TYPE ,

  p_fee_cal_type IN IGS_EN_UNITSETFEETRG.fee_cal_type%TYPE ,

  p_fee_ci_sequence_number IN NUMBER ,

  p_fee_type IN IGS_EN_UNITSETFEETRG.fee_type%TYPE ,

  p_unit_set_cd IN IGS_EN_UNITSETFEETRG.unit_set_cd%TYPE ,

  p_version_number IN IGS_EN_UNITSETFEETRG.version_number%TYPE ,

  p_create_dt IN IGS_EN_UNITSETFEETRG.create_dt%TYPE ,

  p_fee_trigger_group_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2)

  RETURN BOOLEAN AS



  BEGIN	-- finp_val_usft_open

  	-- Validate that there are no other "open" IGS_EN_UNITSETFEETRG records for

  	-- the nominated unit_set_cd details and the same parent IGS_FI_F_CAT_FEE_LBL.

  DECLARE

  	CURSOR c_usft IS

  		SELECT	'x'

  		FROM	IGS_EN_UNITSETFEETRG usft

  		WHERE	usft.fee_cat			= p_fee_cat AND

  			usft.fee_cal_type 		= p_fee_cal_type AND

  			usft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND

  			usft.fee_type			= p_fee_type AND

  			usft.unit_set_cd		= p_unit_set_cd AND

  			NVL(usft.version_number,0)	= NVL(p_version_number,0) AND

  			usft.create_dt			<> p_create_dt AND

  			NVL(usft.fee_trigger_group_number,0) = NVL(p_fee_trigger_group_number,0) AND

  			usft.logical_delete_dt IS NULL;

  	v_check 	VARCHAR2(1);

  BEGIN

  	--- Set the default message number

  	p_message_name := null;

  	IF p_fee_cat IS NULL OR

  		p_fee_cal_type 		 IS NULL OR

  		p_fee_ci_sequence_number IS NULL OR

  		p_fee_type 		 IS NULL OR

  		p_unit_set_cd 		 IS NULL OR

  		p_version_number	 IS NULL OR

  		p_create_dt 		 IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_usft;

  	FETCH c_usft INTO v_check;

  	IF (c_usft%FOUND) THEN

  		CLOSE c_usft;

  		p_message_name := 'IGS_GE_DUPLICATE_VALUE';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_usft;

  	RETURN TRUE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN

 			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_USFT.finp_val_usft_open');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END finp_val_usft_open;

  --

  -- To validate the calendar instance system cal status is not 'INACTIVE'

  FUNCTION FINP_VAL_US_STATUS(

  p_unit_set_cd IN IGS_EN_UNIT_SET_ALL.unit_set_cd%TYPE ,

  p_version_number IN IGS_EN_UNIT_SET_ALL.version_number%TYPE ,

	p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean AS



  BEGIN	-- finp_val_us_status

  	-- Validate the  s_unit_set_status is NOT inactive.

  DECLARE

  	v_dummy			VARCHAR2(1);

  	CURSOR	c_us (	cp_unit_set_cd		IGS_EN_UNIT_SET.unit_set_cd%TYPE,

  			cp_version_number	IGS_EN_UNIT_SET.version_number%TYPE) IS

  		SELECT	'X'

  		FROM	IGS_EN_UNIT_SET		us,

  			IGS_EN_UNIT_SET_STAT	uss

  		WHERE	us.unit_set_cd		= p_unit_set_cd AND

  			us.version_number		= p_version_number AND

  			us.unit_set_status		= uss.unit_set_status AND

  			uss.s_unit_set_status	= 'INACTIVE';

  BEGIN

  	p_message_name := null;

  	IF p_unit_set_cd IS NULL OR

  	    p_version_number IS NULL THEN

  		RETURN TRUE;

  	END IF;

  	OPEN c_us (	p_unit_set_cd,

  			p_version_number);

  	FETCH c_us INTO v_dummy;

  	IF (c_us%FOUND) THEN

  		CLOSE c_us;

  		p_message_name := 'IGS_FI_UNITSET_INACTIVE';

  		RETURN FALSE;

  	END IF;

  	CLOSE c_us;

  	RETURN TRUE;

  END;

  EXCEPTION

  	WHEN OTHERS THEN

			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_VAL_USFT.finp_val_us_status');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END finp_val_us_status;



END IGS_EN_VAL_USFT;

/
