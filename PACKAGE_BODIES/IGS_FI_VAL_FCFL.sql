--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FCFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FCFL" AS
/* $Header: IGSFI26B.pls 115.10 2002/11/29 12:49:29 vvutukur ship $ */
  --who       when        what
  --vvutukur 29-Nov-2002  Enh#2584986.Modified finp_val_fcfl_cur.
  --vvutukur 26-Aug-2002  Bug#2531390. Modified function finp_val_fcfl_cur.
  --vvutukur 23-Jul-2002  Removed function finp_val_fcfl_rank which validates
  --                      payment_hierarchy_rank column, which is obsoleted.
  -- Removed reference to IGS_FI_FEE_ENCMB since the table is obselted as part of bug 2126091 - sykrishn -30112001 --
  -- Validate FCFL can be made ACTIVE.
  FUNCTION finp_val_fcfl_active(
  p_fee_liability_status IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- finp_val_fcfl_active
  	-- Validates that IGS_FI_F_CAT_FEE_LBL has a system calendar category of
  	-- 'FEE' and that the calendar instance is active when setting the
  	-- IGS_FI_F_CAT_FEE_LBL status to active.
  DECLARE
  	cst_active			CONSTANT VARCHAR2(6) := 'ACTIVE';
  	cst_fee				CONSTANT VARCHAR2(3) := 'FEE';
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status			IGS_CA_STAT.s_cal_status%TYPE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_fss (
  		cp_fee_liability_status	IGS_FI_F_CAT_FEE_LBL.fee_liability_status%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_STR_STAT		fss
  		WHERE	fss.fee_structure_status	= cp_fee_liability_status AND
  			fss.s_fee_structure_status	= cst_active;
  	CURSOR c_cict (
  			cp_cal_type 			IGS_CA_INST.cal_type%TYPE,
  			cp_sequence_number		IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	cat.s_cal_cat,
  			cs.s_cal_status
  		FROM	IGS_CA_INST			ci,
  			IGS_CA_STAT			cs,
  			IGS_CA_TYPE			cat
  		WHERE	ci.cal_type			= cp_cal_type AND
  			ci.sequence_number		= cp_sequence_number AND
  			ci.cal_type			= cat.cal_type AND
  			ci.cal_status			= cs.cal_status;
  BEGIN
  	p_message_name := NULL;
  	-- Check parameters
  	IF(p_fee_liability_status IS NULL OR
  			p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Check system value of status.
  	-- If not 'ACTIVE', no further processing is required.
  	OPEN	c_fss(
  			p_fee_liability_status);
  	FETCH	c_fss INTO v_dummy;
  	IF(c_fss%NOTFOUND) THEN
  		CLOSE c_fss;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_fss;
  	-- Check the calendar system category
  	OPEN	c_cict(
  			p_fee_cal_type,
  			p_fee_ci_sequence_number);
  	FETCH	c_cict INTO 	v_s_cal_cat,
  				v_s_cal_status;
  	CLOSE	c_cict;
  	IF(v_s_cal_cat <> cst_fee) THEN
  		p_message_name := 'IGS_FI_CAL_MUSTBE_CAT_AS_FEE';
  		RETURN FALSE;
  	END IF;
  	IF(v_s_cal_status <> cst_active) THEN
  		p_message_name := 'IGS_FI_CALINST_MUSTBE_ACTIVE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_fcfl_active;
  --
  -- Ensure fields are/are not allowable.
  FUNCTION finp_val_fcfl_rqrd(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_chg_method IN VARCHAR2 ,
  p_rule_sequence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_fee_type	IGS_FI_FEE_TYPE.fee_type%TYPE;
  	v_s_fee_trigger_cat	IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
  	v_s_chg_method_type	IGS_FI_F_TYP_CA_INST.s_chg_method_type%TYPE;
  	v_rul_sequence_number	IGS_FI_F_TYP_CA_INST.rul_sequence_number%TYPE;
  	cst_fee_trigger_cat	CONSTANT	VARCHAR2(9):= 'INSTITUTN';
  	cst_fee_type		CONSTANT	VARCHAR2(4):= 'HECS';
  	CURSOR c_ft IS
  		SELECT	ft.s_fee_type,
  			ft.s_fee_trigger_cat
  		FROM	IGS_FI_FEE_TYPE	ft
  		WHERE	ft.fee_type = p_fee_type;
  	CURSOR c_ftci IS
  		SELECT 	ftci.s_chg_method_type,
  			ftci.rul_sequence_number
  		FROM	IGS_FI_F_TYP_CA_INST	ftci
  		WHERE	ftci.fee_cal_type = p_fee_cal_type AND
  			ftci.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			ftci.fee_type = p_fee_type;
  BEGIN
  	-- Validate if IGS_FI_F_CAT_FEE_LBL.s_chg_method_type and
  	--IGS_FI_F_CAT_FEE_LBL.rul_sequence_number are required or
  	--not, depending on related values.
  	--1.	Check parameters.
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_type IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	--2.	If p_chg_method is not null or p_rule_sequence is not
  	--null then validate the fee_type to see if it is permissable
  	--for these values to be specified. Not permissable when
  	--IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN' or s_fee_type =
  	--'HECS'.
  	OPEN c_ft;
  	FETCH c_ft INTO		v_fee_type,
  				v_s_fee_trigger_cat;
  	CLOSE c_ft;
  	IF v_fee_type = cst_fee_type AND p_chg_method is not null THEN
  		p_message_name := 'IGS_FI_CHARGE_METHOD_NOT_SPEC';
  		RETURN FALSE;
  	END IF;
  	IF v_fee_type = cst_fee_type AND p_rule_sequence is not null THEN
  		p_message_name := 'IGS_FI_RULSEQ_HECS';
  		RETURN FALSE;
  	END IF;
  	IF v_s_fee_trigger_cat = cst_fee_trigger_cat AND
  	   p_chg_method is not null THEN
  		p_message_name := 'IGS_FI_CHGMTH_INSTITUTN';
  		RETURN FALSE;
  	END IF;
  	IF  v_fee_type = cst_fee_type AND
  	   p_rule_sequence is not null THEN
  		p_message_name := 'IGS_FI_RULE_SEQ_NOT_SPECIFIED';
  		RETURN FALSE;
  	END IF;
  	--3.	Validate the IGS_FI_F_TYP_CA_INST record to see if
  	-- these fields are set.  If not, they must be specified in the
  	-- IGS_FI_F_CAT_FEE_LBL record.  If they are, they cannot be
  	-- specified in the IGS_FI_F_CAT_FEE_LBL record.
  	IF  v_fee_type <> cst_fee_type AND  v_fee_type <> cst_fee_type THEN
  		OPEN c_ftci;
  		FETCH c_ftci INTO	v_s_chg_method_type,
  					v_rul_sequence_number;
  		CLOSE c_ftci;
    		IF v_s_chg_method_type IS NOT NULL AND
    				p_chg_method IS NOT NULL THEN
    			p_message_name := 'IGS_FI_CHGMTH_FEETYPE_EXISTS';
    			RETURN FALSE;
    		END IF;
    		IF v_rul_sequence_number IS NOT NULL AND
    				p_rule_sequence IS NOT NULL THEN
    			p_message_name := 'IGS_FI_RULSEQ_FEETYPE_EXISTS';
    			RETURN FALSE;
    		END IF;
  		IF v_s_chg_method_type IS NULL AND
  				p_chg_method IS NULL THEN
  			p_message_name := 'IGS_FI_CHARGE_METHOD_SPECIFY';
  			RETURN FALSE;
  		END IF;
  		IF v_rul_sequence_number IS NULL AND
  				p_rule_sequence IS NULL THEN
  			p_message_name := 'IGS_FI_RULE_SEQ_SPECIFY';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--4.	Return no error.
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_fcfl_rqrd;
  --
  -- Ensure status value is allowed.
  FUNCTION finp_val_fcfl_status(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	v_fss_fee_structure_status	IGS_FI_FEE_STR_STAT.s_fee_structure_status%TYPE;
  	cst_active_status		CONSTANT	VARCHAR2(6):= 'ACTIVE';
  	CURSOR c_ftci IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_F_TYP_CA_INST	ftci,
  			IGS_FI_FEE_STR_STAT	fss
  		WHERE	ftci.fee_cal_type = p_fee_cal_type AND
  			ftci.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			ftci.fee_type = p_fee_type AND
  			ftci.fee_type_ci_status = fss.fee_structure_status;
  	CURSOR c_fss IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_FEE_STR_STAT	fss
  		WHERE	fss.fee_structure_status = p_fee_status;
  	CURSOR c_fcci IS
  		SELECT	fss.s_fee_structure_status
  		FROM	IGS_FI_F_CAT_CA_INST	fcci,
  			IGS_FI_FEE_STR_STAT	fss
  		WHERE	fcci.fee_cal_type = p_fee_cal_type AND
  			fcci.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			fcci.fee_cat = p_fee_cat AND
  			fcci.fee_cat_ci_status = fss.fee_structure_status;
  BEGIN
  	--Validate IGS_FI_F_CAT_FEE_LBL.fee_liability_status.  Check
  	-- that parent records have a status of 'ACTIVE' when
  	-- setting fee_liability_status to 'ACTIVE'.
  	--1. 	Check Parameters
  	IF (p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_fee_cat IS NULL OR
  			p_fee_type IS NULL OR
  			p_fee_status IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	--2.	Get the system status of the fee status.  If not 'ACTIVE'
  	--no further processing is required.
  	OPEN c_fss;
  	FETCH c_fss INTO v_fss_fee_structure_status;
  	CLOSE c_fss;
  	IF (v_fss_fee_structure_status IS NULL OR
  			v_fss_fee_structure_status <> cst_active_status) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	v_fss_fee_structure_status := NULL;
  	--3.	Validate that corresponding IGS_FI_F_TYP_CA_INST
  	-- record has status of 'ACTIVE'. (IGS_GE_NOTE: IGS_FI_F_CAT_FEE_LBL
  	-- records cannot exist without corresponding IGS_FI_F_TYP_CA_INST
  	-- records.
  	OPEN c_ftci;
  	FETCH c_ftci INTO v_fss_fee_structure_status;
  	CLOSE c_ftci;
  	IF (v_fss_fee_structure_status IS NULL OR
  			v_fss_fee_structure_status <> cst_active_status) THEN
  		p_message_name := 'IGS_FI_STNOT_ACTIVE_CORTYPE';
  		RETURN FALSE;
  	END IF;
  	v_fss_fee_structure_status := NULL;
  	--4.	Validate that corresdponding fee_cal_cat_instance record
  	-- has a status of 'ACTIVE'. (IGS_GE_NOTE: IGS_FI_F_CAT_FEE_LBL
  	-- records cannot exist without corresponding IGS_FI_F_TYP_CA_INST
  	-- records.
  	OPEN c_fcci;
  	FETCH c_fcci INTO v_fss_fee_structure_status;
  	CLOSE c_fcci;
  	IF (v_fss_fee_structure_status IS NULL OR
  			v_fss_fee_structure_status <> cst_active_status) THEN
  		p_message_name := 'IGS_FI_STNOT_ACTIVE_CORCAT';
  		RETURN FALSE;
  	END IF;
  	--5.	Return no error.
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_fcfl_status;
  --
  -- Validate insert of FCFL does not clash currency with FTCI definitions
  FUNCTION finp_val_fcfl_cur(
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
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
  ||  vvutukur        29-Nov-2002  Enh#2584986.Removed references to igs_fi_cur as the same has been
  ||                               obsoleted.Instead defaulted the currency that is set up in System Options Form.
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_fcfl_cur
  	-- Validate insert of the IGS_FI_F_CAT_FEE_LBL.
  	-- When the fee category currency does not match the local currency
  	-- check there are no inherited definitions taken from the
  	-- fee type calendar instance. All definitions at the FTCI level
  	-- operate under the local currency
  DECLARE
  	v_check			CHAR;
  	v_fee_cat_currency_cd	igs_fi_control.currency_cd%TYPE;
        l_v_currency            igs_fi_control.currency_cd%TYPE;

        CURSOR cur_ctrl IS
          SELECT currency_cd
          FROM   igs_fi_control;

  	CURSOR c_fc	IS
  		SELECT	currency_cd
  		FROM	IGS_FI_FEE_CAT
  		WHERE	fee_cat	= p_fee_cat;

  	CURSOR c_frtns	IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_RET_SCHD
  		WHERE	fee_cal_type = p_fee_cal_type AND
  			fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			s_relation_type = 'FTCI' AND
  			fee_type = p_fee_type;

  -- Removed reference to IGS_FI_FEE_ENCMB(c_fe cursor) since the table is obselted as part of bug 2126091 - sykrishn -30112001 --
  	CURSOR c_far	IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_AS_RATE
  		WHERE	fee_type = p_fee_type AND
  			fee_cal_type = p_fee_cal_type AND
  			fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			s_relation_type = 'FTCI' AND
  			logical_delete_dt IS NULL;
  BEGIN
  	p_message_name := NULL;
  	-- get the fee category currency code
  	OPEN c_fc;
  	FETCH c_fc INTO v_fee_cat_currency_cd;
  	CLOSE	c_fc;
  	IF (v_fee_cat_currency_cd IS NULL) THEN
  		-- local currency is the default
  		RETURN TRUE;
  	END IF;

        --Capture the default currency that is set up in System Options Form.
        OPEN cur_ctrl;
        FETCH cur_ctrl INTO l_v_currency;
        IF cur_ctrl%NOTFOUND THEN
          p_message_name := 'IGS_FI_SYSTEM_OPT_SETUP';
          CLOSE cur_ctrl;
          RETURN FALSE;
        END IF;
        CLOSE cur_ctrl;

 	IF (v_fee_cat_currency_cd = l_v_currency) THEN
  		-- local currency is being used
  		RETURN TRUE;
  	END IF;
  	-- check there are no definitions under the fee category taken from
  	-- the fee type calendar instance. All definitions at the FTCI level
  	-- operate under the local currency

  	-- check if FTCI retention schedules exist for the fee category fee liability
  	OPEN	c_frtns;
  	FETCH	c_frtns INTO v_check;
  	IF (c_frtns%FOUND) THEN
  		CLOSE c_frtns;
  		p_message_name := 'IGS_FI_FEETYPE_CLASH_RETNSCH';
  		RETURN FALSE;
  	END IF;
  	CLOSE	c_frtns;
  	-- check if FTCI fee encumbrances exist for the fee category fee liability
   -- This check Removed since reference to IGS_FI_FEE_ENCMB is removed since the table is obselted as part of bug 2126091 - sykrishn -30112001 --
  	-- check if FTCI fee assessment rates exist for the fee category fee liability
  	OPEN	c_far;
  	FETCH	c_far INTO v_check;
  	IF (c_far%FOUND) THEN
  		CLOSE c_far;
  		p_message_name := 'IGS_FI_FEETYPE_CLASH_FEEASSES';
  		RETURN FALSE;
  	END IF;
  	CLOSE	c_far;
  	RETURN TRUE;
  END;
  END finp_val_fcfl_cur;
  --
  -- Validate the fee structure status closed indicator
  -- bug 1956374 Duplicate code removal removed finp_val_fss_closed
  -- Validate the PAYMENT_HIERARCHY_RANK
  -- As part of bugfix#2425767, removed function finp_val_fcfl_rank, as payment_hierarchy_rank column is
  -- obsoleted.
END IGS_FI_VAL_FCFL;

/
