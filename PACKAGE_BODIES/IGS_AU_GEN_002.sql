--------------------------------------------------------
--  DDL for Package Body IGS_AU_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AU_GEN_002" AS
/* $Header: IGSAU02B.pls 120.0 2005/06/03 15:47:31 appldev noship $ */
/*
CHANGE HISTORY :
WHO        WHEN           WHAT
ijeddy      05-nov-2003  Bug# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
smvk       10-Oct-2003    Enh # 3052445. Added MAX_WLST_PER_STUD to the function audp_get_cvh_col.
vvutukur   19_oct-2002    Enh#2608227.Removed references to obsoleted columns std_ft_completion_time,std_ft_completion_time.
                          Also removed references to DEFAULT keyword to avoid gscc File.Pkg.22 warnings.
vvutukur   29-Jul-2002    Bug#2425767.Removed references to payment_hierarchy_rank(obsoleted column)
                          from functions audp_get_fcflh_col,audp_get_ftcih_col.
vchappid   25-Apr-2002    Bug# 2329407, Removed reference to the columns fin_cal_type, fin_ci_sequence_number, account_cd
                          in the function audp_get_ftcih_col
ayedubat   25-MAY-2001    modified the function,audp_get_cvh_col to add the
			  new columns according to the DLD,PSP001-US
*/

  FUNCTION audp_get_culh_col(
  p_unit_cd  igs_ps_unit_lvl_hist_all.unit_cd%TYPE ,
  p_course_type  igs_ps_unit_lvl_hist_all.course_type%TYPE DEFAULT NULL,
  p_version_number  igs_ps_unit_lvl_hist_all.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  igs_ps_unit_lvl_hist_all.hist_start_dt%TYPE,
  p_course_cd   IGS_PS_UNIT_LVL_HIST_ALL.course_cd%TYPE,
  p_course_version_number   IGS_PS_UNIT_LVL_HIST_ALL.course_version_number%TYPE

  )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_culh_col
    -- get the oldest column value (after a given date) for the
    -- WAM_WEIGHTING column, unit_cd,  and version_number.
  DECLARE
    v_column_value  VARCHAR2(2000) := NULL;
    CURSOR c_culh IS
      SELECT decode (p_column_name,
        'UNIT_LEVEL', culh.unit_level,
        'WAM_WEIGHTING', TO_CHAR(culh.wam_weighting))
      FROM igs_ps_unit_lvl_hist culh
      WHERE culh.unit_cd  = p_unit_cd AND
        culh.version_number = p_version_number AND
        culh.course_cd = p_course_cd   AND
        culh.course_version_number =  p_course_version_number AND
        culh.hist_start_dt  >= p_hist_date AND
        decode (p_column_name,
        'UNIT_LEVEL', culh.unit_level,
        'WAM_WEIGHTING', TO_CHAR(culh.wam_weighting)) IS NOT NULL
      ORDER BY culh.hist_start_dt;
  BEGIN
    OPEN c_culh;
    FETCH c_culh INTO v_column_value;
    CLOSE c_culh;
    RETURN v_column_value;
    EXCEPTION
    WHEN OTHERS THEN
    IF (c_culh%isopen) THEN
    CLOSE c_culh;
    END IF;
    RAISE;
    END;
  END audp_get_culh_col;

  FUNCTION audp_get_cvh_col(
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi       23-Jan-2004   Enh#3345205, added column annual_instruction_time in the select statement
  vvutukur       19_oct-2002   Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ayedubat       25-MAY-2001    modified the procedure to add new columns
  (reverse chronological order - newest change first)
  ***************************************************************/
  p_course_cd  igs_ps_ver_hist_all.course_cd%TYPE ,
  p_version_number  igs_ps_ver_hist_all.version_number%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  igs_ps_ver_hist_all.hist_start_dt%TYPE )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_cvh_col
    -- Get the oldest column value (after a given date) for a given
    -- column name, course_cd and version_number.
  DECLARE
    cst_start_dt   VARCHAR2(30) := 'START_DT';
    cst_review_dt   VARCHAR2(30) := 'REVIEW_DT';
    cst_expiry_dt   VARCHAR2(30) := 'EXPIRY_DT';
    cst_end_dt   VARCHAR2(30) := 'END_DT';
    cst_course_status  VARCHAR2(30) := 'COURSE_STATUS';
    cst_title   VARCHAR2(30) := 'TITLE';
    cst_short_title   VARCHAR2(30) := 'SHORT_TITLE';
    cst_abbreviation   VARCHAR2(30) := 'ABBREVIATION';
    cst_supp_exam_permitted_ind VARCHAR2(30) := 'SUPP_EXAM_PERMITTED_IND';
    cst_generic_course_ind   VARCHAR2(30) := 'GENERIC_COURSE_IND';
    cst_graduate_students_ind VARCHAR2(30) := 'GRADUATE_STUDENTS_IND';
    cst_count_intrmsn_in_time_ind VARCHAR2(30) := 'COUNT_INTRMSN_IN_TIME_IND';
    cst_intrmsn_allowed_ind  VARCHAR2(30) := 'INTRMSN_ALLOWED_IND';
    cst_course_type   VARCHAR2(30) := 'COURSE_TYPE';
    cst_ct_description  VARCHAR2(30) := 'CT_DESCRIPTION';
    cst_responsible_org_unit_cd VARCHAR2(30) := 'RESPONSIBLE_ORG_UNIT_CD';
    cst_responsible_ou_start_dt VARCHAR2(30) := 'RESPONSIBLE_OU_START_DT';
    cst_ou_description  VARCHAR2(30) := 'OU_DESCRIPTION';
    cst_govt_special_course_type VARCHAR2(30) := 'GOVT_SPECIAL_COURSE_TYPE';
    cst_gsct_description   VARCHAR2(30) := 'GSCT_DESCRIPTION';
    cst_qualification_recency VARCHAR2(30) := 'QUALIFICATION_RECENCY';
    cst_external_adv_stnd_limit VARCHAR2(30) := 'EXTERNAL_ADV_STND_LIMIT';
    cst_internal_adv_stnd_limit VARCHAR2(30) := 'INTERNAL_ADV_STND_LIMIT';
    cst_contact_hours  VARCHAR2(30) := 'CONTACT_HOURS';
    cst_credit_points_required VARCHAR2(30) := 'CREDIT_POINTS_REQUIRED';
    cst_govt_course_load  VARCHAR2(30) := 'GOVT_COURSE_LOAD';
    cst_std_annual_load  VARCHAR2(30) := 'STD_ANNUAL_LOAD';
    cst_course_total_eftsu  VARCHAR2(30) := 'COURSE_TOTAL_EFTSU';
    cst_max_intrmsn_duration VARCHAR2(30) := 'MAX_INTRMSN_DURATION';
    cst_num_of_unts_bfr_intrmsn VARCHAR2(30) := 'NUM_OF_UNITS_BEFORE_INTRMSN';
    cst_min_sbmsn_percentage VARCHAR2(30) := 'MIN_SBMSN_PERCENTAGE';
    cst_min_cp_per_calendar         VARCHAR2(30) := 'MIN_CP_PER_CALENDAR';
    cst_approval_date               VARCHAR2(30) := 'APPROVAL_DATE';
    cst_external_approval_date      VARCHAR2(30) := 'EXTERNAL_APPROVAL_DATE';
    cst_federal_financial_aid       VARCHAR2(30) := 'FEDERAL_FINANCIAL_AID';
    c_institutional_financial_aid   VARCHAR2(30) := 'INSTITUTIONAL_FINANCIAL_AID';
    cst_max_cp_per_teaching_period  VARCHAR2(30) := 'MAX_CP_PER_TEACHING_PERIOD';
    cst_residency_cp_required       VARCHAR2(30) := 'RESIDENCY_CP_REQUIRED';
    cst_state_financial_aid         VARCHAR2(30) := 'STATE_FINANCIAL_AID';
    cst_primary_program_rank        VARCHAR2(30) := 'PRIMARY_PROGRAM_RANK';
    l_c_max_wlst_per_stud           VARCHAR2(30) := 'MAX_WLST_PER_STUD';
    l_c_annual_instruction_time     VARCHAR2(30) := 'ANNUAL_INSTRUCTION_TIME';
    v_column_value   VARCHAR2(2000) := NULL;
    CURSOR c_cvh IS
      SELECT decode (p_column_name,
        cst_start_dt,   igs_ge_date.igschardt(cvh.start_dt),
        cst_review_dt,   igs_ge_date.igschardt(cvh.review_dt),
        cst_expiry_dt,   igs_ge_date.igschardt(cvh.expiry_dt),
        cst_end_dt,   igs_ge_date.igschardt(cvh.end_dt),
        cst_course_status,  cvh.course_status,
        cst_title,   cvh.title,
        cst_short_title,  cvh.short_title,
        cst_abbreviation,   cvh.abbreviation,
        cst_supp_exam_permitted_ind, cvh.supp_exam_permitted_ind,
        cst_generic_course_ind,  cvh.generic_course_ind,
        cst_graduate_students_ind, cvh.graduate_students_ind,
        cst_count_intrmsn_in_time_ind, cvh.count_intrmsn_in_time_ind,
        cst_intrmsn_allowed_ind, cvh.intrmsn_allowed_ind,
        cst_course_type,  cvh.course_type,
        cst_ct_description,  cvh.ct_description,
        cst_responsible_org_unit_cd, cvh.responsible_org_unit_cd,
        cst_responsible_ou_start_dt, igs_ge_date.igschardt(cvh.responsible_ou_start_dt),
        cst_ou_description,  cvh.ou_description,
        cst_govt_special_course_type, cvh.govt_special_course_type,
        cst_gsct_description,  cvh.gsct_description,
        cst_qualification_recency, TO_CHAR(cvh.qualification_recency),
        cst_external_adv_stnd_limit, TO_CHAR(cvh.external_adv_stnd_limit),
        cst_internal_adv_stnd_limit, TO_CHAR(cvh.internal_adv_stnd_limit),
        cst_contact_hours,  TO_CHAR(cvh.contact_hours),
        cst_credit_points_required, TO_CHAR(cvh.credit_points_required),
        cst_govt_course_load,  TO_CHAR(cvh.govt_course_load),
        cst_std_annual_load,  TO_CHAR(cvh.std_annual_load),
        cst_course_total_eftsu,  TO_CHAR(cvh.course_total_eftsu),
        cst_max_intrmsn_duration, TO_CHAR(cvh.max_intrmsn_duration),
        cst_num_of_unts_bfr_intrmsn, TO_CHAR(cvh.num_of_units_before_intrmsn),
        cst_min_sbmsn_percentage, TO_CHAR(cvh.min_sbmsn_percentage),
        cst_min_cp_per_calendar,        TO_CHAR(cvh.min_cp_per_calendar),
        cst_approval_date,              igs_ge_date.igschardt(cvh.approval_date),
        cst_external_approval_date,     igs_ge_date.igschardt(cvh.external_approval_date),
        cst_federal_financial_aid,      cvh.federal_financial_aid,
        c_institutional_financial_aid,  cvh.institutional_financial_aid,
        cst_max_cp_per_teaching_period, TO_CHAR(cvh.max_cp_per_teaching_period),
        cst_residency_cp_required,      TO_CHAR(residency_cp_required),
        cst_state_financial_aid,        state_financial_aid,
        cst_primary_program_rank,       TO_CHAR(primary_program_rank),
        l_c_max_wlst_per_stud, TO_CHAR(max_wlst_per_stud),
	l_c_annual_instruction_time, TO_CHAR(annual_instruction_time))
      FROM igs_ps_ver_hist cvh
      WHERE cvh.course_cd  = p_course_cd AND
        cvh.version_number = p_version_number AND
        cvh.hist_start_dt >= p_hist_date AND
        decode (p_column_name,
        cst_start_dt,   igs_ge_date.igschardt(cvh.start_dt),
        cst_review_dt,   igs_ge_date.igschardt(cvh.review_dt),
        cst_expiry_dt,   igs_ge_date.igschardt(cvh.expiry_dt),
        cst_end_dt,   igs_ge_date.igschardt(cvh.end_dt),
        cst_course_status,  cvh.course_status,
        cst_title,   cvh.title,
        cst_short_title,  cvh.short_title,
        cst_abbreviation,   cvh.abbreviation,
        cst_supp_exam_permitted_ind, cvh.supp_exam_permitted_ind,
        cst_generic_course_ind,  cvh.generic_course_ind,
        cst_graduate_students_ind, cvh.graduate_students_ind,
        cst_count_intrmsn_in_time_ind, cvh.count_intrmsn_in_time_ind,
        cst_intrmsn_allowed_ind, cvh.intrmsn_allowed_ind,
        cst_course_type,  cvh.course_type,
        cst_ct_description,  cvh.ct_description,
        cst_responsible_org_unit_cd, cvh.responsible_org_unit_cd,
        cst_responsible_ou_start_dt, igs_ge_date.igschardt(cvh.responsible_ou_start_dt),
        cst_ou_description,  cvh.ou_description,
        cst_govt_special_course_type, cvh.govt_special_course_type,
        cst_gsct_description,  cvh.gsct_description,
        cst_qualification_recency, TO_CHAR(cvh.qualification_recency),
        cst_external_adv_stnd_limit, TO_CHAR(cvh.external_adv_stnd_limit),
        cst_internal_adv_stnd_limit, TO_CHAR(cvh.internal_adv_stnd_limit),
        cst_contact_hours,  TO_CHAR(cvh.contact_hours),
        cst_credit_points_required, TO_CHAR(cvh.credit_points_required),
        cst_govt_course_load,  TO_CHAR(cvh.govt_course_load),
        cst_std_annual_load,  TO_CHAR(cvh.std_annual_load),
        cst_course_total_eftsu,  TO_CHAR(cvh.course_total_eftsu),
        cst_max_intrmsn_duration, TO_CHAR(cvh.max_intrmsn_duration),
        cst_num_of_unts_bfr_intrmsn, TO_CHAR(cvh.num_of_units_before_intrmsn),
        cst_min_sbmsn_percentage, TO_CHAR(cvh.min_sbmsn_percentage),
        cst_min_cp_per_calendar,        TO_CHAR(cvh.min_cp_per_calendar),
        cst_approval_date,              igs_ge_date.igschardt(cvh.approval_date),
        cst_external_approval_date,     igs_ge_date.igschardt(cvh.external_approval_date),
        cst_federal_financial_aid,      cvh.federal_financial_aid,
        c_institutional_financial_aid,  cvh.institutional_financial_aid,
        cst_max_cp_per_teaching_period, TO_CHAR(cvh.max_cp_per_teaching_period),
        cst_residency_cp_required,      TO_CHAR(residency_cp_required),
        cst_state_financial_aid,        state_financial_aid,
        cst_primary_program_rank,       TO_CHAR(primary_program_rank),
        l_c_max_wlst_per_stud,          TO_CHAR(max_wlst_per_stud),
        l_c_annual_instruction_time,    TO_CHAR(annual_instruction_time)) IS NOT NULL
        ORDER BY cvh.hist_start_dt;
    BEGIN
      OPEN c_cvh;
      FETCH c_cvh INTO v_column_value;
      CLOSE c_cvh;
      RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF (c_cvh%isopen) THEN
         CLOSE c_cvh;
       END IF;
       RAISE;
    END;
  END audp_get_cvh_col;


  FUNCTION audp_get_dh_col(
    p_column_name  user_tab_columns.column_name%TYPE ,
    p_dscplne_grp_cd  igs_ps_dscp_hist_all.discipline_group_cd%TYPE ,
    p_hist_end_dt  igs_ps_dscp_hist_all.hist_end_dt%TYPE )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_dh_col
   -- get the oldest column value (after a given date) for a given
   -- discipline_cd
  DECLARE
    cst_description  VARCHAR2(11) := 'DESCRIPTION';
    cst_funding_index_1 VARCHAR2(15) := 'FUNDING_INDEX_1';
    cst_funding_index_2 VARCHAR2(15) := 'FUNDING_INDEX_2';
    cst_funding_index_3 VARCHAR2(15) := 'FUNDING_INDEX_3';
    cst_gvt_dscplne_grp_cd VARCHAR2(24) := 'GOVT_DISCIPLINE_GROUP_CD';
    cst_closed_ind  VARCHAR2(10) := 'CLOSED_IND';
    CURSOR c_dh IS
      SELECT decode (p_column_name,
        cst_description,  dh.description,
        cst_funding_index_1, TO_CHAR(dh.funding_index_1),
        cst_funding_index_2, TO_CHAR(dh.funding_index_2),
        cst_funding_index_3, TO_CHAR(dh.funding_index_3),
        cst_gvt_dscplne_grp_cd, dh.govt_discipline_group_cd,
        cst_closed_ind,  dh.closed_ind)
      FROM igs_ps_dscp_hist  dh
      WHERE dh.discipline_group_cd = p_dscplne_grp_cd  AND
        dh.hist_start_dt  >= p_hist_end_dt  AND
        decode (p_column_name,
        cst_description,  dh.description,
        cst_funding_index_1, TO_CHAR(dh.funding_index_1),
        cst_funding_index_2, TO_CHAR(dh.funding_index_2),
        cst_funding_index_3, TO_CHAR(dh.funding_index_3),
        cst_gvt_dscplne_grp_cd, dh.govt_discipline_group_cd,
        cst_closed_ind,  dh.closed_ind) IS NOT NULL
      ORDER BY
        dh.hist_start_dt;
    v_column_value  VARCHAR2(2000) := NULL;
  BEGIN
    OPEN c_dh;
    FETCH c_dh INTO v_column_value;
    CLOSE c_dh;
    RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF (c_dh%isopen) THEN
          CLOSE c_dh;
        END IF;
        RAISE;
      END;
  END audp_get_dh_col;

  FUNCTION audp_get_fcflh_col(
    p_column_name IN user_tab_columns.column_name%TYPE ,
    p_fee_cat IN igs_fi_f_cat_f_lbl_h_all.fee_cat%TYPE ,
    p_fee_cal_type IN VARCHAR2 ,
    p_fee_ci_sequence_number IN NUMBER ,
    p_fee_type IN igs_fi_f_cat_f_lbl_h_all.fee_type%TYPE ,
    p_hist_end_dt IN DATE )
  RETURN VARCHAR2 AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     29-Jul-2002     Bug2425767.Removed references to payment_hierarchy_rank column from cursor
                               c_fcflh.
  ***************************************************************/

  BEGIN -- audp_get_fcflh_col
   -- get the oldest column value (after a given date) for a given
   -- fee_cat, fee_cal_type, fee_ci_sequence_number, fee_type
  DECLARE
    cst_fee_liability_status VARCHAR2(30) := 'FEE_LIABILITY_STATUS';
    cst_start_dt_alias  VARCHAR2(30) := 'START_DT_ALIAS';
    cst_start_dai_sequence_number VARCHAR2(30) := 'START_DAI_SEQUENCE_NUMBER';
    cst_s_chg_method_type  VARCHAR2(30) := 'S_CHG_METHOD_TYPE';
    cst_rul_sequence_number  VARCHAR2(30) := 'RUL_SEQUENCE_NUMBER';
    CURSOR c_fcflh IS
      SELECT decode (p_column_name,
        cst_fee_liability_status, fcflh.fee_liability_status,
        cst_start_dt_alias,  fcflh.start_dt_alias,
        cst_start_dai_sequence_number, TO_CHAR(fcflh.start_dai_sequence_number),
        cst_s_chg_method_type,  fcflh.s_chg_method_type,
        cst_rul_sequence_number, TO_CHAR(fcflh.rul_sequence_number))
      FROM igs_fi_f_cat_f_lbl_h fcflh
      WHERE fcflh.fee_cat   = p_fee_cat    AND
        fcflh.fee_cal_type  = p_fee_cal_type   AND
        fcflh.fee_ci_sequence_number = p_fee_ci_sequence_number  AND
        fcflh.fee_type   = p_fee_type    AND
        fcflh.hist_start_dt  >= p_hist_end_dt   AND
        decode (p_column_name,
        cst_start_dt_alias,  fcflh.start_dt_alias,
        cst_start_dai_sequence_number, TO_CHAR(fcflh.start_dai_sequence_number),
        cst_s_chg_method_type,  fcflh.s_chg_method_type,
        cst_rul_sequence_number, TO_CHAR(fcflh.rul_sequence_number)
        ) IS NOT NULL
      ORDER BY
    fcflh.hist_start_dt;
    v_column_value  VARCHAR2(2000) := NULL;
  BEGIN
    OPEN c_fcflh;
    FETCH c_fcflh INTO v_column_value;
    CLOSE c_fcflh;
    RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF (c_fcflh%isopen) THEN
          CLOSE c_fcflh;
        END IF;
        RAISE;
      END;
  END audp_get_fcflh_col;

  FUNCTION audp_get_fosh_col(
    p_column_name  user_tab_columns.column_name%TYPE ,
    p_field_of_study  igs_ps_fld_stdy_hist_all.field_of_study%TYPE ,
    p_hist_end_dt  igs_ps_fld_stdy_hist_all.hist_end_dt%TYPE )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_fosh_col
   -- get the oldest column value (after a given date) for a
   -- specified field_of_study from IGS_PS_FLD_STDY_HIST
  DECLARE
   CURSOR c_fosh IS
    SELECT
      decode (p_column_name,
      'DESCRIPTION',  fosh.description,
      'GOVT_FIELD_OF_STUDY', fosh.govt_field_of_study,
      'CLOSED_IND',  fosh.closed_ind)
    FROM igs_ps_fld_stdy_hist fosh
    WHERE fosh.field_of_study = p_field_of_study AND
      fosh.hist_start_dt >= p_hist_end_dt AND
      decode (p_column_name,
      'DESCRIPTION',  fosh.description,
      'GOVT_FIELD_OF_STUDY', fosh.govt_field_of_study,
      'CLOSED_IND',  fosh.closed_ind) IS NOT NULL
    ORDER BY
      fosh.hist_start_dt;
   v_column_value  VARCHAR2(2000) := NULL;
  BEGIN
    OPEN c_fosh;
    FETCH c_fosh INTO v_column_value;
    CLOSE c_fosh;
    RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_fosh%isopen THEN
          CLOSE c_fosh;
        END IF;
        RAISE;
      END;
  END audp_get_fosh_col;

  FUNCTION audp_get_fsh_col(
    p_funding_source  igs_fi_fund_src_hist_all.funding_source%TYPE ,
    p_column_name  user_tab_columns.column_name%TYPE ,
    p_hist_end_dt  igs_fi_fund_src_hist_all.hist_end_dt%TYPE )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_fsh_col
   -- get the oldest column value (after a given date) for a given
   -- funding source
  DECLARE
    v_column_value  VARCHAR2(2000) := NULL;
    CURSOR c_fsh IS
      SELECT
        decode (p_column_name,
        'DESCRIPTION',   fsh.description,
        'GOVT_FUNDING_SOURCE',  TO_CHAR(fsh.govt_funding_source),
        'CLOSED_IND',   fsh.closed_ind)
      FROM igs_fi_fund_src_hist fsh
      WHERE fsh.funding_source = p_funding_source AND
        fsh.hist_start_dt >= p_hist_end_dt AND
        decode (p_column_name,
        'DESCRIPTION',  fsh.description,
        'GOVT_FUNDING_SOURCE', TO_CHAR(fsh.govt_funding_source),
        'CLOSED_IND',  fsh.closed_ind)IS NOT NULL
      ORDER BY
      fsh.hist_start_dt;
  BEGIN
    OPEN c_fsh;
    FETCH c_fsh INTO v_column_value;
    CLOSE c_fsh;
    RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF(c_fsh%isopen) THEN
          CLOSE c_fsh;
        END IF;
      END;
  END audp_get_fsh_col;

  FUNCTION audp_get_fsrh_col(
    p_course_cd  igs_fi_fd_src_rstn_h_all.course_cd%TYPE ,
    p_version_number  igs_fi_fd_src_rstn_h_all.version_number%TYPE ,
    p_funding_source  igs_fi_fd_src_rstn_h_all.funding_source%TYPE ,
    p_column_name  user_tab_columns.column_name%TYPE ,
    p_hist_date  igs_fi_fd_src_rstn_h_all.hist_start_dt%TYPE )
  RETURN VARCHAR2 AS

  BEGIN -- audp_get_fsrh_col
   -- get the oldest column value (after a given date) for the dflt_ind column
   -- and a given course_cd, version_number and funding_source.
  DECLARE
   v_column_value  VARCHAR2(1) := NULL;
   CURSOR c_fsrh IS
      SELECT fsrh.dflt_ind
      FROM igs_fi_fd_src_rstn_h fsrh
      WHERE fsrh.course_cd  = p_course_cd AND
        fsrh.version_number = p_version_number AND
        fsrh.funding_source = p_funding_source AND
        fsrh.hist_start_dt  >= p_hist_date AND
        fsrh.dflt_ind  IS NOT NULL
      ORDER BY fsrh.hist_start_dt;
  BEGIN
    OPEN c_fsrh;
    FETCH c_fsrh INTO v_column_value;
    CLOSE c_fsrh;
    RETURN v_column_value;
  EXCEPTION
    WHEN OTHERS THEN
      IF (c_fsrh%isopen) THEN
        CLOSE c_fsrh;
      END IF;
      RAISE;
    END;
  END audp_get_fsrh_col;

  FUNCTION audp_get_ftcih_col(
    p_column_name IN user_tab_columns.column_name%TYPE ,
    p_fee_type IN igs_fi_fee_type_ci_h_all.fee_type%TYPE ,
    p_fee_cal_type IN igs_fi_fee_type_ci_h_all.fee_cal_type%TYPE ,
    p_fee_ci_sequence_number IN NUMBER ,
    p_hist_end_dt IN igs_fi_fee_type_ci_h_all.hist_end_dt%TYPE )
  RETURN VARCHAR2 AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur     29-Jul-2002     Bug2425767.Removed references payment_hierarchy_rank(obsoleted column)
                               from cursor c_ftcih.
  ***************************************************************/
  BEGIN -- audp_get_ftcih_col
   -- get the oldest column value (after a given date) for a given
   -- p_fee_type, p_fee_cal_type, p_fee_ci_sequence_number
  DECLARE
    cst_fee_type_ci_status  VARCHAR2(30) := 'FEE_TYPE_CI_STATUS';
    cst_start_dt_alias  VARCHAR2(30) := 'START_DT_ALIAS';
    cst_start_dai_sequence_number VARCHAR2(30) := 'START_DAI_SEQUENCE_NUMBER';
    cst_end_dt_alias  VARCHAR2(30) := 'END_DT_ALIAS';
    cst_end_dai_sequence_number VARCHAR2(30) := 'END_DAI_SEQUENCE_NUMBER';
    cst_retro_dt_alias  VARCHAR2(30) := 'RETRO_DT_ALIAS';
    cst_retro_dai_sequence_number VARCHAR2(30) := 'RETRO_DAI_SEQUENCE_NUMBER';
    cst_s_chg_method_type  VARCHAR2(30) := 'S_CHG_METHOD_TYPE';
    cst_rul_sequence_number  VARCHAR2(30) := 'RUL_SEQUENCE_NUMBER';
    CURSOR c_ftcih IS
    SELECT DECODE (p_column_name,
      cst_fee_type_ci_status,  ftcih.fee_type_ci_status,
      cst_start_dt_alias,  ftcih.start_dt_alias,
      cst_start_dai_sequence_number, TO_CHAR(ftcih.start_dai_sequence_number),
      cst_end_dt_alias,  ftcih.end_dt_alias,
      cst_end_dai_sequence_number, TO_CHAR(ftcih.end_dai_sequence_number),
      cst_retro_dt_alias,  ftcih.retro_dt_alias,
      cst_retro_dai_sequence_number, TO_CHAR(ftcih.retro_dai_sequence_number),
      cst_s_chg_method_type,  ftcih.s_chg_method_type,
      cst_rul_sequence_number, TO_CHAR(ftcih.rul_sequence_number))
    FROM igs_fi_fee_type_ci_h  ftcih
    WHERE ftcih.fee_type   = p_fee_type    AND
      ftcih.fee_cal_type  = p_fee_cal_type  AND
      ftcih.fee_ci_sequence_number = p_fee_ci_sequence_number AND
      ftcih.hist_start_dt  >= p_hist_end_dt   AND
      decode (p_column_name,
      cst_start_dt_alias,  ftcih.start_dt_alias,
      cst_start_dai_sequence_number, ftcih.start_dai_sequence_number,
      cst_end_dt_alias,  ftcih.end_dt_alias,
      cst_end_dai_sequence_number, ftcih.end_dai_sequence_number,
      cst_retro_dt_alias,  ftcih.retro_dt_alias,
      cst_retro_dai_sequence_number, ftcih.retro_dai_sequence_number,
      cst_s_chg_method_type,  ftcih.s_chg_method_type,
      cst_rul_sequence_number, ftcih.rul_sequence_number) IS NOT NULL
    ORDER BY ftcih.hist_start_dt;
    v_column_value  VARCHAR2(2000) := NULL;
  BEGIN
    OPEN c_ftcih;
    FETCH c_ftcih INTO v_column_value;
    CLOSE c_ftcih;
    RETURN v_column_value;
    EXCEPTION
      WHEN OTHERS THEN
        IF (c_ftcih%isopen) THEN
          CLOSE c_ftcih;
        END IF;
      RAISE;
    END;
  END audp_get_ftcih_col;

END igs_au_gen_002;

/
