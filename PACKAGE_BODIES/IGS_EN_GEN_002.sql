--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_002" AS
/* $Header: IGSEN02B.pls 120.1 2006/01/15 23:05:12 ctyagi noship $ */

--History
--Who         When            What
--PTANDON     13-Jun-2003     Modified the Function Enrp_Get_Acad_Alt_Cd to skip recursive check to find the superior
--                            Academic Calendar instance if the subordinate calendar instance is a Load Calendar
--                            Instance - Bug# 2917463

Function Enrp_Ext_Enrl_Form(
  p_key IN VARCHAR2 ,
  p_log_type IN VARCHAR2,
  p_message_name out NOCOPY Varchar2 )
RETURN BOOLEAN AS

BEGIN	-- enrp_ext_enrl_form
	-- This module extracts enrolment forms data from the IGS_GE_S_LOG_ENTRY table
	-- and writes it to the server host.
DECLARE

      -- commented for conc issue...
	--cst_enrol_form		CONSTANT VARCHAR2(10) := 'ENROL-FORM';

	CURSOR c_sle IS
		SELECT	sle.text
		FROM	IGS_GE_S_LOG_ENTRY sle,
			IGS_GE_S_LOG sl
		WHERE	sl.key 		= p_key AND
			sl.s_log_type 	= p_log_type AND
			sle.s_log_type 	= sl.s_log_type AND
			sle.creation_dt = sl.creation_dt
		ORDER BY sle.sequence_number;

	v_sle_rec	c_sle%ROWTYPE;
	v_sle_found 		BOOLEAN DEFAULT FALSE;
BEGIN
	-- Set the default message number
	p_message_name := null;
	-- loop through records found and write out NOCOPY each line
	-- fetched to the output file
	FOR v_sle_rec IN c_sle LOOP
		v_sle_found := TRUE;
		FND_FILE.PUT_LINE(
				FND_FILE.OUTPUT,
				v_sle_rec.text);
	END LOOP;
	IF NOT v_sle_found THEN
		-- close output file
    -- anilk, bug#2744709
		p_message_name := 'IGS_EN_NOENR_FORM_DATA_FOUND';

		RETURN FALSE;
	END IF;
	-- Return the default value
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF c_sle%ISOPEN THEN
			CLOSE c_sle;
		END IF;
		p_message_name := 'IGS_EN_NOTWRITE_ENR_EXTFILE';
		RETURN FALSE;
END;
EXCEPTION
	WHEN OTHERS THEN
	Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_002.enrp_ext_enrl_form');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
END enrp_ext_enrl_form;


Function Enrp_Get_1st_Enr_Crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
BEGIN
DECLARE
	v_output			VARCHAR2(25);
	v_first_enrolment_course	VARCHAR2(25);
	CURSOR	c_suav_details (
		cp_person_id	IGS_PE_PERSON.person_id%TYPE,
		cp_course_cd	IGS_PS_COURSE.course_cd%TYPE) IS
		SELECT 	IGS_EN_GEN_014.enrs_get_acad_alt_cd(SUAV.cal_type,SUAV.ci_sequence_number)
        ||'/'|| IGS_CA_GEN_001.calp_get_alt_cd(SUAV.cal_type,SUAV.ci_sequence_number)
		FROM	IGS_EN_SU_ATTEMPT SUAV,
			IGS_CA_INST CI
		WHERE	SUAV.person_id 	   	= cp_person_id 	AND
			SUAV.course_cd 	   	= cp_course_cd 	AND
			SUAV.enrolled_dt   	IS NOT NULL 	AND
			SUAV.cal_type 	   	= CI.cal_type 	AND
			SUAV.ci_sequence_number = CI.sequence_number
		ORDER BY CI.start_dt,
			     CI.end_dt ;
