--------------------------------------------------------
--  DDL for Package Body IGS_AU_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AU_GEN_004" AS
/* $Header: IGSAU04B.pls 120.0 2005/06/01 23:26:49 appldev noship $ */
/* Change History
   Who       When          What
   sarakshi  30-Apr-2004   Bug#3568858, Added columns ovrd_wkld_val_flag, workload_val_code related logic
   sarakshi  03-Nov-2003   Enh#3116171, modified audp_get_uvh_col to add the column billing_credit_points related logic
   sarakshi  02-Sep-2003   Enh#3052452,removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind
   shtatiko  25-OCT-2002    Modified c_uvh cursor in audp_get_uvh_col procedure as per Bug# 2636716.
   jbegum    19 April 02    As part of bug fix of bug #2322290 and bug#2250784
                            Removed the following 4 columns
                            BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS
			    from Function Audp_Get_Uvh_Col.*/
Function Audp_Get_Trh_Col(
  p_unit_cd  IGS_PS_TCH_RESP_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_TCH_RESP_HIST_ALL.version_number%TYPE ,
  p_org_unit_cd  IGS_PS_TCH_RESP_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_TCH_RESP_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_TCH_RESP_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER AS

BEGIN	-- audp_get_trh_col
	-- get the oldest column value (after a given date) of the
	-- percentage column for a specified unit_cd, version_number,
	-- org_unit_cd, ou_start_dt and hist_start_dt.
DECLARE
	v_column_value		IGS_PS_TCH_RESP_HIST.percentage%TYPE := NULL;
	CURSOR	c_trh IS
		SELECT	trh.percentage
		FROM	IGS_PS_TCH_RESP_HIST	trh
		WHERE	trh.unit_cd		= p_unit_cd AND
			trh.version_number	= p_version_number AND
			trh.org_unit_cd		= p_org_unit_cd AND
			trh.ou_start_dt		= p_ou_start_dt AND
			trh.hist_start_dt 		>=p_hist_date AND
			trh.percentage		IS NOT NULL
		ORDER BY trh.hist_start_dt;
BEGIN
	OPEN c_trh;
	FETCH c_trh INTO v_column_value;
	CLOSE c_trh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_trh%ISOPEN) THEN
			CLOSE c_trh;
		END IF;
		RAISE;
END;
END audp_get_trh_col;

Function Audp_Get_Troh_Col(
  p_unit_cd  IGS_PS_TCH_RSOV_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_TCH_RSOV_HIST_ALL.version_number%TYPE ,
  p_cal_type  IGS_PS_TCH_RSOV_HIST_ALL.cal_type%TYPE ,
  p_ci_sequence_number  IGS_PS_TCH_RSOV_HIST_ALL.ci_sequence_number%TYPE ,
  p_location_cd  IGS_PS_TCH_RSOV_HIST_ALL.location_cd%TYPE ,
  p_unit_class  IGS_PS_TCH_RSOV_HIST_ALL.unit_class%TYPE ,
  p_org_unit_cd  IGS_PS_TCH_RSOV_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_TCH_RSOV_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_TCH_RSOV_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER AS

BEGIN	-- audp_get_troh_col
	-- get the oldest column value (after a given date) for the percentage column
	-- and a given unit_cd, version_number, cal_type, ci_sequence-number,
	-- location_cd, unit_class, org_unit_cd and ou_start_dt.
DECLARE
	v_column_value		IGS_PS_TCH_RSOV_HIST.percentage%TYPE := NULL;
	CURSOR	c_troh IS
		SELECT	troh.percentage
		FROM	IGS_PS_TCH_RSOV_HIST	troh
		WHERE	troh.unit_cd		= p_unit_cd AND
			troh.version_number	= p_version_number AND
			troh.cal_type		= p_cal_type AND
			troh.ci_sequence_number	= p_ci_sequence_number AND
			troh.location_cd		= p_location_cd AND
			troh.unit_class		= p_unit_class AND
			troh.org_unit_cd		= p_org_unit_cd AND
			troh.ou_start_dt		= p_ou_start_dt AND
			troh.hist_start_dt		>= p_hist_date AND
			troh.percentage		IS NOT NULL
		ORDER BY troh.hist_start_dt;
BEGIN
	OPEN c_troh;
	FETCH c_troh INTO v_column_value;
	CLOSE c_troh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_troh%ISOPEN) THEN
			CLOSE c_troh;
		END IF;
		RAISE;
END;
END audp_get_troh_col;

