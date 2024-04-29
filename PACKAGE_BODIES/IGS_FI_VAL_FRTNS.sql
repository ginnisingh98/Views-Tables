--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FRTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FRTNS" AS
/* $Header: IGSFI32B.pls 115.7 2002/12/30 10:22:22 sykrishn ship $ */
  --
  /*Change History:
    Who       When            What
    sykrishn 30dec2002   Bug 2708665 - Function finp_val_frtns_amt Changed the message to be returned
			 as more menaingful instead of IGS_GE_MANDATORY_FLD.
    vvutukur 29-Nov-2002  Enh#2584986.Modified finp_val_frtns_cur to remove references to igs_fi_cur.

  /* Bug 1956374
     What Duplicate code finp_val_sched_mbrs removed
     who msrinivi
  */
  -- Validate fee retention schedules can be created for the relation type.
  FUNCTION finp_val_frtns_creat(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_frtns_creat
  	-- Validate if IGS_FI_FEE_RET_SCHD records can be created.
  	-- When defined at FTCI level, they cannot also be
  	-- defined at FCFL level and vice-versa.
  DECLARE
  	CURSOR c_frtns (
  		cp_s_relation_type 		IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_RET_SCHD
  		WHERE	FEE_TYPE 		= p_fee_type AND
  			fee_cal_type 		= p_fee_cal_type AND
  			fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			s_relation_type 	= cp_s_relation_type;
  	v_fcfl_exists		VARCHAR2(1);
  	v_ftci_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check Parameters
  	IF p_fee_type IS NULL OR
  			p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_s_relation_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. If p_s_relation_type = FCFL, check if any  records
  	-- have been defined at the FTCI level.  If so, return error.
  	IF p_s_relation_type = 'FCFL' THEN
  		OPEN c_frtns(
  			'FTCI');
  		FETCH c_frtns INTO v_ftci_exists;
  		IF c_frtns%FOUND THEN
  			CLOSE c_frtns;
  			p_message_name := 'IGS_FI_FEE_RETN_SCH_FEECAT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_frtns;
  	END IF;
  	-- 3. If p_s_relation_type = FTCI, check if any records
  	-- have been defined at the FCFL level.  If so, return error.
  	IF p_s_relation_type = 'FTCI' THEN
  		OPEN c_frtns(
  			'FCFL');
  		FETCH c_frtns INTO v_fcfl_exists;
  		IF c_frtns%FOUND THEN
  			CLOSE c_frtns;
  			p_message_name := 'IGS_FI_FEE_RETN_SCH_FEETYPE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_frtns;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_frtns_creat;
  --
  -- Validate IGS_FI_FEE_RET_SCHD retention_amount
  FUNCTION finp_val_frtns_amt(
  p_retention_amount IN NUMBER ,
  p_retention_percentage IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_frtns_amt
  	-- Validate IGS_FI_FEE_RET_SCHD.retention_amount and
  	-- retention_percentage.
  	-- Only one of either retention_amount or retention_percentage
  	-- may be specified.
  	-- Set the default message number
  	p_message_name := NULL;
  	-- 1. Check parameter values
  	IF (p_retention_amount IS NOT NULL AND
  			p_retention_percentage IS NOT NULL) THEN
  		p_message_name := 'IGS_FI_ONE_RETAMT_OR_RETPREC';
  		RETURN FALSE;
  	END IF;
  	IF (p_retention_amount IS NULL AND
  			p_retention_percentage IS NULL) THEN
  		p_message_name := 'IGS_FI_RETAMT_OR_PER_MAND';
  		RETURN FALSE;
  	END IF;
  	-- 2. Return no error
  	RETURN TRUE;
  END finp_val_frtns_amt;
  --
  -- Validate IGS_FI_FEE_RET_SCHD fee type
  FUNCTION finp_val_frtns_ft(
  p_fee_type IN VARCHAR2 ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_frtns_ft
  	-- Validate IGS_FI_FEE_RET_SCHD.FEE_TYPE.
  	-- If IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN', then retention schedules
  	-- can only be defined against fee_type_cal_instances. If the
  	-- IGS_FI_FEE_TYPE.optional_payment_ind
  	-- is set to 'Y' then fee retention schedules can only be set against
  	-- fee_cat_cal_instances.
  DECLARE
  	cst_institutn		CONSTANT VARCHAR(10) := 'INSTITUTN';
  	cst_hecs		CONSTANT VARCHAR(4) := 'HECS';
  	cst_ftci		CONSTANT VARCHAR(5) := 'FTCI';
  	cst_fcci		CONSTANT VARCHAR(5) := 'FCCI';
  	cst_yes		CONSTANT CHAR := 'Y';
  	CURSOR c_ft(
  			cp_fee_type		IGS_FI_FEE_TYPE.FEE_TYPE%TYPE) IS
  		SELECT	s_fee_trigger_cat,
  			s_fee_type,
  			optional_payment_ind
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	FEE_TYPE = cp_fee_type;
  	v_ft_rec		c_ft%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF (p_fee_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system fee trigger category and the optional indicator of the
  	-- IGS_FI_FEE_TYPE.
  	OPEN c_ft (p_fee_type);
  	FETCH c_ft INTO v_ft_rec;
  	IF c_ft%NOTFOUND THEN
  		CLOSE c_ft;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_ft;
  	IF v_ft_rec.s_fee_trigger_cat = cst_institutn AND
  			p_s_relation_type <> cst_ftci THEN
  		p_message_name := 'IGS_FI_FEERET_SCH_FEETYPE_CAL';
  		RETURN FALSE;
  	END IF;
  	IF v_ft_rec.s_fee_type = cst_hecs AND
  			p_s_relation_type <> cst_ftci THEN
  		p_message_name := 'IGS_FI_FEERET_SCH_ONLY_DFEINE';
  		RETURN FALSE;
  	END IF;
  	IF v_ft_rec.optional_payment_ind = cst_yes AND
  			p_s_relation_type <> cst_fcci THEN
  		p_message_name := 'IGS_FI_FEERET_SCH_FEECAT_CAL';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  END finp_val_frtns_ft;
  --
  -- Validate appropriate fields set for relation type.
  -- Duplicate code finp_val_sched_mbrs removed
  -- Validate insert of FRTNS does not clash currency code set up with FCFL definitions
  FUNCTION finp_val_frtns_cur(
  p_fee_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_s_relation_type IN VARCHAR2 ,
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
  || vvutukur    29-Nov-2002  Enh#2584986. Removed the references to
  ||                                    igs_fi_cur, instead defaulted the currency
  ||                                    that is set up in System Options Form.
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_frtns_cur
  	-- Validate insert of the IGS_FI_FEE_RET_SCHD.
  	-- When adding an entry at the FTCI level;
  	-- check there are no related fee category fee liabilities
  	-- with a fee category currency set to other than the local
  	-- currency.
  DECLARE

  l_v_currency          igs_fi_control.currency_cd%TYPE;
  v_fee_cat_currency_cd	igs_fi_control.currency_cd%TYPE;

  	CURSOR c_fc	(cp_fee_cat	IGS_FI_FEE_CAT.fee_cat%TYPE)	IS
  		SELECT	currency_cd
  		FROM	IGS_FI_FEE_CAT
  		WHERE	FEE_CAT	= cp_fee_cat;
  	CURSOR c_fcfl	IS
  		SELECT	FEE_CAT
  		FROM	IGS_FI_F_CAT_FEE_LBL
  		WHERE	fee_cal_type = p_fee_cal_type AND
  			fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			FEE_TYPE = p_fee_type;
        CURSOR cur_ctrl IS
          SELECT currency_cd
          FROM   igs_fi_control;
  BEGIN
  	p_message_name := NULL;
  	-- check if the definition is at the Fee Type Calendar Instance level
  	IF (p_s_relation_type <> 'FTCI') THEN
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

        -- check there are no related fee category fee liabilities
  	-- with a fee category currency set to other than the local
  	-- currency.
  	FOR v_fcfl_rec IN c_fcfl LOOP
  		-- get the fee category currency code
  		OPEN	c_fc (v_fcfl_rec.fee_cat);
  		FETCH	c_fc	INTO	v_fee_cat_currency_cd;
  		CLOSE	c_fc;
  		IF (NVL(v_fee_cat_currency_cd, l_v_currency) <> l_v_currency)
  		THEN
  			p_message_name := 'IGS_FI_FEEPYM_CLASH_FEECAT';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END;
  END finp_val_frtns_cur;
END IGS_FI_VAL_FRTNS;

/