BEGIN
	-- This module determines the enrolment period a
	-- IGS_PE_PERSON is first enrolled in for a specified
	-- IGS_PS_COURSE and returns it.  A null value may
	-- also be returned.
	-- Retrieving the student IGS_PS_UNIT attempt records for the
	-- IGS_PE_PERSON's IGS_PS_COURSE attempt.
	-- The order the records are returned will ensure that
	-- the oldest IGS_PS_UNIT attempt record for the IGS_PE_PERSON's IGS_PS_COURSE
	-- attempt is returned first.
    -- modified cursor c_suav_details for performance bug 3687016
	OPEN  c_suav_details(p_person_id,
			     p_course_cd);
	FETCH c_suav_details INTO v_first_enrolment_course;
	IF (c_suav_details%FOUND) THEN
		CLOSE c_suav_details;
		v_output := v_first_enrolment_course;
		RETURN v_output;
	ELSE -- no records are found
		CLOSE c_suav_details;
		v_output := NULL;
		RETURN v_output;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_002.enrp_get_1st_enr_crs');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
END;
END enrp_get_1st_enr_crs;


Function Enrp_Get_Acad_Alt_Cd(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_acad_cal_type OUT NOCOPY VARCHAR2 ,
  p_acad_ci_sequence_number OUT NOCOPY NUMBER ,
  p_acad_ci_start_dt OUT NOCOPY DATE ,
  p_acad_ci_end_dt OUT NOCOPY DATE ,
  p_message_name out NOCOPY Varchar2 )
RETURN VARCHAR2 AS

	gv_acad_rec_found	BOOLEAN := FALSE;
	gv_alternate_code	IGS_CA_INST.alternate_code%TYPE;
	gv_s_cal_cat		IGS_CA_TYPE.s_cal_cat%TYPE;

BEGIN	-- enrp_get_acad_alt_cd
	-- Get the alternate_code for the superior ACADEMIC IGS_CA_INST of the
	-- IGS_CA_INST passed
DECLARE
	-- This function recursively track down the first superior academic
	-- IGS_CA_INST  (deep first recursive).  Returning TRUE if it can find one,
	-- FALSE otherwise

	CURSOR	c_check_s_cal_cat (cp_cal_type	IGS_CA_TYPE.cal_type%TYPE) IS
	SELECT	cat.s_cal_cat
	FROM	IGS_CA_TYPE			cat
	WHERE	cat.cal_type			= cp_cal_type;

	CURSOR 	c_get_super_ci_for_load (cp_cal_type	IGS_CA_INST.cal_type%TYPE,
					cp_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE) IS
	SELECT	cir.sup_cal_type,
		cir.sup_ci_sequence_number,
		ci.start_dt,
		ci.end_dt,
		ci.alternate_code
	FROM	IGS_CA_INST_REL	cir,
		IGS_CA_INST			ci,
		IGS_CA_TYPE			cat
	WHERE	cir.sub_cal_type		= cp_cal_type		AND
		cir.sub_ci_sequence_number	= cp_ci_sequence_number AND
		ci.cal_type			= cir.sup_cal_type	AND
		ci.sequence_number		= cir.sup_ci_sequence_number AND
		cat.cal_type			= ci.cal_type		AND
		cat.s_cal_cat			= 'ACADEMIC'
	ORDER BY
		ci.start_dt asc,
		ci.end_dt asc;

	FUNCTION enrpl_get_acad_alt_cd_re (cp_cal_type		IGS_CA_INST.cal_type%TYPE,
				  	   cp_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE)
	RETURN BOOLEAN
	AS
	BEGIN
	DECLARE

		CURSOR 	c_get_super_ci (cp_cal_type	IGS_CA_INST.cal_type%TYPE,
					cp_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE) IS
			SELECT	cir.sup_cal_type,
				cir.sup_ci_sequence_number,
				ci.start_dt,
				ci.end_dt,
				ci.alternate_code,
				cat.s_cal_cat
			FROM	IGS_CA_INST_REL	cir,
				IGS_CA_INST			ci,
				IGS_CA_TYPE			cat
			WHERE	cir.sub_cal_type		= cp_cal_type		AND
				cir.sub_ci_sequence_number	= cp_ci_sequence_number AND
				ci.cal_type			= cir.sup_cal_type	AND
				ci.sequence_number		= cir.sup_ci_sequence_number AND
				cat.cal_type			= ci.cal_type
			ORDER BY
				ci.start_dt asc,
				ci.end_dt asc;
	BEGIN
		FOR super_ci_rec IN c_get_super_ci(cp_cal_type, cp_ci_sequence_number) LOOP
			IF (super_ci_rec.s_cal_cat = 'ACADEMIC') THEN
				p_acad_cal_type		:= super_ci_rec.sup_cal_type;
				p_acad_ci_sequence_number := super_ci_rec.sup_ci_sequence_number;
				p_acad_ci_start_dt	:= super_ci_rec.start_dt;
				p_acad_ci_end_dt	:= super_ci_rec.end_dt;
				gv_alternate_code 	:= super_ci_rec.alternate_code;
				-- found it! exit right away
				gv_acad_rec_found := TRUE;
				EXIT;
			ELSE
				-- recursively process this superior cal instance
				IF (enrpl_get_acad_alt_cd_re(super_ci_rec.sup_cal_type,
					 	             super_ci_rec.sup_ci_sequence_number) = TRUE) THEN
					EXIT;
				END IF;
			END IF;
		END LOOP;
		IF (gv_acad_rec_found = TRUE) THEN
			RETURN TRUE;
		END IF;
		RETURN FALSE;
