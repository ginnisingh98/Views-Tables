--------------------------------------------------------
--  DDL for Package Body IGS_ST_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GEN_002" AS
/* $Header: IGSST02B.pls 115.7 2003/05/09 14:09:40 sarakshi ship $ */

/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sarakshi       06-May-2003     Enh#2858431,modified procedure stap_get_crs_study replaced CRSOFSTUDY to OTHER
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified P_GOVT_PRIOR_UG_INST from NUMBER to VARCHAR2 in STAP_GET_PERSON_DATA. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
*/

Function Stap_Get_Course_Lvl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_govt_course_type IN NUMBER )
RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_course_lvl
	-- Routine to return the level of a course.
	-- If the level cannot be determined a null value is returned.
	-- This routine will eventually be replaced with an level field
	-- on the course_type table.
DECLARE
	v_govt_course_type		IGS_PS_TYPE.govt_course_type%TYPE;
	CURSOR c_cty IS
		SELECT	cty.govt_course_type
		FROM	IGS_PS_VER 	cv,
			IGS_PS_TYPE 	cty
		WHERE	cv.course_cd		= p_course_cd AND
			cv.version_number	= p_version_number AND
			cty.course_type		= cv.course_type;
BEGIN
	--- Determine the Government course Type.
	IF p_govt_course_type IS NULL THEN
		OPEN c_cty;
		FETCH c_cty INTO v_govt_course_type;
		IF c_cty%NOTFOUND THEN
			CLOSE c_cty;
			RETURN NULL;
		END IF;
		CLOSE c_cty;
	ELSE
		v_govt_course_type := p_govt_course_type;
	END IF;
	IF v_govt_course_type = 01 THEN
		RETURN 130;
	ELSIF v_govt_course_type IN (
				02,
				12) THEN
		RETURN 120;
	ELSIF v_govt_course_type = 03 THEN
		RETURN 110;
	ELSIF v_govt_course_type = 04 THEN
		RETURN 100;
	ELSIF v_govt_course_type IN (
				05,
				06,
				07) THEN
		RETURN 90;
	ELSIF v_govt_course_type = 11 THEN
		RETURN 80;
	ELSIF v_govt_course_type = 08 THEN
		RETURN 70;
	ELSIF v_govt_course_type = 09 THEN
		RETURN 60;
	ELSIF v_govt_course_type = 10 THEN
		RETURN 50;
	ELSIF v_govt_course_type IN (
				20,
				13) THEN
		RETURN 40;
	ELSIF v_govt_course_type = 21 THEN
		RETURN 30;
	ELSIF v_govt_course_type = 22 THEN
		RETURN 20;
	ELSIF v_govt_course_type = 30 THEN
		RETURN 10;
	END IF;
	RETURN NULL;
END;
END stap_get_course_lvl;

Procedure Stap_Get_Crs_Study(
  p_course_cd  IGS_PS_VER_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_VER_ALL.version_number%TYPE ,
  p_reference_cd OUT NOCOPY IGS_PS_REF_CD.reference_cd%TYPE ,
  p_description OUT NOCOPY IGS_PS_VER_ALL.title%TYPE )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_crs_study
	-- This module returns the course of study code and
	-- course of study name if they exist,
	-- otherwise it returns the course code and course title
DECLARE
	CURSOR c_crfc_rct IS
		SELECT	crfc.reference_cd,
			crfc.description
		FROM	IGS_PS_REF_CD	crfc,
			IGS_GE_REF_CD_TYPE	rct
		WHERE	crfc.course_cd		= p_course_cd AND
			crfc.version_number	= p_version_number AND
			rct.reference_cd_type	= crfc.reference_cd_type AND
			rct.s_reference_cd_type	= 'OTHER' AND
			rct.closed_ind		= 'N';
	CURSOR c_crv IS
		SELECT	crv.title
		FROM	IGS_PS_VER	crv
		WHERE	crv.course_cd		= p_course_cd AND
			crv.version_number	= p_version_number;
BEGIN
	p_reference_cd := NULL;
	p_description := NULL;
	OPEN c_crfc_rct;
	FETCH c_crfc_rct INTO	p_reference_cd,
				p_description;
	IF c_crfc_rct%NOTFOUND THEN
		OPEN c_crv;
		FETCH c_crv INTO p_description;
		IF c_crv%FOUND THEN
			p_reference_cd := p_course_cd;
		END IF;
		CLOSE c_crv;
	END IF;
	CLOSE c_crfc_rct;
EXCEPTION
	WHEN OTHERS THEN
		IF c_crfc_rct%ISOPEN THEN
			CLOSE c_crfc_rct;
		END IF;
		IF c_crv%ISOPEN THEN
			CLOSE c_crv;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stap_get_crs_study');
		IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
END stap_get_crs_study;

