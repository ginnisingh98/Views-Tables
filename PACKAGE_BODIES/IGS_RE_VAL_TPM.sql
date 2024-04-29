--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_TPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_TPM" AS
/* $Header: IGSRE17B.pls 120.1 2006/01/24 01:32:59 bdeviset noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001    Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --msrinivi    25-Aug-2001    Bug No.  1956374. the func genp_val_pe_deceased removed
  -- smaddali  11-may-04      Bug#3577988 - EN302 build, corrected message name IGS_RE_ CANT_UNCNFRM_PAID_DT to remove the space
  -- bdeviset  24-JAN-06      Removed the cursor c_pe in RESP_VAL_TPM_PE procedure and used igs_en_gen_003.get_staff_ind call
  --                          for bug# 4991049
  -------------------------------------------------------------------------------------------
   -- To validate thesis panel member minimum panel size
  FUNCTION RESP_VAL_TPM_MIN(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- func_module
  DECLARE
  	v_tpt_recommended_panel_size	IGS_RE_THS_PNL_TYPE.recommended_panel_size%TYPE;
  	v_panel_cnt			NUMBER;
  	CURSOR c_tpt IS
  		SELECT	tpt.recommended_panel_size
  		FROM	IGS_RE_THS_PNL_TYPE tpt
  		WHERE	thesis_panel_type = p_thesis_panel_type;
  	CURSOR c_tpm IS
  		SELECT	count('x')
  		FROM	IGS_RE_THS_PNL_MBR tpm
  		WHERE	ca_person_id	= p_person_id AND
  			ca_sequence_number = p_ca_sequence_number AND
  			the_sequence_number = p_the_sequence_number AND
  			creation_dt = p_creation_dt AND
  			confirmed_dt IS NOT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Select panel size from thesis panel type
  	OPEN c_tpt;
  	FETCH c_tpt INTO v_tpt_recommended_panel_size;
  	IF c_tpt%NOTFOUND THEN
  		CLOSE c_tpt;
  		--Invalid parameters - return true
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tpt;
  	IF v_tpt_recommended_panel_size IS NULL OR
  			v_tpt_recommended_panel_size =0 THEN
  		--No panel size specified - warning not applicable.
  		RETURN TRUE;
  	END IF;
  	OPEN c_tpm;
  	FETCH c_tpm INTO v_panel_cnt;
  	IF c_tpm%NOTFOUND THEN
  		CLOSE c_tpm;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_tpm;
  	If v_panel_cnt >= v_tpt_recommended_panel_size then
  		p_message_name := 'IGS_RE_RECOM_PANEL_SIZE_REACH';
  		Return TRUE;		-- Warning Only
  	End IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_tpt %ISOPEN THEN
  			CLOSE c_tpt;
  		END IF;
  		IF c_tpm %ISOPEN THEN
  			CLOSE c_tpm;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END RESP_VAL_TPM_MIN;
  --

  -- To validate the thesis panel member chair indicator
  FUNCTION RESP_VAL_TPM_CHAIR(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_chair
  	-- Description: Validate that there is only one confirmed
  	-- chairperson on the panel.
  DECLARE
  	v_loop_bool		BOOLEAN DEFAULT FALSE;
  	CURSOR	c_tpm_tpmpt IS
  		SELECT	'X'
  		FROM	IGS_RE_THS_PNL_MBR		tpm,
  			IGS_RE_THS_PNL_MR_TP	tpmpt
  		WHERE	tpm.ca_person_id		= p_ca_person_id AND
  			tpm.ca_sequence_number		= p_ca_sequence_number AND
  			tpm.the_sequence_number		= p_the_sequence_number AND
  			tpm.creation_dt			= p_creation_dt AND
  			tpm.confirmed_dt IS NOT NULL AND
  			tpmpt.panel_member_type 	= tpm.panel_member_type AND
  			tpmpt.panel_chair_ind 		= 'Y';
  	v_dummy		VARCHAR2(1);
  BEGIN
  	p_message_name := NULL;
  	FOR v_tpm_tpmpt_dummy IN c_tpm_tpmpt
  	LOOP
  		IF((c_tpm_tpmpt%ROWCOUNT) > 1) THEN
  			p_message_name := 'IGS_RE_ONLY_ONE_CHAIRPERSON';
  			v_loop_bool := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF (v_loop_bool = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  	IF (c_tpm_tpmpt%ISOPEN) THEN
  		CLOSE c_tpm_tpmpt;
  	END IF;
  	RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_chair;
  --
  -- To validate thesis panel member paid date
  FUNCTION RESP_VAL_TPM_PAID(
  p_paid_dt IN DATE ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_paid
  	-- Description: Validate the IGS_RE_THS_PNL_MBR.paid_dt, checking for:
  	-- * Cannot set if confirmed_dt is null
  	-- * Cannot be a future date
  	-- * Cannot be prior to confirmed_dt
  DECLARE
  BEGIN
  	p_message_name := NULL;
  	IF p_paid_dt IS NOT NULL THEN
  		--1. Can only be set when confirmed panel member
  		IF p_confirmed_dt IS NULL THEN
  			p_message_name := 'IGS_RE_CANT_SET_PAID_DATE';
  			RETURN FALSE;
  		END IF;
  		--2. Cannot be a future date and must be after the confirmed date
  		IF p_paid_dt NOT BETWEEN p_confirmed_dt
  				AND SYSDATE THEN
  			p_message_name := 'IGS_RE_CHK_PAID_DATE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_paid;
  --
  -- To validate the thesis panel member confirmed date
  FUNCTION RESP_VAL_TPM_CNFRM(
  p_confirmed_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_paid_dt IN DATE ,
  p_declined_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_cnfrm
  	-- Validate the IGS_RE_THS_PNL_MBR.confirmed_dt, checking for :
  	--   Cannot unset if thesis_result_cd has been set
  	--   Cannot unset if paid_dt has been set
  	--   Cannot be a future date
  	--   Cannot set if declined_dt is set
  BEGIN
  	-- set default value
  	p_message_name := NULL;
  	IF p_confirmed_dt IS NULL THEN
  		-- 1. Cannot unset if result has been entered
  		IF p_thesis_result_cd IS NOT NULL THEN
  			p_message_name := 'IGS_RE_CANT_UNCNFRM_RES_ENTER';
  			RETURN FALSE;
  		END IF;
  		-- 2. Cannot unset if paid date has been entered
  		IF p_paid_dt IS NOT NULL THEN
  			p_message_name := 'IGS_RE_CANT_UNCNFRM_PAID_DT';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- 1. Cannot set if member has declined.
  		 IF p_declined_dt IS NOT NULL THEN
  			p_message_name := 'IGS_RE_CANT_SET_MEM_CONFIRM';
  			RETURN FALSE;
  		END IF;
  		-- 2. Cannot be a future date
  		IF p_confirmed_dt > SYSDATE THEN
  			p_message_name := 'IGS_RE_CNFRM_DT_CANT_BE_FUTUR';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_cnfrm; -- resp_val_tpm_cnfrm
  --
  -- To validate thesis panel member declined date
  FUNCTION RESP_VAL_TPM_DCLN(
  p_declined_dt IN DATE ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_dcln
  	-- Validate the IGS_RE_THS_PNL_MBR.declined_dt, checking for :
  	-- Cannot be set if the confirmed_dt is set
  	-- Cannot be a future date
  DECLARE
  BEGIN
  	IF p_declined_dt IS NOT  NULL THEN
  		-- 1. Cannot be set if confirmed date is set
  		IF p_confirmed_dt IS NOT NULL THEN
  			p_message_name := 'IGS_RE_CANT_SET_DECLINED_DATE';
  			RETURN FALSE;
  		END IF;
  		--2. Cannot be a future date
  		IF p_declined_dt > SYSDATE THEN
  			p_message_name := 'IGS_RE_DECL_DT_CANT_BE_FUTURE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_dcln;
  --
  -- To validate the thesis panel member person ID
  FUNCTION RESP_VAL_TPM_PE(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_pe
  	-- Validate the IGS_RE_THS_PNL_MBR.person_id, checking for :
  	-- Warn if the person is a current student
  	-- person cannot be a panel member for themselves
  	-- Warn if the person is a supervisor of the candidate
  DECLARE
  	cst_enrolled	CONSTANT	VARCHAR2(10) := 'ENROLLED';
  	cst_inactive	CONSTANT	VARCHAR2(10) := 'INACTIVE';
  	cst_lapsed	CONSTANT	VARCHAR2(10) := 'LAPSED';
  	cst_intermit	CONSTANT	VARCHAR2(10) := 'INTERMIT';
  	v_dummy				VARCHAR2(1);
  	v_message_name		VARCHAR2(30);
  	CURSOR	c_sca IS
  		SELECT 	'x'
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id 			= p_person_id AND
  			sca.course_attempt_status 	IN (
  							cst_enrolled,
  							cst_inactive,
  							cst_lapsed,
  							cst_intermit);
  	CURSOR	c_rsup IS
  		SELECT 	'x'
  		FROM	IGS_RE_SPRVSR rsup
  		WHERE	rsup.ca_person_id 	= p_ca_person_id 	AND
  			rsup.ca_sequence_number = p_ca_sequence_number 	AND
  			rsup.person_id 		= p_person_id 		AND
  			rsup.start_dt 		<= SYSDATE 		AND
  			(rsup.end_dt 		IS NULL 		OR
   			rsup.end_dt 		> SYSDATE);

  BEGIN
  	p_message_name := NULL;
  	-- Check whether person is deceased.
  	IF IGS_RE_VAL_TEX.genp_val_pe_deceased(	p_person_id,
  						'ERROR',
  						v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--1. Check that person is not a panel member for themselves
  	IF p_ca_person_id = p_person_id THEN
  		p_message_name := 'IGS_RE_PERS_CANT_BE_EXAMINER';
  		RETURN FALSE;
  	END IF;
  	--2. Warn if person is a current student.
  	OPEN c_sca;
  	FETCH c_sca INTO v_dummy;
  	IF c_sca%FOUND THEN
  		CLOSE c_sca;
  		p_message_name := 'IGS_RE_EXAMINER_IS_CUR_STUDEN';
  		RETURN TRUE; --(Warning Only)
  	END IF;
  	CLOSE c_sca;
  	-- Warn if person is a staff member.
  	IF  IGS_EN_GEN_003.Get_Staff_Ind(p_person_id) = 'Y' THEN
  		p_message_name := 'IGS_RE_EXAMINAR_IS_STAFF_MEM';
  		RETURN TRUE;	-- (Warning Only)
  	END IF;

  	-- 3. Warn if person is a supervisor of the candidate
  	OPEN c_rsup;
  	FETCH c_rsup INTO v_dummy;
  	IF c_rsup%FOUND THEN
  		CLOSE c_rsup;
  		p_message_name := 'IGS_RE_PERS_CUR_SUPERVIOR';
  		RETURN TRUE; -- (Warning Only)
  	END IF;
  	CLOSE c_rsup;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		IF (c_rsup%ISOPEN) THEN
  			CLOSE c_rsup;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_pe;
  --
  -- To validate the thesis panel member IGS_RE_THESIS result code
  FUNCTION RESP_VAL_TPM_THR(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 ,
  p_recommendation_summary IN VARCHAR2 ,
  p_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_thr
  	-- Description: Validate the IGS_RE_THS_PNL_MBR.thesis_result_cd
  	-- recommendation_summary fields, checking for :
  	-- * Cannot be a closed IGS_RE_THESIS result code
  	-- * Cannot set if parent thesis_examination has not been submitted
  	-- * Cannot set if panel member has not confirmed
  DECLARE
  	v_tex_rec	IGS_RE_THESIS_EXAM.submission_dt%TYPE;
  	v_thr_rec	IGS_RE_THESIS_RESULT.closed_ind%TYPE;
  	CURSOR	c_tex IS
  		SELECT	tex.submission_dt
  		FROM	IGS_RE_THESIS_EXAM		tex
  		WHERE	tex.person_id		= p_ca_person_id AND
  			tex.ca_sequence_number	= p_ca_sequence_number AND
  			tex.the_sequence_number	= p_the_sequence_number AND
  			tex.creation_dt 	= p_creation_dt;
  	CURSOR	c_thr IS
  		SELECT	thr.closed_ind
  		FROM	IGS_RE_THESIS_RESULT 		thr
  		WHERE	thr.thesis_result_cd 	= p_thesis_result_cd;
  BEGIN
  	p_message_name := NULL;
  	IF p_thesis_result_cd IS NOT NULL OR
  	    p_recommendation_summary IS NOT NULL THEN
  		--Check that person has been confirmed
  		IF p_confirmed_dt IS NULL THEN
  			p_message_name := 'IGS_RE_CANT_ENT_RES_UNCNF_MEM';
  			RETURN FALSE;
  		END IF;
  		OPEN c_tex;
  		FETCH c_tex INTO v_tex_rec;
  		CLOSE c_tex;
  		--Check that IGS_RE_THESIS has been submitted
  		IF v_tex_rec IS NULL THEN
  			p_message_name := 'IGS_RE_CANT_ENT_RES_FOR_THESI';
  			RETURN FALSE;
  		END IF;
  		IF p_thesis_result_cd IS NOT NULL THEN
  			--Check for closed result code
  			OPEN c_thr;
  			FETCH c_thr INTO v_thr_rec;
  			--Invalid date ; to be picked up by calling routine
  			IF (c_thr%NOTFOUND) THEN
  				CLOSE c_thr;
  				RETURN TRUE;
  			END IF;
  			CLOSE c_thr;
  			IF v_thr_rec = 'Y' THEN
  				p_message_name := 'IGS_RE_THESIS_RESUILT_CLOSED';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_tex%ISOPEN) THEN
  			CLOSE c_thr;
  		END IF;
  		IF (c_thr%ISOPEN) THEN
  			CLOSE c_thr;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_thr;
  --
  -- To validate IGS_RE_THESIS panel member panel type
  FUNCTION RESP_VAL_TPM_TPMT(
  p_panel_member_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_tpmt
  	-- Description: Validate the IGS_RE_THS_PNL_MBR.panel_member_type, checking
  	-- for:  Closed type.
  DECLARE
  	v_tpmt_rec		IGS_RE_THS_PNL_MR_TP.closed_ind%TYPE;
  	CURSOR	c_tpmt IS
  		SELECT	tpmt.closed_ind
  		FROM 	IGS_RE_THS_PNL_MR_TP 	tpmt
  		WHERE	tpmt.panel_member_type 		= p_panel_member_type;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_tpmt;
  	FETCH c_tpmt INTO v_tpmt_rec;
  	IF (c_tpmt%NOTFOUND) THEN
  		CLOSE c_tpmt;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tpmt;
  	IF v_tpmt_rec = 'Y' THEN
  		p_message_name := 'IGS_RE_THESIS_PANEL_TYPE_CLOS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_tpmt%ISOPEN) THEN
  			CLOSE c_tpmt;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_tpmt;
  --
  -- To validate thesis panel member updates
  FUNCTION RESP_VAL_TPM_UPD(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_transaction_type IN VARCHAR2 ,
  p_old_thesis_result_cd IN VARCHAR2 ,
  p_new_thesis_result_cd IN VARCHAR2 ,
  p_old_panel_member_type IN VARCHAR2 ,
  p_new_panel_member_type IN VARCHAR2 ,
  p_old_confirmed_dt IN DATE ,
  p_new_confirmed_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_tpm_upd
  	-- Validate whether IGS_RE_THS_PNL_MBR update transactions are possible
  	-- (insert,update and delete), checking for :
  	-- Can only insert or delete records when parent
  	-- thesis_examination.thesis_result_cd is not set
  	-- Cannot update thesis_result_cd, panel_member_type, confirmed_dt if parent
  	-- examination result has been entered.
  DECLARE
  	cst_insert	CONSTANT	VARCHAR2(10) := 'INSERT';
  	cst_delete	CONSTANT	VARCHAR2(10) := 'DELETE';
  	cst_update	CONSTANT	VARCHAR2(10) := 'UPDATE';
  	v_thesis_result_cd		IGS_RE_THESIS_EXAM.thesis_result_cd%TYPE;
  	CURSOR	c_tex IS
  		SELECT	tex.thesis_result_cd
  		FROM	IGS_RE_THESIS_EXAM tex
  		WHERE	tex.person_id 		= p_ca_person_id 	AND
  			tex.ca_sequence_number 	= p_ca_sequence_number	AND
  			tex.the_sequence_number = p_the_sequence_number AND
  			tex.creation_dt 	= p_creation_dt;
  BEGIN
  	p_message_name := NULL;
  	-- 1. Get the result code from the parent thesis examination.
  	OPEN c_tex;
  	FETCH c_tex INTO v_thesis_result_cd;
  	IF c_tex%NOTFOUND THEN
  		--Invalid parameters ; will be picked up be the calling routine.
  		CLOSE c_tex;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_tex;
  	IF p_transaction_type IN (cst_insert, cst_delete) THEN
  		-- 2. If the parent result code is set then insert and delete
  		-- are not possible.
  		IF v_thesis_result_cd IS NOT NULL THEN
  			p_message_name := 'IGS_RE_CANT_ID_PANEL_MEMBERS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF p_transaction_type = cst_update THEN
  		-- 3. If specified fields have changed and the parent result has
  		-- been entered then fail.
  		IF v_thesis_result_cd IS NOT NULL THEN
  			IF NVL(p_old_thesis_result_cd, 'NULL') <>
  					NVL(p_new_thesis_result_cd, 'NULL') OR
  		    			NVL(p_old_panel_member_type, 'NULL') <>
  					NVL(p_new_panel_member_type, 'NULL') OR
  		    			NVL(p_old_confirmed_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
  					NVL(p_new_confirmed_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
  				p_message_name := 'IGS_RE_CANT_UPD_PAN_MEM_TYPE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_tex%ISOPEN) THEN
  			CLOSE c_tex;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_tpm_upd;
END IGS_RE_VAL_TPM;

/