/*
	EXCEPTION
		WHEN OTHERS THEN
			Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
			App_Exception.Raise_Exception;
*/
	END;
	END enrpl_get_acad_alt_cd_re;
BEGIN
	OPEN c_check_s_cal_cat(p_cal_type);
	FETCH c_check_s_cal_cat INTO gv_s_cal_cat;
	CLOSE c_check_s_cal_cat;

	p_message_name := null;
	IF gv_s_cal_cat='LOAD' THEN
		FOR super_ci_rec IN c_get_super_ci_for_load(p_cal_type, p_ci_sequence_number) LOOP
			p_acad_cal_type		:= super_ci_rec.sup_cal_type;
			p_acad_ci_sequence_number := super_ci_rec.sup_ci_sequence_number;
			p_acad_ci_start_dt	:= super_ci_rec.start_dt;
			p_acad_ci_end_dt	:= super_ci_rec.end_dt;
			gv_alternate_code 	:= super_ci_rec.alternate_code;
			-- found it! exit right away
			gv_acad_rec_found := TRUE;
			EXIT;
		END LOOP;
		IF (gv_acad_rec_found = TRUE) THEN
			RETURN gv_alternate_code;
		END IF;
	ELSE
		IF (enrpl_get_acad_alt_cd_re (p_cal_type,
				      p_ci_sequence_number) = TRUE) THEN
			RETURN gv_alternate_code;
		END IF;
	END IF;
	p_message_name := 'IGS_EN_SUP_ACACAL_INST_NOTDFN';
	RETURN NULL;
END;
/*
EXCEPTION
	WHEN OTHERS THEN
	Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
	App_Exception.Raise_Exception;
*/
END enrp_get_acad_alt_cd;


Function Enrp_Get_Acad_Comm(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_admission_appl_number IN NUMBER ,
  p_adm_nominated_course_cd IN VARCHAR2 ,
  p_adm_sequence_number IN NUMBER ,
  p_chk_adm_prpsd_comm_ind IN VARCHAR2)
RETURN DATE AS

--History
--Who         When            What
--stutta  24-Aug-2004   Reverted back the check to p_chk_adm_prpsd_comm_ind = 'N'
--                      Bug#3793016
BEGIN
	-- enrp_get_acad_comm
	-- This module gets the default student IGS_PS_COURSE attempt commencement date.
	-- This is used by ENRF3000 and ENRP_INS_SNEW_PRENRL.