Function Stap_Get_Govt_Ou_Cd(
  p_org_unit_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
	gv_other_detail		VARCHAR2(255);
	v_ret_val		VARCHAR2(3);
BEGIN	-- stap_get_govt_ou_cd
	-- Determine the 3 character code to be reported to DEETYA
DECLARE
BEGIN
	-- Validate input parameter
	IF (p_org_unit_cd IS NULL) THEN
		RETURN NULL;
	END IF;
	-- Determine the return organisational unit code
	IF (LENGTH(p_org_unit_cd) < 4) THEN
		v_ret_val := p_org_unit_cd;
	ELSE
		-- Return the 2nd, 3rd, 4th characters
		v_ret_val := SUBSTR(p_org_unit_cd, 2, 3);
	END IF;
	RETURN v_ret_val;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stap_get_govt_ou_cd');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_get_govt_ou_cd;

Function Stap_Get_Govt_Sem(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_teach_cal_type IN VARCHAR2 )
RETURN NUMBER AS
BEGIN
DECLARE
	v_other_detail		VARCHAR2(255);
	v_govt_sem		IGS_ST_GVTSEMLOAD_OV.govt_semester%TYPE;
	CURSOR	c_gslov IS
		SELECT 	gslov.govt_semester
		FROM	IGS_ST_GVTSEMLOAD_OV gslov
		WHERE	gslov.submission_yr      = p_submission_yr 	    AND
			gslov.submission_number  = p_submission_number 	    AND
			gslov.cal_type 	        = p_load_cal_type  	    AND
			gslov.ci_sequence_number = p_load_ci_sequence_number AND
			gslov.teach_cal_type 	= p_teach_cal_type;
	CURSOR	c_gslc IS
		SELECT 	gslc.govt_semester
		FROM	IGS_ST_GVTSEMLOAD_CA gslc
		WHERE	gslc.submission_yr      = p_submission_yr 	    AND
			gslc.submission_number  = p_submission_number 	    AND
			gslc.cal_type 	        = p_load_cal_type  	    AND
			gslc.ci_sequence_number = p_load_ci_sequence_number;
BEGIN
	-- This module gets the government semester for a load calendar
	-- instance or a load calendar structure (ie. load calendar instance
	-- and teaching calendar) for a specified government submission.
	-- If the government semester cannot be determined, a null value
	-- will be returned.
	-- get the government value from the IGS_ST_GVTSEMLOAD_OV
	-- table
	OPEN  c_gslov;
	FETCH c_gslov INTO v_govt_sem;
	-- check if a record has been found
	IF (c_gslov%FOUND) THEN
		CLOSE c_gslov;
		RETURN v_govt_sem;
	END IF;
	CLOSE c_gslov;
	-- get the government value from the IGS_ST_GVTSEMLOAD_CA
	-- table
	OPEN  c_gslc;
	FETCH c_gslc INTO v_govt_sem;
	-- check if a record has been found
	IF (c_gslc%FOUND) THEN
		CLOSE c_gslc;
		RETURN v_govt_sem;
	END IF;
	CLOSE c_gslc;
	-- return null when government value can't be
	-- determined
	RETURN NULL;
END;
END stap_get_govt_sem;

Function Stap_Get_New_Hgh_Edu(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_new_hgh_edu
	-- Derive the New To Higher Education value.
	-- DEETYA element 924
DECLARE
	v_ret_val	NUMBER(1) DEFAULT 1;
	v_prior_post_grad	IGS_PE_STATISTICS.prior_post_grad%TYPE;
	v_prior_degree		IGS_PE_STATISTICS.prior_degree%TYPE;
	v_prior_subdeg_notafe	IGS_PE_STATISTICS.prior_subdeg_notafe%TYPE;
	CURSOR c_ps IS
		SELECT	ps.prior_post_grad,
			ps.prior_degree,
			ps.prior_subdeg_notafe
		FROM	IGS_PE_STATISTICS	ps
		WHERE	ps.person_id 	= p_person_id AND
			TRUNC(ps.start_dt) <= TRUNC(SYSDATE) AND
			(ps.end_dt 	IS NULL OR
			TRUNC(ps.end_dt) >= TRUNC(SYSDATE))
		ORDER BY end_dt;
BEGIN
	IF p_commencing_student_ind = 'N' THEN
		-- not a commencing student
		RETURN v_ret_val;
	END IF;
	OPEN c_ps;
	FETCH c_ps INTO	v_prior_post_grad,
			v_prior_degree,
			v_prior_subdeg_notafe;
	IF c_ps%NOTFOUND THEN
		CLOSE c_ps;
		-- A commencing student but no information on prior higher
		-- education course
		RETURN 9;
	END IF;
	CLOSE c_ps;
	IF v_prior_post_grad = '100' AND
    			v_prior_degree = '100' AND
    			v_prior_subdeg_notafe = '100' THEN
		-- A commecing student who had never commenced
		-- a higher education course prior to the first
		-- enrolment in the current course
		v_ret_val := 2;
	ELSIF SUBSTR(v_prior_post_grad, 1, 1) = '3' OR
			SUBSTR(v_prior_degree, 1, 1) = '3' OR
			SUBSTR(v_prior_subdeg_notafe, 1, 1) = '3' THEN
		-- A commecing student who had commenced and complete
		-- all of the requirements of a higer education course
		-- prior to the first enrolment in the current course
		v_ret_val := 3;
	ELSIF SUBSTR(v_prior_post_grad, 1, 1) = '2' OR
		SUBSTR(v_prior_degree, 1, 1) = '2' OR
		SUBSTR(v_prior_subdeg_notafe, 1, 1) = '2' THEN
		-- A commecing student who had commenced but not
		-- completed all of the requirements of a higer
		-- education course prior to the
		-- first enrolment in the current course
		v_ret_val := 4;
	ELSE
		-- A commencing student but no information on
		-- prior higher education course
		v_ret_val := 9;
	END IF;
	RETURN v_ret_val;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stap_get_new_hgh_edu');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_get_new_hgh_edu;

Procedure Stap_Get_Pcc_Pe_Dtl(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_birth_dt OUT NOCOPY DATE ,
  p_sex OUT NOCOPY VARCHAR2 ,
  p_govt_aborig_torres_cd OUT NOCOPY NUMBER ,
  p_govt_citizenship_cd OUT NOCOPY NUMBER ,
  p_govt_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_yr_arrival OUT NOCOPY VARCHAR2 ,
  p_govt_home_language_cd OUT NOCOPY NUMBER )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_pcc_pe_dtl
	-- This module gets the person based details needed for the
	-- government statistics past course completions file.
DECLARE
	CURSOR c_pe IS
		SELECT	pe.birth_dt,
			pe.sex
		FROM	IGS_PE_PERSON		pe
		WHERE	pe.person_id	= p_person_id;
	CURSOR c_ps IS
		SELECT	ps.aborig_torres_cd,
			ps.citizenship_cd,
			ps.birth_country_cd,
			ps.yr_arrival,
			ps.home_language_cd
		FROM	IGS_PE_STATISTICS	ps
		WHERE	ps.person_id		= p_person_id AND
			TRUNC(ps.start_dt)	<= TRUNC(p_effective_dt)
		ORDER BY ps.start_dt DESC;
	v_aborig_torres_cd	IGS_PE_STATISTICS.aborig_torres_cd%TYPE;
	v_citizenship_cd	IGS_PE_STATISTICS.citizenship_cd%TYPE;
	v_birth_country_cd	IGS_PE_STATISTICS.birth_country_cd%TYPE;
	v_home_language_cd	IGS_PE_STATISTICS.home_language_cd%TYPE;
	CURSOR c_atc IS
		SELECT	atc.govt_aborig_torres_cd
		FROM	IGS_PE_ABORG_TORESCD	atc
		WHERE	atc.aborig_torres_cd	= v_aborig_torres_cd;
	CURSOR c_cic IS
		SELECT	cic.govt_citizenship_cd
		FROM	IGS_ST_CITIZENSHP_CD		cic
		WHERE	cic.citizenship_cd	= v_citizenship_cd;
	CURSOR c_cnc IS
		SELECT	cnc.govt_country_cd
		FROM	IGS_PE_COUNTRY_CD	cnc
		WHERE	cnc.country_cd	= v_birth_country_cd;
	CURSOR c_lc IS
		SELECT	lc.govt_language_cd
		FROM	IGS_PE_LANGUAGE_CD	lc
		WHERE	lc.language_cd	= v_home_language_cd;
BEGIN
	OPEN c_pe;
	FETCH c_pe INTO	p_birth_dt,
			p_sex;
	IF c_pe%NOTFOUND THEN
		CLOSE c_pe;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c_pe;
	OPEN c_ps;
	FETCH c_ps INTO
			v_aborig_torres_cd,
			v_citizenship_cd,
			v_birth_country_cd,
			p_yr_arrival,
			v_home_language_cd;
	IF c_ps%NOTFOUND THEN
		CLOSE c_ps;
		p_govt_aborig_torres_cd := 9;
		p_govt_citizenship_cd := 9;
		p_yr_arrival := 'A9';
		p_govt_birth_country_cd := '9999';
		p_govt_home_language_cd := 99;
		RETURN;
	ELSE
		CLOSE c_ps;
	END IF;
	OPEN c_atc;
	FETCH c_atc INTO p_govt_aborig_torres_cd;
	IF c_atc%NOTFOUND THEN
		CLOSE c_atc;
		p_govt_aborig_torres_cd := 9;
	ELSE
		CLOSE c_atc;
	END IF;
	OPEN c_cic;
	FETCH c_cic INTO p_govt_citizenship_cd;
	IF c_cic%NOTFOUND THEN
		CLOSE c_cic;
		p_govt_citizenship_cd := 9;
	ELSE
		CLOSE c_cic;
	END IF;
	OPEN c_cnc;
	FETCH c_cnc INTO p_govt_birth_country_cd;
	IF c_cnc%NOTFOUND THEN
		CLOSE c_cnc;
		p_govt_birth_country_cd := v_birth_country_cd;
	ELSE
		CLOSE c_cnc;
	END IF;
	OPEN c_lc;
	FETCH c_lc INTO p_govt_home_language_cd;
	IF c_lc%NOTFOUND THEN
		CLOSE c_lc;
		p_govt_home_language_cd := TO_NUMBER(v_home_language_cd);
	ELSE
		CLOSE c_lc;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_pe%ISOPEN THEN
			CLOSE c_pe;
		END IF;
		IF c_ps%ISOPEN THEN
			CLOSE c_ps;
		END IF;
		IF c_atc%ISOPEN THEN
			CLOSE c_atc;
		END IF;
		IF c_cic%ISOPEN THEN
			CLOSE c_cic;
		END IF;
		IF c_cnc%ISOPEN THEN
			CLOSE c_cnc;
		END IF;
		IF c_lc%ISOPEN THEN
			CLOSE c_lc;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stap_get_pcc_pe_dtl');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_get_pcc_pe_dtl;

Procedure Stap_Get_Person_Data(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_logged_ind IN OUT NOCOPY BOOLEAN ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_birth_dt OUT NOCOPY DATE ,
  p_sex OUT NOCOPY VARCHAR2 ,
  p_aborig_torres_cd OUT NOCOPY VARCHAR2 ,
  p_govt_aborig_torres_cd OUT NOCOPY NUMBER ,
  p_citizenship_cd OUT NOCOPY VARCHAR2 ,
  p_govt_citizenship_cd OUT NOCOPY NUMBER ,
  p_perm_resident_cd OUT NOCOPY VARCHAR2 ,
  p_govt_perm_resident_cd OUT NOCOPY NUMBER ,
  p_home_location_cd OUT NOCOPY VARCHAR2 ,
  p_govt_home_location_cd OUT NOCOPY VARCHAR2 ,
  p_term_location_cd OUT NOCOPY VARCHAR2 ,
  p_govt_term_location_cd OUT NOCOPY VARCHAR2 ,
  p_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_govt_birth_country_cd OUT NOCOPY VARCHAR2 ,
  p_yr_arrival OUT NOCOPY VARCHAR2 ,
  p_home_language_cd OUT NOCOPY VARCHAR2 ,
  p_govt_home_language_cd OUT NOCOPY NUMBER ,
  p_prior_ug_inst OUT NOCOPY VARCHAR2 ,
  p_govt_prior_ug_inst OUT NOCOPY VARCHAR2 ,
  p_prior_other_qual OUT NOCOPY VARCHAR2 ,
  p_prior_post_grad OUT NOCOPY VARCHAR2 ,
  p_prior_degree OUT NOCOPY VARCHAR2 ,
  p_prior_subdeg_notafe OUT NOCOPY VARCHAR2 ,
  p_prior_subdeg_tafe OUT NOCOPY VARCHAR2 ,
  p_prior_seced_tafe OUT NOCOPY VARCHAR2 ,
  p_prior_seced_school OUT NOCOPY VARCHAR2 ,
  p_prior_tafe_award OUT NOCOPY VARCHAR2 ,
  p_govt_disability OUT NOCOPY VARCHAR2 )
AS
/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified GOVT_PRIOR_UG_INST from NUMBER to VARCHAR2. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
*/
	gv_other_detail			VARCHAR2(255);
BEGIN
DECLARE
	v_other_detail			VARCHAR2(255);
	v_citizenship_cd		IGS_ST_GOVT_STDNT_EN.citizenship_cd%TYPE;
	v_aborig_torres_cd		IGS_ST_GOVT_STDNT_EN.aborig_torres_cd%TYPE;
	v_birth_dt			IGS_PE_PERSON.birth_dt%TYPE;
	v_sex				IGS_PE_PERSON.sex%TYPE;
	v_govt_disability		CHAR(8);
	v_govt_aborig_torres_cd		IGS_ST_GOVT_STDNT_EN.govt_aborig_torres_cd%TYPE;
	v_govt_citizenship_cd		IGS_ST_GOVT_STDNT_EN.govt_citizenship_cd%TYPE;
	v_perm_resident_cd		IGS_ST_GOVT_STDNT_EN.perm_resident_cd%TYPE;
	v_govt_perm_resident_cd		IGS_ST_GOVT_STDNT_EN.govt_perm_resident_cd%TYPE;
	v_home_location			IGS_ST_GOVT_STDNT_EN.home_location%TYPE;
	v_govt_home_location		IGS_ST_GOVT_STDNT_EN.govt_home_location%TYPE;
	v_term_location			IGS_ST_GOVT_STDNT_EN.term_location%TYPE;
	v_govt_term_location		IGS_ST_GOVT_STDNT_EN.govt_term_location%TYPE;
	v_home_location_postcode	IGS_PE_STATISTICS.home_location_postcode%TYPE;
	v_home_location_country		IGS_PE_STATISTICS.home_location_country%TYPE;
	v_term_location_postcode	IGS_PE_STATISTICS.term_location_postcode%TYPE;
	v_term_location_country		IGS_PE_STATISTICS.term_location_country%TYPE;
	v_birth_country_cd		IGS_PE_STATISTICS.birth_country_cd%TYPE;
	v_govt_birth_country_cd		IGS_ST_GOVT_STDNT_EN.govt_birth_country_cd%TYPE;
	v_yr_arrival			IGS_ST_GOVT_STDNT_EN.yr_arrival%TYPE;
	v_home_language_cd		IGS_ST_GOVT_STDNT_EN.home_language_cd%TYPE;
	v_govt_home_language_cd		IGS_ST_GOVT_STDNT_EN.govt_home_language_cd%TYPE;
	v_prior_ug_inst			IGS_ST_GOVT_STDNT_EN.prior_ug_inst%TYPE;
	v_govt_prior_ug_inst		IGS_ST_GOVT_STDNT_EN.govt_prior_ug_inst%TYPE;
	v_prior_other_qual		IGS_ST_GOVT_STDNT_EN.prior_other_qual%TYPE;
	v_prior_post_grad		IGS_ST_GOVT_STDNT_EN.prior_post_grad%TYPE;
	v_prior_degree			IGS_ST_GOVT_STDNT_EN.prior_degree%TYPE;
	v_prior_subdeg_notafe		IGS_ST_GOVT_STDNT_EN.prior_subdeg_notafe%TYPE;
	v_prior_subdeg_tafe		IGS_ST_GOVT_STDNT_EN.prior_subdeg_tafe%TYPE;
	v_prior_seced_tafe		IGS_ST_GOVT_STDNT_EN.prior_seced_tafe%TYPE;
	v_prior_seced_school		IGS_ST_GOVT_STDNT_EN.prior_seced_school%TYPE;
	v_prior_tafe_award		IGS_ST_GOVT_STDNT_EN.prior_tafe_award%TYPE;
	v_course_cd			IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
	CURSOR  c_get_person_dtls IS
		SELECT	pe.birth_dt,
			pe.sex
		FROM	IGS_PE_PERSON pe
		WHERE	pe.person_id = p_person_id;
	CURSOR	c_prsn_stats IS
		SELECT	ps.aborig_torres_cd,
			ps.citizenship_cd,
			ps.perm_resident_cd,
			ps.home_location_postcode,
			ps.home_location_country,
			ps.term_location_postcode,
			ps.term_location_country,
			ps.birth_country_cd,
			ps.yr_arrival,
			ps.home_language_cd,
			ps.prior_ug_inst,
			ps.prior_other_qual,
			ps.prior_post_grad,
			ps.prior_degree,
			ps.prior_subdeg_notafe,
			ps.prior_subdeg_tafe,
			ps.prior_seced_tafe,
			ps.prior_seced_school,
			ps.prior_tafe_award
		FROM	IGS_PE_STATISTICS ps
		WHERE	ps.person_id = p_person_id AND
			ps.start_dt <= p_effective_dt AND
			(ps.end_dt IS NULL OR
		 	ps.end_dt >= p_effective_dt)
		ORDER BY ps.end_dt ASC;
	CURSOR 	c_aborig_tsi IS
		SELECT 	atcd.govt_aborig_torres_cd
		FROM   	IGS_PE_ABORG_TORESCD atcd
		WHERE	atcd.aborig_torres_cd = v_aborig_torres_cd;
	CURSOR  c_citz IS
		SELECT 	ccd.govt_citizenship_cd
		FROM   	IGS_ST_CITIZENSHP_CD ccd
		WHERE	ccd.citizenship_cd = v_citizenship_cd;
	CURSOR  c_perm_res (
			cp_perm_res_cd	IGS_PE_PERM_RES_CD.perm_resident_cd%TYPE) IS
		SELECT 	prcd.govt_perm_resident_cd
		FROM   	IGS_PE_PERM_RES_CD prcd
		WHERE	prcd.perm_resident_cd = cp_perm_res_cd;
	CURSOR  c_country_dtls (
			cp_country_cd	IGS_PE_COUNTRY_CD.country_cd%TYPE) IS
		SELECT 	ccd.govt_country_cd
		FROM	IGS_PE_COUNTRY_CD ccd
		WHERE	ccd.country_cd = cp_country_cd;
	CURSOR  c_language (
			cp_language_cd	IGS_PE_LANGUAGE_CD.language_cd%TYPE) IS
		SELECT 	lcd.govt_language_cd
		FROM	IGS_PE_LANGUAGE_CD lcd
		WHERE	lcd.language_cd = cp_language_cd;
	CURSOR  c_inst (
			cp_prior_ug_inst	IGS_OR_INSTITUTION.institution_cd%TYPE) IS
		SELECT 	inst.govt_institution_cd
		FROM	IGS_OR_INSTITUTION inst
		WHERE	inst.institution_cd = cp_prior_ug_inst;
	PROCEDURE stapl_ins_log_message(
		p_message_name	OUT NOCOPY VARCHAR2,
		p_logged_ind	IN OUT NOCOPY	BOOLEAN)
	AS
	BEGIN
	DECLARE
	BEGIN
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- Log an error to the IGS_GE_S_ERROR_LOG

               p_logged_ind := TRUE;
		END IF;
		-- Create an entry in the System Log Entry
		IGS_GE_GEN_003.genp_ins_log_entry(
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			p_message_name,
			NULL);
	END;
	EXCEPTION
		WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stapl_ins_log_message');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END stapl_ins_log_message;
BEGIN	-- this routine returns all the person details
	-- get the person data
	OPEN  c_get_person_dtls;
	FETCH c_get_person_dtls INTO	v_birth_dt,
					v_sex;
	-- raise an exception if no person record found
	IF (c_get_person_dtls%NOTFOUND) THEN
		CLOSE c_get_person_dtls;
		         Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		         IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		gv_other_detail := 'Parm:'
			|| ' p_person_id-'			|| TO_CHAR(p_person_id)
			|| ', p_effective_dt-' 			|| IGS_GE_DATE.igschar(p_effective_dt)
			|| ', p_commencing_student_ind-' 	|| p_commencing_student_ind
			|| ', p_s_log_type-' 			|| p_s_log_type
			|| ', p_creation_dt-' 			|| IGS_GE_DATE.igschardt(p_creation_dt)
			|| ', person Data not found for person '|| TO_CHAR(p_person_id);
	END IF;
	CLOSE c_get_person_dtls;
	IF (v_birth_dt IS NULL) THEN
		IF (p_logged_ind = FALSE) THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error
		      -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4194,
			NULL);
	END IF;
	IF (v_sex NOT IN('M','F')) THEN
		--Check if an entry has been written to the error log.
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

                 -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON,' || TO_CHAR(p_person_id),
			4195,
			NULL);
		--Continue processing this record after the error has been loged.
	END IF;
	-- retrieve the person disability
	v_govt_disability := IGS_ST_GEN_003.stap_get_prsn_dsblty(p_person_id);
	-- retrieve the person statistics data
	-- get the first record only, which will
	-- be the end dated record if one exists
	OPEN  c_prsn_stats;
	FETCH c_prsn_stats INTO v_aborig_torres_cd,
				v_citizenship_cd,
				v_perm_resident_cd,
				v_home_location_postcode,
				v_home_location_country,
				v_term_location_postcode,
				v_term_location_country,
				v_birth_country_cd,
				v_yr_arrival,
				v_home_language_cd,
				v_prior_ug_inst,
				v_prior_other_qual,
				v_prior_post_grad,
				v_prior_degree,
				v_prior_subdeg_notafe,
				v_prior_subdeg_tafe,
				v_prior_seced_tafe,
				v_prior_seced_school,
				v_prior_tafe_award;
	IF (c_prsn_stats%NOTFOUND) THEN
		CLOSE c_prsn_stats;
		-- Check if an entry has been written to the error log
		IF (p_logged_ind = FALSE) THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

                -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4196,
			NULL);
	ELSE
		CLOSE c_prsn_stats;
	END IF;
	-- re-set statistics values and set the government values
	-- Aboriginal / Torres Strait Islander code
	IF (v_aborig_torres_cd IS NOT NULL) THEN
		-- a record will always exist because of
		-- referential integrity
		OPEN  c_aborig_tsi;
		FETCH c_aborig_tsi INTO v_govt_aborig_torres_cd;
		CLOSE c_aborig_tsi;
		IF v_govt_aborig_torres_cd = 9 THEN
			-- Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				-- using IGS_GE_GEN_003.genp_log_error

                   -- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
				4197,
				NULL);
		END IF;
	ELSE
		v_aborig_torres_cd := '9';
		v_govt_aborig_torres_cd := 9;
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

            -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4197,
			NULL);
	END IF;
	-- citizenship code
	IF (v_citizenship_cd IS NOT NULL) THEN
		-- a record will always exist because of
		-- referential integrity
		OPEN  c_citz;
		FETCH c_citz INTO v_govt_citizenship_cd;
		CLOSE c_citz;
		IF v_govt_citizenship_cd = 9 THEN
			-- Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				-- using IGS_GE_GEN_003.genp_log_error

       	-- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
				4202,
				NULL);
		END IF;
	ELSE
		v_citizenship_cd := '9';
		v_govt_citizenship_cd := 9;
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

       	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4202,
			NULL);
	END IF;
	-- permanent resident code
	IF (v_perm_resident_cd IS NOT NULL) THEN
		-- a record will always exist because of
		-- referential integrity
		OPEN  c_perm_res(
			v_perm_resident_cd);
		FETCH c_perm_res INTO v_govt_perm_resident_cd;
		CLOSE c_perm_res;
	ELSE
		IF v_govt_citizenship_cd in (2, 3, 9) THEN
			v_perm_resident_cd := '9';
			v_govt_perm_resident_cd := 9;
			-- Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				-- using IGS_GE_GEN_003.genp_log_error

          	-- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
				4203,
				NULL);
		ELSE
			v_perm_resident_cd := '0';
			v_govt_perm_resident_cd := 0;
			-- Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
				4644,
				NULL);
		END IF;
	END IF;
	-- home location
	IF (v_home_location_postcode IS NOT NULL) THEN
		-- when a postcode is used, it must be 4 digits in
		-- length, therefore, left pad them with zeros to
		-- make them 4 digits long
		-- eg. 801 becomes 0801
		v_home_location := LPAD(TO_CHAR(v_home_location_postcode), 4, '0');
		v_govt_home_location := LPAD(TO_CHAR(v_home_location_postcode), 4, '0');
	ELSIF(v_home_location_country IS NOT NULL) THEN
		v_home_location := v_home_location_country;
		-- check if v_home_location_country exists on the
		-- country code table
		OPEN  c_country_dtls(
			v_home_location_country);
		FETCH c_country_dtls INTO v_govt_home_location;
		IF (c_country_dtls%NOTFOUND) THEN
			-- term location country is a DEETYA value
			v_govt_home_location := v_home_location_country;
		END IF;
		CLOSE c_country_dtls;
	ELSE
		v_home_location := '9999';
		v_govt_home_location := '9999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

         -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4204,
			NULL);
	END IF;
	-- term location
	IF (v_term_location_postcode IS NOT NULL) THEN
		-- when a postcode is used, it must be 4 digits in
		-- length, therefore, left pad them with zeros to
		-- make them 4 digits long
		-- eg. 801 becomes 0801
		v_term_location := LPAD(TO_CHAR(v_term_location_postcode), 4, '0');
		v_govt_term_location := LPAD(TO_CHAR(v_term_location_postcode), 4, '0');
	ELSIF (v_term_location_country IS NOT NULL) THEN
		v_term_location := v_term_location_country;
		-- check if v_term_location_country exists on the
		-- country code table
		OPEN  c_country_dtls(
				v_term_location_country);
		FETCH c_country_dtls INTO v_govt_term_location;
		IF (c_country_dtls%NOTFOUND) THEN
			-- term location country is a DEETYA value
			v_govt_term_location := v_term_location_country;
		END IF;
		CLOSE c_country_dtls;
	ELSE
		v_term_location := '9999';
		v_govt_term_location := '9999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

     -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4205,
			NULL);
	END IF;
	-- country of birth code
	IF (v_birth_country_cd IS NOT NULL) THEN
		-- check if v_birth_country_cd exists on the
		-- country code table
		OPEN  c_country_dtls(v_birth_country_cd);
		FETCH c_country_dtls INTO v_govt_birth_country_cd;
		IF (c_country_dtls%NOTFOUND) THEN
			-- country of birth is a DEETYA value
			v_govt_birth_country_cd := v_birth_country_cd;
		END IF;
		CLOSE c_country_dtls;
	ELSE
		v_birth_country_cd := '9999';
		v_govt_birth_country_cd := '9999';
	END IF;
	IF v_govt_birth_country_cd = '9999' THEN
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

        -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4206,
			NULL);
	END IF;
	-- year of arrival
	IF (v_yr_arrival IS NULL) THEN
		v_yr_arrival := 'A9';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

        -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4207,
			NULL);
	ELSIF v_yr_arrival = 'A8' OR
	           v_yr_arrival = 'A9' THEN
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

           -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4207,
			NULL);
	END IF;
	-- home language code
	IF (v_home_language_cd IS NOT NULL) THEN
		-- check if v_home_language_cd exists on the
		-- language code table
		OPEN  c_language(
				v_home_language_cd);
		FETCH c_language INTO v_govt_home_language_cd;
		IF (c_language%NOTFOUND) THEN
			-- home langauge is a DEETYA value
			v_govt_home_language_cd := TO_NUMBER(v_home_language_cd);
		END IF;
		CLOSE c_language;
	ELSE
		v_home_language_cd := '99';
		v_govt_home_language_cd := 99;
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4208,
			NULL);
	END IF;
	-- prior undergraduate institution
	IF (p_commencing_student_ind = 'N') OR
			(p_commencing_student_ind = 'Y' AND
			IGS_EN_GEN_008.enrp_get_ug_pg_crs(
					p_course_cd,
					p_crv_version_number) <> 'PG') THEN
		-- not commencing a postgraduate course
		v_prior_ug_inst := '0001';
		v_govt_prior_ug_inst := '0001';
	ELSIF (v_prior_ug_inst IS NOT NULL) THEN
		-- check if v_prior_ug_inst exists on the
		-- institution code table
		OPEN  c_inst(
			v_prior_ug_inst);
		FETCH c_inst INTO v_govt_prior_ug_inst;
		IF (c_inst%NOTFOUND) THEN
			-- prior undergraduate institution is a DEETYA value
			v_govt_prior_ug_inst := v_prior_ug_inst;
		END IF;
		CLOSE c_inst;
		IF v_govt_prior_ug_inst = '9999' THEN
			-- Check if an entry has been written to the error log
			IF p_logged_ind = FALSE THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
				4209,
				NULL);
		END IF;
	ELSE
		v_prior_ug_inst := '9999';
		v_govt_prior_ug_inst := '9999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

        -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4209,
			NULL);
	END IF;
	-- prior other qualification/certificate
	IF (p_commencing_student_ind = 'N') THEN
		IF v_prior_other_qual IS NULL OR
				v_prior_other_qual <> '001' THEN
			v_prior_other_qual := '001';
		END IF;
	END IF;
	IF v_prior_other_qual IS NULL OR
			v_prior_other_qual = '999' THEN
		v_prior_other_qual := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

         -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4210,
			NULL);
	END IF;
	-- prior postgraduate course
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_post_grad IS NULL OR
				v_prior_post_grad <> '001' THEN
			v_prior_post_grad := '001';
		END IF;
	END IF;
	IF v_prior_post_grad IS NULL OR
			v_prior_post_grad = '999' THEN
		v_prior_post_grad := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

      -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4211,
			NULL);
	END IF;
	-- prior degree
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_degree IS NULL OR
				v_prior_degree <> '001' THEN
			v_prior_degree := '001';
		END IF;
	END IF;
	IF v_prior_degree IS NULL OR
			v_prior_degree = '999' THEN
		v_prior_degree := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

         -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4212,
			NULL);
	END IF;
	-- prior sub-degree course (not at TAFE)
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_subdeg_notafe IS NULL OR
				v_prior_subdeg_notafe <> '001' THEN
			v_prior_subdeg_notafe := '001';
		END IF;
	END IF;
	IF v_prior_subdeg_notafe IS NULL OR
	    v_prior_subdeg_notafe = '999' THEN
		v_prior_subdeg_notafe := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

         -- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4213,
			NULL);
	END IF;
	-- prior sub-degree course
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_subdeg_tafe IS NULL OR
				v_prior_subdeg_tafe <> '001' THEN
			v_prior_subdeg_tafe := '001';
		END IF;
	END IF;
	IF v_prior_subdeg_tafe IS NULL OR
			v_prior_subdeg_tafe = '999' THEN
		v_prior_subdeg_tafe := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4214,
			NULL);
	END IF;
	-- prior secondary education course at TAFE
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_seced_tafe IS NULL OR
				v_prior_seced_tafe <> '001' THEN
			v_prior_seced_tafe := '001';
		END IF;
	END IF;
	IF v_prior_seced_tafe IS NULL OR
	 		v_prior_seced_tafe = '999' THEN
		v_prior_seced_tafe := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4215,
			NULL);
	END IF;
	-- prior secondary course at school
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_seced_school IS NULL OR
				v_prior_seced_school <> '001' THEN
			v_prior_seced_school := '001';
		END IF;
	END IF;
	IF v_prior_seced_school IS NULL OR
			v_prior_seced_school = '999' THEN
		v_prior_seced_school := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

       	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4216,
			NULL);
	END IF;
	-- prior TAFE award course
	IF p_commencing_student_ind = 'N' THEN
		IF v_prior_tafe_award IS NULL OR
				v_prior_tafe_award <> '001' THEN
			v_prior_tafe_award := '001';
		END IF;
	END IF;
	IF v_prior_tafe_award IS NULL OR
	    v_prior_tafe_award = '999' THEN
		v_prior_tafe_award := '999';
		-- Check if an entry has been written to the error log
		IF p_logged_ind = FALSE THEN
			-- log an error to the IGS_GE_S_ERROR_LOG
			-- using IGS_GE_GEN_003.genp_log_error

      	-- set that an error has been logged
			p_logged_ind := TRUE;
		END IF;
		-- create an entry in the system log entry
		IGS_GE_GEN_003.genp_ins_log_entry (
			p_s_log_type,
			p_creation_dt,
			'IGS_PE_PERSON' || ',' || TO_CHAR(p_person_id),
			4217,
			NULL);
	END IF;
	-- setting the output parameters to what these
	-- values were set to above
	p_birth_dt := v_birth_dt;
	p_sex := v_sex;
	p_aborig_torres_cd := v_aborig_torres_cd;
	p_govt_aborig_torres_cd := v_govt_aborig_torres_cd;
	p_citizenship_cd := v_citizenship_cd;
	p_govt_citizenship_cd := v_govt_citizenship_cd;
	p_perm_resident_cd := v_perm_resident_cd;
	p_govt_perm_resident_cd := v_govt_perm_resident_cd;
	p_home_location_cd := v_home_location;
	p_govt_home_location_cd := v_govt_home_location;
	p_term_location_cd := v_term_location;
	p_govt_term_location_cd := v_govt_term_location;
	p_birth_country_cd := v_birth_country_cd;
	p_govt_birth_country_cd := v_govt_birth_country_cd;
	p_yr_arrival := v_yr_arrival;
	p_home_language_cd := v_home_language_cd;
	p_govt_home_language_cd := v_govt_home_language_cd;
	p_prior_ug_inst := v_prior_ug_inst;
	p_govt_prior_ug_inst := v_govt_prior_ug_inst;
	p_prior_other_qual := v_prior_other_qual;
	p_prior_post_grad := v_prior_post_grad;
	p_prior_degree := v_prior_degree;
	p_prior_subdeg_notafe := v_prior_subdeg_notafe;
	p_prior_subdeg_tafe := v_prior_subdeg_tafe;
	p_prior_seced_tafe := v_prior_seced_tafe;
	p_prior_seced_school := v_prior_seced_school;
	p_prior_tafe_award := v_prior_tafe_award;
	p_govt_disability := v_govt_disability;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGSST_GEN_002.stap_get_person_data');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END stap_get_person_data;

END IGS_ST_GEN_002;

/
