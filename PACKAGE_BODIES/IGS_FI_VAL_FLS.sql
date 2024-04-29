--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FLS" AS
/* $Header: IGSFI30B.pls 115.6 2002/11/29 00:21:22 nsidana ship $ */
  /* bug 1956374
     Duplicate code removal Removed proc finp_val_fls_pps,finp_val_fss_closed1,finp_upd_pps_spnsr
     bug 2170429
     Removed functions finp_val_fls_scafs,finp_val_fls_status,finp_val_fls_status2,finp_val_fls_del along with pragmas
  */
  -- Validate the Fee Cat Fee Liability is active
  FUNCTION finp_val_fls_fcfl(
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_fls_fcfl
  	-- Validate if the IGS_FI_FEE_LBL_SPNSR is related to a
  	-- IGS_FI_F_CAT_FEE_LBL which is ACTIVE.
  DECLARE
  	cst_active	CONSTANT	VARCHAR2(6) := 'ACTIVE';
  	v_s_fee_structure_status	IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	CURSOR c_fss IS
  		SELECT	s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss,
  			IGS_FI_F_CAT_FEE_LBL	fcfl
  		WHERE	fcfl.fee_cat			= p_fee_cat		AND
  			fcfl.fee_cal_type		= p_fee_cal_type	AND
  			fcfl.fee_ci_sequence_number	= p_fee_ci_sequence_number AND
  			fcfl.fee_type			= p_fee_type		AND
  			fcfl.fee_liability_status	= fss.fee_structure_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check parameters
  	IF (
  		p_fee_cat IS NULL OR
  		p_fee_cal_type IS NULL OR
  		p_fee_ci_sequence_number IS NULL OR
  		p_fee_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.	Validation
  	OPEN c_fss;
  	FETCH c_fss INTO v_s_fee_structure_status;
  	IF c_fss%FOUND THEN
  		IF (v_s_fee_structure_status <> cst_active) THEN
  			CLOSE c_fss;
  			p_message_name := 'IGS_FI_FEECATFEE_LIAB_NOTACTI';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_fss;
  	RETURN TRUE;
  END;
  END finp_val_fls_fcfl;
  --

END IGS_FI_VAL_FLS;

/