DECLARE
	cst_transfer		CONSTANT VARCHAR2(10) := 'TRANSFER';
	cst_academic		CONSTANT VARCHAR2(10) := 'ACADEMIC';
	CURSOR c_sca IS
		SELECT	MIN(sca.commencement_dt)	commencement_dt
		FROM	IGS_PS_STDNT_TRN sct,
			IGS_EN_STDNT_PS_ATT 	sca,
			IGS_PS_VER 		crv
		WHERE	sct.person_id 		= p_person_id AND
			sct.course_cd 		= p_course_cd AND
			sct.person_id 		= sca.person_id AND
			sct.transfer_course_cd 	= sca.course_cd AND
			crv.course_cd 		= sca.course_cd AND
			crv.version_number 	= sca.version_number AND
			crv.generic_course_ind 	= 'Y';
	v_sca_rec	c_sca%ROWTYPE;


	CURSOR c_daiv (
		cp_acad_cal_type		IGS_CA_DA_INST_V.cal_type%TYPE,
		cp_acad_ci_sequence_number	IGS_CA_DA_INST_V.ci_sequence_number%TYPE) IS
		SELECT	MIN(IGS_CA_GEN_001.calp_set_alias_value
				(
				 daiv.absolute_val,
				 IGS_CA_GEN_002.cals_clc_dt_from_dai
					(
					 daiv.ci_sequence_number,
					 daiv.CAL_TYPE,
					 daiv.DT_ALIAS,
					 daiv.sequence_number
					)
				 )
			) alias_val
		FROM	IGS_CA_DA_INST 		daiv,
			IGS_EN_CAL_CONF 	secc
		WHERE	daiv.cal_type 			= cp_acad_cal_type AND
			daiv.ci_sequence_number 	= cp_acad_ci_sequence_number AND
			secc.commencement_dt_alias 	= daiv.dt_alias AND
			secc.s_control_num 		= 1;
	v_daiv_rec	c_daiv%ROWTYPE;

	CURSOR c_acaiv IS
		SELECT 	NVL(acai.adm_cal_type, aa.adm_cal_type) adm_cal_type,
		     	NVL(acai.adm_ci_sequence_number, aa.adm_ci_sequence_number) adm_ci_sequence_number,
		     	acai.prpsd_commencement_dt prpsd_commencement_dt
		FROM
		     	IGS_AD_PS_APPL_INST acai,
		     	IGS_AD_APPL aa,
		     	IGS_CA_INST ci,
		     	IGS_AD_PS_APPL aca,
		     	IGS_PS_VER crv
		WHERE	acai.person_id = p_person_id AND
     			aa.person_id = acai.person_id AND
			acai.admission_appl_number = p_adm_admission_appl_number AND
     			aa.admission_appl_number = acai.admission_appl_number AND
     			ci.cal_type (+) = acai.deferred_adm_cal_type AND
     			ci.sequence_number (+) = acai.deferred_adm_ci_sequence_num AND
     			aca.person_id = acai.person_id AND
     			aca.admission_appl_number = acai.admission_appl_number AND
			acai.nominated_course_cd = p_adm_nominated_course_cd AND
		     	aca.nominated_course_cd = acai.nominated_course_cd AND
     			crv.course_cd = acai.course_cd AND
     			crv.version_number = acai.crv_version_number AND
			acai.sequence_number = p_adm_sequence_number;
	v_acaiv_rec	c_acaiv%ROWTYPE;

	CURSOR c_aa IS
		SELECT	aa.s_admission_process_type
		FROM	IGS_AD_APPL	aa
		WHERE	person_id 		= p_person_id AND
			admission_appl_number 	= p_adm_admission_appl_number;
	v_aa_rec 	c_aa%ROWTYPE;
	CURSOR c_scae_cir_ci_cat IS
		SELECT 	cir.sup_cal_type,
			cir.sup_ci_sequence_number
		FROM	IGS_AS_SC_ATMPT_ENR scae,
 			IGS_CA_INST_REL cir,
			IGS_CA_INST ci,
 			IGS_CA_TYPE cat
		WHERE	scae.person_id 			= p_person_id 			AND
			scae.course_cd 			= p_course_cd 			AND
			scae.cal_type 			= cir.sub_cal_type 		AND
			scae.ci_sequence_number 	= cir.sub_ci_sequence_number 	AND
			cir.sub_cal_type 		= ci.cal_type 			AND
			cir.sub_ci_sequence_number 	= ci_sequence_number 		AND
			cir.sup_cal_type 		= cat.cal_type 			AND
			cat.s_cal_cat 			= cst_academic
		ORDER BY ci.start_dt ASC;
	v_acad_cal_type			IGS_CA_INST_REL.sup_cal_type%TYPE;
	v_acad_ci_sequence_number
				IGS_CA_INST_REL.sup_ci_sequence_number%TYPE;
	v_course_start_dt	DATE DEFAULT NULL;
