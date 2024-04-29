--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACA" AS
 /* $Header: IGSAD21B.pls 115.5 2002/11/28 21:26:52 nsidana ship $ */
  --
  -- To validate discontinuation and student course transfer
  FUNCTION enrp_val_sca_trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_discontinued_dt IN DATE ,
  p_validation_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN IS
  BEGIN	-- enrp_val_sca_trnsfr
  	-- This module validates IGS_PS_STDNT_TRN links to a
  	-- IGS_EN_STDNT_PS_ATT when lifting discontinuation.
  	-- Do not allow lifting of discontinuation if IGS_PS_STDNT_TRN
  	-- exists where
  	-- * IGS_PS_STDNT_TRN details already exist against the course
  	--   attempt and the last transfer was not 'to' the course.
  	-- * The transfer_course_cd has IGS_PS_STDNT_TRN links where the
  	--   course transferred to is currently enrolled, inactive, intermitted
  	--   or lapsed.
  DECLARE
  	cst_enrolled	CONSTANT	VARCHAR2(10) := 'ENROLLED';
  	cst_inactive	CONSTANT	VARCHAR2(10) := 'INACTIVE';
  	cst_intermit	CONSTANT	VARCHAR2(10) := 'INTERMIT';
  	cst_lapsed	CONSTANT	VARCHAR2(10) := 'LAPSED';
  	v_trnsfr_crs_cd			IGS_PS_STDNT_TRN.transfer_course_cd%TYPE;
  	v_link_found			BOOLEAN	DEFAULT FALSE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_sct IS
  		SELECT	sct.transfer_course_cd
  		FROM 	IGS_PS_STDNT_TRN sct
  		WHERE	sct.person_id 		= p_person_id AND
  			(sct.course_cd 		= p_course_cd OR
  			sct.transfer_course_cd 	= p_course_cd)
  		ORDER BY transfer_dt desc;
  		CURSOR c_sct_sca_course_cd IS
  		SELECT 	sca.course_cd
  		FROM	IGS_EN_STDNT_PS_ATT	sca,
  			IGS_PS_STDNT_TRN	sct
  		WHERE	sct.person_id 		= p_person_id AND
  			sct.course_cd 		= p_course_cd AND
  			sca.person_id 		= sct.person_id AND
  			sca.course_cd		= sct.transfer_course_cd;
  	CURSOR c_sct_sca(
  			cp_transfer_course_cd	IGS_PS_STDNT_TRN.transfer_course_cd%TYPE) IS
  		SELECT 	'X'
  		FROM 	IGS_PS_STDNT_TRN sct,
  			IGS_EN_STDNT_PS_ATT sca
  		WHERE 	sct.person_id 		= p_person_id AND
  			sct.transfer_course_cd 	= cp_transfer_course_cd AND
  			(sct.course_cd 		<> p_course_cd) AND
  			sca.person_id 		= sct.person_id AND
  			sca.course_cd 		= sct.course_cd AND
  			sca.course_attempt_status IN (
  						cst_enrolled,
  						cst_inactive,
  						cst_intermit,
  						cst_lapsed);
  BEGIN
  	p_message_name := null;
  	IF p_discontinued_dt IS NULL THEN
  		-- Validate that if student course transfer details exist, then the last was
  		-- a transfer to this course
  		OPEN c_sct;
  		FETCH c_sct INTO v_trnsfr_crs_cd;
  		IF (c_sct%FOUND) THEN
  			IF v_trnsfr_crs_cd = p_course_cd THEN
  				CLOSE c_sct;
  				-- Cannot lift discontinuation unless last transfer was to this course
  				IF p_validation_ind = 'E' THEN
  					-- Do not allow lifting of student course attempt discontinuation
  					p_message_name := 'IGS_EN_DISCONT_NOTLIFT_PRGATT';
  					RETURN FALSE;
  				ELSE
  					-- Disallow application for course re_admission
  					p_message_name := 'IGS_EN_READM_NOT_VALID';
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  		CLOSE c_sct;
  		-- Validate that student course transfers do not exist for the 'from' course
  		-- attempt that are active.
  		FOR  v_transfer_course_cd IN c_sct_sca_course_cd LOOP
  			-- Determine if transferred from course has other transfer links that
  			-- are enrolled.
  			OPEN c_sct_sca(v_transfer_course_cd.course_cd);
  			FETCH c_sct_sca INTO v_dummy;
  			IF (c_sct_sca%FOUND) THEN
  				CLOSE c_sct_sca;
  				v_link_found := TRUE;
  				IF p_validation_ind = 'E' THEN
  					p_message_name := 'IGS_EN_DISCONT_NOT_FROM_TRNS';
  				ELSE
  					p_message_name := 'IGS_EN_READM_INVALID';
  				END IF;
  				EXIT;
  			END IF;
  			CLOSE c_sct_sca;
  		END LOOP;
  		IF v_link_found = TRUE THEN
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sct%ISOPEN) THEN
  			CLOSE c_sct;
  		END IF;
  		IF (c_sct_sca_course_cd%ISOPEN) THEN
  			CLOSE c_sct_sca_course_cd;
  		END IF;
  		IF (c_sct_sca%ISOPEN) THEN
  			CLOSE c_sct_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.enrp_val_sca_trnsfr');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END enrp_val_sca_trnsfr;
  --

  -- The following procedures have been commented to handle mutation logic

  -- To validate the admission application preference limit.
  FUNCTION admp_val_pref_limit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_pref_limit  NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN 	-- admp_val_pref_limit
  	-- Validate preference limit.
  DECLARE
  	cst_course		CONSTANT	VARCHAR2(6) := 'COURSE';
  	v_count_acai		NUMBER;
  	CURSOR c_acai (
  			cp_person_id			IGS_AD_APPL.person_id%TYPE,
  			cp_admission_appl_number	IGS_AD_APPL.admission_appl_number%TYPE,
  			cp_nominated_course_cd		IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
  			cp_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
  		SELECT	COUNT(*)
  		FROM	IGS_AD_PS_APPL_INST	acai
  		WHERE	acai.person_id			= cp_person_id AND
  			acai.admission_appl_number	= cp_admission_appl_number AND
  			NOT (acai.nominated_course_cd	= cp_nominated_course_cd AND
  			acai.sequence_number		= cp_sequence_number);
  BEGIN
  	p_message_name := NULL;
  	-- Determine if preferences are allowed for the admission application
  	IF(p_s_admission_process_type = cst_course AND
  			p_pref_limit IS NOT NULL) THEN
  		-- Preferences are allowed.
  		-- Determine if the preference limit has been exceeded.
  		OPEN	 c_acai(
  				p_person_id,
  				p_admission_appl_number,
  				p_nominated_course_cd,
  				p_acai_sequence_number);
  		FETCH	 c_acai INTO v_count_acai;
  		IF(v_count_acai >= p_pref_limit) THEN
  			CLOSE  c_acai;
  			p_message_name := 'IGS_AD_PREFLIMIT_ADMAPL_REACH';
  			RETURN FALSE;
  		END IF;
  		CLOSE  c_acai;
  	ELSE
  		-- Preferences are not allowed.
  		-- Determine if a record already exists for the application.
  		OPEN	 c_acai(
  				p_person_id,
   				p_admission_appl_number,
  				p_nominated_course_cd,
  				p_acai_sequence_number);
  		FETCH	 c_acai INTO v_count_acai;
  		IF(v_count_acai > 0) THEN
  			CLOSE  c_acai;
  			p_message_name := 'IGS_AD_PREF_NOTALLOW_ADMAPL';
  			RETURN FALSE;
  		END IF;
  		CLOSE  c_acai;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_pref_limit');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_pref_limit;
  --
  -- Validate the course code of the admission application.
  --
  -- Perform encumbrance check for admission_course_appl_instance.course_cd
  -- Validate course appl process type against the student course attempt.
  --
  -- Validate admission course application transfer details.
  FUNCTION admp_val_aca_trnsfr(
  p_person_id IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_nominated_version_number IN NUMBER ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_aca_trnsfr
  	-- Validate that the nominated course and transfer course are valid for the
  	-- system admission process type course Transfer.
  DECLARE
  	cst_error			CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn			CONSTANT	VARCHAR2(1) := 'W';
  	cst_enrolled			CONSTANT	VARCHAR2(8) := 'ENROLLED';
  	cst_inactive			CONSTANT	VARCHAR2(8) := 'INACTIVE';
  	cst_intermit			CONSTANT	VARCHAR2(8) := 'INTERMIT';
  	cst_lapsed			CONSTANT	VARCHAR2(6) := 'LAPSED';
  	cst_discontin			CONSTANT	VARCHAR2(9) := 'DISCONTIN';
  	cst_completed			CONSTANT	VARCHAR2(9) := 'COMPLETED';
  	v_message_name			VARCHAR2(30);
  	v_encmb_chk_dt			IGS_CA_DA_INST_V.alias_val%TYPE;
  	v_generic_course_ind		IGS_PS_VER.generic_course_ind%TYPE;
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	v_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_transfer_course_group_found 	BOOLEAN DEFAULT FALSE;
  	v_nominated_course_found 	BOOLEAN DEFAULT FALSE;
  	v_check				CHAR;
  	CURSOR	c_cv IS
  		SELECT	generic_course_ind
  		FROM	IGS_PS_VER
  		WHERE	course_cd	= p_nominated_course_cd	AND
  			version_number	= p_nominated_version_number;
  	CURSOR	c_sca IS
  		SELECT	course_attempt_status,
  			version_number
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id	= p_person_id AND
  			course_cd	= p_transfer_course_cd;
  	CURSOR c_get_course_group_cd (
  			cp_version_number	IGS_PS_GRP_MBR.version_number%TYPE) IS
  		SELECT	cgr.course_group_cd
  		FROM	IGS_PS_GRP_MBR	cgm,
  			IGS_PS_GRP		cgr,
  			IGS_PS_GRP_TYPE	cgt
  		WHERE	cgm.course_cd		= p_transfer_course_cd	AND
  			cgm.version_number	= cp_version_number	AND
  			cgm.course_group_cd	= cgr.course_group_cd	AND
  			cgr.course_group_type	= cgt.course_group_type	AND
  			cgt.s_course_group_type	= 'ADMTRANSFR';
  	CURSOR c_cgm (	cp_course_cd		IGS_PS_GRP_MBR.course_cd%TYPE,
  			cp_version_number	IGS_PS_GRP_MBR.version_number%TYPE,
  			cp_course_group_cd	IGS_PS_GRP_MBR.course_group_cd%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_GRP_MBR
  		WHERE	course_cd	= cp_course_cd		AND
  			version_number	= cp_version_number	AND
  			course_group_cd	= cp_course_group_cd;
  BEGIN
  	p_message_name := NULL;
  	IF (p_s_admission_process_type <> 'TRANSFER') THEN
  		-- Transfer code is not required
  		IF (p_transfer_course_cd IS NULL) THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_AD_TRANSFERCD_REQ_PRGTRNS';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the nominated course is not a generic course
  	OPEN c_cv;
  	FETCH c_cv INTO v_generic_course_ind;
  	IF (c_cv%NOTFOUND) THEN
  		CLOSE c_cv;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_cv;
  	IF (v_generic_course_ind = 'Y') THEN
  		p_message_name := 'IGS_AD_PRG_TRANSFERED_CANNOT';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Tranfer course code must exist
  	IF (p_transfer_course_cd IS NULL) THEN
  		p_message_name := 'IGS_AD_SPECIFY_TRANSFERCD';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Validate transfer code exists as a student course attempt
  	OPEN c_sca;
  	FETCH c_sca INTO v_course_attempt_status,
  			v_version_number;
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE c_sca;
  		p_return_type := cst_error;
  		p_message_name := 'IGS_AD_STUDPRG_DOESNOT_EXIST';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca;
  	IF v_course_attempt_status NOT IN (	cst_enrolled,
  						cst_inactive,
   						cst_intermit,
  						cst_lapsed,
  						cst_discontin,
  						cst_completed) THEN
  		-- Invalid course attempt status to allow admission transfer
  		p_return_type := cst_error;
  		p_message_name := 'IGS_AD_CRSTRNSFER_ADMPRC';
  		RETURN FALSE;
  	END IF;
  	-- Validate that transfer student course attempt belongs to
  	-- admission course transfer group
  	FOR v_crg_rec IN c_get_course_group_cd(
  					v_version_number) LOOP
  		v_transfer_course_group_found := TRUE;
  		-- Validate that nominated course belongs to the same
  		-- admission course transfer group
  		OPEN c_cgm (
  			p_nominated_course_cd,
  			p_nominated_version_number,
  			v_crg_rec.course_group_cd);
  		FETCH c_cgm INTO v_check;
  		IF (c_cgm%FOUND) THEN
  			v_nominated_course_found := TRUE;
  			CLOSE c_cgm;
  			EXIT;
  		END IF;
  		CLOSE c_cgm;
  	END LOOP;
  	IF (v_transfer_course_group_found = FALSE) THEN
  		p_return_type := cst_error;
  		p_message_name := 'IGS_AD_INVALID_TRANSFERCD_CHK';
  		RETURN FALSE;
  	END IF;
  	IF (v_nominated_course_found = FALSE) THEN
  		p_return_type := cst_error;
  		p_message_name := 'IGS_AD_INVALID_ADM_PRGCD';
  		RETURN FALSE;
  	END IF;
  	--Validate Encumbrances
  	IF (p_course_encmb_chk_ind = 'Y') THEN
  		--Validate encumbrances
  		v_encmb_chk_dt := IGS_AD_GEN_006.ADMP_GET_ENCMB_DT(
  						p_adm_cal_type,
  						p_adm_ci_sequence_number);
  		IF (v_encmb_chk_dt IS NULL) THEN
  			p_message_name := 'IGS_AD_NO_ENCUMB_DTALIAS_PRD';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  		IF (IGS_EN_VAL_ENCMB.enrp_val_excld_crs(
  					p_person_id,
  					p_nominated_course_cd,
  					v_encmb_chk_dt,
  					v_message_name) = FALSE) THEN
  			p_message_name := 'IGS_AD_PRSN_ENCUMB_SUSPEND';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_aca_trnsfr');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
   END admp_val_aca_trnsfr;
  --
  -- Validate if IGS_AD_CD.admission_cd is closed.
  FUNCTION admp_val_aco_closed(
  p_admission_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN 	-- admp_val_aco_closed
  	-- Validate the admission_cd closed indicator
  DECLARE
  	CURSOR c_aco(
  			cp_admission_cd	IGS_AD_CD.admission_cd%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_AD_CD
  		WHERE	admission_cd = cp_admission_cd;
  	v_aco_rec			c_aco%ROWTYPE;
  	cst_yes			CONSTANT CHAR := 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Cursor handling
  	OPEN c_aco(
  			p_admission_cd);
  	FETCH c_aco INTO v_aco_rec;
  	IF c_aco%NOTFOUND THEN
  		CLOSE c_aco;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_aco;
  	IF (v_aco_rec.closed_ind = cst_yes) THEN
  		p_message_name := 'IGS_AD_ADMCD_CLOSED';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_aco_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aco_closed;
  --
  -- Validate if IGS_AD_BASIS_FOR_AD.basis_for_admission_type is closed.
  FUNCTION admp_val_bfa_closed(
  p_basis_for_admission_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN
  DECLARE
  	v_closed_ind		IGS_AD_BASIS_FOR_AD.closed_ind%TYPE;
  	CURSOR c_bfa IS
  		SELECT	bfa.closed_ind
  		FROM	IGS_AD_BASIS_FOR_AD	bfa
  		WHERE	bfa.basis_for_admission_type = p_basis_for_admission_type;
  BEGIN
  	-- Validate if IGS_AD_BASIS_FOR_AD.basis_for_admission_type is closed.
  	OPEN c_bfa;
  	FETCH c_bfa INTO v_closed_ind;
  	IF (c_bfa%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_bfa;
  			p_message_name := 'IGS_AD_BASIS_ADM_TYPE_CLOSED' ;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_bfa;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_bfa_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END;
  END admp_val_bfa_closed;
  --
  -- Validate IGS_AD_PS_APPL.req_for_reconsideration_ind.
  FUNCTION admp_val_aca_req_rec(
  p_req_for_reconsideration_ind IN VARCHAR2 DEFAULT 'N',
  p_req_reconsider_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_aca_req_rec
  	-- Validate IGS_AD_PS_APPL.req_for_reconsideration_ind
  DECLARE
  BEGIN
  	-- Validate if the request for reconsideration indicator can be set.
  	IF (p_req_for_reconsideration_ind = 'Y' AND
  			p_req_reconsider_allowed = 'N') THEN
  		p_message_name := 'IGS_AD_NO_RECONSIDERATION';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_aca_req_rec');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_aca_req_rec;
  --
  -- Validate IGS_AD_PS_APPL.req_for_adv_standing_ind.
  FUNCTION admp_val_aca_req_adv(
  p_req_for_adv_standing_ind IN VARCHAR2 DEFAULT 'N',
  p_req_adv_standing_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_aca_req_adv
  	-- Validate IGS_AD_PS_APPL.req_for_adv_standing_ind
  DECLARE
  BEGIN
  	-- Validate if the request for advanced standing indicator can be set.
  	IF (p_req_for_adv_standing_ind = 'Y' AND
  			p_req_adv_standing_allowed = 'N') THEN
  		p_message_name := 'IGS_AD_ADV_NOTREQ_ADM_APPL';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACA.admp_val_aca_req_adv');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aca_req_adv;

END IGS_AD_VAL_ACA;

/
