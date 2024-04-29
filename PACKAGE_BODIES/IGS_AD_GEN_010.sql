--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_010" AS
/* $Header: IGSAD10B.pls 115.10 2003/12/03 20:48:59 knag ship $ */

/* who       when        what
   sarakshi  6-May-2003  Bug#2858431,modified procedure admp_get_tac_ceprc,admp_get_tac_return to
                         change system reference codes to OTHER from TAC-FEE,TAC-HECS
*/
FUNCTION admp_get_tac_api(
  p_person_id IN NUMBER )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_tac_api
	-- This function gets the TAC alternate person ID
DECLARE
	cst_tac		CONSTANT	IGS_PE_PERSON_ID_TYP.s_person_id_type%TYPE := 'TAC';
	v_tac_id				IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
	CURSOR c_api_pit IS
		SELECT	api.api_person_id
		FROM	IGS_PE_ALT_PERS_ID	api,
			IGS_PE_PERSON_ID_TYP		pit
		WHERE	api.pe_person_id	      = p_person_id AND
			pit.person_id_type	= api.person_id_type AND
			pit.s_person_id_type	= cst_tac;
BEGIN
	OPEN c_api_pit;
	FETCH c_api_pit INTO v_tac_id;
	IF (c_api_pit%NOTFOUND) THEN
		CLOSE c_api_pit;
		RETURN NULL;
	END IF;
	CLOSE c_api_pit;
	RETURN v_tac_id; -- This is a VARCHAR2
EXCEPTION
	WHEN OTHERS THEN
		IF (c_api_pit%ISOPEN) THEN
			CLOSE c_api_pit;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_get_tac_api');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_tac_api;

FUNCTION Admp_Get_Tac_Ceprc(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_admission_cat IN OUT NOCOPY VARCHAR2 ,
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_version_number OUT NOCOPY NUMBER ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_location_cd OUT NOCOPY VARCHAR2 ,
  p_attendance_mode OUT NOCOPY VARCHAR2 ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_unit_set_cd OUT NOCOPY VARCHAR2 ,
  p_us_version_number OUT NOCOPY NUMBER ,
  p_coo_id OUT NOCOPY NUMBER ,
  p_ref_cd_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_tac_ceprc
	-- This module gets course offering option details from the
	-- course entry point reference code table.
DECLARE
	v_course_cd		IGS_PS_ENT_PT_REF_CD.course_cd%TYPE;
	v_version_number	IGS_PS_ENT_PT_REF_CD.version_number%TYPE;
	v_cal_type		IGS_PS_ENT_PT_REF_CD.cal_type%TYPE;
	v_location_cd	IGS_PS_ENT_PT_REF_CD.location_cd%TYPE;
	v_attendance_mode	IGS_PS_ENT_PT_REF_CD.attendance_mode%TYPE;
	v_attendance_type	IGS_PS_ENT_PT_REF_CD.attendance_type%TYPE;
	v_coo_id		IGS_PS_ENT_PT_REF_CD.coo_id%TYPE;
	v_ref_cd_type	IGS_GE_REF_CD_TYPE.reference_cd_type%TYPE;
	v_unit_set_cd 	IGS_EN_UNIT_SET.unit_set_cd%TYPE;
  	v_us_version_number 	IGS_EN_UNIT_SET.version_number%TYPE;
    v_message_name  varchar2(30);
	cst_active		CONSTANT	VARCHAR2(10) := 'ACTIVE';
	CURSOR	c_ceprc IS
		SELECT 	ceprc.course_cd,
			ceprc.version_number,
			ceprc.cal_type,
			ceprc.location_cd,
			ceprc.attendance_mode,
			ceprc.attendance_type,
			ceprc.coo_id,
			rct.s_reference_cd_type,
			ceprc.unit_set_cd,
			ceprc.us_version_number
		FROM 	IGS_PS_ENT_PT_REF_CD 	ceprc,
			IGS_GE_REF_CD_TYPE 	rct,
			IGS_PS_VER			crv,
			IGS_PS_STAT			cs
		WHERE   rct.s_reference_cd_type = 'OTHER' AND
			ceprc.reference_cd_type = rct.reference_cd_type AND
			ceprc.reference_cd 	= p_reference_cd AND
			ceprc.cal_type 		= p_acad_cal_type AND
			crv.course_cd		= ceprc.course_cd AND
			crv.version_number	= ceprc.version_number AND
			crv.expiry_dt		IS NULL AND
			cs.course_status	      = crv.course_status AND
			cs.s_course_status	= cst_active AND
			(ceprc.unit_set_cd	IS NULL OR
				EXISTS (
					SELECT	'x'
					FROM	IGS_EN_UNIT_SET	us,
						IGS_EN_UNIT_SET_STAT	uss
					WHERE	us.unit_set_cd		= ceprc.unit_set_cd AND
						us.version_number	= ceprc.us_version_number AND
						expiry_dt		IS NULL AND
						uss.unit_set_status	= us.unit_set_status AND
						uss.s_unit_set_status	= cst_active));
BEGIN
	p_message_name := null;
	OPEN c_ceprc;
	LOOP
		FETCH c_ceprc INTO	v_course_cd,
				   	v_version_number,
					v_cal_type,
				  	v_location_cd,
					v_attendance_mode,
		          		v_attendance_type,
					v_coo_id,
					v_ref_cd_type,
					v_unit_set_cd,
					v_us_version_number;
		EXIT WHEN (c_ceprc%NOTFOUND);
		IF (c_ceprc%ROWCOUNT > 1) THEN
			exit;
		END IF;
	END LOOP;
	IF (c_ceprc%ROWCOUNT = 0) THEN
		p_message_name := 'IGS_GE_INVALID_VALUE';
		CLOSE c_ceprc;
		RETURN FALSE;
	ELSIF (c_ceprc%ROWCOUNT > 1) THEN
		p_message_name := 'IGS_AD_MULTIPLE_PRG_GOUND';
		CLOSE c_ceprc;
		RETURN FALSE;
	END IF;
	CLOSE c_ceprc;
	IF IGS_AD_PRC_TAC_OFFER.admp_get_ac_cooac(
						v_coo_id,
						p_admission_cat,
						v_message_name) = FALSE THEN
		p_message_name := v_message_name;

		RETURN FALSE;
	END IF;
	IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_admperd(
							p_adm_cal_type,
							p_adm_ci_sequence_number,
							p_admission_cat,
							'COURSE',
							v_course_cd,
							v_version_number,
							v_cal_type,
							v_location_cd,
							v_attendance_mode,
							v_attendance_type,
							v_message_name) = FALSE THEN
			p_message_name := v_message_name;
			RETURN FALSE;
	END IF;
	p_course_cd := v_course_cd;
	p_version_number := v_version_number;
	p_cal_type := v_cal_type;
	p_location_cd := v_location_cd;
	p_attendance_mode := v_attendance_mode;
	p_attendance_type := v_attendance_type;
	p_coo_id := v_coo_id;
	p_ref_cd_type := v_ref_cd_type;
	p_unit_set_cd := v_unit_set_cd;
	p_us_version_number := v_us_version_number;
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ceprc%ISOPEN) THEN
			CLOSE c_ceprc;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_get_tac_ceprc');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_tac_ceprc;