BEGIN

	-- Determine that student IGS_PS_COURSE attempt is not the result of a
	-- generic IGS_PS_COURSE transfer
	OPEN c_sca;
	FETCH c_sca INTO v_sca_rec;
	IF c_sca%FOUND AND
			v_sca_rec.commencement_dt IS NOT NULL THEN
		CLOSE c_sca;
		-- Default to commencement date of generic IGS_PS_COURSE
		RETURN v_sca_rec.commencement_dt;
	END IF;
	CLOSE c_sca;
	IF p_adm_admission_appl_number IS NULL AND
			p_adm_nominated_course_cd IS NULL AND
			p_adm_sequence_number IS NULL THEN
		-- Student IGS_PS_COURSE attempt is not the result of an admissions
		-- application offer, therefore default commencement date to
		-- latest of today?s date and academic commencement date
		IF p_acad_cal_type IS NULL OR
				p_acad_ci_sequence_number IS NULL THEN
			--Determine academic period from latest enrolment period
			OPEN c_scae_cir_ci_cat;
			FETCH c_scae_cir_ci_cat INTO
					v_acad_cal_type,
					v_acad_ci_sequence_number;
			IF c_scae_cir_ci_cat%NOTFOUND THEN
				CLOSE c_scae_cir_ci_cat;
				RETURN TRUNC(SYSDATE);
			END IF;
			CLOSE c_scae_cir_ci_cat;
		ELSE
			v_acad_cal_type := p_acad_cal_type;
			v_acad_ci_sequence_number := p_acad_ci_sequence_number;
		END IF;
		OPEN c_daiv (
				v_acad_cal_type,
				v_acad_ci_sequence_number);
		FETCH c_daiv INTO v_daiv_rec;
		CLOSE c_daiv;
		IF v_daiv_rec.alias_val IS NULL OR
				v_daiv_rec.alias_val < TRUNC(SYSDATE) THEN
			-- Academic commencement date unable to be determined,
			-- return today?s date
			RETURN TRUNC(SYSDATE);
		END IF;
		RETURN v_daiv_rec.alias_val;
	END IF;
	-- Student IGS_PS_COURSE attempt is the result of an admissions offer, therefore
	-- default to latest of admission period IGS_PS_COURSE start date and today?s date
	OPEN c_acaiv;
	FETCH c_acaiv INTO v_acaiv_rec;
	IF c_acaiv%FOUND THEN
		CLOSE c_acaiv;
		IF v_acaiv_rec.prpsd_commencement_dt IS NULL OR
			NVL(p_chk_adm_prpsd_comm_ind,'N') = 'N' THEN
			-- Get IGS_PS_COURSE start date of admission period of offer

			v_course_start_dt := IGS_AD_GEN_005.admp_get_crv_strt_dt(
						v_acaiv_rec.adm_cal_type,
						v_acaiv_rec.adm_ci_sequence_number);

			IF v_course_start_dt IS NULL OR
					v_course_start_dt < TRUNC(SYSDATE) THEN
				-- Admission IGS_PS_COURSE start date could not be determined,
				-- return today?s date
				RETURN TRUNC(SYSDATE);
			END IF;
			-- Determine if admission application is a IGS_PS_COURSE transfer
			OPEN c_aa;
			FETCH c_aa INTO v_aa_rec;
			IF c_aa%NOTFOUND OR
					v_aa_rec.s_admission_process_type = cst_transfer THEN
				CLOSE c_aa;
				RETURN TRUNC(SYSDATE);
			END IF;
			CLOSE c_aa;
			RETURN v_course_start_dt;
		ELSE
			RETURN v_acaiv_rec.prpsd_commencement_dt;
		END IF;
	END IF;
	CLOSE c_acaiv;
	-- Admission IGS_PS_COURSE start date could not be determined,
	-- return today?s date
	RETURN TRUNC(SYSDATE);
EXCEPTION
	WHEN OTHERS THEN
		IF c_acaiv%ISOPEN THEN
			CLOSE c_acaiv;
		END IF;
		IF c_sca%ISOPEN THEN
			CLOSE c_sca;
		END IF;
		IF c_daiv%ISOPEN THEN
			CLOSE c_daiv;
		END IF;
		IF c_aa%ISOPEN THEN
			CLOSE c_aa;
		END IF;
		IF c_scae_cir_ci_cat%ISOPEN THEN
			CLOSE c_scae_cir_ci_cat;
		END IF;
		RAISE;

END;
/*
      EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		App_Exception.Raise_Exception;
*/
END enrp_get_acad_comm;


Function Enrp_Get_Acad_P_Att(
  p_load_figure IN NUMBER )
