--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACAIU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACAIU" AS
/* $Header: IGSAD23B.pls 115.9 2003/12/03 20:49:01 knag ship $ */

  --
  -- Validate the ins/upd/del admission course application instance unit
  FUNCTION admp_val_acaiu_iud(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_restr_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_iud
  	-- This modules validates the insert/update/delete of
  	--  IGS_AD_PS_APLINSTUNT.
  DECLARE
  	v_s_adm_appl_status	IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  	v_s_adm_outcome_status	IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
  	CURSOR	c_aa_aas IS
  		SELECT	aas.s_adm_appl_status
  		FROM	IGS_AD_APPL 		aa,
  			IGS_AD_APPL_STAT 	aas
  		WHERE
  			aa.person_id		= p_person_id			AND
  			aa.admission_appl_number= p_admission_appl_number	AND
  			aa.adm_appl_status	= aas.adm_appl_status;
  	CURSOR c_acai_aos IS
  		SELECT	aos.s_adm_outcome_status
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos
  		WHERE	acai.person_id			= p_person_id			AND
  			acai.admission_appl_number	= p_admission_appl_number	AND
  			acai.nominated_course_cd	= p_nominated_course_cd		AND
  			acai.sequence_number		= p_acai_sequence_number	AND
  			acai.adm_outcome_status		= aos.adm_outcome_status;
  BEGIN
  	p_message_name := NULL;
  	If (p_unit_restr_ind = 'N') THEN
  		-- Admission course application units should not be inserted/updated/deleted
  		p_message_name := 'IGS_AD_NO_IUD_ADMPRC_CAT';
  		RETURN FALSE;
  	END IF;
  	-- Validate against admission application status
  	OPEN c_aa_aas;
  	FETCH c_aa_aas INTO v_s_adm_appl_status;
  	IF (c_aa_aas%NOTFOUND) THEN
  		-- something is very wrong and will be handled elsewhere
  		CLOSE c_aa_aas;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_aa_aas;
  	IF v_s_adm_appl_status = 'WITHDRAWN' OR  v_s_adm_appl_status = 'COMPLETED' THEN
  		p_message_name := 'IGS_AD_NO_IUD_APPL_WITHDRAWN';
  		RETURN FALSE;
  	END IF;
  	-- Validate that the admission course application is not offered
  	OPEN c_acai_aos;
  	FETCH c_acai_aos INTO v_s_adm_outcome_status;
  	IF c_acai_aos%NOTFOUND THEN
  		-- something is very wrong and will be handled elsewhere
  		CLOSE c_acai_aos;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_acai_aos;
  	IF v_s_adm_outcome_status IN (
  			'OFFER', 'COND-OFFER', 'WITHDRAWN', 'VOIDED')THEN
  		p_message_name := 'IGS_AD_NO_IUD_APPL_OFFERED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_iud');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_acaiu_iud;

  -- Validate the admission course application instance unit
  FUNCTION admp_val_acaiu_unit(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_acaiu_unit
  	-- validate IGS_AD_PS_APLINSTUNT unit.
  DECLARE
  	cst_yes				CONSTANT	VARCHAR2(1) := 'Y';
  	v_cir_1_rec_found		BOOLEAN		DEFAULT FALSE;
  	v_unit_version_valid		BOOLEAN		DEFAULT FALSE;
  	v_dummy				VARCHAR2(1);
  	v_message_name			VARCHAR2(30);
  	CURSOR c_cir_1 (
  			cp_unit_cd			IGS_AD_PS_APLINSTUNT.unit_cd%TYPE,
  			cp_uv_version_number		IGS_AD_PS_APLINSTUNT.uv_version_number%TYPE,
  			cp_acad_cal_type		IGS_AD_APPL.acad_cal_type%TYPE,
  			cp_acad_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE) IS
  		SELECT	DISTINCT uoo.cal_type,
  			uoo.ci_sequence_number
  		FROM	IGS_PS_UNIT_OFR_OPT		uoo,
  			IGS_CA_INST_REL	cir
  		WHERE	uoo.unit_cd			= cp_unit_cd AND
  			uoo.version_number		= cp_uv_version_number AND
  			uoo.offered_ind			= cst_yes AND
  			cir.sub_cal_type		= uoo.cal_type AND
  			cir.sub_ci_sequence_number	= uoo.ci_sequence_number AND
  			cir.sup_cal_type		= cp_acad_cal_type AND
  			cir.sup_ci_sequence_number	= cp_acad_ci_sequence_number;
  	CURSOR c_cir_2 (
  			cp_adm_cal_type			IGS_AD_APPL.acad_cal_type%TYPE,
  			cp_adm_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE,
  			cp_sup_cal_type			IGS_AD_APPL.acad_cal_type%TYPE,
  			cp_sup_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CA_INST_REL	cir
  		WHERE	cir.sub_cal_type		= cp_adm_cal_type AND
  			cir.sub_ci_sequence_number	= cp_adm_ci_sequence_number AND
  			cir.sup_cal_type		= cp_sup_cal_type AND
  			cir.sup_ci_sequence_number	= cp_sup_ci_sequence_number;
  BEGIN
  	p_message_name := NULL;
  	-- Validate unit version
  	IF(IGS_AD_VAL_ACAIU.admp_val_acaiu_uv (
  					p_unit_cd,
  					p_uv_version_number,
  					p_s_admission_process_type,
  					p_offered_ind,
  					v_message_name) = FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	FOR v_cir_1_rec IN c_cir_1(
  				p_unit_cd,
  				p_uv_version_number,
  				p_acad_cal_type,
  				p_acad_ci_sequence_number) LOOP
  		v_cir_1_rec_found := TRUE;
  		OPEN 	c_cir_2(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				v_cir_1_rec.cal_type,
  				v_cir_1_rec.ci_sequence_number);
  		FETCH	c_cir_2 INTO v_dummy;
  		IF(c_cir_2%FOUND) THEN
  			v_unit_version_valid := TRUE;
  			CLOSE c_cir_2;
  			EXIT;
  		ELSE
  			CLOSE c_cir_2;
  		END IF;
  	END LOOP;
  	IF(v_cir_1_rec_found = FALSE) THEN
  		-- unit version has no offered unit offering options in the
  		-- academic period of the admission course application.
  		p_message_name := 'IGS_AD_UNITVER_UOO_ACADEMIC';
  		RETURN FALSE;
  	END IF;
  	IF(v_unit_version_valid = FALSE) THEN
  		-- unit version is not valid.
  		p_message_name := 'IGS_AD_UNITVER_UOO_COMMENCPRD';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_unit');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END admp_val_acaiu_unit;

  --
  -- Validate the admission course application instance unit
  FUNCTION admp_val_acaiu_opt(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_opt
  	-- This module validates the unit offering option of the
  	-- IGS_AD_PS_APLINSTUNT
  DECLARE
  	-- Select valid teaching periods for the admission course application
  	CURSOR c_cir IS
  		SELECT  cir.sub_cal_type,
  			cir.sub_ci_sequence_number
  		FROM	IGS_CA_INST_REL cir,
  			IGS_CA_TYPE cat1,
  			IGS_CA_TYPE cat2
  		WHERE	cir.sup_cal_type = p_acad_cal_type AND
  			cir.sup_ci_sequence_number = p_acad_ci_sequence_number AND
  			cat1.s_cal_cat = 'TEACHING' AND
  			cat2.s_cal_cat = 'ACADEMIC' AND
   			cir.sub_cal_type = cat1.cal_type AND
  			cir.sup_cal_type = cat2.cal_type;
  		v_cal_type		IGS_CA_INST.cal_type%TYPE;
  		v_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE;
  		v_message_name		VARCHAR2(30);
  		v_val_off_optn_found	BOOLEAN DEFAULT FALSE;
  		v_cir_found		BOOLEAN	DEFAULT FALSE;
  		v_admp_pk_ind		BOOLEAN DEFAULT FALSE;
  		v_val_ind_type		NUMBER;
  		v_val_ind_type_offer	NUMBER;
  	------------------------------SUB-FUNCTION-------------------------------------
  ----------
  	FUNCTION admpl_val_offer_optn(
  		v_cal_type		IGS_AD_APPL.adm_cal_type%TYPE,
  		v_ci_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE,
  		v_val_ind_type_offer		OUT NOCOPY	NUMBER)
  	RETURN BOOLEAN
  	AS
  	BEGIN	-- admpl_val_off_optn
  		-- Validate unit offering option (if uoo.offered_ind = 'Y')
  	DECLARE
  		CURSOR c_uoo(
  				cp_cal_type		IGS_AD_APPL.adm_cal_type%TYPE,
  				cp_ci_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
  			SELECT  uoo.offered_ind,
  				uoo.unit_class
  			FROM 	IGS_PS_UNIT_OFR_OPT uoo
  			WHERE	uoo.unit_cd 		= p_unit_cd AND
  				uoo.version_number 	= p_uv_version_number AND
  				uoo.cal_type 		= cp_cal_type AND
  				uoo.ci_sequence_number 	= cp_ci_sequence_number AND
  				(p_location_cd IS NULL OR
  				 uoo.location_cd = p_location_cd) AND
  				(p_unit_class IS NULL OR
  				 uoo.unit_class = p_unit_class);
  		v_offered_optn_found	BOOLEAN DEFAULT FALSE;
  		v_offered_ind		VARCHAR2(1) := 'N';
  		v_val_optn_found	BOOLEAN DEFAULT FALSE;
  	BEGIN
  		FOR c_uoo_rec IN c_uoo (
  					v_cal_type,
  					v_ci_sequence_number) LOOP
  			v_val_optn_found := TRUE;
  			-- A valid option exists
  			IF c_uoo_rec.offered_ind = 'Y' THEN
  				v_offered_ind := 'Y';
  				-- Validate unit class/unit mode
  				IF p_unit_mode IS NOT NULL THEN
  					IF IGS_AD_VAL_ACAIU.admp_val_acaiu_um(
  									c_uoo_rec.unit_class,
  									p_unit_mode,
  									v_message_name) = TRUE THEN
  						-- A valid offered option exists
  						v_offered_optn_found := TRUE;
  						EXIT; --(IGS_PS_UNIT_OFR_OPT)
  					END IF;
  				ELSE
  					-- A valid offered option exists
  					v_offered_optn_found := TRUE;
  					EXIT; --(IGS_PS_UNIT_OFR_OPT)
  				END IF;
  			END IF;
  		END LOOP;
  		IF (v_val_optn_found = FALSE OR
  			v_val_optn_found = TRUE AND v_offered_ind = 'N') THEN
  			v_val_ind_type_offer := 1; 	-- No valid option found -> 3509
  			RETURN FALSE;
  		ELSIF v_offered_optn_found = FALSE THEN
  			v_val_ind_type_offer := 2; 	-- No valid offered option found -> 3510
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF c_uoo%ISOPEN THEN
  				CLOSE c_uoo;
  			END IF;
  			RAISE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_offer_optn');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  	END admpl_val_offer_optn;
  	--------------------------------------- MAIN ----------------------------------
  ------------------
  BEGIN
  	p_message_name := NULL;
  	IF (p_offered_ind = 'Y' AND
  		 (p_cal_type IS NULL OR
  		  p_ci_sequence_number IS NULL OR
  		  p_location_cd IS NULL OR
  		  p_unit_class IS NULL)) THEN
  		-- unit offering option components must all be specified when offered
  		p_message_name := 'IGS_AD_COMPONENTS_TOBE_SPECIF';
  		RETURN FALSE;
  	END IF;
  	IF (p_cal_type IS NOT NULL OR
  		p_location_cd IS NOT NULL OR
  		p_unit_class IS NOT NULL OR
  		p_unit_mode IS NOT NULL) THEN
  		-- Initialize input parameters first
  		v_val_ind_type := 0;
  		IF (p_cal_type IS NULL OR
  			p_ci_sequence_number IS NULL) THEN
  			-- Search for valid offering option
  			FOR c_cir_rec IN c_cir LOOP
  				v_cir_found := TRUE;
  				v_cal_type := c_cir_rec.sub_cal_type;
  				v_ci_sequence_number := c_cir_rec.sub_ci_sequence_number;
  				-- Validate the teaching period
  				IF IGS_AD_VAL_ACAIU.admp_val_acaiu_ci(
  						c_cir_rec.sub_cal_type,
  						c_cir_rec.sub_ci_sequence_number,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_acad_cal_type,
  						p_acad_ci_sequence_number,
  						p_offered_ind,
  						'Y', --(validate admission link only)
  						v_message_name) = TRUE THEN
  					v_admp_pk_ind := TRUE;
  					-- Validate unit offering option
  					IF admpl_val_offer_optn(
  							v_cal_type,
  							v_ci_sequence_number,
  							v_val_ind_type_offer) = TRUE THEN
  						v_val_ind_type := v_val_ind_type_offer;
  						v_val_off_optn_found := TRUE;
  						EXIT; -- (IGS_CA_INST_REL)
  					ELSE
  						v_val_ind_type := v_val_ind_type_offer;
  						v_val_off_optn_found := FALSE;
  					END IF;
  				END IF;
  			END LOOP;  -- (IGS_CA_INST_REL)
  			-- set flag to 1 so that the error msg number could be returned
  			IF v_cir_found = FALSE  OR v_admp_pk_ind = FALSE THEN
  				v_val_ind_type := 1;
  			END IF;
  		ELSE
  			 -- Validate the teaching period
  			IF IGS_AD_VAL_ACAIU.admp_val_acaiu_ci(
  					p_cal_type,
  					p_ci_sequence_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					p_acad_cal_type,
  					p_acad_ci_sequence_number,
  					p_offered_ind,
  					'N',  -- (validate admission link only)
  					v_message_name) = FALSE THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  			v_cal_type := p_cal_type;
  			v_ci_sequence_number := p_ci_sequence_number;
  			-- Validate unit offering option
  			IF admpl_val_offer_optn(
  						v_cal_type,
  						v_ci_sequence_number,
  						v_val_ind_type_offer) = TRUE THEN
  				v_val_ind_type := v_val_ind_type_offer;
  				v_val_off_optn_found := TRUE;
  			ELSE
  				v_val_ind_type := v_val_ind_type_offer;
  			END IF;
  		END IF;
  		IF v_val_off_optn_found = FALSE AND v_val_ind_type = 1 THEN
  			p_message_name:= 'IGS_AD_NO_UOO_MATCHING';
  			RETURN FALSE;
  		END IF;
  		IF v_val_off_optn_found = FALSE AND v_val_ind_type = 2 THEN
  			p_message_name := 'IGS_AD_NO_OFR_UOO_MATCHING';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_opt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END admp_val_acaiu_opt;

  --
  -- Validate the admission course application instance unit outcome status
  FUNCTION admp_val_acaiu_auos(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2	 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_auos
  	-- This module validates IGS_AD_PS_APLINSTUNT outcome status.
  DECLARE
  	cst_pending		CONSTANT VARCHAR2(7) :='PENDING';
  	cst_offer		CONSTANT VARCHAR2(5) :='OFFER';
  	cst_cond_offer		CONSTANT VARCHAR2(10) :='COND-OFFER';
  	cst_withdrawn		CONSTANT VARCHAR2(9) :='WITHDRAWN';
  	cst_voided		CONSTANT VARCHAR2(6) :='VOIDED';
  	v_message_name		VARCHAR2(30);
  	v_s_adm_outcome_status_aos		IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
  	v_s_adm_outcome_status_auos		IGS_AD_UNIT_OU_STAT.s_adm_outcome_status%TYPE;
  	CURSOR c_aos IS
  		SELECT	aos.s_adm_outcome_status
  		FROM	IGS_AD_PS_APPL_INST	acai,
  			IGS_AD_OU_STAT		aos
  		WHERE	acai.adm_outcome_status		= aos.adm_outcome_status	AND
  			acai.person_id			= p_person_id			AND
  			acai.admission_appl_number	= p_admission_appl_number	AND
  			acai.nominated_course_cd	= p_nominated_course_cd		AND
  			acai.sequence_number		= p_acai_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate that the status is not closed.
  	IF IGS_AD_VAL_ACAIU.admp_val_auos_closed(
  		p_adm_unit_outcome_status,
  		v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate that status does not conflict with the admission course
  	-- application status.
  	OPEN c_aos;
  	FETCH c_aos INTO v_s_adm_outcome_status_aos;
  	IF c_aos%FOUND THEN
  		CLOSE c_aos;
  		-- Get system value for unit outcome status
  		v_s_adm_outcome_status_auos := IGS_AD_GEN_008.ADMP_GET_SAUOS(
  						p_adm_unit_outcome_status);
  		-- Validate statuses
  		IF v_s_adm_outcome_status_auos = cst_pending		AND
  				v_s_adm_outcome_status_aos IN (
  								cst_offer,
  								cst_cond_offer,
  								cst_withdrawn,
  								cst_voided)	THEN
  			p_message_name := 'IGS_PR_OUTCOME_ST_NOTBE_PEND';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		CLOSE c_aos;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_aos%ISOPEN THEN
  			CLOSE c_aos;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_auos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acaiu_auos;

  --
  -- Validate the admission course application instance unit cal. instance
  FUNCTION admp_val_acaiu_ci(
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_val_adm_only_ind IN VARCHAR2 DEFAULT 'N',
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_ci
  	-- This module validates the teaching period IGS_CA_INST given for the
  	-- IGS_AD_PS_APLINSTUNT.
  DECLARE
  	cst_teaching	CONSTANT	VARCHAR2(8) := 'TEACHING';
  	cst_inactive	CONSTANT	VARCHAR2(8) := 'INACTIVE';
  	cst_planned	CONSTANT	VARCHAR2(7) := 'PLANNED';
  	cst_academic	CONSTANT	VARCHAR2(8) := 'ACADEMIC';
  	cst_admission	CONSTANT	VARCHAR2(9) := 'ADMISSION';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_teach_perd IS
  		SELECT	cs.s_cal_status,
  			cat.s_cal_cat
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_STAT	cs,
  			IGS_CA_TYPE	cat
  		WHERE	ci.cal_status		= cs.cal_status			AND
  			ci.cal_type		= cat.cal_type			AND
  			ci.cal_type		= p_teach_cal_type		AND
  			ci.sequence_number	= p_teach_ci_sequence_number;
  	v_teach_perd_rec	c_teach_perd%ROWTYPE;
  	CURSOR c_chk_within_acad IS
  		SELECT	'x'
  		FROM	IGS_CA_INST_REL	cir,
  			IGS_CA_TYPE			cat
  		WHERE	cir.sup_cal_type		= cat.cal_type		AND
  			cir.sup_cal_type		= p_acad_cal_type	AND
  			cir.sup_ci_sequence_number	= p_acad_ci_sequence_number AND
  			cir.sub_cal_type		= p_teach_cal_type	AND
  			cir.sub_ci_sequence_number	= p_teach_ci_sequence_number AND
  			cat.s_cal_cat			= cst_academic;
  	CURSOR c_chk_include_adm IS
  		SELECT	'x'
  		FROM	IGS_CA_INST_REL	cir,
  			IGS_CA_TYPE			cat
  		WHERE	cir.sub_cal_type		= cat.cal_type		AND
  			cir.sup_cal_type		= p_teach_cal_type	AND
  			cir.sup_ci_sequence_number	= p_teach_ci_sequence_number AND
  			cir.sub_cal_type		= p_adm_cal_type	AND
  			cir.sub_ci_sequence_number	= p_adm_ci_sequence_number AND
  			cat.s_cal_cat			= cst_admission;
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	-- Validate that the calendar instance is a teaching calendar of the
  	-- right status.
  	OPEN c_teach_perd;
  	LOOP
  		FETCH c_teach_perd INTO v_teach_perd_rec;
  		EXIT WHEN c_teach_perd%NOTFOUND;
  	END LOOP;
  	IF c_teach_perd%ROWCOUNT = 0 THEN
  		CLOSE c_teach_perd;
  		RETURN TRUE;
  	ELSE
  		CLOSE c_teach_perd;
  		IF v_teach_perd_rec.s_cal_cat <> cst_teaching THEN
  			p_message_name := 'IGS_AD_CALINST_NOT_TEACHING';
  			RETURN FALSE;
  		END IF;
  		IF p_offered_ind = 'N'	AND
  				v_teach_perd_rec.s_cal_status = cst_inactive THEN
  			p_message_name := 'IGS_AD_CALST_NOT_ACTIVE_PLAN';
  			RETURN FALSE;
  		END IF;
  		IF p_offered_ind = 'Y'	AND
  				v_teach_perd_rec.s_cal_status IN(
  								cst_inactive,
  								cst_planned) THEN
  			p_message_name := 'IGS_AD_CALST_NOT_ACTIVE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate that the teaching period is a calendar instance in the
  	-- academic period of the admission course application.
  	IF p_val_adm_only_ind = 'N' THEN
  		OPEN c_chk_within_acad;
  		FETCH c_chk_within_acad INTO v_dummy;
  		IF c_chk_within_acad%NOTFOUND THEN
  			CLOSE c_chk_within_acad;
  			p_message_name := 'IGS_AD_TCHPRD_NOT_LINKED';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_chk_within_acad;
  	END IF;
  	-- Validate that the teaching period is a superior calendar instance
  	-- for the admission period of the admission course application.
  	OPEN c_chk_include_adm;
  	FETCH c_chk_include_adm INTO v_dummy;
  	IF c_chk_include_adm%NOTFOUND THEN
  		CLOSE c_chk_include_adm;
  		p_message_name := 'IGS_AD_TEACHPRD_NOT_LINKED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_chk_include_adm;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_teach_perd%ISOPEN THEN
  			CLOSE c_teach_perd;
  		END IF;
  		IF c_chk_within_acad%ISOPEN THEN
  			CLOSE c_chk_within_acad;
  		END IF;
  		IF c_chk_include_adm%ISOPEN THEN
  			CLOSE c_chk_include_adm;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_ci');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
       END admp_val_acaiu_ci;

  --
  -- Validate the unit mode of the admission course application inst unit.
  FUNCTION admp_val_acaiu_um(
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_um
  	-- This module validates that the IGS_AD_PS_APLINSTUNT unit class
  	-- and unit mode do not conflict.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_um IS
  		SELECT	'x'
  		FROM	IGS_AS_UNIT_CLASS uc
  		WHERE	uc.unit_mode	= p_unit_mode	AND
  			uc.unit_class	= p_unit_class;
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	IF p_unit_mode IS NOT NULL AND
  			p_unit_class IS NOT NULL THEN
  		OPEN c_um;
  		FETCH c_um INTO v_dummy ;
  		IF c_um%NOTFOUND THEN
  			CLOSE c_um;
  			p_message_name := 'IGS_AD_UC_UM_INCOMPLATIBLE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_um;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_um%ISOPEN THEN
  			CLOSE c_um;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_um');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END admp_val_acaiu_um;

  --
  -- Validate the admission course application instance unit restr number
  FUNCTION admp_val_acaiu_restr(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_restriction_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_uv_version_number IN NUMBER ,  -- Added for bug 3083148
  p_cal_type IN VARCHAR2 ,         -- Added for bug 3083148
  p_ci_sequence_number IN NUMBER , -- Added for bug 3083148
  p_location_cd IN VARCHAR2 ,      -- Added for bug 3083148
  p_unit_class IN VARCHAR2 )       -- Added for bug 3083148
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_restr
  	-- This module validates the IGS_AD_PS_APLINSTUNT unit
  	--  restriction number.
  DECLARE
  	v_count		NUMBER(5);
  	CURSOR c_count_acaiu IS
  		SELECT	count(*)
  		FROM	IGS_AD_PS_APLINSTUNT acaiu
  		WHERE	acaiu.person_id			= p_person_id			AND
  			acaiu.admission_appl_number	= p_admission_appl_number	AND
  			acaiu.nominated_course_cd	= p_nominated_course_cd		AND
  			acaiu.acai_sequence_number	= p_acai_sequence_number	AND
  			acaiu.unit_cd			<> p_unit_cd AND
        acaiu.uv_version_number <> p_uv_version_number AND
        NVL(acaiu.cal_type,'*-1') <> NVL(p_cal_type,'*-2') AND
        NVL(acaiu.ci_sequence_number,-1) <> NVL(p_ci_sequence_number,-2) AND
        NVL(acaiu.location_cd,'*-1') <> NVL(p_location_cd,'*-2') AND
        NVL(acaiu.unit_class,'*-1') <> NVL(p_unit_class,'*-2');
  BEGIN
  	-- Set default value.
  	p_message_name := NULL;
  	OPEN c_count_acaiu;
  	FETCH c_count_acaiu INTO v_count;
  	CLOSE c_count_acaiu;
  	IF v_count > NVL(p_unit_restriction_num,0) THEN
  		p_message_name := 'IGS_AD_UNITS_CANNOT_CREATED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_count_acaiu%ISOPEN THEN
  			CLOSE c_count_acaiu;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_restr');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acaiu_restr;

  --
  -- Validate if IGS_AD_OU_STAT.adm_outcome_status is closed.
  FUNCTION admp_val_auos_closed(
  p_adm_unit_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_auos_closed
  	--Validate if IGS_AD_UNIT_OU_STAT.adm_unit_outcome_status is closed
  DECLARE
  	v_auos_exists	VARCHAR2(1);
  	CURSOR c_auos IS
  		SELECT	'x'
  		FROM	IGS_AD_UNIT_OU_STAT		auos
  		WHERE	adm_unit_outcome_status = p_adm_unit_outcome_status	AND
  			closed_ind = 'Y';
  BEGIN
  	--set the default message number
  	p_message_name := null	;
  	OPEN c_auos;
  	FETCH c_auos INTO v_auos_exists;
  	IF (c_auos%FOUND) THEN
  		CLOSE c_auos;
  		p_message_name := 'IGS_AD_UNIT_OUTCOME_ST_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_auos;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_auos%ISOPEN) THEN
  			CLOSE c_auos;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_auos_closed');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_auos_closed;

  --
  -- Validate the admission course application instance unit alternate code
  FUNCTION admp_val_acaiu_altcd(
  p_alternate_code IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY  VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_altcd
  	-- This module validates the teaching period alternate code given
  	-- for the IGS_AD_PS_APLINSTUNT
  DECLARE
  	cst_teaching		CONSTANT VARCHAR2(10) := 'TEACHING';
  	CURSOR c_cat IS
  		SELECT	cat.s_cal_cat
  		FROM	IGS_CA_INST 	ci,
  			IGS_CA_TYPE	cat
  		WHERE	ci.alternate_code 	= p_alternate_code AND
  			ci.cal_type 		= cat.cal_type;
  	CURSOR c_cir IS
  		SELECT	ci.cal_type,
  			ci.sequence_number,
  			cs.s_cal_status
  		FROM	IGS_CA_INST_REL	cir,
  			IGS_CA_INST			ci,
  			IGS_CA_TYPE			cat,
  			IGS_CA_STAT			cs
  		WHERE	cir.sup_cal_type 		= p_acad_cal_type AND
  			cir.sup_ci_sequence_number 	= p_acad_ci_sequence_number AND
  			ci.sequence_number 		= cir.sub_ci_sequence_number AND
  			ci.cal_type	 		= cir.sub_cal_type AND
  			ci.alternate_code 		= p_alternate_code AND
  			cat.cal_type 			= ci.cal_type AND
  			cs.cal_status 			= ci.cal_status AND
  			cat.s_cal_cat 			= cst_teaching AND
  			ci.cal_status			= cs.cal_status;
  	CURSOR c_cir_cat(
  		cp_cal_type		IGS_AD_APPL.adm_cal_type%TYPE,
  		cp_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CA_INST_REL 	cir,
  			IGS_CA_TYPE			cat
  		WHERE	cir.sub_cal_type 		= p_adm_cal_type AND
  			cir.sub_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			cir.sup_cal_type 		= cp_cal_type AND
  			cir.sup_ci_sequence_number 	= cp_sequence_number;
  	CURSOR c_uoo (
  		cp_cal_type		IGS_AD_APPL.adm_cal_type%TYPE,
  		cp_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_UNIT_OFR_OPT uoo
  		WHERE	uoo.unit_cd 		= p_unit_cd AND
  			uoo.version_number 	= p_uv_version_number AND
  			uoo.cal_type 		= cp_cal_type AND
  			uoo.ci_sequence_number 	= cp_sequence_number AND
  			uoo.offered_ind 	= 'Y';
  	v_cat_found		BOOLEAN DEFAULT FALSE;
  	v_alternate_code_valid	BOOLEAN DEFAULT FALSE;
  	v_cir_found		BOOLEAN DEFAULT FALSE;
  	v_planned_active_found	BOOLEAN DEFAULT FALSE;
  	v_cir_cat_exists	VARCHAR2(1);
  	v_alternate_code_teach 	BOOLEAN DEFAULT FALSE;
  	v_uoo_exists		VARCHAR2(1);
  	v_uoo_found		BOOLEAN DEFAULT FALSE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate alternate code
  	FOR v_cat_rec IN c_cat LOOP
  		v_cat_found := TRUE;
  		IF v_cat_rec.s_cal_cat = cst_teaching THEN
  			v_alternate_code_valid := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF NOT v_cat_found THEN
  		p_message_name := 'IGS_AD_TCHPRD_DOESNOT_EXIST';
  		RETURN FALSE;
  	END IF;
  	IF NOT v_alternate_code_valid THEN
  		p_message_name := 'IGS_AD_TCHPRD_MAPS_CALINST';
  		RETURN FALSE;
  	END IF;
  	-- Validate that alternate code has at least one calendar instance
  	-- in the academic period of the admission application that is
  	-- active.
  	FOR v_cir_rec IN c_cir LOOP
  		v_cir_found := TRUE;
  		IF v_cir_rec.s_cal_status IN ('ACTIVE') THEN  --removed the planned status as per bug#2722785 --rghosh
  			v_planned_active_found := TRUE;
  			-- Validate that alternate code is teaching
  			-- period in the admission period.
  			OPEN c_cir_cat(
  					v_cir_rec.cal_type,
  					v_cir_rec.sequence_number);
  			FETCH c_cir_cat INTO v_cir_cat_exists;
  			IF c_cir_cat%FOUND THEN
  				v_alternate_code_teach := TRUE;
  				-- Validate unit offering option exists for the unit code
  				-- in the teaching period specified for the academic
  				-- period/admission.
  				OPEN c_uoo (
  					v_cir_rec.cal_type,
  					v_cir_rec.sequence_number);
  				FETCH c_uoo INTO v_uoo_exists;
  				IF c_uoo%FOUND THEN
  					CLOSE c_cir_cat;
  					CLOSE c_uoo;
  					v_uoo_found := TRUE;
  					EXIT;
  				END IF;
  				CLOSE c_uoo;
  			END IF;
  			CLOSE c_cir_cat;
  		END IF;
  	END LOOP;
  	IF NOT v_cir_found THEN
  		-- The alternate code is not a teaching calendar in
  		-- the academic period of the admission application.
  		p_message_name := 'IGS_AD_TCHPRD_NOTIN_ACADEMIC';
  		RETURN FALSE;
  	END IF;
  	IF NOT v_planned_active_found THEN
  		-- Alternate code has no active teaching
  		-- calendars in the academic period of the admission applcaition
  		p_message_name := 'IGS_AD_TCHPRD_EXISTS_ACADEMIC';
  		RETURN FALSE;
  	END IF;
  	IF NOT v_alternate_code_teach THEN
  		-- Alternate Code is not a teaching period in the
  		-- admission period of the admission application.
  		p_message_name := 'IGS_AD_TCHPRD_NOTIN_COMPRD';
  		RETURN FALSE;
  	END IF;
  	IF NOT v_uoo_found THEN
  		-- Alternate code is a teaching period in the admission
  		-- period but there are no offerings of the unit in the
  		-- academic period/admission period.
  		p_message_name := 'IGS_AD_TCHPRD_NO_UOO';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_altcd');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END admp_val_acaiu_altcd;

  --
  -- Validate the unit version of the admission course application.
  FUNCTION admp_val_acaiu_uv(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_uv
  	-- This module validate IGS_AD_PS_APLINSTUNT unit version.
  DECLARE
  	v_award_course_only_ind		IGS_PS_UNIT_VER.award_course_only_ind%TYPE;
  	v_s_unit_status			IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR c_val_unit_version IS
  		SELECT	uv.award_course_only_ind,
  			us.s_unit_status
  		FROM	IGS_PS_UNIT_VER	uv,
  			IGS_PS_UNIT_STAT	us
  		WHERE	uv.unit_cd		= p_unit_cd	AND
  			uv.version_number	= p_uv_version_number AND
  			us.unit_status		= uv.unit_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate unit version
  	OPEN c_val_unit_version;
  	FETCH c_val_unit_version INTO	v_award_course_only_ind,
  					v_s_unit_status;
  	IF c_val_unit_version%NOTFOUND THEN
  		CLOSE c_val_unit_version;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	ELSE
  		CLOSE c_val_unit_version;
  		IF  (v_s_unit_status <> 'ACTIVE') THEN       --removed the planned status as per bug#2722785 --rghosh
  			-- unit Version must be  active.
  			p_message_name := 'IGS_AD_UNITVER_DOESNOT_ACTIVE';
  			RETURN FALSE;
  		END IF;
  		IF (p_offered_ind = 'Y' AND
  			v_s_unit_status = 'PLANNED') THEN
  			-- unit Version must be active when offered
  			p_message_name := 'IGS_AD_UNITVER_ST_ACTIVE';
  			RETURN FALSE;
  		END IF;
  		IF (p_s_admission_process_type = 'NON-AWARD') THEN
  			IF(v_award_course_only_ind = 'Y') THEN
  				-- unit version is for award courses only
  				p_message_name := 'IGS_AD_UNITVER_AWARD_PRG';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_uv');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
     END admp_val_acaiu_uv;

  --
  -- Do encumbrance check for admission_course_appl_instance_unit.unit_cd.
  FUNCTION admp_val_acaiu_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_unit_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_encmb
  	-- Perform encumbrance checks for the
  	-- admission_course_appl_instance_unit.unit_cd
  DECLARE
  	v_message_name	 VARCHAR2(30) DEFAULT NULL;
  	v_encmb_check_dt	DATE;
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_unit_encmb_chk_ind = 'Y' THEN
  		-- Get the encumbrance checking date.
  		v_encmb_check_dt := IGS_AD_GEN_006.ADMP_GET_ENCMB_DT(
  						p_adm_cal_type,
  						p_adm_ci_sequence_number);
  		IF v_encmb_check_dt IS NULL THEN
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_ENCUMB_CANNOT_PERFORM';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_ENCUMB_CHK_NOT_PERFORM';
  				p_return_type := cst_warn;
  			END IF;
  			RETURN FALSE;
  		END IF;
  		-- Validate for exclusion or suspension from the unit within the course
  		IF IGS_EN_VAL_ENCMB.enrp_val_excld_unit(
  						p_person_id,
  						p_course_cd,
  						p_unit_cd,
  						v_encmb_check_dt,
  						v_message_name) = FALSE THEN
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_PRSN_ENCUMB_EXC_PRG';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_PRSN_ENCUMB_EXC_UNIT';
  				p_return_type := cst_warn;
  			END IF;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_encmb');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_acaiu_encmb;

  --
  -- Validate an admission course application instance research unit.
  FUNCTION admp_val_res_unit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_res_unit
  	-- Description: Validate an admission course application instance
  	-- research unit.
  DECLARE
  	v_uv_rec			VARCHAR2(1);
  	v_can_rec			VARCHAR2(1);
  	v_admission_appl_number
  					IGS_AD_PS_APLINSTUNT.admission_appl_number%TYPE;
  	v_nominated_course_cd		IGS_AD_PS_APLINSTUNT.nominated_course_cd%TYPE;
  	v_acai_sequence_number
  					IGS_AD_PS_APLINSTUNT.acai_sequence_number%TYPE;
  	cst_error			CONSTANT VARCHAR2(1) := 'E';
  	cst_warn			CONSTANT VARCHAR2(1) := 'W';
  	cst_readmit			CONSTANT VARCHAR2(9) := 'RE-ADMIT';
  	CURSOR	c_uv IS
  		SELECT	'X'
  		FROM	IGS_PS_UNIT_VER		uv
  		WHERE	uv.unit_cd 		= p_unit_cd AND
  			uv.version_number 	= p_uv_version_number AND
  			uv.research_unit_ind 	= 'Y';
  	CURSOR	c_can IS
  		SELECT	'X'
  		FROM	IGS_RE_CANDIDATURE			can
  		WHERE	can.person_id			= p_person_id AND
  			((v_admission_appl_number	IS NOT NULL AND
  			can.acai_admission_appl_number	= v_admission_appl_number AND
  			v_nominated_course_cd		IS NOT NULL AND
  			can.acai_nominated_course_cd	= v_nominated_course_cd AND
  			v_acai_sequence_number		IS NOT NULL AND
  			can.acai_sequence_number	= v_acai_sequence_number) OR
  			(p_course_cd 			IS NOT NULL AND
  			can.sca_course_cd 		= p_course_cd));
  BEGIN
  	p_message_name := NULL;
  	OPEN c_uv;
  	FETCH c_uv INTO v_uv_rec;
  	IF (c_uv%FOUND) THEN
  		CLOSE c_uv;
  		IF p_s_admission_process_type = cst_readmit THEN
  			IGS_RE_GEN_002.RESP_GET_SCA_CA_ACAI (
  					p_person_id,
  					p_course_cd,
  					p_admission_appl_number,
  					p_nominated_course_cd,
  					p_acai_sequence_number,
  					v_admission_appl_number,
  					v_nominated_course_cd,
  					v_acai_sequence_number);
  		ELSE
  			v_admission_appl_number := p_admission_appl_number;
  			v_nominated_course_cd := p_nominated_course_cd;
  			v_acai_sequence_number := p_acai_sequence_number;
  		END IF;
  		OPEN c_can;
  		FETCH c_can INTO v_can_rec;
  		IF (c_can%NOTFOUND) THEN
  			CLOSE c_can;
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_RESCAND_NOT_SUPPLIED';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			ELSE
  				p_message_name := 'IGS_AD_RES_CANDIDATURE_MUSTEX';
  				p_return_type := cst_warn;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_can;
  	ELSE
  		CLOSE c_uv;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uv%ISOPEN) THEN
  			CLOSE c_uv;
  		END IF;
  		IF (c_can%ISOPEN) THEN
  			CLOSE c_can;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_res_unit');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
      END admp_val_res_unit;

  --
  -- Validate the adm course appl inst unit against the teaching period.
  FUNCTION admp_val_acaiu_uv_ci(
  p_unit_cd IN VARCHAR2 ,
  p_uv_version_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 ,
  p_teach_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_acaiu_uv_ci
  	-- Validate the admission course application instance unit version against
  	-- the teaching calendar
  DECLARE
  	v_expiry_dt	IGS_PS_UNIT_VER.expiry_dt%TYPE;
  	v_start_dt	IGS_CA_INST.start_dt%TYPE;
  	CURSOR c_uv IS
  		SELECT	uv.expiry_dt
  		FROM	IGS_PS_UNIT_VER		uv
  		WHERE	uv.unit_cd 		= p_unit_cd AND
  			uv.version_number	= p_uv_version_number AND
  			uv.expiry_dt		IS NOT NULL;
  	CURSOR c_ci IS
  		SELECT	ci.start_dt
  		FROM	IGS_CA_INST		ci
  		WHERE	ci.cal_type		= p_teach_cal_type AND
  			ci.sequence_number	= p_teach_ci_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate if the expiry date of the unit version is set
  	OPEN c_uv;
  	FETCH c_uv INTO v_expiry_dt;
  	IF c_uv%FOUND THEN
  		CLOSE c_uv;
  		-- Determine the start date of the teaching period
  		OPEN c_ci;
  		FETCH c_ci INTO v_start_dt;
  		IF c_ci%FOUND THEN
  			CLOSE c_ci;
  			IF v_expiry_dt < v_start_dt THEN
  				p_message_name := 'IGS_AD_UNITVER_EXP_DT_AFTER';
  				RETURN FALSE;
  			END IF;
  		ELSE
  			CLOSE c_ci;
  		END IF;
  	ELSE
  		CLOSE c_uv;
  	END IF;
  	RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uv%ISOPEN THEN
  			CLOSE c_uv;
  		END IF;
  		IF c_ci%ISOPEN THEN
  			CLOSE c_ci;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_ACAIU.admp_val_acaiu_uv_ci');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
    END admp_val_acaiu_uv_ci;
END IGS_AD_VAL_ACAIU;

/
