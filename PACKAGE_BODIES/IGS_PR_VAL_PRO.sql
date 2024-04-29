--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_PRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_PRO" AS
/* $Header: IGSPR19B.pls 115.10 2002/11/29 02:48:45 nsidana ship $ */
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Removed program unit (PRGP_VAL_OU_ACTIVE) - from the spec and body. -- kdande
*/
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001    Bug Id : 1956374. Removed procedure "prgp_val_appeal_ind"
  --smadathi    29-AUG-2001    Bug Id : 1956374. Removed procedure "prgp_val_cause_ind"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_att_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cgr_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  --Nalin Kumar 12-NOV-2002    Modified 'PRGP_VAL_PRO_POT' function as per the FA110 PR-ENH. Bug# 2658550
  -------------------------------------------------------------------------------------------
  --
  -- Validate progression outcome type clolsed indicator
  FUNCTION prgp_val_pot_closed(
  p_progression_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pot_closed
  	-- Validate the progression_outcome_type is not closed.
  DECLARE
  	v_dummy                         VARCHAR2(1);
  	CURSOR	c_pot IS
  	SELECT	'X'
  	FROM	IGS_PR_OU_TYPE	pot
  	WHERE	pot.progression_outcome_type	= p_progression_outcome_type AND
  		pot.closed_ind			= 'N';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot;
  	FETCH c_pot INTO v_dummy;
  	IF c_pot%NOTFOUND THEN
  		CLOSE c_pot;
  		p_message_name := 'IGS_PR_PRG_OUT_TYCLD';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pot;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pot_closed;
  --
  -- Validate progression rule outcome restrict attendance type
  FUNCTION prgp_val_pro_att(
  p_progression_outcome_type IN VARCHAR2 ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pro_att
  	-- Validate that if progression_rule_outcome.restricted_attendance_type is set
  	-- that the progression_outcome_type relates to a s_encmb_effect_type of
  	-- RSTR_AT_TY
  DECLARE
  	cst_rstr_at_ty	CONSTANT	VARCHAR(10) := 'RSTR_AT_TY';
  	v_dummy                         VARCHAR2(1);
  	CURSOR c_pot IS
  	SELECT 		'X'
  	FROM		IGS_PR_OU_TYPE 		pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  	WHERE		pot.progression_outcome_type 	= p_progression_outcome_type AND
  		 	pot.encumbrance_type		= etde.encumbrance_type AND
  			etde.s_encmb_effect_type		= cst_rstr_at_ty;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL OR
  			p_restricted_attendance_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot;
  	FETCH c_pot INTO v_dummy;
  	IF c_pot%NOTFOUND THEN
  		CLOSE c_pot;
  		p_message_name := 'IGS_PR_RSTR_AT_TY';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pot;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_att;
  --
  -- Validate progression rule outcome automatically apply indicator
  FUNCTION prgp_val_pro_auto(
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_progression_outcome_type IN VARCHAR2 ,
  p_apply_automatically_ind IN VARCHAR2,
  p_encmb_course_group_cd IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pro_auto
  	-- Validate that if progression_rule_outcome.apply_automatically_ind is set
  	-- to 'Y' that the progression_outcome_type relates to a s_encmb_effect_type of
  	-- EXC_COURSE, EXC_CRS_GP or SUS_COURSE
  DECLARE
  	cst_exc_course		CONSTANT	VARCHAR2(10) := 'EXC_COURSE';
  	cst_exc_crs_gp		CONSTANT	VARCHAR2(10) := 'EXC_CRS_GP';
  	cst_sus_course		CONSTANT	VARCHAR2(10) := 'SUS_COURSE';
  	cst_exc_crs_us		CONSTANT	VARCHAR2(10) := 'EXC_CRS_US';
  	cst_exc_crs_u		CONSTANT	VARCHAR2(10) := 'EXC_CRS_U';
  	cst_rqrd_crs_u		CONSTANT	VARCHAR2(10) := 'RQRD_CRS_U';
  	cst_rstr_ge_cp		CONSTANT	VARCHAR2(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp		CONSTANT	VARCHAR2(10) := 'RSTR_LE_CP';
  	cst_rstr_at_ty		CONSTANT	VARCHAR2(10) := 'RSTR_AT_TY';
  	cst_excluded		CONSTANT	VARCHAR2(10) := 'EXCLUDED';
  	cst_required		CONSTANT	VARCHAR2(10) := 'REQUIRED';
  	v_exit			BOOLEAN                      := FALSE;
  	v_dummy                 VARCHAR2(1);
  	CURSOR c_pot_etde IS
  		SELECT 		etde.s_encmb_effect_type
  		FROM		IGS_PR_OU_TYPE 	pot,
  				IGS_FI_ENC_DFLT_EFT		etde
  		WHERE		pot.progression_outcome_type 	= p_progression_outcome_type AND
  			 	pot.encumbrance_type		= etde.encumbrance_type;
  	CURSOR c_pous IS
  		SELECT		'X'
  		FROM		IGS_PR_OU_UNIT_SET
  		WHERE		progression_rule_cat 		= p_progression_rule_cat AND
  				pra_sequence_number 		= p_pra_sequence_number AND
  				pro_sequence_number 		= p_sequence_number;
  	CURSOR c_pou_1 IS
  		SELECT		'X'
  		FROM		IGS_PR_OU_UNIT
  		WHERE		progression_rule_cat 		= p_progression_rule_cat AND
  				pra_sequence_number 		= p_pra_sequence_number AND
  				pro_sequence_number 		= p_sequence_number AND
  				s_unit_type			= cst_excluded;
  	CURSOR c_pou_2 IS
  		SELECT		'X'
  		FROM		IGS_PR_OU_UNIT
  		WHERE		progression_rule_cat 		= p_progression_rule_cat AND
  				pra_sequence_number 		= p_pra_sequence_number AND
  				pro_sequence_number 		= p_sequence_number AND
  				s_unit_type			= cst_required;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_rule_cat IS NULL OR
     			p_pra_sequence_number IS NULL OR
     			p_sequence_number IS NULL OR
  			p_progression_outcome_type IS NULL OR
  			p_apply_automatically_ind = 'N' THEN
  		RETURN TRUE;
  	END IF;
  	FOR v_pot_etde_rec IN c_pot_etde LOOP
  		-- If related encumbrance effects contain EXC_COURSE,EXC_CRS_GP or SUS_COURSEE
  		-- then raise error
  		IF v_pot_etde_rec.s_encmb_effect_type IN (
  							cst_exc_course,
  							cst_exc_crs_gp,
  							cst_sus_course) THEN
  			p_message_name := 'IGS_PR_EXC_CRS_GP_SUS';
  			v_exit := TRUE;
  			EXIT;
  		END IF;
  		-- If related encumbrance effects contain EXC_CRS_US, then at least one
  		-- record must exist in the prg_outcome_unit_set table
  		IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_us THEN
  			OPEN c_pous;
  			FETCH c_pous INTO v_dummy;
  			IF c_pous%NOTFOUND THEN
  				CLOSE c_pous;
  				p_message_name := 'IGS_PR_APAUO_SOT_EMEF_USER_CR';
  				v_exit := TRUE;
  				EXIT;
  			ELSE
  				CLOSE c_pous;
  			END IF;
  		END IF;
  		-- If related encumbrance effects contain EXC_CRS_U, then record must exist
  		-- in the prg_outcome_unit table with s_unit_type of 'EXCLUDED'
  		IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_u THEN
  			OPEN c_pou_1;
  			FETCH c_pou_1 INTO v_dummy;
  			IF c_pou_1%NOTFOUND THEN
  				CLOSE c_pou_1;
  				p_message_name := 'IGS_PR_APAUO_SOT_EMEF_UER_CR';
  				v_exit := TRUE;
  				EXIT;
  			ELSE
  				CLOSE c_pou_1;
  			END IF;
  		END IF;
  		-- If related encumbrance effects contain RQRD_CRS_U, then a record must
  		-- exist in the prg_outcome_unit table with s_unit_type of 'REQUIRED'
  		IF v_pot_etde_rec.s_encmb_effect_type = cst_rqrd_crs_u THEN
  			OPEN c_pou_2;
  			FETCH c_pou_2 INTO v_dummy;
  			IF c_pou_2%NOTFOUND THEN
  				CLOSE c_pou_2;
  				p_message_name := 'IGS_PR_APAUO_SOT_EMEF_UROR_CR';
  				v_exit := TRUE;
  				EXIT;
  			ELSE
  				CLOSE c_pou_2;
  			END IF;
  		END IF;
  		-- If related encumbrance effects contain RSTR_{GE,LE}_CP then
  		-- pro.restricted_enrolment_cp must be set
  		IF v_pot_etde_rec.s_encmb_effect_type IN (
  							cst_rstr_ge_cp,
  							cst_rstr_le_cp) AND
  				NVL(p_restricted_enrolment_cp, 0) = 0 THEN
  			p_message_name := 'IGS_PR_APTUO_SOT_CPR_RNCV_EN';
  			v_exit := TRUE;
  			EXIT;
  		END IF;
  		-- If related encumbrance effects contain RSTR_AT_TY,  then
  		-- pro.restricted_attendance_type must be set
  		IF v_pot_etde_rec.s_encmb_effect_type = cst_rstr_at_ty AND
  				p_restricted_attendance_type IS NULL THEN
  			p_message_name := 'IGS_PR_APTUO_SOT_ATYR_RATY_EN';
  			v_exit := TRUE;
  			EXIT;
  		END IF;
  		-- If related encumbrance effects contain EXC_CRS_GP, then
  		-- pro.encmb_course_group_cd must be set
  		IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_gp AND
  				p_encmb_course_group_cd IS NULL THEN
  			p_message_name := 'IGS_PR_APTUO_SOT_ENE_CGE_EN';
  			v_exit := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_exit THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot_etde%ISOPEN THEN
  			CLOSE c_pot_etde;
  		END IF;
  		IF c_pous%ISOPEN THEN
  			CLOSE c_pous;
  		END IF;
  		IF c_pou_1%ISOPEN THEN
  			CLOSE c_pou_1;
  		END IF;
  		IF c_pou_2%ISOPEN THEN
  			CLOSE c_pou_2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_auto;
  --
  -- Validate progression rule outcome exclude course group
  FUNCTION prgp_val_pro_cgr(
  p_progression_outcome_type IN VARCHAR2 ,
  p_encmb_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pro_cgr
  	-- Validate that if progression_rule_outcome.encmb_course-group_cd is set
  	--that the progression-outcome_type relates to a s_encmb_effect_type of
  	-- EXC_CRS_GP
  DECLARE
  	cst_exc_crs_gp  CONSTANT	VARCHAR2(10) := 'EXC_CRS_GP';
  	v_dummy                         VARCHAR2(1);
  	CURSOR	c_pot IS
  	SELECT	'X'
  	FROM	IGS_PR_OU_TYPE 		pot,
  		IGS_FI_ENC_DFLT_EFT 		etde
  	WHERE	pot.progression_outcome_type 	= p_progression_outcome_type AND
  		pot.encumbrance_type 		= etde.encumbrance_type AND
  		etde.s_encmb_effect_type 		= cst_exc_crs_gp;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL OR
  			p_encmb_course_group_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot;
  	FETCH c_pot INTO v_dummy;
  	IF c_pot%NOTFOUND THEN
  		CLOSE c_pot;
  		p_message_name := 'IGS_PR_ENCGP_EXC_CRS_GP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pot;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_cgr;
  --
  -- Validate progression outcome type restrict enrolled credit points
  FUNCTION prgp_val_pro_cp(
  p_progression_outcome_type IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pro_cp
  	-- Validate that if progression_rule_outcome.restricted_enrolment_cp is set
  	--that the progression_outcome_type relates to a s_encmb_effect_type of
  	-- RSTR_GE_CP or RSTR_LE_CP.
  DECLARE
  	cst_rstr_ge_cp	CONSTANT	VARCHAR2(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp  CONSTANT	VARCHAR2(10) := 'RSTR_LE_CP';
  	v_dummy                         VARCHAR2(1);
  	CURSOR	c_pot IS
  	SELECT	'X'
  	FROM	IGS_PR_OU_TYPE 		pot,
  		IGS_FI_ENC_DFLT_EFT 		etde
  	WHERE	pot.progression_outcome_type 		= p_progression_outcome_type AND
  		pot.encumbrance_type 			= etde.encumbrance_type AND
  		etde.s_encmb_effect_type 		IN (	cst_rstr_ge_cp,
  							cst_rstr_le_cp);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL OR
  			p_restricted_enrolment_cp IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot;
  	FETCH c_pot INTO v_dummy;
  	IF c_pot%NOTFOUND THEN
  		CLOSE c_pot;
  		p_message_name := 'IGS_PR_RSTR_GE_LE_CP';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_pot;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_cp;
  --
  -- Validate progression rule outcome progression outcome type
  FUNCTION prgp_val_pro_pot(
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_progression_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  ----------------------------------------------------------------------------
  --Change History:
  --Who         When        What
  --kdande      17-Jul-2002 Changed message name to IGS_PR_PROT_TY_INCO_EPOCR
  --                        from 5149 for Bug# 2462120
  --Nalin Kumar 12-NOV-2002 Modified this function as per the FA110 PR-ENH. Bug# 2658550
  ----------------------------------------------------------------------------
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- Validate  changes to the progression_rule_outcome.progression_outcome
  	--_type.
   	-- * If prg_outcome_course records exist the progression_outcome_type must
  	-- relate to a s_encmb_effect_type of EXC_COURSE or SUS_COURSE.
   	-- * If prg_outcome_unit_set records exist the progression_outcome_type
  	-- must relate to a s_encmb_effect_type of EXC_CRS_US.
   	-- * If prg_outcome_unit records exist the progression_outcome_type
  	-- must relate to a s_encmb_effect_type of EXC_CRS_U when s_unit_type = EXCLUDE
  	-- or a s_encmb_effect_type of RQRD_CRS_U when s_unit_type = REQUIRED.
   	-- * If prg_outcome_fund records exist the progression_outcome_type must
  	-- relate to a s_encmb_effect_type of EX_FUND.
  DECLARE
  	cst_exc_course	 CONSTANT	VARCHAR2(10) := 'EXC_COURSE';
  	cst_sus_course	 CONSTANT	VARCHAR2(10) := 'SUS_COURSE';
  	cst_exc_crs_us	 CONSTANT	VARCHAR2(10) := 'EXC_CRS_US';
  	cst_exc_crs_u	 CONSTANT	VARCHAR2(10) := 'EXC_CRS_U';
  	cst_rqrd_crs_u	 CONSTANT	VARCHAR2(10) := 'RQRD_CRS_U';
  	cst_excluded	 CONSTANT	VARCHAR2(10) := 'EXCLUDED';
  	cst_required	 CONSTANT	VARCHAR2(10) := 'REQUIRED';
  	cst_exe_fund	 CONSTANT	VARCHAR2(10) := 'EX_FUND';
  	v_dummy                         VARCHAR2(1);
  	v_record_not_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_poc IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_PS 		poc
  		WHERE	poc.progression_rule_cat 	= p_progression_rule_cat  AND
  			poc.pra_sequence_number		= p_pra_sequence_number	AND
  			poc.pro_sequence_number		= p_sequence_number;
  	CURSOR c_pot_etde1 IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_TYPE	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type 	= p_progression_outcome_type  AND
  			pot.encumbrance_type		= etde.encumbrance_type	AND
  			etde.s_encmb_effect_type	IN (
  							cst_exc_course,
  							cst_sus_course);
  	CURSOR c_pous IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_UNIT_SET		pous
  		WHERE	pous.progression_rule_cat	= p_progression_rule_cat  AND
  			pous.pra_sequence_number	= p_pra_sequence_number	AND
  			pous.pro_sequence_number	= p_sequence_number;
  	CURSOR c_pot_etde2 IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_TYPE	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type	= p_progression_outcome_type  AND
  			pot.encumbrance_type		= etde.encumbrance_type	AND
  			etde.s_encmb_effect_type	= cst_exc_crs_us;
  	CURSOR c_popu IS
  		SELECT	DISTINCT s_unit_type
  		FROM	IGS_PR_OU_UNIT		popu
  		WHERE	popu.progression_rule_cat	= p_progression_rule_cat  AND
  			popu.pra_sequence_number	= p_pra_sequence_number	AND
  			popu.pro_sequence_number	= p_sequence_number;
  	CURSOR c_pot_etde3 IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_TYPE	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type	= p_progression_outcome_type  AND
  			pot.encumbrance_type		= etde.encumbrance_type	AND
  			etde.s_encmb_effect_type	= cst_exc_crs_u;
  	CURSOR c_pot_etde4 IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_TYPE	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type	= p_progression_outcome_type  AND
  			pot.encumbrance_type		= etde.encumbrance_type	AND
  			etde.s_encmb_effect_type	= cst_rqrd_crs_u;
        -- Added as per the FA110 PR ENH. Bug# 2658550
  	CURSOR c_pof IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_FND pof
  		WHERE	pof.progression_rule_cat = p_progression_rule_cat  AND
  			pof.pra_sequence_number	 = p_pra_sequence_number   AND
  			pof.pro_sequence_number	 = p_sequence_number;

	CURSOR c_pot_etde5 IS
  		SELECT	'X'
  		FROM	IGS_PR_OU_TYPE	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type	= p_progression_outcome_type  AND
  			pot.encumbrance_type		= etde.encumbrance_type	AND
  			etde.s_encmb_effect_type	= cst_exe_fund;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_rule_cat IS NULL OR
  			p_pra_sequence_number IS NULL OR
  			p_progression_outcome_type IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;

	OPEN c_poc;
  	FETCH c_poc INTO v_dummy;
  	IF c_poc%FOUND THEN
  		CLOSE c_poc;
  		OPEN c_pot_etde1;
  		FETCH c_pot_etde1 INTO v_dummy;
  		IF c_pot_etde1%NOTFOUND THEN
  			CLOSE c_pot_etde1;
                        -- Start of fix for Bug# 2462120
  			p_message_name := 'IGS_PR_PROT_TY_INCO_EPOCR';
                        -- End of fix for Bug# 2462120
  			RETURN FALSE;
  		END IF;
  		CLOSE c_pot_etde1;
  	ELSE
  		CLOSE c_poc;
  	END IF;

	OPEN c_pous;
  	FETCH c_pous INTO v_dummy;
  	IF c_pous%FOUND THEN
  		CLOSE c_pous;
  		OPEN c_pot_etde2;
  		FETCH c_pot_etde2 INTO v_dummy;
  		IF c_pot_etde2%NOTFOUND THEN
  			CLOSE c_pot_etde2;
  			p_message_name := 'IGS_PR_PROUT_TYICM_EPOU_STRE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_pot_etde2;
  	ELSE
  		CLOSE c_pous;
  	END IF;
  	FOR v_popu_rec IN c_popu LOOP
  		IF v_popu_rec.s_unit_type = cst_excluded THEN
  			OPEN c_pot_etde3;
  			FETCH c_pot_etde3 INTO v_dummy;
  			IF c_pot_etde3%NOTFOUND THEN
  				CLOSE c_pot_etde3;
  				p_message_name := 'IGS_PR_PROUT_TYICM_EPOU_RE';
  				v_record_not_found := TRUE;
  				EXIT;
  			END IF;
  			CLOSE c_pot_etde3;
  		ELSE
  			OPEN c_pot_etde4;
  			FETCH c_pot_etde4 INTO v_dummy;
  			IF c_pot_etde4%NOTFOUND THEN
  				CLOSE c_pot_etde4;
  				p_message_name := 'IGS_PR_PROUT_TYICM_EPOU_RE';
  				v_record_not_found := TRUE;
  				EXIT;
  			END IF;
  			CLOSE c_pot_etde4;
  		END IF;
  	END LOOP;
	--
        --Start of code added as per the FA110 PR-ENH. Bug# 2658550
	--
  	OPEN c_pof;
  	FETCH c_pof INTO v_dummy;
  	IF c_pof%FOUND THEN
  		CLOSE c_pof;
  		OPEN c_pot_etde5;
  		FETCH c_pot_etde5 INTO v_dummy;
  		IF c_pot_etde5%NOTFOUND THEN
  			CLOSE c_pot_etde5;
  			p_message_name := 'IGS_PR_PROT_TY_INCO_FUND';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_pot_etde5;
  	ELSE
  		CLOSE c_pof;
  	END IF;
	--
        --End of code added as per the FA110 PR-ENH. Bug# 2658550
	--

	IF v_record_not_found THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_poc%ISOPEN THEN
  			CLOSE c_poc;
  		END IF;
  		IF c_pot_etde1%ISOPEN THEN
  			CLOSE c_pot_etde1;
  		END IF;
  		IF c_pous%ISOPEN THEN
  			CLOSE c_pous;
  		END IF;
  		IF c_pot_etde2%ISOPEN THEN
  			CLOSE c_pot_etde2;
  		END IF;
  		IF c_popu%ISOPEN THEN
  			CLOSE c_popu;
  		END IF;
  		IF c_pot_etde3%ISOPEN THEN
  			CLOSE c_pot_etde3;
  		END IF;
  		IF c_pot_etde4%ISOPEN THEN
  			CLOSE c_pot_etde4;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
   		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_pot;
  --
  -- Validate progression rule outcome has required details
  FUNCTION prgp_val_pro_rqrd(
  p_progression_outcome_type IN VARCHAR2 ,
  p_duration IN NUMBER ,
  p_duration_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_pro_rqrd
  	-- Validate that if progression_rule_outcome has the required details:
  	--1. If duration_type is specified as (NORMAL or EFFECTIVE) then a duration
  	-- must be specified and vice versa
  	--2. If related s_progression_type is SUSPENSION, then duration and duration_
  	--type must be specified
  	--3. If related s_progression_outcome_type is EXCLUSION, EXPULSION, NOPENALTY,
  	--  MANUAL or EX_FUND, then duration and duration_type cannot be specified
  	--4. If related s_progress_outcome_type not PROBATION then duration_type
  	--cannot be effective
  DECLARE
  	v_s_progression_outcome_type    IGS_PR_OU_TYPE.s_progression_outcome_type%TYPE;
  	cst_suspension	 CONSTANT	VARCHAR2(10) := 'SUSPENSION';
  	cst_exclusion	 CONSTANT	VARCHAR2(10) := 'EXCLUSION';
  	cst_expulsion	 CONSTANT	VARCHAR2(10) := 'EXPULSION';
  	cst_nopenalty	 CONSTANT	VARCHAR2(10) := 'NOPENALTY';
  	cst_manual	 CONSTANT	VARCHAR2(10) := 'MANUAL';
  	cst_probation	 CONSTANT	VARCHAR2(10) := 'PROBATION';
  	cst_effective	 CONSTANT	VARCHAR2(10) := 'EFFECTIVE';
	cst_ex_fund      CONSTANT	VARCHAR2(10) := 'EX_FUND';
  	CURSOR c_pot IS
  	SELECT	pot.s_progression_outcome_type
  	FROM	IGS_PR_OU_TYPE pot
  	WHERE	pot.progression_outcome_type = p_progression_outcome_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF (p_duration_type IS NULL AND
  			p_duration IS NOT NULL) THEN
  		p_message_name := 'IGS_PR_DU_SET_DTYP_MSET';
  		RETURN FALSE;
  	END IF;
  	IF (p_duration_type IS NOT NULL AND
  			p_duration IS NULL) THEN
  		p_message_name := 'IGS_PR_DUTY_SET_DU_MSET';
  		RETURN FALSE;
  	END IF;
  	IF p_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot;
  	FETCH c_pot INTO v_s_progression_outcome_type;
  	IF c_pot%NOTFOUND THEN
  		CLOSE c_pot;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_pot;
  	IF v_s_progression_outcome_type = cst_suspension AND
  			p_duration IS NULL THEN
  		p_message_name := 'IGS_PR_DU_DUTY_SUS';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_progression_outcome_type = cst_exclusion OR
  		v_s_progression_outcome_type = cst_expulsion OR
  		v_s_progression_outcome_type = cst_ex_fund OR
  		v_s_progression_outcome_type = cst_nopenalty) AND
  		p_duration IS NOT NULL THEN
  			p_message_name := 'IGS_PR_DUTY_PRTY_EXC_NOP';
  			RETURN FALSE;
  	END IF;
  	IF v_s_progression_outcome_type NOT IN (cst_probation,cst_manual) AND
  			p_duration_type = cst_effective THEN
  		p_message_name := 'IGS_PR_DTYP_CNTEF_PRO_MAN';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot%ISOPEN THEN
  			CLOSE c_pot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_pro_rqrd;
END IGS_PR_VAL_PRO;

/
