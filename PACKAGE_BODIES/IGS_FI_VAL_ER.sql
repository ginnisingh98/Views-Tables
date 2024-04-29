--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_ER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_ER" AS
/* $Header: IGSFI20B.pls 115.7 2002/11/29 00:18:43 nsidana ship $ */
/*  Who         When            What
    jbegum      05-Mar-2002     Modified the logic of function finp_val_er_ovrlp
                                The logic was changed as part of bug fix for
				bug #2117296.
  --sbaliga  	20-feb-2002	Modified the finp_val_er_ovrlp procedure
  --				bug no-2231567                               */
  -- Validate elements ranges can be created for the relation type.
  FUNCTION finp_val_er_defn(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_er_defn
  	-- Validate if IGS_FI_ELM_RANGE records can be created.
  	-- When defined at FTCI level, they cannot also be
  	-- defined at FCFL level and vice-versa.
  DECLARE
  	CURSOR c_er (
  		cp_s_relation_type 		IGS_FI_ELM_RANGE.s_relation_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_ELM_RANGE
  		WHERE	fee_type 		= p_fee_type AND
  			fee_cal_type 		= p_fee_cal_type AND
  			fee_ci_sequence_number 	= p_fee_ci_sequence_number AND
  			s_relation_type 	= cp_s_relation_type AND
  			logical_delete_dt	IS NULL;
  	v_fcfl_exists		VARCHAR2(1);
  	v_ftci_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- 1. Check Parameters
  	IF p_fee_type IS NULL OR
  			p_fee_cal_type IS NULL OR
  			p_fee_ci_sequence_number IS NULL OR
  			p_s_relation_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. If p_s_relation_type = ?FCFL?, check if any IGS_FI_ELM_RANGE records
  	-- have been defined at the FTCI level.  If so, return error.
  	IF p_s_relation_type = 'FCFL' THEN
  		OPEN c_er(
  			'FTCI');
  		FETCH c_er INTO v_ftci_exists;
  		IF c_er%FOUND THEN
  			CLOSE c_er;
  			p_message_name := 'IGS_FI_ELERNG_ND_FEECATFEELIA';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_er;
  	END IF;
  	-- 3. If p_s_relation_type = ?FTCI?, check if any IGS_FI_ELM_RANGE records
  	-- have been defined at the FCFL level.  If so, return error.
  	IF p_s_relation_type = 'FTCI' THEN
  		OPEN c_er(
  			'FCFL');
  		FETCH c_er INTO v_fcfl_exists;
  		IF c_er%FOUND THEN
  			CLOSE c_er;
  			p_message_name := 'IGS_FI_ELERNG_ND_FEETYPECALIN';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_er;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_er_defn;
  --
  -- Ensure elements range values do not overlap.
  FUNCTION finp_val_er_ovrlp(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_lower_range IN NUMBER ,
  p_upper_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
 /***********************************************************************
 Change History
 Who 		When		What
 jbegum         05-Mar-2002     Modified the logic of function finp_val_er_ovrlp
                                The logic was changed as part of bug fix for
				bug #2117296.
				The existing logic was assuming the lower_range field
				to be mandatory and only checking for the cases where
				upper_range field was Null or Not Null.
				The logic did not handle the cases where the lower_range
				field is Null.
 sbaliga	20-feb-2002	Added check for case when both ranges are open
 				ranges-bug no 2231567
 *************************************************************************/
  BEGIN
  DECLARE
  	CURSOR c_er IS
  		SELECT	er.lower_range,
  			er.upper_range
  		FROM	IGS_FI_ELM_RANGE	er
  		WHERE	er.fee_type 		= p_fee_type AND
  			er.fee_cal_type 	= p_fee_cal_type AND
  			er.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			er.s_relation_type 	= p_s_relation_type AND
  			nvl(er.fee_cat,'NULL')	= nvl(p_fee_cat,'NULL') AND
  			er.range_number		<> nvl(p_range_number,0) AND
  			er.logical_delete_dt 	IS NULL;
  	v_message_name	VARCHAR2(30) := Null;
  BEGIN
  	-- Validate that IGS_FI_ELM_RANGE.lower_range and upper_range do not overlap with
  	-- existing records with the same fee_type, fee_cal_type,
  	-- fee_ci_sequence_number,  s_relation_type (FTCI and FCFL) and
  	-- fee_cat (FCFL only)
  	--- Set the default message number

  	p_message_name := NULL;

  	FOR v_er_rec IN c_er LOOP

            -- Existing records with closed ranges
	    IF v_er_rec.upper_range IS NOT NULL AND v_er_rec.lower_range IS NOT NULL THEN

	       -- If the lower range is between an existing lower to upper range
	          IF (p_lower_range >= v_er_rec.lower_range AND
  		      p_lower_range <= v_er_rec.upper_range) THEN
  		     v_message_name := 'IGS_FI_RO_LOWRNG_LOWER';
  		     EXIT;
  		  END IF;
               -- If the upper range is between an existing lower to upper range
		  IF (p_upper_range >= v_er_rec.lower_range AND
  		      p_upper_range <= v_er_rec.upper_range) THEN
  		      v_message_name := 'IGS_FI_RO_UPPERRNG_LOWER';
  		      EXIT;
  		  END IF;
               -- If lower and upper ranges encompass an existing lower to upper range
		  IF (p_lower_range <= v_er_rec.lower_range AND
  		      p_upper_range >= v_er_rec.upper_range) THEN
  		      v_message_name := 'IGS_FI_RO_LOWRNG_ENCOMPASS';
  		      EXIT;
  		  END IF;
               -- If open range overlaps with an existing elements range
		  IF  p_upper_range IS NULL THEN
		    IF (p_lower_range <= v_er_rec.lower_range OR
  		      p_lower_range <= v_er_rec.upper_range) THEN
  		      v_message_name := 'IGS_FI_OPEN_RO_LOWRNG_LOWER';
  		      EXIT;
  		    END IF;
                  ELSIF p_lower_range IS NULL THEN
		    IF (p_upper_range >= v_er_rec.lower_range OR
  		      p_upper_range >= v_er_rec.upper_range) THEN
  		      v_message_name := 'IGS_FI_OPEN_RO_LOWRNG_LOWER';
  		      EXIT;
  		    END IF;
                  END IF;
            -- Existing records with open ranges (ie. the lower_range is not set )
	    ELSIF v_er_rec.upper_range IS NOT NULL THEN
                  IF (p_lower_range <= v_er_rec.upper_range OR
  		      p_upper_range <= v_er_rec.upper_range) THEN
  		      v_message_name := 'IGS_FI_RO_RNG_OVERLAPS';
  		     EXIT;
  		  END IF;
            -- Existing records with open ranges (ie. the upper_range is not set )
            ELSIF v_er_rec.lower_range IS NOT NULL THEN
	          IF (p_lower_range >= v_er_rec.lower_range OR
  		      p_upper_range >= v_er_rec.lower_range) THEN
  		      v_message_name := 'IGS_FI_RO_RNG_OVERLAPS';
  		     EXIT;
  		  END IF;
	    END IF;

  	END LOOP;
  	IF v_message_name IS NOT NULL THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_er_ovrlp;
  --
  -- Ensure elements range rate can be created.
  -- Duplicate code removal, msrinivi Removed proc finp_val_err_ins
  -- Ensure elements range can be created.
  FUNCTION finp_val_er_create(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_er_create
  	-- Validate IGS_FI_F_TYP_CA_INST.s_chg_method_type, fee_type and
  	-- IGS_FI_F_CAT_FEE_LBL.s_chg_method_type, fee_type.
  	-- If s_chg_method_type = 'FLATRATE' or IGS_FI_FEE_TYPE.s_fee_type = 'HECS', then
  	-- element ranges cannot be defined
  DECLARE
  	CURSOR c_ftci IS
  		SELECT	ftci.s_chg_method_type
  		FROM	IGS_FI_F_TYP_CA_INST ftci
  		WHERE	ftci.fee_type = p_fee_type AND
  			ftci.fee_cal_type = p_fee_cal_type AND
  			ftci.fee_ci_sequence_number = p_fee_ci_sequence_number;
  	CURSOR c_ftfl IS
  		SELECT	ftfl.s_chg_method_type
  		FROM	IGS_FI_F_CAT_FEE_LBL ftfl
  		WHERE	ftfl.fee_type = p_fee_type AND
  			ftfl.fee_cal_type = p_fee_cal_type AND
  			ftfl.fee_ci_sequence_number = p_fee_ci_sequence_number AND
  			ftfl.fee_cat = p_fee_cat;
  	CURSOR c_ft IS
  		SELECT	ft.s_fee_type
  		FROM	IGS_FI_FEE_TYPE ft
  		WHERE	ft.fee_type = p_fee_type;
  	cst_flatrate		CONSTANT VARCHAR2(10) := 'FLATRATE';
  	cst_hecs		CONSTANT VARCHAR2(10) := 'HECS';
  	v_s_fee_type		IGS_FI_FEE_TYPE.s_fee_type%TYPE;
  	v_ftci_scmt	 	IGS_FI_F_CAT_FEE_LBL.s_chg_method_type%TYPE;
  	v_ftfl_scmt	 	IGS_FI_F_CAT_FEE_LBL.s_chg_method_type%TYPE;
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	-- 1. check parameters
  	IF ((p_fee_cal_type IS NULL) OR
  			(p_fee_ci_sequence_number IS NULL) OR
  			(p_fee_type IS NULL)) THEN
  		p_message_name := Null;
  		RETURN TRUE;
  	END IF;
  	-- 2. Determine the s_chg_method_type, if p_fee_cat is null, master record must
  	--  be a IGS_FI_F_TYP_CA_INST record
  	IF p_fee_cat IS NULL THEN
  		OPEN c_ftci;
  		FETCH c_ftci INTO v_ftci_scmt;
  		IF (c_ftci%NOTFOUND) THEN
  			CLOSE c_ftci;
/* Changed by lpriyadh to close the bug 1488301  */
--  			RAISE NO_DATA_FOUND;
                        RETURN FALSE;
  		ELSE
  			IF v_ftci_scmt = cst_flatrate THEN
  				p_message_name := 'IGS_FI_ELERNG_NOTDEFN_CHGMTH';
  				CLOSE c_ftci;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_ftci;
  	END IF;
  	-- 3.if p_fee_cat is not null, master record must be a IGS_FI_F_CAT_FEE_LBL
  	-- record
  	IF p_fee_cat IS NOT NULL THEN
  		OPEN c_ftfl;
  		FETCH c_ftfl INTO v_ftfl_scmt;
  		IF (c_ftfl%NOTFOUND) THEN
  			CLOSE c_ftfl;
/* changed by lpriyadh to close the bug 1488301 */
--  			RAISE NO_DATA_FOUND;
                        RETURN FALSE;
  		ELSE
  			IF v_ftfl_scmt = cst_flatrate THEN
  				p_message_name := 'IGS_FI_ELERNG_NOTDEFN_CHGMTH';
  				CLOSE c_ftfl;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_ftfl;
  	END IF;
  	-- 4.Check the fee_type
  		OPEN c_ft;
  		FETCH c_ft INTO v_s_fee_type;
  		IF v_s_fee_type = cst_hecs THEN
  			p_message_name := 'IGS_FI_ELERNG_NOTDEFN_FEETYPE';
  			CLOSE c_ft;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ft;
  	RETURN TRUE;
  END;
  END finp_val_er_create;
  --
  -- Ensure elements range values are valid.
  FUNCTION finp_val_er_ranges(
  p_lower_range IN NUMBER ,
  p_upper_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_er_ranges
  	-- validate IGS_FI_ELM_RANGE.lower_range and IGS_FI_ELM_RANGE.upper_range.
  	-- If both are specififed, then lower_range must be less than or equal to
  	-- upper range
  DECLARE
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	-- validate parameters (one or both must exist)
  	IF p_lower_range IS NULL
  		AND p_upper_range IS NULL THEN
  		p_message_name := 'IGS_FI_ONE_LOW_AND_UP_RANGE';
  		RETURN FALSE;
  	END IF;
  	-- validate ranges if both are specified
  	IF (p_lower_range IS NOT NULL
  		AND p_upper_range IS NOT NULL) THEN
  		IF p_lower_range > p_upper_range THEN
  			p_message_name := 'IGS_FI_UPRANGE_GE_LOWRANGE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_er_ranges;
  --
  -- Ensure elements range relations are valid.
  FUNCTION finp_val_er_rltn(
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_er_relation
  	-- Validate IGS_FI_ELM_RANGE.fee_cat is only specified for the appropriate
  	-- IGS_FI_ELM_RANGE.s_relation_type
  DECLARE
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	-- Validate parameter values
  	IF p_s_relation_type IS NULL THEN
  		RETURN TRUE;
  	ELSIF p_s_relation_type NOT IN('FTCI','FCFL') THEN
  		p_message_name := 'IGS_FI_FINP_VAL_ER_RLTN_CALL';
  		RETURN FALSE;
  	END IF;
  	-- Validate that for relation type FTCI, fee_cat is NULL
  	IF p_s_relation_type = 'FTCI' THEN
  		IF p_fee_cat IS NULL THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_FI_FEECAT_NULL_ELERNG';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that for relation type 'FCFL', fee_cat is NOT NULL
  	IF p_s_relation_type = 'FCFL' THEN
  		IF p_fee_cat IS NOT NULL THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_FI_FEECAT_SPEC_ELERNG';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  END finp_val_er_rltn;
  --
  -- Ensure elements range can be created.
  FUNCTION finp_val_er_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- finp_val_er_ins
  	-- validate IGS_FI_ELM_RANGE.fee_type.  If IGS_FI_FEE_TYPE.s_fee_trigger_cat equals
  	-- 'INSTITUTN', then apportionments  can only be defined against
  	-- IGS_FI_F_TYP_CA_INSTs
  DECLARE
  	CURSOR c_ft IS
  		SELECT	s_fee_trigger_cat,
  			s_fee_type
  		FROM	IGS_FI_FEE_TYPE
  		WHERE	fee_type = p_fee_type;
  	v_s_fee_trigger_cat	IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
  	v_s_fee_type		IGS_FI_FEE_TYPE.s_fee_type%TYPE;
  	cst_institutn		CONSTANT IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE := 'INSTITUTN';
  	cst_hecs			CONSTANT IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'HECS';
  BEGIN
  	--- Set the default message number
  	p_message_name := Null;
  	IF p_fee_type IS NULL THEN
  		p_message_name := Null;
  		RETURN TRUE;
  	END IF;
  	OPEN c_ft;
  	FETCH c_ft INTO v_s_fee_trigger_cat, v_s_fee_type;
  	IF (c_ft%FOUND) THEN
  		IF v_s_fee_trigger_cat = cst_institutn THEN
  			p_message_name := 'IGS_FI_ELERNG_NOTDEFN_FEECAT';
  			CLOSE c_ft;
  			RETURN FALSE;
  		END IF;
  		IF v_s_fee_type = cst_hecs THEN
  			p_message_name := 'IGS_FI_ELERNG_NOTDEFN_FEECAT';
  			CLOSE c_ft;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_ft;
  	RETURN TRUE;
  END;
  END finp_val_er_ins;
END IGS_FI_VAL_ER;

/
