--------------------------------------------------------
--  DDL for Package Body IGS_PR_VAL_SPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_VAL_SPO" AS
/* $Header: IGSPR21B.pls 115.10 2003/04/14 09:51:58 anilk ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- bug 1956374 msrinivi removed duplicate code genp_prc_clear_row_id
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  /*
  ||=========================================================================================||
  ||  kdande --Bug ID 1956374 - Removal of Duplicate Program Units from OSS.                 ||
  ||  Removed program unit (PRGP_VAL_POT_CLOSED) - from the spec and body.                   ||
  ||=========================================================================================||
  ||  NALKUMAR    19-NOV-2002   Bug NO: 2658550. Modified 'prgp_val_spo_rqrd'                ||
  ||                            and 'prgp_val_spo_approve' function as per the FA110 PR Enh. ||
  ||=========================================================================================||
  ||  NALKUMAR    13-JAN-2003   Bug NO: 2728493. Modified 'prgp_val_spo_dcsn' procedure to   ||
	||                            display error IGS_PR_CNTCH_DST_APRC_WAP_OAP  when the        ||
	||                            decision status is changed to WAIVED/PENDING for an Approved ||
	||                            applied outcome                                              ||
  ||=========================================================================================||
  */
  -------------------------------------------------------------------------------------------

  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  FUNCTION prgp_prc_spo_rowids(
  p_inserting IN BOOLEAN ,
  p_updating IN BOOLEAN ,
  p_deleting IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	v_index			BINARY_INTEGER;
  	v_other_detail		VARCHAR(255);
  	v_message_name		VARCHAR(30);
  BEGIN
  	-- Process saved rows.
  	FOR  v_index IN 1..gv_table_index - 1 LOOP
  		-- Validate student progression outcome
  		IF IGS_PR_GEN_006.IGS_PR_UPD_SCA_STATUS (
  				gt_rowid_table(v_index).person_id,
  				gt_rowid_table(v_index).course_cd,
  				NULL,
  				NULL,
  				v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate insert
  		IF p_inserting THEN
  			IF igs_pr_val_spo.prgp_val_spo_ins (
  					gt_rowid_table(v_index).person_id,
  					gt_rowid_table(v_index).course_cd,
  					gt_rowid_table(v_index).prg_cal_type,
  					gt_rowid_table(v_index).prg_ci_sequence_number,
  					gt_rowid_table(v_index).rule_check_dt,
  					gt_rowid_table(v_index).progression_rule_cat,
  					gt_rowid_table(v_index).pra_sequence_number,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- Check the decision status can be changed
  		IF p_inserting OR (p_updating AND
  		   gt_rowid_table(v_index).new_decision_status <>
  		   gt_rowid_table(v_index).old_decision_status) THEN
  			IF igs_pr_val_spo.prgp_val_spo_dcsn (
  						gt_rowid_table(v_index).person_id,
  						gt_rowid_table(v_index).course_cd,
  						gt_rowid_table(v_index).prg_cal_type,
  						gt_rowid_table(v_index).prg_ci_sequence_number,
  						gt_rowid_table(v_index).rule_check_dt,
  						gt_rowid_table(v_index).progression_rule_cat,
  						gt_rowid_table(v_index).pra_sequence_number,
  						gt_rowid_table(v_index).progression_outcome_type,
  						gt_rowid_table(v_index).old_decision_status,
  						gt_rowid_table(v_index).new_decision_status,
  						gt_rowid_table(v_index).decision_dt,
  						gt_rowid_table(v_index).decision_org_unit_cd,
  						gt_rowid_table(v_index).decision_ou_start_dt,
  						gt_rowid_table(v_index).applied_dt,
  						gt_rowid_table(v_index).expiry_dt,
  						v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- Check the decision status can be set to approved
  		IF p_inserting OR (p_updating AND
   		   gt_rowid_table(v_index).new_decision_status <>
  		   gt_rowid_table(v_index).old_decision_status) THEN
  			IF igs_pr_val_spo.prgp_val_spo_approve (
  					gt_rowid_table(v_index).person_id,
  					gt_rowid_table(v_index).course_cd,
  					gt_rowid_table(v_index).sequence_number,
  					gt_rowid_table(v_index).progression_outcome_type,
  					gt_rowid_table(v_index).old_decision_status,
  					gt_rowid_table(v_index).new_decision_status,
  					gt_rowid_table(v_index).encmb_course_group_cd,
  					gt_rowid_table(v_index).restricted_enrolment_cp,
  					gt_rowid_table(v_index).restricted_attendance_type,
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- Check the duration/duration type can be changed
  		IF p_inserting OR (p_updating AND
  		   NVL(gt_rowid_table(v_index).new_duration, -1) <>
  		   NVL(gt_rowid_table(v_index).old_duration, -1) OR
  		   NVL(gt_rowid_table(v_index).new_duration_type, ' ') <>
  		   NVL(gt_rowid_table(v_index).old_duration_type, ' ')) THEN
  			IF igs_pr_val_spo.prgp_val_spo_drtn (
  						gt_rowid_table(v_index).person_id,
  						gt_rowid_table(v_index).course_cd,
  						gt_rowid_table(v_index).sequence_number,
  						gt_rowid_table(v_index).new_decision_status,
  						gt_rowid_table(v_index).old_duration,
  						gt_rowid_table(v_index).new_duration,
  						gt_rowid_table(v_index).old_duration_type,
  						gt_rowid_table(v_index).new_duration_type,
  						gt_rowid_table(v_index).expiry_dt,
  						v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  END prgp_prc_spo_rowids;

  --
  -- Validate student progression outcome decision status changes
  FUNCTION prgp_val_spo_dcsn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_rule_check_dt IN DATE ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_decision_status IN VARCHAR2 ,
  p_new_decision_status IN VARCHAR2 ,
  p_decision_dt IN DATE ,
  p_decision_org_unit_cd IN VARCHAR2 ,
  p_decision_ou_start_dt IN DATE ,
  p_applied_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN	-- prgp_val_spo_dcsn
  	-- Validate changes to the student _progression_outcome decision_status:
  	-- PENDING => APPROVED
  	--	decision_dt, decision_org_unit_cd, decision_ou_start_dt must be set
  	-- 	spo records for future test of the same rule cannot exist
  	-- PENDING => WAIVED
  	--	decision_dt, decision_org_unit_cd, decision_ou_start_dt must be set
  	-- PENDING => <OTHER>
  	--	not allowed
  	-- APPROVED => WAIVED
  	-- 	applied_dt cannot be set
  	-- APPROVED => REMOVED
  	-- 	if expiry_dt is set it must be < SYSDATE
  	-- APPROVED => CANCELLED
  	-- 	if expiry_dt is set it must be < SYSDATE
  	--	applied_dt must be set
  	-- APPROVED => PENDING
  	-- 	applied_dt cannot be set
  	--	decision_dt, decision_org_unit_cd, decision_ou_start_dt cannot be set
  	-- WAIVED => PENDING
  	--	spo records for future test of the same rule cannot exist
  	-- 	decision_dt, decision_org_unit_cd, decision_ou_start_dt cannot be set
  	-- WAIVED => APPROVED
  	-- 	decision_dt, decision_org_unit_cd, decision_ou_start_dt must be set
  	-- 	spo records for future test of the same rule cannot exist
  	-- WAIVED => <OTHER>
  	-- 	not allowed
  	-- CANCELLED => APPROVED
  	-- 	decision_dt, decision_org_unit_cd, decision_ou_start_dt must be set
  	-- CANCELLED => <OTHER>
  	-- 	not allowed
  	-- REMOVED => <OTHER>
  	-- 	not allowed
  DECLARE
  	cst_pending	CONSTANT	VARCHAR(10) := 'PENDING';
  	cst_approved	CONSTANT	VARCHAR(10) := 'APPROVED';
  	cst_waived	CONSTANT	VARCHAR(10) := 'WAIVED';
  	cst_cancelled	CONSTANT	VARCHAR(10) := 'CANCELLED';
  	cst_removed	CONSTANT	VARCHAR(10) := 'REMOVED';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_spo IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_OU              spo
  		WHERE	spo.person_id			= p_person_id AND
  			spo.course_cd			= p_course_cd AND
  			spo.prg_cal_type		= p_prg_cal_type AND
  			spo.prg_ci_sequence_number 	= p_prg_ci_sequence_number AND
  			spo.rule_check_dt 		IS NOT NULL AND
  			spo.rule_check_dt 		> p_rule_check_dt AND
  			spo.progression_rule_cat 	= p_progression_rule_cat AND
  			spo.pra_sequence_number 	= p_pra_sequence_number;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_prg_cal_type IS NULL OR
  			p_prg_ci_sequence_number IS NULL OR
  			p_new_decision_status IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_old_decision_status = cst_pending AND
  		p_new_decision_status  NOT IN ( cst_pending,
  						cst_approved,
  						cst_waived)  THEN
  		p_message_name := 'IGS_PR_CAOCH_DST_PEN_RE_APWA';
  		RETURN FALSE;
  	END IF;
  	IF p_old_decision_status = cst_waived AND
  		p_new_decision_status  NOT IN ( cst_waived,
  						cst_approved,
  						cst_pending)  THEN
  		p_message_name := 'IGS_PR_CACH_DEST_WAD_RE_APPE';
  		RETURN FALSE;
  	END IF;
  	IF p_old_decision_status = cst_cancelled AND
  		p_new_decision_status NOT IN (	cst_cancelled,
  						cst_approved) THEN
  		p_message_name := 'IGS_PR_CACH_DEST_CAN_RE_AP';
  		RETURN FALSE;
  	END IF;
  	IF p_old_decision_status = cst_removed AND
  	   p_new_decision_status <> cst_removed THEN
  		p_message_name := 'IGS_PR_CANT_CHDE_RED_REC';
  		RETURN FALSE;
  	END IF;
  	IF p_new_decision_status = cst_pending THEN
  		IF p_decision_dt IS NOT  NULL OR
  				p_decision_org_unit_cd IS NOT NULL OR
  				p_decision_ou_start_dt IS NOT NULL THEN
  			p_message_name := 'IGS_PR_DEDT_DORG_CNT_DEST_PEN';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_new_decision_status  IN (	cst_approved,
  					cst_waived) THEN
  		IF p_decision_dt IS NULL OR
  				p_decision_org_unit_cd IS NULL OR
  				p_decision_ou_start_dt IS NULL THEN
  			p_message_name := 'IGS_PR_DEDT_DEOR_CNT_DEST_PEN';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_new_decision_status  IN (	cst_approved,
  					cst_pending) AND
  	   p_old_decision_status  NOT IN (	cst_approved,
  						cst_pending) THEN
  		OPEN c_spo;
  		FETCH c_spo INTO v_dummy;
  		IF c_spo%FOUND THEN
  			CLOSE c_spo;
  			p_message_name := 'IGS_PR_CNCH_DEST_APPEN_OTRE_RUCK';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_spo;
  	END IF;
  	IF p_old_decision_status = cst_approved AND
  	   p_new_decision_status = cst_cancelled AND
  	   p_applied_dt IS NULL THEN
  		p_message_name := 'IGS_PR_CNT_CHDES_CA_OUHNT_AP';
  		RETURN FALSE;
  	END IF;
  	IF p_old_decision_status = cst_approved AND
  	   p_new_decision_status IN (	cst_waived,
  					cst_pending) AND
  	   p_applied_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_CNTCH_DST_APRC_WAP_OAP';
  		RETURN FALSE;
  	END IF;
  	IF p_old_decision_status = cst_approved AND
  	   p_new_decision_status IN (	cst_removed,
  					cst_cancelled)  AND
  	   TRUNC(NVL(p_expiry_dt, igs_ge_date.igsdate('9999/01/01'))) <=
  	   TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_CNTCH_DEST_APRE_EXDT_AP';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_spo%ISOPEN THEN
  			CLOSE c_spo;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_dcsn;

  --
  -- Validate student progression outcome decision date
  FUNCTION prgp_val_spo_dcsn_dt(
  p_decision_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_dcsn_dt
  	-- Validate that the IGS_PR_STDNT_PR_OU decision_dt
  	-- is not future dated.
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_decision_dt IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(p_decision_dt) > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_DECDT_CNT_IN_FUT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_dcsn_dt;

  --
  -- Validate student progression outcome show cause date
  FUNCTION prgp_val_spo_sc_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_applied_dt IN DATE ,
  p_decision_dt IN DATE ,
  p_decision_status IN VARCHAR2 ,
  p_show_cause_expiry_dt IN DATE ,
  p_old_show_cause_dt IN DATE ,
  p_new_show_cause_dt IN DATE ,
  p_show_cause_outcome_dt IN DATE ,
  p_appeal_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_sc_dt
  	-- Validate the IGS_PR_STDNT_PR_OU show_cause_dt:
  	--	 The show_cause_dt cannot be set unless decision_dt has been set
  	--	 The show_cause_dt cannot be set if decision_status is WAIVED
  	--	 Cannot set show_cause_dt if the appeal_dt is already set
  	--	 Cannot alter show_cause_dt once show_cause_outcome_dt has been set
  	--	 If 'applicable' apply_before_show_ind is N then cannot set show_cause_dt
  	--	  once applied_dt has been set.
  DECLARE
  	v_apply_start_dt_alias		IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  	v_apply_end_dt_alias		IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  	v_end_benefit_dt_alias		IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  	v_end_penalty_dt_alias		IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  	v_show_cause_cutoff_dt		IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  	v_appeal_cutoff_dt		IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  	v_show_cause_ind		IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	v_apply_before_show_ind		IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	v_apply_before_appeal_ind	IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  	v_count_sus_in_time_ind		IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  	v_count_exc_in_time_ind		IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  	v_calculate_wam_ind		IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  	v_calculate_gpa_ind		IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_outcome_check_type		VARCHAR2(10);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_dt, igs_ge_date.igsdate('0001/01/01'))) >
  			TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_SHCA_DT_CNT_FUT';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_dt IS NOT NULL AND
  			p_decision_dt IS NULL THEN
  		p_message_name := 'IGS_PR_SHCDT_CNT_ST_DEDT_NST';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_dt IS NOT NULL AND
  			p_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_SHCA_DTCNT_DEST_NTAP';
  		RETURN FALSE;
  	END IF;
  	IF p_show_cause_expiry_dt IS NULL AND
  	   p_new_show_cause_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SCADT_CNT_SHEX_DTNST';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_dt IS NOT NULL AND
  			p_appeal_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SHCDT_CNT_ST_APDT_ST';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  	   TRUNC(NVL(p_old_show_cause_dt, igs_ge_date.igsdate('0001/01/01'))) AND
     	   p_show_cause_outcome_dt IS NOT NULL AND
  	   p_old_show_cause_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SHCA_DTCNT_AL_OUDTS';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_dt IS NOT NULL AND
  			p_applied_dt IS NOT NULL THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_version_number;
  		CLOSE c_sca;
  		IGS_PR_GEN_003.IGS_PR_GET_CONFIG_PARM(
  			p_course_cd,
  			v_version_number,
  			v_apply_start_dt_alias,
  			v_apply_end_dt_alias,
  			v_end_benefit_dt_alias,
  			v_end_penalty_dt_alias,
  			v_show_cause_cutoff_dt,
  			v_appeal_cutoff_dt,
  			v_show_cause_ind,
  			v_apply_before_show_ind,
  			v_appeal_ind,
  			v_apply_before_appeal_ind,
  			v_count_sus_in_time_ind,
  			v_count_exc_in_time_ind,
  			v_calculate_wam_ind,
  			v_calculate_gpa_ind,
  			v_outcome_check_type);
  		IF v_apply_before_show_ind = 'N' THEN
  			p_message_name := 'IGS_PR_SHCA_DTCNT_APDT_BSNTA';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_sc_dt;

  --
  -- Validate student progression outcome show cause expiry date
  FUNCTION prgp_val_spo_sc_exp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_decision_status IN VARCHAR2 ,
  p_old_show_cause_expiry_dt IN DATE ,
  p_new_show_cause_expiry_dt IN DATE ,
  p_show_cause_dt IN DATE ,
  p_show_cause_outcome_dt IN DATE ,
  p_appeal_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_sc_exp
  	-- Validate the IGS_PR_STDNT_PR_OU show_cause_expiry_dt:
  	--	The show_cause_expiry_dt cannot be set to a past date
  	--	The show_cause_expiry_dt cannot be set to if decision_status is WAIVED
  	--	The show_cause_expiry_dt cannot be after the appeal_expiry_dt (if set)
  	--	Cannot alter show_cause_expiry_dt once show_cause_outcome_dt has been set
  	--	Warn if the show_cause_expiry_dt is after the applicable show cause
  	--	  cut-off date for the student's course version.
  DECLARE
  	v_apply_start_dt_alias		IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  	v_apply_end_dt_alias		IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  	v_end_benefit_dt_alias		IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  	v_end_penalty_dt_alias		IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  	v_show_cause_cutoff_dt		IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  	v_appeal_cutoff_dt		IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  	v_show_cause_ind		IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	v_apply_before_show_ind		IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	v_apply_before_appeal_ind	IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  	v_count_sus_in_time_ind		IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  	v_count_exc_in_time_ind		IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  	v_calculate_wam_ind		IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  	v_calculate_gpa_ind		IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_alias_val			IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_outcome_check_type		VARCHAR2(10);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  	CURSOR c_daiv
  (cp_shw_cse_ctoff_dt_alias		IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE) IS
  		SELECT	MAX(daiv.alias_val)
  		FROM	IGS_CA_DA_INST_V	daiv
  		WHERE	daiv.dt_alias 		= cp_shw_cse_ctoff_dt_alias AND
  			daiv.cal_type 		= p_prg_cal_type AND
  			daiv.ci_sequence_number = p_prg_ci_sequence_number;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_expiry_dt,
  	igs_ge_date.igsdate('9999/01/01'))) < TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_SHCA_EXPDT_CNTB_TODAT';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_expiry_dt IS NOT NULL AND
  			p_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_SHCA_EXPDT_CNTB_DSTNA';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_expiry_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) >
  	   TRUNC(NVL(p_appeal_expiry_dt,
  	   igs_ge_date.igsdate('9999/01/01'))) THEN
  		p_message_name := 'IGS_PR_SH_EXPDT_CNT_APEXDT';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_expiry_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) <>
  	   TRUNC(NVL(p_old_show_cause_expiry_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) AND
  	   p_show_cause_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SHEXP_CNT_AL_SCDST';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_show_cause_expiry_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) <>
  	   TRUNC(NVL(p_old_show_cause_expiry_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) AND
  	   p_show_cause_outcome_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SHEXP_DTCNT_ASHOU_DTST';
  		RETURN FALSE;
  	END IF;
  	IF p_new_show_cause_expiry_dt IS NOT NULL THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_version_number;
  		CLOSE c_sca;
  		IGS_PR_GEN_003.IGS_PR_GET_CONFIG_PARM(
  			p_course_cd,
  			v_version_number,
  			v_apply_start_dt_alias,
  			v_apply_end_dt_alias,
  			v_end_benefit_dt_alias,
  			v_end_penalty_dt_alias,
  			v_show_cause_cutoff_dt,
  			v_appeal_cutoff_dt,
  			v_show_cause_ind,
  			v_apply_before_show_ind,
  			v_appeal_ind,
  			v_apply_before_appeal_ind,
  			v_count_sus_in_time_ind,
  			v_count_exc_in_time_ind,
  			v_calculate_wam_ind,
  			v_calculate_gpa_ind,
  			v_outcome_check_type);
  		OPEN c_daiv(v_show_cause_cutoff_dt);
  		FETCH c_daiv INTO v_alias_val;
  		CLOSE c_daiv;
  		IF TRUNC(NVL(p_new_show_cause_expiry_dt,
  		   igs_ge_date.igsdate('0001/01/01'))) >
  		   TRUNC(v_alias_val) THEN
  			p_message_name := 'IGS_PR_WA_SCA_EXDT_ASCT_DT';
  			RETURN TRUE;	-- warning only
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_daiv%ISOPEN THEN
  			CLOSE c_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_sc_exp;

  --
  -- Validate student progression outcome show cause outcome date
  FUNCTION prgp_val_spo_sc_out(
  p_decision_status IN VARCHAR2 ,
  p_show_cause_dt IN DATE ,
  p_show_cause_outcome_dt IN DATE ,
  p_show_cause_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_sc_out
  	-- Validate the IGS_PR_STDNT_PR_OU show_cause_outcome_dt and
  	-- show_cause_outcome_type:
  	--	* The show_cause_outcome_dt, show_cause_outcome_type cannot be set
  	--	  where show_cause_dt is not set
  	--	* Both show_cause_outcome_dt, show_cause_outcome_type must be set
  	--	  and unset together.
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF p_show_cause_dt IS NULL AND
  			(p_show_cause_outcome_dt IS NOT NULL OR
  			p_show_cause_outcome_type IS NOT NULL) THEN
  		p_message_name := 'IGS_PR_SHCA_OTY_ODTCT_SCDT_NT';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_show_cause_outcome_dt,
  	   igs_ge_date.igsdate('0001/01/01'))) > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_SHCA_OUDT_CNT_FUT';
  		RETURN FALSE;
  	END IF;
  	IF p_show_cause_outcome_dt IS NOT NULL AND
  			p_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_SHCA_OUT_DTTY_CNTST';
  		RETURN FALSE;
  	END IF;
  	IF p_show_cause_outcome_dt IS NULL AND
  			p_show_cause_outcome_type IS NOT NULL THEN
  		p_message_name := 'IGS_PR_SCADT_MST_SHOTY_ST';
  		RETURN FALSE;
  	END IF;
  	IF p_show_cause_outcome_dt IS NOT NULL AND
  			p_show_cause_outcome_type IS NULL THEN
  		p_message_name := 'IGS_PR_SHOT_TYMST_SCO_DTST';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_sc_out;

  --
  -- Validate student progression outcome appeal date
  FUNCTION prgp_val_spo_apl_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_applied_dt IN DATE ,
  p_decision_dt IN DATE ,
  p_decision_status IN VARCHAR2 ,
  p_appeal_expiry_dt IN DATE ,
  p_old_appeal_dt IN DATE ,
  p_new_appeal_dt IN DATE ,
  p_appeal_outcome_dt IN DATE ,
  p_show_cause_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_apl_dt
  	-- Validate the IGS_PR_STDNT_PR_OU appeal_dt:
  	--	The appeal_dt cannot be set unless decision_dt is set
  	--	The appeal_dt cannot be before the show_cause_dt (if set)
  	--	Cannot alter appeal_dt once appeal_outcome_dt has been set
  	--	If 'applicable' apply_before_appeal_ind is N then cannot
  	--	  set appeal_dt once applied_dt has been set.
  DECLARE
  	v_apply_start_dt_alias		IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  	v_apply_end_dt_alias		IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  	v_end_benefit_dt_alias		IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  	v_end_penalty_dt_alias		IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  	v_show_cause_cutoff_dt		IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  	v_appeal_cutoff_dt		IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  	v_show_cause_ind		IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	v_apply_before_show_ind		IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	v_apply_before_appeal_ind	IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  	v_count_sus_in_time_ind		IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  	v_count_exc_in_time_ind		IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  	v_calculate_wam_ind		IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  	v_calculate_gpa_ind		IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_outcome_check_type		VARCHAR2(10);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_dt, igs_ge_date.igsdate('0001/01/01'))) >
  			TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_APOUT_DT_CNT_FUT';
  		RETURN FALSE;
  	END IF;
  	IF p_new_appeal_dt IS NOT NULL AND
  			p_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_APDT_CNT_SDCST_NTAP';
  		RETURN FALSE;
  	END IF;
  	IF p_appeal_expiry_dt IS NULL AND
  	   p_new_appeal_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_APDT_CNT_SAPEX_DTNTS';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_dt, igs_ge_date.igsdate('9999/01/01'))) <
  	   TRUNC(NVL(p_show_cause_dt, igs_ge_date.igsdate('0001/01/01'))) THEN
  		p_message_name := 'IGS_PR_APDT_CNTS_BSHDT';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  	   TRUNC(NVL(p_old_appeal_dt, igs_ge_date.igsdate('0001/01/01'))) AND
     	   p_appeal_outcome_dt IS NOT NULL AND
  	   p_old_appeal_dt  IS NOT NULL THEN
  		p_message_name := 'IGS_PR_APDT_CNT_AL_AODT_ST';
  		RETURN FALSE;
  	END IF;
  	IF p_new_appeal_dt IS NOT NULL AND
  			p_applied_dt IS NOT NULL THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_version_number;
  		CLOSE c_sca;
  		IGS_PR_GEN_003.IGS_PR_GET_CONFIG_PARM(
  			p_course_cd,
  			v_version_number,
  			v_apply_start_dt_alias,
  			v_apply_end_dt_alias,
  			v_end_benefit_dt_alias,
  			v_end_penalty_dt_alias,
  			v_show_cause_cutoff_dt,
  			v_appeal_cutoff_dt,
  			v_show_cause_ind,
  			v_apply_before_show_ind,
  			v_appeal_ind,
  			v_apply_before_appeal_ind,
  			v_count_sus_in_time_ind,
  			v_count_exc_in_time_ind,
  			v_calculate_wam_ind,
  			v_calculate_gpa_ind,
  			v_outcome_check_type);
  		IF v_apply_before_appeal_ind = 'N' THEN
  			p_message_name := 'IGS_PR_APDT_CNT_APDT_SABA_NAL';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_apl_dt;

  --
  -- Validate student progression outcome appeal expiry date
  FUNCTION prgp_val_spo_apl_exp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_decision_status IN VARCHAR2 ,
  p_old_appeal_expiry_dt IN DATE ,
  p_new_appeal_expiry_dt IN DATE ,
  p_appeal_dt IN DATE ,
  p_appeal_outcome_dt IN DATE ,
  p_show_cause_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_apl_exp
  	-- Validate the IGS_PR_STDNT_PR_OU appeal_expiry_dt:
  	--	The appeal_expiry_dt cannot be set to a past date
  	--	The appeal_expiry_dt cannot be before the show_cause_expiry_dt (if set)
  	--	Cannot alter appeal_expiry_dt once appeal_outcome_dt has been set
  	--	Warn if the appeal_expiry_dt is after the applicable appeal cut-off date
  	--	  for the student's course version.
  DECLARE
  	v_apply_start_dt_alias		IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  	v_apply_end_dt_alias		IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  	v_end_benefit_dt_alias		IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  	v_end_penalty_dt_alias		IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  	v_show_cause_cutoff_dt		IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  	v_appeal_cutoff_dt		IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  	v_show_cause_ind		IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	v_apply_before_show_ind		IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	v_apply_before_appeal_ind	IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  	v_count_sus_in_time_ind		IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  	v_count_exc_in_time_ind		IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  	v_calculate_wam_ind		IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  	v_calculate_gpa_ind		IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_alias_val			IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_outcome_check_type		VARCHAR2(10);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  	CURSOR c_daiv (cp_apl_ctoff_dt_alias	IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE) IS
  		SELECT	MAX(daiv.alias_val)
  		FROM	IGS_CA_DA_INST_V	daiv
  		WHERE	daiv.dt_alias 		= cp_apl_ctoff_dt_alias AND
  			daiv.cal_type 		= p_prg_cal_type AND
  			daiv.ci_sequence_number = p_prg_ci_sequence_number;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_expiry_dt, igs_ge_date.igsdate('9999/01/01'))) <
  	TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_APEXDT_CNTS_BTODT';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_expiry_dt, igs_ge_date.igsdate('9999/01/01'))) <
  	TRUNC(NVL(p_show_cause_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) THEN
  		p_message_name := 'IGS_PR_APEXDT_CNTB_SEXDT';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  	TRUNC(NVL(p_old_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) AND
  	p_appeal_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_APEDT_CNT_AL_APDT_HST';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_new_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  	TRUNC(NVL(p_old_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) AND
  			p_appeal_outcome_dt IS NOT NULL THEN
  		p_message_name := 'IGS_PR_APEXDT_CNTAL_AODT_HST';
  		RETURN FALSE;
  	END IF;
  	IF p_new_appeal_expiry_dt IS NOT NULL AND
  	   p_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_AEXDT_CNT_ST_DECST_NTAP';
  		RETURN FALSE;
  	END IF;
  	IF p_new_appeal_expiry_dt IS NOT NULL THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_version_number;
  		CLOSE c_sca;
  		IGS_PR_GEN_003.IGS_PR_GET_CONFIG_PARM(
  			p_course_cd,
  			v_version_number,
  			v_apply_start_dt_alias,
  			v_apply_end_dt_alias,
  			v_end_benefit_dt_alias,
  			v_end_penalty_dt_alias,
  			v_show_cause_cutoff_dt,
  			v_appeal_cutoff_dt,
  			v_show_cause_ind,
  			v_apply_before_show_ind,
  			v_appeal_ind,
  			v_apply_before_appeal_ind,
  			v_count_sus_in_time_ind,
  			v_count_exc_in_time_ind,
  			v_calculate_wam_ind,
  			v_calculate_gpa_ind,
  			v_outcome_check_type);
  		OPEN c_daiv(v_appeal_cutoff_dt);
  		FETCH c_daiv INTO v_alias_val;
  		CLOSE c_daiv;
  		IF TRUNC(NVL(p_new_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) >
  		   TRUNC(v_alias_val) THEN
  			p_message_name := 'IGS_PR_WA_APEX_DTAT_APCT_DT';
  			RETURN TRUE;	-- warning only
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_daiv%ISOPEN THEN
  			CLOSE c_daiv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_apl_exp;

  --
  -- Validate student progression outcome appeal outcome date
  FUNCTION prgp_val_spo_apl_out(
  p_old_decision_status IN VARCHAR2 ,
  p_appeal_dt IN DATE ,
  p_appeal_outcome_dt IN DATE ,
  p_appeal_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_apl_out
  	-- Validate the IGS_PR_STDNT_PR_OU appeal_outcome_dt and
  	-- appeal_outcome_type:
  	--	* The appeal_outcome_dt, appeal_outcome_type cannot be set where appeal_dt
  	--	  is not set
  	--	* Both appeal_outcome_dt, appeal_outcome_type must be set and unset together
  DECLARE
  BEGIN
  	p_message_name := null;
  	IF p_appeal_dt IS NULL AND
  			(p_appeal_outcome_dt IS NOT NULL OR
  			p_appeal_outcome_type IS NOT NULL) THEN
  		p_message_name := 'IGS_PR_APOTY_DTCNT_APDT_NST';
  		RETURN FALSE;
  	END IF;
  	IF TRUNC(NVL(p_appeal_outcome_dt, igs_ge_date.igsdate('0001/01/01'))) >
  			TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_APOUT_DT_CNT_FUT';
  		RETURN FALSE;
  	END IF;
  	IF p_appeal_outcome_dt IS NOT NULL AND
  	   p_old_decision_status <> 'APPROVED' THEN
  		p_message_name := 'IGS_PR_AOUT_DTTY_CNTS_DEST_NAP';
  		RETURN FALSE;
  	END IF;
  	IF p_appeal_outcome_dt IS NULL AND
  			p_appeal_outcome_type IS NOT NULL THEN
  		p_message_name := 'IGS_PR_APODT_MST_AOTY_ST';
  		RETURN FALSE;
  	END IF;
  	IF p_appeal_outcome_dt IS NOT NULL AND
  			p_appeal_outcome_type IS NULL THEN
  		p_message_name := 'IGS_PR_APOTY_MST_AODT_ST';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_apl_out;

  --
  -- Get applied date if student progression outcome detail has changed
  FUNCTION prgp_GET_SPO_APLY_DT(
  p_decision_status IN VARCHAR2 ,
  p_old_applied_dt IN DATE ,
  p_new_applied_dt IN DATE ,
  p_old_encmb_course_group_cd IN VARCHAR2 ,
  p_new_encmb_course_group_cd IN VARCHAR2 ,
  p_old_restricted_enrolment_cp IN NUMBER ,
  p_new_restricted_enrolment_cp IN NUMBER ,
  p_old_restricted_attend_type IN VARCHAR2 ,
  p_new_restricted_attend_type IN VARCHAR2 ,
  p_old_expiry_dt IN DATE ,
  p_new_expiry_dt IN DATE ,
  p_old_duration IN NUMBER ,
  p_new_duration IN NUMBER ,
  p_old_duration_type IN VARCHAR2 ,
  p_new_duration_type IN VARCHAR2 ,
  p_out_applied_dt OUT NOCOPY DATE )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN	-- IGS_PR_GEN_004.IGS_PR_GET_SPO_APLY_DT
  	-- If the student progression outcome details have been changed
  	-- return the correct applied date.
  	p_out_applied_dt := NULL;
  	IF p_decision_status <> 'APPROVED' OR
  	   TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01'))) <>
  	   TRUNC(NVL(p_old_applied_dt, igs_ge_date.igsdate('9999/01/01'))) THEN
  		RETURN TRUE;
  	END IF;
  	IF NVL(p_old_encmb_course_group_cd, 'NULL') <>
  		NVL(p_new_encmb_course_group_cd, 'NULL') OR
  	   NVL(p_old_restricted_enrolment_cp, 0) <>
  		NVL(p_new_restricted_enrolment_cp, 0) OR
  	   NVL(p_old_restricted_attend_type, 'NULL') <>
  		NVL(p_new_restricted_attend_type, 'NULL') OR
  	   TRUNC(NVL(p_old_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  		TRUNC(NVL(p_new_expiry_dt, igs_ge_date.igsdate('0001/01/01'))) OR
  	   NVL(p_old_duration, 0) <>
  		NVL(p_new_duration, 0) OR
  	   NVL(p_old_duration_type, 'NULL') <>
  		NVL(p_new_duration_type, 'NULL') THEN
  		If TRUNC(p_new_applied_dt) <>
  		   TRUNC(igs_ge_date.igsdate('0001/01/01')) THEN
  			p_out_applied_dt := igs_ge_date.igsdate('0001/01/01');
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN

  			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  			IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END PRGP_GET_SPO_APLY_DT;
  --
  --
  -- Routine to save key in a PL/SQL TABLE for the current commit.
  PROCEDURE prgp_set_spo_rowid(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_rule_check_dt IN DATE ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_decision_status IN VARCHAR2 ,
  p_new_decision_status IN VARCHAR2 ,
  p_decision_dt IN DATE ,
  p_decision_org_unit_cd IN VARCHAR2 ,
  p_decision_ou_start_dt IN DATE ,
  p_applied_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_encmb_course_group_cd IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_old_duration IN NUMBER ,
  p_new_duration IN NUMBER ,
  p_old_duration_type IN VARCHAR2 ,
  p_new_duration_type IN VARCHAR2 )
  IS
  	v_index				BINARY_INTEGER;
  	v_spo_found			BOOLEAN DEFAULT FALSE;
  BEGIN
  	-- Check if record already exists in gt_rowid_table
  	FOR v_index IN 1..gv_table_index - 1 LOOP
  		IF gt_rowid_table(v_index).person_id = p_person_id AND
  		   gt_rowid_table(v_index).course_cd = p_course_cd AND
  		   gt_rowid_table(v_index).sequence_number = p_sequence_number THEN
  			v_spo_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF NOT v_spo_found THEN
  		--save student progression outcome person_id, course_cd  key details
  		gt_rowid_table(gv_table_index).person_id := p_person_id;
  		gt_rowid_table(gv_table_index).course_cd := p_course_cd;
  		gt_rowid_table(gv_table_index).sequence_number := p_sequence_number;
  		gt_rowid_table(gv_table_index).prg_cal_type := p_prg_cal_type;
  		gt_rowid_table(gv_table_index).prg_ci_sequence_number :=
  			p_prg_ci_sequence_number;
  		gt_rowid_table(gv_table_index).rule_check_dt := p_rule_check_dt;
  		gt_rowid_table(gv_table_index).progression_rule_cat := p_progression_rule_cat;
  		gt_rowid_table(gv_table_index).pra_sequence_number := p_pra_sequence_number;
  		gt_rowid_table(gv_table_index).progression_outcome_type :=
  			p_progression_outcome_type;
  		gt_rowid_table(gv_table_index).old_decision_status := p_old_decision_status;
  		gt_rowid_table(gv_table_index).new_decision_status := p_new_decision_status;
  		gt_rowid_table(gv_table_index).decision_dt := p_decision_dt;
  		gt_rowid_table(gv_table_index).decision_org_unit_cd := p_decision_org_unit_cd;
  		gt_rowid_table(gv_table_index).decision_ou_start_dt := p_decision_ou_start_dt;
  		gt_rowid_table(gv_table_index).applied_dt := p_applied_dt;
  		gt_rowid_table(gv_table_index).expiry_dt := p_expiry_dt;
  		gt_rowid_table(gv_table_index).encmb_course_group_cd :=
  			p_encmb_course_group_cd;
  		gt_rowid_table(gv_table_index).restricted_enrolment_cp :=
  			p_restricted_enrolment_cp;
  		gt_rowid_table(gv_table_index).restricted_attendance_type :=
  			p_restricted_attendance_type;
  		gt_rowid_table(gv_table_index).old_duration := p_old_duration;
  		gt_rowid_table(gv_table_index).new_duration := p_new_duration;
  		gt_rowid_table(gv_table_index).old_duration_type := p_old_duration_type;
  		gt_rowid_table(gv_table_index).new_duration_type := p_new_duration_type;
  		gv_table_index := gv_table_index +1;
  	END IF;
  END prgp_set_spo_rowid;

  --
  -- Validate progression calendar instance
  FUNCTION prgp_val_prg_ci(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- Validate for active and progression calender instance.
  DECLARE
  	cst_progress	 CONSTANT	VARCHAR2(10) := 'PROGRESS';
  	cst_active	 CONSTANT	VARCHAR2(10) := 'ACTIVE';
  	v_s_cal_type			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status		IGS_CA_STAT.s_cal_status%TYPE;
  	CURSOR c_ci_cat_cs IS
  	SELECT	cat.s_cal_cat,
  		cs.s_cal_status
  	FROM	IGS_CA_INST 		ci,
  		IGS_CA_TYPE		cat,
  		IGS_CA_STAT		cs
  	WHERE	cat.cal_type		= p_cal_type AND
  		ci.cal_type		= cat.cal_type AND
  		ci.sequence_number	= p_ci_sequence_number AND
  		cs.cal_status		= ci.cal_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  		OPEN c_ci_cat_cs;
  	FETCH c_ci_cat_cs INTO v_s_cal_type, v_s_cal_status;
  	IF c_ci_cat_cs%NOTFOUND THEN
  		CLOSE c_ci_cat_cs;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ci_cat_cs;
  	IF v_s_cal_type <>cst_progress OR
  		v_s_cal_status<>cst_active THEN
  		p_message_name := 'IGS_PR_CAL_INS_OACT_PR_CAL';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ci_cat_cs%ISOPEN THEN
  			CLOSE c_ci_cat_cs;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_prg_ci;

  --
  -- Validate student progression outcome can be inserted
  FUNCTION prgp_val_spo_ins(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_rule_check_dt IN DATE ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_ins
  	-- Validate insert of IGS_PR_STDNT_PR_OU record, validating for
  	-- related course attempt must have status of ENROLLED/INACTIVE/INTERMIT/
  	-- LAPSED / DISCONTIN
  	-- If related to IGS_PR_SDT_PR_RU_CK cannot be record against passed rule.
  	-- If related to student rule check, must be recorded against the latest
  	--check of a given rule within the IGS_PR_SDT_PR_RU_CK table.
  DECLARE
  	cst_enrolled	 CONSTANT	VARCHAR2(10) := 'ENROLLED';
  	cst_inactive	 CONSTANT	VARCHAR2(10) := 'INACTIVE';
  	cst_intermit	 CONSTANT	VARCHAR2(10) := 'INTERMIT';
  	cst_lapsed	CONSTANT	VARCHAR2(10) := 'LAPSED';
  	cst_discontin	CONSTANT	VARCHAR2(10) := 'DISCONTIN';
  	v_s_progression_outcome_type
  					IGS_PR_OU_TYPE.s_progression_outcome_type%TYPE;
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_passed_ind			IGS_PR_SDT_PR_RU_CK.passed_ind%TYPE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_sca IS
  		SELECT	course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT 	sca
  		WHERE	person_id 		= p_person_id  AND
  			course_cd 		= p_course_cd;
  	CURSOR c_spra1 IS
  		SELECT	passed_ind
  		FROM	IGS_PR_SDT_PR_RU_CK 	sprc
  		WHERE	person_id		= p_person_id AND
  			course_cd 		= p_course_cd AND
  			prg_cal_type		= p_prg_cal_type AND
  			prg_ci_sequence_number 	= p_prg_ci_sequence_number AND
  			rule_check_dt 		= p_rule_check_dt  AND
  			progression_rule_cat	= p_progression_rule_cat AND
  			pra_sequence_number 	= p_pra_sequence_number;
  	CURSOR c_spra2 IS
  		SELECT 'X'
  		FROM	IGS_PR_SDT_PR_RU_CK 	sprc
  		WHERE	person_id 		= p_person_id AND
  			course_cd 		= p_course_cd AND
  			prg_cal_type 		= p_prg_cal_type AND
  			prg_ci_sequence_number 	= p_prg_ci_sequence_number AND
  			pra_sequence_number 	= p_pra_sequence_number AND
  			rule_check_dt 		> p_rule_check_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_sca;
  	FETCH c_sca INTO v_course_attempt_status;
  	IF c_sca%NOTFOUND THEN
  		CLOSE c_sca;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca;
  	IF v_course_attempt_status NOT IN (
  					cst_enrolled,
  					cst_inactive,
  					cst_intermit,
  					cst_lapsed,
  					cst_discontin)THEN
  		p_message_name := 'IGS_PR_CA_REC_PROU_AENRO_INT';
  		RETURN FALSE;
  	END IF;
  	IF p_rule_check_dt is NOT NULL THEN
  		OPEN c_spra1;
  		FETCH c_spra1 INTO v_passed_ind;
  		IF c_spra1%FOUND THEN
  			IF v_passed_ind = 'Y' THEN
  				CLOSE c_spra1;
  				p_message_name := 'IGS_PR_CNT_CROUT_APRRU_CHPAS';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			CLOSE c_spra1;
  		END IF;
  		OPEN c_spra2;
  		FETCH c_spra2 INTO v_dummy;
  		IF c_spra2%FOUND THEN
  			CLOSE c_spra2;
  			p_message_name := 'IGS_PR_OUT_REC_ALAT_CH_PRCAL';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_spra2;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_spra1%ISOPEN THEN
  			CLOSE c_spra1;
  		END IF;
  		IF c_spra2%ISOPEN THEN
  			CLOSE c_spra2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  		IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_ins;

  --
  -- Validate student progression outcome has the required details
  FUNCTION prgp_val_spo_rqrd(
  p_progression_outcome_type IN VARCHAR2 ,
  p_duration IN NUMBER ,
  p_duration_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_rqrd
  	-- Validate that if  student _progression_outcome has the required details:
   	-- If duration_type is specified (as NORMAL or EFFECTIVE) then a duration
  	-- must be specified, and visa versa
  	-- If related s_progression_outcome_type is SUSPENSION,
  	-- then duration and duration_type must be specified
  	-- If related s_progression_outcome_type is EXCLUSION, EXPULSION, NOPENALTY,
  	-- MANUAL or EX_FUND , then duration and duration_type cannot be specified
  	-- If related s_progress_outcome_type not PROBATION then duration_type cannot
  	-- be EFFECTIVE.
  /*
  ||Change History:
  ||  Who         When          What
  ||==============================================================================||
  ||  NALKUMAR    19-NOV-2002   Bug NO: 2658550. Modified this function as per the||
  ||                            FA110 PR Enh.					  ||
  ||==============================================================================||
  */
  DECLARE
  	cst_normal	CONSTANT	VARCHAR(10) := 'NORMAL';
  	cst_effective	CONSTANT	VARCHAR(10) := 'EFFECTIVE';
  	cst_suspension	CONSTANT	VARCHAR(10) := 'SUSPENSION';
  	cst_exclusion	CONSTANT	VARCHAR(10) := 'EXCLUSION';
  	cst_expulsion	CONSTANT	VARCHAR(10) := 'EXPULSION';
  	cst_nopenalty	CONSTANT	VARCHAR(10) := 'NOPENALTY';
  	cst_manual	CONSTANT	VARCHAR(10) := 'MANUAL';
  	cst_probation	CONSTANT	VARCHAR(10) := 'PROBATION';
	cst_ex_fund	 CONSTANT	VARCHAR2(10):= 'EX_FUND';
	v_s_progression_outcome_type  	IGS_PR_OU_TYPE.s_progression_outcome_type%TYPE;
  	CURSOR c_pot IS
  		SELECT  s_progression_outcome_type
  		FROM    IGS_PR_OU_TYPE	pot
  		WHERE   pot.progression_outcome_type	= p_progression_outcome_type;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_duration_type IS NULL AND
  		p_duration IS NOT NULL THEN
  		p_message_name := 'IGS_PR_DU_SET_DTYP_MSET';
  		RETURN FALSE;
  	END IF;
  	IF p_duration_type IS NOT NULL AND
  		p_duration IS NULL THEN
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
  	IF v_s_progression_outcome_type IN (
  					cst_exclusion,
  					cst_expulsion,
  					cst_nopenalty,
					cst_ex_fund) AND
  			p_duration IS NOT NULL THEN
  		p_message_name := 'IGS_PR_DUTY_PRTY_EXC_NOP';
  		RETURN FALSE;
  	END IF;
  	IF v_s_progression_outcome_type NOT IN (cst_probation, cst_manual) AND
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
  END prgp_val_spo_rqrd;

  --
  -- Validate student progression outcome restricted attendance type
  FUNCTION prgp_val_spo_att(
  p_progression_outcome_type IN VARCHAR2,
  p_restricted_attendance_type IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_att
  	-- Validate that if IGS_PR_STDNT_PR_OU.restricted_attendance_type
  	-- is set that the progression_outcome_type relates to a
  	-- s_encmb_effect_type of RSTR_AT_TY.
  DECLARE
  	cst_rstr_at_ty	CONSTANT	VARCHAR(10) := 'RSTR_AT_TY';
  	v_dummy                         VARCHAR2(1);
  	CURSOR c_pot_etde IS
  		SELECT 	'X'
  		FROM	IGS_PR_OU_TYPE 	pot,
  			IGS_FI_ENC_DFLT_EFT etde
  		WHERE	pot.progression_outcome_type 	= p_progression_outcome_type AND
  			pot.encumbrance_type		= etde.encumbrance_type  AND
  			etde.s_encmb_effect_type	= cst_rstr_at_ty;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot_etde;
  	FETCH c_pot_etde INTO v_dummy;
  	IF c_pot_etde%NOTFOUND THEN
  		IF p_restricted_attendance_type IS NOT NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_RSTR_AT_TY';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF p_restricted_attendance_type IS NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_PROU_TYICM_EPOC_RE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_pot_etde;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot_etde%ISOPEN THEN
  			CLOSE c_pot_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_att;

  --
  -- Validate student progression outcome encumbered course group code
  FUNCTION prgp_val_spo_cgr(
  p_progression_outcome_type IN VARCHAR2 ,
  p_encmb_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_cgr
  	-- Validate that if  IGS_PR_STDNT_PR_OU.encmb_course_group_cd
  	-- is set that the progression_outcome_type relates to a
  	-- s_encmb_effect_type of EXC_CRS_GP.
  DECLARE
  	cst_exc_crs_gp	CONSTANT	VARCHAR(10) := 'EXC_CRS_GP';
  	v_dummy                         VARCHAR2(1);
  	CURSOR c_pot_etde IS
  		SELECT 	'X'
  		FROM	IGS_PR_OU_TYPE 	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type 	= p_progression_outcome_type AND
  			pot.encumbrance_type		= etde.encumbrance_type  AND
  			etde.s_encmb_effect_type	= cst_exc_crs_gp;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot_etde;
  	FETCH c_pot_etde INTO v_dummy;
  	IF c_pot_etde%NOTFOUND THEN
  		IF p_encmb_course_group_cd IS NOT NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_ENCGP_EXC_CRS_GP';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF p_encmb_course_group_cd IS NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_ENCUM_CGP_MEN_EXC';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_pot_etde;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot_etde%ISOPEN THEN
  			CLOSE c_pot_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_cgr;

  --
  -- Validate student progression outcome restricted enrolment cp's
  FUNCTION prgp_val_spo_cp(
  p_progression_outcome_type IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_cp
  	-- Validate that if  IGS_PR_STDNT_PR_OU.restricted_enrolment_cp is
  	-- set that the IGS_PR_OU_TYPE relates to a s_encmb_effect_type of
  	-- RSTR_GE_CP or RSTR_LE_CP.
  DECLARE
  	cst_rstr_ge_cp	CONSTANT	VARCHAR(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp	CONSTANT	VARCHAR(10) := 'RSTR_LE_CP';
  	v_dummy                         VARCHAR2(1);
  	CURSOR c_pot_etde IS
  		SELECT 	'X'
  		FROM	IGS_PR_OU_TYPE 	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type 	= p_progression_outcome_type AND
  			pot.encumbrance_type		= etde.encumbrance_type  AND
  			etde.s_encmb_effect_type	IN (
  								cst_rstr_ge_cp,
  								cst_rstr_le_cp);
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_pot_etde;
  	FETCH c_pot_etde INTO v_dummy;
  	IF c_pot_etde%NOTFOUND THEN
  		IF p_restricted_enrolment_cp IS NOT NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_RSTR_GE_LE_CP';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF p_restricted_enrolment_cp IS NULL THEN
  			CLOSE c_pot_etde;
  			p_message_name := 'IGS_PR_RERN_CPO_MEN_URE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_pot_etde;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot_etde%ISOPEN THEN
  			CLOSE c_pot_etde;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_cp;

  --
  -- Validate student progression outcome duration/duration type changes
  FUNCTION prgp_val_spo_drtn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_decision_status IN VARCHAR2 ,
  p_old_duration IN NUMBER ,
  p_new_duration IN NUMBER ,
  p_old_duration_type IN VARCHAR2 ,
  p_new_duration_type IN VARCHAR2 ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_drtn
  	-- If the IGS_PR_STDNT_PR_OU.duration or duration_type is being
  	-- changed and the decision_status has been set to approved then check that:
  	-- the expiry_dt has not already passed
  	-- the new expiry date would not have already passed
  DECLARE
  	cst_approved	CONSTANT	VARCHAR(10) := 'APPROVED';
  	cst_expired	CONSTANT	VARCHAR(10) := 'EXPIRED';
  	v_expiry_dt			IGS_PR_STDNT_PR_OU.expiry_dt%TYPE;
  	v_apply_automatically_ind
  					IGS_PR_RU_OU.apply_automatically_ind%TYPE;
  	CURSOR c_spo_pro IS
  		SELECT	pro.apply_automatically_ind
  		FROM	IGS_PR_STDNT_PR_OU 	spo,
  			IGS_PR_RU_OU 	pro
  		WHERE	spo.person_id 			= p_person_id AND
  			spo.course_cd 			= p_course_cd AND
  			spo.sequence_number 		= p_sequence_number AND
  			pro.progression_rule_cat (+)		= spo.progression_rule_cat AND
  			pro.pra_sequence_number (+)	= spo.pro_pra_sequence_number AND
  			pro.sequence_number (+)		= spo.pro_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_sequence_number IS NULL OR
  			p_decision_status <> cst_approved THEN
  		RETURN TRUE;
  	END IF;
  	IF NVL(p_old_duration, 0) <> NVL(p_new_duration, 0) OR
  	   NVL(p_old_duration_type, 'NULL') <> NVL(p_new_duration_type, 'NULL') THEN
  		IF TRUNC(NVL(p_expiry_dt, igs_ge_date.igsdate('9999/01/01')))
  				< TRUNC(SYSDATE) THEN
  			p_message_name := 'IGS_PR_DUTY_CNTCH_STPR_OAEXP';
  			RETURN FALSE;
  		END IF;
  		IF p_old_duration IS NULL AND
  				p_old_duration_type IS NULL THEN
  			OPEN c_spo_pro;
  			FETCH c_spo_pro INTO v_apply_automatically_ind;
  			CLOSE c_spo_pro;
  		ELSE
  			v_apply_automatically_ind := NULL;
  		END IF;
  		IF v_apply_automatically_ind IS NULL OR
  				v_apply_automatically_ind = 'N' THEN
  			IF IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
  					p_person_id,
  					p_course_cd,
  					p_sequence_number,
  					NULL,
  					v_expiry_dt) = cst_expired THEN
  				p_message_name := 'IGS_PR_DUTY_CNTCH_STPR_OPEXDT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_spo_pro%ISOPEN THEN
  			CLOSE c_spo_pro;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                    IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_drtn;

  --
  -- Validate if IGS_PS_GRP.course_group_cd is closed.
  FUNCTION crsp_val_cgr_closed(
  p_course_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- crsp_val_cgr_closed
  	-- Validate if IGS_PS_GRP.course_group_cd is closed.
  DECLARE
  	CURSOR c_cg(
  			cp_course_group_cd	IGS_PS_GRP.course_group_cd%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_PS_GRP
  		WHERE	course_group_cd = cp_course_group_cd;
  	v_closed_ind		IGS_PS_GRP.closed_ind%TYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_cg(p_course_group_cd);
  	FETCH c_cg INTO v_closed_ind;
  	IF c_cg%NOTFOUND THEN
  		CLOSE c_cg;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cg;
  	IF v_closed_ind = cst_yes THEN
  		p_message_name := 'IGS_PS_PRGGRP_CODE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                  IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END crsp_val_cgr_closed;

  --
  -- Validate student progression outcome decision status of APPROVED
  FUNCTION prgp_val_spo_approve(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_decision_status IN VARCHAR2 ,
  p_new_decision_status IN VARCHAR2 ,
  p_encmb_course_group_cd IN VARCHAR2 ,
  p_restricted_enrolment_cp IN NUMBER ,
  p_restricted_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  /*
  ||Change History:
  ||  Who         When          What
  ||================================================================================||
  ||  NALKUMAR    19-NOV-2002   Bug NO: 2658550. Modified this function as per the  ||
  ||                            FA110 PR Enh. Added check related to the FUND holds.||
  ||================================================================================||
  */
  BEGIN
        -- prgp_val_spo_approve
  	-- If the IGS_PR_STDNT_PR_OU.decision_status is being set to approved
  	-- then check the encmb_dflt_effect_type.s_encmb_effect_type records related
  	-- to the IGS_PR_OU_TYPE.encumbrance_type defined for the
  	-- student _progression_outcome.IGS_PR_OU_TYPE.
  DECLARE
  	cst_approved	CONSTANT	VARCHAR(10) := 'APPROVED';
  	cst_sus_course	CONSTANT	VARCHAR(10) := 'SUS_COURSE';
  	cst_exc_course	CONSTANT	VARCHAR(10) := 'EXC_COURSE';
  	cst_exc_crs_us	CONSTANT	VARCHAR(10) := 'EXC_CRS_US';
  	cst_exc_crs_u	CONSTANT	VARCHAR(10) := 'EXC_CRS_U';
  	cst_excluded	CONSTANT	VARCHAR(10) := 'EXCLUDED';
  	cst_rqrd_crs_u	CONSTANT	VARCHAR(10) := 'RQRD_CRS_U';
  	cst_required	CONSTANT	VARCHAR(10) := 'REQUIRED';
  	cst_rstr_ge_cp	CONSTANT	VARCHAR(10) := 'RSTR_GE_CP';
  	cst_rstr_le_cp	CONSTANT	VARCHAR(10) := 'RSTR_LE_CP';
  	cst_rstr_at_ty	CONSTANT	VARCHAR(10) := 'RSTR_AT_TY';
  	cst_exc_crs_gp	CONSTANT	VARCHAR(10) := 'EXC_CRS_GP';
  	cst_ex_sp_awd	CONSTANT	VARCHAR(10) := 'EX_SP_AWD';
  	cst_ex_sp_disb	CONSTANT	VARCHAR(15) := 'EX_SP_DISB';
  	cst_expired	CONSTANT	VARCHAR(10) := 'EXPIRED';
  	cst_completed	CONSTANT	VARCHAR2(10) := 'COMPLETED';
  	v_dummy				VARCHAR2(1);
  	v_expiry_dt			IGS_PR_STDNT_PR_OU.expiry_dt%TYPE;
  	v_exit				BOOLEAN	DEFAULT FALSE;
  	v_apply_automatically_ind		VARCHAR2(1);
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	CURSOR c_sca IS
  		SELECT	course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id	= p_person_id AND
  			course_cd	= p_course_cd;
  	CURSOR c_pot_etde IS
  		SELECT 	etde.s_encmb_effect_type
  		FROM	IGS_PR_OU_TYPE 	pot,
  			IGS_FI_ENC_DFLT_EFT		etde
  		WHERE	pot.progression_outcome_type 	= p_progression_outcome_type AND
  			pot. encumbrance_type		= etde.encumbrance_type;
  	CURSOR c_spc IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_PS
  		WHERE	person_id 	 	= p_person_id AND
  			spo_course_cd	 	= p_course_cd AND
  			spo_sequence_number 	= p_sequence_number;
  	CURSOR c_spus IS
  		SELECT	'X'
  		FROM	IGS_PR_SDT_PR_UNT_ST
  		WHERE	person_id 	 	= p_person_id AND
  			course_cd	 	= p_course_cd AND
  			spo_sequence_number 	= p_sequence_number;
	CURSOR c_spuf IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_FND
  		WHERE	person_id 	 	= p_person_id AND
  			course_cd	 	= p_course_cd AND
  			spo_sequence_number 	= p_sequence_number;
	CURSOR c_spu_1 IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_UNIT
  		WHERE	person_id 	 	= p_person_id AND
  			course_cd	 	= p_course_cd AND
  			spo_sequence_number 	= p_sequence_number AND
  			s_unit_type		= cst_excluded;
  	CURSOR c_spu_2 IS
  		SELECT	'X'
  		FROM	IGS_PR_STDNT_PR_UNIT
  		WHERE	person_id 	 	= p_person_id AND
  			course_cd	 	= p_course_cd AND
  			spo_sequence_number 	= p_sequence_number AND
  			s_unit_type		= cst_required;
  	CURSOR c_spo_pro IS
  		SELECT	pro.apply_automatically_ind
  		FROM	IGS_PR_STDNT_PR_OU 	spo,
  			IGS_PR_RU_OU 	pro
  		WHERE	spo.person_id 			= p_person_id AND
  			spo.course_cd 			= p_course_cd AND
  			spo.sequence_number 		= p_sequence_number AND
  			pro.progression_rule_cat (+)	= spo.progression_rule_cat AND
  			pro.pra_sequence_number (+)	= spo.pro_pra_sequence_number AND
  			pro.sequence_number (+)		= spo.pro_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_sequence_number IS NULL OR
  			p_progression_outcome_type IS NULL OR
  			p_old_decision_status IS NULL OR
  			p_new_decision_status IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_new_decision_status = cst_approved THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_course_attempt_status;
  		IF c_sca%FOUND THEN
  			CLOSE c_sca;
  			IF v_course_attempt_status = cst_completed THEN
  				p_message_name := 'IGS_PR_CNT_APOT_CRAT_HCMT';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			CLOSE c_sca;
  		END IF;
  		FOR v_pot_etde_rec IN c_pot_etde LOOP
  			-- If related encumbrance effects contain SUS_COURSE or EXC_COURSE,
  			-- then at least one record must exist in the IGS_PR_STDNT_PR_PS table
  			IF v_pot_etde_rec.s_encmb_effect_type IN (
  								cst_sus_course,
  								cst_exc_course) THEN
  				OPEN c_spc;
  				FETCH c_spc INTO v_dummy;
  				IF c_spc%NOTFOUND THEN
  					CLOSE c_spc;
  					p_message_name := 'IGS_PR_AT_OSTPR_CR_MCR_CSU_EXC';
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_spc;
  			END IF;
  			-- If related encumbrance effects contain EXC_CRS_US, then at least one
  			-- record must exist in the IGS_PR_SDT_PR_RU_CK table
  			IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_us THEN
  				OPEN c_spus;
  				FETCH c_spus INTO v_dummy;
  				IF c_spus%NOTFOUND THEN
  					CLOSE c_spus;
  					p_message_name := 'IGS_PR_AT_OSTPR_CR_MCR_UST_EXC';
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_spus;
  			END IF;
  			-- If related encumbrance effects contain EXC_CRS_U, then a record must
  			-- exist in the IGS_PR_STDNT_PR_UNIT table with s_unit_type of 'EXCLUDE
  			IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_u THEN
  				OPEN c_spu_1;
  				FETCH c_spu_1 INTO v_dummy;
  				IF c_spu_1%NOTFOUND THEN
  					CLOSE c_spu_1;
  					p_message_name := 'IGS_PR_ATON_STPR_UREC_MCR_UEX';
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_spu_1;
  			END IF;
  			-- If related encumbrance effects contain RQRD_CRS_U, then a record must
  			-- exist in the IGS_PR_STDNT_PR_UNIT table with s_unit_type of 'REQUIRED'
  			IF v_pot_etde_rec.s_encmb_effect_type = cst_rqrd_crs_u THEN
  				OPEN c_spu_2;
  				FETCH c_spu_2 INTO v_dummy;
  				IF c_spu_2%NOTFOUND THEN
  					CLOSE c_spu_2;
  					p_message_name := 'IGS_PR_ATON_STPR_UREC_MCR_URE';
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_spu_2;
  			END IF;
  			-- If related encumbrance effects contain RSTR_{GE,LE}_CP then
  			-- spo.restricted_enrolment_cp must be set
  			IF v_pot_etde_rec.s_encmb_effect_type IN (
  								cst_rstr_ge_cp,
  								cst_rstr_le_cp) AND
  				NVL(p_restricted_enrolment_cp, 0) = 0 THEN
  				p_message_name := 'IGS_PR_RERN_CPO_MEN_URE';
  				v_exit := TRUE;
  				EXIT;
  			END IF;
  			-- If related encumbrance effects contain RSTR_AT_TY,  then
  			-- spo.restricted_attendance_type must be set
  			IF v_pot_etde_rec.s_encmb_effect_type = cst_rstr_at_ty AND
  				p_restricted_attendance_type IS NULL THEN
  				p_message_name := 'IGS_PR_REATY_MEN_PROT_ATRES';
  				v_exit := TRUE;
  				EXIT;
  			END IF;
  			-- If related encumbrance effects contain EXC_CRS_GP, then
  			-- spo.encmb_course_group_cd must be set
  			IF v_pot_etde_rec.s_encmb_effect_type = cst_exc_crs_gp AND
  				p_encmb_course_group_cd IS NULL THEN
  				p_message_name := 'IGS_PR_ENCUM_CGP_MEN_EXC';
  				v_exit := TRUE;
  				EXIT;
  			END IF;

			--
			--  Start of new code as per the FA110 TD. Bug# 2658550.
			--
			-- If related encumbrance effects contain 'EX_SP_AWD' or 'EX_SP_DISB', then
  			-- a record must exist in the IGS_PR_STDNT_PR_FND table
			--
  			IF v_pot_etde_rec.s_encmb_effect_type IN (cst_ex_sp_awd,cst_ex_sp_disb) THEN
  				OPEN c_spuf;
  				FETCH c_spuf INTO v_dummy;
  				IF c_spuf%NOTFOUND THEN
  					CLOSE c_spuf;
  					p_message_name := 'IGS_PR_ATON_STPR_FNEC_MCR';
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_spuf;
  			END IF;
			--
			--  End of new code as per the FA110 TD. Bug# 2658550.
			--
  		END LOOP;
  		IF v_exit THEN
  			RETURN FALSE;
  		END IF;
  		OPEN c_spo_pro;
  		FETCH c_spo_pro INTO v_apply_automatically_ind;
  		IF c_spo_pro%FOUND AND
  				(v_apply_automatically_ind IS NULL OR
  				v_apply_automatically_ind = 'N') THEN
  			CLOSE c_spo_pro;
  			-- The outcome cannot be approved if it will already have expired
  			IF IGS_PR_GEN_006.IGS_PR_GET_SPO_EXPIRY (
  					p_person_id,
  					p_course_cd,
  					p_sequence_number,
  					NULL,
  					v_expiry_dt) = cst_expired THEN
  				p_message_name := 'IGS_PR_OUCNT_AP_ALEXP';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			CLOSE c_spo_pro;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pot_etde%ISOPEN THEN
  			CLOSE c_pot_etde;
  		END IF;
  		IF c_spc%ISOPEN THEN
  			CLOSE c_spc;
  		END IF;
  		IF c_spus%ISOPEN THEN
  			CLOSE c_spus;
  		END IF;
  		IF c_spu_1%ISOPEN THEN
  			CLOSE c_spu_1;
  		END IF;
  		IF c_spu_2%ISOPEN THEN
  			CLOSE c_spu_2;
  		END IF;
  		IF c_spo_pro%ISOPEN THEN
  			CLOSE c_spo_pro;
  		END IF;
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_approve;

  --
  -- Validate student progression outcome applied date
  FUNCTION prgp_val_spo_aply_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_old_applied_dt IN DATE ,
  p_new_applied_dt IN DATE ,
  p_decision_status IN VARCHAR2 ,
  p_decision_dt IN DATE ,
  p_show_cause_expiry_dt IN DATE ,
  p_show_cause_outcome_dt IN DATE ,
  p_appeal_expiry_dt IN DATE ,
  p_appeal_outcome_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- Validate that if IGS_PR_STDNT_PR_OU.applied_dt.
  	-- Cannot set applied_dt unless decision_status is APPROVED
  	-- Cannot unset applied_dt unless decision_status is CANCELLED or REMOVED
  	-- The applied_dt cannot be a future date
  	-- The applied_dt must be on or after the decision_dt
  	-- If 'applicable' apply_before_show_ind is N and not beyond
  	--show_cause_expiry_dt then cannot set applied_dt
  	-- If 'applicable' apply_before_appeal_ind is N and not beyond
  	--show_cause_expiry_dt then cannot set applied_dt
  DECLARE
  	cst_cancelled	 CONSTANT	VARCHAR2(10) := 'CANCELLED';
  	cst_removed	 CONSTANT	VARCHAR2(10) := 'REMOVED';
  	cst_approved	 CONSTANT	VARCHAR2(10) := 'APPROVED';
  	v_version_number			IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_apply_start_dt_alias		IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  	v_apply_end_dt_alias		IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  	v_end_benefit_dt_alias		IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  	v_end_penalty_dt_alias		IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  	v_show_cause_cutoff_dt_alias	IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  	v_appeal_cutoff_dt_alias		IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  	v_show_cause_ind			IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  	v_apply_before_show_ind		IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  	v_appeal_ind			IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  	v_apply_before_appeal_ind		IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  	v_count_sus_in_time_ind		IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  	v_count_exc_in_time_ind		IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  	v_calculate_wam_ind		IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  	v_calculate_gpa_ind		IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  	v_outcome_check_type		VARCHAR2(10);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT 	sca
  		WHERE	sca.person_id 		= p_person_id  AND
  			sca.course_cd 		= p_course_cd;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL THEN
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  	   TRUNC(NVL(p_old_applied_dt, igs_ge_date.igsdate('0001/01/01'))) THEN
  		IF p_new_applied_dt IS NULL THEN
  			IF p_decision_status NOT IN (
  						cst_cancelled,
  						cst_removed) THEN
  				p_message_name := 'IGS_PR_CNT_APDT_UNDE_ST_CNREM';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			IF p_decision_status <> cst_approved THEN
  				p_message_name := 'IGS_PR_CNT_APDT_UNL_DEDT_AP';
  				RETURN FALSE;
  			END IF;
  			IF TRUNC(p_new_applied_dt) > TRUNC(SYSDATE) Then
  				p_message_name := 'IGS_PR_APDT_CNT_FUDT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		IF TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01'))) <
  		   TRUNC(NVL(p_decision_dt, igs_ge_date.igsdate('0001/01/01'))) AND
  		   TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('0001/01/01'))) <>
  		   TRUNC(igs_ge_date.igsdate('0001/01/01')) THEN
  			p_message_name := 'IGS_PR_APDT_MST_ONAF_DEDT';
  			RETURN FALSE;
  		END IF;
  		OPEN c_sca;
  		FETCH c_sca INTO v_version_number;
  		CLOSE c_sca;
  		IGS_PR_GEN_003.IGS_PR_GET_CONFIG_PARM (
  					p_course_cd,
  					v_version_number,
  					v_apply_start_dt_alias,
  					v_apply_end_dt_alias,
  					v_end_benefit_dt_alias,
  					v_end_penalty_dt_alias,
  					v_show_cause_cutoff_dt_alias,
  					v_appeal_cutoff_dt_alias,
  					v_show_cause_ind,
  					v_apply_before_show_ind,
  					v_appeal_ind,
  					v_apply_before_appeal_ind,
  					v_count_sus_in_time_ind,
  					v_count_exc_in_time_ind,
  					v_calculate_wam_ind,
  					v_calculate_gpa_ind,
  					v_outcome_check_type);
  		IF v_show_cause_ind = 'Y' AND
  				v_apply_before_show_ind = 'N' AND
  				p_show_cause_outcome_dt IS NULL THEN
  			IF NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01')) <>
  							 igs_ge_date.igsdate('0001/01/01') AND
  			(TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01'))) <
  			TRUNC(NVL(p_show_cause_expiry_dt,
  						 igs_ge_date.igsdate('0001/01/01')))) THEN
  				p_message_name := 'IGS_PR__APDT_CNT_BFSCA_EXDT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		IF v_appeal_ind = 'Y' AND
  				v_apply_before_appeal_ind ='N' AND
  				p_appeal_outcome_dt IS NULL THEN
  			IF NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01')) <>
  							 igs_ge_date.igsdate('0001/01/01') AND
  			(TRUNC(NVL(p_new_applied_dt, igs_ge_date.igsdate('9999/01/01'))) <
  			 TRUNC(NVL(p_appeal_expiry_dt, igs_ge_date.igsdate('0001/01/01')))) THEN
  				p_message_name := 'IGS_PR_APDT_CNT_BFAP_EXP_APNT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_aply_dt;

  --
  -- Validate student progression outcome show cause
  FUNCTION prgp_val_spo_cause(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pro_pra_sequence_number IN NUMBER ,
  p_pro_sequence_number IN NUMBER ,
  p_show_cause_dt IN DATE ,
  p_show_cause_expiry_dt IN DATE ,
  p_show_cause_outcome_dt IN DATE ,
  p_show_cause_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_cause
  	-- Validate the IGS_PR_STDNT_PR_OU show cause details.
  	-- If show cause not allowed then show_cause_expiry_dt, show_cause_dt,
  	-- show_cause_outcome_dt and show_cause_outcome_type cannot be set.
  DECLARE
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  BEGIN
  	p_message_name := null;
  	-- -- Check parameters and test if any of the show cause parameters are set.
  	IF p_person_id IS NULL OR
     			p_course_cd IS NULL OR
  			(p_show_cause_dt IS NULL AND
  			p_show_cause_expiry_dt IS NULL AND
  			p_show_cause_outcome_dt IS NULL AND
  			p_show_cause_outcome_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_sca;
  	FETCH c_sca INTO v_version_number;
  	CLOSE c_sca;
  	IF IGS_PR_GEN_005.IGS_PR_GET_CAUSE_ALWD(
  			p_progression_rule_cat,
  			p_pro_pra_sequence_number,
  			p_pro_sequence_number,
  			p_course_cd,
  			v_version_number) = 'N' THEN
  		p_message_name := 'IGS_PR_SHCA_DTCNT_SHCA_NTALD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                  IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_cause;

  --
  -- Validate student progression outcome appeal
  FUNCTION prgp_val_spo_appeal(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pro_pra_sequence_number IN NUMBER ,
  p_pro_sequence_number IN NUMBER ,
  p_appeal_dt IN DATE ,
  p_appeal_expiry_dt IN DATE ,
  p_appeal_outcome_dt IN DATE ,
  p_appeal_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- prgp_val_spo_appeal
  	-- Validate the IGS_PR_STDNT_PR_OU appeal details.
  	-- If appeal not allowed then appeal_expiry_dt, appeal_dt,
  	-- appeal_outcome_dt and appeal_outcome_type cannot be set.
  DECLARE
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			(p_appeal_dt IS NULL AND
  			p_appeal_expiry_dt IS NULL AND
  			p_appeal_outcome_dt IS NULL AND
  			p_appeal_outcome_type IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_sca;
  	FETCH c_sca INTO v_version_number;
  	CLOSE c_sca;
  	IF IGS_PR_GEN_005.IGS_PR_GET_APPEAL_ALWD(
  			p_progression_rule_cat,
  			p_pro_pra_sequence_number,
  			p_pro_sequence_number,
  			p_course_cd,
  			v_version_number) = 'N' THEN
  		p_message_name := 'IGS_PR_APDT_CNT_APNT_AL';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
               IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_appeal;

  --
  -- Validate student progression outcome outcome type is not being changed
  FUNCTION prgp_val_spo_pot(
  p_old_progression_outcome_type IN VARCHAR2 ,
  p_new_progression_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN	-- prgp_val_spo_pot
  	-- Prevent changes to IGS_PR_STDNT_PR_OU.IGS_PR_OU_TYPE
  	p_message_name := null;
  	IF p_old_progression_outcome_type IS NULL OR
  	   p_new_progression_outcome_type IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_old_progression_outcome_type <> p_new_progression_outcome_type THEN
  		p_message_name := 'IGS_PR_PROUT_TY_CNT_ALT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_pot;

  --
  -- Validate student progression outcome expiry date
  FUNCTION prgp_val_spo_exp_dt(
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail                 VARCHAR2(255);
  BEGIN	-- prgp_val_spo_exp_dt
  	-- Validate that the IGS_PR_STDNT_PR_OU expiry_dt
  	-- is not future dated.  FORM ONLY!!!
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	IF p_expiry_dt IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF TRUNC(p_expiry_dt) > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_PR_EXPDT_CNT_MAN_STFU';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN

  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
  END prgp_val_spo_exp_dt;
END igs_pr_val_spo;

/
