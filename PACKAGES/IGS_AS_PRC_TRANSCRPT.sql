--------------------------------------------------------
--  DDL for Package IGS_AS_PRC_TRANSCRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_PRC_TRANSCRPT" AUTHID CURRENT_USER AS
/* $Header: IGSAS08S.pls 120.0 2005/07/05 11:21:53 appldev noship $ */
  --
  TYPE r_sca_dtl IS RECORD
  (
  v_acad_alternate_code VARCHAR2(10),
  v_course_cd IGS_EN_STDNT_PS_ATT_ALL.COURSE_CD%TYPE,
  v_title IGS_PS_VER_ALL.TITLE%TYPE,
  v_acad_cal_type IGS_CA_INST_ALL.CAL_TYPE%TYPE,
  v_acad_ci_sequence_number IGS_CA_INST_ALL.SEQUENCE_NUMBER%TYPE,
  v_acad_start_dt IGS_CA_INST_ALL.START_DT%TYPE,
  v_attendance_type IGS_PS_OFR_PAT.ATTENDANCE_TYPE%TYPE,
  v_location_cd IGS_PS_OFR_PAT.LOCATION_CD%TYPE,
  v_commencement_dt IGS_EN_STDNT_PS_ATT_ALL.COMMENCEMENT_DT%TYPE);
  --
  --
  TYPE r_sua_dtl IS RECORD
  (
  v_teach_alternate_code IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE,
  v_unit_cd IGS_EN_SU_ATTEMPT_ALL.UNIT_CD%TYPE,
  v_title IGS_PS_UNIT_VER_ALL.TITLE%TYPE,
  v_short_title IGS_PS_UNIT_VER_ALL.SHORT_TITLE%TYPE,
  v_cp_achievable IGS_PS_UNIT_VER_ALL.ACHIEVABLE_CREDIT_POINTS%TYPE,
  v_cp_achieved IGS_PS_UNIT_VER_ALL.ACHIEVABLE_CREDIT_POINTS%TYPE,
  v_unit_level IGS_PS_UNIT_VER_ALL.UNIT_LEVEL%TYPE,
  v_mark IGS_AS_SU_STMPTOUT_ALL.MARK%TYPE,
  v_grade IGS_AS_SU_STMPTOUT_ALL.GRADE%TYPE,
  v_grading_schema_cd IGS_AS_SU_STMPTOUT_ALL.GRADING_SCHEMA_CD%TYPE,
  v_gs_version_number IGS_AS_SU_STMPTOUT_ALL.VERSION_NUMBER%TYPE,
  v_s_result IGS_AS_GRD_SCH_GRADE.S_RESULT_TYPE%TYPE);
  --
  --
  TYPE r_stdg_dtl IS RECORD
  (
  v_acad_alternate_code VARCHAR2(10),
  v_course_cd IGS_EN_STDNT_PS_ATT_ALL.COURSE_CD%TYPE,
  v_int_start_dt IGS_EN_STDNT_PS_INTM.START_DT%TYPE,
  v_int_end_dt IGS_EN_STDNT_PS_INTM.END_DT%TYPE,
  v_lapsed_dt IGS_EN_STDNT_PS_ATT_ALL.LAPSED_DT%TYPE,
  v_discontinued_dt IGS_EN_STDNT_PS_ATT_ALL.DISCONTINUED_DT%TYPE,
  v_type VARCHAR2(10));
  --
  --
  TYPE r_adv_dtl IS RECORD
  (
  v_title VARCHAR2(50));
  --
  --
  TYPE r_asu_dtl IS RECORD
  (
  v_unit_cd IGS_AV_STND_UNIT_ALL.UNIT_CD%TYPE,
  v_unit_level IGS_PS_UNIT_VER_ALL.UNIT_LEVEL%TYPE,
  v_cp_achievable IGS_PS_UNIT_VER_ALL.ACHIEVABLE_CREDIT_POINTS%TYPE,
  v_title IGS_PS_UNIT_VER_ALL.TITLE%TYPE,
  v_short_title IGS_PS_UNIT_VER_ALL.SHORT_TITLE%TYPE);
  --
  --
  TYPE r_asule_dtl IS RECORD
  (
  v_description VARCHAR2(50),
  v_unit_level IGS_AV_STND_UNIT_LVL_ALL.UNIT_LEVEL%TYPE,
  v_cp_granted IGS_AV_STND_UNIT_LVL_ALL.CREDIT_POINTS%TYPE);
  --
  --
  TYPE r_sct_dtl IS RECORD
  (
  v_teach_alternate_code IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE,
  v_from_course IGS_PS_STDNT_TRN.TRANSFER_COURSE_CD%TYPE,
  v_to_course IGS_PS_STDNT_TRN.COURSE_CD%TYPE,
  v_transfer_dt IGS_PS_STDNT_TRN.TRANSFER_DT%TYPE,
  v_unit_ind VARCHAR2(1));
  --
  --
  TYPE r_sut_dtl IS RECORD
  (
  v_teach_alternate_code IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE,
  v_acad_alternate_code IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE,
  v_unit_cd IGS_PS_STDNT_UNT_TRN.UNIT_CD%TYPE,
  v_title IGS_PS_UNIT_VER_ALL.TITLE%TYPE,
  v_short_title IGS_PS_UNIT_VER_ALL.SHORT_TITLE%TYPE,
  v_cp_achievable IGS_PS_UNIT_VER_ALL.ACHIEVABLE_CREDIT_POINTS%TYPE,
  v_cp_achieved IGS_PS_UNIT_VER_ALL.ACHIEVABLE_CREDIT_POINTS%TYPE,
  v_unit_level IGS_PS_UNIT_VER_ALL.UNIT_LEVEL%TYPE,
  v_mark IGS_AS_SU_STMPTOUT_ALL.MARK%TYPE,
  v_grade IGS_AS_SU_STMPTOUT_ALL.GRADE%TYPE,
  v_grading_schema_cd IGS_AS_SU_STMPTOUT_ALL.GRADING_SCHEMA_CD%TYPE,
  v_gs_version_number IGS_AS_SU_STMPTOUT_ALL.VERSION_NUMBER%TYPE);
  --
  --
  TYPE r_susa_dtl IS RECORD
  (
  v_unit_set_cd IGS_AS_SU_SETATMPT.UNIT_SET_CD%TYPE,
  v_title IGS_EN_UNIT_SET_ALL.TITLE%TYPE,
  v_unit_set_cat IGS_EN_UNIT_SET_CAT.UNIT_SET_CAT%TYPE,
  v_unit_set_cat_desc IGS_EN_UNIT_SET_CAT.DESCRIPTION%TYPE,
  v_selection_dt IGS_AS_SU_SETATMPT.SELECTION_DT%TYPE,
  v_primary_set_ind IGS_AS_SU_SETATMPT.PRIMARY_SET_IND%TYPE,
  v_completion_dt IGS_AS_SU_SETATMPT.RQRMNTS_COMPLETE_DT%TYPE);
  --
  --
  TYPE r_res_dtl IS RECORD
  (
  v_teach_alternate_code IGS_CA_INST_ALL.ALTERNATE_CODE%TYPE,
  v_course_cd IGS_EN_STDNT_PS_ATT_ALL.COURSE_CD%TYPE,
  v_title IGS_RE_THESIS_ALL.TITLE%TYPE,
  v_final_title_ind IGS_RE_THESIS_ALL.FINAL_TITLE_IND%TYPE);
  --
  --
  TYPE r_grd_dtl IS RECORD
  (
  v_acad_alternate_code VARCHAR2(10),
  v_course_cd IGS_EN_STDNT_PS_ATT_ALL.COURSE_CD%TYPE,
  v_completion_dt IGS_EN_STDNT_PS_ATT_ALL.COURSE_RQRMNTS_COMPLETE_DT%TYPE,
  v_conferral_dt IGS_GR_GRADUAND.CONFERRAL_DT%TYPE,
  v_award_title IGS_PS_AWD.AWARD_TITLE%TYPE,
  v_type VARCHAR2(10));
  --
  --
  TYPE t_sca_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_sca_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sua_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_sua_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_stdg_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_stdg_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_adv_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_adv_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_asu_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_asu_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_asule_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_asule_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sct_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_sct_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_sut_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_sut_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_susa_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_susa_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_res_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_res_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  TYPE t_grd_dtl IS TABLE OF
  IGS_AS_PRC_TRANSCRPT.r_grd_dtl
  INDEX BY BINARY_INTEGER;
  --
  --
  gt_sca_dtl_table t_sca_dtl;
  --
  --
  gt_asule_dtl_table t_asule_dtl;
  --
  --
  gt_sut_dtl_table t_sut_dtl;
  --
  --
  gt_sct_dtl_table t_sct_dtl;
  --
  --
  gt_res_dtl_table t_res_dtl;
  --
  --
  gt_asu_dtl_table t_asu_dtl;
  --
  --
  gt_adv_dtl_table t_adv_dtl;
  --
  --
  gt_susa_dtl_table t_susa_dtl;
  --
  --
  gt_sua_dtl_table t_sua_dtl;
  --
  --
  gt_stdg_dtl_table t_stdg_dtl;
  --
  --
  gt_grd_dtl_table t_grd_dtl;
  --
  --
  gv_sca_dtl_index BINARY_INTEGER;
  --
  --
  gv_stdg_dtl_index BINARY_INTEGER;
  --
  --
  gv_grd_dtl_index BINARY_INTEGER;
  --
  --
  gv_asule_dtl_index BINARY_INTEGER;
  --
  --
  gv_sut_dtl_index BINARY_INTEGER;
  --
  --
  gv_res_dtl_index BINARY_INTEGER;
  --
  --
  gv_sct_dtl_index BINARY_INTEGER;
  --
  --
  gv_susa_dtl_index BINARY_INTEGER;
  --
  --
  gv_asu_dtl_index BINARY_INTEGER;
  --
  --
  gv_adv_dtl_index BINARY_INTEGER;
  --
  --
  gv_sua_dtl_index BINARY_INTEGER;
  --
  -- Retrieves graduation details for display on transcript
  FUNCTION assp_get_trn_grd_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- To get one component of a string which is delimited.
  FUNCTION ASSP_GET_TRN_DESC(
  p_extract_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(ASSP_GET_TRN_DESC,WNDS);
  --
  -- Retrieves research details for display on transcript.
  FUNCTION assp_get_trn_res_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

 --
  -- Retrieves UNIT set attempt details for display on transcript.
  FUNCTION assp_get_trn_us_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- Retrieves UNIT transfer details for display on transcript
  FUNCTION assp_get_trn_sut_dtl(
  p_person_id IN NUMBER ,
  p_to_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- Retrieves COURSE transfer details for display on transcript
  FUNCTION assp_get_trn_sct_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_record_number IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(assp_get_trn_sct_dtl,WNDS);
  --
  -- Retrieves COURSE standing details for display on transcript
  FUNCTION assp_get_trn_crs_std(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(assp_get_trn_crs_std,WNDS);
  --
  -- Retrieves basic UNIT details for display on transcript
  FUNCTION assp_get_trn_sua_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_record_number IN NUMBER )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(assp_get_trn_sua_dtl,WNDS);
  --
  -- Retrieves adv standing UNIT level details for display on transcript
  FUNCTION assp_get_trn_asl_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- Retrieves advanced standing UNIT details for display on transcript
  FUNCTION assp_get_trn_asu_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- Retrieves basic advanced standing details for display on transcript
  FUNCTION assp_get_trn_adv_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER )
RETURN VARCHAR2;

  --
  -- Retrieves basic COURSE details for display on transcript
  FUNCTION assp_get_trn_sca_dtl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_order_by IN VARCHAR2 DEFAULT 'YEAR',
  p_include_fail_grade_ind IN VARCHAR2 DEFAULT 'N',
  p_enrolled_units_ind IN VARCHAR2 DEFAULT 'C',
  p_exclude_research_units_ind IN VARCHAR2 DEFAULT 'N',
  p_exclude_unit_category IN VARCHAR2 ,
  p_include_related_crs_ind IN VARCHAR2 DEFAULT 'N',
  p_record_number IN NUMBER ,
  p_extra_context OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

END IGS_AS_PRC_TRANSCRPT;

 

/
