--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_013" AS
/* $Header: IGSAD13B.pls 120.1 2005/09/30 04:44:09 appldev ship $ */

Function Adms_Get_Acai_Coo(
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
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_deferred_appl IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
	v_return_type	VARCHAR2(1);
	v_late_ind	VARCHAR2(1);
	cst_error		CONSTANT	VARCHAR2(1) := 'E';
BEGIN
	IF IGS_AD_VAL_ACAI.admp_val_acai_coo (
			p_course_cd,
			p_version_number,
			p_location_cd,
			p_attendance_mode,
			p_attendance_type,
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
			v_late_ind) = TRUE THEN
		-- Admission Application Course Offering Option is valid
		Return 'Y';
	ELSE
		IF v_return_type = cst_error THEN
			-- Admission Application Course Offering Option is not valid
			Return 'N';
		ELSE
			-- Admission Application IGS_PS_COURSE Offering Option is valid
			Return 'Y';
		END IF;
	END IF;
END adms_get_acai_coo;

Function Adms_Get_Acai_Course(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
	v_return_type		VARCHAR2(1);
	v_crv_version_number	IGS_PS_VER.version_number%TYPE;
	cst_error		CONSTANT	VARCHAR2(1) := 'E';
BEGIN
	IF IGS_AD_VAL_ACAI.admp_val_acai_course (
			p_course_cd,
			p_version_number,
			p_admission_cat,
			p_s_admission_process_type,
			p_acad_cal_type,
			p_acad_ci_sequence_number,
			p_adm_cal_type,
			p_adm_ci_sequence_number,
			p_appl_dt,
			p_late_appl_allowed,
			p_offer_ind,
			v_crv_version_number,
			v_message_name,
			v_return_type) = TRUE THEN
		-- Admission Application Course is valid
		Return 'Y';
	ELSE
		-- Admission Application Course is not valid
		IF v_return_type = cst_error THEN
			-- Admission Application Course is not valid
			Return 'N';
		ELSE
			-- Admission Application Course is valid
			Return 'Y';
		END IF;
	END IF;
END adms_get_acai_course;

Function Adms_Get_Acai_Us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
	v_return_type		VARCHAR2(1);
	cst_error		CONSTANT	VARCHAR2(1) := 'E';
BEGIN
	IF IGS_AD_VAL_ACAI.admp_val_acai_us (
			p_unit_set_cd,
			p_us_version_number,
			p_course_cd,
			p_crv_version_number,
			p_acad_cal_type,
			p_location_cd,
			p_attendance_mode,
			p_attendance_type,
			p_admission_cat,
			p_offer_ind,
			p_unit_set_appl,
			v_message_name,
			v_return_type) = TRUE THEN
		-- Admission Application Course Unit Set is valid
		Return 'Y';
	ELSE
		IF v_return_type = cst_error THEN
			-- Admission Application Course Unit Set is not valid
			Return 'N';
		ELSE
			-- Admission Application Course Unit Set is valid
			Return 'Y';
		END IF;
	END IF;
END adms_get_acai_us;

Function Adms_Get_Ads_Item(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 )
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
BEGIN
	IF IGS_AD_VAL_ACAI_STATUS.admp_val_ads_item (
			p_adm_doc_status,
			p_s_admission_process_type,
			v_message_name) = TRUE THEN
		-- Admission Application Documenation Status is valid
		Return 'Y';
	ELSE
		-- Admission Application Documentation Status is not valid
		Return 'N';
	END IF;
END adms_get_ads_item;

Function Adms_Get_Aeqs_Item(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 )
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
BEGIN
	IF IGS_AD_VAL_ACAI_STATUS.admp_val_aeqs_item (
			p_adm_entry_qual_status,
			p_s_admission_process_type,
			v_message_name) = TRUE THEN
		-- Admission Application Entry Qualification Status is valid
		Return 'Y';
	ELSE
		-- Admission Application Entry Qualification Status is not valid
		Return 'N';
	END IF;
END adms_get_aeqs_item;

Function Adms_Get_Coo_Admperd(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 )
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
BEGIN
	IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_admperd(
		p_adm_cal_type,
		p_adm_ci_sequence_number,
		p_admission_cat,
		p_s_admission_process_type,
		p_course_cd,
		p_version_number,
		p_acad_cal_type,
		p_location_cd,
		p_attendance_mode,
		p_attendance_type,
		v_message_name) = TRUE THEN
		-- Course Offering Option is valid in the admission period
		Return 'Y';
	ELSE
		-- Course Offering Option is not valid in the admission period
		Return 'N';
	END IF;
END adms_get_coo_admperd;

-- Place the following declaration in the package specification adm_gen_013.
Function Adms_Get_Coo_Adm_Cat(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 )
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
BEGIN
	IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat (
		p_course_cd,
		p_version_number,
		p_cal_type,
		p_location_cd,
		p_attendance_mode,
		p_attendance_type,
		p_admission_cat,
		v_message_name) = TRUE THEN
		-- Course Offering Option is valid for the admission category
		Return 'Y';
	ELSE
		-- IGS_PS_COURSE Offering Option is not valid for the admission category
		Return 'N';
	END IF;
END adms_get_coo_adm_cat;

Function Adms_Get_Coo_Crv(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
	v_message_name VARCHAR2(30);
BEGIN
	IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv (
		p_course_cd,
		p_version_number,
		p_s_admission_process_type,
		p_offer_ind,
		v_message_name) = TRUE THEN
		-- Course Offering Option Course Version is valid
		Return 'Y';
	ELSE
		-- Course Offering Option Course Version is not valid
		Return 'N';
	END IF;
END adms_get_coo_crv;

FUNCTION Check_apc_Step(p_admission_cat VARCHAR2,
                  p_s_admission_process_type VARCHAR2,
                  p_s_adm_step_group_type VARCHAR2,
                  p_s_admission_step_type VARCHAR2) RETURN BOOLEAN IS
----------------------------------------------------------------
--Created by  : Navin Sinha
--Date created: 13-Jun-03
--
--Purpose: BUG NO : 1366894 - Interview Build.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
----------------------------------------------------------------

  CURSOR c_apcs IS
  SELECT  apcs.s_admission_step_type
  FROM    igs_ad_prcs_cat_step apcs
  WHERE   apcs.admission_cat = p_admission_cat AND
          apcs.s_admission_process_type = p_s_admission_process_type AND
          apcs.s_admission_step_type = p_s_admission_step_type AND
          apcs.step_group_type = p_s_adm_step_group_type;

  l_c_apcs  c_apcs%ROWTYPE;
BEGIN
  OPEN  c_apcs;
  FETCH c_apcs INTO l_c_apcs;
  IF c_apcs%NOTFOUND THEN
        CLOSE  c_apcs;
        RETURN FALSE;
  ELSE
        CLOSE  c_apcs;
        RETURN TRUE;
  END IF;
END Check_apc_Step;

FUNCTION get_sys_code_status (p_name IN VARCHAR2,
				p_class IN VARCHAR2)
RETURN VARCHAR2 IS
----------------------------------------------------------------
--Created by  : Navin Sinha
--Date created: 13-Jun-03
--
--Purpose: BUG NO : 1366894 - Interview Build.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
----------------------------------------------------------------

   -- Cursor to get the fee type
   CURSOR cur_sys_stat IS
   SELECT system_status
   FROM   igs_ad_code_classes
   WHERE  name = p_name
   AND    class = p_class
   AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   l_sys_stat igs_ad_code_classes.system_status%TYPE;
BEGIN
   --initialise l_sys_stat
   l_sys_stat := NULL;
   OPEN cur_sys_stat;
   FETCH cur_sys_stat INTO l_sys_stat;
   CLOSE cur_sys_stat ;
   RETURN l_sys_stat;
END get_sys_code_status;  -- igs_ad_gen_013.get_sys_code_status

END IGS_AD_GEN_013;

/