Function Audp_Get_Udh_Col(
  p_unit_cd  IGS_PS_UNT_DSCP_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNT_DSCP_HIST_ALL.version_number%TYPE ,
  p_discipline_group_cd  IGS_PS_UNT_DSCP_HIST_ALL.discipline_group_cd%TYPE ,
  p_hist_date  IGS_PS_UNT_DSCP_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER AS

BEGIN	-- audp_get_udh_col
	-- Get the oldest column value (after a given date) for the percentage
	-- column, unit_cd, version_number and discipline_group_cd.
DECLARE
	v_column_value		igs_ps_unt_dscp_hist.percentage%TYPE := NULL;
	CURSOR	c_udh IS
		SELECT	udh.percentage
		FROM	igs_ps_unt_dscp_hist	udh
		WHERE	udh.unit_cd		= p_unit_cd AND
			udh.version_number	= p_version_number AND
			udh.discipline_group_cd	= p_discipline_group_cd AND
			udh.hist_start_dt		>= p_hist_date AND
			udh.percentage		IS NOT NULL
		ORDER BY udh.percentage;
BEGIN
	OPEN c_udh;
	FETCH c_udh INTO v_column_value;
	CLOSE c_udh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_udh%ISOPEN) THEN
			CLOSE c_udh;
		END IF;
		RAISE;
END;
END audp_get_udh_col;

Function Audp_Get_Uiclh_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_unit_int_course_level_cd  IGS_PS_UNT_INLV_HIST_ALL.unit_int_course_level_cd%TYPE ,
  p_hist_end_dt  IGS_PS_UNT_INLV_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_uiclh_col
	-- get the oldest column value (after a given date) for a given
	-- unit_int_course_level_cd
DECLARE
	cst_description		VARCHAR2(15) := 'DESCRIPTION';
	cst_weftsu_factor		VARCHAR2(15) := 'WEFTSU_FACTOR';
	cst_closed_ind		VARCHAR2(10) := 'CLOSED_IND';
	CURSOR	c_uiclh IS
		SELECT	DECODE (p_column_name,
				cst_description,		uiclh.description,
				cst_weftsu_factor,		TO_CHAR(uiclh.weftsu_factor),
				cst_closed_ind,		uiclh.closed_ind)
		FROM	IGS_PS_UNT_INLV_HIST	uiclh
		WHERE	uiclh.unit_int_course_level_cd	= p_unit_int_course_level_cd AND
			uiclh.hist_start_dt			>= p_hist_end_dt AND
			DECODE (p_column_name,
				cst_description,		uiclh.description,
				cst_weftsu_factor,		TO_CHAR(uiclh.weftsu_factor),
				cst_closed_ind,		uiclh.closed_ind) IS NOT NULL
		ORDER BY
			uiclh.hist_start_dt;
		v_column_value		VARCHAR2(2000) := NULL;
BEGIN
	OPEN c_uiclh;
	FETCH c_uiclh INTO v_column_value;
	CLOSE c_uiclh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_uiclh%ISOPEN) THEN
			CLOSE c_uiclh;
		END IF;
		RAISE;
END;
END audp_get_uiclh_col;

Function Audp_Get_Urch_Col(
  p_unit_cd  IGS_PS_UNIT_REF_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNIT_REF_HIST_ALL.version_number%TYPE ,
  p_reference_cd_type  IGS_PS_UNIT_REF_HIST_ALL.reference_cd_type%TYPE ,
  p_reference_cd  IGS_PS_UNIT_REF_HIST_ALL.reference_cd%TYPE ,
  p_hist_date  IGS_PS_UNIT_REF_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_urch_col
	-- Get the oldest column value(after a given date) for a given unit_cd,
	-- version_number, reference_type and reference_cd
DECLARE
	v_column_value		igs_ps_unit_ref_hist.description%TYPE := NULL;
	CURSOR	c_urch IS
		SELECT	urch.description
		FROM	IGS_PS_UNIT_REF_HIST	urch
		WHERE	urch.unit_cd		= p_unit_cd AND
			urch.version_number	= p_version_number AND
			urch.reference_cd_type	= p_reference_cd_type AND
			urch.reference_cd		= p_reference_cd AND
			urch.hist_start_dt		>= p_hist_date AND
			urch.description		IS NOT NULL
		ORDER BY urch.hist_start_dt;
BEGIN
	OPEN c_urch;
	FETCH c_urch INTO v_column_value;
	CLOSE c_urch;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_urch%ISOPEN) THEN
			CLOSE c_urch;
		END IF;
		RAISE;
