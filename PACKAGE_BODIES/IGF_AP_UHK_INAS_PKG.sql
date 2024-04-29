--------------------------------------------------------
--  DDL for Package Body IGF_AP_UHK_INAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_UHK_INAS_PKG" AS
/* $Header: IGFAP46B.pls 120.0 2005/06/01 14:54:09 appldev noship $ */
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 30-SEP-2003
--
--Purpose:
--   The userhook function to calculate student's Institutional Methodology Expected Family Contribution
--
--Known limitations/enhancements and/or remarks:
--  1. This package can be run only if INAS is integrated. The code is customized at customer location
--  2. This will overwrite the userhook is already a version is installed in the customer site.
--Change History:
--Who         When            What
-------------------------------------------------------------------

  FUNCTION get_im_efc(
                        p_sys_awd_year IN            igf_ap_batch_aw_map.sys_award_year%TYPE,
                        p_profile_rec  IN OUT NOCOPY igf_ap_css_profile%ROWTYPE,
                        p_fnar_rec     IN OUT NOCOPY igf_ap_css_fnar%ROWTYPE,
                        p_error_msg    OUT    NOCOPY fnd_new_messages.message_name%TYPE
                      ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 30-SEP-2003
  --
  --Purpose:
  --   This is the user hook function to calculate EFC according to Institutional Methodology
  --   Parameters:
  --    p_sys_awd_year         - System Award Year (like 0203, 0304,etc.)
  --    p_profile_rec          - Profile record type
  --    p_fnar_rec             - FNAR record type
  --    p_error_msg            - Error message,if any,returned from the external application
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN
    RETURN TRUE;
  END get_im_efc;

   FUNCTION efc_i_award_prd(
                            p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE
                           ) RETURN NUMBER AS
   ------------------------------------------------------------------
   --Created by  : veramach, Oracle India
   --Date created: 02-Nov-2004
   --
   --Purpose:
   --   Calculate IM EFC.
   --   Parameters:
   --   p_base_id      - Student for whom EFC needs to be calculated
   --   p_awd_prd_code - Award Period in which EFC has to be calculated
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   -------------------------------------------------------------------
   BEGIN
     RETURN 0;
   END efc_i_award_prd;

  FUNCTION  callHook(
                    p_sys_awd_year   IN igf_ap_batch_aw_map.sys_award_year%TYPE,

                    pr_cssp_id                    IN OUT NOCOPY igf_ap_css_profile.cssp_id%TYPE                      ,
                    pr_org_id                     IN OUT NOCOPY igf_ap_css_profile.org_id%TYPE                       ,
                    pr_base_id                    IN OUT NOCOPY igf_ap_css_profile.base_id%TYPE                      ,
                    pr_system_record_type         IN OUT NOCOPY igf_ap_css_profile.system_record_type%TYPE           ,
                    pr_active_profile             IN OUT NOCOPY igf_ap_css_profile.active_profile%TYPE               ,
                    pr_college_code               IN OUT NOCOPY igf_ap_css_profile.college_code%TYPE                 ,
                    pr_academic_year              IN OUT NOCOPY igf_ap_css_profile.academic_year%TYPE                ,
                    pr_stu_record_type            IN OUT NOCOPY igf_ap_css_profile.stu_record_type%TYPE              ,
                    pr_css_id_number              IN OUT NOCOPY igf_ap_css_profile.css_id_number%TYPE                ,
                    pr_registration_receipt_date  IN OUT NOCOPY igf_ap_css_profile.registration_receipt_date%TYPE    ,
                    pr_registration_type          IN OUT NOCOPY igf_ap_css_profile.registration_type%TYPE            ,
                    pr_application_receipt_date   IN OUT NOCOPY igf_ap_css_profile.application_receipt_date%TYPE     ,
                    pr_application_type           IN OUT NOCOPY igf_ap_css_profile.application_type%TYPE             ,
                    pr_original_fnar_compute      IN OUT NOCOPY igf_ap_css_profile.original_fnar_compute%TYPE        ,
                    pr_revision_fnar_compute_date IN OUT NOCOPY igf_ap_css_profile.revision_fnar_compute_date%TYPE   ,
                    pr_electronic_extract_date    IN OUT NOCOPY igf_ap_css_profile.electronic_extract_date%TYPE      ,
                    pr_inst_reporting_type        IN OUT NOCOPY igf_ap_css_profile.institutional_reporting_type%TYPE ,
                    pr_asr_receipt_date           IN OUT NOCOPY igf_ap_css_profile.asr_receipt_date%TYPE             ,
                    pr_last_name                  IN OUT NOCOPY igf_ap_css_profile.last_name%TYPE                    ,
                    pr_first_name                 IN OUT NOCOPY igf_ap_css_profile.first_name%TYPE                   ,
                    pr_middle_initial             IN OUT NOCOPY igf_ap_css_profile.middle_initial%TYPE               ,
                    pr_address_number_and_street  IN OUT NOCOPY igf_ap_css_profile.address_number_and_street%TYPE    ,
                    pr_city                       IN OUT NOCOPY igf_ap_css_profile.city%TYPE                        ,
                    pr_state_mailing              IN OUT NOCOPY igf_ap_css_profile.state_mailing%TYPE                ,
                    pr_zip_code                   IN OUT NOCOPY igf_ap_css_profile.zip_code%TYPE                     ,
                    pr_s_telephone_number         IN OUT NOCOPY igf_ap_css_profile.s_telephone_number%TYPE           ,
                    pr_s_title                    IN OUT NOCOPY igf_ap_css_profile.s_title%TYPE                      ,
                    pr_date_of_birth              IN OUT NOCOPY igf_ap_css_profile.date_of_birth%TYPE                ,
                    pr_social_security_number     IN OUT NOCOPY igf_ap_css_profile.social_security_number%TYPE       ,
                    pr_state_legal_residence      IN OUT NOCOPY igf_ap_css_profile.state_legal_residence%TYPE        ,
                    pr_foreign_address_indicator  IN OUT NOCOPY igf_ap_css_profile.foreign_address_indicator%TYPE    ,
                    pr_foreign_postal_code        IN OUT NOCOPY igf_ap_css_profile.foreign_postal_code%TYPE          ,
                    pr_country                    IN OUT NOCOPY igf_ap_css_profile.country%TYPE                      ,
                    pr_financial_aid_status       IN OUT NOCOPY igf_ap_css_profile.financial_aid_status%TYPE         ,
                    pr_year_in_college            IN OUT NOCOPY igf_ap_css_profile.year_in_college%TYPE              ,
                    pr_marital_status             IN OUT NOCOPY igf_ap_css_profile.marital_status%TYPE               ,
                    pr_ward_court                 IN OUT NOCOPY igf_ap_css_profile.ward_court%TYPE                   ,
                    pr_legal_dependents_other     IN OUT NOCOPY igf_ap_css_profile.legal_dependents_other%TYPE       ,
                    pr_household_size             IN OUT NOCOPY igf_ap_css_profile.household_size%TYPE               ,
                    pr_number_in_college          IN OUT NOCOPY igf_ap_css_profile.number_in_college%TYPE            ,
                    pr_citizenship_status         IN OUT NOCOPY igf_ap_css_profile.citizenship_status%TYPE           ,
                    pr_citizenship_country        IN OUT NOCOPY igf_ap_css_profile.citizenship_country%TYPE          ,
                    pr_visa_classification        IN OUT NOCOPY igf_ap_css_profile.visa_classification%TYPE          ,
                    pr_tax_figures                IN OUT NOCOPY igf_ap_css_profile.tax_figures%TYPE                  ,
                    pr_number_exemptions          IN OUT NOCOPY igf_ap_css_profile.number_exemptions%TYPE            ,
                    pr_adjusted_gross_inc         IN OUT NOCOPY igf_ap_css_profile.adjusted_gross_inc%TYPE           ,
                    pr_us_tax_paid                IN OUT NOCOPY igf_ap_css_profile.us_tax_paid%TYPE                  ,
                    pr_itemized_deductions        IN OUT NOCOPY igf_ap_css_profile.itemized_deductions%TYPE          ,
                    pr_stu_income_work            IN OUT NOCOPY igf_ap_css_profile.stu_income_work%TYPE              ,
                    pr_spouse_income_work         IN OUT NOCOPY igf_ap_css_profile.spouse_income_work%TYPE           ,
                    pr_divid_int_inc              IN OUT NOCOPY igf_ap_css_profile.divid_int_inc%TYPE                ,
                    pr_soc_sec_benefits           IN OUT NOCOPY igf_ap_css_profile.soc_sec_benefits%TYPE             ,
                    pr_welfare_tanf               IN OUT NOCOPY igf_ap_css_profile.welfare_tanf%TYPE                 ,
                    pr_child_supp_rcvd            IN OUT NOCOPY igf_ap_css_profile.child_supp_rcvd%TYPE              ,
                    pr_earned_income_credit       IN OUT NOCOPY igf_ap_css_profile.earned_income_credit%TYPE         ,
                    pr_other_untax_income         IN OUT NOCOPY igf_ap_css_profile.other_untax_income%TYPE           ,
                    pr_tax_stu_aid                IN OUT NOCOPY igf_ap_css_profile.tax_stu_aid%TYPE                  ,
                    pr_cash_sav_check             IN OUT NOCOPY igf_ap_css_profile.cash_sav_check%TYPE               ,
                    pr_ira_keogh                  IN OUT NOCOPY igf_ap_css_profile.ira_keogh%TYPE                    ,
                    pr_invest_value               IN OUT NOCOPY igf_ap_css_profile.invest_value%TYPE                 ,
                    pr_invest_debt                IN OUT NOCOPY igf_ap_css_profile.invest_debt%TYPE                  ,
                    pr_home_value                 IN OUT NOCOPY igf_ap_css_profile.home_value%TYPE                   ,
                    pr_home_debt                  IN OUT NOCOPY igf_ap_css_profile.home_debt%TYPE                    ,
                    pr_oth_real_value             IN OUT NOCOPY igf_ap_css_profile.oth_real_value%TYPE               ,
                    pr_oth_real_debt              IN OUT NOCOPY igf_ap_css_profile.oth_real_debt%TYPE                ,
                    pr_bus_farm_value             IN OUT NOCOPY igf_ap_css_profile.bus_farm_value%TYPE               ,
                    pr_bus_farm_debt              IN OUT NOCOPY igf_ap_css_profile.bus_farm_debt%TYPE                ,
                    pr_live_on_farm               IN OUT NOCOPY igf_ap_css_profile.live_on_farm%TYPE                 ,
                    pr_home_purch_price           IN OUT NOCOPY igf_ap_css_profile.home_purch_price%TYPE             ,
                    pr_hope_ll_credit             IN OUT NOCOPY igf_ap_css_profile.hope_ll_credit%TYPE               ,
                    pr_home_purch_year            IN OUT NOCOPY igf_ap_css_profile.home_purch_year%TYPE              ,
                    pr_trust_amount               IN OUT NOCOPY igf_ap_css_profile.trust_amount%TYPE                 ,
                    pr_trust_avail                IN OUT NOCOPY igf_ap_css_profile.trust_avail%TYPE                  ,
                    pr_trust_estab                IN OUT NOCOPY igf_ap_css_profile.trust_estab%TYPE                  ,
                    pr_child_support_paid         IN OUT NOCOPY igf_ap_css_profile.child_support_paid%TYPE           ,
                    pr_med_dent_expenses          IN OUT NOCOPY igf_ap_css_profile.med_dent_expenses%TYPE            ,
                    pr_vet_us                     IN OUT NOCOPY igf_ap_css_profile.vet_us%TYPE                       ,
                    pr_vet_ben_amount             IN OUT NOCOPY igf_ap_css_profile.vet_ben_amount%TYPE               ,
                    pr_vet_ben_months             IN OUT NOCOPY igf_ap_css_profile.vet_ben_months%TYPE               ,
                    pr_stu_summer_wages           IN OUT NOCOPY igf_ap_css_profile.stu_summer_wages%TYPE             ,
                    pr_stu_school_yr_wages        IN OUT NOCOPY igf_ap_css_profile.stu_school_yr_wages%TYPE          ,
                    pr_spouse_summer_wages        IN OUT NOCOPY igf_ap_css_profile.spouse_summer_wages%TYPE          ,
                    pr_spouse_school_yr_wages     IN OUT NOCOPY igf_ap_css_profile.spouse_school_yr_wages%TYPE       ,
                    pr_summer_other_tax_inc       IN OUT NOCOPY igf_ap_css_profile.summer_other_tax_inc%TYPE         ,
                    pr_school_yr_other_tax_inc    IN OUT NOCOPY igf_ap_css_profile.school_yr_other_tax_inc%TYPE      ,
                    pr_summer_untax_inc           IN OUT NOCOPY igf_ap_css_profile.summer_untax_inc%TYPE             ,
                    pr_school_yr_untax_inc        IN OUT NOCOPY igf_ap_css_profile.school_yr_untax_inc%TYPE          ,
                    pr_grants_schol_etc           IN OUT NOCOPY igf_ap_css_profile.grants_schol_etc%TYPE             ,
                    pr_tuit_benefits              IN OUT NOCOPY igf_ap_css_profile.tuit_benefits%TYPE                ,
                    pr_cont_parents               IN OUT NOCOPY igf_ap_css_profile.cont_parents%TYPE                 ,
                    pr_cont_relatives             IN OUT NOCOPY igf_ap_css_profile.cont_relatives%TYPE               ,
                    pr_p_siblings_pre_tuit        IN OUT NOCOPY igf_ap_css_profile.p_siblings_pre_tuit%TYPE          ,
                    pr_p_student_pre_tuit         IN OUT NOCOPY igf_ap_css_profile.p_student_pre_tuit%TYPE           ,
                    pr_p_household_size           IN OUT NOCOPY igf_ap_css_profile.p_household_size%TYPE             ,
                    pr_p_number_in_college        IN OUT NOCOPY igf_ap_css_profile.p_number_in_college%TYPE          ,
                    pr_p_parents_in_college       IN OUT NOCOPY igf_ap_css_profile.p_parents_in_college%TYPE         ,
                    pr_p_marital_status           IN OUT NOCOPY igf_ap_css_profile.p_marital_status%TYPE             ,
                    pr_p_state_legal_residence    IN OUT NOCOPY igf_ap_css_profile.p_state_legal_residence%TYPE      ,
                    pr_p_natural_par_status       IN OUT NOCOPY igf_ap_css_profile.p_natural_par_status%TYPE         ,
                    pr_p_child_supp_paid          IN OUT NOCOPY igf_ap_css_profile.p_child_supp_paid%TYPE            ,
                    pr_p_repay_ed_loans           IN OUT NOCOPY igf_ap_css_profile.p_repay_ed_loans%TYPE             ,
                    pr_p_med_dent_expenses        IN OUT NOCOPY igf_ap_css_profile.p_med_dent_expenses%TYPE          ,
                    pr_p_tuit_paid_amount         IN OUT NOCOPY igf_ap_css_profile.p_tuit_paid_amount%TYPE           ,
                    pr_p_tuit_paid_number         IN OUT NOCOPY igf_ap_css_profile.p_tuit_paid_number%TYPE           ,
                    pr_p_exp_child_supp_paid      IN OUT NOCOPY igf_ap_css_profile.p_exp_child_supp_paid%TYPE        ,
                    pr_p_exp_repay_ed_loans       IN OUT NOCOPY igf_ap_css_profile.p_exp_repay_ed_loans%TYPE         ,
                    pr_p_exp_med_dent_expenses    IN OUT NOCOPY igf_ap_css_profile.p_exp_med_dent_expenses%TYPE      ,
                    pr_p_exp_tuit_pd_amount       IN OUT NOCOPY igf_ap_css_profile.p_exp_tuit_pd_amount%TYPE         ,
                    pr_p_exp_tuit_pd_number       IN OUT NOCOPY igf_ap_css_profile.p_exp_tuit_pd_number%TYPE         ,
                    pr_p_cash_sav_check           IN OUT NOCOPY igf_ap_css_profile.p_cash_sav_check%TYPE             ,
                    pr_p_month_mortgage_pay       IN OUT NOCOPY igf_ap_css_profile.p_month_mortgage_pay%TYPE         ,
                    pr_p_invest_value             IN OUT NOCOPY igf_ap_css_profile.p_invest_value%TYPE               ,
                    pr_p_invest_debt              IN OUT NOCOPY igf_ap_css_profile.p_invest_debt%TYPE                ,
                    pr_p_home_value               IN OUT NOCOPY igf_ap_css_profile.p_home_value%TYPE                 ,
                    pr_p_home_debt                IN OUT NOCOPY igf_ap_css_profile.p_home_debt%TYPE                  ,
                    pr_p_home_purch_price         IN OUT NOCOPY igf_ap_css_profile.p_home_purch_price%TYPE           ,
                    pr_p_own_business_farm        IN OUT NOCOPY igf_ap_css_profile.p_own_business_farm%TYPE          ,
                    pr_p_business_value           IN OUT NOCOPY igf_ap_css_profile.p_business_value%TYPE             ,
                    pr_p_business_debt            IN OUT NOCOPY igf_ap_css_profile.p_business_debt%TYPE              ,
                    pr_p_farm_value               IN OUT NOCOPY igf_ap_css_profile.p_farm_value%TYPE                 ,
                    pr_p_farm_debt                IN OUT NOCOPY igf_ap_css_profile.p_farm_debt%TYPE                  ,
                    pr_p_live_on_farm             IN OUT NOCOPY igf_ap_css_profile.p_live_on_farm%TYPE               ,
                    pr_p_oth_real_estate_value    IN OUT NOCOPY igf_ap_css_profile.p_oth_real_estate_value%TYPE      ,
                    pr_p_oth_real_estate_debt     IN OUT NOCOPY igf_ap_css_profile.p_oth_real_estate_debt%TYPE       ,
                    pr_p_oth_real_purch_price     IN OUT NOCOPY igf_ap_css_profile.p_oth_real_purch_price%TYPE       ,
                    pr_p_siblings_assets          IN OUT NOCOPY igf_ap_css_profile.p_siblings_assets%TYPE           ,
                    pr_p_home_purch_year          IN OUT NOCOPY igf_ap_css_profile.p_home_purch_year%TYPE            ,
                    pr_p_oth_real_purch_year      IN OUT NOCOPY igf_ap_css_profile.p_oth_real_purch_year%TYPE        ,
                    pr_p_prior_agi                IN OUT NOCOPY igf_ap_css_profile.p_prior_agi%TYPE                  ,
                    pr_p_prior_us_tax_paid        IN OUT NOCOPY igf_ap_css_profile.p_prior_us_tax_paid%TYPE          ,
                    pr_p_prior_item_deductions    IN OUT NOCOPY igf_ap_css_profile.p_prior_item_deductions%TYPE      ,
                    pr_p_prior_other_untax_inc    IN OUT NOCOPY igf_ap_css_profile.p_prior_other_untax_inc%TYPE      ,
                    pr_p_tax_figures              IN OUT NOCOPY igf_ap_css_profile.p_tax_figures%TYPE                ,
                    pr_p_number_exemptions        IN OUT NOCOPY igf_ap_css_profile.p_number_exemptions%TYPE          ,
                    pr_p_adjusted_gross_inc       IN OUT NOCOPY igf_ap_css_profile.p_adjusted_gross_inc%TYPE         ,
                    pr_p_wages_sal_tips           IN OUT NOCOPY igf_ap_css_profile.p_wages_sal_tips%TYPE             ,
                    pr_p_interest_income          IN OUT NOCOPY igf_ap_css_profile.p_interest_income%TYPE            ,
                    pr_p_dividend_income          IN OUT NOCOPY igf_ap_css_profile.p_dividend_income%TYPE            ,
                    pr_p_net_inc_bus_farm         IN OUT NOCOPY igf_ap_css_profile.p_net_inc_bus_farm%TYPE           ,
                    pr_p_other_taxable_income     IN OUT NOCOPY igf_ap_css_profile.p_other_taxable_income%TYPE       ,
                    pr_p_adj_to_income            IN OUT NOCOPY igf_ap_css_profile.p_adj_to_income%TYPE              ,
                    pr_p_us_tax_paid              IN OUT NOCOPY igf_ap_css_profile.p_us_tax_paid%TYPE                ,
                    pr_p_itemized_deductions      IN OUT NOCOPY igf_ap_css_profile.p_itemized_deductions%TYPE        ,
                    pr_p_father_income_work       IN OUT NOCOPY igf_ap_css_profile.p_father_income_work%TYPE         ,
                    pr_p_mother_income_work       IN OUT NOCOPY igf_ap_css_profile.p_mother_income_work%TYPE         ,
                    pr_p_soc_sec_ben              IN OUT NOCOPY igf_ap_css_profile.p_soc_sec_ben%TYPE                ,
                    pr_p_welfare_tanf             IN OUT NOCOPY igf_ap_css_profile.p_welfare_tanf%TYPE               ,
                    pr_p_child_supp_rcvd          IN OUT NOCOPY igf_ap_css_profile.p_child_supp_rcvd%TYPE            ,
                    pr_p_ded_ira_keogh            IN OUT NOCOPY igf_ap_css_profile.p_ded_ira_keogh%TYPE              ,
                    pr_p_tax_defer_pens_savs      IN OUT NOCOPY igf_ap_css_profile.p_tax_defer_pens_savs%TYPE        ,
                    pr_p_dep_care_med_spending    IN OUT NOCOPY igf_ap_css_profile.p_dep_care_med_spending%TYPE      ,
                    pr_p_earned_income_credit     IN OUT NOCOPY igf_ap_css_profile.p_earned_income_credit%TYPE       ,
                    pr_p_living_allow             IN OUT NOCOPY igf_ap_css_profile.p_living_allow%TYPE               ,
                    pr_p_tax_exmpt_int            IN OUT NOCOPY igf_ap_css_profile.p_tax_exmpt_int%TYPE              ,
                    pr_p_foreign_inc_excl         IN OUT NOCOPY igf_ap_css_profile.p_foreign_inc_excl%TYPE           ,
                    pr_p_other_untax_inc          IN OUT NOCOPY igf_ap_css_profile.p_other_untax_inc%TYPE            ,
                    pr_p_hope_ll_credit           IN OUT NOCOPY igf_ap_css_profile.p_hope_ll_credit%TYPE             ,
                    pr_p_yr_separation            IN OUT NOCOPY igf_ap_css_profile.p_yr_separation%TYPE              ,
                    pr_p_yr_divorce               IN OUT NOCOPY igf_ap_css_profile.p_yr_divorce%TYPE                 ,
                    pr_p_exp_father_inc           IN OUT NOCOPY igf_ap_css_profile.p_exp_father_inc%TYPE             ,
                    pr_p_exp_mother_inc           IN OUT NOCOPY igf_ap_css_profile.p_exp_mother_inc%TYPE             ,
                    pr_p_exp_other_tax_inc        IN OUT NOCOPY igf_ap_css_profile.p_exp_other_tax_inc%TYPE          ,
                    pr_p_exp_other_untax_inc      IN OUT NOCOPY igf_ap_css_profile.p_exp_other_untax_inc%TYPE        ,
                    pr_line_2_relation            IN OUT NOCOPY igf_ap_css_profile.line_2_relation%TYPE              ,
                    pr_line_2_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_2_attend_college%TYPE        ,
                    pr_line_3_relation            IN OUT NOCOPY igf_ap_css_profile.line_3_relation%TYPE              ,
                    pr_line_3_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_3_attend_college%TYPE        ,
                    pr_line_4_relation            IN OUT NOCOPY igf_ap_css_profile.line_4_relation%TYPE              ,
                    pr_line_4_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_4_attend_college%TYPE        ,
                    pr_line_5_relation            IN OUT NOCOPY igf_ap_css_profile.line_5_relation%TYPE              ,
                    pr_line_5_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_5_attend_college%TYPE        ,
                    pr_line_6_relation            IN OUT NOCOPY igf_ap_css_profile.line_6_relation%TYPE              ,
                    pr_line_6_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_6_attend_college%TYPE        ,
                    pr_line_7_relation            IN OUT NOCOPY igf_ap_css_profile.line_7_relation%TYPE              ,
                    pr_line_7_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_7_attend_college%TYPE        ,
                    pr_line_8_relation            IN OUT NOCOPY igf_ap_css_profile.line_8_relation%TYPE              ,
                    pr_line_8_attend_college      IN OUT NOCOPY igf_ap_css_profile.line_8_attend_college%TYPE        ,
                    pr_p_age_father               IN OUT NOCOPY igf_ap_css_profile.p_age_father%TYPE                 ,
                    pr_p_age_mother               IN OUT NOCOPY igf_ap_css_profile.p_age_mother%TYPE                 ,
                    pr_p_div_sep_ind              IN OUT NOCOPY igf_ap_css_profile.p_div_sep_ind%TYPE                ,
                    pr_b_cont_non_custodial_par   IN OUT NOCOPY igf_ap_css_profile.b_cont_non_custodial_par%TYPE     ,
                    pr_college_type_2             IN OUT NOCOPY igf_ap_css_profile.college_type_2%TYPE               ,
                    pr_college_type_3             IN OUT NOCOPY igf_ap_css_profile.college_type_3%TYPE               ,
                    pr_college_type_4             IN OUT NOCOPY igf_ap_css_profile.college_type_4%TYPE               ,
                    pr_college_type_5             IN OUT NOCOPY igf_ap_css_profile.college_type_5%TYPE               ,
                    pr_college_type_6             IN OUT NOCOPY igf_ap_css_profile.college_type_6%TYPE              ,
                    pr_college_type_7             IN OUT NOCOPY igf_ap_css_profile.college_type_7%TYPE               ,
                    pr_college_type_8             IN OUT NOCOPY igf_ap_css_profile.college_type_8%TYPE               ,
                    pr_school_code_1              IN OUT NOCOPY igf_ap_css_profile.school_code_1%TYPE                ,
                    pr_housing_code_1             IN OUT NOCOPY igf_ap_css_profile.housing_code_1%TYPE               ,
                    pr_school_code_2              IN OUT NOCOPY igf_ap_css_profile.school_code_2%TYPE                ,
                    pr_housing_code_2             IN OUT NOCOPY igf_ap_css_profile.housing_code_2%TYPE               ,
                    pr_school_code_3              IN OUT NOCOPY igf_ap_css_profile.school_code_3%TYPE                ,
                    pr_housing_code_3             IN OUT NOCOPY igf_ap_css_profile.housing_code_3%TYPE               ,
                    pr_school_code_4              IN OUT NOCOPY igf_ap_css_profile.school_code_4%TYPE                ,
                    pr_housing_code_4             IN OUT NOCOPY igf_ap_css_profile.housing_code_4%TYPE               ,
                    pr_school_code_5              IN OUT NOCOPY igf_ap_css_profile.school_code_5%TYPE                ,
                    pr_housing_code_5             IN OUT NOCOPY igf_ap_css_profile.housing_code_5%TYPE               ,
                    pr_school_code_6              IN OUT NOCOPY igf_ap_css_profile.school_code_6%TYPE                ,
                    pr_housing_code_6             IN OUT NOCOPY igf_ap_css_profile.housing_code_6%TYPE               ,
                    pr_school_code_7              IN OUT NOCOPY igf_ap_css_profile.school_code_7%TYPE                ,
                    pr_housing_code_7             IN OUT NOCOPY igf_ap_css_profile.housing_code_7%TYPE               ,
                    pr_school_code_8              IN OUT NOCOPY igf_ap_css_profile.school_code_8%TYPE                ,
                    pr_housing_code_8             IN OUT NOCOPY igf_ap_css_profile.housing_code_8%TYPE               ,
                    pr_school_code_9              IN OUT NOCOPY igf_ap_css_profile.school_code_9%TYPE                ,
                    pr_housing_code_9             IN OUT NOCOPY igf_ap_css_profile.housing_code_9%TYPE               ,
                    pr_school_code_10             IN OUT NOCOPY igf_ap_css_profile.school_code_10%TYPE               ,
                    pr_housing_code_10            IN OUT NOCOPY igf_ap_css_profile.housing_code_10%TYPE              ,
                    pr_additional_school_code_1   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_1%TYPE     ,
                    pr_additional_school_code_2   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_2%TYPE     ,
                    pr_additional_school_code_3   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_3%TYPE     ,
                    pr_additional_school_code_4   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_4%TYPE     ,
                    pr_additional_school_code_5   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_5%TYPE     ,
                    pr_additional_school_code_6   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_6%TYPE     ,
                    pr_additional_school_code_7   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_7%TYPE     ,
                    pr_additional_school_code_8   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_8%TYPE     ,
                    pr_additional_school_code_9   IN OUT NOCOPY igf_ap_css_profile.additional_school_code_9%TYPE     ,
                    pr_additional_school_code_10  IN OUT NOCOPY igf_ap_css_profile.additional_school_code_10%TYPE    ,
                    pr_explanation_spec_circum    IN OUT NOCOPY igf_ap_css_profile.explanation_spec_circum%TYPE      ,
                    pr_signature_student          IN OUT NOCOPY igf_ap_css_profile.signature_student%TYPE            ,
                    pr_signature_spouse           IN OUT NOCOPY igf_ap_css_profile.signature_spouse%TYPE             ,
                    pr_signature_father           IN OUT NOCOPY igf_ap_css_profile.signature_father%TYPE             ,
                    pr_signature_mother           IN OUT NOCOPY igf_ap_css_profile.signature_mother%TYPE             ,
                    pr_month_day_completed        IN OUT NOCOPY igf_ap_css_profile.month_day_completed%TYPE          ,
                    pr_year_completed             IN OUT NOCOPY igf_ap_css_profile.year_completed%TYPE               ,
                    pr_age_line_2                 IN OUT NOCOPY igf_ap_css_profile.age_line_2%TYPE                   ,
                    pr_age_line_3                 IN OUT NOCOPY igf_ap_css_profile.age_line_3%TYPE                   ,
                    pr_age_line_4                 IN OUT NOCOPY igf_ap_css_profile.age_line_4%TYPE                   ,
                    pr_age_line_5                 IN OUT NOCOPY igf_ap_css_profile.age_line_5%TYPE                   ,
                    pr_age_line_6                 IN OUT NOCOPY igf_ap_css_profile.age_line_6%TYPE                   ,
                    pr_age_line_7                 IN OUT NOCOPY igf_ap_css_profile.age_line_7%TYPE                   ,
                    pr_age_line_8                 IN OUT NOCOPY igf_ap_css_profile.age_line_8%TYPE                   ,
                    pr_a_online_signature         IN OUT NOCOPY igf_ap_css_profile.a_online_signature%TYPE           ,
                    pr_question_1_number          IN OUT NOCOPY igf_ap_css_profile.question_1_number%TYPE            ,
                    pr_question_1_size            IN OUT NOCOPY igf_ap_css_profile.question_1_size%TYPE              ,
                    pr_question_1_answer          IN OUT NOCOPY igf_ap_css_profile.question_1_answer%TYPE            ,
                    pr_question_2_number          IN OUT NOCOPY igf_ap_css_profile.question_2_number%TYPE            ,
                    pr_question_2_size            IN OUT NOCOPY igf_ap_css_profile.question_2_size%TYPE              ,
                    pr_question_2_answer          IN OUT NOCOPY igf_ap_css_profile.question_2_answer%TYPE            ,
                    pr_question_3_number          IN OUT NOCOPY igf_ap_css_profile.question_3_number%TYPE            ,
                    pr_question_3_size            IN OUT NOCOPY igf_ap_css_profile.question_3_size%TYPE             ,
                    pr_question_3_answer          IN OUT NOCOPY igf_ap_css_profile.question_3_answer%TYPE            ,
                    pr_question_4_number          IN OUT NOCOPY igf_ap_css_profile.question_4_number%TYPE            ,
                    pr_question_4_size            IN OUT NOCOPY igf_ap_css_profile.question_4_size%TYPE              ,
                    pr_question_4_answer          IN OUT NOCOPY igf_ap_css_profile.question_4_answer%TYPE            ,
                    pr_question_5_number          IN OUT NOCOPY igf_ap_css_profile.question_5_number%TYPE            ,
                    pr_question_5_size            IN OUT NOCOPY igf_ap_css_profile.question_5_size%TYPE              ,
                    pr_question_5_answer          IN OUT NOCOPY igf_ap_css_profile.question_5_answer%TYPE            ,
                    pr_question_6_number          IN OUT NOCOPY igf_ap_css_profile.question_6_number%TYPE            ,
                    pr_question_6_size            IN OUT NOCOPY igf_ap_css_profile.question_6_size%TYPE              ,
                    pr_question_6_answer          IN OUT NOCOPY igf_ap_css_profile.question_6_answer%TYPE            ,
                    pr_question_7_number          IN OUT NOCOPY igf_ap_css_profile.question_7_number%TYPE            ,
                    pr_question_7_size            IN OUT NOCOPY igf_ap_css_profile.question_7_size%TYPE              ,
                    pr_question_7_answer          IN OUT NOCOPY igf_ap_css_profile.question_7_answer%TYPE            ,
                    pr_question_8_number          IN OUT NOCOPY igf_ap_css_profile.question_8_number%TYPE            ,
                    pr_question_8_size            IN OUT NOCOPY igf_ap_css_profile.question_8_size%TYPE              ,
                    pr_question_8_answer          IN OUT NOCOPY igf_ap_css_profile.question_8_answer%TYPE            ,
                    pr_question_9_number          IN OUT NOCOPY igf_ap_css_profile.question_9_number%TYPE            ,
                    pr_question_9_size            IN OUT NOCOPY igf_ap_css_profile.question_9_size%TYPE              ,
                    pr_question_9_answer          IN OUT NOCOPY igf_ap_css_profile.question_9_answer%TYPE            ,
                    pr_question_10_number         IN OUT NOCOPY igf_ap_css_profile.question_10_number%TYPE           ,
                    pr_question_10_size           IN OUT NOCOPY igf_ap_css_profile.question_10_size%TYPE             ,
                    pr_question_10_answer         IN OUT NOCOPY igf_ap_css_profile.question_10_answer%TYPE           ,
                    pr_question_11_number         IN OUT NOCOPY igf_ap_css_profile.question_11_number%TYPE           ,
                    pr_question_11_size           IN OUT NOCOPY igf_ap_css_profile.question_11_size%TYPE             ,
                    pr_question_11_answer         IN OUT NOCOPY igf_ap_css_profile.question_11_answer%TYPE           ,
                    pr_question_12_number         IN OUT NOCOPY igf_ap_css_profile.question_12_number%TYPE           ,
                    pr_question_12_size           IN OUT NOCOPY igf_ap_css_profile.question_12_size%TYPE             ,
                    pr_question_12_answer         IN OUT NOCOPY igf_ap_css_profile.question_12_answer%TYPE           ,
                    pr_question_13_number         IN OUT NOCOPY igf_ap_css_profile.question_13_number%TYPE           ,
                    pr_question_13_size           IN OUT NOCOPY igf_ap_css_profile.question_13_size%TYPE             ,
                    pr_question_13_answer         IN OUT NOCOPY igf_ap_css_profile.question_13_answer%TYPE           ,
                    pr_question_14_number         IN OUT NOCOPY igf_ap_css_profile.question_14_number%TYPE           ,
                    pr_question_14_size           IN OUT NOCOPY igf_ap_css_profile.question_14_size%TYPE             ,
                    pr_question_14_answer         IN OUT NOCOPY igf_ap_css_profile.question_14_answer%TYPE           ,
                    pr_question_15_number         IN OUT NOCOPY igf_ap_css_profile.question_15_number%TYPE           ,
                    pr_question_15_size           IN OUT NOCOPY igf_ap_css_profile.question_15_size%TYPE             ,
                    pr_question_15_answer         IN OUT NOCOPY igf_ap_css_profile.question_15_answer%TYPE           ,
                    pr_question_16_number         IN OUT NOCOPY igf_ap_css_profile.question_16_number%TYPE           ,
                    pr_question_16_size           IN OUT NOCOPY igf_ap_css_profile.question_16_size%TYPE             ,
                    pr_question_16_answer         IN OUT NOCOPY igf_ap_css_profile.question_16_answer%TYPE           ,
                    pr_question_17_number         IN OUT NOCOPY igf_ap_css_profile.question_17_number%TYPE           ,
                    pr_question_17_size           IN OUT NOCOPY igf_ap_css_profile.question_17_size%TYPE             ,
                    pr_question_17_answer         IN OUT NOCOPY igf_ap_css_profile.question_17_answer%TYPE           ,
                    pr_question_18_number         IN OUT NOCOPY igf_ap_css_profile.question_18_number%TYPE           ,
                    pr_question_18_size           IN OUT NOCOPY igf_ap_css_profile.question_18_size%TYPE             ,
                    pr_question_18_answer         IN OUT NOCOPY igf_ap_css_profile.question_18_answer%TYPE           ,
                    pr_question_19_number         IN OUT NOCOPY igf_ap_css_profile.question_19_number%TYPE           ,
                    pr_question_19_size           IN OUT NOCOPY igf_ap_css_profile.question_19_size%TYPE             ,
                    pr_question_19_answer         IN OUT NOCOPY igf_ap_css_profile.question_19_answer%TYPE           ,
                    pr_question_20_number         IN OUT NOCOPY igf_ap_css_profile.question_20_number%TYPE           ,
                    pr_question_20_size           IN OUT NOCOPY igf_ap_css_profile.question_20_size%TYPE             ,
                    pr_question_20_answer         IN OUT NOCOPY igf_ap_css_profile.question_20_answer%TYPE           ,
                    pr_question_21_number         IN OUT NOCOPY igf_ap_css_profile.question_21_number%TYPE           ,
                    pr_question_21_size           IN OUT NOCOPY igf_ap_css_profile.question_21_size%TYPE             ,
                    pr_question_21_answer         IN OUT NOCOPY igf_ap_css_profile.question_21_answer%TYPE           ,
                    pr_question_22_number         IN OUT NOCOPY igf_ap_css_profile.question_22_number%TYPE           ,
                    pr_question_22_size           IN OUT NOCOPY igf_ap_css_profile.question_22_size%TYPE             ,
                    pr_question_22_answer         IN OUT NOCOPY igf_ap_css_profile.question_22_answer%TYPE           ,
                    pr_question_23_number         IN OUT NOCOPY igf_ap_css_profile.question_23_number%TYPE           ,
                    pr_question_23_size           IN OUT NOCOPY igf_ap_css_profile.question_23_size%TYPE             ,
                    pr_question_23_answer         IN OUT NOCOPY igf_ap_css_profile.question_23_answer%TYPE           ,
                    pr_question_24_number         IN OUT NOCOPY igf_ap_css_profile.question_24_number%TYPE           ,
                    pr_question_24_size           IN OUT NOCOPY igf_ap_css_profile.question_24_size%TYPE             ,
                    pr_question_24_answer         IN OUT NOCOPY igf_ap_css_profile.question_24_answer%TYPE           ,
                    pr_question_25_number         IN OUT NOCOPY igf_ap_css_profile.question_25_number%TYPE           ,
                    pr_question_25_size           IN OUT NOCOPY igf_ap_css_profile.question_25_size%TYPE             ,
                    pr_question_25_answer         IN OUT NOCOPY igf_ap_css_profile.question_25_answer%TYPE           ,
                    pr_question_26_number         IN OUT NOCOPY igf_ap_css_profile.question_26_number%TYPE           ,
                    pr_question_26_size           IN OUT NOCOPY igf_ap_css_profile.question_26_size%TYPE             ,
                    pr_question_26_answer         IN OUT NOCOPY igf_ap_css_profile.question_26_answer%TYPE           ,
                    pr_question_27_number         IN OUT NOCOPY igf_ap_css_profile.question_27_number%TYPE           ,
                    pr_question_27_size           IN OUT NOCOPY igf_ap_css_profile.question_27_size%TYPE             ,
                    pr_question_27_answer         IN OUT NOCOPY igf_ap_css_profile.question_27_answer%TYPE           ,
                    pr_question_28_number         IN OUT NOCOPY igf_ap_css_profile.question_28_number%TYPE           ,
                    pr_question_28_size           IN OUT NOCOPY igf_ap_css_profile.question_28_size%TYPE             ,
                    pr_question_28_answer         IN OUT NOCOPY igf_ap_css_profile.question_28_answer%TYPE           ,
                    pr_question_29_number         IN OUT NOCOPY igf_ap_css_profile.question_29_number%TYPE           ,
                    pr_question_29_size           IN OUT NOCOPY igf_ap_css_profile.question_29_size%TYPE             ,
                    pr_question_29_answer         IN OUT NOCOPY igf_ap_css_profile.question_29_answer%TYPE           ,
                    pr_question_30_number         IN OUT NOCOPY igf_ap_css_profile.question_30_number%TYPE           ,
                    pr_questions_30_size          IN OUT NOCOPY igf_ap_css_profile.questions_30_size%TYPE            ,
                    pr_question_30_answer         IN OUT NOCOPY igf_ap_css_profile.question_30_answer%TYPE           ,
                    pr_legacy_record_flag         IN OUT NOCOPY igf_ap_css_profile.legacy_record_flag%TYPE           ,
                    pr_coa_duration_efc_amt       IN OUT NOCOPY igf_ap_css_profile.coa_duration_efc_amt%TYPE         ,
                    pr_coa_duration_num           IN OUT NOCOPY igf_ap_css_profile.coa_duration_num %TYPE            ,
                    pr_created_by                 IN OUT NOCOPY igf_ap_css_profile.created_by%TYPE                   ,
                    pr_creation_date              IN OUT NOCOPY igf_ap_css_profile.creation_date%TYPE                ,
                    pr_last_updated_by            IN OUT NOCOPY igf_ap_css_profile.last_updated_by%TYPE              ,
                    pr_last_update_date           IN OUT NOCOPY igf_ap_css_profile.last_update_date%TYPE             ,
                    pr_last_update_login          IN OUT NOCOPY igf_ap_css_profile.last_update_login%TYPE            ,
                    pr_p_soc_sec_ben_student_amt  IN OUT NOCOPY igf_ap_css_profile.p_soc_sec_ben_student_amt%TYPE    ,
                    pr_p_tuit_fee_deduct_amt      IN OUT NOCOPY igf_ap_css_profile.p_tuit_fee_deduct_amt%TYPE        ,
                    pr_stu_lives_with_num         IN OUT NOCOPY igf_ap_css_profile.stu_lives_with_num%TYPE           ,
                    pr_stu_most_support_from_num  IN OUT NOCOPY igf_ap_css_profile.stu_most_support_from_num%TYPE    ,
                    pr_location_computer_num      IN OUT NOCOPY igf_ap_css_profile.location_computer_num%TYPE        ,

                    f_fnar_id                               IN OUT NOCOPY igf_ap_css_fnar.fnar_id%TYPE                       ,
                    f_cssp_id                               IN OUT NOCOPY igf_ap_css_fnar.cssp_id%TYPE                      ,
                    f_r_s_email_address                     IN OUT NOCOPY igf_ap_css_fnar.r_s_email_address%TYPE            ,
                    f_eps_code                              IN OUT NOCOPY igf_ap_css_fnar.eps_code%TYPE                     ,
                    f_comp_css_dependency_status            IN OUT NOCOPY igf_ap_css_fnar.comp_css_dependency_status%TYPE   ,
                    f_stu_age                               IN OUT NOCOPY igf_ap_css_fnar.stu_age%TYPE                      ,
                    f_assumed_stu_yr_in_coll                IN OUT NOCOPY igf_ap_css_fnar.assumed_stu_yr_in_coll%TYPE       ,
                    f_comp_stu_marital_status               IN OUT NOCOPY igf_ap_css_fnar.comp_stu_marital_status%TYPE      ,
                    f_stu_family_members                    IN OUT NOCOPY igf_ap_css_fnar.stu_family_members%TYPE           ,
                    f_stu_fam_members_in_college            IN OUT NOCOPY igf_ap_css_fnar.stu_fam_members_in_college%TYPE   ,
                    f_par_marital_status                    IN OUT NOCOPY igf_ap_css_fnar.par_marital_status%TYPE           ,
                    f_par_family_members                    IN OUT NOCOPY igf_ap_css_fnar.par_family_members%TYPE           ,
                    f_par_total_in_college                  IN OUT NOCOPY igf_ap_css_fnar.par_total_in_college%TYPE         ,
                    f_par_par_in_college                    IN OUT NOCOPY igf_ap_css_fnar.par_par_in_college%TYPE           ,
                    f_par_others_in_college                 IN OUT NOCOPY igf_ap_css_fnar.par_others_in_college%TYPE        ,
                    f_par_aesa                              IN OUT NOCOPY igf_ap_css_fnar.par_aesa%TYPE                     ,
                    f_par_cesa                              IN OUT NOCOPY igf_ap_css_fnar.par_cesa%TYPE                     ,
                    f_stu_aesa                              IN OUT NOCOPY igf_ap_css_fnar.stu_aesa%TYPE                     ,
                    f_stu_cesa                              IN OUT NOCOPY igf_ap_css_fnar.stu_cesa%TYPE                     ,
                    f_im_p_bas_agi_taxable_income           IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_agi_taxable_income%TYPE  ,
                    f_im_p_bas_untx_inc_and_ben             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_untx_inc_and_ben%TYPE    ,
                    f_im_p_bas_inc_adj                      IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_inc_adj%TYPE             ,
                    f_im_p_bas_total_income                 IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_income%TYPE        ,
                    f_im_p_bas_us_income_tax                IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_us_income_tax%TYPE       ,
                    f_im_p_bas_st_and_other_tax             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_st_and_other_tax%TYPE    ,
                    f_im_p_bas_fica_tax                     IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_fica_tax%TYPE            ,
                    f_im_p_bas_med_dental                   IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_med_dental%TYPE          ,
                    f_im_p_bas_employment_allow             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_employment_allow%TYPE    ,
                    f_im_p_bas_annual_ed_savings            IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_annual_ed_savings%TYPE   ,
                    f_im_p_bas_inc_prot_allow_m             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_inc_prot_allow_m%TYPE    ,
                    f_im_p_bas_total_inc_allow              IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_inc_allow%TYPE     ,
                    f_im_p_bas_cal_avail_inc                IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cal_avail_inc%TYPE       ,
                    f_im_p_bas_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_avail_income%TYPE        ,
                    f_im_p_bas_total_cont_inc               IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_cont_inc%TYPE      ,
                    f_im_p_bas_cash_bank_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cash_bank_accounts%TYPE  ,
                    f_im_p_bas_home_equity                  IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_home_equity%TYPE         ,
                    f_im_p_bas_ot_rl_est_inv_eq             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_ot_rl_est_inv_eq%TYPE    ,
                    f_im_p_bas_adj_bus_farm_worth           IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_adj_bus_farm_worth%TYPE  ,
                    f_im_p_bas_ass_sibs_pre_tui             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_ass_sibs_pre_tui%TYPE    ,
                    f_im_p_bas_net_worth                    IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_net_worth%TYPE           ,
                    f_im_p_bas_emerg_res_allow              IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_emerg_res_allow%TYPE     ,
                    f_im_p_bas_cum_ed_savings               IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cum_ed_savings%TYPE      ,
                    f_im_p_bas_low_inc_allow                IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_low_inc_allow%TYPE       ,
                    f_im_p_bas_total_asset_allow            IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_asset_allow%TYPE   ,
                    f_im_p_bas_disc_net_worth               IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_disc_net_worth%TYPE      ,
                    f_im_p_bas_total_cont_asset             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_cont_asset%TYPE    ,
                    f_im_p_bas_total_cont                   IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_total_cont%TYPE          ,
                    f_im_p_bas_num_in_coll_adj              IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_num_in_coll_adj%TYPE     ,
                    f_im_p_bas_cont_for_stu                 IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cont_for_stu%TYPE        ,
                    f_im_p_bas_cont_from_income             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cont_from_income%TYPE    ,
                    f_im_p_bas_cont_from_assets             IN OUT NOCOPY igf_ap_css_fnar.im_p_bas_cont_from_assets%TYPE    ,
                    f_im_p_opt_agi_taxable_income           IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_agi_taxable_income%TYPE  ,
                    f_im_p_opt_untx_inc_and_ben             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_untx_inc_and_ben%TYPE    ,
                    f_im_p_opt_inc_adj                      IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_inc_adj%TYPE             ,
                    f_im_p_opt_total_income                 IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_income%TYPE        ,
                    f_im_p_opt_us_income_tax                IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_us_income_tax%TYPE       ,
                    f_im_p_opt_st_and_other_tax             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_st_and_other_tax%TYPE    ,
                    f_im_p_opt_fica_tax                     IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_fica_tax%TYPE            ,
                    f_im_p_opt_med_dental                   IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_med_dental%TYPE          ,
                    f_im_p_opt_elem_sec_tuit                IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_elem_sec_tuit%TYPE       ,
                    f_im_p_opt_employment_allow             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_employment_allow%TYPE    ,
                    f_im_p_opt_annual_ed_savings            IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_annual_ed_savings%TYPE   ,
                    f_im_p_opt_inc_prot_allow_m             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_inc_prot_allow_m%TYPE    ,
                    f_im_p_opt_total_inc_allow              IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_inc_allow%TYPE     ,
                    f_im_p_opt_cal_avail_inc                IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cal_avail_inc%TYPE       ,
                    f_im_p_opt_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_avail_income%TYPE        ,
                    f_im_p_opt_total_cont_inc               IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_cont_inc%TYPE      ,
                    f_im_p_opt_cash_bank_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cash_bank_accounts%TYPE  ,
                    f_im_p_opt_home_equity                  IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_home_equity%TYPE         ,
                    f_im_p_opt_ot_rl_est_inv_eq             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_ot_rl_est_inv_eq%TYPE   ,
                    f_im_p_opt_adj_bus_farm_worth           IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_adj_bus_farm_worth%TYPE  ,
                    f_im_p_opt_ass_sibs_pre_tui             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_ass_sibs_pre_tui%TYPE    ,
                    f_im_p_opt_net_worth                    IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_net_worth%TYPE           ,
                    f_im_p_opt_emerg_res_allow              IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_emerg_res_allow%TYPE     ,
                    f_im_p_opt_cum_ed_savings               IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cum_ed_savings%TYPE      ,
                    f_im_p_opt_low_inc_allow                IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_low_inc_allow%TYPE       ,
                    f_im_p_opt_total_asset_allow            IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_asset_allow%TYPE   ,
                    f_im_p_opt_disc_net_worth               IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_disc_net_worth%TYPE      ,
                    f_im_p_opt_total_cont_asset             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_cont_asset%TYPE    ,
                    f_im_p_opt_total_cont                   IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_total_cont%TYPE          ,
                    f_im_p_opt_num_in_coll_adj              IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_num_in_coll_adj%TYPE     ,
                    f_im_p_opt_cont_for_stu                 IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cont_for_stu%TYPE        ,
                    f_im_p_opt_cont_from_income             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cont_from_income%TYPE    ,
                    f_im_p_opt_cont_from_assets             IN OUT NOCOPY igf_ap_css_fnar.im_p_opt_cont_from_assets%TYPE    ,
                    f_fm_p_analysis_type                    IN OUT NOCOPY igf_ap_css_fnar.fm_p_analysis_type%TYPE           ,
                    f_fm_p_agi_taxable_income               IN OUT NOCOPY igf_ap_css_fnar.fm_p_agi_taxable_income%TYPE      ,
                    f_fm_p_untx_inc_and_ben                 IN OUT NOCOPY igf_ap_css_fnar.fm_p_untx_inc_and_ben%TYPE        ,
                    f_fm_p_inc_adj                          IN OUT NOCOPY igf_ap_css_fnar.fm_p_inc_adj%TYPE                 ,
                    f_fm_p_total_income                     IN OUT NOCOPY igf_ap_css_fnar.fm_p_total_income%TYPE            ,
                    f_fm_p_us_income_tax                    IN OUT NOCOPY igf_ap_css_fnar.fm_p_us_income_tax%TYPE           ,
                    f_fm_p_state_and_other_taxes            IN OUT NOCOPY igf_ap_css_fnar.fm_p_state_and_other_taxes%TYPE   ,
                    f_fm_p_fica_tax                         IN OUT NOCOPY igf_ap_css_fnar.fm_p_fica_tax%TYPE                ,
                    f_fm_p_employment_allow                 IN OUT NOCOPY igf_ap_css_fnar.fm_p_employment_allow%TYPE        ,
                    f_fm_p_income_prot_allow                IN OUT NOCOPY igf_ap_css_fnar.fm_p_income_prot_allow%TYPE       ,
                    f_fm_p_total_allow                      IN OUT NOCOPY igf_ap_css_fnar.fm_p_total_allow%TYPE             ,
                    f_fm_p_avail_income                     IN OUT NOCOPY igf_ap_css_fnar.fm_p_avail_income%TYPE            ,
                    f_fm_p_cash_bank_accounts               IN OUT NOCOPY igf_ap_css_fnar.fm_p_cash_bank_accounts%TYPE      ,
                    f_fm_p_ot_rl_est_inv_equity             IN OUT NOCOPY igf_ap_css_fnar.fm_p_ot_rl_est_inv_equity%TYPE    ,
                    f_fm_p_adj_bus_farm_net_worth           IN OUT NOCOPY igf_ap_css_fnar.fm_p_adj_bus_farm_net_worth%TYPE  ,
                    f_fm_p_net_worth                        IN OUT NOCOPY igf_ap_css_fnar.fm_p_net_worth%TYPE               ,
                    f_fm_p_asset_prot_allow                 IN OUT NOCOPY igf_ap_css_fnar.fm_p_asset_prot_allow%TYPE        ,
                    f_fm_p_disc_net_worth                   IN OUT NOCOPY igf_ap_css_fnar.fm_p_disc_net_worth%TYPE          ,
                    f_fm_p_total_contribution               IN OUT NOCOPY igf_ap_css_fnar.fm_p_total_contribution%TYPE      ,
                    f_fm_p_num_in_coll                      IN OUT NOCOPY igf_ap_css_fnar.fm_p_num_in_coll%TYPE             ,
                    f_fm_p_cont_for_stu                     IN OUT NOCOPY igf_ap_css_fnar.fm_p_cont_for_stu%TYPE            ,
                    f_fm_p_cont_from_income                 IN OUT NOCOPY igf_ap_css_fnar.fm_p_cont_from_income%TYPE        ,
                    f_fm_p_cont_from_assets                 IN OUT NOCOPY igf_ap_css_fnar.fm_p_cont_from_assets%TYPE        ,
                    f_im_s_bas_agi_taxable_income           IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_agi_taxable_income%TYPE  ,
                    f_im_s_bas_untx_inc_and_ben             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_untx_inc_and_ben%TYPE    ,
                    f_im_s_bas_inc_adj                      IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_inc_adj%TYPE             ,
                    f_im_s_bas_total_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_income%TYPE        ,
                    f_im_s_bas_us_income_tax                IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_us_income_tax%TYPE       ,
                    f_im_s_bas_state_and_oth_taxes          IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_state_and_oth_taxes%TYPE ,
                    f_im_s_bas_fica_tax                     IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_fica_tax%TYPE            ,
                    f_im_s_bas_med_dental                   IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_med_dental%TYPE          ,
                    f_im_s_bas_employment_allow             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_employment_allow%TYPE    ,
                    f_im_s_bas_annual_ed_savings            IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_annual_ed_savings%TYPE   ,
                    f_im_s_bas_inc_prot_allow_m             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_inc_prot_allow_m%TYPE    ,
                    f_im_s_bas_total_inc_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_inc_allow%TYPE     ,
                    f_im_s_bas_cal_avail_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cal_avail_income%TYPE    ,
                    f_im_s_bas_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_avail_income%TYPE        ,
                    f_im_s_bas_total_cont_inc               IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_cont_inc%TYPE      ,
                    f_im_s_bas_cash_bank_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cash_bank_accounts%TYPE  ,
                    f_im_s_bas_home_equity                  IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_home_equity%TYPE         ,
                    f_im_s_bas_ot_rl_est_inv_eq             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_ot_rl_est_inv_eq%TYPE    ,
                    f_im_s_bas_adj_busfarm_worth            IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_adj_busfarm_worth%TYPE   ,
                    f_im_s_bas_trusts                       IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_trusts%TYPE              ,
                    f_im_s_bas_net_worth                    IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_net_worth%TYPE           ,
                    f_im_s_bas_emerg_res_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_emerg_res_allow%TYPE     ,
                    f_im_s_bas_cum_ed_savings               IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cum_ed_savings%TYPE      ,
                    f_im_s_bas_total_asset_allow            IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_asset_allow%TYPE   ,
                    f_im_s_bas_disc_net_worth               IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_disc_net_worth%TYPE      ,
                    f_im_s_bas_total_cont_asset             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_cont_asset%TYPE    ,
                    f_im_s_bas_total_cont                   IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_total_cont%TYPE          ,
                    f_im_s_bas_num_in_coll_adj              IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_num_in_coll_adj%TYPE     ,
                    f_im_s_bas_cont_for_stu                 IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cont_for_stu%TYPE        ,
                    f_im_s_bas_cont_from_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cont_from_income%TYPE    ,
                    f_im_s_bas_cont_from_assets             IN OUT NOCOPY igf_ap_css_fnar.im_s_bas_cont_from_assets%TYPE    ,
                    f_im_s_est_agitaxable_income            IN OUT NOCOPY igf_ap_css_fnar.im_s_est_agitaxable_income%TYPE   ,
                    f_im_s_est_untx_inc_and_ben             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_untx_inc_and_ben%TYPE    ,
                    f_im_s_est_inc_adj                      IN OUT NOCOPY igf_ap_css_fnar.im_s_est_inc_adj%TYPE             ,
                    f_im_s_est_total_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_income%TYPE        ,
                    f_im_s_est_us_income_tax                IN OUT NOCOPY igf_ap_css_fnar.im_s_est_us_income_tax%TYPE       ,
                    f_im_s_est_state_and_oth_taxes          IN OUT NOCOPY igf_ap_css_fnar.im_s_est_state_and_oth_taxes%TYPE ,
                    f_im_s_est_fica_tax                     IN OUT NOCOPY igf_ap_css_fnar.im_s_est_fica_tax%TYPE            ,
                    f_im_s_est_med_dental                   IN OUT NOCOPY igf_ap_css_fnar.im_s_est_med_dental%TYPE          ,
                    f_im_s_est_employment_allow             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_employment_allow%TYPE    ,
                    f_im_s_est_annual_ed_savings            IN OUT NOCOPY igf_ap_css_fnar.im_s_est_annual_ed_savings%TYPE   ,
                    f_im_s_est_inc_prot_allow_m             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_inc_prot_allow_m%TYPE    ,
                    f_im_s_est_total_inc_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_inc_allow%TYPE     ,
                    f_im_s_est_cal_avail_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cal_avail_income%TYPE    ,
                    f_im_s_est_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_est_avail_income%TYPE        ,
                    f_im_s_est_total_cont_inc               IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_cont_inc%TYPE      ,
                    f_im_s_est_cash_bank_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cash_bank_accounts%TYPE  ,
                    f_im_s_est_home_equity                  IN OUT NOCOPY igf_ap_css_fnar.im_s_est_home_equity%TYPE         ,
                    f_im_s_est_ot_rl_est_inv_eq             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_ot_rl_est_inv_eq%TYPE    ,
                    f_im_s_est_adj_bus_farm_worth           IN OUT NOCOPY igf_ap_css_fnar.im_s_est_adj_bus_farm_worth%TYPE  ,
                    f_im_s_est_est_trusts                   IN OUT NOCOPY igf_ap_css_fnar.im_s_est_est_trusts%TYPE          ,
                    f_im_s_est_net_worth                    IN OUT NOCOPY igf_ap_css_fnar.im_s_est_net_worth%TYPE           ,
                    f_im_s_est_emerg_res_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_est_emerg_res_allow%TYPE     ,
                    f_im_s_est_cum_ed_savings               IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cum_ed_savings%TYPE      ,
                    f_im_s_est_total_asset_allow            IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_asset_allow%TYPE   ,
                    f_im_s_est_disc_net_worth               IN OUT NOCOPY igf_ap_css_fnar.im_s_est_disc_net_worth%TYPE      ,
                    f_im_s_est_total_cont_asset             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_cont_asset%TYPE    ,
                    f_im_s_est_total_cont                   IN OUT NOCOPY igf_ap_css_fnar.im_s_est_total_cont%TYPE          ,
                    f_im_s_est_num_in_coll_adj              IN OUT NOCOPY igf_ap_css_fnar.im_s_est_num_in_coll_adj%TYPE     ,
                    f_im_s_est_cont_for_stu                 IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cont_for_stu%TYPE        ,
                    f_im_s_est_cont_from_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cont_from_income%TYPE    ,
                    f_im_s_est_cont_from_assets             IN OUT NOCOPY igf_ap_css_fnar.im_s_est_cont_from_assets%TYPE    ,
                    f_im_s_opt_agi_taxable_income           IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_agi_taxable_income%TYPE  ,
                    f_im_s_opt_untx_inc_and_ben             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_untx_inc_and_ben%TYPE    ,
                    f_im_s_opt_inc_adj                      IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_inc_adj%TYPE             ,
                    f_im_s_opt_total_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_income%TYPE        ,
                    f_im_s_opt_us_income_tax                IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_us_income_tax%TYPE       ,
                    f_im_s_opt_state_and_oth_taxes          IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_state_and_oth_taxes%TYPE ,
                    f_im_s_opt_fica_tax                     IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_fica_tax%TYPE            ,
                    f_im_s_opt_med_dental                   IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_med_dental%TYPE          ,
                    f_im_s_opt_employment_allow             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_employment_allow%TYPE    ,
                    f_im_s_opt_annual_ed_savings            IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_annual_ed_savings%TYPE   ,
                    f_im_s_opt_inc_prot_allow_m             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_inc_prot_allow_m%TYPE    ,
                    f_im_s_opt_total_inc_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_inc_allow%TYPE     ,
                    f_im_s_opt_cal_avail_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cal_avail_income%TYPE    ,
                    f_im_s_opt_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_avail_income%TYPE        ,
                    f_im_s_opt_total_cont_inc               IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_cont_inc%TYPE      ,
                    f_im_s_opt_cash_bank_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cash_bank_accounts%TYPE  ,
                    f_im_s_opt_ira_keogh_accounts           IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_ira_keogh_accounts%TYPE  ,
                    f_im_s_opt_home_equity                  IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_home_equity%TYPE         ,
                    f_im_s_opt_ot_rl_est_inv_eq             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_ot_rl_est_inv_eq%TYPE    ,
                    f_im_s_opt_adj_bus_farm_worth           IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_adj_bus_farm_worth%TYPE  ,
                    f_im_s_opt_trusts                       IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_trusts%TYPE              ,
                    f_im_s_opt_net_worth                    IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_net_worth%TYPE           ,
                    f_im_s_opt_emerg_res_allow              IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_emerg_res_allow%TYPE     ,
                    f_im_s_opt_cum_ed_savings               IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cum_ed_savings%TYPE      ,
                    f_im_s_opt_total_asset_allow            IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_asset_allow%TYPE   ,
                    f_im_s_opt_disc_net_worth               IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_disc_net_worth%TYPE      ,
                    f_im_s_opt_total_cont_asset             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_cont_asset%TYPE    ,
                    f_im_s_opt_total_cont                   IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_total_cont%TYPE          ,
                    f_im_s_opt_num_in_coll_adj              IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_num_in_coll_adj%TYPE     ,
                    f_im_s_opt_cont_for_stu                 IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cont_for_stu%TYPE        ,
                    f_im_s_opt_cont_from_income             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cont_from_income%TYPE    ,
                    f_im_s_opt_cont_from_assets             IN OUT NOCOPY igf_ap_css_fnar.im_s_opt_cont_from_assets%TYPE    ,
                    f_fm_s_analysis_type                    IN OUT NOCOPY igf_ap_css_fnar.fm_s_analysis_type%TYPE           ,
                    f_fm_s_agi_taxable_income               IN OUT NOCOPY igf_ap_css_fnar.fm_s_agi_taxable_income%TYPE      ,
                    f_fm_s_untx_inc_and_ben                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_untx_inc_and_ben%TYPE        ,
                    f_fm_s_inc_adj                          IN OUT NOCOPY igf_ap_css_fnar.fm_s_inc_adj%TYPE                 ,
                    f_fm_s_total_income                     IN OUT NOCOPY igf_ap_css_fnar.fm_s_total_income%TYPE            ,
                    f_fm_s_us_income_tax                    IN OUT NOCOPY igf_ap_css_fnar.fm_s_us_income_tax%TYPE           ,
                    f_fm_s_state_and_oth_taxes              IN OUT NOCOPY igf_ap_css_fnar.fm_s_state_and_oth_taxes%TYPE     ,
                    f_fm_s_fica_tax                         IN OUT NOCOPY igf_ap_css_fnar.fm_s_fica_tax%TYPE                ,
                    f_fm_s_employment_allow                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_employment_allow%TYPE        ,
                    f_fm_s_income_prot_allow                IN OUT NOCOPY igf_ap_css_fnar.fm_s_income_prot_allow%TYPE       ,
                    f_fm_s_total_allow                      IN OUT NOCOPY igf_ap_css_fnar.fm_s_total_allow%TYPE             ,
                    f_fm_s_cal_avail_income                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_cal_avail_income%TYPE        ,
                    f_fm_s_avail_income                     IN OUT NOCOPY igf_ap_css_fnar.fm_s_avail_income%TYPE            ,
                    f_fm_s_cash_bank_accounts               IN OUT NOCOPY igf_ap_css_fnar.fm_s_cash_bank_accounts%TYPE      ,
                    f_fm_s_ot_rl_est_inv_equity             IN OUT NOCOPY igf_ap_css_fnar.fm_s_ot_rl_est_inv_equity%TYPE    ,
                    f_fm_s_adj_bus_farm_worth               IN OUT NOCOPY igf_ap_css_fnar.fm_s_adj_bus_farm_worth%TYPE      ,
                    f_fm_s_trusts                           IN OUT NOCOPY igf_ap_css_fnar.fm_s_trusts%TYPE                  ,
                    f_fm_s_net_worth                        IN OUT NOCOPY igf_ap_css_fnar.fm_s_net_worth%TYPE              ,
                    f_fm_s_asset_prot_allow                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_asset_prot_allow%TYPE        ,
                    f_fm_s_disc_net_worth                   IN OUT NOCOPY igf_ap_css_fnar.fm_s_disc_net_worth%TYPE          ,
                    f_fm_s_total_cont                       IN OUT NOCOPY igf_ap_css_fnar.fm_s_total_cont%TYPE              ,
                    f_fm_s_num_in_coll                      IN OUT NOCOPY igf_ap_css_fnar.fm_s_num_in_coll%TYPE             ,
                    f_fm_s_cont_for_stu                     IN OUT NOCOPY igf_ap_css_fnar.fm_s_cont_for_stu%TYPE            ,
                    f_fm_s_cont_from_income                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_cont_from_income%TYPE        ,
                    f_fm_s_cont_from_assets                 IN OUT NOCOPY igf_ap_css_fnar.fm_s_cont_from_assets%TYPE        ,
                    f_im_inst_resident_ind                  IN OUT NOCOPY igf_ap_css_fnar.im_inst_resident_ind%TYPE         ,
                    f_institutional_1_budget_name           IN OUT NOCOPY igf_ap_css_fnar.institutional_1_budget_name%TYPE  ,
                    f_im_inst_1_budget_duration             IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_budget_duration%TYPE    ,
                    f_im_inst_1_tuition_fees                IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_tuition_fees%TYPE       ,
                    f_im_inst_1_books_supplies              IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_books_supplies%TYPE     ,
                    f_im_inst_1_living_expenses             IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_living_expenses%TYPE    ,
                    f_im_inst_1_tot_expenses                IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_tot_expenses%TYPE       ,
                    f_im_inst_1_tot_stu_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_tot_stu_cont%TYPE       ,
                    f_im_inst_1_tot_par_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_tot_par_cont%TYPE       ,
                    f_im_inst_1_tot_family_cont             IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_tot_family_cont%TYPE    ,
                    f_im_inst_1_va_benefits                 IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_va_benefits%TYPE        ,
                    f_im_inst_1_ot_cont                     IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_ot_cont%TYPE            ,
                    f_im_inst_1_est_financial_need          IN OUT NOCOPY igf_ap_css_fnar.im_inst_1_est_financial_need%TYPE ,
                    f_institutional_2_budget_name           IN OUT NOCOPY igf_ap_css_fnar.institutional_2_budget_name%TYPE  ,
                    f_im_inst_2_budget_duration             IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_budget_duration%TYPE    ,
                    f_im_inst_2_tuition_fees                IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_tuition_fees%TYPE       ,
                    f_im_inst_2_books_supplies              IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_books_supplies%TYPE     ,
                    f_im_inst_2_living_expenses             IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_living_expenses%TYPE    ,
                    f_im_inst_2_tot_expenses                IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_tot_expenses%TYPE       ,
                    f_im_inst_2_tot_stu_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_tot_stu_cont%TYPE       ,
                    f_im_inst_2_tot_par_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_tot_par_cont%TYPE       ,
                    f_im_inst_2_tot_family_cont             IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_tot_family_cont%TYPE    ,
                    f_im_inst_2_va_benefits                 IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_va_benefits%TYPE        ,
                    f_im_inst_2_est_financial_need          IN OUT NOCOPY igf_ap_css_fnar.im_inst_2_est_financial_need%TYPE ,
                    f_institutional_3_budget_name           IN OUT NOCOPY igf_ap_css_fnar.institutional_3_budget_name%TYPE  ,
                    f_im_inst_3_budget_duration             IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_budget_duration%TYPE    ,
                    f_im_inst_3_tuition_fees                IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_tuition_fees%TYPE       ,
                    f_im_inst_3_books_supplies              IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_books_supplies%TYPE     ,
                    f_im_inst_3_living_expenses             IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_living_expenses%TYPE    ,
                    f_im_inst_3_tot_expenses                IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_tot_expenses%TYPE       ,
                    f_im_inst_3_tot_stu_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_tot_stu_cont%TYPE       ,
                    f_im_inst_3_tot_par_cont                IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_tot_par_cont%TYPE       ,
                    f_im_inst_3_tot_family_cont             IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_tot_family_cont%TYPE    ,
                    f_im_inst_3_va_benefits                 IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_va_benefits%TYPE        ,
                    f_im_inst_3_est_financial_need          IN OUT NOCOPY igf_ap_css_fnar.im_inst_3_est_financial_need%TYPE ,
                    f_fm_inst_1_federal_efc                 IN OUT NOCOPY igf_ap_css_fnar.fm_inst_1_federal_efc%TYPE        ,
                    f_fm_inst_1_va_benefits                 IN OUT NOCOPY igf_ap_css_fnar.fm_inst_1_va_benefits%TYPE        ,
                    f_fm_inst_1_fed_eligibility             IN OUT NOCOPY igf_ap_css_fnar.fm_inst_1_fed_eligibility%TYPE    ,
                    f_fm_inst_1_pell                        IN OUT NOCOPY igf_ap_css_fnar.fm_inst_1_pell%TYPE               ,
                    f_option_par_loss_allow_ind             IN OUT NOCOPY igf_ap_css_fnar.option_par_loss_allow_ind%TYPE    ,
                    f_option_par_tuition_ind                IN OUT NOCOPY igf_ap_css_fnar.option_par_tuition_ind%TYPE       ,
                    f_option_par_home_ind                   IN OUT NOCOPY igf_ap_css_fnar.option_par_home_ind%TYPE          ,
                    f_option_par_home_value                 IN OUT NOCOPY igf_ap_css_fnar.option_par_home_value%TYPE        ,
                    f_option_par_home_debt                  IN OUT NOCOPY igf_ap_css_fnar.option_par_home_debt%TYPE         ,
                    f_option_stu_ira_keogh_ind              IN OUT NOCOPY igf_ap_css_fnar.option_stu_ira_keogh_ind%TYPE     ,
                    f_option_stu_home_ind                   IN OUT NOCOPY igf_ap_css_fnar.option_stu_home_ind%TYPE          ,
                    f_option_stu_home_value                 IN OUT NOCOPY igf_ap_css_fnar.option_stu_home_value%TYPE        ,
                    f_option_stu_home_debt                  IN OUT NOCOPY igf_ap_css_fnar.option_stu_home_debt%TYPE         ,
                    f_option_stu_sum_ay_inc_ind             IN OUT NOCOPY igf_ap_css_fnar.option_stu_sum_ay_inc_ind%TYPE    ,
                    f_option_par_hope_ll_credit             IN OUT NOCOPY igf_ap_css_fnar.option_par_hope_ll_credit%TYPE    ,
                    f_option_stu_hope_ll_credit             IN OUT NOCOPY igf_ap_css_fnar.option_stu_hope_ll_credit%TYPE    ,
                    f_option_par_cola_adj_ind               IN OUT NOCOPY igf_ap_css_fnar.option_par_cola_adj_ind%TYPE      ,
                    f_option_par_stu_fa_assets_ind          IN OUT NOCOPY igf_ap_css_fnar.option_par_stu_fa_assets_ind%TYPE ,
                    f_option_par_ipt_assets_ind             IN OUT NOCOPY igf_ap_css_fnar.option_par_ipt_assets_ind%TYPE    ,
                    f_option_stu_ipt_assets_ind             IN OUT NOCOPY igf_ap_css_fnar.option_stu_ipt_assets_ind%TYPE    ,
                    f_option_par_cola_adj_value             IN OUT NOCOPY igf_ap_css_fnar.option_par_cola_adj_value%TYPE    ,
                    f_im_parent_1_8_months_bas              IN OUT NOCOPY igf_ap_css_fnar.im_parent_1_8_months_bas%TYPE     ,
                    f_im_p_more_than_9_mth_ba               IN OUT NOCOPY igf_ap_css_fnar.im_p_more_than_9_mth_ba%TYPE      ,
                    f_im_parent_1_8_months_opt              IN OUT NOCOPY igf_ap_css_fnar.im_parent_1_8_months_opt%TYPE     ,
                    f_im_p_more_than_9_mth_op               IN OUT NOCOPY igf_ap_css_fnar.im_p_more_than_9_mth_op%TYPE      ,
                    f_fnar_message_1                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_1%TYPE               ,
                    f_fnar_message_2                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_2%TYPE               ,
                    f_fnar_message_3                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_3%TYPE               ,
                    f_fnar_message_4                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_4%TYPE              ,
                    f_fnar_message_5                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_5%TYPE               ,
                    f_fnar_message_6                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_6%TYPE               ,
                    f_fnar_message_7                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_7%TYPE               ,
                    f_fnar_message_8                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_8%TYPE               ,
                    f_fnar_message_9                        IN OUT NOCOPY igf_ap_css_fnar.fnar_message_9%TYPE               ,
                    f_fnar_message_10                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_10%TYPE              ,
                    f_fnar_message_11                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_11%TYPE              ,
                    f_fnar_message_12                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_12%TYPE              ,
                    f_fnar_message_13                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_13%TYPE              ,
                    f_fnar_message_20                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_20%TYPE              ,
                    f_fnar_message_21                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_21%TYPE              ,
                    f_fnar_message_22                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_22%TYPE              ,
                    f_fnar_message_23                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_23%TYPE              ,
                    f_fnar_message_24                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_24%TYPE              ,
                    f_fnar_message_25                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_25%TYPE              ,
                    f_fnar_message_26                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_26%TYPE              ,
                    f_fnar_message_27                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_27%TYPE              ,
                    f_fnar_message_30                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_30%TYPE              ,
                    f_fnar_message_31                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_31%TYPE              ,
                    f_fnar_message_32                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_32%TYPE              ,
                    f_fnar_message_33                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_33%TYPE              ,
                    f_fnar_message_34                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_34%TYPE              ,
                    f_fnar_message_35                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_35%TYPE              ,
                    f_fnar_message_36                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_36%TYPE              ,
                    f_fnar_message_37                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_37%TYPE              ,
                    f_fnar_message_38                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_38%TYPE              ,
                    f_fnar_message_39                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_39%TYPE              ,
                    f_fnar_message_45                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_45%TYPE              ,
                    f_fnar_message_46                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_46%TYPE              ,
                    f_fnar_message_47                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_47%TYPE              ,
                    f_fnar_message_48                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_48%TYPE              ,
                    f_fnar_message_49                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_49%TYPE              ,
                    f_fnar_message_50                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_50%TYPE              ,
                    f_fnar_message_51                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_51%TYPE              ,
                    f_fnar_message_52                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_52%TYPE              ,
                    f_fnar_message_53                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_53%TYPE              ,
                    f_fnar_message_55                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_55%TYPE              ,
                    f_fnar_message_56                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_56%TYPE              ,
                    f_fnar_message_57                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_57%TYPE              ,
                    f_fnar_message_58                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_58%TYPE              ,
                    f_fnar_message_59                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_59%TYPE              ,
                    f_fnar_message_60                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_60%TYPE              ,
                    f_fnar_message_61                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_61%TYPE              ,
                    f_fnar_message_62                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_62%TYPE              ,
                    f_fnar_message_63                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_63%TYPE              ,
                    f_fnar_message_64                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_64%TYPE              ,
                    f_fnar_message_65                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_65%TYPE              ,
                    f_fnar_message_71                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_71%TYPE              ,
                    f_fnar_message_72                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_72%TYPE              ,
                    f_fnar_message_73                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_73%TYPE              ,
                    f_fnar_message_74                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_74%TYPE              ,
                    f_fnar_message_75                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_75%TYPE              ,
                    f_fnar_message_76                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_76%TYPE              ,
                    f_fnar_message_77                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_77%TYPE              ,
                    f_fnar_message_78                       IN OUT NOCOPY igf_ap_css_fnar.fnar_message_78%TYPE              ,
                    f_fnar_mesg_10_stu_fam_mem              IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_10_stu_fam_mem%TYPE     ,
                    f_fnar_mesg_11_stu_no_in_coll           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_11_stu_no_in_coll%TYPE  ,
                    f_fnar_mesg_24_stu_avail_inc            IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_24_stu_avail_inc%TYPE   ,
                    f_fnar_mesg_26_stu_taxes                IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_26_stu_taxes%TYPE       ,
                    f_fnar_mesg_33_stu_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_33_stu_home_value%TYPE  ,
                    f_fnar_mesg_34_stu_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_34_stu_home_value%TYPE  ,
                    f_fnar_mesg_34_stu_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_34_stu_home_equity%TYPE ,
                    f_fnar_mesg_35_stu_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_35_stu_home_value%TYPE  ,
                    f_fnar_mesg_35_stu_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_35_stu_home_equity%TYPE ,
                    f_fnar_mesg_36_stu_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_36_stu_home_equity%TYPE ,
                    f_fnar_mesg_48_par_fam_mem              IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_48_par_fam_mem%TYPE     ,
                    f_fnar_mesg_49_par_no_in_coll           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_49_par_no_in_coll%TYPE  ,
                    f_fnar_mesg_56_par_agi                  IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_56_par_agi%TYPE         ,
                    f_fnar_mesg_62_par_taxes                IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_62_par_taxes%TYPE       ,
                    f_fnar_mesg_73_par_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_73_par_home_value%TYPE  ,
                    f_fnar_mesg_74_par_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_74_par_home_value%TYPE  ,
                    f_fnar_mesg_74_par_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_74_par_home_equity%TYPE ,
                    f_fnar_mesg_75_par_home_value           IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_75_par_home_value%TYPE  ,
                    f_fnar_mesg_75_par_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_75_par_home_equity%TYPE ,
                    f_fnar_mesg_76_par_home_equity          IN OUT NOCOPY igf_ap_css_fnar.fnar_mesg_76_par_home_equity%TYPE ,
                    f_assumption_message_1                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_1%TYPE         ,
                    f_assumption_message_2                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_2%TYPE         ,
                    f_assumption_message_3                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_3%TYPE         ,
                    f_assumption_message_4                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_4%TYPE         ,
                    f_assumption_message_5                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_5%TYPE         ,
                    f_assumption_message_6                  IN OUT NOCOPY igf_ap_css_fnar.assumption_message_6%TYPE         ,
                    f_record_mark                           IN OUT NOCOPY igf_ap_css_fnar.record_mark%TYPE                  ,
                    f_legacy_record_flag                    IN OUT NOCOPY igf_ap_css_fnar.legacy_record_flag%TYPE           ,
                    f_creation_date                         IN OUT NOCOPY igf_ap_css_fnar.creation_date%TYPE                ,
                    f_created_by                            IN OUT NOCOPY igf_ap_css_fnar.created_by%TYPE                   ,
                    f_last_updated_by                       IN OUT NOCOPY igf_ap_css_fnar.last_updated_by%TYPE              ,
                    f_last_update_date                      IN OUT NOCOPY igf_ap_css_fnar.last_update_date%TYPE             ,
                    f_last_update_login                     IN OUT NOCOPY igf_ap_css_fnar.last_update_login%TYPE            ,
                    f_opt_ind_stu_ipt_assets_flag           IN OUT NOCOPY igf_ap_css_fnar.option_ind_stu_ipt_assets_flag%TYPE ,
                    f_cust_parent_cont_adj_num              IN OUT NOCOPY igf_ap_css_fnar.cust_parent_cont_adj_num%TYPE     ,
                    f_custodial_parent_num                  IN OUT NOCOPY igf_ap_css_fnar.custodial_parent_num%TYPE         ,
                    f_cust_par_base_prcnt_inc_amt           IN OUT NOCOPY igf_ap_css_fnar.cust_par_base_prcnt_inc_amt%TYPE  ,
                    f_cust_par_base_cont_inc_amt            IN OUT NOCOPY igf_ap_css_fnar.cust_par_base_cont_inc_amt%TYPE   ,
                    f_cust_par_base_cont_ast_amt            IN OUT NOCOPY igf_ap_css_fnar.cust_par_base_cont_ast_amt%TYPE   ,
                    f_cust_par_base_tot_cont_amt            IN OUT NOCOPY igf_ap_css_fnar.cust_par_base_tot_cont_amt%TYPE   ,
                    f_cust_par_opt_prcnt_inc_amt            IN OUT NOCOPY igf_ap_css_fnar.cust_par_opt_prcnt_inc_amt%TYPE   ,
                    f_cust_par_opt_cont_inc_amt             IN OUT NOCOPY igf_ap_css_fnar.cust_par_opt_cont_inc_amt%TYPE    ,
                    f_cust_par_opt_cont_ast_amt             IN OUT NOCOPY igf_ap_css_fnar.cust_par_opt_cont_ast_amt%TYPE    ,
                    f_cust_par_opt_tot_cont_amt             IN OUT NOCOPY igf_ap_css_fnar.cust_par_opt_tot_cont_amt%TYPE    ,
                    f_parents_email_txt                     IN OUT NOCOPY igf_ap_css_fnar.parents_email_txt%TYPE            ,
                    f_parent_1_birth_date                   IN OUT NOCOPY igf_ap_css_fnar.parent_1_birth_date%TYPE          ,
                    f_parent_2_birth_date                   IN OUT NOCOPY igf_ap_css_fnar.parent_2_birth_date%TYPE          ,

                    p_err_mesg OUT NOCOPY fnd_new_messages.message_name%TYPE)
  RETURN VARCHAR AS

  p_profile_rec igf_ap_css_profile%ROWTYPE;

  p_fnar_rec igf_ap_css_fnar%ROWTYPE;

  p_user_hook BOOLEAN;

  p_error_msg fnd_new_messages.message_name%TYPE;

  BEGIN


    p_profile_rec.cssp_id                         :=  pr_cssp_id                        ;
    p_profile_rec.org_id                          :=  pr_org_id                         ;
    p_profile_rec.base_id                         :=  pr_base_id                        ;
    p_profile_rec.system_record_type              :=  pr_system_record_type             ;
    p_profile_rec.active_profile                  :=  pr_active_profile                 ;
    p_profile_rec.college_code                    :=  pr_college_code                   ;
    p_profile_rec.academic_year                   :=  pr_academic_year                  ;
    p_profile_rec.stu_record_type                 :=  pr_stu_record_type                ;
    p_profile_rec.css_id_number                   :=  pr_css_id_number                  ;
    p_profile_rec.registration_receipt_date       :=  pr_registration_receipt_date      ;
    p_profile_rec.registration_type               :=  pr_registration_type              ;
    p_profile_rec.application_receipt_date        :=  pr_application_receipt_date       ;
    p_profile_rec.application_type                :=  pr_application_type               ;
    p_profile_rec.original_fnar_compute           :=  pr_original_fnar_compute          ;
    p_profile_rec.revision_fnar_compute_date      :=  pr_revision_fnar_compute_date     ;
    p_profile_rec.electronic_extract_date         :=  pr_electronic_extract_date        ;
    p_profile_rec.institutional_reporting_type    :=  pr_inst_reporting_type            ;
    p_profile_rec.asr_receipt_date                :=  pr_asr_receipt_date               ;
    p_profile_rec.last_name                       :=  pr_last_name                      ;
    p_profile_rec.first_name                      :=  pr_first_name                     ;
    p_profile_rec.middle_initial                  :=  pr_middle_initial                 ;
    p_profile_rec.address_number_and_street       :=  pr_address_number_and_street      ;
    p_profile_rec.city                            :=  pr_city                           ;
    p_profile_rec.state_mailing                   :=  pr_state_mailing                  ;
    p_profile_rec.zip_code                        :=  pr_zip_code                       ;
    p_profile_rec.s_telephone_number              :=  pr_s_telephone_number             ;
    p_profile_rec.s_title                         :=  pr_s_title                        ;
    p_profile_rec.date_of_birth                   :=  pr_date_of_birth                  ;
    p_profile_rec.social_security_number          :=  pr_social_security_number         ;
    p_profile_rec.state_legal_residence           :=  pr_state_legal_residence          ;
    p_profile_rec.foreign_address_indicator       :=  pr_foreign_address_indicator      ;
    p_profile_rec.foreign_postal_code             :=  pr_foreign_postal_code            ;
    p_profile_rec.country                         :=  pr_country                        ;
    p_profile_rec.financial_aid_status            :=  pr_financial_aid_status           ;
    p_profile_rec.year_in_college                 :=  pr_year_in_college                ;
    p_profile_rec.marital_status                  :=  pr_marital_status                 ;
    p_profile_rec.ward_court                      :=  pr_ward_court                     ;
    p_profile_rec.legal_dependents_other          :=  pr_legal_dependents_other         ;
    p_profile_rec.household_size                  :=  pr_household_size                 ;
    p_profile_rec.number_in_college               :=  pr_number_in_college              ;
    p_profile_rec.citizenship_status              :=  pr_citizenship_status             ;
    p_profile_rec.citizenship_country             :=  pr_citizenship_country            ;
    p_profile_rec.visa_classification             :=  pr_visa_classification            ;
    p_profile_rec.tax_figures                     :=  pr_tax_figures                    ;
    p_profile_rec.number_exemptions               :=  pr_number_exemptions              ;
    p_profile_rec.adjusted_gross_inc              :=  pr_adjusted_gross_inc             ;
    p_profile_rec.us_tax_paid                     :=  pr_us_tax_paid                    ;
    p_profile_rec.itemized_deductions             :=  pr_itemized_deductions            ;
    p_profile_rec.stu_income_work                 :=  pr_stu_income_work                ;
    p_profile_rec.spouse_income_work              :=  pr_spouse_income_work             ;
    p_profile_rec.divid_int_inc                   :=  pr_divid_int_inc                  ;
    p_profile_rec.soc_sec_benefits                :=  pr_soc_sec_benefits               ;
    p_profile_rec.welfare_tanf                    :=  pr_welfare_tanf                   ;
    p_profile_rec.child_supp_rcvd                 :=  pr_child_supp_rcvd                ;
    p_profile_rec.earned_income_credit            :=  pr_earned_income_credit           ;
    p_profile_rec.other_untax_income              :=  pr_other_untax_income             ;
    p_profile_rec.tax_stu_aid                     :=  pr_tax_stu_aid                    ;
    p_profile_rec.cash_sav_check                  :=  pr_cash_sav_check                 ;
    p_profile_rec.ira_keogh                       :=  pr_ira_keogh                      ;
    p_profile_rec.invest_value                    :=  pr_invest_value                   ;
    p_profile_rec.invest_debt                     :=  pr_invest_debt                    ;
    p_profile_rec.home_value                      :=  pr_home_value                     ;
    p_profile_rec.home_debt                       :=  pr_home_debt                      ;
    p_profile_rec.oth_real_value                  :=  pr_oth_real_value                 ;
    p_profile_rec.oth_real_debt                   :=  pr_oth_real_debt                  ;
    p_profile_rec.bus_farm_value                  :=  pr_bus_farm_value                 ;
    p_profile_rec.bus_farm_debt                   :=  pr_bus_farm_debt                  ;
    p_profile_rec.live_on_farm                    :=  pr_live_on_farm                   ;
    p_profile_rec.home_purch_price                :=  pr_home_purch_price               ;
    p_profile_rec.hope_ll_credit                  :=  pr_hope_ll_credit                 ;
    p_profile_rec.home_purch_year                 :=  pr_home_purch_year                ;
    p_profile_rec.trust_amount                    :=  pr_trust_amount                   ;
    p_profile_rec.trust_avail                     :=  pr_trust_avail                    ;
    p_profile_rec.trust_estab                     :=  pr_trust_estab                    ;
    p_profile_rec.child_support_paid              :=  pr_child_support_paid             ;
    p_profile_rec.med_dent_expenses               :=  pr_med_dent_expenses              ;
    p_profile_rec.vet_us                          :=  pr_vet_us                         ;
    p_profile_rec.vet_ben_amount                  :=  pr_vet_ben_amount                 ;
    p_profile_rec.vet_ben_months                  :=  pr_vet_ben_months                 ;
    p_profile_rec.stu_summer_wages                :=  pr_stu_summer_wages               ;
    p_profile_rec.stu_school_yr_wages             :=  pr_stu_school_yr_wages            ;
    p_profile_rec.spouse_summer_wages             :=  pr_spouse_summer_wages            ;
    p_profile_rec.spouse_school_yr_wages          :=  pr_spouse_school_yr_wages         ;
    p_profile_rec.summer_other_tax_inc            :=  pr_summer_other_tax_inc           ;
    p_profile_rec.school_yr_other_tax_inc         :=  pr_school_yr_other_tax_inc        ;
    p_profile_rec.summer_untax_inc                :=  pr_summer_untax_inc               ;
    p_profile_rec.school_yr_untax_inc             :=  pr_school_yr_untax_inc            ;
    p_profile_rec.grants_schol_etc                :=  pr_grants_schol_etc               ;
    p_profile_rec.tuit_benefits                   :=  pr_tuit_benefits                  ;
    p_profile_rec.cont_parents                    :=  pr_cont_parents                   ;
    p_profile_rec.cont_relatives                  :=  pr_cont_relatives                 ;
    p_profile_rec.p_siblings_pre_tuit             :=  pr_p_siblings_pre_tuit            ;
    p_profile_rec.p_student_pre_tuit              :=  pr_p_student_pre_tuit             ;
    p_profile_rec.p_household_size                :=  pr_p_household_size               ;
    p_profile_rec.p_number_in_college             :=  pr_p_number_in_college            ;
    p_profile_rec.p_parents_in_college            :=  pr_p_parents_in_college           ;
    p_profile_rec.p_marital_status                :=  pr_p_marital_status               ;
    p_profile_rec.p_state_legal_residence         :=  pr_p_state_legal_residence        ;
    p_profile_rec.p_natural_par_status            :=  pr_p_natural_par_status           ;
    p_profile_rec.p_child_supp_paid               :=  pr_p_child_supp_paid              ;
    p_profile_rec.p_repay_ed_loans                :=  pr_p_repay_ed_loans               ;
    p_profile_rec.p_med_dent_expenses             :=  pr_p_med_dent_expenses            ;
    p_profile_rec.p_tuit_paid_amount              :=  pr_p_tuit_paid_amount             ;
    p_profile_rec.p_tuit_paid_number              :=  pr_p_tuit_paid_number             ;
    p_profile_rec.p_exp_child_supp_paid           :=  pr_p_exp_child_supp_paid          ;
    p_profile_rec.p_exp_repay_ed_loans            :=  pr_p_exp_repay_ed_loans           ;
    p_profile_rec.p_exp_med_dent_expenses         :=  pr_p_exp_med_dent_expenses        ;
    p_profile_rec.p_exp_tuit_pd_amount            :=  pr_p_exp_tuit_pd_amount           ;
    p_profile_rec.p_exp_tuit_pd_number            :=  pr_p_exp_tuit_pd_number           ;
    p_profile_rec.p_cash_sav_check                :=  pr_p_cash_sav_check               ;
    p_profile_rec.p_month_mortgage_pay            :=  pr_p_month_mortgage_pay           ;
    p_profile_rec.p_invest_value                  :=  pr_p_invest_value                 ;
    p_profile_rec.p_invest_debt                   :=  pr_p_invest_debt                  ;
    p_profile_rec.p_home_value                    :=  pr_p_home_value                   ;
    p_profile_rec.p_home_debt                     :=  pr_p_home_debt                    ;
    p_profile_rec.p_home_purch_price              :=  pr_p_home_purch_price             ;
    p_profile_rec.p_own_business_farm             :=  pr_p_own_business_farm            ;
    p_profile_rec.p_business_value                :=  pr_p_business_value               ;
    p_profile_rec.p_business_debt                 :=  pr_p_business_debt                ;
    p_profile_rec.p_farm_value                    :=  pr_p_farm_value                   ;
    p_profile_rec.p_farm_debt                     :=  pr_p_farm_debt                    ;
    p_profile_rec.p_live_on_farm                  :=  pr_p_live_on_farm                 ;
    p_profile_rec.p_oth_real_estate_value         :=  pr_p_oth_real_estate_value        ;
    p_profile_rec.p_oth_real_estate_debt          :=  pr_p_oth_real_estate_debt         ;
    p_profile_rec.p_oth_real_purch_price          :=  pr_p_oth_real_purch_price         ;
    p_profile_rec.p_siblings_assets               :=  pr_p_siblings_assets              ;
    p_profile_rec.p_home_purch_year               :=  pr_p_home_purch_year              ;
    p_profile_rec.p_oth_real_purch_year           :=  pr_p_oth_real_purch_year          ;
    p_profile_rec.p_prior_agi                     :=  pr_p_prior_agi                    ;
    p_profile_rec.p_prior_us_tax_paid             :=  pr_p_prior_us_tax_paid            ;
    p_profile_rec.p_prior_item_deductions         :=  pr_p_prior_item_deductions        ;
    p_profile_rec.p_prior_other_untax_inc         :=  pr_p_prior_other_untax_inc        ;
    p_profile_rec.p_tax_figures                   :=  pr_p_tax_figures                  ;
    p_profile_rec.p_number_exemptions             :=  pr_p_number_exemptions            ;
    p_profile_rec.p_adjusted_gross_inc            :=  pr_p_adjusted_gross_inc           ;
    p_profile_rec.p_wages_sal_tips                :=  pr_p_wages_sal_tips               ;
    p_profile_rec.p_interest_income               :=  pr_p_interest_income              ;
    p_profile_rec.p_dividend_income               :=  pr_p_dividend_income              ;
    p_profile_rec.p_net_inc_bus_farm              :=  pr_p_net_inc_bus_farm             ;
    p_profile_rec.p_other_taxable_income          :=  pr_p_other_taxable_income         ;
    p_profile_rec.p_adj_to_income                 :=  pr_p_adj_to_income                ;
    p_profile_rec.p_us_tax_paid                   :=  pr_p_us_tax_paid                  ;
    p_profile_rec.p_itemized_deductions           :=  pr_p_itemized_deductions          ;
    p_profile_rec.p_father_income_work            :=  pr_p_father_income_work           ;
    p_profile_rec.p_mother_income_work            :=  pr_p_mother_income_work           ;
    p_profile_rec.p_soc_sec_ben                   :=  pr_p_soc_sec_ben                  ;
    p_profile_rec.p_welfare_tanf                  :=  pr_p_welfare_tanf                 ;
    p_profile_rec.p_child_supp_rcvd               :=  pr_p_child_supp_rcvd              ;
    p_profile_rec.p_ded_ira_keogh                 :=  pr_p_ded_ira_keogh                ;
    p_profile_rec.p_tax_defer_pens_savs           :=  pr_p_tax_defer_pens_savs          ;
    p_profile_rec.p_dep_care_med_spending         :=  pr_p_dep_care_med_spending        ;
    p_profile_rec.p_earned_income_credit          :=  pr_p_earned_income_credit         ;
    p_profile_rec.p_living_allow                  :=  pr_p_living_allow                 ;
    p_profile_rec.p_tax_exmpt_int                 :=  pr_p_tax_exmpt_int                ;
    p_profile_rec.p_foreign_inc_excl              :=  pr_p_foreign_inc_excl             ;
    p_profile_rec.p_other_untax_inc               :=  pr_p_other_untax_inc              ;
    p_profile_rec.p_hope_ll_credit                :=  pr_p_hope_ll_credit               ;
    p_profile_rec.p_yr_separation                 :=  pr_p_yr_separation                ;
    p_profile_rec.p_yr_divorce                    :=  pr_p_yr_divorce                   ;
    p_profile_rec.p_exp_father_inc                :=  pr_p_exp_father_inc               ;
    p_profile_rec.p_exp_mother_inc                :=  pr_p_exp_mother_inc               ;
    p_profile_rec.p_exp_other_tax_inc             :=  pr_p_exp_other_tax_inc            ;
    p_profile_rec.p_exp_other_untax_inc           :=  pr_p_exp_other_untax_inc          ;
    p_profile_rec.line_2_relation                 :=  pr_line_2_relation                ;
    p_profile_rec.line_2_attend_college           :=  pr_line_2_attend_college          ;
    p_profile_rec.line_3_relation                 :=  pr_line_3_relation                ;
    p_profile_rec.line_3_attend_college           :=  pr_line_3_attend_college          ;
    p_profile_rec.line_4_relation                 :=  pr_line_4_relation                ;
    p_profile_rec.line_4_attend_college           :=  pr_line_4_attend_college          ;
    p_profile_rec.line_5_relation                 :=  pr_line_5_relation                ;
    p_profile_rec.line_5_attend_college           :=  pr_line_5_attend_college          ;
    p_profile_rec.line_6_relation                 :=  pr_line_6_relation                ;
    p_profile_rec.line_6_attend_college           :=  pr_line_6_attend_college          ;
    p_profile_rec.line_7_relation                 :=  pr_line_7_relation                ;
    p_profile_rec.line_7_attend_college           :=  pr_line_7_attend_college          ;
    p_profile_rec.line_8_relation                 :=  pr_line_8_relation                ;
    p_profile_rec.line_8_attend_college           :=  pr_line_8_attend_college          ;
    p_profile_rec.p_age_father                    :=  pr_p_age_father                   ;
    p_profile_rec.p_age_mother                    :=  pr_p_age_mother                   ;
    p_profile_rec.p_div_sep_ind                   :=  pr_p_div_sep_ind                  ;
    p_profile_rec.b_cont_non_custodial_par        :=  pr_b_cont_non_custodial_par       ;
    p_profile_rec.college_type_2                  :=  pr_college_type_2                 ;
    p_profile_rec.college_type_3                  :=  pr_college_type_3                 ;
    p_profile_rec.college_type_4                  :=  pr_college_type_4                 ;
    p_profile_rec.college_type_5                  :=  pr_college_type_5                 ;
    p_profile_rec.college_type_6                  :=  pr_college_type_6                 ;
    p_profile_rec.college_type_7                  :=  pr_college_type_7                 ;
    p_profile_rec.college_type_8                  :=  pr_college_type_8                 ;
    p_profile_rec.school_code_1                   :=  pr_school_code_1                  ;
    p_profile_rec.housing_code_1                  :=  pr_housing_code_1                 ;
    p_profile_rec.school_code_2                   :=  pr_school_code_2                  ;
    p_profile_rec.housing_code_2                  :=  pr_housing_code_2                 ;
    p_profile_rec.school_code_3                   :=  pr_school_code_3                  ;
    p_profile_rec.housing_code_3                  :=  pr_housing_code_3                 ;
    p_profile_rec.school_code_4                   :=  pr_school_code_4                  ;
    p_profile_rec.housing_code_4                  :=  pr_housing_code_4                 ;
    p_profile_rec.school_code_5                   :=  pr_school_code_5                  ;
    p_profile_rec.housing_code_5                  :=  pr_housing_code_5                 ;
    p_profile_rec.school_code_6                   :=  pr_school_code_6                  ;
    p_profile_rec.housing_code_6                  :=  pr_housing_code_6                 ;
    p_profile_rec.school_code_7                   :=  pr_school_code_7                  ;
    p_profile_rec.housing_code_7                  :=  pr_housing_code_7                 ;
    p_profile_rec.school_code_8                   :=  pr_school_code_8                  ;
    p_profile_rec.housing_code_8                  :=  pr_housing_code_8                 ;
    p_profile_rec.school_code_9                   :=  pr_school_code_9                  ;
    p_profile_rec.housing_code_9                  :=  pr_housing_code_9                 ;
    p_profile_rec.school_code_10                  :=  pr_school_code_10                 ;
    p_profile_rec.housing_code_10                 :=  pr_housing_code_10                ;
    p_profile_rec.additional_school_code_1        :=  pr_additional_school_code_1       ;
    p_profile_rec.additional_school_code_2        :=  pr_additional_school_code_2       ;
    p_profile_rec.additional_school_code_3        :=  pr_additional_school_code_3       ;
    p_profile_rec.additional_school_code_4        :=  pr_additional_school_code_4       ;
    p_profile_rec.additional_school_code_5        :=  pr_additional_school_code_5       ;
    p_profile_rec.additional_school_code_6        :=  pr_additional_school_code_6       ;
    p_profile_rec.additional_school_code_7        :=  pr_additional_school_code_7       ;
    p_profile_rec.additional_school_code_8        :=  pr_additional_school_code_8       ;
    p_profile_rec.additional_school_code_9        :=  pr_additional_school_code_9       ;
    p_profile_rec.additional_school_code_10       :=  pr_additional_school_code_10      ;
    p_profile_rec.explanation_spec_circum         :=  pr_explanation_spec_circum        ;
    p_profile_rec.signature_student               :=  pr_signature_student              ;
    p_profile_rec.signature_spouse                :=  pr_signature_spouse               ;
    p_profile_rec.signature_father                :=  pr_signature_father               ;
    p_profile_rec.signature_mother                :=  pr_signature_mother               ;
    p_profile_rec.month_day_completed             :=  pr_month_day_completed            ;
    p_profile_rec.year_completed                  :=  pr_year_completed                 ;
    p_profile_rec.age_line_2                      :=  pr_age_line_2                     ;
    p_profile_rec.age_line_3                      :=  pr_age_line_3                     ;
    p_profile_rec.age_line_4                      :=  pr_age_line_4                     ;
    p_profile_rec.age_line_5                      :=  pr_age_line_5                     ;
    p_profile_rec.age_line_6                      :=  pr_age_line_6                     ;
    p_profile_rec.age_line_7                      :=  pr_age_line_7                     ;
    p_profile_rec.age_line_8                      :=  pr_age_line_8                     ;
    p_profile_rec.a_online_signature              :=  pr_a_online_signature             ;
    p_profile_rec.question_1_number               :=  pr_question_1_number              ;
    p_profile_rec.question_1_size                 :=  pr_question_1_size                ;
    p_profile_rec.question_1_answer               :=  pr_question_1_answer              ;
    p_profile_rec.question_2_number               :=  pr_question_2_number              ;
    p_profile_rec.question_2_size                 :=  pr_question_2_size                ;
    p_profile_rec.question_2_answer               :=  pr_question_2_answer              ;
    p_profile_rec.question_3_number               :=  pr_question_3_number              ;
    p_profile_rec.question_3_size                 :=  pr_question_3_size                ;
    p_profile_rec.question_3_answer               :=  pr_question_3_answer              ;
    p_profile_rec.question_4_number               :=  pr_question_4_number              ;
    p_profile_rec.question_4_size                 :=  pr_question_4_size                ;
    p_profile_rec.question_4_answer               :=  pr_question_4_answer              ;
    p_profile_rec.question_5_number               :=  pr_question_5_number              ;
    p_profile_rec.question_5_size                 :=  pr_question_5_size                ;
    p_profile_rec.question_5_answer               :=  pr_question_5_answer              ;
    p_profile_rec.question_6_number               :=  pr_question_6_number              ;
    p_profile_rec.question_6_size                 :=  pr_question_6_size                ;
    p_profile_rec.question_6_answer               :=  pr_question_6_answer              ;
    p_profile_rec.question_7_number               :=  pr_question_7_number              ;
    p_profile_rec.question_7_size                 :=  pr_question_7_size                ;
    p_profile_rec.question_7_answer               :=  pr_question_7_answer              ;
    p_profile_rec.question_8_number               :=  pr_question_8_number              ;
    p_profile_rec.question_8_size                 :=  pr_question_8_size                ;
    p_profile_rec.question_8_answer               :=  pr_question_8_answer              ;
    p_profile_rec.question_9_number               :=  pr_question_9_number              ;
    p_profile_rec.question_9_size                 :=  pr_question_9_size                ;
    p_profile_rec.question_9_answer               :=  pr_question_9_answer              ;
    p_profile_rec.question_10_number              :=  pr_question_10_number             ;
    p_profile_rec.question_10_size                :=  pr_question_10_size               ;
    p_profile_rec.question_10_answer              :=  pr_question_10_answer             ;
    p_profile_rec.question_11_number              :=  pr_question_11_number             ;
    p_profile_rec.question_11_size                :=  pr_question_11_size               ;
    p_profile_rec.question_11_answer              :=  pr_question_11_answer             ;
    p_profile_rec.question_12_number              :=  pr_question_12_number             ;
    p_profile_rec.question_12_size                :=  pr_question_12_size               ;
    p_profile_rec.question_12_answer              :=  pr_question_12_answer             ;
    p_profile_rec.question_13_number              :=  pr_question_13_number             ;
    p_profile_rec.question_13_size                :=  pr_question_13_size               ;
    p_profile_rec.question_13_answer              :=  pr_question_13_answer             ;
    p_profile_rec.question_14_number              :=  pr_question_14_number             ;
    p_profile_rec.question_14_size                :=  pr_question_14_size               ;
    p_profile_rec.question_14_answer              :=  pr_question_14_answer             ;
    p_profile_rec.question_15_number              :=  pr_question_15_number             ;
    p_profile_rec.question_15_size                :=  pr_question_15_size               ;
    p_profile_rec.question_15_answer              :=  pr_question_15_answer             ;
    p_profile_rec.question_16_number              :=  pr_question_16_number             ;
    p_profile_rec.question_16_size                :=  pr_question_16_size               ;
    p_profile_rec.question_16_answer              :=  pr_question_16_answer             ;
    p_profile_rec.question_17_number              :=  pr_question_17_number             ;
    p_profile_rec.question_17_size                :=  pr_question_17_size               ;
    p_profile_rec.question_17_answer              :=  pr_question_17_answer             ;
    p_profile_rec.question_18_number              :=  pr_question_18_number             ;
    p_profile_rec.question_18_size                :=  pr_question_18_size               ;
    p_profile_rec.question_18_answer              :=  pr_question_18_answer             ;
    p_profile_rec.question_19_number              :=  pr_question_19_number             ;
    p_profile_rec.question_19_size                :=  pr_question_19_size               ;
    p_profile_rec.question_19_answer              :=  pr_question_19_answer             ;
    p_profile_rec.question_20_number              :=  pr_question_20_number             ;
    p_profile_rec.question_20_size                :=  pr_question_20_size               ;
    p_profile_rec.question_20_answer              :=  pr_question_20_answer             ;
    p_profile_rec.question_21_number              :=  pr_question_21_number             ;
    p_profile_rec.question_21_size                :=  pr_question_21_size               ;
    p_profile_rec.question_21_answer              :=  pr_question_21_answer             ;
    p_profile_rec.question_22_number              :=  pr_question_22_number             ;
    p_profile_rec.question_22_size                :=  pr_question_22_size               ;
    p_profile_rec.question_22_answer              :=  pr_question_22_answer             ;
    p_profile_rec.question_23_number              :=  pr_question_23_number             ;
    p_profile_rec.question_23_size                :=  pr_question_23_size               ;
    p_profile_rec.question_23_answer              :=  pr_question_23_answer             ;
    p_profile_rec.question_24_number              :=  pr_question_24_number             ;
    p_profile_rec.question_24_size                :=  pr_question_24_size               ;
    p_profile_rec.question_24_answer              :=  pr_question_24_answer             ;
    p_profile_rec.question_25_number              :=  pr_question_25_number             ;
    p_profile_rec.question_25_size                :=  pr_question_25_size               ;
    p_profile_rec.question_25_answer              :=  pr_question_25_answer             ;
    p_profile_rec.question_26_number              :=  pr_question_26_number             ;
    p_profile_rec.question_26_size                :=  pr_question_26_size               ;
    p_profile_rec.question_26_answer              :=  pr_question_26_answer             ;
    p_profile_rec.question_27_number              :=  pr_question_27_number             ;
    p_profile_rec.question_27_size                :=  pr_question_27_size               ;
    p_profile_rec.question_27_answer              :=  pr_question_27_answer             ;
    p_profile_rec.question_28_number              :=  pr_question_28_number             ;
    p_profile_rec.question_28_size                :=  pr_question_28_size               ;
    p_profile_rec.question_28_answer              :=  pr_question_28_answer             ;
    p_profile_rec.question_29_number              :=  pr_question_29_number             ;
    p_profile_rec.question_29_size                :=  pr_question_29_size               ;
    p_profile_rec.question_29_answer              :=  pr_question_29_answer             ;
    p_profile_rec.question_30_number              :=  pr_question_30_number             ;
    p_profile_rec.questions_30_size               :=  pr_questions_30_size              ;
    p_profile_rec.question_30_answer              :=  pr_question_30_answer             ;
    p_profile_rec.legacy_record_flag              :=  pr_legacy_record_flag             ;
    p_profile_rec.coa_duration_efc_amt            :=  pr_coa_duration_efc_amt           ;
    p_profile_rec.coa_duration_num                :=  pr_coa_duration_num               ;
    p_profile_rec.created_by                      :=  pr_created_by                     ;
    p_profile_rec.creation_date                   :=  pr_creation_date                  ;
    p_profile_rec.last_updated_by                 :=  pr_last_updated_by                ;
    p_profile_rec.last_update_date                :=  pr_last_update_date               ;
    p_profile_rec.last_update_login               :=  pr_last_update_login              ;
    p_profile_rec.p_soc_sec_ben_student_amt       :=  pr_p_soc_sec_ben_student_amt      ;
    p_profile_rec.p_tuit_fee_deduct_amt           :=  pr_p_tuit_fee_deduct_amt          ;
    p_profile_rec.stu_lives_with_num              :=  pr_stu_lives_with_num             ;
    p_profile_rec.stu_most_support_from_num       :=  pr_stu_most_support_from_num      ;
    p_profile_rec.location_computer_num           :=  pr_location_computer_num          ;

    p_fnar_rec.fnar_id                            :=  f_fnar_id                        ;
    p_fnar_rec.cssp_id                            :=  f_cssp_id                        ;
    p_fnar_rec.r_s_email_address                  :=  f_r_s_email_address              ;
    p_fnar_rec.eps_code                           :=  f_eps_code                       ;
    p_fnar_rec.comp_css_dependency_status         :=  f_comp_css_dependency_status     ;
    p_fnar_rec.stu_age                            :=  f_stu_age                        ;
    p_fnar_rec.assumed_stu_yr_in_coll             :=  f_assumed_stu_yr_in_coll         ;
    p_fnar_rec.comp_stu_marital_status            :=  f_comp_stu_marital_status        ;
    p_fnar_rec.stu_family_members                 :=  f_stu_family_members             ;
    p_fnar_rec.stu_fam_members_in_college         :=  f_stu_fam_members_in_college     ;
    p_fnar_rec.par_marital_status                 :=  f_par_marital_status             ;
    p_fnar_rec.par_family_members                 :=  f_par_family_members             ;
    p_fnar_rec.par_total_in_college               :=  f_par_total_in_college           ;
    p_fnar_rec.par_par_in_college                 :=  f_par_par_in_college             ;
    p_fnar_rec.par_others_in_college              :=  f_par_others_in_college          ;
    p_fnar_rec.par_aesa                           :=  f_par_aesa                       ;
    p_fnar_rec.par_cesa                           :=  f_par_cesa                       ;
    p_fnar_rec.stu_aesa                           :=  f_stu_aesa                       ;
    p_fnar_rec.stu_cesa                           :=  f_stu_cesa                       ;
    p_fnar_rec.im_p_bas_agi_taxable_income        :=  f_im_p_bas_agi_taxable_income    ;
    p_fnar_rec.im_p_bas_untx_inc_and_ben          :=  f_im_p_bas_untx_inc_and_ben      ;
    p_fnar_rec.im_p_bas_inc_adj                   :=  f_im_p_bas_inc_adj               ;
    p_fnar_rec.im_p_bas_total_income              :=  f_im_p_bas_total_income          ;
    p_fnar_rec.im_p_bas_us_income_tax             :=  f_im_p_bas_us_income_tax         ;
    p_fnar_rec.im_p_bas_st_and_other_tax          :=  f_im_p_bas_st_and_other_tax      ;
    p_fnar_rec.im_p_bas_fica_tax                  :=  f_im_p_bas_fica_tax              ;
    p_fnar_rec.im_p_bas_med_dental                :=  f_im_p_bas_med_dental            ;
    p_fnar_rec.im_p_bas_employment_allow          :=  f_im_p_bas_employment_allow      ;
    p_fnar_rec.im_p_bas_annual_ed_savings         :=  f_im_p_bas_annual_ed_savings     ;
    p_fnar_rec.im_p_bas_inc_prot_allow_m          :=  f_im_p_bas_inc_prot_allow_m      ;
    p_fnar_rec.im_p_bas_total_inc_allow           :=  f_im_p_bas_total_inc_allow       ;
    p_fnar_rec.im_p_bas_cal_avail_inc             :=  f_im_p_bas_cal_avail_inc         ;
    p_fnar_rec.im_p_bas_avail_income              :=  f_im_p_bas_avail_income          ;
    p_fnar_rec.im_p_bas_total_cont_inc            :=  f_im_p_bas_total_cont_inc        ;
    p_fnar_rec.im_p_bas_cash_bank_accounts        :=  f_im_p_bas_cash_bank_accounts    ;
    p_fnar_rec.im_p_bas_home_equity               :=  f_im_p_bas_home_equity           ;
    p_fnar_rec.im_p_bas_ot_rl_est_inv_eq          :=  f_im_p_bas_ot_rl_est_inv_eq      ;
    p_fnar_rec.im_p_bas_adj_bus_farm_worth        :=  f_im_p_bas_adj_bus_farm_worth    ;
    p_fnar_rec.im_p_bas_ass_sibs_pre_tui          :=  f_im_p_bas_ass_sibs_pre_tui      ;
    p_fnar_rec.im_p_bas_net_worth                 :=  f_im_p_bas_net_worth             ;
    p_fnar_rec.im_p_bas_emerg_res_allow           :=  f_im_p_bas_emerg_res_allow       ;
    p_fnar_rec.im_p_bas_cum_ed_savings            :=  f_im_p_bas_cum_ed_savings        ;
    p_fnar_rec.im_p_bas_low_inc_allow             :=  f_im_p_bas_low_inc_allow         ;
    p_fnar_rec.im_p_bas_total_asset_allow         :=  f_im_p_bas_total_asset_allow     ;
    p_fnar_rec.im_p_bas_disc_net_worth            :=  f_im_p_bas_disc_net_worth        ;
    p_fnar_rec.im_p_bas_total_cont_asset          :=  f_im_p_bas_total_cont_asset      ;
    p_fnar_rec.im_p_bas_total_cont                :=  f_im_p_bas_total_cont            ;
    p_fnar_rec.im_p_bas_num_in_coll_adj           :=  f_im_p_bas_num_in_coll_adj       ;
    p_fnar_rec.im_p_bas_cont_for_stu              :=  f_im_p_bas_cont_for_stu          ;
    p_fnar_rec.im_p_bas_cont_from_income          :=  f_im_p_bas_cont_from_income      ;
    p_fnar_rec.im_p_bas_cont_from_assets          :=  f_im_p_bas_cont_from_assets      ;
    p_fnar_rec.im_p_opt_agi_taxable_income        :=  f_im_p_opt_agi_taxable_income    ;
    p_fnar_rec.im_p_opt_untx_inc_and_ben          :=  f_im_p_opt_untx_inc_and_ben      ;
    p_fnar_rec.im_p_opt_inc_adj                   :=  f_im_p_opt_inc_adj               ;
    p_fnar_rec.im_p_opt_total_income              :=  f_im_p_opt_total_income          ;
    p_fnar_rec.im_p_opt_us_income_tax             :=  f_im_p_opt_us_income_tax         ;
    p_fnar_rec.im_p_opt_st_and_other_tax          :=  f_im_p_opt_st_and_other_tax      ;
    p_fnar_rec.im_p_opt_fica_tax                  :=  f_im_p_opt_fica_tax              ;
    p_fnar_rec.im_p_opt_med_dental                :=  f_im_p_opt_med_dental            ;
    p_fnar_rec.im_p_opt_elem_sec_tuit             :=  f_im_p_opt_elem_sec_tuit         ;
    p_fnar_rec.im_p_opt_employment_allow          :=  f_im_p_opt_employment_allow      ;
    p_fnar_rec.im_p_opt_annual_ed_savings         :=  f_im_p_opt_annual_ed_savings     ;
    p_fnar_rec.im_p_opt_inc_prot_allow_m          :=  f_im_p_opt_inc_prot_allow_m      ;
    p_fnar_rec.im_p_opt_total_inc_allow           :=  f_im_p_opt_total_inc_allow       ;
    p_fnar_rec.im_p_opt_cal_avail_inc             :=  f_im_p_opt_cal_avail_inc         ;
    p_fnar_rec.im_p_opt_avail_income              :=  f_im_p_opt_avail_income          ;
    p_fnar_rec.im_p_opt_total_cont_inc            :=  f_im_p_opt_total_cont_inc        ;
    p_fnar_rec.im_p_opt_cash_bank_accounts        :=  f_im_p_opt_cash_bank_accounts    ;
    p_fnar_rec.im_p_opt_home_equity               :=  f_im_p_opt_home_equity           ;
    p_fnar_rec.im_p_opt_ot_rl_est_inv_eq          :=  f_im_p_opt_ot_rl_est_inv_eq      ;
    p_fnar_rec.im_p_opt_adj_bus_farm_worth        :=  f_im_p_opt_adj_bus_farm_worth    ;
    p_fnar_rec.im_p_opt_ass_sibs_pre_tui          :=  f_im_p_opt_ass_sibs_pre_tui      ;
    p_fnar_rec.im_p_opt_net_worth                 :=  f_im_p_opt_net_worth             ;
    p_fnar_rec.im_p_opt_emerg_res_allow           :=  f_im_p_opt_emerg_res_allow       ;
    p_fnar_rec.im_p_opt_cum_ed_savings            :=  f_im_p_opt_cum_ed_savings        ;
    p_fnar_rec.im_p_opt_low_inc_allow             :=  f_im_p_opt_low_inc_allow         ;
    p_fnar_rec.im_p_opt_total_asset_allow         :=  f_im_p_opt_total_asset_allow     ;
    p_fnar_rec.im_p_opt_disc_net_worth            :=  f_im_p_opt_disc_net_worth        ;
    p_fnar_rec.im_p_opt_total_cont_asset          :=  f_im_p_opt_total_cont_asset      ;
    p_fnar_rec.im_p_opt_total_cont                :=  f_im_p_opt_total_cont            ;
    p_fnar_rec.im_p_opt_num_in_coll_adj           :=  f_im_p_opt_num_in_coll_adj       ;
    p_fnar_rec.im_p_opt_cont_for_stu              :=  f_im_p_opt_cont_for_stu          ;
    p_fnar_rec.im_p_opt_cont_from_income          :=  f_im_p_opt_cont_from_income      ;
    p_fnar_rec.im_p_opt_cont_from_assets          :=  f_im_p_opt_cont_from_assets      ;
    p_fnar_rec.fm_p_analysis_type                 :=  f_fm_p_analysis_type             ;
    p_fnar_rec.fm_p_agi_taxable_income            :=  f_fm_p_agi_taxable_income        ;
    p_fnar_rec.fm_p_untx_inc_and_ben              :=  f_fm_p_untx_inc_and_ben          ;
    p_fnar_rec.fm_p_inc_adj                       :=  f_fm_p_inc_adj                   ;
    p_fnar_rec.fm_p_total_income                  :=  f_fm_p_total_income              ;
    p_fnar_rec.fm_p_us_income_tax                 :=  f_fm_p_us_income_tax             ;
    p_fnar_rec.fm_p_state_and_other_taxes         :=  f_fm_p_state_and_other_taxes     ;
    p_fnar_rec.fm_p_fica_tax                      :=  f_fm_p_fica_tax                  ;
    p_fnar_rec.fm_p_employment_allow              :=  f_fm_p_employment_allow          ;
    p_fnar_rec.fm_p_income_prot_allow             :=  f_fm_p_income_prot_allow         ;
    p_fnar_rec.fm_p_total_allow                   :=  f_fm_p_total_allow               ;
    p_fnar_rec.fm_p_avail_income                  :=  f_fm_p_avail_income              ;
    p_fnar_rec.fm_p_cash_bank_accounts            :=  f_fm_p_cash_bank_accounts        ;
    p_fnar_rec.fm_p_ot_rl_est_inv_equity          :=  f_fm_p_ot_rl_est_inv_equity      ;
    p_fnar_rec.fm_p_adj_bus_farm_net_worth        :=  f_fm_p_adj_bus_farm_net_worth    ;
    p_fnar_rec.fm_p_net_worth                     :=  f_fm_p_net_worth                 ;
    p_fnar_rec.fm_p_asset_prot_allow              :=  f_fm_p_asset_prot_allow          ;
    p_fnar_rec.fm_p_disc_net_worth                :=  f_fm_p_disc_net_worth            ;
    p_fnar_rec.fm_p_total_contribution            :=  f_fm_p_total_contribution        ;
    p_fnar_rec.fm_p_num_in_coll                   :=  f_fm_p_num_in_coll               ;
    p_fnar_rec.fm_p_cont_for_stu                  :=  f_fm_p_cont_for_stu              ;
    p_fnar_rec.fm_p_cont_from_income              :=  f_fm_p_cont_from_income          ;
    p_fnar_rec.fm_p_cont_from_assets              :=  f_fm_p_cont_from_assets          ;
    p_fnar_rec.im_s_bas_agi_taxable_income        :=  f_im_s_bas_agi_taxable_income    ;
    p_fnar_rec.im_s_bas_untx_inc_and_ben          :=  f_im_s_bas_untx_inc_and_ben      ;
    p_fnar_rec.im_s_bas_inc_adj                   :=  f_im_s_bas_inc_adj               ;
    p_fnar_rec.im_s_bas_total_income              :=  f_im_s_bas_total_income          ;
    p_fnar_rec.im_s_bas_us_income_tax             :=  f_im_s_bas_us_income_tax         ;
    p_fnar_rec.im_s_bas_state_and_oth_taxes       :=  f_im_s_bas_state_and_oth_taxes   ;
    p_fnar_rec.im_s_bas_fica_tax                  :=  f_im_s_bas_fica_tax              ;
    p_fnar_rec.im_s_bas_med_dental                :=  f_im_s_bas_med_dental            ;
    p_fnar_rec.im_s_bas_employment_allow          :=  f_im_s_bas_employment_allow      ;
    p_fnar_rec.im_s_bas_annual_ed_savings         :=  f_im_s_bas_annual_ed_savings     ;
    p_fnar_rec.im_s_bas_inc_prot_allow_m          :=  f_im_s_bas_inc_prot_allow_m      ;
    p_fnar_rec.im_s_bas_total_inc_allow           :=  f_im_s_bas_total_inc_allow       ;
    p_fnar_rec.im_s_bas_cal_avail_income          :=  f_im_s_bas_cal_avail_income      ;
    p_fnar_rec.im_s_bas_avail_income              :=  f_im_s_bas_avail_income          ;
    p_fnar_rec.im_s_bas_total_cont_inc            :=  f_im_s_bas_total_cont_inc        ;
    p_fnar_rec.im_s_bas_cash_bank_accounts        :=  f_im_s_bas_cash_bank_accounts    ;
    p_fnar_rec.im_s_bas_home_equity               :=  f_im_s_bas_home_equity           ;
    p_fnar_rec.im_s_bas_ot_rl_est_inv_eq          :=  f_im_s_bas_ot_rl_est_inv_eq      ;
    p_fnar_rec.im_s_bas_adj_busfarm_worth         :=  f_im_s_bas_adj_busfarm_worth     ;
    p_fnar_rec.im_s_bas_trusts                    :=  f_im_s_bas_trusts                ;
    p_fnar_rec.im_s_bas_net_worth                 :=  f_im_s_bas_net_worth             ;
    p_fnar_rec.im_s_bas_emerg_res_allow           :=  f_im_s_bas_emerg_res_allow       ;
    p_fnar_rec.im_s_bas_cum_ed_savings            :=  f_im_s_bas_cum_ed_savings        ;
    p_fnar_rec.im_s_bas_total_asset_allow         :=  f_im_s_bas_total_asset_allow     ;
    p_fnar_rec.im_s_bas_disc_net_worth            :=  f_im_s_bas_disc_net_worth        ;
    p_fnar_rec.im_s_bas_total_cont_asset          :=  f_im_s_bas_total_cont_asset      ;
    p_fnar_rec.im_s_bas_total_cont                :=  f_im_s_bas_total_cont            ;
    p_fnar_rec.im_s_bas_num_in_coll_adj           :=  f_im_s_bas_num_in_coll_adj       ;
    p_fnar_rec.im_s_bas_cont_for_stu              :=  f_im_s_bas_cont_for_stu          ;
    p_fnar_rec.im_s_bas_cont_from_income          :=  f_im_s_bas_cont_from_income      ;
    p_fnar_rec.im_s_bas_cont_from_assets          :=  f_im_s_bas_cont_from_assets      ;
    p_fnar_rec.im_s_est_agitaxable_income         :=  f_im_s_est_agitaxable_income     ;
    p_fnar_rec.im_s_est_untx_inc_and_ben          :=  f_im_s_est_untx_inc_and_ben      ;
    p_fnar_rec.im_s_est_inc_adj                   :=  f_im_s_est_inc_adj               ;
    p_fnar_rec.im_s_est_total_income              :=  f_im_s_est_total_income          ;
    p_fnar_rec.im_s_est_us_income_tax             :=  f_im_s_est_us_income_tax         ;
    p_fnar_rec.im_s_est_state_and_oth_taxes       :=  f_im_s_est_state_and_oth_taxes   ;
    p_fnar_rec.im_s_est_fica_tax                  :=  f_im_s_est_fica_tax              ;
    p_fnar_rec.im_s_est_med_dental                :=  f_im_s_est_med_dental            ;
    p_fnar_rec.im_s_est_employment_allow          :=  f_im_s_est_employment_allow      ;
    p_fnar_rec.im_s_est_annual_ed_savings         :=  f_im_s_est_annual_ed_savings     ;
    p_fnar_rec.im_s_est_inc_prot_allow_m          :=  f_im_s_est_inc_prot_allow_m      ;
    p_fnar_rec.im_s_est_total_inc_allow           :=  f_im_s_est_total_inc_allow       ;
    p_fnar_rec.im_s_est_cal_avail_income          :=  f_im_s_est_cal_avail_income      ;
    p_fnar_rec.im_s_est_avail_income              :=  f_im_s_est_avail_income          ;
    p_fnar_rec.im_s_est_total_cont_inc            :=  f_im_s_est_total_cont_inc        ;
    p_fnar_rec.im_s_est_cash_bank_accounts        :=  f_im_s_est_cash_bank_accounts    ;
    p_fnar_rec.im_s_est_home_equity               :=  f_im_s_est_home_equity           ;
    p_fnar_rec.im_s_est_ot_rl_est_inv_eq          :=  f_im_s_est_ot_rl_est_inv_eq      ;
    p_fnar_rec.im_s_est_adj_bus_farm_worth        :=  f_im_s_est_adj_bus_farm_worth    ;
    p_fnar_rec.im_s_est_est_trusts                :=  f_im_s_est_est_trusts            ;
    p_fnar_rec.im_s_est_net_worth                 :=  f_im_s_est_net_worth             ;
    p_fnar_rec.im_s_est_emerg_res_allow           :=  f_im_s_est_emerg_res_allow       ;
    p_fnar_rec.im_s_est_cum_ed_savings            :=  f_im_s_est_cum_ed_savings        ;
    p_fnar_rec.im_s_est_total_asset_allow         :=  f_im_s_est_total_asset_allow     ;
    p_fnar_rec.im_s_est_disc_net_worth            :=  f_im_s_est_disc_net_worth        ;
    p_fnar_rec.im_s_est_total_cont_asset          :=  f_im_s_est_total_cont_asset      ;
    p_fnar_rec.im_s_est_total_cont                :=  f_im_s_est_total_cont            ;
    p_fnar_rec.im_s_est_num_in_coll_adj           :=  f_im_s_est_num_in_coll_adj       ;
    p_fnar_rec.im_s_est_cont_for_stu              :=  f_im_s_est_cont_for_stu          ;
    p_fnar_rec.im_s_est_cont_from_income          :=  f_im_s_est_cont_from_income      ;
    p_fnar_rec.im_s_est_cont_from_assets          :=  f_im_s_est_cont_from_assets      ;
    p_fnar_rec.im_s_opt_agi_taxable_income        :=  f_im_s_opt_agi_taxable_income    ;
    p_fnar_rec.im_s_opt_untx_inc_and_ben          :=  f_im_s_opt_untx_inc_and_ben      ;
    p_fnar_rec.im_s_opt_inc_adj                   :=  f_im_s_opt_inc_adj               ;
    p_fnar_rec.im_s_opt_total_income              :=  f_im_s_opt_total_income          ;
    p_fnar_rec.im_s_opt_us_income_tax             :=  f_im_s_opt_us_income_tax         ;
    p_fnar_rec.im_s_opt_state_and_oth_taxes       :=  f_im_s_opt_state_and_oth_taxes   ;
    p_fnar_rec.im_s_opt_fica_tax                  :=  f_im_s_opt_fica_tax              ;
    p_fnar_rec.im_s_opt_med_dental                :=  f_im_s_opt_med_dental            ;
    p_fnar_rec.im_s_opt_employment_allow          :=  f_im_s_opt_employment_allow      ;
    p_fnar_rec.im_s_opt_annual_ed_savings         :=  f_im_s_opt_annual_ed_savings     ;
    p_fnar_rec.im_s_opt_inc_prot_allow_m          :=  f_im_s_opt_inc_prot_allow_m      ;
    p_fnar_rec.im_s_opt_total_inc_allow           :=  f_im_s_opt_total_inc_allow       ;
    p_fnar_rec.im_s_opt_cal_avail_income          :=  f_im_s_opt_cal_avail_income      ;
    p_fnar_rec.im_s_opt_avail_income              :=  f_im_s_opt_avail_income          ;
    p_fnar_rec.im_s_opt_total_cont_inc            :=  f_im_s_opt_total_cont_inc        ;
    p_fnar_rec.im_s_opt_cash_bank_accounts        :=  f_im_s_opt_cash_bank_accounts    ;
    p_fnar_rec.im_s_opt_ira_keogh_accounts        :=  f_im_s_opt_ira_keogh_accounts    ;
    p_fnar_rec.im_s_opt_home_equity               :=  f_im_s_opt_home_equity           ;
    p_fnar_rec.im_s_opt_ot_rl_est_inv_eq          :=  f_im_s_opt_ot_rl_est_inv_eq      ;
    p_fnar_rec.im_s_opt_adj_bus_farm_worth        :=  f_im_s_opt_adj_bus_farm_worth    ;
    p_fnar_rec.im_s_opt_trusts                    :=  f_im_s_opt_trusts                ;
    p_fnar_rec.im_s_opt_net_worth                 :=  f_im_s_opt_net_worth             ;
    p_fnar_rec.im_s_opt_emerg_res_allow           :=  f_im_s_opt_emerg_res_allow       ;
    p_fnar_rec.im_s_opt_cum_ed_savings            :=  f_im_s_opt_cum_ed_savings        ;
    p_fnar_rec.im_s_opt_total_asset_allow         :=  f_im_s_opt_total_asset_allow     ;
    p_fnar_rec.im_s_opt_disc_net_worth            :=  f_im_s_opt_disc_net_worth        ;
    p_fnar_rec.im_s_opt_total_cont_asset          :=  f_im_s_opt_total_cont_asset      ;
    p_fnar_rec.im_s_opt_total_cont                :=  f_im_s_opt_total_cont            ;
    p_fnar_rec.im_s_opt_num_in_coll_adj           :=  f_im_s_opt_num_in_coll_adj       ;
    p_fnar_rec.im_s_opt_cont_for_stu              :=  f_im_s_opt_cont_for_stu          ;
    p_fnar_rec.im_s_opt_cont_from_income          :=  f_im_s_opt_cont_from_income      ;
    p_fnar_rec.im_s_opt_cont_from_assets          :=  f_im_s_opt_cont_from_assets      ;
    p_fnar_rec.fm_s_analysis_type                 :=  f_fm_s_analysis_type             ;
    p_fnar_rec.fm_s_agi_taxable_income            :=  f_fm_s_agi_taxable_income        ;
    p_fnar_rec.fm_s_untx_inc_and_ben              :=  f_fm_s_untx_inc_and_ben          ;
    p_fnar_rec.fm_s_inc_adj                       :=  f_fm_s_inc_adj                   ;
    p_fnar_rec.fm_s_total_income                  :=  f_fm_s_total_income              ;
    p_fnar_rec.fm_s_us_income_tax                 :=  f_fm_s_us_income_tax             ;
    p_fnar_rec.fm_s_state_and_oth_taxes           :=  f_fm_s_state_and_oth_taxes       ;
    p_fnar_rec.fm_s_fica_tax                      :=  f_fm_s_fica_tax                  ;
    p_fnar_rec.fm_s_employment_allow              :=  f_fm_s_employment_allow          ;
    p_fnar_rec.fm_s_income_prot_allow             :=  f_fm_s_income_prot_allow         ;
    p_fnar_rec.fm_s_total_allow                   :=  f_fm_s_total_allow               ;
    p_fnar_rec.fm_s_cal_avail_income              :=  f_fm_s_cal_avail_income          ;
    p_fnar_rec.fm_s_avail_income                  :=  f_fm_s_avail_income              ;
    p_fnar_rec.fm_s_cash_bank_accounts            :=  f_fm_s_cash_bank_accounts        ;
    p_fnar_rec.fm_s_ot_rl_est_inv_equity          :=  f_fm_s_ot_rl_est_inv_equity      ;
    p_fnar_rec.fm_s_adj_bus_farm_worth            :=  f_fm_s_adj_bus_farm_worth        ;
    p_fnar_rec.fm_s_trusts                        :=  f_fm_s_trusts                    ;
    p_fnar_rec.fm_s_net_worth                     :=  f_fm_s_net_worth                 ;
    p_fnar_rec.fm_s_asset_prot_allow              :=  f_fm_s_asset_prot_allow          ;
    p_fnar_rec.fm_s_disc_net_worth                :=  f_fm_s_disc_net_worth            ;
    p_fnar_rec.fm_s_total_cont                    :=  f_fm_s_total_cont                ;
    p_fnar_rec.fm_s_num_in_coll                   :=  f_fm_s_num_in_coll               ;
    p_fnar_rec.fm_s_cont_for_stu                  :=  f_fm_s_cont_for_stu              ;
    p_fnar_rec.fm_s_cont_from_income              :=  f_fm_s_cont_from_income          ;
    p_fnar_rec.fm_s_cont_from_assets              :=  f_fm_s_cont_from_assets          ;
    p_fnar_rec.im_inst_resident_ind               :=  f_im_inst_resident_ind           ;
    p_fnar_rec.institutional_1_budget_name        :=  f_institutional_1_budget_name    ;
    p_fnar_rec.im_inst_1_budget_duration          :=  f_im_inst_1_budget_duration      ;
    p_fnar_rec.im_inst_1_tuition_fees             :=  f_im_inst_1_tuition_fees         ;
    p_fnar_rec.im_inst_1_books_supplies           :=  f_im_inst_1_books_supplies       ;
    p_fnar_rec.im_inst_1_living_expenses          :=  f_im_inst_1_living_expenses      ;
    p_fnar_rec.im_inst_1_tot_expenses             :=  f_im_inst_1_tot_expenses         ;
    p_fnar_rec.im_inst_1_tot_stu_cont             :=  f_im_inst_1_tot_stu_cont         ;
    p_fnar_rec.im_inst_1_tot_par_cont             :=  f_im_inst_1_tot_par_cont         ;
    p_fnar_rec.im_inst_1_tot_family_cont          :=  f_im_inst_1_tot_family_cont      ;
    p_fnar_rec.im_inst_1_va_benefits              :=  f_im_inst_1_va_benefits          ;
    p_fnar_rec.im_inst_1_ot_cont                  :=  f_im_inst_1_ot_cont              ;
    p_fnar_rec.im_inst_1_est_financial_need       :=  f_im_inst_1_est_financial_need   ;
    p_fnar_rec.institutional_2_budget_name        :=  f_institutional_2_budget_name    ;
    p_fnar_rec.im_inst_2_budget_duration          :=  f_im_inst_2_budget_duration      ;
    p_fnar_rec.im_inst_2_tuition_fees             :=  f_im_inst_2_tuition_fees         ;
    p_fnar_rec.im_inst_2_books_supplies           :=  f_im_inst_2_books_supplies       ;
    p_fnar_rec.im_inst_2_living_expenses          :=  f_im_inst_2_living_expenses      ;
    p_fnar_rec.im_inst_2_tot_expenses             :=  f_im_inst_2_tot_expenses         ;
    p_fnar_rec.im_inst_2_tot_stu_cont             :=  f_im_inst_2_tot_stu_cont         ;
    p_fnar_rec.im_inst_2_tot_par_cont             :=  f_im_inst_2_tot_par_cont         ;
    p_fnar_rec.im_inst_2_tot_family_cont          :=  f_im_inst_2_tot_family_cont      ;
    p_fnar_rec.im_inst_2_va_benefits              :=  f_im_inst_2_va_benefits          ;
    p_fnar_rec.im_inst_2_est_financial_need       :=  f_im_inst_2_est_financial_need   ;
    p_fnar_rec.institutional_3_budget_name        :=  f_institutional_3_budget_name    ;
    p_fnar_rec.im_inst_3_budget_duration          :=  f_im_inst_3_budget_duration      ;
    p_fnar_rec.im_inst_3_tuition_fees             :=  f_im_inst_3_tuition_fees         ;
    p_fnar_rec.im_inst_3_books_supplies           :=  f_im_inst_3_books_supplies       ;
    p_fnar_rec.im_inst_3_living_expenses          :=  f_im_inst_3_living_expenses      ;
    p_fnar_rec.im_inst_3_tot_expenses             :=  f_im_inst_3_tot_expenses         ;
    p_fnar_rec.im_inst_3_tot_stu_cont             :=  f_im_inst_3_tot_stu_cont         ;
    p_fnar_rec.im_inst_3_tot_par_cont             :=  f_im_inst_3_tot_par_cont         ;
    p_fnar_rec.im_inst_3_tot_family_cont          :=  f_im_inst_3_tot_family_cont      ;
    p_fnar_rec.im_inst_3_va_benefits              :=  f_im_inst_3_va_benefits          ;
    p_fnar_rec.im_inst_3_est_financial_need       :=  f_im_inst_3_est_financial_need   ;
    p_fnar_rec.fm_inst_1_federal_efc              :=  f_fm_inst_1_federal_efc          ;
    p_fnar_rec.fm_inst_1_va_benefits              :=  f_fm_inst_1_va_benefits          ;
    p_fnar_rec.fm_inst_1_fed_eligibility          :=  f_fm_inst_1_fed_eligibility      ;
    p_fnar_rec.fm_inst_1_pell                     :=  f_fm_inst_1_pell                 ;
    p_fnar_rec.option_par_loss_allow_ind          :=  f_option_par_loss_allow_ind      ;
    p_fnar_rec.option_par_tuition_ind             :=  f_option_par_tuition_ind         ;
    p_fnar_rec.option_par_home_ind                :=  f_option_par_home_ind            ;
    p_fnar_rec.option_par_home_value              :=  f_option_par_home_value          ;
    p_fnar_rec.option_par_home_debt               :=  f_option_par_home_debt           ;
    p_fnar_rec.option_stu_ira_keogh_ind           :=  f_option_stu_ira_keogh_ind       ;
    p_fnar_rec.option_stu_home_ind                :=  f_option_stu_home_ind            ;
    p_fnar_rec.option_stu_home_value              :=  f_option_stu_home_value          ;
    p_fnar_rec.option_stu_home_debt               :=  f_option_stu_home_debt           ;
    p_fnar_rec.option_stu_sum_ay_inc_ind          :=  f_option_stu_sum_ay_inc_ind      ;
    p_fnar_rec.option_par_hope_ll_credit          :=  f_option_par_hope_ll_credit      ;
    p_fnar_rec.option_stu_hope_ll_credit          :=  f_option_stu_hope_ll_credit      ;
    p_fnar_rec.option_par_cola_adj_ind            :=  f_option_par_cola_adj_ind        ;
    p_fnar_rec.option_par_stu_fa_assets_ind       :=  f_option_par_stu_fa_assets_ind   ;
    p_fnar_rec.option_par_ipt_assets_ind          :=  f_option_par_ipt_assets_ind      ;
    p_fnar_rec.option_stu_ipt_assets_ind          :=  f_option_stu_ipt_assets_ind      ;
    p_fnar_rec.option_par_cola_adj_value          :=  f_option_par_cola_adj_value      ;
    p_fnar_rec.im_parent_1_8_months_bas           :=  f_im_parent_1_8_months_bas       ;
    p_fnar_rec.im_p_more_than_9_mth_ba            :=  f_im_p_more_than_9_mth_ba        ;
    p_fnar_rec.im_parent_1_8_months_opt           :=  f_im_parent_1_8_months_opt       ;
    p_fnar_rec.im_p_more_than_9_mth_op            :=  f_im_p_more_than_9_mth_op        ;
    p_fnar_rec.fnar_message_1                     :=  f_fnar_message_1                 ;
    p_fnar_rec.fnar_message_2                     :=  f_fnar_message_2                 ;
    p_fnar_rec.fnar_message_3                     :=  f_fnar_message_3                 ;
    p_fnar_rec.fnar_message_4                     :=  f_fnar_message_4                 ;
    p_fnar_rec.fnar_message_5                     :=  f_fnar_message_5                 ;
    p_fnar_rec.fnar_message_6                     :=  f_fnar_message_6                 ;
    p_fnar_rec.fnar_message_7                     :=  f_fnar_message_7                 ;
    p_fnar_rec.fnar_message_8                     :=  f_fnar_message_8                 ;
    p_fnar_rec.fnar_message_9                     :=  f_fnar_message_9                 ;
    p_fnar_rec.fnar_message_10                    :=  f_fnar_message_10                ;
    p_fnar_rec.fnar_message_11                    :=  f_fnar_message_11                ;
    p_fnar_rec.fnar_message_12                    :=  f_fnar_message_12                ;
    p_fnar_rec.fnar_message_13                    :=  f_fnar_message_13                ;
    p_fnar_rec.fnar_message_20                    :=  f_fnar_message_20                ;
    p_fnar_rec.fnar_message_21                    :=  f_fnar_message_21                ;
    p_fnar_rec.fnar_message_22                    :=  f_fnar_message_22                ;
    p_fnar_rec.fnar_message_23                    :=  f_fnar_message_23                ;
    p_fnar_rec.fnar_message_24                    :=  f_fnar_message_24                ;
    p_fnar_rec.fnar_message_25                    :=  f_fnar_message_25                ;
    p_fnar_rec.fnar_message_26                    :=  f_fnar_message_26                ;
    p_fnar_rec.fnar_message_27                    :=  f_fnar_message_27                ;
    p_fnar_rec.fnar_message_30                    :=  f_fnar_message_30                ;
    p_fnar_rec.fnar_message_31                    :=  f_fnar_message_31                ;
    p_fnar_rec.fnar_message_32                    :=  f_fnar_message_32                ;
    p_fnar_rec.fnar_message_33                    :=  f_fnar_message_33                ;
    p_fnar_rec.fnar_message_34                    :=  f_fnar_message_34                ;
    p_fnar_rec.fnar_message_35                    :=  f_fnar_message_35                ;
    p_fnar_rec.fnar_message_36                    :=  f_fnar_message_36                ;
    p_fnar_rec.fnar_message_37                    :=  f_fnar_message_37                ;
    p_fnar_rec.fnar_message_38                    :=  f_fnar_message_38                ;
    p_fnar_rec.fnar_message_39                    :=  f_fnar_message_39                ;
    p_fnar_rec.fnar_message_45                    :=  f_fnar_message_45                ;
    p_fnar_rec.fnar_message_46                    :=  f_fnar_message_46                ;
    p_fnar_rec.fnar_message_47                    :=  f_fnar_message_47                ;
    p_fnar_rec.fnar_message_48                    :=  f_fnar_message_48                ;
    p_fnar_rec.fnar_message_49                    :=  f_fnar_message_49                ;
    p_fnar_rec.fnar_message_50                    :=  f_fnar_message_50                ;
    p_fnar_rec.fnar_message_51                    :=  f_fnar_message_51                ;
    p_fnar_rec.fnar_message_52                    :=  f_fnar_message_52                ;
    p_fnar_rec.fnar_message_53                    :=  f_fnar_message_53                ;
    p_fnar_rec.fnar_message_55                    :=  f_fnar_message_55                ;
    p_fnar_rec.fnar_message_56                    :=  f_fnar_message_56                ;
    p_fnar_rec.fnar_message_57                    :=  f_fnar_message_57                ;
    p_fnar_rec.fnar_message_58                    :=  f_fnar_message_58                ;
    p_fnar_rec.fnar_message_59                    :=  f_fnar_message_59                ;
    p_fnar_rec.fnar_message_60                    :=  f_fnar_message_60                ;
    p_fnar_rec.fnar_message_61                    :=  f_fnar_message_61                ;
    p_fnar_rec.fnar_message_62                    :=  f_fnar_message_62                ;
    p_fnar_rec.fnar_message_63                    :=  f_fnar_message_63                ;
    p_fnar_rec.fnar_message_64                    :=  f_fnar_message_64                ;
    p_fnar_rec.fnar_message_65                    :=  f_fnar_message_65                ;
    p_fnar_rec.fnar_message_71                    :=  f_fnar_message_71                ;
    p_fnar_rec.fnar_message_72                    :=  f_fnar_message_72                ;
    p_fnar_rec.fnar_message_73                    :=  f_fnar_message_73                ;
    p_fnar_rec.fnar_message_74                    :=  f_fnar_message_74                ;
    p_fnar_rec.fnar_message_75                    :=  f_fnar_message_75                ;
    p_fnar_rec.fnar_message_76                    :=  f_fnar_message_76                ;
    p_fnar_rec.fnar_message_77                    :=  f_fnar_message_77                ;
    p_fnar_rec.fnar_message_78                    :=  f_fnar_message_78                ;
    p_fnar_rec.fnar_mesg_10_stu_fam_mem           :=  f_fnar_mesg_10_stu_fam_mem       ;
    p_fnar_rec.fnar_mesg_11_stu_no_in_coll        :=  f_fnar_mesg_11_stu_no_in_coll    ;
    p_fnar_rec.fnar_mesg_24_stu_avail_inc         :=  f_fnar_mesg_24_stu_avail_inc     ;
    p_fnar_rec.fnar_mesg_26_stu_taxes             :=  f_fnar_mesg_26_stu_taxes         ;
    p_fnar_rec.fnar_mesg_33_stu_home_value        :=  f_fnar_mesg_33_stu_home_value    ;
    p_fnar_rec.fnar_mesg_34_stu_home_value        :=  f_fnar_mesg_34_stu_home_value    ;
    p_fnar_rec.fnar_mesg_34_stu_home_equity       :=  f_fnar_mesg_34_stu_home_equity   ;
    p_fnar_rec.fnar_mesg_35_stu_home_value        :=  f_fnar_mesg_35_stu_home_value    ;
    p_fnar_rec.fnar_mesg_35_stu_home_equity       :=  f_fnar_mesg_35_stu_home_equity   ;
    p_fnar_rec.fnar_mesg_36_stu_home_equity       :=  f_fnar_mesg_36_stu_home_equity   ;
    p_fnar_rec.fnar_mesg_48_par_fam_mem           :=  f_fnar_mesg_48_par_fam_mem       ;
    p_fnar_rec.fnar_mesg_49_par_no_in_coll        :=  f_fnar_mesg_49_par_no_in_coll    ;
    p_fnar_rec.fnar_mesg_56_par_agi               :=  f_fnar_mesg_56_par_agi           ;
    p_fnar_rec.fnar_mesg_62_par_taxes             :=  f_fnar_mesg_62_par_taxes         ;
    p_fnar_rec.fnar_mesg_73_par_home_value        :=  f_fnar_mesg_73_par_home_value    ;
    p_fnar_rec.fnar_mesg_74_par_home_value        :=  f_fnar_mesg_74_par_home_value    ;
    p_fnar_rec.fnar_mesg_74_par_home_equity       :=  f_fnar_mesg_74_par_home_equity   ;
    p_fnar_rec.fnar_mesg_75_par_home_value        :=  f_fnar_mesg_75_par_home_value    ;
    p_fnar_rec.fnar_mesg_75_par_home_equity       :=  f_fnar_mesg_75_par_home_equity   ;
    p_fnar_rec.fnar_mesg_76_par_home_equity       :=  f_fnar_mesg_76_par_home_equity   ;
    p_fnar_rec.assumption_message_1               :=  f_assumption_message_1           ;
    p_fnar_rec.assumption_message_2               :=  f_assumption_message_2           ;
    p_fnar_rec.assumption_message_3               :=  f_assumption_message_3           ;
    p_fnar_rec.assumption_message_4               :=  f_assumption_message_4           ;
    p_fnar_rec.assumption_message_5               :=  f_assumption_message_5           ;
    p_fnar_rec.assumption_message_6               :=  f_assumption_message_6           ;
    p_fnar_rec.record_mark                        :=  f_record_mark                    ;
    p_fnar_rec.legacy_record_flag                 :=  f_legacy_record_flag             ;
    p_fnar_rec.creation_date                      :=  f_creation_date                  ;
    p_fnar_rec.created_by                         :=  f_created_by                     ;
    p_fnar_rec.last_updated_by                    :=  f_last_updated_by                ;
    p_fnar_rec.last_update_date                   :=  f_last_update_date               ;
    p_fnar_rec.last_update_login                  :=  f_last_update_login              ;
    p_fnar_rec.option_ind_stu_ipt_assets_flag     :=  f_opt_ind_stu_ipt_assets_flag    ;
    p_fnar_rec.cust_parent_cont_adj_num           :=  f_cust_parent_cont_adj_num       ;
    p_fnar_rec.custodial_parent_num               :=  f_custodial_parent_num           ;
    p_fnar_rec.cust_par_base_prcnt_inc_amt        :=  f_cust_par_base_prcnt_inc_amt    ;
    p_fnar_rec.cust_par_base_cont_inc_amt         :=  f_cust_par_base_cont_inc_amt     ;
    p_fnar_rec.cust_par_base_cont_ast_amt         :=  f_cust_par_base_cont_ast_amt     ;
    p_fnar_rec.cust_par_base_tot_cont_amt         :=  f_cust_par_base_tot_cont_amt     ;
    p_fnar_rec.cust_par_opt_prcnt_inc_amt         :=  f_cust_par_opt_prcnt_inc_amt     ;
    p_fnar_rec.cust_par_opt_cont_inc_amt          :=  f_cust_par_opt_cont_inc_amt      ;
    p_fnar_rec.cust_par_opt_cont_ast_amt          :=  f_cust_par_opt_cont_ast_amt      ;
    p_fnar_rec.cust_par_opt_tot_cont_amt          :=  f_cust_par_opt_tot_cont_amt      ;
    p_fnar_rec.parents_email_txt                  :=  f_parents_email_txt              ;
    p_fnar_rec.parent_1_birth_date                :=  f_parent_1_birth_date            ;
    p_fnar_rec.parent_2_birth_date                :=  f_parent_2_birth_date            ;

    p_user_hook := igf_ap_uhk_inas_pkg.get_im_efc(p_sys_awd_year, p_profile_rec, p_fnar_rec, p_err_mesg);


    pr_cssp_id                        :=  p_profile_rec.cssp_id                         ;
    pr_base_id                        :=  p_profile_rec.base_id                         ;
    pr_system_record_type             :=  p_profile_rec.system_record_type              ;
    pr_active_profile                 :=  p_profile_rec.active_profile                  ;
    pr_college_code                   :=  p_profile_rec.college_code                    ;
    pr_academic_year                  :=  p_profile_rec.academic_year                   ;
    pr_stu_record_type                :=  p_profile_rec.stu_record_type                 ;
    pr_css_id_number                  :=  p_profile_rec.css_id_number                   ;
    pr_registration_receipt_date      :=  p_profile_rec.registration_receipt_date       ;
    pr_registration_type              :=  p_profile_rec.registration_type               ;
    pr_application_receipt_date       :=  p_profile_rec.application_receipt_date        ;
    pr_application_type               :=  p_profile_rec.application_type                ;
    pr_original_fnar_compute          :=  p_profile_rec.original_fnar_compute           ;
    pr_revision_fnar_compute_date     :=  p_profile_rec.revision_fnar_compute_date      ;
    pr_electronic_extract_date        :=  p_profile_rec.electronic_extract_date         ;
    pr_inst_reporting_type            :=  p_profile_rec.institutional_reporting_type    ;
    pr_asr_receipt_date               :=  p_profile_rec.asr_receipt_date                ;
    pr_last_name                      :=  p_profile_rec.last_name                       ;
    pr_first_name                     :=  p_profile_rec.first_name                      ;
    pr_middle_initial                 :=  p_profile_rec.middle_initial                  ;
    pr_address_number_and_street      :=  p_profile_rec.address_number_and_street       ;
    pr_city                           :=  p_profile_rec.city                            ;
    pr_state_mailing                  :=  p_profile_rec.state_mailing                   ;
    pr_zip_code                       :=  p_profile_rec.zip_code                        ;
    pr_s_telephone_number             :=  p_profile_rec.s_telephone_number              ;
    pr_s_title                        :=  p_profile_rec.s_title                         ;
    pr_date_of_birth                  :=  p_profile_rec.date_of_birth                   ;
    pr_social_security_number         :=  p_profile_rec.social_security_number          ;
    pr_state_legal_residence          :=  p_profile_rec.state_legal_residence           ;
    pr_foreign_address_indicator      :=  p_profile_rec.foreign_address_indicator       ;
    pr_foreign_postal_code            :=  p_profile_rec.foreign_postal_code             ;
    pr_country                        :=  p_profile_rec.country                         ;
    pr_financial_aid_status           :=  p_profile_rec.financial_aid_status            ;
    pr_year_in_college                :=  p_profile_rec.year_in_college                 ;
    pr_marital_status                 :=  p_profile_rec.marital_status                  ;
    pr_ward_court                     :=  p_profile_rec.ward_court                      ;
    pr_legal_dependents_other         :=  p_profile_rec.legal_dependents_other          ;
    pr_household_size                 :=  p_profile_rec.household_size                  ;
    pr_number_in_college              :=  p_profile_rec.number_in_college               ;
    pr_citizenship_status             :=  p_profile_rec.citizenship_status              ;
    pr_citizenship_country            :=  p_profile_rec.citizenship_country             ;
    pr_visa_classification            :=  p_profile_rec.visa_classification             ;
    pr_tax_figures                    :=  p_profile_rec.tax_figures                     ;
    pr_number_exemptions              :=  p_profile_rec.number_exemptions               ;
    pr_adjusted_gross_inc             :=  p_profile_rec.adjusted_gross_inc              ;
    pr_us_tax_paid                    :=  p_profile_rec.us_tax_paid                     ;
    pr_itemized_deductions            :=  p_profile_rec.itemized_deductions             ;
    pr_stu_income_work                :=  p_profile_rec.stu_income_work                 ;
    pr_spouse_income_work             :=  p_profile_rec.spouse_income_work              ;
    pr_divid_int_inc                  :=  p_profile_rec.divid_int_inc                   ;
    pr_soc_sec_benefits               :=  p_profile_rec.soc_sec_benefits                ;
    pr_welfare_tanf                   :=  p_profile_rec.welfare_tanf                    ;
    pr_child_supp_rcvd                :=  p_profile_rec.child_supp_rcvd                 ;
    pr_earned_income_credit           :=  p_profile_rec.earned_income_credit            ;
    pr_other_untax_income             :=  p_profile_rec.other_untax_income              ;
    pr_tax_stu_aid                    :=  p_profile_rec.tax_stu_aid                     ;
    pr_cash_sav_check                 :=  p_profile_rec.cash_sav_check                  ;
    pr_ira_keogh                      :=  p_profile_rec.ira_keogh                       ;
    pr_invest_value                   :=  p_profile_rec.invest_value                    ;
    pr_invest_debt                    :=  p_profile_rec.invest_debt                     ;
    pr_home_value                     :=  p_profile_rec.home_value                      ;
    pr_home_debt                      :=  p_profile_rec.home_debt                       ;
    pr_oth_real_value                 :=  p_profile_rec.oth_real_value                  ;
    pr_oth_real_debt                  :=  p_profile_rec.oth_real_debt                   ;
    pr_bus_farm_value                 :=  p_profile_rec.bus_farm_value                  ;
    pr_bus_farm_debt                  :=  p_profile_rec.bus_farm_debt                   ;
    pr_live_on_farm                   :=  p_profile_rec.live_on_farm                    ;
    pr_home_purch_price               :=  p_profile_rec.home_purch_price                ;
    pr_hope_ll_credit                 :=  p_profile_rec.hope_ll_credit                  ;
    pr_home_purch_year                :=  p_profile_rec.home_purch_year                 ;
    pr_trust_amount                   :=  p_profile_rec.trust_amount                    ;
    pr_trust_avail                    :=  p_profile_rec.trust_avail                     ;
    pr_trust_estab                    :=  p_profile_rec.trust_estab                     ;
    pr_child_support_paid             :=  p_profile_rec.child_support_paid              ;
    pr_med_dent_expenses              :=  p_profile_rec.med_dent_expenses               ;
    pr_vet_us                         :=  p_profile_rec.vet_us                          ;
    pr_vet_ben_amount                 :=  p_profile_rec.vet_ben_amount                  ;
    pr_vet_ben_months                 :=  p_profile_rec.vet_ben_months                  ;
    pr_stu_summer_wages               :=  p_profile_rec.stu_summer_wages                ;
    pr_stu_school_yr_wages            :=  p_profile_rec.stu_school_yr_wages             ;
    pr_spouse_summer_wages            :=  p_profile_rec.spouse_summer_wages             ;
    pr_spouse_school_yr_wages         :=  p_profile_rec.spouse_school_yr_wages          ;
    pr_summer_other_tax_inc           :=  p_profile_rec.summer_other_tax_inc            ;
    pr_school_yr_other_tax_inc        :=  p_profile_rec.school_yr_other_tax_inc         ;
    pr_summer_untax_inc               :=  p_profile_rec.summer_untax_inc                ;
    pr_school_yr_untax_inc            :=  p_profile_rec.school_yr_untax_inc             ;
    pr_grants_schol_etc               :=  p_profile_rec.grants_schol_etc                ;
    pr_tuit_benefits                  :=  p_profile_rec.tuit_benefits                   ;
    pr_cont_parents                   :=  p_profile_rec.cont_parents                    ;
    pr_cont_relatives                 :=  p_profile_rec.cont_relatives                  ;
    pr_p_siblings_pre_tuit            :=  p_profile_rec.p_siblings_pre_tuit             ;
    pr_p_student_pre_tuit             :=  p_profile_rec.p_student_pre_tuit              ;
    pr_p_household_size               :=  p_profile_rec.p_household_size                ;
    pr_p_number_in_college            :=  p_profile_rec.p_number_in_college             ;
    pr_p_parents_in_college           :=  p_profile_rec.p_parents_in_college            ;
    pr_p_marital_status               :=  p_profile_rec.p_marital_status                ;
    pr_p_state_legal_residence        :=  p_profile_rec.p_state_legal_residence         ;
    pr_p_natural_par_status           :=  p_profile_rec.p_natural_par_status            ;
    pr_p_child_supp_paid              :=  p_profile_rec.p_child_supp_paid               ;
    pr_p_repay_ed_loans               :=  p_profile_rec.p_repay_ed_loans                ;
    pr_p_med_dent_expenses            :=  p_profile_rec.p_med_dent_expenses             ;
    pr_p_tuit_paid_amount             :=  p_profile_rec.p_tuit_paid_amount              ;
    pr_p_tuit_paid_number             :=  p_profile_rec.p_tuit_paid_number              ;
    pr_p_exp_child_supp_paid          :=  p_profile_rec.p_exp_child_supp_paid           ;
    pr_p_exp_repay_ed_loans           :=  p_profile_rec.p_exp_repay_ed_loans            ;
    pr_p_exp_med_dent_expenses        :=  p_profile_rec.p_exp_med_dent_expenses         ;
    pr_p_exp_tuit_pd_amount           :=  p_profile_rec.p_exp_tuit_pd_amount            ;
    pr_p_exp_tuit_pd_number           :=  p_profile_rec.p_exp_tuit_pd_number            ;
    pr_p_cash_sav_check               :=  p_profile_rec.p_cash_sav_check                ;
    pr_p_month_mortgage_pay           :=  p_profile_rec.p_month_mortgage_pay            ;
    pr_p_invest_value                 :=  p_profile_rec.p_invest_value                  ;
    pr_p_invest_debt                  :=  p_profile_rec.p_invest_debt                   ;
    pr_p_home_value                   :=  p_profile_rec.p_home_value                    ;
    pr_p_home_debt                    :=  p_profile_rec.p_home_debt                     ;
    pr_p_home_purch_price             :=  p_profile_rec.p_home_purch_price              ;
    pr_p_own_business_farm            :=  p_profile_rec.p_own_business_farm             ;
    pr_p_business_value               :=  p_profile_rec.p_business_value                ;
    pr_p_business_debt                :=  p_profile_rec.p_business_debt                 ;
    pr_p_farm_value                   :=  p_profile_rec.p_farm_value                    ;
    pr_p_farm_debt                    :=  p_profile_rec.p_farm_debt                     ;
    pr_p_live_on_farm                 :=  p_profile_rec.p_live_on_farm                  ;
    pr_p_oth_real_estate_value        :=  p_profile_rec.p_oth_real_estate_value         ;
    pr_p_oth_real_estate_debt         :=  p_profile_rec.p_oth_real_estate_debt          ;
    pr_p_oth_real_purch_price         :=  p_profile_rec.p_oth_real_purch_price          ;
    pr_p_siblings_assets              :=  p_profile_rec.p_siblings_assets               ;
    pr_p_home_purch_year              :=  p_profile_rec.p_home_purch_year               ;
    pr_p_oth_real_purch_year          :=  p_profile_rec.p_oth_real_purch_year           ;
    pr_p_prior_agi                    :=  p_profile_rec.p_prior_agi                     ;
    pr_p_prior_us_tax_paid            :=  p_profile_rec.p_prior_us_tax_paid             ;
    pr_p_prior_item_deductions        :=  p_profile_rec.p_prior_item_deductions         ;
    pr_p_prior_other_untax_inc        :=  p_profile_rec.p_prior_other_untax_inc         ;
    pr_p_tax_figures                  :=  p_profile_rec.p_tax_figures                   ;
    pr_p_number_exemptions            :=  p_profile_rec.p_number_exemptions             ;
    pr_p_adjusted_gross_inc           :=  p_profile_rec.p_adjusted_gross_inc            ;
    pr_p_wages_sal_tips               :=  p_profile_rec.p_wages_sal_tips                ;
    pr_p_interest_income              :=  p_profile_rec.p_interest_income               ;
    pr_p_dividend_income              :=  p_profile_rec.p_dividend_income               ;
    pr_p_net_inc_bus_farm             :=  p_profile_rec.p_net_inc_bus_farm              ;
    pr_p_other_taxable_income         :=  p_profile_rec.p_other_taxable_income          ;
    pr_p_adj_to_income                :=  p_profile_rec.p_adj_to_income                 ;
    pr_p_us_tax_paid                  :=  p_profile_rec.p_us_tax_paid                   ;
    pr_p_itemized_deductions          :=  p_profile_rec.p_itemized_deductions           ;
    pr_p_father_income_work           :=  p_profile_rec.p_father_income_work            ;
    pr_p_mother_income_work           :=  p_profile_rec.p_mother_income_work            ;
    pr_p_soc_sec_ben                  :=  p_profile_rec.p_soc_sec_ben                   ;
    pr_p_welfare_tanf                 :=  p_profile_rec.p_welfare_tanf                  ;
    pr_p_child_supp_rcvd              :=  p_profile_rec.p_child_supp_rcvd               ;
    pr_p_ded_ira_keogh                :=  p_profile_rec.p_ded_ira_keogh                 ;
    pr_p_tax_defer_pens_savs          :=  p_profile_rec.p_tax_defer_pens_savs           ;
    pr_p_dep_care_med_spending        :=  p_profile_rec.p_dep_care_med_spending         ;
    pr_p_earned_income_credit         :=  p_profile_rec.p_earned_income_credit          ;
    pr_p_living_allow                 :=  p_profile_rec.p_living_allow                  ;
    pr_p_tax_exmpt_int                :=  p_profile_rec.p_tax_exmpt_int                 ;
    pr_p_foreign_inc_excl             :=  p_profile_rec.p_foreign_inc_excl              ;
    pr_p_other_untax_inc              :=  p_profile_rec.p_other_untax_inc               ;
    pr_p_hope_ll_credit               :=  p_profile_rec.p_hope_ll_credit                ;
    pr_p_yr_separation                :=  p_profile_rec.p_yr_separation                 ;
    pr_p_yr_divorce                   :=  p_profile_rec.p_yr_divorce                    ;
    pr_p_exp_father_inc               :=  p_profile_rec.p_exp_father_inc                ;
    pr_p_exp_mother_inc               :=  p_profile_rec.p_exp_mother_inc                ;
    pr_p_exp_other_tax_inc            :=  p_profile_rec.p_exp_other_tax_inc             ;
    pr_p_exp_other_untax_inc          :=  p_profile_rec.p_exp_other_untax_inc           ;
    pr_line_2_relation                :=  p_profile_rec.line_2_relation                 ;
    pr_line_2_attend_college          :=  p_profile_rec.line_2_attend_college           ;
    pr_line_3_relation                :=  p_profile_rec.line_3_relation                 ;
    pr_line_3_attend_college          :=  p_profile_rec.line_3_attend_college           ;
    pr_line_4_relation                :=  p_profile_rec.line_4_relation                 ;
    pr_line_4_attend_college          :=  p_profile_rec.line_4_attend_college           ;
    pr_line_5_relation                :=  p_profile_rec.line_5_relation                 ;
    pr_line_5_attend_college          :=  p_profile_rec.line_5_attend_college           ;
    pr_line_6_relation                :=  p_profile_rec.line_6_relation                 ;
    pr_line_6_attend_college          :=  p_profile_rec.line_6_attend_college           ;
    pr_line_7_relation                :=  p_profile_rec.line_7_relation                 ;
    pr_line_7_attend_college          :=  p_profile_rec.line_7_attend_college           ;
    pr_line_8_relation                :=  p_profile_rec.line_8_relation                 ;
    pr_line_8_attend_college          :=  p_profile_rec.line_8_attend_college           ;
    pr_p_age_father                   :=  p_profile_rec.p_age_father                    ;
    pr_p_age_mother                   :=  p_profile_rec.p_age_mother                    ;
    pr_p_div_sep_ind                  :=  p_profile_rec.p_div_sep_ind                   ;
    pr_b_cont_non_custodial_par       :=  p_profile_rec.b_cont_non_custodial_par        ;
    pr_college_type_2                 :=  p_profile_rec.college_type_2                  ;
    pr_college_type_3                 :=  p_profile_rec.college_type_3                  ;
    pr_college_type_4                 :=  p_profile_rec.college_type_4                  ;
    pr_college_type_5                 :=  p_profile_rec.college_type_5                  ;
    pr_college_type_6                 :=  p_profile_rec.college_type_6                  ;
    pr_college_type_7                 :=  p_profile_rec.college_type_7                  ;
    pr_college_type_8                 :=  p_profile_rec.college_type_8                  ;
    pr_school_code_1                  :=  p_profile_rec.school_code_1                   ;
    pr_housing_code_1                 :=  p_profile_rec.housing_code_1                  ;
    pr_school_code_2                  :=  p_profile_rec.school_code_2                   ;
    pr_housing_code_2                 :=  p_profile_rec.housing_code_2                  ;
    pr_school_code_3                  :=  p_profile_rec.school_code_3                   ;
    pr_housing_code_3                 :=  p_profile_rec.housing_code_3                  ;
    pr_school_code_4                  :=  p_profile_rec.school_code_4                   ;
    pr_housing_code_4                 :=  p_profile_rec.housing_code_4                  ;
    pr_school_code_5                  :=  p_profile_rec.school_code_5                   ;
    pr_housing_code_5                 :=  p_profile_rec.housing_code_5                  ;
    pr_school_code_6                  :=  p_profile_rec.school_code_6                   ;
    pr_housing_code_6                 :=  p_profile_rec.housing_code_6                  ;
    pr_school_code_7                  :=  p_profile_rec.school_code_7                   ;
    pr_housing_code_7                 :=  p_profile_rec.housing_code_7                  ;
    pr_school_code_8                  :=  p_profile_rec.school_code_8                   ;
    pr_housing_code_8                 :=  p_profile_rec.housing_code_8                  ;
    pr_school_code_9                  :=  p_profile_rec.school_code_9                   ;
    pr_housing_code_9                 :=  p_profile_rec.housing_code_9                  ;
    pr_school_code_10                 :=  p_profile_rec.school_code_10                  ;
    pr_housing_code_10                :=  p_profile_rec.housing_code_10                 ;
    pr_additional_school_code_1       :=  p_profile_rec.additional_school_code_1        ;
    pr_additional_school_code_2       :=  p_profile_rec.additional_school_code_2        ;
    pr_additional_school_code_3       :=  p_profile_rec.additional_school_code_3        ;
    pr_additional_school_code_4       :=  p_profile_rec.additional_school_code_4        ;
    pr_additional_school_code_5       :=  p_profile_rec.additional_school_code_5        ;
    pr_additional_school_code_6       :=  p_profile_rec.additional_school_code_6        ;
    pr_additional_school_code_7       :=  p_profile_rec.additional_school_code_7        ;
    pr_additional_school_code_8       :=  p_profile_rec.additional_school_code_8        ;
    pr_additional_school_code_9       :=  p_profile_rec.additional_school_code_9        ;
    pr_additional_school_code_10      :=  p_profile_rec.additional_school_code_10       ;
    pr_explanation_spec_circum        :=  p_profile_rec.explanation_spec_circum         ;
    pr_signature_student              :=  p_profile_rec.signature_student               ;
    pr_signature_spouse               :=  p_profile_rec.signature_spouse                ;
    pr_signature_father               :=  p_profile_rec.signature_father                ;
    pr_signature_mother               :=  p_profile_rec.signature_mother                ;
    pr_month_day_completed            :=  p_profile_rec.month_day_completed             ;
    pr_year_completed                 :=  p_profile_rec.year_completed                  ;
    pr_age_line_2                     :=  p_profile_rec.age_line_2                      ;
    pr_age_line_3                     :=  p_profile_rec.age_line_3                      ;
    pr_age_line_4                     :=  p_profile_rec.age_line_4                      ;
    pr_age_line_5                     :=  p_profile_rec.age_line_5                      ;
    pr_age_line_6                     :=  p_profile_rec.age_line_6                      ;
    pr_age_line_7                     :=  p_profile_rec.age_line_7                      ;
    pr_age_line_8                     :=  p_profile_rec.age_line_8                      ;
    pr_a_online_signature             :=  p_profile_rec.a_online_signature              ;
    pr_question_1_number              :=  p_profile_rec.question_1_number               ;
    pr_question_1_size                :=  p_profile_rec.question_1_size                 ;
    pr_question_1_answer              :=  p_profile_rec.question_1_answer               ;
    pr_question_2_number              :=  p_profile_rec.question_2_number               ;
    pr_question_2_size                :=  p_profile_rec.question_2_size                 ;
    pr_question_2_answer              :=  p_profile_rec.question_2_answer               ;
    pr_question_3_number              :=  p_profile_rec.question_3_number               ;
    pr_question_3_size                :=  p_profile_rec.question_3_size                 ;
    pr_question_3_answer              :=  p_profile_rec.question_3_answer               ;
    pr_question_4_number              :=  p_profile_rec.question_4_number               ;
    pr_question_4_size                :=  p_profile_rec.question_4_size                 ;
    pr_question_4_answer              :=  p_profile_rec.question_4_answer               ;
    pr_question_5_number              :=  p_profile_rec.question_5_number               ;
    pr_question_5_size                :=  p_profile_rec.question_5_size                 ;
    pr_question_5_answer              :=  p_profile_rec.question_5_answer               ;
    pr_question_6_number              :=  p_profile_rec.question_6_number               ;
    pr_question_6_size                :=  p_profile_rec.question_6_size                 ;
    pr_question_6_answer              :=  p_profile_rec.question_6_answer               ;
    pr_question_7_number              :=  p_profile_rec.question_7_number               ;
    pr_question_7_size                :=  p_profile_rec.question_7_size                 ;
    pr_question_7_answer              :=  p_profile_rec.question_7_answer               ;
    pr_question_8_number              :=  p_profile_rec.question_8_number               ;
    pr_question_8_size                :=  p_profile_rec.question_8_size                 ;
    pr_question_8_answer              :=  p_profile_rec.question_8_answer               ;
    pr_question_9_number              :=  p_profile_rec.question_9_number               ;
    pr_question_9_size                :=  p_profile_rec.question_9_size                 ;
    pr_question_9_answer              :=  p_profile_rec.question_9_answer               ;
    pr_question_10_number             :=  p_profile_rec.question_10_number              ;
    pr_question_10_size               :=  p_profile_rec.question_10_size                ;
    pr_question_10_answer             :=  p_profile_rec.question_10_answer              ;
    pr_question_11_number             :=  p_profile_rec.question_11_number              ;
    pr_question_11_size               :=  p_profile_rec.question_11_size                ;
    pr_question_11_answer             :=  p_profile_rec.question_11_answer              ;
    pr_question_12_number             :=  p_profile_rec.question_12_number              ;
    pr_question_12_size               :=  p_profile_rec.question_12_size                ;
    pr_question_12_answer             :=  p_profile_rec.question_12_answer              ;
    pr_question_13_number             :=  p_profile_rec.question_13_number              ;
    pr_question_13_size               :=  p_profile_rec.question_13_size                ;
    pr_question_13_answer             :=  p_profile_rec.question_13_answer              ;
    pr_question_14_number             :=  p_profile_rec.question_14_number              ;
    pr_question_14_size               :=  p_profile_rec.question_14_size                ;
    pr_question_14_answer             :=  p_profile_rec.question_14_answer              ;
    pr_question_15_number             :=  p_profile_rec.question_15_number              ;
    pr_question_15_size               :=  p_profile_rec.question_15_size                ;
    pr_question_15_answer             :=  p_profile_rec.question_15_answer              ;
    pr_question_16_number             :=  p_profile_rec.question_16_number              ;
    pr_question_16_size               :=  p_profile_rec.question_16_size                ;
    pr_question_16_answer             :=  p_profile_rec.question_16_answer              ;
    pr_question_17_number             :=  p_profile_rec.question_17_number              ;
    pr_question_17_size               :=  p_profile_rec.question_17_size                ;
    pr_question_17_answer             :=  p_profile_rec.question_17_answer              ;
    pr_question_18_number             :=  p_profile_rec.question_18_number              ;
    pr_question_18_size               :=  p_profile_rec.question_18_size                ;
    pr_question_18_answer             :=  p_profile_rec.question_18_answer              ;
    pr_question_19_number             :=  p_profile_rec.question_19_number              ;
    pr_question_19_size               :=  p_profile_rec.question_19_size                ;
    pr_question_19_answer             :=  p_profile_rec.question_19_answer              ;
    pr_question_20_number             :=  p_profile_rec.question_20_number              ;
    pr_question_20_size               :=  p_profile_rec.question_20_size                ;
    pr_question_20_answer             :=  p_profile_rec.question_20_answer              ;
    pr_question_21_number             :=  p_profile_rec.question_21_number              ;
    pr_question_21_size               :=  p_profile_rec.question_21_size                ;
    pr_question_21_answer             :=  p_profile_rec.question_21_answer              ;
    pr_question_22_number             :=  p_profile_rec.question_22_number              ;
    pr_question_22_size               :=  p_profile_rec.question_22_size                ;
    pr_question_22_answer             :=  p_profile_rec.question_22_answer              ;
    pr_question_23_number             :=  p_profile_rec.question_23_number              ;
    pr_question_23_size               :=  p_profile_rec.question_23_size                ;
    pr_question_23_answer             :=  p_profile_rec.question_23_answer              ;
    pr_question_24_number             :=  p_profile_rec.question_24_number              ;
    pr_question_24_size               :=  p_profile_rec.question_24_size                ;
    pr_question_24_answer             :=  p_profile_rec.question_24_answer              ;
    pr_question_25_number             :=  p_profile_rec.question_25_number              ;
    pr_question_25_size               :=  p_profile_rec.question_25_size                ;
    pr_question_25_answer             :=  p_profile_rec.question_25_answer              ;
    pr_question_26_number             :=  p_profile_rec.question_26_number              ;
    pr_question_26_size               :=  p_profile_rec.question_26_size                ;
    pr_question_26_answer             :=  p_profile_rec.question_26_answer              ;
    pr_question_27_number             :=  p_profile_rec.question_27_number              ;
    pr_question_27_size               :=  p_profile_rec.question_27_size                ;
    pr_question_27_answer             :=  p_profile_rec.question_27_answer              ;
    pr_question_28_number             :=  p_profile_rec.question_28_number              ;
    pr_question_28_size               :=  p_profile_rec.question_28_size                ;
    pr_question_28_answer             :=  p_profile_rec.question_28_answer              ;
    pr_question_29_number             :=  p_profile_rec.question_29_number              ;
    pr_question_29_size               :=  p_profile_rec.question_29_size                ;
    pr_question_29_answer             :=  p_profile_rec.question_29_answer              ;
    pr_question_30_number             :=  p_profile_rec.question_30_number              ;
    pr_questions_30_size              :=  p_profile_rec.questions_30_size               ;
    pr_question_30_answer             :=  p_profile_rec.question_30_answer              ;
    pr_legacy_record_flag             :=  p_profile_rec.legacy_record_flag              ;
    pr_coa_duration_efc_amt           :=  p_profile_rec.coa_duration_efc_amt            ;
    pr_coa_duration_num               :=  p_profile_rec.coa_duration_num                ;
    pr_created_by                     :=  p_profile_rec.created_by                      ;
    pr_creation_date                  :=  p_profile_rec.creation_date                   ;
    pr_last_updated_by                :=  p_profile_rec.last_updated_by                 ;
    pr_last_update_date               :=  p_profile_rec.last_update_date                ;
    pr_last_update_login              :=  p_profile_rec.last_update_login               ;
    pr_p_soc_sec_ben_student_amt      :=  p_profile_rec.p_soc_sec_ben_student_amt       ;
    pr_p_tuit_fee_deduct_amt          :=  p_profile_rec.p_tuit_fee_deduct_amt           ;
    pr_stu_lives_with_num             :=  p_profile_rec.stu_lives_with_num              ;
    pr_stu_most_support_from_num      :=  p_profile_rec.stu_most_support_from_num       ;
    pr_location_computer_num          :=  p_profile_rec.location_computer_num           ;

    f_fnar_id                        :=  p_fnar_rec.fnar_id                         ;
    f_cssp_id                        :=  p_fnar_rec.cssp_id                         ;
    f_r_s_email_address              :=  p_fnar_rec.r_s_email_address               ;
    f_eps_code                       :=  p_fnar_rec.eps_code                        ;
    f_comp_css_dependency_status     :=  p_fnar_rec.comp_css_dependency_status      ;
    f_stu_age                        :=  p_fnar_rec.stu_age                         ;
    f_assumed_stu_yr_in_coll         :=  p_fnar_rec.assumed_stu_yr_in_coll          ;
    f_comp_stu_marital_status        :=  p_fnar_rec.comp_stu_marital_status         ;
    f_stu_family_members             :=  p_fnar_rec.stu_family_members              ;
    f_stu_fam_members_in_college     :=  p_fnar_rec.stu_fam_members_in_college      ;
    f_par_marital_status             :=  p_fnar_rec.par_marital_status              ;
    f_par_family_members             :=  p_fnar_rec.par_family_members              ;
    f_par_total_in_college           :=  p_fnar_rec.par_total_in_college            ;
    f_par_par_in_college             :=  p_fnar_rec.par_par_in_college              ;
    f_par_others_in_college          :=  p_fnar_rec.par_others_in_college           ;
    f_par_aesa                       :=  p_fnar_rec.par_aesa                        ;
    f_par_cesa                       :=  p_fnar_rec.par_cesa                        ;
    f_stu_aesa                       :=  p_fnar_rec.stu_aesa                        ;
    f_stu_cesa                       :=  p_fnar_rec.stu_cesa                        ;
    f_im_p_bas_agi_taxable_income    :=  p_fnar_rec.im_p_bas_agi_taxable_income     ;
    f_im_p_bas_untx_inc_and_ben      :=  p_fnar_rec.im_p_bas_untx_inc_and_ben       ;
    f_im_p_bas_inc_adj               :=  p_fnar_rec.im_p_bas_inc_adj                ;
    f_im_p_bas_total_income          :=  p_fnar_rec.im_p_bas_total_income           ;
    f_im_p_bas_us_income_tax         :=  p_fnar_rec.im_p_bas_us_income_tax          ;
    f_im_p_bas_st_and_other_tax      :=  p_fnar_rec.im_p_bas_st_and_other_tax       ;
    f_im_p_bas_fica_tax              :=  p_fnar_rec.im_p_bas_fica_tax               ;
    f_im_p_bas_med_dental            :=  p_fnar_rec.im_p_bas_med_dental             ;
    f_im_p_bas_employment_allow      :=  p_fnar_rec.im_p_bas_employment_allow       ;
    f_im_p_bas_annual_ed_savings     :=  p_fnar_rec.im_p_bas_annual_ed_savings      ;
    f_im_p_bas_inc_prot_allow_m      :=  p_fnar_rec.im_p_bas_inc_prot_allow_m       ;
    f_im_p_bas_total_inc_allow       :=  p_fnar_rec.im_p_bas_total_inc_allow        ;
    f_im_p_bas_cal_avail_inc         :=  p_fnar_rec.im_p_bas_cal_avail_inc          ;
    f_im_p_bas_avail_income          :=  p_fnar_rec.im_p_bas_avail_income           ;
    f_im_p_bas_total_cont_inc        :=  p_fnar_rec.im_p_bas_total_cont_inc         ;
    f_im_p_bas_cash_bank_accounts    :=  p_fnar_rec.im_p_bas_cash_bank_accounts     ;
    f_im_p_bas_home_equity           :=  p_fnar_rec.im_p_bas_home_equity            ;
    f_im_p_bas_ot_rl_est_inv_eq      :=  p_fnar_rec.im_p_bas_ot_rl_est_inv_eq       ;
    f_im_p_bas_adj_bus_farm_worth    :=  p_fnar_rec.im_p_bas_adj_bus_farm_worth     ;
    f_im_p_bas_ass_sibs_pre_tui      :=  p_fnar_rec.im_p_bas_ass_sibs_pre_tui       ;
    f_im_p_bas_net_worth             :=  p_fnar_rec.im_p_bas_net_worth              ;
    f_im_p_bas_emerg_res_allow       :=  p_fnar_rec.im_p_bas_emerg_res_allow        ;
    f_im_p_bas_cum_ed_savings        :=  p_fnar_rec.im_p_bas_cum_ed_savings         ;
    f_im_p_bas_low_inc_allow         :=  p_fnar_rec.im_p_bas_low_inc_allow          ;
    f_im_p_bas_total_asset_allow     :=  p_fnar_rec.im_p_bas_total_asset_allow      ;
    f_im_p_bas_disc_net_worth        :=  p_fnar_rec.im_p_bas_disc_net_worth         ;
    f_im_p_bas_total_cont_asset      :=  p_fnar_rec.im_p_bas_total_cont_asset       ;
    f_im_p_bas_total_cont            :=  p_fnar_rec.im_p_bas_total_cont             ;
    f_im_p_bas_num_in_coll_adj       :=  p_fnar_rec.im_p_bas_num_in_coll_adj        ;
    f_im_p_bas_cont_for_stu          :=  p_fnar_rec.im_p_bas_cont_for_stu           ;
    f_im_p_bas_cont_from_income      :=  p_fnar_rec.im_p_bas_cont_from_income       ;
    f_im_p_bas_cont_from_assets      :=  p_fnar_rec.im_p_bas_cont_from_assets       ;
    f_im_p_opt_agi_taxable_income    :=  p_fnar_rec.im_p_opt_agi_taxable_income     ;
    f_im_p_opt_untx_inc_and_ben      :=  p_fnar_rec.im_p_opt_untx_inc_and_ben       ;
    f_im_p_opt_inc_adj               :=  p_fnar_rec.im_p_opt_inc_adj                ;
    f_im_p_opt_total_income          :=  p_fnar_rec.im_p_opt_total_income           ;
    f_im_p_opt_us_income_tax         :=  p_fnar_rec.im_p_opt_us_income_tax          ;
    f_im_p_opt_st_and_other_tax      :=  p_fnar_rec.im_p_opt_st_and_other_tax       ;
    f_im_p_opt_fica_tax              :=  p_fnar_rec.im_p_opt_fica_tax               ;
    f_im_p_opt_med_dental            :=  p_fnar_rec.im_p_opt_med_dental             ;
    f_im_p_opt_elem_sec_tuit         :=  p_fnar_rec.im_p_opt_elem_sec_tuit          ;
    f_im_p_opt_employment_allow      :=  p_fnar_rec.im_p_opt_employment_allow       ;
    f_im_p_opt_annual_ed_savings     :=  p_fnar_rec.im_p_opt_annual_ed_savings      ;
    f_im_p_opt_inc_prot_allow_m      :=  p_fnar_rec.im_p_opt_inc_prot_allow_m       ;
    f_im_p_opt_total_inc_allow       :=  p_fnar_rec.im_p_opt_total_inc_allow        ;
    f_im_p_opt_cal_avail_inc         :=  p_fnar_rec.im_p_opt_cal_avail_inc          ;
    f_im_p_opt_avail_income          :=  p_fnar_rec.im_p_opt_avail_income           ;
    f_im_p_opt_total_cont_inc        :=  p_fnar_rec.im_p_opt_total_cont_inc         ;
    f_im_p_opt_cash_bank_accounts    :=  p_fnar_rec.im_p_opt_cash_bank_accounts     ;
    f_im_p_opt_home_equity           :=  p_fnar_rec.im_p_opt_home_equity            ;
    f_im_p_opt_ot_rl_est_inv_eq      :=  p_fnar_rec.im_p_opt_ot_rl_est_inv_eq       ;
    f_im_p_opt_adj_bus_farm_worth    :=  p_fnar_rec.im_p_opt_adj_bus_farm_worth     ;
    f_im_p_opt_ass_sibs_pre_tui      :=  p_fnar_rec.im_p_opt_ass_sibs_pre_tui       ;
    f_im_p_opt_net_worth             :=  p_fnar_rec.im_p_opt_net_worth              ;
    f_im_p_opt_emerg_res_allow       :=  p_fnar_rec.im_p_opt_emerg_res_allow        ;
    f_im_p_opt_cum_ed_savings        :=  p_fnar_rec.im_p_opt_cum_ed_savings         ;
    f_im_p_opt_low_inc_allow         :=  p_fnar_rec.im_p_opt_low_inc_allow          ;
    f_im_p_opt_total_asset_allow     :=  p_fnar_rec.im_p_opt_total_asset_allow      ;
    f_im_p_opt_disc_net_worth        :=  p_fnar_rec.im_p_opt_disc_net_worth         ;
    f_im_p_opt_total_cont_asset      :=  p_fnar_rec.im_p_opt_total_cont_asset       ;
    f_im_p_opt_total_cont            :=  p_fnar_rec.im_p_opt_total_cont             ;
    f_im_p_opt_num_in_coll_adj       :=  p_fnar_rec.im_p_opt_num_in_coll_adj        ;
    f_im_p_opt_cont_for_stu          :=  p_fnar_rec.im_p_opt_cont_for_stu           ;
    f_im_p_opt_cont_from_income      :=  p_fnar_rec.im_p_opt_cont_from_income       ;
    f_im_p_opt_cont_from_assets      :=  p_fnar_rec.im_p_opt_cont_from_assets       ;
    f_fm_p_analysis_type             :=  p_fnar_rec.fm_p_analysis_type              ;
    f_fm_p_agi_taxable_income        :=  p_fnar_rec.fm_p_agi_taxable_income         ;
    f_fm_p_untx_inc_and_ben          :=  p_fnar_rec.fm_p_untx_inc_and_ben           ;
    f_fm_p_inc_adj                   :=  p_fnar_rec.fm_p_inc_adj                    ;
    f_fm_p_total_income              :=  p_fnar_rec.fm_p_total_income               ;
    f_fm_p_us_income_tax             :=  p_fnar_rec.fm_p_us_income_tax              ;
    f_fm_p_state_and_other_taxes     :=  p_fnar_rec.fm_p_state_and_other_taxes      ;
    f_fm_p_fica_tax                  :=  p_fnar_rec.fm_p_fica_tax                   ;
    f_fm_p_employment_allow          :=  p_fnar_rec.fm_p_employment_allow           ;
    f_fm_p_income_prot_allow         :=  p_fnar_rec.fm_p_income_prot_allow          ;
    f_fm_p_total_allow               :=  p_fnar_rec.fm_p_total_allow                ;
    f_fm_p_avail_income              :=  p_fnar_rec.fm_p_avail_income               ;
    f_fm_p_cash_bank_accounts        :=  p_fnar_rec.fm_p_cash_bank_accounts         ;
    f_fm_p_ot_rl_est_inv_equity      :=  p_fnar_rec.fm_p_ot_rl_est_inv_equity       ;
    f_fm_p_adj_bus_farm_net_worth    :=  p_fnar_rec.fm_p_adj_bus_farm_net_worth     ;
    f_fm_p_net_worth                 :=  p_fnar_rec.fm_p_net_worth                  ;
    f_fm_p_asset_prot_allow          :=  p_fnar_rec.fm_p_asset_prot_allow           ;
    f_fm_p_disc_net_worth            :=  p_fnar_rec.fm_p_disc_net_worth             ;
    f_fm_p_total_contribution        :=  p_fnar_rec.fm_p_total_contribution         ;
    f_fm_p_num_in_coll               :=  p_fnar_rec.fm_p_num_in_coll                ;
    f_fm_p_cont_for_stu              :=  p_fnar_rec.fm_p_cont_for_stu               ;
    f_fm_p_cont_from_income          :=  p_fnar_rec.fm_p_cont_from_income           ;
    f_fm_p_cont_from_assets          :=  p_fnar_rec.fm_p_cont_from_assets           ;
    f_im_s_bas_agi_taxable_income    :=  p_fnar_rec.im_s_bas_agi_taxable_income     ;
    f_im_s_bas_untx_inc_and_ben      :=  p_fnar_rec.im_s_bas_untx_inc_and_ben       ;
    f_im_s_bas_inc_adj               :=  p_fnar_rec.im_s_bas_inc_adj                ;
    f_im_s_bas_total_income          :=  p_fnar_rec.im_s_bas_total_income           ;
    f_im_s_bas_us_income_tax         :=  p_fnar_rec.im_s_bas_us_income_tax          ;
    f_im_s_bas_state_and_oth_taxes   :=  p_fnar_rec.im_s_bas_state_and_oth_taxes    ;
    f_im_s_bas_fica_tax              :=  p_fnar_rec.im_s_bas_fica_tax               ;
    f_im_s_bas_med_dental            :=  p_fnar_rec.im_s_bas_med_dental             ;
    f_im_s_bas_employment_allow      :=  p_fnar_rec.im_s_bas_employment_allow       ;
    f_im_s_bas_annual_ed_savings     :=  p_fnar_rec.im_s_bas_annual_ed_savings      ;
    f_im_s_bas_inc_prot_allow_m      :=  p_fnar_rec.im_s_bas_inc_prot_allow_m       ;
    f_im_s_bas_total_inc_allow       :=  p_fnar_rec.im_s_bas_total_inc_allow        ;
    f_im_s_bas_cal_avail_income      :=  p_fnar_rec.im_s_bas_cal_avail_income       ;
    f_im_s_bas_avail_income          :=  p_fnar_rec.im_s_bas_avail_income           ;
    f_im_s_bas_total_cont_inc        :=  p_fnar_rec.im_s_bas_total_cont_inc         ;
    f_im_s_bas_cash_bank_accounts    :=  p_fnar_rec.im_s_bas_cash_bank_accounts     ;
    f_im_s_bas_home_equity           :=  p_fnar_rec.im_s_bas_home_equity            ;
    f_im_s_bas_ot_rl_est_inv_eq      :=  p_fnar_rec.im_s_bas_ot_rl_est_inv_eq       ;
    f_im_s_bas_adj_busfarm_worth     :=  p_fnar_rec.im_s_bas_adj_busfarm_worth      ;
    f_im_s_bas_trusts                :=  p_fnar_rec.im_s_bas_trusts                 ;
    f_im_s_bas_net_worth             :=  p_fnar_rec.im_s_bas_net_worth              ;
    f_im_s_bas_emerg_res_allow       :=  p_fnar_rec.im_s_bas_emerg_res_allow        ;
    f_im_s_bas_cum_ed_savings        :=  p_fnar_rec.im_s_bas_cum_ed_savings         ;
    f_im_s_bas_total_asset_allow     :=  p_fnar_rec.im_s_bas_total_asset_allow      ;
    f_im_s_bas_disc_net_worth        :=  p_fnar_rec.im_s_bas_disc_net_worth         ;
    f_im_s_bas_total_cont_asset      :=  p_fnar_rec.im_s_bas_total_cont_asset       ;
    f_im_s_bas_total_cont            :=  p_fnar_rec.im_s_bas_total_cont             ;
    f_im_s_bas_num_in_coll_adj       :=  p_fnar_rec.im_s_bas_num_in_coll_adj        ;
    f_im_s_bas_cont_for_stu          :=  p_fnar_rec.im_s_bas_cont_for_stu           ;
    f_im_s_bas_cont_from_income      :=  p_fnar_rec.im_s_bas_cont_from_income       ;
    f_im_s_bas_cont_from_assets      :=  p_fnar_rec.im_s_bas_cont_from_assets       ;
    f_im_s_est_agitaxable_income     :=  p_fnar_rec.im_s_est_agitaxable_income      ;
    f_im_s_est_untx_inc_and_ben      :=  p_fnar_rec.im_s_est_untx_inc_and_ben       ;
    f_im_s_est_inc_adj               :=  p_fnar_rec.im_s_est_inc_adj                ;
    f_im_s_est_total_income          :=  p_fnar_rec.im_s_est_total_income           ;
    f_im_s_est_us_income_tax         :=  p_fnar_rec.im_s_est_us_income_tax          ;
    f_im_s_est_state_and_oth_taxes   :=  p_fnar_rec.im_s_est_state_and_oth_taxes    ;
    f_im_s_est_fica_tax              :=  p_fnar_rec.im_s_est_fica_tax               ;
    f_im_s_est_med_dental            :=  p_fnar_rec.im_s_est_med_dental             ;
    f_im_s_est_employment_allow      :=  p_fnar_rec.im_s_est_employment_allow       ;
    f_im_s_est_annual_ed_savings     :=  p_fnar_rec.im_s_est_annual_ed_savings      ;
    f_im_s_est_inc_prot_allow_m      :=  p_fnar_rec.im_s_est_inc_prot_allow_m       ;
    f_im_s_est_total_inc_allow       :=  p_fnar_rec.im_s_est_total_inc_allow        ;
    f_im_s_est_cal_avail_income      :=  p_fnar_rec.im_s_est_cal_avail_income       ;
    f_im_s_est_avail_income          :=  p_fnar_rec.im_s_est_avail_income           ;
    f_im_s_est_total_cont_inc        :=  p_fnar_rec.im_s_est_total_cont_inc         ;
    f_im_s_est_cash_bank_accounts    :=  p_fnar_rec.im_s_est_cash_bank_accounts     ;
    f_im_s_est_home_equity           :=  p_fnar_rec.im_s_est_home_equity            ;
    f_im_s_est_ot_rl_est_inv_eq      :=  p_fnar_rec.im_s_est_ot_rl_est_inv_eq       ;
    f_im_s_est_adj_bus_farm_worth    :=  p_fnar_rec.im_s_est_adj_bus_farm_worth     ;
    f_im_s_est_est_trusts            :=  p_fnar_rec.im_s_est_est_trusts             ;
    f_im_s_est_net_worth             :=  p_fnar_rec.im_s_est_net_worth              ;
    f_im_s_est_emerg_res_allow       :=  p_fnar_rec.im_s_est_emerg_res_allow        ;
    f_im_s_est_cum_ed_savings        :=  p_fnar_rec.im_s_est_cum_ed_savings         ;
    f_im_s_est_total_asset_allow     :=  p_fnar_rec.im_s_est_total_asset_allow      ;
    f_im_s_est_disc_net_worth        :=  p_fnar_rec.im_s_est_disc_net_worth         ;
    f_im_s_est_total_cont_asset      :=  p_fnar_rec.im_s_est_total_cont_asset       ;
    f_im_s_est_total_cont            :=  p_fnar_rec.im_s_est_total_cont             ;
    f_im_s_est_num_in_coll_adj       :=  p_fnar_rec.im_s_est_num_in_coll_adj        ;
    f_im_s_est_cont_for_stu          :=  p_fnar_rec.im_s_est_cont_for_stu           ;
    f_im_s_est_cont_from_income      :=  p_fnar_rec.im_s_est_cont_from_income       ;
    f_im_s_est_cont_from_assets      :=  p_fnar_rec.im_s_est_cont_from_assets       ;
    f_im_s_opt_agi_taxable_income    :=  p_fnar_rec.im_s_opt_agi_taxable_income     ;
    f_im_s_opt_untx_inc_and_ben      :=  p_fnar_rec.im_s_opt_untx_inc_and_ben       ;
    f_im_s_opt_inc_adj               :=  p_fnar_rec.im_s_opt_inc_adj                ;
    f_im_s_opt_total_income          :=  p_fnar_rec.im_s_opt_total_income           ;
    f_im_s_opt_us_income_tax         :=  p_fnar_rec.im_s_opt_us_income_tax          ;
    f_im_s_opt_state_and_oth_taxes   :=  p_fnar_rec.im_s_opt_state_and_oth_taxes    ;
    f_im_s_opt_fica_tax              :=  p_fnar_rec.im_s_opt_fica_tax               ;
    f_im_s_opt_med_dental            :=  p_fnar_rec.im_s_opt_med_dental             ;
    f_im_s_opt_employment_allow      :=  p_fnar_rec.im_s_opt_employment_allow       ;
    f_im_s_opt_annual_ed_savings     :=  p_fnar_rec.im_s_opt_annual_ed_savings      ;
    f_im_s_opt_inc_prot_allow_m      :=  p_fnar_rec.im_s_opt_inc_prot_allow_m       ;
    f_im_s_opt_total_inc_allow       :=  p_fnar_rec.im_s_opt_total_inc_allow        ;
    f_im_s_opt_cal_avail_income      :=  p_fnar_rec.im_s_opt_cal_avail_income       ;
    f_im_s_opt_avail_income          :=  p_fnar_rec.im_s_opt_avail_income           ;
    f_im_s_opt_total_cont_inc        :=  p_fnar_rec.im_s_opt_total_cont_inc         ;
    f_im_s_opt_cash_bank_accounts    :=  p_fnar_rec.im_s_opt_cash_bank_accounts     ;
    f_im_s_opt_ira_keogh_accounts    :=  p_fnar_rec.im_s_opt_ira_keogh_accounts     ;
    f_im_s_opt_home_equity           :=  p_fnar_rec.im_s_opt_home_equity            ;
    f_im_s_opt_ot_rl_est_inv_eq      :=  p_fnar_rec.im_s_opt_ot_rl_est_inv_eq       ;
    f_im_s_opt_adj_bus_farm_worth    :=  p_fnar_rec.im_s_opt_adj_bus_farm_worth     ;
    f_im_s_opt_trusts                :=  p_fnar_rec.im_s_opt_trusts                 ;
    f_im_s_opt_net_worth             :=  p_fnar_rec.im_s_opt_net_worth              ;
    f_im_s_opt_emerg_res_allow       :=  p_fnar_rec.im_s_opt_emerg_res_allow        ;
    f_im_s_opt_cum_ed_savings        :=  p_fnar_rec.im_s_opt_cum_ed_savings         ;
    f_im_s_opt_total_asset_allow     :=  p_fnar_rec.im_s_opt_total_asset_allow      ;
    f_im_s_opt_disc_net_worth        :=  p_fnar_rec.im_s_opt_disc_net_worth         ;
    f_im_s_opt_total_cont_asset      :=  p_fnar_rec.im_s_opt_total_cont_asset       ;
    f_im_s_opt_total_cont            :=  p_fnar_rec.im_s_opt_total_cont             ;
    f_im_s_opt_num_in_coll_adj       :=  p_fnar_rec.im_s_opt_num_in_coll_adj        ;
    f_im_s_opt_cont_for_stu          :=  p_fnar_rec.im_s_opt_cont_for_stu           ;
    f_im_s_opt_cont_from_income      :=  p_fnar_rec.im_s_opt_cont_from_income       ;
    f_im_s_opt_cont_from_assets      :=  p_fnar_rec.im_s_opt_cont_from_assets       ;
    f_fm_s_analysis_type             :=  p_fnar_rec.fm_s_analysis_type              ;
    f_fm_s_agi_taxable_income        :=  p_fnar_rec.fm_s_agi_taxable_income         ;
    f_fm_s_untx_inc_and_ben          :=  p_fnar_rec.fm_s_untx_inc_and_ben           ;
    f_fm_s_inc_adj                   :=  p_fnar_rec.fm_s_inc_adj                    ;
    f_fm_s_total_income              :=  p_fnar_rec.fm_s_total_income               ;
    f_fm_s_us_income_tax             :=  p_fnar_rec.fm_s_us_income_tax              ;
    f_fm_s_state_and_oth_taxes       :=  p_fnar_rec.fm_s_state_and_oth_taxes        ;
    f_fm_s_fica_tax                  :=  p_fnar_rec.fm_s_fica_tax                   ;
    f_fm_s_employment_allow          :=  p_fnar_rec.fm_s_employment_allow           ;
    f_fm_s_income_prot_allow         :=  p_fnar_rec.fm_s_income_prot_allow          ;
    f_fm_s_total_allow               :=  p_fnar_rec.fm_s_total_allow                ;
    f_fm_s_cal_avail_income          :=  p_fnar_rec.fm_s_cal_avail_income           ;
    f_fm_s_avail_income              :=  p_fnar_rec.fm_s_avail_income               ;
    f_fm_s_cash_bank_accounts        :=  p_fnar_rec.fm_s_cash_bank_accounts         ;
    f_fm_s_ot_rl_est_inv_equity      :=  p_fnar_rec.fm_s_ot_rl_est_inv_equity       ;
    f_fm_s_adj_bus_farm_worth        :=  p_fnar_rec.fm_s_adj_bus_farm_worth         ;
    f_fm_s_trusts                    :=  p_fnar_rec.fm_s_trusts                     ;
    f_fm_s_net_worth                 :=  p_fnar_rec.fm_s_net_worth                  ;
    f_fm_s_asset_prot_allow          :=  p_fnar_rec.fm_s_asset_prot_allow           ;
    f_fm_s_disc_net_worth            :=  p_fnar_rec.fm_s_disc_net_worth             ;
    f_fm_s_total_cont                :=  p_fnar_rec.fm_s_total_cont                 ;
    f_fm_s_num_in_coll               :=  p_fnar_rec.fm_s_num_in_coll                ;
    f_fm_s_cont_for_stu              :=  p_fnar_rec.fm_s_cont_for_stu               ;
    f_fm_s_cont_from_income          :=  p_fnar_rec.fm_s_cont_from_income           ;
    f_fm_s_cont_from_assets          :=  p_fnar_rec.fm_s_cont_from_assets           ;
    f_im_inst_resident_ind           :=  p_fnar_rec.im_inst_resident_ind            ;
    f_institutional_1_budget_name    :=  p_fnar_rec.institutional_1_budget_name     ;
    f_im_inst_1_budget_duration      :=  p_fnar_rec.im_inst_1_budget_duration       ;
    f_im_inst_1_tuition_fees         :=  p_fnar_rec.im_inst_1_tuition_fees          ;
    f_im_inst_1_books_supplies       :=  p_fnar_rec.im_inst_1_books_supplies        ;
    f_im_inst_1_living_expenses      :=  p_fnar_rec.im_inst_1_living_expenses       ;
    f_im_inst_1_tot_expenses         :=  p_fnar_rec.im_inst_1_tot_expenses          ;
    f_im_inst_1_tot_stu_cont         :=  p_fnar_rec.im_inst_1_tot_stu_cont          ;
    f_im_inst_1_tot_par_cont         :=  p_fnar_rec.im_inst_1_tot_par_cont          ;
    f_im_inst_1_tot_family_cont      :=  p_fnar_rec.im_inst_1_tot_family_cont       ;
    f_im_inst_1_va_benefits          :=  p_fnar_rec.im_inst_1_va_benefits           ;
    f_im_inst_1_ot_cont              :=  p_fnar_rec.im_inst_1_ot_cont               ;
    f_im_inst_1_est_financial_need   :=  p_fnar_rec.im_inst_1_est_financial_need    ;
    f_institutional_2_budget_name    :=  p_fnar_rec.institutional_2_budget_name     ;
    f_im_inst_2_budget_duration      :=  p_fnar_rec.im_inst_2_budget_duration       ;
    f_im_inst_2_tuition_fees         :=  p_fnar_rec.im_inst_2_tuition_fees          ;
    f_im_inst_2_books_supplies       :=  p_fnar_rec.im_inst_2_books_supplies        ;
    f_im_inst_2_living_expenses      :=  p_fnar_rec.im_inst_2_living_expenses       ;
    f_im_inst_2_tot_expenses         :=  p_fnar_rec.im_inst_2_tot_expenses          ;
    f_im_inst_2_tot_stu_cont         :=  p_fnar_rec.im_inst_2_tot_stu_cont          ;
    f_im_inst_2_tot_par_cont         :=  p_fnar_rec.im_inst_2_tot_par_cont          ;
    f_im_inst_2_tot_family_cont      :=  p_fnar_rec.im_inst_2_tot_family_cont       ;
    f_im_inst_2_va_benefits          :=  p_fnar_rec.im_inst_2_va_benefits           ;
    f_im_inst_2_est_financial_need   :=  p_fnar_rec.im_inst_2_est_financial_need    ;
    f_institutional_3_budget_name    :=  p_fnar_rec.institutional_3_budget_name     ;
    f_im_inst_3_budget_duration      :=  p_fnar_rec.im_inst_3_budget_duration       ;
    f_im_inst_3_tuition_fees         :=  p_fnar_rec.im_inst_3_tuition_fees          ;
    f_im_inst_3_books_supplies       :=  p_fnar_rec.im_inst_3_books_supplies        ;
    f_im_inst_3_living_expenses      :=  p_fnar_rec.im_inst_3_living_expenses       ;
    f_im_inst_3_tot_expenses         :=  p_fnar_rec.im_inst_3_tot_expenses          ;
    f_im_inst_3_tot_stu_cont         :=  p_fnar_rec.im_inst_3_tot_stu_cont          ;
    f_im_inst_3_tot_par_cont         :=  p_fnar_rec.im_inst_3_tot_par_cont          ;
    f_im_inst_3_tot_family_cont      :=  p_fnar_rec.im_inst_3_tot_family_cont       ;
    f_im_inst_3_va_benefits          :=  p_fnar_rec.im_inst_3_va_benefits           ;
    f_im_inst_3_est_financial_need   :=  p_fnar_rec.im_inst_3_est_financial_need    ;
    f_fm_inst_1_federal_efc          :=  p_fnar_rec.fm_inst_1_federal_efc           ;
    f_fm_inst_1_va_benefits          :=  p_fnar_rec.fm_inst_1_va_benefits           ;
    f_fm_inst_1_fed_eligibility      :=  p_fnar_rec.fm_inst_1_fed_eligibility       ;
    f_fm_inst_1_pell                 :=  p_fnar_rec.fm_inst_1_pell                  ;
    f_option_par_loss_allow_ind      :=  p_fnar_rec.option_par_loss_allow_ind       ;
    f_option_par_tuition_ind         :=  p_fnar_rec.option_par_tuition_ind          ;
    f_option_par_home_ind            :=  p_fnar_rec.option_par_home_ind             ;
    f_option_par_home_value          :=  p_fnar_rec.option_par_home_value           ;
    f_option_par_home_debt           :=  p_fnar_rec.option_par_home_debt            ;
    f_option_stu_ira_keogh_ind       :=  p_fnar_rec.option_stu_ira_keogh_ind        ;
    f_option_stu_home_ind            :=  p_fnar_rec.option_stu_home_ind             ;
    f_option_stu_home_value          :=  p_fnar_rec.option_stu_home_value           ;
    f_option_stu_home_debt           :=  p_fnar_rec.option_stu_home_debt            ;
    f_option_stu_sum_ay_inc_ind      :=  p_fnar_rec.option_stu_sum_ay_inc_ind       ;
    f_option_par_hope_ll_credit      :=  p_fnar_rec.option_par_hope_ll_credit       ;
    f_option_stu_hope_ll_credit      :=  p_fnar_rec.option_stu_hope_ll_credit       ;
    f_option_par_cola_adj_ind        :=  p_fnar_rec.option_par_cola_adj_ind         ;
    f_option_par_stu_fa_assets_ind   :=  p_fnar_rec.option_par_stu_fa_assets_ind    ;
    f_option_par_ipt_assets_ind      :=  p_fnar_rec.option_par_ipt_assets_ind       ;
    f_option_stu_ipt_assets_ind      :=  p_fnar_rec.option_stu_ipt_assets_ind       ;
    f_option_par_cola_adj_value      :=  p_fnar_rec.option_par_cola_adj_value       ;
    f_im_parent_1_8_months_bas       :=  p_fnar_rec.im_parent_1_8_months_bas        ;
    f_im_p_more_than_9_mth_ba        :=  p_fnar_rec.im_p_more_than_9_mth_ba         ;
    f_im_parent_1_8_months_opt       :=  p_fnar_rec.im_parent_1_8_months_opt        ;
    f_im_p_more_than_9_mth_op        :=  p_fnar_rec.im_p_more_than_9_mth_op         ;
    f_fnar_message_1                 :=  p_fnar_rec.fnar_message_1                  ;
    f_fnar_message_2                 :=  p_fnar_rec.fnar_message_2                  ;
    f_fnar_message_3                 :=  p_fnar_rec.fnar_message_3                  ;
    f_fnar_message_4                 :=  p_fnar_rec.fnar_message_4                  ;
    f_fnar_message_5                 :=  p_fnar_rec.fnar_message_5                  ;
    f_fnar_message_6                 :=  p_fnar_rec.fnar_message_6                  ;
    f_fnar_message_7                 :=  p_fnar_rec.fnar_message_7                  ;
    f_fnar_message_8                 :=  p_fnar_rec.fnar_message_8                  ;
    f_fnar_message_9                 :=  p_fnar_rec.fnar_message_9                  ;
    f_fnar_message_10                :=  p_fnar_rec.fnar_message_10                 ;
    f_fnar_message_11                :=  p_fnar_rec.fnar_message_11                 ;
    f_fnar_message_12                :=  p_fnar_rec.fnar_message_12                 ;
    f_fnar_message_13                :=  p_fnar_rec.fnar_message_13                 ;
    f_fnar_message_20                :=  p_fnar_rec.fnar_message_20                 ;
    f_fnar_message_21                :=  p_fnar_rec.fnar_message_21                 ;
    f_fnar_message_22                :=  p_fnar_rec.fnar_message_22                 ;
    f_fnar_message_23                :=  p_fnar_rec.fnar_message_23                 ;
    f_fnar_message_24                :=  p_fnar_rec.fnar_message_24                 ;
    f_fnar_message_25                :=  p_fnar_rec.fnar_message_25                 ;
    f_fnar_message_26                :=  p_fnar_rec.fnar_message_26                 ;
    f_fnar_message_27                :=  p_fnar_rec.fnar_message_27                 ;
    f_fnar_message_30                :=  p_fnar_rec.fnar_message_30                 ;
    f_fnar_message_31                :=  p_fnar_rec.fnar_message_31                 ;
    f_fnar_message_32                :=  p_fnar_rec.fnar_message_32                 ;
    f_fnar_message_33                :=  p_fnar_rec.fnar_message_33                 ;
    f_fnar_message_34                :=  p_fnar_rec.fnar_message_34                 ;
    f_fnar_message_35                :=  p_fnar_rec.fnar_message_35                 ;
    f_fnar_message_36                :=  p_fnar_rec.fnar_message_36                 ;
    f_fnar_message_37                :=  p_fnar_rec.fnar_message_37                 ;
    f_fnar_message_38                :=  p_fnar_rec.fnar_message_38                 ;
    f_fnar_message_39                :=  p_fnar_rec.fnar_message_39                 ;
    f_fnar_message_45                :=  p_fnar_rec.fnar_message_45                 ;
    f_fnar_message_46                :=  p_fnar_rec.fnar_message_46                 ;
    f_fnar_message_47                :=  p_fnar_rec.fnar_message_47                 ;
    f_fnar_message_48                :=  p_fnar_rec.fnar_message_48                 ;
    f_fnar_message_49                :=  p_fnar_rec.fnar_message_49                 ;
    f_fnar_message_50                :=  p_fnar_rec.fnar_message_50                 ;
    f_fnar_message_51                :=  p_fnar_rec.fnar_message_51                 ;
    f_fnar_message_52                :=  p_fnar_rec.fnar_message_52                 ;
    f_fnar_message_53                :=  p_fnar_rec.fnar_message_53                 ;
    f_fnar_message_55                :=  p_fnar_rec.fnar_message_55                 ;
    f_fnar_message_56                :=  p_fnar_rec.fnar_message_56                 ;
    f_fnar_message_57                :=  p_fnar_rec.fnar_message_57                 ;
    f_fnar_message_58                :=  p_fnar_rec.fnar_message_58                 ;
    f_fnar_message_59                :=  p_fnar_rec.fnar_message_59                 ;
    f_fnar_message_60                :=  p_fnar_rec.fnar_message_60                 ;
    f_fnar_message_61                :=  p_fnar_rec.fnar_message_61                 ;
    f_fnar_message_62                :=  p_fnar_rec.fnar_message_62                 ;
    f_fnar_message_63                :=  p_fnar_rec.fnar_message_63                 ;
    f_fnar_message_64                :=  p_fnar_rec.fnar_message_64                 ;
    f_fnar_message_65                :=  p_fnar_rec.fnar_message_65                 ;
    f_fnar_message_71                :=  p_fnar_rec.fnar_message_71                 ;
    f_fnar_message_72                :=  p_fnar_rec.fnar_message_72                 ;
    f_fnar_message_73                :=  p_fnar_rec.fnar_message_73                 ;
    f_fnar_message_74                :=  p_fnar_rec.fnar_message_74                 ;
    f_fnar_message_75                :=  p_fnar_rec.fnar_message_75                 ;
    f_fnar_message_76                :=  p_fnar_rec.fnar_message_76                 ;
    f_fnar_message_77                :=  p_fnar_rec.fnar_message_77                 ;
    f_fnar_message_78                :=  p_fnar_rec.fnar_message_78                 ;
    f_fnar_mesg_10_stu_fam_mem       :=  p_fnar_rec.fnar_mesg_10_stu_fam_mem        ;
    f_fnar_mesg_11_stu_no_in_coll    :=  p_fnar_rec.fnar_mesg_11_stu_no_in_coll     ;
    f_fnar_mesg_24_stu_avail_inc     :=  p_fnar_rec.fnar_mesg_24_stu_avail_inc      ;
    f_fnar_mesg_26_stu_taxes         :=  p_fnar_rec.fnar_mesg_26_stu_taxes          ;
    f_fnar_mesg_33_stu_home_value    :=  p_fnar_rec.fnar_mesg_33_stu_home_value     ;
    f_fnar_mesg_34_stu_home_value    :=  p_fnar_rec.fnar_mesg_34_stu_home_value     ;
    f_fnar_mesg_34_stu_home_equity   :=  p_fnar_rec.fnar_mesg_34_stu_home_equity    ;
    f_fnar_mesg_35_stu_home_value    :=  p_fnar_rec.fnar_mesg_35_stu_home_value     ;
    f_fnar_mesg_35_stu_home_equity   :=  p_fnar_rec.fnar_mesg_35_stu_home_equity    ;
    f_fnar_mesg_36_stu_home_equity   :=  p_fnar_rec.fnar_mesg_36_stu_home_equity    ;
    f_fnar_mesg_48_par_fam_mem       :=  p_fnar_rec.fnar_mesg_48_par_fam_mem        ;
    f_fnar_mesg_49_par_no_in_coll    :=  p_fnar_rec.fnar_mesg_49_par_no_in_coll     ;
    f_fnar_mesg_56_par_agi           :=  p_fnar_rec.fnar_mesg_56_par_agi            ;
    f_fnar_mesg_62_par_taxes         :=  p_fnar_rec.fnar_mesg_62_par_taxes          ;
    f_fnar_mesg_73_par_home_value    :=  p_fnar_rec.fnar_mesg_73_par_home_value     ;
    f_fnar_mesg_74_par_home_value    :=  p_fnar_rec.fnar_mesg_74_par_home_value     ;
    f_fnar_mesg_74_par_home_equity   :=  p_fnar_rec.fnar_mesg_74_par_home_equity    ;
    f_fnar_mesg_75_par_home_value    :=  p_fnar_rec.fnar_mesg_75_par_home_value     ;
    f_fnar_mesg_75_par_home_equity   :=  p_fnar_rec.fnar_mesg_75_par_home_equity    ;
    f_fnar_mesg_76_par_home_equity   :=  p_fnar_rec.fnar_mesg_76_par_home_equity    ;
    f_assumption_message_1           :=  p_fnar_rec.assumption_message_1            ;
    f_assumption_message_2           :=  p_fnar_rec.assumption_message_2            ;
    f_assumption_message_3           :=  p_fnar_rec.assumption_message_3            ;
    f_assumption_message_4           :=  p_fnar_rec.assumption_message_4            ;
    f_assumption_message_5           :=  p_fnar_rec.assumption_message_5            ;
    f_assumption_message_6           :=  p_fnar_rec.assumption_message_6            ;
    f_record_mark                    :=  p_fnar_rec.record_mark                     ;
    f_legacy_record_flag             :=  p_fnar_rec.legacy_record_flag              ;
    f_creation_date                  :=  p_fnar_rec.creation_date                   ;
    f_created_by                     :=  p_fnar_rec.created_by                      ;
    f_last_updated_by                :=  p_fnar_rec.last_updated_by                 ;
    f_last_update_date               :=  p_fnar_rec.last_update_date                ;
    f_last_update_login              :=  p_fnar_rec.last_update_login               ;
    f_opt_ind_stu_ipt_assets_flag    :=  p_fnar_rec.option_ind_stu_ipt_assets_flag  ;
    f_cust_parent_cont_adj_num       :=  p_fnar_rec.cust_parent_cont_adj_num        ;
    f_custodial_parent_num           :=  p_fnar_rec.custodial_parent_num            ;
    f_cust_par_base_prcnt_inc_amt    :=  p_fnar_rec.cust_par_base_prcnt_inc_amt     ;
    f_cust_par_base_cont_inc_amt     :=  p_fnar_rec.cust_par_base_cont_inc_amt      ;
    f_cust_par_base_cont_ast_amt     :=  p_fnar_rec.cust_par_base_cont_ast_amt      ;
    f_cust_par_base_tot_cont_amt     :=  p_fnar_rec.cust_par_base_tot_cont_amt      ;
    f_cust_par_opt_prcnt_inc_amt     :=  p_fnar_rec.cust_par_opt_prcnt_inc_amt      ;
    f_cust_par_opt_cont_inc_amt      :=  p_fnar_rec.cust_par_opt_cont_inc_amt       ;
    f_cust_par_opt_cont_ast_amt      :=  p_fnar_rec.cust_par_opt_cont_ast_amt       ;
    f_cust_par_opt_tot_cont_amt      :=  p_fnar_rec.cust_par_opt_tot_cont_amt       ;
    f_parents_email_txt              :=  p_fnar_rec.parents_email_txt               ;
    f_parent_1_birth_date            :=  p_fnar_rec.parent_1_birth_date             ;
    f_parent_2_birth_date            :=  p_fnar_rec.parent_2_birth_date             ;


   if p_user_hook = TRUE then
      return 'true';
    else
      return 'false';
    end if;

    return 'true';

  END callHook;

END igf_ap_uhk_inas_pkg;

/
