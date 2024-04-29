--------------------------------------------------------
--  DDL for Package Body IGS_ST_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GEN_003" AS
/* $Header: IGSST03B.pls 115.7 2003/05/13 09:02:15 kkillams ship $ */

/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified P_GOVT_EXEMPTION_INST_CD from NUMBER to VARCHAR2 in STAP_GET_SCA_DATA. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
*/

Function Stap_Get_Prsn_Dsblty(
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_prsn_dsblty
	-- Derive the government disability value for a person. Disability
	-- is an 8 character code derived from the IGS_PE_PERSON table
	-- DEETYA element 386
DECLARE
	v_disability		CHAR(8) DEFAULT '        ';
	v_disability_exist	CHAR	DEFAULT ' ';
	v_hearing		CHAR	DEFAULT ' ';
	v_learning		CHAR	DEFAULT ' ';
	v_mobility		CHAR	DEFAULT ' ';
	v_vision		CHAR	DEFAULT ' ';
	v_medical		CHAR	DEFAULT ' ';
	v_other			CHAR	DEFAULT ' ';
	v_contact		CHAR	DEFAULT ' ';
	CURSOR	c_prsn_dsblty (cp_person_id	IGS_PE_PERSON.person_id%TYPE) IS
		SELECT	pd.contact_ind,
			dt.govt_disability_type
		FROM
			IGS_PE_PERS_DISABLTY	pd,
			IGS_AD_DISBL_TYPE		dt
		WHERE
			pd.person_id		= cp_person_id	AND
			dt.disability_type 	= pd.disability_type;
BEGIN
	FOR v_prsn_dsblty IN c_prsn_dsblty (p_person_id) LOOP
		v_disability_exist := '1';
		IF    (v_prsn_dsblty.govt_disability_type = 'HEARING') THEN
			v_hearing := '1';
		ELSIF (v_prsn_dsblty.govt_disability_type = 'LEARNING') THEN
			v_learning := '1';
		ELSIF (v_prsn_dsblty.govt_disability_type = 'MOBILITY') THEN
			v_mobility := '1';
		ELSIF (v_prsn_dsblty.govt_disability_type = 'VISION') THEN
			v_vision := '1';
		ELSIF (v_prsn_dsblty.govt_disability_type = 'MEDICAL') THEN
			v_medical := '1';
		ELSIF (v_prsn_dsblty.govt_disability_type = 'OTHER') THEN
			v_other := '1';
		END IF;
		IF (v_prsn_dsblty.contact_ind = 'Y') THEN
			v_contact := '1';
		END IF;
	END LOOP;
	IF (v_disability_exist = '1' AND
			v_contact = ' ') THEN
		v_contact := '2';
	END IF;
	v_disability := v_disability_exist || v_hearing || v_learning || v_mobility ||
			v_vision || v_medical || v_other || v_contact;
	RETURN v_disability;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_prsn_dsblty');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
   END stap_get_prsn_dsblty;

Procedure Stap_Get_Prsn_Names(
  p_person_id IN NUMBER ,
  p_given_name OUT NOCOPY VARCHAR2 ,
  p_other_names OUT NOCOPY VARCHAR2 )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_prsn_names
	-- Derive the student's first given name and other given name(s)
	-- DEETYA element 403, 404
DECLARE
	v_delim_space		NUMBER(2);
	v_all_given_name	IGS_PE_PERSON.given_names%TYPE;
	CURSOR c_get_given_name (cp_person_id	IGS_PE_PERSON.person_id%TYPE) IS
		SELECT	given_names
		FROM	IGS_PE_PERSON
		WHERE	person_id = cp_person_id;
BEGIN
	OPEN c_get_given_name(p_person_id);
	FETCH c_get_given_name INTO v_all_given_name;
	IF (c_get_given_name%FOUND) THEN
		v_delim_space := INSTR(v_all_given_name, ' ');
		IF (v_delim_space = 0) THEN
			-- No space, only one given name
			p_given_name := v_all_given_name;
		ELSE
			-- Found a space
			p_given_name := SUBSTR(v_all_given_name, 1, v_delim_space -1);
			p_other_names := LTRIM(SUBSTR(v_all_given_name, v_delim_space + 1));
		END IF;
	END IF;
	CLOSE c_get_given_name;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_prsn_names');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
    END stap_get_prsn_names;

Function Stap_Get_Rptbl_Benc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_govt_reportable_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_dt IN DATE ,
  p_submission_cutoff_dt IN DATE )
RETURN VARCHAR2 AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_rptbl_benc
	-- Routine to determine if a unit of study should be reported to
	-- the Benefits Control branch.
DECLARE
	v_govt_hecs_payment_option IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
	CURSOR c_scho_hpo IS
		SELECT	hpo.govt_hecs_payment_option
		FROM
			IGS_EN_STDNTPSHECSOP	scho,
			IGS_FI_HECS_PAY_OPTN		hpo
		WHERE
			scho.person_id	= p_person_id	AND
			scho.course_cd	= p_course_cd	AND
			scho.start_dt	<= p_submission_cutoff_dt AND
			(scho.end_dt	IS NULL	OR
			 scho.end_dt	>= p_submission_cutoff_dt)AND
			hpo.hecs_payment_option = scho.hecs_payment_option
		ORDER BY
			scho.end_dt	ASC;
BEGIN
	-- Processing will stop if any of the parameters is null.
	IF (
		p_person_id		IS NULL OR
		p_course_cd		IS NULL OR
		p_crv_version_number	IS NULL OR
		p_govt_reportable_ind	IS NULL OR
		p_enrolled_dt		IS NULL OR
		p_submission_cutoff_dt	IS NULL) THEN
		RETURN 'N';
	END IF;
	-- Determine if the unit should be reported in the specified submission.
	-- Do not report non-government reportable records.
	IF (p_govt_reportable_ind = 'N') THEN
		RETURN 'N';
	END IF;
	-- Exclude units that are not enrolled as at the cutoff date.
	IF (p_enrolled_dt > p_submission_cutoff_dt) THEN
		RETURN 'N';
	END IF;
	-- Exclude Overseas Student
	-- Select the first record only.
	-- This will be the end dated record if one exists.
	OPEN c_scho_hpo;
	FETCH c_scho_hpo INTO v_govt_hecs_payment_option;
	CLOSE c_scho_hpo;
	IF (v_govt_hecs_payment_option IN ('22','23','24','30')) THEN
		RETURN 'N';
	END IF;
	-- Otherwise, unit of study is reportable
	RETURN 'Y';
EXCEPTION
	WHEN OTHERS THEN
		IF c_scho_hpo%ISOPEN THEN
			CLOSE c_scho_hpo;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_rptbl_benc');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
   END stap_get_rptbl_benc;