RETURN VARCHAR2 AS
BEGIN
DECLARE
	v_record_found 		BOOLEAN;
	v_record_count 		NUMBER;
	v_attendance_type	IGS_EN_ATD_TYPE.attendance_type%TYPE;
	CURSOR	c_attendance_type(
			cp_load_figure IGS_EN_ATD_TYPE.lower_enr_load_range%TYPE) IS
		SELECT	attendance_type
		FROM	IGS_EN_ATD_TYPE
		WHERE	lower_enr_load_range <= p_load_figure AND
			upper_enr_load_range >= p_load_figure AND
			lower_enr_load_range <> 0 AND	-- testing for non zero ensures a
			upper_enr_load_range <> 0;	-- valid derivable load range has
							-- been specified
BEGIN
	-- Get the attendance type for a nominated load figure.
	-- This is done by searching for an attendance_type record which specifies
	-- the load ranges for the different attendance types within the academic
	-- period. If no record is found then NULL is returned, as it is not possible
	-- to derive the figure.
	IF p_load_figure = 0 THEN
		RETURN NULL;
	END IF;
	v_record_found := FALSE;
	v_record_count := 0;
	FOR v_attendance_type_rec IN c_attendance_type(
						p_load_figure)
	LOOP
		v_record_found := TRUE;
		v_record_count := v_record_count + 1;
		v_attendance_type := v_attendance_type_rec.attendance_type;
	END LOOP;
	IF(v_record_found = FALSE) THEN
		RETURN NULL;
	END IF;
	IF(v_record_count > 1) THEN
		RETURN NULL;
	ELSE
		RETURN v_attendance_type;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
       IF SQLCODE <> -20001 THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_002.enrp_get_acad_p_att');
	IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception(NULL, NULL, fnd_message.get);
       ELSE
         RAISE;
        END IF;
--		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXP');
--		App_Exception.Raise_Exception ;
END;
END enrp_get_acad_p_att;


Function Enrp_Get_Acai_Offer(
  	p_adm_outcome_status IN VARCHAR2 ,
  	p_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2 AS
    	CURSOR  c_aos IS
 		SELECT s_adm_outcome_status
		FROM IGS_AD_OU_STAT aos
		WHERE adm_outcome_status = p_adm_outcome_status;

	v_s_adm_outcome_status IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;

	CURSOR c_aors IS
 		SELECT s_adm_offer_resp_status
 		FROM IGS_AD_OFR_RESP_STAT aors
 		WHERE adm_offer_resp_status = p_adm_offer_resp_status;

 	v_s_adm_offer_resp_status IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
	gv_other_detail 	varchar2(255);
BEGIN
 	OPEN c_aos;
 	FETCH c_aos INTO v_s_adm_outcome_status;
 	IF c_aos%NOTFOUND THEN
  		CLOSE c_aos;
  		RETURN 'N';
 	ELSE
  		IF v_s_adm_outcome_status NOT IN ('OFFER','COND-OFFER') THEN
   			CLOSE c_aos;
   			RETURN 'N';
  		ELSE
   			-- Select the system offer response status. Check that it hasn't lapsed or been rejected.
			OPEN c_aors;
   			FETCH c_aors INTO v_s_adm_offer_resp_status;
   			IF c_aors%NOTFOUND THEN
    				CLOSE c_aos;
    				CLOSE c_aors;
    				RETURN 'N';
   			ELSE
    				IF v_s_adm_offer_resp_status IN ('LAPSED','REJECTED') THEN
     					CLOSE c_aos;
     					CLOSE c_aors;
     					RETURN 'N';
    				ELSE
     					CLOSE c_aos;
     					CLOSE c_aors;
     					RETURN 'Y';
    				END IF;
   			END IF;
  		END IF;
 	END IF;
END enrp_get_acai_offer;


Function Enrp_Get_Att_Dflt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_attendance_type IN VARCHAR2 ,
  p_load_cal_type IN VARCHAR2 ,
  p_eftsu IN OUT NOCOPY NUMBER ,
  p_credit_points OUT NOCOPY NUMBER )
RETURN boolean AS

