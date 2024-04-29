--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_007" AS
/* $Header: IGSAD07B.pls 120.3 2006/02/01 23:46:58 pfotedar ship $ */
FUNCTION Admp_Get_Match_Prsn(
  p_surname IN VARCHAR2 ,
  p_birth_dt IN VARCHAR2 ,
  p_sex IN VARCHAR2 ,
  p_initial IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN NUMBER IS
BEGIN	-- admp_get_match_prsn
	-- This module attempts to find a person based on surname, birth date,
	-- sex and first initial.
DECLARE
	v_match		BOOLEAN;
	v_person_id	IGS_PE_PERSON.person_id%TYPE;
	v_dd_mm_yyyy	NUMBER(8);
	CURSOR c_person IS
		SELECT 	person_id,
			first_name given_names
		FROM 	igs_pe_person_base_v
		WHERE 	last_name     = p_surname AND
			birth_date    = TO_DATE(p_birth_dt, 'DDMMYYYY') AND
			gender        = p_sex;
BEGIN
	-- Set the default message number
	p_message_name := null;
	-- Check the parameter birthday in correct format.
	BEGIN
		v_dd_mm_yyyy := IGS_GE_NUMBER.TO_NUM(p_birth_dt);
		IF v_dd_mm_yyyy <= 0 THEN
			p_message_name := 'IGS_AD_BIRTHDT_INCORRECT_DATA';
			RETURN 0;
		END IF;
		v_dd_mm_yyyy := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_birth_dt,1,2));
		IF (v_dd_mm_yyyy > 31) THEN
			p_message_name := 'IGS_AD_BIRTHDT_INCORRECT_DATA';
			RETURN 0;
		END IF;
		v_dd_mm_yyyy := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_birth_dt,3,2));
		IF (v_dd_mm_yyyy > 12) THEN
			p_message_name := 'IGS_AD_BIRTHDT_INCORRECT_DATA';
			RETURN 0;
		END IF;
		v_dd_mm_yyyy := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_birth_dt,5,4));
		IF (v_dd_mm_yyyy <= 1900) THEN
			p_message_name := 'IGS_AD_BIRTHDT_INCORRECT_DATA';
			RETURN 0;
		END IF;
	EXCEPTION
		WHEN VALUE_ERROR THEN
			p_message_name := 'IGS_AD_BIRTHDT_INCORRECT_DATA';
			RETURN 0;
	END;
	v_match := FALSE;
	FOR v_person_rec IN c_person LOOP
		IF (SUBSTR(v_person_rec.given_names,1,1) = p_initial) THEN
			v_person_id := v_person_rec.person_id;
			v_match := TRUE;
			EXIT;
		END IF;
	END LOOP;
	IF (v_match = TRUE) THEN
		RETURN v_person_id;
	ELSE
		RETURN 0;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_007.admp_get_match_prsn');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_match_prsn;

FUNCTION Admp_Get_Ovrd_Comm(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR ,
  p_sequence_number IN NUMBER )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_ovrd_comm
DECLARE
	v_ovrd_comm_period	VARCHAR2(40);
	CURSOR	c_aa_acai_ci IS
		SELECT	ci1.cal_type ||
			TO_CHAR(ci1.start_dt, 'DDMMYYYY') ||
			ci2.cal_type ||
			TO_CHAR(ci2.start_dt, 'DDMMYYYY')
		FROM	IGS_AD_APPL			aa,
			IGS_AD_PS_APPL_INST		acai,
			IGS_CA_INST			ci1,
			IGS_CA_INST			ci2
		WHERE	aa.person_id			= p_person_id AND
			aa.admission_appl_number		= p_admission_appl_number AND
			acai.person_id			= aa.person_id AND
			acai.admission_appl_number	= aa.admission_appl_number AND
			acai.nominated_course_cd		= p_nominated_course_cd AND
			acai.sequence_number 		= p_sequence_number AND
			ci1.cal_type			= aa.acad_cal_type AND
			ci1.sequence_number		= (
								SELECT 	sup_ci_sequence_number
								FROM 	IGS_CA_INST_REL
								WHERE	sup_cal_type		= aa.acad_cal_type AND
									sub_cal_type		= acai.adm_cal_type AND
									sub_ci_sequence_number	= acai.adm_ci_sequence_number) AND
			ci2.cal_type  			= acai.adm_cal_type AND
			ci2.sequence_number		= acai.adm_ci_sequence_number;
