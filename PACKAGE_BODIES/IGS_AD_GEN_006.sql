--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_006" AS
/* $Header: IGSAD06B.pls 115.10 2003/12/01 13:15:54 rboddu ship $ */
FUNCTION admp_get_encmb_dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE IS
BEGIN	-- admp_get_encmb_dt
	-- This module gets the encumbrance check date when passed an admission
	-- calendar type and sequence number.
DECLARE
	v_encmb_chk_dt		IGS_CA_DA_INST_V.alias_val%TYPE;
	CURSOR c_encmb_dt IS
		SELECT	daiv.alias_val
		FROM	IGS_CA_DA_INST_V	daiv,
			IGS_AD_CAL_CONF		sacc
		WHERE	daiv.cal_type		= p_adm_cal_type	AND
			daiv.ci_sequence_number	= p_adm_ci_sequence_number AND
			daiv.dt_alias		= sacc.adm_appl_encmb_chk_dt_alias
		ORDER BY daiv.alias_val DESC;
BEGIN
	OPEN c_encmb_dt;
	FETCH c_encmb_dt INTO v_encmb_chk_dt;
	IF (c_encmb_dt%FOUND) THEN
		CLOSE c_encmb_dt;
		RETURN v_encmb_chk_dt;
	ELSE
		CLOSE c_encmb_dt;
		RETURN IGS_GE_DATE.IGSDATE(NULL);
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_encmb_dt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_encmb_dt;

PROCEDURE admp_get_enq_pp(
  p_oracle_username IN VARCHAR2 ,
  p_enq_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_enq_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enq_acad_alternate_code OUT NOCOPY VARCHAR2 ,
  p_enq_acad_abbreviation OUT NOCOPY VARCHAR2 ,
  p_enq_adm_cal_type OUT NOCOPY VARCHAR2 ,
  p_enq_adm_ci_sequence_number OUT NOCOPY NUMBER ,
  p_enq_adm_alternate_code OUT NOCOPY VARCHAR2 ,
  p_enq_adm_abbreviation OUT NOCOPY VARCHAR2 )
IS
BEGIN 	-- admp_get_enq_pp
	-- Routine to get the admission enquiry person preferences
DECLARE
	CURSOR c_ppenqv (p_person_id 			IN  IGS_PE_PERSON.person_id%TYPE) IS
		SELECT	ppenqv.enq_acad_cal_type,
			ppenqv.enq_acad_ci_sequence_number,
			ppenqv.enq_acad_alternate_code,
			cat1.abbreviation,
			ppenqv.enq_adm_cal_type,
			ppenqv.enq_adm_ci_sequence_number,
			ppenqv.enq_adm_alternate_code,
			cat2.abbreviation
		FROM	igs_pe_person_prefs_enq_v 	ppenqv,  /* Removed cartesian join with IGS_PE_PERSON. Bug 3150054 */
			igs_ca_inst 			ci1,
			igs_ca_type 			cat1,
			igs_ca_inst 			ci2,
			igs_ca_type 			cat2
		WHERE
			ppenqv.person_id 		= p_person_id AND
			ci1.cal_type (+)		= ppenqv.enq_acad_cal_type AND
			ci1.sequence_number (+) 	= ppenqv.enq_acad_ci_sequence_number AND
			cat1.cal_type (+) 		= ci1.cal_type AND
			ci2.cal_type (+) 		= ppenqv.enq_adm_cal_type AND
			ci2.sequence_number (+) 	= ppenqv.enq_adm_ci_sequence_number AND
			cat2.cal_type (+) 		= ci2.cal_type;

v_person_id             IGS_PE_PERSON.PERSON_ID%TYPE;
BEGIN
	v_person_id   := FND_GLOBAL.USER_ID;
	OPEN	c_ppenqv(v_person_id);
	FETCH	c_ppenqv INTO 	p_enq_acad_cal_type,
				p_enq_acad_ci_sequence_number,
				p_enq_acad_alternate_code,
				p_enq_acad_abbreviation,
				p_enq_adm_cal_type,
				p_enq_adm_ci_sequence_number,
				p_enq_adm_alternate_code,
				p_enq_adm_abbreviation;
	IF(c_ppenqv%NOTFOUND) THEN
		p_enq_acad_cal_type := NULL;
		p_enq_acad_ci_sequence_number := NULL;
		p_enq_acad_alternate_code := NULL;
		p_enq_acad_abbreviation := NULL;
		p_enq_adm_cal_type := NULL;
		p_enq_adm_ci_sequence_number := NULL;
		p_enq_adm_alternate_code := NULL;
		p_enq_adm_abbreviation := NULL;
	END IF;
	CLOSE c_ppenqv;
	RETURN;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_enq_pp');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_enq_pp;

