--------------------------------------------------------
--  DDL for Package Body IGF_AP_LI_ISIR_IMP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LI_ISIR_IMP_PROC" AS
  /* $Header: IGFAP34B.pls 120.7 2006/04/18 05:41:05 hkodali ship $ */

  CURSOR c_int_data (p_batch_id NUMBER)
        IS
        SELECT
              a.rowid              row_id,
              a.person_number,
              a.batch_year_num,
              a.transaction_num_txt,
              a.ssn_name_change_type,
              a.original_ssn_txt,
              a.orig_name_id_txt,
              a.current_ssn_txt,
              a.last_name,
              a.first_name,
              a.middle_initial_txt,
              a.perm_mail_address_txt,
              a.perm_city_txt,
              a.perm_state_txt,
              a.perm_zip_cd,
              a.birth_date,
              a.phone_number_txt,
              a.driver_license_number_txt,
              a.driver_license_state_txt,
              a.citizenship_status_type,
              a.alien_reg_number_txt,
              a.s_marital_status_type,
              a.s_marital_status_date,
              a.summ_enrl_status_type,
              a.fall_enrl_status_type,
              a.winter_enrl_status_type,
              a.spring_enrl_status_type,
              a.summ2_enrl_status_type,
              a.fathers_highest_edu_level_type,
              a.mothers_highest_edu_level_type,
              a.s_state_legal_residence,
              a.legal_res_before_year_flag,
              a.s_legal_resd_date,
              a.ss_r_u_male_flag,
              a.selective_service_reg_flag,
              a.degree_certification_type,
              a.grade_level_in_college_type,
              a.high_school_diploma_ged_flag,
              a.first_bachelor_deg_year_flag,
              a.interest_in_loan_flag,
              a.interest_in_stu_employmnt_flag,
              a.drug_offence_conviction_type,
              a.s_tax_return_status_type,
              a.s_type_tax_return_type,
              a.s_elig_1040ez_type,
              a.s_adjusted_gross_income_amt,
              a.s_fed_taxes_paid_amt,
              a.s_exemptions_amt,
              a.s_income_from_work_amt,
              a.spouse_income_from_work_amt,
              a.s_total_from_wsa_amt,
              a.s_total_from_wsb_amt,
              a.s_total_from_wsc_amt,
              a.s_investment_networth_amt,
              a.s_busi_farm_networth_amt,
              a.s_cash_savings_amt,
              a.va_months_num,
              a.va_amt,
              a.stud_dob_before_year_flag,
              a.deg_beyond_bachelor_flag,
              a.s_married_flag,
              a.s_have_children_flag,
              a.legal_dependents_flag,
              a.orphan_ward_of_court_flag,
              a.s_veteran_flag,
              a.p_marital_status_type,
              a.father_ssn_txt,
              a.f_last_name,
              a.mother_ssn_txt,
              a.m_last_name,
              a.p_family_members_num,
              a.p_in_college_num,
              a.p_state_legal_residence_txt,
              a.p_legal_res_before_dt_flag,
              a.p_legal_res_date,
              a.age_older_parent_num,
              a.p_tax_return_status_type,
              a.p_type_tax_return_type,
              a.p_elig_1040aez_type,
              a.p_adjusted_gross_income_amt,
              a.p_taxes_paid_amt,
              a.p_exemptions_amt,
              a.f_income_work_amt,
              a.m_income_work_amt,
              a.p_income_wsa_amt,
              a.p_income_wsb_amt,
              a.p_income_wsc_amt,
              a.p_investment_networth_amt,
              a.p_business_networth_amt,
              a.p_cash_saving_amt,
              a.s_family_members_num,
              a.s_in_college_num,
              a.first_college_cd,
              a.first_house_plan_type,
              a.second_college_cd,
              a.second_house_plan_type,
              a.third_college_cd,
              a.third_house_plan_type,
              a.fourth_college_cd,
              a.fourth_house_plan_type,
              a.fifth_college_cd,
              a.fifth_house_plan_type,
              a.sixth_college_cd,
              a.sixth_house_plan_type,
              a.app_completed_date,
              a.signed_by_type,
              a.preparer_ssn_txt,
              a.preparer_emp_id_number_txt,
              a.preparer_sign_flag,
              a.transaction_receipt_date,
              a.dependency_override_type,
              a.faa_fedral_schl_cd,
              a.faa_adjustment_type,
              a.input_record_type,
              a.serial_num,
              a.batch_number_txt,
              a.early_analysis_flag,
              a.app_entry_source_type,
              a.eti_destination_cd,
              a.reject_override_b_flag,
              a.reject_override_n_flag,
              a.reject_override_w_flag,
              a.assum_override_1_flag,
              a.assum_override_2_flag,
              a.assum_override_3_flag,
              a.assum_override_4_flag,
              a.assum_override_5_flag,
              a.assum_override_6_flag,
              a.dependency_status_type,
              a.s_email_address_txt,
              a.nslds_reason_cd,
              a.app_receipt_date,
              a.processed_rec_type,
              a.hist_corr_for_tran_num,
              a.sys_generated_indicator_type,
              a.dup_request_indicator_type,
              a.source_of_correction_type,
              a.p_cal_tax_status_type,
              a.s_cal_tax_status_type,
              a.graduate_flag,
              a.auto_zero_efc_flag,
              a.efc_change_flag,
              a.sarc_flag,
              a.simplified_need_test_flag,
              a.reject_reason_codes_txt,
              a.select_service_match_type,
              a.select_service_reg_type,
              a.ins_match_flag,
              a.ins_verification_num,
              a.sec_ins_match_type,
              a.sec_ins_ver_num,
              a.ssn_match_type,
              a.ssa_citizenship_type,
              a.ssn_death_date,
              a.nslds_match_type,
              a.va_match_type,
              a.prisoner_match_flag,
              a.verification_flag,
              a.subsequent_app_flag,
              a.app_source_site_cd,
              a.tran_source_site_cd,
              a.drn_num,
              a.tran_process_date,
              a.correction_flags_txt,
              a.computer_batch_num,
              a.highlight_flags_txt,
              a.paid_efc_amt,
              a.primary_efc_amt,
              a.secondary_efc_amt,
              a.fed_pell_grant_efc_type,
              a.primary_efc_type,
              a.sec_efc_type,
              a.primary_alt_month_1_amt,
              a.primary_alt_month_2_amt,
              a.primary_alt_month_3_amt,
              a.primary_alt_month_4_amt,
              a.primary_alt_month_5_amt,
              a.primary_alt_month_6_amt,
              a.primary_alt_month_7_amt,
              a.primary_alt_month_8_amt,
              a.primary_alt_month_10_amt,
              a.primary_alt_month_11_amt,
              a.primary_alt_month_12_amt,
              a.sec_alternate_month_1_amt,
              a.sec_alternate_month_2_amt,
              a.sec_alternate_month_3_amt,
              a.sec_alternate_month_4_amt,
              a.sec_alternate_month_5_amt,
              a.sec_alternate_month_6_amt,
              a.sec_alternate_month_7_amt,
              a.sec_alternate_month_8_amt,
              a.sec_alternate_month_10_amt,
              a.sec_alternate_month_11_amt,
              a.sec_alternate_month_12_amt,
              a.total_income_amt,
              a.allow_total_income_amt,
              a.state_tax_allow_amt,
              a.employment_allow_amt,
              a.income_protection_allow_amt,
              a.available_income_amt,
              a.contribution_from_ai_amt,
              a.discretionary_networth_amt,
              a.efc_networth_amt,
              a.asset_protect_allow_amt,
              a.parents_cont_from_assets_amt,
              a.adjusted_available_income_amt,
              a.total_student_contribution_amt,
              a.total_parent_contribution_amt,
              a.parents_contribution_amt,
              a.student_total_income_amt,
              a.sati_amt,
              a.sic_amt,
              a.sdnw_amt,
              a.sca_amt,
              a.fti_amt,
              a.secti_amt,
              a.secati_amt,
              a.secstx_amt,
              a.secea_amt,
              a.secipa_amt,
              a.secai_amt,
              a.seccai_amt,
              a.secdnw_amt,
              a.secnw_amt,
              a.secapa_amt,
              a.secpca_amt,
              a.secaai_amt,
              a.sectsc_amt,
              a.sectpc_amt,
              a.secpc_amt,
              a.secsti_amt,
              a.secsati_amt,
              a.secsic_amt,
              a.secsdnw_amt,
              a.secsca_amt,
              a.secfti_amt,
              a.a_citizenship_flag,
              a.a_student_marital_status_flag,
              a.a_student_agi_amt,
              a.a_s_us_tax_paid_amt,
              a.a_s_income_work_amt,
              a.a_spouse_income_work_amt,
              a.a_s_total_wsc_amt,
              a.a_date_of_birth_flag,
              a.a_student_married_flag,
              a.a_have_children_flag,
              a.a_s_have_dependents_flag,
              a.a_va_status_flag,
              a.a_s_in_family_num,
              a.a_s_in_college_num,
              a.a_p_marital_status_flag,
              a.a_father_ssn_txt,
              a.a_mother_ssn_txt,
              a.a_parents_family_num,
              a.a_parents_college_num,
              a.a_parents_agi_amt,
              a.a_p_us_tax_paid_amt,
              a.a_f_work_income_amt,
              a.a_m_work_income_amt,
              a.a_p_total_wsc_amt,
              a.comment_codes_txt,
              a.sar_ack_comm_codes_txt,
              a.pell_grant_elig_flag,
              a.reprocess_reason_cd,
              a.duplicate_date,
              a.isir_transaction_type,
              a.fedral_schl_type,
              a.multi_school_cd_flags_txt,
              a.dup_ssn_indicator_flag,
              a.nslds_transaction_num,
              a.nslds_database_results_type,
              a.nslds_flag,
              a.nslds_pell_overpay_type,
              a.nslds_pell_overpay_contact_txt,
              a.nslds_seog_overpay_type,
              a.nslds_seog_overpay_contact_txt,
              a.nslds_perkins_overpay_type,
              a.nslds_perkins_ovrpay_cntct_txt,
              a.nslds_defaulted_loan_flag,
              a.nslds_discharged_loan_type,
              a.nslds_satis_repay_flag,
              a.nslds_act_bankruptcy_flag,
              a.nslds_agg_subsz_out_pbal_amt,
              a.nslds_agg_unsbz_out_pbal_amt,
              a.nslds_agg_comb_out_pbal_amt,
              a.nslds_agg_cons_out_pbal_amt,
              a.nslds_agg_subsz_pend_disb_amt,
              a.nslds_agg_unsbz_pend_disb_amt,
              a.nslds_agg_comb_pend_disb_amt,
              a.nslds_agg_subsz_total_amt,
              a.nslds_agg_unsbz_total_amt,
              a.nslds_agg_comb_total_amt,
              a.nslds_agg_consd_total_amt,
              a.nslds_perkins_out_bal_amt,
              a.nslds_perkins_cur_yr_disb_amt,
              a.nslds_default_loan_chng_flag,
              a.nslds_dischged_loan_chng_flag,
              a.nslds_satis_repay_chng_flag,
              a.nslds_act_bnkrupt_chng_flag,
              a.nslds_overpay_chng_flag,
              a.nslds_agg_loan_chng_flag,
              a.nslds_perkins_loan_chng_flag,
              a.nslds_pell_paymnt_chng_flag,
              a.nslds_addtnl_pell_flag,
              a.nslds_addtnl_loan_flag,
              a.direct_loan_mas_prom_nt_type,
              a.nslds_pell_1_seq_num,
              a.nslds_pell_1_verify_f_txt,
              a.nslds_pell_1_efc_amt,
              a.nslds_pell_1_school_num,
              a.nslds_pell_1_transcn_num,
              a.nslds_pell_1_last_updt_date,
              a.nslds_pell_1_scheduled_amt,
              a.nslds_pell_1_paid_todt_amt,
              a.nslds_pell_1_remng_amt,
              a.nslds_pell_1_pc_schawd_use_amt,
              a.nslds_pell_1_award_amt,
              a.nslds_pell_2_seq_num,
              a.nslds_pell_2_verify_f_txt,
              a.nslds_pell_2_efc_amt,
              a.nslds_pell_2_school_num,
              a.nslds_pell_2_transcn_num,
              a.nslds_pell_2_last_updt_date,
              a.nslds_pell_2_scheduled_amt,
              a.nslds_pell_2_paid_todt_amt,
              a.nslds_pell_2_remng_amt,
              a.nslds_pell_2_pc_schawd_use_amt,
              a.nslds_pell_2_award_amt,
              a.nslds_pell_3_seq_num,
              a.nslds_pell_3_verify_f_txt,
              a.nslds_pell_3_efc_amt,
              a.nslds_pell_3_school_num,
              a.nslds_pell_3_transcn_num,
              a.nslds_pell_3_last_updt_date,
              a.nslds_pell_3_scheduled_amt,
              a.nslds_pell_3_paid_todt_amt,
              a.nslds_pell_3_remng_amt,
              a.nslds_pell_3_pc_schawd_use_amt,
              a.nslds_pell_3_award_amt,
              a.nslds_loan_1_seq_num,
              a.nslds_loan_1_type,
              a.nslds_loan_1_chng_flag,
              a.nslds_loan_1_prog_cd,
              a.nslds_loan_1_net_amt,
              a.nslds_loan_1_cur_st_cd,
              a.nslds_loan_1_cur_st_date,
              a.nslds_loan_1_agg_pr_bal_amt,
              a.nslds_loan_1_out_pr_bal_date,
              a.nslds_loan_1_begin_date,
              a.nslds_loan_1_end_date,
              a.nslds_loan_1_ga_cd,
              a.nslds_loan_1_cont_type,
              a.nslds_loan_1_schol_cd,
              a.nslds_loan_1_cont_cd,
              a.nslds_loan_1_grade_lvl_txt,
              a.nslds_loan_1_xtr_unsbz_ln_type,
              a.nslds_loan_1_capital_int_flag,
              a.nslds_loan_2_seq_num,
              a.nslds_loan_2_type,
              a.nslds_loan_2_chng_flag,
              a.nslds_loan_2_prog_cd,
              a.nslds_loan_2_net_amt,
              a.nslds_loan_2_cur_st_cd,
              a.nslds_loan_2_cur_st_date,
              a.nslds_loan_2_agg_pr_bal_amt,
              a.nslds_loan_2_out_pr_bal_date,
              a.nslds_loan_2_begin_date,
              a.nslds_loan_2_end_date,
              a.nslds_loan_2_ga_cd,
              a.nslds_loan_2_cont_type,
              a.nslds_loan_2_schol_cd,
              a.nslds_loan_2_cont_cd,
              a.nslds_loan_2_grade_lvl_txt,
              a.nslds_loan_2_xtr_unsbz_ln_type,
              a.nslds_loan_2_capital_int_flag,
              a.nslds_loan_3_seq_num,
              a.nslds_loan_3_type,
              a.nslds_loan_3_chng_flag,
              a.nslds_loan_3_prog_cd,
              a.nslds_loan_3_net_amt,
              a.nslds_loan_3_cur_st_cd,
              a.nslds_loan_3_cur_st_date,
              a.nslds_loan_3_agg_pr_bal_amt,
              a.nslds_loan_3_out_pr_bal_date,
              a.nslds_loan_3_begin_date,
              a.nslds_loan_3_end_date,
              a.nslds_loan_3_ga_cd,
              a.nslds_loan_3_cont_type,
              a.nslds_loan_3_schol_cd,
              a.nslds_loan_3_cont_cd,
              a.nslds_loan_3_grade_lvl_txt,
              a.nslds_loan_3_xtr_unsbz_ln_type,
              a.nslds_loan_3_capital_int_flag,
              a.nslds_loan_4_seq_num,
              a.nslds_loan_4_type,
              a.nslds_loan_4_chng_flag,
              a.nslds_loan_4_prog_cd,
              a.nslds_loan_4_net_amt,
              a.nslds_loan_4_cur_st_cd,
              a.nslds_loan_4_cur_st_date,
              a.nslds_loan_4_agg_pr_bal_amt,
              a.nslds_loan_4_out_pr_bal_date,
              a.nslds_loan_4_begin_date,
              a.nslds_loan_4_end_date,
              a.nslds_loan_4_ga_cd,
              a.nslds_loan_4_cont_type,
              a.nslds_loan_4_schol_cd,
              a.nslds_loan_4_cont_cd,
              a.nslds_loan_4_grade_lvl_txt,
              a.nslds_loan_4_xtr_unsbz_ln_type,
              a.nslds_loan_4_capital_int_flag,
              a.nslds_loan_5_seq_num,
              a.nslds_loan_5_type,
              a.nslds_loan_5_chng_flag,
              a.nslds_loan_5_prog_cd,
              a.nslds_loan_5_net_amt,
              a.nslds_loan_5_cur_st_cd,
              a.nslds_loan_5_cur_st_date,
              a.nslds_loan_5_agg_pr_bal_amt,
              a.nslds_loan_5_out_pr_bal_date,
              a.nslds_loan_5_begin_date,
              a.nslds_loan_5_end_date,
              a.nslds_loan_5_ga_cd,
              a.nslds_loan_5_cont_type,
              a.nslds_loan_5_schol_cd,
              a.nslds_loan_5_cont_cd,
              a.nslds_loan_5_grade_lvl_txt,
              a.nslds_loan_5_xtr_unsbz_ln_type,
              a.nslds_loan_5_capital_int_flag,
              a.nslds_loan_6_seq_num,
              a.nslds_loan_6_type,
              a.nslds_loan_6_chng_flag,
              a.nslds_loan_6_prog_cd,
              a.nslds_loan_6_net_amt,
              a.nslds_loan_6_cur_st_cd,
              a.nslds_loan_6_cur_st_date,
              a.nslds_loan_6_agg_pr_bal_amt,
              a.nslds_loan_6_out_pr_bal_date,
              a.nslds_loan_6_begin_date,
              a.nslds_loan_6_end_date,
              a.nslds_loan_6_ga_cd,
              a.nslds_loan_6_cont_type,
              a.nslds_loan_6_schol_cd,
              a.nslds_loan_6_cont_cd,
              a.nslds_loan_6_grade_lvl_txt,
              a.nslds_loan_6_xtr_unsbz_ln_type,
              a.nslds_loan_6_capital_int_flag,
              a.request_id,
              a.program_application_id,
              a.program_id,
              a.program_update_date,
              a.nslds_loan_1_last_disb_amt,
              a.nslds_loan_1_last_disb_date,
              a.nslds_loan_2_last_disb_amt,
              a.nslds_loan_2_last_disb_date,
              a.nslds_loan_3_last_disb_amt,
              a.nslds_loan_3_last_disb_date,
              a.nslds_loan_4_last_disb_amt,
              a.nslds_loan_4_last_disb_date,
              a.nslds_loan_5_last_disb_amt,
              a.nslds_loan_5_last_disb_date,
              a.nslds_loan_6_last_disb_amt,
              a.nslds_loan_6_last_disb_date,
              a.verif_track_type,
              a.fafsa_data_verification_txt,
              a.reject_override_a_flag,
              a.reject_override_c_flag,
              a.parent_marital_status_date,
              a.dlp_master_prom_note_type,
              NVL(a.import_record_type,'I')   import_record_type,
              a.father_first_name_initial_txt,
              a.father_step_father_birth_date,
              a.mother_first_name_initial_txt,
              a.mother_step_mother_birth_date,
              a.parents_email_address_txt,
              a.address_change_type,
              a.cps_pushed_isir_flag,
              a.electronic_transaction_type,
              a.sar_c_change_type,
              a.father_ssn_match_type,
              a.mother_ssn_match_type,
              a.subsidized_loan_limit_type,
              a.combined_loan_limit_type,
              a.reject_override_g_flag,
              a.dhs_verification_num_txt,
              'IDAP05OP.dat' data_file_name_txt,
              'IDAP05OP' message_class_txt,
              reject_override_3_flag,
              reject_override_12_flag,
              reject_override_j_flag,
              reject_override_k_flag,
              rejected_status_change_flag,
              verification_selection_flag
        FROM
              igf_ap_li_isir_ints a
        WHERE
              a.batch_num = p_batch_id  AND
              a.import_status_type IN ('U','R')
        ORDER BY  a.person_number;

        c_int_data_rec       c_int_data%ROWTYPE;

  CURSOR c_cps_int_data(p_batch_year  VARCHAR2 )
        IS
        SELECT rowid row_id, a.*
        FROM
             igf_ap_isir_ints_all a
        WHERE
             a.record_status = 'LEGACY' AND
             a.batch_year_num = p_batch_year
        ORDER BY  a.original_ssn_txt;

  l_cps_int_data_rec   c_cps_int_data%rowtype;
  l_blank              VARCHAR2(30) := '       ' ;
  l_debug_str          VARCHAR2(4000) := NULL;
  l_error              igf_lookups_view.meaning%TYPE ;
  l_cps_log            VARCHAR2(1) ;
  g_import_type        VARCHAR2(1);
  g_sys_award_year     igf_ap_batch_aw_map.sys_award_year%TYPE ;

  FUNCTION convert_negative_char( pv_charnum IN VARCHAR2)
  RETURN NUMBER
  IS
    /*
    ||  Created By : brajendr
    ||  Created On : 24-NOV-2000
    ||  Purpose :        Process which converts the Alphaneumeric signed number to equavalent numeric signed number.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */
      ln_Amount         NUMBER;
      lv_Signed_Char    VARCHAR2(1);
      lv_Number         VARCHAR2(10);
      lv_Signed_Value   VARCHAR2(1);

  BEGIN

      -- Select the last character which is used to denote a signed number
      IF pv_charnum IS NULL THEN
           RETURN NULL;
      END IF;

      lv_signed_char := SUBSTR( pv_charnum, LENGTH( pv_charnum), 1);

      IF lv_signed_char NOT IN ( '{','}','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R')        THEN
           RETURN NULL ;
      END IF;

      -- Select the number part from the amount field
      lv_number := SUBSTR( pv_charnum, 1,LENGTH( pv_charnum)-1);

      -- Get the value of        the signed character
      -- The mapping is '{' => +0,  'A' =>+1 to 'I' => +9        and '}'        => -0,        'J'=> -1 so on to 'R' => -9
      SELECT DECODE( lv_signed_char, '{','0','A','1', 'B','2', 'C','3', 'D','4', 'E','5',        'F','6',
                                     'G','7', 'H','8', 'I','9', 'J','1', 'K','2',
                                     'L','3', 'M','4', 'N','5', 'O','6', 'P','7',        'Q','8', 'R','9', '}','0' )
      INTO   lv_signed_value
      FROM   dual;

      -- Get the amount by concatanating number and signed value
      ln_Amount := TO_NUMBER( lv_number||lv_signed_value);

      -- add the signed value
      IF lv_signed_char IN ( '}','J','K','L','M','N','O','P','Q','R') THEN
            ln_Amount := ln_Amount*(-1);
      END IF;

      RETURN ln_Amount;

  EXCEPTION

      WHEN others THEN
       RETURN NULL;

  END convert_negative_char;