BEGIN
	IF p_sequence_number IS NULL THEN
		RETURN NULL;
	END IF;
	OPEN c_aa_acai_ci;
	FETCH c_aa_acai_ci INTO v_ovrd_comm_period;
	CLOSE c_aa_acai_ci;
  	RETURN v_ovrd_comm_period;
EXCEPTION
	WHEN OTHERS THEN
		IF c_aa_acai_ci%ISOPEN THEN
			CLOSE c_aa_acai_ci;
		END IF;
		RAISE;
END;
END admp_get_ovrd_comm;

PROCEDURE Admp_Get_Pe_Exists(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_athletics IN BOOLEAN ,
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
  p_check_excurr IN BOOLEAN ,
  p_athletics_exists OUT NOCOPY BOOLEAN ,
  p_alternate_exists OUT NOCOPY BOOLEAN ,
  p_address_exists OUT NOCOPY BOOLEAN ,
  p_disability_exists OUT NOCOPY BOOLEAN ,
  p_visa_exists OUT NOCOPY BOOLEAN ,
  p_finance_exists OUT NOCOPY BOOLEAN ,
  p_notes_exists OUT NOCOPY BOOLEAN ,
  p_statistics_exists OUT NOCOPY BOOLEAN ,
  p_alias_exists OUT NOCOPY BOOLEAN ,
  p_tertiary_exists OUT NOCOPY BOOLEAN ,
  p_aus_sec_ed_exists OUT NOCOPY BOOLEAN ,
  p_os_sec_ed_exists OUT NOCOPY BOOLEAN ,
  p_employment_exists OUT NOCOPY BOOLEAN ,
  p_membership_exists OUT NOCOPY BOOLEAN,
  p_excurr_exists OUT NOCOPY BOOLEAN)
IS
BEGIN	-- admp_get_pe_exists
	-- Return output parameters indicating whether or not data exists on person
	-- detail
	-- tables for the specified person ID.
DECLARE
	v_person_id		IGS_PE_PERSON.person_id%TYPE;

        CURSOR c_at IS
                SELECT  person_id
                FROM    igs_pe_athletic_dtl
                WHERE   person_id       = p_person_id;

	CURSOR c_api IS
		SELECT	pe_person_id
		FROM	IGS_PE_ALT_PERS_ID
		WHERE	pe_person_id	= p_person_id	;

	CURSOR c_person IS
		SELECT	person_id
		FROM	IGS_PE_PERSON_ADDR	pa,
			IGS_CO_ADDR_TYPE	adt
		WHERE	pa.person_id	= p_person_id	AND
			adt.addr_type	= pa.addr_type	AND
			pa.correspondence_ind	= 'Y';
	CURSOR c_pd IS
		SELECT	person_id
		FROM	IGS_PE_PERS_DISABLTY
		WHERE	person_id	= p_person_id;
	CURSOR c_iv IS
		SELECT	person_id
		FROM	IGS_PE_VISA
		WHERE	person_id	= p_person_id;
	CURSOR c_pn IS
		SELECT	person_id
		FROM	IGS_PE_PERS_NOTE
		WHERE	person_id	= p_person_id;
	CURSOR c_ps IS
		SELECT coun.person_id
                FROM IGS_PE_EIT coun,
                     HZ_CITIZENSHIP cz,
		     HZ_PERSON_LANGUAGE lang,
		     IGS_PE_EIT state,
		     IGS_PE_VOTE_INFO_ALL voter,
                     IGS_PE_INCOME_TAX_ALL itax
                WHERE coun.INFORMATION_TYPE = 'PE_STAT_RES_COUNTRY'
                AND coun.person_id = p_person_id
		AND cz.PARTY_ID = coun.person_id
                AND cz.STATUS = 'A'
                AND lang.PARTY_ID = coun.person_id
                AND lang.STATUS = 'A'
                AND state.INFORMATION_TYPE = 'PE_STAT_RES_STATE'
                AND state.person_id = coun.person_id
                AND voter.person_id = coun.person_id
                AND itax.person_id = coun.person_id;

	CURSOR c_pa IS
		SELECT	person_id
		FROM	IGS_PE_PERSON_ALIAS
		WHERE	person_id	= p_person_id	;
	CURSOR c_te IS
		SELECT	person_id
		FROM	IGS_AD_TER_EDU
		WHERE	person_id	= p_person_id;
	CURSOR c_ase IS
		SELECT	person_id
		FROM	IGS_AD_AUS_SEC_EDU
		WHERE	person_id	= p_person_id;
	CURSOR c_ose IS
		SELECT	person_id
		FROM	IGS_AD_OS_SEC_EDU
		WHERE	person_id	= p_person_id;
	CURSOR c_ed IS
		SELECT	person_id
		FROM	IGS_AD_EMP_DTL
		WHERE	person_id 	= p_person_id;

	CURSOR c_ex IS
		SELECT PI.PARTY_ID
		FROM HZ_PERSON_INTEREST PI, IGS_AD_HZ_EXTRACURR_ACT HEA
		WHERE PI.PERSON_INTEREST_ID = HEA.PERSON_INTEREST_ID
			AND PI.PARTY_ID = p_person_id;


