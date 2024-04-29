--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCT" AS
/* $Header: IGSEN66B.pls 120.1 2005/12/05 07:13:31 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .Modified function GENP_VAL_SDTT_SESS
  --ckasu       20-Nov-2004     modified enrp_val_sua_trnsfr and enrp_val_sct_to procedure
  --                            as aprt of program transfer build bug#4000939
  --ckasu       06-Dec-2004     modified enrp_val_sua_trnsfr procedure as a part of bug#4048248
  --                            inorder to transfer discontinue unit attempt with result other
  --                            than fail from source prgm to dest prgm.
  -- smaddali   21-dec-04       Modified wrong message name in proc enrp_val_sct_to for bug#4080736
  -- smaddali  21-dec-04       modified parameter in procedure enrp_val_sua_acad for bug#4083358
  -- amuthu     23-Dec-2004     The source program for a transfer could be unconfirmed.
  -- bdeviset   07-JAN-2005     Bug# 4103437.Modified enrp_val_sct_to,enrp_val_sct_from.To avoid having
  --                            when a source/destination is already invloved in a stored transfer.
  -------------------------------------------------------------------------------------------

  --
  -- Validate the enrolment period for a transferred course_attempt.
  FUNCTION enrp_val_scae_acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_scae_acad
  	-- When transferring a IGS_EN_STDNT_PS_ATT and the calendar
  	-- type of the IGS_PS_OFR_OPT varies from that of the
  	-- original course, validate that the enrolment period of the
  	-- current IGS_AS_SC_ATMPT_ENR is also a sub-ordinate of the
  	-- new calendar type.
  DECLARE
  	v_ci_sequence_number	IGS_AS_SC_ATMPT_ENR.ci_sequence_number%TYPE;
  	v_cal_type		IGS_AS_SC_ATMPT_ENR.cal_type%TYPE;
  	v_enrolment_cat		IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
  	v_ret			BOOLEAN;
  	CURSOR	c_scae_ci IS
  		SELECT	scae.cal_type,
  			scae.ci_sequence_number,
  			scae.enrolment_cat
  		FROM	IGS_AS_SC_ATMPT_ENR	scae,
  			IGS_CA_INST		ci
  		WHERE	scae.person_id	= p_person_id AND
  			scae.course_cd	= p_course_cd AND
  			scae.cal_type	= ci.cal_type AND
  			scae.ci_sequence_number = ci.sequence_number
  		ORDER BY ci.start_dt DESC;
  BEGIN
  	p_message_name := null;
  	-- Check parameters.
  	IF p_person_id IS NULL OR
  			p_course_cd 	IS NULL OR
  			p_cal_type 	IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the current enrolment period from the latest
  	-- student course attempt enrolment record.
  	OPEN c_scae_ci;
  	FETCH c_scae_ci INTO v_cal_type,
  				v_ci_sequence_number,
  				v_enrolment_cat;
  	IF (c_scae_ci%NOTFOUND) THEN
  		CLOSE c_scae_ci;
  		p_message_name := 'IGS_EN_NO_SPA_ENR_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_scae_ci;
  	v_ret := IGS_EN_GEN_008.ENRP_GET_WITHIN_CI (
  					p_cal_type,
  					NULL,
  					v_cal_type,
  					v_ci_sequence_number,
  					FALSE);
  	IF v_ret = FALSE THEN
  		p_message_name := 'IGS_EN_CURENR_PRD_NOT_SUBORD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_scae_ci%ISOPEN) THEN
  			CLOSE c_scae_ci;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_scae_acad');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scae_acad;
  --
  -- Validate the IGS_PS_OFR_OPT for a transferred unit_attempt
  -- smaddali modified parameter for bug#4083358
  FUNCTION enrp_val_sua_acad(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_uoo_id    IN NUMBER,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_sua_acad
  	-- Validate whether the ENROLLED unit attempt has a link to an instance of
  	-- their enrolled course academic calendar type.
  	-- This is the result of a change of course offering option calendar type
  	-- during a course transfer.
  DECLARE
  	v_acad_cal_type			IGS_CA_INST.cal_type%TYPE;
  	v_acad_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE;
  	v_acad_ci_start_dt		IGS_CA_INST.start_dt%TYPE;
  	v_acad_ci_end_dt		IGS_CA_INST.end_dt%TYPE;
  	v_alternate_code		IGS_CA_INST.alternate_code%TYPE;
  	v_message_name			varchar2(30);
  	CURSOR c_sua IS
  		SELECT	sua.cal_type,
  			sua.ci_sequence_number
  		FROM	IGS_EN_SU_ATTEMPT	sua
  		WHERE	person_id		= p_person_id	AND
  			   course_cd		= p_course_cd	AND
  			   uoo_id			= p_uoo_id	;
  	v_sua_rec		c_sua%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- 1. Check parameters.
  	IF p_person_id			IS NULL	OR
  			p_course_cd	IS NULL	OR
  			p_uoo_id	IS NULL	OR
  			p_cal_type	IS NULL		THEN
  		RETURN TRUE;
  	END IF;
  	-- 2. Fetch the unit attempt record.
  	OPEN c_sua;
  	FETCH c_sua INTO v_sua_rec;
  	IF c_sua%NOTFOUND THEN
  		-- this should not happen
  		CLOSE c_sua;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sua;
  	-- 3. Check if a link exists.
  	v_alternate_code := IGS_EN_GEN_002.ENRP_GET_ACAD_ALT_CD(
  					v_sua_rec.cal_type,
  					v_sua_rec.ci_sequence_number,
  					v_acad_cal_type,
  					v_acad_ci_sequence_number,
  					v_acad_ci_start_dt,
  					v_acad_ci_end_dt,
  					v_message_name);
  	IF v_acad_cal_type IS NULL OR v_acad_cal_type <> p_cal_type THEN
  		p_message_name := 'IGS_EN_UA_TEACHPRD_NOTLINKED';
  		RETURN FALSE;
  	END IF;
  	-- 4. Set p_message_name to 0
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sua%ISOPEN THEN
  			CLOSE c_sua;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_sua_acad');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sua_acad;
  --
  -- To validate student course transfer insert
  FUNCTION enrp_val_sct_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_sct_insert
  	-- This module validates IGS_PS_STDNT_TRN courses.
  	-- Course_cd and transfer_course_cd must not be the same.
  	-- Course_cd and transfer_course_cd must be in a system defined course transfer
  	-- group type, and must be members of the same group.
  	-- Validate course_cd.
  	-- Validate transfer_course_cd.
  DECLARE
  	cst_unconfirm	CONSTANT	VARCHAR(9) := 'UNCONFIRM';
  	cst_transfer	CONSTANT	VARCHAR(8) := 'TRANSFER';
  	cst_admtransfr	CONSTANT	VARCHAR(10) := 'ADMTRANSFR';
  	v_dummy				VARCHAR2(1);
  	v_message_name			varchar2(30);
  	v_to_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_to_course_attempt_status	IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
   	v_to_acai_sequence_number	IGS_EN_STDNT_PS_ATT.adm_sequence_number%TYPE;
  	v_s_course_group_type		IGS_PS_GRP_TYPE.s_course_group_type%TYPE;
  	v_from_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_from_course_attempt_status
  		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_to_admission_appl_number
  		IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE;
   	v_to_nominated_course_cd
  		IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE;
  	CURSOR	c_sca_to IS
  		SELECT 	sca.version_number,
  			sca.course_attempt_status,
  			sca.adm_admission_appl_number,
  			sca.adm_nominated_course_cd ,
  			sca.adm_sequence_number
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd;
  	CURSOR c_sca_from IS
  		SELECT 	sca.version_number,
  			sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_transfer_course_cd;
  	CURSOR c_cgm_cg_cgt(
  		cp_s_course_group_type	IGS_PS_GRP_TYPE.s_course_group_type%TYPE,
  		cp_to_version_number 	IGS_EN_STDNT_PS_ATT.version_number%TYPE,
  		cp_from_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE)
  	IS
  		SELECT	'x'
  		FROM 	IGS_PS_GRP_MBR cgm,
  			IGS_PS_GRP cg,
  			IGS_PS_GRP_TYPE cgt
  		WHERE	cgm.course_cd 		= p_course_cd 			AND
  			cgm.version_number	= cp_to_version_number 		AND
  			cgt.s_course_group_type = cp_s_course_group_type 	AND
  			cg.course_group_cd 	= cgm.course_group_cd 		AND
  			cg.course_group_type 	= cgt.course_group_type 	AND
  			EXISTS	(SELECT 'x'
  				FROM 	IGS_PS_GRP_MBR cgm2
  				WHERE	cgm2.course_cd 		= p_transfer_course_cd 		AND
  					cgm2.version_number 	= cp_from_version_number 	AND
  					cgm2.course_group_cd 	= cgm.course_group_cd);
  BEGIN
  	p_message_name := null;
  	-- Validate that transfer 'from' and 'to' course codes are not the same.
  	IF p_course_cd = p_transfer_course_cd THEN
  		p_message_name := 'IGS_EN_UA_FAILS_ST_INVALID';
  		RETURN FALSE;
  	END IF;
  	-- Get student course attempt details for transfer 'to' IGS_PS_COURSE
  	OPEN c_sca_to;
  	FETCH c_sca_to INTO	v_to_version_number,
  				v_to_course_attempt_status,
   				v_to_admission_appl_number,
   				v_to_nominated_course_cd,
   				v_to_acai_sequence_number;
  	IF (c_sca_to%NOTFOUND) THEN
  		-- Return, This error will be resolved elsewhere.
  		CLOSE c_sca_to;
  		p_message_name := null;
  		RETURN FALSE;
  	ELSE
  		CLOSE c_sca_to;
  		-- Set system course group type depending on status of transfer 'to'
  		-- course attempt
  		IF v_to_course_attempt_status = cst_unconfirm THEN
  			v_s_course_group_type := cst_admtransfr;
  		ELSE
  			v_s_course_group_type := cst_transfer;
  		END IF;
  	END IF;
  	-- Get student course attempt details for transfer 'from' course
  	OPEN c_sca_from;
  	FETCH c_sca_from INTO 	v_from_version_number,
  				v_from_course_attempt_status;
  	IF (c_sca_from%NOTFOUND) THEN
  		-- Return, This error will be resolved elsewhere.
  		CLOSE c_sca_from;
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca_from;
  	-- Validate that transfer 'from' and transfer 'to' course attempts are
  	-- members of the same course group, and are mapped to system course group
  	-- type 'TRANSFER' or 'ADMTRANSFR'.
  	OPEN c_cgm_cg_cgt(
  		v_s_course_group_type,
  		v_to_version_number,
  		v_from_version_number);
  	FETCH c_cgm_cg_cgt INTO v_dummy;
  	IF (c_cgm_cg_cgt%NOTFOUND) THEN
  		CLOSE c_cgm_cg_cgt;
  		p_message_name := 'IGS_EN_TOPRG_TRNS_TO_PRG';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cgm_cg_cgt;
  	-- Validate transfer 'to' course code
  	IF IGS_EN_VAL_SCT.enrp_val_sct_to(
  			p_person_id,
  			p_course_cd,
  			p_transfer_dt,
  			v_to_version_number,
  			v_to_course_attempt_status,
  			v_to_admission_appl_number,
  			v_to_nominated_course_cd,
  			v_to_acai_sequence_number,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate transfer 'from' course code
  	IF IGS_EN_VAL_SCT.enrp_val_sct_from(
  			p_person_id,
  			p_course_cd,
  			p_transfer_course_cd,
  			p_transfer_dt,
  			v_from_course_attempt_status,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca_to%ISOPEN) THEN
  			CLOSE c_sca_to;
  		END IF;
  		IF (c_sca_from%ISOPEN) THEN
  			CLOSE c_sca_from;
  		END IF;
  		IF (c_cgm_cg_cgt%ISOPEN) THEN
  			CLOSE c_cgm_cg_cgt;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_sct_insert');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sct_insert;
  --
  -- To validate student course transfer 'to' course code
  FUNCTION enrp_val_sct_to(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_crv_version_number IN NUMBER ,
  p_course_attempt_status IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS


  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --ckasu       20-Nov-2004     modified procedure by removing message IGS_EN_TRANSDT_NOTBE_FUTUREDT
  --                            and corresponding if condition as aprt of program transfer
  --                            build bug#4000939
  --bdeviset    07-JAN-2005    Bug# 4103437.Modified cursor c_sct. To avoid having another transfer
  --                            when a destination program is already invloved in a stored transfer.
  -------------------------------------------------------------------------------------------
  BEGIN	-- enrp_val_sct_to
  	-- This module validates IGS_PS_STDNT_TRN.course_cd details.
  	-- Course_cd must not be course version defined as generic.
  	-- Course_cd must map to IGS_EN_STDNT_PS_ATT whose course_attempt_status
  	-- is 'ENROLLED', 'INTERMIT', 'INACTIVE' or ('UNCONFIRM'  and
  	-- admission_course_appl matching transfer details exist).
  	-- NOTE: also allow 'DISCONTIN' to prevent invalid lifting of discontinuation
  	-- through ENRF3000.
  	-- If IGS_EN_STDNT_PS_ATT is created through Admissions, the related
  	-- IGS_AD_PS_APPL_INST.IGS_AD_OU_STAT must map to
  	-- s_adm_outcome_status 'OFFER', 'COND-OFFER'.
  	-- If IGS_EN_STDNT_PS_ATT is created through Admissions, the related
  	-- IGS_AD_PS_APPL_INST.IGS_AD_OFR_RESP_STAT must map to
  	-- s_adm_offer_resp_status 'REJECTED', 'LAPSED'.
  	-- Course_cd must not have existing IGS_PS_STDNT_TRN mapping whose
  	-- transfer_dt is >= this transfer_dt.
  	-- Transfer_dt >= IGS_EN_STDNT_PS_ATT.commencement_dt and <= today's date
  DECLARE
  	cst_lapsed	CONSTANT	VARCHAR2(6) := 'LAPSED';
  	cst_discontin	CONSTANT	VARCHAR2(9) := 'DISCONTIN';
  	cst_completed	CONSTANT	VARCHAR2(9) := 'COMPLETED';
  	cst_transfer	CONSTANT	VARCHAR2(8) := 'TRANSFER';
  	cst_unconfirm	CONSTANT	VARCHAR2(9) := 'UNCONFIRM';
  	v_dummy				VARCHAR2(1);
  	v_generic_course_ind		IGS_PS_VER.generic_course_ind%TYPE;
  	v_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE;
  	v_adm_outcome_status		IGS_AD_PS_APPL_INST.adm_outcome_status%TYPE;
  	v_adm_offer_resp_status		IGS_AD_PS_APPL_INST.adm_offer_resp_status%TYPE;
  	v_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	CURSOR	c_cv IS
  		SELECT	generic_course_ind
  		FROM 	IGS_PS_VER cv
  		WHERE 	cv.course_cd 		= p_course_cd AND
  			cv.version_number 	= p_crv_version_number;
  	CURSOR c_aa IS
  		SELECT 	s_admission_process_type
  		FROM	IGS_AD_APPL aa
  		WHERE	aa.person_id 			= p_person_id AND
  			aa.admission_appl_number 	= p_admission_appl_number;
  	CURSOR c_acai IS
  		SELECT 	adm_outcome_status,
  			adm_offer_resp_status
  		FROM 	IGS_AD_PS_APPL_INST acai
  		WHERE	acai.person_id 			= p_person_id 			AND
  			acai.admission_appl_number 	= p_admission_appl_number 	AND
  			acai.nominated_course_cd 	= p_nominated_course_cd		AND
  			acai.sequence_number		= p_acai_sequence_number;

    -- cursor to check if a destination program is already invloved in a stored transfer
  	CURSOR c_sct IS
  		SELECT 	'x'
  		FROM	IGS_PS_STDNT_TRN sct
  		WHERE	sct.person_id 		= p_person_id 	AND
  			(course_cd 		= p_course_cd 	OR
  			transfer_course_cd 	= p_course_cd) 	AND
  			status_flag = 'U';
  	CURSOR c_sca IS
  		SELECT	sca.commencement_dt
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id 	= p_person_id AND
  			sca.course_cd 	= p_course_cd;
  BEGIN
  	p_message_name := null;
  	-- Validate parameters
  	IF p_person_id IS NULL OR
  			p_course_cd 		IS NULL OR
  			p_transfer_dt 		IS NULL OR
  			p_crv_version_number 	IS NULL OR
  			p_course_attempt_status IS NULL THEN
  		p_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER';
  		RETURN FALSE;
  	END IF;
  	-- Validate that course attempt is not mapped to a course version that
  	-- is defined as generic
  	OPEN c_cv;
  	FETCH c_cv INTO v_generic_course_ind;
  	IF (c_cv%NOTFOUND) THEN
  		-- return, this error will be resolved elsewhere
  		CLOSE c_cv;
  		p_message_name := null;
  		RETURN TRUE;
  	ELSE
  		IF (v_generic_course_ind = 'Y') THEN
  			CLOSE c_cv;
  			p_message_name := 'IGS_EN_TOPRG_NOT_MAP';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate course attempt status and related admission status
    -- smaddali modified message name from 3942 to IGS_EN_TOPRG_NOT_LAPSED, bug#4080736
  	IF p_course_attempt_status IN (
  			cst_lapsed,
  			cst_completed) THEN
  		p_message_name := 'IGS_EN_TOPRG_NOT_LAPSED';
  		RETURN FALSE;
  	ELSIF
  		p_course_attempt_status = 'UNCONFIRM' THEN
  		OPEN c_aa;
  		FETCH c_aa INTO v_s_admission_process_type;
  		IF (c_aa%NOTFOUND) OR
  				v_s_admission_process_type <> cst_transfer THEN
  			CLOSE c_aa;
  			p_message_name := 'IGS_EN_TOPRG_NOT_UNCONFIRMED';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_aa;
  		-- Cannot transfer if admission course application was not offered or
  		-- The applicant has already responded, and rejected, or the application
  		-- has lapsed
  		OPEN c_acai;
  		FETCH c_acai INTO 	v_adm_outcome_status,
  					v_adm_offer_resp_status;
  		IF (c_acai%NOTFOUND) THEN
  			CLOSE c_acai;
  			p_message_name := 'IGS_EN_TOPRG_NOT_ADMPRG_APPL';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_acai;
  			-- Determine the admission course application is valid
  			-- for course Transfer
  			IF IGS_EN_GEN_002.ENRP_GET_ACAI_OFFER(
  					v_adm_outcome_status,
  					v_adm_offer_resp_status) = 'N' THEN
  				p_message_name := 'IGS_EN_TOPRG_NOTLINK_ADMPRG';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate that student course transfer details do not already exist for
  	-- this course attempt Where the transfer to date is >= this transfer date
  	OPEN c_sct;
  	FETCH c_sct INTO v_dummy;
  	IF (c_sct%FOUND) THEN
  		CLOSE c_sct;
  		p_message_name := 'IGS_EN_TOPRG_TRNS_RELATIONSHI';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sct;
  	-- Validate that transfer date is on or after the course commencement date
  	-- and on or before today's date
  	-- IF p_transfer_dt > TRUNC(SYSDATE) THEN
  		OPEN c_sca;
  		FETCH c_sca INTO v_commencement_dt;
  		IF (c_sca%NOTFOUND) THEN
  			CLOSE c_sca;
  			p_message_name := null;
  			RETURN TRUE;	-- this should never occur
  		ELSE
  			CLOSE c_sca;
  			IF v_commencement_dt IS NOT NULL AND
  					p_transfer_dt < v_commencement_dt THEN
  				p_message_name := 'IGS_EN_TRANSDT_NOTBE_PRIOR';
  				RETURN FALSE;
  			END IF;
  		END IF;

  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_cv%ISOPEN) THEN
  			CLOSE c_cv;
  		END IF;
  		IF (c_aa%ISOPEN) THEN
  			CLOSE c_aa;
  		END IF;
  		IF (c_acai%ISOPEN) THEN
  			CLOSE c_acai;
  		END IF;
  		IF (c_sct%ISOPEN) THEN
  			CLOSE c_sct;
  		END IF;
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_sct_to');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sct_to;
  --
  -- To validate student course transfer 'from' course code
  FUNCTION enrp_val_sct_from(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_transfer_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  --Change History :
  --Who             When            What
  --bdeviset    07-JAN-2005    Bug# 4103437.Modified cursor c_sct_sca. To avoid having another transfer
  --                            when a source program is already invloved in a stored transfer.

  BEGIN	-- enrp_val_sct_from
  	-- This module validates IGS_PS_STDNT_TRN.transfer_course_cd details.
  	-- Transfer_course_cd must map to IGS_EN_STDNT_PS_ATT whose
  	-- course_attempt_status is 'ENROLLED', 'DISCONTIN', 'INACTIVE',
  	-- 'INTERMIT', 'COMPLETED', 'LAPSED'.
  	-- Transfer_course_cd must not have existing IGS_PS_STDNT_TRN mapping
  	-- whose transfer_dt is >= this transfer_dt.
  	-- Transfer_course_cd is not currently transferred to IGS_EN_STDNT_PS_ATT
  	-- with course_attempt_status 'ENROLLED', 'INACTIVE', 'INTERMIT','LAPSED'.
  DECLARE
  	cst_enrolled	CONSTANT 	VARCHAR2(10) := 'ENROLLED';
  	cst_inactive	CONSTANT 	VARCHAR2(10) := 'INACTIVE';
  	cst_intermit	CONSTANT 	VARCHAR2(10) := 'INTERMIT';
  	cst_lapsed	CONSTANT 	VARCHAR2(10) := 'LAPSED';
  	cst_unconfirm	CONSTANT 	VARCHAR2(10) := 'UNCONFIRM';
  	v_dummy		VARCHAR2(1);

 --cursor to check if a source program is  invloved in a stored transfer

CURSOR c_sct_sca IS
  		SELECT 	'x'
  		FROM	IGS_PS_STDNT_TRN sct
  		WHERE	sct.person_id 		= p_person_id 	AND
  			(course_cd 		= p_transfer_course_cd 	OR
  			transfer_course_cd 	= p_transfer_course_cd) 	AND
  			status_flag = 'U';
  BEGIN
  	p_message_name := null;
  	-- Validate parameters
  	IF (p_person_id IS NULL OR
  			p_course_cd	 	IS NULL OR
  			p_transfer_course_cd 	IS NULL OR
  			p_transfer_dt 		IS NULL OR
  			p_course_attempt_status IS NULL) THEN
  		p_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER';
  		RETURN FALSE;
  	END IF;
/*
    -- validate course_attempt_status
  	IF p_course_attempt_status = cst_unconfirm THEN
  		p_message_name := 'IGS_EN_FROMPRG_NOT_UNCONFIRM';
  		RETURN FALSE;
  	END IF;
*/

  	-- Validate that transfer 'from' course attempt is not currently transferred
  	-- to course attempt with enrolled, inactive or intermission course attempt
  	-- status.
  	OPEN c_sct_sca;
  	FETCH c_sct_sca INTO v_dummy;
  	IF (c_sct_sca%FOUND) THEN
  		CLOSE c_sct_sca;
  		p_message_name := 'IGS_EN_FROMPRG_TRNS_RELATION';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sct_sca;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sct_sca%ISOPEN) THEN
  			CLOSE c_sct_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_sct_from');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sct_from;
  --
  -- To validate transfer of SUA.
  FUNCTION enrp_val_sua_trnsfr(
  p_person_id           IN NUMBER ,
  p_course_cd           IN VARCHAR2 ,
  p_unit_cd             IN VARCHAR2 ,
  p_cal_type            IN VARCHAR2 ,
  p_ci_sequence_number  IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name        OUT NOCOPY VARCHAR2,
  p_uoo_id              IN NUMBER,
  p_unit_outcome   OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS
/*
||  Created By : pkpatel
||  Created On : 27-SEP-2002
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  kkillams        21-03-2003      Modified validation, to bypass the IGS_EN_SUA_ENR_COMPL_DISCN_DU error message
||                                  for the wait list units w.r.t bug 2863707
||  kkillams        28-04-2003      Added new parameter p_uoo_id to the enrp_val_sua_trnsfr function
||                                  w.r.t. bug number 2829262
||  ckasu           20-Nov-2004     added new parameter p_unit_outcome as a part of Program Transfer build bug#4000939
||  ckasu           06-Dec-2004     removed IF p_outcome <> 'FAIL' THEN as a part of bug#4048248 inorder to transfer
||                                  discontinue unit attempt with result other than fail from source prgm to dest prgm.
*/
  BEGIN	-- enrp_val_sua_trnsfr
  	-- This module validates that only student_unit_attempts with
  	-- unit_attempt_status values of 'ENROLLED', 'COMPLETED',
  	-- 'DISCONTIN' and 'DUPLICATE', can transferred as a result of
  	-- a course transfer.

  DECLARE
  	cst_completed	CONSTANT	VARCHAR(9)   := 'COMPLETED';
  	cst_enrolled	CONSTANT	VARCHAR(9)   := 'ENROLLED';
  	cst_discontin	CONSTANT	VARCHAR(9)   := 'DISCONTIN';
  	cst_duplicate	CONSTANT	VARCHAR(9)   := 'DUPLICATE';
  	cst_fail	CONSTANT	VARCHAR(9)   := 'FAIL';
        cst_waitlist    CONSTANT        VARCHAR2(10) := 'WAITLISTED';
        cst_invalid     CONSTANT        VARCHAR2(10) := 'INVALID';
  	v_outcome_dt		IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  	v_grading_schema_cd	IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  	v_gs_version_number	IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  	v_grade			IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  	v_mark			IGS_AS_SU_STMPTOUT.mark%TYPE;
  	v_origin_course_cd	IGS_AS_SU_STMPTOUT.course_cd%TYPE;
  	v_s_result_type		IGS_LOOKUPS_VIEW.lookup_code%TYPE;
  BEGIN

  	p_message_name := null;
  	IF p_unit_attempt_status NOT IN (
  					cst_completed,
  					cst_enrolled,
  					cst_discontin,
  					cst_duplicate,
                                        cst_waitlist,
                                        cst_invalid) THEN
  		p_message_name := 'IGS_EN_SUA_ENR_COMPL_DISCN_DU';
  		RETURN FALSE;
  	END IF;
  	IF p_unit_attempt_status = cst_discontin THEN
  		p_unit_outcome := IGS_AS_GEN_003.ASSP_GET_SUA_OUTCOME(
  							p_person_id,
  							p_course_cd,
  							p_unit_cd,
  							p_cal_type,
  							p_ci_sequence_number,
  							p_unit_attempt_status,
  							'Y',
  							v_outcome_dt,
  							v_grading_schema_cd,
  							v_gs_version_number,
  							v_grade,
  							v_mark,
  							v_origin_course_cd,
                                                        p_uoo_id,
--added by LKAKI---
							'N');

  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_sua_trnsfr');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_sua_trnsfr;
  --
  -- To validate a student unit set attempt exists.
  FUNCTION enrp_val_susa_exists(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

  BEGIN	-- enrp_val_susa_exist
  	-- Check that a student unit set attempt which
  	-- is to be created as a result of a course transfer.
  DECLARE
  	CURSOR	c_susa IS
  		SELECT	'x'
  		FROM	IGS_AS_SU_SETATMPT
  		WHERE	person_id 		= p_person_id AND
  			course_cd 		= p_course_cd AND
  			unit_set_cd 		= p_unit_set_cd AND
  			us_version_number 	= p_us_version_number;
  	v_susa_found	VARCHAR2(1) DEFAULT NULL;
  BEGIN
  	p_message_name := null;
  	-- Check parameters
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_unit_set_cd IS NULL OR
  			p_us_version_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Check whether student unit attempt already exist.
  	-- This could be as a result of a proir transfer or admissions pre-enrolment.
  	OPEN c_susa;
  	FETCH c_susa INTO v_susa_found;
  	IF (c_susa%FOUND) THEN
  		CLOSE c_susa;
  		p_message_name := 'IGS_EN_SUA_SET_ATT_TRNS_EXIST';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_susa;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_susa%ISOPEN) THEN
  			CLOSE c_susa;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCT.enrp_val_susa_exists');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_susa_exists;

END ;

/