END;
END audp_get_urch_col;

Function Audp_Get_Ush_Col(
  p_unit_set_cd  IGS_EN_UNIT_SET_HIST_ALL.unit_set_cd%TYPE ,
  p_version_number  IGS_EN_UNIT_SET_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_end_dt  IGS_EN_UNIT_SET_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_ush_col
	-- get the oldest column value (after a given date) for a
	-- specified column and version_number
DECLARE
	v_column_value		VARCHAR2(2000) := NULL;
	CURSOR	c_ush IS
		SELECT	DECODE (p_column_name,
				'UNIT_SET_STATUS',		ush.UNIT_SET_STATUS,
				'UNIT_SET_CAT',			ush.UNIT_SET_CAT,
				'START_DT',			IGS_GE_DATE.igscharDT(ush.start_dt),
				'REVIEW_DT',			IGS_GE_DATE.igscharDT(ush.review_dt),
				'EXPIRY_DT',			IGS_GE_DATE.igscharDT(ush.expiry_dt),
				'END_DT',				IGS_GE_DATE.igscharDT(ush.end_dt),
				'TITLE',				ush.TITLE,
				'SHORT_TITLE',			ush.short_title,
				'ABBREVIATION',			ush.abbreviation,
				'RESPONSIBLE_ORG_UNIT_CD',	ush.responsible_org_unit_cd,
				'RESPONSIBLE_OU_START_DT',	IGS_GE_DATE.igscharDT(ush.responsible_ou_start_dt),
				'OU_DESCRIPTION',			ush.ou_description,
				'ADMINISTRATIVE_IND',		ush.administrative_ind,
				'AUTHORISATION_RQRD_IND',	ush.authorisation_rqrd_ind)
		FROM	IGS_EN_UNIT_SET_HIST		ush
		WHERE	ush.unit_set_cd		= p_unit_set_cd AND
			ush.version_number	= p_version_number AND
			ush.hist_start_dt		>= p_hist_end_dt AND
			DECODE (p_column_name,
				'UNIT_SET_STATUS',		ush.UNIT_SET_STATUS,
				'UNIT_SET_CAT',			ush.UNIT_SET_CAT,
				'START_DT',			IGS_GE_DATE.igscharDT(ush.start_dt),
				'REVIEW_DT',			IGS_GE_DATE.igscharDT(ush.review_dt),
				'EXPIRY_DT',			IGS_GE_DATE.igscharDT(ush.expiry_dt),
				'END_DT',				IGS_GE_DATE.igscharDT(ush.end_dt),
				'TITLE',				ush.TITLE,
				'SHORT_TITLE',			ush.short_title,
				'ABBREVIATION',			ush.abbreviation,
				'RESPONSIBLE_ORG_UNIT_CD',	ush.responsible_org_unit_cd,
				'RESPONSIBLE_OU_START_DT',	IGS_GE_DATE.igscharDT(ush.responsible_ou_start_dt),
				'OU_DESCRIPTION',			ush.ou_description,
				'ADMINISTRATIVE_IND',		ush.administrative_ind,
				'AUTHORISATION_RQRD_IND',	ush.authorisation_rqrd_ind) IS NOT NULL
		ORDER BY ush.hist_start_dt;
BEGIN
	OPEN c_ush;
	FETCH c_ush INTO v_column_value;
	CLOSE c_ush;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_ush%ISOPEN) THEN
			CLOSE c_ush;
		END IF;
		RAISE;
END;
END audp_get_ush_col;

-- Added auditable_ind, audit_permission_ind and max_auditors_allowed
-- parameters in SELECT statement as per Bug# 2636716 by shtatiko.