BEGIN
	-- Initialise output parameters
	p_athletics_exists	:= FALSE;
	p_alternate_exists	:= FALSE;
	p_address_exists	:= FALSE;
	p_disability_exists	:= FALSE;
	p_visa_exists		:= FALSE;
	p_finance_exists	:= FALSE;
	p_notes_exists		:= FALSE;
	p_statistics_exists	:= FALSE;
	p_alias_exists		:= FALSE;
	p_tertiary_exists	:= FALSE;
	p_aus_sec_ed_exists	:= FALSE;
	p_os_sec_ed_exists	:= FALSE;
	p_employment_exists	:= FALSE;
	p_membership_exists	:= FALSE;
	p_excurr_exists         := FALSE;
	IF p_check_athletics THEN
		-- Check for the existence of an Alternate person ID record.
		OPEN c_at;
		FETCH c_at INTO v_person_id;
		IF (c_at%FOUND) THEN
			p_athletics_exists := TRUE;
		END IF;
		CLOSE c_at;
	END IF;
	IF p_check_alternate THEN
		-- Check for the existence of an Alternate person ID record.
		OPEN c_api;
		FETCH c_api INTO v_person_id;
		IF (c_api%FOUND) THEN
			p_alternate_exists := TRUE;
		END IF;
		CLOSE c_api;
	END IF;
	IF p_check_address THEN
		-- Check for the existence of an Address record(correspondence).
		OPEN c_person;
		FETCH c_person INTO v_person_id;
		IF (c_person%FOUND) THEN
			p_address_exists := TRUE;
		END IF;
		CLOSE c_person;
	END IF;
	IF p_check_disability THEN
		-- Check for the existence of a person Disability record.
		OPEN c_pd;
		FETCH c_pd INTO v_person_id;
		IF (c_pd%FOUND) THEN
			p_disability_exists := TRUE;
		END IF;
		CLOSE c_pd;
	END IF;
	IF p_check_visa THEN
		-- Check for the existence of an International Visa record.
		OPEN c_iv;
		FETCH c_iv INTO v_person_id;
		IF (c_iv%FOUND) THEN
			p_visa_exists := TRUE;
		END IF;
		CLOSE c_iv;
	END IF;

	IF p_check_notes THEN
		-- Check for the existence of a person Notes record.
		OPEN c_pn;
		FETCH c_pn INTO v_person_id;
		IF (c_pn%FOUND) THEN
			p_notes_exists := TRUE;
		END IF;
		CLOSE c_pn;
	END IF;
	IF p_check_statistics THEN
		-- Check for the existence of an person Statistics record.
		OPEN c_ps;
		FETCH c_ps INTO v_person_id;
		IF (c_ps%FOUND) THEN
			p_statistics_exists := TRUE;
		END IF;
		CLOSE c_ps;
	END IF;
	IF p_check_alias THEN
		-- Check for the existence of an person Alias record.
		OPEN c_pa;
		FETCH c_pa INTO v_person_id;
		IF (c_pa%FOUND) THEN
			p_alias_exists := TRUE;
		END IF;
		CLOSE c_pa;
	END IF;
	IF p_check_tertiary THEN
		-- Check for the existence of an Tertiary Education record.
		OPEN c_te;
		FETCH c_te INTO v_person_id;
		IF (c_te%FOUND) THEN
			p_tertiary_exists := TRUE;
		END IF;
		CLOSE c_te;
	END IF;
	IF p_check_aus_sec_ed THEN
		-- Check for the existence of an Australian Secondary Education record.
		OPEN c_ase;
		FETCH c_ase INTO v_person_id;
		IF (c_ase%FOUND) THEN
			p_aus_sec_ed_exists := TRUE;
		END IF;
		CLOSE c_ase;
	END IF;
	IF p_check_os_sec_ed THEN
		-- Check for the existence of an Overseas Secondary Education record.
		OPEN c_ose;
		FETCH c_ose INTO v_person_id;
		IF (c_ose%FOUND) THEN
			p_os_sec_ed_exists := TRUE;
		END IF;
		CLOSE c_ose;
	END IF;
	IF p_check_employment THEN
		-- Check for the existence of a person Finance record.
		OPEN c_ed;
		FETCH c_ed INTO v_person_id;
		IF (c_ed%FOUND) THEN
			p_employment_exists := TRUE;
		END IF;
		CLOSE c_ed;
	END IF;
        IF p_check_excurr THEN
		-- Check for the existence of a person Activities record.
		OPEN c_ex;
		FETCH c_ex INTO v_person_id;
		IF (c_ex%FOUND) THEN
			p_excurr_exists := TRUE;
		END IF;
		CLOSE c_ex;
	END IF;

