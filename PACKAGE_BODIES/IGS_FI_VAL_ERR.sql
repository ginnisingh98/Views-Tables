--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_ERR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_ERR" AS
/* $Header: IGSFI21B.pls 115.3 2002/11/29 00:19:01 nsidana ship $ */
  --
  -- Ensure elements range rate can be created.
  FUNCTION finp_val_err_create(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_err_create
  	-- Validate that the IGS_FI_ELM_RANGE_RT record can be created.
  	-- Unable to be created if the IGS_FI_ELM_RANGE or IGS_FI_FEE_AS_RATE
  	-- records it is based on, are logically deleted.
  DECLARE
  	CURSOR c_er IS
  		SELECT	'x'
   		FROM	IGS_FI_ELM_RANGE er
  		WHERE 	er.fee_type 			= p_fee_type 	AND
  		 	er.fee_cal_type 		= p_fee_cal_type 		AND
   			er.fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  		 	er.s_relation_type 		= p_s_relation_type 	AND
  		 	NVL(er.fee_cat, 'NULL') 	= NVL(p_fee_cat, 'NULL') 	AND
  		 	er.range_number 		= p_range_number 		AND
   			er.logical_delete_dt 		IS NOT NULL;
  	CURSOR c_far IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_AS_RATE far
  		WHERE	far.fee_type 			= p_fee_type 			AND
  			far.fee_cal_type 		= p_fee_cal_type 		AND
  			far.fee_ci_sequence_number 	= p_fee_ci_sequence_number 	AND
  			far.s_relation_type 		= p_s_relation_type 		AND
  			NVL(far.fee_cat, 'NULL') 	= NVL(p_fee_cat, 'NULL') 	AND
  			far.rate_number 		= p_rate_number 		AND
  			far.logical_delete_dt 		IS NOT NULL;
  	v_far_exists		VARCHAR2(1);
  	v_er_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- 1. Check parameters :
  	IF p_fee_type IS NULL OR
  			p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_s_relation_type IS NULL OR
  			p_range_number IS NULL OR
  			p_rate_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Check that the parent IGS_FI_ELM_RANGE record is not logically deleted
  	OPEN c_er;
  	FETCH c_er INTO v_er_exists;
  	IF c_er%FOUND THEN
  		CLOSE c_er;
  		p_message_name := 'IGS_FI_ELERNG_RATE_NOTCREATED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_er;
  	-- 3. Check that the parent IGS_FI_FEE_AS_RATE record is not logically deleted
  	OPEN c_far;
  	FETCH c_far INTO v_far_exists;
  	IF c_far%FOUND THEN
  		CLOSE c_far;
  		p_message_name := 'IGS_FI_ELERNG_RATE_FEEASS_RAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_far;
  	-- 4. Return no error
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_er%ISOPEN THEN
  			CLOSE c_er;
  		END IF;
  		IF c_far%ISOPEN THEN
  			CLOSE c_far;
  		END IF;
  		RAISE;
  END;
  END finp_val_err_create;
  --
  -- Ensure only one elements range rate is active.
  FUNCTION finp_val_err_active(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_err_active
  	-- Validate that there are no other "open-ended" element_range_rate records
  	-- for the nominated IGS_FI_ELM_RANGE record
  DECLARE
  	v_err_exists	CHAR;
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  	CURSOR	c_err IS
  		SELECT	'x'
  		FROM	IGS_FI_ELM_RANGE_RT	err
  		WHERE	err.fee_type		= p_fee_type		AND
  			err.fee_cal_type	= p_fee_cal_type	AND
  			err.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			err.s_relation_type	= p_s_relation_type	AND
  			NVL(err.fee_cat, 'NULL')= NVL(p_fee_cat, 'NULL')AND
  			err.range_number	= p_range_number	AND
  			err.rate_number = p_rate_number AND
  			err.create_dt 		<> p_create_dt		AND
  			err.logical_delete_dt	IS NULL;
  BEGIN
  	p_message_name := Null;
  	-- Check parameters.
  	IF (	p_fee_type			IS NULL	OR
  		p_fee_cal_type			IS NULL	OR
  		p_fee_ci_sequence_number	IS NULL	OR
  		p_range_number			IS NULL	OR
  		p_rate_number			IS NULL    OR
  		p_s_relation_type			IS NULL	OR
  		p_create_dt			IS NULL)	THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_err;
  	FETCH c_err INTO v_err_exists;
  	IF (c_err%FOUND) THEN
  		p_message_name := 'IGS_FI_ELERNG_RATE_ACTIVE';
  		v_ret_val := FALSE;
  	END IF;
  	CLOSE c_err;
  	RETURN v_ret_val;
  END;
  END finp_val_err_active;
  --
  -- Ensure elements range rate can be created.
  FUNCTION finp_val_err_ins(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_err_ins
  	-- validate IGS_FI_ELM_RANGE_RT records can only be matched to a IGS_FI_FEE_AS_RATE
  	-- defined at
  	-- the same level as the IGS_FI_ELM_RANGE on which it is based
  DECLARE
  	CURSOR c_far IS
  		SELECT	far.rate_number
  		FROM	IGS_FI_FEE_AS_RATE far
  		WHERE	far.fee_type 	 	= p_fee_type AND
  			far.fee_cal_type 	= p_fee_cal_type AND
  			far.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			far.s_relation_type 	= p_s_relation_type AND
  			far.rate_number 	= p_rate_number AND
  			far.logical_delete_dt 	IS NULL;
  	v_rate_number	IGS_FI_ELM_RANGE_RT.rate_number%TYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	IF 	p_fee_type 		IS NULL OR
  		p_fee_cal_type 		IS NULL OR
  		p_fee_ci_sequence_number 	IS NULL OR
  		p_s_relation_type 		IS NULL OR
  		p_rate_number 		IS NULL 		THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_far;
  	FETCH c_far INTO v_rate_number;
  	IF (c_far%NOTFOUND) THEN
  		p_message_name := 'IGS_FI_FEEASSRATE_NOT_DENF';
  		CLOSE c_far;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_far;
  	RETURN TRUE;
  END;
  END finp_val_err_ins;
END IGS_FI_VAL_ERR;

/
