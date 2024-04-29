--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_POT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_POT" AS
/* $Header: IGSPR03B.pls 115.8 2002/11/29 05:17:58 nalkumar ship $ */
  -- Validate the dflt_restricted_enrolment_cp field.
--
-- bug id : 1956374
-- sjadhav ,28-aug-2001
-- removed function enrp_val_et_closed
--
----------------------------------------------------------------------------
--  Change History :
--  Who             When            What
-- ayedubat      15-DEC-2001   Enhance Bug no : 2138644 , changed the Function, prgp_val_pot_et
-- avenkatr      30-AUG-2001   Bug Id: 1956374, Removed procedure "crsp_val_att_closed"
-- Nalin Kumar   12-NOV-2002   Modified the 'prgp_val_pot_et' function as per the FA110 PR-ENH. bug# 2658550
----------------------------------------------------------------------------
  FUNCTION prgp_val_pot_att(
  p_dflt_restricted_att_type IN VARCHAR2 ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_pot_att
  	-- Validate the IGS_PR_OU_TYPE.dflt_restricted_att_type field.
  	-- Should only be specified where the related encumbrance type has a
  	-- restricted attendance type related effect.
  DECLARE
  	cst_rstr_at_ty		CONSTANT	VARCHAR2(10) := 'RSTR_AT_TY';
  	v_dummy					VARCHAR2(1);
  	CURSOR c_etde IS
  		SELECT	'X'
  		FROM	IGS_FI_ENC_DFLT_EFT 	etde
  		WHERE	etde.encumbrance_type	= p_encumbrance_type AND
  			etde.s_encmb_effect_type	= cst_rstr_at_ty;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_dflt_restricted_att_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_encumbrance_type IS NULL THEN
  		p_message_name := 'IGS_PR_CHK_DFLT_ATTEND_TYPE';
  		RETURN FALSE;
  	END IF;
  	OPEN c_etde;
  	FETCH c_etde INTO v_dummy;
  	IF c_etde%NOTFOUND THEN
  		CLOSE c_etde;
  		p_message_name := 'IGS_PR_CHK_DFLT_ATTEND_TYPE';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_etde;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_etde%ISOPEN THEN
  			CLOSE c_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_POT_ATT');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pot_att;

  -- Validate the dflt_restricted_enrolment_cp field.
  FUNCTION prgp_val_pot_cp(
  p_dflt_restricted_enrolment_cp IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_pot_cp
  	-- Validate the IGS_PR_OU_TYPE.dflt_restricted_enrolment_cp field.
  	-- Should only be specified where the related encumbrance type has a
  	-- restricted enrolment related effect.
  DECLARE
  	cst_rstr_ge_cp		CONSTANT	VARCHAR2(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp		CONSTANT	VARCHAR2(10) := 'RSTR_LE_CP';
  	v_dummy					VARCHAR2(1);
  	CURSOR c_etde IS
  		SELECT	'X'
  		FROM	IGS_FI_ENC_DFLT_EFT 	etde
  		WHERE	etde.encumbrance_type	= p_encumbrance_type AND
  			etde.s_encmb_effect_type IN (
  						cst_rstr_ge_cp,
  						cst_rstr_le_cp);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_dflt_restricted_enrolment_cp IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_encumbrance_type IS NULL THEN
  		p_message_name := 'IGS_PR_SPECIF_ONLY_DFT_ENR_CP';
  		RETURN FALSE;
  	END IF;
  	OPEN c_etde;
  	FETCH c_etde INTO v_dummy;
  	IF c_etde%NOTFOUND THEN
  		CLOSE c_etde;
  		p_message_name := 'IGS_PR_SPECIF_ONLY_DFT_ENR_CP';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_etde;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_etde%ISOPEN THEN
  			CLOSE c_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_POT_CP');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pot_cp;

  -- Validate the Encumbrance Type.
  FUNCTION prgp_val_pot_et(
  p_s_progression_outcome_type IN VARCHAR2 ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  /* Change History
   WHO         WHEN              WHAT
   ayedubat    15/12/2001        Added the Validation if the System Progression Outcome Type
                                 is 'AWARD' as per Enhancement Bug No : 2138644
   Nalin Kumar 13/11/2002        Added the Validation if the System Progression Outcome Type
                                 is 'FUND' as per Enhancement Bug No : 2658550  */

  BEGIN 	-- prgp_val_pot_et
  	-- Validate the encumbrance type for a IGS_PR_OU_TYPE record based
  	-- on the s_progression_outcome_type which has been entered.
  DECLARE
  	cst_academic		CONSTANT	VARCHAR2(10) := 'ACADEMIC';
  	cst_expulsion		CONSTANT	VARCHAR2(10) := 'EXPULSION';
  	cst_exclusion		CONSTANT	VARCHAR2(10) := 'EXCLUSION';
  	cst_suspension		CONSTANT	VARCHAR2(10) := 'SUSPENSION';
  	cst_probation		CONSTANT	VARCHAR2(10) := 'PROBATION';
  	cst_nopenalty		CONSTANT	VARCHAR2(10) := 'NOPENALTY';
  	cst_manual		CONSTANT	VARCHAR2(10) := 'MANUAL';
  	cst_award		CONSTANT	VARCHAR2(10) := 'AWARD';
  	cst_sus			CONSTANT	VARCHAR2(10) := 'SUS%';
  	cst_sus_course		CONSTANT	VARCHAR2(10) := 'SUS_COURSE';
  	cst_exc			CONSTANT	VARCHAR2(10) := 'EXC%';
  	cst_exc_course		CONSTANT	VARCHAR2(10) := 'EXC_COURSE';
  	cst_exc_crs_gp		CONSTANT	VARCHAR2(10) := 'EXC_CRS_GP';
  	cst_rqrd_crs_u		CONSTANT	VARCHAR2(10) := 'RQRD_CRS_U';
  	cst_rstr_ge_cp		CONSTANT	VARCHAR2(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp		CONSTANT	VARCHAR2(10) := 'RSTR_LE_CP';
  	cst_rstr_at_ty		CONSTANT	VARCHAR2(10) := 'RSTR_AT_TY';
--
  	cst_ex_fund		CONSTANT	VARCHAR2(15) := 'EX_FUND';
	cst_ex_sp_awd		CONSTANT	VARCHAR2(10) := 'EX_SP_AWD';
	cst_ex_sp_disb		CONSTANT	VARCHAR2(10) := 'EX_SP_DISB';
 	cst_ex_awd		CONSTANT	VARCHAR2(10) := 'EX_AWD';
 	cst_ex_disb		CONSTANT	VARCHAR2(10) := 'EX_DISB';
  	v_ex_fund_1_exists	BOOLEAN                      := FALSE;

--
	v_s_encumbrance_cat			IGS_FI_ENCMB_TYPE.s_encumbrance_cat%TYPE;
  	v_suspension_1_exists			BOOLEAN := FALSE;
  	v_suspension_2_exists			BOOLEAN := FALSE;
  	v_exclusion_1_exists			BOOLEAN := FALSE;
  	v_exclusion_2_exists			BOOLEAN := FALSE;
  	v_expulsion_1_exists			BOOLEAN := FALSE;
  	v_probation_1_exists			BOOLEAN := FALSE;
  	v_probation_2_exists			BOOLEAN := FALSE;
  	CURSOR c_et IS
  		SELECT 	et.s_encumbrance_cat
  		FROM	IGS_FI_ENCMB_TYPE 		et
  		WHERE	et.encumbrance_type		= p_encumbrance_type;
  	CURSOR c_edte IS
  		SELECT	edte.s_encmb_effect_type
  		FROM	IGS_FI_ENC_DFLT_EFT 		edte
  		WHERE	edte.encumbrance_type		= p_encumbrance_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_s_progression_outcome_type IN (
  					cst_expulsion,
  					cst_exclusion,
  					cst_suspension,
  					cst_probation,
					cst_ex_fund) AND
  			p_encumbrance_type IS NULL THEN
  		p_message_name := 'IGS_PR_CHK_PRG_OUT_TYPE';
  		RETURN FALSE;
  	END IF;
  	IF p_encumbrance_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_et;
  	FETCH c_et INTO v_s_encumbrance_cat;
  	IF c_et%FOUND THEN
  		CLOSE c_et;
  		IF v_s_encumbrance_cat <> cst_academic THEN
  			p_message_name := 'IGS_PR_ENCUM_TYPE_MUST_BE_ACA';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_et;
  		RETURN TRUE;
  	END IF;
  	FOR v_edte_rec IN c_edte LOOP
  		IF p_s_progression_outcome_type = cst_suspension THEN
  			IF v_edte_rec.s_encmb_effect_type = cst_sus_course THEN
  				v_suspension_1_exists := TRUE;
  			END IF;
  			IF v_edte_rec.s_encmb_effect_type LIKE cst_exc THEN
  				v_suspension_2_exists := TRUE;
  			END IF;
  		END IF;
  		IF p_s_progression_outcome_type IN (
  						cst_exclusion,
  						cst_expulsion) THEN
  			IF p_s_progression_outcome_type = cst_exclusion THEN
  				v_expulsion_1_exists := TRUE;
  				IF v_edte_rec.s_encmb_effect_type LIKE cst_exc THEN
  					v_exclusion_1_exists := TRUE;
  				END IF;
  			ELSE
  				v_exclusion_1_exists := TRUE;
  				IF v_edte_rec.s_encmb_effect_type IN (
  								cst_exc_course,
  								cst_exc_crs_gp) THEN
  					v_expulsion_1_exists := TRUE;
  				END IF;
  			END IF;
  			IF v_edte_rec.s_encmb_effect_type LIKE cst_sus THEN
  				v_exclusion_2_exists := TRUE;
  			END IF;
  		END IF;
  		IF p_s_progression_outcome_type = cst_probation THEN
  			IF v_edte_rec.s_encmb_effect_type IN (
  							cst_rqrd_crs_u,
  							cst_rstr_ge_cp,
  							cst_rstr_le_cp,
  							cst_rstr_at_ty) THEN
  				v_probation_1_exists := TRUE;
  			END IF;
  			IF v_edte_rec.s_encmb_effect_type LIKE cst_sus OR
  					v_edte_rec.s_encmb_effect_type LIKE cst_exc THEN
  				v_probation_2_exists := TRUE;
  			END IF;
  		END IF;
		--Start of new code added as per FA110 PR-ENH. bug# 2658550
		IF p_s_progression_outcome_type = cst_ex_fund THEN
		     IF v_edte_rec.s_encmb_effect_type IN (cst_ex_sp_awd, cst_ex_sp_disb, cst_ex_awd, cst_ex_disb) THEN
			  v_ex_fund_1_exists := TRUE;
		      END IF;
		 END IF;
		--End of new code added as per FA110 PR-ENH. bug# 2658550
  	END LOOP;
  	IF p_s_progression_outcome_type = cst_suspension THEN
  		IF NOT v_suspension_1_exists THEN
  			p_message_name := 'IGS_PR_CHK_SUSP_PRG_OUTCOME';
  			RETURN FALSE;
  		END IF;
  		IF v_suspension_2_exists THEN
  			p_message_name := 'IGS_PR_CHK_SUSP_PRG_OUT_TYPES';
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END IF;
  	IF p_s_progression_outcome_type IN (
  					cst_exclusion,
  					cst_expulsion) THEN
  		IF NOT v_exclusion_1_exists OR
  				NOT v_expulsion_1_exists THEN
  			p_message_name := 'IGS_PR_CHK_EXCL_PRG_OUT_TYPES';
  			RETURN FALSE;
  		END IF;
  		IF v_exclusion_2_exists THEN
  			p_message_name := 'IGS_PR_CHK_EXPL_PRG_OUT_TYPES';
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END IF;
  	IF p_s_progression_outcome_type = cst_probation THEN
  		IF NOT v_probation_1_exists THEN
  			p_message_name := 'IGS_PR_CHK_PROB_PRG_OUT_TYPES';
  			RETURN FALSE;
  		END IF;
  		IF v_probation_2_exists THEN
  			p_message_name := 'IGS_PR_INVALID_PRG_OUTCOMES';
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END IF;
  	IF p_s_progression_outcome_type = cst_nopenalty AND
  			p_encumbrance_type IS NOT NULL THEN
  		p_message_name :='IGS_PR_CANNOT_LNK_NO_PRG_OUT';
  		RETURN FALSE;
  	END IF;
  	IF p_s_progression_outcome_type = cst_manual AND
  			p_encumbrance_type IS NOT NULL THEN
  		p_message_name := 'IGS_PR_CANT_LINK_MANUAL_PRG';
  		RETURN FALSE;
  	END IF;
  	IF p_s_progression_outcome_type = cst_award AND
  			p_encumbrance_type IS NOT NULL THEN
  		p_message_name := 'IGS_PR_CANT_LINK_AWARD_PRG';
  		RETURN FALSE;
  	END IF;
	--Start of new code added as per FA110 PR-ENH. bug# 2658550
	IF p_s_progression_outcome_type = cst_ex_fund THEN
  	  IF NOT v_ex_fund_1_exists THEN
  	    p_message_name := 'IGS_PR_CHK_EX_FND_PRG_OUT_TYPE';
  	    RETURN FALSE;
  	  END IF;
  	END IF;
	--End of new code added as per FA110 PR-ENH. bug# 2658550
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_et%ISOPEN THEN
  			CLOSE c_et;
  		END IF;
  		IF c_edte%ISOPEN THEN
  			CLOSE c_edte;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_POT_ET');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pot_et;

  -- Validate the Change of Encumbrance Type.
  FUNCTION prgp_val_pot_et_upd(
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_encumbrance_type IN VARCHAR2 ,
  p_new_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_pot_et_upd
  	-- Validate the change of encumbrance type for a progression outcome type.
  	-- The encumbrance type cannot be changed once the progression outcome type
  	-- has been used.
  DECLARE
  	v_dummy			VARCHAR2(1);
  	CURSOR c_pro IS
  		SELECT	'X'
  		FROM	IGS_PR_RU_OU 	pro
  		WHERE	pro.progression_outcome_type	= p_progression_outcome_type;
  	CURSOR c_spo IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_OU 	spo
  		WHERE	spo.progression_outcome_type	= p_progression_outcome_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF NVL(p_old_encumbrance_type, ' ') = NVL(p_new_encumbrance_type, ' ') THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pro;
  	FETCH c_pro INTO v_dummy;
  	IF c_pro%FOUND THEN
  		CLOSE c_pro;
  		p_message_name := 'IGS_PR_ENCUM_TYPE_CANT_CHANGE';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_pro;
  		OPEN c_spo;
  		FETCH c_spo INTO v_dummy;
  		IF c_spo%FOUND THEN
  			CLOSE c_spo;
  			p_message_name := 'IGS_PR_ENCUM_TYPE_CANT_CHANGE';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_spo;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pro%ISOPEN THEN
  			CLOSE c_pro;
  		END IF;
  		IF c_spo%ISOPEN THEN
  			CLOSE c_spo;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_POT_ET_UPD');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pot_et_upd;

  -- Validate the Change of System Progression Outcome Type.
  FUNCTION prgp_val_pot_spot_u(
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_s_prg_outcome_type IN VARCHAR2 ,
  p_new_s_prg_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_pot_spot_u
  	-- Validate the change of system progression outcome type for a progression
  	-- outcome type.
  	-- The system type cannot be changed once the progression outcome type has
  	-- been used.
  DECLARE
  	v_dummy			VARCHAR2(1);
  	CURSOR c_pro IS
  		SELECT	'X'
  		FROM	IGS_PR_RU_OU 	pro
  		WHERE	pro.progression_outcome_type	= p_progression_outcome_type;
  	CURSOR c_spo IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_OU 	spo
  		WHERE	spo.progression_outcome_type	= p_progression_outcome_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF NVL(p_old_s_prg_outcome_type, ' ') = NVL(p_new_s_prg_outcome_type, ' ') THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pro;
  	FETCH c_pro INTO v_dummy;
  	IF c_pro%FOUND THEN
  		CLOSE c_pro;
  		p_message_name := 'IGS_PR_OUT_TYPE_CANT_CHANGED';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_pro;
  		OPEN c_spo;
  		FETCH c_spo INTO v_dummy;
  		IF c_spo%FOUND THEN
  			CLOSE c_spo;
  			p_message_name := 'IGS_PR_OUT_TYPE_CANT_CHANGED';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_spo;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pro%ISOPEN THEN
  			CLOSE c_pro;
  		END IF;
  		IF c_spo%ISOPEN THEN
  			CLOSE c_spo;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_POT_SPOT_U');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_pot_spot_u;


  -- Validate that the s_progression_outcome_type is not closed
  FUNCTION prgp_val_spot_closed(
  p_s_prog_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- prgp_val_spot_closed
  	-- Validate if s_progression_outcome_type.s_progression_outcome_type is closed
  DECLARE
  	v_closed_ind		VARCHAR2(1);
  	CURSOR c_spot IS
  		SELECT	spot.closed_ind
  		FROM	IGS_LOOKUPS_VIEW	spot
  		WHERE	spot.LOOKUP_TYPE	= p_s_prog_outcome_type;
  BEGIN
  	--set default message_name
  	p_message_name := null;
  	OPEN c_spot;
  	FETCH c_spot INTO v_closed_ind;
  	IF c_spot%FOUND THEN
  		CLOSE c_spot;
  		IF v_closed_ind = 'Y' THEN
  			p_message_name := 'IGS_PR_SYS_PRG_OUT_TYPE_CLOSE';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_spot;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_spot%ISOPEN THEN
  			CLOSE c_spot;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_VAL_POT.PRGP_VAL_SPOT_CLOSED');
                --IGS_GE_MSG_STACK.ADD;

  END prgp_val_spot_closed;
END IGS_PR_VAL_POT;

/