END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_007.admp_get_pe_exists');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_pe_exists;

FUNCTION Admp_Get_Resp_Dt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_admission_process_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_offer_dt IN DATE )
RETURN DATE IS
  -- admp_get_resp_dt
  -- Calculate the offer response date. If the date cannot be derived return
  -- NULL, otherwise return the derived date.
  v_offer_resp_offset    IGS_AD_PRCS_CAT.offer_response_offset%TYPE;
  v_appl_offer_resp_dt_alias  IGS_AD_CAL_CONF.adm_appl_offer_resp_dt_alias%TYPE;
        v_offer_resp_dt_alias_val  IGS_CA_DA_INST_V.alias_val%TYPE;
  v_offer_resp_dt      DATE;
  v_apc_found      BOOLEAN;
  v_dai_sequence_number		IGS_AD_PECRS_OFOP_DT.dai_sequence_number%TYPE ;
  v_apcood_found			BOOLEAN := FALSE;
  v_curr_component_ctr		NUMBER := 0;
  v_high_component_ctr		NUMBER := 0;

  CURSOR c_apc IS
    SELECT  offer_response_offset
    FROM  IGS_AD_PRCS_CAT
    WHERE    admission_cat        = p_admission_cat  AND
      s_admission_process_type  = p_admission_process_type;

  CURSOR c_sacc IS
    SELECT  adm_appl_offer_resp_dt_alias ,
      adm_appl_due_dt_alias,
      adm_appl_final_dt_alias
    FROM  IGS_AD_CAL_CONF
    WHERE  s_control_num = 1;

  CURSOR c_apcood(cp_appl_offer_resp_dt_alias
               IGS_AD_CAL_CONF.adm_appl_offer_resp_dt_alias%TYPE) IS
    SELECT  apcood.s_admission_process_type,
      apcood.course_cd,
      apcood.version_number,
      apcood.acad_cal_type,
      apcood.location_cd,
      apcood.attendance_mode,
      apcood.attendance_type,
      apcood.dai_sequence_number
    FROM  IGS_AD_PECRS_OFOP_DT  apcood
    WHERE  apcood.adm_cal_type    = p_adm_cal_type    AND
      apcood.adm_ci_sequence_number   = p_adm_ci_sequence_number  AND
      apcood.admission_cat     = p_admission_cat    AND
      apcood.dt_alias     = cp_appl_offer_resp_dt_alias;

  CURSOR c_daiv IS
    SELECT IGS_CA_GEN_001.calp_set_alias_value(absolute_val, IGS_CA_GEN_002.cals_clc_dt_from_dai(ci_sequence_number, CAL_TYPE, DT_ALIAS, sequence_number) ) alias_val
    FROM   IGS_CA_DA_INST  daiv,
       IGS_AD_PERD_AD_CAT  apac
    WHERE  daiv.dt_alias      = v_appl_offer_resp_dt_alias      AND
      apac.adm_cal_type    = p_adm_cal_type    AND
      apac.adm_ci_sequence_number  = p_adm_ci_sequence_number  AND
      apac.admission_cat    = p_admission_cat    AND
      apac.adm_cal_type    = daiv.cal_type      AND
      apac.adm_ci_sequence_number  = daiv.ci_sequence_number  AND
      NOT EXISTS(
        SELECT 'x'
        FROM  IGS_AD_PECRS_OFOP_DT  apcood
        WHERE  apcood.adm_cal_type    = apac.adm_cal_type    AND
          apcood.adm_ci_sequence_number  = apac.adm_ci_sequence_number  AND
          apcood.dt_alias      = daiv.dt_alias      AND
          apcood.dai_sequence_number  = daiv.sequence_number)
    ORDER BY 1 desc;

  CURSOR c_daiv2 IS
    SELECT IGS_CA_GEN_001.calp_set_alias_value(absolute_val, IGS_CA_GEN_002.cals_clc_dt_from_dai(ci_sequence_number, CAL_TYPE, DT_ALIAS, sequence_number) ) alias_val
    FROM    IGS_CA_DA_INST  daiv
    WHERE  daiv.cal_type      = p_adm_cal_type    AND
      daiv.ci_sequence_number    = p_adm_ci_sequence_number  AND
      daiv.dt_alias      = v_appl_offer_resp_dt_alias      AND
      daiv.sequence_number    = v_dai_sequence_number;

        l_sacc c_sacc%ROWTYPE;
