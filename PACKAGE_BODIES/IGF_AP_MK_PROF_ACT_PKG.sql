--------------------------------------------------------
--  DDL for Package Body IGF_AP_MK_PROF_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_MK_PROF_ACT_PKG" AS
/* $Header: IGFAP42B.pls 120.2 2006/01/17 02:38:20 tsailaja noship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;

 -- The PL/SQL table for storing the duplicate person number
TYPE PerTab IS TABLE OF igf_ap_li_css_act_ints.person_number%TYPE
           index by binary_integer;

g_per_tab PerTab;

  PROCEDURE lg_make_active_profile ( errbuf          OUT NOCOPY VARCHAR2,
                                     retcode         OUT NOCOPY NUMBER,
                                     p_award_year    IN         VARCHAR2,
                                     p_batch_id      IN         NUMBER,
                                     p_del_ind       IN         VARCHAR2
                                   )
    IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : Main process makes the Profile records active based on the data in the
    ||            Legacy Make Active Profile Interface Table .
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
	||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  (reverse chronological order - newest change first)
    */
    l_proc_item_str    VARCHAR2(50) := NULL;
    l_message_str     VARCHAR2(800) := NULL;
    l_terminate_flag  BOOLEAN := FALSE;
    l_error_flag      BOOLEAN := FALSE;
    l_error           VARCHAR2(80);
    lv_row_id         VARCHAR2(80) := NULL;
    lv_person_id           igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id             igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
    l_person_skip_flag   BOOLEAN  := FALSE;
    l_success_record_cnt    NUMBER := 0;
    l_error_record_cnt      NUMBER := 0;
    l_todo_flag          BOOLEAN := FALSE;
    l_chk_profile     VARCHAR2(1) := 'N';
    l_chk_batch       VARCHAR2(1) := 'N';
    l_index            NUMBER := 1;
    l_total_record_cnt      NUMBER := 0;
    l_process_flag         BOOLEAN := FALSE;
    l_debug_str       VARCHAR2(800) := NULL;

    l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;



    -- Cursor for getting the context award year details
    CURSOR c_get_status(cp_cal_type VARCHAR2,
                        cp_seq_number NUMBER)
    IS
    SELECT sys_award_year,
           batch_year,
           award_year_status_code,
           css_academic_year
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_get_status c_get_status%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                cp_seq_number NUMBER)
    IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    l_get_alternate_code  c_get_alternate_code%ROWTYPE;

    CURSOR c_get_records(cp_alternate_code VARCHAR2,
                         cp_batch_id NUMBER)
    IS
    SELECT  A.batch_num batch_num,
            A.csaint_id csaint_id,
            A.ci_alternate_code ci_alternate_code,
            A.person_number person_number,
            A.css_id_number_txt  css_id_number_txt,
            A.academic_year_txt academic_year_txt,
            A.stu_record_type stu_record_type,
            A.import_status_type import_status_type,
            A.ROWID ROW_ID
    FROM    igf_ap_li_css_act_ints A
    WHERE   A.ci_alternate_code = cp_alternate_code
    AND     A.batch_num = cp_batch_id
    AND     A.import_status_type IN ('U','R')
    ORDER BY A.person_number;


    l_get_records c_get_records%ROWTYPE;

    -- check whether that profile record came through legacy
    CURSOR c_chk_prof_rec_legacy(cp_base_id NUMBER,
                                 cp_academic_year VARCHAR2 )
    IS
    SELECT PROF.row_id row_id
    FROM   igf_ap_css_profile PROF

    WHERE  PROF.base_id = cp_base_id
    AND    PROF.academic_year = cp_academic_year
    AND    NVL(PROF.legacy_record_flag,'X') <> 'Y'
    AND    rownum = 1;

    l_chk_prof_rec_legacy  c_chk_prof_rec_legacy%ROWTYPE;

    CURSOR c_get_dup_person(cp_alternate_code VARCHAR2,
                            cp_batch_id       NUMBER)
    IS
    SELECT person_number
    FROM   igf_ap_li_css_act_ints
    WHERE  ci_alternate_code = cp_alternate_code
    AND    batch_num = cp_batch_id
    GROUP BY person_number
    HAVING COUNT(person_number) > 1;

    l_get_dup_person  c_get_dup_person%ROWTYPE;

    CURSOR c_get_efc(cp_cssp_id igf_ap_css_profile.cssp_id%TYPE)
    IS
    SELECT fm_inst_1_federal_efc
    FROM   igf_ap_css_fnar
    WHERE  cssp_id = cp_cssp_id;

    l_get_efc  c_get_efc%ROWTYPE;

    CURSOR c_get_prof_rec(cp_base_id       NUMBER,
                          cp_academic_year   VARCHAR2,
                          cp_css_id_number   VARCHAR2,
                          cp_rec_type  VARCHAR2)
    IS
    SELECT  ROWID row_id,
            PROF.cssp_id cssp_id,
            PROF.org_id org_id,
            PROF.base_id base_id,
            PROF.system_record_type system_record_type,
            PROF.active_profile active_profile,
            PROF.college_code college_code,
            PROF.academic_year academic_year,
            PROF.stu_record_type stu_record_type,
            PROF.css_id_number css_id_number,
            PROF.registration_receipt_date registration_receipt_date,
            PROF.registration_type registration_type,
            PROF.application_receipt_date application_receipt_date,
            PROF.application_type application_type,
            PROF.original_fnar_compute original_fnar_compute,
            PROF.revision_fnar_compute_date revision_fnar_compute_date,
            PROF.electronic_extract_date electronic_extract_date,
            PROF.institutional_reporting_type institutional_reporting_type,
            PROF.asr_receipt_date asr_receipt_date,
            PROF.last_name last_name,
            PROF.first_name first_name,
            PROF.middle_initial middle_initial,
            PROF.address_number_and_street address_number_and_street,
            PROF.city city,
            PROF.state_mailing state_mailing,
            PROF.zip_code zip_code,
            PROF.s_telephone_number s_telephone_number,
            PROF.s_title s_title,
            PROF.date_of_birth date_of_birth,
            PROF.social_security_number social_security_number,
            PROF.state_legal_residence state_legal_residence,
            PROF.foreign_address_indicator foreign_address_indicator,
            PROF.foreign_postal_code foreign_postal_code,
            PROF.country country,
            PROF.financial_aid_status financial_aid_status,
            PROF.year_in_college year_in_college,
            PROF.marital_status marital_status,
            PROF.ward_court ward_court,
            PROF.legal_dependents_other legal_dependents_other,
            PROF.household_size household_size,
            PROF.number_in_college number_in_college,
            PROF.citizenship_status citizenship_status,
            PROF.citizenship_country citizenship_country,
            PROF.visa_classification visa_classification,
            PROF.tax_figures tax_figures,
            PROF.number_exemptions number_exemptions,
            PROF.adjusted_gross_inc adjusted_gross_inc,
            PROF.us_tax_paid us_tax_paid,
            PROF.itemized_deductions itemized_deductions,
            PROF.stu_income_work stu_income_work,
            PROF.spouse_income_work spouse_income_work,
            PROF.divid_int_inc divid_int_inc,
            PROF.soc_sec_benefits soc_sec_benefits,
            PROF.welfare_tanf welfare_tanf,
            PROF.child_supp_rcvd child_supp_rcvd,
            PROF.earned_income_credit earned_income_credit,
            PROF.other_untax_income other_untax_income,
            PROF.tax_stu_aid tax_stu_aid,
            PROF.cash_sav_check cash_sav_check,
            PROF.ira_keogh ira_keogh,
            PROF.invest_value invest_value,
            PROF.invest_debt invest_debt,
            PROF.home_value home_value,
            PROF.home_debt home_debt,
            PROF.oth_real_value oth_real_value,
            PROF.oth_real_debt oth_real_debt,
            PROF.bus_farm_value bus_farm_value,
            PROF.bus_farm_debt bus_farm_debt,
            PROF.live_on_farm live_on_farm,
            PROF.home_purch_price home_purch_price,
            PROF.hope_ll_credit hope_ll_credit,
            PROF.home_purch_year home_purch_year,
            PROF.trust_amount trust_amount,
            PROF.trust_avail trust_avail,
            PROF.trust_estab trust_estab,
            PROF.child_support_paid child_support_paid,
            PROF.med_dent_expenses med_dent_expenses,
            PROF.vet_us vet_us,
            PROF.vet_ben_amount vet_ben_amount,
            PROF.vet_ben_months vet_ben_months,
            PROF.stu_summer_wages stu_summer_wages,
            PROF.stu_school_yr_wages stu_school_yr_wages,
            PROF.spouse_summer_wages spouse_summer_wages,
            PROF.spouse_school_yr_wages spouse_school_yr_wages,
            PROF.summer_other_tax_inc summer_other_tax_inc,
            PROF.school_yr_other_tax_inc school_yr_other_tax_inc,
            PROF.summer_untax_inc summer_untax_inc,
            PROF.school_yr_untax_inc school_yr_untax_inc,
            PROF.grants_schol_etc grants_schol_etc,
            PROF.tuit_benefits tuit_benefits,
            PROF.cont_parents cont_parents,
            PROF.cont_relatives cont_relatives,
            PROF.p_siblings_pre_tuit p_siblings_pre_tuit,
            PROF.p_student_pre_tuit p_student_pre_tuit,
            PROF.p_household_size p_household_size,
            PROF.p_number_in_college p_number_in_college,
            PROF.p_parents_in_college p_parents_in_college,
            PROF.p_marital_status p_marital_status,
            PROF.p_state_legal_residence p_state_legal_residence,
            PROF.p_natural_par_status p_natural_par_status,
            PROF.p_child_supp_paid p_child_supp_paid,
            PROF.p_repay_ed_loans p_repay_ed_loans,
            PROF.p_med_dent_expenses p_med_dent_expenses,
            PROF.p_tuit_paid_amount p_tuit_paid_amount,
            PROF.p_tuit_paid_number p_tuit_paid_number,
            PROF.p_exp_child_supp_paid p_exp_child_supp_paid,
            PROF.p_exp_repay_ed_loans p_exp_repay_ed_loans,
            PROF.p_exp_med_dent_expenses p_exp_med_dent_expenses,
            PROF.p_exp_tuit_pd_amount p_exp_tuit_pd_amount,
            PROF.p_exp_tuit_pd_number p_exp_tuit_pd_number,
            PROF.p_cash_sav_check p_cash_sav_check,
            PROF.p_month_mortgage_pay p_month_mortgage_pay,
            PROF.p_invest_value p_invest_value,
            PROF.p_invest_debt p_invest_debt,
            PROF.p_home_value p_home_value,
            PROF.p_home_debt p_home_debt,
            PROF.p_home_purch_price p_home_purch_price,
            PROF.p_own_business_farm p_own_business_farm,
            PROF.p_business_value p_business_value,
            PROF.p_business_debt p_business_debt,
            PROF.p_farm_value p_farm_value,
            PROF.p_farm_debt p_farm_debt,
            PROF.p_live_on_farm p_live_on_farm,
            PROF.p_oth_real_estate_value p_oth_real_estate_value,
            PROF.p_oth_real_estate_debt p_oth_real_estate_debt,
            PROF.p_oth_real_purch_price p_oth_real_purch_price,
            PROF.p_siblings_assets p_siblings_assets,
            PROF.p_home_purch_year p_home_purch_year,
            PROF.p_oth_real_purch_year p_oth_real_purch_year,
            PROF.p_prior_agi p_prior_agi,
            PROF.p_prior_us_tax_paid p_prior_us_tax_paid,
            PROF.p_prior_item_deductions p_prior_item_deductions,
            PROF.p_prior_other_untax_inc p_prior_other_untax_inc,
            PROF.p_tax_figures p_tax_figures,
            PROF.p_number_exemptions p_number_exemptions,
            PROF.p_adjusted_gross_inc p_adjusted_gross_inc,
            PROF.p_wages_sal_tips p_wages_sal_tips,
            PROF.p_interest_income p_interest_income,
            PROF.p_dividend_income p_dividend_income,
            PROF.p_net_inc_bus_farm p_net_inc_bus_farm,
            PROF.p_other_taxable_income p_other_taxable_income,
            PROF.p_adj_to_income p_adj_to_income,
            PROF.p_us_tax_paid p_us_tax_paid,
            PROF.p_itemized_deductions p_itemized_deductions,
            PROF.p_father_income_work p_father_income_work,
            PROF.p_mother_income_work p_mother_income_work,
            PROF.p_soc_sec_ben p_soc_sec_ben,
            PROF.p_welfare_tanf p_welfare_tanf,
            PROF.p_child_supp_rcvd p_child_supp_rcvd,
            PROF.p_ded_ira_keogh p_ded_ira_keogh,
            PROF.p_tax_defer_pens_savs p_tax_defer_pens_savs,
            PROF.p_dep_care_med_spending p_dep_care_med_spending,
            PROF.p_earned_income_credit p_earned_income_credit,
            PROF.p_living_allow p_living_allow,
            PROF.p_tax_exmpt_int p_tax_exmpt_int,
            PROF.p_foreign_inc_excl p_foreign_inc_excl,
            PROF.p_other_untax_inc p_other_untax_inc,
            PROF.p_hope_ll_credit p_hope_ll_credit,
            PROF.p_yr_separation p_yr_separation,
            PROF.p_yr_divorce p_yr_divorce,
            PROF.p_exp_father_inc p_exp_father_inc,
            PROF.p_exp_mother_inc p_exp_mother_inc,
            PROF.p_exp_other_tax_inc p_exp_other_tax_inc,
            PROF.p_exp_other_untax_inc p_exp_other_untax_inc,
            PROF.line_2_relation line_2_relation,
            PROF.line_2_attend_college line_2_attend_college,
            PROF.line_3_relation line_3_relation,
            PROF.line_3_attend_college line_3_attend_college,
            PROF.line_4_relation line_4_relation,
            PROF.line_4_attend_college line_4_attend_college,
            PROF.line_5_relation line_5_relation,
            PROF.line_5_attend_college line_5_attend_college,
            PROF.line_6_relation line_6_relation,
            PROF.line_6_attend_college line_6_attend_college,
            PROF.line_7_relation line_7_relation,
            PROF.line_7_attend_college line_7_attend_college,
            PROF.line_8_relation line_8_relation,
            PROF.line_8_attend_college line_8_attend_college,
            PROF.p_age_father p_age_father,
            PROF.p_age_mother p_age_mother,
            PROF.p_div_sep_ind p_div_sep_ind,
            PROF.b_cont_non_custodial_par b_cont_non_custodial_par,
            PROF.college_type_2 college_type_2,
            PROF.college_type_3 college_type_3,
            PROF.college_type_4 college_type_4,
            PROF.college_type_5 college_type_5,
            PROF.college_type_6 college_type_6,
            PROF.college_type_7 college_type_7,
            PROF.college_type_8 college_type_8,
            PROF.school_code_1 school_code_1,
            PROF.housing_code_1 housing_code_1,
            PROF.school_code_2 school_code_2,
            PROF.housing_code_2 housing_code_2,
            PROF.school_code_3 school_code_3,
            PROF.housing_code_3 housing_code_3,
            PROF.school_code_4 school_code_4,
            PROF.housing_code_4 housing_code_4,
            PROF.school_code_5 school_code_5,
            PROF.housing_code_5 housing_code_5,
            PROF.school_code_6 school_code_6,
            PROF.housing_code_6 housing_code_6,
            PROF.school_code_7 school_code_7,
            PROF.housing_code_7 housing_code_7,
            PROF.school_code_8 school_code_8,
            PROF.housing_code_8 housing_code_8,
            PROF.school_code_9 school_code_9,
            PROF.housing_code_9 housing_code_9,
            PROF.school_code_10 school_code_10,
            PROF.housing_code_10 housing_code_10,
            PROF.additional_school_code_1 additional_school_code_1,
            PROF.additional_school_code_2 additional_school_code_2,
            PROF.additional_school_code_3 additional_school_code_3,
            PROF.additional_school_code_4 additional_school_code_4,
            PROF.additional_school_code_5 additional_school_code_5,
            PROF.additional_school_code_6 additional_school_code_6,
            PROF.additional_school_code_7 additional_school_code_7,
            PROF.additional_school_code_8 additional_school_code_8,
            PROF.additional_school_code_9 additional_school_code_9,
            PROF.additional_school_code_10 additional_school_code_10,
            PROF.explanation_spec_circum explanation_spec_circum,
            PROF.signature_student signature_student,
            PROF.signature_spouse signature_spouse,
            PROF.signature_father signature_father,
            PROF.signature_mother signature_mother,
            PROF.month_day_completed month_day_completed,
            PROF.year_completed year_completed,
            PROF.age_line_2 age_line_2,
            PROF.age_line_3 age_line_3,
            PROF.age_line_4 age_line_4,
            PROF.age_line_5 age_line_5,
            PROF.age_line_6 age_line_6,
            PROF.age_line_7 age_line_7,
            PROF.age_line_8 age_line_8,
            PROF.a_online_signature a_online_signature,
            PROF.question_1_number question_1_number,
            PROF.question_1_size question_1_size,
            PROF.question_1_answer question_1_answer,
            PROF.question_2_number question_2_number,
            PROF.question_2_size question_2_size,
            PROF.question_2_answer question_2_answer,
            PROF.question_3_number question_3_number,
            PROF.question_3_size question_3_size,
            PROF.question_3_answer question_3_answer,
            PROF.question_4_number question_4_number,
            PROF.question_4_size question_4_size,
            PROF.question_4_answer question_4_answer,
            PROF.question_5_number question_5_number,
            PROF.question_5_size question_5_size,
            PROF.question_5_answer question_5_answer,
            PROF.question_6_number question_6_number,
            PROF.question_6_size question_6_size,
            PROF.question_6_answer question_6_answer,
            PROF.question_7_number question_7_number,
            PROF.question_7_size question_7_size,
            PROF.question_7_answer question_7_answer,
            PROF.question_8_number question_8_number,
            PROF.question_8_size question_8_size,
            PROF.question_8_answer question_8_answer,
            PROF.question_9_number question_9_number,
            PROF.question_9_size question_9_size,
            PROF.question_9_answer question_9_answer,
            PROF.question_10_number question_10_number,
            PROF.question_10_size question_10_size,
            PROF.question_10_answer question_10_answer,
            PROF.question_11_number question_11_number,
            PROF.question_11_size question_11_size,
            PROF.question_11_answer question_11_answer,
            PROF.question_12_number question_12_number,
            PROF.question_12_size question_12_size,
            PROF.question_12_answer question_12_answer,
            PROF.question_13_number question_13_number,
            PROF.question_13_size question_13_size,
            PROF.question_13_answer question_13_answer,
            PROF.question_14_number question_14_number,
            PROF.question_14_size question_14_size,
            PROF.question_14_answer question_14_answer,
            PROF.question_15_number question_15_number,
            PROF.question_15_size question_15_size,
            PROF.question_15_answer question_15_answer,
            PROF.question_16_number question_16_number,
            PROF.question_16_size question_16_size,
            PROF.question_16_answer question_16_answer,
            PROF.question_17_number question_17_number,
            PROF.question_17_size question_17_size,
            PROF.question_17_answer question_17_answer,
            PROF.question_18_number question_18_number,
            PROF.question_18_size question_18_size,
            PROF.question_18_answer question_18_answer,
            PROF.question_19_number question_19_number,
            PROF.question_19_size question_19_size,
            PROF.question_19_answer question_19_answer,
            PROF.question_20_number question_20_number,
            PROF.question_20_size question_20_size,
            PROF.question_20_answer question_20_answer,
            PROF.question_21_number question_21_number,
            PROF.question_21_size question_21_size,
            PROF.question_21_answer question_21_answer,
            PROF.question_22_number question_22_number,
            PROF.question_22_size question_22_size,
            PROF.question_22_answer question_22_answer,
            PROF.question_23_number question_23_number,
            PROF.question_23_size question_23_size,
            PROF.question_23_answer question_23_answer,
            PROF.question_24_number question_24_number,
            PROF.question_24_size question_24_size,
            PROF.question_24_answer question_24_answer,
            PROF.question_25_number question_25_number,
            PROF.question_25_size question_25_size,
            PROF.question_25_answer question_25_answer,
            PROF.question_26_number question_26_number,
            PROF.question_26_size question_26_size,
            PROF.question_26_answer question_26_answer,
            PROF.question_27_number question_27_number,
            PROF.question_27_size question_27_size,
            PROF.question_27_answer question_27_answer,
            PROF.question_28_number question_28_number,
            PROF.question_28_size question_28_size,
            PROF.question_28_answer question_28_answer,
            PROF.question_29_number question_29_number,
            PROF.question_29_size question_29_size,
            PROF.question_29_answer question_29_answer,
            PROF.question_30_number question_30_number,
            PROF.questions_30_size questions_30_size,
            PROF.question_30_answer question_30_answer,
            PROF.legacy_record_flag legacy_record_flag,
            PROF.coa_duration_efc_amt,
            PROF.coa_duration_num,
            PROF.p_soc_sec_ben_student_amt,
            PROF.p_tuit_fee_deduct_amt,
            PROF.stu_lives_with_num,
            PROF.stu_most_support_from_num,
            PROF.location_computer_num
    FROM   igf_ap_css_profile_all PROF
    WHERE  PROF.base_id = cp_base_id
    AND    PROF.academic_year = cp_academic_year
    AND    PROF.css_id_number = cp_css_id_number
    AND    PROF.system_record_type = cp_rec_type;


    l_get_prof_rec  c_get_prof_rec%ROWTYPE;

    CURSOR c_old_act_prof(cp_base_id NUMBER,
                          cp_rec_type VARCHAR2)
    IS
    SELECT PROF.row_id row_id
    FROM   igf_ap_css_profile PROF
    WHERE  PROF.base_id = cp_base_id
    AND    PROF.active_profile = 'Y'
    AND    PROF.system_record_type = cp_rec_type;

    l_old_act_prof  c_old_act_prof%ROWTYPE;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

    l_error := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_chk_profile := igf_ap_gen.check_profile;
    IF l_chk_profile = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'PROFILE');
    IF l_chk_batch = 'N' THEN
      fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
       add_log_table_process(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;
    -- this is to get the alternate code
    l_get_alternate_code := NULL;
    OPEN  c_get_alternate_code(l_cal_type,l_seq_number);
    FETCH c_get_alternate_code INTO l_get_alternate_code;
    CLOSE c_get_alternate_code;

    -- this is to check that the award year is valid or not
    l_get_status := NULL;
    OPEN  c_get_status(l_cal_type,l_seq_number);
    FETCH c_get_status INTO l_get_status;
    CLOSE c_get_status;

    IF l_get_status.award_year_status_code NOT IN ('O','LD') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',l_get_status.award_year_status_code);
      add_log_table_process(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;
    IF l_terminate_flag = TRUE THEN
      print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);
      RETURN;
    END IF;

    OPEN c_get_dup_person(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      FETCH c_get_dup_person INTO l_get_dup_person;
      EXIT WHEN c_get_dup_person%NOTFOUND;
      g_per_tab(l_index) := l_get_dup_person.person_number;
      l_index := l_index + 1;
    END LOOP;
    CLOSE c_get_dup_person;

    -- THE MAIN LOOP STARTS HERE FOR FETCHING THE RECORD FROM THE INTERFACE TABLE
    -- IF MORE THAN PROFILE RECORD PER STUDENT IS ENTERED THEN THE PERSON IS TO BE SKIPPED ENTIRELY
    OPEN c_get_records(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      BEGIN
      SAVEPOINT sp1;
      FETCH c_get_records INTO l_get_records;
      EXIT WHEN c_get_records%NOTFOUND OR c_get_records%NOTFOUND IS NULL;
       l_debug_str := 'Csaint_id is:' || l_get_records.csaint_id;
     -- here the check is there to see if the person number is repetitive so skip the person
      IF NOT check_dup_person(l_get_records.person_number) THEN
        lv_base_id := NULL;
        lv_person_id := NULL;
        igf_ap_gen.check_person(l_get_records.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
        IF lv_person_id IS NULL THEN
           fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
           add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
           l_error_flag := TRUE;
        ELSE
          IF lv_base_id IS NULL THEN
            fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
            add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
            l_error_flag := TRUE;
          ELSE
             l_debug_str := l_debug_str || ' Person and Base ID check passed';
            -- here the academic year validation is done it shd correspond to the award year
            IF l_get_records.academic_year_txt <> NVL(l_get_status.css_academic_year,-1) THEN
               fnd_message.set_name('IGF','IGF_AP_AW_BATCH_NOT_EXISTS');
               add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
               l_error_flag := TRUE;

            ELSE
             l_chk_prof_rec_legacy := NULL;
             OPEN  c_chk_prof_rec_legacy(lv_base_id,l_get_records.academic_year_txt);
             FETCH c_chk_prof_rec_legacy INTO l_chk_prof_rec_legacy;
             CLOSE c_chk_prof_rec_legacy;
             IF l_chk_prof_rec_legacy.row_id IS NOT NULL THEN
               fnd_message.set_name('IGF','IGF_AP_NON_LI_PROF_EXISTS');
               add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
               l_error_flag := TRUE;
             ELSE -- THIS MEANS THE THERE IS PROFILE IS IMPORTED BY LEGACY ONLY
                 l_debug_str := l_debug_str || ' Legacy PROFILE check passed';
                 l_get_prof_rec := NULL;
                 OPEN  c_get_prof_rec(lv_base_id,l_get_records.academic_year_txt,l_get_records.css_id_number_txt,'ORIGINAL');
                 FETCH c_get_prof_rec INTO l_get_prof_rec;
                 CLOSE c_get_prof_rec;
                 IF l_get_prof_rec.row_id IS NULL THEN
                   fnd_message.set_name('IGF','IGF_AP_NO_PROF_RECS_EXIST');
                   add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                   l_error_flag := TRUE;
                 ELSE
                   l_debug_str := l_debug_str || ' PROFILE record exists check passed';
                   -- HERE GET THE VALUE OF THE EFC FROM THE OTHER PROFILE TABLE IGF_AP_CSS_FNAR
                    l_get_efc := NULL;
                    OPEN  c_get_efc(l_get_prof_rec.cssp_id);
                    FETCH c_get_efc INTO l_get_efc;
                    CLOSE c_get_efc;
                   IF l_get_efc.fm_inst_1_federal_efc IS NULL THEN
                     fnd_message.set_name('IGF','IGF_AP_PROF_INVALID_EFC');
                     add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                     l_error_flag := TRUE;
                   ELSE
                      l_debug_str := l_debug_str || ' FM_INST_FEDERAL_EFC check passed';
                     l_old_act_prof := NULL;
                     OPEN  c_old_act_prof(lv_base_id,'ORIGINAL');
                     FETCH c_old_act_prof INTO l_old_act_prof;
                     CLOSE c_old_act_prof;
                     IF l_old_act_prof.row_id IS NOT NULL THEN
                       fnd_message.set_name('IGF','IGF_AP_REC_ALREADY_ACT');
                       add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                       l_error_flag := TRUE;
                     ELSE
                      -- update_profile_rec(l_get_prof_rec);
                         igf_ap_css_profile_pkg.update_row (
                         x_mode                              => 'R',
                         x_rowid                             => l_get_prof_rec.row_id,
                         x_cssp_id                           => l_get_prof_rec.cssp_id,
                         x_base_id                           => l_get_prof_rec.base_id,
                         x_system_record_type                => l_get_prof_rec.system_record_type,
                         x_active_profile                    => 'Y',
                         x_college_code                      => l_get_prof_rec.college_code,
                         x_academic_year                     => l_get_prof_rec.academic_year,
                         x_stu_record_type                   => l_get_prof_rec.stu_record_type,
                         x_css_id_number                     => l_get_prof_rec.css_id_number,
                         x_registration_receipt_date         => l_get_prof_rec.registration_receipt_date,
                         x_registration_type                 => l_get_prof_rec.registration_type,
                         x_application_receipt_date          => l_get_prof_rec.application_receipt_date,
                         x_application_type                  => l_get_prof_rec.application_type,
                         x_original_fnar_compute             => l_get_prof_rec.original_fnar_compute,
                         x_revision_fnar_compute_date        => l_get_prof_rec.revision_fnar_compute_date,
                         x_electronic_extract_date           => l_get_prof_rec.electronic_extract_date,
                         x_institutional_reporting_type      => l_get_prof_rec.institutional_reporting_type,
                         x_asr_receipt_date                  => l_get_prof_rec.asr_receipt_date,
                         x_last_name                         => l_get_prof_rec.last_name,
                         x_first_name                        => l_get_prof_rec.first_name,
                         x_middle_initial                    => l_get_prof_rec.middle_initial,
                         x_address_number_and_street         => l_get_prof_rec.address_number_and_street,
                         x_city                              => l_get_prof_rec.city,
                         x_state_mailing                     => l_get_prof_rec.state_mailing,
                         x_zip_code                          => l_get_prof_rec.zip_code,
                         x_s_telephone_number                => l_get_prof_rec.s_telephone_number,
                         x_s_title                           => l_get_prof_rec.s_title,
                         x_date_of_birth                     => l_get_prof_rec.date_of_birth,
                         x_social_security_number            => l_get_prof_rec.social_security_number,
                         x_state_legal_residence             => l_get_prof_rec.state_legal_residence,
                         x_foreign_address_indicator         => l_get_prof_rec.foreign_address_indicator,
                         x_foreign_postal_code               => l_get_prof_rec.foreign_postal_code,
                         x_country                           => l_get_prof_rec.country,
                         x_financial_aid_status              => l_get_prof_rec.financial_aid_status,
                         x_year_in_college                   => l_get_prof_rec.year_in_college,
                         x_marital_status                    => l_get_prof_rec.marital_status,
                         x_ward_court                        => l_get_prof_rec.ward_court,
                         x_legal_dependents_other            => l_get_prof_rec.legal_dependents_other,
                         x_household_size                    => l_get_prof_rec.household_size,
                         x_number_in_college                 => l_get_prof_rec.number_in_college,
                         x_citizenship_status                => l_get_prof_rec.citizenship_status,
                         x_citizenship_country               => l_get_prof_rec.citizenship_country,
                         x_visa_classification               => l_get_prof_rec.visa_classification,
                         x_tax_figures                       => l_get_prof_rec.tax_figures,
                         x_number_exemptions                 => l_get_prof_rec.number_exemptions,
                         x_adjusted_gross_inc                => l_get_prof_rec.adjusted_gross_inc,
                         x_us_tax_paid                       => l_get_prof_rec.us_tax_paid,
                         x_itemized_deductions               => l_get_prof_rec.itemized_deductions,
                         x_stu_income_work                   => l_get_prof_rec.stu_income_work,
                         x_spouse_income_work                => l_get_prof_rec.spouse_income_work,
                         x_divid_int_inc                     => l_get_prof_rec.divid_int_inc,
                         x_soc_sec_benefits                  => l_get_prof_rec.soc_sec_benefits,
                         x_welfare_tanf                      => l_get_prof_rec.welfare_tanf,
                         x_child_supp_rcvd                   => l_get_prof_rec.child_supp_rcvd,
                         x_earned_income_credit              => l_get_prof_rec.earned_income_credit,
                         x_other_untax_income                => l_get_prof_rec.other_untax_income,
                         x_tax_stu_aid                       => l_get_prof_rec.tax_stu_aid,
                         x_cash_sav_check                    => l_get_prof_rec.cash_sav_check,
                         x_ira_keogh                         => l_get_prof_rec.ira_keogh,
                         x_invest_value                      => l_get_prof_rec.invest_value,
                         x_invest_debt                       => l_get_prof_rec.invest_debt,
                         x_home_value                        => l_get_prof_rec.home_value,
                         x_home_debt                         => l_get_prof_rec.home_debt,
                         x_oth_real_value                    => l_get_prof_rec.oth_real_value,
                         x_oth_real_debt                     => l_get_prof_rec.oth_real_debt,
                         x_bus_farm_value                    => l_get_prof_rec.bus_farm_value,
                         x_bus_farm_debt                     => l_get_prof_rec.bus_farm_debt,
                         x_live_on_farm                      => l_get_prof_rec.live_on_farm,
                         x_home_purch_price                  => l_get_prof_rec.home_purch_price,
                         x_hope_ll_credit                    => l_get_prof_rec.hope_ll_credit,
                         x_home_purch_year                   => l_get_prof_rec.home_purch_year,
                         x_trust_amount                      => l_get_prof_rec.trust_amount,
                         x_trust_avail                       => l_get_prof_rec.trust_avail,
                         x_trust_estab                       => l_get_prof_rec.trust_estab,
                         x_child_support_paid                => l_get_prof_rec.child_support_paid,
                         x_med_dent_expenses                 => l_get_prof_rec.med_dent_expenses,
                         x_vet_us                            => l_get_prof_rec.vet_us,
                         x_vet_ben_amount                    => l_get_prof_rec.vet_ben_amount,
                         x_vet_ben_months                    => l_get_prof_rec.vet_ben_months,
                         x_stu_summer_wages                  => l_get_prof_rec.stu_summer_wages,
                         x_stu_school_yr_wages               => l_get_prof_rec.stu_school_yr_wages,
                         x_spouse_summer_wages               => l_get_prof_rec.spouse_summer_wages,
                         x_spouse_school_yr_wages            => l_get_prof_rec.spouse_school_yr_wages,
                         x_summer_other_tax_inc              => l_get_prof_rec.summer_other_tax_inc,
                         x_school_yr_other_tax_inc           => l_get_prof_rec.school_yr_other_tax_inc,
                         x_summer_untax_inc                  => l_get_prof_rec.summer_untax_inc,
                         x_school_yr_untax_inc               => l_get_prof_rec.school_yr_untax_inc,
                         x_grants_schol_etc                  => l_get_prof_rec.grants_schol_etc,
                         x_tuit_benefits                     => l_get_prof_rec.tuit_benefits,
                         x_cont_parents                      => l_get_prof_rec.cont_parents,
                         x_cont_relatives                    => l_get_prof_rec.cont_relatives,
                         x_p_siblings_pre_tuit               => l_get_prof_rec.p_siblings_pre_tuit,
                         x_p_student_pre_tuit                => l_get_prof_rec.p_student_pre_tuit,
                         x_p_household_size                  => l_get_prof_rec.p_household_size,
                         x_p_number_in_college               => l_get_prof_rec.p_number_in_college,
                         x_p_parents_in_college              => l_get_prof_rec.p_parents_in_college,
                         x_p_marital_status                  => l_get_prof_rec.p_marital_status,
                         x_p_state_legal_residence           => l_get_prof_rec.p_state_legal_residence,
                         x_p_natural_par_status              => l_get_prof_rec.p_natural_par_status,
                         x_p_child_supp_paid                 => l_get_prof_rec.p_child_supp_paid,
                         x_p_repay_ed_loans                  => l_get_prof_rec.p_repay_ed_loans,
                         x_p_med_dent_expenses               => l_get_prof_rec.p_med_dent_expenses,
                         x_p_tuit_paid_amount                => l_get_prof_rec.p_tuit_paid_amount,
                         x_p_tuit_paid_number                => l_get_prof_rec.p_tuit_paid_number,
                         x_p_exp_child_supp_paid             => l_get_prof_rec.p_exp_child_supp_paid,
                         x_p_exp_repay_ed_loans              => l_get_prof_rec.p_exp_repay_ed_loans,
                         x_p_exp_med_dent_expenses           => l_get_prof_rec.p_exp_med_dent_expenses,
                         x_p_exp_tuit_pd_amount              => l_get_prof_rec.p_exp_tuit_pd_amount,
                         x_p_exp_tuit_pd_number              => l_get_prof_rec.p_exp_tuit_pd_number,
                         x_p_cash_sav_check                  => l_get_prof_rec.p_cash_sav_check,
                         x_p_month_mortgage_pay              => l_get_prof_rec.p_month_mortgage_pay,
                         x_p_invest_value                    => l_get_prof_rec.p_invest_value,
                         x_p_invest_debt                     => l_get_prof_rec.p_invest_debt,
                         x_p_home_value                      => l_get_prof_rec.p_home_value,
                         x_p_home_debt                       => l_get_prof_rec.p_home_debt,
                         x_p_home_purch_price                => l_get_prof_rec.p_home_purch_price,
                         x_p_own_business_farm               => l_get_prof_rec.p_own_business_farm,
                         x_p_business_value                  => l_get_prof_rec.p_business_value,
                         x_p_business_debt                   => l_get_prof_rec.p_business_debt,
                         x_p_farm_value                      => l_get_prof_rec.p_farm_value,
                         x_p_farm_debt                       => l_get_prof_rec.p_farm_debt,
                         x_p_live_on_farm                    => l_get_prof_rec.p_live_on_farm,
                         x_p_oth_real_estate_value           => l_get_prof_rec.p_oth_real_estate_value,
                         x_p_oth_real_estate_debt            => l_get_prof_rec.p_oth_real_estate_debt,
                         x_p_oth_real_purch_price            => l_get_prof_rec.p_oth_real_purch_price,
                         x_p_siblings_assets                 => l_get_prof_rec.p_siblings_assets,
                         x_p_home_purch_year                 => l_get_prof_rec.p_home_purch_year,
                         x_p_oth_real_purch_year             => l_get_prof_rec.p_oth_real_purch_year,
                         x_p_prior_agi                       => l_get_prof_rec.p_prior_agi,
                         x_p_prior_us_tax_paid               => l_get_prof_rec.p_prior_us_tax_paid,
                         x_p_prior_item_deductions           => l_get_prof_rec.p_prior_item_deductions,
                         x_p_prior_other_untax_inc           => l_get_prof_rec.p_prior_other_untax_inc,
                         x_p_tax_figures                     => l_get_prof_rec.p_tax_figures,
                         x_p_number_exemptions               => l_get_prof_rec.p_number_exemptions,
                         x_p_adjusted_gross_inc              => l_get_prof_rec.p_adjusted_gross_inc,
                         x_p_wages_sal_tips                  => l_get_prof_rec.p_wages_sal_tips,
                         x_p_interest_income                 => l_get_prof_rec.p_interest_income,
                         x_p_dividend_income                 => l_get_prof_rec.p_dividend_income,
                         x_p_net_inc_bus_farm                => l_get_prof_rec.p_net_inc_bus_farm,
                         x_p_other_taxable_income            => l_get_prof_rec.p_other_taxable_income,
                         x_p_adj_to_income                   => l_get_prof_rec.p_adj_to_income,
                         x_p_us_tax_paid                     => l_get_prof_rec.p_us_tax_paid,
                         x_p_itemized_deductions             => l_get_prof_rec.p_itemized_deductions,
                         x_p_father_income_work              => l_get_prof_rec.p_father_income_work,
                         x_p_mother_income_work              => l_get_prof_rec.p_mother_income_work,
                         x_p_soc_sec_ben                     => l_get_prof_rec.p_soc_sec_ben,
                         x_p_welfare_tanf                    => l_get_prof_rec.p_welfare_tanf,
                         x_p_child_supp_rcvd                 => l_get_prof_rec.p_child_supp_rcvd,
                         x_p_ded_ira_keogh                   => l_get_prof_rec.p_ded_ira_keogh,
                         x_p_tax_defer_pens_savs             => l_get_prof_rec.p_tax_defer_pens_savs,
                         x_p_dep_care_med_spending           => l_get_prof_rec.p_dep_care_med_spending,
                         x_p_earned_income_credit            => l_get_prof_rec.p_earned_income_credit,
                         x_p_living_allow                    => l_get_prof_rec.p_living_allow,
                         x_p_tax_exmpt_int                   => l_get_prof_rec.p_tax_exmpt_int,
                         x_p_foreign_inc_excl                => l_get_prof_rec.p_foreign_inc_excl,
                         x_p_other_untax_inc                 => l_get_prof_rec.p_other_untax_inc,
                         x_p_hope_ll_credit                  => l_get_prof_rec.p_hope_ll_credit,
                         x_p_yr_separation                   => l_get_prof_rec.p_yr_separation,
                         x_p_yr_divorce                      => l_get_prof_rec.p_yr_divorce,
                         x_p_exp_father_inc                  => l_get_prof_rec.p_exp_father_inc,
                         x_p_exp_mother_inc                  => l_get_prof_rec.p_exp_mother_inc,
                         x_p_exp_other_tax_inc               => l_get_prof_rec.p_exp_other_tax_inc,
                         x_p_exp_other_untax_inc             => l_get_prof_rec.p_exp_other_untax_inc,
                         x_line_2_relation                   => l_get_prof_rec.line_2_relation,
                         x_line_2_attend_college             => l_get_prof_rec.line_2_attend_college,
                         x_line_3_relation                   => l_get_prof_rec.line_3_relation,
                         x_line_3_attend_college             => l_get_prof_rec.line_3_attend_college,
                         x_line_4_relation                   => l_get_prof_rec.line_4_relation,
                         x_line_4_attend_college             => l_get_prof_rec.line_4_attend_college,
                         x_line_5_relation                   => l_get_prof_rec.line_5_relation,
                         x_line_5_attend_college             => l_get_prof_rec.line_5_attend_college,
                         x_line_6_relation                   => l_get_prof_rec.line_6_relation,
                         x_line_6_attend_college             => l_get_prof_rec.line_6_attend_college,
                         x_line_7_relation                   => l_get_prof_rec.line_7_relation,
                         x_line_7_attend_college             => l_get_prof_rec.line_7_attend_college,
                         x_line_8_relation                   => l_get_prof_rec.line_8_relation,
                         x_line_8_attend_college             => l_get_prof_rec.line_8_attend_college,
                         x_p_age_father                      => l_get_prof_rec.p_age_father,
                         x_p_age_mother                      => l_get_prof_rec.p_age_mother,
                         x_p_div_sep_ind                     => l_get_prof_rec.p_div_sep_ind,
                         x_b_cont_non_custodial_par          => l_get_prof_rec.b_cont_non_custodial_par,
                         x_college_type_2                    => l_get_prof_rec.college_type_2,
                         x_college_type_3                    => l_get_prof_rec.college_type_3,
                         x_college_type_4                    => l_get_prof_rec.college_type_4,
                         x_college_type_5                    => l_get_prof_rec.college_type_5,
                         x_college_type_6                    => l_get_prof_rec.college_type_6,
                         x_college_type_7                    => l_get_prof_rec.college_type_7,
                         x_college_type_8                    => l_get_prof_rec.college_type_8,
                         x_school_code_1                     => l_get_prof_rec.school_code_1,
                         x_housing_code_1                    => l_get_prof_rec.housing_code_1,
                         x_school_code_2                     => l_get_prof_rec.school_code_2,
                         x_housing_code_2                    => l_get_prof_rec.housing_code_2,
                         x_school_code_3                     => l_get_prof_rec.school_code_3,
                         x_housing_code_3                    => l_get_prof_rec.housing_code_3,
                         x_school_code_4                     => l_get_prof_rec.school_code_4,
                         x_housing_code_4                    => l_get_prof_rec.housing_code_4,
                         x_school_code_5                     => l_get_prof_rec.school_code_5,
                         x_housing_code_5                    => l_get_prof_rec.housing_code_5,
                         x_school_code_6                     => l_get_prof_rec.school_code_6,
                         x_housing_code_6                    => l_get_prof_rec.housing_code_6,
                         x_school_code_7                     => l_get_prof_rec.school_code_7,
                         x_housing_code_7                    => l_get_prof_rec.housing_code_7,
                         x_school_code_8                     => l_get_prof_rec.school_code_8,
                         x_housing_code_8                    => l_get_prof_rec.housing_code_8,
                         x_school_code_9                     => l_get_prof_rec.school_code_9,
                         x_housing_code_9                    => l_get_prof_rec.housing_code_9,
                         x_school_code_10                    => l_get_prof_rec.school_code_10,
                         x_housing_code_10                   => l_get_prof_rec.housing_code_10,
                         x_additional_school_code_1          => l_get_prof_rec.additional_school_code_1,
                         x_additional_school_code_2          => l_get_prof_rec.additional_school_code_2,
                         x_additional_school_code_3          => l_get_prof_rec.additional_school_code_3,
                         x_additional_school_code_4          => l_get_prof_rec.additional_school_code_4,
                         x_additional_school_code_5          => l_get_prof_rec.additional_school_code_5,
                         x_additional_school_code_6          => l_get_prof_rec.additional_school_code_6,
                         x_additional_school_code_7          => l_get_prof_rec.additional_school_code_7,
                         x_additional_school_code_8          => l_get_prof_rec.additional_school_code_8,
                         x_additional_school_code_9          => l_get_prof_rec.additional_school_code_9,
                         x_additional_school_code_10         => l_get_prof_rec.additional_school_code_10,
                         x_explanation_spec_circum           => l_get_prof_rec.explanation_spec_circum,
                         x_signature_student                 => l_get_prof_rec.signature_student,
                         x_signature_spouse                  => l_get_prof_rec.signature_spouse,
                         x_signature_father                  => l_get_prof_rec.signature_father,
                         x_signature_mother                  => l_get_prof_rec.signature_mother,
                         x_month_day_completed               => l_get_prof_rec.month_day_completed,
                         x_year_completed                    => l_get_prof_rec.year_completed,
                         x_age_line_2                        => l_get_prof_rec.age_line_2,
                         x_age_line_3                        => l_get_prof_rec.age_line_3,
                         x_age_line_4                        => l_get_prof_rec.age_line_4,
                         x_age_line_5                        => l_get_prof_rec.age_line_5,
                         x_age_line_6                        => l_get_prof_rec.age_line_6,
                         x_age_line_7                        => l_get_prof_rec.age_line_7,
                         x_age_line_8                        => l_get_prof_rec.age_line_8,
                         x_a_online_signature                => l_get_prof_rec.a_online_signature,
                         x_question_1_number                 => l_get_prof_rec.question_1_number,
                         x_question_1_size                   => l_get_prof_rec.question_1_size,
                         x_question_1_answer                 => l_get_prof_rec.question_1_answer,
                         x_question_2_number                 => l_get_prof_rec.question_2_number,
                         x_question_2_size                   => l_get_prof_rec.question_2_size,
                         x_question_2_answer                 => l_get_prof_rec.question_2_answer,
                         x_question_3_number                 => l_get_prof_rec.question_3_number,
                         x_question_3_size                   => l_get_prof_rec.question_3_size,
                         x_question_3_answer                 => l_get_prof_rec.question_3_answer,
                         x_question_4_number                 => l_get_prof_rec.question_4_number,
                         x_question_4_size                   => l_get_prof_rec.question_4_size,
                         x_question_4_answer                 => l_get_prof_rec.question_4_answer,
                         x_question_5_number                 => l_get_prof_rec.question_5_number,
                         x_question_5_size                   => l_get_prof_rec.question_5_size,
                         x_question_5_answer                 => l_get_prof_rec.question_5_answer,
                         x_question_6_number                 => l_get_prof_rec.question_6_number,
                         x_question_6_size                   => l_get_prof_rec.question_6_size,
                         x_question_6_answer                 => l_get_prof_rec.question_6_answer,
                         x_question_7_number                 => l_get_prof_rec.question_7_number,
                         x_question_7_size                   => l_get_prof_rec.question_7_size,
                         x_question_7_answer                 => l_get_prof_rec.question_7_answer,
                         x_question_8_number                 => l_get_prof_rec.question_8_number,
                         x_question_8_size                   => l_get_prof_rec.question_8_size,
                         x_question_8_answer                 => l_get_prof_rec.question_8_answer,
                         x_question_9_number                 => l_get_prof_rec.question_9_number,
                         x_question_9_size                   => l_get_prof_rec.question_9_size,
                         x_question_9_answer                 => l_get_prof_rec.question_9_answer,
                         x_question_10_number                => l_get_prof_rec.question_10_number,
                         x_question_10_size                  => l_get_prof_rec.question_10_size,
                         x_question_10_answer                => l_get_prof_rec.question_10_answer,
                         x_question_11_number                => l_get_prof_rec.question_11_number,
                         x_question_11_size                  => l_get_prof_rec.question_11_size,
                         x_question_11_answer                => l_get_prof_rec.question_11_answer,
                         x_question_12_number                => l_get_prof_rec.question_12_number,
                         x_question_12_size                  => l_get_prof_rec.question_12_size,
                         x_question_12_answer                => l_get_prof_rec.question_12_answer,
                         x_question_13_number                => l_get_prof_rec.question_13_number,
                         x_question_13_size                  => l_get_prof_rec.question_13_size,
                         x_question_13_answer                => l_get_prof_rec.question_13_answer,
                         x_question_14_number                => l_get_prof_rec.question_14_number,
                         x_question_14_size                  => l_get_prof_rec.question_14_size,
                         x_question_14_answer                => l_get_prof_rec.question_14_answer,
                         x_question_15_number                => l_get_prof_rec.question_15_number,
                         x_question_15_size                  => l_get_prof_rec.question_15_size,
                         x_question_15_answer                => l_get_prof_rec.question_15_answer,
                         x_question_16_number                => l_get_prof_rec.question_16_number,
                         x_question_16_size                  => l_get_prof_rec.question_16_size,
                         x_question_16_answer                => l_get_prof_rec.question_16_answer,
                         x_question_17_number                => l_get_prof_rec.question_17_number,
                         x_question_17_size                  => l_get_prof_rec.question_17_size,
                         x_question_17_answer                => l_get_prof_rec.question_17_answer,
                         x_question_18_number                => l_get_prof_rec.question_18_number,
                         x_question_18_size                  => l_get_prof_rec.question_18_size,
                         x_question_18_answer                => l_get_prof_rec.question_18_answer,
                         x_question_19_number                => l_get_prof_rec.question_19_number,
                         x_question_19_size                  => l_get_prof_rec.question_19_size,
                         x_question_19_answer                => l_get_prof_rec.question_19_answer,
                         x_question_20_number                => l_get_prof_rec.question_20_number,
                         x_question_20_size                  => l_get_prof_rec.question_20_size,
                         x_question_20_answer                => l_get_prof_rec.question_20_answer,
                         x_question_21_number                => l_get_prof_rec.question_21_number,
                         x_question_21_size                  => l_get_prof_rec.question_21_size,
                         x_question_21_answer                => l_get_prof_rec.question_21_answer,
                         x_question_22_number                => l_get_prof_rec.question_22_number,
                         x_question_22_size                  => l_get_prof_rec.question_22_size,
                         x_question_22_answer                => l_get_prof_rec.question_22_answer,
                         x_question_23_number                => l_get_prof_rec.question_23_number,
                         x_question_23_size                  => l_get_prof_rec.question_23_size,
                         x_question_23_answer                => l_get_prof_rec.question_23_answer,
                         x_question_24_number                => l_get_prof_rec.question_24_number,
                         x_question_24_size                  => l_get_prof_rec.question_24_size,
                         x_question_24_answer                => l_get_prof_rec.question_24_answer,
                         x_question_25_number                => l_get_prof_rec.question_25_number,
                         x_question_25_size                  => l_get_prof_rec.question_25_size,
                         x_question_25_answer                => l_get_prof_rec.question_25_answer,
                         x_question_26_number                => l_get_prof_rec.question_26_number,
                         x_question_26_size                  => l_get_prof_rec.question_26_size,
                         x_question_26_answer                => l_get_prof_rec.question_26_answer,
                         x_question_27_number                => l_get_prof_rec.question_27_number,
                         x_question_27_size                  => l_get_prof_rec.question_27_size,
                         x_question_27_answer                => l_get_prof_rec.question_27_answer,
                         x_question_28_number                => l_get_prof_rec.question_28_number,
                         x_question_28_size                  => l_get_prof_rec.question_28_size,
                         x_question_28_answer                => l_get_prof_rec.question_28_answer,
                         x_question_29_number                => l_get_prof_rec.question_29_number,
                         x_question_29_size                  => l_get_prof_rec.question_29_size,
                         x_question_29_answer                => l_get_prof_rec.question_29_answer,
                         x_question_30_number                => l_get_prof_rec.question_30_number,
                         x_questions_30_size                 => l_get_prof_rec.questions_30_size,
                         x_question_30_answer                => l_get_prof_rec.question_30_answer,
                         x_legacy_record_flag                => l_get_prof_rec.legacy_record_flag,
                         x_coa_duration_efc_amt              => l_get_prof_rec.coa_duration_efc_amt,
                         x_coa_duration_num                  => l_get_prof_rec.coa_duration_num,
                         x_p_soc_sec_ben_student_amt         => l_get_prof_rec.p_soc_sec_ben_student_amt,
                         x_p_tuit_fee_deduct_amt             => l_get_prof_rec.p_tuit_fee_deduct_amt,
                         x_stu_lives_with_num                => l_get_prof_rec.stu_lives_with_num,
                         x_stu_most_support_from_num         => l_get_prof_rec.stu_most_support_from_num,
                         x_location_computer_num             => l_get_prof_rec.location_computer_num
                         );


                        l_success_record_cnt := l_success_record_cnt + 1;
                     END IF;
                     l_debug_str := l_debug_str || ' Old PROFILE check passed';

                   END IF; -- for the efc null check
                 END IF;
               END IF; -- PROFILE IMPORTED BY LEGACY OR NOT
             END IF; -- THIS IS FOR THE ACADEMIC YEAR VALIDATION
            END IF; -- BASE ID EXISTS OR NOT
        END IF; -- PERSON EXISTS OR NOT

    ELSE
      fnd_message.set_name('IGF','IGF_AP_MK_ACT_PROF_SKIP');
      add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
      l_error_flag := TRUE;
    END IF; -- if the person is not duplicate
      IF l_error_flag = TRUE THEN
        l_error_flag := FALSE;
        l_error_record_cnt := l_error_record_cnt + 1;
        --update the legacy interface table column import_status to 'E'
        UPDATE igf_ap_li_css_act_ints
        SET import_status_type = 'E'
        WHERE ROWID = l_get_records.ROW_ID;
      ELSE
        IF p_del_ind = 'Y' THEN
           DELETE FROM igf_ap_li_css_act_ints
           WHERE ROWID = l_get_records.ROW_ID;
        ELSE
           --update the legacy interface table column import_status to 'I'
           UPDATE igf_ap_li_css_act_ints
           SET import_status_type = 'I'
           WHERE ROWID = l_get_records.ROW_ID;
        END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_mk_prof_act_pkg.lg_make_active_profile.debug',l_debug_str);
      END IF;
      l_process_flag := FALSE;
      l_debug_str := NULL;
      EXCEPTION
       WHEN others THEN
         l_process_flag := FALSE;
         l_debug_str := NULL;
         l_error_flag := FALSE;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_MK_PROF_ACT_PKG.LG_MAKE_ACTIVE_PROFILE');
         add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
         ROLLBACK TO sp1;
      END;
      COMMIT;
    END LOOP;
    CLOSE c_get_records;

    IF l_success_record_cnt = 0 AND l_error_record_cnt = 0 THEN
       fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
       add_log_table_process(NULL,l_error,fnd_message.get);
    END IF;

    -- CALL THE PRINT LOG PROCESS
    print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);

    l_total_record_cnt := l_success_record_cnt + l_error_record_cnt;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' || l_total_record_cnt);
    fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_success_record_cnt);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_error_record_cnt);
  EXCEPTION
        WHEN others THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_mk_prof_act_pkg.lg_make_active_profile.exception','Unhandled exception error:'||SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_MK_PROF_ACT_PKG.LG_MAKE_ACTIVE_PROFILE');
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;

  END lg_make_active_profile;

  FUNCTION check_dup_person(p_person_number  IN VARCHAR2)
  RETURN BOOLEAN
  IS
    /*
    ||  Created By : bkkumar
    ||  Created On :
    ||  Purpose : Routine will verify whether the person number is duplicate
    ||            in the interface table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    l_count NUMBER(5) := g_per_tab.COUNT;
  BEGIN
    FOR i IN 1..l_count LOOP
      IF g_per_tab(i) = p_person_number THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END;

  PROCEDURE add_log_table_process(
                                  p_person_number     IN VARCHAR2,
                                  p_error             IN VARCHAR2,
                                  p_message_str       IN VARCHAR2
                                 ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process adds a record to the global pl/sql table containing log messages
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

    g_log_tab_index := g_log_tab_index + 1;
    g_log_tab(g_log_tab_index).person_number := p_person_number;
    g_log_tab(g_log_tab_index).message_text := RPAD(p_error,12) || p_message_str;

  END add_log_table_process;

  PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_count NUMBER(5) := g_log_tab.COUNT;
    l_old_person igf_ap_li_css_act_ints.person_number%TYPE := '*******';

    l_person_number   VARCHAR2(80);
    l_batch_id        VARCHAR2(80);
    l_award_yr        VARCHAR2(80);
    l_batch_desc      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);

    CURSOR c_get_batch_desc(cp_batch_num NUMBER) IS
    SELECT batch_desc
      FROM igf_ap_li_bat_ints
     WHERE batch_num = cp_batch_num;

    l_get_batch_desc c_get_batch_desc%ROWTYPE;

  BEGIN

    l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_id      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_yr      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no        := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_del_ind);

    OPEN  c_get_batch_desc(p_batch_id);
    FETCH c_get_batch_desc INTO l_get_batch_desc;
    CLOSE c_get_batch_desc;
    l_batch_desc := l_get_batch_desc.batch_desc ;

     -- HERE THE INPUT PARAMETERS ARE TO BE LOGGED TO THE LOG FILE
    fnd_message.set_name('IGS','IGS_DA_JOB');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,RPAD(l_batch_id,50) || ' : ' || p_batch_id || ' - ' || l_batch_desc);
    fnd_file.put_line(fnd_file.log,RPAD(l_award_yr,50) || ' : ' || p_alternate_code);
    fnd_message.set_name('IGS','IGS_GE_ASK_DEL_REC');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get,50) || ' : ' || l_yes_no);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------------');

    FOR i IN 1..l_count LOOP
      IF g_log_tab(i).person_number IS NOT NULL THEN
        IF l_old_person <> g_log_tab(i).person_number THEN
          fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.log,l_person_number || ' : ' || g_log_tab(i).person_number);
        END IF;
        l_old_person := g_log_tab(i).person_number;
      END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
    END LOOP;

  END print_log_process;

END igf_ap_mk_prof_act_pkg;

/
