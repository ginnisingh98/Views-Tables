--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_AA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_AA" AS
/* $Header: IGSAD76B.pls 120.0 2005/06/01 22:17:58 appldev noship $ */

  --
  -- Validate delete of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_delete(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_delete
  	-- Validate delete of an IGS_AD_APPL record.
  DECLARE
  	v_s_adm_appl_status	IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Get the system admission application status.
  	v_s_adm_appl_status := IGS_AD_GEN_007.ADMP_GET_SAAS(
  					p_adm_appl_status);
  	IF (v_s_adm_appl_status <> 'RECEIVED') THEN
		p_message_name := 'IGS_AD_CANNOTDEL_ADMAPPL_PRD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_delete');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_aa_delete;
  --
  -- Validate insert of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_insert(
  p_person_id IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_title_required_ind IN VARCHAR2 DEFAULT 'N',
  p_birth_dt_required_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- admp_val_aa_insert
  	-- Validate insert of an IGS_AD_APPL record.
  	-- 	* If the admission process type is short admission, the short admission
  	--  	  date alias for the admission period must be set.
  	-- 	* If the admission process type is short admission, the short admission
  	--  	  date must be greater than the current date.
  	-- 	* If encumbrance checking is applicable, warn if the person has an
  	--  	  encumbrance of revoke service or suspend service effective as at the
  	--  	  application date.
  	-- 	* If encumbrance checking is applicable, warn if the person has an
  	--  	  encumbrance of revoke service or suspend service effective as at the
  	--  	  encumbrance checking date.
  	-- 	* If the person?s title is required, warn if the persons?s title is not set.
  	-- 	* If the person?s birth date is required, warn if the persons?s birth date
  	-- 	  is not set.
  DECLARE
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_person_found		BOOLEAN DEFAULT FALSE;
  	v_short_adm_dt		DATE;
  	v_encmb_chk_dt		DATE;
  	v_effective_dt		DATE;
	v_message_name VARCHAR2(30);
  	CURSOR c_person IS
  		SELECT	pb.title,
  			pb.birth_date,
  			ph.deceased_ind
  		FROM IGS_PE_PERSON_BASE_V pb, IGS_PE_HZ_PARTIES ph
  		WHERE pb.person_id = ph.party_id
                AND pb.person_id = p_person_id;

  	v_person_rec	c_person%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	OPEN c_person;
  	FETCH c_person INTO v_person_rec;
  	IF (c_person%NOTFOUND) THEN
  		CLOSE c_person;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_person;
  	-- Validate for deceased person.
  	IF (v_person_rec.deceased_ind = 'Y') THEN
		p_message_name := 'IGS_AD_CANCREATE_ADMAPPL';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Validate admission process type of short admission.
  	IF (p_s_admission_process_type = 'SHORT-ADM') THEN
  		-- Short admission date alias must exist for admission period and must
  		-- be greater than the current date.
  		v_short_adm_dt := IGS_AD_GEN_008.ADMP_GET_SHORT_DT (
  				p_adm_cal_type,
  				p_adm_ci_sequence_number);
  		IF (v_short_adm_dt IS NULL) THEN
			p_message_name := 'IGS_AD_CANNOTINS_NO_SHORT_DT';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		IF (v_short_adm_dt > SYSDATE) THEN
			p_message_name := 'IGS_AD_CANNOTINS_SHORT_DT';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate encumbrances.
  	IF (p_encmb_chk_ind = 'Y') THEN
  		--Warn if person is encumbered as at the application date.
  		IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (
  					p_person_id,
  					NULL,	-- Input parameter course code: not applicable
  					p_appl_dt,
  					v_message_name) THEN
			p_message_name := 'IGS_AD_PERSON_ENCUMB_SUSPEND';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  		-- Determine the effective_dt for performing the
  		-- encumbrance check.
  		v_effective_dt := IGS_AD_GEN_006.ADMP_GET_ENCMB_DT(
  						p_adm_cal_type,
  						p_adm_ci_sequence_number);
  		IF v_effective_dt IS NOT NULL THEN
  			-- Warn if IGS_PE_PERSON is encumbered as at the
  			-- encumbrance checking date.
  			IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn (
  					p_person_id,
  					NULL,	-- Input parameter course code: not applicable
  					v_effective_dt,
  					v_message_name) THEN
				p_message_name := 'IGS_AD_ENCUMB_CHKING_DATE';
  				p_return_type := cst_warn;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate person title.
  	IF (p_title_required_ind = 'Y') THEN
  		-- Warn if title is not set.
  		IF (v_person_rec.title IS NULL) THEN
			p_message_name := 'IGS_AD_TITLE_TOBE_SET';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate person birth date.
  	IF (p_birth_dt_required_ind = 'Y') THEN
  		-- Warn if birth date is not set.
  		IF (v_person_rec.birth_date IS NULL) THEN
			p_message_name := 'IGS_AD_DOB_TOBE_SET';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_insert');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_insert;
  --
  -- Validate update of an IGS_AD_APPL record.
  FUNCTION admp_val_aa_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_update
  	-- Validate update of an IGS_AD_APPL record.
  DECLARE
  	v_s_adm_appl_status	IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Get the system admission application status.
  	v_s_adm_appl_status := IGS_AD_GEN_007.ADMP_GET_SAAS(
  					p_adm_appl_status);
  	IF v_s_adm_appl_status IN ('COMPLETED', 'WITHDRAWN') THEN
		p_message_name := 'IGS_AD_CANNOTUPD_STATUS_COMPL';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_update');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_update;
  --
  -- Validate the IGS_AD_APPL.appl_dt.
  FUNCTION admp_val_aa_appl_dt(
  p_appl_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	-- Validate the IGS_AD_APPL.appl_dt.
  	-- Validations are -
  	-- IGS_AD_APPL.appl_dt must be less than or equal to
  	-- the current date.
  	IF (TRUNC(p_appl_dt) > TRUNC(SYSDATE)) THEN
		p_message_name := 'IGS_AD_APPLDT_LE_CURRENT_DT';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_appl_dt');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_appl_dt;
  --
  -- Validate the admission application academic calendar.
  FUNCTION admp_val_aa_acad_cal(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_acad_cal
  	-- Validate the admission application commencement period
  	-- (IGS_AD_APPL.acad_cal_type, IGS_AD_APPL.acad_ci_sequence_number).
  	-- Validations are -
  	-- ? IGS_AD_APPL.acad_cal_type must be an Academic calendar.
  	-- ? IGS_AD_APPL.acad_cal_type and IGS_AD_APPL.acad_ci_sequence_number
  	-- 	must be an Active calendar instance.
  DECLARE
  	CURSOR c_ct (
  			cp_acad_cal_type		IGS_AD_APPL.acad_cal_type%TYPE) IS
  		SELECT s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = cp_acad_cal_type;
  	CURSOR c_ci_cs (
  			cp_acad_cal_type		IGS_AD_APPL.acad_cal_type%TYPE,
  			cp_acad_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE) IS
  		SELECT	cs.s_cal_status
  		FROM	IGS_CA_STAT cs,
  			IGS_CA_INST ci
  		WHERE	ci.cal_type 		= cp_acad_cal_type AND
  			ci.sequence_number 	= cp_acad_ci_sequence_number AND
  			ci.cal_status 	= cs.cal_status;

	v_ct_rec		c_ct%ROWTYPE;
  	v_ci_cs_rec	c_ci_cs%ROWTYPE;
  	cst_academic	VARCHAR2(10) := 'ACADEMIC';
  	cst_active		VARCHAR2(10) := 'ACTIVE';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_ct (p_acad_cal_type);
  	FETCH c_ct INTO v_ct_rec;
  	IF c_ct%FOUND THEN
  		CLOSE c_ct;
  		IF v_ct_rec.s_cal_cat <> cst_academic THEN
			p_message_name := 'IGS_AD_CAT_AS_ACADEMIC';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_ct;
  	END IF;
  	OPEN c_ci_cs (
  			p_acad_cal_type,
  			p_acad_ci_sequence_number);
  	FETCH c_ci_cs INTO v_ci_cs_rec;
  	IF c_ci_cs%NOTFOUND THEN
  		CLOSE c_ci_cs;
                p_message_name := 'IGS_AD_ADM_CAL_INSTNOT_DEFINE';
  		RETURN FALSE; -- Corrected, to return FALSE as part of the bug 2772337.
                   --  Removed the End_Date validation as part of bug 2974150
	END IF;
  	CLOSE c_ci_cs;

  	IF v_ci_cs_rec.s_cal_status <> cst_active  THEN     --removed the planned status as per bug#2722785 --rghosh
		p_message_name := 'IGS_AD_ACACAL_PLANNED_ACTIVE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_acad_cal');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_acad_cal;
  --
  -- Validate the admission application admission calendar.
  FUNCTION admp_val_aa_adm_cal(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	cst_admission 			CONSTANT VARCHAR2(10) := 'ADMISSION';
  	cst_active 			CONSTANT VARCHAR2(10) := 'ACTIVE';
  	v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_cal_type (
  			cp_cal_type	IGS_CA_TYPE.cal_type%TYPE) IS
  		SELECT	cat.s_cal_cat
  		FROM	IGS_CA_TYPE cat
  		WHERE	cat.cal_type = cp_cal_type;
  	--Modified the following cursor to fetch end_dt in addition with s_cal_status. Bug: 2772337
        --Modified the following cursor not to fetch end_dt in addition with s_cal_status. Bug: 2974150
	CURSOR c_cal_instance (
  			cp_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	cs.s_cal_status
  		FROM	IGS_CA_INST ci,
  			IGS_CA_STAT cs
  		WHERE	ci.cal_status = cs.cal_status AND
  			ci.cal_type = cp_cal_type AND
  			ci.sequence_number = cp_sequence_number;
  	CURSOR c_cal_ins_rel (
  			cp_acad_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_acad_ci_sequence_number IGS_CA_INST.sequence_number%TYPE,
  			cp_adm_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_adm_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CA_INST_REL cir
  		WHERE	cir.sup_cal_type =cp_acad_cal_type AND
  			cir.sup_ci_sequence_number = cp_acad_ci_sequence_number AND
  			cir.sub_cal_type = cp_adm_cal_type AND
  			cir.sub_ci_sequence_number = cp_adm_ci_sequence_number;
  	CURSOR c_adm_perd_adm_proc_cat (
  			cp_adm_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_adm_ci_sequence_number IGS_CA_INST.sequence_number%TYPE,
  			cp_admission_cat IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE,
  			cp_s_admission_process_type
  					IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AD_PRD_AD_PRC_CA apapc
  		WHERE	apapc.adm_cal_type = cp_adm_cal_type AND
  			apapc.adm_ci_sequence_number = cp_adm_ci_sequence_number AND
  			apapc.admission_cat = cp_admission_cat AND
  			apapc.s_admission_process_type = cp_s_admission_process_type AND
			apapc.closed_ind = 'N';               --added the closed indicator for bug# 2380108 (rghosh)
  	v_s_cal_status			c_cal_instance%ROWTYPE;
  BEGIN
  	-- Validate the admission application admission calendar
  	-- (IGS_AD_APPL.adm_cal_type,
  	-- IGS_AD_APPL.adm_ci_sequence_number).
  	-- Validations are -
  	-- IGS_AD_APPL.acad_cal_type must be an Admission calendar.
  	-- IGS_AD_APPL.adm_cal_type and IGS_AD_APPL.adm_ci_sequence_number
  	-- must be
  	-- an Active calendar instance.
  	-- The Admission Calendar must be a child of the Academic Calendar.
  	-- This validation is enforced in the database via the foreign key AA_CIR_FK.
  	-- It is included in this module for Forms processing purposes only.
  	-- The Admission Calendar must be for the Admission Process Category.  This
  	-- validation is enforced in the database via the foreign key AA_APAPC_FK.
  	-- It is included in this module for Forms processing purposes only.
  	p_message_name := null;
  	OPEN	c_cal_type(
  			p_adm_cal_type);
  	FETCH	c_cal_type INTO v_s_cal_cat;
  	IF(c_cal_type%FOUND) THEN
  		IF(v_s_cal_cat <> cst_admission) THEN
  			CLOSE c_cal_type;
			p_message_name := 'IGS_AD_ADMCAL_CAT_AS_ADM';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_cal_type;

  	OPEN	c_cal_instance(
  			p_adm_cal_type,
  			p_adm_ci_sequence_number);
  	FETCH	c_cal_instance INTO v_s_cal_status;
  	IF(c_cal_instance%FOUND) THEN
	        -- Added the End_Date validation as part of the bug 2772337.
                --Removed the End_Date validation as part of bug 2974150

  		IF(v_s_cal_status.s_cal_status<> cst_active) THEN
  			CLOSE c_cal_instance;
			p_message_name := 'IGS_AD_ADMCAL_PLANNED_ACTIVE';      --removed the planned status as per bug#2722785 --rghosh
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE	c_cal_instance;

  	OPEN	c_cal_ins_rel(
  			p_acad_cal_type,
  			p_acad_ci_sequence_number,
  			p_adm_cal_type,
  			p_adm_ci_sequence_number);
  	FETCH	c_cal_ins_rel INTO v_dummy;
  	IF(c_cal_ins_rel%NOTFOUND) THEN
  		CLOSE c_cal_ins_rel;
		p_message_name := 'IGS_AD_ADMCAL_CHILD_ACACAL';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cal_ins_rel;
  	OPEN	c_adm_perd_adm_proc_cat(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				p_admission_cat,
  				p_s_admission_process_type);
  	FETCH	c_adm_perd_adm_proc_cat INTO v_dummy;
  	IF(c_adm_perd_adm_proc_cat%NOTFOUND) THEN
  		CLOSE c_adm_perd_adm_proc_cat;
		p_message_name := 'IGS_AD_ADMCAL_NOTLINK_ADMCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_adm_perd_adm_proc_cat;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_adm_cal');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_adm_cal;
  --
  -- Validate the IGS_AD_APPL.admission_cat.
  FUNCTION admp_val_aa_adm_cat(
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_closed_ind		IGS_AD_CAT.closed_ind%TYPE;
  	v_count			NUMBER;
  	v_admission_cat		IGS_AD_CAT.admission_cat%TYPE;
  	CURSOR c_ac IS
  		SELECT	ac.closed_ind
  		FROM	IGS_AD_CAT	ac
  		WHERE	ac.admission_cat = p_admission_cat;
  	CURSOR c_ccm IS
  		SELECT	ccm.admission_cat,
  			COUNT(*)
  		FROM	IGS_CO_CAT_MAP	ccm
  		WHERE	ccm.admission_cat = p_admission_cat AND
  			ccm.dflt_cat_ind = 'Y'
  		GROUP BY ccm.admission_cat;
  	CURSOR c_ecm IS
  		SELECT	ecm.admission_cat,
  			COUNT(*)
  		FROM	IGS_EN_CAT_MAPPING	ecm
  		WHERE	ecm.admission_cat = p_admission_cat AND
  			ecm.dflt_cat_ind = 'Y'
  		GROUP BY ecm.admission_cat;
  	CURSOR c_fcm IS
  		SELECT	fcm.admission_cat,
  			COUNT(*)
  		FROM	IGS_FI_FEE_CAT_MAP	fcm
  		WHERE	fcm.admission_cat = p_admission_cat AND
  			fcm.dflt_cat_ind = 'Y'
  		GROUP BY fcm.admission_cat;
  BEGIN
  	-- Validate the IGS_AD_APPL.admission_cat.
  	-- Validations are:
  	-- IGS_AD_APPL.admission_cat must not be closed.
  	-- IGS_AD_APPL.admission_cat must have one and only
  	-- one default IGS_CO_CAT_MAP record.
  	-- IGS_AD_APPL.admission_cat must have one and only
  	-- one default IGS_EN_CAT_MAPPING record.
  	-- IGS_AD_APPL.admission_cat must have one and only
  	-- one default IGS_FI_FEE_CAT_MAP record.
  	OPEN c_ac;
  	FETCH c_ac INTO v_closed_ind;
  	IF (c_ac%FOUND) THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_ac;
			p_message_name := 'IGS_AD_ADM_CATEGORY_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_ac;
/* Commented out NOCOPY because correspondence functionality is removed. Bug# 1478593 P1, nsinha 25-Oct-00
  	OPEN c_ccm;
  	FETCH c_ccm INTO 	v_admission_cat,
  				v_count;
  	IF (c_ccm%NOTFOUND) THEN
  		CLOSE c_ccm;
		p_message_name := 'IGS_AD_ADMCAT_NOT_DFLT_CORCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ccm;
  	IF (v_count > 1) THEN
		p_message_name := 'IGS_AD_ADMCAT_MORE_DFLT_CORCA';
  		RETURN FALSE;
  	END IF;
*/

        --These are not required while creating the application/instance.
        -- Needs to be handled in the set up form

/*        OPEN c_ecm;
  	FETCH c_ecm INTO 	v_admission_cat,
  				v_count;
  	IF (c_ecm%NOTFOUND) THEN
  		CLOSE c_ecm;
		p_message_name := 'IGS_AD_ADMCAT_NOT_DFLT_ENRCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ecm;
  	IF (v_count > 1) THEN
		p_message_name := 'IGS_AD_ADMCAT_MORE_DFLT_ENRCA';
  		RETURN FALSE;
  	END IF;
  	OPEN c_fcm;
  	FETCH c_fcm INTO 	v_admission_cat,
  				v_count;
  	IF (c_fcm%NOTFOUND) THEN
  		CLOSE c_fcm;
		p_message_name := 'IGS_AD_ADMCAT_NOT_DFLT_FEECAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_fcm;
  	IF (v_count > 1) THEN
		p_message_name := 'IGS_AD_ADMCAT_DFLT_FEECAT';
  		RETURN FALSE;
  	END IF;*/
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_adm_cat');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END admp_val_aa_adm_cat;
  --
  -- Validate the IGS_AD_APPL.adm_appl_status.
  FUNCTION admp_val_aa_aas(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_aas
  	-- Validate the IGS_AD_APPL.adm_appl_status.  Validations are -
  	-- * The admission application status must be open.  (AAS01)
  	-- * If the admission application status has a system value of
  	--   received, then it must equal the derived value.  (AAS02)
  	-- * If the admission application status has a system value of
  	--   completed, then it must equal the derived value.  (AAS03)
  	-- * If the admission application status has a system value of
  	--   withdrawn, then it must equal the derived value.  (AAS04)
  	-- * If the admission application status has a system value of
  	--   withdrawn, there must be no admission course application
  	--   instance that has been made an offer that has not been
  	--   resolved or accepted (including deferral).  (AAS05)
  DECLARE
  	CURSOR c_acai IS
  		SELECT	aos.s_adm_outcome_status,
  			aors.s_adm_offer_resp_status
  		FROM	IGS_AD_PS_APPL_INST 	acai,
  			IGS_AD_OU_STAT 		aos,
  			IGS_AD_OFR_RESP_STAT 		aors
  		WHERE	acai.person_id 			= p_person_id AND
  			acai.admission_appl_number 	= p_admission_appl_number AND
  			aos.adm_outcome_status		= acai.adm_outcome_status AND
  			aors.adm_offer_resp_status 	= acai.adm_offer_resp_status;
  	cst_received		CONSTANT VARCHAR2(10) := 'RECEIVED';
  	cst_completed		CONSTANT VARCHAR2(10) := 'COMPLETED';
  	cst_withdrawn		CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  	cst_offer		CONSTANT VARCHAR2(10) := 'OFFER';
  	cst_cond_offer		CONSTANT VARCHAR2(10) := 'COND-OFFER';
  	cst_rejected		CONSTANT VARCHAR2(10) := 'REJECTED';
  	cst_lapsed		CONSTANT VARCHAR2(10) := 'LAPSED';
  	cst_not_applic		CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
	v_message_name VARCHAR2(30);
  	v_s_adm_appl_status		IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  	v_derived_s_adm_appl_status	IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  	v_exit_loop		BOOLEAN DEFAULT FALSE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate the closed indicator.
  	IF NOT IGS_AD_VAL_AA.admp_val_aas_closed (
  					p_adm_appl_status,
  					v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Get the admission application status system value.
  	v_s_adm_appl_status := IGS_AD_GEN_007.ADMP_GET_SAAS (
  					p_adm_appl_status);
  	-- Get admission application status derived value.
  	v_derived_s_adm_appl_status := IGS_AD_GEN_002.ADMP_GET_AA_AAS (
  						p_person_id,
  						p_admission_appl_number,
  						p_adm_appl_status);
  	-- Validate when the application is received.
  	IF v_s_adm_appl_status = cst_received AND
  			IGS_AD_GEN_007.ADMP_GET_SAAS(v_derived_s_adm_appl_status) <> cst_received THEN
		p_message_name := 'IGS_AD_APPLST_CANNOT_RECEIVED';
  		RETURN FALSE;
  	END IF;
  	-- Validate when the application is completed.
  	IF v_s_adm_appl_status = cst_completed AND
  			IGS_AD_GEN_007.ADMP_GET_SAAS(v_derived_s_adm_appl_status) <> cst_completed THEN
		p_message_name := 'IGS_AD_APPLST_CANNOT_COMPLETE';
  		RETURN FALSE;
  	END IF;
  	-- Validate when the application is withdrawn.
  	IF v_s_adm_appl_status = cst_withdrawn THEN
  		IF IGS_AD_GEN_007.ADMP_GET_SAAS(v_derived_s_adm_appl_status) <> cst_withdrawn THEN
			p_message_name := 'IGS_AD_APPLST_CANNOT_WITHDRAW';
  			RETURN FALSE;
  		END IF;
  		-- Validate if the admission application can be withdrawn.
  		-- Loop through IGS_AD_PS_APPL_INST records:
  		FOR v_acai_rec IN c_acai LOOP
  			-- If any admission IGS_PS_COURSE application instance has been
  			-- made an offer that has not been resolved or accepted
  			-- (including deferral), then the admission application
  			-- cannot be withdrawn.  The applicant should reject the offer.
  			IF v_acai_rec.s_adm_outcome_status IN (
  							cst_offer,
  							cst_cond_offer) AND
  					v_acai_rec.s_adm_offer_resp_status NOT IN (
  									cst_rejected,
  									cst_lapsed,
  									cst_not_applic) THEN
  				v_exit_loop := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF v_exit_loop THEN
			p_message_name := 'IGS_AD_APPLST_NOTBE_WITHDRAWN';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_acai%ISOPEN THEN
  			CLOSE c_acai;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_aas');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_aas;
  --
  -- Validate if IGS_AD_APPL_STAT.adm_appl_status is closed.
  FUNCTION admp_val_aas_closed(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_aas_closed
  	-- Validate if IGS_AD_APPL_STAT.adm_appl_status is closed
  DECLARE
  	CURSOR c_aas IS
  		SELECT	closed_ind
  		FROM	IGS_AD_APPL_STAT
  		WHERE	adm_appl_status = p_adm_appl_status;
  	v_closed_ind		IGS_AD_APPL_STAT.closed_ind%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_aas;
  	FETCH c_aas INTO v_closed_ind;
  	IF c_aas%FOUND THEN
  		IF (v_closed_ind = 'Y') THEN
  			CLOSE c_aas;
			p_message_name := 'IGS_AD_ADMAPL_STATUS_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	CLOSE c_aas;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aas_closed');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aas_closed;
  --
  -- Validate the IGS_AD_APPL.adm_fee_status.
  FUNCTION admp_val_aa_afs(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_fee_status IN VARCHAR2 ,
  p_fees_required_ind IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_afs
  	-- Validate the IGS_AD_APPL.adm_fee_status.  Validations are
  	--   The adm_fee_status must be open.
  	--   If fee's are required the adm_fee_status must not have a system value of
  	--   not-applicable.
  	--   If fee's are not required the adm_fee_status must have a system value of
  	--   not-applicable.
  	--   The IGS_AD_PS_APPL_INST relating to the admission application have
  	--   valid statuses for adm_fee_status.
  DECLARE
  	cst_not_applic	CONSTANT VARCHAR2(10) :='NOT-APPLIC';
  	cst_pending	CONSTANT VARCHAR2(7) :='PENDING';
  	cst_assessed	CONSTANT VARCHAR2(8) :='ASSESSED';
  	cst_offer		CONSTANT VARCHAR2(5) :='OFFER';
  	cst_cond_offer	CONSTANT VARCHAR2(10) :='COND-OFFER';
  	cst_withdrawn	CONSTANT VARCHAR2(9) :='WITHDRAWN';
  	cst_voided	CONSTANT VARCHAR2(6) :='VOIDED';
  	cst_satisfied	CONSTANT VARCHAR2(9) :='SATISFIED';
  	v_dummy			VARCHAR2(1);
  	v_s_adm_fee_status	IGS_AD_FEE_STAT.s_adm_fee_status%TYPE;
	v_message_name VARCHAR2(30);
  	CURSOR c_chk_offer_pend IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos
  		WHERE	acai.person_id			= p_person_id AND
  			acai.admission_appl_number	= p_admission_appl_number AND
  			aos.s_adm_outcome_status	IN (
  							cst_offer,
  							cst_cond_offer,
  							cst_withdrawn,
  							cst_voided) AND
  			acai.adm_outcome_status		= aos.adm_outcome_status;
  	CURSOR c_chk_offer_ass IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos
  		WHERE	acai.person_id			= p_person_id AND
  			acai.admission_appl_number	= p_admission_appl_number AND
  			aos.s_adm_outcome_status	= cst_offer AND
  			acai.adm_outcome_status		= aos.adm_outcome_status;
  	CURSOR c_chk_cond_fee IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT	aos
  		WHERE	acai.person_id			= p_person_id AND
  			acai.admission_appl_number	= p_admission_appl_number AND
  			aos.s_adm_outcome_status		= cst_cond_offer AND
  			acai.adm_outcome_status		= aos.adm_outcome_status;
  	CURSOR c_check_cndtnl IS
  		SELECT	'x'
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos,
  			IGS_AD_CNDNL_OFRSTAT		acos
  		WHERE	acai.person_id			= p_person_id	AND
  			acai.admission_appl_number	= p_admission_appl_number AND
  			aos.s_adm_outcome_status 	= cst_cond_offer	AND
  			acos.s_adm_cndtnl_offer_status	= cst_satisfied		AND
  			acai.adm_cndtnl_offer_status	= acos.adm_cndtnl_offer_status AND
  			acai.adm_outcome_status		= aos.adm_outcome_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate the closed indicator.
  	IF IGS_AD_VAL_ACAI_STATUS.admp_val_afs_closed(
  		p_adm_fee_status,
  		v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Get the admission fee status system value.
  	v_s_adm_fee_status := IGS_AD_GEN_008.ADMP_GET_SAFS(p_adm_fee_status);
  	-- Validate when fee's are required.
  	IF (p_fees_required_ind = 'Y') THEN
  		IF (v_s_adm_fee_status = cst_not_applic) THEN
			p_message_name := 'IGS_AD_APPLFEE_REQUIRED';
  			RETURN FALSE;
  		END IF;
  		-- Validate against admission IGS_PS_COURSE application outcome status
  		IF (v_s_adm_fee_status = cst_pending) THEN
  			OPEN c_chk_offer_pend;
  			FETCH c_chk_offer_pend INTO v_dummy;
  			IF c_chk_offer_pend%FOUND THEN
  				CLOSE c_chk_offer_pend;
  				-- Cannot be determining fees when offer has been made
				p_message_name := 'IGS_AD_APPLFEE_NOTSET_OFRMADE';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_chk_offer_pend;
  		END IF;
  		IF (v_s_adm_fee_status = cst_assessed) THEN
  			OPEN c_chk_offer_ass;
  			FETCH c_chk_offer_ass INTO v_dummy;
  			IF c_chk_offer_ass%FOUND THEN
  				CLOSE c_chk_offer_ass;
  				-- Cannot be assessing fees when offer is being made
				p_message_name := 'IGS_AD_APPLFEE_NOTSET_ASSESED';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_chk_offer_ass;
  			IF p_cond_offer_fee_allowed = 'N' THEN
  				OPEN c_chk_cond_fee;
  				FETCH c_chk_cond_fee INTO v_dummy;
  				IF c_chk_cond_fee%FOUND THEN
  					CLOSE c_chk_cond_fee;
  					-- Cannot be assessing fees when conditional offer is being made and fee
  					-- condtional offers are not allowed.
					p_message_name := 'IGS_AD_FEEST_NOTBE_ASSESSED';
  					RETURN FALSE;
  				END IF;
  				CLOSE c_chk_cond_fee;
  			END IF;
  			OPEN c_check_cndtnl;
  			FETCH c_check_cndtnl INTO v_dummy;
  			IF c_check_cndtnl%FOUND THEN
  				CLOSE c_check_cndtnl;
  				-- Cannot be assessing fees when a conditional offer has been satisfied.
				p_message_name := 'IGS_AD_APPLFEE_NOTBE_ASSESSED';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_check_cndtnl;
  		END IF;
  	END IF;
  	-- Validate when fee's are not required.
  	IF p_fees_required_ind = 'N' AND
  			v_s_adm_fee_status <> cst_not_applic THEN
		p_message_name := 'IGS_AD_APPLFEE_NOT_APPLICABLE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_chk_offer_pend%ISOPEN THEN
  			CLOSE c_chk_offer_pend;
  		END IF;
  		IF c_chk_offer_ass%ISOPEN THEN
  			CLOSE c_chk_offer_ass;
  		END IF;
  		IF c_chk_cond_fee%ISOPEN THEN
  			CLOSE c_chk_cond_fee;
  		END IF;
  		IF c_check_cndtnl%ISOPEN THEN
  			CLOSE c_check_cndtnl;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_afs');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END admp_val_aa_afs;
  --
  -- Validate if IGS_AD_FEE_STAT.adm_fee_status is closed.

  --
  -- Validate the IGS_AD_APPL.tac_appl_ind.
  FUNCTION admp_val_aa_tac_appl(
  p_person_id IN NUMBER ,
  p_tac_appl_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aa_tac_appl
  DECLARE -- Validate the IGS_AD_APPL.tac_appl_ind.
  	-- Validations are -
  	-- If the IGS_AD_APPL.tac_appl_ind = 'Y' then an alternate_person_id
  	-- record must exist for the person with an s_person_id_type of 'TAC'.
  	-- If the IGS_PE_ALT_PERS_ID record is dated, then it must be effective
  	-- as of the IGS_AD_APPL.appl_dt.
  	cst_error		CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT	VARCHAR2(1) := 'W';
  	cst_course		CONSTANT	IGS_AD_APPL.s_admission_process_type%TYPE := 'COURSE';
  	v_pe_person_id		IGS_PE_ALT_PERS_ID.pe_person_id%TYPE;
	-- gmaheswa: Added START_DT <> END_DT OR END_DT IS NULL condition as part of bug 3882788
  	CURSOR	c_api_pit IS
  		SELECT	api.pe_person_id
  		FROM	IGS_PE_ALT_PERS_ID	api,
  			IGS_PE_PERSON_ID_TYP		pit
  		WHERE	api.pe_person_id = p_person_id AND
  			(api.start_dt IS NULL OR
  			(api.start_dt <= p_appl_dt AND
  			NVL(api.end_dt, IGS_GE_DATE.IGSCHAR('9999/01/01')) >= p_appl_dt) AND
			(api.end_dt IS NULL OR api.start_dt <> api.end_dt)) AND
  			pit.person_id_type = api.person_id_type AND
  			pit.s_person_id_type = 'TAC';
  BEGIN
  	IF (p_tac_appl_ind = 'Y') THEN
  		IF (p_s_admission_process_type <> cst_course) THEN
			p_message_name := 'IGS_AD_SYSADM_PRCTYPE_TACAPPL';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		OPEN c_api_pit;
  		FETCH c_api_pit INTO v_pe_person_id;
  		IF (c_api_pit%NOTFOUND) THEN
  			CLOSE c_api_pit;
			p_message_name := 'IGS_AD_TACAPPL_INDICATOR_Y';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_api_pit;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_AA.admp_val_aa_tac_appl');
	    IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END admp_val_aa_tac_appl;
END IGS_AD_VAL_AA;

/