-- Offer Response Date to be defaulted can be derived from
--1. Admission period Override -> Date alias value for the
--   Admission period and Admission Category at Process type / Program Offering level
--2. Calendar setup and Date alias -> Date alias value for the Admission period
--3. APC -> Offset to offer date (offer date is defaulted to system date) for the APC

--1. Check (1). If available, also check to see if greater than system date. If so use (1). Else go to step 2.
--2. Check (3). If available, also check to see if greater than system date. If so use (2). Else go to step 3.
--3. Check (2). If available, also check to see if greater than system date. If so use (3). Else go to step 4.
--4. Default in as null.
BEGIN
 --Find whether the offer response date alias set up in admission calendars set up.
 -- Get offer response date alias
  OPEN c_sacc;
  FETCH c_sacc INTO l_sacc;
  v_appl_offer_resp_dt_alias := l_sacc.adm_appl_offer_resp_dt_alias;
  IF (c_sacc%NOTFOUND  OR
      v_appl_offer_resp_dt_alias IS NULL) THEN
    v_offer_resp_dt_alias_val := NULL;
  ELSE
    IF p_admission_process_type IS NULL AND
      p_course_cd		IS NULL AND
      p_version_number	        IS NULL AND
      p_acad_cal_type		IS NULL AND
      p_location_cd		IS NULL AND
      p_attendance_mode	        IS NULL AND
      p_attendance_type         IS NULL THEN
       RETURN NULL;
    END IF;
   --Find whether the offer response date alias is overridden in Admission overrides form.
   FOR v_apcood_rec IN c_apcood(v_appl_offer_resp_dt_alias) LOOP
     v_apcood_found := TRUE;
     --Check that the record firstly is valid for the parameters
     IF ((v_apcood_rec.s_admission_process_type IS NULL  OR
      v_apcood_rec.s_admission_process_type = p_admission_process_type)  AND
      (v_apcood_rec.course_cd IS NULL  OR
      (v_apcood_rec.course_cd   = p_course_cd    AND
      v_apcood_rec.version_number   = p_version_number  AND
      v_apcood_rec.acad_cal_type  = p_acad_cal_type))      AND
      (v_apcood_rec.location_cd   IS NULL  OR
      v_apcood_rec.location_cd  = p_location_cd)       AND
      (v_apcood_rec.attendance_mode  IS NULL  OR
      v_apcood_rec.attendance_mode  = p_attendance_mode)      AND
      (v_apcood_rec.attendance_type  IS NULL  OR
      v_apcood_rec.attendance_type  = p_attendance_type))  THEN
    --Match on the components and save the IGS_CA_DA_INST_V key for the
    --Record that matches with the highest number of components
    IF (v_apcood_rec.s_admission_process_type IS NOT NULL) THEN
      IF (v_apcood_rec.s_admission_process_type = p_admission_process_type) THEN
        v_curr_component_ctr := v_curr_component_ctr + 1;
      END IF;
    END IF;
      IF (v_apcood_rec.course_cd IS NOT NULL) THEN
        IF (v_apcood_rec.course_cd = p_course_cd  AND
        v_apcood_rec.version_number  = p_version_number  AND
         v_apcood_rec.acad_cal_type  = p_acad_cal_type) THEN
          v_curr_component_ctr := v_curr_component_ctr + 1;
        END IF;
      END IF;
      IF (v_apcood_rec.location_cd IS NOT NULL) THEN
        IF (v_apcood_rec.location_cd = p_location_cd) THEN
          v_curr_component_ctr := v_curr_component_ctr + 1;
        END IF;
      END IF;
      IF (v_apcood_rec.attendance_mode IS NOT NULL) THEN
        IF (v_apcood_rec.attendance_mode = p_attendance_mode) THEN
          v_curr_component_ctr := v_curr_component_ctr + 1;
        END IF;
      END IF;
      IF (v_apcood_rec.attendance_type IS NOT NULL) THEN
        IF (v_apcood_rec.attendance_type = p_attendance_type) THEN
          v_curr_component_ctr := v_curr_component_ctr + 1;
        END IF;
      END IF;
      --If this record has the most number of matches then we want to use
      --its dai_sequence_number
      IF (v_curr_component_ctr > v_high_component_ctr) THEN
          v_high_component_ctr := v_curr_component_ctr;
        v_dai_sequence_number := v_apcood_rec.dai_sequence_number;
      END IF;
      v_curr_component_ctr := 0;
    END IF;
   END LOOP;
   IF v_apcood_found AND v_dai_sequence_number IS NOT NULL THEN
     OPEN c_daiv2;
     FETCH c_daiv2 INTO v_offer_resp_dt_alias_val;
     IF (c_daiv2%NOTFOUND) THEN
       v_offer_resp_dt_alias_val := NULL;
     END IF;
     CLOSE c_daiv2;
   ELSE
     v_offer_resp_dt_alias_val := NULL;
   END IF;
  END IF;
  CLOSE c_sacc;

 IF v_offer_resp_dt_alias_val IS NOT NULL AND v_offer_resp_dt_alias_val > TRUNC(SYSDATE) THEN
   RETURN v_offer_resp_dt_alias_val;
 ELSE
   v_offer_resp_dt_alias_val := NULL;
 END IF;

  OPEN c_apc;
  FETCH c_apc INTO v_offer_resp_offset;
  IF (c_apc%NOTFOUND    OR
      v_offer_resp_offset IS NULL) THEN
    v_apc_found := FALSE;
  ELSE
    v_apc_found := TRUE;
  END IF;
  CLOSE c_apc;

  IF v_offer_resp_dt_alias_val IS NULL  AND v_apc_found THEN
    v_offer_resp_dt_alias_val := p_offer_dt + v_offer_resp_offset;
    IF v_offer_resp_dt_alias_val > TRUNC(SYSDATE) THEN
      RETURN v_offer_resp_dt_alias_val;
    ELSE
      v_offer_resp_dt_alias_val := NULL;
    END IF;
  END IF;
  IF v_appl_offer_resp_dt_alias IS NOT NULL AND v_offer_resp_dt_alias_val IS NULL THEN
    OPEN c_daiv;
    FETCH c_daiv INTO v_offer_resp_dt_alias_val;
    CLOSE c_daiv;
    IF v_offer_resp_dt_alias_val > TRUNC(SYSDATE) THEN
      RETURN v_offer_resp_dt_alias_val;
    ELSE
      v_offer_resp_dt_alias_val := NULL;
    END IF;
  END IF;

  RETURN v_offer_resp_dt_alias_val;