BEGIN	-- enrp_get_att_dflt
	-- Description: Get the default EFTSU / CP value for an attendance type within
	-- a nominated load calendar type for the first year of the coure. This
	-- routine is designed for use in calculating prospective figures for
	-- admissions fees. The EFTSU is calculated by using the
	-- IGS_ST_DFT_LOAD_APPO.default_eftsu figure.
	-- The CP is calculated by multiplying the proportion of the EFTSU into
	-- 1.000 multiplied by the standard annual load of the first year of the
	-- IGS_PS_COURSE.
DECLARE
	v_atl_rec		IGS_EN_ATD_TYPE_LOAD.default_eftsu%TYPE;
	v_cal_rec		IGS_PS_ANL_LOAD.annual_load_val%TYPE;
	v_crv_rec		IGS_PS_VER.std_annual_load%TYPE;
	v_annual_load		NUMBER;
	CURSOR	c_atl IS
		SELECT	atl.default_eftsu
		FROM	IGS_EN_ATD_TYPE_LOAD	atl
		WHERE	atl.cal_type 		= p_load_cal_type AND
			atl.attendance_type	= p_attendance_type;
	CURSOR	c_cal IS
		SELECT	annual_load_val
		FROM	IGS_PS_ANL_LOAD	cal
		WHERE	cal.course_cd		= p_course_cd AND
			cal.version_number	= p_version_number
		ORDER BY yr_num	ASC;
	CURSOR	c_crv IS
		SELECT	std_annual_load
		FROM	IGS_PS_VER	crv
		WHERE	crv.course_cd		= p_course_cd AND
			crv.version_number	= p_version_number;
BEGIN
	v_annual_load := 0;
	--Select detail from default load apportion
	OPEN c_atl;
	FETCH c_atl INTO v_atl_rec;
	IF (c_atl%NOTFOUND) THEN
		CLOSE c_atl;
		RETURN FALSE;
	END IF;
	CLOSE c_atl;
	IF (v_atl_rec IS NULL) THEN
		RETURN FALSE;
	END IF;
	p_EFTSU := v_atl_rec;
	-- Determine the standard annual load from IGS_PS_COURSE structure tables.
	OPEN c_cal;
	FETCH c_cal INTO v_cal_rec;
	IF (c_cal%FOUND) THEN
		CLOSE c_cal;
		v_annual_load := v_cal_rec;
	ELSE
		CLOSE c_cal;
		OPEN c_crv;
		FETCH c_crv INTO v_crv_rec;
		IF (c_crv%NOTFOUND) THEN
			CLOSE c_crv;
			v_annual_load := 0;
		ELSE
			CLOSE c_crv;
			v_annual_load := v_crv_rec;
		END IF;
	END IF;
	p_credit_points := (p_EFTSU / 1.000) * v_annual_load;
	RETURN TRUE;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_atl%ISOPEN) THEN
			CLOSE c_atl;
		END IF;
		IF (c_cal%ISOPEN) THEN
			CLOSE c_cal;
		END IF;
		IF (c_crv%ISOPEN) THEN
			CLOSE c_crv;
		END IF;
	RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
       if SQLCODE <> -20001 then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_002.enrp_get_att_dflt');
	IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception(Null, Null, fnd_message.get);
       else
         RAISE;
        end if;
--		Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXP');
--		App_Exception.Raise_Exception ;
END enrp_get_att_dflt;


Procedure Enrp_Get_Crs_Exists(
  P_PERSON_ID IN NUMBER ,
  P_COURSE_CD IN VARCHAR2 ,
  P_EFFECTIVE_DT IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_check_hecs IN boolean ,
  p_check_unitset IN boolean ,
  p_check_notes IN boolean ,
  p_check_research IN boolean ,
  p_check_prenrol IN boolean ,
  p_hecs_exists OUT NOCOPY boolean ,
  p_unitset_exists OUT NOCOPY boolean ,
  p_notes_exists OUT NOCOPY boolean ,
  p_research_exists OUT NOCOPY boolean ,
  p_prenrol_exists OUT NOCOPY boolean )
AS
BEGIN	-- enrp_get_crs_exists
	-- Return output parameters indicating whether or not data exists on IGS_PE_PERSON
	-- IGS_PS_COURSE attempt detail tables for the specified IGS_PE_PERSON ID.
