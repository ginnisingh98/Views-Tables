--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FC" AS
/* $Header: IGSFI24B.pls 115.7 2002/11/29 11:13:48 vvutukur ship $ */
  --
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        29-Nov-2002  Enh#2584986.Obsoleted finp_val_fc_cur_upd.
  ||  vvutukur        26-Aug-2002  Bug#2531390.Modified function finp_val_fc_cur_upd.Removed DEFAULT clause
  ||                               in this package body to avoid gscc warning.
  ----------------------------------------------------------------------------*/
  /* Removed reference to IGS_FI_FEE_ENCMB_TYPE_V as part of bug 2126091 - sykrishn 29112001 */
  -- Validate update of fee category closed indicator.
  FUNCTION finp_val_fc_clsd_upd(
  p_fee_cat IN VARCHAR2 ,
  p_closed_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     02-Sep-2002     Bug#2531390.Removed DEFAULT clause to avoid gscc warning, and replaced
  ||                               with assignment operator for defaulting variable v_ret_val.
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_fc_clsd_upd
  	-- Validate update of the IGS_FI_FEE_CAT.closed_ind.
  DECLARE
  	v_check		CHAR;
  	v_ret_val	BOOLEAN	:= TRUE;
  	CURSOR c_fcm IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_CAT_MAP
  		WHERE	fee_cat  = p_fee_cat AND
  			dflt_cat_ind = 'Y';
  BEGIN
  	p_message_name := NULL;
  	IF (p_closed_ind = 'Y') THEN
  		-- Validate if the fee category is the default for an admission category.
  		OPEN c_fcm;
  		FETCH c_fcm INTO v_check;
  		IF (c_fcm%FOUND) THEN
  			p_message_name := 'IGS_FI_FEECAT_NC_DFLT_ADMCAT';
  			v_ret_val := FALSE;
  		END IF;
  		CLOSE c_fcm;
  	END IF;
  	RETURN v_ret_val;
  END;
  END finp_val_fc_clsd_upd;
  --
  -- Warn if IGS_FI_FEE_CAT.currency_cd change effects child records.
  FUNCTION finp_chk_rates_exist(
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_chk_rates_exist
  	-- Check if IGS_FI_F_CAT_FEE_LBL records exist for the IGS_FI_FEE_CAT,
  	-- which have associated IGS_FI_FEE_AS_RATE records.
  DECLARE
  	cst_fcfl		CONSTANT VARCHAR2(5) := 'FCFL';
  	CURSOR c_fcfl(
  			cp_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE)    IS
  		SELECT	fee_cal_type,
  			fee_ci_sequence_number,
  			FEE_TYPE
  		FROM	IGS_FI_F_CAT_FEE_LBL
  		WHERE	fee_cat = cp_fee_cat;
  	CURSOR c_far(
  			cp_fee_type		IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE,
  			cp_fee_cal_type		IGS_FI_F_CAT_FEE_LBL.fee_cal_type%TYPE,
  			cp_fee_ci_sequence_number	IGS_FI_F_CAT_FEE_LBL.fee_ci_sequence_number%TYPE,
  			cp_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE) IS
  		SELECT	rate_number
  		FROM	IGS_FI_FEE_AS_RATE
  		WHERE	fee_type= cp_fee_type AND
  			fee_cal_type = cp_fee_cal_type AND
  			fee_ci_sequence_number = cp_fee_ci_sequence_number AND
  			s_relation_type = cst_fcfl AND
  			fee_cat = cp_fee_cat;
  	CURSOR c_err(
  			cp_fee_type		IGS_FI_F_CAT_FEE_LBL.fee_type%TYPE,
  			cp_fee_cal_type		IGS_FI_F_CAT_FEE_LBL.fee_cal_type%TYPE,
  			cp_fee_ci_sequence_number	IGS_FI_F_CAT_FEE_LBL.fee_ci_sequence_number%TYPE,
  			cp_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE)IS
            SELECT range_number
  		FROM	IGS_FI_ELM_RANGE_RT
  		WHERE	FEE_TYPE = cp_fee_type AND
  			fee_cal_type = cp_fee_cal_type AND
  			fee_ci_sequence_number = cp_fee_ci_sequence_number AND
  			s_relation_type = cst_fcfl AND
  			fee_cat = cp_fee_cat AND
  			logical_delete_dt IS NULL;
  	v_err_rec		c_err%ROWTYPE;
  	v_far_rec		c_far%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check parameter
  	IF p_fee_cat IS NULL THEN
  		RETURN FALSE;
  	END IF;
  	-- Use a loop to find any IGS_FI_F_CAT_FEE_LBL records based on the IGS_FI_FEE_CAT.
  	FOR v_fcfl_rec IN c_fcfl(p_fee_cat) LOOP
  		-- Check if any associated IGS_FI_FEE_AS_RATE records exist for the
  		-- IGS_FI_F_CAT_FEE_LBL record. If so, return a warning.
  		OPEN c_far(
  			v_fcfl_rec.fee_type,
  			v_fcfl_rec.fee_cal_type,
  			v_fcfl_rec.fee_ci_sequence_number,
  			p_fee_cat);
  		FETCH c_far INTO v_far_rec;
  		IF c_far%NOTFOUND THEN
  			CLOSE c_far;
  		ELSE
  			CLOSE c_far;
  			p_message_name := 'IGS_FI_FEECATFEELIAB_EXIST';
  			RETURN TRUE;
  		END IF;
  		-- Check if any associated IGS_FI_ELM_RANGE_RT records exist for the
  		-- IGS_FI_F_CAT_FEE_LBL record. If so, return a warning.
  		OPEN c_err(
  			v_fcfl_rec.FEE_TYPE,
  			v_fcfl_rec.fee_cal_type,
  			v_fcfl_rec.fee_ci_sequence_number,
  			p_fee_cat);
  		FETCH c_err INTO v_err_rec;
  		IF c_err%NOTFOUND THEN
  			CLOSE c_err;
  		ELSE
  			CLOSE c_err;
  			p_message_name := 'IGS_FI_FEECATFEELIAB_EXIST';
  			RETURN TRUE;
  		END IF;
  	END LOOP;
  	-- Return the default value
  	RETURN FALSE;
  END;
  END finp_chk_rates_exist;
END IGS_FI_VAL_FC;

/
