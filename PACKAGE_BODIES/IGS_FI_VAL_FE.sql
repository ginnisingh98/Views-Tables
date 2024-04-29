--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FE" AS
/* $Header: IGSFI29B.pls 115.8 2002/11/29 12:47:26 vvutukur ship $ */
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        29-Nov-2002  Enh#2584986.Modified finp_val_fe_cur,finp_val_fe_cur.
  ||  vvutukur        26-Aug-2002  Bug#2531390.Modifications done in FUNCTION finp_val_sched_mbrs.
  ----------------------------------------------------------------------------*/
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- remove funtion enrp_val_et_closed
/****************************
Removed the functions shown below as part of bug 2126091 by sykrishn - 30112001
1) finp_val_fe_dai
2) finp_val_fe_ft
3) finp_val_fe_offset
4) finp_val_fe_ins
5) finp_val_fe_create
*****************************/
  --
  -- Validate fee_encumbrance dt alias.
  --Removed this function shown below as part of bug 2126091 by sykrishn - 30112001
  -- Validate fee_encumbrance fee type
  --Removed this function shown below as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate fee_encumbrance offsets.
  --Removed this function shown below as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate IGS_FI_FEE_ENCMB insert.
   --Removed this function shown below as part of bug 2126091 by sykrishn - 30112001
  --
  -- Validate appropriate fields set for relation type.
  FUNCTION finp_val_sched_mbrs(
  p_fee_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
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
  ||  vvutukur        26-Aug-2002  Bug#2531390.Modified the comment which mentions about the validation
  ||                               of fee_cat and fee_type to avoid confusion as igs_fi_fee_pay_sched is
  ||                               obsolete.
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	cst_relation_type_FTCI		CONSTANT	VARCHAR2(4) := 'FTCI';
  	cst_relation_type_FCCI		CONSTANT	VARCHAR2(4) := 'FCCI';
  	cst_relation_type_FCFL		CONSTANT	VARCHAR2(4) := 'FCFL';
  BEGIN
  	--  Validate if p_fee_cat and p_fee_type are only specified
  	--  for the appropriate p_fee_relation_type.
  	--1.	Check parameters.
  	IF (p_fee_relation_type IS NULL) THEN
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	IF p_fee_relation_type NOT IN (cst_relation_type_FTCI, cst_relation_type_FCCI,
  cst_relation_type_FCFL) THEN
  		p_message_name := 'IGS_FI_FUNC_P_RELATION_TYPE';
  		RETURN FALSE;
  	END IF;
  	--2.	Validate that for relation type 'FTCI', fee_type
  	--is specified and fee_cat is NULL.
  	IF p_fee_relation_type = cst_relation_type_FTCI THEN
  		IF (p_fee_type IS NOT NULL AND
  		     p_fee_cat IS NULL) THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_FI_FEETYPE_MUSTBE_SPECIFI';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--3.	Validate that for relation type 'FCCI', fee_cat is
  	--specified and fee_type IS NULL.
  	IF p_fee_relation_type = cst_relation_type_FCCI THEN
  		IF (p_fee_cat IS NOT NULL AND
  				p_fee_type IS NULL) THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_FI_FEECAT_MUSTBE_SPECIFIE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--4.	Validate that for relation type 'FCFL' both fee_cat
  	--and fee_type are specified.
  	IF p_fee_relation_type = cst_relation_type_FCFL THEN
  		IF (p_fee_type IS NOT NULL AND
  				p_fee_cat IS NOT NULL) THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_FI_BOTH_FEECAT_FEETYPE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--5.	Return no error.
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  END finp_val_sched_mbrs;
  --
  -- Validate fee encumbrance can be created for the relation type.
  --Removed this function shown below as part of bug 2126091 by sykrishn - 30112001
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Validate insert of FE does not clash currencywith FCFL definitions
  FUNCTION finp_val_fe_cur(
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
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
  ||                          igs_fi_cur, instead defaulted the currency
  ||                          that is set up in System Options Form.
  ----------------------------------------------------------------------------*/
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_fe_cur

  	-- When adding an entry at the FTCI level;
  	-- check there are no related fee category fee liabilities
  	-- with a fee category currency set to other than the local
  	-- currency.
  DECLARE

  	v_fee_cat_currency_cd	igs_fi_control.currency_cd%TYPE;
        l_v_currency            igs_fi_control.currency_cd%TYPE;

        CURSOR cur_ctrl IS
          SELECT currency_cd
          FROM   igs_fi_control;

  	CURSOR c_fc	(cp_fee_cat	IGS_FI_FEE_CAT.fee_cat%TYPE)	IS
  		SELECT	currency_cd
  		FROM	IGS_FI_FEE_CAT
  		WHERE	fee_cat	= cp_fee_cat;
  	CURSOR c_fcfl	IS
  		SELECT	fee_cat
  		FROM	IGS_FI_F_CAT_FEE_LBL
  		WHERE	fee_cal_type = p_fee_cal_type AND
  			fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			fee_type = p_fee_type;
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
  	-- with a fee category currencyset to other than the local
  	-- currency
  	FOR v_fcfl_rec IN c_fcfl LOOP
  		-- get the fee category currencycode
  		OPEN	c_fc (v_fcfl_rec.fee_cat);
  		FETCH	c_fc	INTO	v_fee_cat_currency_cd;
  		CLOSE	c_fc;
  		IF (NVL(v_fee_cat_currency_cd, l_v_currency) <> l_v_currency)
  		THEN
  			p_message_name := 'IGS_FI_FEEENCUMB_NOT_CREATED';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END;
  END finp_val_fe_cur;
END IGS_FI_VAL_FE;

/