FUNCTION admp_get_itt_amttyp(
  p_intake_target_type IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_itt_amttyp
	-- Description: This module retrieves the s_amount_type from
	-- intake_target_type for a given intake_target_type.
DECLARE
	v_s_amount_type		IGS_AD_INTAK_TRG_TYP.s_amount_type%TYPE;
	CURSOR	c_itt IS
		SELECT	itt.s_amount_type
		FROM	IGS_AD_INTAK_TRG_TYP 	itt
		WHERE	itt.intake_target_type 	= p_intake_target_type;
BEGIN
	OPEN c_itt;
	FETCH c_itt INTO v_s_amount_type;
	IF (c_itt%NOTFOUND) THEN
		CLOSE c_itt;
		RETURN NULL;
	ELSE
		CLOSE c_itt;
		RETURN v_s_amount_type;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_itt_amttyp');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_itt_amttyp;

FUNCTION admp_get_iv_addr(
  p_person_id IN NUMBER )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_iv_addr
	-- This module retrieves name and address information of international agents
	-- for use on letters.
DECLARE
	cst_case_type		CONSTANT	VARCHAR2(6) := 'NORMAL';
	cst_name_style		CONSTANT	VARCHAR2(5) := 'TITLE';
	v_agent_person_id	IGS_PE_VISA.agent_person_id%TYPE;
	v_out_string		VARCHAR2(2000);
	CURSOR	c_iv IS
		SELECT 	agent_person_id
		FROM	IGS_PE_VISA	iv
		WHERE	person_id = p_person_id AND
			agent_person_id IS NOT NULL AND
			(visa_expiry_date > TRUNC(SYSDATE) OR
			visa_expiry_date IS NULL);
BEGIN
	OPEN c_iv;
	FETCH c_iv INTO v_agent_person_id;
	IF (c_iv%NOTFOUND) THEN
		CLOSE c_iv;
		RETURN NULL;
	END IF;
	CLOSE c_iv;
	v_out_string:= IGS_GE_GEN_001.genp_get_addr(v_agent_person_id,
			NULL,
			NULL,
			NULL,
			NULL,
			cst_case_type,
			'N',
			cst_name_style,
			'Y');
	RETURN v_out_string;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_iv_addr');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_iv_addr;

FUNCTION admp_get_let_resp_dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN
DECLARE
	v_out_date	IGS_AD_PS_APPL_INST.offer_response_dt%TYPE;
	CURSOR c_acai IS
		SELECT	acai.offer_response_dt
		FROM	IGS_AD_PS_APPL_INST	acai
		WHERE	acai.person_id			= p_person_id AND
			acai.admission_appl_number	= p_admission_appl_number AND
			acai.nominated_course_cd	= p_nominated_course_cd AND
			acai.sequence_number		= p_acai_sequence_number;
BEGIN
	-- Validate parameters
	IF (p_person_id IS NULL OR
			p_admission_appl_number IS NULL OR
			p_nominated_course_cd IS NULL OR
			p_acai_sequence_number IS NULL) THEN
		RETURN NULL;
	END IF;
	OPEN c_acai;
	FETCH c_acai INTO v_out_date;
	IF (c_acai%NOTFOUND) THEN
		CLOSE c_acai;
		RETURN NULL;
	END IF;
	CLOSE c_acai;
	RETURN TO_CHAR(v_out_date, 'DD/MM/YYYY');
EXCEPTION
	WHEN OTHERS THEN
		IF (c_acai%ISOPEN) THEN
			CLOSE c_acai;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_let_resp_dt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_let_resp_dt;

FUNCTION admp_get_lvl_qual(
  p_tac_level_of_qual IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_lvl_qual
	-- This module finds the user defined tertiary education level of qualification
	-- from the TAC level of qualification.
DECLARE
	CURSOR c_telq IS
		SELECT	tertiary_edu_lvl_qual
		FROM	IGS_AD_TER_ED_LVL_QF
		WHERE	tac_level_of_qual = p_tac_level_of_qual AND
			closed_ind = 'N';
	v_tertiary_edu_lvl_qual
		IGS_AD_TER_ED_LVL_QF.tertiary_edu_lvl_qual%TYPE DEFAULT NULL;
BEGIN
	-- Cursor handling
	OPEN c_telq ;
	FETCH c_telq INTO v_tertiary_edu_lvl_qual;
	CLOSE c_telq;
	-- Return the appropriate value, null if record is not found
	RETURN v_tertiary_edu_lvl_qual;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_006.admp_get_lvl_qual');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_lvl_qual;

END igs_ad_gen_006;

/