DECLARE
	v_check			VARCHAR2(1);
	CURSOR c_scan
	IS
		SELECT	'x'
		FROM	IGS_AS_SC_ATMPT_NOTE	scan
		WHERE	scan.person_id 		= p_person_id AND
			Course_cd 		= p_course_cd;
	CURSOR c_susa
	IS
		SELECT	'x'
		FROM	IGS_AS_SU_SETATMPT susa
		WHERE	susa.person_id 			= p_person_id AND
			susa.course_cd			= p_course_cd AND
			susa.student_confirmed_ind 	= 'Y' AND
			susa.end_dt 			IS NULL;
	CURSOR c_scho
	IS
		SELECT	'x'
		FROM	IGS_EN_STDNTPSHECSOP scho
		WHERE	scho.person_id		= p_person_id AND
			scho.course_cd		= p_course_cd AND
			scho.start_dt 		<= p_effective_dt AND
			(scho.end_dt 		IS NULL OR
			scho.end_dt 		> p_effective_dt);
	CURSOR c_ca
	IS
		SELECT	'x'
		FROM	IGS_RE_CANDIDATURE ca
		WHERE	ca.person_id 		= p_person_id AND
			ca.sca_course_cd	= p_course_cd;
	CURSOR c_scae
	IS
		SELECT	'x'
		FROM	IGS_AS_SC_ATMPT_ENR scae
		WHERE	scae.person_id = p_person_id AND
			scae.course_cd = p_course_cd AND
			IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
					p_acad_cal_type,
					p_acad_sequence_number,
					scae.cal_type,
					scae.ci_sequence_number,
					'N') = 'Y';
BEGIN
	-- Initialise output parameters.
	p_notes_exists 		:= FALSE;
	p_unitset_exists 	:= FALSE;
	p_hecs_exists		:= FALSE;
	p_research_exists 	:= FALSE;
	p_prenrol_exists	:= FALSE;
	IF p_check_notes = TRUE THEN
		-- Check for the existence of a IGS_PE_PERSON Notes record.
		OPEN c_scan;
		FETCH c_scan INTO v_check;
		IF c_scan%FOUND THEN
			CLOSE c_scan;
			p_notes_exists := TRUE;
		ELSE
			CLOSE c_scan;
		END IF;
	END IF;
	IF p_check_unitset = TRUE THEN
		-- Check for the existence of a Student IGS_PS_UNIT Set Attempt record.
		OPEN c_susa;
		FETCH c_susa INTO v_check;
		IF c_susa%FOUND THEN
			CLOSE c_susa;
			p_unitset_exists := TRUE;
		ELSE
			CLOSE c_susa;
		END IF;
	END IF;
	IF p_check_hecs = TRUE THEN
		-- Check for the existence of a Student IGS_PS_COURSE HECS Option record.
		OPEN c_scho;
		FETCH c_scho INTO v_check;
		IF c_scho%FOUND THEN
			CLOSE c_scho;
			p_hecs_exists := TRUE;
		ELSE
			CLOSE c_scho;
		END IF;
	END IF;
	IF p_check_research = TRUE THEN
		-- Check for the existence of a research IGS_RE_CANDIDATURE record
		OPEN c_ca;
		FETCH c_ca INTO v_check;
		IF c_ca%FOUND THEN
			CLOSE c_ca;
			p_research_exists := TRUE;
		ELSE
			CLOSE c_ca;
		END IF;
	END IF;
	IF p_check_prenrol = TRUE AND
			p_acad_cal_type IS NOT NULL AND
			p_acad_sequence_number IS NOT NULL THEN
		-- Check for the existence of a Student IGS_PS_COURSE Enrolment record
		OPEN c_scae;
		FETCH c_scae INTO v_check;
		IF c_scae%FOUND THEN
			CLOSE c_scae;
			p_prenrol_exists := TRUE;
		ELSE
			CLOSE c_scae;
		END IF;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_scan%ISOPEN THEN
			CLOSE c_scan;
		END IF;
		IF c_susa%ISOPEN THEN
			CLOSE c_susa;
		END IF;
		IF c_scho%ISOPEN THEN
			CLOSE c_scho;
		END IF;
		IF c_ca%ISOPEN THEN
			CLOSE c_ca;
		END IF;
		IF c_scae%ISOPEN THEN
			CLOSE c_scae;
		END IF;
	RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_002.enrp_get_crs_exists');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END enrp_get_crs_exists;

END IGS_EN_GEN_002;

/