EXCEPTION
    WHEN OTHERS THEN
     Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
     Fnd_Message.Set_Token('NAME','IGS_AD_GEN_007.admp_get_resp_dt');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
END admp_get_resp_dt;


FUNCTION Admp_Get_Saas(
  p_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	--admp_get_saas
	--Get the s_adm_appl_status for a specified adm_appl_status
DECLARE
	v_adm_appl_status	IGS_AD_APPL_STAT.adm_appl_status%TYPE;
	CURSOR c_aas IS
		SELECT	s_adm_appl_status
		FROM	IGS_AD_APPL_STAT
		WHERE	adm_appl_status	= p_adm_appl_status;
BEGIN
	--initialise v_adm_appl_status
	v_adm_appl_status := NULL;
	OPEN c_aas;
	FETCH c_aas INTO v_adm_appl_status;
	CLOSE c_aas;
	RETURN v_adm_appl_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_007.admp_get_saas');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_saas;

FUNCTION Admp_Get_Sacos(
  p_adm_cndtnl_offer_status IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	--admp_get_sacos
	--Get the s_adm_cndtnl_offer_status for a specified adm_cndtnl_offer_status
DECLARE
	v_adm_offer_status	IGS_AD_CNDNL_OFRSTAT.s_adm_cndtnl_offer_status%TYPE;
	CURSOR c_acos IS
		SELECT	s_adm_cndtnl_offer_status
		FROM	IGS_AD_CNDNL_OFRSTAT
		WHERE	adm_cndtnl_offer_status = p_adm_cndtnl_offer_status;
BEGIN
	--initialise v_adm_offer_status
	v_adm_offer_status := NULL;
	OPEN c_acos ;
	FETCH c_acos INTO v_adm_offer_status;
	CLOSE c_acos ;
	RETURN v_adm_offer_status;
END;

END admp_get_sacos;

FUNCTION Admp_Get_Sads(
  p_adm_doc_status IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	--admp_get_sads
	--Get the s_adm_doc_status for a specified adm_doc_status
DECLARE
	v_s_adm_doc_status	IGS_AD_DOC_STAT.s_adm_doc_status%TYPE;
	CURSOR c_ads IS
		SELECT	s_adm_doc_status
		FROM	IGS_AD_DOC_STAT
		WHERE	adm_doc_status = p_adm_doc_status;
BEGIN
	--initialise v_s_adm_doc_status
	v_s_adm_doc_status := NULL;
	OPEN c_ads ;
	FETCH c_ads INTO v_s_adm_doc_status;
	CLOSE c_ads ;
	RETURN v_s_adm_doc_status;
END;
END admp_get_sads;

FUNCTION Admp_Get_Saeqs(
  p_adm_entry_qual_status IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	--admp_get_saeqs
	--Get the s_adm_entry_qual_status for a specified adm_entry_qual_status.
DECLARE
	v_qual_status	IGS_AD_ENT_QF_STAT.s_adm_entry_qual_status%TYPE;
	CURSOR c_aeqs IS
		SELECT	s_adm_entry_qual_status
		FROM	IGS_AD_ENT_QF_STAT
		WHERE	adm_entry_qual_status = p_adm_entry_qual_status;
BEGIN
	--initialise v_s_adm_doc_status
	v_qual_status := NULL;
	OPEN c_aeqs ;
	FETCH c_aeqs INTO v_qual_status;
	CLOSE c_aeqs ;
	RETURN v_qual_status;
END;
END admp_get_saeqs;

END igs_ad_gen_007;

/
