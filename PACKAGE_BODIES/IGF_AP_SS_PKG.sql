--------------------------------------------------------
--  DDL for Package Body IGF_AP_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_SS_PKG" AS
/* $Header: IGFAP30B.pls 120.4 2006/04/19 04:22:53 azmohamm ship $ */

PROCEDURE set_internal_isir (
        p_isir_id IN IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE,
        p_ret_isir_id IN OUT NOCOPY IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE
  )IS
      /*
  ||  Created By : cdcruz
  ||  Created On : 27-NOV-2002
  ||  Purpose : To be used for all self service wrappers
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  azmohamm     19-Apr-2006   4950206: Copied the verification item values
  ||                             to the internal ISIR record
  ||  bkkumar      15-Dec-2003   2826844: Added UPDATE NOWAIT to the cursor
  ||                             chk_internal so that it will throw exception
  ||                             if the row is locked and also it will return
  ||                             p_ret_isir_id = -2 . Also after creating the
  ||                             internal record it will commit and also obtain
  ||                             lock on it so that no one else can update the same
  ||                             record.
  ||  asbala       19-nov-2003   3026594: FA128 - ISIR Federal Updates 04- 05,
  ||                             modified signature of igf_ap_isir_matched_pkg
  ||  (reverse chronological order - newest change first)
  */

   CURSOR c_isir (l_isir_id igf_ap_isir_matched_all.isir_id%type)
   IS
   SELECT ISIR.*
   FROM IGF_AP_ISIR_MATCHED ISIR
   WHERE ISIR.ISIR_ID = l_isir_id ;

   lv_isir c_isir%rowtype ;

   CURSOR chk_internal (l_base_id igf_ap_isir_matched_all.base_id%type)
   IS
   SELECT isir.rowid row_id,isir.isir_id FROM IGF_AP_ISIR_MATCHED_ALL ISIR
   WHERE
   ISIR.BASE_ID = l_base_id AND
   NVL(ISIR.SYSTEM_RECORD_TYPE,'X') = 'INTERNAL'
   FOR UPDATE NOWAIT;

   lv_chk_internal chk_internal%rowtype ;
   lv_rowid VARCHAR2(30) ;

   CURSOR chk_row_id
   IS
   SELECT isir.rowid row_id
   FROM IGF_AP_ISIR_MATCHED_ALL ISIR
   WHERE
   ISIR.rowid = lv_rowid
   FOR UPDATE NOWAIT;

    CURSOR cur_get_ver_data (pn_base_id number) is
   SELECT lkup.lookup_code col_name,
          verf.item_value col_val
     FROM igf_ap_inst_ver_item verf ,
          igf_ap_fa_base_rec_all fabase ,
          igf_ap_batch_aw_map map ,
          igf_fc_sar_cd_mst sar ,
          igf_lookups_view lkup
    WHERE fabase.base_id = verf.base_id
      AND verf.udf_vern_item_seq_num = 1
      AND map.ci_cal_type = fabase.ci_cal_type
      AND map.ci_sequence_number = fabase.ci_sequence_number
      AND sar.sys_award_year = map.sys_award_year
      AND sar.sar_field_number = verf.isir_map_col
      AND lkup.lookup_type = 'IGF_AP_SAR_FIELD_MAP'
      AND lkup.lookup_code = sar.sar_field_name
      AND NVL(verf.waive_flag,'N') = 'N'
      AND ((verf.item_value IS NOT NULL) OR (verf.item_value IS NULL AND verf.use_blank_flag = 'Y'))
      AND verf.base_id = pn_base_id ;

   pn_isir_id igf_ap_isir_matched_all.isir_id%type ;
   pn_base_id igf_ap_isir_matched_all.base_id%type;

   l_get_ver_data_rec cur_get_ver_data%ROWTYPE;

 BEGIN

  lv_rowid := null;

  OPEN c_isir(p_isir_id) ;
  FETCH c_isir INTO lv_isir ;
  IF c_isir%FOUND THEN
     -- Initialize the package variable with the isir rec values
     igf_ap_batch_ver_prc_pkg.lp_isir_rec := lv_isir;
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','fetched ISIR Detials for ISIR ID: '||lv_isir.isir_id);
     END IF;

     OPEN  cur_get_ver_data ( lv_isir.base_id ) ;
     LOOP
       FETCH cur_get_ver_data  INTO  l_get_ver_data_rec ;
       EXIT WHEN cur_get_ver_data%NOTFOUND;

       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','fetching verification items Item Name: '||l_get_ver_data_rec.col_name||' value:'||l_get_ver_data_rec.col_val);
       END IF;

       EXECUTE IMMEDIATE  'BEGIN igf_ap_batch_ver_prc_pkg.lp_isir_rec.'
                          || l_get_ver_data_rec.col_name || ' := ' ||  '''' || l_get_ver_data_rec.col_val || '''' || ' ; END;' ;
     END LOOP;
     CLOSE cur_get_ver_data ;

     lv_isir := igf_ap_batch_ver_prc_pkg.lp_isir_rec;

       -- Check if the student has an Internal ISIR

       OPEN chk_internal(lv_isir.base_id);
       FETCH chk_internal into lv_chk_internal ;
         IF chk_internal%FOUND THEN

               p_ret_isir_id  := lv_chk_internal.isir_id ;

      igf_ap_isir_matched_pkg.update_row(
                  x_Mode                              => 'R',
                  x_rowid                             => lv_chk_internal.row_id,
                  x_isir_id                           => lv_chk_internal.isir_id,
                  x_base_id                           => lv_isir.base_id,
                  x_batch_year                        => lv_isir.batch_year                       ,
                  x_transaction_num                   => lv_isir.transaction_num                  ,
                  x_current_ssn                       => lv_isir.current_ssn                      ,
                  x_ssn_name_change                   => lv_isir.ssn_name_change                  ,
                  x_original_ssn                      => lv_isir.original_ssn                     ,
                  x_orig_name_id                      => lv_isir.orig_name_id                     ,
                  x_last_name                         => lv_isir.last_name                        ,
                  x_first_name                        => lv_isir.first_name                       ,
                  x_middle_initial                    => lv_isir.middle_initial                   ,
                  x_perm_mail_add                     => lv_isir.perm_mail_add                    ,
                  x_perm_city                         => lv_isir.perm_city                        ,
                  x_perm_state                        => lv_isir.perm_state                       ,
                  x_perm_zip_code                     => lv_isir.perm_zip_code                    ,
                  x_date_of_birth                     => lv_isir.date_of_birth                    ,
                  x_phone_number                      => lv_isir.phone_number                     ,
                  x_driver_license_number             => lv_isir.driver_license_number            ,
                  x_driver_license_state              => lv_isir.driver_license_state             ,
                  x_citizenship_status                => lv_isir.citizenship_status               ,
                  x_alien_reg_number                  => lv_isir.alien_reg_number                 ,
                  x_s_marital_status                  => lv_isir.s_marital_status                 ,
                  x_s_marital_status_date             => lv_isir.s_marital_status_date            ,
                  x_summ_enrl_status                  => lv_isir.summ_enrl_status                 ,
                  x_fall_enrl_status                  => lv_isir.fall_enrl_status                 ,
                  x_winter_enrl_status                => lv_isir.winter_enrl_status               ,
                  x_spring_enrl_status                => lv_isir.spring_enrl_status               ,
                  x_summ2_enrl_status                 => lv_isir.summ2_enrl_status                ,
                  x_fathers_highest_edu_level         => lv_isir.fathers_highest_edu_level        ,
                  x_mothers_highest_edu_level         => lv_isir.mothers_highest_edu_level        ,
                  x_s_state_legal_residence           => lv_isir.s_state_legal_residence          ,
                  x_legal_residence_before_date       => lv_isir.legal_residence_before_date      ,
                  x_s_legal_resd_date                 => lv_isir.s_legal_resd_date                ,
                  x_ss_r_u_male                       => lv_isir.ss_r_u_male                      ,
                  x_selective_service_reg             => lv_isir.selective_service_reg            ,
                  x_degree_certification              => lv_isir.degree_certification             ,
                  x_grade_level_in_college            => lv_isir.grade_level_in_college           ,
                  x_high_school_diploma_ged           => lv_isir.high_school_diploma_ged          ,
                  x_first_bachelor_deg_by_date        => lv_isir.first_bachelor_deg_by_date       ,
                  x_interest_in_loan                  => lv_isir.interest_in_loan                 ,
                  x_interest_in_stud_employment       => lv_isir.interest_in_stud_employment      ,
                  x_drug_offence_conviction           => lv_isir.drug_offence_conviction          ,
                  x_s_tax_return_status               => lv_isir.s_tax_return_status              ,
                  x_s_type_tax_return                 => lv_isir.s_type_tax_return                ,
                  x_s_elig_1040ez                     => lv_isir.s_elig_1040ez                    ,
                  x_s_adjusted_gross_income           => lv_isir.s_adjusted_gross_income          ,
                  x_s_fed_taxes_paid                  => lv_isir.s_fed_taxes_paid                 ,
                  x_s_exemptions                      => lv_isir.s_exemptions                     ,
                  x_s_income_from_work                => lv_isir.s_income_from_work               ,
                  x_spouse_income_from_work           => lv_isir.spouse_income_from_work          ,
                  x_s_toa_amt_from_wsa                => lv_isir.s_toa_amt_from_wsa               ,
                  x_s_toa_amt_from_wsb                => lv_isir.s_toa_amt_from_wsb               ,
                  x_s_toa_amt_from_wsc                => lv_isir.s_toa_amt_from_wsc               ,
                  x_s_investment_networth             => lv_isir.s_investment_networth            ,
                  x_s_busi_farm_networth              => lv_isir.s_busi_farm_networth             ,
                  x_s_cash_savings                    => lv_isir.s_cash_savings                   ,
                  x_va_months                         => lv_isir.va_months                        ,
                  x_va_amount                         => lv_isir.va_amount                        ,
                  x_stud_dob_before_date              => lv_isir.stud_dob_before_date             ,
                  x_deg_beyond_bachelor               => lv_isir.deg_beyond_bachelor              ,
                  x_s_married                         => lv_isir.s_married                        ,
                  x_s_have_children                   => lv_isir.s_have_children                  ,
                  x_legal_dependents                  => lv_isir.legal_dependents                 ,
                  x_orphan_ward_of_court              => lv_isir.orphan_ward_of_court             ,
                  x_s_veteran                         => lv_isir.s_veteran                        ,
                  x_p_marital_status                  => lv_isir.p_marital_status                 ,
                  x_father_ssn                        => lv_isir.father_ssn                       ,
                  x_f_last_name                       => lv_isir.f_last_name                      ,
                  x_mother_ssn                        => lv_isir.mother_ssn                       ,
                  x_m_last_name                       => lv_isir.m_last_name                      ,
                  x_p_num_family_member               => lv_isir.p_num_family_member              ,
                  x_p_num_in_college                  => lv_isir.p_num_in_college                 ,
                  x_p_state_legal_residence           => lv_isir.p_state_legal_residence          ,
                  x_p_state_legal_res_before_dt       => lv_isir.p_state_legal_res_before_dt      ,
                  x_p_legal_res_date                  => lv_isir.p_legal_res_date                 ,
                  x_age_older_parent                  => lv_isir.age_older_parent                 ,
                  x_p_tax_return_status               => lv_isir.p_tax_return_status              ,
                  x_p_type_tax_return                 => lv_isir.p_type_tax_return                ,
                  x_p_elig_1040aez                    => lv_isir.p_elig_1040aez                   ,
                  x_p_adjusted_gross_income           => lv_isir.p_adjusted_gross_income          ,
                  x_p_taxes_paid                      => lv_isir.p_taxes_paid                     ,
                  x_p_exemptions                      => lv_isir.p_exemptions                     ,
                  x_f_income_work                     => lv_isir.f_income_work                    ,
                  x_m_income_work                     => lv_isir.m_income_work                    ,
                  x_p_income_wsa                      => lv_isir.p_income_wsa                     ,
                  x_p_income_wsb                      => lv_isir.p_income_wsb                     ,
                  x_p_income_wsc                      => lv_isir.p_income_wsc                     ,
                  x_p_investment_networth             => lv_isir.p_investment_networth            ,
                  x_p_business_networth               => lv_isir.p_business_networth              ,
                  x_p_cash_saving                     => lv_isir.p_cash_saving                    ,
                  x_s_num_family_members              => lv_isir.s_num_family_members             ,
                  x_s_num_in_college                  => lv_isir.s_num_in_college                 ,
                  x_first_college                     => lv_isir.first_college                    ,
                  x_first_house_plan                  => lv_isir.first_house_plan                 ,
                  x_second_college                    => lv_isir.second_college                   ,
                  x_second_house_plan                 => lv_isir.second_house_plan                ,
                  x_third_college                     => lv_isir.third_college                    ,
                  x_third_house_plan                  => lv_isir.third_house_plan                 ,
                  x_fourth_college                    => lv_isir.fourth_college                   ,
                  x_fourth_house_plan                 => lv_isir.fourth_house_plan                ,
                  x_fifth_college                     => lv_isir.fifth_college                    ,
                  x_fifth_house_plan                  => lv_isir.fifth_house_plan                 ,
                  x_sixth_college                     => lv_isir.sixth_college                    ,
                  x_sixth_house_plan                  => lv_isir.sixth_house_plan                 ,
                  x_date_app_completed                => lv_isir.date_app_completed               ,
                  x_signed_by                         => lv_isir.signed_by                        ,
                  x_preparer_ssn                      => lv_isir.preparer_ssn                     ,
                  x_preparer_emp_id_number            => lv_isir.preparer_emp_id_number           ,
                  x_preparer_sign                     => lv_isir.preparer_sign                    ,
                  x_transaction_receipt_date          => lv_isir.transaction_receipt_date         ,
                  x_dependency_override_ind           => lv_isir.dependency_override_ind          ,
                  x_faa_fedral_schl_code              => lv_isir.faa_fedral_schl_code             ,
                  x_faa_adjustment                    => lv_isir.faa_adjustment                   ,
                  x_input_record_type                 => lv_isir.input_record_type                ,
                  x_serial_number                     => lv_isir.serial_number                    ,
                  x_batch_number                      => lv_isir.batch_number                     ,
                  x_early_analysis_flag               => lv_isir.early_analysis_flag              ,
                  x_app_entry_source_code             => lv_isir.app_entry_source_code            ,
                  x_eti_destination_code              => lv_isir.eti_destination_code             ,
                  x_reject_override_b                 => lv_isir.reject_override_b                ,
                  x_reject_override_n                 => lv_isir.reject_override_n                ,
                  x_reject_override_w                 => lv_isir.reject_override_w                ,
                  x_assum_override_1                  => lv_isir.assum_override_1                 ,
                  x_assum_override_2                  => lv_isir.assum_override_2                 ,
                  x_assum_override_3                  => lv_isir.assum_override_3                 ,
                  x_assum_override_4                  => lv_isir.assum_override_4                 ,
                  x_assum_override_5                  => lv_isir.assum_override_5                 ,
                  x_assum_override_6                  => lv_isir.assum_override_6                 ,
                  x_dependency_status                 => lv_isir.dependency_status                ,
                  x_s_email_address                   => lv_isir.s_email_address                  ,
                  x_nslds_reason_code                 => lv_isir.nslds_reason_code                ,
                  x_app_receipt_date                  => lv_isir.app_receipt_date                 ,
                  x_processed_rec_type                => lv_isir.processed_rec_type               ,
                  x_hist_correction_for_tran_id       => lv_isir.hist_correction_for_tran_id      ,
                  x_system_generated_indicator        => lv_isir.system_generated_indicator       ,
                  x_dup_request_indicator             => lv_isir.dup_request_indicator            ,
                  x_source_of_correction              => lv_isir.source_of_correction             ,
                  x_p_cal_tax_status                  => lv_isir.p_cal_tax_status                 ,
                  x_s_cal_tax_status                  => lv_isir.s_cal_tax_status                 ,
                  x_graduate_flag                     => lv_isir.graduate_flag                    ,
                  x_auto_zero_efc                     => lv_isir.auto_zero_efc                    ,
                  x_efc_change_flag                   => lv_isir.efc_change_flag                  ,
                  x_sarc_flag                         => lv_isir.sarc_flag                        ,
                  x_simplified_need_test              => lv_isir.simplified_need_test             ,
                  x_reject_reason_codes               => lv_isir.reject_reason_codes              ,
                  x_select_service_match_flag         => lv_isir.select_service_match_flag        ,
                  x_select_service_reg_flag           => lv_isir.select_service_reg_flag          ,
                  x_ins_match_flag                    => lv_isir.ins_match_flag                   ,
                  x_ins_verification_number           => NULL,
                  x_sec_ins_match_flag                => lv_isir.sec_ins_match_flag               ,
                  x_sec_ins_ver_number                => lv_isir.sec_ins_ver_number               ,
                  x_ssn_match_flag                    => lv_isir.ssn_match_flag                   ,
                  x_ssa_citizenship_flag              => lv_isir.ssa_citizenship_flag             ,
                  x_ssn_date_of_death                 => lv_isir.ssn_date_of_death                ,
                  x_nslds_match_flag                  => lv_isir.nslds_match_flag                 ,
                  x_va_match_flag                     => lv_isir.va_match_flag                    ,
                  x_prisoner_match                    => lv_isir.prisoner_match                   ,
                  x_verification_flag                 => lv_isir.verification_flag                ,
                  x_subsequent_app_flag               => lv_isir.subsequent_app_flag              ,
                  x_app_source_site_code              => lv_isir.app_source_site_code             ,
                  x_tran_source_site_code             => lv_isir.tran_source_site_code            ,
                  x_drn                               => lv_isir.drn                              ,
                  x_tran_process_date                 => lv_isir.tran_process_date                ,
                  x_computer_batch_number             => lv_isir.computer_batch_number            ,
                  x_correction_flags                  => lv_isir.correction_flags                 ,
                  x_highlight_flags                   => lv_isir.highlight_flags                  ,
                  x_paid_efc                          => NULL                                     ,
                  x_primary_efc                       => lv_isir.primary_efc                      ,
                  x_secondary_efc                     => lv_isir.secondary_efc                    ,
                  x_fed_pell_grant_efc_type           => NULL,
                  x_primary_efc_type                  => lv_isir.primary_efc_type                 ,
                  x_sec_efc_type                      => lv_isir.sec_efc_type                     ,
                  x_primary_alternate_month_1         => lv_isir.primary_alternate_month_1        ,
                  x_primary_alternate_month_2         => lv_isir.primary_alternate_month_2        ,
                  x_primary_alternate_month_3         => lv_isir.primary_alternate_month_3        ,
                  x_primary_alternate_month_4         => lv_isir.primary_alternate_month_4        ,
                  x_primary_alternate_month_5         => lv_isir.primary_alternate_month_5        ,
                  x_primary_alternate_month_6         => lv_isir.primary_alternate_month_6        ,
                  x_primary_alternate_month_7         => lv_isir.primary_alternate_month_7        ,
                  x_primary_alternate_month_8         => lv_isir.primary_alternate_month_8        ,
                  x_primary_alternate_month_10        => lv_isir.primary_alternate_month_10       ,
                  x_primary_alternate_month_11        => lv_isir.primary_alternate_month_11       ,
                  x_primary_alternate_month_12        => lv_isir.primary_alternate_month_12       ,
                  x_sec_alternate_month_1             => lv_isir.sec_alternate_month_1            ,
                  x_sec_alternate_month_2             => lv_isir.sec_alternate_month_2            ,
                  x_sec_alternate_month_3             => lv_isir.sec_alternate_month_3            ,
                  x_sec_alternate_month_4             => lv_isir.sec_alternate_month_4            ,
                  x_sec_alternate_month_5             => lv_isir.sec_alternate_month_5            ,
                  x_sec_alternate_month_6             => lv_isir.sec_alternate_month_6            ,
                  x_sec_alternate_month_7             => lv_isir.sec_alternate_month_7            ,
                  x_sec_alternate_month_8             => lv_isir.sec_alternate_month_8            ,
                  x_sec_alternate_month_10            => lv_isir.sec_alternate_month_10           ,
                  x_sec_alternate_month_11            => lv_isir.sec_alternate_month_11           ,
                  x_sec_alternate_month_12            => lv_isir.sec_alternate_month_12           ,
                  x_total_income                      => lv_isir.total_income                     ,
                  x_allow_total_income                => lv_isir.allow_total_income               ,
                  x_state_tax_allow                   => lv_isir.state_tax_allow                  ,
                  x_employment_allow                  => lv_isir.employment_allow                 ,
                  x_income_protection_allow           => lv_isir.income_protection_allow          ,
                  x_available_income                  => lv_isir.available_income                 ,
                  x_contribution_from_ai              => lv_isir.contribution_from_ai             ,
                  x_discretionary_networth            => lv_isir.discretionary_networth           ,
                  x_efc_networth                      => lv_isir.efc_networth                     ,
                  x_asset_protect_allow               => lv_isir.asset_protect_allow              ,
                  x_parents_cont_from_assets          => lv_isir.parents_cont_from_assets         ,
                  x_adjusted_available_income         => lv_isir.adjusted_available_income        ,
                  x_total_student_contribution        => lv_isir.total_student_contribution       ,
                  x_total_parent_contribution         => lv_isir.total_parent_contribution        ,
                  x_parents_contribution              => lv_isir.parents_contribution             ,
                  x_student_total_income              => lv_isir.student_total_income             ,
                  x_sati                              => lv_isir.sati                             ,
                  x_sic                               => lv_isir.sic                              ,
                  x_sdnw                              => lv_isir.sdnw                             ,
                  x_sca                               => lv_isir.sca                              ,
                  x_fti                               => lv_isir.fti                              ,
                  x_secti                             => lv_isir.secti                            ,
                  x_secati                            => lv_isir.secati                           ,
                  x_secstx                            => lv_isir.secstx                           ,
                  x_secea                             => lv_isir.secea                            ,
                  x_secipa                            => lv_isir.secipa                           ,
                  x_secai                             => lv_isir.secai                            ,
                  x_seccai                            => lv_isir.seccai                           ,
                  x_secdnw                            => lv_isir.secdnw                           ,
                  x_secnw                             => lv_isir.secnw                            ,
                  x_secapa                            => lv_isir.secapa                           ,
                  x_secpca                            => lv_isir.secpca                           ,
                  x_secaai                            => lv_isir.secaai                           ,
                  x_sectsc                            => lv_isir.sectsc                           ,
                  x_sectpc                            => lv_isir.sectpc                           ,
                  x_secpc                             => lv_isir.secpc                            ,
                  x_secsti                            => lv_isir.secsti                           ,
                  x_secsic                            => lv_isir.secsic                           ,
                  x_secsati                           => lv_isir.secsati                          ,
                  x_secsdnw                           => lv_isir.secsdnw                          ,
                  x_secsca                            => lv_isir.secsca                           ,
                  x_secfti                            => lv_isir.secfti                           ,
                  x_a_citizenship                     => lv_isir.a_citizenship                    ,
                  x_a_student_marital_status          => lv_isir.a_student_marital_status         ,
                  x_a_student_agi                     => lv_isir.a_student_agi                    ,
                  x_a_s_us_tax_paid                   => lv_isir.a_s_us_tax_paid                  ,
                  x_a_s_income_work                   => lv_isir.a_s_income_work                  ,
                  x_a_spouse_income_work              => lv_isir.a_spouse_income_work             ,
                  x_a_s_total_wsc                     => lv_isir.a_s_total_wsc                    ,
                  x_a_date_of_birth                   => lv_isir.a_date_of_birth                  ,
                  x_a_student_married                 => lv_isir.a_student_married                ,
                  x_a_have_children                   => lv_isir.a_have_children                  ,
                  x_a_s_have_dependents               => lv_isir.a_s_have_dependents              ,
                  x_a_va_status                       => lv_isir.a_va_status                      ,
                  x_a_s_num_in_family                 => lv_isir.a_s_num_in_family                ,
                  x_a_s_num_in_college                => lv_isir.a_s_num_in_college               ,
                  x_a_p_marital_status                => lv_isir.a_p_marital_status               ,
                  x_a_father_ssn                      => lv_isir.a_father_ssn                     ,
                  x_a_mother_ssn                      => lv_isir.a_mother_ssn                     ,
                  x_a_parents_num_family              => lv_isir.a_parents_num_family             ,
                  x_a_parents_num_college             => lv_isir.a_parents_num_college            ,
                  x_a_parents_agi                     => lv_isir.a_parents_agi                    ,
                  x_a_p_us_tax_paid                   => lv_isir.a_p_us_tax_paid                  ,
                  x_a_f_work_income                   => lv_isir.a_f_work_income                  ,
                  x_a_m_work_income                   => lv_isir.a_m_work_income                  ,
                  x_a_p_total_wsc                     => lv_isir.a_p_total_wsc                    ,
                  x_comment_codes                     => lv_isir.comment_codes                    ,
                  x_sar_ack_comm_code                 => lv_isir.sar_ack_comm_code                ,
                  x_pell_grant_elig_flag              => lv_isir.pell_grant_elig_flag             ,
                  x_reprocess_reason_code             => lv_isir.reprocess_reason_code            ,
                  x_duplicate_date                    => lv_isir.duplicate_date                   ,
                  x_isir_transaction_type             => lv_isir.isir_transaction_type            ,
                  x_fedral_schl_code_indicator        => lv_isir.fedral_schl_code_indicator       ,
                  x_multi_school_code_flags           => lv_isir.multi_school_code_flags          ,
                  x_dup_ssn_indicator                 => lv_isir.dup_ssn_indicator                ,
                  x_system_record_type                => 'INTERNAL'               ,
                  x_payment_isir                      => 'N'                     ,
                  x_receipt_status                    => lv_isir.receipt_status                   ,
                  x_isir_receipt_completed            => lv_isir.isir_receipt_completed           ,
                  x_active_isir                       => 'N'                      ,
                  x_fafsa_data_verify_flags           => lv_isir.fafsa_data_verify_flags          ,
                  x_reject_override_a                 => lv_isir.reject_override_a                ,
                  x_reject_override_c                 => lv_isir.reject_override_c                ,
                  x_parent_marital_status_date        => lv_isir.parent_marital_status_date       ,
                  x_legacy_record_flag                => NULL                                     ,
                  x_father_first_name_initial         => lv_isir.father_first_name_initial_txt    ,
                  x_father_step_father_birth_dt       => lv_isir.father_step_father_birth_date    ,
                  x_mother_first_name_initial         => lv_isir.mother_first_name_initial_txt    ,
                  x_mother_step_mother_birth_dt       => lv_isir.mother_step_mother_birth_date    ,
                  x_parents_email_address_txt         => lv_isir.parents_email_address_txt        ,
                  x_address_change_type               => lv_isir.address_change_type              ,
                  x_cps_pushed_isir_flag              => lv_isir.cps_pushed_isir_flag             ,
                  x_electronic_transaction_type       => lv_isir.electronic_transaction_type      ,
                  x_sar_c_change_type                 => lv_isir.sar_c_change_type                ,
                  x_father_ssn_match_type             => lv_isir.father_ssn_match_type            ,
                  x_mother_ssn_match_type             => lv_isir.mother_ssn_match_type            ,
                  x_reject_override_g_flag            => lv_isir.reject_override_g_flag,
                  x_dhs_verification_num_txt          => lv_isir.dhs_verification_num_txt         ,
                  x_data_file_name_txt                => lv_isir.data_file_name_txt               ,
                  x_message_class_txt                 => NULL,  -- Passing NULL as the record is created internally and not imported from external system
                  x_reject_override_3_flag            => lv_isir.reject_override_3_flag,
                  x_reject_override_12_flag           => lv_isir.reject_override_12_flag,
                  x_reject_override_j_flag            => lv_isir.reject_override_j_flag,
                  x_reject_override_k_flag            => lv_isir.reject_override_k_flag,
                  x_rejected_status_change_flag       => lv_isir.rejected_status_change_flag,
                  x_verification_selection_flag       => lv_isir.verification_selection_flag
                  );


               ELSE
                 lv_rowid   :=  null;
                 pn_isir_id := null;

            igf_ap_isir_matched_pkg.insert_row(
                  x_Mode                              => 'R',
                  x_rowid                             => lv_rowid,
                  x_isir_id                           => pn_isir_id,
                  x_base_id                           => lv_isir.base_id,
                  x_batch_year                        => lv_isir.batch_year                       ,
                  x_transaction_num                   => lv_isir.transaction_num                  ,
                  x_current_ssn                       => lv_isir.current_ssn                      ,
                  x_ssn_name_change                   => lv_isir.ssn_name_change                  ,
                  x_original_ssn                      => lv_isir.original_ssn                     ,
                  x_orig_name_id                      => lv_isir.orig_name_id                     ,
                  x_last_name                         => lv_isir.last_name                        ,
                  x_first_name                        => lv_isir.first_name                       ,
                  x_middle_initial                    => lv_isir.middle_initial                   ,
                  x_perm_mail_add                     => lv_isir.perm_mail_add                    ,
                  x_perm_city                         => lv_isir.perm_city                        ,
                  x_perm_state                        => lv_isir.perm_state                       ,
                  x_perm_zip_code                     => lv_isir.perm_zip_code                    ,
                  x_date_of_birth                     => lv_isir.date_of_birth                    ,
                  x_phone_number                      => lv_isir.phone_number                     ,
                  x_driver_license_number             => lv_isir.driver_license_number            ,
                  x_driver_license_state              => lv_isir.driver_license_state             ,
                  x_citizenship_status                => lv_isir.citizenship_status               ,
                  x_alien_reg_number                  => lv_isir.alien_reg_number                 ,
                  x_s_marital_status                  => lv_isir.s_marital_status                 ,
                  x_s_marital_status_date             => lv_isir.s_marital_status_date            ,
                  x_summ_enrl_status                  => lv_isir.summ_enrl_status                 ,
                  x_fall_enrl_status                  => lv_isir.fall_enrl_status                 ,
                  x_winter_enrl_status                => lv_isir.winter_enrl_status               ,
                  x_spring_enrl_status                => lv_isir.spring_enrl_status               ,
                  x_summ2_enrl_status                 => lv_isir.summ2_enrl_status                ,
                  x_fathers_highest_edu_level         => lv_isir.fathers_highest_edu_level        ,
                  x_mothers_highest_edu_level         => lv_isir.mothers_highest_edu_level        ,
                  x_s_state_legal_residence           => lv_isir.s_state_legal_residence          ,
                  x_legal_residence_before_date       => lv_isir.legal_residence_before_date      ,
                  x_s_legal_resd_date                 => lv_isir.s_legal_resd_date                ,
                  x_ss_r_u_male                       => lv_isir.ss_r_u_male                      ,
                  x_selective_service_reg             => lv_isir.selective_service_reg            ,
                  x_degree_certification              => lv_isir.degree_certification             ,
                  x_grade_level_in_college            => lv_isir.grade_level_in_college           ,
                  x_high_school_diploma_ged           => lv_isir.high_school_diploma_ged          ,
                  x_first_bachelor_deg_by_date        => lv_isir.first_bachelor_deg_by_date       ,
                  x_interest_in_loan                  => lv_isir.interest_in_loan                 ,
                  x_interest_in_stud_employment       => lv_isir.interest_in_stud_employment      ,
                  x_drug_offence_conviction           => lv_isir.drug_offence_conviction          ,
                  x_s_tax_return_status               => lv_isir.s_tax_return_status              ,
                  x_s_type_tax_return                 => lv_isir.s_type_tax_return                ,
                  x_s_elig_1040ez                     => lv_isir.s_elig_1040ez                    ,
                  x_s_adjusted_gross_income           => lv_isir.s_adjusted_gross_income          ,
                  x_s_fed_taxes_paid                  => lv_isir.s_fed_taxes_paid                 ,
                  x_s_exemptions                      => lv_isir.s_exemptions                     ,
                  x_s_income_from_work                => lv_isir.s_income_from_work               ,
                  x_spouse_income_from_work           => lv_isir.spouse_income_from_work          ,
                  x_s_toa_amt_from_wsa                => lv_isir.s_toa_amt_from_wsa               ,
                  x_s_toa_amt_from_wsb                => lv_isir.s_toa_amt_from_wsb               ,
                  x_s_toa_amt_from_wsc                => lv_isir.s_toa_amt_from_wsc               ,
                  x_s_investment_networth             => lv_isir.s_investment_networth            ,
                  x_s_busi_farm_networth              => lv_isir.s_busi_farm_networth             ,
                  x_s_cash_savings                    => lv_isir.s_cash_savings                   ,
                  x_va_months                         => lv_isir.va_months                        ,
                  x_va_amount                         => lv_isir.va_amount                        ,
                  x_stud_dob_before_date              => lv_isir.stud_dob_before_date             ,
                  x_deg_beyond_bachelor               => lv_isir.deg_beyond_bachelor              ,
                  x_s_married                         => lv_isir.s_married                        ,
                  x_s_have_children                   => lv_isir.s_have_children                  ,
                  x_legal_dependents                  => lv_isir.legal_dependents                 ,
                  x_orphan_ward_of_court              => lv_isir.orphan_ward_of_court             ,
                  x_s_veteran                         => lv_isir.s_veteran                        ,
                  x_p_marital_status                  => lv_isir.p_marital_status                 ,
                  x_father_ssn                        => lv_isir.father_ssn                       ,
                  x_f_last_name                       => lv_isir.f_last_name                      ,
                  x_mother_ssn                        => lv_isir.mother_ssn                       ,
                  x_m_last_name                       => lv_isir.m_last_name                      ,
                  x_p_num_family_member               => lv_isir.p_num_family_member              ,
                  x_p_num_in_college                  => lv_isir.p_num_in_college                 ,
                  x_p_state_legal_residence           => lv_isir.p_state_legal_residence          ,
                  x_p_state_legal_res_before_dt       => lv_isir.p_state_legal_res_before_dt      ,
                  x_p_legal_res_date                  => lv_isir.p_legal_res_date                 ,
                  x_age_older_parent                  => lv_isir.age_older_parent                 ,
                  x_p_tax_return_status               => lv_isir.p_tax_return_status              ,
                  x_p_type_tax_return                 => lv_isir.p_type_tax_return                ,
                  x_p_elig_1040aez                    => lv_isir.p_elig_1040aez                   ,
                  x_p_adjusted_gross_income           => lv_isir.p_adjusted_gross_income          ,
                  x_p_taxes_paid                      => lv_isir.p_taxes_paid                     ,
                  x_p_exemptions                      => lv_isir.p_exemptions                     ,
                  x_f_income_work                     => lv_isir.f_income_work                    ,
                  x_m_income_work                     => lv_isir.m_income_work                    ,
                  x_p_income_wsa                      => lv_isir.p_income_wsa                     ,
                  x_p_income_wsb                      => lv_isir.p_income_wsb                     ,
                  x_p_income_wsc                      => lv_isir.p_income_wsc                     ,
                  x_p_investment_networth             => lv_isir.p_investment_networth            ,
                  x_p_business_networth               => lv_isir.p_business_networth              ,
                  x_p_cash_saving                     => lv_isir.p_cash_saving                    ,
                  x_s_num_family_members              => lv_isir.s_num_family_members             ,
                  x_s_num_in_college                  => lv_isir.s_num_in_college                 ,
                  x_first_college                     => lv_isir.first_college                    ,
                  x_first_house_plan                  => lv_isir.first_house_plan                 ,
                  x_second_college                    => lv_isir.second_college                   ,
                  x_second_house_plan                 => lv_isir.second_house_plan                ,
                  x_third_college                     => lv_isir.third_college                    ,
                  x_third_house_plan                  => lv_isir.third_house_plan                 ,
                  x_fourth_college                    => lv_isir.fourth_college                   ,
                  x_fourth_house_plan                 => lv_isir.fourth_house_plan                ,
                  x_fifth_college                     => lv_isir.fifth_college                    ,
                  x_fifth_house_plan                  => lv_isir.fifth_house_plan                 ,
                  x_sixth_college                     => lv_isir.sixth_college                    ,
                  x_sixth_house_plan                  => lv_isir.sixth_house_plan                 ,
                  x_date_app_completed                => lv_isir.date_app_completed               ,
                  x_signed_by                         => lv_isir.signed_by                        ,
                  x_preparer_ssn                      => lv_isir.preparer_ssn                     ,
                  x_preparer_emp_id_number            => lv_isir.preparer_emp_id_number           ,
                  x_preparer_sign                     => lv_isir.preparer_sign                    ,
                  x_transaction_receipt_date          => lv_isir.transaction_receipt_date         ,
                  x_dependency_override_ind           => lv_isir.dependency_override_ind          ,
                  x_faa_fedral_schl_code              => lv_isir.faa_fedral_schl_code             ,
                  x_faa_adjustment                    => lv_isir.faa_adjustment                   ,
                  x_input_record_type                 => lv_isir.input_record_type                ,
                  x_serial_number                     => lv_isir.serial_number                    ,
                  x_batch_number                      => lv_isir.batch_number                     ,
                  x_early_analysis_flag               => lv_isir.early_analysis_flag              ,
                  x_app_entry_source_code             => lv_isir.app_entry_source_code            ,
                  x_eti_destination_code              => lv_isir.eti_destination_code             ,
                  x_reject_override_b                 => lv_isir.reject_override_b                ,
                  x_reject_override_n                 => lv_isir.reject_override_n                ,
                  x_reject_override_w                 => lv_isir.reject_override_w                ,
                  x_assum_override_1                  => lv_isir.assum_override_1                 ,
                  x_assum_override_2                  => lv_isir.assum_override_2                 ,
                  x_assum_override_3                  => lv_isir.assum_override_3                 ,
                  x_assum_override_4                  => lv_isir.assum_override_4                 ,
                  x_assum_override_5                  => lv_isir.assum_override_5                 ,
                  x_assum_override_6                  => lv_isir.assum_override_6                 ,
                  x_dependency_status                 => lv_isir.dependency_status                ,
                  x_s_email_address                   => lv_isir.s_email_address                  ,
                  x_nslds_reason_code                 => lv_isir.nslds_reason_code                ,
                  x_app_receipt_date                  => lv_isir.app_receipt_date                 ,
                  x_processed_rec_type                => lv_isir.processed_rec_type               ,
                  x_hist_correction_for_tran_id       => lv_isir.hist_correction_for_tran_id      ,
                  x_system_generated_indicator        => lv_isir.system_generated_indicator       ,
                  x_dup_request_indicator             => lv_isir.dup_request_indicator            ,
                  x_source_of_correction              => lv_isir.source_of_correction             ,
                  x_p_cal_tax_status                  => lv_isir.p_cal_tax_status                 ,
                  x_s_cal_tax_status                  => lv_isir.s_cal_tax_status                 ,
                  x_graduate_flag                     => lv_isir.graduate_flag                    ,
                  x_auto_zero_efc                     => lv_isir.auto_zero_efc                    ,
                  x_efc_change_flag                   => lv_isir.efc_change_flag                  ,
                  x_sarc_flag                         => lv_isir.sarc_flag                        ,
                  x_simplified_need_test              => lv_isir.simplified_need_test             ,
                  x_reject_reason_codes               => lv_isir.reject_reason_codes              ,
                  x_select_service_match_flag         => lv_isir.select_service_match_flag        ,
                  x_select_service_reg_flag           => lv_isir.select_service_reg_flag          ,
                  x_ins_match_flag                    => lv_isir.ins_match_flag                   ,
                  x_ins_verification_number           => NULL,
                  x_sec_ins_match_flag                => lv_isir.sec_ins_match_flag               ,
                  x_sec_ins_ver_number                => lv_isir.sec_ins_ver_number               ,
                  x_ssn_match_flag                    => lv_isir.ssn_match_flag                   ,
                  x_ssa_citizenship_flag              => lv_isir.ssa_citizenship_flag             ,
                  x_ssn_date_of_death                 => lv_isir.ssn_date_of_death                ,
                  x_nslds_match_flag                  => lv_isir.nslds_match_flag                 ,
                  x_va_match_flag                     => lv_isir.va_match_flag                    ,
                  x_prisoner_match                    => lv_isir.prisoner_match                   ,
                  x_verification_flag                 => lv_isir.verification_flag                ,
                  x_subsequent_app_flag               => lv_isir.subsequent_app_flag              ,
                  x_app_source_site_code              => lv_isir.app_source_site_code             ,
                  x_tran_source_site_code             => lv_isir.tran_source_site_code            ,
                  x_drn                               => lv_isir.drn                              ,
                  x_tran_process_date                 => lv_isir.tran_process_date                ,
                  x_computer_batch_number             => lv_isir.computer_batch_number            ,
                  x_correction_flags                  => lv_isir.correction_flags                 ,
                  x_highlight_flags                   => lv_isir.highlight_flags                  ,
                  x_paid_efc                          => NULL                        ,
                  x_primary_efc                       => lv_isir.primary_efc                      ,
                  x_secondary_efc                     => lv_isir.secondary_efc                    ,
                  x_fed_pell_grant_efc_type           => NULL          ,
                  x_primary_efc_type                  => lv_isir.primary_efc_type                 ,
                  x_sec_efc_type                      => lv_isir.sec_efc_type                     ,
                  x_primary_alternate_month_1         => lv_isir.primary_alternate_month_1        ,
                  x_primary_alternate_month_2         => lv_isir.primary_alternate_month_2        ,
                  x_primary_alternate_month_3         => lv_isir.primary_alternate_month_3        ,
                  x_primary_alternate_month_4         => lv_isir.primary_alternate_month_4        ,
                  x_primary_alternate_month_5         => lv_isir.primary_alternate_month_5        ,
                  x_primary_alternate_month_6         => lv_isir.primary_alternate_month_6        ,
                  x_primary_alternate_month_7         => lv_isir.primary_alternate_month_7        ,
                  x_primary_alternate_month_8         => lv_isir.primary_alternate_month_8        ,
                  x_primary_alternate_month_10        => lv_isir.primary_alternate_month_10       ,
                  x_primary_alternate_month_11        => lv_isir.primary_alternate_month_11       ,
                  x_primary_alternate_month_12        => lv_isir.primary_alternate_month_12       ,
                  x_sec_alternate_month_1             => lv_isir.sec_alternate_month_1            ,
                  x_sec_alternate_month_2             => lv_isir.sec_alternate_month_2            ,
                  x_sec_alternate_month_3             => lv_isir.sec_alternate_month_3            ,
                  x_sec_alternate_month_4             => lv_isir.sec_alternate_month_4            ,
                  x_sec_alternate_month_5             => lv_isir.sec_alternate_month_5            ,
                  x_sec_alternate_month_6             => lv_isir.sec_alternate_month_6            ,
                  x_sec_alternate_month_7             => lv_isir.sec_alternate_month_7            ,
                  x_sec_alternate_month_8             => lv_isir.sec_alternate_month_8            ,
                  x_sec_alternate_month_10            => lv_isir.sec_alternate_month_10           ,
                  x_sec_alternate_month_11            => lv_isir.sec_alternate_month_11           ,
                  x_sec_alternate_month_12            => lv_isir.sec_alternate_month_12           ,
                  x_total_income                      => lv_isir.total_income                     ,
                  x_allow_total_income                => lv_isir.allow_total_income               ,
                  x_state_tax_allow                   => lv_isir.state_tax_allow                  ,
                  x_employment_allow                  => lv_isir.employment_allow                 ,
                  x_income_protection_allow           => lv_isir.income_protection_allow          ,
                  x_available_income                  => lv_isir.available_income                 ,
                  x_contribution_from_ai              => lv_isir.contribution_from_ai             ,
                  x_discretionary_networth            => lv_isir.discretionary_networth           ,
                  x_efc_networth                      => lv_isir.efc_networth                     ,
                  x_asset_protect_allow               => lv_isir.asset_protect_allow              ,
                  x_parents_cont_from_assets          => lv_isir.parents_cont_from_assets         ,
                  x_adjusted_available_income         => lv_isir.adjusted_available_income        ,
                  x_total_student_contribution        => lv_isir.total_student_contribution       ,
                  x_total_parent_contribution         => lv_isir.total_parent_contribution        ,
                  x_parents_contribution              => lv_isir.parents_contribution             ,
                  x_student_total_income              => lv_isir.student_total_income             ,
                  x_sati                              => lv_isir.sati                             ,
                  x_sic                               => lv_isir.sic                              ,
                  x_sdnw                              => lv_isir.sdnw                             ,
                  x_sca                               => lv_isir.sca                              ,
                  x_fti                               => lv_isir.fti                              ,
                  x_secti                             => lv_isir.secti                            ,
                  x_secati                            => lv_isir.secati                           ,
                  x_secstx                            => lv_isir.secstx                           ,
                  x_secea                             => lv_isir.secea                            ,
                  x_secipa                            => lv_isir.secipa                           ,
                  x_secai                             => lv_isir.secai                            ,
                  x_seccai                            => lv_isir.seccai                           ,
                  x_secdnw                            => lv_isir.secdnw                           ,
                  x_secnw                             => lv_isir.secnw                            ,
                  x_secapa                            => lv_isir.secapa                           ,
                  x_secpca                            => lv_isir.secpca                           ,
                  x_secaai                            => lv_isir.secaai                           ,
                  x_sectsc                            => lv_isir.sectsc                           ,
                  x_sectpc                            => lv_isir.sectpc                           ,
                  x_secpc                             => lv_isir.secpc                            ,
                  x_secsti                            => lv_isir.secsti                           ,
                  x_secsic                            => lv_isir.secsic                           ,
                  x_secsati                           => lv_isir.secsati                          ,
                  x_secsdnw                           => lv_isir.secsdnw                          ,
                  x_secsca                            => lv_isir.secsca                           ,
                  x_secfti                            => lv_isir.secfti                           ,
                  x_a_citizenship                     => lv_isir.a_citizenship                    ,
                  x_a_student_marital_status          => lv_isir.a_student_marital_status         ,
                  x_a_student_agi                     => lv_isir.a_student_agi                    ,
                  x_a_s_us_tax_paid                   => lv_isir.a_s_us_tax_paid                  ,
                  x_a_s_income_work                   => lv_isir.a_s_income_work                  ,
                  x_a_spouse_income_work              => lv_isir.a_spouse_income_work             ,
                  x_a_s_total_wsc                     => lv_isir.a_s_total_wsc                    ,
                  x_a_date_of_birth                   => lv_isir.a_date_of_birth                  ,
                  x_a_student_married                 => lv_isir.a_student_married                ,
                  x_a_have_children                   => lv_isir.a_have_children                  ,
                  x_a_s_have_dependents               => lv_isir.a_s_have_dependents              ,
                  x_a_va_status                       => lv_isir.a_va_status                      ,
                  x_a_s_num_in_family                 => lv_isir.a_s_num_in_family                ,
                  x_a_s_num_in_college                => lv_isir.a_s_num_in_college               ,
                  x_a_p_marital_status                => lv_isir.a_p_marital_status               ,
                  x_a_father_ssn                      => lv_isir.a_father_ssn                     ,
                  x_a_mother_ssn                      => lv_isir.a_mother_ssn                     ,
                  x_a_parents_num_family              => lv_isir.a_parents_num_family             ,
                  x_a_parents_num_college             => lv_isir.a_parents_num_college            ,
                  x_a_parents_agi                     => lv_isir.a_parents_agi                    ,
                  x_a_p_us_tax_paid                   => lv_isir.a_p_us_tax_paid                  ,
                  x_a_f_work_income                   => lv_isir.a_f_work_income                  ,
                  x_a_m_work_income                   => lv_isir.a_m_work_income                  ,
                  x_a_p_total_wsc                     => lv_isir.a_p_total_wsc                    ,
                  x_comment_codes                     => lv_isir.comment_codes                    ,
                  x_sar_ack_comm_code                 => lv_isir.sar_ack_comm_code                ,
                  x_pell_grant_elig_flag              => lv_isir.pell_grant_elig_flag             ,
                  x_reprocess_reason_code             => lv_isir.reprocess_reason_code            ,
                  x_duplicate_date                    => lv_isir.duplicate_date                   ,
                  x_isir_transaction_type             => lv_isir.isir_transaction_type            ,
                  x_fedral_schl_code_indicator        => lv_isir.fedral_schl_code_indicator       ,
                  x_multi_school_code_flags           => lv_isir.multi_school_code_flags          ,
                  x_dup_ssn_indicator                 => lv_isir.dup_ssn_indicator                ,
                  x_system_record_type                => 'INTERNAL'               ,
                  x_payment_isir                      => 'N'                     ,
                  x_receipt_status                    => lv_isir.receipt_status                   ,
                  x_isir_receipt_completed            => lv_isir.isir_receipt_completed           ,
                  x_active_isir                       => 'N'                      ,
                  x_fafsa_data_verify_flags           => lv_isir.fafsa_data_verify_flags          ,
                  x_reject_override_a                 => lv_isir.reject_override_a                ,
                  x_reject_override_c                 => lv_isir.reject_override_c                ,
                  x_parent_marital_status_date        => lv_isir.parent_marital_status_date       ,
                  x_legacy_record_flag                => NULL                                     ,
                  x_father_first_name_initial         => lv_isir.FATHER_FIRST_NAME_INITIAL_TXT    ,
                  x_father_step_father_birth_dt       => lv_isir.FATHER_STEP_FATHER_BIRTH_DATE    ,
                  x_mother_first_name_initial         => lv_isir.MOTHER_FIRST_NAME_INITIAL_TXT    ,
                  x_mother_step_mother_birth_dt       => lv_isir.MOTHER_STEP_MOTHER_BIRTH_DATE    ,
                  x_parents_email_address_txt         => lv_isir.PARENTS_EMAIL_ADDRESS_TXT        ,
                  x_address_change_type               => lv_isir.ADDRESS_CHANGE_TYPE              ,
                  x_cps_pushed_isir_flag              => lv_isir.CPS_PUSHED_ISIR_FLAG             ,
                  x_electronic_transaction_type       => lv_isir.ELECTRONIC_TRANSACTION_TYPE      ,
                  x_sar_c_change_type                 => lv_isir.SAR_C_CHANGE_TYPE                ,
                  x_father_ssn_match_type             => lv_isir.FATHER_SSN_MATCH_TYPE            ,
                  x_mother_ssn_match_type             => lv_isir.MOTHER_SSN_MATCH_TYPE            ,
                  x_reject_override_g_flag            => lv_isir.REJECT_OVERRIDE_G_FLAG,
                  x_dhs_verification_num_txt          => lv_isir.dhs_verification_num_txt         ,
                  x_data_file_name_txt                => lv_isir.data_file_name_txt               ,
                  x_message_class_txt                 => NULL,  -- Passing NULL as the record is created internally
                  x_reject_override_3_flag            => lv_isir.reject_override_3_flag,
                  x_reject_override_12_flag           => lv_isir.reject_override_12_flag,
                  x_reject_override_j_flag            => lv_isir.reject_override_j_flag,
                  x_reject_override_k_flag            => lv_isir.reject_override_k_flag,
                  x_rejected_status_change_flag       => lv_isir.rejected_status_change_flag,
                  x_verification_selection_flag       => lv_isir.verification_selection_flag
                  );
             p_ret_isir_id  := pn_isir_id ;

             COMMIT;
             OPEN chk_row_id;
             FETCH chk_row_id into lv_rowid;
             CLOSE chk_row_id;
         END IF;
       CLOSE chk_internal ;
       CLOSE c_isir;
  ELSE
     -- ISIR Not FOUND hence return -1
     CLOSE c_isir;
     p_ret_isir_id  := -1 ;
  RETURN  ;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -54 THEN
          -- ORA-00054: resource busy and acquire with NOWAIT specified
        p_ret_isir_id := -2;
      ELSE
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_ap_ss_pkg.set_internal_isir');
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_ss_pkg.set_internal_isir.exception','Exception: '||SQLERRM);
        END IF;
        IGS_GE_MSG_STACK.ADD;
      END IF;
 END set_internal_isir;

   FUNCTION get_pid (
          p_pid_grp IN igs_pe_persid_group.group_id%TYPE,
          p_status  OUT NOCOPY VARCHAR2,
          p_group_type OUT NOCOPY igs_pe_persid_group_v.group_type%TYPE
    ) RETURN VARCHAR2 IS
    /*************************************************************
    Change History
    Who             When            What
    ridas           07-Feb-2006     Bug #5021084. Replaced function IGS_GET_DYNAMIC_SQL with GET_DYNAMIC_SQL.
    (reverse chronological order - newest change first)
    ***************************************************************/

      lv_ret_sql      VARCHAR2(32767);
      lv_status       VARCHAR2(1);

      g_api_version   CONSTANT NUMBER       := 1.0;
      g_api_name      CONSTANT VARCHAR2(30) := 'get_dynamic_sql';
      g_pkg_name      CONSTANT VARCHAR2(30) := 'igs_dynamic_perid_group';
      g_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| g_api_name;
      lv_group_type   igs_pe_persid_group_v.group_type%TYPE;

   BEGIN
      --Bug #5021084.
      lv_ret_sql :=  igs_pe_dynamic_persid_group.get_dynamic_sql
                       (p_pid_grp,lv_status,lv_group_type);
      p_status      := lv_status;
      p_group_type  := lv_group_type;
      RETURN lv_ret_sql;
   END;


  PROCEDURE update_isir(
                        p_isir_rec  igf_ap_isir_matched%ROWTYPE,
                        p_isir_id   igf_ap_isir_matched.ISIR_ID%TYPE,
                        p_rowid     VARCHAR2
                       ) IS
    ------------------------------------------------------------------
    --Created by  : brajendr
    --Date created: 17-Feb-2003
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --asbala   19-nov-2003    3026594: FA128 - ISIR Federal Updates 04- 05,
    --                        modified signature of igf_ap_isir_matched_pkg
    -------------------------------------------------------------------

  BEGIN

    --The existing Correction ISIR is updated with the Simulated ISIR values
    igf_ap_isir_matched_pkg.update_row(
                                       x_rowid                           =>  p_rowid,
                                       x_isir_id                         =>  p_isir_id,
                                       x_base_id                         =>  p_isir_rec.base_id,
                                       x_batch_year                      =>  p_isir_rec.batch_year,
                                       x_transaction_num                 =>  p_isir_rec.transaction_num,
                                       x_current_ssn                     =>  p_isir_rec.current_ssn,
                                       x_ssn_name_change                 =>  p_isir_rec.ssn_name_change,
                                       x_original_ssn                    =>  p_isir_rec.original_ssn,
                                       x_orig_name_id                    =>  p_isir_rec.orig_name_id,
                                       x_last_name                       =>  p_isir_rec.last_name,
                                       x_first_name                      =>  p_isir_rec.first_name,
                                       x_middle_initial                  =>  p_isir_rec.middle_initial,
                                       x_perm_mail_add                   =>  p_isir_rec.perm_mail_add,
                                       x_perm_city                       =>  p_isir_rec.perm_city,
                                       x_perm_state                      =>  p_isir_rec.perm_state,
                                       x_perm_zip_code                   =>  p_isir_rec.perm_zip_code,
                                       x_date_of_birth                   =>  p_isir_rec.date_of_birth,
                                       x_phone_number                    =>  p_isir_rec.phone_number,
                                       x_driver_license_number           =>  p_isir_rec.driver_license_number,
                                       x_driver_license_state            =>  p_isir_rec.driver_license_state,
                                       x_citizenship_status              =>  p_isir_rec.citizenship_status,
                                       x_alien_reg_number                =>  p_isir_rec.alien_reg_number,
                                       x_s_marital_status                =>  p_isir_rec.s_marital_status,
                                       x_s_marital_status_date           =>  p_isir_rec.s_marital_status_date,
                                       x_summ_enrl_status                =>  p_isir_rec.summ_enrl_status,
                                       x_fall_enrl_status                =>  p_isir_rec.fall_enrl_status,
                                       x_winter_enrl_status              =>  p_isir_rec.winter_enrl_status,
                                       x_spring_enrl_status              =>  p_isir_rec.spring_enrl_status,
                                       x_summ2_enrl_status               =>  p_isir_rec.summ2_enrl_status,
                                       x_fathers_highest_edu_level       =>  p_isir_rec.fathers_highest_edu_level,
                                       x_mothers_highest_edu_level       =>  p_isir_rec.mothers_highest_edu_level,
                                       x_s_state_legal_residence         =>  p_isir_rec.s_state_legal_residence,
                                       x_legal_residence_before_date     =>  p_isir_rec.legal_residence_before_date,
                                       x_s_legal_resd_date               =>  p_isir_rec.s_legal_resd_date,
                                       x_ss_r_u_male                     =>  p_isir_rec.ss_r_u_male,
                                       x_selective_service_reg           =>  p_isir_rec.selective_service_reg,
                                       x_degree_certification            =>  p_isir_rec.degree_certification,
                                       x_grade_level_in_college          =>  p_isir_rec.grade_level_in_college,
                                       x_high_school_diploma_ged         =>  p_isir_rec.high_school_diploma_ged,
                                       x_first_bachelor_deg_by_date      =>  p_isir_rec.first_bachelor_deg_by_date,
                                       x_interest_in_loan                =>  p_isir_rec.interest_in_loan,
                                       x_interest_in_stud_employment     =>  p_isir_rec.interest_in_stud_employment,
                                       x_drug_offence_conviction         =>  p_isir_rec.drug_offence_conviction,
                                       x_s_tax_return_status             =>  p_isir_rec.s_tax_return_status,
                                       x_s_type_tax_return               =>  p_isir_rec.s_type_tax_return,
                                       x_s_elig_1040ez                   =>  p_isir_rec.s_elig_1040ez,
                                       x_s_adjusted_gross_income         =>  p_isir_rec.s_adjusted_gross_income,
                                       x_s_fed_taxes_paid                =>  p_isir_rec.s_fed_taxes_paid,
                                       x_s_exemptions                    =>  p_isir_rec.s_exemptions,
                                       x_s_income_from_work              =>  p_isir_rec.s_income_from_work,
                                       x_spouse_income_from_work         =>  p_isir_rec.spouse_income_from_work,
                                       x_s_toa_amt_from_wsa              =>  p_isir_rec.s_toa_amt_from_wsa,
                                       x_s_toa_amt_from_wsb              =>  p_isir_rec.s_toa_amt_from_wsb,
                                       x_s_toa_amt_from_wsc              =>  p_isir_rec.s_toa_amt_from_wsc,
                                       x_s_investment_networth           =>  p_isir_rec.s_investment_networth,
                                       x_s_busi_farm_networth            =>  p_isir_rec.s_busi_farm_networth,
                                       x_s_cash_savings                  =>  p_isir_rec.s_cash_savings,
                                       x_va_months                       =>  p_isir_rec.va_months,
                                       x_va_amount                       =>  p_isir_rec.va_amount,
                                       x_stud_dob_before_date            =>  p_isir_rec.stud_dob_before_date,
                                       x_deg_beyond_bachelor             =>  p_isir_rec.deg_beyond_bachelor,
                                       x_s_married                       =>  p_isir_rec.s_married,
                                       x_s_have_children                 =>  p_isir_rec.s_have_children,
                                       x_legal_dependents                =>  p_isir_rec.legal_dependents,
                                       x_orphan_ward_of_court            =>  p_isir_rec.orphan_ward_of_court,
                                       x_s_veteran                       =>  p_isir_rec.s_veteran,
                                       x_p_marital_status                =>  p_isir_rec.p_marital_status,
                                       x_father_ssn                      =>  p_isir_rec.father_ssn,
                                       x_f_last_name                     =>  p_isir_rec.f_last_name,
                                       x_mother_ssn                      =>  p_isir_rec.mother_ssn,
                                       x_m_last_name                     =>  p_isir_rec.m_last_name,
                                       x_p_num_family_member             =>  p_isir_rec.p_num_family_member,
                                       x_p_num_in_college                =>  p_isir_rec.p_num_in_college,
                                       x_p_state_legal_residence         =>  p_isir_rec.p_state_legal_residence,
                                       x_p_state_legal_res_before_dt     =>  p_isir_rec.p_state_legal_res_before_dt,
                                       x_p_legal_res_date                =>  p_isir_rec.p_legal_res_date,
                                       x_age_older_parent                =>  p_isir_rec.age_older_parent,
                                       x_p_tax_return_status             =>  p_isir_rec.p_tax_return_status,
                                       x_p_type_tax_return               =>  p_isir_rec.p_type_tax_return,
                                       x_p_elig_1040aez                  =>  p_isir_rec.p_elig_1040aez,
                                       x_p_adjusted_gross_income         =>  p_isir_rec.p_adjusted_gross_income,
                                       x_p_taxes_paid                    =>  p_isir_rec.p_taxes_paid,
                                       x_p_exemptions                    =>  p_isir_rec.p_exemptions,
                                       x_f_income_work                   =>  p_isir_rec.f_income_work,
                                       x_m_income_work                   =>  p_isir_rec.m_income_work,
                                       x_p_income_wsa                    =>  p_isir_rec.p_income_wsa,
                                       x_p_income_wsb                    =>  p_isir_rec.p_income_wsb,
                                       x_p_income_wsc                    =>  p_isir_rec.p_income_wsc,
                                       x_p_investment_networth           =>  p_isir_rec.p_investment_networth,
                                       x_p_business_networth             =>  p_isir_rec.p_business_networth,
                                       x_p_cash_saving                   =>  p_isir_rec.p_cash_saving,
                                       x_s_num_family_members            =>  p_isir_rec.s_num_family_members,
                                       x_s_num_in_college                =>  p_isir_rec.s_num_in_college,
                                       x_first_college                   =>  p_isir_rec.first_college,
                                       x_first_house_plan                =>  p_isir_rec.first_house_plan,
                                       x_second_college                  =>  p_isir_rec.second_college,
                                       x_second_house_plan               =>  p_isir_rec.second_house_plan,
                                       x_third_college                   =>  p_isir_rec.third_college,
                                       x_third_house_plan                =>  p_isir_rec.third_house_plan,
                                       x_fourth_college                  =>  p_isir_rec.fourth_college,
                                       x_fourth_house_plan               =>  p_isir_rec.fourth_house_plan,
                                       x_fifth_college                   =>  p_isir_rec.fifth_college,
                                       x_fifth_house_plan                =>  p_isir_rec.fifth_house_plan,
                                       x_sixth_college                   =>  p_isir_rec.sixth_college,
                                       x_sixth_house_plan                =>  p_isir_rec.sixth_house_plan,
                                       x_date_app_completed              =>  p_isir_rec.date_app_completed,
                                       x_signed_by                       =>  p_isir_rec.signed_by,
                                       x_preparer_ssn                    =>  p_isir_rec.preparer_ssn,
                                       x_preparer_emp_id_number          =>  p_isir_rec.preparer_emp_id_number,
                                       x_preparer_sign                   =>  p_isir_rec.preparer_sign,
                                       x_transaction_receipt_date        =>  p_isir_rec.transaction_receipt_date,
                                       x_dependency_override_ind         =>  p_isir_rec.dependency_override_ind,
                                       x_faa_fedral_schl_code            =>  p_isir_rec.faa_fedral_schl_code,
                                       x_faa_adjustment                  =>  p_isir_rec.faa_adjustment,
                                       x_input_record_type               =>  p_isir_rec.input_record_type,
                                       x_serial_number                   =>  p_isir_rec.serial_number,
                                       x_batch_number                    =>  p_isir_rec.batch_number,
                                       x_early_analysis_flag             =>  p_isir_rec.early_analysis_flag,
                                       x_app_entry_source_code           =>  p_isir_rec.app_entry_source_code,
                                       x_eti_destination_code            =>  p_isir_rec.eti_destination_code,
                                       x_reject_override_b               =>  p_isir_rec.reject_override_b,
                                       x_reject_override_n               =>  p_isir_rec.reject_override_n,
                                       x_reject_override_w               =>  p_isir_rec.reject_override_w,
                                       x_assum_override_1                =>  p_isir_rec.assum_override_1,
                                       x_assum_override_2                =>  p_isir_rec.assum_override_2,
                                       x_assum_override_3                =>  p_isir_rec.assum_override_3,
                                       x_assum_override_4                =>  p_isir_rec.assum_override_4,
                                       x_assum_override_5                =>  p_isir_rec.assum_override_5,
                                       x_assum_override_6                =>  p_isir_rec.assum_override_6,
                                       x_dependency_status               =>  p_isir_rec.dependency_status,
                                       x_s_email_address                 =>  p_isir_rec.s_email_address,
                                       x_nslds_reason_code               =>  p_isir_rec.nslds_reason_code,
                                       x_app_receipt_date                =>  p_isir_rec.app_receipt_date,
                                       x_processed_rec_type              =>  p_isir_rec.processed_rec_type,
                                       x_hist_correction_for_tran_id     =>  p_isir_rec.hist_correction_for_tran_id,
                                       x_system_generated_indicator      =>  p_isir_rec.system_generated_indicator,
                                       x_dup_request_indicator           =>  p_isir_rec.dup_request_indicator,
                                       x_source_of_correction            =>  p_isir_rec.source_of_correction,
                                       x_p_cal_tax_status                =>  p_isir_rec.p_cal_tax_status,
                                       x_s_cal_tax_status                =>  p_isir_rec.s_cal_tax_status,
                                       x_graduate_flag                   =>  p_isir_rec.graduate_flag,
                                       x_auto_zero_efc                   =>  p_isir_rec.auto_zero_efc,
                                       x_efc_change_flag                 =>  p_isir_rec.efc_change_flag,
                                       x_sarc_flag                       =>  p_isir_rec.sarc_flag,
                                       x_simplified_need_test            =>  p_isir_rec.simplified_need_test,
                                       x_reject_reason_codes             =>  p_isir_rec.reject_reason_codes,
                                       x_select_service_match_flag       =>  p_isir_rec.select_service_match_flag,
                                       x_select_service_reg_flag         =>  p_isir_rec.select_service_reg_flag,
                                       x_ins_match_flag                  =>  p_isir_rec.ins_match_flag,
                                       x_ins_verification_number         =>  NULL,
                                       x_sec_ins_match_flag              =>  p_isir_rec.sec_ins_match_flag,
                                       x_sec_ins_ver_number              =>  p_isir_rec.sec_ins_ver_number,
                                       x_ssn_match_flag                  =>  p_isir_rec.ssn_match_flag,
                                       x_ssa_citizenship_flag            =>  p_isir_rec.ssa_citizenship_flag,
                                       x_ssn_date_of_death               =>  p_isir_rec.ssn_date_of_death,
                                       x_nslds_match_flag                =>  p_isir_rec.nslds_match_flag,
                                       x_va_match_flag                   =>  p_isir_rec.va_match_flag,
                                       x_prisoner_match                  =>  p_isir_rec.prisoner_match,
                                       x_verification_flag               =>  p_isir_rec.verification_flag,
                                       x_subsequent_app_flag             =>  p_isir_rec.subsequent_app_flag,
                                       x_app_source_site_code            =>  p_isir_rec.app_source_site_code,
                                       x_tran_source_site_code           =>  p_isir_rec.tran_source_site_code,
                                       x_drn                             =>  p_isir_rec.drn,
                                       x_tran_process_date               =>  p_isir_rec.tran_process_date,
                                       x_correction_flags                =>  p_isir_rec.correction_flags,
                                       x_computer_batch_number           =>  p_isir_rec.computer_batch_number,
                                       x_highlight_flags                 =>  p_isir_rec.highlight_flags,
                                       x_paid_efc                        =>  NULL,
                                       x_primary_efc                     =>  p_isir_rec.primary_efc,
                                       x_secondary_efc                   =>  p_isir_rec.secondary_efc,
                                       x_fed_pell_grant_efc_type         =>  NULL,
                                       x_primary_efc_type                =>  p_isir_rec.primary_efc_type,
                                       x_sec_efc_type                    =>  p_isir_rec.sec_efc_type,
                                       x_primary_alternate_month_1       =>  p_isir_rec.primary_alternate_month_1,
                                       x_primary_alternate_month_2       =>  p_isir_rec.primary_alternate_month_2,
                                       x_primary_alternate_month_3       =>  p_isir_rec.primary_alternate_month_3,
                                       x_primary_alternate_month_4       =>  p_isir_rec.primary_alternate_month_4,
                                       x_primary_alternate_month_5       =>  p_isir_rec.primary_alternate_month_5,
                                       x_primary_alternate_month_6       =>  p_isir_rec.primary_alternate_month_6,
                                       x_primary_alternate_month_7       =>  p_isir_rec.primary_alternate_month_7,
                                       x_primary_alternate_month_8       =>  p_isir_rec.primary_alternate_month_8,
                                       x_primary_alternate_month_10      =>  p_isir_rec.primary_alternate_month_10,
                                       x_primary_alternate_month_11      =>  p_isir_rec.primary_alternate_month_11,
                                       x_primary_alternate_month_12      =>  p_isir_rec.primary_alternate_month_12,
                                       x_sec_alternate_month_1           =>  p_isir_rec.sec_alternate_month_1,
                                       x_sec_alternate_month_2           =>  p_isir_rec.sec_alternate_month_2,
                                       x_sec_alternate_month_3           =>  p_isir_rec.sec_alternate_month_3,
                                       x_sec_alternate_month_4           =>  p_isir_rec.sec_alternate_month_4,
                                       x_sec_alternate_month_5           =>  p_isir_rec.sec_alternate_month_5,
                                       x_sec_alternate_month_6           =>  p_isir_rec.sec_alternate_month_6,
                                       x_sec_alternate_month_7           =>  p_isir_rec.sec_alternate_month_7,
                                       x_sec_alternate_month_8           =>  p_isir_rec.sec_alternate_month_8,
                                       x_sec_alternate_month_10          =>  p_isir_rec.sec_alternate_month_10,
                                       x_sec_alternate_month_11          =>  p_isir_rec.sec_alternate_month_11,
                                       x_sec_alternate_month_12          =>  p_isir_rec.sec_alternate_month_12,
                                       x_total_income                    =>  p_isir_rec.total_income,
                                       x_allow_total_income              =>  p_isir_rec.allow_total_income,
                                       x_state_tax_allow                 =>  p_isir_rec.state_tax_allow,
                                       x_employment_allow                =>  p_isir_rec.employment_allow,
                                       x_income_protection_allow         =>  p_isir_rec.income_protection_allow,
                                       x_available_income                =>  p_isir_rec.available_income,
                                       x_contribution_from_ai            =>  p_isir_rec.contribution_from_ai,
                                       x_discretionary_networth          =>  p_isir_rec.discretionary_networth,
                                       x_efc_networth                    =>  p_isir_rec.efc_networth,
                                       x_asset_protect_allow             =>  p_isir_rec.asset_protect_allow,
                                       x_parents_cont_from_assets        =>  p_isir_rec.parents_cont_from_assets,
                                       x_adjusted_available_income       =>  p_isir_rec.adjusted_available_income,
                                       x_total_student_contribution      =>  p_isir_rec.total_student_contribution,
                                       x_total_parent_contribution       =>  p_isir_rec.total_parent_contribution,
                                       x_parents_contribution            =>  p_isir_rec.parents_contribution,
                                       x_student_total_income            =>  p_isir_rec.student_total_income,
                                       x_sati                            =>  p_isir_rec.sati,
                                       x_sic                             =>  p_isir_rec.sic,
                                       x_sdnw                            =>  p_isir_rec.sdnw,
                                       x_sca                             =>  p_isir_rec.sca,
                                       x_fti                             =>  p_isir_rec.fti,
                                       x_secti                           =>  p_isir_rec.secti,
                                       x_secati                          =>  p_isir_rec.secati,
                                       x_secstx                          =>  p_isir_rec.secstx,
                                       x_secea                           =>  p_isir_rec.secea,
                                       x_secipa                          =>  p_isir_rec.secipa,
                                       x_secai                           =>  p_isir_rec.secai,
                                       x_seccai                          =>  p_isir_rec.seccai,
                                       x_secdnw                          =>  p_isir_rec.secdnw,
                                       x_secnw                           =>  p_isir_rec.secnw,
                                       x_secapa                          =>  p_isir_rec.secapa,
                                       x_secpca                          =>  p_isir_rec.secpca,
                                       x_secaai                          =>  p_isir_rec.secaai,
                                       x_sectsc                          =>  p_isir_rec.sectsc,
                                       x_sectpc                          =>  p_isir_rec.sectpc,
                                       x_secpc                           =>  p_isir_rec.secpc,
                                       x_secsti                          =>  p_isir_rec.secsti,
                                       x_secsati                         =>  p_isir_rec.secsati,
                                       x_secsic                          =>  p_isir_rec.secsic,
                                       x_secsdnw                         =>  p_isir_rec.secsdnw,
                                       x_secsca                          =>  p_isir_rec.secsca,
                                       x_secfti                          =>  p_isir_rec.secfti,
                                       x_a_citizenship                   =>  p_isir_rec.a_citizenship,
                                       x_a_student_marital_status        =>  p_isir_rec.a_student_marital_status,
                                       x_a_student_agi                   =>  p_isir_rec.a_student_agi,
                                       x_a_s_us_tax_paid                 =>  p_isir_rec.a_s_us_tax_paid,
                                       x_a_s_income_work                 =>  p_isir_rec.a_s_income_work,
                                       x_a_spouse_income_work            =>  p_isir_rec.a_spouse_income_work,
                                       x_a_s_total_wsc                   =>  p_isir_rec.a_s_total_wsc,
                                       x_a_date_of_birth                 =>  p_isir_rec.a_date_of_birth,
                                       x_a_student_married               =>  p_isir_rec.a_student_married,
                                       x_a_have_children                 =>  p_isir_rec.a_have_children,
                                       x_a_s_have_dependents             =>  p_isir_rec.a_s_have_dependents,
                                       x_a_va_status                     =>  p_isir_rec.a_va_status,
                                       x_a_s_num_in_family               =>  p_isir_rec.a_s_num_in_family,
                                       x_a_s_num_in_college              =>  p_isir_rec.a_s_num_in_college,
                                       x_a_p_marital_status              =>  p_isir_rec.a_p_marital_status,
                                       x_a_father_ssn                    =>  p_isir_rec.a_father_ssn,
                                       x_a_mother_ssn                    =>  p_isir_rec.a_mother_ssn,
                                       x_a_parents_num_family            =>  p_isir_rec.a_parents_num_family,
                                       x_a_parents_num_college           =>  p_isir_rec.a_parents_num_college,
                                       x_a_parents_agi                   =>  p_isir_rec.a_parents_agi,
                                       x_a_p_us_tax_paid                 =>  p_isir_rec.a_p_us_tax_paid,
                                       x_a_f_work_income                 =>  p_isir_rec.a_f_work_income,
                                       x_a_m_work_income                 =>  p_isir_rec.a_m_work_income,
                                       x_a_p_total_wsc                   =>  p_isir_rec.a_p_total_wsc,
                                       x_comment_codes                   =>  p_isir_rec.comment_codes,
                                       x_sar_ack_comm_code               =>  p_isir_rec.sar_ack_comm_code,
                                       x_pell_grant_elig_flag            =>  p_isir_rec.pell_grant_elig_flag,
                                       x_reprocess_reason_code           =>  p_isir_rec.reprocess_reason_code,
                                       x_duplicate_date                  =>  p_isir_rec.duplicate_date,
                                       x_isir_transaction_type           =>  p_isir_rec.isir_transaction_type,
                                       x_fedral_schl_code_indicator      =>  p_isir_rec.fedral_schl_code_indicator,
                                       x_multi_school_code_flags         =>  p_isir_rec.multi_school_code_flags,
                                       x_dup_ssn_indicator               =>  p_isir_rec.dup_ssn_indicator,
                                       x_payment_isir                    =>  p_isir_rec.payment_isir,
                                       x_receipt_status                  =>  p_isir_rec.receipt_status,
                                       x_isir_receipt_completed          =>  p_isir_rec.isir_receipt_completed,
                                       x_system_record_type              =>  p_isir_rec.system_record_type,
                                       x_verif_track_flag                =>  p_isir_rec.verif_track_flag,
                                       x_active_isir                     =>  p_isir_rec.active_isir,
                                       x_fafsa_data_verify_flags         =>  p_isir_rec.fafsa_data_verify_flags,
                                       x_reject_override_a               =>  p_isir_rec.reject_override_a,
                                       x_reject_override_c               =>  p_isir_rec.reject_override_c,
                                       x_parent_marital_status_date      =>  p_isir_rec.parent_marital_status_date,
                                       x_mode                            =>  'R',
                                       x_legacy_record_flag              =>  NULL,
                                       x_father_first_name_initial       =>  p_isir_rec.father_first_name_initial_txt    ,
                                       x_father_step_father_birth_dt     =>  p_isir_rec.father_step_father_birth_date    ,
                                       x_mother_first_name_initial       =>  p_isir_rec.mother_first_name_initial_txt    ,
                                       x_mother_step_mother_birth_dt     =>  p_isir_rec.mother_step_mother_birth_date    ,
                                       x_parents_email_address_txt       =>  p_isir_rec.parents_email_address_txt        ,
                                       x_address_change_type             =>  p_isir_rec.address_change_type              ,
                                       x_cps_pushed_isir_flag            =>  p_isir_rec.cps_pushed_isir_flag             ,
                                       x_electronic_transaction_type     =>  p_isir_rec.electronic_transaction_type      ,
                                       x_sar_c_change_type               =>  p_isir_rec.sar_c_change_type                ,
                                       x_father_ssn_match_type           =>  p_isir_rec.father_ssn_match_type            ,
                                       x_mother_ssn_match_type           =>  p_isir_rec.mother_ssn_match_type            ,
                                       x_reject_override_g_flag          =>  p_isir_rec.reject_override_g_flag,
                                       x_dhs_verification_num_txt        =>  p_isir_rec.dhs_verification_num_txt         ,
                                       x_data_file_name_txt              =>  p_isir_rec.data_file_name_txt               ,
                                       x_message_class_txt               =>  p_isir_rec.message_class_txt                ,
                                       x_reject_override_3_flag          => p_isir_rec.reject_override_3_flag,
                                       x_reject_override_12_flag        => p_isir_rec.reject_override_12_flag,
                                       x_reject_override_j_flag         => p_isir_rec.reject_override_j_flag,
                                       x_reject_override_k_flag         => p_isir_rec.reject_override_k_flag,
                                       x_rejected_status_change_flag    => p_isir_rec.rejected_status_change_flag,
                                       x_verification_selection_flag    => p_isir_rec.verification_selection_flag
                                      ) ;
  END update_isir;


  PROCEDURE save_as_correction_isir(
                                    p_org_isir_id      IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                    p_mod_isir_id      IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                    p_cal_type         IN  igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                                    p_sequence_number  IN  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                                    p_corr_status      IN  VARCHAR2 ,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    p_msg_name         OUT NOCOPY VARCHAR2
                                   ) IS

    ------------------------------------------------------------------
    --Created by  : brajendr
    --Date created: 17-Feb-2003
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    -- Get the details of ISIR Record from isir_matched table
    CURSOR c_isir_detials(
                          p_isir_id  igf_ap_isir_matched_all.isir_id%TYPE
                         ) IS
    SELECT *
      FROM igf_ap_isir_matched
     WHERE isir_id = p_isir_id;

    -- Get the details of
    CURSOR c_get_pymt_isir(
                           c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                          ) IS
    SELECT isir_id
      FROM igf_ap_isir_matched
     WHERE base_id = c_base_id
       AND system_record_type = 'ORIGINAL'
       AND payment_isir = 'Y' ;

    -- Get the details of
    CURSOR c_get_active_isir(
                             c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                            ) IS
    SELECT *
      FROM igf_ap_isir_matched
     WHERE base_id = c_base_id
       AND active_isir = 'Y';


    isir_detials_rec      igf_ap_isir_matched%ROWTYPE;
    corr_detials_rec      igf_ap_isir_matched%ROWTYPE;
    l_payment_isir_id     igf_ap_isir_matched_all.isir_id%TYPE;
    isir_row_id           ROWID;
    l_message             VARCHAR2(50);
    l_old_active_isir_id  igf_ap_isir_matched_all.isir_id%TYPE;
    l_anticip_status      VARCHAR2(30);
    l_awd_prc_status      VARCHAR2(30);


  BEGIN

    SAVEPOINT SP_ISIR;

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Fetch the modified ISIR details  (Internal ISIR Record)
    OPEN c_isir_detials( p_mod_isir_id);
    FETCH c_isir_detials INTO isir_detials_rec;
    CLOSE c_isir_detials;

    -- Fetch the Correction ISIR details
    OPEN c_isir_detials( p_org_isir_id);
    FETCH c_isir_detials INTO corr_detials_rec;
    CLOSE c_isir_detials;

    l_old_active_isir_id := NULL;

    -- make the existing Active ISIR = 'N'
    FOR c_get_active_isir_rec IN c_get_active_isir(corr_detials_rec.base_id) LOOP
      c_get_active_isir_rec.active_isir  := 'N';
      l_old_active_isir_id := c_get_active_isir_rec.isir_id;
      update_isir( c_get_active_isir_rec, c_get_active_isir_rec.isir_id, c_get_active_isir_rec.row_id);
    END LOOP;

    isir_detials_rec.system_record_type    := 'CORRECTION';
    isir_detials_rec.isir_transaction_type := 'C';
    isir_detials_rec.active_isir           := 'Y';
    isir_detials_rec.message_class_txt     := NULL; -- Passing NULL as the record is created internally and not imported from external system
    l_anticip_status  := NULL;
    l_awd_prc_status  := NULL;


    -- Correction ISIR record is alredy exits, then overwrite the existing correction ISIR with the modified values
    IF corr_detials_rec.system_record_type = 'CORRECTION' THEN

      update_isir( isir_detials_rec, p_org_isir_id, corr_detials_rec.row_id);

      -- Update the anticipated data and Award process status data.
      igf_ap_isir_gen_pkg.upd_ant_data_awd_prc_status( p_old_active_isir_id => l_old_active_isir_id,
                                                       p_new_active_isir_id => p_org_isir_id,
                                                       p_upd_ant_val        => 'Y',
                                                       p_anticip_status     => l_anticip_status,
                                                       p_awd_prc_status     => l_awd_prc_status
                                                     );


    -- Correction ISIR is not present in the system
    ELSE

      update_isir( isir_detials_rec, p_mod_isir_id, isir_detials_rec.row_id);

      -- Update the anticipated data and Award process status data.
      igf_ap_isir_gen_pkg.upd_ant_data_awd_prc_status( p_old_active_isir_id => l_old_active_isir_id,
                                                       p_new_active_isir_id => p_mod_isir_id,
                                                       p_upd_ant_val        => 'Y',
                                                       p_anticip_status     => l_anticip_status,
                                                       p_awd_prc_status     => l_awd_prc_status
                                                     );


    END IF;

    OPEN c_get_pymt_isir( isir_detials_rec.base_id);
    FETCH c_get_pymt_isir INTO l_payment_isir_id;
    CLOSE c_get_pymt_isir;

    -- Bug 3598933
    IF l_payment_isir_id is NULL THEN
      -- Student does not have a Payment ISIR
      -- Hence Create Correction Records against the Initial ISIR Being Saved as the Correction Rec.
      l_payment_isir_id := p_org_isir_id;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_ss_pkg.save_as_correction_isir.debug','Corrections generated against Non Payment Original ISIR');
      END IF;

    END IF;


    --Compare the Correction ISIR Created now with the Payment ISIR
    igf_aw_gen_002.compare_isirs(l_payment_isir_id, p_mod_isir_id, p_cal_type, p_sequence_number,p_corr_status);

    fnd_msg_pub.count_and_get(
                              p_encoded  => fnd_api.g_false,
                              p_count    => x_msg_count,
                              p_data     => x_msg_data
                             );

    -- If the Current SSN values are changed then Make a call to IGF_GR_GEN
    IF corr_detials_rec.current_ssn <> isir_detials_rec.current_ssn THEN
      igf_gr_gen.update_current_ssn(
                                    isir_detials_rec.base_id,
                                    isir_detials_rec.current_ssn,
                                    l_message
                                   );
       IF l_message = 'IGF_GR_UPDT_SSN_FAIL' THEN
         x_return_status := 'W';
         p_msg_name      := 'IGF_GR_UPDT_SSN_FAIL';
       END IF;
    ELSE
      p_msg_name := NULL;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK TO SP_ISIR;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

  END save_as_correction_isir;


  PROCEDURE create_simulation_isir(
                                   p_mod_isir_id    IN  igf_ap_isir_matched_all.isir_id%TYPE,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   x_return_status  OUT NOCOPY VARCHAR2
                                  ) IS
    ------------------------------------------------------------------
    --Created by  : brajendr
    --Date created: 17-Feb-2003
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

    -- Get the details of ISIR Record from isir_matched table
    CURSOR c_isir_detials(
                          p_isir_id  igf_ap_isir_matched_all.isir_id%TYPE
                         ) IS
    SELECT *
      FROM igf_ap_isir_matched
     WHERE isir_id = p_isir_id;

     --Cursor to get the Max Transaction Number from Prev SIMULATION ISIR Ids
    CURSOR cur_get_max_trans( c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT NVL(MAX(NVL(transaction_num,0)),0)+1
      FROM igf_ap_isir_matched
     WHERE system_record_type='SIMULATION'
       AND base_id = c_base_id;

    l_trans           igf_ap_isir_matched.transaction_num%TYPE;
    isir_detials_rec  igf_ap_isir_matched%ROWTYPE;

  BEGIN

    SAVEPOINT SP_ISIR;

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Fetch the modified ISIR details
    OPEN c_isir_detials( p_mod_isir_id);
    FETCH c_isir_detials INTO isir_detials_rec;
    CLOSE c_isir_detials;

    --Arrive at the Transaction Number for the new simulation record to be inserted
    OPEN cur_get_max_trans(isir_detials_rec.base_id);
    FETCH cur_get_max_trans INTO l_trans;
    CLOSE cur_get_max_trans;

    --Do not proceed further if transaction number  >99
    IF l_trans > 99  THEN
      fnd_message.set_name('IGF','IGF_AP_SIM_ISIR_MAX');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;

    ELSE

      isir_detials_rec.transaction_num:=LPAD(l_trans,2,'0');
      isir_detials_rec.system_record_type    := 'SIMULATION';
      isir_detials_rec.isir_transaction_type := 'S';
      isir_detials_rec.active_isir           := 'N';
      isir_detials_rec.message_class_txt     := NULL; -- Passing NULL as the record is created internally and not imported from external system

      update_isir( isir_detials_rec, p_mod_isir_id, isir_detials_rec.row_id);

    END IF;

    fnd_msg_pub.count_and_get(
                              p_encoded  => fnd_api.g_false,
                              p_count    => x_msg_count,
                              p_data     => x_msg_data
                             );

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK TO SP_ISIR;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

  END create_simulation_isir;


  PROCEDURE compute_efc(
                        p_isir_id            IN  igf_ap_isir_matched_all.isir_id%TYPE,
                        p_system_award_year  IN  VARCHAR2,
                        p_ignore_warnings    IN  VARCHAR2,
                        x_msg_count          OUT NOCOPY NUMBER,
                        x_msg_data           OUT NOCOPY VARCHAR2,
                        x_return_status      OUT NOCOPY VARCHAR2
                       )  IS
    /*
    ||  Created By : masehgal
    ||  Created On : 18-Feb-2003
    ||  Purpose : To be used for all self service wrappers to do efc calculations
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  masehgal        04-Mar-2003     # 2826603   Storing intermediate values for both
    ||                                  Success ( "S" ) and Warning ( "W" )
    ||  (reverse chronological order - newest change first)
    */

  CURSOR cur_isir_rec ( cp_isir_id    igf_ap_isir_matched_all.isir_id%TYPE )   IS
  SELECT isir.*
    FROM igf_ap_isir_matched isir
   WHERE isir_id = cp_isir_id ;

  isir_rec  cur_isir_rec%ROWTYPE ;
  l_msg_str  VARCHAR2(20000) := '';

-- Bug 4950206: Moved the follwing commented code to set_internal_isir procedure
--  CURSOR cur_get_ver_data (pn_base_id number) is
--  SELECT lkup.lookup_code col_name,
--         verf.item_value col_val
--    FROM igf_ap_inst_ver_item verf ,
--         igf_ap_fa_base_rec_all fabase ,
--         igf_ap_batch_aw_map map ,
--         igf_fc_sar_cd_mst sar ,
--         igf_lookups_view lkup
--   WHERE fabase.base_id = verf.base_id
--     AND verf.udf_vern_item_seq_num = 1
--     AND map.ci_cal_type = fabase.ci_cal_type
--     AND map.ci_sequence_number = fabase.ci_sequence_number
--     AND sar.sys_award_year = map.sys_award_year
--     AND sar.sar_field_number = verf.isir_map_col
--     AND lkup.lookup_type = 'IGF_AP_SAR_FIELD_MAP'
--     AND lkup.lookup_code = sar.sar_field_name
--     AND NVL(verf.waive_flag,'N') = 'N'
--     AND ((verf.item_value IS NOT NULL) OR (verf.item_value IS NULL AND verf.use_blank_flag = 'Y'))
--     AND verf.base_id = pn_base_id ;

--  l_get_ver_data_rec cur_get_ver_data%ROWTYPE;

  BEGIN

    FND_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT SP_ISIR;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Starting, Completed initializing the message pub and SAVEPOINT');
    END IF;

    OPEN  cur_isir_rec ( p_isir_id ) ;
    FETCH cur_isir_rec  INTO  isir_rec ;
    CLOSE cur_isir_rec ;

    -- Bug 4752938: Moved the follwing commented code to set_internal_isir procedure
    -- Initialize the package variable with the isir rec values
    --igf_ap_batch_ver_prc_pkg.lp_isir_rec := isir_rec;
    --IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    --  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','fetched ISIR Detials for ISIR ID: '||isir_rec.isir_id);
    --END IF;

    --OPEN  cur_get_ver_data ( isir_rec.base_id ) ;
    --LOOP
    --  FETCH cur_get_ver_data  INTO  l_get_ver_data_rec ;
    --  EXIT WHEN cur_get_ver_data%NOTFOUND;

    --  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    --    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','fetching verification items Item Name: '||l_get_ver_data_rec.col_name||' value:'||l_get_ver_data_rec.col_val);
    --  END IF;

    --  EXECUTE IMMEDIATE  'BEGIN igf_ap_batch_ver_prc_pkg.lp_isir_rec.'
    --                     || l_get_ver_data_rec.col_name || ' := ' ||  '''' || l_get_ver_data_rec.col_val || '''' || ' ; END;' ;
    --END LOOP;
    --CLOSE cur_get_ver_data ;

    --isir_rec := igf_ap_batch_ver_prc_pkg.lp_isir_rec;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Before calling main Calculate EFC routine with Ignore Warnings:'||p_ignore_warnings);
    END IF;

    igf_ap_efc_calc.calculate_efc(
                                  p_isir_rec         =>  isir_rec,
                                  p_ignore_warnings  =>  p_ignore_warnings,
                                  p_sys_batch_yr     =>  p_system_award_year,
                                  p_return_status    =>  x_return_status
                                 );

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','After calling main Calculate EFC routine Return Status:'||x_return_status);
    END IF;

    -- masehgal   # 2826603
    -- Storing intermediate values for both Success ( "S" ) and Warning ( "W" )
    IF x_return_status IN ('S','W')   THEN

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Updating ISIR Rec since the return status is either W or S');
      END IF;

        igf_ap_isir_matched_pkg.update_row(
                                       x_rowid                           =>  isir_rec.row_id,
                                       x_isir_id                         =>  p_isir_id,
                                       x_base_id                         =>  isir_rec.base_id,
                                       x_batch_year                      =>  isir_rec.batch_year,
                                       x_transaction_num                 =>  isir_rec.transaction_num,
                                       x_current_ssn                     =>  isir_rec.current_ssn,
                                       x_ssn_name_change                 =>  isir_rec.ssn_name_change,
                                       x_original_ssn                    =>  isir_rec.original_ssn,
                                       x_orig_name_id                    =>  isir_rec.orig_name_id,
                                       x_last_name                       =>  isir_rec.last_name,
                                       x_first_name                      =>  isir_rec.first_name,
                                       x_middle_initial                  =>  isir_rec.middle_initial,
                                       x_perm_mail_add                   =>  isir_rec.perm_mail_add,
                                       x_perm_city                       =>  isir_rec.perm_city,
                                       x_perm_state                      =>  isir_rec.perm_state,
                                       x_perm_zip_code                   =>  isir_rec.perm_zip_code,
                                       x_date_of_birth                   =>  isir_rec.date_of_birth,
                                       x_phone_number                    =>  isir_rec.phone_number,
                                       x_driver_license_number           =>  isir_rec.driver_license_number,
                                       x_driver_license_state            =>  isir_rec.driver_license_state,
                                       x_citizenship_status              =>  isir_rec.citizenship_status,
                                       x_alien_reg_number                =>  isir_rec.alien_reg_number,
                                       x_s_marital_status                =>  isir_rec.s_marital_status,
                                       x_s_marital_status_date           =>  isir_rec.s_marital_status_date,
                                       x_summ_enrl_status                =>  isir_rec.summ_enrl_status,
                                       x_fall_enrl_status                =>  isir_rec.fall_enrl_status,
                                       x_winter_enrl_status              =>  isir_rec.winter_enrl_status,
                                       x_spring_enrl_status              =>  isir_rec.spring_enrl_status,
                                       x_summ2_enrl_status               =>  isir_rec.summ2_enrl_status,
                                       x_fathers_highest_edu_level       =>  isir_rec.fathers_highest_edu_level,
                                       x_mothers_highest_edu_level       =>  isir_rec.mothers_highest_edu_level,
                                       x_s_state_legal_residence         =>  isir_rec.s_state_legal_residence,
                                       x_legal_residence_before_date     =>  isir_rec.legal_residence_before_date,
                                       x_s_legal_resd_date               =>  isir_rec.s_legal_resd_date,
                                       x_ss_r_u_male                     =>  isir_rec.ss_r_u_male,
                                       x_selective_service_reg           =>  isir_rec.selective_service_reg,
                                       x_degree_certification            =>  isir_rec.degree_certification,
                                       x_grade_level_in_college          =>  isir_rec.grade_level_in_college,
                                       x_high_school_diploma_ged         =>  isir_rec.high_school_diploma_ged,
                                       x_first_bachelor_deg_by_date      =>  isir_rec.first_bachelor_deg_by_date,
                                       x_interest_in_loan                =>  isir_rec.interest_in_loan,
                                       x_interest_in_stud_employment     =>  isir_rec.interest_in_stud_employment,
                                       x_drug_offence_conviction         =>  isir_rec.drug_offence_conviction,
                                       x_s_tax_return_status             =>  isir_rec.s_tax_return_status,
                                       x_s_type_tax_return               =>  isir_rec.s_type_tax_return,
                                       x_s_elig_1040ez                   =>  isir_rec.s_elig_1040ez,
                                       x_s_adjusted_gross_income         =>  isir_rec.s_adjusted_gross_income,
                                       x_s_fed_taxes_paid                =>  isir_rec.s_fed_taxes_paid,
                                       x_s_exemptions                    =>  isir_rec.s_exemptions,
                                       x_s_income_from_work              =>  isir_rec.s_income_from_work,
                                       x_spouse_income_from_work         =>  isir_rec.spouse_income_from_work,
                                       x_s_toa_amt_from_wsa              =>  isir_rec.s_toa_amt_from_wsa,
                                       x_s_toa_amt_from_wsb              =>  isir_rec.s_toa_amt_from_wsb,
                                       x_s_toa_amt_from_wsc              =>  isir_rec.s_toa_amt_from_wsc,
                                       x_s_investment_networth           =>  isir_rec.s_investment_networth,
                                       x_s_busi_farm_networth            =>  isir_rec.s_busi_farm_networth,
                                       x_s_cash_savings                  =>  isir_rec.s_cash_savings,
                                       x_va_months                       =>  isir_rec.va_months,
                                       x_va_amount                       =>  isir_rec.va_amount,
                                       x_stud_dob_before_date            =>  isir_rec.stud_dob_before_date,
                                       x_deg_beyond_bachelor             =>  isir_rec.deg_beyond_bachelor,
                                       x_s_married                       =>  isir_rec.s_married,
                                       x_s_have_children                 =>  isir_rec.s_have_children,
                                       x_legal_dependents                =>  isir_rec.legal_dependents,
                                       x_orphan_ward_of_court            =>  isir_rec.orphan_ward_of_court,
                                       x_s_veteran                       =>  isir_rec.s_veteran,
                                       x_p_marital_status                =>  isir_rec.p_marital_status,
                                       x_father_ssn                      =>  isir_rec.father_ssn,
                                       x_f_last_name                     =>  isir_rec.f_last_name,
                                       x_mother_ssn                      =>  isir_rec.mother_ssn,
                                       x_m_last_name                     =>  isir_rec.m_last_name,
                                       x_p_num_family_member             =>  isir_rec.p_num_family_member,
                                       x_p_num_in_college                =>  isir_rec.p_num_in_college,
                                       x_p_state_legal_residence         =>  isir_rec.p_state_legal_residence,
                                       x_p_state_legal_res_before_dt     =>  isir_rec.p_state_legal_res_before_dt,
                                       x_p_legal_res_date                =>  isir_rec.p_legal_res_date,
                                       x_age_older_parent                =>  isir_rec.age_older_parent,
                                       x_p_tax_return_status             =>  isir_rec.p_tax_return_status,
                                       x_p_type_tax_return               =>  isir_rec.p_type_tax_return,
                                       x_p_elig_1040aez                  =>  isir_rec.p_elig_1040aez,
                                       x_p_adjusted_gross_income         =>  isir_rec.p_adjusted_gross_income,
                                       x_p_taxes_paid                    =>  isir_rec.p_taxes_paid,
                                       x_p_exemptions                    =>  isir_rec.p_exemptions,
                                       x_f_income_work                   =>  isir_rec.f_income_work,
                                       x_m_income_work                   =>  isir_rec.m_income_work,
                                       x_p_income_wsa                    =>  isir_rec.p_income_wsa,
                                       x_p_income_wsb                    =>  isir_rec.p_income_wsb,
                                       x_p_income_wsc                    =>  isir_rec.p_income_wsc,
                                       x_p_investment_networth           =>  isir_rec.p_investment_networth,
                                       x_p_business_networth             =>  isir_rec.p_business_networth,
                                       x_p_cash_saving                   =>  isir_rec.p_cash_saving,
                                       x_s_num_family_members            =>  isir_rec.s_num_family_members,
                                       x_s_num_in_college                =>  isir_rec.s_num_in_college,
                                       x_first_college                   =>  isir_rec.first_college,
                                       x_first_house_plan                =>  isir_rec.first_house_plan,
                                       x_second_college                  =>  isir_rec.second_college,
                                       x_second_house_plan               =>  isir_rec.second_house_plan,
                                       x_third_college                   =>  isir_rec.third_college,
                                       x_third_house_plan                =>  isir_rec.third_house_plan,
                                       x_fourth_college                  =>  isir_rec.fourth_college,
                                       x_fourth_house_plan               =>  isir_rec.fourth_house_plan,
                                       x_fifth_college                   =>  isir_rec.fifth_college,
                                       x_fifth_house_plan                =>  isir_rec.fifth_house_plan,
                                       x_sixth_college                   =>  isir_rec.sixth_college,
                                       x_sixth_house_plan                =>  isir_rec.sixth_house_plan,
                                       x_date_app_completed              =>  isir_rec.date_app_completed,
                                       x_signed_by                       =>  isir_rec.signed_by,
                                       x_preparer_ssn                    =>  isir_rec.preparer_ssn,
                                       x_preparer_emp_id_number          =>  isir_rec.preparer_emp_id_number,
                                       x_preparer_sign                   =>  isir_rec.preparer_sign,
                                       x_transaction_receipt_date        =>  isir_rec.transaction_receipt_date,
                                       x_dependency_override_ind         =>  isir_rec.dependency_override_ind,
                                       x_faa_fedral_schl_code            =>  isir_rec.faa_fedral_schl_code,
                                       x_faa_adjustment                  =>  isir_rec.faa_adjustment,
                                       x_input_record_type               =>  isir_rec.input_record_type,
                                       x_serial_number                   =>  isir_rec.serial_number,
                                       x_batch_number                    =>  isir_rec.batch_number,
                                       x_early_analysis_flag             =>  isir_rec.early_analysis_flag,
                                       x_app_entry_source_code           =>  isir_rec.app_entry_source_code,
                                       x_eti_destination_code            =>  isir_rec.eti_destination_code,
                                       x_reject_override_b               =>  isir_rec.reject_override_b,
                                       x_reject_override_n               =>  isir_rec.reject_override_n,
                                       x_reject_override_w               =>  isir_rec.reject_override_w,
                                       x_assum_override_1                =>  isir_rec.assum_override_1,
                                       x_assum_override_2                =>  isir_rec.assum_override_2,
                                       x_assum_override_3                =>  isir_rec.assum_override_3,
                                       x_assum_override_4                =>  isir_rec.assum_override_4,
                                       x_assum_override_5                =>  isir_rec.assum_override_5,
                                       x_assum_override_6                =>  isir_rec.assum_override_6,
                                       x_dependency_status               =>  isir_rec.dependency_status,
                                       x_s_email_address                 =>  isir_rec.s_email_address,
                                       x_nslds_reason_code               =>  isir_rec.nslds_reason_code,
                                       x_app_receipt_date                =>  isir_rec.app_receipt_date,
                                       x_processed_rec_type              =>  isir_rec.processed_rec_type,
                                       x_hist_correction_for_tran_id     =>  isir_rec.hist_correction_for_tran_id,
                                       x_system_generated_indicator      =>  isir_rec.system_generated_indicator,
                                       x_dup_request_indicator           =>  isir_rec.dup_request_indicator,
                                       x_source_of_correction            =>  isir_rec.source_of_correction,
                                       x_p_cal_tax_status                =>  isir_rec.p_cal_tax_status,
                                       x_s_cal_tax_status                =>  isir_rec.s_cal_tax_status,
                                       x_graduate_flag                   =>  isir_rec.graduate_flag,
                                       x_auto_zero_efc                   =>  isir_rec.auto_zero_efc,
                                       x_efc_change_flag                 =>  isir_rec.efc_change_flag,
                                       x_sarc_flag                       =>  isir_rec.sarc_flag,
                                       x_simplified_need_test            =>  isir_rec.simplified_need_test,
                                       x_reject_reason_codes             =>  isir_rec.reject_reason_codes,
                                       x_select_service_match_flag       =>  isir_rec.select_service_match_flag,
                                       x_select_service_reg_flag         =>  isir_rec.select_service_reg_flag,
                                       x_ins_match_flag                  =>  isir_rec.ins_match_flag,
                                       x_ins_verification_number         =>  NULL,
                                       x_sec_ins_match_flag              =>  isir_rec.sec_ins_match_flag,
                                       x_sec_ins_ver_number              =>  isir_rec.sec_ins_ver_number,
                                       x_ssn_match_flag                  =>  isir_rec.ssn_match_flag,
                                       x_ssa_citizenship_flag            =>  isir_rec.ssa_citizenship_flag,
                                       x_ssn_date_of_death               =>  isir_rec.ssn_date_of_death,
                                       x_nslds_match_flag                =>  isir_rec.nslds_match_flag,
                                       x_va_match_flag                   =>  isir_rec.va_match_flag,
                                       x_prisoner_match                  =>  isir_rec.prisoner_match,
                                       x_verification_flag               =>  isir_rec.verification_flag,
                                       x_subsequent_app_flag             =>  isir_rec.subsequent_app_flag,
                                       x_app_source_site_code            =>  isir_rec.app_source_site_code,
                                       x_tran_source_site_code           =>  isir_rec.tran_source_site_code,
                                       x_drn                             =>  isir_rec.drn,
                                       x_tran_process_date               =>  isir_rec.tran_process_date,
                                       x_correction_flags                =>  isir_rec.correction_flags,
                                       x_computer_batch_number           =>  isir_rec.computer_batch_number,
                                       x_highlight_flags                 =>  isir_rec.highlight_flags,
                                       x_paid_efc                        =>  NULL,
                                       x_primary_efc                     =>  isir_rec.primary_efc,
                                       x_secondary_efc                   =>  isir_rec.secondary_efc,
                                       x_fed_pell_grant_efc_type         =>  NULL,
                                       x_primary_efc_type                =>  isir_rec.primary_efc_type,
                                       x_sec_efc_type                    =>  isir_rec.sec_efc_type,
                                       x_primary_alternate_month_1       =>  isir_rec.primary_alternate_month_1,
                                       x_primary_alternate_month_2       =>  isir_rec.primary_alternate_month_2,
                                       x_primary_alternate_month_3       =>  isir_rec.primary_alternate_month_3,
                                       x_primary_alternate_month_4       =>  isir_rec.primary_alternate_month_4,
                                       x_primary_alternate_month_5       =>  isir_rec.primary_alternate_month_5,
                                       x_primary_alternate_month_6       =>  isir_rec.primary_alternate_month_6,
                                       x_primary_alternate_month_7       =>  isir_rec.primary_alternate_month_7,
                                       x_primary_alternate_month_8       =>  isir_rec.primary_alternate_month_8,
                                       x_primary_alternate_month_10      =>  isir_rec.primary_alternate_month_10,
                                       x_primary_alternate_month_11      =>  isir_rec.primary_alternate_month_11,
                                       x_primary_alternate_month_12      =>  isir_rec.primary_alternate_month_12,
                                       x_sec_alternate_month_1           =>  isir_rec.sec_alternate_month_1,
                                       x_sec_alternate_month_2           =>  isir_rec.sec_alternate_month_2,
                                       x_sec_alternate_month_3           =>  isir_rec.sec_alternate_month_3,
                                       x_sec_alternate_month_4           =>  isir_rec.sec_alternate_month_4,
                                       x_sec_alternate_month_5           =>  isir_rec.sec_alternate_month_5,
                                       x_sec_alternate_month_6           =>  isir_rec.sec_alternate_month_6,
                                       x_sec_alternate_month_7           =>  isir_rec.sec_alternate_month_7,
                                       x_sec_alternate_month_8           =>  isir_rec.sec_alternate_month_8,
                                       x_sec_alternate_month_10          =>  isir_rec.sec_alternate_month_10,
                                       x_sec_alternate_month_11          =>  isir_rec.sec_alternate_month_11,
                                       x_sec_alternate_month_12          =>  isir_rec.sec_alternate_month_12,
                                       x_total_income                    =>  isir_rec.total_income,
                                       x_allow_total_income              =>  isir_rec.allow_total_income,
                                       x_state_tax_allow                 =>  isir_rec.state_tax_allow,
                                       x_employment_allow                =>  isir_rec.employment_allow,
                                       x_income_protection_allow         =>  isir_rec.income_protection_allow,
                                       x_available_income                =>  isir_rec.available_income,
                                       x_contribution_from_ai            =>  isir_rec.contribution_from_ai,
                                       x_discretionary_networth          =>  isir_rec.discretionary_networth,
                                       x_efc_networth                    =>  isir_rec.efc_networth,
                                       x_asset_protect_allow             =>  isir_rec.asset_protect_allow,
                                       x_parents_cont_from_assets        =>  isir_rec.parents_cont_from_assets,
                                       x_adjusted_available_income       =>  isir_rec.adjusted_available_income,
                                       x_total_student_contribution      =>  isir_rec.total_student_contribution,
                                       x_total_parent_contribution       =>  isir_rec.total_parent_contribution,
                                       x_parents_contribution            =>  isir_rec.parents_contribution,
                                       x_student_total_income            =>  isir_rec.student_total_income,
                                       x_sati                            =>  isir_rec.sati,
                                       x_sic                             =>  isir_rec.sic,
                                       x_sdnw                            =>  isir_rec.sdnw,
                                       x_sca                             =>  isir_rec.sca,
                                       x_fti                             =>  isir_rec.fti,
                                       x_secti                           =>  isir_rec.secti,
                                       x_secati                          =>  isir_rec.secati,
                                       x_secstx                          =>  isir_rec.secstx,
                                       x_secea                           =>  isir_rec.secea,
                                       x_secipa                          =>  isir_rec.secipa,
                                       x_secai                           =>  isir_rec.secai,
                                       x_seccai                          =>  isir_rec.seccai,
                                       x_secdnw                          =>  isir_rec.secdnw,
                                       x_secnw                           =>  isir_rec.secnw,
                                       x_secapa                          =>  isir_rec.secapa,
                                       x_secpca                          =>  isir_rec.secpca,
                                       x_secaai                          =>  isir_rec.secaai,
                                       x_sectsc                          =>  isir_rec.sectsc,
                                       x_sectpc                          =>  isir_rec.sectpc,
                                       x_secpc                           =>  isir_rec.secpc,
                                       x_secsti                          =>  isir_rec.secsti,
                                       x_secsati                         =>  isir_rec.secsati,
                                       x_secsic                          =>  isir_rec.secsic,
                                       x_secsdnw                         =>  isir_rec.secsdnw,
                                       x_secsca                          =>  isir_rec.secsca,
                                       x_secfti                          =>  isir_rec.secfti,
                                       x_a_citizenship                   =>  isir_rec.a_citizenship,
                                       x_a_student_marital_status        =>  isir_rec.a_student_marital_status,
                                       x_a_student_agi                   =>  isir_rec.a_student_agi,
                                       x_a_s_us_tax_paid                 =>  isir_rec.a_s_us_tax_paid,
                                       x_a_s_income_work                 =>  isir_rec.a_s_income_work,
                                       x_a_spouse_income_work            =>  isir_rec.a_spouse_income_work,
                                       x_a_s_total_wsc                   =>  isir_rec.a_s_total_wsc,
                                       x_a_date_of_birth                 =>  isir_rec.a_date_of_birth,
                                       x_a_student_married               =>  isir_rec.a_student_married,
                                       x_a_have_children                 =>  isir_rec.a_have_children,
                                       x_a_s_have_dependents             =>  isir_rec.a_s_have_dependents,
                                       x_a_va_status                     =>  isir_rec.a_va_status,
                                       x_a_s_num_in_family               =>  isir_rec.a_s_num_in_family,
                                       x_a_s_num_in_college              =>  isir_rec.a_s_num_in_college,
                                       x_a_p_marital_status              =>  isir_rec.a_p_marital_status,
                                       x_a_father_ssn                    =>  isir_rec.a_father_ssn,
                                       x_a_mother_ssn                    =>  isir_rec.a_mother_ssn,
                                       x_a_parents_num_family            =>  isir_rec.a_parents_num_family,
                                       x_a_parents_num_college           =>  isir_rec.a_parents_num_college,
                                       x_a_parents_agi                   =>  isir_rec.a_parents_agi,
                                       x_a_p_us_tax_paid                 =>  isir_rec.a_p_us_tax_paid,
                                       x_a_f_work_income                 =>  isir_rec.a_f_work_income,
                                       x_a_m_work_income                 =>  isir_rec.a_m_work_income,
                                       x_a_p_total_wsc                   =>  isir_rec.a_p_total_wsc,
                                       x_comment_codes                   =>  isir_rec.comment_codes,
                                       x_sar_ack_comm_code               =>  isir_rec.sar_ack_comm_code,
                                       x_pell_grant_elig_flag            =>  isir_rec.pell_grant_elig_flag,
                                       x_reprocess_reason_code           =>  isir_rec.reprocess_reason_code,
                                       x_duplicate_date                  =>  isir_rec.duplicate_date,
                                       x_isir_transaction_type           =>  isir_rec.isir_transaction_type,
                                       x_fedral_schl_code_indicator      =>  isir_rec.fedral_schl_code_indicator,
                                       x_multi_school_code_flags         =>  isir_rec.multi_school_code_flags,
                                       x_dup_ssn_indicator               =>  isir_rec.dup_ssn_indicator,
                                       x_payment_isir                    =>  isir_rec.payment_isir,
                                       x_receipt_status                  =>  isir_rec.receipt_status,
                                       x_isir_receipt_completed          =>  isir_rec.isir_receipt_completed,
                                       x_system_record_type              =>  isir_rec.system_record_type,
                                       x_verif_track_flag                =>  isir_rec.verif_track_flag,
                                       x_active_isir                     =>  isir_rec.active_isir,
                                       x_fafsa_data_verify_flags         =>  isir_rec.fafsa_data_verify_flags,
                                       x_reject_override_a               =>  isir_rec.reject_override_a,
                                       x_reject_override_c               =>  isir_rec.reject_override_c,
                                       x_parent_marital_status_date      =>  isir_rec.parent_marital_status_date,
                                       x_mode                            =>  'R',
                                       x_legacy_record_flag              =>  NULL,
                                       x_father_first_name_initial       =>  isir_rec.father_first_name_initial_txt  ,
                                       x_father_step_father_birth_dt     =>  isir_rec.father_step_father_birth_date  ,
                                       x_mother_first_name_initial       =>  isir_rec.mother_first_name_initial_txt  ,
                                       x_mother_step_mother_birth_dt     =>  isir_rec.mother_step_mother_birth_date  ,
                                       x_parents_email_address_txt       =>  isir_rec.parents_email_address_txt      ,
                                       x_address_change_type             =>  isir_rec.address_change_type            ,
                                       x_cps_pushed_isir_flag            =>  isir_rec.cps_pushed_isir_flag           ,
                                       x_electronic_transaction_type     =>  isir_rec.electronic_transaction_type    ,
                                       x_sar_c_change_type               =>  isir_rec.sar_c_change_type              ,
                                       x_father_ssn_match_type           =>  isir_rec.father_ssn_match_type          ,
                                       x_mother_ssn_match_type           =>  isir_rec.mother_ssn_match_type          ,
                                       x_reject_override_g_flag          =>  isir_rec.reject_override_g_flag,
                                       x_dhs_verification_num_txt        =>  isir_rec.dhs_verification_num_txt       ,
                                       x_data_file_name_txt              =>  isir_rec.data_file_name_txt              ,
                                       x_message_class_txt               =>  isir_rec.message_class_txt              ,
                                       x_reject_override_3_flag          => isir_rec.reject_override_3_flag,
                                       x_reject_override_12_flag         => isir_rec.reject_override_12_flag,
                                       x_reject_override_j_flag          => isir_rec.reject_override_j_flag,
                                       x_reject_override_k_flag          => isir_rec.reject_override_k_flag,
                                       x_rejected_status_change_flag     => isir_rec.rejected_status_change_flag,
                                       x_verification_selection_flag     => isir_rec.verification_selection_flag
                                      ) ;
    END IF; -- End of Return status 'S'/'W'

    IF x_return_status = 'W' THEN
      FOR i IN 1..fnd_msg_pub.count_msg LOOP
        l_msg_str := l_msg_str ||'  '|| to_char(i) ||'. '|| fnd_msg_pub.get(i,'F');
      END LOOP;


      -- Append the last Message
      fnd_message.SET_NAME('IGF','IGF_AP_SUPRESS_REJ_CODE');
      l_msg_str := l_msg_str ||'  '|| fnd_message.GET;


      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Wrapping Warning messages, l_msg_str:'||l_msg_str);
      END IF;

    ELSE

      fnd_msg_pub.count_and_get(
                              p_encoded  => fnd_api.g_false,
                              p_count    => x_msg_count,
                              p_data     => l_msg_str
                              );
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Wrapping Error messages, l_msg_str:'||l_msg_str);
      END IF;

    END IF;

    x_msg_data := l_msg_str;

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc','Returning back to SS page');
    END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SP_ISIR;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc.exception:FND_API.G_EXC_ERROR',SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SP_ISIR;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc.exception:FND_API.G_EXC_UNEXPECTED_ERROR',SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );

    WHEN OTHERS THEN
      ROLLBACK TO SP_ISIR;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_ss_pkg.compute_efc.exception:OTHERS',SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.count_and_get(
                                p_encoded  => fnd_api.g_false,
                                p_count    => x_msg_count,
                                p_data     => x_msg_data
                               );


  END compute_efc;


  PROCEDURE get_dynamic_dates(
                              p_sys_award_year IN VARCHAR2,
                              p_current_year   OUT NOCOPY VARCHAR2,
                              p_next_year      OUT NOCOPY VARCHAR2,
                              p_award_year     OUT NOCOPY VARCHAR2,
                              p_legal_res_dt   OUT NOCOPY VARCHAR2,
                              p_first_bachlor  OUT NOCOPY VARCHAR2,
                              p_born_before    OUT NOCOPY VARCHAR2
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 12-Mar-2003
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    ld_date DATE;
  BEGIN

    -- Assign the Default Date
    IF p_sys_award_year = '0203' THEN
       ld_date := TO_DATE('01/01/2002','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0304' THEN
       ld_date := TO_DATE('01/01/2003','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0405' THEN
       ld_date := TO_DATE('01/01/2004','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0506' THEN
       ld_date := TO_DATE('01/01/2005','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0607' THEN
       ld_date := TO_DATE('01/01/2006','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0708' THEN
       ld_date := TO_DATE('01/01/2007','DD/MM/YYYY');

    ELSIF p_sys_award_year = '0809' THEN
       ld_date := TO_DATE('01/01/2008','DD/MM/YYYY');

    END IF;

    -- Assign the Dynamic Prompts to the OUt Variables
    p_current_year   := TO_CHAR( ld_date, 'YYYY');
    p_next_year      := TO_CHAR( ADD_MONTHS(ld_date, 12), 'YYYY');
    p_award_year     := p_current_year || '-' || p_next_year;
    p_legal_res_dt   := fnd_date.date_to_displaydate( ADD_MONTHS( ld_date, -60));
    p_first_bachlor  := fnd_date.date_to_displaydate( ADD_MONTHS( ld_date, 6));
    p_born_before    := fnd_date.date_to_displaydate( ADD_MONTHS( ld_date, -276));

  END get_dynamic_dates;

  PROCEDURE get_internal_isir_id (
         p_isir_id IN IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE,
         p_ret_isir_id IN OUT NOCOPY IGF_AP_ISIR_MATCHED_ALL.ISIR_ID%TYPE
   )IS
       /*
   ||  Created By : hkodali
   ||  Created On : 07-01-2005
   ||  Purpose : To get the ISIR Id of internal ISIR, which will help to know if the Internal ISIR is locked.
   ||  If Internal ISIR id is 0 the  no internal ISIR present.
   ||  If Internal ISIR id is -2 , then internal ISIR is locked by another user
   ||  If Internal ISIR present and not locked by anothre user then the actual ISIR Id will be returned.
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
   */

    CURSOR c_isir (l_isir_id igf_ap_isir_matched_all.isir_id%type)
    IS
    SELECT ISIR.rowid row_id,ISIR.*
    FROM IGF_AP_ISIR_MATCHED_ALL ISIR
    WHERE ISIR.ISIR_ID = l_isir_id ;

    lv_isir c_isir%rowtype ;

    CURSOR chk_internal (l_base_id igf_ap_isir_matched_all.base_id%type)
    IS
    SELECT isir.rowid row_id,isir.isir_id FROM IGF_AP_ISIR_MATCHED_ALL ISIR
    WHERE
    ISIR.BASE_ID = l_base_id AND
    NVL(ISIR.SYSTEM_RECORD_TYPE,'X') = 'INTERNAL'
    FOR UPDATE NOWAIT;

    lv_chk_internal chk_internal%rowtype ;
    lv_rowid VARCHAR2(30) ;
    pn_isir_id igf_ap_isir_matched_all.isir_id%type ;

  BEGIN

    OPEN c_isir(p_isir_id) ;
    FETCH c_isir INTO lv_isir ;
    IF c_isir%FOUND THEN
        -- Check if the student has an Internal ISIR
      OPEN chk_internal(lv_isir.base_id);
      FETCH chk_internal into lv_chk_internal ;
      IF chk_internal%FOUND THEN
        CLOSE chk_internal ;
        p_ret_isir_id  := lv_chk_internal.isir_id ;
      ELSE
        CLOSE chk_internal ;
        lv_rowid   :=  null;
        pn_isir_id := null;

        igf_ap_isir_matched_pkg.insert_row(
              x_Mode                              => 'R',
              x_rowid                             => lv_rowid,
              x_isir_id                           => pn_isir_id,
              x_base_id                           => lv_isir.base_id,
              x_batch_year                        => lv_isir.batch_year                       ,
              x_transaction_num                   => lv_isir.transaction_num                  ,
              x_current_ssn                       => lv_isir.current_ssn                      ,
              x_ssn_name_change                   => lv_isir.ssn_name_change                  ,
              x_original_ssn                      => lv_isir.original_ssn                     ,
              x_orig_name_id                      => lv_isir.orig_name_id                     ,
              x_last_name                         => lv_isir.last_name                        ,
              x_first_name                        => lv_isir.first_name                       ,
              x_middle_initial                    => lv_isir.middle_initial                   ,
              x_perm_mail_add                     => lv_isir.perm_mail_add                    ,
              x_perm_city                         => lv_isir.perm_city                        ,
              x_perm_state                        => lv_isir.perm_state                       ,
              x_perm_zip_code                     => lv_isir.perm_zip_code                    ,
              x_date_of_birth                     => lv_isir.date_of_birth                    ,
              x_phone_number                      => lv_isir.phone_number                     ,
              x_driver_license_number             => lv_isir.driver_license_number            ,
              x_driver_license_state              => lv_isir.driver_license_state             ,
              x_citizenship_status                => lv_isir.citizenship_status               ,
              x_alien_reg_number                  => lv_isir.alien_reg_number                 ,
              x_s_marital_status                  => lv_isir.s_marital_status                 ,
              x_s_marital_status_date             => lv_isir.s_marital_status_date            ,
              x_summ_enrl_status                  => lv_isir.summ_enrl_status                 ,
              x_fall_enrl_status                  => lv_isir.fall_enrl_status                 ,
              x_winter_enrl_status                => lv_isir.winter_enrl_status               ,
              x_spring_enrl_status                => lv_isir.spring_enrl_status               ,
              x_summ2_enrl_status                 => lv_isir.summ2_enrl_status                ,
              x_fathers_highest_edu_level         => lv_isir.fathers_highest_edu_level        ,
              x_mothers_highest_edu_level         => lv_isir.mothers_highest_edu_level        ,
              x_s_state_legal_residence           => lv_isir.s_state_legal_residence          ,
              x_legal_residence_before_date       => lv_isir.legal_residence_before_date      ,
              x_s_legal_resd_date                 => lv_isir.s_legal_resd_date                ,
              x_ss_r_u_male                       => lv_isir.ss_r_u_male                      ,
              x_selective_service_reg             => lv_isir.selective_service_reg            ,
              x_degree_certification              => lv_isir.degree_certification             ,
              x_grade_level_in_college            => lv_isir.grade_level_in_college           ,
              x_high_school_diploma_ged           => lv_isir.high_school_diploma_ged          ,
              x_first_bachelor_deg_by_date        => lv_isir.first_bachelor_deg_by_date       ,
              x_interest_in_loan                  => lv_isir.interest_in_loan                 ,
              x_interest_in_stud_employment       => lv_isir.interest_in_stud_employment      ,
              x_drug_offence_conviction           => lv_isir.drug_offence_conviction          ,
              x_s_tax_return_status               => lv_isir.s_tax_return_status              ,
              x_s_type_tax_return                 => lv_isir.s_type_tax_return                ,
              x_s_elig_1040ez                     => lv_isir.s_elig_1040ez                    ,
              x_s_adjusted_gross_income           => lv_isir.s_adjusted_gross_income          ,
              x_s_fed_taxes_paid                  => lv_isir.s_fed_taxes_paid                 ,
              x_s_exemptions                      => lv_isir.s_exemptions                     ,
              x_s_income_from_work                => lv_isir.s_income_from_work               ,
              x_spouse_income_from_work           => lv_isir.spouse_income_from_work          ,
              x_s_toa_amt_from_wsa                => lv_isir.s_toa_amt_from_wsa               ,
              x_s_toa_amt_from_wsb                => lv_isir.s_toa_amt_from_wsb               ,
              x_s_toa_amt_from_wsc                => lv_isir.s_toa_amt_from_wsc               ,
              x_s_investment_networth             => lv_isir.s_investment_networth            ,
              x_s_busi_farm_networth              => lv_isir.s_busi_farm_networth             ,
              x_s_cash_savings                    => lv_isir.s_cash_savings                   ,
              x_va_months                         => lv_isir.va_months                        ,
              x_va_amount                         => lv_isir.va_amount                        ,
              x_stud_dob_before_date              => lv_isir.stud_dob_before_date             ,
              x_deg_beyond_bachelor               => lv_isir.deg_beyond_bachelor              ,
              x_s_married                         => lv_isir.s_married                        ,
              x_s_have_children                   => lv_isir.s_have_children                  ,
              x_legal_dependents                  => lv_isir.legal_dependents                 ,
              x_orphan_ward_of_court              => lv_isir.orphan_ward_of_court             ,
              x_s_veteran                         => lv_isir.s_veteran                        ,
              x_p_marital_status                  => lv_isir.p_marital_status                 ,
              x_father_ssn                        => lv_isir.father_ssn                       ,
              x_f_last_name                       => lv_isir.f_last_name                      ,
              x_mother_ssn                        => lv_isir.mother_ssn                       ,
              x_m_last_name                       => lv_isir.m_last_name                      ,
              x_p_num_family_member               => lv_isir.p_num_family_member              ,
              x_p_num_in_college                  => lv_isir.p_num_in_college                 ,
              x_p_state_legal_residence           => lv_isir.p_state_legal_residence          ,
              x_p_state_legal_res_before_dt       => lv_isir.p_state_legal_res_before_dt      ,
              x_p_legal_res_date                  => lv_isir.p_legal_res_date                 ,
              x_age_older_parent                  => lv_isir.age_older_parent                 ,
              x_p_tax_return_status               => lv_isir.p_tax_return_status              ,
              x_p_type_tax_return                 => lv_isir.p_type_tax_return                ,
              x_p_elig_1040aez                    => lv_isir.p_elig_1040aez                   ,
              x_p_adjusted_gross_income           => lv_isir.p_adjusted_gross_income          ,
              x_p_taxes_paid                      => lv_isir.p_taxes_paid                     ,
              x_p_exemptions                      => lv_isir.p_exemptions                     ,
              x_f_income_work                     => lv_isir.f_income_work                    ,
              x_m_income_work                     => lv_isir.m_income_work                    ,
              x_p_income_wsa                      => lv_isir.p_income_wsa                     ,
              x_p_income_wsb                      => lv_isir.p_income_wsb                     ,
              x_p_income_wsc                      => lv_isir.p_income_wsc                     ,
              x_p_investment_networth             => lv_isir.p_investment_networth            ,
              x_p_business_networth               => lv_isir.p_business_networth              ,
              x_p_cash_saving                     => lv_isir.p_cash_saving                    ,
              x_s_num_family_members              => lv_isir.s_num_family_members             ,
              x_s_num_in_college                  => lv_isir.s_num_in_college                 ,
              x_first_college                     => lv_isir.first_college                    ,
              x_first_house_plan                  => lv_isir.first_house_plan                 ,
              x_second_college                    => lv_isir.second_college                   ,
              x_second_house_plan                 => lv_isir.second_house_plan                ,
              x_third_college                     => lv_isir.third_college                    ,
              x_third_house_plan                  => lv_isir.third_house_plan                 ,
              x_fourth_college                    => lv_isir.fourth_college                   ,
              x_fourth_house_plan                 => lv_isir.fourth_house_plan                ,
              x_fifth_college                     => lv_isir.fifth_college                    ,
              x_fifth_house_plan                  => lv_isir.fifth_house_plan                 ,
              x_sixth_college                     => lv_isir.sixth_college                    ,
              x_sixth_house_plan                  => lv_isir.sixth_house_plan                 ,
              x_date_app_completed                => lv_isir.date_app_completed               ,
              x_signed_by                         => lv_isir.signed_by                        ,
              x_preparer_ssn                      => lv_isir.preparer_ssn                     ,
              x_preparer_emp_id_number            => lv_isir.preparer_emp_id_number           ,
              x_preparer_sign                     => lv_isir.preparer_sign                    ,
              x_transaction_receipt_date          => lv_isir.transaction_receipt_date         ,
              x_dependency_override_ind           => lv_isir.dependency_override_ind          ,
              x_faa_fedral_schl_code              => lv_isir.faa_fedral_schl_code             ,
              x_faa_adjustment                    => lv_isir.faa_adjustment                   ,
              x_input_record_type                 => lv_isir.input_record_type                ,
              x_serial_number                     => lv_isir.serial_number                    ,
              x_batch_number                      => lv_isir.batch_number                     ,
              x_early_analysis_flag               => lv_isir.early_analysis_flag              ,
              x_app_entry_source_code             => lv_isir.app_entry_source_code            ,
              x_eti_destination_code              => lv_isir.eti_destination_code             ,
              x_reject_override_b                 => lv_isir.reject_override_b                ,
              x_reject_override_n                 => lv_isir.reject_override_n                ,
              x_reject_override_w                 => lv_isir.reject_override_w                ,
              x_assum_override_1                  => lv_isir.assum_override_1                 ,
              x_assum_override_2                  => lv_isir.assum_override_2                 ,
              x_assum_override_3                  => lv_isir.assum_override_3                 ,
              x_assum_override_4                  => lv_isir.assum_override_4                 ,
              x_assum_override_5                  => lv_isir.assum_override_5                 ,
              x_assum_override_6                  => lv_isir.assum_override_6                 ,
              x_dependency_status                 => lv_isir.dependency_status                ,
              x_s_email_address                   => lv_isir.s_email_address                  ,
              x_nslds_reason_code                 => lv_isir.nslds_reason_code                ,
              x_app_receipt_date                  => lv_isir.app_receipt_date                 ,
              x_processed_rec_type                => lv_isir.processed_rec_type               ,
              x_hist_correction_for_tran_id       => lv_isir.hist_correction_for_tran_id      ,
              x_system_generated_indicator        => lv_isir.system_generated_indicator       ,
              x_dup_request_indicator             => lv_isir.dup_request_indicator            ,
              x_source_of_correction              => lv_isir.source_of_correction             ,
              x_p_cal_tax_status                  => lv_isir.p_cal_tax_status                 ,
              x_s_cal_tax_status                  => lv_isir.s_cal_tax_status                 ,
              x_graduate_flag                     => lv_isir.graduate_flag                    ,
              x_auto_zero_efc                     => lv_isir.auto_zero_efc                    ,
              x_efc_change_flag                   => lv_isir.efc_change_flag                  ,
              x_sarc_flag                         => lv_isir.sarc_flag                        ,
              x_simplified_need_test              => lv_isir.simplified_need_test             ,
              x_reject_reason_codes               => lv_isir.reject_reason_codes              ,
              x_select_service_match_flag         => lv_isir.select_service_match_flag        ,
              x_select_service_reg_flag           => lv_isir.select_service_reg_flag          ,
              x_ins_match_flag                    => lv_isir.ins_match_flag                   ,
              x_ins_verification_number           => NULL,
              x_sec_ins_match_flag                => lv_isir.sec_ins_match_flag               ,
              x_sec_ins_ver_number                => lv_isir.sec_ins_ver_number               ,
              x_ssn_match_flag                    => lv_isir.ssn_match_flag                   ,
              x_ssa_citizenship_flag              => lv_isir.ssa_citizenship_flag             ,
              x_ssn_date_of_death                 => lv_isir.ssn_date_of_death                ,
              x_nslds_match_flag                  => lv_isir.nslds_match_flag                 ,
              x_va_match_flag                     => lv_isir.va_match_flag                    ,
              x_prisoner_match                    => lv_isir.prisoner_match                   ,
              x_verification_flag                 => lv_isir.verification_flag                ,
              x_subsequent_app_flag               => lv_isir.subsequent_app_flag              ,
              x_app_source_site_code              => lv_isir.app_source_site_code             ,
              x_tran_source_site_code             => lv_isir.tran_source_site_code            ,
              x_drn                               => lv_isir.drn                              ,
              x_tran_process_date                 => lv_isir.tran_process_date                ,
              x_computer_batch_number             => lv_isir.computer_batch_number            ,
              x_correction_flags                  => lv_isir.correction_flags                 ,
              x_highlight_flags                   => lv_isir.highlight_flags                  ,
              x_paid_efc                          => NULL                        ,
              x_primary_efc                       => lv_isir.primary_efc                      ,
              x_secondary_efc                     => lv_isir.secondary_efc                    ,
              x_fed_pell_grant_efc_type           => NULL          ,
              x_primary_efc_type                  => lv_isir.primary_efc_type                 ,
              x_sec_efc_type                      => lv_isir.sec_efc_type                     ,
              x_primary_alternate_month_1         => lv_isir.primary_alternate_month_1        ,
              x_primary_alternate_month_2         => lv_isir.primary_alternate_month_2        ,
              x_primary_alternate_month_3         => lv_isir.primary_alternate_month_3        ,
              x_primary_alternate_month_4         => lv_isir.primary_alternate_month_4        ,
              x_primary_alternate_month_5         => lv_isir.primary_alternate_month_5        ,
              x_primary_alternate_month_6         => lv_isir.primary_alternate_month_6        ,
              x_primary_alternate_month_7         => lv_isir.primary_alternate_month_7        ,
              x_primary_alternate_month_8         => lv_isir.primary_alternate_month_8        ,
              x_primary_alternate_month_10        => lv_isir.primary_alternate_month_10       ,
              x_primary_alternate_month_11        => lv_isir.primary_alternate_month_11       ,
              x_primary_alternate_month_12        => lv_isir.primary_alternate_month_12       ,
              x_sec_alternate_month_1             => lv_isir.sec_alternate_month_1            ,
              x_sec_alternate_month_2             => lv_isir.sec_alternate_month_2            ,
              x_sec_alternate_month_3             => lv_isir.sec_alternate_month_3            ,
              x_sec_alternate_month_4             => lv_isir.sec_alternate_month_4            ,
              x_sec_alternate_month_5             => lv_isir.sec_alternate_month_5            ,
              x_sec_alternate_month_6             => lv_isir.sec_alternate_month_6            ,
              x_sec_alternate_month_7             => lv_isir.sec_alternate_month_7            ,
              x_sec_alternate_month_8             => lv_isir.sec_alternate_month_8            ,
              x_sec_alternate_month_10            => lv_isir.sec_alternate_month_10           ,
              x_sec_alternate_month_11            => lv_isir.sec_alternate_month_11           ,
              x_sec_alternate_month_12            => lv_isir.sec_alternate_month_12           ,
              x_total_income                      => lv_isir.total_income                     ,
              x_allow_total_income                => lv_isir.allow_total_income               ,
              x_state_tax_allow                   => lv_isir.state_tax_allow                  ,
              x_employment_allow                  => lv_isir.employment_allow                 ,
              x_income_protection_allow           => lv_isir.income_protection_allow          ,
              x_available_income                  => lv_isir.available_income                 ,
              x_contribution_from_ai              => lv_isir.contribution_from_ai             ,
              x_discretionary_networth            => lv_isir.discretionary_networth           ,
              x_efc_networth                      => lv_isir.efc_networth                     ,
              x_asset_protect_allow               => lv_isir.asset_protect_allow              ,
              x_parents_cont_from_assets          => lv_isir.parents_cont_from_assets         ,
              x_adjusted_available_income         => lv_isir.adjusted_available_income        ,
              x_total_student_contribution        => lv_isir.total_student_contribution       ,
              x_total_parent_contribution         => lv_isir.total_parent_contribution        ,
              x_parents_contribution              => lv_isir.parents_contribution             ,
              x_student_total_income              => lv_isir.student_total_income             ,
              x_sati                              => lv_isir.sati                             ,
              x_sic                               => lv_isir.sic                              ,
              x_sdnw                              => lv_isir.sdnw                             ,
              x_sca                               => lv_isir.sca                              ,
              x_fti                               => lv_isir.fti                              ,
              x_secti                             => lv_isir.secti                            ,
              x_secati                            => lv_isir.secati                           ,
              x_secstx                            => lv_isir.secstx                           ,
              x_secea                             => lv_isir.secea                            ,
              x_secipa                            => lv_isir.secipa                           ,
              x_secai                             => lv_isir.secai                            ,
              x_seccai                            => lv_isir.seccai                           ,
              x_secdnw                            => lv_isir.secdnw                           ,
              x_secnw                             => lv_isir.secnw                            ,
              x_secapa                            => lv_isir.secapa                           ,
              x_secpca                            => lv_isir.secpca                           ,
              x_secaai                            => lv_isir.secaai                           ,
              x_sectsc                            => lv_isir.sectsc                           ,
              x_sectpc                            => lv_isir.sectpc                           ,
              x_secpc                             => lv_isir.secpc                            ,
              x_secsti                            => lv_isir.secsti                           ,
              x_secsic                            => lv_isir.secsic                           ,
              x_secsati                           => lv_isir.secsati                          ,
              x_secsdnw                           => lv_isir.secsdnw                          ,
              x_secsca                            => lv_isir.secsca                           ,
              x_secfti                            => lv_isir.secfti                           ,
              x_a_citizenship                     => lv_isir.a_citizenship                    ,
              x_a_student_marital_status          => lv_isir.a_student_marital_status         ,
              x_a_student_agi                     => lv_isir.a_student_agi                    ,
              x_a_s_us_tax_paid                   => lv_isir.a_s_us_tax_paid                  ,
              x_a_s_income_work                   => lv_isir.a_s_income_work                  ,
              x_a_spouse_income_work              => lv_isir.a_spouse_income_work             ,
              x_a_s_total_wsc                     => lv_isir.a_s_total_wsc                    ,
              x_a_date_of_birth                   => lv_isir.a_date_of_birth                  ,
              x_a_student_married                 => lv_isir.a_student_married                ,
              x_a_have_children                   => lv_isir.a_have_children                  ,
              x_a_s_have_dependents               => lv_isir.a_s_have_dependents              ,
              x_a_va_status                       => lv_isir.a_va_status                      ,
              x_a_s_num_in_family                 => lv_isir.a_s_num_in_family                ,
              x_a_s_num_in_college                => lv_isir.a_s_num_in_college               ,
              x_a_p_marital_status                => lv_isir.a_p_marital_status               ,
              x_a_father_ssn                      => lv_isir.a_father_ssn                     ,
              x_a_mother_ssn                      => lv_isir.a_mother_ssn                     ,
              x_a_parents_num_family              => lv_isir.a_parents_num_family             ,
              x_a_parents_num_college             => lv_isir.a_parents_num_college            ,
              x_a_parents_agi                     => lv_isir.a_parents_agi                    ,
              x_a_p_us_tax_paid                   => lv_isir.a_p_us_tax_paid                  ,
              x_a_f_work_income                   => lv_isir.a_f_work_income                  ,
              x_a_m_work_income                   => lv_isir.a_m_work_income                  ,
              x_a_p_total_wsc                     => lv_isir.a_p_total_wsc                    ,
              x_comment_codes                     => lv_isir.comment_codes                    ,
              x_sar_ack_comm_code                 => lv_isir.sar_ack_comm_code                ,
              x_pell_grant_elig_flag              => lv_isir.pell_grant_elig_flag             ,
              x_reprocess_reason_code             => lv_isir.reprocess_reason_code            ,
              x_duplicate_date                    => lv_isir.duplicate_date                   ,
              x_isir_transaction_type             => lv_isir.isir_transaction_type            ,
              x_fedral_schl_code_indicator        => lv_isir.fedral_schl_code_indicator       ,
              x_multi_school_code_flags           => lv_isir.multi_school_code_flags          ,
              x_dup_ssn_indicator                 => lv_isir.dup_ssn_indicator                ,
              x_system_record_type                => 'INTERNAL'               ,
              x_payment_isir                      => 'N'                     ,
              x_receipt_status                    => lv_isir.receipt_status                   ,
              x_isir_receipt_completed            => lv_isir.isir_receipt_completed           ,
              x_active_isir                       => 'N'                      ,
              x_fafsa_data_verify_flags           => lv_isir.fafsa_data_verify_flags          ,
              x_reject_override_a                 => lv_isir.reject_override_a                ,
              x_reject_override_c                 => lv_isir.reject_override_c                ,
              x_parent_marital_status_date        => lv_isir.parent_marital_status_date       ,
              x_legacy_record_flag                => NULL                                     ,
              x_father_first_name_initial         => lv_isir.FATHER_FIRST_NAME_INITIAL_TXT    ,
              x_father_step_father_birth_dt       => lv_isir.FATHER_STEP_FATHER_BIRTH_DATE    ,
              x_mother_first_name_initial         => lv_isir.MOTHER_FIRST_NAME_INITIAL_TXT    ,
              x_mother_step_mother_birth_dt       => lv_isir.MOTHER_STEP_MOTHER_BIRTH_DATE    ,
              x_parents_email_address_txt         => lv_isir.PARENTS_EMAIL_ADDRESS_TXT        ,
              x_address_change_type               => lv_isir.ADDRESS_CHANGE_TYPE              ,
              x_cps_pushed_isir_flag              => lv_isir.CPS_PUSHED_ISIR_FLAG             ,
              x_electronic_transaction_type       => lv_isir.ELECTRONIC_TRANSACTION_TYPE      ,
              x_sar_c_change_type                 => lv_isir.SAR_C_CHANGE_TYPE                ,
              x_father_ssn_match_type             => lv_isir.FATHER_SSN_MATCH_TYPE            ,
              x_mother_ssn_match_type             => lv_isir.MOTHER_SSN_MATCH_TYPE            ,
              x_reject_override_g_flag            => lv_isir.REJECT_OVERRIDE_G_FLAG,
              x_dhs_verification_num_txt          => lv_isir.dhs_verification_num_txt         ,
              x_data_file_name_txt                => lv_isir.data_file_name_txt               ,
              x_message_class_txt                 => NULL,  -- Passing NULL as the record is created internally
              x_reject_override_3_flag            => lv_isir.reject_override_3_flag,
              x_reject_override_12_flag           => lv_isir.reject_override_12_flag,
              x_reject_override_j_flag            => lv_isir.reject_override_j_flag,
              x_reject_override_k_flag            => lv_isir.reject_override_k_flag,
              x_rejected_status_change_flag       => lv_isir.rejected_status_change_flag,
              x_verification_selection_flag       => lv_isir.verification_selection_flag
              );
        p_ret_isir_id  := pn_isir_id ;
        COMMIT;

        OPEN chk_internal(lv_isir.base_id);
        FETCH chk_internal into lv_chk_internal ;
        IF chk_internal%FOUND THEN
          CLOSE chk_internal ;
          p_ret_isir_id  := lv_chk_internal.isir_id ;
        ELSE
          CLOSE chk_internal ;
        END IF;

      END IF;
      CLOSE c_isir;
    ELSE
      -- ISIR Not FOUND hence return -1
      CLOSE c_isir;
      p_ret_isir_id  := -1 ;
    RETURN  ;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -54 THEN
           -- ORA-00054: resource busy and acquire with NOWAIT specified
          p_ret_isir_id := -2;
        ELSE
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','igf_ap_ss_pkg.set_internal_isir');
          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_ss_pkg.set_internal_isir.exception','Exception: '||SQLERRM);
          END IF;
          IGS_GE_MSG_STACK.ADD;
        END IF;
  END get_internal_isir_id;

  PROCEDURE insert_into_todo(
                              p_base_id NUMBER,
                              p_seq_num NUMBER,
                              p_status VARCHAR2,
                              p_req_for_app VARCHAR2,
                              p_freq_attempt NUMBER,
                              p_max_attempt NUMBER
                            ) IS
   /*
   ||  Change History :
   ||  Who            When            What
   ||  museshad       17-Nov-2005     Bug 4741517.
   ||                                 ToDo Item was getting inserted as 'Inactive'
   ||                                 bcoz the x_inactive_flag was being sent as
   ||                                 NULL. Modified this and made x_inactive_flag
   ||                                 as 'N'.
   ||  (reverse chronological order - newest change first)
   */
    l_row_id rowid;
  BEGIN
    igf_ap_td_item_inst_pkg.insert_row(
      x_mode                              => 'R',
      x_rowid                             => l_row_id,
      x_base_id                           => p_base_id,
      x_item_sequence_number              => p_seq_num,
      x_status                            => p_status,
      x_status_date                       => SYSDATE,
      x_add_date                          => SYSDATE,
      x_corsp_date                        => NULL,
      x_corsp_count                       => NULL,
      x_inactive_flag                     => 'N',
      x_required_for_application          => p_req_for_app,
      x_max_attempt                       => p_freq_attempt,
      x_freq_attempt                      => p_max_attempt,
      x_legacy_record_flag                => NULL,
      x_clprl_id                          => NULL );

  END insert_into_todo;


END IGF_AP_SS_PKG;

/