PROCEDURE p_convert_rec
  IS

   l_field_debug NUMBER;
  BEGIN

   l_field_debug := 0 ;
   l_field_debug := l_field_debug + 1 ;

              c_int_data_rec.row_id                                               := l_cps_int_data_rec.row_id;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.person_number                                        := NULL;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.batch_year_num                                       := l_cps_int_data_rec.batch_year_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.transaction_num_txt                                  := l_cps_int_data_rec.transaction_num_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ssn_name_change_type                                 := l_cps_int_data_rec.ssn_name_change_type  ;
             l_field_debug := l_field_debug + 1 ;
             c_int_data_rec.original_ssn_txt                                     := l_cps_int_data_rec.original_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.orig_name_id_txt                                     := l_cps_int_data_rec.orig_name_id_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.current_ssn_txt                                      := l_cps_int_data_rec.current_ssn_txt;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.last_name                                            := l_cps_int_data_rec.last_name ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.first_name                                           := l_cps_int_data_rec.first_name ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.middle_initial_txt                                   := l_cps_int_data_rec.middle_initial_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.perm_mail_address_txt                                := l_cps_int_data_rec.perm_mail_address_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.perm_city_txt                                        := l_cps_int_data_rec.perm_city_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.perm_state_txt                                       := l_cps_int_data_rec.perm_state_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.perm_zip_cd                                          := l_cps_int_data_rec.perm_zip_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.birth_date                                           := l_cps_int_data_rec.birth_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.phone_number_txt                                     := l_cps_int_data_rec.phone_number_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.driver_license_number_txt                            := l_cps_int_data_rec.driver_license_number_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.driver_license_state_txt                             := l_cps_int_data_rec.driver_license_state_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.citizenship_status_type                              := l_cps_int_data_rec.citizenship_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.alien_reg_number_txt                                 := l_cps_int_data_rec.alien_reg_number_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_marital_status_type                                := l_cps_int_data_rec.s_marital_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_marital_status_date                                := l_cps_int_data_rec.s_marital_status_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.summ_enrl_status_type                                := l_cps_int_data_rec.summ_enrl_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fall_enrl_status_type                                := l_cps_int_data_rec.fall_enrl_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.winter_enrl_status_type                              := l_cps_int_data_rec.winter_enrl_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.spring_enrl_status_type                              := l_cps_int_data_rec.spring_enrl_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.summ2_enrl_status_type                               := l_cps_int_data_rec.summ2_enrl_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fathers_highest_edu_level_type                       := l_cps_int_data_rec.fathers_highst_edu_lvl_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.mothers_highest_edu_level_type                       := l_cps_int_data_rec.mothers_highst_edu_lvl_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_state_legal_residence                              := l_cps_int_data_rec.s_state_legal_residence ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.legal_res_before_year_flag                           := l_cps_int_data_rec.legal_res_before_year_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_legal_resd_date                                    := l_cps_int_data_rec.s_legal_resd_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ss_r_u_male_flag                                     := l_cps_int_data_rec.ss_r_u_male_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.selective_service_reg_flag                           := l_cps_int_data_rec.selective_service_reg_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.degree_certification_type                            := l_cps_int_data_rec.degree_certification_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.grade_level_in_college_type                          := l_cps_int_data_rec.grade_level_in_college_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.high_school_diploma_ged_flag                         := l_cps_int_data_rec.high_schl_diploma_ged_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.first_bachelor_deg_year_flag                         := l_cps_int_data_rec.first_bachlr_deg_year_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.interest_in_loan_flag                                := l_cps_int_data_rec.interest_in_loan_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.interest_in_stu_employmnt_flag                       := l_cps_int_data_rec.interest_in_stu_employ_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.drug_offence_conviction_type                         := l_cps_int_data_rec.drug_offence_convict_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_tax_return_status_type                             := l_cps_int_data_rec.s_tax_return_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_type_tax_return_type                               := l_cps_int_data_rec.s_type_tax_return_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_elig_1040ez_type                                   := l_cps_int_data_rec.s_elig_1040ez_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_adjusted_gross_income_amt                          := convert_negative_char( l_cps_int_data_rec.s_adjusted_gross_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_fed_taxes_paid_amt                                 := l_cps_int_data_rec.s_fed_taxes_paid_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_exemptions_amt                                     := l_cps_int_data_rec.s_exemptions_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_income_from_work_amt                               := convert_negative_char( l_cps_int_data_rec.s_income_from_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.spouse_income_from_work_amt                          := convert_negative_char( l_cps_int_data_rec.spouse_income_from_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_total_from_wsa_amt                                 := l_cps_int_data_rec.s_total_from_wsa_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_total_from_wsb_amt                                 := l_cps_int_data_rec.s_total_from_wsb_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_total_from_wsc_amt                                 := l_cps_int_data_rec.s_total_from_wsc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_investment_networth_amt                            := l_cps_int_data_rec.s_investment_networth_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_busi_farm_networth_amt                             := l_cps_int_data_rec.s_busi_farm_networth_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_cash_savings_amt                                   := l_cps_int_data_rec.s_cash_savings_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.va_months_num                                        := l_cps_int_data_rec.va_months_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.va_amt                                               := l_cps_int_data_rec.va_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.stud_dob_before_year_flag                            := l_cps_int_data_rec.stud_dob_before_year_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.deg_beyond_bachelor_flag                             := l_cps_int_data_rec.deg_beyond_bachelor_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_married_flag                                       := l_cps_int_data_rec.s_married_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_have_children_flag                                 := l_cps_int_data_rec.s_have_children_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.legal_dependents_flag                                := l_cps_int_data_rec.legal_dependents_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.orphan_ward_of_court_flag                            := l_cps_int_data_rec.orphan_ward_of_court_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_veteran_flag                                       := l_cps_int_data_rec.s_veteran_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_marital_status_type                                := l_cps_int_data_rec.p_marital_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.father_ssn_txt                                       := l_cps_int_data_rec.father_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.f_last_name                                          := l_cps_int_data_rec.f_last_name ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.mother_ssn_txt                                       := l_cps_int_data_rec.mother_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.m_last_name                                          := l_cps_int_data_rec.m_last_name ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_family_members_num                                 := l_cps_int_data_rec.p_family_members_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_in_college_num                                     := l_cps_int_data_rec.p_in_college_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_state_legal_residence_txt                          := l_cps_int_data_rec.p_state_legal_residence_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_legal_res_before_dt_flag                           := l_cps_int_data_rec.p_legal_res_before_dt_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_legal_res_date                                     := l_cps_int_data_rec.p_legal_res_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.age_older_parent_num                                 := l_cps_int_data_rec.age_older_parent_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_tax_return_status_type                             := l_cps_int_data_rec.p_tax_return_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_type_tax_return_type                               := l_cps_int_data_rec.p_type_tax_return_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_elig_1040aez_type                                  := l_cps_int_data_rec.p_elig_1040aez_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_adjusted_gross_income_amt                          := convert_negative_char( l_cps_int_data_rec.p_adjusted_gross_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_taxes_paid_amt                                     := l_cps_int_data_rec.p_taxes_paid_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_exemptions_amt                                     := l_cps_int_data_rec.p_exemptions_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.f_income_work_amt                                    := convert_negative_char( l_cps_int_data_rec.f_income_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.m_income_work_amt                                    := convert_negative_char( l_cps_int_data_rec.m_income_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_income_wsa_amt                                     := l_cps_int_data_rec.p_income_wsa_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_income_wsb_amt                                     := l_cps_int_data_rec.p_income_wsb_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_income_wsc_amt                                     := l_cps_int_data_rec.p_income_wsc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_investment_networth_amt                            := l_cps_int_data_rec.p_investment_networth_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_business_networth_amt                              := l_cps_int_data_rec.p_business_networth_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_cash_saving_amt                                    := l_cps_int_data_rec.p_cash_saving_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_family_members_num                                 := l_cps_int_data_rec.s_family_members_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_in_college_num                                     := l_cps_int_data_rec.s_in_college_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.first_college_cd                                     := l_cps_int_data_rec.first_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.first_house_plan_type                                := l_cps_int_data_rec.first_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.second_college_cd                                    := l_cps_int_data_rec.second_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.second_house_plan_type                               := l_cps_int_data_rec.second_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.third_college_cd                                     := l_cps_int_data_rec.third_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.third_house_plan_type                                := l_cps_int_data_rec.third_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fourth_college_cd                                    := l_cps_int_data_rec.fourth_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fourth_house_plan_type                               := l_cps_int_data_rec.fourth_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fifth_college_cd                                     := l_cps_int_data_rec.fifth_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fifth_house_plan_type                                := l_cps_int_data_rec.fifth_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sixth_college_cd                                     := l_cps_int_data_rec.sixth_college_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sixth_house_plan_type                                := l_cps_int_data_rec.sixth_house_plan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.app_completed_date                                   := l_cps_int_data_rec.app_completed_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.signed_by_type                                       := l_cps_int_data_rec.signed_by_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.preparer_ssn_txt                                     := l_cps_int_data_rec.preparer_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.preparer_emp_id_number_txt                           := l_cps_int_data_rec.preparer_emp_id_number_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.preparer_sign_flag                                   := l_cps_int_data_rec.preparer_sign_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.transaction_receipt_date                             := l_cps_int_data_rec.transaction_receipt_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.dependency_override_type                             := l_cps_int_data_rec.dependency_override_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.faa_fedral_schl_cd                                   := l_cps_int_data_rec.faa_fedral_schl_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.faa_adjustment_type                                  := l_cps_int_data_rec.faa_adjustment_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.input_record_type                                    := l_cps_int_data_rec.input_record_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.serial_num                                           := l_cps_int_data_rec.serial_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.batch_number_txt                                     := l_cps_int_data_rec.batch_number_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.early_analysis_flag                                  := l_cps_int_data_rec.early_analysis_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.app_entry_source_type                                := l_cps_int_data_rec.app_entry_source_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.eti_destination_cd                                   := l_cps_int_data_rec.eti_destination_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_b_flag                               := l_cps_int_data_rec.reject_override_b_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_n_flag                               := l_cps_int_data_rec.reject_override_n_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_w_flag                               := l_cps_int_data_rec.reject_override_w_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_1_flag                                := l_cps_int_data_rec.assum_override_1_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_2_flag                                := l_cps_int_data_rec.assum_override_2_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_3_flag                                := l_cps_int_data_rec.assum_override_3_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_4_flag                                := l_cps_int_data_rec.assum_override_4_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_5_flag                                := l_cps_int_data_rec.assum_override_5_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.assum_override_6_flag                                := l_cps_int_data_rec.assum_override_6_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.dependency_status_type                               := l_cps_int_data_rec.dependency_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_email_address_txt                                  := l_cps_int_data_rec.s_email_address_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_reason_cd                                      := l_cps_int_data_rec.nslds_reason_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.app_receipt_date                                     := l_cps_int_data_rec.app_receipt_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.processed_rec_type                                   := l_cps_int_data_rec.processed_rec_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.hist_corr_for_tran_num                               := l_cps_int_data_rec.hist_corr_for_tran_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sys_generated_indicator_type                         := l_cps_int_data_rec.sys_generated_indicator_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.dup_request_indicator_type                           := l_cps_int_data_rec.dup_request_indicator_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.source_of_correction_type                            := l_cps_int_data_rec.source_of_correction_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.p_cal_tax_status_type                                := l_cps_int_data_rec.p_cal_tax_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.s_cal_tax_status_type                                := l_cps_int_data_rec.s_cal_tax_status_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.graduate_flag                                        := l_cps_int_data_rec.graduate_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.auto_zero_efc_flag                                   := l_cps_int_data_rec.auto_zero_efc_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.efc_change_flag                                      := l_cps_int_data_rec.efc_change_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sarc_flag                                            := l_cps_int_data_rec.sarc_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.simplified_need_test_flag                            := l_cps_int_data_rec.simplified_need_test_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_reason_codes_txt                              := l_cps_int_data_rec.reject_reason_codes_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.select_service_match_type                            := l_cps_int_data_rec.select_service_match_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.select_service_reg_type                              := l_cps_int_data_rec.select_service_reg_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ins_match_flag                                       := l_cps_int_data_rec.ins_match_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ins_verification_num                                 := l_cps_int_data_rec.ins_verification_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_ins_match_type                                   := l_cps_int_data_rec.sec_ins_match_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_ins_ver_num                                      := l_cps_int_data_rec.sec_ins_ver_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ssn_match_type                                       := l_cps_int_data_rec.ssn_match_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ssa_citizenship_type                                 := l_cps_int_data_rec.ssa_citizenship_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.ssn_death_date                                       := l_cps_int_data_rec.ssn_death_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_match_type                                     := l_cps_int_data_rec.nslds_match_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.va_match_type                                        := l_cps_int_data_rec.va_match_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.prisoner_match_flag                                  := l_cps_int_data_rec.prisoner_match_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.verification_flag                                    := l_cps_int_data_rec.verification_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.subsequent_app_flag                                  := l_cps_int_data_rec.subsequent_app_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.app_source_site_cd                                   := l_cps_int_data_rec.app_source_site_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.tran_source_site_cd                                  := l_cps_int_data_rec.tran_source_site_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.drn_num                                              := l_cps_int_data_rec.drn_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.tran_process_date                                    := l_cps_int_data_rec.tran_process_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.correction_flags_txt                                 := l_cps_int_data_rec.correction_flags_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.computer_batch_num                                   := l_cps_int_data_rec.computer_batch_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.highlight_flags_txt                                  := l_cps_int_data_rec.highlight_flags_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.paid_efc_amt                                         := l_cps_int_data_rec.paid_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_efc_amt                                      := l_cps_int_data_rec.primary_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secondary_efc_amt                                    := l_cps_int_data_rec.secondary_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fed_pell_grant_efc_type                              := l_cps_int_data_rec.fed_pell_grant_efc_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_efc_type                                     := l_cps_int_data_rec.primary_efc_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_efc_type                                         := l_cps_int_data_rec.sec_efc_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_1_amt                              := l_cps_int_data_rec.primary_alt_month_1_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_2_amt                              := l_cps_int_data_rec.primary_alt_month_2_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_3_amt                              := l_cps_int_data_rec.primary_alt_month_3_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_4_amt                              := l_cps_int_data_rec.primary_alt_month_4_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_5_amt                              := l_cps_int_data_rec.primary_alt_month_5_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_6_amt                              := l_cps_int_data_rec.primary_alt_month_6_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_7_amt                              := l_cps_int_data_rec.primary_alt_month_7_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_8_amt                              := l_cps_int_data_rec.primary_alt_month_8_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_10_amt                             := l_cps_int_data_rec.primary_alt_month_10_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_11_amt                             := l_cps_int_data_rec.primary_alt_month_11_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.primary_alt_month_12_amt                             := l_cps_int_data_rec.primary_alt_month_12_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_1_amt                            := l_cps_int_data_rec.sec_alternate_month_1_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_2_amt                            := l_cps_int_data_rec.sec_alternate_month_2_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_3_amt                            := l_cps_int_data_rec.sec_alternate_month_3_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_4_amt                            := l_cps_int_data_rec.sec_alternate_month_4_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_5_amt                            := l_cps_int_data_rec.sec_alternate_month_5_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_6_amt                            := l_cps_int_data_rec.sec_alternate_month_6_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_7_amt                            := l_cps_int_data_rec.sec_alternate_month_7_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_8_amt                            := l_cps_int_data_rec.sec_alternate_month_8_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_10_amt                           := l_cps_int_data_rec.sec_alternate_month_10_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_11_amt                           := l_cps_int_data_rec.sec_alternate_month_11_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sec_alternate_month_12_amt                           := l_cps_int_data_rec.sec_alternate_month_12_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.total_income_amt                                     := convert_negative_char( l_cps_int_data_rec.total_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.allow_total_income_amt                               := l_cps_int_data_rec.allow_total_income_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.state_tax_allow_amt                                  := convert_negative_char( l_cps_int_data_rec.state_tax_allow_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.employment_allow_amt                                 := l_cps_int_data_rec.employment_allow_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.income_protection_allow_amt                          := l_cps_int_data_rec.income_protection_allow_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.available_income_amt                                 := convert_negative_char( l_cps_int_data_rec.available_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.contribution_from_ai_amt                             := convert_negative_char( l_cps_int_data_rec.contribution_from_ai_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.discretionary_networth_amt                           := convert_negative_char( l_cps_int_data_rec.discretionary_networth_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.efc_networth_amt                                     := l_cps_int_data_rec.efc_networth_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.asset_protect_allow_amt                              := l_cps_int_data_rec.asset_protect_allow_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.parents_cont_from_assets_amt                         := convert_negative_char( l_cps_int_data_rec.parents_cont_from_assets_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.adjusted_available_income_amt                        := convert_negative_char( l_cps_int_data_rec.adjusted_avail_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.total_student_contribution_amt                       := l_cps_int_data_rec.total_student_contrib_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.total_parent_contribution_amt                        := l_cps_int_data_rec.total_parent_contrib_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.parents_contribution_amt                             := l_cps_int_data_rec.parents_contribution_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.student_total_income_amt                             := convert_negative_char( l_cps_int_data_rec.student_total_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sati_amt                                             := convert_negative_char( l_cps_int_data_rec.sati_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sic_amt                                              := l_cps_int_data_rec.sic_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sdnw_amt                                             := convert_negative_char( l_cps_int_data_rec.sdnw_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sca_amt                                              := convert_negative_char( l_cps_int_data_rec.sca_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fti_amt                                              := convert_negative_char( l_cps_int_data_rec.fti_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secti_amt                                            := convert_negative_char( l_cps_int_data_rec.secti_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secati_amt                                           := l_cps_int_data_rec.secati_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secstx_amt                                           := convert_negative_char( l_cps_int_data_rec.secstx_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secea_amt                                            := l_cps_int_data_rec.secea_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secipa_amt                                           := l_cps_int_data_rec.secipa_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secai_amt                                            := convert_negative_char( l_cps_int_data_rec.secai_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.seccai_amt                                           := convert_negative_char( l_cps_int_data_rec.seccai_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secdnw_amt                                           := convert_negative_char( l_cps_int_data_rec.secdnw_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secnw_amt                                            := l_cps_int_data_rec.secnw_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secapa_amt                                           := l_cps_int_data_rec.secapa_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secpca_amt                                           := convert_negative_char( l_cps_int_data_rec.secpca_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secaai_amt                                           := convert_negative_char( l_cps_int_data_rec.secaai_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sectsc_amt                                           := l_cps_int_data_rec.sectsc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sectpc_amt                                           := l_cps_int_data_rec.sectpc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secpc_amt                                            := l_cps_int_data_rec.secpc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secsti_amt                                           := convert_negative_char( l_cps_int_data_rec.secsti_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secsati_amt                                          := l_cps_int_data_rec.secsati_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secsic_amt                                           := convert_negative_char( l_cps_int_data_rec.secsic_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secsdnw_amt                                          := convert_negative_char( l_cps_int_data_rec.secsdnw_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secsca_amt                                           := convert_negative_char( l_cps_int_data_rec.secsca_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.secfti_amt                                           := convert_negative_char( l_cps_int_data_rec.secfti_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_citizenship_flag                                   := l_cps_int_data_rec.a_citizenship_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_student_marital_status_flag                        := l_cps_int_data_rec.a_studnt_marital_status_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_student_agi_amt                                    := convert_negative_char( l_cps_int_data_rec.a_student_agi_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_us_tax_paid_amt                                  := l_cps_int_data_rec.a_s_us_tax_paid_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_income_work_amt                                  := convert_negative_char( l_cps_int_data_rec.a_s_income_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_spouse_income_work_amt                             := convert_negative_char( l_cps_int_data_rec.a_spouse_income_work_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_total_wsc_amt                                    := l_cps_int_data_rec.a_s_total_wsc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_date_of_birth_flag                                 := l_cps_int_data_rec.a_date_of_birth_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_student_married_flag                               := l_cps_int_data_rec.a_student_married_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_have_children_flag                                 := l_cps_int_data_rec.a_have_children_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_have_dependents_flag                             := l_cps_int_data_rec.a_s_have_dependents_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_va_status_flag                                     := l_cps_int_data_rec.a_va_status_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_in_family_num                                    := l_cps_int_data_rec.a_s_in_family_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_s_in_college_num                                   := l_cps_int_data_rec.a_s_in_college_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_p_marital_status_flag                              := l_cps_int_data_rec.a_p_marital_status_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_father_ssn_txt                                     := l_cps_int_data_rec.a_father_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_mother_ssn_txt                                     := l_cps_int_data_rec.a_mother_ssn_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_parents_family_num                                 := l_cps_int_data_rec.a_parents_family_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_parents_college_num                                := l_cps_int_data_rec.a_parents_college_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_parents_agi_amt                                    := convert_negative_char( l_cps_int_data_rec.a_parents_agi_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_p_us_tax_paid_amt                                  := l_cps_int_data_rec.a_p_us_tax_paid_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_f_work_income_amt                                  := convert_negative_char( l_cps_int_data_rec.a_f_work_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_m_work_income_amt                                  := convert_negative_char( l_cps_int_data_rec.a_m_work_income_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.a_p_total_wsc_amt                                    := l_cps_int_data_rec.a_p_total_wsc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.comment_codes_txt                                    := l_cps_int_data_rec.comment_codes_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sar_ack_comm_codes_txt                               := l_cps_int_data_rec.sar_ack_comm_codes_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.pell_grant_elig_flag                                 := l_cps_int_data_rec.pell_grant_elig_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reprocess_reason_cd                                  := l_cps_int_data_rec.reprocess_reason_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.duplicate_date                                       := l_cps_int_data_rec.duplicate_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.isir_transaction_type                                := l_cps_int_data_rec.isir_transaction_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fedral_schl_type                                     := l_cps_int_data_rec.fedral_schl_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.multi_school_cd_flags_txt                            := l_cps_int_data_rec.multi_school_cd_flags_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.dup_ssn_indicator_flag                               := l_cps_int_data_rec.dup_ssn_indicator_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_transaction_num                                := l_cps_int_data_rec.nslds_transaction_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_database_results_type                          := l_cps_int_data_rec.nslds_database_results_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_flag                                           := l_cps_int_data_rec.nslds_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_overpay_type                              := l_cps_int_data_rec.NSLDS_PELL_OVERPAY_TYPE ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_overpay_contact_txt                       := l_cps_int_data_rec.nslds_pell_overpay_cont_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_seog_overpay_type                              := l_cps_int_data_rec.nslds_seog_overpay_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_seog_overpay_contact_txt                       := l_cps_int_data_rec.nslds_seog_overpay_cont_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_perkins_overpay_type                           := l_cps_int_data_rec.nslds_perkins_overpay_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_perkins_ovrpay_cntct_txt                       := l_cps_int_data_rec.NSLDS_PERK_OVRPAY_CNTCT_TXT ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_defaulted_loan_flag                            := l_cps_int_data_rec.nslds_defaulted_loan_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_discharged_loan_type                           := l_cps_int_data_rec.nslds_discharged_loan_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_satis_repay_flag                               := l_cps_int_data_rec.nslds_satis_repay_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_act_bankruptcy_flag                            := l_cps_int_data_rec.nslds_act_bankruptcy_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_subsz_out_pbal_amt                         := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_subsz_out_pbal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_unsbz_out_pbal_amt                         := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_unsbz_out_pbal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_comb_out_pbal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_comb_out_pbal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_cons_out_pbal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_cons_out_pbal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_subsz_pend_disb_amt                        := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.NSLDS_AGG_SUBSZ_PND_DISB_AMT) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_unsbz_pend_disb_amt                        := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.NSLDS_AGG_UNSBZ_PND_DISB_AMT) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_comb_pend_disb_amt                         := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_comb_pend_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_subsz_total_amt                            := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_subsz_total_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_unsbz_total_amt                            := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_unsbz_total_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_comb_total_amt                             := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_comb_total_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_consd_total_amt                            := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_agg_consd_total_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_perkins_out_bal_amt                            := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_perkins_out_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_perkins_cur_yr_disb_amt                        := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_perkin_cur_yr_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_default_loan_chng_flag                         := l_cps_int_data_rec.nslds_default_loan_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_dischged_loan_chng_flag                        := l_cps_int_data_rec.nslds_dischgd_loan_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_satis_repay_chng_flag                          := l_cps_int_data_rec.nslds_satis_repay_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_act_bnkrupt_chng_flag                          := l_cps_int_data_rec.nslds_act_bnkrupt_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_overpay_chng_flag                              := l_cps_int_data_rec.nslds_overpay_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_agg_loan_chng_flag                             := l_cps_int_data_rec.nslds_agg_loan_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_perkins_loan_chng_flag                         := l_cps_int_data_rec.nslds_perkins_loan_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_paymnt_chng_flag                          := l_cps_int_data_rec.nslds_pell_paymnt_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_addtnl_pell_flag                               := l_cps_int_data_rec.nslds_addtnl_pell_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_addtnl_loan_flag                               := l_cps_int_data_rec.nslds_addtnl_loan_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.direct_loan_mas_prom_nt_type                         := l_cps_int_data_rec.direct_loan_mas_prom_nt_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_seq_num                                 := l_cps_int_data_rec.nslds_pell_1_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_verify_f_txt                            := l_cps_int_data_rec.nslds_pell_1_verify_f_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_efc_amt                                 := l_cps_int_data_rec.nslds_pell_1_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_school_num                              := l_cps_int_data_rec.nslds_pell_1_school_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_transcn_num                             := l_cps_int_data_rec.nslds_pell_1_transcn_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_last_updt_date                          := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_pell_1_last_updt_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_scheduled_amt                           := l_cps_int_data_rec.nslds_pell_1_scheduled_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_paid_todt_amt                           := l_cps_int_data_rec.nslds_pell_1_paid_todt_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_remng_amt                               := l_cps_int_data_rec.nslds_pell_1_remng_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_pc_schawd_use_amt                       := l_cps_int_data_rec.nslds_pell_1_pc_scwd_use_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_1_award_amt                               := l_cps_int_data_rec.nslds_pell_1_award_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_seq_num                                 := l_cps_int_data_rec.nslds_pell_2_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_verify_f_txt                            := l_cps_int_data_rec.nslds_pell_2_verify_f_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_efc_amt                                 := l_cps_int_data_rec.nslds_pell_2_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_school_num                              := l_cps_int_data_rec.nslds_pell_2_school_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_transcn_num                             := l_cps_int_data_rec.nslds_pell_2_transcn_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_last_updt_date                          := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_pell_2_last_updt_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_scheduled_amt                           := l_cps_int_data_rec.nslds_pell_2_scheduled_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_paid_todt_amt                           := l_cps_int_data_rec.nslds_pell_2_paid_todt_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_remng_amt                               := l_cps_int_data_rec.nslds_pell_2_remng_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_pc_schawd_use_amt                       := l_cps_int_data_rec.NSLDS_PELL_2_PC_SCWD_USE_AMT ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_2_award_amt                               := l_cps_int_data_rec.nslds_pell_2_award_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_seq_num                                 := l_cps_int_data_rec.nslds_pell_3_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_verify_f_txt                            := l_cps_int_data_rec.nslds_pell_3_verify_f_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_efc_amt                                 := l_cps_int_data_rec.nslds_pell_3_efc_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_school_num                              := l_cps_int_data_rec.nslds_pell_3_school_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_transcn_num                             := l_cps_int_data_rec.nslds_pell_3_transcn_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_last_updt_date                          := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_pell_3_last_updt_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_scheduled_amt                           := l_cps_int_data_rec.nslds_pell_3_scheduled_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_paid_todt_amt                           := l_cps_int_data_rec.nslds_pell_3_paid_todt_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_remng_amt                               := l_cps_int_data_rec.nslds_pell_3_remng_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_pc_schawd_use_amt                       := l_cps_int_data_rec.NSLDS_PELL_3_PC_SCWD_USE_AMT ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_pell_3_award_amt                               := l_cps_int_data_rec.nslds_pell_3_award_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_seq_num                                 := l_cps_int_data_rec.nslds_loan_1_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_type                                    := l_cps_int_data_rec.nslds_loan_1_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_chng_flag                               := l_cps_int_data_rec.nslds_loan_1_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_prog_cd                                 := l_cps_int_data_rec.nslds_loan_1_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_net_amt                                 := l_cps_int_data_rec.nslds_loan_1_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_1_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_1_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_1_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_1_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_1_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_1_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_ga_cd                                   := l_cps_int_data_rec.nslds_loan_1_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_cont_type                               := l_cps_int_data_rec.nslds_loan_1_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_schol_cd                                := l_cps_int_data_rec.nslds_loan_1_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_cont_cd                                 := l_cps_int_data_rec.nslds_loan_1_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_1_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_xtr_unsbz_ln_type                       := l_cps_int_data_rec.NSLDS_LOAN_1_X_UNSBZ_LN_TYPE  ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_capital_int_flag                        := l_cps_int_data_rec.NSLDS_LOAN_1_CAPTAL_INT_FLAG  ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_seq_num                                 := l_cps_int_data_rec.nslds_loan_2_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_type                                    := l_cps_int_data_rec.nslds_loan_2_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_chng_flag                               := l_cps_int_data_rec.nslds_loan_2_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_prog_cd                                 := l_cps_int_data_rec.nslds_loan_2_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_net_amt                                 := l_cps_int_data_rec.nslds_loan_2_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_2_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_2_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_2_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_2_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_2_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_2_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_ga_cd                                   := l_cps_int_data_rec.nslds_loan_2_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_cont_type                               := l_cps_int_data_rec.nslds_loan_2_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_schol_cd                                := l_cps_int_data_rec.nslds_loan_2_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_cont_cd                                 := l_cps_int_data_rec.nslds_loan_2_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_2_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_xtr_unsbz_ln_type                       := l_cps_int_data_rec.NSLDS_LOAN_2_X_UNSBZ_LN_TYPE ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_capital_int_flag                        := l_cps_int_data_rec.nslds_loan_2_captal_int_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_seq_num                                 := l_cps_int_data_rec.nslds_loan_3_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_type                                    := l_cps_int_data_rec.nslds_loan_3_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_chng_flag                               := l_cps_int_data_rec.nslds_loan_3_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_prog_cd                                 := l_cps_int_data_rec.nslds_loan_3_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_net_amt                                 := l_cps_int_data_rec.nslds_loan_3_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_3_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_3_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_3_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_3_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_3_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_3_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_ga_cd                                   := l_cps_int_data_rec.nslds_loan_3_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_cont_type                               := l_cps_int_data_rec.nslds_loan_3_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_schol_cd                                := l_cps_int_data_rec.nslds_loan_3_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_cont_cd                                 := l_cps_int_data_rec.nslds_loan_3_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_3_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_xtr_unsbz_ln_type                       := l_cps_int_data_rec.nslds_loan_3_x_unsbz_ln_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_capital_int_flag                        := l_cps_int_data_rec.nslds_loan_3_captal_int_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_seq_num                                 := l_cps_int_data_rec.nslds_loan_4_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_type                                    := l_cps_int_data_rec.nslds_loan_4_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_chng_flag                               := l_cps_int_data_rec.nslds_loan_4_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_prog_cd                                 := l_cps_int_data_rec.nslds_loan_4_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_net_amt                                 := l_cps_int_data_rec.nslds_loan_4_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_4_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_4_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_4_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_4_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_4_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_4_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_ga_cd                                   := l_cps_int_data_rec.nslds_loan_4_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_cont_type                               := l_cps_int_data_rec.nslds_loan_4_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_schol_cd                                := l_cps_int_data_rec.nslds_loan_4_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_cont_cd                                 := l_cps_int_data_rec.nslds_loan_4_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_4_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_xtr_unsbz_ln_type                       := l_cps_int_data_rec.nslds_loan_4_x_unsbz_ln_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_capital_int_flag                        := l_cps_int_data_rec.nslds_loan_4_captal_int_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_seq_num                                 := l_cps_int_data_rec.nslds_loan_5_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_type                                    := l_cps_int_data_rec.nslds_loan_5_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_chng_flag                               := l_cps_int_data_rec.nslds_loan_5_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_prog_cd                                 := l_cps_int_data_rec.nslds_loan_5_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_net_amt                                 := l_cps_int_data_rec.nslds_loan_5_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_5_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_5_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_5_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_5_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_5_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_5_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_ga_cd                                   := l_cps_int_data_rec.nslds_loan_5_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_cont_type                               := l_cps_int_data_rec.nslds_loan_5_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_schol_cd                                := l_cps_int_data_rec.nslds_loan_5_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_cont_cd                                 := l_cps_int_data_rec.nslds_loan_5_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_5_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_xtr_unsbz_ln_type                       := l_cps_int_data_rec.nslds_loan_5_x_unsbz_ln_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_capital_int_flag                        := l_cps_int_data_rec.nslds_loan_5_captal_int_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_seq_num                                 := l_cps_int_data_rec.nslds_loan_6_seq_num ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_type                                    := l_cps_int_data_rec.nslds_loan_6_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_chng_flag                               := l_cps_int_data_rec.nslds_loan_6_chng_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_prog_cd                                 := l_cps_int_data_rec.nslds_loan_6_prog_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_net_amt                                 := l_cps_int_data_rec.nslds_loan_6_net_amt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_cur_st_cd                               := l_cps_int_data_rec.nslds_loan_6_cur_st_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_cur_st_date                             := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_6_cur_st_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_agg_pr_bal_amt                          := igf_ap_matching_process_pkg.convert_to_number( l_cps_int_data_rec.nslds_loan_6_agg_pr_bal_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_out_pr_bal_date                         := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_6_out_pr_bal_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_begin_date                              := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_6_begin_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_end_date                                := igf_ap_matching_process_pkg.convert_to_date( l_cps_int_data_rec.nslds_loan_6_end_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_ga_cd                                   := l_cps_int_data_rec.nslds_loan_6_ga_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_cont_type                               := l_cps_int_data_rec.nslds_loan_6_cont_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_schol_cd                                := l_cps_int_data_rec.nslds_loan_6_schol_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_cont_cd                                 := l_cps_int_data_rec.nslds_loan_6_cont_cd ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_grade_lvl_txt                           := l_cps_int_data_rec.nslds_loan_6_grade_lvl_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_xtr_unsbz_ln_type                       := l_cps_int_data_rec.nslds_loan_6_x_unsbz_ln_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_capital_int_flag                        := l_cps_int_data_rec.nslds_loan_6_captal_int_flag ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_1_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_1_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_1_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_2_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_2_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_2_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_3_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_3_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_3_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_4_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_4_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_4_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_5_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_5_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_5_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_last_disb_amt                           := igf_ap_matching_process_pkg.convert_to_number(l_cps_int_data_rec.nslds_loan_6_last_disb_amt) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.nslds_loan_6_last_disb_date                          := igf_ap_matching_process_pkg.convert_to_date(l_cps_int_data_rec.nslds_loan_6_last_disb_date) ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.import_record_type                                   := 'I' ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.fafsa_data_verification_txt                          := l_cps_int_data_rec.fafsa_data_verification_txt;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_a_flag                               := l_cps_int_data_rec.reject_override_a_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_c_flag                               := l_cps_int_data_rec.reject_override_c_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.parent_marital_status_date                           := l_cps_int_data_rec.parent_marital_status_date;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.father_first_name_initial_txt                        := l_cps_int_data_rec.fathr_first_name_initial_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.father_step_father_birth_date                        := l_cps_int_data_rec.fathr_step_father_birth_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.mother_first_name_initial_txt                        := l_cps_int_data_rec.mothr_first_name_initial_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.mother_step_mother_birth_date                        := l_cps_int_data_rec.mothr_step_mother_birth_date ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.parents_email_address_txt                            := l_cps_int_data_rec.parents_email_address_txt ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.address_change_type                                  := l_cps_int_data_rec.address_change_type       ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.cps_pushed_isir_flag                                 := l_cps_int_data_rec.cps_pushed_isir_flag          ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.electronic_transaction_type                          := l_cps_int_data_rec.electronic_transaction_type ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.sar_c_change_type                                    := l_cps_int_data_rec.sar_c_change_type         ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.father_ssn_match_type                                := l_cps_int_data_rec.father_ssn_match_type         ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.mother_ssn_match_type                                := l_cps_int_data_rec.mother_ssn_match_type         ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.subsidized_loan_limit_type                           := l_cps_int_data_rec.subsidized_loan_limit_type  ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.combined_loan_limit_type                             := l_cps_int_data_rec.combined_loan_limit_type  ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_g_flag                               := l_cps_int_data_rec.reject_override_g_flag  ;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.dhs_verification_num_txt                             := l_cps_int_data_rec.dhs_verification_num_txt;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_3_flag                               := l_cps_int_data_rec.reject_override_3_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_12_flag                              := l_cps_int_data_rec.reject_override_12_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_j_flag                               := l_cps_int_data_rec.reject_override_j_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.reject_override_k_flag                               := l_cps_int_data_rec.reject_override_k_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.rejected_status_change_flag                          := l_cps_int_data_rec.rejected_status_change_flag;
              l_field_debug := l_field_debug + 1 ;
              c_int_data_rec.verification_selection_flag                          := l_cps_int_data_rec.verification_selection_flag;
              l_field_debug := l_field_debug + 1 ;

  EXCEPTION WHEN OTHERS THEN

    l_debug_str := l_debug_str || ' Error while Swapping fields in p_convert_rec - Value of l_field_debug >' || TO_CHAR(l_field_debug) || ' ' ;
    RETURN ;

  END p_convert_rec;


  FUNCTION p_l_to_i_col( p_in_col_name IN VARCHAR2)
  RETURN VARCHAR2
  /***************************************************************
     Created By :       rasahoo
     Date Created By  : 03-June-2003
     Purpose    : Returns col name to print based on type of import being run
     Known Limitations,Enhancements or Remarks
     Change History :
     Who      When    What
   ***************************************************************/
  IS
    p_out_col_name VARCHAR2(200);

    BEGIN

    IF l_cps_log = 'N' THEN

      RETURN p_in_col_name ;

    END IF;

    IF p_in_col_name = 'ORIGINAL_SSN_NUM' THEN
       p_out_col_name := 'ORIGINAL_SSN_TXT' ;
    ELSIF p_in_col_name = 'CURRENT_SSN_NUM' THEN
       p_out_col_name := 'CURRENT_SSN_TXT' ;
    ELSIF p_in_col_name = 'FATHERS_HIGHEST_EDU_LEVEL_TYPE' THEN
       p_out_col_name := 'FATHERS_HIGHST_EDU_LVL_TYPE' ;
    ELSIF p_in_col_name = 'MOTHERS_HIGHEST_EDU_LEVEL_TYPE' THEN
       p_out_col_name := 'MOTHERS_HIGHST_EDU_LVL_TYPE' ;
    ELSIF p_in_col_name = 'HIGH_SCHOOL_DIPLOMA_GED_FLAG' THEN
       p_out_col_name := 'HIGH_SCHL_DIPLOMA_GED_FLAG' ;
    ELSIF p_in_col_name = 'FIRST_BACHELOR_DEG_YEAR_FLAG' THEN
       p_out_col_name := 'FIRST_BACHLR_DEG_YEAR_FLAG' ;
    ELSIF p_in_col_name = 'INTEREST_IN_STU_EMPLOYMNT_FLAG' THEN
       p_out_col_name := 'INTEREST_IN_STU_EMPLOY_FLAG' ;
    ELSIF p_in_col_name = 'DRUG_OFFENCE_CONVICTION_TYPE' THEN
       p_out_col_name := 'DRUG_OFFENCE_CONVICT_TYPE' ;
    ELSIF p_in_col_name = 'ADJUSTED_AVAILABLE_INCOME_AMT' THEN
       p_out_col_name := 'ADJUSTED_AVAIL_INCOME_AMT' ;
    ELSIF p_in_col_name = 'TOTAL_STUDENT_CONTRIBUTION_AMT' THEN
       p_out_col_name := 'TOTAL_STUDENT_CONTRIB_AMT' ;
    ELSIF p_in_col_name = 'TOTAL_PARENT_CONTRIBUTION_AMT' THEN
       p_out_col_name := 'TOTAL_PARENT_CONTRIB_AMT' ;
    ELSIF p_in_col_name = 'A_STUDENT_MARITAL_STATUS_FLAG' THEN
       p_out_col_name := 'A_STUDNT_MARITAL_STATUS_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_PELL_OVERPAY_CONTACT_TXT' THEN
       p_out_col_name := 'NSLDS_PELL_OVERPAY_CONT_TXT' ;
    ELSIF p_in_col_name = 'NSLDS_SEOG_OVERPAY_CONTACT_TXT' THEN
       p_out_col_name := 'NSLDS_SEOG_OVERPAY_CONT_TXT' ;
    ELSIF p_in_col_name = 'NSLDS_PERKINS_OVRPAY_CNTCT_TXT' THEN
       p_out_col_name := 'NSLDS_PERK_OVRPAY_CNTCT_TXT' ;
    ELSIF p_in_col_name = 'NSLDS_AGG_SUBSZ_PEND_DISB_AMT' THEN
       p_out_col_name := 'NSLDS_AGG_SUBSZ_PND_DISB_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_AGG_UNSBZ_PEND_DISB_AMT' THEN
       p_out_col_name := 'NSLDS_AGG_UNSBZ_PND_DISB_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_PERKINS_CUR_YR_DISB_AMT' THEN
       p_out_col_name := 'NSLDS_PERKIN_CUR_YR_DISB_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_DISCHGED_LOAN_CHNG_FLAG' THEN
       p_out_col_name := 'NSLDS_DISCHGD_LOAN_CHNG_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_PELL_1_PC_SCHAWD_USE_AMT' THEN
       p_out_col_name := 'NSLDS_PELL_1_PC_SCWD_USE_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_PELL_2_PC_SCHAWD_USE_AMT' THEN
       p_out_col_name := 'NSLDS_PELL_2_PC_SCWD_USE_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_PELL_3_PC_SCHAWD_USE_AMT' THEN
       p_out_col_name := 'NSLDS_PELL_3_PC_SCWD_USE_AMT' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_1_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_1_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_1_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_1_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_2_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_2_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_2_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_2_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_3_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_3_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_3_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_3_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_4_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_4_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_4_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_4_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_5_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_5_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_5_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_5_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_6_XTR_UNSBZ_LN_TYPE' THEN
       p_out_col_name := 'NSLDS_LOAN_6_X_UNSBZ_LN_TYPE' ;
    ELSIF p_in_col_name = 'NSLDS_LOAN_6_CAPITAL_INT_FLAG' THEN
       p_out_col_name := 'NSLDS_LOAN_6_CAPTAL_INT_FLAG' ;
    ELSIF p_in_col_name = 'FATHER_FIRST_NAME_INITIAL_TXT' THEN
       p_out_col_name := 'FATHR_FIRST_NAME_INITIAL_TXT';
    ELSIF p_in_col_name = 'FATHER_STEP_FATHER_BIRTH_DATE' THEN
       p_out_col_name := 'FATHR_STEP_FATHER_BIRTH_DATE';
    ELSIF p_in_col_name = 'MOTHER_FIRST_NAME_INITIAL_TXT' THEN
       p_out_col_name := 'MOTHR_FIRST_NAME_INITIAL_TXT';
    ELSIF p_in_col_name = 'MOTHER_STEP_MOTHER_BIRTH_DATE' THEN
       p_out_col_name := 'MOTHR_STEP_MOTHER_BIRTH_DATE' ;
    ELSE
       p_out_col_name := p_in_col_name;
    END IF;

    RETURN p_out_col_name ;
  END p_l_to_i_col;


PROCEDURE log_input_params( p_batch_num         IN  igf_aw_li_coa_ints.batch_num%TYPE,
                            p_alternate_code    IN  igs_ca_inst.alternate_code%TYPE,
                            p_delete_flag       IN  VARCHAR2,
                            p_import_type       IN  VARCHAR2)  IS
/*
||  Created By : masehgal
||  Created On : 28-May-2003
||  Purpose    : Logs all the Input Parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- cursor to get batch desc for the batch id from igf_ap_li_bat_ints
  CURSOR c_batch_desc(cp_batch_num     igf_aw_li_coa_ints.batch_num%TYPE ) IS
     SELECT batch_desc, batch_type
       FROM igf_ap_li_bat_ints
      WHERE batch_num = cp_batch_num ;

  -- cursor for getting the message from fnd_new_messages
  CURSOR c_get_message(cp_message_name VARCHAR2) IS
     SELECT message_text
       FROM fnd_new_messages
      WHERE message_name = cp_message_name;

  l_delete_flag_prmpt fnd_new_messages.message_text%TYPE;

  l_lkup_type            VARCHAR2(60) ;
  l_lkup_code            VARCHAR2(60) ;
  l_batch_desc           igf_ap_li_bat_ints.batch_desc%TYPE ;
  l_batch_type           igf_ap_li_bat_ints.batch_type%TYPE ;
  l_batch_id             igf_ap_li_bat_ints.batch_type%TYPE ;
  l_yes_no               igf_lookups_view.meaning%TYPE ;
  l_award_year_pmpt      igf_lookups_view.meaning%TYPE ;
  l_params_pass_prmpt    igf_lookups_view.meaning%TYPE ;
  l_person_number_prmpt  igf_lookups_view.meaning%TYPE ;
  l_batch_num_prmpt      igf_lookups_view.meaning%TYPE ;

  BEGIN -- begin log parameters

     -- get the batch description
     OPEN  c_batch_desc( p_batch_num) ;
     FETCH c_batch_desc INTO l_batch_desc, l_batch_type ;
     CLOSE c_batch_desc ;

    OPEN  c_get_message('IGS_GE_ASK_DEL_REC');
    FETCH c_get_message INTO l_delete_flag_prmpt;
    CLOSE c_get_message;

    l_error               := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_person_number_prmpt := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_num_prmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_year_pmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no              := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag);
    l_params_pass_prmpt   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');

    fnd_file.put_line( fnd_file.log, ' ');
    fnd_file.put_line( fnd_file.log, '-------------------------------------------------------------');
    fnd_file.put_line( fnd_file.log, ' ');

    fnd_file.put_line( fnd_file.log, ' ') ;
    fnd_file.put_line( fnd_file.log, l_params_pass_prmpt) ; --parameters passed
    fnd_file.put_line( fnd_file.log, ' ') ;

    fnd_file.put_line( fnd_file.log, RPAD( l_award_year_pmpt, 40)    || ' : '|| p_alternate_code ) ;
    IF NVL(g_import_type,'N') <> 'Y' THEN
    fnd_file.put_line( fnd_file.log, RPAD( l_batch_num_prmpt, 40)     || ' : '|| p_batch_num || '-' || l_batch_desc ) ;
    END IF;

    fnd_file.put_line( fnd_file.log, RPAD( l_delete_flag_prmpt, 40)   || ' : '|| l_yes_no ) ;
    fnd_file.put_line( fnd_file.log, ' ');
    fnd_file.put_line( fnd_file.log, '-------------------------------------------------------------');
    fnd_file.put_line( fnd_file.log, ' ');

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_input_params ;



  FUNCTION convert_to_number( pv_org_number IN VARCHAR2 )
  RETURN NUMBER
  IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :        Converts the valid number to into the NUMBER format else RETURN NULL.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */
      ld_number NUMBER;
  BEGIN
      ld_number := TO_NUMBER( pv_org_number);
      RETURN ld_number;
  EXCEPTION
      WHEN others THEN
        RETURN NULL;
  END convert_to_number;

  PROCEDURE create_ssn(cp_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                       cp_original_ssn_txt VARCHAR2
                      )
    AS

   /*
    ||  Created By : rajagupt
    ||  Created On : 06-Oct-2005
    ||  Purpose : create SSN record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

   l_rowid ROWID;

  BEGIN
     IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW (
                    X_ROWID => l_rowid,
                    X_PE_PERSON_ID  => cp_person_id,
                    X_API_PERSON_ID => cp_original_ssn_txt,
                    X_PERSON_ID_TYPE  => 'SSN',
                    X_START_DT   => SYSDATE,
                    X_END_DT => NULL,
                    X_ATTRIBUTE_CATEGORY => NULL,
                    X_ATTRIBUTE1         => NULL,
                    X_ATTRIBUTE2         => NULL,
                    X_ATTRIBUTE3         => NULL,
                    X_ATTRIBUTE4         => NULL,
                    X_ATTRIBUTE5         => NULL,
                    X_ATTRIBUTE6         => NULL,
                    X_ATTRIBUTE7         => NULL,
                    X_ATTRIBUTE8         => NULL,
                    X_ATTRIBUTE9         => NULL,
                    X_ATTRIBUTE10        => NULL,
                    X_ATTRIBUTE11        => NULL,
                    X_ATTRIBUTE12        => NULL,
                    X_ATTRIBUTE13        => NULL,
                    X_ATTRIBUTE14        => NULL,
                    X_ATTRIBUTE15        => NULL,
                    X_ATTRIBUTE16        => NULL,
                    X_ATTRIBUTE17        => NULL,
                    X_ATTRIBUTE18        => NULL,
                    X_ATTRIBUTE19        => NULL,
                    X_ATTRIBUTE20        => NULL,
                    X_REGION_CD          => NULL,
                    X_MODE =>  'R'
                   );
  END create_ssn;

  PROCEDURE create_base_rec(p_ci_cal_type         IN VARCHAR2,
                          p_person_id             IN NUMBER,
                          p_ci_sequence_number    IN NUMBER,
                          p_nslds_match_type      IN VARCHAR2,
                          l_fa_base_id            OUT NOCOPY NUMBER,
                          p_award_fmly_contribution_type IN VARCHAR2
                          )
AS
 /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : create FA base record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  museshad       12-Apr-2006      Added the IF condition to call create_ssn()
    ||                                  only if there is a valid SSN. If create_ssn()
    ||                                  is called with SSN as null, it throws ORA-06502
    ||                                  error. Also, this proc gets called from other
    ||                                  packages also, in which case c_int_data_rec.original_ssn_txt
    ||                                  would be null.
    ||  ridas          14-Feb-2006      Bug #5021084. Removed trunc function from
    ||                                  cursor SSN_CUR.
    ||  rajagupt       06-Oct-2005      Bug#4068548 - added a new cursor ssn_cur
    ||  rasahoo        17-NOV-2003      FA 128 - ISIR update 2004-05
    ||                                  added new parameter award_fmly_contribution_type to
    ||                                  igf_ap_fa_base_rec_pkg.insert_row
    */
   -- cursor to get the ssn no of a person
   CURSOR ssn_cur(cp_person_id number) IS
     SELECT api_person_id,api_person_id_uf, end_dt
     FROM   igs_pe_alt_pers_id
     WHERE  pe_person_id=cp_person_id
     AND    person_id_type like 'SSN'
     AND    SYSDATE < = NVL(end_dt,SYSDATE);

       rec_ssn_cur ssn_cur%ROWTYPE;
       l_rowid   VARCHAR2(30);
       l_isir_id NUMBER;
       l_base_id NUMBER;
       lv_profile_value VARCHAR2(20);
 BEGIN
         l_rowid:= NULL;
         l_isir_id := NULL;
         l_base_id := NULL;
   --check if the ssn no is available or not

    fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);

    IF(lv_profile_value = 'Y') THEN
     OPEN ssn_cur(p_person_id) ;
     FETCH ssn_cur INTO rec_ssn_cur;
     IF ssn_cur%NOTFOUND THEN
       CLOSE ssn_cur;

       IF c_int_data_rec.original_ssn_txt IS NOT NULL THEN
        create_ssn(p_person_id, c_int_data_rec.original_ssn_txt);
       END IF;

     ELSE
       CLOSE ssn_cur;

     END IF;

     END IF;

     igf_ap_fa_base_rec_pkg.insert_row(
        x_Mode                                  => 'R',
        x_rowid                                 => l_rowid,
        x_base_id                               => l_base_id,
        x_ci_cal_type                           => p_ci_cal_type,
        x_person_id                             => p_person_id,   --  p_int_data_rec.igs_person_id,
        x_ci_sequence_number                    => p_ci_sequence_number,
        x_org_id                                => NULL,
        x_coa_pending                           => NULL,
        x_verification_process_run              => NULL,
        x_inst_verif_status_date                => NULL,
        x_manual_verif_flag                     => NULL,
        x_fed_verif_status                      => NULL,
        x_fed_verif_status_date                 => NULL,
        x_inst_verif_status                     => NULL,
        x_nslds_eligible                        => p_nslds_match_type,  -- p_int_data_rec.NSLDS_MATCH_TYPE,
        x_ede_correction_batch_id               => NULL,
        x_fa_process_status_date                => TRUNC(SYSDATE),
        x_isir_corr_status                      => NULL,
        x_isir_corr_status_date                 => NULL,
        x_isir_status                           => NULL,
        x_isir_status_date                      => NULL,
        x_coa_code_f                            => NULL,
        x_coa_code_i                            => NULL,
        x_coa_f                                 => NULL,
        x_coa_i                                 => NULL,
        x_disbursement_hold                     => NULL,
        x_fa_process_status                     => 'RECEIVED',
        x_notification_status                   => NULL,
        x_notification_status_date              => NULL,
        x_packaging_status                      => NULL,
        x_packaging_status_date                 => NULL,
        x_total_package_accepted                => NULL,
        x_total_package_offered                 => NULL,
        x_admstruct_id                          => NULL,
        x_admsegment_1                          => NULL,
        x_admsegment_2                          => NULL,
        x_admsegment_3                          => NULL,
        x_admsegment_4                          => NULL,
        x_admsegment_5                          => NULL,
        x_admsegment_6                          => NULL,
        x_admsegment_7                          => NULL,
        x_admsegment_8                          => NULL,
        x_admsegment_9                          => NULL,
        x_admsegment_10                         => NULL,
        x_admsegment_11                         => NULL,
        x_admsegment_12                         => NULL,
        x_admsegment_13                         => NULL,
        x_admsegment_14                         => NULL,
        x_admsegment_15                         => NULL,
        x_admsegment_16                         => NULL,
        x_admsegment_17                         => NULL,
        x_admsegment_18                         => NULL,
        x_admsegment_19                         => NULL,
        x_admsegment_20                         => NULL,
        x_packstruct_id                         => NULL,
        x_packsegment_1                         => NULL,
        x_packsegment_2                         => NULL,
        x_packsegment_3                         => NULL,
        x_packsegment_4                         => NULL,
        x_packsegment_5                         => NULL,
        x_packsegment_6                         => NULL,
        x_packsegment_7                         => NULL,
        x_packsegment_8                         => NULL,
        x_packsegment_9                         => NULL,
        x_packsegment_10                        => NULL,
        x_packsegment_11                        => NULL,
        x_packsegment_12                        => NULL,
        x_packsegment_13                        => NULL,
        x_packsegment_14                        => NULL,
        x_packsegment_15                        => NULL,
        x_packsegment_16                        => NULL,
        x_packsegment_17                        => NULL,
        x_packsegment_18                        => NULL,
        x_packsegment_19                        => NULL,
        x_packsegment_20                        => NULL,
        x_miscstruct_id                         => NULL,
        x_miscsegment_1                         => NULL,
        x_miscsegment_2                         => NULL,
        x_miscsegment_3                         => NULL,
        x_miscsegment_4                         => NULL,
        x_miscsegment_5                         => NULL,
        x_miscsegment_6                         => NULL,
        x_miscsegment_7                         => NULL,
        x_miscsegment_8                         => NULL,
        x_miscsegment_9                         => NULL,
        x_miscsegment_10                        => NULL,
        x_miscsegment_11                        => NULL,
        x_miscsegment_12                        => NULL,
        x_miscsegment_13                        => NULL,
        x_miscsegment_14                        => NULL,
        x_miscsegment_15                        => NULL,
        x_miscsegment_16                        => NULL,
        x_miscsegment_17                        => NULL,
        x_miscsegment_18                        => NULL,
        x_miscsegment_19                        => NULL,
        x_miscsegment_20                        => NULL,
        x_prof_judgement_flg                    => NULL,
        x_nslds_data_override_flg               => NULL,
        x_target_group                          => NULL,
        x_coa_fixed                             => NULL,
         x_coa_pell                              => NULL,
        x_profile_status                        => NULL,
        x_profile_status_date                   => NULL,
        x_profile_fc                            => NULL,
        x_manual_disb_hold                      => NULL,
        x_pell_alt_expense                      => NULL,
        x_assoc_org_num                         => NULL,
        x_award_fmly_contribution_type          => p_award_fmly_contribution_type,
        x_isir_locked_by                        => NULL,
        x_adnl_unsub_loan_elig_flag             => 'N',
        x_lock_awd_flag                         => 'N',
        x_lock_coa_flag                         => 'N'
        );

     l_fa_base_id := l_base_id;
  END create_base_rec;

  PROCEDURE update_row(p_int_data_rec     IN  c_int_data%ROWTYPE,
                       p_base_id          IN  NUMBER,
                       p_rowid            IN  VARCHAR2,
                       p_isir_id          IN  NUMBER
                       ) AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : update the isir matched table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */



  BEGIN


    igf_ap_isir_matched_pkg.update_row(
         x_Mode                         =>  'R',
         x_rowid                        =>  p_rowid,
         x_isir_id                      =>  p_isir_id,
         x_base_id                      =>  p_base_id,
         x_batch_year                   =>  p_int_data_rec.batch_year_num,
         x_transaction_num              =>  p_int_data_rec.transaction_num_txt,
         x_current_ssn                  =>  p_int_data_rec.current_ssn_txt,
         x_ssn_name_change              =>  p_int_data_rec.ssn_name_change_type,
         x_original_ssn                 =>  p_int_data_rec.original_ssn_txt,
         x_orig_name_id                 =>  p_int_data_rec.orig_name_id_txt,
         x_last_name                    =>  p_int_data_rec.last_name,
         x_first_name                   =>  p_int_data_rec.first_name,
         x_middle_initial               =>  p_int_data_rec.middle_initial_txt,
         x_perm_mail_add                =>  p_int_data_rec.perm_mail_address_txt,
         x_perm_city                    =>  p_int_data_rec.perm_city_txt,
         x_perm_state                   =>  p_int_data_rec.perm_state_txt,
         x_perm_zip_code                =>  p_int_data_rec.perm_zip_cd,
         x_date_of_birth                =>  p_int_data_rec.birth_date,
         x_phone_number                 =>  p_int_data_rec.phone_number_txt,
         x_driver_license_number        =>  p_int_data_rec.driver_license_number_txt,
         x_driver_license_state         =>  p_int_data_rec.driver_license_state_txt,
         x_citizenship_status           =>  p_int_data_rec.citizenship_status_type,
         x_alien_reg_number             =>  p_int_data_rec.alien_reg_number_txt,
         x_s_marital_status             =>  p_int_data_rec.s_marital_status_type,
         x_s_marital_status_date        =>  p_int_data_rec.s_marital_status_date,
         x_summ_enrl_status             =>  p_int_data_rec.summ_enrl_status_type,
         x_fall_enrl_status             =>  p_int_data_rec.fall_enrl_status_type,
         x_winter_enrl_status           =>  p_int_data_rec.winter_enrl_status_type,
         x_spring_enrl_status           =>  p_int_data_rec.spring_enrl_status_type,
         x_summ2_enrl_status            =>  p_int_data_rec.summ2_enrl_status_type,
         x_fathers_highest_edu_level    =>  p_int_data_rec.fathers_highest_edu_level_type,
         x_mothers_highest_edu_level    =>  p_int_data_rec.mothers_highest_edu_level_type,
         x_s_state_legal_residence      =>  p_int_data_rec.s_state_legal_residence,
         x_legal_residence_before_date  =>  p_int_data_rec.legal_res_before_year_flag,
         x_s_legal_resd_date            =>  p_int_data_rec.s_legal_resd_date,
         x_ss_r_u_male                  =>  p_int_data_rec.ss_r_u_male_flag,
         x_selective_service_reg        =>  p_int_data_rec.selective_service_reg_flag,
         x_degree_certification         =>  p_int_data_rec.degree_certification_type,
         x_grade_level_in_college       =>  p_int_data_rec.grade_level_in_college_type,
         x_high_school_diploma_ged      =>  p_int_data_rec.high_school_diploma_ged_flag,
         x_first_bachelor_deg_by_date   =>  p_int_data_rec.first_bachelor_deg_year_flag,
         x_interest_in_loan             =>  p_int_data_rec.interest_in_loan_flag,
         x_interest_in_stud_employment  =>  p_int_data_rec.interest_in_stu_employmnt_flag,
         x_drug_offence_conviction      =>  p_int_data_rec.drug_offence_conviction_type,
         x_s_tax_return_status          =>  p_int_data_rec.s_tax_return_status_type,
         x_s_type_tax_return            =>  p_int_data_rec.s_type_tax_return_type,
         x_s_elig_1040ez                =>  p_int_data_rec.s_elig_1040ez_type,
         x_s_adjusted_gross_income      =>  p_int_data_rec.s_adjusted_gross_income_amt,
         x_s_fed_taxes_paid             =>  p_int_data_rec.s_fed_taxes_paid_amt,
         x_s_exemptions                 =>  p_int_data_rec.s_exemptions_amt,
         x_s_income_from_work           =>  p_int_data_rec.s_income_from_work_amt,
         x_spouse_income_from_work      =>  p_int_data_rec.spouse_income_from_work_amt,
         x_s_toa_amt_from_wsa           =>  p_int_data_rec.s_total_from_wsa_amt,
         x_s_toa_amt_from_wsb           =>  p_int_data_rec.s_total_from_wsb_amt,
         x_s_toa_amt_from_wsc           =>  p_int_data_rec.s_total_from_wsc_amt,
         x_s_investment_networth        =>  p_int_data_rec.s_investment_networth_amt,
         x_s_busi_farm_networth         =>  p_int_data_rec.s_busi_farm_networth_amt,
         x_s_cash_savings               =>  p_int_data_rec.s_cash_savings_amt,
         x_va_months                    =>  p_int_data_rec.va_months_num,
         x_va_amount                    =>  p_int_data_rec.va_amt,
         x_stud_dob_before_date         =>  p_int_data_rec.stud_dob_before_year_flag,
         x_deg_beyond_bachelor          =>  p_int_data_rec.deg_beyond_bachelor_flag,
         x_s_married                    =>  p_int_data_rec.s_married_flag,
         x_s_have_children              =>  p_int_data_rec.s_have_children_flag,
         x_legal_dependents             =>  p_int_data_rec.legal_dependents_flag,
         x_orphan_ward_of_court         =>  p_int_data_rec.orphan_ward_of_court_flag,
         x_s_veteran                    =>  p_int_data_rec.s_veteran_flag,
         x_p_marital_status             =>  p_int_data_rec.p_marital_status_type,
         x_father_ssn                   =>  p_int_data_rec.father_ssn_txt,
         x_f_last_name                  =>  p_int_data_rec.f_last_name,
         x_mother_ssn                   =>  p_int_data_rec.mother_ssn_txt,
         x_m_last_name                  =>  p_int_data_rec.m_last_name,
         x_p_num_family_member          =>  p_int_data_rec.p_family_members_num,
         x_p_num_in_college             =>  p_int_data_rec.p_in_college_num,
         x_p_state_legal_residence      =>  p_int_data_rec.p_state_legal_residence_txt,
         x_p_state_legal_res_before_dt  =>  p_int_data_rec.p_legal_res_before_dt_flag,
         x_p_legal_res_date             =>  p_int_data_rec.p_legal_res_date,
         x_age_older_parent             =>  p_int_data_rec.age_older_parent_num,
         x_p_tax_return_status          =>  p_int_data_rec.p_tax_return_status_type,
         x_p_type_tax_return            =>  p_int_data_rec.p_type_tax_return_type,
         x_p_elig_1040aez               =>  p_int_data_rec.p_elig_1040aez_type,
         x_p_adjusted_gross_income      =>  p_int_data_rec.p_adjusted_gross_income_amt,
         x_p_taxes_paid                 =>  p_int_data_rec.p_taxes_paid_amt,
         x_p_exemptions                 =>  p_int_data_rec.p_exemptions_amt,
         x_f_income_work                =>  p_int_data_rec.f_income_work_amt,
         x_m_income_work                =>  p_int_data_rec.m_income_work_amt,
         x_p_income_wsa                 =>  p_int_data_rec.p_income_wsa_amt,
         x_p_income_wsb                 =>  p_int_data_rec.p_income_wsb_amt,
         x_p_income_wsc                 =>  p_int_data_rec.p_income_wsc_amt,
         x_p_investment_networth        =>  p_int_data_rec.p_investment_networth_amt,
         x_p_business_networth          =>  p_int_data_rec.p_business_networth_amt,
         x_p_cash_saving                =>  p_int_data_rec.p_cash_saving_amt,
         x_s_num_family_members         =>  p_int_data_rec.s_family_members_num,
         x_s_num_in_college             =>  p_int_data_rec.s_in_college_num,
         x_first_college                =>  p_int_data_rec.first_college_cd,
         x_first_house_plan             =>  p_int_data_rec.first_house_plan_type,
         x_second_college               =>  p_int_data_rec.second_college_cd,
         x_second_house_plan            =>  p_int_data_rec.second_house_plan_type,
         x_third_college                =>  p_int_data_rec.third_college_cd,
         x_third_house_plan             =>  p_int_data_rec.third_house_plan_type,
         x_fourth_college               =>  p_int_data_rec.fourth_college_cd,
         x_fourth_house_plan            =>  p_int_data_rec.fourth_house_plan_type,
         x_fifth_college                =>  p_int_data_rec.fifth_college_cd,
         x_fifth_house_plan             =>  p_int_data_rec.fifth_house_plan_type,
         x_sixth_college                =>  p_int_data_rec.sixth_college_cd,
         x_sixth_house_plan             =>  p_int_data_rec.sixth_house_plan_type,
         x_date_app_completed           =>  p_int_data_rec.app_completed_date,
         x_signed_by                    =>  p_int_data_rec.signed_by_type,
         x_preparer_ssn                 =>  p_int_data_rec.preparer_ssn_txt,
         x_preparer_emp_id_number       =>  p_int_data_rec.preparer_emp_id_number_txt,
         x_preparer_sign                =>  p_int_data_rec.preparer_sign_flag,
         x_transaction_receipt_date     =>  p_int_data_rec.transaction_receipt_date,
         x_dependency_override_ind      =>  p_int_data_rec.dependency_override_type,
         x_faa_fedral_schl_code         =>  p_int_data_rec.faa_fedral_schl_cd,
         x_faa_adjustment               =>  p_int_data_rec.faa_adjustment_type,
         x_input_record_type            =>  p_int_data_rec.input_record_type,
         x_serial_number                =>  p_int_data_rec.serial_num,
         x_batch_number                 =>  p_int_data_rec.batch_number_txt,
         x_early_analysis_flag          =>  p_int_data_rec.early_analysis_flag,
         x_app_entry_source_code        =>  p_int_data_rec.app_entry_source_type,
         x_eti_destination_code         =>  p_int_data_rec.eti_destination_cd,
         x_reject_override_b            =>  p_int_data_rec.reject_override_b_flag,
         x_reject_override_n            =>  p_int_data_rec.reject_override_n_flag,
         x_reject_override_w            =>  p_int_data_rec.reject_override_w_flag,
         x_assum_override_1             =>  p_int_data_rec.assum_override_1_flag,
         x_assum_override_2             =>  p_int_data_rec.assum_override_2_flag,
         x_assum_override_3             =>  p_int_data_rec.assum_override_3_flag,
         x_assum_override_4             =>  p_int_data_rec.assum_override_4_flag,
         x_assum_override_5             =>  p_int_data_rec.assum_override_5_flag,
         x_assum_override_6             =>  p_int_data_rec.assum_override_6_flag,
         x_dependency_status            =>  p_int_data_rec.dependency_status_type,
         x_s_email_address              =>  p_int_data_rec.s_email_address_txt,
         x_nslds_reason_code            =>  p_int_data_rec.nslds_reason_cd,
         x_app_receipt_date             =>  p_int_data_rec.app_receipt_date,
         x_processed_rec_type           =>  p_int_data_rec.processed_rec_type,
         x_hist_correction_for_tran_id  =>  p_int_data_rec.hist_corr_for_tran_num,
         x_system_generated_indicator   =>  p_int_data_rec.sys_generated_indicator_type,
         x_dup_request_indicator        =>  p_int_data_rec.dup_request_indicator_type,
         x_source_of_correction         =>  p_int_data_rec.source_of_correction_type,
         x_p_cal_tax_status             =>  p_int_data_rec.p_cal_tax_status_type,
         x_s_cal_tax_status             =>  p_int_data_rec.s_cal_tax_status_type,
         x_graduate_flag                =>  p_int_data_rec.graduate_flag,
         x_auto_zero_efc                =>  p_int_data_rec.auto_zero_efc_flag,
         x_efc_change_flag              =>  p_int_data_rec.efc_change_flag,
         x_sarc_flag                    =>  p_int_data_rec.sarc_flag,
         x_simplified_need_test         =>  p_int_data_rec.simplified_need_test_flag,
         x_reject_reason_codes          =>  p_int_data_rec.reject_reason_codes_txt,
         x_select_service_match_flag    =>  p_int_data_rec.select_service_match_type,
         x_select_service_reg_flag      =>  p_int_data_rec.select_service_reg_type,
         x_ins_match_flag               =>  p_int_data_rec.ins_match_flag,
         x_ins_verification_number      =>  NULL,
         x_sec_ins_match_flag           =>  p_int_data_rec.sec_ins_match_type,
         x_sec_ins_ver_number           =>  p_int_data_rec.sec_ins_ver_num,
         x_ssn_match_flag               =>  p_int_data_rec.ssn_match_type,
         x_ssa_citizenship_flag         =>  p_int_data_rec.ssa_citizenship_type,
         x_ssn_date_of_death            =>  p_int_data_rec.ssn_death_date,
         x_nslds_match_flag             =>  p_int_data_rec.nslds_match_type,
         x_va_match_flag                =>  p_int_data_rec.va_match_type,
         x_prisoner_match               =>  p_int_data_rec.prisoner_match_flag,
         x_verification_flag            =>  p_int_data_rec.verification_flag,
         x_subsequent_app_flag          =>  p_int_data_rec.subsequent_app_flag,
         x_app_source_site_code         =>  p_int_data_rec.app_source_site_cd,
         x_tran_source_site_code        =>  p_int_data_rec.tran_source_site_cd,
         x_drn                          =>  p_int_data_rec.drn_num,
         x_tran_process_date            =>  p_int_data_rec.tran_process_date,
         x_computer_batch_number        =>  p_int_data_rec.computer_batch_num,
         x_correction_flags             =>  p_int_data_rec.correction_flags_txt,
         x_highlight_flags              =>  p_int_data_rec.highlight_flags_txt,
         x_paid_efc                     =>  NULL,
         x_primary_efc                  =>  p_int_data_rec.primary_efc_amt,
         x_secondary_efc                =>  p_int_data_rec.secondary_efc_amt,
         x_fed_pell_grant_efc_type      =>  NULL,
         x_primary_efc_type             =>  p_int_data_rec.primary_efc_type,
         x_sec_efc_type                 =>  p_int_data_rec.sec_efc_type,
         x_primary_alternate_month_1    =>  p_int_data_rec.primary_alt_month_1_amt,
         x_primary_alternate_month_2    =>  p_int_data_rec.primary_alt_month_2_amt,
         x_primary_alternate_month_3    =>  p_int_data_rec.primary_alt_month_3_amt,
         x_primary_alternate_month_4    =>  p_int_data_rec.primary_alt_month_4_amt,
         x_primary_alternate_month_5    =>  p_int_data_rec.primary_alt_month_5_amt,
         x_primary_alternate_month_6    =>  p_int_data_rec.primary_alt_month_6_amt,
         x_primary_alternate_month_7    =>  p_int_data_rec.primary_alt_month_7_amt,
         x_primary_alternate_month_8    =>  p_int_data_rec.primary_alt_month_8_amt,
         x_primary_alternate_month_10   =>  p_int_data_rec.primary_alt_month_10_amt,
         x_primary_alternate_month_11   =>  p_int_data_rec.primary_alt_month_11_amt,
         x_primary_alternate_month_12   =>  p_int_data_rec.primary_alt_month_12_amt,
         x_sec_alternate_month_1        =>  p_int_data_rec.sec_alternate_month_1_amt,
         x_sec_alternate_month_2        =>  p_int_data_rec.sec_alternate_month_2_amt,
         x_sec_alternate_month_3        =>  p_int_data_rec.sec_alternate_month_3_amt,
         x_sec_alternate_month_4        =>  p_int_data_rec.sec_alternate_month_4_amt,
         x_sec_alternate_month_5        =>  p_int_data_rec.sec_alternate_month_5_amt,
         x_sec_alternate_month_6        =>  p_int_data_rec.sec_alternate_month_6_amt,
         x_sec_alternate_month_7        =>  p_int_data_rec.sec_alternate_month_7_amt,
         x_sec_alternate_month_8        =>  p_int_data_rec.sec_alternate_month_8_amt,
         x_sec_alternate_month_10       =>  p_int_data_rec.sec_alternate_month_10_amt,
         x_sec_alternate_month_11       =>  p_int_data_rec.sec_alternate_month_11_amt,
         x_sec_alternate_month_12       =>  p_int_data_rec.sec_alternate_month_12_amt,
         x_total_income                 =>  p_int_data_rec.total_income_amt,
         x_allow_total_income           =>  p_int_data_rec.allow_total_income_amt,
         x_state_tax_allow              =>  p_int_data_rec.state_tax_allow_amt,
         x_employment_allow             =>  p_int_data_rec.employment_allow_amt,
         x_income_protection_allow      =>  p_int_data_rec.income_protection_allow_amt,
         x_available_income             =>  p_int_data_rec.available_income_amt,
         x_contribution_from_ai         =>  p_int_data_rec.contribution_from_ai_amt,
         x_discretionary_networth       =>  p_int_data_rec.discretionary_networth_amt,
         x_efc_networth                 =>  p_int_data_rec.efc_networth_amt,
         x_asset_protect_allow          =>  p_int_data_rec.asset_protect_allow_amt,
         x_parents_cont_from_assets     =>  p_int_data_rec.parents_cont_from_assets_amt,
         x_adjusted_available_income    =>  p_int_data_rec.adjusted_available_income_amt,
         x_total_student_contribution   =>  p_int_data_rec.total_student_contribution_amt,
         x_total_parent_contribution    =>  p_int_data_rec.total_parent_contribution_amt,
         x_parents_contribution         =>  p_int_data_rec.parents_contribution_amt,
         x_student_total_income         =>  p_int_data_rec.student_total_income_amt,
         x_sati                         =>  p_int_data_rec.sati_amt,
         x_sic                          =>  p_int_data_rec.sic_amt,
         x_sdnw                         =>  p_int_data_rec.sdnw_amt,
         x_sca                          =>  p_int_data_rec.sca_amt,
         x_fti                          =>  p_int_data_rec.fti_amt,
         x_secti                        =>  p_int_data_rec.secti_amt,
         x_secati                       =>  p_int_data_rec.secati_amt,
         x_secstx                       =>  p_int_data_rec.secstx_amt,
         x_secea                        =>  p_int_data_rec.secea_amt,
         x_secipa                       =>  p_int_data_rec.secipa_amt,
         x_secai                        =>  p_int_data_rec.secai_amt,
         x_seccai                       =>  p_int_data_rec.seccai_amt,
         x_secdnw                       =>  p_int_data_rec.secdnw_amt,
         x_secnw                        =>  p_int_data_rec.secnw_amt,
         x_secapa                       =>  p_int_data_rec.secapa_amt,
         x_secpca                       =>  p_int_data_rec.secpca_amt,
         x_secaai                       =>  p_int_data_rec.secaai_amt,
         x_sectsc                       =>  p_int_data_rec.sectsc_amt,
         x_sectpc                       =>  p_int_data_rec.sectpc_amt,
         x_secpc                        =>  p_int_data_rec.secpc_amt,
         x_secsti                       =>  p_int_data_rec.secsti_amt,
         x_secsic                       =>  p_int_data_rec.secsati_amt,
         x_secsati                      =>  p_int_data_rec.secsic_amt,
         x_secsdnw                      =>  p_int_data_rec.secsdnw_amt,
         x_secsca                       =>  p_int_data_rec.secsca_amt,
         x_secfti                       =>  p_int_data_rec.secfti_amt,
         x_a_citizenship                =>  p_int_data_rec.a_citizenship_flag,
         x_a_student_marital_status     =>  p_int_data_rec.a_student_marital_status_flag,
         x_a_student_agi                =>  p_int_data_rec.a_student_agi_amt,
         x_a_s_us_tax_paid              =>  p_int_data_rec.a_s_us_tax_paid_amt,
         x_a_s_income_work              =>  p_int_data_rec.a_s_income_work_amt,
         x_a_spouse_income_work         =>  p_int_data_rec.a_spouse_income_work_amt,
         x_a_s_total_wsc                =>  p_int_data_rec.a_s_total_wsc_amt,
         x_a_date_of_birth              =>  p_int_data_rec.a_date_of_birth_flag,
         x_a_student_married            =>  p_int_data_rec.a_student_married_flag,
         x_a_have_children              =>  p_int_data_rec.a_have_children_flag,
         x_a_s_have_dependents          =>  p_int_data_rec.a_s_have_dependents_flag,
         x_a_va_status                  =>  p_int_data_rec.a_va_status_flag,
         x_a_s_num_in_family            =>  p_int_data_rec.a_s_in_family_num,
         x_a_s_num_in_college           =>  p_int_data_rec.a_s_in_college_num,
         x_a_p_marital_status           =>  p_int_data_rec.a_p_marital_status_flag,
         x_a_father_ssn                 =>  p_int_data_rec.a_father_ssn_txt,
         x_a_mother_ssn                 =>  p_int_data_rec.a_mother_ssn_txt,
         x_a_parents_num_family         =>  p_int_data_rec.a_parents_family_num,
         x_a_parents_num_college        =>  p_int_data_rec.a_parents_college_num,
         x_a_parents_agi                =>  p_int_data_rec.a_parents_agi_amt,
         x_a_p_us_tax_paid              =>  p_int_data_rec.a_p_us_tax_paid_amt,
         x_a_f_work_income              =>  p_int_data_rec.a_f_work_income_amt,
         x_a_m_work_income              =>  p_int_data_rec.a_m_work_income_amt,
         x_a_p_total_wsc                =>  p_int_data_rec.a_p_total_wsc_amt,
         x_comment_codes                =>  p_int_data_rec.comment_codes_txt,
         x_sar_ack_comm_code            =>  p_int_data_rec.sar_ack_comm_codes_txt,
         x_pell_grant_elig_flag         =>  p_int_data_rec.pell_grant_elig_flag,
         x_reprocess_reason_code        =>  p_int_data_rec.reprocess_reason_cd,
         x_duplicate_date               =>  p_int_data_rec.duplicate_date,
         x_isir_transaction_type        =>  p_int_data_rec.isir_transaction_type,
         x_fedral_schl_code_indicator   =>  p_int_data_rec.fedral_schl_type,
         x_multi_school_code_flags      =>  p_int_data_rec.multi_school_cd_flags_txt,
         x_dup_ssn_indicator            =>  p_int_data_rec.dup_ssn_indicator_flag,
         x_system_record_type           =>  'ORIGINAL',
         x_payment_isir                 =>  NULL,
         x_receipt_status               =>  NULL,
         x_isir_receipt_completed       =>  NULL,
         x_active_isir                  =>  NULL,
         x_fafsa_data_verify_flags      =>  p_int_data_rec.fafsa_data_verification_txt,
         x_reject_override_a            =>  p_int_data_rec.reject_override_a_flag,
         x_reject_override_c            =>  p_int_data_rec.reject_override_c_flag,
         x_parent_marital_status_date   =>  p_int_data_rec.parent_marital_status_date,
         x_legacy_record_flag           =>  'Y',
         x_father_first_name_initial    => p_int_data_rec.father_first_name_initial_txt,
         x_father_step_father_birth_dt  => p_int_data_rec.father_step_father_birth_date,
         x_mother_first_name_initial    => p_int_data_rec.mother_first_name_initial_txt,
         x_mother_step_mother_birth_dt  => p_int_data_rec.mother_step_mother_birth_date,
         x_parents_email_address_txt    => p_int_data_rec.parents_email_address_txt,
         x_address_change_type          => p_int_data_rec.address_change_type,
         x_cps_pushed_isir_flag         => p_int_data_rec.cps_pushed_isir_flag,
         x_electronic_transaction_type  => p_int_data_rec.electronic_transaction_type,
         x_sar_c_change_type            => p_int_data_rec.sar_c_change_type,
         x_father_ssn_match_type        => p_int_data_rec.father_ssn_match_type,
         x_mother_ssn_match_type        => p_int_data_rec.mother_ssn_match_type,
         x_reject_override_g_flag       => p_int_data_rec.reject_override_g_flag,
         x_dhs_verification_num_txt     => p_int_data_rec.dhs_verification_num_txt,
         x_data_file_name_txt           => p_int_data_rec.data_file_name_txt,
         x_message_class_txt            => p_int_data_rec.message_class_txt,
         x_reject_override_3_flag       => p_int_data_rec.reject_override_3_flag,
         x_reject_override_12_flag      => p_int_data_rec.reject_override_12_flag,
         x_reject_override_j_flag       => p_int_data_rec.reject_override_j_flag,
         x_reject_override_k_flag       => p_int_data_rec.reject_override_k_flag,
         x_rejected_status_change_flag  => p_int_data_rec.rejected_status_change_flag,
         x_verification_selection_flag  => p_int_data_rec.verification_selection_flag
        );
  END update_row;

  PROCEDURE insert_row( p_int_data_rec      IN c_int_data%ROWTYPE,
                        p_base_id           IN NUMBER,
                        pv_isir_id          OUT NOCOPY NUMBER)
             AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : insert into the isir matched table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

       l_rowid   VARCHAR2(30);
       l_isir_id NUMBER;

  BEGIN
       l_rowid:= NULL;
       l_isir_id := NULL;
       igf_ap_isir_matched_pkg.insert_row(
             x_Mode                         =>  'R',
             x_rowid                        =>  l_rowid,
             x_isir_id                      =>  l_isir_id,
             x_base_id                      =>  p_base_id,
             x_batch_year                   =>  p_int_data_rec.batch_year_num,
             x_transaction_num              =>  p_int_data_rec.transaction_num_txt,
             x_current_ssn                  =>  p_int_data_rec.current_ssn_txt,
             x_ssn_name_change              =>  p_int_data_rec.ssn_name_change_type,
             x_original_ssn                 =>  p_int_data_rec.original_ssn_txt,
             x_orig_name_id                 =>  p_int_data_rec.orig_name_id_txt,
             x_last_name                    =>  p_int_data_rec.last_name,
             x_first_name                   =>  p_int_data_rec.first_name,
             x_middle_initial               =>  p_int_data_rec.middle_initial_txt,
             x_perm_mail_add                =>  p_int_data_rec.perm_mail_address_txt,
             x_perm_city                    =>  p_int_data_rec.perm_city_txt,
             x_perm_state                   =>  p_int_data_rec.perm_state_txt,
             x_perm_zip_code                =>  p_int_data_rec.perm_zip_cd,
             x_date_of_birth                =>  p_int_data_rec.birth_date,
             x_phone_number                 =>  p_int_data_rec.phone_number_txt,
             x_driver_license_number        =>  p_int_data_rec.driver_license_number_txt,
             x_driver_license_state         =>  p_int_data_rec.driver_license_state_txt,
             x_citizenship_status           =>  p_int_data_rec.citizenship_status_type,
             x_alien_reg_number             =>  p_int_data_rec.alien_reg_number_txt,
             x_s_marital_status             =>  p_int_data_rec.s_marital_status_type,
             x_s_marital_status_date        =>  p_int_data_rec.s_marital_status_date,
             x_summ_enrl_status             =>  p_int_data_rec.summ_enrl_status_type,
             x_fall_enrl_status             =>  p_int_data_rec.fall_enrl_status_type,
             x_winter_enrl_status           =>  p_int_data_rec.winter_enrl_status_type,
             x_spring_enrl_status           =>  p_int_data_rec.spring_enrl_status_type,
             x_summ2_enrl_status            =>  p_int_data_rec.summ2_enrl_status_type,
             x_fathers_highest_edu_level    =>  p_int_data_rec.fathers_highest_edu_level_type,
             x_mothers_highest_edu_level    =>  p_int_data_rec.mothers_highest_edu_level_type,
             x_s_state_legal_residence      =>  p_int_data_rec.s_state_legal_residence,
             x_legal_residence_before_date  =>  p_int_data_rec.legal_res_before_year_flag,
             x_s_legal_resd_date            =>  p_int_data_rec.s_legal_resd_date,
             x_ss_r_u_male                  =>  p_int_data_rec.ss_r_u_male_flag,
             x_selective_service_reg        =>  p_int_data_rec.selective_service_reg_flag,
             x_degree_certification         =>  p_int_data_rec.degree_certification_type,
             x_grade_level_in_college       =>  p_int_data_rec.grade_level_in_college_type,
             x_high_school_diploma_ged      =>  p_int_data_rec.high_school_diploma_ged_flag,
             x_first_bachelor_deg_by_date   =>  p_int_data_rec.first_bachelor_deg_year_flag,
             x_interest_in_loan             =>  p_int_data_rec.interest_in_loan_flag,
             x_interest_in_stud_employment  =>  p_int_data_rec.interest_in_stu_employmnt_flag,
             x_drug_offence_conviction      =>  p_int_data_rec.drug_offence_conviction_type,
             x_s_tax_return_status          =>  p_int_data_rec.s_tax_return_status_type,
             x_s_type_tax_return            =>  p_int_data_rec.s_type_tax_return_type,
             x_s_elig_1040ez                =>  p_int_data_rec.s_elig_1040ez_type,
             x_s_adjusted_gross_income      =>  p_int_data_rec.s_adjusted_gross_income_amt,
             x_s_fed_taxes_paid             =>  p_int_data_rec.s_fed_taxes_paid_amt,
             x_s_exemptions                 =>  p_int_data_rec.s_exemptions_amt,
             x_s_income_from_work           =>  p_int_data_rec.s_income_from_work_amt,
             x_spouse_income_from_work      =>  p_int_data_rec.spouse_income_from_work_amt,
             x_s_toa_amt_from_wsa           =>  p_int_data_rec.s_total_from_wsa_amt,
             x_s_toa_amt_from_wsb           =>  p_int_data_rec.s_total_from_wsb_amt,
             x_s_toa_amt_from_wsc           =>  p_int_data_rec.s_total_from_wsc_amt,
             x_s_investment_networth        =>  p_int_data_rec.s_investment_networth_amt,
             x_s_busi_farm_networth         =>  p_int_data_rec.s_busi_farm_networth_amt,
             x_s_cash_savings               =>  p_int_data_rec.s_cash_savings_amt,
             x_va_months                    =>  p_int_data_rec.va_months_num,
             x_va_amount                    =>  p_int_data_rec.va_amt,
             x_stud_dob_before_date         =>  p_int_data_rec.stud_dob_before_year_flag,
             x_deg_beyond_bachelor          =>  p_int_data_rec.deg_beyond_bachelor_flag,
             x_s_married                    =>  p_int_data_rec.s_married_flag,
             x_s_have_children              =>  p_int_data_rec.s_have_children_flag,
             x_legal_dependents             =>  p_int_data_rec.legal_dependents_flag,
             x_orphan_ward_of_court         =>  p_int_data_rec.orphan_ward_of_court_flag,
             x_s_veteran                    =>  p_int_data_rec.s_veteran_flag,
             x_p_marital_status             =>  p_int_data_rec.p_marital_status_type,
             x_father_ssn                   =>  p_int_data_rec.father_ssn_txt,
             x_f_last_name                  =>  p_int_data_rec.f_last_name,
             x_mother_ssn                   =>  p_int_data_rec.mother_ssn_txt,
             x_m_last_name                  =>  p_int_data_rec.m_last_name,
             x_p_num_family_member          =>  p_int_data_rec.p_family_members_num,
             x_p_num_in_college             =>  p_int_data_rec.p_in_college_num,
             x_p_state_legal_residence      =>  p_int_data_rec.p_state_legal_residence_txt,
             x_p_state_legal_res_before_dt  =>  p_int_data_rec.p_legal_res_before_dt_flag,
             x_p_legal_res_date             =>  p_int_data_rec.p_legal_res_date,
             x_age_older_parent             =>  p_int_data_rec.age_older_parent_num,
             x_p_tax_return_status          =>  p_int_data_rec.p_tax_return_status_type,
             x_p_type_tax_return            =>  p_int_data_rec.p_type_tax_return_type,
             x_p_elig_1040aez               =>  p_int_data_rec.p_elig_1040aez_type,
             x_p_adjusted_gross_income      =>  p_int_data_rec.p_adjusted_gross_income_amt,
             x_p_taxes_paid                 =>  p_int_data_rec.p_taxes_paid_amt,
             x_p_exemptions                 =>  p_int_data_rec.p_exemptions_amt,
             x_f_income_work                =>  p_int_data_rec.f_income_work_amt,
             x_m_income_work                =>  p_int_data_rec.m_income_work_amt,
             x_p_income_wsa                 =>  p_int_data_rec.p_income_wsa_amt,
             x_p_income_wsb                 =>  p_int_data_rec.p_income_wsb_amt,
             x_p_income_wsc                 =>  p_int_data_rec.p_income_wsc_amt,
             x_p_investment_networth        =>  p_int_data_rec.p_investment_networth_amt,
             x_p_business_networth          =>  p_int_data_rec.p_business_networth_amt,
             x_p_cash_saving                =>  p_int_data_rec.p_cash_saving_amt,
             x_s_num_family_members         =>  p_int_data_rec.s_family_members_num,
             x_s_num_in_college             =>  p_int_data_rec.s_in_college_num,
             x_first_college                =>  p_int_data_rec.first_college_cd,
             x_first_house_plan             =>  p_int_data_rec.first_house_plan_type,
             x_second_college               =>  p_int_data_rec.second_college_cd,
             x_second_house_plan            =>  p_int_data_rec.second_house_plan_type,
             x_third_college                =>  p_int_data_rec.third_college_cd,
             x_third_house_plan             =>  p_int_data_rec.third_house_plan_type,
             x_fourth_college               =>  p_int_data_rec.fourth_college_cd,
             x_fourth_house_plan            =>  p_int_data_rec.fourth_house_plan_type,
             x_fifth_college                =>  p_int_data_rec.fifth_college_cd,
             x_fifth_house_plan             =>  p_int_data_rec.fifth_house_plan_type,
             x_sixth_college                =>  p_int_data_rec.sixth_college_cd,
             x_sixth_house_plan             =>  p_int_data_rec.sixth_house_plan_type,
             x_date_app_completed           =>  p_int_data_rec.app_completed_date,
             x_signed_by                    =>  p_int_data_rec.signed_by_type,
             x_preparer_ssn                 =>  p_int_data_rec.preparer_ssn_txt,
             x_preparer_emp_id_number       =>  p_int_data_rec.preparer_emp_id_number_txt,
             x_preparer_sign                =>  p_int_data_rec.preparer_sign_flag,
             x_transaction_receipt_date     =>  p_int_data_rec.transaction_receipt_date,
             x_dependency_override_ind      =>  p_int_data_rec.dependency_override_type,
             x_faa_fedral_schl_code         =>  p_int_data_rec.faa_fedral_schl_cd,
             x_faa_adjustment               =>  p_int_data_rec.faa_adjustment_type,
             x_input_record_type            =>  p_int_data_rec.input_record_type,
             x_serial_number                =>  p_int_data_rec.serial_num,
             x_batch_number                 =>  p_int_data_rec.batch_number_txt,
             x_early_analysis_flag          =>  p_int_data_rec.early_analysis_flag,
             x_app_entry_source_code        =>  p_int_data_rec.app_entry_source_type,
             x_eti_destination_code         =>  p_int_data_rec.eti_destination_cd,
             x_reject_override_b            =>  p_int_data_rec.reject_override_b_flag,
             x_reject_override_n            =>  p_int_data_rec.reject_override_n_flag,
             x_reject_override_w            =>  p_int_data_rec.reject_override_w_flag,
             x_assum_override_1             =>  p_int_data_rec.assum_override_1_flag,
             x_assum_override_2             =>  p_int_data_rec.assum_override_2_flag,
             x_assum_override_3             =>  p_int_data_rec.assum_override_3_flag,
             x_assum_override_4             =>  p_int_data_rec.assum_override_4_flag,
             x_assum_override_5             =>  p_int_data_rec.assum_override_5_flag,
             x_assum_override_6             =>  p_int_data_rec.assum_override_6_flag,
             x_dependency_status            =>  p_int_data_rec.dependency_status_type,
             x_s_email_address              =>  p_int_data_rec.s_email_address_txt,
             x_nslds_reason_code            =>  p_int_data_rec.nslds_reason_cd,
             x_app_receipt_date             =>  p_int_data_rec.app_receipt_date,
             x_processed_rec_type           =>  p_int_data_rec.processed_rec_type,
             x_hist_correction_for_tran_id  =>  p_int_data_rec.hist_corr_for_tran_num,
             x_system_generated_indicator   =>  p_int_data_rec.sys_generated_indicator_type,
             x_dup_request_indicator        =>  p_int_data_rec.dup_request_indicator_type,
             x_source_of_correction         =>  p_int_data_rec.source_of_correction_type,
             x_p_cal_tax_status             =>  p_int_data_rec.p_cal_tax_status_type,
             x_s_cal_tax_status             =>  p_int_data_rec.s_cal_tax_status_type,
             x_graduate_flag                =>  p_int_data_rec.graduate_flag,
             x_auto_zero_efc                =>  p_int_data_rec.auto_zero_efc_flag,
             x_efc_change_flag              =>  p_int_data_rec.efc_change_flag,
             x_sarc_flag                    =>  p_int_data_rec.sarc_flag,
             x_simplified_need_test         =>  p_int_data_rec.simplified_need_test_flag,
             x_reject_reason_codes          =>  p_int_data_rec.reject_reason_codes_txt,
             x_select_service_match_flag    =>  p_int_data_rec.select_service_match_type,
             x_select_service_reg_flag      =>  p_int_data_rec.select_service_reg_type,
             x_ins_match_flag               =>  p_int_data_rec.ins_match_flag,
             x_ins_verification_number      =>  NULL,
             x_sec_ins_match_flag           =>  p_int_data_rec.sec_ins_match_type,
             x_sec_ins_ver_number           =>  p_int_data_rec.sec_ins_ver_num,
             x_ssn_match_flag               =>  p_int_data_rec.ssn_match_type,
             x_ssa_citizenship_flag         =>  p_int_data_rec.ssa_citizenship_type,
             x_ssn_date_of_death            =>  p_int_data_rec.ssn_death_date,
             x_nslds_match_flag             =>  p_int_data_rec.nslds_match_type,
             x_va_match_flag                =>  p_int_data_rec.va_match_type,
             x_prisoner_match               =>  p_int_data_rec.prisoner_match_flag,
             x_verification_flag            =>  p_int_data_rec.verification_flag,
             x_subsequent_app_flag          =>  p_int_data_rec.subsequent_app_flag,
             x_app_source_site_code         =>  p_int_data_rec.app_source_site_cd,
             x_tran_source_site_code        =>  p_int_data_rec.tran_source_site_cd,
             x_drn                          =>  p_int_data_rec.drn_num,
             x_tran_process_date            =>  p_int_data_rec.tran_process_date,
             x_computer_batch_number        =>  p_int_data_rec.computer_batch_num,
             x_correction_flags             =>  p_int_data_rec.correction_flags_txt,
             x_highlight_flags              =>  p_int_data_rec.highlight_flags_txt,
             x_paid_efc                     =>  NULL,
             x_primary_efc                  =>  p_int_data_rec.primary_efc_amt,
             x_secondary_efc                =>  p_int_data_rec.secondary_efc_amt,
             x_fed_pell_grant_efc_type      =>  NULL,
             x_primary_efc_type             =>  p_int_data_rec.primary_efc_type,
             x_sec_efc_type                 =>  p_int_data_rec.sec_efc_type,
             x_primary_alternate_month_1    =>  p_int_data_rec.primary_alt_month_1_amt,
             x_primary_alternate_month_2    =>  p_int_data_rec.primary_alt_month_2_amt,
             x_primary_alternate_month_3    =>  p_int_data_rec.primary_alt_month_3_amt,
             x_primary_alternate_month_4    =>  p_int_data_rec.primary_alt_month_4_amt,
             x_primary_alternate_month_5    =>  p_int_data_rec.primary_alt_month_5_amt,
             x_primary_alternate_month_6    =>  p_int_data_rec.primary_alt_month_6_amt,
             x_primary_alternate_month_7    =>  p_int_data_rec.primary_alt_month_7_amt,
             x_primary_alternate_month_8    =>  p_int_data_rec.primary_alt_month_8_amt,
             x_primary_alternate_month_10   =>  p_int_data_rec.primary_alt_month_10_amt,
             x_primary_alternate_month_11   =>  p_int_data_rec.primary_alt_month_11_amt,
             x_primary_alternate_month_12   =>  p_int_data_rec.primary_alt_month_12_amt,
             x_sec_alternate_month_1        =>  p_int_data_rec.sec_alternate_month_1_amt,
             x_sec_alternate_month_2        =>  p_int_data_rec.sec_alternate_month_2_amt,
             x_sec_alternate_month_3        =>  p_int_data_rec.sec_alternate_month_3_amt,
             x_sec_alternate_month_4        =>  p_int_data_rec.sec_alternate_month_4_amt,
             x_sec_alternate_month_5        =>  p_int_data_rec.sec_alternate_month_5_amt,
             x_sec_alternate_month_6        =>  p_int_data_rec.sec_alternate_month_6_amt,
             x_sec_alternate_month_7        =>  p_int_data_rec.sec_alternate_month_7_amt,
             x_sec_alternate_month_8        =>  p_int_data_rec.sec_alternate_month_8_amt,
             x_sec_alternate_month_10       =>  p_int_data_rec.sec_alternate_month_10_amt,
             x_sec_alternate_month_11       =>  p_int_data_rec.sec_alternate_month_11_amt,
             x_sec_alternate_month_12       =>  p_int_data_rec.sec_alternate_month_12_amt,
             x_total_income                 =>  p_int_data_rec.total_income_amt,
             x_allow_total_income           =>  p_int_data_rec.allow_total_income_amt,
             x_state_tax_allow              =>  p_int_data_rec.state_tax_allow_amt,
             x_employment_allow             =>  p_int_data_rec.employment_allow_amt,
             x_income_protection_allow      =>  p_int_data_rec.income_protection_allow_amt,
             x_available_income             =>  p_int_data_rec.available_income_amt,
             x_contribution_from_ai         =>  p_int_data_rec.contribution_from_ai_amt,
             x_discretionary_networth       =>  p_int_data_rec.discretionary_networth_amt,
             x_efc_networth                 =>  p_int_data_rec.efc_networth_amt,
             x_asset_protect_allow          =>  p_int_data_rec.asset_protect_allow_amt,
             x_parents_cont_from_assets     =>  p_int_data_rec.parents_cont_from_assets_amt,
             x_adjusted_available_income    =>  p_int_data_rec.adjusted_available_income_amt,
             x_total_student_contribution   =>  p_int_data_rec.total_student_contribution_amt,
             x_total_parent_contribution    =>  p_int_data_rec.total_parent_contribution_amt,
             x_parents_contribution         =>  p_int_data_rec.parents_contribution_amt,
             x_student_total_income         =>  p_int_data_rec.student_total_income_amt,
             x_sati                         =>  p_int_data_rec.sati_amt,
             x_sic                          =>  p_int_data_rec.sic_amt,
             x_sdnw                         =>  p_int_data_rec.sdnw_amt,
             x_sca                          =>  p_int_data_rec.sca_amt,
             x_fti                          =>  p_int_data_rec.fti_amt,
             x_secti                        =>  p_int_data_rec.secti_amt,
             x_secati                       =>  p_int_data_rec.secati_amt,
             x_secstx                       =>  p_int_data_rec.secstx_amt,
             x_secea                        =>  p_int_data_rec.secea_amt,
             x_secipa                       =>  p_int_data_rec.secipa_amt,
             x_secai                        =>  p_int_data_rec.secai_amt,
             x_seccai                       =>  p_int_data_rec.seccai_amt,
             x_secdnw                       =>  p_int_data_rec.secdnw_amt,
             x_secnw                        =>  p_int_data_rec.secnw_amt,
             x_secapa                       =>  p_int_data_rec.secapa_amt,
             x_secpca                       =>  p_int_data_rec.secpca_amt,
             x_secaai                       =>  p_int_data_rec.secaai_amt,
             x_sectsc                       =>  p_int_data_rec.sectsc_amt,
             x_sectpc                       =>  p_int_data_rec.sectpc_amt,
             x_secpc                        =>  p_int_data_rec.secpc_amt,
             x_secsti                       =>  p_int_data_rec.secsti_amt,
             x_secsic                       =>  p_int_data_rec.secsati_amt,
             x_secsati                      =>  p_int_data_rec.secsic_amt,
             x_secsdnw                      =>  p_int_data_rec.secsdnw_amt,
             x_secsca                       =>  p_int_data_rec.secsca_amt,
             x_secfti                       =>  p_int_data_rec.secfti_amt,
             x_a_citizenship                =>  p_int_data_rec.a_citizenship_flag,
             x_a_student_marital_status     =>  p_int_data_rec.a_student_marital_status_flag,
             x_a_student_agi                =>  p_int_data_rec.a_student_agi_amt,
             x_a_s_us_tax_paid              =>  p_int_data_rec.a_s_us_tax_paid_amt,
             x_a_s_income_work              =>  p_int_data_rec.a_s_income_work_amt,
             x_a_spouse_income_work         =>  p_int_data_rec.a_spouse_income_work_amt,
             x_a_s_total_wsc                =>  p_int_data_rec.a_s_total_wsc_amt,
             x_a_date_of_birth              =>  p_int_data_rec.a_date_of_birth_flag,
             x_a_student_married            =>  p_int_data_rec.a_student_married_flag,
             x_a_have_children              =>  p_int_data_rec.a_have_children_flag,
             x_a_s_have_dependents          =>  p_int_data_rec.a_s_have_dependents_flag,
             x_a_va_status                  =>  p_int_data_rec.a_va_status_flag,
             x_a_s_num_in_family            =>  p_int_data_rec.a_s_in_family_num,
             x_a_s_num_in_college           =>  p_int_data_rec.a_s_in_college_num,
             x_a_p_marital_status           =>  p_int_data_rec.a_p_marital_status_flag,
             x_a_father_ssn                 =>  p_int_data_rec.a_father_ssn_txt,
             x_a_mother_ssn                 =>  p_int_data_rec.a_mother_ssn_txt,
             x_a_parents_num_family         =>  p_int_data_rec.a_parents_family_num,
             x_a_parents_num_college        =>  p_int_data_rec.a_parents_college_num,
             x_a_parents_agi                =>  p_int_data_rec.a_parents_agi_amt,
             x_a_p_us_tax_paid              =>  p_int_data_rec.a_p_us_tax_paid_amt,
             x_a_f_work_income              =>  p_int_data_rec.a_f_work_income_amt,
             x_a_m_work_income              =>  p_int_data_rec.a_m_work_income_amt,
             x_a_p_total_wsc                =>  p_int_data_rec.a_p_total_wsc_amt,
             x_comment_codes                =>  p_int_data_rec.comment_codes_txt,
             x_sar_ack_comm_code            =>  p_int_data_rec.sar_ack_comm_codes_txt,
             x_pell_grant_elig_flag         =>  p_int_data_rec.pell_grant_elig_flag,
             x_reprocess_reason_code        =>  p_int_data_rec.reprocess_reason_cd,
             x_duplicate_date               =>  p_int_data_rec.duplicate_date,
             x_isir_transaction_type        =>  p_int_data_rec.isir_transaction_type,
             x_fedral_schl_code_indicator   =>  p_int_data_rec.fedral_schl_type,
             x_multi_school_code_flags      =>  p_int_data_rec.multi_school_cd_flags_txt,
             x_dup_ssn_indicator            =>  p_int_data_rec.dup_ssn_indicator_flag,
             x_system_record_type           =>  'ORIGINAL',
             x_payment_isir                 =>  NULL,
             x_receipt_status               =>  NULL,
             x_isir_receipt_completed       =>  NULL,
             x_active_isir                  =>  NULL,
             x_fafsa_data_verify_flags      =>  p_int_data_rec.fafsa_data_verification_txt,
             x_reject_override_a            =>  p_int_data_rec.reject_override_a_flag,
             x_reject_override_c            =>  p_int_data_rec.reject_override_c_flag,
             x_parent_marital_status_date   =>  p_int_data_rec.parent_marital_status_date,
             x_legacy_record_flag           =>  'Y',
             x_father_first_name_initial    => p_int_data_rec.father_first_name_initial_txt,
             x_father_step_father_birth_dt  => p_int_data_rec.father_step_father_birth_date,
             x_mother_first_name_initial    => p_int_data_rec.mother_first_name_initial_txt,
             x_mother_step_mother_birth_dt  => p_int_data_rec.mother_step_mother_birth_date,
             x_parents_email_address_txt    => p_int_data_rec.parents_email_address_txt,
             x_address_change_type          => p_int_data_rec.address_change_type,
             x_cps_pushed_isir_flag         => p_int_data_rec.cps_pushed_isir_flag,
             x_electronic_transaction_type  => p_int_data_rec.electronic_transaction_type,
             x_sar_c_change_type            => p_int_data_rec.sar_c_change_type,
             x_father_ssn_match_type        => p_int_data_rec.father_ssn_match_type,
             x_mother_ssn_match_type        => p_int_data_rec.mother_ssn_match_type,
             x_reject_override_g_flag       => p_int_data_rec.reject_override_g_flag,
             x_dhs_verification_num_txt     => p_int_data_rec.dhs_verification_num_txt,
             x_data_file_name_txt           => p_int_data_rec.data_file_name_txt,
             x_message_class_txt            => p_int_data_rec.message_class_txt,
             x_reject_override_3_flag       => p_int_data_rec.reject_override_3_flag,
             x_reject_override_12_flag      => p_int_data_rec.reject_override_12_flag,
             x_reject_override_j_flag       => p_int_data_rec.reject_override_j_flag,
             x_reject_override_k_flag       => p_int_data_rec.reject_override_k_flag,
             x_rejected_status_change_flag  => p_int_data_rec.rejected_status_change_flag,
             x_verification_selection_flag  => p_int_data_rec.verification_selection_flag
            );

             pv_isir_id :=l_isir_id ;

   END insert_row;

     PROCEDURE nslds_insert_row(p_int_data_rec IN c_int_data%ROWTYPE,
                                p_base_id      IN NUMBER,
                                p_isir_id      IN NUMBER)
             AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : Insert  NSLDS data
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
      l_rowid        VARCHAR2(30);
      l_nslds_id     NUMBER;


   BEGIN
             l_rowid := NULL;
             l_nslds_id := NULL;

        igf_ap_nslds_data_pkg.insert_row(
             x_mode                                => 'R',
             x_rowid                               => l_rowid,
             x_nslds_id                            => l_nslds_id,
             x_isir_id                             => p_isir_id,
             x_base_id                             => p_base_id,
             x_nslds_transaction_num               => p_int_data_rec.transaction_num_txt,
             x_nslds_database_results_f            => p_int_data_rec.nslds_database_results_type,
             x_nslds_f                             => p_int_data_rec.nslds_flag,
             x_nslds_pell_overpay_f                => p_int_data_rec.nslds_pell_overpay_type,
             x_nslds_pell_overpay_contact          => p_int_data_rec.nslds_pell_overpay_contact_txt,
             x_nslds_seog_overpay_f                => p_int_data_rec.nslds_seog_overpay_type,
             x_nslds_seog_overpay_contact          => p_int_data_rec.nslds_seog_overpay_contact_txt,
             x_nslds_perkins_overpay_f             => p_int_data_rec.nslds_perkins_overpay_type,
             x_nslds_perkins_overpay_cntct         => p_int_data_rec.nslds_perkins_ovrpay_cntct_txt,
             x_nslds_defaulted_loan_f              => p_int_data_rec.nslds_defaulted_loan_flag,
             x_nslds_dischged_loan_chng_f          => p_int_data_rec.nslds_discharged_loan_type,
             x_nslds_satis_repay_f                 => p_int_data_rec.nslds_satis_repay_flag,
             x_nslds_act_bankruptcy_f              => p_int_data_rec.nslds_act_bankruptcy_flag,
             x_nslds_agg_subsz_out_prin_bal        => p_int_data_rec.nslds_agg_subsz_out_pbal_amt,
             x_nslds_agg_unsbz_out_prin_bal        => p_int_data_rec.nslds_agg_unsbz_out_pbal_amt,
             x_nslds_agg_comb_out_prin_bal         => p_int_data_rec.nslds_agg_comb_out_pbal_amt,
             x_nslds_agg_cons_out_prin_bal         => p_int_data_rec.nslds_agg_cons_out_pbal_amt,
             x_nslds_agg_subsz_pend_dismt          => p_int_data_rec.nslds_agg_subsz_pend_disb_amt,
             x_nslds_agg_unsbz_pend_dismt          => p_int_data_rec.nslds_agg_unsbz_pend_disb_amt,
             x_nslds_agg_comb_pend_dismt           => p_int_data_rec.nslds_agg_comb_pend_disb_amt,
             x_nslds_agg_subsz_total               => p_int_data_rec.nslds_agg_subsz_total_amt,
             x_nslds_agg_unsbz_total               => p_int_data_rec.nslds_agg_unsbz_total_amt,
             x_nslds_agg_comb_total                => p_int_data_rec.nslds_agg_comb_total_amt,
             x_nslds_agg_consd_total               => p_int_data_rec.nslds_agg_consd_total_amt,
             x_nslds_perkins_out_bal               => p_int_data_rec.nslds_perkins_out_bal_amt,
             x_nslds_perkins_cur_yr_dismnt         => p_int_data_rec.nslds_perkins_cur_yr_disb_amt,
             x_nslds_default_loan_chng_f           => p_int_data_rec.nslds_default_loan_chng_flag,
             x_nslds_discharged_loan_f             => p_int_data_rec.nslds_dischged_loan_chng_flag,
             x_nslds_satis_repay_chng_f            => p_int_data_rec.nslds_satis_repay_chng_flag,
             x_nslds_act_bnkrupt_chng_f            => p_int_data_rec.nslds_act_bnkrupt_chng_flag,
             x_nslds_overpay_chng_f                => p_int_data_rec.nslds_overpay_chng_flag,
             x_nslds_agg_loan_chng_f               => p_int_data_rec.nslds_agg_loan_chng_flag,
             x_nslds_perkins_loan_chng_f           => p_int_data_rec.nslds_perkins_loan_chng_flag,
             x_nslds_pell_paymnt_chng_f            => p_int_data_rec.nslds_pell_paymnt_chng_flag,
             x_nslds_addtnl_pell_f                 => p_int_data_rec.nslds_addtnl_pell_flag,
             x_nslds_addtnl_loan_f                 => p_int_data_rec.nslds_addtnl_loan_flag,
             x_direct_loan_mas_prom_nt_f           => p_int_data_rec.direct_loan_mas_prom_nt_type,
             x_nslds_pell_seq_num_1                => p_int_data_rec.nslds_pell_1_seq_num,
             x_nslds_pell_verify_f_1               => p_int_data_rec.nslds_pell_1_verify_f_txt,
             x_nslds_pell_efc_1                    => p_int_data_rec.nslds_pell_1_efc_amt,
             x_nslds_pell_school_code_1            => p_int_data_rec.nslds_pell_1_school_num,
             x_nslds_pell_transcn_num_1            => p_int_data_rec.nslds_pell_1_transcn_num,
             x_nslds_pell_last_updt_dt_1           => p_int_data_rec.nslds_pell_1_last_updt_date,
             x_nslds_pell_scheduled_amt_1          => p_int_data_rec.nslds_pell_1_scheduled_amt,
             x_nslds_pell_amt_paid_todt_1          => p_int_data_rec.nslds_pell_1_paid_todt_amt,
             x_nslds_pell_remng_amt_1              => p_int_data_rec.nslds_pell_1_remng_amt,
             x_nslds_pell_pc_schd_awd_us_1         => p_int_data_rec.nslds_pell_1_pc_schawd_use_amt,
             x_nslds_pell_award_amt_1              => p_int_data_rec.nslds_pell_1_award_amt,
             x_nslds_pell_seq_num_2                => p_int_data_rec.nslds_pell_2_seq_num,
             x_nslds_pell_verify_f_2               => p_int_data_rec.nslds_pell_2_verify_f_txt,
             x_nslds_pell_efc_2                    => p_int_data_rec.nslds_pell_2_efc_amt,
             x_nslds_pell_school_code_2            => p_int_data_rec.nslds_pell_2_school_num,
             x_nslds_pell_transcn_num_2            => p_int_data_rec.nslds_pell_2_transcn_num,
             x_nslds_pell_last_updt_dt_2           => p_int_data_rec.nslds_pell_2_last_updt_date,
             x_nslds_pell_scheduled_amt_2          => p_int_data_rec.nslds_pell_2_scheduled_amt,
             x_nslds_pell_amt_paid_todt_2          => p_int_data_rec.nslds_pell_2_paid_todt_amt,
             x_nslds_pell_remng_amt_2              => p_int_data_rec.nslds_pell_2_remng_amt,
             x_nslds_pell_pc_schd_awd_us_2         => p_int_data_rec.nslds_pell_2_pc_schawd_use_amt,
             x_nslds_pell_award_amt_2              => p_int_data_rec.nslds_pell_2_award_amt,
             x_nslds_pell_seq_num_3                => p_int_data_rec.nslds_pell_3_seq_num,
             x_nslds_pell_verify_f_3               => p_int_data_rec.nslds_pell_3_verify_f_txt,
             x_nslds_pell_efc_3                    => p_int_data_rec.nslds_pell_3_efc_amt,
             x_nslds_pell_school_code_3            => p_int_data_rec.nslds_pell_3_school_num,
             x_nslds_pell_transcn_num_3            => p_int_data_rec.nslds_pell_3_transcn_num,
             x_nslds_pell_last_updt_dt_3           => p_int_data_rec.nslds_pell_3_last_updt_date,
             x_nslds_pell_scheduled_amt_3          => p_int_data_rec.nslds_pell_3_scheduled_amt,
             x_nslds_pell_amt_paid_todt_3          => p_int_data_rec.nslds_pell_3_paid_todt_amt,
             x_nslds_pell_remng_amt_3              => p_int_data_rec.nslds_pell_3_remng_amt,
             x_nslds_pell_pc_schd_awd_us_3         => p_int_data_rec.nslds_pell_3_pc_schawd_use_amt,
             x_nslds_pell_award_amt_3              => p_int_data_rec.nslds_pell_3_award_amt,
             x_nslds_loan_seq_num_1                => p_int_data_rec.nslds_loan_1_seq_num,
             x_nslds_loan_type_code_1              => p_int_data_rec.nslds_loan_1_type,
             x_nslds_loan_chng_f_1                 => p_int_data_rec.nslds_loan_1_chng_flag,
             x_nslds_loan_prog_code_1              => p_int_data_rec.nslds_loan_1_prog_cd,
             x_nslds_loan_net_amnt_1               => p_int_data_rec.nslds_loan_1_net_amt,
             x_nslds_loan_cur_st_code_1            => p_int_data_rec.nslds_loan_1_cur_st_cd,
             x_nslds_loan_cur_st_date_1            => p_int_data_rec.nslds_loan_1_cur_st_date,
             x_nslds_loan_agg_pr_bal_1             => p_int_data_rec.nslds_loan_1_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_1          => p_int_data_rec.nslds_loan_1_out_pr_bal_date,
             x_nslds_loan_begin_dt_1               => p_int_data_rec.nslds_loan_1_begin_date,
             x_nslds_loan_end_dt_1                 => p_int_data_rec.nslds_loan_1_end_date,
             x_nslds_loan_ga_code_1                => p_int_data_rec.nslds_loan_1_ga_cd,
             x_nslds_loan_cont_type_1              => p_int_data_rec.nslds_loan_1_cont_type,
             x_nslds_loan_schol_code_1             => p_int_data_rec.nslds_loan_1_schol_cd,
             x_nslds_loan_cont_code_1              => p_int_data_rec.nslds_loan_1_cont_cd,
             x_nslds_loan_grade_lvl_1              => p_int_data_rec.nslds_loan_1_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_1         => p_int_data_rec.nslds_loan_1_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_1          => p_int_data_rec.nslds_loan_1_capital_int_flag,
             x_nslds_loan_seq_num_2                => p_int_data_rec.nslds_loan_2_seq_num,
             x_nslds_loan_type_code_2              => p_int_data_rec.nslds_loan_2_type,
             x_nslds_loan_chng_f_2                 => p_int_data_rec.nslds_loan_2_chng_flag,
             x_nslds_loan_prog_code_2              => p_int_data_rec.nslds_loan_2_prog_cd,
             x_nslds_loan_net_amnt_2               => p_int_data_rec.nslds_loan_2_net_amt,
             x_nslds_loan_cur_st_code_2            => p_int_data_rec.nslds_loan_2_cur_st_cd,
             x_nslds_loan_cur_st_date_2            => p_int_data_rec.nslds_loan_2_cur_st_date,
             x_nslds_loan_agg_pr_bal_2             => p_int_data_rec.nslds_loan_2_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_2          => p_int_data_rec.nslds_loan_2_out_pr_bal_date,
             x_nslds_loan_begin_dt_2               => p_int_data_rec.nslds_loan_2_begin_date,
             x_nslds_loan_end_dt_2                 => p_int_data_rec.nslds_loan_2_end_date,
             x_nslds_loan_ga_code_2                => p_int_data_rec.nslds_loan_2_ga_cd,
             x_nslds_loan_cont_type_2              => p_int_data_rec.nslds_loan_2_cont_type,
             x_nslds_loan_schol_code_2             => p_int_data_rec.nslds_loan_2_schol_cd,
             x_nslds_loan_cont_code_2              => p_int_data_rec.nslds_loan_2_cont_cd,
             x_nslds_loan_grade_lvl_2              => p_int_data_rec.nslds_loan_2_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_2         => p_int_data_rec.nslds_loan_2_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_2          => p_int_data_rec.nslds_loan_2_capital_int_flag,
             x_nslds_loan_seq_num_3                => p_int_data_rec.nslds_loan_3_seq_num,
             x_nslds_loan_type_code_3              => p_int_data_rec.nslds_loan_3_type,
             x_nslds_loan_chng_f_3                 => p_int_data_rec.nslds_loan_3_chng_flag,
             x_nslds_loan_prog_code_3              => p_int_data_rec.nslds_loan_3_prog_cd,
             x_nslds_loan_net_amnt_3               => p_int_data_rec.nslds_loan_3_net_amt,
             x_nslds_loan_cur_st_code_3            => p_int_data_rec.nslds_loan_3_cur_st_cd,
             x_nslds_loan_cur_st_date_3            => p_int_data_rec.nslds_loan_3_cur_st_date,
             x_nslds_loan_agg_pr_bal_3             => p_int_data_rec.nslds_loan_3_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_3          => p_int_data_rec.nslds_loan_3_out_pr_bal_date,
             x_nslds_loan_begin_dt_3               => p_int_data_rec.nslds_loan_3_begin_date,
             x_nslds_loan_end_dt_3                 => p_int_data_rec.nslds_loan_3_end_date,
             x_nslds_loan_ga_code_3                => p_int_data_rec.nslds_loan_3_ga_cd,
             x_nslds_loan_cont_type_3              => p_int_data_rec.nslds_loan_3_cont_type,
             x_nslds_loan_schol_code_3             => p_int_data_rec.nslds_loan_3_schol_cd,
             x_nslds_loan_cont_code_3              => p_int_data_rec.nslds_loan_3_cont_cd,
             x_nslds_loan_grade_lvl_3              => p_int_data_rec.nslds_loan_3_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_3         => p_int_data_rec.nslds_loan_3_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_3          => p_int_data_rec.nslds_loan_3_capital_int_flag,
             x_nslds_loan_seq_num_4                => p_int_data_rec.nslds_loan_4_seq_num,
             x_nslds_loan_type_code_4              => p_int_data_rec.nslds_loan_4_type,
             x_nslds_loan_chng_f_4                 => p_int_data_rec.nslds_loan_4_chng_flag,
             x_nslds_loan_prog_code_4              => p_int_data_rec.nslds_loan_4_prog_cd,
             x_nslds_loan_net_amnt_4               => p_int_data_rec.nslds_loan_4_net_amt,
             x_nslds_loan_cur_st_code_4            => p_int_data_rec.nslds_loan_4_cur_st_cd,
             x_nslds_loan_cur_st_date_4            => p_int_data_rec.nslds_loan_4_cur_st_date,
             x_nslds_loan_agg_pr_bal_4             => p_int_data_rec.nslds_loan_4_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_4          => p_int_data_rec.nslds_loan_4_out_pr_bal_date,
             x_nslds_loan_begin_dt_4               => p_int_data_rec.nslds_loan_4_begin_date,
             x_nslds_loan_end_dt_4                 => p_int_data_rec.nslds_loan_4_end_date,
             x_nslds_loan_ga_code_4                => p_int_data_rec.nslds_loan_4_ga_cd,
             x_nslds_loan_cont_type_4              => p_int_data_rec.nslds_loan_4_cont_type,
             x_nslds_loan_schol_code_4             => p_int_data_rec.nslds_loan_4_schol_cd,
             x_nslds_loan_cont_code_4              => p_int_data_rec.nslds_loan_4_cont_cd,
             x_nslds_loan_grade_lvl_4              => p_int_data_rec.nslds_loan_4_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_4         => p_int_data_rec.nslds_loan_4_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_4          => p_int_data_rec.nslds_loan_4_capital_int_flag,
             x_nslds_loan_seq_num_5                => p_int_data_rec.nslds_loan_5_seq_num,
             x_nslds_loan_type_code_5              => p_int_data_rec.nslds_loan_5_type,
             x_nslds_loan_chng_f_5                 => p_int_data_rec.nslds_loan_5_chng_flag,
             x_nslds_loan_prog_code_5              => p_int_data_rec.nslds_loan_5_prog_cd,
             x_nslds_loan_net_amnt_5               => p_int_data_rec.nslds_loan_5_net_amt,
             x_nslds_loan_cur_st_code_5            => p_int_data_rec.nslds_loan_5_cur_st_cd,
             x_nslds_loan_cur_st_date_5            => p_int_data_rec. nslds_loan_5_cur_st_date,
             x_nslds_loan_agg_pr_bal_5             => p_int_data_rec. nslds_loan_5_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_5          => p_int_data_rec. nslds_loan_5_out_pr_bal_date,
             x_nslds_loan_begin_dt_5               => p_int_data_rec. nslds_loan_5_begin_date,
             x_nslds_loan_end_dt_5                 => p_int_data_rec. nslds_loan_5_end_date,
             x_nslds_loan_ga_code_5                => p_int_data_rec.nslds_loan_5_ga_cd,
             x_nslds_loan_cont_type_5              => p_int_data_rec.nslds_loan_5_cont_type,
             x_nslds_loan_schol_code_5             => p_int_data_rec.nslds_loan_5_schol_cd,
             x_nslds_loan_cont_code_5              => p_int_data_rec.nslds_loan_5_cont_cd,
             x_nslds_loan_grade_lvl_5              => p_int_data_rec.nslds_loan_5_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_5         => p_int_data_rec.nslds_loan_5_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_5          => p_int_data_rec.nslds_loan_5_capital_int_flag,
             x_nslds_loan_seq_num_6                => p_int_data_rec.nslds_loan_6_seq_num,
             x_nslds_loan_type_code_6              => p_int_data_rec.nslds_loan_6_type,
             x_nslds_loan_chng_f_6                 => p_int_data_rec.nslds_loan_6_chng_flag,
             x_nslds_loan_prog_code_6              => p_int_data_rec.nslds_loan_6_prog_cd,
             x_nslds_loan_net_amnt_6               => p_int_data_rec.nslds_loan_6_net_amt,
             x_nslds_loan_cur_st_code_6            => p_int_data_rec.nslds_loan_6_cur_st_cd,
             x_nslds_loan_cur_st_date_6            => p_int_data_rec.nslds_loan_6_cur_st_date,
             x_nslds_loan_agg_pr_bal_6             => p_int_data_rec.nslds_loan_6_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_6          => p_int_data_rec.nslds_loan_6_out_pr_bal_date,
             x_nslds_loan_begin_dt_6               => p_int_data_rec.nslds_loan_6_begin_date,
             x_nslds_loan_end_dt_6                 => p_int_data_rec.nslds_loan_6_end_date,
             x_nslds_loan_ga_code_6                => p_int_data_rec.nslds_loan_6_ga_cd,
             x_nslds_loan_cont_type_6              => p_int_data_rec.nslds_loan_6_cont_type,
             x_nslds_loan_schol_code_6             => p_int_data_rec.nslds_loan_6_schol_cd,
             x_nslds_loan_cont_code_6              => p_int_data_rec.nslds_loan_6_cont_cd,
             x_nslds_loan_grade_lvl_6              => p_int_data_rec.nslds_loan_6_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_6         => p_int_data_rec.nslds_loan_6_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_6          => p_int_data_rec.nslds_loan_6_capital_int_flag,
             x_nslds_loan_last_d_amt_1             => p_int_data_rec.nslds_loan_1_last_disb_amt,
             x_nslds_loan_last_d_date_1            => p_int_data_rec.NSLDS_LOAN_1_LAST_DISB_DATE,
             x_nslds_loan_last_d_amt_2             => p_int_data_rec.nslds_loan_2_last_disb_amt,
             x_nslds_loan_last_d_date_2            => p_int_data_rec.nslds_loan_2_last_disb_date,
             x_nslds_loan_last_d_amt_3             => p_int_data_rec.nslds_loan_3_last_disb_amt,
             x_nslds_loan_last_d_date_3            => p_int_data_rec.nslds_loan_3_last_disb_date,
             x_nslds_loan_last_d_amt_4             => p_int_data_rec.nslds_loan_4_last_disb_amt,
             x_nslds_loan_last_d_date_4            => p_int_data_rec.nslds_loan_4_last_disb_date,
             x_nslds_loan_last_d_amt_5             => p_int_data_rec.nslds_loan_5_last_disb_amt,
             x_nslds_loan_last_d_date_5            => p_int_data_rec.nslds_loan_5_last_disb_date,
             x_nslds_loan_last_d_amt_6             => p_int_data_rec.nslds_loan_6_last_disb_amt,
             x_nslds_loan_last_d_date_6            => p_int_data_rec.nslds_loan_6_last_disb_date,
             x_dlp_master_prom_note_flag           => p_int_data_rec.dlp_master_prom_note_type,
             x_subsidized_loan_limit_type          => p_int_data_rec.subsidized_loan_limit_type,
             x_combined_loan_limit_type            => p_int_data_rec.combined_loan_limit_type,
             x_transaction_num_txt                 => p_int_data_rec.transaction_num_txt
             );

 END nslds_insert_row;

 PROCEDURE nslds_update_row(p_int_data_rec IN c_int_data%ROWTYPE,
                            p_base_id      IN NUMBER,
          p_rowid        IN VARCHAR2,
          p_nslds_id     IN NUMBER,
          p_isir_id      IN NUMBER)
              AS
     /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : Update  NSLDS data
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */


  BEGIN

  igf_ap_nslds_data_pkg.update_row(
             x_mode                                  => 'R',
             x_rowid                                 => p_rowid,
             x_nslds_id                              => p_nslds_id,
             x_isir_id                               => p_isir_id,
             x_base_id                               => p_base_id,
             x_nslds_transaction_num               => p_int_data_rec.transaction_num_txt,
             x_nslds_database_results_f            => p_int_data_rec.nslds_database_results_type,
             x_nslds_f                             => p_int_data_rec.nslds_flag,
             x_nslds_pell_overpay_f                => p_int_data_rec.nslds_pell_overpay_type,
             x_nslds_pell_overpay_contact          => p_int_data_rec.nslds_pell_overpay_contact_txt,
             x_nslds_seog_overpay_f                => p_int_data_rec.nslds_seog_overpay_type,
             x_nslds_seog_overpay_contact          => p_int_data_rec.nslds_seog_overpay_contact_txt,
             x_nslds_perkins_overpay_f             => p_int_data_rec.nslds_perkins_overpay_type,
             x_nslds_perkins_overpay_cntct         => p_int_data_rec.nslds_perkins_ovrpay_cntct_txt,
             x_nslds_defaulted_loan_f              => p_int_data_rec.nslds_defaulted_loan_flag,
             x_nslds_dischged_loan_chng_f          => p_int_data_rec.nslds_discharged_loan_type,
             x_nslds_satis_repay_f                 => p_int_data_rec.nslds_satis_repay_flag,
             x_nslds_act_bankruptcy_f              => p_int_data_rec.nslds_act_bankruptcy_flag,
             x_nslds_agg_subsz_out_prin_bal        => p_int_data_rec.nslds_agg_subsz_out_pbal_amt,
             x_nslds_agg_unsbz_out_prin_bal        => p_int_data_rec.nslds_agg_unsbz_out_pbal_amt,
             x_nslds_agg_comb_out_prin_bal         => p_int_data_rec.nslds_agg_comb_out_pbal_amt,
             x_nslds_agg_cons_out_prin_bal         => p_int_data_rec.nslds_agg_cons_out_pbal_amt,
             x_nslds_agg_subsz_pend_dismt          => p_int_data_rec.nslds_agg_subsz_pend_disb_amt,
             x_nslds_agg_unsbz_pend_dismt          => p_int_data_rec.nslds_agg_unsbz_pend_disb_amt,
             x_nslds_agg_comb_pend_dismt           => p_int_data_rec.nslds_agg_comb_pend_disb_amt,
             x_nslds_agg_subsz_total               => p_int_data_rec.nslds_agg_subsz_total_amt,
             x_nslds_agg_unsbz_total               => p_int_data_rec.nslds_agg_unsbz_total_amt,
             x_nslds_agg_comb_total                => p_int_data_rec.nslds_agg_comb_total_amt,
             x_nslds_agg_consd_total               => p_int_data_rec.nslds_agg_consd_total_amt,
             x_nslds_perkins_out_bal               => p_int_data_rec.nslds_perkins_out_bal_amt,
             x_nslds_perkins_cur_yr_dismnt         => p_int_data_rec.nslds_perkins_cur_yr_disb_amt,
             x_nslds_default_loan_chng_f           => p_int_data_rec.nslds_default_loan_chng_flag,
             x_nslds_discharged_loan_f             => p_int_data_rec.nslds_dischged_loan_chng_flag,
             x_nslds_satis_repay_chng_f            => p_int_data_rec.nslds_satis_repay_chng_flag,
             x_nslds_act_bnkrupt_chng_f            => p_int_data_rec.nslds_act_bnkrupt_chng_flag,
             x_nslds_overpay_chng_f                => p_int_data_rec.nslds_overpay_chng_flag,
             x_nslds_agg_loan_chng_f               => p_int_data_rec.nslds_agg_loan_chng_flag,
             x_nslds_perkins_loan_chng_f           => p_int_data_rec.nslds_perkins_loan_chng_flag,
             x_nslds_pell_paymnt_chng_f            => p_int_data_rec.nslds_pell_paymnt_chng_flag,
             x_nslds_addtnl_pell_f                 => p_int_data_rec.nslds_addtnl_pell_flag,
             x_nslds_addtnl_loan_f                 => p_int_data_rec.nslds_addtnl_loan_flag,
             x_direct_loan_mas_prom_nt_f           => p_int_data_rec.direct_loan_mas_prom_nt_type,
             x_nslds_pell_seq_num_1                => p_int_data_rec.nslds_pell_1_seq_num,
             x_nslds_pell_verify_f_1               => p_int_data_rec.nslds_pell_1_verify_f_txt,
             x_nslds_pell_efc_1                    => p_int_data_rec.nslds_pell_1_efc_amt,
             x_nslds_pell_school_code_1            => p_int_data_rec.nslds_pell_1_school_num,
             x_nslds_pell_transcn_num_1            => p_int_data_rec.nslds_pell_1_transcn_num,
             x_nslds_pell_last_updt_dt_1           => p_int_data_rec.nslds_pell_1_last_updt_date,
             x_nslds_pell_scheduled_amt_1          => p_int_data_rec.nslds_pell_1_scheduled_amt,
             x_nslds_pell_amt_paid_todt_1          => p_int_data_rec.nslds_pell_1_paid_todt_amt,
             x_nslds_pell_remng_amt_1              => p_int_data_rec.nslds_pell_1_remng_amt,
             x_nslds_pell_pc_schd_awd_us_1         => p_int_data_rec.nslds_pell_1_pc_schawd_use_amt,
             x_nslds_pell_award_amt_1              => p_int_data_rec.nslds_pell_1_award_amt,
             x_nslds_pell_seq_num_2                => p_int_data_rec.nslds_pell_2_seq_num,
             x_nslds_pell_verify_f_2               => p_int_data_rec.nslds_pell_2_verify_f_txt,
             x_nslds_pell_efc_2                    => p_int_data_rec.nslds_pell_2_efc_amt,
             x_nslds_pell_school_code_2            => p_int_data_rec.nslds_pell_2_school_num,
             x_nslds_pell_transcn_num_2            => p_int_data_rec.nslds_pell_2_transcn_num,
             x_nslds_pell_last_updt_dt_2           => p_int_data_rec.nslds_pell_2_last_updt_date,
             x_nslds_pell_scheduled_amt_2          => p_int_data_rec.nslds_pell_2_scheduled_amt,
             x_nslds_pell_amt_paid_todt_2          => p_int_data_rec.nslds_pell_2_paid_todt_amt,
             x_nslds_pell_remng_amt_2              => p_int_data_rec.nslds_pell_2_remng_amt,
             x_nslds_pell_pc_schd_awd_us_2         => p_int_data_rec.nslds_pell_2_pc_schawd_use_amt,
             x_nslds_pell_award_amt_2              => p_int_data_rec.nslds_pell_2_award_amt,
             x_nslds_pell_seq_num_3                => p_int_data_rec.nslds_pell_3_seq_num,
             x_nslds_pell_verify_f_3               => p_int_data_rec.nslds_pell_3_verify_f_txt,
             x_nslds_pell_efc_3                    => p_int_data_rec.nslds_pell_3_efc_amt,
             x_nslds_pell_school_code_3            => p_int_data_rec.nslds_pell_3_school_num,
             x_nslds_pell_transcn_num_3            => p_int_data_rec.nslds_pell_3_transcn_num,
             x_nslds_pell_last_updt_dt_3           => p_int_data_rec.nslds_pell_3_last_updt_date,
             x_nslds_pell_scheduled_amt_3          => p_int_data_rec.nslds_pell_3_scheduled_amt,
             x_nslds_pell_amt_paid_todt_3          => p_int_data_rec.nslds_pell_3_paid_todt_amt,
             x_nslds_pell_remng_amt_3              => p_int_data_rec.nslds_pell_3_remng_amt,
             x_nslds_pell_pc_schd_awd_us_3         => p_int_data_rec.nslds_pell_3_pc_schawd_use_amt,
             x_nslds_pell_award_amt_3              => p_int_data_rec.nslds_pell_3_award_amt,
             x_nslds_loan_seq_num_1                => p_int_data_rec.nslds_loan_1_seq_num,
             x_nslds_loan_type_code_1              => p_int_data_rec.nslds_loan_1_type,
             x_nslds_loan_chng_f_1                 => p_int_data_rec.nslds_loan_1_chng_flag,
             x_nslds_loan_prog_code_1              => p_int_data_rec.nslds_loan_1_prog_cd,
             x_nslds_loan_net_amnt_1               => p_int_data_rec.nslds_loan_1_net_amt,
             x_nslds_loan_cur_st_code_1            => p_int_data_rec.nslds_loan_1_cur_st_cd,
             x_nslds_loan_cur_st_date_1            => p_int_data_rec.nslds_loan_1_cur_st_date,
             x_nslds_loan_agg_pr_bal_1             => p_int_data_rec.nslds_loan_1_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_1          => p_int_data_rec.nslds_loan_1_out_pr_bal_date,
             x_nslds_loan_begin_dt_1               => p_int_data_rec.nslds_loan_1_begin_date,
             x_nslds_loan_end_dt_1                 => p_int_data_rec.nslds_loan_1_end_date,
             x_nslds_loan_ga_code_1                => p_int_data_rec.nslds_loan_1_ga_cd,
             x_nslds_loan_cont_type_1              => p_int_data_rec.nslds_loan_1_cont_type,
             x_nslds_loan_schol_code_1             => p_int_data_rec.nslds_loan_1_schol_cd,
             x_nslds_loan_cont_code_1              => p_int_data_rec.nslds_loan_1_cont_cd,
             x_nslds_loan_grade_lvl_1              => p_int_data_rec.nslds_loan_1_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_1         => p_int_data_rec.nslds_loan_1_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_1          => p_int_data_rec.nslds_loan_1_capital_int_flag,
             x_nslds_loan_seq_num_2                => p_int_data_rec.nslds_loan_2_seq_num,
             x_nslds_loan_type_code_2              => p_int_data_rec.nslds_loan_2_type,
             x_nslds_loan_chng_f_2                 => p_int_data_rec.nslds_loan_2_chng_flag,
             x_nslds_loan_prog_code_2              => p_int_data_rec.nslds_loan_2_prog_cd,
             x_nslds_loan_net_amnt_2               => p_int_data_rec.nslds_loan_2_net_amt,
             x_nslds_loan_cur_st_code_2            => p_int_data_rec.nslds_loan_2_cur_st_cd,
             x_nslds_loan_cur_st_date_2            => p_int_data_rec.nslds_loan_2_cur_st_date,
             x_nslds_loan_agg_pr_bal_2             => p_int_data_rec.nslds_loan_2_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_2          => p_int_data_rec.nslds_loan_2_out_pr_bal_date,
             x_nslds_loan_begin_dt_2               => p_int_data_rec.nslds_loan_2_begin_date,
             x_nslds_loan_end_dt_2                 => p_int_data_rec.nslds_loan_2_end_date,
             x_nslds_loan_ga_code_2                => p_int_data_rec.nslds_loan_2_ga_cd,
             x_nslds_loan_cont_type_2              => p_int_data_rec.nslds_loan_2_cont_type,
             x_nslds_loan_schol_code_2             => p_int_data_rec.nslds_loan_2_schol_cd,
             x_nslds_loan_cont_code_2              => p_int_data_rec.nslds_loan_2_cont_cd,
             x_nslds_loan_grade_lvl_2              => p_int_data_rec.nslds_loan_2_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_2         => p_int_data_rec.nslds_loan_2_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_2          => p_int_data_rec.nslds_loan_2_capital_int_flag,
             x_nslds_loan_seq_num_3                => p_int_data_rec.nslds_loan_3_seq_num,
             x_nslds_loan_type_code_3              => p_int_data_rec.nslds_loan_3_type,
             x_nslds_loan_chng_f_3                 => p_int_data_rec.nslds_loan_3_chng_flag,
             x_nslds_loan_prog_code_3              => p_int_data_rec.nslds_loan_3_prog_cd,
             x_nslds_loan_net_amnt_3               => p_int_data_rec.nslds_loan_3_net_amt,
             x_nslds_loan_cur_st_code_3            => p_int_data_rec.nslds_loan_3_cur_st_cd,
             x_nslds_loan_cur_st_date_3            => p_int_data_rec. nslds_loan_3_cur_st_date,
             x_nslds_loan_agg_pr_bal_3             => p_int_data_rec. nslds_loan_3_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_3          => p_int_data_rec. nslds_loan_3_out_pr_bal_date,
             x_nslds_loan_begin_dt_3               => p_int_data_rec. nslds_loan_3_begin_date,
             x_nslds_loan_end_dt_3                 => p_int_data_rec. nslds_loan_3_end_date,
             x_nslds_loan_ga_code_3                => p_int_data_rec.nslds_loan_3_ga_cd,
             x_nslds_loan_cont_type_3              => p_int_data_rec.nslds_loan_3_cont_type,
             x_nslds_loan_schol_code_3             => p_int_data_rec.nslds_loan_3_schol_cd,
             x_nslds_loan_cont_code_3              => p_int_data_rec.nslds_loan_3_cont_cd,
             x_nslds_loan_grade_lvl_3              => p_int_data_rec.nslds_loan_3_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_3         => p_int_data_rec.nslds_loan_3_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_3          => p_int_data_rec.nslds_loan_3_capital_int_flag,
             x_nslds_loan_seq_num_4                => p_int_data_rec.nslds_loan_4_seq_num,
             x_nslds_loan_type_code_4              => p_int_data_rec.nslds_loan_4_type,
             x_nslds_loan_chng_f_4                 => p_int_data_rec.nslds_loan_4_chng_flag,
             x_nslds_loan_prog_code_4              => p_int_data_rec.nslds_loan_4_prog_cd,
             x_nslds_loan_net_amnt_4               => p_int_data_rec.nslds_loan_4_net_amt,
             x_nslds_loan_cur_st_code_4            => p_int_data_rec.nslds_loan_4_cur_st_cd,
             x_nslds_loan_cur_st_date_4            => p_int_data_rec.nslds_loan_4_cur_st_date,
             x_nslds_loan_agg_pr_bal_4             => p_int_data_rec.nslds_loan_4_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_4          => p_int_data_rec.nslds_loan_4_out_pr_bal_date,
             x_nslds_loan_begin_dt_4               => p_int_data_rec.nslds_loan_4_begin_date,
             x_nslds_loan_end_dt_4                 => p_int_data_rec.nslds_loan_4_end_date,
             x_nslds_loan_ga_code_4                => p_int_data_rec.nslds_loan_4_ga_cd,
             x_nslds_loan_cont_type_4              => p_int_data_rec.nslds_loan_4_cont_type,
             x_nslds_loan_schol_code_4             => p_int_data_rec.nslds_loan_4_schol_cd,
             x_nslds_loan_cont_code_4              => p_int_data_rec.nslds_loan_4_cont_cd,
             x_nslds_loan_grade_lvl_4              => p_int_data_rec.nslds_loan_4_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_4         => p_int_data_rec.nslds_loan_4_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_4          => p_int_data_rec.nslds_loan_4_capital_int_flag,
             x_nslds_loan_seq_num_5                => p_int_data_rec.nslds_loan_5_seq_num,
             x_nslds_loan_type_code_5              => p_int_data_rec.nslds_loan_5_type,
             x_nslds_loan_chng_f_5                 => p_int_data_rec.nslds_loan_5_chng_flag,
             x_nslds_loan_prog_code_5              => p_int_data_rec.nslds_loan_5_prog_cd,
             x_nslds_loan_net_amnt_5               => p_int_data_rec.nslds_loan_5_net_amt,
             x_nslds_loan_cur_st_code_5            => p_int_data_rec.nslds_loan_5_cur_st_cd,
             x_nslds_loan_cur_st_date_5            => p_int_data_rec. nslds_loan_5_cur_st_date,
             x_nslds_loan_agg_pr_bal_5             => p_int_data_rec. nslds_loan_5_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_5          => p_int_data_rec. nslds_loan_5_out_pr_bal_date,
             x_nslds_loan_begin_dt_5               => p_int_data_rec. nslds_loan_5_begin_date,
             x_nslds_loan_end_dt_5                 => p_int_data_rec. nslds_loan_5_end_date,
             x_nslds_loan_ga_code_5                => p_int_data_rec.nslds_loan_5_ga_cd,
             x_nslds_loan_cont_type_5              => p_int_data_rec.nslds_loan_5_cont_type,
             x_nslds_loan_schol_code_5             => p_int_data_rec.nslds_loan_5_schol_cd,
             x_nslds_loan_cont_code_5              => p_int_data_rec.nslds_loan_5_cont_cd,
             x_nslds_loan_grade_lvl_5              => p_int_data_rec.nslds_loan_5_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_5         => p_int_data_rec.nslds_loan_5_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_5          => p_int_data_rec.nslds_loan_5_capital_int_flag,
             x_nslds_loan_seq_num_6                => p_int_data_rec.nslds_loan_6_seq_num,
             x_nslds_loan_type_code_6              => p_int_data_rec.nslds_loan_6_type,
             x_nslds_loan_chng_f_6                 => p_int_data_rec.nslds_loan_6_chng_flag,
             x_nslds_loan_prog_code_6              => p_int_data_rec.nslds_loan_6_prog_cd,
             x_nslds_loan_net_amnt_6               => p_int_data_rec.nslds_loan_6_net_amt,
             x_nslds_loan_cur_st_code_6            => p_int_data_rec.nslds_loan_6_cur_st_cd,
             x_nslds_loan_cur_st_date_6            => p_int_data_rec.nslds_loan_6_cur_st_date,
             x_nslds_loan_agg_pr_bal_6             => p_int_data_rec.nslds_loan_6_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_6          => p_int_data_rec.nslds_loan_6_out_pr_bal_date,
             x_nslds_loan_begin_dt_6               => p_int_data_rec.nslds_loan_6_begin_date,
             x_nslds_loan_end_dt_6                 => p_int_data_rec.nslds_loan_6_end_date,
             x_nslds_loan_ga_code_6                => p_int_data_rec.nslds_loan_6_ga_cd,
             x_nslds_loan_cont_type_6              => p_int_data_rec.nslds_loan_6_cont_type,
             x_nslds_loan_schol_code_6             => p_int_data_rec.nslds_loan_6_schol_cd,
             x_nslds_loan_cont_code_6              => p_int_data_rec.nslds_loan_6_cont_cd,
             x_nslds_loan_grade_lvl_6              => p_int_data_rec.nslds_loan_6_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_6         => p_int_data_rec.nslds_loan_6_xtr_unsbz_ln_type,
             x_nslds_loan_capital_int_f_6          => p_int_data_rec.nslds_loan_6_capital_int_flag,
             x_nslds_loan_last_d_amt_1             => p_int_data_rec.nslds_loan_1_last_disb_amt,
             x_nslds_loan_last_d_date_1            => p_int_data_rec.NSLDS_LOAN_1_LAST_DISB_DATE,
             x_nslds_loan_last_d_amt_2             => p_int_data_rec.nslds_loan_2_last_disb_amt,
             x_nslds_loan_last_d_date_2            => p_int_data_rec.nslds_loan_2_last_disb_date,
             x_nslds_loan_last_d_amt_3             => p_int_data_rec.nslds_loan_3_last_disb_amt,
             x_nslds_loan_last_d_date_3            => p_int_data_rec.nslds_loan_3_last_disb_date,
             x_nslds_loan_last_d_amt_4             => p_int_data_rec.nslds_loan_4_last_disb_amt,
             x_nslds_loan_last_d_date_4            => p_int_data_rec.nslds_loan_4_last_disb_date,
             x_nslds_loan_last_d_amt_5             => p_int_data_rec.nslds_loan_5_last_disb_amt,
             x_nslds_loan_last_d_date_5            => p_int_data_rec.nslds_loan_5_last_disb_date,
             x_nslds_loan_last_d_amt_6             => p_int_data_rec.nslds_loan_6_last_disb_amt,
             x_nslds_loan_last_d_date_6            => p_int_data_rec.nslds_loan_6_last_disb_date,
             x_dlp_master_prom_note_flag           => p_int_data_rec.dlp_master_prom_note_type,
             x_subsidized_loan_limit_type          => p_int_data_rec.subsidized_loan_limit_type,
             x_combined_loan_limit_type            => p_int_data_rec.combined_loan_limit_type,
             x_transaction_num_txt                 => p_int_data_rec.transaction_num_txt
             );

   END nslds_update_row;


  PROCEDURE put_meaning(list IN VARCHAR2)
         AS
           lookups_table    dbms_utility.uncl_array;
           -- Get the details of
           CURSOR c_meaning(p_lookup_code VARCHAR2,
                            p_lookup_type VARCHAR2)
           IS
           SELECT meaning
           FROM igf_lookups_view
           WHERE lookup_code=p_lookup_code
           AND lookup_type = p_lookup_type
           AND enabled_flag = 'Y' ;
           c_meaning_rec c_meaning%ROWTYPE;
           l_hash_value  NUMBER;
           tablen NUMBER;
         BEGIN
           dbms_utility.comma_to_table(list,tablen,lookups_table);
           FOR i IN lookups_table.FIRST .. lookups_table.LAST
           LOOP
             c_meaning_rec := NULL;
             OPEN c_meaning(lookups_table(i),'IGF_AW_LOOKUPS_MSG');
             FETCH c_meaning INTO c_meaning_rec;
             CLOSE c_meaning;
             l_hash_value := dbms_utility.get_hash_value(
                                           lookups_table(i),
                                           1000,
                                           25000);
             lookup_meaning_table(l_hash_value).field_name:=lookups_table(i);
             lookup_meaning_table(l_hash_value).msg_text:=c_meaning_rec.meaning;
          END LOOP;
  END put_meaning;


  PROCEDURE put_hash_values(list         IN VARCHAR2,
                            p_award_year IN VARCHAR2)


  IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Takes a list of lookup types separated by comma and store those in a pl/sql table.
  ||            Generate hash values with corresponding look up code and store in another pl/sql table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
        tablen           BINARY_INTEGER      ;
        lookups_table    DBMS_UTILITY.uncl_array;
        l_hash_value     NUMBER;


        -- Get the details of
        CURSOR c_lookup_values(p_lookup_type VARCHAR2,
                               p_award_year  VARCHAR2 )
                   IS

             SELECT   LOOKUP_CODE
             FROM     IGF_AW_LOOKUPS_VIEW
             WHERE    LOOKUP_TYPE = p_lookup_type
             AND SYS_AWARD_YEAR =p_award_year
             AND enabled_flag = 'Y' ;

             l_lookup_values c_lookup_values%ROWTYPE;

      BEGIN
       DBMS_UTILITY.comma_to_table(list,tablen,lookups_table);

       FOR i IN lookups_table.FIRST .. lookups_table.LAST
       LOOP


          FOR rec IN c_lookup_values(lookups_table(i),p_award_year)
          LOOP
           l_hash_value := DBMS_UTILITY.get_hash_value(
                                     RTRIM(LTRIM(lookups_table(i)))||'@*?'||rec.lookup_code,
                                     1000,
                                     25000);

           lookup_hash_table(l_hash_value):=l_hash_value;



          END LOOP;



       END LOOP;




  END put_hash_values ;

   FUNCTION  is_lookup_code_exist(p_lookup_code  IN VARCHAR2,
                                  p_lookup_type  IN VARCHAR2)
   RETURN BOOLEAN AS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose : Takes look up code and lookup type and generate hash code  and checks whether the hash value (for a lookup code) exists or not
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
  l_hash_value  NUMBER;
  l_lookup_type igf_aw_lookups_view. lookup_type%TYPE;
  BEGIN


               l_hash_value := dbms_utility.get_hash_value(
                                        RTRIM(LTRIM(p_lookup_type))||'@*?'|| RTRIM(LTRIM(p_lookup_code)),
                                       1000,
                                       25000);



               IF lookup_hash_table.EXISTS(l_hash_value) THEN

                    RETURN TRUE;
               ELSE

                    RETURN FALSE;

               END IF;

  END is_lookup_code_exist;


  PROCEDURE print_message(p_igf_ap_message_table IN igf_ap_message_table) AS
        /*
        ||  Created By : rasahoo
        ||  Created On : 03-June-2003
        ||  Purpose : Print the error messages stored in PL/SQL message table.
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */
  CURSOR c_lkup_values(p_lookup_code  VARCHAR2 )
             IS
             SELECT   meaning
             FROM     igf_lookups_view
             WHERE    lookup_type ='IGF_AW_LOOKUPS_MSG'
             AND lookup_code =p_lookup_code
             AND enabled_flag = 'Y' ;

             c_lkup_values_err_rec  c_lkup_values%ROWTYPE;
             indx NUMBER;
  BEGIN
        c_lkup_values_err_rec := NULL;
        OPEN  c_lkup_values('ERROR');
        FETCH c_lkup_values INTO c_lkup_values_err_rec;
        CLOSE c_lkup_values;

        IF p_igf_ap_message_table.COUNT<>0 THEN

        FOR indx IN p_igf_ap_message_table.FIRST..p_igf_ap_message_table.LAST

          LOOP

          fnd_file.put_line(fnd_file.log,l_error || l_blank || p_igf_ap_message_table(indx).field_name||' '||p_igf_ap_message_table(indx).msg_text);

          END LOOP;
        END IF;
  END print_message;




  FUNCTION convert_to_date( pv_org_date IN VARCHAR2)
  RETURN DATE
  IS
    /*
    ||  Created By : rasahoo
    ||  Created On : 03-June-2003
    ||  Purpose :        Converts the valid dates to into the DATE format else return NULL.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who              When              What
    ||  (reverse chronological order - newest change first)
    */
  ld_date   DATE;
  BEGIN
    ld_date := fnd_date.chardate_to_date( pv_org_date);
    RETURN ld_date;
  EXCEPTION
    WHEN others THEN
    RETURN NULL;
  END convert_to_date;

  PROCEDURE get_hash_value( string       IN VARCHAR2,
                            l_hash_value OUT NOCOPY NUMBER) AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :  Accepts one string and returns hash value corresponding to that string.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN

  l_hash_value := dbms_utility.get_hash_value(string,1000,25000);
  END get_hash_value;


  FUNCTION Val_Name ( l_length IN NUMBER,
                    l_value  IN VARCHAR2
                  ) RETURN BOOLEAN
  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :   Validate the length of string is less that the length of the field(l_length)
  ||              Validate that there are no invalid characters present in the string using
  ||              translate function ( check the length of string before and after translation)
  ||              Validate that first character is alphabet.
  ||              Validate that the second character is NON NUMERIC
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_char_set VARCHAR2(100) := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.,- ';
  BEGIN

    IF      l_length < LENGTH(l_value)
    OR(TRANSLATE((SUBSTR(UPPER(l_value),1,1)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ',  'AAAAAAAAAAAAAAAAAAAAAAAAAA') <> 'A'      )
    OR l_value <> UPPER(l_value)
    OR TRANSLATE(SUBSTR(l_value,2,1),'1234567890',  '**********') = '*'
    OR NVL(LENGTH(TRIM(TRANSLATE(UPPER(l_value),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Name;

  FUNCTION Val_Char ( l_length IN NUMBER,
                      l_value  IN VARCHAR2
          ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Validate the length of string is less that the length of the field(l_length)
  ||      Validate that there are no invalid characters present in the string using translate function ( check the length of string before and after translation)
  ||      Validate that first character is alphabet.
  ||      Validate that the second character is NON NUMERIC
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_char_set VARCHAR2(100) := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-* ';
  BEGIN

    IF LENGTH (l_value) > l_length
       OR LTRIM (RTRIM(SUBSTR(l_value,1,1))) IS NULL
       OR LTRIM(RTRIM(SUBSTR(l_value,1,1))) = '*'
       OR NVL(LENGTH(TRIM(TRANSLATE(UPPER(l_value),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
       OR   LENGTH (TRANSLATE (l_value,'*','*')) = LENGTH (l_value)
       OR   LENGTH (TRANSLATE (l_value,'0123456789','0123456789')) = LENGTH (l_value)
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Char;

  FUNCTION Val_Date ( l_value IN  VARCHAR2)
         RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :Validate the validity of date
  ||         date should be between 01011900 and 31121999
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF TO_NUMBER(l_value) BETWEEN  19000101  AND  19991231
      THEN
          RETURN TRUE ;
      ELSE
          RETURN FALSE;
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Date;
  FUNCTION Val_Date_2( l_value IN  VARCHAR2
          ) RETURN BOOLEAN  AS
  /*
  ||  Created By : rasahoo
  ||  Created On :  03-June-2003
  ||
  ||  Purpose :Validate the validity of date
  ||           Date should be between 190001 to 20041
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
  IF g_sys_award_year = '0304' THEN
       IF  TO_NUMBER(l_value) BETWEEN  190001 AND  200412
       THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
   ELSIF g_sys_award_year = '0405' THEN
       IF  TO_NUMBER(l_value) BETWEEN  190001 AND  200512
       THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
   ELSIF g_sys_award_year = '0506' THEN
       IF  TO_NUMBER(l_value) BETWEEN  190001 AND  200612
       THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
   ELSIF g_sys_award_year = '0607' THEN
       IF  TO_NUMBER(l_value) BETWEEN  190001 AND  200712
       THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Date_2;

  FUNCTION Val_Email( l_length IN NUMBER,
                      l_value  IN VARCHAR2
                  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On :  03-June-2003
  ||  Purpose :   Validate that only one '@' is present.
  ||        Validate that non alphanumeric characters are not together. Translate all alphanumeric characters to '2'
  ||              and then check if there is occurrence of more than one '2' together.
  ||          Translate the whole string into NUMBER except '@' which is translated to '.'.
  ||              Now this string is converted into NUMBER, if more that 2 '@' are present, to_number will give error.
  ||            round off translated string, if the string value is same after translation, that means there are no characters after '@' and give error
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   lv_val     VARCHAR2(100);
   lv_num_val NUMBER;
   l_loc1     NUMBER;
   l_loc2     NUMBER;
   l_ret_val  NUMBER;
  BEGIN

    lv_val := TRANSLATE (UPPER(l_value),'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ._-@', '111111111111111111111111111111111111222.');
    lv_num_val := TO_NUMBER(lv_val);
    l_loc1 := INSTR(lv_val,'2');
    l_loc2 := INSTR(lv_val,'22');
    is_number(lv_val,l_ret_val);
    IF l_loc1 = 1
     OR l_loc1 = LENGTH(l_value)
     OR l_loc2 <> 0
     OR lv_val = ROUND(lv_val)
     OR l_ret_val<>1
    THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Email;

  FUNCTION Val_Input_Rec_type(l_value IN  VARCHAR2
                           ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :  Validate that the value is among the one defined in the list
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF NVL(l_value,'C')  in ('C','D','H','Q','R','S','V')
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Input_Rec_type;

  FUNCTION Val_Int( l_value  IN VARCHAR2
          ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :  Validate that the value is between -999999 and 999999.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF LENGTH(TO_CHAR(ABS(l_value))) > 6
     THEN
       RETURN FALSE;
     ELSE
       RETURN TRUE;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Int;

  FUNCTION Val_Alpha( l_value  IN VARCHAR2,
                    l_length IN NUMBER
                  ) RETURN BOOLEAN  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose  : Validate that the value is a valid alphabetic character
  ||             Validate that the length of the field is valid.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF l_length <> LENGTH(l_value)
    OR      TRANSLATE(UPPER(l_value),' ABCDEFGHIJKLMNOPQRSTUVWXYZ','0') <> RPAD('0',l_length,'0')
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Alpha;

  FUNCTION Val_Add( l_length IN NUMBER,
                  l_value  IN VARCHAR2
                ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Only Uppercase A-Z, 0-9, period, apostrophe, dash, slash,
  ||            number sign, at sign, percent sign, ampersand sign, comma or embedded space(s)
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   lv_val    VARCHAR2(100);
   l_ret_val NUMBER;
  BEGIN

    lv_val := TRANSLATE (UPPER(l_value),'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ.'||'''-/#@%&, ', '111111111111111111111111111111111111111111111111');
    is_number(lv_val,l_ret_val);
    IF l_ret_val=1
    THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Add;

  FUNCTION Val_Num( l_length IN NUMBER,
                  l_value  IN VARCHAR2
                ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :The value should be a valid NUMBER of size less than or equal to l_length
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_ret_val NUMBER;
  BEGIN

    is_number(l_value,l_ret_val);
    IF l_length < LENGTH(l_value)
    OR l_ret_val<>1
    OR l_value < 0
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num;

  FUNCTION Val_Num_NonZero( l_value IN   VARCHAR2,
                          l_length IN NUMBER
                        ) RETURN BOOLEAN  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :The value should be a valid NUMBER of size less than or equal to l_length
  ||           The value must be non zero
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_ret_val NUMBER;
  BEGIN

    is_number(l_value,l_ret_val);
    IF l_length < LENGTH(l_value)
    OR l_ret_val<>1
    OR l_value <= 0
    THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_NonZero;

  FUNCTION Val_Num_1( l_value IN  VARCHAR2)
                 RETURN  BOOLEAN AS
  /*
  ||  Created By : brajendr
  ||  Created On : 03-June-2003
  ||  Purpose :    Validate that the value is '1'. No other value is allowed
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF NVL(l_value,'1') = '1'
    THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_1;

  FUNCTION Val_Num_12( l_value IN  VARCHAR2)
              RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On :  03-June-2003
  ||  Purpose :  Validate that the value is between 0 and 12. No other value is allowed
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF NVL(l_value,'1') NOT IN ( '0','1','2','3','4','5','6','7','8','9','10','11','12')
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_12;

  FUNCTION Val_Num_2( l_value IN  VARCHAR2)
           RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On :03-June-2003
  ||  Purpose : Validate that the value is between 1 and 2. No other value is allowed
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

   IF NVL(l_value,'1') NOT IN ( '1','2')
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_2;

  FUNCTION Val_Num_3( l_value IN  VARCHAR2)
          RETURN BOOLEAN AS
  /*
  ||  Created By : brajendr
  ||  Created On : 03-June-2003
  ||  Purpose :  Validate that the value is between 1 and 3. No other value is allowed.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN




    IF NVL(l_value,'1') NOT IN ( '1','2','3') THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;

  END Val_Num_3;

  FUNCTION Val_Num_4( l_value IN  VARCHAR2)
           RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On :03-June-2003
  ||  Purpose :  Validate that the value is between 1 and 4. No other value is allowed.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    IF NVL(l_value,'1') NOT IN ( '1','2','3','4') THEN
     RETURN FALSE;
    ELSE
     RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_4;

  FUNCTION Val_Num_5( l_value IN  VARCHAR2)
          RETURN BOOLEAN  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Validate that the value is between 1 and 5. No other value is allowed
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

     IF NVL(l_value,'1') NOT IN ( '1','2','3','4','5') THEN
      RETURN FALSE;
     ELSE
      RETURN TRUE;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_5;

  FUNCTION Val_Num_7(l_value IN  VARCHAR2)
           RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On :03-June-2003
  ||  Purpose :  Validate that the value is between 0 and 7. No other value is allowed.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    IF NVL(l_value,'1') NOT IN ( '0','1','2','3','4','5','6','7') THEN
      RETURN FALSE;
     ELSE
      RETURN TRUE;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Num_7;

  FUNCTION Val_Num_9( l_value IN  VARCHAR2)
           RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose : Validate that the value is between 1 and 9. No other value is allowed
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF NVL(l_value,'1') NOT IN ( '1','2','3','4','5','6','7','8','9') THEN
      RETURN FALSE;
     ELSE
      RETURN TRUE;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;

  END Val_Num_9;

  FUNCTION Val_School_Cd( l_value IN   VARCHAR2,
                        l_length IN NUMBER
                      ) RETURN BOOLEAN AS
  /*
  ||  Created By :rasahoo
  ||  Created On :03-June-2003
  ||  Purpose : Validate that first character is '0','B','E','G'
  ||      Validate that length is 6 characters
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF SUBSTR(l_value,1,1) NOT IN ('0','B','E','G')
    OR  LENGTH(l_value) <> 6
    THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_School_Cd;

  FUNCTION Val_Signed_By( l_value IN  VARCHAR2)
            RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :    Validate that first character is 'A','B','P'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF l_value NOT IN ('A','B','P')
    THEN
       RETURN FALSE;
    ELSE
       RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Signed_By;

FUNCTION val_ssn(l_value IN  VARCHAR2)
           RETURN BOOLEAN AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 03-June-2003
  ||  Purpose :   Validate that length is 9 characters long
  ||              Value of each segment is greater that 001-01-0001
  ||              Valid number
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_ret_val NUMBER;
BEGIN
      is_number(l_value,l_ret_val);
      IF  NVL(l_ret_val,0)<>1
      OR  NVL(TO_NUMBER(SUBSTR(l_value,1,3)),0) < 1
      OR  NVL(TO_NUMBER(SUBSTR(l_value,4,2)),0) < 1
      OR  NVL(TO_NUMBER(SUBSTR(l_value,6,4)),0) < 1
      OR  NVL(LENGTH (l_value),0) <> 9
      THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
 EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
END val_ssn;

  PROCEDURE is_number (
                         p_number  IN           VARCHAR2,
                         ret_num   OUT NOCOPY   NUMBER
                       ) IS
   /***************************************************************
     Created By :       rasahoo
     Date Created By  : 03-June-2003
     Purpose    : To Check if it is number
     Known Limitations,Enhancements or Remarks
     Change History :
     Who      When    What
   ***************************************************************/
     l_value NUMBER;
    BEGIN
      l_value := TO_NUMBER(p_number);
      ret_num := 1 ;
    EXCEPTION
      WHEN OTHERS THEN
           ret_num := 0 ;
  END is_number ;

  FUNCTION Val_Char_set( l_value      IN VARCHAR2,
                         l_length     IN NUMBER,
                         l_char_set   IN VARCHAR2
                        ) RETURN BOOLEAN AS
  BEGIN
    IF LENGTH (l_value) <> l_length
     OR NVL(LENGTH(TRIM(TRANSLATE(UPPER(l_value),l_char_set,LPAD(' ',LENGTH(l_char_set),' ' )))),0) > 0
    THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE ;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;
  END Val_Char_set;

  PROCEDURE validate_isir_rec(        p_isir_rec                IN c_int_data%ROWTYPE,
                                       p_status                 OUT NOCOPY BOOLEAN,
                                       p_igf_ap_message_table   OUT NOCOPY igf_ap_message_table)
  AS

  /***************************************************************
     Created By :       rasahoo
     Date Created By  : 03-June-2003
     Purpose    : To Validate legacy ISIR record
     Known Limitations,Enhancements or Remarks
     Change History :
     Who      When    What
   ***************************************************************/


    CURSOR c_lkup_values(p_lookup_code  VARCHAR2 )
             IS
       SELECT   meaning
       FROM     igf_aw_lookups_view
       WHERE    lookup_type ='IGF_AW_LOOKUPS_MSG'
       AND lookup_code =p_lookup_code
       AND enabled_flag = 'Y' ;

       c_lkup_values_rec c_lkup_values%ROWTYPE;
       indx NUMBER ;
       l_ret_val BOOLEAN;
       l_hash_value NUMBER;
       message      VARCHAR2(200);

  BEGIN
    indx  :=0 ;


    p_igf_ap_message_table.DELETE;
    put_meaning('IGF_AP_CSS_DEP_STATUS,STATE_CODES,CITIZENSHIP_TYPES,MARITAL_STATUSES,ENROLLMENT_TYPES,HIGHGRADLEVEL_TYPES,DEGCERT_TYPES,GRADE_LEVELS,DRUG_CONVICTS,TAXRETSTAT_TYPES,TAXFORM_TYPES,TAXEXEM_ELIGTYPES,PMARITAL_STATUSES,HOUSING_STATS');

    p_status:=TRUE;

    IF p_isir_rec.p_state_legal_residence_txt IS NOT NULL THEN

      l_ret_val:=is_lookup_code_exist(p_isir_rec.p_state_legal_residence_txt,'IGF_AP_STATE_CODES');

      IF  NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('STATE_CODES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:='';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_STATE_LEGAL_RESIDENCE_TXT');


      END IF;

   END IF;
     IF p_isir_rec.s_state_legal_residence IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.s_state_legal_residence,'IGF_AP_STATE_CODES');

       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('STATE_CODES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:='';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('S_STATE_LEGAL_RESIDENCE');

      END IF;
   END IF;

     IF p_isir_rec.perm_state_txt IS NOT NULL THEN
         l_ret_val:=is_lookup_code_exist(p_isir_rec.perm_state_txt,'IGF_AP_STATE_CODES');
        IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('STATE_CODES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:='';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('PERM_STATE_TXT');

     END IF;
  END IF;

    IF p_isir_rec.driver_license_state_txt IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.driver_license_state_txt,'IGF_AP_STATE_CODES');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('STATE_CODES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('DRIVER_LICENSE_STATE_TXT');

     END IF;
  END IF;
     IF p_isir_rec.citizenship_status_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.citizenship_status_type,'IGF_CITIZENSHIP_TYPE');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('CITIZENSHIP_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('CITIZENSHIP_STATUS_TYPE');

     END IF;
  END IF;
     IF p_isir_rec.s_marital_status_type IS NOT NULL THEN

         l_ret_val:=is_lookup_code_exist( p_isir_rec.s_marital_status_type,'IGF_ST_MARITAL_STAT_TYPE');
         IF NOT l_ret_val  THEN
          p_status:=FALSE;
          indx:= indx+1;
          l_hash_value:=dbms_utility.get_hash_value('MARITAL_STATUSES',
                                         1000,
                                         25000);
          p_igf_ap_message_table(indx).field_name:=' ';
          p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('S_MARITAL_STATUS_TYPE');

     END IF;
   END IF;


    IF p_isir_rec.summ_enrl_status_type IS NOT NULL THEN
      IF g_sys_award_year NOT IN ('0405','0506', '0607') THEN
        l_ret_val:=is_lookup_code_exist(  p_isir_rec.summ_enrl_status_type,'IGF_ENROLMENT_TYPE');
        IF NOT l_ret_val   THEN
          p_status:=FALSE;
          indx:= indx+1;
          l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                         1000,
                                         25000);

          p_igf_ap_message_table(indx).field_name:=' ';
          p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SUMM_ENRL_STATUS_TYPE');
        END IF;
      ELSE
        l_ret_val:=is_lookup_code_exist(  p_isir_rec.summ_enrl_status_type,'IGF_AP_ENROLLMENT_STATUS_TYPE');
        IF NOT l_ret_val   THEN
          p_status:=FALSE;
          indx:= indx+1;
          l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                         1000,
                                         25000);

          p_igf_ap_message_table(indx).field_name:=' ';
          p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SUMM_ENRL_STATUS_TYPE');
        END IF;
      END IF;
    END IF;
   IF g_sys_award_year NOT IN ('0405','0506', '0607') THEN
      IF p_isir_rec.fall_enrl_status_type IS NOT NULL THEN
         l_ret_val:=is_lookup_code_exist(p_isir_rec.fall_enrl_status_type,'IGF_ENROLMENT_TYPE');
         IF NOT l_ret_val   THEN
          p_status:=FALSE;
          indx:= indx+1;
          l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                         1000,
                                         25000);
          p_igf_ap_message_table(indx).field_name:=' ';
          p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FALL_ENRL_STATUS_TYPE');

         END IF;
      END IF;
   ELSE
      IF p_isir_rec.fall_enrl_status_type IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FALL_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
   END IF;
   IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.winter_enrl_status_type IS NOT NULL THEN
        l_ret_val:=is_lookup_code_exist(p_isir_rec.winter_enrl_status_type,'IGF_ENROLMENT_TYPE');
        IF NOT l_ret_val   THEN
          p_status:=FALSE;
          indx:= indx+1;
          l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                         1000,
                                         25000);
          p_igf_ap_message_table(indx).field_name:=' ';
          p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('WINTER_ENRL_STATUS_TYPE');

       END IF;
     END IF;
  ELSE
    IF p_isir_rec.winter_enrl_status_type IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('WINTER_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.spring_enrl_status_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.spring_enrl_status_type,'IGF_ENROLMENT_TYPE');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SPRING_ENRL_STATUS_TYPE');

     END IF;
    END IF;
  ELSE
    IF p_isir_rec.spring_enrl_status_type IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SPRING_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.summ2_enrl_status_type IS NOT NULL THEN
        l_ret_val:=is_lookup_code_exist(p_isir_rec.summ2_enrl_status_type,'IGF_ENROLMENT_TYPE');
       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('ENROLLMENT_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SUMM2_ENRL_STATUS_TYPE');

       END IF;
     END IF;
   ELSE
      IF p_isir_rec.summ2_enrl_status_type IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SUMM2_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
   END IF;
   IF p_isir_rec.fathers_highest_edu_level_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.fathers_highest_edu_level_type,'IGF_HIGH_GRAD_LVL_TYPE');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HIGHGRADLEVEL_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FATHERS_HIGHEST_EDU_LEVEL_TYPE');

     END IF;
   END IF;
    IF p_isir_rec.mothers_highest_edu_level_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.mothers_highest_edu_level_type,'IGF_HIGH_GRAD_LVL_TYPE');
       IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HIGHGRADLEVEL_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('MOTHERS_HIGHEST_EDU_LEVEL_TYPE');

     END IF;
   END IF;

     IF p_isir_rec.degree_certification_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.degree_certification_type,'IGF_DEG_CERT_TYPE');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('DEGCERT_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('DEGREE_CERTIFICATION_TYPE');

     END IF;
   END IF;
     IF p_isir_rec.grade_level_in_college_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.grade_level_in_college_type,'IGF_AP_GRADE_LEVEL');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('GRADE_LEVELS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('GRADE_LEVEL_IN_COLLEGE_TYPE');

     END IF;
   END IF;

     IF p_isir_rec.drug_offence_conviction_type IS NOT NULL THEN
         l_ret_val:=is_lookup_code_exist(p_isir_rec.drug_offence_conviction_type,'IGF_DRUG_ELIGIBILITY_TYPE');
       IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('DRUG_CONVICTS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('DRUG_OFFENCE_CONVICTION_TYPE');

     END IF;
   END IF;

    IF p_isir_rec.s_tax_return_status_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.s_tax_return_status_type,'IGF_TAX_RET_STAT_TYPE');
     IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('TAXRETSTAT_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('S_TAX_RETURN_STATUS_TYPE');

     END IF;
   END IF;

    IF p_isir_rec.p_tax_return_status_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.p_tax_return_status_type,'IGF_TAX_RET_STAT_TYPE') ;
       IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
         l_hash_value:=dbms_utility.get_hash_value('TAXRETSTAT_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_TAX_RETURN_STATUS_TYPE');

     END IF;
   END IF;
    IF p_isir_rec.s_type_tax_return_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.s_type_tax_return_type,'IGF_TAX_FORM_TYPE');
      IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
         l_hash_value:=dbms_utility.get_hash_value('TAXFORM_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('S_TYPE_TAX_RETURN_TYPE');

     END IF;
   END IF;

    IF p_isir_rec.p_type_tax_return_type IS NOT NULL THEN
        l_ret_val:=is_lookup_code_exist(p_isir_rec.p_type_tax_return_type,'IGF_TAX_FORM_TYPE');
       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('TAXFORM_TYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_TYPE_TAX_RETURN_TYPE');

     END IF;
  END IF;
   IF p_isir_rec.s_elig_1040ez_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.s_elig_1040ez_type,'IGF_TAX_EXEMPTION_ELIG_TYPE');
       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('TAXEXEM_ELIGTYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('S_ELIG_1040EZ_TYPE');

     END IF;
  END IF;
    IF p_isir_rec.p_elig_1040aez_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.p_elig_1040aez_type,'IGF_TAX_EXEMPTION_ELIG_TYPE');
       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('TAXEXEM_ELIGTYPES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_ELIG_1040AEZ_TYPE');

     END IF;
   END IF;
     IF p_isir_rec.p_marital_status_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.p_marital_status_type,'IGF_P_MARITAL_STAT_TYPE');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
         indx:= indx+1;
         l_hash_value:=dbms_utility.get_hash_value('PMARITAL_STATUSES',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('P_MARITAL_STATUS_TYPE');

     END IF;
  END IF;
    IF p_isir_rec.first_house_plan_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.first_house_plan_type,'IGF_AP_HOUSING_STAT');
     IF NOT l_ret_val   THEN
      p_status:=FALSE;
      indx:= indx+1;
      l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                     1000,
                                     25000);
      p_igf_ap_message_table(indx).field_name:=' ';
      p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FIRST_HOUSE_PLAN_TYPE');

     END IF;
  END IF;
   IF p_isir_rec.second_house_plan_type IS NOT NULL THEN
      l_ret_val:=is_lookup_code_exist(p_isir_rec.second_house_plan_type,'IGF_AP_HOUSING_STAT');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SECOND_HOUSE_PLAN_TYPE');

     END IF;
   END IF;
    IF p_isir_rec.third_house_plan_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.third_house_plan_type,'IGF_AP_HOUSING_STAT');
       IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('THIRD_HOUSE_PLAN_TYPE');

     END IF;
   END IF;
     IF p_isir_rec.fourth_house_plan_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.fourth_house_plan_type,'IGF_AP_HOUSING_STAT');
      IF NOT l_ret_val   THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FOURTH_HOUSE_PLAN_TYPE');

     END IF;
  END IF;

   IF p_isir_rec.fifth_house_plan_type IS NOT NULL THEN
         l_ret_val:=is_lookup_code_exist(p_isir_rec.fifth_house_plan_type,'IGF_AP_HOUSING_STAT');
       IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('FIFTH_HOUSE_PLAN_TYPE');

     END IF;
   END IF;

    IF p_isir_rec.sixth_house_plan_type IS NOT NULL THEN
       l_ret_val:=is_lookup_code_exist(p_isir_rec.sixth_house_plan_type,'IGF_AP_HOUSING_STAT');
       IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('HOUSING_STATS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('SIXTH_HOUSE_PLAN_TYPE');

     END IF;
    END IF;

     IF p_isir_rec.dependency_status_type IS NOT NULL THEN
      l_ret_val:= is_lookup_code_exist(p_isir_rec.dependency_status_type,'IGF_AP_DEP_STATUS');
      IF NOT l_ret_val  THEN
        p_status:=FALSE;
        indx:= indx+1;
        l_hash_value:=dbms_utility.get_hash_value('IGF_AP_CSS_DEP_STATUS',
                                       1000,
                                       25000);
        p_igf_ap_message_table(indx).field_name:=' ';
        p_igf_ap_message_table(indx).msg_text:=lookup_meaning_table(l_hash_value).msg_text||' '|| p_l_to_i_col('DEPENDENCY_STATUS_TYPE');

     END IF;
    END IF;

   IF p_isir_rec.last_name IS NOT NULL THEN
    IF  NOT Val_Name(16,p_isir_rec.last_name) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NAME');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('LAST_NAME');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;

    END IF;
 END IF;

  IF p_isir_rec.first_name IS NOT NULL THEN
    IF NOT Val_Name(12,p_isir_rec.first_name) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NAME');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIRST_NAME');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;

  END IF;
 END IF;
 IF p_isir_rec.middle_initial_txt IS NOT NULL THEN
   IF NOT Val_Alpha(p_isir_rec.middle_initial_txt,1) OR p_isir_rec.middle_initial_txt <> UPPER(p_isir_rec.middle_initial_txt)  THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_M_INITIAL');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MIDDLE_INITIAL_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;

  END IF;
 END IF;


 IF p_isir_rec.perm_mail_address_txt IS NOT NULL THEN
    IF NOT Val_Add(12,p_isir_rec.perm_mail_address_txt) OR p_isir_rec.perm_mail_address_txt <> UPPER(p_isir_rec.perm_mail_address_txt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_ADDRESS');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PERM_MAIL_ADDRESS_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
  END IF;
 END IF;
  IF p_isir_rec.perm_city_txt IS NOT NULL THEN
   IF NOT Val_Add(12,p_isir_rec.PERM_CITY_TXT) OR p_isir_rec.perm_city_txt <> UPPER(p_isir_rec.perm_city_txt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_CITY');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PERM_CITY_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

   IF p_isir_rec.perm_zip_cd IS NOT NULL THEN
      IF NOT Val_Num(5,p_isir_rec.perm_zip_cd) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_ZIP_CODE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PERM_ZIP_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;

   IF p_isir_rec.birth_date IS NOT NULL THEN
     IF NOT Val_date(TO_CHAR(p_isir_rec.birth_date,'YYYYMMDD')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_DOB');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('BIRTH_DATE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

     IF NOT val_ssn(p_isir_rec.current_ssn_txt) THEN

         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SSN');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('CURRENT_SSN_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;


     IF NOT Val_SSN(p_isir_rec.ORIGINAL_SSN_TXT) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SSN');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('ORIGINAL_SSN_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;


     IF p_isir_rec.phone_number_txt IS NOT NULL THEN
      IF NOT Val_Num(10,p_isir_rec.phone_number_txt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PH_NUM');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PHONE_NUMBER_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
    END IF;



     IF p_isir_rec.citizenship_status_type IS NOT NULL THEN
      IF NOT Val_Num_3(p_isir_rec.citizenship_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('CITIZENSHIP_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.alien_reg_number_txt IS NOT NULL THEN
      IF NOT Val_Num_NonZero(p_isir_rec.alien_reg_number_txt,9) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_ALN_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('ALIEN_REG_NUMBER_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
    IF p_isir_rec.s_marital_status_type IS NOT NULL THEN
      IF NOT Val_Num_3(p_isir_rec.s_marital_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_MARITAL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;

   END IF;
    IF p_isir_rec.s_marital_status_date IS NOT NULL THEN
     IF NOT Val_Date_2(TO_CHAR(p_isir_rec.s_marital_status_date,'YYYYMM')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('S_MARITAL_STATUS_DATE'));
         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= '';
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

    IF p_isir_rec.summ_enrl_status_type IS NOT NULL THEN
      IF NOT Val_Num_5(p_isir_rec.summ_enrl_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SUMM_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
   IF p_isir_rec.fall_enrl_status_type IS NOT NULL THEN
      IF NOT Val_Num_5(p_isir_rec.fall_enrl_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FALL_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
     IF p_isir_rec.winter_enrl_status_type IS NOT NULL THEN
      IF NOT Val_Num_5(p_isir_rec.winter_enrl_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('WINTER_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
     IF p_isir_rec.spring_enrl_status_type IS NOT NULL THEN
      IF NOT Val_Num_5(p_isir_rec.spring_enrl_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SPRING_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
     IF p_isir_rec.summ2_enrl_status_type IS NOT NULL THEN
      IF NOT Val_Num_5(p_isir_rec.summ2_enrl_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SUMM2_ENRL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.fathers_highest_edu_level_type IS NOT NULL THEN
      IF NOT Val_Num_4(p_isir_rec.fathers_highest_edu_level_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHERS_HIGHEST_EDU_LEVEL_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

    IF p_isir_rec.mothers_highest_edu_level_type IS NOT NULL THEN
      IF NOT Val_Num_4(p_isir_rec.mothers_highest_edu_level_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHERS_HIGHEST_EDU_LEVEL_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
    IF p_isir_rec.legal_res_before_year_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.legal_res_before_year_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('LEGAL_RES_BEFORE_YEAR_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
     IF p_isir_rec.s_legal_resd_date IS NOT NULL THEN
      IF NOT Val_Date_2(TO_CHAR(p_isir_rec.s_legal_resd_date,'YYYYMM')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD', p_l_to_i_col('S_LEGAL_RESD_DATE'));

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= '';
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
    END IF;

   IF p_isir_rec.ss_r_u_male_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.ss_r_u_male_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SS_R_U_MALE_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;

    IF p_isir_rec.selective_service_reg_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.selective_service_reg_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SELECTIVE_SERVICE_REG_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;

   IF p_isir_rec.degree_certification_type IS NOT NULL THEN
      IF NOT Val_Num_9(p_isir_rec.degree_certification_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('DEGREE_CERTIFICATION_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
   END IF;
    IF p_isir_rec.grade_level_in_college_type IS NOT NULL THEN
      IF NOT Val_Num_7(p_isir_rec.grade_level_in_college_type)  THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('GRADE_LEVEL_IN_COLLEGE_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
     IF p_isir_rec.high_school_diploma_ged_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.high_school_diploma_ged_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('HIGH_SCHOOL_DIPLOMA_GED_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;

    IF p_isir_rec.first_bachelor_deg_year_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.first_bachelor_deg_year_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIRST_BACHELOR_DEG_YEAR_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;

     IF p_isir_rec.interest_in_loan_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.interest_in_loan_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('INTEREST_IN_LOAN_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.interest_in_stu_employmnt_flag IS NOT NULL THEN
      IF NOT Val_Num_2(p_isir_rec.interest_in_stu_employmnt_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('INTEREST_IN_STU_EMPLOYMNT_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.drug_offence_conviction_type IS NOT NULL THEN
      IF NOT Val_Num_3(p_isir_rec.drug_offence_conviction_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('DRUG_OFFENCE_CONVICTION_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_tax_return_status_type IS NOT NULL THEN
      IF NOT Val_Num_3(p_isir_rec.s_tax_return_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_TAX_RETURN_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;

     IF p_isir_rec.s_type_tax_return_type IS NOT NULL THEN
      IF NOT Val_Num_4(p_isir_rec.s_type_tax_return_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_TYPE_TAX_RETURN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_elig_1040ez_type IS NOT NULL THEN
      IF NOT Val_Num_3(p_isir_rec.s_elig_1040ez_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_ELIG_1040EZ_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_adjusted_gross_income_amt IS NOT NULL THEN
      IF NOT Val_Int(p_isir_rec.s_adjusted_gross_income_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_ADJUSTED_GROSS_INCOME_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;

   IF p_isir_rec.s_fed_taxes_paid_amt IS NOT NULL THEN
      IF NOT Val_Num(5,p_isir_rec.s_fed_taxes_paid_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_FED_TAXES_PAID_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
   IF p_isir_rec.s_exemptions_amt IS NOT NULL THEN
      IF NOT Val_Num(2,p_isir_rec.s_exemptions_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_EXEMPTIONS_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_income_from_work_amt IS NOT NULL THEN
      IF NOT Val_Int(p_isir_rec.s_income_from_work_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_INCOME_FROM_WORK_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.spouse_income_from_work_amt IS NOT NULL THEN
      IF NOT Val_Int(p_isir_rec.spouse_income_from_work_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SPOUSE_INCOME_FROM_WORK_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
     IF p_isir_rec.s_total_from_wsa_amt IS NOT NULL THEN
      IF NOT Val_Num(5,p_isir_rec.s_total_from_wsa_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_TOTAL_FROM_WSA_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
     END IF;

    IF p_isir_rec.s_total_from_wsb_amt IS NOT NULL THEN
     IF NOT Val_Num(5,p_isir_rec.s_total_from_wsb_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_TOTAL_FROM_WSB_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_total_from_wsc_amt IS NOT NULL THEN
     IF NOT Val_Num(5,p_isir_rec.s_total_from_wsc_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_TOTAL_FROM_WSC_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.s_investment_networth_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.s_investment_networth_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_INVESTMENT_NETWORTH_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.s_busi_farm_networth_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.s_busi_farm_networth_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_BUSI_FARM_NETWORTH_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
    END IF;
    IF p_isir_rec.s_cash_savings_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.s_cash_savings_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_CASH_SAVINGS_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.va_months_num IS NOT NULL THEN
     IF NOT Val_Num_12(p_isir_rec.va_months_num)  THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('VA_MONTHS_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.va_amt IS NOT NULL THEN
     IF NOT Val_Num(15,p_isir_rec.va_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('VA_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.stud_dob_before_year_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.stud_dob_before_year_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('STUD_DOB_BEFORE_YEAR_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.deg_beyond_bachelor_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.deg_beyond_bachelor_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('DEG_BEYOND_BACHELOR_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.s_married_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.s_married_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_MARRIED_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.s_have_children_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.s_have_children_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_HAVE_CHILDREN_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.legal_dependents_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.legal_dependents_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('LEGAL_DEPENDENTS_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
    IF p_isir_rec.orphan_ward_of_court_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.orphan_ward_of_court_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('ORPHAN_WARD_OF_COURT_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.s_veteran_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.s_veteran_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_VETERAN_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_marital_status_type IS NOT NULL THEN
     IF NOT Val_Num_4(p_isir_rec.p_marital_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_MARITAL_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.father_ssn_txt IS NOT NULL THEN
     IF NOT Val_Char_set(p_isir_rec.father_ssn_txt,9,'0123456789') THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INVALID_PAR_SSN');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHER_SSN_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
  IF p_isir_rec.f_last_name IS NOT NULL THEN
     IF NOT Val_Name(16,p_isir_rec.f_last_name) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NAME');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('F_LAST_NAME');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.mother_ssn_txt IS NOT NULL THEN
     IF NOT Val_Char_set(p_isir_rec.mother_ssn_txt,9,'0123456789') THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INVALID_PAR_SSN');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHER_SSN_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.m_last_name IS NOT NULL THEN
     IF NOT Val_Name(16,p_isir_rec.m_last_name) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NAME');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('M_LAST_NAME');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_family_members_num IS NOT NULL THEN
     IF NOT Val_Num_NonZero(p_isir_rec.p_family_members_num,2) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_FAMILY_MEMBERS_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_in_college_num IS NOT NULL THEN
     IF NOT Val_Num_9(p_isir_rec.p_in_college_num) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_IN_COLLEGE_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_legal_res_before_dt_flag IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.p_legal_res_before_dt_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_LEGAL_RES_BEFORE_DT_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.p_legal_res_date IS NOT NULL THEN
     IF NOT Val_Date_2(TO_CHAR(p_isir_rec.p_legal_res_date,'YYYYMM')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD',  p_l_to_i_col('P_LEGAL_RES_DATE'));

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= '';
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.age_older_parent_num IS NOT NULL THEN
       IF NOT Val_Num(2,p_isir_rec.age_older_parent_num) THEN
           p_status:=FALSE;
           fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

           indx:= indx+1;
           p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('AGE_OLDER_PARENT_NUM');
           p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
    END IF;
  ELSE
     IF p_isir_rec.age_older_parent_num IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('AGE_OLDER_PARENT_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
  END IF;
   IF p_isir_rec.p_tax_return_status_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.p_tax_return_status_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_TAX_RETURN_STATUS_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_type_tax_return_type IS NOT NULL THEN
     IF NOT Val_Num_4(p_isir_rec.p_type_tax_return_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_TYPE_TAX_RETURN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_elig_1040aez_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.p_elig_1040aez_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_ELIG_1040AEZ_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.p_adjusted_gross_income_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.p_adjusted_gross_income_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_ADJUSTED_GROSS_INCOME_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.p_taxes_paid_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.p_taxes_paid_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_TAXES_PAID_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
  IF p_isir_rec.p_exemptions_amt IS NOT NULL THEN
     IF NOT Val_Num(2,p_isir_rec.p_exemptions_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_EXEMPTIONS_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.f_income_work_amt IS NOT NULL THEN
     IF NOT Val_Int(p_isir_rec.f_income_work_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('F_INCOME_WORK_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.m_income_work_amt IS NOT NULL THEN
     IF NOT Val_Int(p_isir_rec.m_income_work_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_NUMBER');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('M_INCOME_WORK_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.p_income_wsa_amt IS NOT NULL THEN
     IF NOT Val_Num(5,p_isir_rec.p_income_wsa_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_INCOME_WSA_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

   IF p_isir_rec.p_income_wsb_amt IS NOT NULL THEN
     IF NOT Val_Num(5,p_isir_rec.p_income_wsb_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_INCOME_WSB_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.p_income_wsc_amt IS NOT NULL THEN
     IF NOT Val_Num(5,p_isir_rec.p_income_wsc_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_INCOME_WSC_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
  IF p_isir_rec.p_investment_networth_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.p_investment_networth_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_INVESTMENT_NETWORTH_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.p_business_networth_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.p_business_networth_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_BUSINESS_NETWORTH_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.p_cash_saving_amt IS NOT NULL THEN
     IF NOT Val_Num(6,p_isir_rec.p_cash_saving_amt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('P_CASH_SAVING_AMT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

   IF p_isir_rec.s_family_members_num IS NOT NULL THEN
     IF NOT Val_Num_NonZero(p_isir_rec.s_family_members_num,2) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_FAMILY_MEMBERS_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.s_in_college_num IS NOT NULL THEN
     IF NOT Val_Num_NonZero(p_isir_rec.s_in_college_num,1) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_IN_COLLEGE_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
    IF p_isir_rec.first_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.first_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIRST_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.first_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.first_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIRST_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.second_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.second_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SECOND_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.second_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.second_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SECOND_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;

    IF p_isir_rec.third_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.third_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('THIRD_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.third_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.third_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('THIRD_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
    IF p_isir_rec.fourth_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.fourth_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FOURTH_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.fourth_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.fourth_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FOURTH_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.fifth_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.fifth_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIFTH_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.fifth_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.fifth_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FIFTH_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.sixth_college_cd IS NOT NULL THEN
     IF NOT Val_School_Cd(p_isir_rec.sixth_college_cd,6) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_SCH_CODE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SIXTH_COLLEGE_CD');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.sixth_house_plan_type IS NOT NULL THEN
     IF NOT Val_Num_3(p_isir_rec.sixth_house_plan_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SIXTH_HOUSE_PLAN_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;
   IF p_isir_rec.signed_by_type IS NOT NULL THEN
     IF NOT Val_Signed_By(p_isir_rec.signed_by_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SIGNED_BY_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.preparer_ssn_txt IS NOT NULL THEN
     IF NOT Val_Char_set(p_isir_rec.preparer_ssn_txt,9,'0123456789') THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INVALID_PAR_SSN');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PREPARER_SSN_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.preparer_emp_id_number_txt IS NOT NULL THEN
     IF NOT Val_Num(9,p_isir_rec.preparer_emp_id_number_txt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_P_EMP_ID');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PREPARER_EMP_ID_NUMBER_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.preparer_sign_flag IS NOT NULL THEN
     IF NOT Val_Num_1(p_isir_rec.preparer_sign_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PREPARER_SIGN_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.dependency_override_type IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.dependency_override_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('DEPENDENCY_OVERRIDE_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.faa_adjustment_type IS NOT NULL THEN
     IF NOT Val_Num_2(p_isir_rec.faa_adjustment_type) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FAA_ADJUSTMENT_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.early_analysis_flag IS NOT NULL THEN
      IF NOT Val_Num_1(p_isir_rec.early_analysis_flag) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('EARLY_ANALYSIS_FLAG');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
      END IF;
    END IF;
   ELSE
       IF p_isir_rec.early_analysis_flag IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='EARLY_ANALYSIS_FLAG';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
   END IF;
    IF p_isir_rec.drn_num IS NOT NULL THEN
     IF NOT Val_Num_NonZero(p_isir_rec.drn_num,4) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_DRN');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('DRN_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
    IF p_isir_rec.orig_name_id_txt IS NOT NULL THEN
     IF NOT Val_Alpha(p_isir_rec.orig_name_id_txt,2) THEN
     p_status:=FALSE;
     fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

     indx:= indx+1;
     p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('ORIG_NAME_ID_TXT');
     p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF p_isir_rec.s_email_address_txt IS NOT NULL THEN
     IF NOT Val_Email(50,p_isir_rec.s_email_address_txt) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_EMAIL_ADD');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('S_EMAIL_ADDRESS_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.input_record_type IS NOT NULL THEN
       IF NOT Val_Input_Rec_type(p_isir_rec.input_record_type) THEN
           p_status:=FALSE;
           fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

           indx:= indx+1;
           p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('INPUT_RECORD_TYPE');
           p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
  ELSE
     IF p_isir_rec.input_record_type IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('INPUT_RECORD_TYPE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;
   IF p_isir_rec.transaction_num_txt IS NOT NULL THEN
     IF NOT Val_Num_NonZero(p_isir_rec.transaction_num_txt,2) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_INVALID_TRAN_NUM');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('TRANSACTION_NUM_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
   END IF;
   IF NOT Val_Num_NonZero(p_isir_rec.serial_num,5) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');

         indx:= indx+1;
         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('SERIAL_NUM');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
   END IF;

 IF g_sys_award_year IN ('0405','0506','0607') THEN
     IF p_isir_rec.father_first_name_initial_txt IS NOT NULL THEN
       IF NOT Val_Alpha(p_isir_rec.father_first_name_initial_txt,1) OR p_isir_rec.father_first_name_initial_txt <> UPPER(p_isir_rec.father_first_name_initial_txt)  THEN
         p_status:=FALSE;
         message := NULL;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');
         message := fnd_message.get;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_INITIAL');
         message := message || fnd_message.get;
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHER_FIRST_NAME_INITIAL_TXT');
         p_igf_ap_message_table(indx).msg_text := message;

       END IF;
     END IF;
  ELSE
     IF p_isir_rec.father_first_name_initial_txt IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHER_FIRST_NAME_INITIAL_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;

  IF g_sys_award_year IN ('0405','0506','0607') THEN
     IF p_isir_rec.father_step_father_birth_date IS NOT NULL THEN
       IF NOT Val_date(TO_CHAR(p_isir_rec.father_step_father_birth_date,'YYYYMMDD')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_DOB');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHER_STEP_FATHER_BIRTH_DATE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
  ELSE
     IF p_isir_rec.father_step_father_birth_date IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('FATHER_STEP_FATHER_BIRTH_DATE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;
  IF g_sys_award_year IN ('0405','0506','0607') THEN
     IF p_isir_rec.mother_first_name_initial_txt IS NOT NULL THEN
       IF NOT Val_Alpha(p_isir_rec.mother_first_name_initial_txt,1) OR p_isir_rec.mother_first_name_initial_txt <> UPPER(p_isir_rec.mother_first_name_initial_txt)  THEN
         p_status:=FALSE;
         message := NULL;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_VALUE');
         message := fnd_message.get;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_INITIAL');
         message := message || fnd_message.get;
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHER_FIRST_NAME_INITIAL_TXT');
         p_igf_ap_message_table(indx).msg_text := message;

       END IF;
     END IF;
  ELSE
     IF p_isir_rec.mother_first_name_initial_txt IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHER_FIRST_NAME_INITIAL_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;
  IF g_sys_award_year IN ('0405','0506','0607') THEN
     IF p_isir_rec.mother_step_mother_birth_date IS NOT NULL THEN
       IF NOT Val_date(TO_CHAR(p_isir_rec.mother_step_mother_birth_date,'YYYYMMDD')) THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_DOB');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHER_STEP_MOTHER_BIRTH_DATE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
       END IF;
     END IF;
  ELSE
     IF p_isir_rec.mother_step_mother_birth_date IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('MOTHER_STEP_MOTHER_BIRTH_DATE');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;
  IF g_sys_award_year IN ('0405','0506','0607') THEN
    IF p_isir_rec.parents_email_address_txt IS NOT NULL THEN
        IF NOT Val_Email(50,p_isir_rec.parents_email_address_txt) THEN
                           p_status:=FALSE;
                           fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_EMAIL_ADD');
                           indx:= indx+1;

                           p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PARENTS_EMAIL_ADDRESS_TXT');
                           p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
        END IF;
    END IF;
  ELSE
     IF p_isir_rec.parents_email_address_txt IS NOT NULL THEN
         p_status:=FALSE;
         fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');
         indx:= indx+1;

         p_igf_ap_message_table(indx).field_name:= p_l_to_i_col('PARENTS_EMAIL_ADDRESS_TXT');
         p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;


  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
     IF p_isir_rec.cps_pushed_isir_flag IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='CPS_PUSHED_ISIR_FLAG';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
     END IF;
  END IF;

 IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.electronic_transaction_type IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='ELECTRONIC_TRANSACTION_TYPE';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;

    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.sar_c_change_type IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='SAR_C_CHANGE_TYPE';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.father_ssn_match_type IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='FATHER_SSN_MATCH_TYPE';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.mother_ssn_match_type IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='MOTHER_SSN_MATCH_TYPE';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year NOT IN ('0405','0506','0607') THEN
    IF p_isir_rec.reject_override_g_flag IS NOT NULL THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_REQ_NULL_VALUE');

        p_igf_ap_message_table(indx).field_name:='REJECT_OVERRIDE_G_FLAG';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  IF g_sys_award_year IN ('0203','0304') THEN
    IF p_isir_rec.dhs_verification_num_txt IS NOT NULL AND NOT Val_Num(15,p_isir_rec.dhs_verification_num_txt) THEN
        p_status:=FALSE;
        indx:= indx+1;
        fnd_message.set_name('IGF','IGF_AP_SAR_INVALID_PTIVE_NUM');

        p_igf_ap_message_table(indx).field_name:='DHS_VERIFICATION_NUM_TXT';
        p_igf_ap_message_table(indx).msg_text:=fnd_message.get;
    END IF;
  END IF;

  END validate_isir_rec;


FUNCTION remove_spl_chr(pv_ssn        IN igf_ap_isir_ints_all.CURRENT_SSN_TXT%TYPE)
RETURN VARCHAR2
IS
  /*
  ||  Created By : rasingh
  ||  Created On : 19-Apr-2002
  ||  Purpose :        Strips the special charactes from SSN and returns just the number
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   ln_ssn VARCHAR2(20);

BEGIN

   SELECT TRANSLATE (pv_ssn,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890')
   INTO   ln_ssn
   FROM   dual;

   RETURN ln_ssn;

EXCEPTION
   WHEN        others THEN
   RETURN '-1';

END remove_spl_chr;

  PROCEDURE main (         errbuf         IN OUT  NOCOPY VARCHAR2,
                           retcode        IN OUT  NOCOPY NUMBER,
                           p_award_year   IN VARCHAR2,
                           p_batch_id     IN NUMBER,
                           p_del_int      IN VARCHAR2,
                           p_cps_import   IN VARCHAR2 )
            IS
     /***************************************************************
       Created By :       rasahoo
       Date Created By  : 03-June-2003
       Purpose    : To Import legscy ISIR record
       Known Limitations,Enhancements or Remarks
       Change History :
       Who       When          What
     tsailaja  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
       veramach  11-Dec-2003   Bug # 3184891 Removed references to igf_ap_gen. write_log and added common logging
       bkkumar   05-Aug-2003   Bug# 3025723 Added code to prefix the transaction_num_txt
                               with '0' if it is of length one.

     ***************************************************************/
  CURSOR c_award_det(p_ci_cal_type        igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number igs_ca_inst.sequence_number%TYPE
                    ) IS
             SELECT
               BATCH_YEAR   batch_year,
               AWARD_YEAR_STATUS_CODE,
               SYS_AWARD_YEAR
             FROM
                  IGF_AP_BATCH_AW_MAP
             WHERE
                  CI_CAL_TYPE = p_ci_cal_type
             AND  CI_SEQUENCE_NUMBER = p_ci_sequence_number;

   CURSOR c_igf_ap_fa_base_rec(p_person_id       NUMBER,
                               p_ci_cal_type     VARCHAR2,
                               p_sequence_number VARCHAR2
                               )
            IS
               SELECT
                     base_id
               FROM
                    igf_ap_fa_base_rec fa
               WHERE
                    fa.ci_cal_type =p_ci_cal_type
               AND  fa.ci_sequence_number = p_sequence_number
               AND  fa.person_id = p_person_id;



  CURSOR c_transaction_num(p_base_id         NUMBER,
                           p_transaction_num VARCHAR2)
  IS
   SELECT
       im.transaction_num
    FROM
       igf_ap_isir_matched im
    WHERE
       im.base_id =p_base_id  and
       im.transaction_num = p_transaction_num and
       rownum = 1  ;

   CURSOR c_lkup_values(p_lookup_code  VARCHAR2 )
   IS
     SELECT   meaning
     FROM     igf_aw_lookups_view
     WHERE    lookup_type ='IGF_AW_LOOKUPS_MSG'
     AND lookup_code =p_lookup_code
     AND enabled_flag = 'Y' ;

  CURSOR  c_nslds_data(p_base_id NUMBER)
  IS
    SELECT
      NSLDS.ROW_ID,
      NSLDS.NSLDS_ID,
      NSLDS.NSLDS_TRANSACTION_NUM
    FROM
      IGF_AP_NSLDS_DATA NSLDS
    WHERE
      BASE_ID = p_base_id;


   -- Get the  record status

  CURSOR c_get_rowid(p_base_id NUMBER,
                      p_transn_num VARCHAR2)
  IS
   SELECT rowid,isir_id
     FROM igf_ap_isir_matched
    WHERE transaction_num=p_transn_num
      AND base_id=p_base_id
      AND system_record_type='ORIGINAL';

    -- cursor to get alternate code for award year
    CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ) IS
       SELECT alternate_code
         FROM igs_ca_inst
        WHERE cal_type        = cp_ci_cal_type
          AND sequence_number = cp_ci_sequence_number ;

        l_alternate_code   igs_ca_inst.alternate_code%TYPE ;


    -- cursor to get sys award year and award year status
    CURSOR c_get_stat(  p_ci_cal_type VARCHAR2,p_ci_sequence_number NUMBER)IS
       SELECT award_year_status_code, sys_award_year
         FROM igf_ap_batch_aw_map   map
        WHERE map.ci_cal_type         = p_ci_cal_type
          AND map.ci_sequence_number  = p_ci_sequence_number ;

         g_award_year_status    igf_ap_batch_aw_map.award_year_status_code%TYPE ;
         l_batch_valid          VARCHAR2(1) ;

         c_get_rowid_rec                  c_get_rowid%ROWTYPE;

         -- Get the details of
         CURSOR c_get_person_id( lv_ssn   VARCHAR2
                     ) IS

         SELECT 'SSN' rec_type,
                api.pe_person_id person_id
           FROM igs_pe_alt_pers_id api,
                igs_pe_person_id_typ pit
          WHERE api.person_id_type        = pit.person_id_type
            AND pit.s_person_id_type = 'SSN'
            AND SYSDATE between api.start_dt AND NVL(api.end_dt,SYSDATE)
            AND api.api_person_id_uf = lv_ssn ;



       c_get_person_id_rec      c_get_person_id%ROWTYPE;




         oss_country_code                 VARCHAR2(5):='US';
         igs_ps_participate_fa_prog       VARCHAR2(25):='Y';
         c_award_det_rec                  c_award_det%ROWTYPE;
         isir_rec                         IGF_AP_ISIR_MATCHED%ROWTYPE;
         c_igf_ap_fa_base_rec_rec         c_igf_ap_fa_base_rec%ROWTYPE;
         c_transaction_num_rec            c_transaction_num%ROWTYPE;
         b_batch_year_found               BOOLEAN :=FALSE;
         l_ci_cal_type                    VARCHAR2(10);
         l_ci_sequence_number             NUMBER;
         l_oss_country_code               VARCHAR2(5);
         l_igs_ps_participate_fa_prog     VARCHAR2(25);
         p_validation_status              BOOLEAN :=TRUE;
         c_lkup_values_err_rec            c_lkup_values%ROWTYPE;
         c_lkup_values_pn_rec             c_lkup_values%ROWTYPE;
         c_lkup_values_bi_rec             c_lkup_values%ROWTYPE;

         c_nslds_data_rec                 c_nslds_data%ROWTYPE;


         l_igf_ap_message_table           igf_ap_message_table;

         counter                          NUMBER;
         l_rowid                          VARCHAR2(30):=NULL;
         l_isir_id                        NUMBER:=NULL;
         l_base_id                        NUMBER :=NULL;
         l_nslds_id                       NUMBER:=NULL;
         pv_isir_id                        NUMBER:=NULL;

         lv_person_number                 c_int_data_rec.person_number%TYPE;
         lv_ci_cal_type                   VARCHAR2(10);
         lv_ci_sequence_number            NUMBER;
         lv_person_id                     NUMBER;
         lv_fa_base_id                    c_igf_ap_fa_base_rec_rec.base_id%TYPE;

         l_ret_profile                    VARCHAR2(2);
         l_updated                        VARCHAR2(1):='N';
         l_num_recrd_passed               NUMBER:=0;
         l_num_recrd_failed               NUMBER:=0;
         l_num_recrd_processed            NUMBER := 0;
         l_valid_for_dml                  VARCHAR2(2);
         l_dup_tran_num_exists            VARCHAR2(2);
         l_update                         VARCHAR2(2);
         l_new_base_created               VARCHAR2(2) ;
         indx                             NUMBER;
         -- Get the details of sys award year
         CURSOR c_sys_aw_yr(p_ci_cal_type VARCHAR2,p_ci_sequence_number NUMBER)
         IS
         SELECT SYS_AWARD_YEAR
         FROM IGF_AP_BATCH_AW_MAP
         WHERE CI_CAL_TYPE = p_ci_cal_type
         AND   CI_SEQUENCE_NUMBER=p_ci_sequence_number;
         c_sys_aw_yr_rec  c_sys_aw_yr%ROWTYPE;
         TYPE message_rec IS RECORD
                  (msg_text      VARCHAR2(4000));
         TYPE l_message_table IS TABLE OF message_rec
                              INDEX BY BINARY_INTEGER;
         g_message_table          l_message_table;
         lv_ssn                   VARCHAR2(30);
         lv_fname                 VARCHAR2(30);
         lv_lname                 VARCHAR2(30);
         l_value                  BOOLEAN ;
         l_award_fmly_contribution_type VARCHAR2(1);

 BEGIN
    igf_aw_gen.set_org_id(NULL);
        g_import_type := p_cps_import;
        l_ci_cal_type          := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
        l_ci_sequence_number   := TO_NUMBER(SUBSTR(p_award_year,11));
        IF NVL(p_cps_import,'N') = 'Y' THEN
           l_cps_log := 'Y' ;
        ELSE
           l_cps_log := 'N' ;
        END IF;

        -- Get the Award Year Alternate Code
        l_alternate_code := NULL;
        OPEN  c_alternate_code( l_ci_cal_type, l_ci_sequence_number ) ;
        FETCH c_alternate_code INTO l_alternate_code ;
        CLOSE c_alternate_code ;

        -- Log input params
        log_input_params(  p_batch_id, l_alternate_code,  p_del_int,p_cps_import);

        c_lkup_values_err_rec := NULL;
        OPEN  c_lkup_values('ERROR');
        FETCH c_lkup_values INTO c_lkup_values_err_rec;
        CLOSE c_lkup_values;
        l_error := c_lkup_values_err_rec.meaning;

        IF NVL(p_cps_import,'N') = 'Y' THEN
           OPEN  c_lkup_values('SSN');
        ELSE
           OPEN  c_lkup_values('PERSON_NUMBER');
        END IF;
           c_lkup_values_pn_rec := NULL;
           FETCH c_lkup_values INTO c_lkup_values_pn_rec;
           CLOSE c_lkup_values;

        c_lkup_values_bi_rec := NULL;
        OPEN  c_lkup_values('BATCH_ID');
        FETCH c_lkup_values INTO c_lkup_values_bi_rec;
        CLOSE c_lkup_values;

        -- Check if the  profiles are set
        l_ret_profile:=igf_ap_gen.check_profile;

        IF l_ret_profile <> 'Y' THEN

          -- check if country code is not'US' AND does not participate in financial aidprogram  THEN
          -- write into the log file and exit process

          fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
          fnd_file.put(fnd_file.log,c_lkup_values_err_rec.meaning || l_blank || fnd_message.get);
          RETURN;

        END IF;

        /******************************
        batch level validations
        ******************************/

        -- Get Award Year Status
        OPEN  c_get_stat( l_ci_cal_type,l_ci_sequence_number) ;
        FETCH c_get_stat INTO g_award_year_status, g_sys_award_year ;
        -- check validity of award year
        IF c_get_stat%NOTFOUND THEN
            -- Award Year setup tampered .... Log a message
            fnd_message.set_name('IGF','IGF_AP_AWD_YR_NOT_FOUND');
            fnd_message.set_token('P_AWARD_YEAR', l_alternate_code);
            fnd_file.put_line(fnd_file.log,l_error || l_blank || fnd_message.get);

            RETURN;
        ELSE
            -- Award year exists but is it Open/Legacy Details .... check
            IF g_award_year_status NOT IN ('O','LD') THEN
               fnd_message.set_namE('IGF','IGF_AP_LG_INVALID_STAT');
               fnd_message.set_token('AWARD_STATUS', g_award_year_status);
               fnd_file.put_line(fnd_file.log,l_error || l_blank || fnd_message.get);

               RETURN;
            END IF ;  -- awd ye open or legacy detail chk
        END IF ; -- award year invalid check
        CLOSE c_get_stat ;

        -- check validity of batch
        IF NVL(p_cps_import,'N') <> 'Y' THEN
        l_batch_valid := igf_ap_gen.check_batch ( p_batch_id, 'ISIR') ;
          IF NVL(l_batch_valid,'N') <> 'Y' THEN
              fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
              fnd_file.put_line(fnd_file.log,l_error || l_blank || fnd_message.get);
              RETURN;
          END IF;
        END IF;

             -- Populate the Lookup Types to be validated for each ISIR into a PL/SQL Table
             c_award_det_rec := NULL;
             OPEN c_award_det(l_ci_cal_type,l_ci_sequence_number);
             FETCH c_award_det INTO c_award_det_rec;
             CLOSE c_award_det;

             -- This concatenation done because line length exceeds 250, which is not allowed by GSCC standards
             put_hash_values('IGF_AP_STATE_CODES,IGF_CITIZENSHIP_TYPE,IGF_ST_MARITAL_STAT_TYPE,IGF_ENROLMENT_TYPE,IGF_HIGH_GRAD_LVL_TYPE,IGF_DEG_CERT_TYPE,IGF_AP_GRADE_LEVEL,IGF_DRUG_ELIGIBILITY_TYPE,IGF_TAX_RET_STAT_TYPE,IGF_TAX_FORM_TYPE,'
             ||'IGF_TAX_EXEMPTION_ELIG_TYPE,IGF_P_MARITAL_STAT_TYPE,IGF_AP_HOUSING_STAT,IGF_AP_DEP_STATUS,IGF_AP_ADDRESS_CHANGE_FLAG,IGF_AP_CPS_PUSHED_ISIR_FLAG,IGF_AP_ELECTRONIC_TRANS_TYPE,IGF_AP_SAR_C_CHANGE_TYPE,IGF_AP_PARENTS_SSN_MATCH_TYPE,'
             || 'IGF_AP_LOAN_LIMIT_TYPE,IGF_AP_REJECT_OVERRIDE_FLAG,IGF_AP_ENROLLMENT_STATUS_TYPE',c_award_det_rec.sys_award_year);
              l_debug_str  := l_debug_str || 'Lookups loading complete ' ;
                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_isir_imp_proc.main.debug','c_award_det_rec.batch_year Is: ' || c_award_det_rec.batch_year || ' : ');
                  END IF;

              IF NVL(p_cps_import,'N') = 'Y' THEN
                OPEN c_cps_int_data(c_award_det_rec.batch_year);
                l_cps_log := 'Y' ;
              ELSE
                OPEN c_int_data (p_batch_id);
                l_cps_log := 'N' ;
              END IF;

             LOOP
              BEGIN

                 SAVEPOINT next_record;
                 -- Initialize the variables
                  l_valid_for_dml := 'Y' ;
                  l_dup_tran_num_exists := 'N' ;
                  l_update :=  NULL;
                  l_new_base_created := 'N' ;
                  g_person_print := 'N' ;
                  counter := 0;
                  l_debug_str := NULL;
                  --Check If p_cps_import = 'Y', it indicates that the Import Process has to
                  --run as CPS - Legacy ISIR Import Process else run as  Legacy ISIR Import Process
                  g_message_table.DELETE;


                  IF NVL(p_cps_import,'N') = 'Y' THEN
                         l_cps_int_data_rec := NULL;
                         FETCH c_cps_int_data INTO l_cps_int_data_rec ;
                         IF c_cps_int_data%NOTFOUND THEN
                          EXIT;
                         END IF;
                         p_convert_rec ;
                         l_num_recrd_processed := l_num_recrd_processed + 1;
                   ELSE
                         LOOP
                             c_int_data_rec := NULL;
                             FETCH c_int_data INTO c_int_data_rec;
                             IF c_int_data%NOTFOUND THEN
                                EXIT;
                             END IF;

                          -- Check if the BATCH_YEAR is equal to the Batch Year in the C_AWARD_DET subset.

                             IF c_award_det_rec.batch_year=c_int_data_rec.batch_year_num THEN
                              l_num_recrd_processed := l_num_recrd_processed + 1;
                              EXIT;
                             END IF;
                             fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning || l_blank || c_int_data_rec.person_number);
                             fnd_message.set_name('IGF','IGF_AP_AW_BATCH_NOT_EXISTS');
                             fnd_file.put_line(fnd_file.log,l_error || l_blank || fnd_message.get);
                             FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------------------------');
                             l_num_recrd_processed := l_num_recrd_processed + 1;
                         END LOOP;

                        IF c_int_data%NOTFOUND THEN
                         EXIT;
                        END IF;
                  END IF;

                 --check for the  person id
                 lv_person_id  := NULL;
                 l_value       := NULL;
                 IF NVL(p_cps_import,'N') <> 'Y' THEN
                    lv_person_number:=c_int_data_rec.person_number;
                    l_debug_str := l_debug_str || 'Person Number Is: ' || lv_person_number || ' : ';
                    igf_ap_gen.check_person ( lv_person_number,l_ci_cal_type,l_ci_sequence_number, lv_person_id,lv_fa_base_id );

                    l_debug_str := l_debug_str || 'lv_person_id Is: ' || to_char(lv_person_id) || ' : ' || 'lv_fa_base_id is' || to_char(lv_fa_base_id) || ' : ' ;
                 ELSE
                    lv_ssn   :=  remove_spl_chr(c_int_data_rec.original_ssn_txt) ;
                    l_debug_str := l_debug_str || 'lv_ssn Is: ' || lv_ssn || ' : ';
                    IF lv_ssn IS NOT NULL THEN

                      c_get_person_id_rec := NULL;
                      OPEN c_get_person_id(lv_ssn);
                      FETCH c_get_person_id INTO c_get_person_id_rec;
                      CLOSE c_get_person_id;

                      lv_person_id := c_get_person_id_rec.person_id;
                      l_value := igf_ap_matching_process_pkg.is_fa_base_record_present(lv_person_id,
                                                              c_int_data_rec.batch_year_num,
                                                              lv_fa_base_id        );
                    END IF;
                 END IF;
                 l_debug_str := l_debug_str || 'lv_person_id Is: ' || to_char(lv_person_id) || ' : ';
                 IF lv_person_id IS NULL THEN

                   l_valid_for_dml := 'N' ;

                   IF  NVL(p_cps_import,'N') = 'Y' THEN
                       --Log a message in the logging table that Person does not exist in OSS (IGF_AP_PE_SSN_NOT_EXIST)
                       --Update the Legacy Interface Table column IMPORT_STATUS_FLAG to "E" implying Error.

                         l_debug_str := l_debug_str || lv_person_number || 'person does not exist' || c_int_data_rec.original_ssn_txt;
                         counter := counter+1;
                         fnd_message.set_name('IGF','IGF_AP_PE_SSN_NOT_EXIST');
                         fnd_message.set_token('P_SSN',c_int_data_rec.original_ssn_txt);
                         g_message_table(counter).msg_text:=fnd_message.get;
                    ELSE
                         l_debug_str := l_debug_str || 'person id is null - ' || c_int_data_rec.person_number ;
                      -- Log a message in the logging table that Person does not exist in OSS (IGF_AP_PE_NOT_EXIST)
                       --Update the Legacy Interface Table column IMPORT_STATUS_FLAG to "E" implying Error.

                         fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
                         counter := counter+1;
                         g_message_table(counter).msg_text:=fnd_message.get;

                         UPDATE igf_ap_li_isir_ints
                         SET    IMPORT_STATUS_TYPE='E'
                         WHERE  ROWID = c_int_data_rec.ROW_ID ;
                   END IF;
                 END IF;


                 IF  l_valid_for_dml = 'Y' THEN
                     IF lv_fa_base_id IS NULL THEN
                      --Base record does not exist so create base record.
                       l_debug_str := l_debug_str || lv_person_number || ' base record created';

                       IF (c_int_data_rec.secondary_efc_amt IS NOT NULL) AND (c_int_data_rec.secondary_efc_amt < NVL(c_int_data_rec.primary_efc_amt,0)) THEN
                         l_award_fmly_contribution_type := '2';
                       ELSE
                         l_award_fmly_contribution_type := '1';
                       END IF;
                        create_base_rec(l_ci_cal_type,
                                        lv_person_id,
                                        l_ci_sequence_number,
                                        c_int_data_rec.nslds_match_type,
                                        lv_fa_base_id,
                                        l_award_fmly_contribution_type
                                       );
                        l_new_base_created := 'Y' ;

                     END IF;
                 END IF;
                -- Bug# 3025723
                 IF LENGTH(c_int_data_rec.transaction_num_txt) = 1 THEN
                    c_int_data_rec.transaction_num_txt := '0' || c_int_data_rec.transaction_num_txt;
                 END IF;

                 IF ( l_new_base_created <> 'Y'  AND l_valid_for_dml = 'Y' ) THEN
                   -- Implies that no new base ID was created so the person might have transactions
                   c_transaction_num_rec := NULL;
                   OPEN c_transaction_num(lv_fa_base_id,c_int_data_rec.transaction_num_txt);
                   FETCH c_transaction_num INTO c_transaction_num_rec;
                   CLOSE c_transaction_num;

                   IF c_transaction_num_rec.transaction_num =  c_int_data_rec.transaction_num_txt THEN
                      l_debug_str := l_debug_str || lv_person_number || ' duplication transaction number exist';
                      l_dup_tran_num_exists := 'Y' ;
                   END IF;
                 END IF;

                 IF l_dup_tran_num_exists = 'Y' THEN
                    IF c_int_data_rec.import_record_type <> 'U' AND  l_valid_for_dml = 'Y' THEN
                      l_valid_for_dml := 'N' ;
                      l_update :=  'N';
                      fnd_message.set_name('IGF','IGF_AP_TRAN_NUM_EXISTS');
                      fnd_message.set_token('TRAN_NUM',c_int_data_rec.transaction_num_txt);
                      counter := counter+1;
                      g_message_table(counter).msg_text:=fnd_message.get;
                    ELSE
                      l_update :=  'Y';
                    END IF;
                 ELSE -- Same transaction num does not exists/ So only Insert is possible

                   IF  c_int_data_rec.import_record_type = 'U'  AND  l_valid_for_dml = 'Y' THEN

                          -- Update not possible as no such record exists to update

                         l_debug_str := l_debug_str || lv_person_number || 'Update not possible as no such record exists to update ';
                         fnd_message.set_name('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                         counter := counter+1;
                         g_message_table(counter).msg_text:=fnd_message.get;

                         l_valid_for_dml := 'N' ;
                         l_update :=  'N';
                   END IF;
                 END IF;

                --validate legacy record
                 validate_isir_rec(c_int_data_rec,p_validation_status,l_igf_ap_message_table );

                 IF  NOT p_validation_status THEN
                   l_debug_str := l_debug_str || lv_person_number || 'Failed validate_isir_rec ';
                   l_valid_for_dml := 'N';
                 END IF;

                 IF  p_validation_status THEN
                   IF l_update =  'Y' AND  l_valid_for_dml ='Y'  THEN
                     -- Update ISIS matched table
                     c_get_rowid_rec := NULL;
                     OPEN c_get_rowid(lv_fa_base_id,c_int_data_rec.transaction_num_txt);
                     FETCH c_get_rowid INTO c_get_rowid_rec;
                     CLOSE c_get_rowid;

                     update_row(c_int_data_rec, lv_fa_base_id, c_get_rowid_rec.rowid,c_get_rowid_rec.isir_id);
                     pv_isir_id := c_get_rowid_rec.isir_id;
                     l_debug_str := l_debug_str || lv_person_number || ' ISIR Record updated ';
                     l_num_recrd_passed := l_num_recrd_passed + 1;
                   ELSIF l_valid_for_dml ='Y' THEN
                      --Insert into isir matched table
                       insert_row( c_int_data_rec, lv_fa_base_id,pv_isir_id);
                       l_debug_str := l_debug_str || lv_person_number || 'ISIR Record inserted ';
                       l_num_recrd_passed := l_num_recrd_passed + 1;
                   END IF;
                 END IF;

                   c_nslds_data_rec := null;

                    IF  p_validation_status THEN
                        IF l_valid_for_dml ='Y' THEN
                             c_nslds_data_rec := NULL;
                             OPEN c_nslds_data(lv_fa_base_id);
                             FETCH c_nslds_data INTO c_nslds_data_rec;
                             CLOSE c_nslds_data;
                             IF  c_nslds_data_rec.nslds_id IS NULL THEN
                               --  insert nslds data as the student does not have an NSLDS record
                                nslds_insert_row(c_int_data_rec, lv_fa_base_id, pv_isir_id);
                                l_debug_str := l_debug_str || lv_person_number || ' NSLDS Record inserted ';
                             ELSE
                                IF  c_nslds_data_rec.nslds_transaction_num < TO_NUMBER(c_int_data_rec.transaction_num_txt)   THEN
                                    -- update nsllds data because a NEW ISIR has come in
                                   nslds_update_row(c_int_data_rec, lv_fa_base_id, c_nslds_data_rec.row_id, c_nslds_data_rec.nslds_id, pv_isir_id );
                                  l_debug_str := l_debug_str || lv_person_number || ' NSLDS Record updated ';
                                END IF;
                              END IF;
                        END IF;
                    END IF;

                   IF p_validation_status AND l_valid_for_dml ='Y' THEN
                       IF  NVL(p_cps_import,'N') <> 'Y' THEN
                         IF p_del_int ='Y' THEN
                                --Check if the P_DEL_INT parameter is set to "Y"
                                --If it is set to Y then Delete the Interface Record
                                DELETE FROM igf_ap_li_isir_ints
                                WHERE  ROWID = c_int_data_rec.ROW_ID ;
                          ELSE
                               --Update the Legacy Interface Table column IMPORT_STATUS_FLAG with 'I' implying Imported
                               UPDATE igf_ap_li_isir_ints
                               SET    IMPORT_STATUS_TYPE='I'
                               WHERE  ROWID = c_int_data_rec.ROW_ID ;
                          END IF;
                       ELSE -- CPS IMPORT
                            UPDATE    igf_ap_isir_ints_all
                               SET    RECORD_STATUS ='MATCHED'
                             WHERE  ROWID = c_int_data_rec.ROW_ID ;
                      END IF;
                   END IF;

                   IF l_valid_for_dml <> 'Y' AND NVL(p_cps_import,'N') <> 'Y' THEN
                             UPDATE igf_ap_li_isir_ints
                             SET    IMPORT_STATUS_TYPE='E'
                             WHERE  ROWID = c_int_data_rec.ROW_ID ;
                   END IF;

                   IF l_valid_for_dml <> 'Y' THEN
                      IF  NVL(p_cps_import,'N') <> 'Y' THEN
                          fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning || l_blank || c_int_data_rec.person_number);
                      ELSE
                          fnd_file.put_line(fnd_file.log,c_lkup_values_pn_rec.meaning || l_blank || c_int_data_rec.original_ssn_txt);
                      END IF;

                      FOR indx_1 IN 1 .. counter
                      LOOP
                       fnd_file.put_line(fnd_file.log,l_error || l_blank || g_message_table(indx_1).msg_text);
                      END LOOP;

                      IF NOT p_validation_status THEN
                        print_message(l_igf_ap_message_table );
                      END IF;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------------------------------------------------------------');
                   END IF;
                     -- write debugging message to log table
                     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_isir_imp_proc.main.debug',l_debug_str);
                     END IF;

                 EXCEPTION
                 WHEN OTHERS THEN
                  -- write debugging message to log table
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_isir_imp_proc.main.begin.debug',l_debug_str||SQLERRM);
                  END IF;
                  fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
                  fnd_message.set_token('NAME','IGF_AP_LI_ISIR_IMP_PROC.MAIN'||SQLERRM);
                  fnd_file.put_line(fnd_file.log,fnd_message.get );
                  ROLLBACK TO next_record;
                 END;
                 COMMIT;
               END LOOP;

           -- Close cursor
             IF NVL(p_cps_import,'N') = 'Y' THEN
                CLOSE c_cps_int_data;
             ELSE
                CLOSE c_int_data ;
             END IF;

      fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
      fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' ||l_num_recrd_processed);
      fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
      fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' ||l_num_recrd_passed);
      fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
      l_num_recrd_failed := l_num_recrd_processed - l_num_recrd_passed;
      fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_num_recrd_failed);
  EXCEPTION
    WHEN OTHERS THEN
      -- write debugging message to log table
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_isir_imp_proc.main.debug',l_debug_str||SQLERRM);
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_LI_ISIR_IMP_PROC.MAIN'||SQLERRM);
      fnd_file.put_line(fnd_file.log,fnd_message.get );
  ROLLBACK TO next_record;
  END main;

 PROCEDURE  cps_import( errbuf         IN OUT  NOCOPY VARCHAR2,
                   retcode             IN OUT  NOCOPY NUMBER,
                   p_award_year        IN VARCHAR2
            ) AS
    /*
    ||  Created By : rasahoo
    ||  Created On :
    ||  Purpose : To Import legscy  CPS ISIR record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
  ||  tsailaja      13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  (reverse chronological order - newest change first)
    */

  BEGIN
  -- Make a call to the Legacy Import Process
  igf_aw_gen.set_org_id(NULL);
               main (      errbuf         => ERRBUF,
                           retcode        => RETCODE,
                           p_award_year   => p_award_year,
                           p_batch_id     => NULL,
                           p_del_int      => 'N',
                           p_cps_import   => 'Y') ;


  END cps_import;
  END IGF_AP_LI_ISIR_IMP_PROC;

/
