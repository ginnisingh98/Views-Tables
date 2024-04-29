--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_CFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_CFT" AS
/* $Header: IGSFI13B.pls 115.6 2002/11/29 00:17:27 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------
  --
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed enrp_val_att_closed
  --

  -- Ensure IGS_PS_COURSE fee triggers can be created.
  FUNCTION finp_val_cft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_cft_ins
  	-- Validate IGS_PS_FEE_TRG.IGS_FI_FEE_TYPE.s_fee_trigger_cat = IGS_PS_COURSE or COMPOSITE
  	-- otherwise IGS_PS_COURSE fee triggers cannot be defined.
  DECLARE
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE) IS
  		SELECT	s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	fee_type= cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  	cst_course		CONSTANT VARCHAR2(10) := 'COURSE';
  	cst_composite		CONSTANT VARCHAR2(10) := 'COMPOSITE';
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
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
  	IF v_ft_rec.s_fee_trigger_cat <> cst_course AND
  		v_ft_rec.s_fee_trigger_cat <> cst_composite THEN
  		p_message_name := 'IGS_FI_PRGFEETRG_COURSE_COMPO';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_cft_ins;

-- Ensure only one open IGS_PS_FEE_TRG record exists.
  FUNCTION finp_val_cft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_fee_trigger_group_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_cft_open
  	-- Validate that there are no other "open-ended" IGS_PS_FEE_TRG records for
  	-- the nominated course_cd details and the same parent IGS_FI_F_CAT_FEE_LBL.
  DECLARE
  	CURSOR c_cft IS
  		SELECT	'x'
  		FROM	IGS_PS_FEE_TRG cft
  		WHERE	cft.fee_cat			= p_fee_cat AND
  			cft.fee_cal_type 		= p_fee_cal_type AND
  			cft.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			cft.fee_type				= p_fee_type AND
  			cft.course_cd			= p_course_cd AND
  			cft.sequence_number		<> NVL(p_sequence_number,0) AND
  			NVL(cft.version_number,0)	= NVL(p_version_number,0) AND
  			NVL(cft.cal_type,'NULL')	= NVL(p_cal_type,'NULL') AND
  			NVL(cft.location_cd,'NULL')	= NVL(p_location_cd,'NULL') AND
  			NVL(cft.attendance_mode,'NULL') = NVL(p_attendance_mode,'NULL') AND
  			NVL(cft.attendance_type,'NULL') = NVL(p_attendance_type,'NULL') AND
  			cft.create_dt			<> p_create_dt AND
  			NVL(cft.fee_trigger_group_number,0) = NVL(p_fee_trigger_group_number,0) AND
  			cft.logical_delete_dt IS NULL;
  	v_check 	CHAR;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	IF p_fee_cat IS NULL OR
  			p_fee_cal_type 		 IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type 		 IS NULL OR
  			p_course_cd 		 IS NULL OR
  			p_create_dt 		 IS NULL 	THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_cft;
  	FETCH c_cft INTO v_check;
  	IF (c_cft%FOUND) THEN
  		CLOSE c_cft;
  		p_message_name := 'IGS_GE_DUPLICATE_VALUE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cft;
  	RETURN TRUE;
  END;
  END finp_val_cft_open;
  --
  --
  -- Validate IGS_PS_COURSE code has an 'ACTIVE' or 'PLANNED' version.
  FUNCTION finp_val_cft_crs(
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_cft_crs
  	-- Validate IGS_PS_FEE_TRG.course_cd.  Course code must have at least one
  	-- version which has a status of 'ACTIVE' or 'PLANNED'
  DECLARE
  	cst_planned 		CONSTANT VARCHAR2(10) := 'PLANNED';
  	cst_active 		CONSTANT VARCHAR2(10) := 'ACTIVE';
  	v_dummy			VARCHAR2(1);
  	CURSOR c_course_version_status (
  			cp_course_cd	IGS_PS_FEE_TRG.course_cd%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_VER crv,
  			IGS_PS_STAT cs
  		WHERE	crv.course_cd = cp_course_cd AND
  			crv.course_status = cs.course_status AND
  			cs.s_course_status IN (cst_active, cst_planned);
  BEGIN
  	p_message_name := Null;
  	IF(p_course_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN	c_course_version_status(
  				p_course_cd);
  	FETCH	c_course_version_status INTO v_dummy;
  	IF(c_course_version_status%NOTFOUND) THEN
  		CLOSE c_course_version_status;
  		p_message_name := 'IGS_FI_PRGCD_PLANNED_ACTIVE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_course_version_status;
  	RETURN TRUE;
  END;
  END finp_val_cft_crs;
  --
  -- Validate calendar type has a system category of 'ACADEMIC'.
  FUNCTION finp_val_ct_academic(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_ct_academic
  	-- Validates that the IGS_PS_FEE_TRG.IGS_CA_TYPE has a system calendar
  	-- category of 'ACADEMIC'
  DECLARE
  	cst_academic 		CONSTANT VARCHAR2(10) := 'ACADEMIC';
  	v_dummy			VARCHAR2(1);
  	CURSOR c_cal_type (
  			cp_cal_type	IGS_CA_TYPE.cal_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CA_TYPE cat
  		WHERE	cat.cal_type	= cp_cal_type AND
  			cat.s_cal_cat	= cst_academic;
  BEGIN
  	p_message_name := Null;
  	IF(p_cal_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN	c_cal_type(
  			p_cal_type);
  	FETCH	c_cal_type INTO v_dummy;
  	IF(c_cal_type%NOTFOUND) THEN
  		CLOSE c_cal_type;
  		p_message_name := 'IGS_FI_CALTYPE_CAT_ACADEMIC';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cal_type;
  	RETURN TRUE;
  END;
  END finp_val_ct_academic;

  --
  -- Validate the Calendar Type closed ind
  FUNCTION calp_val_cat_closed(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR c_cat IS
  		SELECT	closed_ind
  		FROM	IGS_CA_TYPE
  		WHERE  cal_type  = p_cal_type;
  	v_cat_rec			c_cat%ROWTYPE;
  BEGIN
  	-- Check if the IGS_CA_TYPE is closed
  	-- Set the default message number
  	p_message_name := Null;
  	-- Cursor handling
  	OPEN c_cat  ;
  	FETCH c_cat INTO v_cat_rec;
  	IF c_cat%NOTFOUND THEN
  		CLOSE c_cat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cat;
  	IF (v_cat_rec.closed_ind = 'Y') THEN
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END calp_val_cat_closed;
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed enrp_val_att_closed
  --
  -- Validate IGS_PS_COURSE fee trigger can belong to a fee trigger group.
  FUNCTION finp_val_cft_ftg(
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_num IN NUMBER ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE,
  p_fee_trigger_group_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_cft_ftg
  	-- Validate IGS_PS_FEE_TRG can belong to a IGS_FI_FEE_TRG_GRP
  DECLARE
  	v_dummy			VARCHAR2(1);
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.fee_type%TYPE)IS
            SELECT	s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE
  		WHERE  fee_type= cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  	cst_composite		CONSTANT VARCHAR2(10) := 'COMPOSITE';
  	CURSOR c_cft(	cp_fee_cat		IGS_PS_FEE_TRG.fee_cat%TYPE,
  			cp_fee_cal_type		IGS_PS_FEE_TRG.fee_cal_type%TYPE,
  			cp_fee_ci_sequence_num	IGS_PS_FEE_TRG.fee_ci_sequence_number%TYPE,
  			cp_fee_type		IGS_PS_FEE_TRG.fee_type%TYPE,
  			cp_course_cd		IGS_PS_FEE_TRG.course_cd%TYPE,
  			cp_fee_trigger_group_num
  					IGS_PS_FEE_TRG.fee_trigger_group_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_FEE_TRG cft
  		WHERE	cft.fee_cat= cp_fee_cat AND
  			cft.fee_cal_type = cp_fee_cal_type AND
  			cft.fee_ci_sequence_number = cp_fee_ci_sequence_num AND
  			cft.fee_type = cp_fee_type AND
  			cft.course_cd <> cp_course_cd AND
  			cft.fee_trigger_group_number = cp_fee_trigger_group_num AND
  			cft.logical_delete_dt IS NULL;
  BEGIN
  	p_message_name := Null;
  	IF(p_fee_cat IS NULL  OR
  		p_fee_cal_type IS NULL OR
  		p_fee_ci_sequence_num IS NULL OR
  		p_fee_type IS NULL OR
  		p_course_cd IS NULL OR
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
  		p_message_name := 'IGS_FI_PRG_FEETRG_COMPOSITE';
  		RETURN FALSE;
  	END IF;
  	OPEN	c_cft(	p_fee_cat,
  			p_fee_cal_type,
  			p_fee_ci_sequence_num,
  			p_fee_type,
  			p_course_cd,
  			p_fee_trigger_group_num);
  	FETCH	c_cft INTO v_dummy;
  	IF(c_cft%FOUND) THEN
  		CLOSE c_cft;
  		p_message_name := 'IGS_FI_PRGFEE_TRG_FEE_TRG_GRP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cft;
  	RETURN TRUE;
  END;
  end FINP_VAL_CFT_FTG;
END IGS_FI_VAL_CFT;

/