FUNCTION Admp_Get_Tac_Return(
  p_tac_person_id IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_given_name1 IN VARCHAR2 ,
  p_given_name2 IN VARCHAR2 ,
  p_tac_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_offer_response OUT NOCOPY VARCHAR2 ,
  p_enrol_status OUT NOCOPY VARCHAR2 ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_attendance_mode OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
	gv_other_detail		VARCHAR2(255);
BEGIN
	-- admp_get_tac_return
	-- This module takes information about a student from a TAC, attempts to find
	-- the student and reports details of their admission and enrolment.  If the
	-- TAC IGS_PS_COURSE code is NULL and no adm_crs_appl_ins record can be found then
	-- the process will return FALSE but the message name will be 0.  This is
	-- to show we didn't find the required information but this is not an error
	-- in this case..
DECLARE
	cst_intermit		CONSTANT	VARCHAR2(8) := 'INTERMIT';
	cst_accept		CONSTANT	VARCHAR2(10) := 'ACCEPT';
	cst_not_enrol		CONSTANT	VARCHAR2(10) := 'NOT-ENROL';
	cst_enrolled		CONSTANT	VARCHAR2(10) := 'ENROLLED';
	cst_dfr_grant		CONSTANT	VARCHAR2(10) := 'DFR-GRANT';
	cst_dfr_reject		CONSTANT	VARCHAR2(10) := 'DFR-REJECT';
	cst_rejected		CONSTANT	VARCHAR2(10) := 'REJECTED';
	cst_active		CONSTANT	VARCHAR2(10) := 'ACTIVE';
    v_message_name  varchar2(30);
	v_matched_id		IGS_PE_ALT_PERS_ID.pe_person_id%TYPE;
	v_given_names		IGS_PE_PERSON.given_names%TYPE;
	v_course_cd		IGS_PS_ENT_PT_REF_CD.course_cd%TYPE;
	v_version_number	IGS_PS_ENT_PT_REF_CD.version_number%TYPE;
	v_location_cd		IGS_PS_ENT_PT_REF_CD.location_cd%TYPE;
	v_attendance_mode	IGS_PS_ENT_PT_REF_CD.attendance_mode%TYPE;
	v_attendance_type	IGS_PS_ENT_PT_REF_CD.attendance_type%TYPE;
	v_adm_offer_resp_status		IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
	v_adm_offer_dfrmnt_status
				IGS_AD_OFRDFRMT_STAT.s_adm_offer_dfrmnt_status%TYPE;
	v_enrol_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
	v_tac_match		BOOLEAN;
	v_course_off_found	BOOLEAN;
	v_course_ins_found	BOOLEAN;
	CURSOR c_tac_id_api IS
		SELECT 	api.pe_person_id
		FROM	IGS_PE_ALT_PERS_ID	api,
			IGS_PE_PERSON_ID_TYP		pit
		WHERE	pit.s_person_id_type	= 'TAC' AND
			api.person_id_type	= pit.person_id_type AND
			api.api_person_id	= p_tac_person_id;
	CURSOR c_tac_id_pe(
		cp_given_names		VARCHAR2) IS
		SELECT 	party_id person_id
		FROM	hz_parties
		WHERE	person_last_name  = p_surname	AND
			person_first_name = cp_given_names;
	CURSOR c_course_offer IS
		SELECT 	ceprc.course_cd,
			ceprc.version_number,
			ceprc.location_cd,
			ceprc.attendance_mode,
			ceprc.attendance_type
		FROM 	IGS_PS_ENT_PT_REF_CD	ceprc,
			IGS_GE_REF_CD_TYPE		rct,
			IGS_PS_VER			crv,
			IGS_PS_STAT			cs
		WHERE	rct.s_reference_cd_type	= 'OTHER' AND
			ceprc.reference_cd_type	= rct.reference_cd_type	AND
			ceprc.reference_cd	= p_tac_course_cd AND
			crv.course_cd		= ceprc.course_cd AND
			crv.version_number	= ceprc.version_number AND
			crv.expiry_dt		IS NULL AND
			cs.course_status  	= crv.course_status AND
			cs.s_course_status	= cst_active AND
			(ceprc.unit_set_cd	IS NULL OR
				EXISTS (
					SELECT	'x'
					FROM	IGS_EN_UNIT_SET	us,
						IGS_EN_UNIT_SET_STAT	uss
					WHERE	us.unit_set_cd		= ceprc.unit_set_cd AND
						us.version_number	= ceprc.us_version_number AND
						expiry_dt		IS NULL AND
						uss.unit_set_status	= us.unit_set_status AND
						uss.s_unit_set_status	= cst_active))
		ORDER BY rct.s_reference_cd_type DESC;
	CURSOR c_course_ins_1(
		cp_matched_id		IGS_PE_ALT_PERS_ID.pe_person_id%TYPE,
		cp_course_cd		IGS_PS_ENT_PT_REF_CD.course_cd%TYPE,
		cp_version_number	IGS_PS_ENT_PT_REF_CD.version_number%TYPE,
		cp_location_cd		IGS_PS_ENT_PT_REF_CD.location_cd%TYPE,
		cp_attendance_mode	IGS_PS_ENT_PT_REF_CD.attendance_mode%TYPE,
		cp_attendance_type	IGS_PS_ENT_PT_REF_CD.attendance_type%TYPE) IS
		SELECT	aors.s_adm_offer_resp_status,
			aods.s_adm_offer_dfrmnt_status
		FROM	igs_ad_appl aa,
		        igs_ad_ps_appl_inst	acaiv,  /* Replaced IGS_AD_PS_APPL_INST_APLINST_V with IGS_AD_PS_APPL_INST. Bug 3150054 */
			igs_ad_ofr_resp_stat	aors,
			igs_ad_ofrdfrmt_stat	aods
		WHERE	acaiv.person_id		= cp_matched_id		AND
			aa.acad_cal_type	= p_acad_cal_type	AND
			aa.acad_ci_sequence_number = p_acad_ci_sequence_number AND
			acaiv.course_cd		= cp_course_cd		AND
			acaiv.crv_version_number	= cp_version_number	AND
			acaiv.location_cd	= cp_location_cd	AND
			acaiv.attendance_mode	= cp_attendance_mode	AND
			acaiv.attendance_type	= cp_attendance_type	AND
			aors.adm_offer_resp_status = acaiv.adm_offer_resp_status AND
			aods.adm_offer_dfrmnt_status = acaiv.adm_offer_dfrmnt_status AND
			aa.person_id = acaiv.person_id AND
			aa.admission_appl_number = acaiv.admission_appl_number;

	CURSOR c_course_ins_2(
		cp_matched_id 		IGS_PE_ALT_PERS_ID.pe_person_id%TYPE) IS
		SELECT	aors.s_adm_offer_resp_status,
			aods.s_adm_offer_dfrmnt_status,
			acaiv.course_cd,
			ceprc.reference_cd
		FROM	igs_ad_appl aa,
		        IGS_AD_PS_APPL_INST	acaiv,   /* Replaced IGS_AD_PS_APPL_INST_APLINST_V with IGS_AD_PS_APPL_INST. Bug 3150054 */
			IGS_AD_OFR_RESP_STAT		aors,
			IGS_AD_OFRDFRMT_STAT		aods,
			IGS_PS_ENT_PT_REF_CD	ceprc,
			IGS_GE_REF_CD_TYPE		rct
		WHERE	acaiv.person_id			= cp_matched_id		AND
			aa.acad_cal_type		= p_acad_cal_type	AND
			aa.acad_ci_sequence_number	= p_acad_ci_sequence_number AND
			aods.adm_offer_dfrmnt_status 	= acaiv.adm_offer_dfrmnt_status AND
			aors.adm_offer_resp_status 	= acaiv.adm_offer_resp_status	AND
			ceprc.course_cd 		      = acaiv.course_cd	AND
			ceprc.version_number		= acaiv.crv_version_number	AND
			ceprc.location_cd		      = acaiv.location_cd	AND
			ceprc.attendance_mode		= acaiv.attendance_mode	AND
			ceprc.attendance_type		= acaiv.attendance_type	AND
			ceprc.reference_cd_type		= rct.reference_cd_type	AND
			rct.s_reference_cd_type  = 'OTHER' AND
			aa.person_id = acaiv.person_id AND
			aa.admission_appl_number = acaiv.admission_appl_number
		ORDER BY rct.s_reference_cd_type DESC;
	v_course_ins_rec_2	c_course_ins_2%ROWTYPE;
	CURSOR c_govt_value(
		cp_attendance_type	IGS_PS_ENT_PT_REF_CD.attendance_type%TYPE) IS
		SELECT 	govt_attendance_type
		FROM 	IGS_EN_ATD_TYPE
		WHERE	attendance_type = v_attendance_type;
	CURSOR c_attn_mode(
		cp_course_cd	IGS_PS_ENT_PT_REF_CD.course_cd%TYPE,
		cp_person_id	IGS_PE_ALT_PERS_ID.pe_person_id%TYPE) IS
		SELECT 	am.govt_attendance_mode
		FROM 	IGS_EN_STDNT_PS_ATT	sca,
			IGS_EN_ATD_MODE		am
		WHERE	sca.course_cd	= cp_course_cd	AND
			sca.person_id	= cp_person_id	AND
			am.attendance_mode = sca.attendance_mode;
BEGIN
	-- Set values for the output parameters.  These are the default values
	-- we want to pass back.
	p_offer_response := 'REJECTED';
	p_enrol_status := 'NOT-ENROL';
	p_attendance_type := NULL;
	p_attendance_mode := NULL;
    p_message_name := null;
    v_message_name := null;

	-- Find student by finding stored TAC ID number.
	v_tac_match := FALSE;
	FOR v_tac_id_rec IN c_tac_id_api LOOP
		v_tac_match := TRUE;
		IF (c_tac_id_api%ROWCOUNT >1) THEN
			v_message_name := 'IGS_AD_CANNOT_MATCH_PERSONID';
			v_tac_match := FALSE;
			exit;
		END IF;
		v_matched_id := v_tac_id_rec.pe_person_id;
	END LOOP;
	IF (v_tac_match = FALSE) THEN
		IF (v_message_name IS NULL) THEN
			-- No api records find. Try to match on other details
			v_given_names := RTRIM(p_given_name1 || ' ' || p_given_name2);
			FOR v_tac_id_rec IN c_tac_id_pe(
						v_given_names) LOOP
				v_tac_match := TRUE;
				IF (c_tac_id_pe%ROWCOUNT > 1) THEN
					v_tac_match := FALSE;
					exit;
				END IF;
				v_matched_id := v_tac_id_rec.person_id;
			END LOOP;
			IF (v_tac_match = FALSE) THEN
				-- No match or more than one record found in IGS_PE_PERSON
				p_message_name := 'IGS_AD_CANNOT_MATCH_PERSONID';
				RETURN FALSE;
			END IF;
		ELSE
			-- More than one api records found
			p_message_name := v_message_name;
			RETURN FALSE;
		END IF;
	END IF;
	IF (p_tac_course_cd IS NOT NULL) THEN
		-- Find the course offering option from the TAC course code.
		v_course_off_found := FALSE;
		FOR v_course_off_rec IN c_course_offer LOOP
			v_course_off_found := TRUE;
			IF (c_course_offer%ROWCOUNT > 1) THEN
				v_course_off_found := FALSE;
				v_message_name := 'IGS_AD_FOUNDMULTIPLE_PRGREFCD';
				exit;
			END IF;
			v_course_cd	 := v_course_off_rec.course_cd;
			v_version_number := v_course_off_rec.version_number;
			v_location_cd	 := v_course_off_rec.location_cd;
			v_attendance_mode := v_course_off_rec.attendance_mode;
			v_attendance_type := v_course_off_rec.attendance_type;
		END LOOP;
		IF (v_course_off_found = FALSE) THEN
			IF (v_message_name IS NULL) THEN
				-- No IGS_PS_COURSE offering option records found.
				p_message_name := 'IGS_AD_CANNOT_MATCH_TACPRGCD';
				RETURN FALSE;
			ELSE
				-- More than one IGS_PS_COURSE offering option recores found.
				p_message_name := v_message_name;
				RETURN FALSE;
			END IF;
		END IF;
		-- Find the IGS_AD_PS_APPL_INST.
		v_course_ins_found := FALSE;
		FOR v_course_ins_rec_1 IN c_course_ins_1(
						v_matched_id,
						v_course_cd,
						v_version_number,
						v_location_cd,
						v_attendance_mode,
						v_attendance_type) LOOP
			v_course_ins_found := TRUE;
			IF (c_course_ins_1%ROWCOUNT > 1) THEN
				v_course_ins_found := FALSE;
				v_message_name := 'IGS_AD_FOUND_MULTIPLE_ADMPRG';
				exit;
			END IF;
			v_adm_offer_resp_status := v_course_ins_rec_1.s_adm_offer_resp_status;
			v_adm_offer_dfrmnt_status := v_course_ins_rec_1.s_adm_offer_dfrmnt_status;
		END LOOP;
		IF (v_course_ins_found = FALSE) THEN
			IF (v_message_name IS NULL) THEN
				-- No IGS_AD_PS_APPL_INST records found.
				p_message_name := 'IGS_AD_CANNOT_FIND_ADMPRGAPPL';
				RETURN FALSE;
			ELSE
				-- More than one adm_course_appl_instanc recores found.
				p_message_name := v_message_name;
				RETURN FALSE;
			END IF;
		END IF;
	ELSE -- No TAC IGS_PS_COURSE code supplied
		-- Find the IGS_AD_PS_APPL_INST
		OPEN c_course_ins_2(
			v_matched_id);
		FETCH c_course_ins_2 INTO v_course_ins_rec_2;
		IF (c_course_ins_2%NOTFOUND) THEN
			-- This is not an error but will still want to return FALSE.
			CLOSE c_course_ins_2;
    		p_message_name := null;
			RETURN FALSE;
		END IF;
		CLOSE c_course_ins_2;
		-- If more than one record is found, just use the first record.
		p_tac_course_cd := v_course_ins_rec_2.reference_cd;
	END IF; -- IF (p_tac_course_cd IS NOT NULL)
	IF (v_adm_offer_resp_status IN ('ACCEPTED', 'COND-ACC', 'PEND-ACC')) THEN
		v_enrol_status := IGS_EN_GEN_006.enrp_get_sca_status(
					v_matched_id,
					v_course_cd,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL,
					NULL);
		IF (v_enrol_status IN ('DELETED','UNCONFIRM','LAPSED','INACTIVE',NULL)) THEN
			p_offer_response := cst_accept;
			p_enrol_status := cst_not_enrol;
			RETURN TRUE;
		ELSIF (v_enrol_status IN ('DISCONTIN', cst_intermit)) THEN
			p_offer_response := cst_accept;
			p_enrol_status := v_enrol_status;
			-- Find Attendance Type as may be late withdrawl
			v_attendance_type := IGS_EN_GEN_006.enrp_get_sca_att(
							v_matched_id,
							v_course_cd,
							SYSDATE);
			IF (v_attendance_type IS NULL) THEN
				p_attendance_type := 0;
			ELSE
				-- Get the Govt. value
				OPEN c_govt_value(
					v_attendance_type);
				FETCH c_govt_value INTO p_attendance_type;
				CLOSE c_govt_value;
				-- Find Attendance mode
				OPEN c_attn_mode(
					v_course_cd,
					v_matched_id);
				FETCH c_attn_mode INTO p_attendance_mode;
				CLOSE c_attn_mode;
			END IF;
			RETURN TRUE;
		ELSE
			-- Find Attendance Type
			v_attendance_type := IGS_EN_GEN_006.enrp_get_sca_att(
							v_matched_id,
							v_course_cd,
							SYSDATE);
			IF (v_attendance_type IS NULL) THEN
	    		p_message_name := 'IGS_AD_NO_ATTTYPE_STUDPRG';
				RETURN FALSE;
			END IF;
			-- Get the Govt. value
			OPEN c_govt_value(
				v_attendance_type);
			FETCH c_govt_value INTO p_attendance_type;
			CLOSE c_govt_value;
			-- Find Attendance mode
			OPEN c_attn_mode(
				v_course_cd,
				v_matched_id);
			FETCH c_attn_mode INTO p_attendance_mode;
			CLOSE c_attn_mode;
			p_offer_response := cst_accept;
			p_enrol_status := cst_enrolled;
			RETURN TRUE;
		END IF; -- if (v_enrol_status = cst_intermit)
	ELSIF (v_adm_offer_resp_status = 'DEFERRAL') THEN
		IF (v_adm_offer_dfrmnt_status = 'APPROVED') THEN
			p_offer_response := cst_dfr_grant;
		ELSE
			p_offer_response := cst_dfr_reject;
		END IF;
	ELSE
		p_offer_response := cst_rejected;
		p_enrol_status := cst_not_enrol;
	END IF; -- if v_adm_offer_resp_status IN ('ACCEPTED', 'COND-ACC', 'PEND-ACC')
	RETURN TRUE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_get_tac_return');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_tac_return;

FUNCTION Admp_Get_Unit_Det(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_record_number IN NUMBER )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_unit_det
	-- This module retrieves IGS_PS_UNIT details from IGS_AD_PS_APPL_INST
	-- for use on letters.
DECLARE
	v_out_string			VARCHAR2(200)	DEFAULT NULL;
	v_comm_period			VARCHAR2(21)	DEFAULT NULL;
	v_acad_alternate_code		IGS_AD_APPL_ADMAPPL_V.acad_alternate_code%TYPE;
	CURSOR c_uv_acaiuv IS
		SELECT	acaiuv.unit_cd,
			acaiuv.uv_version_number,
			acaiuv.location_cd,
			acaiuv.unit_class,
			acaiuv.unit_mode,
			acaiuv.teach_alternate_code,
			uv.short_title,
			acaiuv.adm_unit_outcome_status
		FROM	IGS_AD_PS_APLINSTUNT_APLUNIT_V	acaiuv,
			IGS_PS_UNIT_VER			uv
		WHERE	acaiuv.uv_version_number	= uv.version_number	AND
			acaiuv.unit_cd			= uv.unit_cd		AND
			acaiuv.person_id		      = p_person_id		AND
			acaiuv.admission_appl_number	= p_admission_appl_number AND
			acaiuv.nominated_course_cd	= p_nominated_course_cd	AND
			acaiuv.acai_sequence_number	= p_acai_sequence_number
		ORDER BY acaiuv.unit_cd,
			acaiuv.uv_version_number,
			acaiuv.cal_type,
			acaiuv.ci_sequence_number,
			acaiuv.location_cd,
			acaiuv.unit_class,
			acaiuv.unit_mode;
	CURSOR c_aav IS
		SELECT	ca.alternate_code acad_alternate_code /* Replace IGS_AD_APPL_ADMAPPL_V with IGS_AD_APPL and IGS_CA_INST tables Bug: 3150054 */
		FROM	igs_ad_appl	aav,
		        igs_ca_inst ca
		WHERE	aav.person_id			= p_person_id		AND
			aav.admission_appl_number	= p_admission_appl_number AND
			aav.acad_cal_type               = ca.cal_type AND
			aav.acad_ci_sequence_number     = ca.sequence_number;
BEGIN
	FOR v_uv_acaiuv_rec IN c_uv_acaiuv LOOP
		IF c_uv_acaiuv%ROWCOUNT = p_record_number THEN
			-- create output return string and create p_extra_context string
			OPEN c_aav;
			FETCH c_aav INTO v_acad_alternate_code;
			IF c_aav%NOTFOUND THEN
				v_comm_period := '-';
			ELSE
				v_comm_period := NVL(v_acad_alternate_code, '-') || '/' ||
						 NVL(v_uv_acaiuv_rec.teach_alternate_code, '-');
			END IF;
			CLOSE c_aav;
			v_out_string :=	RPAD(NVL(v_uv_acaiuv_rec.unit_cd, '-'), 10)	|| '	' ||
					RPAD(NVL(v_uv_acaiuv_rec.short_title, '-'), 40)	|| '	' ||
					RPAD(NVL(v_uv_acaiuv_rec.location_cd, '-'), 10)	|| '	' ||
					RPAD(NVL(v_uv_acaiuv_rec.unit_mode, '-'), 10)	|| '	' ||
					RPAD(NVL(v_uv_acaiuv_rec.unit_class, '-'), 10)	|| '	' ||
					v_comm_period ||'	'||
					RPAD(NVL(v_uv_acaiuv_rec.adm_unit_outcome_status, '-'),10);
		END IF;
	END LOOP;
	RETURN v_out_string;
EXCEPTION
	WHEN OTHERS THEN
		IF c_uv_acaiuv%ISOPEN THEN
			CLOSE c_uv_acaiuv;
		END IF;
		IF c_aav%ISOPEN THEN
			CLOSE c_aav;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_get_unit_det');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_unit_det;

FUNCTION Admp_Ins_Aal(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_ins_aal
	-- This module validates and inserts a record into the IGS_AD_APPL_LTR
	--  table
DECLARE
	v_sequence_num		IGS_AD_APPL_LTR.sequence_number%TYPE;
    v_message_name  varchar2(30);
      lv_rowid 			VARCHAR2(25);



	-- Derive the next sequence number
	CURSOR c_aal IS
		SELECT NVL(MAX(sequence_number),0) + 1
		FROM	IGS_AD_APPL_LTR
		WHERE	person_id 		= p_person_id AND
			admission_appl_number 	= p_admission_appl_number AND
			correspondence_type	= p_correspondence_type;
BEGIN
    p_message_name := null;
	-- Validate correspondence type for admission process category
	IF IGS_AD_VAL_AAL.admp_val_aal_cort(
				p_correspondence_type,
				p_admission_cat,
				p_s_admission_process_type,
				v_message_name) = FALSE THEN
		p_message_name := v_message_name;
		RETURN FALSE;
	END IF;
	-- Validate correspondence type not closed
	IF IGS_AD_VAL_AAL.corp_val_cort_closed(
					p_correspondence_type,
					v_message_name) = FALSE THEN
		p_message_name := v_message_name;
		RETURN FALSE;
	END IF;
	-- Validate that an unsent letter with this correspondence type does not
	-- already exist.
	IF IGS_AD_VAL_AAL.admp_val_aal_exists(
					p_person_id,
					p_admission_appl_number,
					p_correspondence_type,
					v_message_name) = FALSE THEN
		p_message_name := v_message_name;
		RETURN FALSE;
	END IF;
	OPEN c_aal;
	FETCH c_aal INTO v_sequence_num;
	CLOSE c_aal;
	-- Insert new record
   	IGS_AD_APPL_Ltr_Pkg.Insert_Row (
      	X_Mode                              => 'R',
      	X_RowId                             => lv_rowid,
      	X_Person_Id                         => p_person_id,
      	X_Admission_Appl_Number             => p_admission_appl_number,
      	X_Correspondence_Type               => p_correspondence_type,
      	X_Sequence_Number                   => v_sequence_num,
      	X_Composed_Ind                      => 'Y',
      	X_Letter_Reference_Number           => Null,
      	X_Spl_Sequence_Number               => Null
   	);


	RETURN TRUE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_ins_aal');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_ins_aal;

FUNCTION Admp_Ins_Aal_Commit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_ins_aal_commit
	-- This module calls admp_ins_aal and performs a commit.
DECLARE
	v_message_name  varchar2(30);
BEGIN
	p_message_name := null;
	IF admp_ins_aal (
			p_person_id,
			p_admission_appl_number,
			p_correspondence_type,
			p_admission_cat,
			p_s_admission_process_type,
			v_message_name) = FALSE THEN
		p_message_name := v_message_name;
		RETURN FALSE;
	END IF;
	COMMIT;
	RETURN TRUE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_ins_aal_commit');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_ins_aal_commit;

PROCEDURE Admp_Ins_Aa_Hist(
  p_person_id IN IGS_AD_APPL_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_new_appl_dt IN IGS_AD_APPL_ALL.appl_dt%TYPE ,
  p_old_appl_dt IN IGS_AD_APPL_ALL.appl_dt%TYPE ,
  p_new_acad_cal_type IN IGS_AD_APPL_ALL.acad_cal_type%TYPE ,
  p_old_acad_cal_type IN IGS_AD_APPL_ALL.acad_cal_type%TYPE ,
  p_new_acad_ci_sequence_number IN NUMBER ,
  p_old_acad_ci_sequence_number IN NUMBER ,
  p_new_adm_cal_type IN IGS_AD_APPL_ALL.adm_cal_type%TYPE ,
  p_old_adm_cal_type IN IGS_AD_APPL_ALL.adm_cal_type%TYPE ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_admission_cat IN IGS_AD_APPL_ALL.admission_cat%TYPE ,
  p_old_admission_cat IN IGS_AD_APPL_ALL.admission_cat%TYPE ,
  p_new_s_admission_process_type IN VARCHAR2 ,
  p_old_s_admission_process_type IN VARCHAR2 ,
  p_new_adm_appl_status IN IGS_AD_APPL_ALL.adm_appl_status%TYPE ,
  p_old_adm_appl_status IN IGS_AD_APPL_ALL.adm_appl_status%TYPE ,
  p_new_adm_fee_status IN IGS_AD_APPL_ALL.adm_fee_status%TYPE ,
  p_old_adm_fee_status IN IGS_AD_APPL_ALL.adm_fee_status%TYPE ,
  p_new_tac_appl_ind IN IGS_AD_APPL_ALL.tac_appl_ind%TYPE ,
  p_old_tac_appl_ind IN IGS_AD_APPL_ALL.tac_appl_ind%TYPE ,
  p_new_update_who IN IGS_AD_APPL_ALL.last_updated_by%TYPE ,
  p_old_update_who IN IGS_AD_APPL_ALL.last_updated_by%TYPE ,
  p_new_update_on IN IGS_AD_APPL_ALL.last_update_date%TYPE ,
  p_old_update_on IN IGS_AD_APPL_ALL.last_update_date%TYPE )
IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_ins_aa_hist
	-- Create a history for an IGS_AD_APPL record
DECLARE
	v_aah_rec		IGS_AD_APPL_HIST%ROWTYPE;
	v_create_history	BOOLEAN := FALSE;
        lv_rowid 		VARCHAR2(25);
      	l_org_id		NUMBER(15);

BEGIN
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF  p_new_appl_dt <> p_old_appl_dt THEN
		v_aah_rec.appl_dt := p_old_appl_dt;
		v_create_history := TRUE;
	END IF;
	IF  p_new_acad_cal_type <>  p_old_acad_cal_type THEN
		v_aah_rec.acad_cal_type := p_old_acad_cal_type;
		v_create_history := TRUE;
	END IF;
	IF  p_new_acad_ci_sequence_number <>  p_old_acad_ci_sequence_number THEN
		v_aah_rec.acad_ci_sequence_number := p_old_acad_ci_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF  p_new_adm_cal_type <>  p_old_adm_cal_type THEN
		v_aah_rec.adm_cal_type := p_old_adm_cal_type;
		v_create_history := TRUE;
	END IF;
	IF  p_new_adm_ci_sequence_number <>  p_old_adm_ci_sequence_number THEN
		v_aah_rec.adm_ci_sequence_number := p_old_adm_ci_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF  p_new_admission_cat <> p_old_admission_cat THEN
		v_aah_rec.admission_cat := p_old_admission_cat;
		v_create_history := TRUE;
	END IF;
	IF  p_new_s_admission_process_type <> p_old_s_admission_process_type THEN
		v_aah_rec.s_admission_process_type := p_old_s_admission_process_type;
		v_create_history := TRUE;
	END IF;
	IF  p_new_adm_appl_status <> p_old_adm_appl_status THEN
		v_aah_rec.adm_appl_status := p_old_adm_appl_status;
		v_create_history := TRUE;
	END IF;
	IF  p_new_adm_fee_status <> p_old_adm_fee_status THEN
		v_aah_rec.adm_fee_status := p_old_adm_fee_status;
		v_create_history := TRUE;
	END IF;
	IF  p_new_tac_appl_ind <> p_old_tac_appl_ind THEN
		v_aah_rec.tac_appl_ind := p_old_tac_appl_ind;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		v_aah_rec.person_id 		:= p_person_id;
		v_aah_rec.admission_appl_number := p_admission_appl_number;
		v_aah_rec.hist_start_dt 	:= p_old_update_on;
		v_aah_rec.hist_end_dt 		:= p_new_update_on;
		v_aah_rec.hist_who 		:= p_old_update_who;
		l_org_id := igs_ge_gen_003.get_org_id;

    		IGS_AD_APPL_Hist_Pkg.Insert_Row (
      		X_Mode                              => 'R',
      		X_RowId                             => lv_rowid,
    		X_Person_Id                         => v_aah_rec.person_id,
      		X_Admission_Appl_Number             => v_aah_rec.admission_appl_number,
      		X_Hist_Start_Dt                     => v_aah_rec.hist_start_dt,
      		X_Hist_End_Dt                       => v_aah_rec.hist_end_dt,
      		X_Hist_Who                          => v_aah_rec.hist_who,
      		X_Appl_Dt                           => v_aah_rec.appl_dt,
      		X_Acad_Cal_Type                     => v_aah_rec.acad_cal_type,
      		X_Acad_Ci_Sequence_Number           => v_aah_rec.acad_ci_sequence_number,
      		X_Adm_Cal_Type                      => v_aah_rec.acad_cal_type,
      		X_Adm_Ci_Sequence_Number            => v_aah_rec.adm_ci_sequence_number,
      		X_Admission_Cat                     => v_aah_rec.admission_cat,
      		X_S_Admission_Process_Type          => v_aah_rec.s_admission_process_type,
      		X_Adm_Appl_Status                   => v_aah_rec.adm_appl_status,
      		X_Adm_Fee_Status                    => v_aah_rec.adm_fee_status,
      		X_Tac_Appl_Ind                      => v_aah_rec.tac_appl_ind,
      		X_Org_Id			    => l_org_id
    		);


	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_ins_aa_hist');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_ins_aa_hist;

PROCEDURE Admp_Ins_Acaiu_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_adm_ps_appl_inst_unit_id IN NUMBER ,
  p_new_uv_version_number IN NUMBER ,
  p_old_uv_version_number IN NUMBER ,
  p_new_cal_type IN VARCHAR2 ,
  p_old_cal_type IN VARCHAR2 ,
  p_new_ci_sequence_number IN NUMBER ,
  p_old_ci_sequence_number IN NUMBER ,
  p_new_location_cd IN VARCHAR2 ,
  p_old_location_cd IN VARCHAR2 ,
  p_new_unit_class IN VARCHAR2 ,
  p_old_unit_class IN VARCHAR2 ,
  p_new_unit_mode IN VARCHAR2 ,
  p_old_unit_mode IN VARCHAR2 ,
  p_new_adm_unit_outcome_status IN VARCHAR2 ,
  p_old_adm_unit_outcome_status IN VARCHAR2 ,
  p_new_ass_tracking_id IN NUMBER ,
  p_old_ass_tracking_id IN NUMBER ,
  p_new_rule_waived_dt IN DATE ,
  p_old_rule_waived_dt IN DATE ,
  p_new_rule_waived_person_id IN NUMBER ,
  p_old_rule_waived_person_id IN NUMBER ,
  p_new_sup_unit_cd IN VARCHAR2 ,
  p_old_sup_unit_cd IN VARCHAR2 ,
  p_new_sup_uv_version_number IN NUMBER ,
  p_old_sup_uv_version_number IN NUMBER ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE )
IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_ins_acaiu_hist
	-- Routine to create a history for the IGS_AD_PS_APLINSTUNT table.
DECLARE
	v_changed_flag		BOOLEAN DEFAULT FALSE;
	v_acaiuh_rec		IGS_AD_PS_APINTUNTHS%ROWTYPE;
      lv_rowid 			VARCHAR2(25);
      l_org_id			NUMBER(15);

BEGIN
	-- Check if any of the old IGS_AD_PS_APLINSTUNT values are different
	-- from the associated new IGS_AD_PS_APLINSTUNT values.

  -- Unit code and and version number are non-updateable fields
/*
  IF NVL(p_new_uv_version_number, -1) <> NVL(p_old_uv_version_number, -1) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.uv_version_number := p_old_uv_version_number;
	END IF;
*/
	IF NVL(p_new_cal_type, 'NULL') <> NVL(p_old_cal_type, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.cal_type := p_old_cal_type;
	END IF;
	IF NVL(p_new_ci_sequence_number, -1) <> NVL(p_old_ci_sequence_number, -1) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.ci_sequence_number := p_old_ci_sequence_number;
	END IF;
	IF NVL(p_new_location_cd, 'NULL') <> NVL(p_old_location_cd, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.location_cd := p_old_location_cd;
	END IF;
	IF NVL(p_new_unit_class, 'NULL') <> NVL(p_old_unit_class, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.unit_class := p_old_unit_class;
	END IF;
	IF NVL(p_new_unit_mode, 'NULL') <> NVL(p_old_unit_mode, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.unit_mode := p_old_unit_mode;
	END IF;
	IF NVL(p_new_adm_unit_outcome_status, 'NULL') <>
			NVL(p_old_adm_unit_outcome_status, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.adm_unit_outcome_status := p_old_adm_unit_outcome_status;
	END IF;
	IF NVL(p_new_ass_tracking_id, -1 ) <> NVL(p_old_ass_tracking_id, -1) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.ass_tracking_id := p_old_ass_tracking_id;
	END IF;
	IF p_new_rule_waived_dt <> p_old_rule_waived_dt		OR
			(p_new_rule_waived_dt IS NULL		AND
			 p_old_rule_waived_dt IS NOT NULL)	OR
			(p_new_rule_waived_dt IS NOT NULL 	AND
			 p_old_rule_waived_dt IS NULL) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.rule_waived_dt := p_old_rule_waived_dt;
	END IF;
	IF NVL(p_new_rule_waived_person_id, -1 ) <>
			NVL(p_old_rule_waived_person_id, -1) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.rule_waived_person_id := p_old_rule_waived_person_id;
	END IF;
	IF NVL(p_new_sup_unit_cd, 'NULL' ) <> NVL(p_old_sup_unit_cd, 'NULL') THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.sup_unit_cd := p_old_sup_unit_cd;
	END IF;
	IF NVL(p_new_sup_uv_version_number, -1 ) <>
			NVL(p_old_sup_uv_version_number, -1) THEN
		v_changed_flag := TRUE;
		v_acaiuh_rec.sup_uv_version_number := p_old_sup_uv_version_number;
	END IF;
	IF v_changed_flag = TRUE THEN
		-- insert into history table
		-- set the mandatory columns
		v_acaiuh_rec.person_id := p_person_id;
		v_acaiuh_rec.admission_appl_number := p_admission_appl_number;
		v_acaiuh_rec.nominated_course_cd := p_nominated_course_cd;
		v_acaiuh_rec.acai_sequence_number := p_acai_sequence_number;
		v_acaiuh_rec.unit_cd := p_unit_cd;
    -- Unit code and and version number are non-updateable fields
 		v_acaiuh_rec.uv_version_number := p_old_uv_version_number;
		v_acaiuh_rec.adm_ps_appl_inst_unit_id := p_adm_ps_appl_inst_unit_id;
		v_acaiuh_rec.hist_start_dt := p_old_update_on;
		v_acaiuh_rec.hist_end_dt := p_new_update_on;
		v_acaiuh_rec.hist_who := p_old_update_who;
		l_org_id := igs_ge_gen_003.get_org_id;

    		IGS_AD_PS_APINTUNTHS_Pkg.Insert_Row (
      		X_Mode                              => 'R',
      		X_RowId                             => lv_rowid,
      		X_Person_Id                         => v_acaiuh_rec.person_id,
      		X_Admission_Appl_Number             => v_acaiuh_rec.admission_appl_number,
      		X_Nominated_Course_Cd               => v_acaiuh_rec.nominated_course_cd,
      		X_Acai_Sequence_Number              => v_acaiuh_rec.acai_sequence_number,
      		X_Unit_Cd                           => v_acaiuh_rec.unit_cd,
      		X_Hist_Start_Dt                     => v_acaiuh_rec.hist_start_dt,
      		X_Hist_End_Dt                       => v_acaiuh_rec.hist_end_dt,
      		X_Hist_Who                          => v_acaiuh_rec.hist_who,
      		X_Uv_Version_Number                 => v_acaiuh_rec.uv_version_number,
      		X_Cal_Type                          => v_acaiuh_rec.cal_type,
      		X_Ci_Sequence_Number                => v_acaiuh_rec.ci_sequence_number,
      		X_Location_Cd                       => v_acaiuh_rec.location_cd,
      		X_Unit_Class                        => v_acaiuh_rec.unit_class,
      		X_Unit_Mode                         => v_acaiuh_rec.unit_mode,
      		X_Adm_Unit_Outcome_Status           => v_acaiuh_rec.adm_unit_outcome_status,
      		X_Ass_Tracking_Id                   => v_acaiuh_rec.ass_tracking_id,
      		X_Rule_Waived_Dt                    => v_acaiuh_rec.rule_waived_dt,
      		X_Rule_Waived_Person_Id             => v_acaiuh_rec.rule_waived_person_id,
      		X_Sup_Unit_Cd                       => v_acaiuh_rec.sup_unit_cd,
      		X_Sup_Uv_Version_Number             => v_acaiuh_rec.sup_uv_version_number,
      		X_Org_Id			                      => l_org_id,
          X_adm_ps_appl_inst_unit_id          => v_acaiuh_rec.adm_ps_appl_inst_unit_id,
          X_adm_ps_appl_inst_unithist_id      => v_acaiuh_rec.adm_ps_appl_inst_unit_hist_id
    		);

	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_010.admp_ins_acaiu_hist');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_ins_acaiu_hist;

END igs_ad_gen_010;

/