Function Audp_Get_Uvh_Col(
  p_unit_cd  IGS_PS_UNIT_VER_HIST_ALL.unit_cd%TYPE ,
  p_version_number  IGS_PS_UNIT_VER_HIST_ALL.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_UNIT_VER_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_uvh_col
	-- get the oldest column value (after a given date) for a
	-- specified column, unit_cd and version_number.
DECLARE
	cst_start_dt			VARCHAR2(30) := 'START_DT';
	cst_review_dt			VARCHAR2(30) := 'REVIEW_DT';
	cst_expiry_dt			VARCHAR2(30) := 'EXPIRY_DT';
	cst_end_dt			VARCHAR2(30) := 'END_DT';
	cst_unit_status			VARCHAR2(30) := 'UNIT_STATUS';
	cst_title				VARCHAR2(30) := 'TITLE';
	cst_short_title			VARCHAR2(30) := 'SHORT_TITLE';
	cst_title_override_ind		VARCHAR2(30) := 'TITLE_OVERRIDE_IND';
	cst_abbreviation			VARCHAR2(30) := 'ABBREVIATION';
	cst_unit_level			VARCHAR2(30) := 'UNIT_LEVEL';
	cst_ul_description			VARCHAR2(30) := 'UL_DESCRIPTION';
	cst_credit_point_descriptor		VARCHAR2(30) := 'CREDIT_POINT_DESCRIPTOR';
	cst_enrolled_credit_points		VARCHAR2(30) := 'ENROLLED_CREDIT_POINTS';
	cst_points_override_ind		VARCHAR2(30) := 'POINTS_OVERRIDE_IND';
	cst_supp_exam_permitted_ind	VARCHAR2(30) := 'SUPP_EXAM_PERMITTED_IND';
	cst_coord_person_id		VARCHAR2(30) := 'COORD_PERSON_ID';
	cst_owner_org_unit_cd		VARCHAR2(30) := 'OWNER_ORG_UNIT_CD';
	cst_owner_ou_start_dt		VARCHAR2(30) := 'OWNER_OU_START_DT';
	cst_ou_description			VARCHAR2(30) := 'OU_DESCRIPTION';
	cst_award_course_only_ind		VARCHAR2(30) := 'AWARD_COURSE_ONLY_IND';
	cst_research_unit_ind		VARCHAR2(30) := 'RESEARCH_UNIT_IND';
	cst_industrial_ind			VARCHAR2(30) := 'INDUSTRIAL_IND';
	cst_practical_ind			VARCHAR2(30) := 'PRACTICAL_IND';
	cst_repeatable_ind			VARCHAR2(30) := 'REPEATABLE_IND';
	cst_assessable_ind		VARCHAR2(30) := 'ASSESSABLE_IND';
	cst_achievable_credit_points	VARCHAR2(30) := 'ACHIEVABLE_CREDIT_POINTS';
	cst_points_increment		VARCHAR2(30) := 'POINTS_INCREMENT';
	cst_points_min			VARCHAR2(30) := 'POINTS_MIN';
	cst_points_max			VARCHAR2(30) := 'POINTS_MAX';
	cst_unit_int_course_level_cd	VARCHAR2(30) := 'UNIT_INT_COURSE_LEVEL_CD';
	cst_uicl_description		VARCHAR2(30) := 'UICL_DESCRIPTION';
	v_column_value			VARCHAR2(2000) := NULL;
        -- Added by rbezawad as per PSP001-US on 24-May-2001
        cst_advance_maximum                    VARCHAR2(30) := 'ADVANCE_MAXIMUM';
        cst_approval_date                      VARCHAR2(30) := 'APPROVAL_DATE';
        cst_cal_type_enrol_load_cal            VARCHAR2(30) := 'CAL_TYPE_ENROL_LOAD_CAL';
        cst_cal_type_offer_load_cal            VARCHAR2(30) := 'CAL_TYPE_OFFER_LOAD_CAL';
        cst_clock_hours                        VARCHAR2(30) := 'CLOCK_HOURS';
        cst_contact_hrs_lab                    VARCHAR2(30) := 'CONTACT_HRS_LAB';
        cst_contact_hrs_lecture                VARCHAR2(30) := 'CONTACT_HRS_LECTURE';
        cst_contact_hrs_other                  VARCHAR2(30) := 'CONTACT_HRS_OTHER';
        cst_continuing_education_units         VARCHAR2(30) := 'CONTINUING_EDUCATION_UNITS';
        cst_curriculum_id                      VARCHAR2(30) := 'CURRICULUM_ID';
        cst_enrollment_expected                VARCHAR2(30) := 'ENROLLMENT_EXPECTED';
        cst_enrollment_maximum                 VARCHAR2(30) := 'ENROLLMENT_MAXIMUM';
        cst_enrollment_minimum                 VARCHAR2(30) := 'ENROLLMENT_MINIMUM';
        cst_exclude_from_max_cp_limit          VARCHAR2(30) := 'EXCLUDE_FROM_MAX_CP_LIMIT';
        cst_federal_financial_aid              VARCHAR2(30) := 'FEDERAL_FINANCIAL_AID';
        c_institutional_financial_aid          VARCHAR2(30) := 'INSTITUTIONAL_FINANCIAL_AID';
        cst_lab_credit_points                  VARCHAR2(30) := 'LAB_CREDIT_POINTS';
        cst_lecture_credit_points              VARCHAR2(30) := 'LECTURE_CREDIT_POINTS';
        cst_level_code                         VARCHAR2(30) := 'LEVEL_CODE';
        cst_max_repeat_credit_points           VARCHAR2(30) := 'MAX_REPEAT_CREDIT_POINTS';
        cst_max_repeats_for_credit             VARCHAR2(30) := 'MAX_REPEATS_FOR_CREDIT';
        cst_max_repeats_for_funding            VARCHAR2(30) := 'MAX_REPEATS_FOR_FUNDING';
        cst_non_schd_required_hrs              VARCHAR2(30) := 'NON_SCHD_REQUIRED_HRS';
        cst_other_credit_points                VARCHAR2(30) := 'OTHER_CREDIT_POINTS';
        cst_override_enrollment_max            VARCHAR2(30) := 'OVERRIDE_ENROLLMENT_MAX';
        cst_record_exclusion_flag              VARCHAR2(30) := 'RECORD_EXCLUSION_FLAG';
        c_ss_display_ind                       VARCHAR2(30) := 'SS_DISPLAY_IND';
        cst_repeat_code                        VARCHAR2(30) := 'REPEAT_CODE';
        cst_rpt_fmly_id                        VARCHAR2(30) := 'RPT_FMLY_ID';
        cst_same_teach_period_repeats          VARCHAR2(30) := 'SAME_TEACH_PERIOD_REPEATS';
        c_same_teach_period_repeats_cp         VARCHAR2(30) := 'SAME_TEACH_PERIOD_REPEATS_CP';
        cst_same_teaching_period               VARCHAR2(30) := 'SAME_TEACHING_PERIOD';
        c_sequence_num_enrol_load_cal          VARCHAR2(30) := 'SEQUENCE_NUM_ENROL_LOAD_CAL';
        c_sequence_num_offer_load_cal          VARCHAR2(30) := 'SEQUENCE_NUM_OFFER_LOAD_CAL';
        cst_special_permission_ind             VARCHAR2(30) := 'SPECIAL_PERMISSION_IND';
        cst_state_financial_aid                VARCHAR2(30) := 'STATE_FINANCIAL_AID';
        cst_subtitle                           VARCHAR2(30) := 'SUBTITLE';
        cst_subtitle_id                        VARCHAR2(30) := 'SUBTITLE_ID';
        cst_subtitle_modifiable_flag           VARCHAR2(30) := 'SUBTITLE_MODIFIABLE_FLAG';
        cst_unit_type_id                       VARCHAR2(30) := 'UNIT_TYPE_ID';
        cst_work_load_cp_lab                   VARCHAR2(30) := 'WORK_LOAD_CP_LAB';
        cst_work_load_cp_lecture               VARCHAR2(30) := 'WORK_LOAD_CP_LECTURE';
        cst_work_load_other                    VARCHAR2(30) := 'WORK_LOAD_OTHER';
        cst_claimable_hours                    VARCHAR2(30) := 'CLAIMABLE_HOURS';
	cst_auditable_ind			VARCHAR2(30) := 'AUDITABLE_IND';
	cst_audit_permission_ind		VARCHAR2(30) := 'AUDIT_PERMISSION_IND';
	cst_max_auditors_allowed		VARCHAR2(30) := 'MAX_AUDITORS_ALLOWED';
	l_c_billing_credit_points               VARCHAR2(30) := 'BILLING_CREDIT_POINTS';
        l_c_ovrd_wkld_val_flag                  VARCHAR2(30) := 'OVRD_WKLD_VAL_FLAG';
        l_c_workload_val_code                   VARCHAR2(30) := 'WORKLOAD_VAL_CODE';
	l_c_billing_hrs                         VARCHAR2(30)  := 'BILLING_HRS';

	CURSOR	c_uvh IS
		SELECT	DECODE (p_column_name,
				cst_start_dt,			IGS_GE_DATE.igscharDT(uvh.start_dt),
				cst_review_dt,			IGS_GE_DATE.igscharDT(uvh.review_dt),
				cst_expiry_dt,			IGS_GE_DATE.igscharDT(uvh.expiry_dt),
				cst_end_dt,			IGS_GE_DATE.igscharDT(uvh.end_dt),
				cst_unit_status,			uvh.UNIT_STATUS,
				cst_title,				uvh.TITLE,
				cst_short_title,			uvh.short_title,
				cst_title_override_ind,		uvh.title_override_ind,
				cst_abbreviation,			uvh.abbreviation,
				cst_unit_level,			uvh.UNIT_LEVEL,
				cst_ul_description,			uvh.ul_description,
				cst_credit_point_descriptor,		uvh.CREDIT_POINT_DESCRIPTOR,
				cst_enrolled_credit_points,		TO_CHAR(uvh.enrolled_credit_points),
				cst_points_override_ind,		uvh.points_override_ind,
				cst_supp_exam_permitted_ind,	uvh.supp_exam_permitted_ind,
				cst_coord_person_id,		TO_CHAR(uvh.coord_person_id),
				cst_owner_org_unit_cd,		uvh.owner_org_unit_cd,
				cst_owner_ou_start_dt,		IGS_GE_DATE.igscharDT(uvh.owner_ou_start_dt),
				cst_ou_description,		uvh.ou_description,
				cst_award_course_only_ind,		uvh.award_course_only_ind,
				cst_research_unit_ind,		uvh.research_unit_ind,
				cst_industrial_ind,			uvh.industrial_ind,
				cst_practical_ind,			uvh.practical_ind,
				cst_repeatable_ind,		uvh.repeatable_ind,
				cst_assessable_ind,		uvh.assessable_ind,
				cst_achievable_credit_points,	TO_CHAR(uvh.achievable_credit_points),
				cst_points_increment,		TO_CHAR(uvh.points_increment),
				cst_points_min,			TO_CHAR(uvh.points_min),
				cst_points_max,			TO_CHAR(uvh.points_max),
				cst_unit_int_course_level_cd,	uvh.unit_int_course_level_cd,
				cst_uicl_description,		uvh.uicl_description,
		                cst_advance_maximum,               TO_CHAR(uvh.advance_maximum),
                                cst_approval_date,                IGS_GE_DATE.igscharDT( uvh.approval_date ),
                                cst_cal_type_enrol_load_cal,       uvh.cal_type_enrol_load_cal,
                                cst_cal_type_offer_load_cal,       uvh.cal_type_offer_load_cal,
                                cst_clock_hours,                   TO_CHAR(uvh.clock_hours),
                                cst_contact_hrs_lab,               TO_CHAR(uvh.contact_hrs_lab),
                                cst_contact_hrs_lecture,           TO_CHAR(uvh.contact_hrs_lecture),
                                cst_contact_hrs_other,             TO_CHAR(uvh.contact_hrs_other),
                                cst_continuing_education_units,    TO_CHAR(uvh.continuing_education_units),
                                cst_curriculum_id,                 uvh.curriculum_id,
                                cst_enrollment_expected,           TO_CHAR(uvh.enrollment_expected),
                                cst_enrollment_maximum,            TO_CHAR(uvh.enrollment_maximum),
                                cst_enrollment_minimum,            TO_CHAR(uvh.enrollment_minimum),
                                cst_exclude_from_max_cp_limit,     uvh.exclude_from_max_cp_limit,
                                cst_federal_financial_aid,         uvh.federal_financial_aid,
                                c_institutional_financial_aid,   uvh.institutional_financial_aid,
                                cst_lab_credit_points,             TO_CHAR(uvh.lab_credit_points),
                                cst_lecture_credit_points,         TO_CHAR(uvh.lecture_credit_points),
                                cst_level_code,                    uvh.level_code,
                                cst_max_repeat_credit_points,      TO_CHAR(uvh.max_repeat_credit_points),
                                cst_max_repeats_for_credit,        TO_CHAR(uvh.max_repeats_for_credit),
                                cst_max_repeats_for_funding,       TO_CHAR(uvh.max_repeats_for_funding),
                                cst_non_schd_required_hrs,         TO_CHAR(uvh.non_schd_required_hrs),
                                cst_other_credit_points,           TO_CHAR(uvh.other_credit_points),
                                cst_override_enrollment_max,       TO_CHAR(uvh.override_enrollment_max),
                                cst_record_exclusion_flag,         uvh.record_exclusion_flag,
                                c_ss_display_ind,                  uvh.ss_display_ind,
                                cst_repeat_code,                   uvh.repeat_code,
                                cst_rpt_fmly_id,                   TO_CHAR(uvh.rpt_fmly_id),
                                cst_same_teach_period_repeats,     TO_CHAR(uvh.same_teach_period_repeats),
                                c_same_teach_period_repeats_cp,  TO_CHAR(uvh.same_teach_period_repeats_cp),
                                cst_same_teaching_period,          uvh.same_teaching_period,
                                c_sequence_num_enrol_load_cal,   TO_CHAR(uvh.sequence_num_enrol_load_cal),
                                c_sequence_num_offer_load_cal,   TO_CHAR(uvh.sequence_num_offer_load_cal),
                                cst_special_permission_ind,        uvh.special_permission_ind,
                                cst_state_financial_aid,           uvh.state_financial_aid,
                                cst_subtitle,                      uvh.subtitle,
                                cst_subtitle_id,                   TO_CHAR(uvh.subtitle_id),
                                cst_subtitle_modifiable_flag,      uvh.subtitle_modifiable_flag,
                                cst_unit_type_id,                  TO_CHAR(uvh.unit_type_id),
                                cst_work_load_cp_lab,              TO_CHAR(uvh.work_load_cp_lab),
                                cst_work_load_cp_lecture,          TO_CHAR(uvh.work_load_cp_lecture),
                                cst_work_load_other,               TO_CHAR(uvh.work_load_other) ,
                                cst_claimable_hours,          TO_CHAR(uvh.claimable_hours),
				cst_auditable_ind,		uvh.auditable_ind,
				cst_audit_permission_ind,	uvh.audit_permission_ind,
				cst_max_auditors_allowed,	TO_CHAR(uvh.max_auditors_allowed),
				l_c_billing_credit_points,       TO_CHAR(uvh.billing_credit_points),
				l_c_ovrd_wkld_val_flag,          uvh.ovrd_wkld_val_flag,
                                l_c_workload_val_code,           uvh.workload_val_code,
				l_c_billing_hrs,                TO_CHAR(uvh.billing_hrs)
				)
                FROM	IGS_PS_UNIT_VER_HIST	uvh
		WHERE	uvh.unit_cd		= p_unit_cd AND
			uvh.version_number	= p_version_number AND
			uvh.hist_start_dt		>= p_hist_date AND
			DECODE (p_column_name,
				cst_start_dt,			IGS_GE_DATE.igscharDT(uvh.start_dt),
				cst_review_dt,			IGS_GE_DATE.igscharDT(uvh.review_dt),
				cst_expiry_dt,			IGS_GE_DATE.igscharDT(uvh.expiry_dt),
				cst_end_dt,			IGS_GE_DATE.igscharDT(uvh.end_dt),
				cst_unit_status,			uvh.UNIT_STATUS,
				cst_title,				uvh.TITLE,
				cst_short_title,			uvh.short_title,
				cst_title_override_ind,		uvh.title_override_ind,
				cst_abbreviation,			uvh.abbreviation,
				cst_unit_level,			uvh.UNIT_LEVEL,
				cst_ul_description,			uvh.ul_description,
				cst_credit_point_descriptor,		uvh.CREDIT_POINT_DESCRIPTOR,
				cst_enrolled_credit_points,		TO_CHAR(uvh.enrolled_credit_points),
				cst_points_override_ind,		uvh.points_override_ind,
				cst_supp_exam_permitted_ind,	uvh.supp_exam_permitted_ind,
				cst_coord_person_id,		TO_CHAR(uvh.coord_person_id),
				cst_owner_org_unit_cd,		uvh.owner_org_unit_cd,
				cst_owner_ou_start_dt,		IGS_GE_DATE.igscharDT(uvh.owner_ou_start_dt),
				cst_ou_description,		uvh.ou_description,
				cst_award_course_only_ind,		uvh.award_course_only_ind,
				cst_research_unit_ind,		uvh.research_unit_ind,
				cst_industrial_ind,			uvh.industrial_ind,
				cst_practical_ind,			uvh.practical_ind,
				cst_repeatable_ind,		uvh.repeatable_ind,
				cst_assessable_ind,		uvh.assessable_ind,
				cst_achievable_credit_points,	TO_CHAR(uvh.achievable_credit_points),
				cst_points_increment,		TO_CHAR(uvh.points_increment),
				cst_points_min,			TO_CHAR(uvh.points_min),
				cst_points_max,			TO_CHAR(uvh.points_max),
				cst_unit_int_course_level_cd,	uvh.unit_int_course_level_cd,
				cst_uicl_description,		uvh.uicl_description,
                                cst_advance_maximum,               TO_CHAR(uvh.advance_maximum),
                                cst_approval_date,                IGS_GE_DATE.igscharDT( uvh.approval_date ),
                                cst_cal_type_enrol_load_cal,       uvh.cal_type_enrol_load_cal,
                                cst_cal_type_offer_load_cal,       uvh.cal_type_offer_load_cal,
                                cst_clock_hours,                   TO_CHAR(uvh.clock_hours),
                                cst_contact_hrs_lab,               TO_CHAR(uvh.contact_hrs_lab),
                                cst_contact_hrs_lecture,           TO_CHAR(uvh.contact_hrs_lecture),
                                cst_contact_hrs_other,             TO_CHAR(uvh.contact_hrs_other),
                                cst_continuing_education_units,    TO_CHAR(uvh.continuing_education_units),
                                cst_curriculum_id,                 uvh.curriculum_id,
                                cst_enrollment_expected,           TO_CHAR(uvh.enrollment_expected),
                                cst_enrollment_maximum,            TO_CHAR(uvh.enrollment_maximum),
                                cst_enrollment_minimum,            TO_CHAR(uvh.enrollment_minimum),
                                cst_exclude_from_max_cp_limit,     uvh.exclude_from_max_cp_limit,
                                cst_federal_financial_aid,         uvh.federal_financial_aid,
                                c_institutional_financial_aid,   uvh.institutional_financial_aid,
                                cst_lab_credit_points,             TO_CHAR(uvh.lab_credit_points),
                                cst_lecture_credit_points,         TO_CHAR(uvh.lecture_credit_points),
                                cst_level_code,                    uvh.level_code,
                                cst_max_repeat_credit_points,      TO_CHAR(uvh.max_repeat_credit_points),
                                cst_max_repeats_for_credit,        TO_CHAR(uvh.max_repeats_for_credit),
                                cst_max_repeats_for_funding,       TO_CHAR(uvh.max_repeats_for_funding),
                                cst_non_schd_required_hrs,         TO_CHAR(uvh.non_schd_required_hrs),
                                cst_other_credit_points,           TO_CHAR(uvh.other_credit_points),
                                cst_override_enrollment_max,       TO_CHAR(uvh.override_enrollment_max),
                                cst_record_exclusion_flag,         uvh.record_exclusion_flag,
                                c_ss_display_ind,                  uvh.ss_display_ind,
                                cst_repeat_code,                   uvh.repeat_code,
                                cst_rpt_fmly_id,                   TO_CHAR(uvh.rpt_fmly_id),
                                cst_same_teach_period_repeats,     TO_CHAR(uvh.same_teach_period_repeats),
                                c_same_teach_period_repeats_cp,  TO_CHAR(uvh.same_teach_period_repeats_cp),
                                cst_same_teaching_period,          uvh.same_teaching_period,
                                c_sequence_num_enrol_load_cal,   TO_CHAR(uvh.sequence_num_enrol_load_cal),
                                c_sequence_num_offer_load_cal,   TO_CHAR(uvh.sequence_num_offer_load_cal),
                                cst_special_permission_ind,        uvh.special_permission_ind,
                                cst_state_financial_aid,           uvh.state_financial_aid,
                                cst_subtitle,                      uvh.subtitle,
                                cst_subtitle_id,                   TO_CHAR(uvh.subtitle_id),
                                cst_subtitle_modifiable_flag,      uvh.subtitle_modifiable_flag,
                                cst_unit_type_id,                  TO_CHAR(uvh.unit_type_id),
                                cst_work_load_cp_lab,              TO_CHAR(uvh.work_load_cp_lab),
                                cst_work_load_cp_lecture,          TO_CHAR(uvh.work_load_cp_lecture),
                                cst_work_load_other,               TO_CHAR(uvh.work_load_other),
                                cst_claimable_hours,               TO_CHAR(uvh.claimable_hours),
				cst_auditable_ind,		   uvh.auditable_ind,
				cst_audit_permission_ind,	   uvh.audit_permission_ind,
				cst_max_auditors_allowed,	   TO_CHAR(uvh.max_auditors_allowed),
				l_c_billing_credit_points,         TO_CHAR(uvh.billing_credit_points),
				l_c_ovrd_wkld_val_flag,            uvh.ovrd_wkld_val_flag,
                                l_c_workload_val_code,             uvh.workload_val_code,
				l_c_billing_hrs,                   uvh.billing_hrs

                              ) IS NOT NULL
		ORDER BY hist_start_dt;
BEGIN
	OPEN c_uvh;
	FETCH c_uvh INTO v_column_value;
	CLOSE c_uvh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_uvh%ISOPEN) THEN
			CLOSE c_uvh;
		END IF;
		RAISE;
END;
END audp_get_uvh_col;

END IGS_AU_GEN_004;

/
