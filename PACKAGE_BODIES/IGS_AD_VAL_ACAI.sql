--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACAI" AS
 /* $Header: IGSAD22B.pls 120.6 2006/05/30 10:58:04 pbondugu ship $ */
-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
--
-- bug id : 1956374
-- sjadhav , 28-aug-2001
-- removed function enrp_val_hpo_closed
-- change  igs_ad_val_acai.enrp_val_hpo_closed
-- to      igs_en_val_scho.enrp_val_hpo_closed
--
--smadathi    28-AUG-2001     Bug No. 1956374 .The exception part removed from genp_val_staff_prsn
  --msrinivi bug 1956374. pointing finp_val_fc_closed to igs_fi_val_fcm

  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed function enrp_val_ec_closed
  -- change  igs_ad_val_acai.enrp_val_ec_closed
  -- to      igs_ad_val_ecm.enrp_val_ec_closed

  --samaresh    21-DEC-2001     Bug No. 2158524 . The cursor c_ar has been modified as the
  --                            the table IGS_AD_APP_ REQ has been moved from application
  --                            instance level to application level
  -- ssawhney   24-oct-2002     admp_val_acai_comp : SWS104 build 2630860, AD_ACAD_HONOR reference moved to PE.
  --				removed DEFAULTs in declarations and parameters
  --hreddych    13-dec-2002     function admp_val_acai_insert modified to check for completed application
  --                            also when called with the parameter p_validate_aa_only set to TRUE .
  --sarakshi    27-Feb-2003    Enh#2797116,modified procedure admp_val_acai_coo ,added delete_falg check in the where clause
  --                           of the cursor c_coo
  -- rghosh     03-mar-2003   Changed the signature of the function ADMP_VAL_DFRMNT_CAL (bug#2765260)
  -------------------------------------------------------------------------------------------

  --
  -- Validate insert of an IGS_AD_PS_APPL_INST record.

 FUNCTION admp_val_acai_insert(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_pref_limit IN NUMBER ,
  p_validate_aa_only IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	gv_validate_aa_only		VARCHAR2(1);
  BEGIN 	-- admp_val_acai_insert
  	-- Routine to validate the insert of an IGS_AD_PS_APPL_INST record.
  DECLARE
  	cst_completed			CONSTANT 	VARCHAR2(9) := 'COMPLETED';
  	cst_withdrawn			CONSTANT 	VARCHAR2(9) := 'WITHDRAWN';
  	cst_warn			CONSTANT 	VARCHAR2(1) := 'W';
  	cst_error			CONSTANT 	VARCHAR2(1) := 'E';
  	v_s_adm_appl_status		IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  	v_message_name			VARCHAR2(30);
  	v_return			BOOLEAN := TRUE;
  	CURSOR c_acaiv (
  			cp_person_id			IGS_AD_PS_APPL_INST.person_id%TYPE,
  			cp_course_cd			IGS_AD_PS_APPL_INST.course_cd%TYPE,
  			cp_admission_appl_number	IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
  			cp_acai_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE,
  			cp_location_cd			IGS_AD_PS_APPL_INST.location_cd%TYPE,
  			cp_attendance_mode		IGS_AD_PS_APPL_INST.attendance_mode%TYPE,
  			cp_attendance_type	   	IGS_AD_PS_APPL_INST.attendance_type%TYPE,
  			cp_unit_set_cd			IGS_AD_PS_APPL_INST.unit_set_cd%TYPE,
  			cp_us_version_number		IGS_AD_PS_APPL_INST.us_version_number%TYPE,
  			cp_adm_cal_type		   	IGS_AD_APPL.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number  	IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
  		SELECT	'x'
	        FROM    IGS_AD_APPL aav, IGS_AD_PS_APPL_INST acaiv
  		WHERE	 aav.person_id = acaiv.person_id AND
	                aav.admission_appl_number = acaiv.admission_appl_number AND
			acaiv.person_id			= cp_person_id AND
  			acaiv.course_cd			= cp_course_cd AND
  			(acaiv.admission_appl_number	<> cp_admission_appl_number OR
  			 acaiv.sequence_number		<> cp_acai_sequence_number) AND
  			NVL(acaiv.location_cd,'NULL')	= NVL(cp_location_cd,'NULL') AND
  			NVL(acaiv.attendance_mode,'NULL') = NVL(cp_attendance_mode,'NULL') AND
  			NVL(acaiv.attendance_type,'NULL') = NVL(cp_attendance_type,'NULL') AND
  			NVL(acaiv.unit_set_cd, 'NULL')	= NVL(cp_unit_set_cd, 'NULL') AND
  			NVL(acaiv.us_version_number,0)	= NVL(cp_us_version_number,0) AND
  	                NVL(acaiv.adm_cal_type, aav.adm_cal_type) = cp_adm_cal_type AND
  	                NVL(acaiv.adm_ci_sequence_number, aav.adm_ci_sequence_number)
  			    = cp_adm_ci_sequence_number AND
                        -- Check for CANCELLED added for bug 2678766
                        NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(acaiv.adm_outcome_status),'x') <> 'CANCELLED';

  -- Added the following cursor definitions for UK Bug 2462198
  -- by rrengara on 24-JUL-2002

	CURSOR c_acaiv_uk (
	        	cp_person_id			IGS_AD_PS_APPL_INST.person_id%TYPE,
  			cp_course_cd			IGS_AD_PS_APPL_INST.course_cd%TYPE,
  			cp_admission_appl_number	IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
  			cp_acai_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE,
  			cp_location_cd			IGS_AD_PS_APPL_INST.location_cd%TYPE,
  			cp_attendance_mode		IGS_AD_PS_APPL_INST.attendance_mode%TYPE,
  			cp_attendance_type	   	IGS_AD_PS_APPL_INST.attendance_type%TYPE,
  			cp_unit_set_cd			IGS_AD_PS_APPL_INST.unit_set_cd%TYPE,
  			cp_us_version_number		IGS_AD_PS_APPL_INST.us_version_number%TYPE,
  			cp_adm_cal_type		   	IGS_AD_APPL.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number  	IGS_AD_APPL.adm_ci_sequence_number%TYPE,
			cp_choice_number                IGS_AD_APPL.choice_number%TYPE,
			cp_alt_appl_id                  IGS_AD_APPL.alt_appl_id%TYPE) IS
         	 SELECT 'x'
	         FROM   IGS_AD_APPL aav, IGS_AD_PS_APPL_INST acaiv
	         WHERE  aav.person_id = acaiv.person_id AND
	                aav.admission_appl_number = acaiv.admission_appl_number AND
                        acaiv.person_id			= cp_person_id AND
  	                acaiv.course_cd			= cp_course_cd AND
           	        (acaiv.admission_appl_number	<> cp_admission_appl_number OR
  	                  acaiv.sequence_number		<> cp_acai_sequence_number) AND
           	        NVL(acaiv.location_cd,'NULL')	= NVL(cp_location_cd,'NULL') AND
  	                NVL(acaiv.attendance_mode,'NULL') = NVL(cp_attendance_mode,'NULL') AND
           	        NVL(acaiv.attendance_type,'NULL') = NVL(cp_attendance_type,'NULL') AND
  	                NVL(acaiv.unit_set_cd, 'NULL')	= NVL(cp_unit_set_cd, 'NULL') AND
           	        NVL(acaiv.us_version_number,0)	= NVL(cp_us_version_number,0) AND
  	                NVL(acaiv.adm_cal_type, aav.adm_cal_type) = cp_adm_cal_type AND
  	                NVL(acaiv.adm_ci_sequence_number, aav.adm_ci_sequence_number)
                            = cp_adm_ci_sequence_number AND
         	        NVL(aav.choice_number, 0) = NVL(cp_choice_number,0) AND
	                NVL(aav.alt_appl_id, 0) = NVL(cp_alt_appl_id,0) AND
                        -- Check for CANCELLED added for bug 2678766
                        NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(acaiv.adm_outcome_status),'x') <> 'CANCELLED';

	  CURSOR c_aav_uk(cp_person_id igs_ad_appl.person_id%TYPE, cp_admission_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
	  SELECT
	    choice_number, alt_appl_id
	  FROM
	    igs_ad_appl aav
	  WHERE
	    aav.person_id = cp_person_id
	    AND aav.admission_appl_number = cp_admission_appl_number;

	  c_aav_uk_rec c_aav_uk%ROWTYPE;

	  CURSOR c_igs_pe_ucas(cp_n_person_id igs_pe_person.person_id%TYPE) IS
          SELECT
            api_person_id
          FROM
            igs_pe_alt_pers_id
          WHERE
            sysdate BETWEEN start_dt AND NVL(end_dt, sysdate)
	    AND person_id_type = 'UCASID'
	    AND pe_person_id = cp_n_person_id ;

          rec_c_igs_pe_ucas     c_igs_pe_ucas%ROWTYPE;

    -- End definitions for UK Bug 2462198   by rrengara on 24-JUL-2002


  	CURSOR c_acaiv_aa (
  			cp_person_id			IGS_AD_PS_APPL_INST.person_id%TYPE,
  			cp_course_cd			IGS_AD_PS_APPL_INST.course_cd%TYPE,
  			cp_admission_appl_number	IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
  			cp_acai_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE,
  			cp_location_cd			IGS_AD_PS_APPL_INST.location_cd%TYPE,
  			cp_attendance_mode		IGS_AD_PS_APPL_INST.attendance_mode%TYPE,
  			cp_attendance_type	   	IGS_AD_PS_APPL_INST.attendance_type%TYPE,
  			cp_unit_set_cd			IGS_AD_PS_APPL_INST.unit_set_cd%TYPE,
  			cp_us_version_number		IGS_AD_PS_APPL_INST.us_version_number%TYPE,
  			cp_adm_cal_type		   	IGS_AD_APPL.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number  	IGS_AD_APPL.adm_ci_sequence_number%TYPE) IS
  		SELECT	aa.adm_appl_status
  		FROM	IGS_AD_PS_APPL_INST		acaiv,
  			IGS_AD_APPL			aa
  		WHERE	acaiv.person_id			= cp_person_id AND
  			acaiv.nominated_course_cd			= cp_course_cd AND
  			(acaiv.admission_appl_number	<> cp_admission_appl_number OR
  			 acaiv.sequence_number		<> cp_acai_sequence_number) AND
  			NVL(acaiv.location_cd,'NULL')	= NVL(cp_location_cd,'NULL') AND
  			NVL(acaiv.attendance_mode,'NULL') = NVL(cp_attendance_mode,'NULL') AND
  			NVL(acaiv.attendance_type,'NULL') = NVL(cp_attendance_type,'NULL') AND
  			NVL(acaiv.unit_set_cd, 'NULL')	= NVL(cp_unit_set_cd, 'NULL') AND
  			NVL(acaiv.us_version_number,0)	= NVL(cp_us_version_number,0) AND
  			(NVL(acaiv.adm_cal_type,aa.adm_cal_type)	<> cp_adm_cal_type OR
  			 NVL(acaiv.adm_ci_sequence_number,aa.adm_ci_sequence_number) <> cp_adm_ci_sequence_number) AND
  			acaiv.person_id			= aa.person_id AND
  			acaiv.admission_appl_number	= aa.admission_appl_number;

  	CURSOR c_aal (
  		cp_person_id			IGS_AD_PS_APPL_INST.person_id%TYPE,
  		cp_admission_appl_number	IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
        IS
  		SELECT	'x'
  		FROM	IGS_AD_APPL_LTR		aal
  		WHERE	aal.person_id			= cp_person_id AND
  			aal.admission_appl_number	= cp_admission_appl_number;
  	CURSOR c_aa (
  		cp_person_id			IGS_AD_APPL.person_id%TYPE,
  		cp_admission_appl_number	IGS_AD_APPL.admission_appl_number%TYPE) IS
  		SELECT	aas.s_adm_appl_status
  		FROM	IGS_AD_APPL 			aa,
  			IGS_AD_APPL_STAT 		aas
  		WHERE	aa.person_id 			= cp_person_id AND
  			aa.admission_appl_number 	= cp_admission_appl_number AND
  			aas.adm_appl_status 		= aa.adm_appl_status;
  BEGIN
  	p_message_name := NULL;
  	p_return_type := NULL;
  	-- Validate the system admission application status.
  	OPEN	c_aa(
  			p_person_id,
  			p_admission_appl_number);
  	FETCH	c_aa	INTO v_s_adm_appl_status;
  	IF(c_aa%FOUND AND
  			v_s_adm_appl_status IN (cst_completed,cst_withdrawn)) THEN
  		CLOSE c_aa;
  		p_message_name := 'IGS_AD_NOTINS_ADMPRG_APPL';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_aa;
  	IF p_validate_aa_only = FALSE THEN
  		-- Validate preferences.
  		IF(IGS_AD_VAL_ACA.admp_val_pref_limit (
  					p_person_id,
  					p_admission_appl_number,
  					p_nominated_course_cd,
  					p_acai_sequence_number,
  					p_s_admission_process_type,
  					p_pref_limit,
  					v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;

		  -- Added the following logics  for UK Bug 2462198
		  -- If the UK profile is switched on and the ucas id is present
		  -- for the applicant then consider the choice number also
		  -- for duplicate application instance check
		  -- otherwise do not consider the choice number in duplicate check
		  -- by rrengara on 24-JUL-2002
                  -- Also added alt_appl_id for duplicate check when UK profile
                  -- is switched on for bug 2664410 by knag

		OPEN c_igs_pe_ucas(p_person_id);
		FETCH c_igs_pe_ucas INTO rec_c_igs_pe_ucas;

                IF FND_PROFILE.VALUE('OSS_COUNTRY_CODE') = 'GB' AND c_igs_pe_ucas%FOUND THEN
			OPEN c_aav_uk(p_person_id, p_admission_appl_number);
			FETCH c_aav_uk INTO c_aav_uk_rec;
                        CLOSE c_aav_uk;
			FOR v_acaiv_rec_uk IN c_acaiv_uk(
  					p_person_id,
  					p_course_cd,
  					p_admission_appl_number,
  					p_acai_sequence_number,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_unit_set_cd,
  					p_us_version_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
					c_aav_uk_rec.choice_number,
					c_aav_uk_rec.alt_appl_id) LOOP
  					p_message_name := 'IGS_AD_ANOTHER_ADMAPPL_EXISTS';
  					p_return_type := cst_error;
  					v_return := FALSE;
  					EXIT;
  			END LOOP;
		ELSE
 			-- Validate for a matching admission course application instance for the
  			-- IGS_PE_PERSON in the same admission period.
  			FOR v_acaiv_rec IN c_acaiv(
  				p_person_id,
  				p_course_cd,
  				p_admission_appl_number,
  				p_acai_sequence_number,
  				p_location_cd,
  				p_attendance_mode,
  				p_attendance_type,
  				p_unit_set_cd,
  				p_us_version_number,
  				p_adm_cal_type,
  				p_adm_ci_sequence_number) LOOP
  				p_message_name := 'IGS_AD_ANOTHER_ADMAPPL_EXISTS';
  				p_return_type := cst_error;
  				v_return := FALSE;
  				EXIT;
  			END LOOP;
		END IF;

		CLOSE c_igs_pe_ucas;

  		IF(v_return = TRUE) THEN
  			-- Validate for a matching admission course application instance for the
  			-- IGS_PE_PERSON
  			-- in a different admission period.
  			FOR v_acaiv_aa_rec IN c_acaiv_aa(
  					p_person_id,
  					p_course_cd,
  					p_admission_appl_number,
  					p_acai_sequence_number,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_unit_set_cd,
  					p_us_version_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number) LOOP
  				IF(NVL(IGS_AD_GEN_007.ADMP_GET_SAAS(
  						v_acaiv_aa_rec.adm_appl_status),'NULL')
  						NOT IN 	(cst_completed, cst_withdrawn)) THEN
  					p_message_name := 'IGS_AD_ADMPRG_MATCH_PRG';
  					p_return_type := cst_warn;
  					v_return := FALSE;
  					EXIT;
  				END IF;
  			END LOOP;
  		END IF;
  	END IF;
  	IF(v_return = TRUE) THEN
  		-- Validate if correspondence has been sent.
  		FOR v_aal_rec IN c_aal(
  					p_person_id,
  					p_admission_appl_number) LOOP
  			p_message_name := 'IGS_AD_COR_SET_ADMAPPL';
  			p_return_type := cst_warn;
  			v_return := FALSE;
  			EXIT;
  		END LOOP;
  	END IF;
  	IF(v_return = TRUE) THEN
  		RETURN TRUE;
  	ELSE
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_insert');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_insert;
  --
  -- Validate update of an IGS_AD_PS_APPL_INST record.
  FUNCTION admp_val_acai_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_update_non_enrol_detail_ind OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--admp_val_acai_update
  	--This module validates update of an IGS_AD_PS_APPL_INST record.
  DECLARE
  	v_s_appl_inst_status	IGS_AD_APPL_STAT.s_adm_appl_status%TYPE;
  	v_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE;
	cst_withdrawn		CONSTANT VARCHAR2(10) := 'WITHDRAWN';
  	CURSOR c_sca (
  		cp_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE,
  		cp_admission_appl_number
  					IGS_EN_STDNT_PS_ATT.adm_admission_appl_number%TYPE,
  		cp_nominated_course_cd	IGS_EN_STDNT_PS_ATT.adm_nominated_course_cd%TYPE,
  		cp_acai_sequence_number	IGS_EN_STDNT_PS_ATT.adm_sequence_number%TYPE) IS
  	SELECT	sca.person_id
  	FROM	IGS_EN_STDNT_PS_ATT sca
  	WHERE	sca.person_id = cp_person_id AND
  		sca.adm_admission_appl_number IS NOT NULL AND
  		sca.adm_admission_appl_number = cp_admission_appl_number AND
  		sca.adm_nominated_course_cd IS NOT NULL AND
  		sca.adm_nominated_course_cd = cp_nominated_course_cd AND
  		sca.adm_sequence_number IS NOT NULL AND
  		sca.adm_sequence_number = cp_acai_sequence_number AND
  		sca.student_confirmed_ind = 'Y';

	CURSOR c_ais IS									--arvsrini igsm
	SELECT appl_inst_status
	FROM IGS_AD_PS_APPL_INST
	WHERE person_id= p_person_id AND
	      admission_appl_number= p_admission_appl_number AND
	      nominated_course_cd= p_nominated_course_cd AND
	      sequence_number =p_acai_sequence_number;

  BEGIN
  	--Set the default message number
  	p_message_name := NULL;
  	-- Set the default update status indicator.
  	p_update_non_enrol_detail_ind := 'N';
  	--Validate the system admission application status

	OPEN c_ais;									--arvsrini igsm
	FETCH c_ais INTO v_s_appl_inst_status;
	CLOSE c_ais;

	IF v_s_appl_inst_status IS NOT NULL THEN
		v_s_appl_inst_status := NVL(IGS_AD_GEN_007.ADMP_GET_SAAS(
  					v_s_appl_inst_status), 'NULL');
	END IF;

	IF v_s_appl_inst_status = cst_withdrawn THEN
		p_message_name := 'IGS_AD_APPL_INST_WITHD';
  		p_update_non_enrol_detail_ind := 'N';
		RETURN FALSE;
	ELSIF igs_ad_gen_002.Is_App_Inst_Complete(p_person_id, p_admission_appl_number, p_nominated_course_cd, p_acai_sequence_number) = 'Y' THEN
		p_message_name := 'IGS_AD_APPL_INST_COMPL';
  		p_update_non_enrol_detail_ind := 'N';
		RETURN FALSE;
	END IF;										--arvsrini igsm





  	-- Validate if the admission application has been pre-enrolled and confirmed.
  	IF p_person_id IS NOT NULL AND
  			p_admission_appl_number IS NOT NULL AND
  			p_nominated_course_cd IS NOT NULL AND
  			p_acai_sequence_number IS NOT NULL THEN
  		OPEN c_sca (
  			p_person_id,
  			p_admission_appl_number,
  			p_nominated_course_cd,
  			p_acai_sequence_number);
  		FETCH c_sca INTO v_person_id;
  		IF c_sca%FOUND = TRUE THEN
  			CLOSE c_sca;
  			p_message_name := 'IGS_AD_CANNOT_UPD_ENR_INFO';
  			p_update_non_enrol_detail_ind := 'Y';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca;
  	END IF;
  	RETURN TRUE;
  END;
   EXCEPTION
  	WHEN OTHERS THEN
  		         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
				 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_update');
				 IGS_GE_MSG_STACK.ADD;
				 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_update;
  --
  -- Validate delete of an IGS_AD_PS_APPL_INST record.
  FUNCTION admp_val_acai_delete(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_delete
  	-- Validate delete of an IGS_AD_PS_APPL_INST record
  DECLARE
  	CURSOR c_aal IS
  		SELECT	'x'
  		FROM	IGS_AD_APPL_LTR
  		WHERE	person_id 		= p_person_id AND
  			admission_appl_number 	= p_admission_appl_number;
  	CURSOR c_aas IS
  		SELECT 	'x'
  		FROM	IGS_AD_APPL 	aa,
  			IGS_AD_APPL_STAT aas
  		WHERE	aa.person_id 			= p_person_id AND
  			aa.admission_appl_number 	= p_admission_appl_number AND
  			aas.adm_appl_status 		= aa.adm_appl_status AND
  			aas.s_adm_appl_status 		= 'WITHDRAWN';
  	v_aal_exists	VARCHAR2(1);
  	v_aas_exists	VARCHAR2(1);
  	cst_error	CONSTANT VARCHAR2(1) := 'E';
  	cst_warn	CONSTANT VARCHAR2(1) := 'W';
  	v_s_adm_outcome_status	igs_ad_ou_stat.s_adm_outcome_status%TYPE := IGS_AD_GEN_008.ADMP_GET_SAOS(p_adm_outcome_status);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the system admission application status.
  	OPEN c_aas;
  	FETCH c_aas INTO v_aas_exists;
  	IF c_aas%FOUND THEN
  		CLOSE c_aas;
  		p_message_name := 'IGS_AD_NOTDEL_ADMPRG_APPL';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_aas;
  	-- Validate the system admission outcome status
  	IF NVL(v_s_adm_outcome_status, 'NULL') <> 'PENDING' THEN
  		p_message_name := 'IGS_AD_CANDEL_ADMPRG_APPL';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Validate if correspondence has been sent
  	OPEN c_aal;
  	FETCH c_aal INTO v_aal_exists;
  	IF c_aal%FOUND THEN
  		CLOSE c_aal;
  		p_message_name := 'IGS_AD_CANDEL_ADMPRG_COR_EXIS';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_aal;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_aas%ISOPEN THEN
  			CLOSE c_aas;
  		END IF;
  		IF c_aal%ISOPEN THEN
  			CLOSE c_aal;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
    	WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
		   FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_delete');
		   IGS_GE_MSG_STACK.ADD;
		   APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_delete;
  --
  -- Validate change of preferences.
  FUNCTION admp_val_chg_of_pref(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_chg_of_pref
  	-- Description: Validate change of preferences
  DECLARE
  	v_chng_of_pref_dt_alias
  				IGS_AD_CAL_CONF.adm_appl_chng_of_pref_dt_alias%TYPE;
  	v_chng_of_pref_dt	DATE;
  	CURSOR	c_sacco IS
  		SELECT	sacco.adm_appl_chng_of_pref_dt_alias
  		FROM	IGS_AD_CAL_CONF	sacco
  		WHERE	sacco.s_control_num 	= 1;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_sacco;
  	FETCH c_sacco INTO v_chng_of_pref_dt_alias;
  	CLOSE c_sacco;
  	IF v_chng_of_pref_dt_alias IS NOT NULL THEN
  		v_chng_of_pref_dt := IGS_AD_GEN_003.ADMP_GET_ADM_PERD_DT (
  						v_chng_of_pref_dt_alias,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type);
  		IF v_chng_of_pref_dt IS NOT NULL AND
  			TRUNC(v_chng_of_pref_dt) < TRUNC(SYSDATE) THEN
  			p_message_name := 'IGS_AD_PREFS_NOT_CHANGED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sacco%ISOPEN) THEN
  			CLOSE c_sacco;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_chg_of_pref');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_chg_of_pref;
  --

  -- Validate the course code of the admission application.
  FUNCTION admp_val_acai_course(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2,
  p_crv_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_course
  	-- Validate the course code of the admission application.
  	-- Validations are performed against the course version
  	-- and against the course offering option.
  DECLARE
  	CURSOR c_crv IS
  		SELECT	version_number
  		FROM	IGS_PS_VER
  		WHERE	course_cd 	= p_course_cd;
  	v_crv_rec		c_crv%ROWTYPE;
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_record_found		BOOLEAN := FALSE;
  	v_exit_loop		BOOLEAN := FALSE;
  	v_message_name		VARCHAR2(30) := NULL;
  	v_version_number	VARCHAR2(3);
  	v_return_type		VARCHAR2(1);
  	v_late_ind		VARCHAR2(1)	:= 'N';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the input parameters
  	IF p_admission_cat IS NULL OR
  			p_s_admission_process_type IS NULL OR
  			p_acad_cal_type IS NULL OR
  			p_acad_ci_sequence_number IS NULL OR
  			p_adm_cal_type IS NULL OR
  			p_adm_ci_sequence_number IS NULL THEN
  		p_message_name := 'IGS_AD_PRG_CANVALID_ADMCAT';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	FOR v_crv_rec IN c_crv LOOP
  		-- Restrict the IGS_PS_VER records to match
  		-- on input parameters.
  		IF p_version_number IS NULL OR
  				p_version_number = v_crv_rec.version_number THEN
  			v_message_name := NULL;
  			v_return_type := NULL;
  			v_record_found := TRUE;
  			-- Validate the course version data
  			IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  							p_course_cd,
  							v_crv_rec.version_number,
  							p_s_admission_process_type,
  							p_offer_ind,
  							v_message_name) = FALSE THEN
  				v_return_type := cst_error;
  				GOTO continue;
  			END IF;
  			IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat(
  							p_course_cd,
  							v_crv_rec.version_number,
  							p_acad_cal_type,
  							NULL,
  							NULL,
  							NULL,
  							p_admission_cat,
  							v_message_name) = FALSE THEN
  				v_return_type := cst_error;
  				GOTO continue;
  			END IF;
  			IF IGS_AD_VAL_ACAI.admp_val_acai_coo(
  							p_course_cd,
  							v_crv_rec.version_number,
  							NULL,
  							NULL,
  							NULL,
  							p_acad_cal_type,
  							p_acad_ci_sequence_number,
  							p_adm_cal_type,
  							p_adm_ci_sequence_number,
  							p_admission_cat,
  							p_s_admission_process_type,
  							p_offer_ind,
  							p_appl_dt,
  							p_late_appl_allowed,
  							'N',	-- Deferred application.
  							v_message_name,
  							v_return_type,
  							v_late_ind) = FALSE THEN
  				IF v_return_type = cst_error THEN
  					GOTO continue;
  				END IF;
  			END IF;
  			-- If this point is reached, then all error validations have been successful,
  			-- however, there may be a warning
  			p_crv_version_number := v_crv_rec.version_number;
  			p_message_name := v_message_name;
  			p_return_type := v_return_type;
  			v_exit_loop := TRUE;
  			EXIT;
  		END IF;
  		<< continue >>
  			NULL;
  	END LOOP; -- v_crv_rec IN c_crv
  	IF v_exit_loop  THEN
  		IF v_message_name IS NULL THEN
  			RETURN TRUE;
  		ELSE
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF NOT v_record_found THEN
  		p_return_type := NULL;
  		RETURN TRUE;
  	END IF;
  	IF p_version_number IS NOT NULL THEN
  		-- Only one course version was processed.
  		p_message_name := v_message_name;
  		p_return_type := v_return_type;
  	ELSE
  		p_message_name := 'IGS_AD_PRG_NOTVALID_ADMAPPL';
  		p_return_type := cst_error;
  	END IF;
  	-- Return the default value
  	RETURN FALSE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_course');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_course;
  --
  -- Perform encumbrance check for admission_course_appl_instance.course_cd
  FUNCTION admp_val_acai_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_encmb_chk_ind IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_encmb
  	-- Perform encumbrance checks for the admission_course_appl_instance.course_cd.
  DECLARE
  	v_message_name		VARCHAR2(30) := NULL;
  	v_encmb_check_dt	DATE;
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_course_encmb_chk_ind = 'Y' THEN
  		-- Get the encumbrance checking date.
  		v_encmb_check_dt := NVL(IGS_AD_GEN_006.ADMP_GET_ENCMB_DT(
  						p_adm_cal_type,
  						p_adm_ci_sequence_number),SYSDATE);	--arvsrini igsm
 /* 		IF v_encmb_check_dt IS NULL THEN

			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_ENCUMB_CANNOT_PERFORM';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_ENCUMB_CHK_NOT_PERFORM';
  				p_return_type := cst_warn;
  			END IF;
  			RETURN FALSE;
  		END IF;
  */
		-- Validate for exclusion or suspension from the course
  		IF IGS_EN_VAL_ENCMB.enrp_val_excld_crs(
  						p_person_id,
  						p_course_cd,
  						v_encmb_check_dt,
  						v_message_name) = FALSE THEN
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_PRSN_ENCUMB_EXCLUDING';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_PRSN_ENCUMBRAN_SUSPEND';
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
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_encmb');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_encmb;
  --
  -- Validate course appl process type against the student course attempt.
  FUNCTION admp_val_aca_sca(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_aca_process
  	-- Validate that the nominated course admission application is
  	-- valid for the admission application system process type and
  	-- any existing course attempts the student may have.
  DECLARE
  	CURSOR c_sca IS
  		SELECT	course_attempt_status,
  			fee_cat,
  			correspondence_cat,
  			discontinued_dt
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id AND
  			course_cd = p_course_cd;
  	CURSOR c_fcm (
  		cp_fee_cat		IGS_EN_STDNT_PS_ATT.fee_cat%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_FI_FEE_CAT_MAP
  		WHERE	admission_cat 	= p_admission_cat AND
  			fee_cat		= cp_fee_cat;

  	CURSOR c_ccm (
  		cp_correspondence_cat		IGS_EN_STDNT_PS_ATT.correspondence_cat%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_CO_CAT_MAP
  		WHERE	admission_cat 		= p_admission_cat AND
  			correspondence_cat	= cp_correspondence_cat;

  	CURSOR c_scae IS
  		SELECT	enrolment_cat
  		FROM	IGS_AS_SC_ATMPT_ENR 	scae,
  			IGS_CA_INST 		ci
  		WHERE	person_id		= p_person_id AND
  			course_cd		= p_course_cd AND
  			scae.cal_type		= ci.cal_type AND
  			scae.ci_sequence_number = ci.sequence_number
  		ORDER BY ci.start_dt DESC;
  	CURSOR c_ecm (
  		cp_enrolment_cat	IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_EN_CAT_MAPPING
  		WHERE	admission_cat		= p_admission_cat AND
  			enrolment_cat		= cp_enrolment_cat ;
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_sca_rec		c_sca%ROWTYPE;
  	v_scae_rec		c_scae%ROWTYPE;
  	v_fcm_exists		VARCHAR2(1);
  	v_ccm_exists		VARCHAR2(1);
  	v_ecm_exists		VARCHAR2(1);
  	v_message_name		VARCHAR2(30) := NULL;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_sca;
  	FETCH c_sca INTO v_sca_rec;
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE c_sca;
  		IF p_s_admission_process_type = 'RE-ADMIT' THEN
  			p_return_type := cst_error;
  			p_message_name := 'IGS_AD_APPL_NOT_EXISTING_STUD';
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca;
  	-- Validate re-admission
  	IF p_s_admission_process_type <> 'RE-ADMIT' THEN
  		-- Validate against all other system admission process types
  		IF v_sca_rec.course_attempt_status NOT IN ('DELETED',  'UNCONFIRM') THEN
  			p_return_type := cst_error;
  			p_message_name := 'IGS_AD_APPL_EXISTING_STUDPRG';
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END IF;
  	IF (v_sca_rec.course_attempt_status <> 'DISCONTIN')  THEN
  		p_message_name := 'IGS_AD_APPL_CANNOT_READMITTED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Validate against any existing student course transfer details
  	IF IGS_AD_VAL_ACA.enrp_val_sca_trnsfr(
  					p_person_id,
  					p_course_cd,
  					NULL,
  					'A',
  					v_message_name) = FALSE THEN
  		p_return_type := cst_error;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Only validate the student course attempt fee category when
  	-- none has been specified for the admission course application instance.
  	IF p_fee_cat IS NULL AND
  		v_sca_rec.fee_cat IS NOT NULL THEN
  		-- Validate the Student course Attempt Fee Category Mapping.
  		OPEN c_fcm (
  			v_sca_rec.fee_cat);
  		FETCH c_fcm INTO v_fcm_exists;
  		IF (c_fcm%NOTFOUND) THEN
  			CLOSE c_fcm;
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_FEECAT_PRGAPPL';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_FEECAT_PRG_APPL_READM';
  				p_return_type := cst_warn;
  			END IF;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_fcm;
  	END IF;
  	-- Only validate the student course attempt correspondence category
  	-- when none has been specified for the admission course application instance.
  	IF p_correspondence_cat IS NULL AND
  			v_sca_rec.correspondence_cat IS NOT NULL THEN
  		-- Validate the Student course Attempt Correspondence Category Mapping.
  		OPEN c_ccm (
  			v_sca_rec.correspondence_cat);
  		FETCH c_ccm INTO v_ccm_exists;
  		IF (c_ccm%NOTFOUND) THEN
  			CLOSE c_ccm;
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_CORCAT_PRG_APPL';
  				p_return_type := cst_error;
  			ELSE
  				p_message_name := 'IGS_AD_CORCAT_PRGAPPLICANT';
  				p_return_type := cst_warn;
  			END IF;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ccm;
  	END IF;
  	-- Only validate the student course attempt enrolment category
  	-- when none has been specified for the admission course application instance.
  	IF p_enrolment_cat IS NULL THEN
  		-- Validate the Student course Attempt Enrolment Category Mapping.
  		OPEN c_scae;
  		FETCH c_scae INTO v_scae_rec;
  		IF (c_scae%FOUND) THEN
  			CLOSE c_scae;
  			OPEN c_ecm (
  				v_scae_rec.enrolment_cat);
  			FETCH c_ecm INTO v_ecm_exists;
  			IF (c_ecm%NOTFOUND) THEN
  				CLOSE c_ecm;
  				IF p_offer_ind = 'Y' THEN
  					p_message_name := 'IGS_AD_ENRCAT_PRG_APPL';
  					p_return_type := cst_error;
  				ELSE
  					p_message_name := 'IGS_AD_ENRCAT_PRGAPPLICANT';
  					p_return_type := cst_warn;
  				END IF;
  				RETURN FALSE;
  			END IF;
  			CLOSE c_ecm;
  		ELSE
  			CLOSE c_scae;
  		END IF;
  		-- Validate the discontinued date
  		IF p_appl_dt IS NOT NULL AND
  				v_sca_rec.discontinued_dt IS NOT NULL AND
  				MONTHS_BETWEEN(p_appl_dt, v_sca_rec.discontinued_dt) <= 12 THEN
  			p_message_name := 'IGS_AD_APPL_ENROLLED_12MONTHS';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_fcm%ISOPEN THEN
  			CLOSE c_fcm;
  		END IF;
  		IF c_ccm%ISOPEN THEN
  			CLOSE c_ccm;
  		END IF;
  		IF c_scae%ISOPEN THEN
  			CLOSE c_scae;
  		END IF;
  		IF c_ecm%ISOPEN THEN
  			CLOSE c_ecm;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_aca_sca');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_aca_sca;
  --
 -- Validate the adm course application instance course offering pattern.
  FUNCTION admp_val_acai_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_deferred_appl IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_late_ind OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_cop
  	-- Validate the admission course application instance course offering pattern
  DECLARE
  	cst_error	CONSTANT VARCHAR2(1) := 'E';
  	cst_warn	CONSTANT VARCHAR2(1) := 'W';
  	v_ret_val		BOOLEAN	:= TRUE;
  	v_location_cd		IGS_AD_PS_APPL_INST.location_cd%TYPE;
  	v_attendance_mode	IGS_AD_PS_APPL_INST.attendance_mode%TYPE;
  	v_attendance_type	IGS_AD_PS_APPL_INST.attendance_type%TYPE;
  	v_message_name		VARCHAR2(30);
  	v_late_ind		VARCHAR2(1)	:= 'N';
  	v_return_type		VARCHAR2(1);
  BEGIN
  	p_message_name := NULL;
  	p_late_ind := 'N';
  	-- Validate the admission process category input parameters
  	-- All must be set for validation to occur
  	IF (p_acad_cal_type IS NULL OR
  			p_acad_ci_sequence_number IS NULL OR
  			p_adm_cal_type IS NULL OR
  			p_adm_ci_sequence_number IS NULL OR
  			p_admission_cat IS NULL OR
  			p_s_admission_process_type IS NULL) THEN
  		p_message_name := 'IGS_AD_PRGOFOP_CANNOT_VALID' ;
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- course offering pattern is offered
  	IF p_offer_ind = 'Y'  THEN
  		-- All components of the course offering pattern must be specified.
  		IF (p_course_cd IS NULL OR
  				p_version_number IS NULL OR
  				p_location_cd IS NULL OR
  				p_attendance_mode IS NULL OR
  				p_attendance_type IS NULL) THEN
  			p_message_name := 'IGS_AD_PRGOFOP_NOVALIDATE_COM';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	ELSE	-- course offering pattern is nominated
  		-- course component of course offering option must be set
  		-- (other components may be null).
  		IF (p_course_cd IS NULL OR
  				p_version_number IS NULL) THEN
  			p_message_name := 'IGS_AD_PRGOFOP_CANVLD_PRGCOMP';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Set the IGS_AD_LOCATION code, attendance mode and attendance type
  	v_location_cd 	  := p_location_cd;
  	v_attendance_mode := p_attendance_mode;
  	v_attendance_type := p_attendance_type;
  	-- Validate the course offering pattern
  	IF NOT IGS_AD_VAL_ACAI.admp_val_acai_coo (
  					p_course_cd,
  					p_version_number,
  					v_location_cd,
  					v_attendance_mode,
  					v_attendance_type,
  					p_acad_cal_type,
  					p_acad_ci_sequence_number,
  					p_adm_cal_type,
  					p_adm_ci_sequence_number,
  					p_admission_cat,
  					p_s_admission_process_type,
  					p_offer_ind,
  					p_appl_dt,
  					p_late_appl_allowed,
  					p_deferred_appl,
  					v_message_name,
  					v_return_type,
  					v_late_ind) THEN
  		p_message_name := v_message_name;
  		p_return_type := v_return_type;
  		p_late_ind := v_late_ind;
  		RETURN FALSE;
  	END IF;
  	-- admission course application instance course offering pattern is valid
  	p_return_type := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_cop');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_cop;
  --
  -- Validate the adm course application instance course offering option.
  FUNCTION admp_val_acai_coo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_deferred_appl IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_late_ind OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_coo
  	-- * This module assumes the course code component of the course offering
  	--   option
  	--   has already been validated (via a call to admp_val_acai_course).
  	-- * On nomination of a course offering option a blank value in the IGS_AD_LOCATION
  	--   code,
  	--   attendance mode or attendance type component of the course offering option
  	--   should be interpreted as any valid value.
  	-- * On offer of a course offering option all components of the course offering
  	--   option should be set.
  DECLARE
  	CURSOR c_coo IS
  		SELECT	location_cd,
  			attendance_mode,
  			attendance_type
  		FROM	IGS_PS_OFR_OPT
  		WHERE	course_cd 	= p_course_cd AND
  			version_number 	= p_version_number AND
  			cal_type 	= p_acad_cal_type AND
                        delete_flag= 'N';
  	CURSOR c_cop (
  		cp_course_cd			IGS_AD_PS_APPL_INST.course_cd%TYPE,
  		cp_version_number			IGS_AD_PS_APPL_INST.crv_version_number%TYPE,
  		cp_acad_cal_type			IGS_AD_APPL.acad_cal_type%TYPE,
  		cp_acad_ci_sequence_number	IGS_AD_APPL.acad_ci_sequence_number%TYPE,
  		cp_location_cd			IGS_AD_PS_APPL_INST.location_cd%TYPE,
  		cp_attendance_mode		IGS_AD_PS_APPL_INST.attendance_mode%TYPE,
  		cp_attendance_type		IGS_AD_PS_APPL_INST.attendance_type%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_OFR_PAT
  		WHERE	course_cd 		= cp_course_cd AND
  			version_number 		= cp_version_number AND
  			cal_type 			= cp_acad_cal_type AND
  			ci_sequence_number 	= cp_acad_ci_sequence_number AND
  			location_cd 		= cp_location_cd AND
  			attendance_mode 		= cp_attendance_mode AND
  			attendance_type 		= cp_attendance_type AND
  			offered_ind 		= 'Y' AND
  			entry_point_ind 		= 'Y';
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_cop_exists		VARCHAR2(1);
  	v_location_cd		IGS_AD_PS_APPL_INST.location_cd%TYPE;
  	v_attendance_mode	IGS_AD_PS_APPL_INST.attendance_mode%TYPE;
  	v_attendance_type		IGS_AD_PS_APPL_INST.attendance_type%TYPE;
  	v_message_name		VARCHAR2(30);
  	v_record_found		BOOLEAN := FALSE;
  	v_cop_found		BOOLEAN := FALSE;
  	v_ac_match		BOOLEAN := FALSE;	-- admission process category
  	v_ap_match		BOOLEAN := FALSE;	-- admission period
  	v_ad_match		BOOLEAN := FALSE;	-- application date
  	v_coo_match		BOOLEAN := FALSE;	-- course offering option
  	v_exit_loop		NUMBER(1) := 0;
  BEGIN
  	p_message_name := NULL;
  	p_late_ind := 'N';
  	-- Validate input parameters. All must be set for validation to occur
  	IF p_acad_cal_type IS NULL OR
  			p_acad_ci_sequence_number IS NULL OR
  			p_adm_cal_type IS NULL OR
  			p_adm_ci_sequence_number IS NULL OR
  			p_admission_cat IS NULL OR
  			p_s_admission_process_type IS NULL THEN
  		p_message_name := 'IGS_AD_PRGOFOP_NOVALID_ADMPRC';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- course componenet of course offering option must be set.
  	IF p_course_cd IS NULL OR
  			p_version_number IS NULL THEN
  		p_message_name := 'IGS_AD_PRGOFOP_NOVALIDATE_PRG';
  		p_return_type := cst_error;
  		RETURN FALSE;
   	END IF;
  	-- Validate the course offering option data
  	FOR v_coo_rec IN c_coo LOOP
  		v_record_found := TRUE;
  		-- Restrict the course offering options to match on input parameters.
  		IF (p_location_cd IS NULL OR
  				p_location_cd = v_coo_rec.location_cd) AND
  				(p_attendance_mode IS NULL OR
  				p_attendance_mode = v_coo_rec.attendance_mode) AND
  				(p_attendance_type IS NULL OR
  				p_attendance_type = v_coo_rec.attendance_type) THEN
  			-- course Offering Option Match
  			v_coo_match := TRUE;
  			-- Check the existence of a course offering pattern that is both offered
  			-- and an entry point for the academic period of the admission application.
  			OPEN c_cop(
  				p_course_cd,
  				p_version_number,
  				p_acad_cal_type,
  				p_acad_ci_sequence_number,
  				v_coo_rec.location_cd,
  				v_coo_rec.attendance_mode,
  				v_coo_rec.attendance_type);
  			FETCH c_cop INTO v_cop_exists;
  			IF c_cop%NOTFOUND THEN
  				CLOSE c_cop;
  			ELSE
  				CLOSE c_cop;
  				v_cop_found := TRUE;
  				-- Determine if there is an Admission Category Match
  				IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat (
  								p_course_cd,
  								p_version_number,
  								p_acad_cal_type,
  								v_coo_rec.location_cd,
  								v_coo_rec.attendance_mode,
  								v_coo_rec.attendance_type,
  								p_admission_cat,
  								v_message_name) THEN
  					-- Admission Process Category Match
  					v_ac_match := TRUE;
  					-- Determine if the course offering pattern is valid for the admission
  					-- period
  					IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_admperd (
  									p_adm_cal_type,
  									p_adm_ci_sequence_number,
  									p_admission_cat,
  									p_s_admission_process_type,
  									p_course_cd,
  									p_version_number,
  									p_acad_cal_type,
  									v_coo_rec.location_cd,
  									v_coo_rec.attendance_mode,
  									v_coo_rec.attendance_type,
  									v_message_name) THEN
  						-- The course offering pattern is valid for the admission process
  						-- category and the admission period
  						-- Admission Period Match
  						v_ap_match := TRUE;
  						-- Determine if the admission course application instance is late.
  						IF IGS_AD_VAL_ACAI.admp_val_acai_late (
  									p_appl_dt,
  									p_course_cd,
  									p_version_number,
  									p_acad_cal_type,
  									v_coo_rec.location_cd,
  									v_coo_rec.attendance_mode,
  									v_coo_rec.attendance_type,
  									p_adm_cal_type,
  									p_adm_ci_sequence_number,
  									p_admission_cat,
  									p_s_admission_process_type,
  									p_late_appl_allowed,
  									v_message_name) THEN
  							-- Application Date Valid
  							-- The course offering pattern is valid for the admission process
  							-- category and the admission period and is valid for the
  							-- application date.
  							v_ad_match := TRUE;
  							EXIT;
  						END IF;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	IF v_ad_match THEN
  		RETURN TRUE;
  	END IF;
  	-- No course offering option record found
  	IF NOT v_coo_match THEN
  		IF p_offer_ind = 'Y' THEN
  			p_message_name := 'IGS_AD_NOMINATED_PRG_NOTEXIST';
  			p_return_type := cst_error;
  		ELSE
  			IF p_deferred_appl = 'N' THEN
  				p_message_name := 'IGS_AD_NOMINATED_PRG_NOTEXIST';
  			ELSE
  				p_message_name := 'IGS_AD_POO_DFRD_ADM_PERIOD';
  			END IF;
  			p_return_type := cst_warn;
  		END IF;
  		RETURN FALSE;
  	END IF;
  	-- No course offering pattern record found
  	IF NOT v_cop_found THEN
  		IF p_offer_ind = 'Y' THEN
  			p_message_name := 'IGS_AD_PRGOFOP_OFR_ENRTYPOINT';
  			p_return_type := cst_error;
  		ELSE
  			IF p_deferred_appl = 'N' THEN
  				p_message_name := 'IGS_AD_NOMINATED_PRG_ENTRYPNT';
  			ELSE
  				p_message_name := 'IGS_AD_POO_PRG_OFRING_ADMPRD';
  			END IF;
  			p_return_type := cst_warn;
  		END IF;
  		RETURN FALSE;
  	END IF;
  	-- IF Admission Category Match
  	IF v_ac_match THEN
  		IF v_ap_match THEN
  			-- There must have been no Application Date Match
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_APPL_CLOSINGDT_PASSED';
  				p_return_type := cst_error;
  			ELSE
                        IF p_deferred_appl = 'N' THEN
                                   IF p_attendance_type IS NULL OR P_attendance_mode IS NULL THEN
                                          p_message_name := 'IGS_AD_APPL_CLOSINGDT_PASSED';
                                          p_return_type := cst_error;
                                    ELSE
                                        p_message_name := 'IGS_AD_APPLDT_HAS_PASSED';
                                          p_return_type := cst_warn;
                                    END IF;
                                ELSE
                                        p_message_name := 'IGS_AD_POO_PRG_OFRING_LATEFEE';
                                           p_return_type := cst_warn;
                                END IF;
                        END IF;
                     p_late_ind := 'Y';
                    RETURN FALSE;

  		END IF;
  		-- There must have been no Admission Period match
  		IF p_offer_ind = 'Y' THEN
  			p_message_name := 'IGS_AD_OFR_PRG_ENTRYPOINT_ADM';
  			p_return_type := cst_error;
  		ELSE
  			IF p_deferred_appl = 'N' THEN
  				p_message_name := 'IGS_AD_NOMINATE_PRG_OFR_ENTRY';
  			ELSE
  				p_message_name := 'IGS_AD_POO_PRG_OFRING_APPL';
  			END IF;
  			p_return_type := cst_warn;
  		END IF;
  		RETURN FALSE;
  	ELSE
  		-- There must have been no Admission Process Category Match
  		p_message_name := 'IGS_AD_PRG_VALIED_ADMCAT';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  END;
  END admp_val_acai_coo;
  --
  -- Validate if the IGS_AD_PS_APPL_INST is late.
  FUNCTION admp_val_acai_late(
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_late
  	-- Validate if the IGS_AD_PS_APPL_INST is late.
  	-- Validate against the due date when late applications are not allowed.
  	-- Validate against the final date when late applications are allowed.
  DECLARE
  	CURSOR c_sacc IS
  		SELECT	adm_appl_due_dt_alias,
  			adm_appl_final_dt_alias
  		FROM	IGS_AD_CAL_CONF
  		WHERE	s_control_num 		= 1 AND
  			adm_appl_due_dt_alias 	IS NOT NULL AND
  			adm_appl_final_dt_alias IS NOT NULL;
  	v_sacc_rec		c_sacc%ROWTYPE;
  	v_final_dt		DATE := NULL;
  	v_due_dt 		DATE := NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Get the admission application due and final date aliases.
  	OPEN c_sacc;
  	FETCH c_sacc INTO v_sacc_rec;
  	IF c_sacc%NOTFOUND THEN
  		CLOSE c_sacc;
  		p_message_name := 'IGS_AD_CHK_ADMCAL_CONFIG' ;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sacc;
  	-- Validate for a late application.
  	IF p_late_appl_allowed = 'Y' THEN
  		-- Validate against the final date when late applications are allowed
  		-- Check the final date.
  		-- Get admission period final date.
  		v_final_dt := IGS_AD_GEN_003.ADMP_GET_ADM_PERD_DT(
  						v_sacc_rec.adm_appl_final_dt_alias,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type);
  		IF v_final_dt IS NOT NULL THEN
  			IF p_appl_dt > v_final_dt THEN
  				-- Admission course application instance is invalid
  				-- because the application date is after the due date
  				-- of the course offering option.
  				p_message_name := 'IGS_AD_APLDT_ADMAPL_FINALDT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	ELSE	-- p_late_appl_allowed = 'Y'
  		-- Validate against the due date when late applications are not allowed.
  		-- Check the final date.
  		-- Get admission period final date.
  		v_due_dt := IGS_AD_GEN_003.ADMP_GET_ADM_PERD_DT(
  						v_sacc_rec.adm_appl_due_dt_alias,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_admission_cat,
  						p_s_admission_process_type,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type);
  		IF v_due_dt IS NOT NULL THEN
  			IF p_appl_dt > v_due_dt THEN
  				-- Admission course application instance is invalid
  				-- because the application date is after the due date
  				-- of the course offering option.
  				p_message_name := 'IGS_AD_APPLDT_ADMAPPL_DUEDT';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_sacc%ISOPEN THEN
  	CLOSE c_sacc;
      END IF;
      RAISE;
  END;
 END admp_val_acai_late;
  --
  -- Validate the admission course appl instance offering option details.
  FUNCTION admp_val_acai_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_opt
  	-- Validate the admission course application instance offering option details.
  DECLARE
  	v_rec_found		BOOLEAN :=FALSE;
  	v_location_cd		IGS_PS_OFR_PAT.location_cd%TYPE;
  	v_attendance_mode	IGS_PS_OFR_PAT.attendance_mode%TYPE;
  	v_attendance_type		IGS_PS_OFR_PAT.attendance_type%TYPE;
  	v_message_name		VARCHAR2(30);
  	CURSOR c_acopv IS
  		SELECT	location_cd,
  			attendance_mode,
  			attendance_type
  		FROM	IGS_PS_OFR_PAT_OFERPAT_V
  		WHERE	course_cd		= p_course_cd AND
  			version_number		= p_version_number AND
  			acad_cal_type		= p_acad_cal_type AND
  			acad_ci_sequence_number	= p_acad_ci_sequence_number AND
  			adm_cal_type		= p_adm_cal_type AND
  			adm_ci_sequence_number	= p_adm_ci_sequence_number AND
  			admission_cat		= p_admission_cat AND
  			s_admission_process_type	= p_s_admission_process_type AND
  			(p_location_cd IS NULL OR
  				location_cd	= p_location_cd) AND
  			(p_attendance_mode IS NULL OR
  				attendance_mode	= p_attendance_mode) AND
  			(p_attendance_type IS NULL OR
  				attendance_type	= p_attendance_type) AND
  			(IGS_AD_GEN_013.ADMS_GET_COO_CRV(
  				course_cd,
  				version_number,
  				s_admission_process_type,
  				p_offer_ind) = 'Y') AND
  			(IGS_AD_GEN_013.ADMS_GET_ACAI_COO (
  				course_cd,
  				version_number,
  				location_cd,
  				attendance_mode,
  				attendance_type,
  				acad_cal_type,
  				acad_ci_sequence_number,
  				adm_cal_type,
  				adm_ci_sequence_number,
  				admission_cat,
  				s_admission_process_type,
  				p_offer_ind,
  				p_appl_dt,
  				p_late_appl_allowed,
  				'N') = 'Y');	-- Deferred application.
  --------------------------------------- SUB-FUNCTION---------------------------
  	FUNCTION admpl_val_param
  	RETURN BOOLEAN
  	AS
  	BEGIN	-- admpl_val_param
  		-- a sub-function that validates p_location_cd, p_attendance_mode,
  		-- p_attendance_type
  	DECLARE
  	BEGIN
  		v_message_name := NULL;
  		IF (p_location_cd IS NOT NULL AND
  				v_rec_found = TRUE) THEN
  			-- Check if the IGS_AD_LOCATION is open and whether IGS_AD_LOCATION type is correct
  			-- For bug # 1956374 changed the below call from IGS_AD_VAL_APCOO.crsp_val_loc_cd
  			IF IGS_PS_VAL_UOO.crsp_val_loc_cd (
  					p_location_cd,
  					v_message_name) = FALSE THEN
  	   			RETURN FALSE;
  			END IF;
  		END IF;
  		IF (p_attendance_mode IS NOT NULL AND
  				v_rec_found = TRUE) THEN
  	       		-- Check if the attendance mode is open
  			IF IGS_AD_VAL_APCOO.crsp_val_am_closed(
  					p_attendance_mode,
  					v_message_name) = FALSE THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  		IF (p_attendance_type IS NOT NULL AND
  				v_rec_found = TRUE) THEN
  			-- Check if the attendance type is open
  			IF IGS_AD_VAL_APCOO.crsp_val_att_closed (
  					p_attendance_type,
  					v_message_name) = FALSE THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
         		          FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
						  FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admpl_val_param');
						  IGS_GE_MSG_STACK.ADD;
						  APP_EXCEPTION.RAISE_EXCEPTION;
  	END admpl_val_param;
  ----------------------------------------- MAIN ---------------------------------
  BEGIN
  	p_message_name := NULL;
  	IF p_location_cd IS NOT NULL OR
  		p_attendance_mode IS NOT NULL OR
  		p_attendance_type IS NOT NULL THEN
  		-- Check if the offering option is valid
  		OPEN c_acopv;
  		FETCH c_acopv INTO
  			v_location_cd,
  			v_attendance_mode,
  			v_attendance_type;
  		IF (c_acopv%FOUND) THEN
  			v_rec_found := TRUE;
  		END IF;
  		CLOSE c_acopv;
  		IF admpl_val_param = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	                 FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
					 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_opt');
					 IGS_GE_MSG_STACK.ADD;
					 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_opt;
  --
  -- Validate the admission course application unit set.
  FUNCTION admp_val_acai_us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_unit_set_appl IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_acai_us
  	-- Validate the admission course application unit set.
  	-- Validations are:
  	-- unit set may only be specified when the 'unit set' step exists for the
  	-- admission process category.
  	-- If the unit set is offered then both the unit set and unit set version must
  	-- be specified.
  	-- If the unit set is nominated then the unit set status must be
  	-- Active, however, if the unit set is offered the unit set status must be
  	-- Active.
  	-- The expiry date of the unit set must not be set.
  	-- The unit set must be mapped to the course offering option (this is an error
  	-- on offer but a warning on nomination).
  	-- The course offering option unit set must be valid for the admission category
  	--  of the admission application.
  DECLARE
  	cst_active		CONSTANT VARCHAR2(6) := 'ACTIVE';
  	cst_yes			CONSTANT VARCHAR2(1) := 'Y';
  	cst_error		CONSTANT VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT VARCHAR2(1) := 'W';
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	v_expiry_dt		IGS_EN_UNIT_SET.expiry_dt%TYPE;
  	v_message_name		VARCHAR2(30);
  	v_coousv_match		BOOLEAN := FALSE;
  	v_coacus_match		BOOLEAN := FALSE;
  	v_coacus_rec_found	BOOLEAN := FALSE;
  	CURSOR c_us_uss (
  			cp_unit_set_cd		IGS_EN_UNIT_SET.unit_set_cd%TYPE,
  			cp_us_version_number	IGS_EN_UNIT_SET.version_number%TYPE) IS
  		SELECT	uss.s_unit_set_status,
  			us.expiry_dt
  		FROM	IGS_EN_UNIT_SET			us,
  			IGS_EN_UNIT_SET_STAT		uss
  		WHERE	  us.unit_set_cat IN
		         ( SELECT usc.unit_set_cat
                           FROM   igs_en_unit_set_cat usc
                     	   WHERE (fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND'  ) <> 'Y'
			      OR usc.s_unit_set_cat = 'PRENRL_YR') )
		AND    us.UNIT_SET_STATUS	= uss.UNIT_SET_STATUS
  		AND	us.unit_set_cd	= cp_unit_set_cd
  		AND	us.version_number	= cp_us_version_number;

  	CURSOR c_coousv (
  			cp_unit_set_cd		IGS_PS_OF_OPT_UNT_ST.unit_set_cd%TYPE,
  			cp_us_version_number	IGS_PS_OF_OPT_UNT_ST.us_version_number%TYPE,
  			cp_course_cd		IGS_PS_OF_OPT_UNT_ST.course_cd%TYPE,
  			cp_crv_version_number	IGS_PS_OF_OPT_UNT_ST.crv_version_number%TYPE,
  			cp_acad_cal_type	IGS_PS_OF_OPT_UNT_ST.cal_type%TYPE,
			cp_admission_cat        IGS_PS_COO_AD_UNIT_S.admission_cat%TYPE,
                        cp_location_cd                IGS_PS_COO_AD_UNIT_S.location_cd%TYPE,
                        cp_attendance_mode              IGS_PS_COO_AD_UNIT_S.attendance_mode%TYPE,
                        cp_attendance_type              IGS_PS_COO_AD_UNIT_S.attendance_type%TYPE)  IS
  		SELECT 1
  		FROM    IGS_PS_OFR_OPT_UNIT_SET_V psusv
  		WHERE   psusv.course_cd              = cp_course_cd
  		        AND psusv.crv_version_number = cp_crv_version_number
			AND psusv.unit_set_cd        = cp_unit_set_cd
                        AND psusv.us_version_number  = cp_us_version_number
  		        AND psusv.cal_type           = cp_acad_cal_type
                        AND psusv.location_cd        = NVL(cp_location_cd, psusv.location_cd)
                        AND psusv.attendance_mode    = NVL(cp_attendance_mode, psusv.attendance_mode)
                        AND psusv.attendance_type    = NVL(cp_attendance_type, psusv.attendance_type)
  		        AND NOT EXISTS
  		        (SELECT 1
  		        FROM    igs_ps_coo_ad_unit_s psus
  		        WHERE   psus.course_cd              = psusv.course_cd
  		                AND psus.crv_version_number = psusv.crv_version_number
  		                AND psus.cal_type           = psusv.cal_type
				AND psus.location_cd        = psusv.location_cd
  		                AND psus.attendance_mode    = psusv.attendance_mode
  		                AND psus.attendance_type    = psusv.attendance_type
  		                AND psus.admission_cat      = cp_admission_cat
		        )
		        AND psusv.UNIT_SET_STATUS IN
  				        (SELECT unit_set_status
  		        FROM    igs_en_unit_set_stat uss
  		        WHERE   psusv.unit_set_status      = uss.unit_set_status
  		                AND uss.s_unit_set_status <> 'INACTIVE'
                        )
                        AND psusv.unit_set_cat IN
                        (SELECT usc.unit_set_cat
  		        FROM    igs_en_unit_set_cat usc
  		        WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
  		                OR usc.s_unit_set_cat  = 'PRENRL_YR'))
  		        )
  		        AND psusv.expiry_dt IS NULL
  		UNION
  		SELECT  1
		FROM    igs_ps_coo_ad_unit_s psus,
		        igs_en_unit_set us
  		WHERE   us.unit_set_cd              = psus.unit_set_cd
  		        AND us.version_number       = psus.us_version_number
                        AND psus.unit_set_cd        = cp_unit_set_cd
                        AND psus.us_version_number  = cp_us_version_number
  		        AND psus.course_cd          = cp_course_cd
  		        AND psus.crv_version_number = cp_crv_version_number
                        AND psus.cal_type           = cp_acad_cal_type
                        AND psus.location_cd        = NVL(cp_location_cd, psus.location_cd)
                        AND psus.attendance_mode    = NVL(cp_attendance_mode, psus.attendance_mode)
  		        AND psus.attendance_type    = NVL(cp_attendance_type, psus.attendance_type)
  		        AND psus.admission_cat      = cp_admission_cat
  		        AND us.unit_set_status IN
  		        (SELECT unit_set_status
  		        FROM    igs_en_unit_set_stat uss
  		        WHERE   us.unit_set_status         = uss.unit_set_status
  		                AND uss.s_unit_set_status <> 'INACTIVE'
  		        )
  		        AND us.unit_set_cat IN
  		        (SELECT usc.unit_set_cat
		        FROM    igs_en_unit_set_cat usc
		        WHERE   ((fnd_profile.value ('IGS_PS_PRENRL_YEAR_IND') <> 'Y'
		                OR usc.s_unit_set_cat  = 'PRENRL_YR'))
		                )
		        AND us.expiry_dt IS NULL;


  	CURSOR c_coacus 	(
  			cp_course_cd		IGS_PS_COO_AD_UNIT_S.course_cd%TYPE,
  			cp_crv_version_number	IGS_PS_COO_AD_UNIT_S.crv_version_number%TYPE,
  			cp_acad_cal_type		IGS_PS_COO_AD_UNIT_S.cal_type%TYPE,
  			cp_admission_cat		IGS_PS_COO_AD_UNIT_S.admission_cat%TYPE,
                        cp_location_cd                IGS_PS_COO_AD_UNIT_S.location_cd%TYPE,
                        cp_attendance_mode              IGS_PS_COO_AD_UNIT_S.attendance_mode%TYPE,
                        cp_attendance_type              IGS_PS_COO_AD_UNIT_S.attendance_type%TYPE) IS
  		SELECT	coacus.unit_set_cd,
  			coacus.us_version_number,
  			coacus.location_cd,
  			coacus.attendance_mode,
  			coacus.attendance_type
  		FROM	IGS_PS_COO_AD_UNIT_S	coacus
  		WHERE	coacus.course_cd		= cp_course_cd AND
  			coacus.crv_version_number	= cp_crv_version_number AND
  			coacus.cal_type		= cp_acad_cal_type AND
  			coacus.admission_cat	= cp_admission_cat AND
			coacus.location_cd = cp_location_cd AND
			coacus.attendance_mode = cp_attendance_mode AND
			coacus.attendance_type = cp_attendance_type;
  BEGIN
  	-- Initialise out NOCOPY parameters
  	p_message_name := NULL;
  	p_return_type := NULL;
  	IF p_unit_set_appl = 'N' THEN
  		-- Ensure the unit set details are not specified for an admission application
  		-- that does not allow unit sets.
  		IF p_unit_set_cd IS NOT NULL OR
  				p_us_version_number IS NOT NULL THEN
  			p_message_name := 'IGS_AD_UNITSET_NOTSPECIFIED' ;
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	ELSE	-- unit sets are allowed for the application.
  		IF p_unit_set_cd IS NOT NULL AND
  				p_us_version_number IS NOT NULL THEN
  			-- Retrieve unit set data
  			OPEN 	c_us_uss(
  				p_unit_set_cd,
  				p_us_version_number);
  			FETCH	c_us_uss INTO 	v_s_unit_set_status,
  						v_expiry_dt;
  			IF(c_us_uss%FOUND) THEN
  				-- Validate unit set status
  				IF p_offer_ind = cst_yes THEN	-- Offered
  					IF v_s_unit_set_status <> cst_active THEN
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_MUSTBE_ACTIVE';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					END IF;
  				ELSE				-- Nominated
  					IF v_s_unit_set_status  <> cst_active THEN   --removed the planned status as per bug#2722785 --rghosh
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_ACTIVE_PLANNED';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				-- Validate expiry date
  				IF v_expiry_dt IS NOT NULL THEN
  					CLOSE c_us_uss;
  					p_message_name := 'IGS_AD_UNITSET_EXPDT_NOTBESET';
  					p_return_type := cst_error;
  					RETURN FALSE;
  				END IF;
  				-- Validate that unit set is mapped to the course offering option.
  				-- If the option details of the course offering option are specified,
  				-- then an exact match must be found.  If the option details are not
  				-- specified then a match on the course offering and unit set is all
  				-- that is needed.
  				FOR v_coousv_rec IN c_coousv (
  						p_unit_set_cd,
  						p_us_version_number,
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
						p_admission_cat,
						p_location_cd,
						p_attendance_mode,
						p_attendance_type) LOOP
					v_coousv_match := TRUE;
  				END LOOP;
  				IF(v_coousv_match = FALSE) THEN
  					IF p_offer_ind = cst_yes THEN	-- Offered
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_NOTMAP_POO';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					ELSE				-- Nominated
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_UNITSET_NOT_MAP_POO';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				-- Validate the course offering option unit set is mapped to the admission
  				-- category.
  				-- This is a restriction table. If no records exist on the table for the
  				-- course offering option, then the course offering option unit set is valid
  				-- for the admission category.  However, if any record exists on the table
  				-- for the course offering option then one must exist for the unit set.
  				FOR v_coacus_rec IN c_coacus(
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_admission_cat,
						p_location_cd,
						p_attendance_mode,
						p_attendance_type) LOOP
  					v_coacus_rec_found := TRUE;
  					IF ((p_unit_set_cd = v_coacus_rec.unit_set_cd) AND
  							(p_us_version_number = v_coacus_rec.us_version_number) AND
  							(p_location_cd IS NULL OR
  							p_location_cd = v_coacus_rec.location_cd) AND
  							(p_attendance_mode IS NULL OR
  							p_attendance_mode = v_coacus_rec.attendance_mode) AND
  							(p_attendance_type IS NULL OR
  							p_attendance_type = v_coacus_rec.attendance_type)) THEN
  						v_coacus_match := TRUE;
  					END IF;
  				END LOOP;
  				IF(v_coacus_rec_found = TRUE AND
  						v_coacus_match = FALSE) THEN
  					IF p_offer_ind = cst_yes THEN 	-- Offered
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_OFRPRG_NOT_VALID';
  						p_return_type := cst_error;
  						RETURN FALSE;
  					ELSE 				-- Nominated
  						CLOSE c_us_uss;
  						p_message_name := 'IGS_AD_PRGOFOP_NOT_VALID';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				IF v_coacus_rec_found = FALSE THEN
  					-- Validate the unit set.
  					IF IGS_AD_VAL_ACAI.crsp_val_cacus_sub (
  							p_course_cd,
  							p_crv_version_number,
  							p_acad_cal_type,
  							p_unit_set_cd,
  							p_us_version_number,
  							v_message_name) = FALSE THEN
  						CLOSE c_us_uss;
  						p_message_name := v_message_name;
  						p_return_type := cst_error;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				CLOSE c_us_uss;
  			ELSE	-- unit set record not found.
  				CLOSE c_us_uss;
  				p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		ELSE	-- unit set is not specified.
  			IF p_offer_ind = cst_yes THEN
  				p_message_name := 'IGS_AD_UNITSET_MUSTBE_SPECIFI';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_us');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_us;
  --
  -- Validate CACUS can only be created when US is not a subordinate
  FUNCTION crsp_val_cacus_sub(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY varchar2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_cacus_sub
  	-- This module validates that a crs_adm_cat_unit_set record can only be
  	-- created when:
  	-- . the IGS_PS_OFR_UNIT_SET.only_as_sub_ind = 'N' and
  	-- . the IGS_PS_OFR_UNIT_SET does not exist as a subordinate in the
  	--   IGS_PS_OF_UNT_SET_RL table.
  DECLARE
  	v_dummy		VARCHAR2(1);
  	CURSOR c_cousr IS
  		SELECT	'x'
  		FROM	IGS_PS_OF_UNT_SET_RL	cousr
  		WHERE	cousr.course_cd			= p_course_cd		AND
  			cousr.crv_version_number	= p_crv_version_number	AND
  			cousr.cal_type			= p_cal_type		AND
  			cousr.sub_unit_set_cd		= p_unit_set_cd		AND
  			cousr.sub_us_version_number	= p_us_version_number;
  BEGIN
  	-- set default vaule
  	p_message_name := null;
  	IF IGS_PS_GEN_003.CRSP_GET_COUS_SUBIND (
  				p_course_cd,
  				p_crv_version_number,
  				p_cal_type,
  				p_unit_set_cd,
  				p_us_version_number) = 'Y'	THEN
  		p_message_name := 'IGS_PS_UNIT_SET_IND_Y';
  		RETURN FALSE;
  	END IF;
  	OPEN c_cousr;
  	FETCH c_cousr INTO v_dummy;
  	IF c_cousr%FOUND THEN
  		CLOSE c_cousr;
  		p_message_name := 'IGS_PS_UNIT_SET_EXISTS_SUBORD';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cousr;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cousr%ISOPEN THEN
  			CLOSE c_cousr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.crsp_val_cacus_sub');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END crsp_val_cacus_sub;
  --
  -- Do encumbrance checks for the IGS_AD_PS_APPL_INST.unit_set_cd.
  FUNCTION admp_val_us_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_encmb_chk_ind IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_us_encmb
  	-- Perform encumberance checks for the
  	-- admission_course_appl_instance.unit_set_cd
  DECLARE
  	v_encmb_check_dt	DATE;
  	v_message_name		VARCHAR2(30);
  BEGIN
  	p_message_name := NULL;
  	IF p_unit_set_cd IS NOT NULL AND
  			p_us_version_number IS NOT NULL AND
  			p_course_encmb_chk_ind = 'Y' THEN
  		-- Get the encumberance checking date.
  		v_encmb_check_dt := NVL(IGS_AD_GEN_006.ADMP_GET_ENCMB_DT(
  					p_adm_cal_type,
  					p_adm_ci_sequence_number),SYSDATE);
/*  		IF v_encmb_check_dt IS NULL THEN
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_ENCUMB_CANNOT_PERFORM';
  				p_return_type := 'E';
  			ELSE
  				p_message_name := 'IGS_AD_ENCUMB_CHK_NOT_PERFORM';
  				p_return_type := 'W';
  			END IF;
  			RETURN FALSE;
  		END IF;
*/
		-- Validate for exclusion or suspension from the
  		-- unit set version within the course.
  		IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_us(
  					p_person_id,
  					p_course_cd,
  					p_unit_set_cd,
  					p_us_version_number,
  					v_encmb_check_dt,
  					v_message_name) THEN
  			IF p_offer_ind = 'Y' THEN
  				p_message_name := 'IGS_AD_PRSN_ENCUMB_EXCL_UNIT';
  				p_return_type := 'E';
  			ELSE
  				p_message_name := 'IGS_AD_ENCUMB_EXCL_PRG';
  				p_return_type := 'W';
  			END IF;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_us_encmb');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
END admp_val_us_encmb;
  --
  -- Validate the IGS_AD_PS_APPL_INST.offer_dt.
  FUNCTION admp_val_offer_dt(
  p_offer_dt IN DATE ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_offer_dt
  	-- Validate the IGS_AD_PS_APPL_INST.offer_dt.
  DECLARE
  	v_s_adm_outcome_status	VARCHAR2(255);
  	v_course_start_dt		DATE;
  BEGIN
  	p_message_name := NULL;
  	-- Validate offer date against the admission outcome status.
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (
  					p_adm_outcome_status);
  	-- Offer date must be not be set for a pending admission course application
  	-- instance.
  	IF 	v_s_adm_outcome_status = 'PENDING' AND
  		p_offer_dt IS NOT NULL THEN
  		p_message_name := 'IGS_AD_OFRDT_SET_PENDING_AMD';
  		RETURN FALSE;
  	END IF;
  	-- Offer date must be set for an offered admission course application instance.
  	IF	v_s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
  		p_offer_dt IS NULL THEN
  		p_message_name := 'IGS_AD_OFRDT_SET_ADMPRG_APPL';
  		RETURN FALSE;
  	END IF;
  -- The following code has been commented out.
  -- The users decided this check is no longer required.


  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_offer_dt');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_offer_dt;
  --
  -- Validate the IGS_AD_PS_APPL_INST.offer_response_dt.
  FUNCTION admp_val_off_resp_dt(
  p_offer_response_dt IN DATE ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_offer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_off_resp_dt
  	-- Validate the IGS_AD_PS_APPL_INST.offer_response_dt.
  DECLARE
  	v_s_adm_outcome_status		VARCHAR2(255);
  BEGIN
  	p_message_name := NULL;
  	-- Validate offer response date against the admission outcome status.
  	v_s_adm_outcome_status := IGS_AD_GEN_008.ADMP_GET_SAOS (
  					p_adm_outcome_status);
  	-- Offer response date must be not be set for a pending admission course
  	-- application instance.
  	IF 	v_s_adm_outcome_status = 'PENDING' AND
  		p_offer_response_dt IS NOT NULL THEN
  		p_message_name := 'IGS_AD_OFR_RESPDT_SET_PENDING';
  		RETURN FALSE;
  	END IF;
  	-- Offer response date must be set for an offered admission course application
  	-- instance.
  	IF	v_s_adm_outcome_status IN ('OFFER', 'COND-OFFER') AND
  		p_offer_response_dt IS NULL THEN
  		p_message_name := 'IGS_AD_OFR_RESPDT_SET_ODR_ADM';
  		RETURN FALSE;
  	END IF;
  	-- Validate offer response date against offer date.
  	IF TRUNC(p_offer_response_dt) < TRUNC(p_offer_dt) THEN
  		p_message_name := 'IGS_AD_OFR_RSPDT_GE_OFRDT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
				 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_off_resp_dt');
				 IGS_GE_MSG_STACK.ADD;
				 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_off_resp_dt;
  --
  -- Validate the IGS_AD_PS_APPL_INST.actual_response_dt.
  FUNCTION admp_val_act_resp_dt(
  p_actual_response_dt IN DATE ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_offer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_act_resp_dt
  	-- Validate the IGS_AD_PS_APPL_INST.actual_response_dt.
  DECLARE
  	v_s_adm_offer_resp_status	VARCHAR2(255);
  BEGIN
  	p_message_name := NULL;
  	-- Validate actual response date against the admission offer response status.
  	v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  					p_adm_offer_resp_status);
  	-- Actual response date must be not be set for an admission course application
  	-- instance with an offer response status of pending, lapsed or not-applicable.
  	IF	v_s_adm_offer_resp_status IN ('PENDING', 'LAPSED', 'NOT-APPLIC') THEN
  		IF p_actual_response_dt IS NOT NULL THEN
  			p_message_name := 'IGS_AD_ACT_RSPDT_NOT_SET_ADM';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- Actual response date must be set for an admission course application
  		-- instance with
  		-- an offer response status that is not pending, lapsed or not-applicable.
  		IF (p_actual_response_dt IS NULL) THEN
  			p_message_name := 'IGS_AD_ACT_RSPDT_SET_ADMPRG';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate actual response date against current date.
  	IF TRUNC(p_actual_response_dt) > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_AD_ACT_RSPDT_LE_CURDT';
  		RETURN FALSE;
  	END IF;
  	-- Validate actual response date against offer date.
  	IF p_actual_response_dt IS NOT NULL AND
  			TRUNC(p_actual_response_dt) < TRUNC(p_offer_dt) THEN
  		p_message_name := 'IGS_AD_ACTRESPDT_GE_OFRDT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_act_resp_dt');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_act_resp_dt;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_satisfied_dt.
  FUNCTION admp_val_stsfd_dt(
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_stsfd_dt
  	-- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_satisfied_dt.
  DECLARE
  	v_s_adm_cndtnl_offer_status	VARCHAR2(255);
  BEGIN
  	p_message_name := NULL;
  	-- Validate conditional offer satisfied date against the admission conditional
  	-- offer status.
  	v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS (
  						p_adm_cndtnl_offer_status);
  	-- Conditional offer satisfied date must be set when the conditional offer has
  	--  been
  	-- satisfied or waived.
  	IF v_s_adm_cndtnl_offer_status IN ('SATISFIED', 'WAIVED') THEN
  		IF (p_cndtnl_offer_satisfied_dt IS NULL) THEN
  			p_message_name := 'IGS_AD_OFRDT_SET_CONDOFR';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- Conditional offer satisfied date must not be set when the conditional offer
  		--  has not
  		-- been satisfied or waived.
  		IF (p_cndtnl_offer_satisfied_dt IS NOT NULL) THEN
  			p_message_name := 'IGS_AD_OFRDT_NOT_SET_CONDOFR';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate conditional offer satisfied date against current date.
  	IF TRUNC(p_cndtnl_offer_satisfied_dt) > TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_AD_COND_OFRDT_LE_CURDT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_stsfd_dt');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_stsfd_dt;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_cndtn.
  FUNCTION admp_val_offer_cndtn(
  p_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_offer_cndtn
  	-- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_cndtn.
  	-- Validations are:
  	-- * The conditional offer condition may only have a value when a
  	--    conditional offer has been made.
  DECLARE
  	cst_not_applic		CONSTANT VARCHAR2(10) :='NOT-APPLIC';
  	v_s_adm_cndtnl_offer_status
  				IGS_AD_CNDNL_OFRSTAT.s_adm_cndtnl_offer_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the conditional offer condition against the admission
  	-- conditional offer status.
  	IF p_cndtnl_offer_cndtn IS NOT NULL THEN
  		v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS (
  							p_adm_cndtnl_offer_status);
  		-- The conditional offer condition may only be specified when an
  		-- conditional offer has been made.
  		IF v_s_adm_cndtnl_offer_status = cst_not_applic THEN
  			p_message_name := 'IGS_AD_CONDOFR_COND';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_offer_cndtn');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_offer_cndtn;
  --
  -- Validate the IGS_AD_PS_APPL_INST.applicant_acptnce_cndtn.
  FUNCTION admp_val_acpt_cndtn(
  p_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acpt_cndtn
  	-- Validate the IGS_AD_PS_APPL_INST.applicant_acptnce_cndtn.
  	-- Validations are:
  	-- * The applicant acceptance condition may only have a value when the
  	--   applicant has responded to an offer of admission.
  DECLARE
  	cst_not_applic		CONSTANT VARCHAR2(10) :='NOT-APPLIC';
  	cst_pending		CONSTANT VARCHAR2(7) :='PENDING';
  	cst_lapsed		CONSTANT VARCHAR2(6) :='LAPSED';
  	v_s_adm_offer_resp_status	IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Validate the applicant acceptance condition against the admission
  	-- offer response status.
  	IF p_applicant_acptnce_cndtn IS NOT NULL THEN
  		v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  							p_adm_offer_resp_status);
  		-- The applicant acceptance condition may only be specified when an
  		-- applicant has responded to an offer of admission.
  		IF v_s_adm_offer_resp_status IN (cst_pending,
  						 cst_lapsed,
  						 cst_not_applic) THEN
  			p_message_name := 'IGS_AD_APPL_RESP_COMMENTS';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acpt_cndtn');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acpt_cndtn;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind.
  FUNCTION admp_val_must_stsfd(
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_must_stsfd
  	-- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind.
  DECLARE
  	v_s_adm_cndtnl_offer_status
  					IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status%TYPE;
  	v_s_adm_offer_resp_status		IGS_AD_OFR_RESP_STAT.adm_offer_resp_status%TYPE;
  	cst_not_applic				CONSTANT VARCHAR2(10) := 'NOT-APPLIC';
  	cst_accepted				CONSTANT VARCHAR2(8) := 'ACCEPTED';

  BEGIN
  	-- Set up the default return value.
  	p_message_name := NULL;

  	IF p_cndtnl_off_must_be_stsfd_ind = 'Y' THEN
  		v_s_adm_cndtnl_offer_status := IGS_AD_GEN_007.ADMP_GET_SACOS(
  							p_adm_cndtnl_offer_status);
  		IF v_s_adm_cndtnl_offer_status = cst_not_applic THEN
  			-- The conditional offer must be satisfied indicator cannot be set when
  			-- the conditional offer status is not applicable.
  			p_message_name := 'IGS_AD_SATISFIEDINDICATOR_SET';
  			RETURN FALSE;
  		END IF;
  		v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS (
  							p_adm_offer_resp_status);
  		IF v_s_adm_offer_resp_status = cst_accepted AND
  				p_cndtnl_offer_satisfied_dt IS NULL THEN
  			-- The conditional offer must be satisfied before it can be accepted.
  			p_message_name := 'IGS_AD_CONDOFR_ACCEPTED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_must_stsfd');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_must_stsfd;
  --
  -- Validate adm course application instance deferred admission calendar.
  FUNCTION admp_val_dfrmnt_cal(
  p_deferred_adm_cal_type IN VARCHAR2 ,
  p_deferred_adm_ci_sequence_num IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_deferral_allowed IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2,
  p_def_acad_ci_sequence_num IN NUMBER
  )
  RETURN BOOLEAN AS
  BEGIN 	-- admp_val_dfrmnt_cal
  	-- Validate the admission course application instance
  	-- deferred admission calendar
  	-- Validations are:
  	--	- If deferral is not allowed, then the deferred
  	-- admission calendar must not be specified
  	--	- If the admission offer response status has a value of deferral,
  	-- then the deferred admission calendar must be specified
  	--	- If the deferred admission calendar is specified,
  	-- then it must be an admission calendar
  	--	- If the deferred admission calendar is specified,
  	-- then it must be a active calendar instance
  	--	- If the deferred admission calendar is specified,
  	-- then it must be a child of an academic calendar that is the same
  	-- calendar tyoe as the admission application academic calendar.
  	--	- If the deferred admission calendar is specified,
  	-- then it must be for the admission process category of the
  	-- admission application
  	--	- If the deferred admission calendar is specified,
  	-- then the course offering pattern must be valid for the
  	-- deferred admission period
  	--	- If the deferred admission calendar is specified,
  	-- and unit sets are applicable for the admission application
  	-- and then the unit set must be valid for the deferred admission period.
  DECLARE
  	cst_error	CONSTANT	VARCHAR2(1) := 'E';
  	cst_deferral	CONSTANT
  				IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE := 'DEFERRAL';
  	v_s_adm_offer_resp_status	IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
  	v_message_name			VARCHAR2(30);
  	v_return_type			VARCHAR2(1);
  	v_late_ind			VARCHAR2(1);
  BEGIN
  	-- Validate if the deferred admission calendar can be specified
  	IF (p_deferral_allowed = 'N' AND
  			(p_deferred_adm_cal_type IS NOT NULL OR
  			p_deferred_adm_ci_sequence_num IS NOT NULL)) THEN
  		-- The deferred admission calendar must not be
  		-- specified when deferments are not allowed.
  		p_message_name := 'IGS_AD_DFRD_ADMCAL_NOTALLOW';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- Validate that the deferred admission calendar has been specified.
  	v_s_adm_offer_resp_status := IGS_AD_GEN_008.ADMP_GET_SAORS(p_adm_offer_resp_status);
  	IF (v_s_adm_offer_resp_status = cst_deferral AND
  			(p_deferred_adm_cal_type IS NULL OR
  			p_deferred_adm_ci_sequence_num IS NULL)) THEN
  		-- The deferred admission calendar must be
  		-- specified when an offer has been deferred.
  		p_message_name := 'IGS_AD_DFRD_ADMCAL_DEFFERED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	IF (p_deferred_adm_cal_type IS NOT NULL) THEN
  		-- Validate the deferred admission calendar
  		-- Determine the calendar instance sequence number of the academic calendar
  		IF (IGS_AD_VAL_AA.admp_val_aa_adm_cal(
  						p_deferred_adm_cal_type,
  						p_deferred_adm_ci_sequence_num,
  						p_acad_cal_type,
  						p_def_acad_ci_sequence_num,
						p_admission_cat,
  						p_s_admission_process_type,
  						v_message_name) = FALSE) THEN
  			-- The deferred admission calendar is invalid
  			p_message_name := v_message_name;
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- Validate the course offering pattern in the deferred admission period
  		IF (IGS_AD_VAL_ACAI.admp_val_acai_cop(
  						p_course_cd,
  						p_crv_version_number,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type,
  						p_acad_cal_type,
  						p_def_acad_ci_sequence_num,
						p_deferred_adm_cal_type,
  						p_deferred_adm_ci_sequence_num,
  						p_admission_cat,
  						p_s_admission_process_type,
  						'Y', -- Offer indicator
  						p_appl_dt,
  						p_late_appl_allowed,
  						'Y', -- Deferred application
  						v_message_name,
  						v_return_type,
  						v_late_ind) = FALSE) THEN
  			p_message_name := v_message_name;
  			p_return_type := v_return_type;
  			RETURN FALSE;
  		END IF;
  		-- Validate the unit set in the deferred admission period
  		IF (p_unit_set_cd IS NOT NULL) THEN
  			IF (IGS_AD_VAL_ACAI.admp_val_acai_us(
  							p_unit_set_cd,
  							p_us_version_number,
  							p_course_cd,
  							p_crv_version_number,
  							p_acad_cal_type,
  							p_location_cd,
  							p_attendance_mode,
  							p_attendance_type,
  							p_admission_cat,
  							'Y', -- Offer indicator
  							'Y', -- unit Set application
  							v_message_name,
  							v_return_type) = FALSE) THEN
  				p_message_name := v_message_name;
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_dfrmnt_cal');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_dfrmnt_cal;
  --
  -- Validate if admission course application instance corresponce cat.
  FUNCTION admp_val_acai_cc(
  p_admission_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_cc
  	-- Validate that the nominated course admission application is valid
  	-- for the admission application system process type and any existing
  	-- course attempts the student may have
  DECLARE
  	CURSOR c_ccm IS
  		Select 'x'
  		FROM 	IGS_CO_CAT_MAP
  		WHERE	correspondence_cat 	= p_correspondence_cat AND
  			admission_cat 		= p_admission_cat;
  	v_x			VARCHAR2(1) := NULL;
  	v_message_name 		VARCHAR2(30);
  BEGIN
  	p_message_name := NULL;
  	IF (p_correspondence_cat IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate that correspondence category is not closed
  	IF IGS_AD_VAL_ACAI.corp_val_cc_closed(
  					p_correspondence_cat,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		Return FALSE;
  	END IF;
  	-- Validate that correspondence category has a mapping to the
  	-- admission category
  	OPEN c_ccm;
  	FETCH c_ccm INTO v_x;
  	IF (c_ccm%NOTFOUND) THEN
  		CLOSE c_ccm;
  		p_message_name := 'IGS_AD_CORCAT_NOTVALID_ADMCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ccm;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_cc');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_cc;
  --
  -- Validate if IGS_CO_CAT.correspondence_cat is closed.
  FUNCTION corp_val_cc_closed(
  p_correspondence_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	--corp_val_cc_closed
  	--Validate if IGS_CO_CAT.correspondence_cat is closed
  DECLARE
  	v_closed_ind	IGS_CO_CAT.closed_ind%TYPE;
  	CURSOR c_cc IS
  		SELECT	cc.closed_ind
  		FROM	IGS_CO_CAT cc
  		WHERE	cc.correspondence_cat = p_correspondence_cat;
  BEGIN
  	--- Set the default message number
  	p_message_name := NULL;
  	OPEN c_cc;
  	FETCH c_cc INTO v_closed_ind;
  	IF (c_cc%FOUND)THEN
  		IF (v_closed_ind = 'Y') THEN
  			p_message_name := 'IGS_CO_CORCAT_IS_CLOSED' ;
  			CLOSE c_cc;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_cc;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.corp_val_cc_closed');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END corp_val_cc_closed;
  --
  -- Validate if admission course application instance enrolment category.
  FUNCTION admp_val_acai_ec(
  p_admission_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_ec
  	-- Validate that the nominated course admission application is valid
  	-- for the admission application system process type and any
  	-- existing course attempts the student may have
  DECLARE
  	CURSOR c_ccm IS
  		Select 'x'
  		FROM 	IGS_EN_CAT_MAPPING
  		WHERE	enrolment_cat 	= p_enrolment_cat AND
  			admission_cat 	= p_admission_cat;
  	v_x			VARCHAR2(1) := NULL;
  	v_message_name 		VARCHAR2(30);
  BEGIN
  	p_message_name := NULL;
  	IF (p_enrolment_cat IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate that enrolment category is not closed
  	IF IGS_AD_VAL_ECM.enrp_val_ec_closed(
  					p_enrolment_cat,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		Return FALSE;
  	END IF;
  	-- Validate that enrolment category has a mapping to the admission
  	-- category
  	OPEN c_ccm;
  	FETCH c_ccm INTO v_x;
  	IF (c_ccm%NOTFOUND) THEN
  		CLOSE c_ccm;
  		p_message_name := 'IGS_AD_ENRCAT_NOTVALID_ADMCAT' ;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ccm;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_ec');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_ec;


  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed function enrp_val_ec_closed
  -- change  igs_ad_val_acai.enrp_val_ec_closed
  -- to      igs_ad_val_ecm.enrp_val_ec_closed
  --
  --
  -- Validate if admission course application instance fee category.
  FUNCTION admp_val_acai_fc(
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   -- admp_val_acai_fc
  DECLARE
  	CURSOR c_fcm(
  		cp_admission_cat	IGS_FI_FEE_CAT_MAP.admission_cat%TYPE,
  		cp_fee_cat		IGS_FI_FEE_CAT_MAP.fee_cat%TYPE) IS
  		SELECT  'x'
  		FROM	IGS_FI_FEE_CAT_MAP
  		WHERE   fee_cat		= cp_fee_cat AND
  			admission_cat	= cp_admission_cat;
  	v_fcm_rec	c_fcm%ROWTYPE;
  	v_message_name	VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF (p_fee_cat IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	IF IGS_AD_VAL_FCM.finp_val_fc_closed(
  				p_fee_cat,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Cursor handling
  	OPEN c_fcm(
  		p_admission_cat,
  		p_fee_cat);
  	FETCH c_fcm INTO v_fcm_rec;
  	IF c_fcm%NOTFOUND THEN
  		CLOSE c_fcm;
  		p_message_name := 'IGS_AD_FEECAT_NOTVALID_ADMCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_fcm;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	          FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			  FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_fc');
			  IGS_GE_MSG_STACK.ADD;
			  APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_fc;
  --
  -- Validate admission course application instance HECS payment option.
  FUNCTION admp_val_acai_hpo(
  p_admission_cat IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_hpo
  	-- Validate the admission course application instance HECS Payment Option.
  DECLARE
  	v_message_name		VARCHAR2(30);
  	v_achpo_exist		VARCHAR2(1);
  	CURSOR c_achpo IS
  		SELECT 'x'
  		FROM	IGS_AD_CT_HECS_PAYOP
  		WHERE	admission_cat		= p_admission_cat AND
  			HECS_PAYMENT_OPTION	= p_hecs_payment_option;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF (p_hecs_payment_option IS NOT NULL) THEN
  		-- Validate that HECS Payment Option is not closed.
  		IF (igs_en_val_scho.enrp_val_hpo_closed(
  					p_hecs_payment_option,
  					v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate that HECS Payment Option has a mapping to the admission category
  		OPEN c_achpo;
  		FETCH c_achpo INTO v_achpo_exist;
  		IF c_achpo%NOTFOUND THEN
  			CLOSE c_achpo;
  			p_message_name := 'IGS_AD_HECS_PRMT_INVALID';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_achpo;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_hpo');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_acai_hpo;
  --
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_auth_dt.
  FUNCTION admp_val_ovrd_dt(
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ovrd_dt
  	-- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_auth_dt so that
  	-- * The admission outcome status authorising date must be null if the outcome
  	--   status cannot be overridden for the admission process category of the
  	--   admission application.
  	-- * If set, the admission outcome status authorising date must be less than or
  	--   equal to the current date.
  DECLARE
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check if the admission outcome status can be overridden
  	IF p_override_outcome_allowed = 'N' AND
  			p_adm_outcome_status_auth_dt IS NOT NULL THEN
  		p_message_name := 'IGS_AD_ATHDT_SET_ADMOUTSOME';
  		RETURN FALSE;
  	END IF;
  	-- Check if the overriding date is valid
  	IF p_adm_outcome_status_auth_dt IS NOT NULL THEN
  		IF p_adm_outcome_status_auth_dt > SYSDATE THEN
  			p_message_name := 'IGS_AD_ATHDT_LE_CURDT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_ovrd_dt');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_ovrd_dt;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_otcm_status_auth_person_id.
  FUNCTION admp_val_ovrd_person(
  p_adm_otcm_status_auth_person IN NUMBER ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ovrd_person
  	-- Validate the following :
  	-- 1) The admission outcome status authorising IGS_PE_PERSON ID must be null if the
  	-- outcome
  	-- status cannot be overridden for the admission process category of the
  	-- admission application
  	-- 2) The admission outcome status authorising IGS_PE_PERSON ID must be null if the
  	-- admission outcome
  	-- status authorising date is not set
  	-- 3) The admission outcome status authorising IGS_PE_PERSON ID must be set if the
  	-- admission outcome
  	-- status authorising date is set
  	-- 4) If set, the admission outcome status authorising IGS_PE_PERSON ID must be a
  	-- staff member.
  DECLARE
  	v_message_name		VARCHAR2(30);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check if the admission outcome status can be overridden
  	IF p_override_outcome_allowed = 'N' AND
  			p_adm_otcm_status_auth_person IS NOT NULL THEN
  		p_message_name := 'IGS_AD_AUTHORISING_PRSNID';
  		RETURN FALSE;
  	END IF;
  	IF p_adm_outcome_status_auth_dt IS NULL AND
  			p_adm_otcm_status_auth_person IS NOT NULL THEN
  		p_message_name := 'IGS_AD_ARTH_PRSNID_SET';
  		RETURN FALSE;
  	END IF;
  	-- Check if the admission outcome status should be set.
  	IF p_adm_outcome_status_auth_dt IS NOT NULL AND
  			p_adm_otcm_status_auth_person IS NULL THEN
  		p_message_name := 'IGS_AD_ARTH_PRSNID_SET_ARTHDT' ;
  		RETURN FALSE;
  	END IF;
  	-- Check if the overriding IGS_PE_PERSON ID is a staff member.
  	IF p_adm_otcm_status_auth_person IS NOT NULL THEN
  		IF IGS_AD_VAL_ACAI.genp_val_staff_prsn (
  						p_adm_otcm_status_auth_person,
  						v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_ovrd_person');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_ovrd_person;
  --
  -- Validate a IGS_PE_PERSON id to ensure the IGS_PE_PERSON is a staff member.
  FUNCTION genp_val_staff_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
     CURSOR pe_typ_cd IS
     SELECT pti.person_type_code
     FROM igs_pe_person_types pt,igs_pe_typ_instances pti
     WHERE     pti.person_id = p_person_id
           AND pti.person_type_code = pt.person_type_code
           AND pt.system_type = 'STAFF'
           AND SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);
   lv_pe_typ_cd pe_typ_cd%RowType;

  BEGIN
    OPEN pe_typ_cd;
    FETCH pe_typ_cd INTO lv_pe_typ_cd;
    IF (pe_typ_cd%FOUND) THEN
       CLOSE pe_typ_cd;
       p_message_name := NULL;
       RETURN TRUE;
    ELSE
       CLOSE pe_typ_cd;
       p_message_name := 'IGS_GE_NOT_STAFF_MEMBER';
       RETURN FALSE;
    END IF;
   END;
  END genp_val_staff_prsn;
  --
    -- Validate a IGS_PE_PERSON id to ensure the IGS_PE_PERSON is a staff/Faculty member.
  FUNCTION genp_val_staff_fculty_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

     CURSOR pe_typ_cd IS
     SELECT pti.person_type_code
     FROM igs_pe_person_types pt,igs_pe_typ_instances pti
     WHERE     pti.person_id = p_person_id
           AND pti.person_type_code = pt.person_type_code
           AND pt.system_type IN ('STAFF', 'FACULTY')
           AND SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);
   lv_pe_typ_cd pe_typ_cd%RowType;

   CURSOR c_dmi IS
   SELECT 'X'
   FROM  igs_pe_person_base_v base, igs_pe_hz_parties pd
   WHERE base.person_id = p_person_id
   AND  base.person_id = pd.party_id (+)
   AND  DECODE(base.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y') = 'Y';

   l_deceased igs_pe_person.person_id%TYPE := NULL;

  BEGIN

    OPEN pe_typ_cd;
    FETCH pe_typ_cd INTO lv_pe_typ_cd;
    CLOSE pe_typ_cd;

    OPEN c_dmi;
    FETCH c_dmi INTO l_deceased;
    CLOSE c_dmi;


    IF lv_pe_typ_cd.person_type_code IS NULL OR l_deceased IS NOT NULL
    THEN
       p_message_name := 'IGS_AD_NOT_STAF_FAC_MEMBER';
       RETURN FALSE;
    END IF;

  RETURN  TRUE;
  END genp_val_staff_fculty_prsn;

      -- Validate a IGS_PE_PERSON id to ensure the IGS_PE_PERSON is a staff/Faculty OR Evaluator  member.
  FUNCTION genp_val_staff_fac_eva_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

     CURSOR pe_typ_cd IS
     SELECT pti.person_type_code
     FROM igs_pe_person_types pt,igs_pe_typ_instances pti
     WHERE     pti.person_id = p_person_id
           AND pti.person_type_code = pt.person_type_code
           AND pt.system_type IN ('STAFF', 'FACULTY' , 'EVALUATOR')
           AND SYSDATE BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE);
   lv_pe_typ_cd pe_typ_cd%RowType;

   CURSOR c_dmi IS
   SELECT 'X'
   FROM  igs_pe_person_base_v base, igs_pe_hz_parties pd
   WHERE base.person_id = p_person_id
   AND  base.person_id = pd.party_id (+)
   AND  DECODE(base.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y') = 'Y';

   l_deceased igs_pe_person.person_id%TYPE := NULL;

  BEGIN

    OPEN pe_typ_cd;
    FETCH pe_typ_cd INTO lv_pe_typ_cd;
    CLOSE pe_typ_cd;

    OPEN c_dmi;
    FETCH c_dmi INTO l_deceased;
    CLOSE c_dmi;


    IF lv_pe_typ_cd.person_type_code IS NULL OR l_deceased IS NOT NULL
    THEN
       p_message_name := 'IGS_AD_NOT_STAF_FAC_EVA_MEMBER';
       RETURN FALSE;
    END IF;

  RETURN  TRUE;
  END genp_val_staff_fac_eva_prsn;

  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_reason.
  FUNCTION admp_val_ovrd_reason(
  p_adm_outcome_status_reason IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_ovrd_reason
  	-- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_reason so that
  	-- * The admission outcome status reason must be null if the outcome
  	-- status cannot be overridden for the admission process category of the
  	-- admission application.
  	-- * The admission outcome status reason must be null if the admission outcome
  	-- status authorising date is not set
  DECLARE
  BEGIN
  	p_message_name := NULL;
  	IF (p_override_outcome_allowed = 'N' AND
  			p_adm_outcome_status_reason IS NOT NULL) THEN
  		p_message_name := 'IGS_AD_REASON_SET_ADMOUTCOME';
  		RETURN FALSE;
  	END IF;
  	IF (p_adm_outcome_status_auth_dt IS NULL AND
  			p_adm_outcome_status_reason IS NOT NULL) THEN
  		p_message_name := 'IGS_AD_REASON_SET_ARTHDT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_ovrd_reason');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_ovrd_reason;
  --
  -- Validate that the course application is complete on offer.
  FUNCTION admp_val_offer_comp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_called_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_offer_comp
  	-- Validate that the course application is complete on offer
  DECLARE
  	v_message_name			VARCHAR2(30);
  	v_mandatory_athletics 		BOOLEAN;
  	v_mandatory_alternate 		BOOLEAN;
  	v_mandatory_address 		BOOLEAN;
  	v_mandatory_disability 		BOOLEAN;
  	v_mandatory_visa 		BOOLEAN;
  	v_mandatory_finance 		BOOLEAN;
  	v_mandatory_notes 		BOOLEAN;
  	v_mandatory_statistics 		BOOLEAN;
  	v_mandatory_alias 		BOOLEAN;
  	v_mandatory_tertiary 		BOOLEAN;
  	v_mandatory_aus_sec_ed 		BOOLEAN;
  	v_mandatory_os_sec_ed 		BOOLEAN;
  	v_mandatory_employment 		BOOLEAN;
  	v_mandatory_membership 		BOOLEAN;
  	v_mandatory_dob 		BOOLEAN;
  	v_mandatory_title 		BOOLEAN;
  	v_mandatory_referee 		BOOLEAN;
  	v_mandatory_scholarship 	BOOLEAN;
  	v_mandatory_lang_prof 		BOOLEAN;
  	v_mandatory_interview 		BOOLEAN;
  	v_mandatory_exchange 		BOOLEAN;
  	v_mandatory_adm_test		BOOLEAN;
  	v_mandatory_fee_assess 		BOOLEAN;
  	v_mandatory_cor_category 	BOOLEAN;
  	v_mandatory_enr_category 	BOOLEAN;
  	v_mandatory_research 		BOOLEAN;
  	v_mandatory_rank_app 		BOOLEAN;
  	v_mandatory_completion 		BOOLEAN;
  	v_mandatory_rank_set 		BOOLEAN;
  	v_mandatory_basis_adm 		BOOLEAN;
  	v_mandatory_crs_international	BOOLEAN;
  	v_mandatory_ass_tracking 	BOOLEAN;
  	v_mandatory_adm_code 		BOOLEAN;
  	v_mandatory_fund_source		BOOLEAN;
  	v_mandatory_location 		BOOLEAN;
  	v_mandatory_att_mode 		BOOLEAN;
  	v_mandatory_att_type 		BOOLEAN;
  	v_mandatory_unit_set		BOOLEAN;
  	v_valid_athletics 		BOOLEAN;
  	v_valid_alternate 		BOOLEAN;
  	v_valid_address 		BOOLEAN;
  	v_valid_disability 		BOOLEAN;
  	v_valid_visa 			BOOLEAN;
  	v_valid_finance 		BOOLEAN;
  	v_valid_notes 			BOOLEAN;
  	v_valid_statistics 		BOOLEAN;
  	v_valid_alias 			BOOLEAN;
  	v_valid_tertiary 		BOOLEAN;
  	v_valid_aus_sec_ed 		BOOLEAN;
  	v_valid_os_sec_ed 		BOOLEAN;
  	v_valid_employment 		BOOLEAN;
  	v_valid_membership 		BOOLEAN;
  	v_valid_dob 			BOOLEAN;
  	v_valid_title			BOOLEAN;
  	v_valid_referee			BOOLEAN;
  	v_valid_scholarship 		BOOLEAN;
  	v_valid_lang_prof	 	BOOLEAN;
  	v_valid_interview 		BOOLEAN;
  	v_valid_exchange 		BOOLEAN;
  	v_valid_adm_test		BOOLEAN;
  	v_valid_fee_assess 		BOOLEAN;
  	v_valid_cor_category 		BOOLEAN;
  	v_valid_enr_category 		BOOLEAN;
  	v_valid_research 		BOOLEAN;
  	v_valid_rank_app 		BOOLEAN;
  	v_valid_completion 		BOOLEAN;
  	v_valid_rank_set 		BOOLEAN;
  	v_valid_basis_adm 		BOOLEAN;
  	v_valid_crs_international 	BOOLEAN;
  	v_valid_ass_tracking 		BOOLEAN;
  	v_valid_adm_code 		BOOLEAN;
  	v_valid_fund_source		BOOLEAN;
  	v_valid_location 		BOOLEAN;
  	v_valid_att_mode 		BOOLEAN;
  	v_valid_att_type 		BOOLEAN;
  	v_valid_unit_set		BOOLEAN;
	v_valid_extrcurr                BOOLEAN;
        v_mandatory_evaluation_tab      BOOLEAN;
        v_mandatory_prog_approval       BOOLEAN;
        v_mandatory_indices             BOOLEAN;
        v_mandatory_tst_scores          BOOLEAN;
        v_mandatory_outcome           BOOLEAN ;
        v_mandatory_override          BOOLEAN ;
        v_mandatory_spl_consider      BOOLEAN ;
        v_mandatory_cond_offer        BOOLEAN ;
        v_mandatory_offer_dead        BOOLEAN ;
        v_mandatory_offer_resp        BOOLEAN ;
        v_mandatory_offer_defer       BOOLEAN ;
        v_mandatory_offer_compl       BOOLEAN ;
        v_mandatory_transfer          BOOLEAN ;
        v_mandatory_other_inst        BOOLEAN ;
        v_mandatory_edu_goals         BOOLEAN ;
        v_mandatory_acad_interest     BOOLEAN ;
        v_mandatory_app_intent        BOOLEAN ;
        v_mandatory_spl_interest      BOOLEAN ;
        v_mandatory_spl_talents       BOOLEAN ;
        v_mandatory_miscell           BOOLEAN ;
        v_mandatory_fees              BOOLEAN ;
        v_mandatory_program           BOOLEAN ;
        v_mandatory_completness       BOOLEAN ;
        v_mandatory_creden            BOOLEAN ;
        v_mandatory_review_det        BOOLEAN ;
        v_mandatory_recomm_det        BOOLEAN ;
        v_mandatory_fin_aid           BOOLEAN ;
        v_mandatory_acad_honors       BOOLEAN ;
        v_mandatory_des_unitsets      BOOLEAN ; -- added for 2382599
	v_mandatory_extrcurr 	      BOOLEAN;


  BEGIN
  	--set the default message number
  	p_message_name := NULL;
  	--get the mandatory admission steps
  	IGS_AD_GEN_003.ADMP_GET_APCS_MNDTRY(
  			p_admission_cat,
  			p_s_admission_process_type,
  			v_mandatory_athletics,
  			v_mandatory_alternate,
  			v_mandatory_address,
  			v_mandatory_disability,
  			v_mandatory_visa,
  			v_mandatory_finance,
  			v_mandatory_notes,
  			v_mandatory_statistics,
  			v_mandatory_alias,
  			v_mandatory_tertiary,
  			v_mandatory_aus_sec_ed,
  			v_mandatory_os_sec_ed,
  			v_mandatory_employment,
  			v_mandatory_membership,
  			v_mandatory_dob,
  			v_mandatory_title,
  			v_mandatory_referee,
  			v_mandatory_scholarship,
  			v_mandatory_lang_prof,
  			v_mandatory_interview,
  			v_mandatory_exchange,
  			v_mandatory_adm_test,
  			v_mandatory_fee_assess,
  			v_mandatory_cor_category,
  			v_mandatory_enr_category,
  			v_mandatory_research,
  			v_mandatory_rank_app,
  			v_mandatory_completion,
  			v_mandatory_rank_set,
  			v_mandatory_basis_adm,
  			v_mandatory_crs_international,
  			v_mandatory_ass_tracking,
  			v_mandatory_adm_code,
  			v_mandatory_fund_source,
  			v_mandatory_location,
  			v_mandatory_att_mode,
  			v_mandatory_att_type,
  			v_mandatory_unit_set,
                        v_mandatory_evaluation_tab,
                        v_mandatory_prog_approval ,
                        v_mandatory_indices       ,
                        v_mandatory_tst_scores   ,
                        v_mandatory_outcome       ,
                        v_mandatory_override      ,
                        v_mandatory_spl_consider ,
                        v_mandatory_cond_offer    ,
                        v_mandatory_offer_dead    ,
                        v_mandatory_offer_resp    ,
                        v_mandatory_offer_defer   ,
                        v_mandatory_offer_compl   ,
                        v_mandatory_transfer      ,
                        v_mandatory_other_inst   ,
                        v_mandatory_edu_goals   ,
                        v_mandatory_acad_interest ,
                        v_mandatory_app_intent    ,
                        v_mandatory_spl_interest  ,
                        v_mandatory_spl_talents   ,
                        v_mandatory_miscell       ,
                        v_mandatory_fees          ,
                        v_mandatory_program      ,
                        v_mandatory_completness   ,
                        v_mandatory_creden        ,
                        v_mandatory_review_det   ,
                        v_mandatory_recomm_det ,
                        v_mandatory_fin_aid       ,
                        v_mandatory_acad_honors ,
                        v_mandatory_des_unitsets,
			v_mandatory_extrcurr);

  	--validate if the admission application IGS_PE_PERSON details are complete
  	IF (IGS_AD_VAL_ACAI.admp_val_pe_comp(
  				p_person_id,
  				p_effective_dt,
  			        v_mandatory_athletics,
  				v_mandatory_alternate,
  				v_mandatory_address,
  				v_mandatory_disability,
  				v_mandatory_visa,
  				v_mandatory_finance,
  				v_mandatory_notes,
  				v_mandatory_statistics,
  				v_mandatory_alias,
  				v_mandatory_tertiary,
  				v_mandatory_aus_sec_ed,
  				v_mandatory_os_sec_ed,
  				v_mandatory_employment,
  				v_mandatory_membership,
  				v_mandatory_dob,
  				v_mandatory_title,
  				v_mandatory_extrcurr,
				v_message_name,
  				v_valid_athletics,
  				v_valid_alternate,
  				v_valid_address,
  				v_valid_disability,
  				v_valid_visa,
  				v_valid_finance,
  				v_valid_notes,
  				v_valid_statistics,
  				v_valid_alias,
  				v_valid_tertiary,
  				v_valid_aus_sec_ed,
  				v_valid_os_sec_ed,
  				v_valid_employment,
  				v_valid_membership,
  				v_valid_dob,
  				v_valid_title,
				v_valid_extrcurr ) = FALSE) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Validate if the admission application course details are complete
  	-- Only peform this validation if not called from the form.
  	IF p_called_from <> 'FORM' THEN
  		IF (IGS_AD_VAL_ACAI.admp_val_acai_comp(
  					p_person_id,
  					p_admission_appl_number,
  					p_nominated_course_cd,
  					p_acai_sequence_number,
  					p_course_cd,
  					p_crv_version_number,
  					p_s_admission_process_type,
  					p_effective_dt,
  					v_mandatory_referee,
  					v_mandatory_scholarship,
  					v_mandatory_lang_prof,
  					v_mandatory_interview,
  					v_mandatory_exchange,
  					v_mandatory_adm_test,
  					v_mandatory_fee_assess,
  					v_mandatory_cor_category,
  					v_mandatory_enr_category,
  					v_mandatory_research,
  					v_mandatory_rank_app,
  					v_mandatory_completion,
  					v_mandatory_rank_set,
  					v_mandatory_basis_adm,
  					v_mandatory_crs_international,
  					v_mandatory_ass_tracking,
  					v_mandatory_adm_code,
  					v_mandatory_fund_source,
  					v_mandatory_location,
  					v_mandatory_att_mode,
  					v_mandatory_att_type,
  					v_mandatory_unit_set,
  					v_message_name,
  					v_valid_referee,
  					v_valid_scholarship,
  					v_valid_lang_prof,
  					v_valid_interview,
  					v_valid_exchange,
  					v_valid_adm_test,
  					v_valid_fee_assess,
  					v_valid_cor_category,
  					v_valid_enr_category,
  					v_valid_research,
  					v_valid_rank_app,
  					v_valid_completion,
  					v_valid_rank_set,
  					v_valid_basis_adm,
  					v_valid_crs_international,
  					v_valid_ass_tracking,
  					v_valid_adm_code,
  					v_valid_fund_source,
  					v_valid_location,
  					v_valid_att_mode,
  					v_valid_att_type,
  					v_valid_unit_set) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
				 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_offer_comp');
				 IGS_GE_MSG_STACK.ADD;
				 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_offer_comp;
  --
  -- Validate if the specified IGS_AD_PS_APPL_INST is complete.
  FUNCTION admp_val_acai_comp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_check_referee IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_check_lang_prof IN BOOLEAN ,
  p_check_interview IN BOOLEAN ,
  p_check_exchange IN BOOLEAN ,
  p_check_adm_test IN BOOLEAN ,
  p_check_fee_assess IN BOOLEAN ,
  p_check_cor_category IN BOOLEAN ,
  p_check_enr_category IN BOOLEAN ,
  p_check_research IN BOOLEAN ,
  p_check_rank_app IN BOOLEAN ,
  p_check_completion IN BOOLEAN ,
  p_check_rank_set IN BOOLEAN ,
  p_check_basis_adm IN BOOLEAN ,
  p_check_crs_international IN BOOLEAN ,
  p_check_ass_tracking IN BOOLEAN ,
  p_check_adm_code IN BOOLEAN ,
  p_check_fund_source IN BOOLEAN ,
  p_check_location IN BOOLEAN ,
  p_check_att_mode IN BOOLEAN ,
  p_check_att_type IN BOOLEAN ,
  p_check_unit_set IN BOOLEAN ,
  p_message_name OUT NOCOPY  VARCHAR2 ,
  p_valid_referee OUT NOCOPY BOOLEAN ,
  p_valid_scholarship OUT NOCOPY BOOLEAN ,
  p_valid_lang_prof OUT NOCOPY BOOLEAN ,
  p_valid_interview OUT NOCOPY BOOLEAN ,
  p_valid_exchange OUT NOCOPY BOOLEAN ,
  p_valid_adm_test OUT NOCOPY BOOLEAN ,
  p_valid_fee_assess OUT NOCOPY BOOLEAN ,
  p_valid_cor_category OUT NOCOPY BOOLEAN ,
  p_valid_enr_category OUT NOCOPY BOOLEAN ,
  p_valid_research OUT NOCOPY BOOLEAN ,
  p_valid_rank_app OUT NOCOPY BOOLEAN ,
  p_valid_completion OUT NOCOPY BOOLEAN ,
  p_valid_rank_set OUT NOCOPY BOOLEAN ,
  p_valid_basis_adm OUT NOCOPY BOOLEAN ,
  p_valid_crs_international OUT NOCOPY BOOLEAN ,
  p_valid_ass_tracking OUT NOCOPY BOOLEAN ,
  p_valid_adm_code OUT NOCOPY BOOLEAN ,
  p_valid_fund_source OUT NOCOPY BOOLEAN ,
  p_valid_location OUT NOCOPY BOOLEAN ,
  p_valid_att_mode OUT NOCOPY BOOLEAN ,
  p_valid_att_type OUT NOCOPY BOOLEAN ,
  p_valid_unit_set OUT NOCOPY BOOLEAN )
  RETURN BOOLEAN AS
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --samaresh    21-DEC-2001     Bug No. 2158524 . The cursor c_ar has been modified as the
  --                            the table IGS_AD_APP_ REQ has been moved from application
  --                            instance level to application level
  -- ssawhney   24-oct-2002     SWS104 build 2630860, AD_ACAD_HONOR reference moved to PE.
  -------------------------------------------------------------------------------------------

  BEGIN	-- admp_val_acai_comp
  	-- Validate if the specified IGS_AD_PS_APPL_INST is complete
  DECLARE
  	cst_re_admit			VARCHAR2(10) := 'RE-ADMIT';
  	v_check_research		BOOLEAN		:=  FALSE;
  	v_valid_referee			BOOLEAN		:= FALSE;
  	v_valid_scholarship		BOOLEAN		:= FALSE;
  	v_valid_lang_prof		BOOLEAN		:= FALSE;
  	v_valid_interview		BOOLEAN		:= FALSE;
  	v_valid_exchange		BOOLEAN		:= FALSE;
  	v_valid_adm_test		BOOLEAN		:= FALSE;
  	v_valid_fee_assess		BOOLEAN		:= FALSE;
  	v_valid_cor_category		BOOLEAN		:= FALSE;
  	v_valid_enr_category		BOOLEAN		:= FALSE;
  	v_valid_research		BOOLEAN		:= FALSE;
  	v_valid_rank_app		BOOLEAN		:= FALSE;
  	v_valid_completion		BOOLEAN		:= FALSE;
  	v_valid_rank_set		BOOLEAN		:= FALSE;
  	v_valid_basis_adm		BOOLEAN		:= FALSE;
  	v_valid_crs_international	BOOLEAN		:= FALSE;
  	v_valid_ass_tracking		BOOLEAN		:= FALSE;
  	v_valid_adm_code		BOOLEAN		:= FALSE;
  	v_valid_fund_source		BOOLEAN		:= FALSE;
  	v_valid_location		BOOLEAN		:= FALSE;
  	v_valid_att_mode		BOOLEAN		:= FALSE;
  	v_valid_att_type		BOOLEAN		:= FALSE;
  	v_valid_unit_set		BOOLEAN		:= FALSE;
  	v_location_cd			IGS_AD_PS_APPL_INST_APLINST_V.location_cd%TYPE;
  	v_attendance_mode		IGS_AD_PS_APPL_INST_APLINST_V.attendance_mode%TYPE;
  	v_attendance_type		IGS_AD_PS_APPL_INST_APLINST_V.attendance_type%TYPE;
  	v_unit_set_cd			IGS_AD_PS_APPL_INST_APLINST_V.unit_set_cd%TYPE;
  	v_us_version_number		IGS_AD_PS_APPL_INST_APLINST_V.us_version_number%TYPE;
  	v_ass_rank			IGS_AD_PS_APPL_INST_APLINST_V.ass_rank%TYPE;
  	v_intrntnl_accptnce_advice_num
  					IGS_AD_PS_APPL_INST_APLINST_V.intrntnl_acceptance_advice_num%TYPE;
  	v_ass_tracking_id		IGS_AD_PS_APPL_INST_APLINST_V.ass_tracking_id%TYPE;
  	v_fee_cat			IGS_AD_PS_APPL_INST_APLINST_V.fee_cat%TYPE;
  	v_expected_completion_yr	IGS_AD_PS_APPL_INST_APLINST_V.expected_completion_yr%TYPE;
  	v_expected_completion_perd
  					IGS_AD_PS_APPL_INST_APLINST_V.expected_completion_perd%TYPE;
  	v_correspondence_cat		IGS_AD_PS_APPL_INST_APLINST_V.correspondence_cat%TYPE;
  	v_enrolment_cat			IGS_AD_PS_APPL_INST_APLINST_V.enrolment_cat%TYPE;
  	v_funding_source		IGS_AD_PS_APPL_INST_APLINST_V.funding_source%TYPE;
  	v_basis_for_admission_type
  					IGS_AD_PS_APPL_INST_APLINST_V.basis_for_admission_type%TYPE;
  	v_admission_cd			IGS_AD_PS_APPL_INST_APLINST_V.admission_cd%TYPE;
  	v_course_rank_set		IGS_AD_PS_APPL_INST_APLINST_V.course_rank_set%TYPE;
  	v_course_rank_schedule		IGS_AD_PS_APPL_INST_APLINST_V.course_rank_schedule%TYPE;
  	v_sca_fee_cat			IGS_EN_STDNT_PS_ATT.fee_cat%TYPE;
  	v_sca_funding_source		IGS_EN_STDNT_PS_ATT.funding_source%TYPE;
  	v_sca_correspondence_cat	IGS_EN_STDNT_PS_ATT.correspondence_cat%TYPE;
  	v_scae_enrolment_cat		IGS_AS_SC_ATMPT_ENR.enrolment_cat%TYPE;
  	v_dummy				VARCHAR2(1);
        v_error_message_research        VARCHAR2(30);

  	CURSOR c_acaiv IS
  		SELECT	acaiv.location_cd,
  			acaiv.attendance_mode,
  			acaiv.attendance_type,
  			acaiv.unit_set_cd,
  			acaiv.us_version_number,
  			acaiv.ass_rank,
  			acaiv.intrntnl_acceptance_advice_num,
  			acaiv.ass_tracking_id,
  			acaiv.fee_cat,
  			acaiv.expected_completion_yr,
  			acaiv.expected_completion_perd,
  			acaiv.correspondence_cat,
  			acaiv.enrolment_cat,
  			acaiv.funding_source,
  			acav.basis_for_admission_type,
  			acav.admission_cd,
  			acav.course_rank_set,
  			acav.course_rank_schedule
  		FROM	IGS_AD_PS_APPL_INST	acaiv,
 		  	    IGS_AD_PS_APPL	acav
  		WHERE	acaiv.person_id 		= p_person_id AND
  			acaiv.admission_appl_number 	= p_admission_appl_number AND
  			acaiv.nominated_course_cd 	= p_nominated_course_cd AND
  			acaiv.sequence_number 		= p_acai_sequence_number AND
  			acav.person_id 		= acaiv.person_id AND
  			acav.admission_appl_number 	= acaiv.admission_appl_number AND
  			acav.nominated_course_cd 	= acav.nominated_course_cd;
  	CURSOR c_sca IS
  		SELECT	sca.fee_cat,
  			sca.correspondence_cat,
  			sca.funding_source
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id	AND
  			sca.course_cd	= p_course_cd;
  	CURSOR c_scae IS
  		SELECT	scae.enrolment_cat
  		FROM	IGS_AS_SC_ATMPT_ENR	scae
  		WHERE	scae.person_id	= p_person_id	AND
  			scae.course_cd	= p_course_cd;
  	CURSOR c_crv IS
  		SELECT	'x'
  		FROM	IGS_PS_VER crv,
  			IGS_PS_TYPE cty
  		WHERE	crv.course_cd 		= p_course_cd AND
  			crv.version_number 	= p_crv_version_number AND
  			cty.course_type 	= crv.course_type AND
  			cty.research_type_ind 	= 'Y';

      v_return  BOOLEAN := TRUE;
      v_person_id  igs_pe_person_v.person_id%TYPE;
    CURSOR c_apcs IS
		  SELECT	apcs.s_admission_step_type
  		FROM	IGS_AD_PRCS_CAT_STEP	apcs
		  WHERE admission_cat= (SELECT admission_cat
				                    FROM IGS_AD_APPL  /* Replaced IGS_AD_APPL_ADMAPPL_V with IGS_AD_APPL Bug 3150054 */
                            WHERE person_id = p_person_id AND
                                  admission_appl_number=p_admission_appl_number) AND
		        s_admission_process_type = p_s_admission_process_type	AND
		        mandatory_step_ind = 'Y' AND
		        step_group_type <> 'TRACK';

            CURSOR c_ae IS
		SELECT	person_id
		FROM	IGS_ad_appl_eval_v
		WHERE	person_id	= p_person_id AND
	            admission_appl_number = p_admission_appl_number AND
			nominated_course_cd = p_nominated_course_cd;
            CURSOR c_pa IS
		SELECT	person_id
		FROM	igs_Ad_appl_pgmapprv_v
		WHERE	person_id	= p_person_id AND
	            admission_appl_number = p_admission_appl_number AND
			nominated_course_cd = p_nominated_course_cd;
            CURSOR c_us IS
		SELECT	person_id
		FROM	igs_ad_unit_sets_v
		WHERE	person_id	= p_person_id AND
	            admission_appl_number = p_admission_appl_number AND
			nominated_course_cd = p_nominated_course_cd;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
	    CURSOR c_oi IS
		SELECT	person_id
		FROM	igs_ad_other_inst
		WHERE	person_id	= p_person_id AND
	        admission_appl_number = p_admission_appl_number;
            CURSOR c_eg IS
		SELECT	person_id
		FROM	igs_ad_edu_goal_v
		WHERE	person_id	= p_person_id AND
	            admission_appl_number = p_admission_appl_number AND
			nominated_course_cd = p_nominated_course_cd;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
            CURSOR c_ai IS
		SELECT	person_id
		FROM	igs_ad_acad_interest_v
		WHERE	person_id	= p_person_id AND
	                admission_appl_number = p_admission_appl_number;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
            CURSOR c_in IS
		SELECT	person_id
		FROM	igs_ad_app_intent_v
		WHERE	person_id	= p_person_id AND
	                admission_appl_number = p_admission_appl_number;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
            CURSOR c_si IS
		SELECT	person_id
		FROM	igs_ad_spl_interests_v
		WHERE	person_id	= p_person_id AND
	                admission_appl_number = p_admission_appl_number;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
            CURSOR c_st IS
		SELECT	person_id
		FROM	igs_ad_spl_talents_v
		WHERE	person_id	= p_person_id AND
	                admission_appl_number = p_admission_appl_number;
            CURSOR c_ar IS
		SELECT	person_id
		FROM	igs_ad_app_req_v
		WHERE	person_id	= p_person_id AND
                        admission_appl_number = p_admission_appl_number;
	    -- Enh# 2177686, DAP Re-design. To revisit in Adimit to future term.
            CURSOR c_ac IS
		SELECT	person_id
		FROM	igs_pe_credentials
		WHERE	person_id	= p_person_id;
	    -- Enh# 2177686, DAP Re-design. Removed the nominated_course_cd join.
	    -- Enh# SWS104 build, 2630860 acad honors moved to PE
	    CURSOR c_ah IS
		SELECT	person_id
		FROM	igs_pe_acad_honors_v
		WHERE	person_id	= p_person_id ;
		CURSOR c_md IS
		SELECT	apply_for_finaid,
            app_file_location,
			late_adm_fee_status,
			enrolment_cat,
			fee_cat,
			hecs_payment_option,
			app_source_id,
			correspondence_cat,
			funding_source
		FROM	igs_ad_ps_appl_inst
		WHERE	person_id	= p_person_id AND
	        admission_appl_number = p_admission_appl_number AND
			    nominated_course_cd = p_nominated_course_cd;

    CURSOR c_id_exist IS
      SELECT person_id
      FROM   igs_ad_panel_dtls
      WHERE  person_id = p_person_id AND
         	   admission_appl_number = p_admission_appl_number AND
    	       nominated_course_cd = p_nominated_course_cd AND
             sequence_number = p_acai_sequence_number AND
             final_decision_type = 'FINAL_INTERVIEW';
    CURSOR c_id IS
      SELECT person_id
      FROM   igs_ad_panel_dtls
      WHERE  person_id = p_person_id AND
        	   admission_appl_number = p_admission_appl_number AND
    	       nominated_course_cd = p_nominated_course_cd AND
             sequence_number = p_acai_sequence_number AND
             final_decision_type = 'FINAL_INTERVIEW' AND
             EXISTS (SELECT 'x'
                     FROM   igs_ad_code_classes
                     WHERE  class = 'FINAL_INTERVIEW'
                     AND    name = final_decision_code
                     AND    system_status <> 'PENDING'
		     AND    CLASS_TYPE_CODE='ADM_CODE_CLASSES');

      v_app_file_location1 igs_ad_ps_appl_inst.app_file_location%TYPE;
			v_late_adm_fee_status1 igs_ad_ps_appl_inst.late_adm_fee_status%TYPE;
			v_enrolment_cat1 igs_ad_ps_appl_inst.enrolment_cat%TYPE;
			v_fee_cat1 igs_ad_ps_appl_inst.fee_cat%TYPE;
			v_hecs_payment_option1 igs_ad_ps_appl_inst.hecs_payment_option%TYPE;
			v_app_source_id1 igs_ad_ps_appl_inst.app_source_id%TYPE;
			v_correspondence_cat1 igs_ad_ps_appl_inst.correspondence_cat%TYPE;
			v_funding_source1 igs_ad_ps_appl_inst.funding_source%TYPE;
	                v_apply_for_finaid VARCHAR2(1);
  BEGIN
  	-- Initialise the output 'valid' parameters
  	IF (p_check_referee) THEN
  		p_valid_referee	:= FALSE;
  	ELSE
  		p_valid_referee	:= TRUE;
  	END IF;
  	IF (p_check_scholarship) THEN
  		p_valid_scholarship := FALSE;
  	ELSE
  		p_valid_scholarship := TRUE;
  	END IF;
  	IF (p_check_lang_prof) THEN
  		p_valid_lang_prof := FALSE;
  	ELSE
  		p_valid_lang_prof := TRUE;
  	END IF;
  	IF (p_check_interview) THEN
  		p_valid_interview := FALSE;
  	ELSE
  		p_valid_interview := TRUE;
  	END IF;
  	IF (p_check_exchange) THEN
  		p_valid_exchange := FALSE;
  	ELSE
  		p_valid_exchange := TRUE;
  	END IF;
  	IF (p_check_adm_test) THEN
  		p_valid_adm_test := FALSE;
  	ELSE
  		p_valid_adm_test := TRUE;
  	END IF;
  	IF (p_check_fee_assess) THEN
  		p_valid_fee_assess := FALSE;
  	ELSE
  		p_valid_fee_assess := TRUE;
  	END IF;
  	IF (p_check_cor_category) THEN
  		p_valid_cor_category := FALSE;
  	ELSE
  		p_valid_cor_category := TRUE;
  	END IF;
  	IF (p_check_enr_category) THEN
  		p_valid_enr_category := FALSE;
  	ELSE
  		p_valid_enr_category := TRUE;
  	END IF;
  	IF (p_check_research) THEN
  		p_valid_research := FALSE;
  		v_check_research := TRUE;
  	ELSE
  		-- Check if research data should be mandatory.
  		-- Research data is mandatory for research courses.
  		OPEN c_crv;
  		FETCH c_crv INTO v_dummy;
  		IF c_crv%FOUND THEN
  			CLOSE c_crv;
  			v_check_research := TRUE;
  			p_valid_research := FALSE;
  		ELSE
  			CLOSE c_crv;
  			v_check_research := FALSE;
  			p_valid_research := TRUE;
  		END IF;
  	END IF;
  	IF (p_check_rank_app) THEN
  		p_valid_rank_app := FALSE;
  	ELSE
  		p_valid_rank_app := TRUE;
  	END IF;
  	IF (p_check_completion) THEN
  		p_valid_completion := FALSE;
  	ELSE
  		p_valid_completion := TRUE;
  	END IF;
  	IF (p_check_rank_set) THEN
  		p_valid_rank_set := FALSE;
  	ELSE
  		p_valid_rank_set := TRUE;
  	END IF;
  	IF (p_check_basis_adm) THEN
  		p_valid_basis_adm := FALSE;
  	ELSE
  		p_valid_basis_adm := TRUE;
  	END IF;
  	IF (p_check_crs_international) THEN
  		p_valid_crs_international := FALSE;
  	ELSE
  		p_valid_crs_international := TRUE;
  	END IF;
  	IF (p_check_ass_tracking) THEN
  		p_valid_ass_tracking := FALSE;
  	ELSE
  		p_valid_ass_tracking := TRUE;
  	END IF;
  	IF (p_check_adm_code) THEN
  		p_valid_adm_code := FALSE;
  	ELSE
  		p_valid_adm_code := TRUE;
  	END IF;
  	IF (p_check_fund_source) THEN
  		p_valid_fund_source := FALSE;
  	ELSE
  		p_valid_fund_source := TRUE;
  	END IF;
  	IF (p_check_location) THEN
  		p_valid_location := FALSE;
  	ELSE
  		p_valid_location := TRUE;
  	END IF;
  	IF (p_check_att_mode) THEN
  		p_valid_att_mode := FALSE;
  	ELSE
  		p_valid_att_mode := TRUE;
  	END IF;
  	IF (p_check_att_type) THEN
  		p_valid_att_type := FALSE;
  	ELSE
  		p_valid_att_type := TRUE;
  	END IF;
  	IF (p_check_unit_set) THEN
  		p_valid_unit_set := FALSE;
  	ELSE
  		p_valid_unit_set := TRUE;
  	END IF;
  	-- Validate course level data
  	IF (p_check_referee = TRUE OR
  			p_check_scholarship	= TRUE OR
  			p_check_lang_prof	= TRUE OR
  			p_check_interview 	= TRUE OR
  			p_check_exchange 	= TRUE OR
  			p_check_adm_test	= TRUE OR
  			v_check_research	= TRUE) THEN
  		IGS_AD_GEN_004.ADMP_GET_CRS_EXISTS(
  				p_person_id,
  				p_admission_appl_number,
  				p_nominated_course_cd,
  				p_acai_sequence_number,
  				p_course_cd,
  				p_effective_dt,
  				p_s_admission_process_type,
  				p_check_referee,
  				p_check_scholarship,
  				p_check_lang_prof,
  				p_check_interview,
  				p_check_exchange,
  				p_check_adm_test,
  				v_check_research,
  				v_valid_referee,
  				v_valid_scholarship,
  				v_valid_lang_prof,
  				v_valid_interview,
  				v_valid_exchange,
  				v_valid_adm_test,
  				v_valid_research,
				v_error_message_research);

      IF v_error_message_research IS NULL THEN
        v_error_message_research := 'IGS_AD_INVALID_RESDET';
      END IF;

  		IF (v_valid_referee = TRUE) THEN
  			p_valid_referee := TRUE;
  		END IF;
  		IF (v_valid_scholarship = TRUE) THEN
  			p_valid_scholarship := TRUE;
  		END IF;
  		IF (v_valid_lang_prof = TRUE) THEN
  			p_valid_lang_prof := TRUE;
  		END IF;
  		IF (v_valid_interview = TRUE) THEN
  			p_valid_interview := TRUE;
  		END IF;
  		IF (v_valid_exchange = TRUE) THEN
  			p_valid_exchange := TRUE;
  		END IF;
  		IF (v_valid_adm_test = TRUE) THEN
  			p_valid_adm_test := TRUE;
  		END IF;
  		IF (v_valid_research = TRUE) THEN
  			p_valid_research := TRUE;
  		END IF;
  	END IF;
  	IF (p_check_fee_assess 		= TRUE OR
  		p_check_cor_category 	= TRUE OR
  		p_check_enr_category 	= TRUE OR
  		p_check_rank_app 	= TRUE OR
  		p_check_completion 	= TRUE OR
  		p_check_rank_set 	= TRUE OR
  		p_check_basis_adm 	= TRUE OR
  		p_check_crs_international = TRUE OR
  		p_check_ass_tracking 	= TRUE OR
  		p_check_adm_code 	= TRUE OR
  		p_check_fund_source 	= TRUE OR
  		p_check_location 	= TRUE OR
  		p_check_att_mode 	= TRUE OR
  		p_check_att_type 	= TRUE OR
  		p_check_unit_set 	= TRUE) THEN
  		OPEN c_acaiv;
  		FETCH c_acaiv INTO 	v_location_cd,
  					v_attendance_mode,
  					v_attendance_type,
  					v_unit_set_cd,
  					v_us_version_number,
  					v_ass_rank,
  					v_intrntnl_accptnce_advice_num,
  					v_ass_tracking_id,
  					v_fee_cat,
  					v_expected_completion_yr,
  					v_expected_completion_perd,
  					v_correspondence_cat,
  					v_enrolment_cat,
  					v_funding_source,
  					v_basis_for_admission_type,
  					v_admission_cd,
  					v_course_rank_set,
  					v_course_rank_schedule;
  		CLOSE c_acaiv;
  		IF (p_check_fee_assess) THEN
  			IF (v_fee_cat IS NOT NULL) THEN
  				p_valid_fee_assess := TRUE;
  				v_valid_fee_assess := TRUE;
  			ELSE
  				IF (p_s_admission_process_type = cst_re_admit) THEN
  					OPEN c_sca;
  					FETCH c_sca INTO v_sca_fee_cat,
  							 v_sca_correspondence_cat,
  							 v_sca_funding_source;
  					CLOSE c_sca;
  					IF (v_sca_fee_cat IS NOT NULL) THEN
  						p_valid_fee_assess := TRUE;
  						v_valid_fee_assess := TRUE;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  		IF (p_check_cor_category) THEN
  			IF (v_correspondence_cat IS NOT NULL) THEN
  				p_valid_cor_category := TRUE;
  				v_valid_cor_category := TRUE;
  			ELSE
  				IF (p_s_admission_process_type = cst_re_admit) THEN
  					OPEN c_sca;
  					FETCH c_sca INTO v_sca_fee_cat,
  							 v_sca_correspondence_cat,
  							 v_sca_funding_source;
  					CLOSE c_sca;
  					IF (v_sca_correspondence_cat IS NOT NULL) THEN
  						p_valid_cor_category := TRUE;
  						v_valid_cor_category := TRUE;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  		IF (p_check_enr_category) THEN
  			IF (v_enrolment_cat IS NOT NULL) THEN
  				p_valid_enr_category := TRUE;
  				v_valid_enr_category := TRUE;
  			ELSE
  				IF (p_s_admission_process_type = cst_re_admit) THEN
  					OPEN c_scae;
  					FETCH c_scae INTO v_scae_enrolment_cat;
  					IF (c_scae%FOUND) THEN
  						CLOSE c_scae;
  						p_valid_enr_category := TRUE;
  						v_valid_enr_category := TRUE;
  					ELSE
  						CLOSE c_scae;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  		IF (p_check_rank_app = TRUE AND
  				v_ass_rank IS NOT NULL) THEN
  			p_valid_rank_app := TRUE;
  			v_valid_rank_app := TRUE;
  		END IF;
  		IF (p_check_completion = TRUE AND
  				v_expected_completion_yr IS NOT NULL AND
  				v_expected_completion_perd IS NOT NULL) THEN
  			p_valid_completion := TRUE;
  			v_valid_completion := TRUE;
  		END IF;
  		IF (p_check_rank_set = TRUE AND
  				v_course_rank_set IS NOT NULL AND
  				v_course_rank_schedule IS NOT NULL) THEN
  			p_valid_rank_set := TRUE;
  			v_valid_rank_set := TRUE;
  		END IF;
  		IF (p_check_basis_adm = TRUE AND
  				v_basis_for_admission_type IS NOT NULL) THEN
  			p_valid_basis_adm := TRUE;
  			v_valid_basis_adm := TRUE;
  		END IF;
  		IF (p_check_crs_international = TRUE AND
  				v_intrntnl_accptnce_advice_num IS NOT NULL) THEN
  			p_valid_crs_international := TRUE;
  			v_valid_crs_international := TRUE;
  		END IF;
  		IF (p_check_ass_tracking = TRUE AND
  				v_ass_tracking_id IS NOT NULL) THEN
  			p_valid_ass_tracking := TRUE;
  			v_valid_ass_tracking := TRUE;
  		END IF;
  		IF (p_check_adm_code = TRUE AND
  				v_admission_cd IS NOT NULL) THEN
  			p_valid_adm_code := TRUE;
  			v_valid_adm_code := TRUE;
  		END IF;
  		IF p_check_fund_source = TRUE THEN
  			IF v_funding_source IS NOT NULL THEN
  				p_valid_fund_source := TRUE;
  				v_valid_fund_source := TRUE;
  			ELSE
  				IF p_s_admission_process_type = cst_re_admit THEN
  					OPEN c_sca;
  					FETCH c_sca INTO v_sca_fee_cat,
  							 v_sca_correspondence_cat,
  							 v_sca_funding_source;
  					CLOSE c_sca;
  					IF v_sca_funding_source IS NOT NULL THEN
  						p_valid_fund_source := TRUE;
  						v_valid_fund_source := TRUE;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  		IF (p_check_location = TRUE AND
  				v_location_cd IS NOT NULL) THEN
  			p_valid_location := TRUE;
  			v_valid_location := TRUE;
  		END IF;
  		IF (p_check_att_mode = TRUE AND
  				v_attendance_mode IS NOT NULL) THEN
  			p_valid_att_mode := TRUE;
  			v_valid_att_mode := TRUE;
  		END IF;
  		IF (p_check_att_type = TRUE AND
  				v_attendance_type IS NOT NULL) THEN
  			p_valid_att_type := TRUE;
  			v_valid_att_type := TRUE;
  		END IF;
  		IF (p_check_unit_set = TRUE AND
  				v_unit_set_cd IS NOT NULL) THEN
  			p_valid_unit_set := TRUE;
  			v_valid_unit_set := TRUE;
  		END IF;
  	END IF;
  	-- Return false if the admission course application instance is incomplete.
  	-- The spec differs from this code, in that you cannot test an OUT NOCOPY parameter
  	-- for
  	-- value, so we set up temporary local variables of the same name (swap the
  	-- first p
  	-- for a v) and gave them the same value (above).

	-- by rrengara on 8-NOV-2002
	-- for bug no 2629077 (P) 2595982 (D) changed v_check_research to p_check_research


  	IF (p_check_adm_test = TRUE AND
  			v_valid_adm_test = FALSE) OR
  			(p_check_fee_assess = TRUE AND
  			v_valid_fee_assess = FALSE) OR
  			(p_check_cor_category = TRUE AND
  			v_valid_cor_category = FALSE) OR
  			(p_check_enr_category = TRUE AND
  			v_valid_enr_category = FALSE) OR
  			(p_check_research = TRUE AND
  			v_valid_research = FALSE) OR
  			(p_check_rank_app = TRUE AND
  			v_valid_rank_app = FALSE) OR
  			(p_check_completion = TRUE AND
  			v_valid_completion = FALSE) OR
  			(p_check_rank_set = TRUE AND
  			v_valid_rank_set = FALSE) OR
  			(p_check_basis_adm = TRUE AND
  			v_valid_basis_adm = FALSE) OR
  			(p_check_crs_international = TRUE AND
  			v_valid_crs_international = FALSE) OR
  			(p_check_ass_tracking = TRUE AND
  			v_valid_ass_tracking = FALSE) OR
  			(p_check_adm_code = TRUE AND
  			v_valid_adm_code = FALSE) OR
  			(p_check_fund_source = TRUE AND
  			v_valid_fund_source = FALSE) OR
  			(p_check_location = TRUE AND
  			v_valid_location = FALSE) OR
  			(p_check_att_mode = TRUE AND
  			v_valid_att_mode = FALSE) OR
  			(p_check_att_type = TRUE AND
  			v_valid_att_type = FALSE) OR
  			(p_check_unit_set = TRUE AND
  			v_valid_unit_set = FALSE) THEN

        --SETS THE MESSAGE FOR INDIVIDUL INVALID OPTIONS,INSTEAD OF A GENERIC MESSAGE.
	IF       v_valid_referee = FALSE AND p_check_referee = TRUE THEN
                 p_message_name := 'IGS_AD_INVALID_REF';
        ELSIF    v_valid_scholarship = FALSE AND p_check_scholarship = TRUE THEN
                 p_message_name := 'IGS_AD_INVALID_SCHOL';
        ELSIF    v_valid_lang_prof = FALSE AND p_check_lang_prof  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_LANGPROF';
  	ELSIF	 v_valid_interview = FALSE AND p_check_interview = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_INTERVIEW';
  	ELSIF	 v_valid_exchange = FALSE AND p_check_exchange = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_EXCHANGE';
  	ELSIF	 v_valid_adm_test = FALSE AND p_check_adm_test  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ADMTST';
 	ELSIF	 v_valid_fee_assess = FALSE AND p_check_fee_assess  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_FEEASS';
  	ELSIF	 v_valid_cor_category = FALSE AND p_check_cor_category  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_CORRCAT';
  	ELSIF    v_valid_enr_category = FALSE AND p_check_enr_category  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ENRCAT';
     	ELSIF	 v_valid_research = FALSE AND p_check_research = TRUE THEN
		 p_message_name := v_error_message_research;
     	ELSIF	 v_valid_rank_app = FALSE AND p_check_rank_app  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_RANKAPP';
  	ELSIF	 v_valid_completion = FALSE AND p_check_completion = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_PERCOMP';
  	ELSIF    v_valid_rank_set = FALSE AND p_check_rank_set  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_PERRANK';
  	ELSIF	 v_valid_basis_adm = FALSE AND p_check_basis_adm  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ADMBAS';
  	ELSIF	 v_valid_crs_international = FALSE AND p_check_crs_international  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_PRGINT';
 	ELSIF	 v_valid_ass_tracking = FALSE AND p_check_ass_tracking  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_TRCK';
  	ELSIF	 v_valid_adm_code = FALSE AND p_check_adm_code  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ADMCD';
  	ELSIF	 v_valid_fund_source = FALSE AND p_check_fund_source  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_FUNDSRC';
  	ELSIF    v_valid_location = FALSE AND p_check_location  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_LOC';
  	ELSIF	 v_valid_att_mode = FALSE AND p_check_att_mode  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ATTNDMODE';
  	ELSIF	 v_valid_att_type = FALSE AND p_check_att_type  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_ATTNDTYPE';
  	ELSIF	 v_valid_unit_set = FALSE AND p_check_unit_set  = TRUE THEN
		 p_message_name := 'IGS_AD_INVALID_UNTSET';
      END IF;
      RETURN FALSE;
      END IF;

  FOR v_apcs_rec IN c_apcs LOOP
	  IF (v_apcs_rec.s_admission_step_type = 'PGM-APPRV') THEN
		  OPEN c_pa;
		  FETCH c_pa INTO v_person_id;
		  IF (c_pa%FOUND) THEN
			  close c_pa;
	    ELSE
        CLOSE c_pa;
        p_message_name:=  'IGS_AD_MND_PRGAPPRV';
        v_return := FALSE;
        EXIT;
		  END IF;

    ELSIF (v_apcs_rec.s_admission_step_type = 'DES-UNITSETS') THEN -- modified for 2382599
		  OPEN c_us;
		  FETCH c_us INTO v_person_id;
		  IF (c_us%FOUND) THEN
			  close c_us;
      ELSE
        CLOSE c_us;
        p_message_name:=   'IGS_AD_MND_UNTSETDL';
        v_return := FALSE;
        EXIT;
  		END IF;

    ELSIF (v_apcs_rec.s_admission_step_type='OTH-INST-APPL') THEN
		  OPEN c_oi;
		  FETCH c_oi INTO v_person_id;
		  IF (c_oi%FOUND) THEN
			  close c_oi;
      ELSE
        CLOSE c_oi;
        p_message_name:=   'IGS_AD_MND_OTUNS_APP';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'EDU-GOALS') THEN
		  OPEN c_eg;
		  FETCH c_eg INTO v_person_id;
		  IF (c_eg%FOUND) THEN
			  close c_eg;
      ELSE
        CLOSE c_eg;
        p_message_name:=   'IGS_AD_MND_EDUGOAL';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'ACAD-INTEREST') THEN
		  OPEN c_ai;
 		  FETCH c_ai INTO v_person_id;
		  IF (c_ai%FOUND) THEN
			  close c_ai;
      ELSE
        CLOSE c_ai;
        p_message_name:=   'IGS_AD_MND_ACADINT';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'APPL-INTENT') THEN
		  OPEN c_in;
		  FETCH c_in INTO v_person_id;
		  IF (c_in%FOUND) THEN
			  close c_in;
      ELSE
        CLOSE c_in;
        p_message_name:=   'IGS_AD_MND_ACINT_DET';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'SPL-INTEREST') THEN
		  OPEN c_si;
		  FETCH c_si INTO v_person_id;
		  IF (c_si%FOUND) THEN
			  close c_si;
      ELSE
        CLOSE c_si;
        p_message_name:=   'IGS_AD_SPINTR_DL';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'SPL-TALENT') THEN
		  OPEN c_st;
		  FETCH c_st INTO v_person_id;
		  IF (c_st%FOUND) THEN
			  close c_st;
      ELSE
        CLOSE c_st;
        p_message_name:=   'IGS_AD_MND_SPLTLNT';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'FEE-DETAIL') THEN
  	  OPEN c_ar;
		  FETCH c_ar INTO v_person_id;
		  IF (c_ar%FOUND) THEN
			  close c_ar;
      ELSE
        CLOSE c_ar;
        p_message_name:=   'IGS_AD_MND_APPFINDTL';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'CREDENTAILS') THEN
  	  OPEN c_ac;
		  FETCH c_ac INTO v_person_id;
		  IF (c_ac%FOUND) THEN
			  close c_ac;
      ELSE
        CLOSE c_ac;
        p_message_name:=   'IGS_AD_MND_CREDEN_DET';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type = 'ACAD-HONORS') THEN
  	  OPEN c_ah;
		  FETCH c_ah INTO v_person_id;
		  IF (c_ah%FOUND) THEN
			  close c_ah;
      ELSE
        CLOSE c_ah;
        p_message_name:=   'IGS_AD_MND_HONORS';
        v_return := FALSE;
        EXIT;
		  END IF;

	  ELSIF (v_apcs_rec.s_admission_step_type IN  ('MISC-DTL','FINAID')) THEN
  	  OPEN c_md;
		  FETCH c_md INTO
  			v_apply_for_finaid,
        v_app_file_location1 ,
		  	v_late_adm_fee_status1,
  			v_enrolment_cat1 ,
	  		v_fee_cat1 ,
		  	v_hecs_payment_option1 ,
  			v_app_source_id1 ,
	  		v_correspondence_cat1,
		  	v_funding_source1 ;
		  IF v_apcs_rec.s_admission_step_type='MISC-DTL' AND
	       (v_app_file_location1 IS NOT NULL OR
				  v_enrolment_cat1 IS NOT NULL OR
				  v_fee_cat1 IS NOT NULL OR
 				  v_hecs_payment_option1 IS NOT NULL OR
				  v_app_source_id1 IS NOT NULL OR
				  v_correspondence_cat1 IS NOT NULL OR
				  v_funding_source1 IS NOT NULL) THEN
			  close c_md;
	    ELSIF v_apcs_rec.s_admission_step_type='FINAID' AND (v_apply_for_finaid = 'Y') THEN
        close c_md;
      ELSE
        CLOSE c_md;
        IF v_apcs_rec.s_admission_step_type='MISC-DTL' THEN
		      p_message_name:=   'IGS_AD_MND_MSCDTL';
        ELSE
		      p_message_name:=   'IGS_AD_MND_FINAID';
        END IF;
        v_return := FALSE;
        EXIT;
	  	END IF;

    -- START Added for 1366894
    -- Ordering of steps INTERVIEW_DTLS and FIN_INTERVIEW_DECS is importent
    ELSIF (v_apcs_rec.s_admission_step_type = 'INTERVIEW_DTLS') THEN
		  OPEN c_id_exist;
		  FETCH c_id_exist INTO v_person_id;
		  IF (c_id_exist%FOUND) THEN
			  CLOSE c_id_exist;
      ELSE
        CLOSE c_id_exist;
        p_message_name:=   'IGS_AD_MND_INTERVIEW_DETAILS';
        v_return := FALSE;
        EXIT;
  		END IF;

    ELSIF (v_apcs_rec.s_admission_step_type = 'FIN_INTERVIEW_DECS') THEN
		  OPEN c_id;
		  FETCH c_id INTO v_person_id;
		  IF (c_id%FOUND) THEN
			  CLOSE c_id;
      ELSE
        CLOSE c_id;
        p_message_name:=   'IGS_AD_MND_INTERVIEW_DECISION';
        v_return := FALSE;
        EXIT;
  		END IF;
    -- END Added for 1366894

    END IF;

	END LOOP;

  IF v_return = FALSE THEN
    RETURN v_return;
  ELSE
    p_message_name := NULL;
    RETURN TRUE;
  END IF;

EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_acaiv%ISOPEN) THEN
  			CLOSE c_acaiv;
  		END IF;
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		IF (c_scae%ISOPEN) THEN
  			CLOSE c_scae;
  		END IF;
  		IF (c_crv%ISOPEN) THEN
  			CLOSE c_crv;
  		END IF;
                IF (c_apcs%ISOPEN) THEN
  			CLOSE c_apcs;
  		END IF;
  		IF (c_ae%ISOPEN) THEN
  			CLOSE c_ae;
  		END IF;
  		IF (c_pa%ISOPEN) THEN
  			CLOSE c_pa;
  		END IF;
  		IF (c_us%ISOPEN) THEN
  			CLOSE c_us;
  		END IF;

  		IF (c_oi%ISOPEN) THEN
  			CLOSE c_oi;
  		END IF;
  		IF (c_eg%ISOPEN) THEN
  			CLOSE c_eg;
  		END IF;
  		IF (c_ai%ISOPEN) THEN
  			CLOSE c_ai;
  		END IF;
  		IF (c_in%ISOPEN) THEN
  			CLOSE c_in;
  		END IF;
  		IF (c_si%ISOPEN) THEN
  			CLOSE c_si;
  		END IF;
  		IF (c_st%ISOPEN) THEN
  			CLOSE c_st;
  		END IF;
  		IF (c_ar%ISOPEN) THEN
  			CLOSE c_ar;
  		END IF;
  		IF (c_ac%ISOPEN) THEN
  			CLOSE c_ac;
  		END IF;
  		IF (c_ah%ISOPEN) THEN
  			CLOSE c_ah;
  		END IF;
  		IF (c_md%ISOPEN) THEN
  			CLOSE c_md;
  		END IF;
		  IF (c_id_exist%FOUND) THEN
			  CLOSE c_id_exist;
      END IF;
		  IF (c_id%FOUND) THEN
			  CLOSE c_id;
      END IF;

  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_comp');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acai_comp;
  --
  -- Validate if the specified admission application IGS_PE_PERSON is complete.
  FUNCTION admp_val_pe_comp(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_athletics IN BOOLEAN,
  p_check_alternate IN BOOLEAN ,
  p_check_address IN BOOLEAN ,
  p_check_disability IN BOOLEAN ,
  p_check_visa IN BOOLEAN ,
  p_check_finance IN BOOLEAN ,
  p_check_notes IN BOOLEAN ,
  p_check_statistics IN BOOLEAN ,
  p_check_alias IN BOOLEAN ,
  p_check_tertiary IN BOOLEAN ,
  p_check_aus_sec_ed IN BOOLEAN ,
  p_check_os_sec_ed IN BOOLEAN ,
  p_check_employment IN BOOLEAN ,
  p_check_membership IN BOOLEAN ,
  p_check_dob IN BOOLEAN ,
  p_check_title IN BOOLEAN ,
  p_check_excurr IN BOOLEAN,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_valid_athletics OUT NOCOPY BOOLEAN ,
  p_valid_alternate OUT NOCOPY BOOLEAN ,
  p_valid_address OUT NOCOPY BOOLEAN ,
  p_valid_disability OUT NOCOPY BOOLEAN ,
  p_valid_visa OUT NOCOPY BOOLEAN ,
  p_valid_finance OUT NOCOPY BOOLEAN ,
  p_valid_notes OUT NOCOPY BOOLEAN ,
  p_valid_statistics OUT NOCOPY BOOLEAN ,
  p_valid_alias OUT NOCOPY BOOLEAN ,
  p_valid_tertiary OUT NOCOPY BOOLEAN ,
  p_valid_aus_sec_ed OUT NOCOPY BOOLEAN ,
  p_valid_os_sec_ed OUT NOCOPY BOOLEAN ,
  p_valid_employment OUT NOCOPY BOOLEAN ,
  p_valid_membership OUT NOCOPY BOOLEAN ,
  p_valid_dob OUT NOCOPY BOOLEAN ,
  p_valid_title OUT NOCOPY BOOLEAN,
  p_valid_excurr OUT NOCOPY BOOLEAN)
  RETURN BOOLEAN AS

  BEGIN	-- admp_val_pe_comp
  	-- Validate if the specified admission application IGS_PE_PERSON is complete
  DECLARE
  	v_valid_athletics	BOOLEAN		:= FALSE;
  	v_valid_alternate	BOOLEAN		:= FALSE;
  	v_valid_address		BOOLEAN		:= FALSE;
  	v_valid_disability	BOOLEAN		:= FALSE;
  	v_valid_visa		BOOLEAN		:= FALSE;
  	v_valid_finance		BOOLEAN		:= FALSE;
  	v_valid_notes		BOOLEAN		:= FALSE;
  	v_valid_statistics	BOOLEAN		:= FALSE;
  	v_valid_alias		BOOLEAN		:= FALSE;
  	v_valid_tertiary	BOOLEAN		:= FALSE;
  	v_valid_aus_sec_ed	BOOLEAN		:= FALSE;
  	v_valid_os_sec_ed	BOOLEAN		:= FALSE;
  	v_valid_employment	BOOLEAN		:= FALSE;
  	v_valid_membership	BOOLEAN		:= FALSE;
  	v_valid_dob		BOOLEAN		:= FALSE;
  	v_valid_title		BOOLEAN		:= FALSE;
  	v_birth_dt		IGS_PE_PERSON.birth_dt%TYPE;
  	v_title			IGS_PE_PERSON.title%TYPE;
	v_valid_excurr         BOOLEAN         := FALSE;
  	CURSOR c_pe IS
  		SELECT	pe.birth_date birth_dt,
  			pe.title
  		FROM	IGS_PE_PERSON_BASE_V	pe
  		WHERE	pe.person_id = p_person_id;
  		  v_list_element VARCHAR2(30);
  BEGIN
  	--set default message number
  	p_message_name := NULL;
  	-- Initialise the output valid parameters
  	IF (p_check_athletics) THEN
  		p_valid_athletics := FALSE;
  	ELSE
  		p_valid_athletics := TRUE;
  	END IF;
  	IF (p_check_alternate) THEN
  		p_valid_alternate := FALSE;
  	ELSE
  		p_valid_alternate := TRUE;
  	END IF;
  	IF (p_check_address) THEN
  		p_valid_address := FALSE;
  	ELSE
  		p_valid_address := TRUE;
  	END IF;
  	IF (p_check_disability) THEN
  		p_valid_disability := FALSE;
  	ELSE
  		p_valid_disability := TRUE;
  	END IF;
  	IF (p_check_visa) THEN
  		p_valid_visa := FALSE;
  	ELSE
  		p_valid_visa := TRUE;
  	END IF;
  	IF (p_check_finance) THEN
  		p_valid_finance := FALSE;
  	ELSE
  		p_valid_finance := TRUE;
  	END IF;
  	IF (p_check_notes) THEN
  		p_valid_notes := FALSE;
  	ELSE
  		p_valid_notes := TRUE;
  	END IF;
  	IF (p_check_statistics) THEN
  		p_valid_statistics := FALSE;
  	ELSE
  		p_valid_statistics := TRUE;
  	END IF;
  	IF (p_check_alias) THEN
  		p_valid_alias := FALSE;
  	ELSE
  		p_valid_alias := TRUE;
  	END IF;
  	IF (p_check_tertiary) THEN
  		p_valid_tertiary := FALSE;
  	ELSE
  		p_valid_tertiary := TRUE;
  	END IF;
  	IF (p_check_aus_sec_ed) THEN
  		p_valid_aus_sec_ed := FALSE;
  	ELSE
  		p_valid_aus_sec_ed := TRUE;
  	END IF;
  	IF (p_check_os_sec_ed) THEN
  		p_valid_os_sec_ed := FALSE;
  	ELSE
  		p_valid_os_sec_ed := TRUE;
  	END IF;
  	IF (p_check_employment) THEN
  		p_valid_employment := FALSE;
  	ELSE
  		p_valid_employment := TRUE;
  	END IF;
  	IF (p_check_membership) THEN
  		p_valid_membership := FALSE;
  	ELSE
  		p_valid_membership := TRUE;
  	END IF;
  	IF (p_check_dob) THEN
  		p_valid_dob := FALSE;
  	ELSE
  		p_valid_dob := TRUE;
  	END IF;
  	IF (p_check_title) THEN
  		p_valid_title := FALSE;
  	ELSE
  		p_valid_title := TRUE;
  	END IF;
        IF (p_check_excurr) THEN
  		p_valid_excurr := FALSE;
  	ELSE
  		p_valid_excurr := TRUE;
  	END IF;

  	-- Validate IGS_PE_PERSON level data
  	IF (    p_check_athletics       = TRUE OR
                p_check_alternate       = TRUE OR
  		p_check_address 	= TRUE OR
  		p_check_disability 	= TRUE OR
  		p_check_visa 		= TRUE OR
  		p_check_finance 	= TRUE OR
  		p_check_notes 		= TRUE OR
  		p_check_statistics 	= TRUE OR
  		p_check_alias 		= TRUE OR
  		p_check_tertiary	= TRUE OR
  		p_check_aus_sec_ed 	= TRUE OR
  		p_check_os_sec_ed 	= TRUE OR
  		p_check_employment 	= TRUE OR
  		p_check_membership 	= TRUE OR
		p_check_excurr          = TRUE) THEN
  		IGS_AD_GEN_007.ADMP_GET_PE_EXISTS(
  				p_person_id,
  				p_effective_dt,
  				p_check_athletics,
  				p_check_alternate,
  				p_check_address,
  				p_check_disability,
  				p_check_visa,
  				p_check_finance,
  				p_check_notes,
  				p_check_statistics,
  				p_check_alias,
  				p_check_tertiary,
  				p_check_aus_sec_ed,
  				p_check_os_sec_ed,
  				p_check_employment,
  				p_check_membership,
				p_check_excurr,
  				v_valid_athletics,
  				v_valid_alternate,
  				v_valid_address,
  				v_valid_disability,
  				v_valid_visa,
  				v_valid_finance,
  				v_valid_notes,
  				v_valid_statistics,
  				v_valid_alias,
  				v_valid_tertiary,
  				v_valid_aus_sec_ed,
  				v_valid_os_sec_ed,
  				v_valid_employment,
  				v_valid_membership,
				v_valid_excurr);
  		IF (v_valid_athletics = TRUE) THEN
  			p_valid_athletics := TRUE;
  		END IF;
  		IF (v_valid_alternate = TRUE) THEN
  			p_valid_alternate := TRUE;
  		END IF;
  		IF (v_valid_address = TRUE) THEN
  			p_valid_address := TRUE;
  		END IF;
  		IF (v_valid_disability = TRUE) THEN
  			p_valid_disability := TRUE;
  		END IF;
  		IF (v_valid_visa = TRUE) THEN
  			p_valid_visa := TRUE;
  		END IF;
  		IF (v_valid_finance = TRUE) THEN
  			p_valid_finance := TRUE;
  		END IF;
  		IF (v_valid_notes = TRUE) THEN
  			p_valid_notes := TRUE;
  		END IF;
  		IF (v_valid_statistics = TRUE) THEN
  			p_valid_statistics := TRUE;
  		END IF;
  		IF (v_valid_alias = TRUE) THEN
  			p_valid_alias := TRUE;
  		END IF;
  		IF (v_valid_tertiary = TRUE) THEN
  			p_valid_tertiary := TRUE;
  		END IF;
  		IF (v_valid_aus_sec_ed = TRUE) THEN
  			p_valid_aus_sec_ed := TRUE;
  		END IF;
  		IF (v_valid_os_sec_ed = TRUE) THEN
  			p_valid_os_sec_ed := TRUE;
  		END IF;
  		IF (v_valid_employment = TRUE) THEN
  			p_valid_employment := TRUE;
  		END IF;
  		IF (v_valid_membership = TRUE) THEN
  			p_valid_membership := TRUE;
  		END IF;
  		IF (v_valid_excurr = TRUE) THEN
  			p_valid_excurr := TRUE;
  		END IF;
  	END IF;
  	IF (p_check_dob = TRUE OR
  			p_check_title = TRUE) THEN
  		OPEN c_pe;
  		FETCH c_pe INTO	v_birth_dt,
  				v_title;
  		CLOSE c_pe;
  		IF (p_check_dob = TRUE AND
  				v_birth_dt IS NOT NULL) THEN
  			p_valid_dob := TRUE;
  			v_valid_dob := TRUE;
  		END IF;
  		IF (p_check_title = TRUE AND
  				v_title IS NOT NULL) THEN
  			p_valid_title := TRUE;
  			v_valid_title := TRUE;
  		END IF;


  	END IF;
  	--Return false if the admission course application instance is incomplete
  	IF (p_check_athletics   = TRUE  AND
  	    v_valid_athletics 	= FALSE) OR
  	   (p_check_alternate   = TRUE  AND
  	    v_valid_alternate 	= FALSE) OR
  	   (p_check_address 	= TRUE	AND
  	    v_valid_address 	= FALSE) OR
  	   (p_check_disability 	= TRUE	AND
  	    v_valid_disability 	= FALSE) OR
  	   (p_check_visa 	= TRUE 	AND
  	    v_valid_visa 	= FALSE) OR
  	   (p_check_finance 	= TRUE 	AND
  	    v_valid_finance 	= FALSE) OR
  	   (p_check_notes 	= TRUE 	AND
  	    v_valid_notes 	= FALSE) OR
  	   (p_check_statistics 	= TRUE 	AND
  	    v_valid_statistics 	= FALSE) OR
  	   (p_check_alias 	= TRUE 	AND
  	    v_valid_alias 	= FALSE) OR
  	   (p_check_tertiary 	= TRUE	AND
  	    v_valid_tertiary 	= FALSE) OR
  	   (p_check_aus_sec_ed 	= TRUE	AND
  	    v_valid_aus_sec_ed 	= FALSE) OR
  	   (p_check_os_sec_ed 	= TRUE	AND
  	    v_valid_os_sec_ed 	= FALSE) OR
  	   (p_check_employment 	= TRUE	AND
  	    v_valid_employment 	= FALSE) OR
  	   (p_check_membership 	= TRUE	AND
  	    v_valid_membership 	= FALSE) OR
  	   (p_check_dob 	= TRUE	AND
  	    v_valid_dob 	= FALSE) OR
  	   (p_check_title 	= TRUE 	AND
  	    v_valid_title 	= FALSE) OR
  	   (p_check_excurr 	= TRUE 	AND
  	    v_valid_excurr 	= FALSE) THEN

                --Set Messages for Individual Mandatory Details
  		IF v_valid_dob 		= FALSE AND p_check_dob = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_DOB';

  		ELSIF v_valid_title 		= FALSE AND p_check_title = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_TITLE';

  		ELSIF v_valid_athletics 	= FALSE AND p_check_athletics = TRUE THEN
  		  v_list_element := 'IGS_AD_MND_ATHLETICS';

  		ELSIF v_valid_alternate 	= FALSE AND p_check_alternate = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_ALTDET';

  		ELSIF v_valid_address 	= FALSE AND p_check_address = TRUE THEN
  	  	  v_list_element := 'IGS_AD_INVALID_ADDR';

  		ELSIF v_valid_disability 	= FALSE AND p_check_disability = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_DISDTL';

  		ELSIF v_valid_visa 		= FALSE AND p_check_visa = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_VISA';

  		ELSIF v_valid_finance 	= FALSE AND p_check_finance = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_FINDET';

  		ELSIF v_valid_notes 		= FALSE  AND p_check_notes = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_NOTES';

  		ELSIF  v_valid_statistics 	= FALSE AND p_check_statistics = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_PERSTAT';

  		ELSIF  v_valid_alias 		= FALSE AND p_check_alias = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_ALIASDET';

  		ELSIF v_valid_tertiary 	= FALSE AND p_check_tertiary = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_TEREDU';

  		ELSIF v_valid_aus_sec_ed 	= FALSE AND p_check_aus_sec_ed = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_GOVSECEDU';

  		ELSIF v_valid_os_sec_ed 	= FALSE AND p_check_os_sec_ed = TRUE THEN
  		  v_list_element :=  'IGS_AD_INVALID_SECEDU';

  		ELSIF v_valid_employment = FALSE AND p_check_employment = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_EMPDTL';

  		ELSIF v_valid_membership 	= FALSE AND p_check_membership = TRUE THEN
  		  v_list_element := 'IGS_AD_INVALID_MEM';

		ELSIF v_valid_excurr = FALSE AND p_check_excurr = TRUE THEN
		  v_list_element := 'IGS_AD_MND_EXCURR';

                END IF;

                p_message_name := v_list_element;
  	        RETURN FALSE;
  	END IF;
          p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_pe%ISOPEN) THEN
  			CLOSE c_pe;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_pe_comp');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
  END admp_val_pe_comp;
  --
  -- Validate the deferment of  IGS_AD_PS_APLINSTUNT records.
  FUNCTION admp_val_acaiu_defer(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acaiu_defer
  	-- Validate the deferment of IGS_AD_PS_APLINSTUNT records
  DECLARE
  	cst_offer	CONSTANT
  					IGS_AD_UNIT_OU_STAT.s_adm_outcome_status%TYPE := 'OFFER';
  	v_message_name			VARCHAR2(30);
  	CURSOR c_acaiu_auos IS
  		SELECT	acaiu.unit_cd,
  			acaiu.uv_version_number,
  			acaiu.cal_type,
  			acaiu.ci_sequence_number,
  			acaiu.location_cd,
  			acaiu.unit_class,
  			acaiu.unit_mode
  		FROM	IGS_AD_PS_APLINSTUNT	acaiu,
  			IGS_AD_UNIT_OU_STAT		auos
  		WHERE	acaiu.person_id			= p_person_id AND
  			acaiu.admission_appl_number	= p_admission_appl_number AND
  			acaiu.nominated_course_cd	= p_nominated_course_cd AND
  			acaiu.acai_sequence_number	= p_acai_sequence_number AND
  			auos.adm_unit_outcome_status	= acaiu.adm_unit_outcome_status AND
  			auos.s_adm_outcome_status	= cst_offer;
  BEGIN
  	-- Retrieve the admission course application instance units
  	FOR v_acaiu_auos_rec IN c_acaiu_auos LOOP
  		-- Validate the unit version
  		IF (IGS_AD_VAL_ACAIU.admp_val_acaiu_uv(
  						v_acaiu_auos_rec.unit_cd,
  						v_acaiu_auos_rec.uv_version_number,
  						p_s_admission_process_type,
  						'Y', -- offered indicator
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate the unit offering option
  		IF (IGS_AD_VAL_ACAIU.admp_val_acaiu_opt(
  						v_acaiu_auos_rec.unit_cd,
  						v_acaiu_auos_rec.uv_version_number,
  						v_acaiu_auos_rec.cal_type,
  						v_acaiu_auos_rec.ci_sequence_number,
  						v_acaiu_auos_rec.location_cd,
  						v_acaiu_auos_rec.unit_class,
  						v_acaiu_auos_rec.unit_mode,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_acad_cal_type,
  						p_acad_ci_sequence_number,
  						'Y', -- offered indicator
  						v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_acaiu_auos%ISOPEN) THEN
  			CLOSE c_acaiu_auos;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acaiu_defer');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_acaiu_defer;
  --
  -- Validate the IGS_AD_PS_APPL_INST.preference_number.
  FUNCTION admp_val_acai_pref(
  p_preference_number IN NUMBER ,
  p_pref_allowed IN VARCHAR2 ,
  p_pref_limit IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_pref
  	-- Validate the IGS_AD_PS_APPL_INST.preference_number.
  	-- Validations are -
  	-- - Preference number must be specified for a course preference application.
  	-- - If specified, the preference number must not exceed the preference limit.
  DECLARE
  	cst_course	CONSTANT VARCHAR2(10) := 'COURSE';
  BEGIN
  	p_message_name := NULL;
  	IF p_pref_allowed = 'Y' AND
  			upper(p_s_admission_process_type) = cst_course THEN
  		--Preference number must be specified for a course preference application.
  		IF p_preference_number IS NULL THEN
  			p_message_name := 'IGS_AD_PREFNUM_SPECIFIED';
  			RETURN FALSE;
  		ELSIF p_preference_number > p_pref_limit THEN
  			--Preference number must be less than the preference limit.
  			p_message_name := 'IGS_AD_PREFNUM_NOT_EXCEED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_pref');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
    END admp_val_acai_pref;
  --
  -- Validate adm course application instance expected completion details.
  FUNCTION admp_val_expctd_comp(
  p_expected_completion_yr IN NUMBER ,
  p_expected_completion_perd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_expctd_comp
  	-- Description: Validate the admission course application
  	-- instance expected completion details.
  DECLARE
  BEGIN
  	p_message_name := NULL;
  	IF p_expected_completion_yr IS NOT NULL AND
  			p_expected_completion_perd IS NULL THEN
  		p_message_name := 'IGS_AD_EXPCOMP_PER_SPECIFIED';
  		RETURN FALSE;
  	END IF;
  	IF p_expected_completion_perd IS NOT NULL AND
  			p_expected_completion_yr IS NULL THEN
  		p_message_name := 'IGS_AD_EXPCOMP_YEAR_SPECIFIED';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
				 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_expctd_comp');
				 IGS_GE_MSG_STACK.ADD;
				 APP_EXCEPTION.RAISE_EXCEPTION;
 END admp_val_expctd_comp;
  --
  -- Validate the admission course application instance funding source.
  FUNCTION admp_val_acai_fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- admp_val_acai_fs
  	-- This module validates the admission course application instance
  	-- funding source.
  DECLARE
  	v_fsr_found		BOOLEAN := FALSE;
  	v_fs_found		BOOLEAN := FALSE;
  	v_message_name		VARCHAR2(30);
  	CURSOR c_fsr IS
  		SELECT	fsr.funding_source
  		FROM	IGS_FI_FND_SRC_RSTN	fsr
  		WHERE	fsr.course_cd		= p_course_cd AND
  			fsr.version_number	= p_version_number AND
  			fsr.restricted_ind	= 'Y';
  BEGIN
  	-- Set initial value
  	p_message_name := NULL;
  	v_fsr_found := FALSE;
  	v_fs_found := FALSE;
  	IF p_funding_source IS NOT NULL THEN
  		-- Validate that the funding source is not closed.
  		IF IGS_AD_VAL_SAFT.crsp_val_fs_closed(
  					p_funding_source,
  					v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  		-- Validate that funding source is valid for the course version.
  		FOR v_fsr_rec IN c_fsr LOOP
  			v_fsr_found := TRUE;
  			IF v_fsr_rec.funding_source = p_funding_source THEN
  				v_fs_found := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF v_fsr_found = FALSE THEN
  			-- No records found in IGS_FI_FND_SRC_RSTN
  			RETURN TRUE;
  		ELSIF v_fs_found = TRUE THEN
  			-- Records found in IGS_FI_FND_SRC_RSTN
  			-- found source is valid for the course version
  			RETURN TRUE;
  		ELSE
  			-- Records found in IGS_FI_FND_SRC_RSTN
  			-- found source is not valid for the course version
  			p_message_name := 'IGS_AD_FUNDSRC_NOTVALID_APPL';
  			RETURN FALSE;
  		END IF;
  	END IF;	--IF p_funding_source IS NOT NULL
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_fsr%ISOPEN THEN
  			CLOSE c_fsr;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXP');
			 FND_MESSAGE.SET_TOKEN('NAME', 'IGS_AD_VAL_ACAI.admp_val_acai_fs');
			 IGS_GE_MSG_STACK.ADD;
			 APP_EXCEPTION.RAISE_EXCEPTION;
        END admp_val_acai_fs; -- admp_val_acai_fs

END igs_ad_val_acai;

/
