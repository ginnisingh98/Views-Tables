--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_UFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_UFT" AS
/* $Header: IGSFI42B.pls 115.8 2003/10/28 05:57:53 uudayapr ship $ */

   -- uudayapr 14-oct-2003
  -- AS part of the Enh#3117341 added cst_audit in function finp_val_uft_ins
  -- and also modified the If Condition to allow the Audit as a valid
  -- unit fee category.
  -- As part of the bug# 2690024 removed the function crsp_val_uv_sys_sts
  -- As part of the bug# 2690024 removed the function crsp_val_ucl_closed
  -- As part of the bug# 2690024 removed the function crsp_val_uv_active
  -- Ensure unit fee triggers can be created.
  FUNCTION finp_val_uft_ins(
  p_fee_type IN VARCHAR2 ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_uft_ins
  	-- Validate IGS_FI_UNIT_FEE_TRG.IGS_FI_FEE_TYPE.s_fee_trigger_cat = IGS_PS_UNIT or COMPOSITE
  	-- otherwise IGS_PS_UNIT fee triggers cannot be defined.
  DECLARE
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS
  		SELECT	s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	fee_type = cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  	cst_unit		CONSTANT VARCHAR2(10) := 'UNIT';
  	cst_composite		CONSTANT VARCHAR2(10) := 'COMPOSITE';
	--Enh#3117341 added this for checking for AUDIT System fee trigger category.
	cst_audit               CONSTANT VARCHAR2(10) := 'AUDIT';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Check parameters
  	IF p_fee_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system fee trigger category of the fee_type.
  	OPEN c_ft (p_fee_type);
  	FETCH c_ft INTO v_ft_rec;
  	IF c_ft%NOTFOUND THEN
  		CLOSE c_ft;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ft;
	--Enh# 3117341 Added 'AUDIT' also as a valid system fee trigger category for
	--creating the unit fee trigger category.
  	IF v_ft_rec.s_fee_trigger_cat <> cst_unit      AND
  	   v_ft_rec.s_fee_trigger_cat <> cst_composite AND
           v_ft_rec.s_fee_trigger_cat <> cst_audit
		THEN
  		p_message_name:= 'IGS_FI_UNIT_FEETRG_UNIT_COMPO';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_uft_ins;
  --
  -- Validate IGS_PS_UNIT fee trigger can belong to a fee trigger group.
  FUNCTION finp_val_uft_ftg(
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_trigger_group_num IN NUMBER ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_uft_ftg
  	-- Validate IGS_FI_UNIT_FEE_TRG can belong to a IGS_FI_FEE_TRG_GRP
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
  	-- Get the system fee trigger category of the fee_type.
  	OPEN c_ft (p_fee_type);
  	FETCH c_ft INTO v_ft_rec;
  	IF c_ft%NOTFOUND THEN
  		CLOSE c_ft;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ft;
  	IF v_ft_rec.s_fee_trigger_cat <> cst_composite THEN
  		p_message_name:= 'IGS_FI_UNIT_FEE_TRG_COMPOSITE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_uft_ftg;
  --
  -- Ensure only one open IGS_FI_UNIT_FEE_TRG record exists.
  FUNCTION finp_val_uft_open(
  p_fee_cat IN IGS_FI_UNIT_FEE_TRG.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_FI_UNIT_FEE_TRG.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_UNIT_FEE_TRG.fee_type%TYPE ,
  p_unit_cd IN IGS_FI_UNIT_FEE_TRG.unit_cd%TYPE ,
  p_sequence_number IN NUMBER ,
  p_version_number IN IGS_FI_UNIT_FEE_TRG.version_number%TYPE ,
  p_cal_type IN IGS_FI_UNIT_FEE_TRG.cal_type%TYPE ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_class IN IGS_FI_UNIT_FEE_TRG.unit_class%TYPE ,
  p_location_cd IN IGS_FI_UNIT_FEE_TRG.location_cd%TYPE ,
  p_create_dt IN IGS_FI_UNIT_FEE_TRG.create_dt%TYPE ,
  p_fee_trigger_group_number IN NUMBER ,
 p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_uft_open
  	-- Validate that there are no other "open" IGS_FI_UNIT_FEE_TRG records for
  	-- the nominated unit_cd details and the same parent IGS_FI_F_CAT_FEE_LBL.
  DECLARE
  	CURSOR c_uft IS
  		SELECT	'x'
  		FROM	IGS_FI_UNIT_FEE_TRG uft
  		WHERE	uft.fee_cat			= p_fee_cat AND
  			uft.fee_cal_type 		= p_fee_cal_type AND
  			uft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			uft.fee_type			= p_fee_type AND
  			uft.unit_cd			= p_unit_cd AND
  			uft.sequence_number		<> NVL(p_sequence_number,0) AND
  			NVL(uft.version_number,0)	= NVL(p_version_number,0) AND
  			NVL(uft.cal_type,'NULL')	= NVL(p_cal_type,'NULL') AND
  			NVL(uft.ci_sequence_number,0)	= NVL(p_ci_sequence_number,0) AND
  			NVL(uft.location_cd,'NULL')	= NVL(p_location_cd,'NULL') AND
  			NVL(uft.unit_class,'NULL') 	= NVL(p_unit_class,'NULL') AND
  			uft.create_dt			<> p_create_dt AND
  			NVL(uft.fee_trigger_group_number,0) = NVL(p_fee_trigger_group_number,0) AND
  			uft.logical_delete_dt IS NULL;
  	v_check 	CHAR;
  BEGIN
  	--- Set the default message number
  	p_message_name := null;
  	IF p_fee_cat IS NULL OR
  			p_fee_cal_type 		 IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type 		 IS NULL OR
  			p_unit_cd 		 IS NULL OR
  			p_create_dt 		 IS NULL 	THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_uft;
  	FETCH c_uft INTO v_check;
  	IF (c_uft%FOUND) THEN
  		CLOSE c_uft;
  		p_message_name:= 'IGS_GE_DUPLICATE_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_uft;
  	RETURN TRUE;
  END;
  END finp_val_uft_open;
  --
  -- Warn if no IGS_PS_UNIT offering option exists for the specified options.
  FUNCTION finp_val_uft_uoo(
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_uoo IS
  		SELECT	'X'
  		FROM	IGS_PS_UNIT_OFR_OPT	uoo
  		WHERE	uoo.unit_cd			= p_unit_cd AND
  			(p_cal_type  IS NULL OR
  			uoo.cal_type			= p_cal_type) AND
  			(p_ci_sequence_number IS NULL OR
  			(uoo.cal_type			= p_cal_type AND
  			uoo.ci_sequence_number		= p_ci_sequence_number)) AND
  			(p_location_cd  IS NULL OR
  			uoo.location_cd			= p_location_cd) AND
  			(p_unit_class  IS NULL OR
  			uoo.unit_class			= p_unit_class);
  BEGIN
  	-- 1. Check parameters
  	IF (p_unit_cd IS NULL) THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	-- 2. Check for IGS_PS_UNIT_OFR_OPT records for the unit_cd,
  	-- location_cd, unit_class and cal_type
  	OPEN c_uoo;
  	FETCH c_uoo INTO v_dummy;
  	IF (c_uoo%NOTFOUND) THEN
  		CLOSE c_uoo;
  		p_message_name:= 'IGS_FI_UOO_NOT_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_uoo;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uoo%ISOPEN) THEN
  			CLOSE c_uoo;
  		END IF;
  		RAISE;
  END;
  END finp_val_uft_uoo;

END igs_fi_val_uft;

/