FUNCTION Stap_Get_Rptbl_Govt(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_crv_version_number          IN NUMBER ,
  p_unit_cd                     IN VARCHAR2 ,
  p_uv_version_number           IN NUMBER ,
  p_teach_cal_type              IN VARCHAR2 ,
  p_teach_ci_sequence_number    IN NUMBER ,
  p_tr_org_unit_cd              IN VARCHAR2 ,
  p_tr_ou_start_dt              IN DATE ,
  p_eftsu                       IN NUMBER ,
  p_effective_dt                IN DATE ,
  p_exclusion_level             OUT NOCOPY VARCHAR2,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN VARCHAR2 AS
  -------------------------------------------------------------------------------------------
  -- stap_get_rptbl_govt
  -- Routine to determine if a student unit attempt, or part of a student
  -- unit attempt should be reported to the government.  This routine is
  -- called from the process that creates the Enrolment Statistics Snapshot,
  -- and is therefore, not government submission specific.  Another routine
  -- exists to determine if a student unit attempt, or part of a student
  -- unit attempt should be reported to the government in a specific
  -- submission.  (STAP_GET_RPTBL_SBMSN)
  -- There are a number of data assumptions inherent in this routine.
  -- These data assumptions are documented in Reportable Data Assumptions.doc
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      Added new parameter p_uoo_id to the function.
  --                            w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
	cst_course		CONSTANT VARCHAR2(15) := 'COURSE';
	cst_pe_course		CONSTANT VARCHAR2(15) := 'PERSON-COURSE';
	cst_unit		CONSTANT VARCHAR2(15) := 'UNIT';
	cst_yes			CONSTANT VARCHAR2(1) := 'Y';
	cst_no			CONSTANT VARCHAR2(1) := 'N';
	cst_warning		CONSTANT VARCHAR2(1) := 'W';
	cst_govt_report		CONSTANT IGS_PS_UNIT_CATEGORY.unit_cat%TYPE := 'GOVT-RPT';
	cst_govt_noreport	CONSTANT IGS_PS_UNIT_CATEGORY.unit_cat%TYPE := 'GOVT-NORPT';
	cst_tuition		CONSTANT IGS_FI_FEE_TYPE.s_fee_type%TYPE := 'TUITION';
	cst_enrolled		CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
							'ENROLLED';
	cst_discontin		CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE :=
							'DISCONTIN';
	v_unit_cat		IGS_PS_UNIT_CATEGORY.unit_cat%TYPE;
	v_crs_cat		IGS_PS_CATEGORISE.course_cat%TYPE;
	v_resp_ou_cd		IGS_PS_VER.responsible_org_unit_cd%TYPE;
	v_resp_ou_start_dt	IGS_PS_VER.responsible_ou_start_dt%TYPE;
	v_govt_crs_type		IGS_PS_TYPE.govt_course_type%TYPE;
	v_award_crs_ind		IGS_PS_TYPE.award_course_ind%TYPE;
	v_enr_cp		IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;
	v_message_name_temp	VARCHAR2(30) DEFAULT NULL;
	v_fee_cat		IGS_EN_STDNT_PS_ATT.fee_cat%TYPE DEFAULT NULL;
	v_crs_req_cmplt_ind	IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE;
	v_comm_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_govt_hpo		IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
	v_sua_status		IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
	v_charged_tuition_fees	BOOLEAN DEFAULT FALSE;
	CURSOR c_uc IS
		SELECT	uc.unit_cat
		FROM	IGS_PS_UNIT_CATEGORY	uc
		WHERE	uc.unit_cd		= p_unit_cd AND
			uc.version_number 	= p_uv_version_number AND
			uc.unit_cat 		IN (
						cst_govt_report,
						cst_govt_noreport );
	CURSOR c_crc IS
		SELECT	crc.course_cat
		FROM	IGS_PS_CATEGORISE	crc
		WHERE	crc.course_cd 		= p_course_cd AND
			crc.version_number 	= p_crv_version_number AND
			crc.course_cat 		IN (
						cst_govt_report,
						cst_govt_noreport );
	CURSOR c_crv IS
		SELECT	crv.responsible_org_unit_cd,
			crv.responsible_ou_start_dt,
			cty.govt_course_type,
			cty.award_course_ind
		FROM	IGS_PS_VER 		crv,
			IGS_PS_TYPE 		cty
		WHERE	crv.course_cd 		= p_course_cd AND
			crv.version_number 	= p_crv_version_number AND
			cty.course_type		= crv.course_type;
	CURSOR c_uv IS
		SELECT	uv.enrolled_credit_points
		FROM	IGS_PS_UNIT_VER	uv
		WHERE	uv.unit_cd 		= p_unit_cd AND
			uv.version_number 	= p_uv_version_number;
	CURSOR c_sca IS
		SELECT	sca.fee_cat,
			sca.course_rqrmnt_complete_ind,
			sca.commencement_dt,
			hpo.govt_hecs_payment_option
		FROM	IGS_EN_STDNT_PS_ATT 		sca,
			IGS_EN_STDNTPSHECSOP 	scho,
			IGS_FI_HECS_PAY_OPTN 		hpo
		WHERE	sca.person_id		= p_person_id AND
			sca.course_cd		= p_course_cd AND
			sca.person_id		= scho.person_id (+) AND
			sca.course_cd		= scho.course_cd (+) AND
			(scho.start_dt		<= p_effective_dt OR
			scho.start_dt		IS NULL) AND
			( scho.end_dt 		IS NULL OR
			scho.end_dt		>= p_effective_dt) AND
			scho.hecs_payment_option = hpo.hecs_payment_option(+)
		ORDER BY scho.end_dt;
	CURSOR c_ft IS
		SELECT	ft.fee_type
		FROM	IGS_FI_FEE_TYPE	ft
		WHERE	ft.s_fee_type = cst_tuition;
	CURSOR c_sua IS
		SELECT	sua.unit_attempt_status
		FROM	IGS_EN_SU_ATTEMPT	sua
		WHERE	sua.person_id 		= p_person_id AND
			sua.course_cd 		= p_course_cd AND
			sua.uoo_id 		= p_uoo_id;
BEGIN
	--- Set the default exclusion level.
	p_exclusion_level := NULL;
	--- Retrieve unit categorisation data.
	OPEN c_uc;
	FETCH c_uc INTO v_unit_cat;
	IF c_uc%FOUND THEN
		CLOSE c_uc;
		p_exclusion_level := cst_unit;
		IF v_unit_cat = cst_govt_report THEN
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	END IF;
	CLOSE c_uc;
	--- Retrieve course categorisation data.
	OPEN c_crc;
	FETCH c_crc INTO v_crs_cat;
	IF c_crc%FOUND THEN
		CLOSE c_crc;
		p_exclusion_level := cst_course;
		IF v_crs_cat = cst_govt_report THEN
			RETURN 'Y';
		ELSE
			RETURN 'N';
		END IF;
	END IF;
	CLOSE c_crc;
	--- Check for units with no load.
	IF p_eftsu = 0 THEN
		RETURN 'N';
	END IF;
	--- Retrieve course version data.
	OPEN c_crv;
	FETCH c_crv INTO	v_resp_ou_cd,
					v_resp_ou_start_dt,
					v_govt_crs_type,
					v_award_crs_ind;
	IF c_crv%FOUND THEN
		CLOSE c_crv;
		--- Check for external course.
		--- Check for Open Learning Studies course.
		--- Check for non-award course owned by an external organisational unit.
		--- Check for cross-institution course owned by an external organisational
		--- unit.
		IF v_govt_crs_type = 60 OR
				(v_govt_crs_type IN (
							40,
							41,
							42,
							50) AND
				NOT IGS_ST_VAL_SNAPSHOT.stap_val_local_ou(
							v_resp_ou_cd,
							v_resp_ou_start_dt,
							v_message_name_temp)) THEN
			p_exclusion_level := cst_course;
			RETURN 'N';
		END IF;
	ELSE
		CLOSE c_crv;
	END IF;
	--- Retrieve unit version data.
	OPEN c_uv;
	FETCH c_uv INTO v_enr_cp;
	CLOSE c_uv;
	--- Check for units with no credit.
	IF v_enr_cp = 0 THEN
		p_exclusion_level := cst_unit;
		RETURN 'N';
	END IF;
	--- Check for units with a teaching responsibility of an external
	--- organisational unit
	--- if teaching responsibility parameters are set.
	IF p_tr_org_unit_cd IS NOT NULL AND
			p_tr_ou_start_dt IS NOT NULL AND
			NOT IGS_ST_VAL_SNAPSHOT.stap_val_local_ou (
							p_tr_org_unit_cd,
							p_tr_ou_start_dt,
							v_message_name_temp) THEN
		RETURN 'N';
	END IF;
	--- Retrieve student course attempt and HECS data.
	OPEN c_sca;
	FETCH c_sca INTO	v_fee_cat,
				v_crs_req_cmplt_ind,
				v_comm_dt,
				v_govt_hpo;
	IF c_sca%FOUND THEN
		CLOSE c_sca;
		--- Check for overseas student who has come to Australia either an as
		--- Exchange Student or Study Abroad student as part of a formal exchange
		--- program arranged between institutions, but who is not being charged
		--- tuition fees by the institution.
		IF v_govt_hpo = '22' AND
				v_fee_cat IS NOT NULL THEN
			--- Determine whether or not the student is being charged tuition fees.
			FOR v_ft_rec IN c_ft LOOP
				IF IGS_FI_GEN_005.finp_val_fee_lblty (
						p_person_id,
						p_course_cd,
						v_fee_cat,
						v_ft_rec.fee_type,
						p_effective_dt,
						v_message_name_temp) THEN
					v_charged_tuition_fees := TRUE;
					exit;
				END IF;
			END LOOP;
			IF NOT v_charged_tuition_fees THEN
				p_exclusion_level := cst_pe_course;
				RETURN 'N';
			END IF;
		END IF;
		OPEN c_sua;
		FETCH c_sua INTO v_sua_status;
		CLOSE c_sua;
		--- Check if the student is enrolled in a unit in a completed award course.
		IF v_award_crs_ind = 'Y' AND
				v_crs_req_cmplt_ind = 'Y' AND
				(v_sua_status = cst_enrolled OR
				 v_sua_status = cst_discontin) THEN
			RETURN cst_warning;
		END IF;
	ELSE
		CLOSE c_sca;
	END IF;
	--- Reportable.
	RETURN cst_yes;
EXCEPTION
	WHEN OTHERS THEN
		IF c_uc%ISOPEN THEN
			CLOSE c_uc;
		END IF;
		IF c_crc%ISOPEN THEN
			CLOSE c_crc;
		END IF;
		IF c_crv%ISOPEN THEN
			CLOSE c_crv;
		END IF;
		IF c_uv%ISOPEN THEN
			CLOSE c_uv;
		END IF;
		IF c_sca%ISOPEN THEN
			CLOSE c_sca;
		END IF;
		IF c_ft%ISOPEN THEN
			CLOSE c_ft;
		END IF;
		IF c_sua%ISOPEN THEN
			CLOSE c_sua;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_rptbl_govt');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
  END stap_get_rptbl_govt;

FUNCTION Stap_Get_Rptbl_Sbmsn(
  p_submission_yr               IN NUMBER ,
  p_submission_number           IN NUMBER ,
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_crv_version_number          IN NUMBER ,
  p_unit_cd                     IN VARCHAR2 ,
  p_uv_version_number           IN NUMBER ,
  p_teach_cal_type              IN VARCHAR2 ,
  p_teach_ci_sequence_number    IN NUMBER ,
  p_tr_org_unit_cd              IN VARCHAR2 ,
  p_tr_ou_start_dt              IN DATE ,
  p_eftsu                       IN NUMBER ,
  p_enrolled_dt                 IN DATE ,
  p_discontinued_dt             IN DATE ,
  p_govt_semester               IN NUMBER ,
  p_teach_census_dt             IN DATE ,
  p_load_cal_type               IN VARCHAR2 ,
  p_load_ci_sequence_number     IN NUMBER,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN VARCHAR2 AS
-------------------------------------------------------------------------------------------
-- This routine determines if a unit of study should be
-- reported to the government within a specified submission.
-- It can return either of :
-- 	** 'Y' - Yes
--	Government Reportable for the specified submission
--	** 'N' - No
--	Not Government Reportable for the specified submisssion
--	** 'W' - Warning
--	To be manually checked by the Statistics Officer.
--	By default, Warning records will be reported to the Government
--	** NULL - Not determined
-- validate the input parameters

--Change History:
--Who         When            What
--kkillams    28-04-2003      Added new parameter p_uoo_id to the function.
--                            w.r.t. bug number 2829262
-------------------------------------------------------------------------------------------
BEGIN
DECLARE
	CURSOR c_daiv (
			cp_cal_type	 IGS_EN_SU_ATTEMPT.cal_type%TYPE,
			cp_ci_seq_num	 IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE) IS
		SELECT  daiv.alias_val
		FROM	IGS_CA_DA_INST_V daiv,
			IGS_GE_S_GEN_CAL_CON sgcc
		WHERE 	daiv.cal_type = cp_cal_type AND
			daiv.ci_sequence_number = cp_ci_seq_num AND
			daiv.dt_alias = sgcc.census_dt_alias
		ORDER BY daiv.alias_val ASC;
	v_teach_census_dt		IGS_CA_DA_INST_V.alias_val%TYPE;
	v_submission_1_census_dt 	DATE;
	v_submission_2_census_dt 	DATE;
	v_govt_semester			NUMBER;
	v_exclusion_level		VARCHAR2(15);
	v_other_detail			VARCHAR2(255);
	v_discontinued_dt		DATE;
BEGIN
	IF (p_submission_yr IS NULL OR
	    p_submission_number IS NULL) THEN
		RETURN NULL;
	END IF;
	IF (p_enrolled_dt IS NULL) THEN
		RETURN 'N';
	END IF;
	-- define the submission census dates
	v_submission_1_census_dt :=  IGS_GE_DATE.igsdate(TO_CHAR(p_SUBMISSION_YR)||'03/31');
	v_submission_2_census_dt :=  IGS_GE_DATE.igsdate(TO_CHAR(p_SUBMISSION_YR)||'08/31');
	-- get the Government Semester
	IF (p_govt_semester IS NULL) THEN
		v_govt_semester := IGS_ST_GEN_002.stap_get_govt_sem(
					p_submission_yr,
					p_submission_number,
					p_load_cal_type,
					p_load_ci_sequence_number,
					p_teach_cal_type);
		IF (v_govt_semester IS NULL) THEN
			RETURN NULL;
		END IF;
	ELSE
		v_govt_semester := p_govt_semester;
	END IF;
	-- get the census date for the teaching calendar
	-- census date is only required for certain submission/
	-- semester combinations
	IF (p_teach_census_dt IS NULL AND
	   ((p_submission_number = 1 AND
	    (v_govt_semester = 3 OR
	     v_govt_semester = 5)) OR
	    (p_submission_number = 2 AND
	    v_govt_semester = 4))) THEN
		-- select the alias_val from IGS_CA_DA_INST_V.
		-- select the first record only
		OPEN c_daiv(
			p_teach_cal_type,
			p_teach_ci_sequence_number);
		FETCH c_daiv INTO v_teach_census_dt;
		-- return NULL if a record can't be found
		IF (c_daiv%NOTFOUND) THEN
			CLOSE c_daiv;
			RETURN NULL;
		END IF;
		CLOSE c_daiv;
	ELSE
		v_teach_census_dt := p_teach_census_dt;
	END IF;
	-- set the v_discontinued_dt to p_discontinued_dt
	-- set the value to a late date if not set
	v_discontinued_dt := NVL(p_discontinued_dt,
				 IGS_GE_DATE.igsdate('9999/01/01'));
	-- determine if the unit should be reported in the
	-- specified submission
	-- Government semester 1
	IF (v_govt_semester = 1) THEN
		IF (p_enrolled_dt > v_submission_1_census_dt OR
		    v_discontinued_dt <= v_submission_1_census_dt) THEN
			RETURN 'N';
		ELSE
			RETURN stap_get_rptbl_govt(
				p_person_id,
				p_course_cd,
				p_crv_version_number,
				p_unit_cd,
				p_uv_version_number,
				p_teach_cal_type,
				p_teach_ci_sequence_number,
				p_tr_org_unit_cd,
				p_tr_ou_start_dt,
				p_eftsu,
				v_submission_1_census_dt,
				v_exclusion_level,
                                p_uoo_id);
		END IF;
	END IF;
	-- Government semester 3 and 5
	IF (v_govt_semester = 3 OR
	    v_govt_semester = 5) THEN
		IF (p_enrolled_dt > v_teach_census_dt OR
		   v_discontinued_dt <= v_teach_census_dt) THEN
			RETURN 'N';
		ELSE
			RETURN stap_get_rptbl_govt(
				p_person_id,
				p_course_cd,
				p_crv_version_number,
				p_unit_cd,
				p_uv_version_number,
				p_teach_cal_type,
				p_teach_ci_sequence_number,
				p_tr_org_unit_cd,
				p_tr_ou_start_dt,
				p_eftsu,
				v_teach_census_dt,
				v_exclusion_level,
                                p_uoo_id);
		END IF;
	END IF;
	-- Government semester 2 and 4
	IF (v_govt_semester = 2 OR
	    v_govt_semester = 4) THEN
		-- Submission 1
		IF (p_submission_number = 1) THEN
			IF (p_enrolled_dt > v_submission_1_census_dt OR
		    	    v_discontinued_dt <= v_submission_1_census_dt) THEN
				RETURN 'N';
			ELSE
				RETURN stap_get_rptbl_govt(
						p_person_id,
						p_course_cd,
						p_crv_version_number,
						p_unit_cd,
						p_uv_version_number,
						p_teach_cal_type,
						p_teach_ci_sequence_number,
						p_tr_org_unit_cd,
						p_tr_ou_start_dt,
						p_eftsu,
						v_submission_1_census_dt,
						v_exclusion_level,
                                                p_uoo_id);
			END IF;
		END IF;
		-- Submission 2 or 3
		IF (p_submission_number = 2 OR
		    p_submission_number = 3) THEN
			-- Government semester 2
			IF (v_govt_semester = 2) THEN
				IF (p_enrolled_dt > v_submission_2_census_dt OR
		    	 	    v_discontinued_dt <= v_submission_2_census_dt) THEN
					RETURN 'N';
				ELSE
					RETURN stap_get_rptbl_govt(
						p_person_id,
						p_course_cd,
						p_crv_version_number,
						p_unit_cd,
						p_uv_version_number,
						p_teach_cal_type,
						p_teach_ci_sequence_number,
						p_tr_org_unit_cd,
						p_tr_ou_start_dt,
						p_eftsu,
						v_submission_2_census_dt,
						v_exclusion_level,
                                                p_uoo_id);
				END IF;
			END IF;
			-- Government semester 4
			IF (v_govt_semester = 4) THEN
				IF (p_enrolled_dt > v_teach_census_dt OR
		    	 	    v_discontinued_dt <= v_teach_census_dt) THEN
					RETURN 'N';
				ELSE
					RETURN stap_get_rptbl_govt(
						p_person_id,
						p_course_cd,
						p_crv_version_number,
						p_unit_cd,
						p_uv_version_number,
						p_teach_cal_type,
						p_teach_ci_sequence_number,
						p_tr_org_unit_cd,
						p_tr_ou_start_dt,
						p_eftsu,
						v_teach_census_dt,
						v_exclusion_level,
                                                p_uoo_id);
				END IF;
			END IF;
		END IF;
	END IF;
	-- Government reportable value for submission cannot
	-- be determined
	RETURN NULL;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_rptbl_sbmsn');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
    END;
END stap_get_rptbl_sbmsn;

Procedure Stap_Get_Sca_Data(
  p_submission_yr  NUMBER ,
  p_submission_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_crv_version_number IN NUMBER ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_logged_ind IN OUT NOCOPY BOOLEAN ,
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_govt_semester IN NUMBER ,
  p_award_course_ind IN VARCHAR2 DEFAULT 'N',
  p_govt_citizenship_cd IN VARCHAR2 ,
  p_prior_seced_tafe IN VARCHAR2 ,
  p_prior_seced_school IN VARCHAR2 ,
  p_sca_commencement_dt OUT NOCOPY DATE ,
  p_prior_studies_exemption OUT NOCOPY NUMBER ,
  p_exemption_institution_cd OUT NOCOPY VARCHAR2 ,
  p_govt_exemption_inst_cd OUT NOCOPY VARCHAR2 ,
  p_tertiary_entrance_score OUT NOCOPY NUMBER ,
  p_basis_for_admission_type OUT NOCOPY VARCHAR2 ,
  p_govt_basis_for_adm_type OUT NOCOPY VARCHAR2 ,
  p_hecs_amount_pd OUT NOCOPY NUMBER ,
  p_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_govt_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_tuition_fee OUT NOCOPY NUMBER ,
  p_hecs_fee OUT NOCOPY NUMBER ,
  p_differential_hecs_ind OUT NOCOPY VARCHAR2 )
AS
/*
  ||  Created By : Prabhat.Patel@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        05-MAR-2002     Bug NO: 2224621
  ||                                 Modified GOVT_EXEMPTION_INST_CD from NUMBER to VARCHAR2. Since its source
  ||                                 IGS_OR_INSTITUTION.GOVT_INSTITUTION_CD is modified from NUMBER to VARCHAR2.
  ||  (reverse chronological order - newest change first)
*/
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_sca_data
DECLARE
	v_adm_admission_appl_number
					IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE;
	v_adm_nominated_course_cd	IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE;
	v_prior_studies_exemption	IGS_AV_ADV_STANDING.total_exmptn_perc_grntd%TYPE;
	v_temp_prior_studies_exemption	IGS_AV_ADV_STANDING.total_exmptn_perc_grntd%TYPE;
	v_exemption_institution_cd	IGS_AV_ADV_STANDING.exemption_institution_cd%TYPE;
	v_govt_exemption_inst_cd
					IGS_ST_GOVT_STDNT_EN.govt_exemption_institution_cd%TYPE;
	v_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
	v_basis_for_adm_type		IGS_AD_BASIS_FOR_AD.basis_for_admission_type%TYPE;
	v_govt_basis_for_adm_type	IGS_AD_BASIS_FOR_AD.govt_basis_for_adm_type%TYPE;
	v_tertiary_entrance_score	IGS_ST_GOVT_STDNT_EN.tertiary_entrance_score%TYPE;
	v_result_obtained_yr		IGS_AD_AUS_SEC_EDU.result_obtained_yr%TYPE;
	v_aus_scndry_edu_ass_type	IGS_AD_AUSE_ED_AS_TY.aus_scndry_edu_ass_type%TYPE;
	v_override_govt_score		IGS_AS_TYPGOV_SCORMP.govt_score%TYPE;
	v_diff_hecs_ind			IGS_EN_STDNTPSHECSOP.differential_hecs_ind%TYPE;
	v_hecs_payment_option		IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE;
	v_s_hecs_payment_type		IGS_FI_GOV_HEC_PA_OP.s_hecs_payment_type%TYPE;
	v_govt_hpo			IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
	v_acad_cal_type			IGS_CA_INST_REL.sup_cal_type%TYPE;
	v_acad_ci_sequence_number
					IGS_CA_INST_REL.sup_ci_sequence_number%TYPE;
	v_hecs_amount_pd 		NUMBER;
	v_hecs_fee			NUMBER;
	v_tuition_fee 			NUMBER;
	v_acad_start_dt			DATE;
	v_acad_end_dt			DATE;
	v_alt_code			IGS_CA_INST.alternate_code%TYPE;
	v_message_name			VARCHAR2(30);
	v_current_log_ind		BOOLEAN;
	v_other_detail			VARCHAR2(255);
	CURSOR 	c_sca IS
		SELECT 	sca.commencement_dt,
			sca.adm_admission_appl_number,
			sca.adm_nominated_course_cd
		FROM 	IGS_EN_STDNT_PS_ATT sca
		WHERE 	sca.person_id = p_person_id AND
			sca.course_cd = p_course_cd;
	CURSOR	c_aca (
		cp_admission_appl_number
						IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE,
		cp_nominated_course_cd
						IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE) IS
		SELECT	aca.basis_for_admission_type
		FROM	IGS_AD_PS_APPL	aca
		WHERE	aca.person_id			= p_person_id AND
			aca.admission_appl_number	= cp_admission_appl_number AND
			aca.nominated_course_cd		= cp_nominated_course_cd;
	CURSOR 	c_bfa (
		cp_basis_for_adm_type	IGS_AD_BASIS_FOR_AD.basis_for_admission_type%TYPE) IS
		SELECT	bfa.govt_basis_for_adm_type
		FROM	IGS_AD_BASIS_FOR_AD	bfa
		WHERE	bfa.basis_for_admission_type	= cp_basis_for_adm_type;
	CURSOR	c_ase IS
		SELECT	ase.score,
			ase.result_obtained_yr,
			aseat.aus_scndry_edu_ass_type
		FROM	IGS_AD_AUS_SEC_EDU	ase,
			IGS_AD_AUSE_ED_AS_TY	aseat
		WHERE	ase.person_id			= p_person_id	AND
			aseat.aus_scndry_edu_ass_type	= ase.aus_scndry_edu_ass_type AND
			aseat.govt_reported_ind		= 'Y'
		ORDER BY NVL(ase.result_obtained_yr,0) DESC,
			 ase.last_update_date DESC;
	CURSOR	c_atgsm (
		cp_result_obtained_yr	IGS_AS_TYPGOV_SCORMP.result_obtained_yr%TYPE,
		cp_scndry_edu_ass_type	IGS_AS_TYPGOV_SCORMP.scndry_edu_ass_type%TYPE,
		cp_institution_score	IGS_AS_TYPGOV_SCORMP.institution_score%TYPE) IS
		SELECT	atgsm.govt_score
		FROM	IGS_AS_TYPGOV_SCORMP	atgsm
		WHERE	atgsm.result_obtained_yr	= cp_result_obtained_yr		AND
			atgsm.scndry_edu_ass_type	= cp_scndry_edu_ass_type	AND
			atgsm.institution_score		= cp_institution_score;
	CURSOR  c_adv_stnd IS
		SELECT 	TRUNC(ast.total_exmptn_perc_grntd),
			ast.exemption_institution_cd
		FROM	IGS_AV_ADV_STANDING ast
		WHERE	ast.person_id 		= p_person_id AND
			ast.course_cd 		= p_course_cd AND
			ast.version_number 	= p_crv_version_number;
	CURSOR	c_inst_code (
		cp_exemption_institution_cd
						IGS_AV_ADV_STANDING.exemption_institution_cd%TYPE) IS
		SELECT  ins.govt_institution_cd
		FROM	IGS_OR_INSTITUTION ins
		WHERE	ins.institution_cd = cp_exemption_institution_cd;
	CURSOR 	c_get_hpo IS
		SELECT	scho.differential_hecs_ind,
			scho.hecs_payment_option,
			hpo.govt_hecs_payment_option,
			ghpo.s_hecs_payment_type
		FROM	IGS_EN_STDNTPSHECSOP 	scho,
			IGS_FI_HECS_PAY_OPTN 		hpo,
			IGS_FI_GOV_HEC_PA_OP	ghpo
		WHERE	scho.person_id 			= p_person_id AND
			scho.course_cd 			= p_course_cd AND
			scho.start_dt 			<= p_effective_dt AND
			(scho.end_dt 			IS NULL OR
			scho.end_dt 			>= p_effective_dt) AND
			hpo.hecs_payment_option 	= 	scho.hecs_payment_option AND
			ghpo.govt_hecs_payment_option	= hpo.govt_hecs_payment_option
		ORDER BY scho.end_dt ASC;
	PROCEDURE stapl_ins_log_message(
		p_message_name		 VARCHAR2,
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
			'IGS_PE_PERSON IGS_PS_COURSE,' ||
				TO_CHAR(p_person_id) || ', ' ||
				p_course_cd,
			p_message_name,
			NULL);
	END;
	EXCEPTION
		WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stapl_ins_log_message');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
	END stapl_ins_log_message;
BEGIN
	-- get the commencement dt
	OPEN c_sca;
	FETCH c_sca INTO v_commencement_dt,
			 v_adm_admission_appl_number,
			 v_adm_nominated_course_cd;
	-- raise an exception if a record not found
	IF (c_sca%NOTFOUND) THEN
		CLOSE c_sca;
		Fnd_Message.Set_Name('IGS','IGS_EN_CAN_LOC_EXIS_STUD ');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
	END IF;
	CLOSE c_sca;
	IF (p_submission_number = 1) THEN
 		-- retrieve advanced standing data
		IF (p_commencing_student_ind = 'N') THEN
			v_prior_studies_exemption := 00;
			   v_exemption_institution_cd := '0001';
			    v_govt_exemption_inst_cd := '0001';
		ELSE
			OPEN  c_adv_stnd;
			FETCH c_adv_stnd INTO	v_temp_prior_studies_exemption,
				      		v_exemption_institution_cd;
			IF (c_adv_stnd%NOTFOUND) THEN
				v_prior_studies_exemption := 00;
				v_exemption_institution_cd := '0001';
				  v_govt_exemption_inst_cd := '0001';
			ELSE
				-- Ensure the prior studies  excemption value is not too large
				IF v_temp_prior_studies_exemption > 99 THEN
					v_prior_studies_exemption := 99;
					--Check if an entry has been written to the error log
					IF p_logged_ind = FALSE THEN
						v_other_detail := 'Check the system log:' ||
								' s_log_type-' || p_s_log_type ||
								', creation_dt-' || IGS_GE_DATE.igschardt(p_creation_dt);
						-- set that an error has been logged
						p_logged_ind := TRUE;
					END IF;
					--Create an entry in the system log entry
					IGS_GE_GEN_003.genp_ins_log_entry (
							p_s_log_type,
							p_creation_dt,
							'IGS_PE_PERSON IGS_PS_COURSE,' ||
							TO_CHAR(p_person_id) || ', ' ||
							p_course_cd,
							4250,
							NULL);
				ELSE
					v_prior_studies_exemption := v_temp_prior_studies_exemption;
				END IF;
				-- determine the government exemption IGS_OR_INSTITUTION code
				OPEN c_inst_code(v_exemption_institution_cd);
				FETCH c_inst_code INTO v_govt_exemption_inst_cd;
				IF (c_inst_code%NOTFOUND) THEN
					-- exemption IGS_OR_INSTITUTION is a DEETYA value
					v_govt_exemption_inst_cd := v_exemption_institution_cd;
				END IF;
				CLOSE c_inst_code;
			END IF;
			CLOSE c_adv_stnd;
		END IF;
		-- retrieve the basis for admission
		IF (p_commencing_student_ind = 'N') THEN
			v_basis_for_adm_type := '01';
			v_govt_basis_for_adm_type := '01';
		ELSE
			OPEN c_aca(v_adm_admission_appl_number,
				v_adm_nominated_course_cd);
			FETCH c_aca INTO v_basis_for_adm_type;
			IF c_aca%FOUND AND
					v_basis_for_adm_type IS NOT NULL THEN
				CLOSE c_aca;
 				OPEN c_bfa(v_basis_for_adm_type);
				FETCH c_bfa INTO v_govt_basis_for_adm_type;
				CLOSE c_bfa;
			ELSE
				CLOSE c_aca;
				v_basis_for_adm_type := '99';
				v_govt_basis_for_adm_type := '99';
				--Check if an entry has been written to the error log
				IF p_logged_ind = FALSE THEN
					v_other_detail := 'Check the system log:' ||
							' s_log_type-' || p_s_log_type ||
							', creation_dt-' || IGS_GE_DATE.igschardt(p_creation_dt);
					-- set that an error has been logged
					p_logged_ind := TRUE;
				END IF;
				--Create an entry in the system log entry
				IGS_GE_GEN_003.genp_ins_log_entry (
						p_s_log_type,
						p_creation_dt,
						'IGS_PE_PERSON IGS_PS_COURSE,' || TO_CHAR(p_person_id) || ', ' || p_course_cd,
						4218,
						NULL);
			END IF;
		END IF;
		-- retrieve the tertiary entrance score
		IF (p_commencing_student_ind = 'N') OR
				(p_commencing_student_ind = 'Y' AND
				NOT(IGS_EN_GEN_008.enrp_get_ug_pg_crs(
						p_course_cd,
						p_crv_version_number) = 'UG' AND
				p_award_course_ind = 'Y')) THEN
			-- Not commencing an undergraduate award course.
			v_tertiary_entrance_score := 001;
		ELSIF p_govt_citizenship_cd NOT IN (1, 2, 3) OR
				(p_prior_seced_tafe <> ('2' || SUBSTR((p_submission_yr - 1), 3)) AND
				p_prior_seced_school <> ('2' || SUBSTR((p_submission_yr - 1), 3))) THEN
			-- Student is an overseas student or did not complete
			-- the major Year 12 examination in the prior year
			-- in any Australian State/Territory
			v_tertiary_entrance_score := 999;
			-- Create s system log entry
			stapl_ins_log_message(
				4534,
				p_logged_ind);
		ELSE
			OPEN c_ase;
			FETCH c_ase INTO	v_tertiary_entrance_score,
						v_result_obtained_yr,
						v_aus_scndry_edu_ass_type;
			IF c_ase%NOTFOUND OR
					v_tertiary_entrance_score IS NULL OR
					v_tertiary_entrance_score = 0 THEN
				v_tertiary_entrance_score := 998;
			ELSIF c_ase%FOUND AND
					v_result_obtained_yr IS NULL THEN
				--Check if an entry has been written to the error log
				IF p_logged_ind = FALSE THEN
					v_other_detail := 'Check the system log:' ||
							' s_log_type-' || p_s_log_type ||
							', creation_dt-' || IGS_GE_DATE.igschardt(p_creation_dt);
					-- set that an error has been logged
					p_logged_ind := TRUE;
				END IF;
				--Create an entry in the system log entry
				IGS_GE_GEN_003.genp_ins_log_entry (
						p_s_log_type,
						p_creation_dt,
						'IGS_PE_PERSON IGS_PS_COURSE,' || TO_CHAR(p_person_id) || ', ' || p_course_cd,
						4219,
						NULL);
			ELSIF  c_ase%FOUND AND
					v_result_obtained_yr IS NOT NULL THEN
				OPEN c_atgsm(
						v_result_obtained_yr,
						v_aus_scndry_edu_ass_type,
						v_tertiary_entrance_score);
				FETCH c_atgsm INTO v_override_govt_score;
				IF c_atgsm%FOUND THEN
					v_tertiary_entrance_score := v_override_govt_score;
				END IF;
				CLOSE c_atgsm;
			END IF;
			CLOSE c_ase;
		END IF;
	END IF;	-- Submission 1 data
	-- retrieve the HECS payment option
	-- select the first record only, which will be
	-- the end dated record if one exists
	OPEN c_get_hpo;
	FETCH c_get_hpo INTO v_diff_hecs_ind,
				v_hecs_payment_option,
				v_govt_hpo,
				v_s_hecs_payment_type;
	-- when no record, log and error and continue
	IF (c_get_hpo%NOTFOUND) THEN
		CLOSE c_get_hpo;
		-- Only log the exception if the course will be in the liabiity file.
		IF (p_submission_number = 1 AND p_govt_semester IN (1, 3, 5)) OR
		     (p_submission_number = 2 AND p_govt_semester IN (2, 4)) THEN
			IF (p_logged_ind = FALSE) THEN
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON IGS_PS_COURSE' || ',' || TO_CHAR(p_person_id) || ',' || p_course_cd,
				4220,
				NULL);
		END IF;
		-- continue processing after this error has been logged
		v_diff_hecs_ind := 'Y';
		v_hecs_payment_option := '00';
		v_govt_hpo := '00';
	ELSE
		CLOSE c_get_hpo;
	END IF;
	-- retrieve the HECS amount paid
	v_hecs_amount_pd := ROUND(IGS_FI_GEN_001.finp_get_hecs_amt_pd(
					p_load_cal_type,
				      	p_load_ci_sequence_number,
					p_person_id,
					p_course_cd));
	-- retrieve the tuition_fee
	-- Check if the person hasn na HECS option indicating that the course
	-- is fully funded by an employer
	IF v_govt_hpo = '27' THEN
		v_tuition_fee := 0;
	ELSE
		v_tuition_fee := TRUNC(IGS_FI_GEN_001.finp_get_tuition_fee(
					p_load_cal_type,
				      	p_load_ci_sequence_number,
					p_person_id,
					p_course_cd));
	END IF;
	-- retrieve the HECS fee
	IF v_s_hecs_payment_type = 'EXEMPT' THEN
		v_hecs_fee := 0;
	ELSE
		v_hecs_fee := ROUND(IGS_FI_GEN_001.finp_get_hecs_fee(
					p_load_cal_type,
				      	p_load_ci_sequence_number,
					p_person_id,
					p_course_cd));
		-- Cannot have a hecs fee greater than 4 digits
		IF v_hecs_fee > 9999 THEN
			IF (p_logged_ind = FALSE) THEN
				-- log an error to the IGS_GE_S_ERROR_LOG
				p_logged_ind := TRUE;
			END IF;
			-- create an entry in the system log entry
			IGS_GE_GEN_003.genp_ins_log_entry (
				p_s_log_type,
				p_creation_dt,
				'IGS_PE_PERSON IGS_PS_COURSE' || ',' || TO_CHAR(p_person_id) || ',' || p_course_cd,
				4901,
				NULL);
			v_hecs_fee := 9999;
		END IF;
	END IF;
	-- set the out NOCOPY parameters to the values set in this function
	p_sca_commencement_dt := v_commencement_dt;
	p_prior_studies_exemption := v_prior_studies_exemption;
	p_exemption_institution_cd := v_exemption_institution_cd;
	p_govt_exemption_inst_cd := v_govt_exemption_inst_cd;
	p_tertiary_entrance_score := v_tertiary_entrance_score;
	p_basis_for_admission_type := v_basis_for_adm_type;
	p_govt_basis_for_adm_type := v_govt_basis_for_adm_type;
	p_hecs_amount_pd := v_hecs_amount_pd;
	p_hecs_payment_option := v_hecs_payment_option;
	p_govt_hecs_payment_option := v_govt_hpo;
	p_tuition_fee := v_tuition_fee;
	p_hecs_fee := v_hecs_fee;
	p_differential_hecs_ind := v_diff_hecs_ind;
EXCEPTION
	WHEN OTHERS THEN
		IF c_sca%ISOPEN THEN
			CLOSE c_sca;
		END IF;
		IF c_aca%ISOPEN THEN
			CLOSE c_aca;
		END IF;
		IF c_bfa%ISOPEN THEN
			CLOSE c_bfa;
		END IF;
		IF c_ase%ISOPEN THEN
			CLOSE c_ase;
		END IF;
		IF c_atgsm%ISOPEN THEN
			CLOSE c_atgsm;
		END IF;
		IF c_adv_stnd%ISOPEN THEN
			CLOSE c_adv_stnd;
		END IF;
		IF c_inst_code%ISOPEN THEN
			CLOSE c_inst_code;
		END IF;
		IF c_get_hpo%ISOPEN THEN
			CLOSE c_get_hpo;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_sca_data');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
      END stap_get_sca_data;

Function Stap_Get_Sch_Leaver(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_commencing_student_ind IN VARCHAR2 DEFAULT 'N',
  p_collection_yr IN NUMBER )
RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_sch_leaver
	-- Derive the school leaver value
	-- DEETYA element 925
DECLARE
	v_ret_val	NUMBER(2) DEFAULT 1;
	v_prior_post_grad	IGS_PE_STATISTICS.prior_post_grad%TYPE;
	v_prior_degree		IGS_PE_STATISTICS.prior_degree%TYPE;
	v_prior_subdeg_notafe	IGS_PE_STATISTICS.prior_subdeg_notafe%TYPE;
	v_prior_subdeg_tafe	IGS_PE_STATISTICS.prior_subdeg_tafe%TYPE;
	v_prior_tafe_award	IGS_PE_STATISTICS.prior_tafe_award%TYPE;
	v_prior_other_qual	IGS_PE_STATISTICS.prior_other_qual%TYPE;
	v_prior_seced_school	IGS_PE_STATISTICS.prior_seced_school%TYPE;
	v_prior_seced_tafe	IGS_PE_STATISTICS.prior_seced_tafe%TYPE;
	v_collection_yr		VARCHAR2(4);
	v_collection_yr_less1	VARCHAR2(4);
	v_collection_yr_less2	VARCHAR2(4);
	CURSOR c_ps IS
		SELECT	ps.prior_post_grad,
			ps.prior_degree,
			ps.prior_subdeg_notafe,
			ps.prior_subdeg_tafe,
			ps.prior_tafe_award,
			ps.prior_other_qual,
			ps.prior_seced_school,
			ps.prior_seced_tafe
		FROM	IGS_PE_STATISTICS	ps
		WHERE	ps.person_id 	=  p_person_id	AND
			TRUNC(ps.start_dt) <= TRUNC(SYSDATE) AND
			(ps.end_dt IS NULL OR
			TRUNC(ps.end_dt) >= TRUNC(SYSDATE))
		ORDER BY ps.end_dt;
BEGIN
	IF p_commencing_student_ind = 'N' THEN
		-- Not a commencing student
		RETURN v_ret_val;
	END IF;
	OPEN c_ps;
	FETCH c_ps INTO
			v_prior_post_grad,
			v_prior_degree,
			v_prior_subdeg_notafe,
			v_prior_subdeg_tafe,
			v_prior_tafe_award,
			v_prior_other_qual,
			v_prior_seced_school,
			v_prior_seced_tafe;
	IF c_ps%NOTFOUND THEN
		CLOSE c_ps;
		-- Other Commencing Student
		RETURN 8;
	END IF;
	CLOSE c_ps;
	v_collection_yr := TO_CHAR(p_collection_yr);
	v_collection_yr_less1 := TO_CHAR(TO_NUMBER(v_collection_yr) - 1);
	v_collection_yr_less2 := TO_CHAR(TO_NUMBER(v_collection_yr) - 2);
	IF SUBSTR(v_prior_post_grad, 1, 1) = '3' OR
			SUBSTR(v_prior_degree, 1, 1) 	= '3' OR
			SUBSTR(v_prior_subdeg_notafe, 1, 1) = '3' OR
			SUBSTR(v_prior_subdeg_tafe, 1, 1) = '3' OR
			SUBSTR(v_prior_tafe_award, 1, 1) = '3' OR
			SUBSTR(v_prior_other_qual, 1, 1) = '2' THEN
		-- student has completed a qualification higher than
		-- final secondary education at school or elsewhere
		v_ret_val := 2;
	ELSIF v_prior_seced_tafe = '2' || SUBSTR(v_collection_yr, 3,2) OR
			v_prior_seced_tafe = '2' || SUBSTR(v_collection_yr_less1,3,2) OR
			v_prior_seced_school = '2' || SUBSTR(v_collection_yr,3,2) OR
			v_prior_seced_school = '2' || SUBSTR(v_collection_yr_less1,3,2) THEN
		-- Student had completed final year of secondary education in
		-- the reference year or the year prior to the ref year
		v_ret_val := 3;
	ELSIF v_prior_seced_tafe BETWEEN
			'200' AND ('2' || SUBSTR(v_collection_yr_less2, 3,2)) OR
			v_prior_seced_school BETWEEN
			'200' AND ('2' || SUBSTR(v_collection_yr_less2, 3,2)) THEN
		-- Student had completed final year of secondary education earlier
		-- than the year prior to the reference year
		v_ret_val := 4;
	ELSIF SUBSTR(v_prior_seced_tafe, 1,1) = '2' OR
		SUBSTR(v_prior_seced_school, 1,1) = '2' THEN
		-- Student who had completed final year of secondary
		-- education but not information on the year of completion
		v_ret_val := 9;
	ELSE
		-- Other commencing student
		v_ret_val := 8;
	END IF;
	RETURN v_ret_val;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_sch_leaver');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
    END stap_get_sch_leaver;

Function Stap_Get_Spclstn(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- stap_get_spclstn
	-- This module get the student course attempt specialisation.
	-- Currently this can only be set to the field of study of the
	-- major of the course
DECLARE
	CURSOR c_cfos_fos IS
		SELECT	fos.govt_field_of_study
		FROM	IGS_PS_FIELD_STUDY	cfos,
			IGS_PS_FLD_OF_STUDY		fos
		WHERE	cfos.course_cd		= p_course_cd AND
			cfos.version_number	= p_version_number AND
			cfos.major_field_ind	= 'Y' AND
			fos.field_of_study	= cfos.field_of_study;
	v_govt_field_of_study	IGS_PS_FLD_OF_STUDY.govt_field_of_study%TYPE;
BEGIN
	-- Cursor handling
	OPEN c_cfos_fos;
	FETCH c_cfos_fos INTO v_govt_field_of_study;
	IF c_cfos_fos%FOUND THEN
		CLOSE c_cfos_fos;
		RETURN v_govt_field_of_study;
	END IF;
	CLOSE c_cfos_fos;
	-- Return the default value
	RETURN NULL;
EXCEPTION
	WHEN OTHERS THEN
		IF c_cfos_fos%ISOPEN THEN
			CLOSE c_cfos_fos;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_ST_GEN_003.stap_get_spclstn');
		IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
END stap_get_spclstn;

END IGS_ST_GEN_003;

/
