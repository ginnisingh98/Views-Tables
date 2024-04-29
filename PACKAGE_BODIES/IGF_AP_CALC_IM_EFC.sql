--------------------------------------------------------
--  DDL for Package Body IGF_AP_CALC_IM_EFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_CALC_IM_EFC" AS
/* $Header: IGFAP45B.pls 120.3 2006/02/08 23:35:52 ridas noship $ */
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 08-OCT-2003
  --
  --Purpose: This package calls the user hook for calculating IM EFC if INAS is integrated
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  -- Get person number
  CURSOR c_person_number(
                          cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties parties,
             igf_ap_fa_base_rec_all fabase
       WHERE fabase.person_id = parties.party_id
         AND fabase.base_id   = cp_base_id;

  l_person_number hz_parties.party_number%TYPE;

  g_tab_1 VARCHAR2(20) DEFAULT '    ';
  g_tab_2 VARCHAR2(20) DEFAULT '        ';

  g_success NUMBER := 0;
  g_error   NUMBER := 0;
  g_total   NUMBER := 0;

  PROCEDURE log_parameters(
                           p_cal_type        IN  igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                           p_sequence_number IN  igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                           p_base_id         IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_persid_grp      IN  igs_pe_persid_group_all.group_id%TYPE
                          ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 08-OCT-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  l_param_pass_log  igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');
  l_awd_yr_log      igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YEAR');
  l_pers_number_log igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_NUMBER');
  l_pers_id_grp_log igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_ID_GROUP');

  -- Get alternate code
  CURSOR c_alternate_code(
                           cp_cal_type   igs_ca_inst_all.cal_type%TYPE,
                           cp_seq_number igs_ca_inst_all.sequence_number%TYPE
                         ) IS
    SELECT alternate_code
      FROM igs_ca_inst_all
     WHERE cal_type        = cp_cal_type
       AND sequence_number = cp_seq_number;

  l_alternate_code igs_ca_inst_all.alternate_code%TYPE;

  -- Get get group description for group_id
  CURSOR c_person_group(
                        cp_persid_grp igs_pe_persid_group_all.group_id%TYPE
                       ) IS
    SELECT group_cd group_name
      FROM igs_pe_persid_group_all
     WHERE group_id = cp_persid_grp;

  l_persid_grp_name c_person_group%ROWTYPE;

  BEGIN
    fnd_file.put_line(fnd_file.log,l_param_pass_log);

    OPEN c_alternate_code(p_cal_type,p_sequence_number);
    FETCH c_alternate_code INTO l_alternate_code;
    CLOSE c_alternate_code;

    fnd_file.put_line(fnd_file.log,RPAD(l_awd_yr_log,40) || ' : ' || l_alternate_code);

    OPEN c_person_number(p_base_id);
    FETCH c_person_number INTO l_person_number;
    CLOSE c_person_number;

    OPEN c_person_group(p_persid_grp);
    FETCH c_person_group INTO l_persid_grp_name;
    CLOSE c_person_group;

    fnd_file.put_line(fnd_file.log,RPAD(l_pers_number_log,40) || ' : ' || l_person_number);
    fnd_file.put_line(fnd_file.log,RPAD(l_pers_id_grp_log,40) || ' : ' || l_persid_grp_name.group_name);
    fnd_file.put_line(fnd_file.log,RPAD('-',55,'-'));

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_CALC_IM_EFC.LOG_PARAMETERS '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END log_parameters;

  PROCEDURE calculate_efc(
                          p_cal_type   IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                          p_seq_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                          p_base_id    IN igf_ap_fa_base_rec_all.base_id%TYPE
                         ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 8-OCT-2003
  --
  --Purpose: This is the main procedure which calculates EFC by invoking the userhook for a given base_id
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- brajendr   2-Dec-2003      Bug # 3026594
  --                            Removed the Code to updated the FA Base record with the calculated ned
  -------------------------------------------------------------------

  l_internal_id_log igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','INTERNAL_ID') || ' ';
  l_fnar_rec_fnd    BOOLEAN := FALSE;

  -- Get all PROFILES of a given base_id
  CURSOR c_all_profiles(
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
    SELECT prof.*
      FROM igf_ap_css_profile prof
     WHERE base_id = cp_base_id;

  l_profile              c_all_profiles%ROWTYPE;

  -- Get fnar record for a PROFILE
  CURSOR c_fnar(
                 cp_cssp_id igf_ap_css_profile_all.cssp_id%TYPE
               ) IS
    SELECT fnar.*
      FROM igf_ap_css_fnar fnar
     WHERE cssp_id = cp_cssp_id;

  l_fnar                 igf_ap_css_fnar%ROWTYPE;

  l_efc_duration         igf_ap_css_profile_all.coa_duration_num%TYPE;
  l_coa_duration_efc_amt igf_ap_css_profile_all.coa_duration_efc_amt%TYPE;

  -- Get sys_award_year based on cal type and sequence number
  CURSOR c_award_year(
                      cp_cal_type   IN igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                      cp_seq_number IN igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                     ) IS
    SELECT sys_award_year
      FROM igf_ap_batch_aw_map_all
     WHERE ci_cal_type   = cp_cal_type
       AND ci_sequence_number = cp_seq_number;

  l_award_year  igf_ap_batch_aw_map_all.sys_award_year%TYPE;

  lv_success BOOLEAN;
  l_error_msg fnd_new_messages.message_name%TYPE DEFAULT NULL;

  lv_cssp_rowid   ROWID;
  lv_fnar_rowid   ROWID;
  l_cssp_id       igf_ap_css_profile_all.cssp_id%TYPE;
  l_fnar_id       igf_ap_css_fnar_all.fnar_id%TYPE;
  l_fnar_cssp_id  igf_ap_css_fnar_all.cssp_id%TYPE;
  l_base_id       igf_ap_css_profile_all.base_id%TYPE;

  SKIP_PROFILE_RECORD EXCEPTION;

  BEGIN

    --Get EFC Duration
    l_efc_duration := igf_ap_efc_calc.get_efc_no_of_months(NULL,p_base_id);
    IF l_efc_duration > 12 THEN
      l_efc_duration := 12;
    ELSIF l_efc_duration = 0 THEN
      RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.calculate_efc.main','l_efc_duration:'||l_efc_duration);
    END IF;

    --get sys award year based on cal type and sequence number
    OPEN c_award_year(p_cal_type,p_seq_number);
    FETCH c_award_year INTO l_award_year;
    CLOSE c_award_year;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.calculate_efc.main','l_award_year:'||l_award_year);
    END IF;

    --Get all profiles
    OPEN c_all_profiles(p_base_id);
    FETCH c_all_profiles INTO l_profile;

    IF c_all_profiles%NOTFOUND THEN
      --log a message
      fnd_message.set_name('IGF','IGF_AP_NO_PROF_RECS_EXIST');
      fnd_file.put_line(fnd_file.log,g_tab_2 || fnd_message.get);
      RETURN;
    ELSE

      WHILE c_all_profiles%FOUND
      LOOP
        --store the PK of PROFILE
        lv_cssp_rowid := l_profile.row_id;
        l_cssp_id     := l_profile.cssp_id;
        l_base_id     := l_profile.base_id;

        BEGIN

          OPEN c_fnar(l_profile.cssp_id);
          FETCH c_fnar INTO l_fnar;
          IF c_fnar%FOUND THEN
            l_fnar_rec_fnd := TRUE;
            l_fnar_id      := l_fnar.fnar_id;
            l_fnar_cssp_id := l_fnar.cssp_id;
            lv_fnar_rowid  := l_fnar.row_id;
          ELSE
            l_fnar_rec_fnd := FALSE;
          END IF;
          CLOSE c_fnar;

          SAVEPOINT SP_PROFILE_ID;

          --for each profile
          fnd_file.put_line(fnd_file.log,g_tab_1 || l_internal_id_log || l_profile.css_id_number || l_profile.stu_record_type);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.calculate_efc.debug','processing internal id '||l_profile.css_id_number || l_profile.stu_record_type);
          END IF;

          --call user hook
          lv_success := igf_ap_uhk_inas_pkg.get_im_efc(
                                                       p_sys_awd_year => l_award_year,
                                                       p_profile_rec  => l_profile,
                                                       p_fnar_rec     => l_fnar,
                                                       p_error_msg    => l_error_msg
                                                      );

          IF NOT lv_success THEN
            ROLLBACK TO SP_PROFILE_ID;
            fnd_message.set_name('IGF',l_error_msg);
            fnd_file.put_line(fnd_file.log,g_tab_2 || fnd_message.get);

            fnd_message.set_name('IGF','IGF_AP_PROF_EFC_CALC_FAILED');
            fnd_file.put_line(fnd_file.log,g_tab_2 || fnd_message.get);
            RAISE SKIP_PROFILE_RECORD;
          END IF;

          IF l_profile.row_id <> lv_cssp_rowid OR
             l_profile.cssp_id <> l_cssp_id OR
             l_profile.base_id <> l_base_id OR
             (l_fnar_rec_fnd AND (l_fnar.row_id <> lv_fnar_rowid OR l_fnar.fnar_id <> l_fnar_id OR l_fnar.cssp_id <> l_fnar_cssp_id)) THEN
            fnd_message.set_name('IGF','IGF_AP_PROF_UHK_UPDATED_PK');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            RAISE SKIP_PROFILE_RECORD;
          END IF;


          BEGIN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.calculate_efc.debug','l_coa_duration_efc_amt:'||l_coa_duration_efc_amt);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.calculate_efc.debug','l_efc_duration:'||l_efc_duration);
            END IF;
            --update coa_duration_efc_amt,coa_duration_num
            igf_ap_css_profile_pkg.update_row(
                                              x_rowid                        => l_profile.row_id,
                                              x_cssp_id                      => l_profile.cssp_id,
                                              x_base_id                      => l_profile.base_id,
                                              x_system_record_type           => l_profile.system_record_type,
                                              x_active_profile               => l_profile.active_profile,
                                              x_college_code                 => l_profile.college_code,
                                              x_academic_year                => l_profile.academic_year,
                                              x_stu_record_type              => l_profile.stu_record_type,
                                              x_css_id_number                => l_profile.css_id_number,
                                              x_registration_receipt_date    => l_profile.registration_receipt_date,
                                              x_registration_type            => l_profile.registration_type,
                                              x_application_receipt_date     => l_profile.application_receipt_date,
                                              x_application_type             => l_profile.application_type,
                                              x_original_fnar_compute        => l_profile.original_fnar_compute,
                                              x_revision_fnar_compute_date   => l_profile.revision_fnar_compute_date,
                                              x_electronic_extract_date      => l_profile.electronic_extract_date,
                                              x_institutional_reporting_type => l_profile.institutional_reporting_type,
                                              x_asr_receipt_date             => l_profile.asr_receipt_date,
                                              x_last_name                    => l_profile.last_name,
                                              x_first_name                   => l_profile.first_name,
                                              x_middle_initial               => l_profile.middle_initial,
                                              x_address_number_and_street    => l_profile.address_number_and_street,
                                              x_city                         => l_profile.city,
                                              x_state_mailing                => l_profile.state_mailing,
                                              x_zip_code                     => l_profile.zip_code,
                                              x_s_telephone_number           => l_profile.s_telephone_number,
                                              x_s_title                      => l_profile.s_title,
                                              x_date_of_birth                => l_profile.date_of_birth,
                                              x_social_security_number       => l_profile.social_security_number,
                                              x_state_legal_residence        => l_profile.state_legal_residence,
                                              x_foreign_address_indicator    => l_profile.foreign_address_indicator,
                                              x_foreign_postal_code          => l_profile.foreign_postal_code,
                                              x_country                      => l_profile.country,
                                              x_financial_aid_status         => l_profile.financial_aid_status,
                                              x_year_in_college              => l_profile.year_in_college,
                                              x_marital_status               => l_profile.marital_status,
                                              x_ward_court                   => l_profile.ward_court,
                                              x_legal_dependents_other       => l_profile.legal_dependents_other,
                                              x_household_size               => l_profile.household_size,
                                              x_number_in_college            => l_profile.number_in_college,
                                              x_citizenship_status           => l_profile.citizenship_status,
                                              x_citizenship_country          => l_profile.citizenship_country,
                                              x_visa_classification          => l_profile.visa_classification,
                                              x_tax_figures                  => l_profile.tax_figures,
                                              x_number_exemptions            => l_profile.number_exemptions,
                                              x_adjusted_gross_inc           => l_profile.adjusted_gross_inc,
                                              x_us_tax_paid                  => l_profile.us_tax_paid,
                                              x_itemized_deductions          => l_profile.itemized_deductions,
                                              x_stu_income_work              => l_profile.stu_income_work,
                                              x_spouse_income_work           => l_profile.spouse_income_work,
                                              x_divid_int_inc                => l_profile.divid_int_inc,
                                              x_soc_sec_benefits             => l_profile.soc_sec_benefits,
                                              x_welfare_tanf                 => l_profile.welfare_tanf,
                                              x_child_supp_rcvd              => l_profile.child_supp_rcvd,
                                              x_earned_income_credit         => l_profile.earned_income_credit,
                                              x_other_untax_income           => l_profile.other_untax_income,
                                              x_tax_stu_aid                  => l_profile.tax_stu_aid,
                                              x_cash_sav_check               => l_profile.cash_sav_check,
                                              x_ira_keogh                    => l_profile.ira_keogh,
                                              x_invest_value                 => l_profile.invest_value,
                                              x_invest_debt                  => l_profile.invest_debt,
                                              x_home_value                   => l_profile.home_value,
                                              x_home_debt                    => l_profile.home_debt,
                                              x_oth_real_value               => l_profile.oth_real_value,
                                              x_oth_real_debt                => l_profile.oth_real_debt,
                                              x_bus_farm_value               => l_profile.bus_farm_value,
                                              x_bus_farm_debt                => l_profile.bus_farm_debt,
                                              x_live_on_farm                 => l_profile.live_on_farm,
                                              x_home_purch_price             => l_profile.home_purch_price,
                                              x_hope_ll_credit               => l_profile.hope_ll_credit,
                                              x_home_purch_year              => l_profile.home_purch_year,
                                              x_trust_amount                 => l_profile.trust_amount,
                                              x_trust_avail                  => l_profile.trust_avail,
                                              x_trust_estab                  => l_profile.trust_estab,
                                              x_child_support_paid           => l_profile.child_support_paid,
                                              x_med_dent_expenses            => l_profile.med_dent_expenses,
                                              x_vet_us                       => l_profile.vet_us,
                                              x_vet_ben_amount               => l_profile.vet_ben_amount,
                                              x_vet_ben_months               => l_profile.vet_ben_months,
                                              x_stu_summer_wages             => l_profile.stu_summer_wages,
                                              x_stu_school_yr_wages          => l_profile.stu_school_yr_wages,
                                              x_spouse_summer_wages          => l_profile.spouse_summer_wages,
                                              x_spouse_school_yr_wages       => l_profile.spouse_school_yr_wages,
                                              x_summer_other_tax_inc         => l_profile.summer_other_tax_inc,
                                              x_school_yr_other_tax_inc      => l_profile.school_yr_other_tax_inc,
                                              x_summer_untax_inc             => l_profile.summer_untax_inc,
                                              x_school_yr_untax_inc          => l_profile.school_yr_untax_inc,
                                              x_grants_schol_etc             => l_profile.grants_schol_etc,
                                              x_tuit_benefits                => l_profile.tuit_benefits,
                                              x_cont_parents                 => l_profile.cont_parents,
                                              x_cont_relatives               => l_profile.cont_relatives,
                                              x_p_siblings_pre_tuit          => l_profile.p_siblings_pre_tuit,
                                              x_p_student_pre_tuit           => l_profile.p_student_pre_tuit,
                                              x_p_household_size             => l_profile.p_household_size,
                                              x_p_number_in_college          => l_profile.p_number_in_college,
                                              x_p_parents_in_college         => l_profile.p_parents_in_college,
                                              x_p_marital_status             => l_profile.p_marital_status,
                                              x_p_state_legal_residence      => l_profile.p_state_legal_residence,
                                              x_p_natural_par_status         => l_profile.p_natural_par_status,
                                              x_p_child_supp_paid            => l_profile.p_child_supp_paid,
                                              x_p_repay_ed_loans             => l_profile.p_repay_ed_loans,
                                              x_p_med_dent_expenses          => l_profile.p_med_dent_expenses,
                                              x_p_tuit_paid_amount           => l_profile.p_tuit_paid_amount,
                                              x_p_tuit_paid_number           => l_profile.p_tuit_paid_number,
                                              x_p_exp_child_supp_paid        => l_profile.p_exp_child_supp_paid,
                                              x_p_exp_repay_ed_loans         => l_profile.p_exp_repay_ed_loans,
                                              x_p_exp_med_dent_expenses      => l_profile.p_exp_med_dent_expenses,
                                              x_p_exp_tuit_pd_amount         => l_profile.p_exp_tuit_pd_amount,
                                              x_p_exp_tuit_pd_number         => l_profile.p_exp_tuit_pd_number,
                                              x_p_cash_sav_check             => l_profile.p_cash_sav_check,
                                              x_p_month_mortgage_pay         => l_profile.p_month_mortgage_pay,
                                              x_p_invest_value               => l_profile.p_invest_value,
                                              x_p_invest_debt                => l_profile.p_invest_debt,
                                              x_p_home_value                 => l_profile.p_home_value,
                                              x_p_home_debt                  => l_profile.p_home_debt,
                                              x_p_home_purch_price           => l_profile.p_home_purch_price,
                                              x_p_own_business_farm          => l_profile.p_own_business_farm,
                                              x_p_business_value             => l_profile.p_business_value,
                                              x_p_business_debt              => l_profile.p_business_debt,
                                              x_p_farm_value                 => l_profile.p_farm_value,
                                              x_p_farm_debt                  => l_profile.p_farm_debt,
                                              x_p_live_on_farm               => l_profile.p_live_on_farm,
                                              x_p_oth_real_estate_value      => l_profile.p_oth_real_estate_value,
                                              x_p_oth_real_estate_debt       => l_profile.p_oth_real_estate_debt,
                                              x_p_oth_real_purch_price       => l_profile.p_oth_real_purch_price,
                                              x_p_siblings_assets            => l_profile.p_siblings_assets,
                                              x_p_home_purch_year            => l_profile.p_home_purch_year,
                                              x_p_oth_real_purch_year        => l_profile.p_oth_real_purch_year,
                                              x_p_prior_agi                  => l_profile.p_prior_agi,
                                              x_p_prior_us_tax_paid          => l_profile.p_prior_us_tax_paid,
                                              x_p_prior_item_deductions      => l_profile.p_prior_item_deductions,
                                              x_p_prior_other_untax_inc      => l_profile.p_prior_other_untax_inc,
                                              x_p_tax_figures                => l_profile.p_tax_figures,
                                              x_p_number_exemptions          => l_profile.p_number_exemptions,
                                              x_p_adjusted_gross_inc         => l_profile.p_adjusted_gross_inc,
                                              x_p_wages_sal_tips             => l_profile.p_wages_sal_tips,
                                              x_p_interest_income            => l_profile.p_interest_income,
                                              x_p_dividend_income            => l_profile.p_dividend_income,
                                              x_p_net_inc_bus_farm           => l_profile.p_net_inc_bus_farm,
                                              x_p_other_taxable_income       => l_profile.p_other_taxable_income,
                                              x_p_adj_to_income              => l_profile.p_adj_to_income,
                                              x_p_us_tax_paid                => l_profile.p_us_tax_paid,
                                              x_p_itemized_deductions        => l_profile.p_itemized_deductions,
                                              x_p_father_income_work         => l_profile.p_father_income_work,
                                              x_p_mother_income_work         => l_profile.p_mother_income_work,
                                              x_p_soc_sec_ben                => l_profile.p_soc_sec_ben,
                                              x_p_welfare_tanf               => l_profile.p_welfare_tanf,
                                              x_p_child_supp_rcvd            => l_profile.p_child_supp_rcvd,
                                              x_p_ded_ira_keogh              => l_profile.p_ded_ira_keogh,
                                              x_p_tax_defer_pens_savs        => l_profile.p_tax_defer_pens_savs,
                                              x_p_dep_care_med_spending      => l_profile.p_dep_care_med_spending,
                                              x_p_earned_income_credit       => l_profile.p_earned_income_credit,
                                              x_p_living_allow               => l_profile.p_living_allow,
                                              x_p_tax_exmpt_int              => l_profile.p_tax_exmpt_int,
                                              x_p_foreign_inc_excl           => l_profile.p_foreign_inc_excl,
                                              x_p_other_untax_inc            => l_profile.p_other_untax_inc,
                                              x_p_hope_ll_credit             => l_profile.p_hope_ll_credit,
                                              x_p_yr_separation              => l_profile.p_yr_separation,
                                              x_p_yr_divorce                 => l_profile.p_yr_divorce,
                                              x_p_exp_father_inc             => l_profile.p_exp_father_inc,
                                              x_p_exp_mother_inc             => l_profile.p_exp_mother_inc,
                                              x_p_exp_other_tax_inc          => l_profile.p_exp_other_tax_inc,
                                              x_p_exp_other_untax_inc        => l_profile.p_exp_other_untax_inc,
                                              x_line_2_relation              => l_profile.line_2_relation,
                                              x_line_2_attend_college        => l_profile.line_2_attend_college,
                                              x_line_3_relation              => l_profile.line_3_relation,
                                              x_line_3_attend_college        => l_profile.line_3_attend_college,
                                              x_line_4_relation              => l_profile.line_4_relation,
                                              x_line_4_attend_college        => l_profile.line_4_attend_college,
                                              x_line_5_relation              => l_profile.line_5_relation,
                                              x_line_5_attend_college        => l_profile.line_5_attend_college,
                                              x_line_6_relation              => l_profile.line_6_relation,
                                              x_line_6_attend_college        => l_profile.line_6_attend_college,
                                              x_line_7_relation              => l_profile.line_7_relation,
                                              x_line_7_attend_college        => l_profile.line_7_attend_college,
                                              x_line_8_relation              => l_profile.line_8_relation,
                                              x_line_8_attend_college        => l_profile.line_8_attend_college,
                                              x_p_age_father                 => l_profile.p_age_father,
                                              x_p_age_mother                 => l_profile.p_age_mother,
                                              x_p_div_sep_ind                => l_profile.p_div_sep_ind,
                                              x_b_cont_non_custodial_par     => l_profile.b_cont_non_custodial_par,
                                              x_college_type_2               => l_profile.college_type_2,
                                              x_college_type_3               => l_profile.college_type_3,
                                              x_college_type_4               => l_profile.college_type_4,
                                              x_college_type_5               => l_profile.college_type_5,
                                              x_college_type_6               => l_profile.college_type_6,
                                              x_college_type_7               => l_profile.college_type_7,
                                              x_college_type_8               => l_profile.college_type_8,
                                              x_school_code_1                => l_profile.school_code_1,
                                              x_housing_code_1               => l_profile.housing_code_1,
                                              x_school_code_2                => l_profile.school_code_2,
                                              x_housing_code_2               => l_profile.housing_code_2,
                                              x_school_code_3                => l_profile.school_code_3,
                                              x_housing_code_3               => l_profile.housing_code_3,
                                              x_school_code_4                => l_profile.school_code_4,
                                              x_housing_code_4               => l_profile.housing_code_4,
                                              x_school_code_5                => l_profile.school_code_5,
                                              x_housing_code_5               => l_profile.housing_code_5,
                                              x_school_code_6                => l_profile.school_code_6,
                                              x_housing_code_6               => l_profile.housing_code_6,
                                              x_school_code_7                => l_profile.school_code_7,
                                              x_housing_code_7               => l_profile.housing_code_7,
                                              x_school_code_8                => l_profile.school_code_8,
                                              x_housing_code_8               => l_profile.housing_code_8,
                                              x_school_code_9                => l_profile.school_code_9,
                                              x_housing_code_9               => l_profile.housing_code_9,
                                              x_school_code_10               => l_profile.school_code_10,
                                              x_housing_code_10              => l_profile.housing_code_10,
                                              x_additional_school_code_1     => l_profile.additional_school_code_1,
                                              x_additional_school_code_2     => l_profile.additional_school_code_2,
                                              x_additional_school_code_3     => l_profile.additional_school_code_3,
                                              x_additional_school_code_4     => l_profile.additional_school_code_4,
                                              x_additional_school_code_5     => l_profile.additional_school_code_5,
                                              x_additional_school_code_6     => l_profile.additional_school_code_6,
                                              x_additional_school_code_7     => l_profile.additional_school_code_7,
                                              x_additional_school_code_8     => l_profile.additional_school_code_8,
                                              x_additional_school_code_9     => l_profile.additional_school_code_9,
                                              x_additional_school_code_10    => l_profile.additional_school_code_10,
                                              x_explanation_spec_circum      => l_profile.explanation_spec_circum,
                                              x_signature_student            => l_profile.signature_student,
                                              x_signature_spouse             => l_profile.signature_spouse,
                                              x_signature_father             => l_profile.signature_father,
                                              x_signature_mother             => l_profile.signature_mother,
                                              x_month_day_completed          => l_profile.month_day_completed,
                                              x_year_completed               => l_profile.year_completed,
                                              x_age_line_2                   => l_profile.age_line_2,
                                              x_age_line_3                   => l_profile.age_line_3,
                                              x_age_line_4                   => l_profile.age_line_4,
                                              x_age_line_5                   => l_profile.age_line_5,
                                              x_age_line_6                   => l_profile.age_line_6,
                                              x_age_line_7                   => l_profile.age_line_7,
                                              x_age_line_8                   => l_profile.age_line_8,
                                              x_a_online_signature           => l_profile.a_online_signature,
                                              x_question_1_number            => l_profile.question_1_number,
                                              x_question_1_size              => l_profile.question_1_size,
                                              x_question_1_answer            => l_profile.question_1_answer,
                                              x_question_2_number            => l_profile.question_2_number,
                                              x_question_2_size              => l_profile.question_2_size,
                                              x_question_2_answer            => l_profile.question_2_answer,
                                              x_question_3_number            => l_profile.question_3_number,
                                              x_question_3_size              => l_profile.question_3_size,
                                              x_question_3_answer            => l_profile.question_3_answer,
                                              x_question_4_number            => l_profile.question_4_number,
                                              x_question_4_size              => l_profile.question_4_size,
                                              x_question_4_answer            => l_profile.question_4_answer,
                                              x_question_5_number            => l_profile.question_5_number,
                                              x_question_5_size              => l_profile.question_5_size,
                                              x_question_5_answer            => l_profile.question_5_answer,
                                              x_question_6_number            => l_profile.question_6_number,
                                              x_question_6_size              => l_profile.question_6_size,
                                              x_question_6_answer            => l_profile.question_6_answer,
                                              x_question_7_number            => l_profile.question_7_number,
                                              x_question_7_size              => l_profile.question_7_size,
                                              x_question_7_answer            => l_profile.question_7_answer,
                                              x_question_8_number            => l_profile.question_8_number,
                                              x_question_8_size              => l_profile.question_8_size,
                                              x_question_8_answer            => l_profile.question_8_answer,
                                              x_question_9_number            => l_profile.question_9_number,
                                              x_question_9_size              => l_profile.question_9_size,
                                              x_question_9_answer            => l_profile.question_9_answer,
                                              x_question_10_number           => l_profile.question_10_number,
                                              x_question_10_size             => l_profile.question_10_size,
                                              x_question_10_answer           => l_profile.question_10_answer,
                                              x_question_11_number           => l_profile.question_11_number,
                                              x_question_11_size             => l_profile.question_11_size,
                                              x_question_11_answer           => l_profile.question_11_answer,
                                              x_question_12_number           => l_profile.question_12_number,
                                              x_question_12_size             => l_profile.question_12_size,
                                              x_question_12_answer           => l_profile.question_12_answer,
                                              x_question_13_number           => l_profile.question_13_number,
                                              x_question_13_size             => l_profile.question_13_size,
                                              x_question_13_answer           => l_profile.question_13_answer,
                                              x_question_14_number           => l_profile.question_14_number,
                                              x_question_14_size             => l_profile.question_14_size,
                                              x_question_14_answer           => l_profile.question_14_answer,
                                              x_question_15_number           => l_profile.question_15_number,
                                              x_question_15_size             => l_profile.question_15_size,
                                              x_question_15_answer           => l_profile.question_15_answer,
                                              x_question_16_number           => l_profile.question_16_number,
                                              x_question_16_size             => l_profile.question_16_size,
                                              x_question_16_answer           => l_profile.question_16_answer,
                                              x_question_17_number           => l_profile.question_17_number,
                                              x_question_17_size             => l_profile.question_17_size,
                                              x_question_17_answer           => l_profile.question_17_answer,
                                              x_question_18_number           => l_profile.question_18_number,
                                              x_question_18_size             => l_profile.question_18_size,
                                              x_question_18_answer           => l_profile.question_18_answer,
                                              x_question_19_number           => l_profile.question_19_number,
                                              x_question_19_size             => l_profile.question_19_size,
                                              x_question_19_answer           => l_profile.question_19_answer,
                                              x_question_20_number           => l_profile.question_20_number,
                                              x_question_20_size             => l_profile.question_20_size,
                                              x_question_20_answer           => l_profile.question_20_answer,
                                              x_question_21_number           => l_profile.question_21_number,
                                              x_question_21_size             => l_profile.question_21_size,
                                              x_question_21_answer           => l_profile.question_21_answer,
                                              x_question_22_number           => l_profile.question_22_number,
                                              x_question_22_size             => l_profile.question_22_size,
                                              x_question_22_answer           => l_profile.question_22_answer,
                                              x_question_23_number           => l_profile.question_23_number,
                                              x_question_23_size             => l_profile.question_23_size,
                                              x_question_23_answer           => l_profile.question_23_answer,
                                              x_question_24_number           => l_profile.question_24_number,
                                              x_question_24_size             => l_profile.question_24_size,
                                              x_question_24_answer           => l_profile.question_24_answer,
                                              x_question_25_number           => l_profile.question_25_number,
                                              x_question_25_size             => l_profile.question_25_size,
                                              x_question_25_answer           => l_profile.question_25_answer,
                                              x_question_26_number           => l_profile.question_26_number,
                                              x_question_26_size             => l_profile.question_26_size,
                                              x_question_26_answer           => l_profile.question_26_answer,
                                              x_question_27_number           => l_profile.question_27_number,
                                              x_question_27_size             => l_profile.question_27_size,
                                              x_question_27_answer           => l_profile.question_27_answer,
                                              x_question_28_number           => l_profile.question_28_number,
                                              x_question_28_size             => l_profile.question_28_size,
                                              x_question_28_answer           => l_profile.question_28_answer,
                                              x_question_29_number           => l_profile.question_29_number,
                                              x_question_29_size             => l_profile.question_29_size,
                                              x_question_29_answer           => l_profile.question_29_answer,
                                              x_question_30_number           => l_profile.question_30_number,
                                              x_questions_30_size            => l_profile.questions_30_size,
                                              x_question_30_answer           => l_profile.question_30_answer,
                                              x_mode                         => 'R',
                                              x_legacy_record_flag           => l_profile.legacy_record_flag,
                                              x_coa_duration_efc_amt         => l_coa_duration_efc_amt,
                                              x_coa_duration_num             => l_efc_duration,
                                              x_p_soc_sec_ben_student_amt    => l_profile.p_soc_sec_ben_student_amt,
                                              x_p_tuit_fee_deduct_amt        => l_profile.p_tuit_fee_deduct_amt,
                                              x_stu_lives_with_num           => l_profile.stu_lives_with_num,
                                              x_stu_most_support_from_num    => l_profile.stu_most_support_from_num,
                                              x_location_computer_num        => l_profile.location_computer_num
                                             );
            IF l_fnar_rec_fnd THEN
              igf_ap_css_fnar_pkg.update_row(
                                             x_rowid                             => l_fnar.row_id,
                                             x_fnar_id                           => l_fnar.fnar_id,
                                             x_cssp_id                           => l_fnar.cssp_id,
                                             x_r_s_email_address                 => l_fnar.r_s_email_address,
                                             x_eps_code                          => l_fnar.eps_code,
                                             x_comp_css_dependency_status        => l_fnar.comp_css_dependency_status,
                                             x_stu_age                           => l_fnar.stu_age,
                                             x_assumed_stu_yr_in_coll            => l_fnar.assumed_stu_yr_in_coll,
                                             x_comp_stu_marital_status           => l_fnar.comp_stu_marital_status,
                                             x_stu_family_members                => l_fnar.stu_family_members,
                                             x_stu_fam_members_in_college        => l_fnar.stu_fam_members_in_college,
                                             x_par_marital_status                => l_fnar.par_marital_status,
                                             x_par_family_members                => l_fnar.par_family_members,
                                             x_par_total_in_college              => l_fnar.par_total_in_college,
                                             x_par_par_in_college                => l_fnar.par_par_in_college,
                                             x_par_others_in_college             => l_fnar.par_others_in_college,
                                             x_par_aesa                          => l_fnar.par_aesa,
                                             x_par_cesa                          => l_fnar.par_cesa,
                                             x_stu_aesa                          => l_fnar.stu_aesa,
                                             x_stu_cesa                          => l_fnar.stu_cesa,
                                             x_im_p_bas_agi_taxable_income       => l_fnar.im_p_bas_agi_taxable_income,
                                             x_im_p_bas_untx_inc_and_ben         => l_fnar.im_p_bas_untx_inc_and_ben,
                                             x_im_p_bas_inc_adj                  => l_fnar.im_p_bas_inc_adj,
                                             x_im_p_bas_total_income             => l_fnar.im_p_bas_total_income,
                                             x_im_p_bas_us_income_tax            => l_fnar.im_p_bas_us_income_tax,
                                             x_im_p_bas_st_and_other_tax         => l_fnar.im_p_bas_st_and_other_tax,
                                             x_im_p_bas_fica_tax                 => l_fnar.im_p_bas_fica_tax,
                                             x_im_p_bas_med_dental               => l_fnar.im_p_bas_med_dental,
                                             x_im_p_bas_employment_allow         => l_fnar.im_p_bas_employment_allow,
                                             x_im_p_bas_annual_ed_savings        => l_fnar.im_p_bas_annual_ed_savings,
                                             x_im_p_bas_inc_prot_allow_m         => l_fnar.im_p_bas_inc_prot_allow_m,
                                             x_im_p_bas_total_inc_allow          => l_fnar.im_p_bas_total_inc_allow,
                                             x_im_p_bas_cal_avail_inc            => l_fnar.im_p_bas_cal_avail_inc,
                                             x_im_p_bas_avail_income             => l_fnar.im_p_bas_avail_income,
                                             x_im_p_bas_total_cont_inc           => l_fnar.im_p_bas_total_cont_inc,
                                             x_im_p_bas_cash_bank_accounts       => l_fnar.im_p_bas_cash_bank_accounts,
                                             x_im_p_bas_home_equity              => l_fnar.im_p_bas_home_equity,
                                             x_im_p_bas_ot_rl_est_inv_eq         => l_fnar.im_p_bas_ot_rl_est_inv_eq,
                                             x_im_p_bas_adj_bus_farm_worth       => l_fnar.im_p_bas_adj_bus_farm_worth,
                                             x_im_p_bas_ass_sibs_pre_tui         => l_fnar.im_p_bas_ass_sibs_pre_tui,
                                             x_im_p_bas_net_worth                => l_fnar.im_p_bas_net_worth,
                                             x_im_p_bas_emerg_res_allow          => l_fnar.im_p_bas_emerg_res_allow,
                                             x_im_p_bas_cum_ed_savings           => l_fnar.im_p_bas_cum_ed_savings,
                                             x_im_p_bas_low_inc_allow            => l_fnar.im_p_bas_low_inc_allow,
                                             x_im_p_bas_total_asset_allow        => l_fnar.im_p_bas_total_asset_allow,
                                             x_im_p_bas_disc_net_worth           => l_fnar.im_p_bas_disc_net_worth,
                                             x_im_p_bas_total_cont_asset         => l_fnar.im_p_bas_total_cont_asset,
                                             x_im_p_bas_total_cont               => l_fnar.im_p_bas_total_cont,
                                             x_im_p_bas_num_in_coll_adj          => l_fnar.im_p_bas_num_in_coll_adj,
                                             x_im_p_bas_cont_for_stu             => l_fnar.im_p_bas_cont_for_stu,
                                             x_im_p_bas_cont_from_income         => l_fnar.im_p_bas_cont_from_income,
                                             x_im_p_bas_cont_from_assets         => l_fnar.im_p_bas_cont_from_assets,
                                             x_im_p_opt_agi_taxable_income       => l_fnar.im_p_opt_agi_taxable_income,
                                             x_im_p_opt_untx_inc_and_ben         => l_fnar.im_p_opt_untx_inc_and_ben,
                                             x_im_p_opt_inc_adj                  => l_fnar.im_p_opt_inc_adj,
                                             x_im_p_opt_total_income             => l_fnar.im_p_opt_total_income,
                                             x_im_p_opt_us_income_tax            => l_fnar.im_p_opt_us_income_tax,
                                             x_im_p_opt_st_and_other_tax         => l_fnar.im_p_opt_st_and_other_tax,
                                             x_im_p_opt_fica_tax                 => l_fnar.im_p_opt_fica_tax,
                                             x_im_p_opt_med_dental               => l_fnar.im_p_opt_med_dental,
                                             x_im_p_opt_elem_sec_tuit            => l_fnar.im_p_opt_elem_sec_tuit,
                                             x_im_p_opt_employment_allow         => l_fnar.im_p_opt_employment_allow,
                                             x_im_p_opt_annual_ed_savings        => l_fnar.im_p_opt_annual_ed_savings,
                                             x_im_p_opt_inc_prot_allow_m         => l_fnar.im_p_opt_inc_prot_allow_m,
                                             x_im_p_opt_total_inc_allow          => l_fnar.im_p_opt_total_inc_allow,
                                             x_im_p_opt_cal_avail_inc            => l_fnar.im_p_opt_cal_avail_inc,
                                             x_im_p_opt_avail_income             => l_fnar.im_p_opt_avail_income,
                                             x_im_p_opt_total_cont_inc           => l_fnar.im_p_opt_total_cont_inc,
                                             x_im_p_opt_cash_bank_accounts       => l_fnar.im_p_opt_cash_bank_accounts,
                                             x_im_p_opt_home_equity              => l_fnar.im_p_opt_home_equity,
                                             x_im_p_opt_ot_rl_est_inv_eq         => l_fnar.im_p_opt_ot_rl_est_inv_eq,
                                             x_im_p_opt_adj_bus_farm_worth       => l_fnar.im_p_opt_adj_bus_farm_worth,
                                             x_im_p_opt_ass_sibs_pre_tui         => l_fnar.im_p_opt_ass_sibs_pre_tui,
                                             x_im_p_opt_net_worth                => l_fnar.im_p_opt_net_worth,
                                             x_im_p_opt_emerg_res_allow          => l_fnar.im_p_opt_emerg_res_allow,
                                             x_im_p_opt_cum_ed_savings           => l_fnar.im_p_opt_cum_ed_savings,
                                             x_im_p_opt_low_inc_allow            => l_fnar.im_p_opt_low_inc_allow,
                                             x_im_p_opt_total_asset_allow        => l_fnar.im_p_opt_total_asset_allow,
                                             x_im_p_opt_disc_net_worth           => l_fnar.im_p_opt_disc_net_worth,
                                             x_im_p_opt_total_cont_asset         => l_fnar.im_p_opt_total_cont_asset,
                                             x_im_p_opt_total_cont               => l_fnar.im_p_opt_total_cont,
                                             x_im_p_opt_num_in_coll_adj          => l_fnar.im_p_opt_num_in_coll_adj,
                                             x_im_p_opt_cont_for_stu             => l_fnar.im_p_opt_cont_for_stu,
                                             x_im_p_opt_cont_from_income         => l_fnar.im_p_opt_cont_from_income,
                                             x_im_p_opt_cont_from_assets         => l_fnar.im_p_opt_cont_from_assets,
                                             x_fm_p_analysis_type                => l_fnar.fm_p_analysis_type,
                                             x_fm_p_agi_taxable_income           => l_fnar.fm_p_agi_taxable_income,
                                             x_fm_p_untx_inc_and_ben             => l_fnar.fm_p_untx_inc_and_ben,
                                             x_fm_p_inc_adj                      => l_fnar.fm_p_inc_adj,
                                             x_fm_p_total_income                 => l_fnar.fm_p_total_income,
                                             x_fm_p_us_income_tax                => l_fnar.fm_p_us_income_tax,
                                             x_fm_p_state_and_other_taxes        => l_fnar.fm_p_state_and_other_taxes,
                                             x_fm_p_fica_tax                     => l_fnar.fm_p_fica_tax,
                                             x_fm_p_employment_allow             => l_fnar.fm_p_employment_allow,
                                             x_fm_p_income_prot_allow            => l_fnar.fm_p_income_prot_allow,
                                             x_fm_p_total_allow                  => l_fnar.fm_p_total_allow,
                                             x_fm_p_avail_income                 => l_fnar.fm_p_avail_income,
                                             x_fm_p_cash_bank_accounts           => l_fnar.fm_p_cash_bank_accounts,
                                             x_fm_p_ot_rl_est_inv_equity         => l_fnar.fm_p_ot_rl_est_inv_equity,
                                             x_fm_p_adj_bus_farm_net_worth       => l_fnar.fm_p_adj_bus_farm_net_worth,
                                             x_fm_p_net_worth                    => l_fnar.fm_p_net_worth,
                                             x_fm_p_asset_prot_allow             => l_fnar.fm_p_asset_prot_allow,
                                             x_fm_p_disc_net_worth               => l_fnar.fm_p_disc_net_worth,
                                             x_fm_p_total_contribution           => l_fnar.fm_p_total_contribution,
                                             x_fm_p_num_in_coll                  => l_fnar.fm_p_num_in_coll,
                                             x_fm_p_cont_for_stu                 => l_fnar.fm_p_cont_for_stu,
                                             x_fm_p_cont_from_income             => l_fnar.fm_p_cont_from_income,
                                             x_fm_p_cont_from_assets             => l_fnar.fm_p_cont_from_assets,
                                             x_im_s_bas_agi_taxable_income       => l_fnar.im_s_bas_agi_taxable_income,
                                             x_im_s_bas_untx_inc_and_ben         => l_fnar.im_s_bas_untx_inc_and_ben,
                                             x_im_s_bas_inc_adj                  => l_fnar.im_s_bas_inc_adj,
                                             x_im_s_bas_total_income             => l_fnar.im_s_bas_total_income,
                                             x_im_s_bas_us_income_tax            => l_fnar.im_s_bas_us_income_tax,
                                             x_im_s_bas_state_and_oth_taxes      => l_fnar.im_s_bas_state_and_oth_taxes,
                                             x_im_s_bas_fica_tax                 => l_fnar.im_s_bas_fica_tax,
                                             x_im_s_bas_med_dental               => l_fnar.im_s_bas_med_dental,
                                             x_im_s_bas_employment_allow         => l_fnar.im_s_bas_employment_allow,
                                             x_im_s_bas_annual_ed_savings        => l_fnar.im_s_bas_annual_ed_savings,
                                             x_im_s_bas_inc_prot_allow_m         => l_fnar.im_s_bas_inc_prot_allow_m,
                                             x_im_s_bas_total_inc_allow          => l_fnar.im_s_bas_total_inc_allow,
                                             x_im_s_bas_cal_avail_income         => l_fnar.im_s_bas_cal_avail_income,
                                             x_im_s_bas_avail_income             => l_fnar.im_s_bas_avail_income,
                                             x_im_s_bas_total_cont_inc           => l_fnar.im_s_bas_total_cont_inc,
                                             x_im_s_bas_cash_bank_accounts       => l_fnar.im_s_bas_cash_bank_accounts,
                                             x_im_s_bas_home_equity              => l_fnar.im_s_bas_home_equity,
                                             x_im_s_bas_ot_rl_est_inv_eq         => l_fnar.im_s_bas_ot_rl_est_inv_eq,
                                             x_im_s_bas_adj_busfarm_worth        => l_fnar.im_s_bas_adj_busfarm_worth,
                                             x_im_s_bas_trusts                   => l_fnar.im_s_bas_trusts,
                                             x_im_s_bas_net_worth                => l_fnar.im_s_bas_net_worth,
                                             x_im_s_bas_emerg_res_allow          => l_fnar.im_s_bas_emerg_res_allow,
                                             x_im_s_bas_cum_ed_savings           => l_fnar.im_s_bas_cum_ed_savings,
                                             x_im_s_bas_total_asset_allow        => l_fnar.im_s_bas_total_asset_allow,
                                             x_im_s_bas_disc_net_worth           => l_fnar.im_s_bas_disc_net_worth,
                                             x_im_s_bas_total_cont_asset         => l_fnar.im_s_bas_total_cont_asset,
                                             x_im_s_bas_total_cont               => l_fnar.im_s_bas_total_cont,
                                             x_im_s_bas_num_in_coll_adj          => l_fnar.im_s_bas_num_in_coll_adj,
                                             x_im_s_bas_cont_for_stu             => l_fnar.im_s_bas_cont_for_stu,
                                             x_im_s_bas_cont_from_income         => l_fnar.im_s_bas_cont_from_income,
                                             x_im_s_bas_cont_from_assets         => l_fnar.im_s_bas_cont_from_assets,
                                             x_im_s_est_agitaxable_income        => l_fnar.im_s_est_agitaxable_income,
                                             x_im_s_est_untx_inc_and_ben         => l_fnar.im_s_est_untx_inc_and_ben,
                                             x_im_s_est_inc_adj                  => l_fnar.im_s_est_inc_adj,
                                             x_im_s_est_total_income             => l_fnar.im_s_est_total_income,
                                             x_im_s_est_us_income_tax            => l_fnar.im_s_est_us_income_tax,
                                             x_im_s_est_state_and_oth_taxes      => l_fnar.im_s_est_state_and_oth_taxes,
                                             x_im_s_est_fica_tax                 => l_fnar.im_s_est_fica_tax,
                                             x_im_s_est_med_dental               => l_fnar.im_s_est_med_dental,
                                             x_im_s_est_employment_allow         => l_fnar.im_s_est_employment_allow,
                                             x_im_s_est_annual_ed_savings        => l_fnar.im_s_est_annual_ed_savings,
                                             x_im_s_est_inc_prot_allow_m         => l_fnar.im_s_est_inc_prot_allow_m,
                                             x_im_s_est_total_inc_allow          => l_fnar.im_s_est_total_inc_allow,
                                             x_im_s_est_cal_avail_income         => l_fnar.im_s_est_cal_avail_income,
                                             x_im_s_est_avail_income             => l_fnar.im_s_est_avail_income,
                                             x_im_s_est_total_cont_inc           => l_fnar.im_s_est_total_cont_inc,
                                             x_im_s_est_cash_bank_accounts       => l_fnar.im_s_est_cash_bank_accounts,
                                             x_im_s_est_home_equity              => l_fnar.im_s_est_home_equity,
                                             x_im_s_est_ot_rl_est_inv_eq         => l_fnar.im_s_est_ot_rl_est_inv_eq,
                                             x_im_s_est_adj_bus_farm_worth       => l_fnar.im_s_est_adj_bus_farm_worth,
                                             x_im_s_est_est_trusts               => l_fnar.im_s_est_est_trusts,
                                             x_im_s_est_net_worth                => l_fnar.im_s_est_net_worth,
                                             x_im_s_est_emerg_res_allow          => l_fnar.im_s_est_emerg_res_allow,
                                             x_im_s_est_cum_ed_savings           => l_fnar.im_s_est_cum_ed_savings,
                                             x_im_s_est_total_asset_allow        => l_fnar.im_s_est_total_asset_allow,
                                             x_im_s_est_disc_net_worth           => l_fnar.im_s_est_disc_net_worth,
                                             x_im_s_est_total_cont_asset         => l_fnar.im_s_est_total_cont_asset,
                                             x_im_s_est_total_cont               => l_fnar.im_s_est_total_cont,
                                             x_im_s_est_num_in_coll_adj          => l_fnar.im_s_est_num_in_coll_adj,
                                             x_im_s_est_cont_for_stu             => l_fnar.im_s_est_cont_for_stu,
                                             x_im_s_est_cont_from_income         => l_fnar.im_s_est_cont_from_income,
                                             x_im_s_est_cont_from_assets         => l_fnar.im_s_est_cont_from_assets,
                                             x_im_s_opt_agi_taxable_income       => l_fnar.im_s_opt_agi_taxable_income,
                                             x_im_s_opt_untx_inc_and_ben         => l_fnar.im_s_opt_untx_inc_and_ben,
                                             x_im_s_opt_inc_adj                  => l_fnar.im_s_opt_inc_adj,
                                             x_im_s_opt_total_income             => l_fnar.im_s_opt_total_income,
                                             x_im_s_opt_us_income_tax            => l_fnar.im_s_opt_us_income_tax,
                                             x_im_s_opt_state_and_oth_taxes      => l_fnar.im_s_opt_state_and_oth_taxes,
                                             x_im_s_opt_fica_tax                 => l_fnar.im_s_opt_fica_tax,
                                             x_im_s_opt_med_dental               => l_fnar.im_s_opt_med_dental,
                                             x_im_s_opt_employment_allow         => l_fnar.im_s_opt_employment_allow,
                                             x_im_s_opt_annual_ed_savings        => l_fnar.im_s_opt_annual_ed_savings,
                                             x_im_s_opt_inc_prot_allow_m         => l_fnar.im_s_opt_inc_prot_allow_m,
                                             x_im_s_opt_total_inc_allow          => l_fnar.im_s_opt_total_inc_allow,
                                             x_im_s_opt_cal_avail_income         => l_fnar.im_s_opt_cal_avail_income,
                                             x_im_s_opt_avail_income             => l_fnar.im_s_opt_avail_income,
                                             x_im_s_opt_total_cont_inc           => l_fnar.im_s_opt_total_cont_inc,
                                             x_im_s_opt_cash_bank_accounts       => l_fnar.im_s_opt_cash_bank_accounts,
                                             x_im_s_opt_ira_keogh_accounts       => l_fnar.im_s_opt_ira_keogh_accounts,
                                             x_im_s_opt_home_equity              => l_fnar.im_s_opt_home_equity,
                                             x_im_s_opt_ot_rl_est_inv_eq         => l_fnar.im_s_opt_ot_rl_est_inv_eq,
                                             x_im_s_opt_adj_bus_farm_worth       => l_fnar.im_s_opt_adj_bus_farm_worth,
                                             x_im_s_opt_trusts                   => l_fnar.im_s_opt_trusts,
                                             x_im_s_opt_net_worth                => l_fnar.im_s_opt_net_worth,
                                             x_im_s_opt_emerg_res_allow          => l_fnar.im_s_opt_emerg_res_allow,
                                             x_im_s_opt_cum_ed_savings           => l_fnar.im_s_opt_cum_ed_savings,
                                             x_im_s_opt_total_asset_allow        => l_fnar.im_s_opt_total_asset_allow,
                                             x_im_s_opt_disc_net_worth           => l_fnar.im_s_opt_disc_net_worth,
                                             x_im_s_opt_total_cont_asset         => l_fnar.im_s_opt_total_cont_asset,
                                             x_im_s_opt_total_cont               => l_fnar.im_s_opt_total_cont,
                                             x_im_s_opt_num_in_coll_adj          => l_fnar.im_s_opt_num_in_coll_adj,
                                             x_im_s_opt_cont_for_stu             => l_fnar.im_s_opt_cont_for_stu,
                                             x_im_s_opt_cont_from_income         => l_fnar.im_s_opt_cont_from_income,
                                             x_im_s_opt_cont_from_assets         => l_fnar.im_s_opt_cont_from_assets,
                                             x_fm_s_analysis_type                => l_fnar.fm_s_analysis_type,
                                             x_fm_s_agi_taxable_income           => l_fnar.fm_s_agi_taxable_income,
                                             x_fm_s_untx_inc_and_ben             => l_fnar.fm_s_untx_inc_and_ben,
                                             x_fm_s_inc_adj                      => l_fnar.fm_s_inc_adj,
                                             x_fm_s_total_income                 => l_fnar.fm_s_total_income,
                                             x_fm_s_us_income_tax                => l_fnar.fm_s_us_income_tax,
                                             x_fm_s_state_and_oth_taxes          => l_fnar.fm_s_state_and_oth_taxes,
                                             x_fm_s_fica_tax                     => l_fnar.fm_s_fica_tax,
                                             x_fm_s_employment_allow             => l_fnar.fm_s_employment_allow,
                                             x_fm_s_income_prot_allow            => l_fnar.fm_s_income_prot_allow,
                                             x_fm_s_total_allow                  => l_fnar.fm_s_total_allow,
                                             x_fm_s_cal_avail_income             => l_fnar.fm_s_cal_avail_income,
                                             x_fm_s_avail_income                 => l_fnar.fm_s_avail_income,
                                             x_fm_s_cash_bank_accounts           => l_fnar.fm_s_cash_bank_accounts,
                                             x_fm_s_ot_rl_est_inv_equity         => l_fnar.fm_s_ot_rl_est_inv_equity,
                                             x_fm_s_adj_bus_farm_worth           => l_fnar.fm_s_adj_bus_farm_worth,
                                             x_fm_s_trusts                       => l_fnar.fm_s_trusts,
                                             x_fm_s_net_worth                    => l_fnar.fm_s_net_worth,
                                             x_fm_s_asset_prot_allow             => l_fnar.fm_s_asset_prot_allow,
                                             x_fm_s_disc_net_worth               => l_fnar.fm_s_disc_net_worth,
                                             x_fm_s_total_cont                   => l_fnar.fm_s_total_cont,
                                             x_fm_s_num_in_coll                  => l_fnar.fm_s_num_in_coll,
                                             x_fm_s_cont_for_stu                 => l_fnar.fm_s_cont_for_stu,
                                             x_fm_s_cont_from_income             => l_fnar.fm_s_cont_from_income,
                                             x_fm_s_cont_from_assets             => l_fnar.fm_s_cont_from_assets,
                                             x_im_inst_resident_ind              => l_fnar.im_inst_resident_ind,
                                             x_institutional_1_budget_name       => l_fnar.institutional_1_budget_name,
                                             x_im_inst_1_budget_duration         => l_fnar.im_inst_1_budget_duration,
                                             x_im_inst_1_tuition_fees            => l_fnar.im_inst_1_tuition_fees,
                                             x_im_inst_1_books_supplies          => l_fnar.im_inst_1_books_supplies,
                                             x_im_inst_1_living_expenses         => l_fnar.im_inst_1_living_expenses,
                                             x_im_inst_1_tot_expenses            => l_fnar.im_inst_1_tot_expenses,
                                             x_im_inst_1_tot_stu_cont            => l_fnar.im_inst_1_tot_stu_cont,
                                             x_im_inst_1_tot_par_cont            => l_fnar.im_inst_1_tot_par_cont,
                                             x_im_inst_1_tot_family_cont         => l_fnar.im_inst_1_tot_family_cont,
                                             x_im_inst_1_va_benefits             => l_fnar.im_inst_1_va_benefits,
                                             x_im_inst_1_ot_cont                 => l_fnar.im_inst_1_ot_cont,
                                             x_im_inst_1_est_financial_need      => l_fnar.im_inst_1_est_financial_need,
                                             x_institutional_2_budget_name       => l_fnar.institutional_2_budget_name,
                                             x_im_inst_2_budget_duration         => l_fnar.im_inst_2_budget_duration,
                                             x_im_inst_2_tuition_fees            => l_fnar.im_inst_2_tuition_fees,
                                             x_im_inst_2_books_supplies          => l_fnar.im_inst_2_books_supplies,
                                             x_im_inst_2_living_expenses         => l_fnar.im_inst_2_living_expenses,
                                             x_im_inst_2_tot_expenses            => l_fnar.im_inst_2_tot_expenses,
                                             x_im_inst_2_tot_stu_cont            => l_fnar.im_inst_2_tot_stu_cont,
                                             x_im_inst_2_tot_par_cont            => l_fnar.im_inst_2_tot_par_cont,
                                             x_im_inst_2_tot_family_cont         => l_fnar.im_inst_2_tot_family_cont,
                                             x_im_inst_2_va_benefits             => l_fnar.im_inst_2_va_benefits,
                                             x_im_inst_2_est_financial_need      => l_fnar.im_inst_2_est_financial_need,
                                             x_institutional_3_budget_name       => l_fnar.institutional_3_budget_name,
                                             x_im_inst_3_budget_duration         => l_fnar.im_inst_3_budget_duration,
                                             x_im_inst_3_tuition_fees            => l_fnar.im_inst_3_tuition_fees,
                                             x_im_inst_3_books_supplies          => l_fnar.im_inst_3_books_supplies,
                                             x_im_inst_3_living_expenses         => l_fnar.im_inst_3_living_expenses,
                                             x_im_inst_3_tot_expenses            => l_fnar.im_inst_3_tot_expenses,
                                             x_im_inst_3_tot_stu_cont            => l_fnar.im_inst_3_tot_stu_cont,
                                             x_im_inst_3_tot_par_cont            => l_fnar.im_inst_3_tot_par_cont,
                                             x_im_inst_3_tot_family_cont         => l_fnar.im_inst_3_tot_family_cont,
                                             x_im_inst_3_va_benefits             => l_fnar.im_inst_3_va_benefits,
                                             x_im_inst_3_est_financial_need      => l_fnar.im_inst_3_est_financial_need,
                                             x_fm_inst_1_federal_efc             => l_fnar.fm_inst_1_federal_efc,
                                             x_fm_inst_1_va_benefits             => l_fnar.fm_inst_1_va_benefits,
                                             x_fm_inst_1_fed_eligibility         => l_fnar.fm_inst_1_fed_eligibility,
                                             x_fm_inst_1_pell                    => l_fnar.fm_inst_1_pell,
                                             x_option_par_loss_allow_ind         => l_fnar.option_par_loss_allow_ind,
                                             x_option_par_tuition_ind            => l_fnar.option_par_tuition_ind,
                                             x_option_par_home_ind               => l_fnar.option_par_home_ind,
                                             x_option_par_home_value             => l_fnar.option_par_home_value,
                                             x_option_par_home_debt              => l_fnar.option_par_home_debt,
                                             x_option_stu_ira_keogh_ind          => l_fnar.option_stu_ira_keogh_ind,
                                             x_option_stu_home_ind               => l_fnar.option_stu_home_ind,
                                             x_option_stu_home_value             => l_fnar.option_stu_home_value,
                                             x_option_stu_home_debt              => l_fnar.option_stu_home_debt,
                                             x_option_stu_sum_ay_inc_ind         => l_fnar.option_stu_sum_ay_inc_ind,
                                             x_option_par_hope_ll_credit         => l_fnar.option_par_hope_ll_credit,
                                             x_option_stu_hope_ll_credit         => l_fnar.option_stu_hope_ll_credit,
                                             x_im_parent_1_8_months_bas          => l_fnar.im_parent_1_8_months_bas,
                                             x_im_p_more_than_9_mth_ba           => l_fnar.im_p_more_than_9_mth_ba,
                                             x_im_parent_1_8_months_opt          => l_fnar.im_parent_1_8_months_opt,
                                             x_im_p_more_than_9_mth_op           => l_fnar.im_p_more_than_9_mth_op,
                                             x_fnar_message_1                    => l_fnar.fnar_message_1,
                                             x_fnar_message_2                    => l_fnar.fnar_message_2,
                                             x_fnar_message_3                    => l_fnar.fnar_message_3,
                                             x_fnar_message_4                    => l_fnar.fnar_message_4,
                                             x_fnar_message_5                    => l_fnar.fnar_message_5,
                                             x_fnar_message_6                    => l_fnar.fnar_message_6,
                                             x_fnar_message_7                    => l_fnar.fnar_message_7,
                                             x_fnar_message_8                    => l_fnar.fnar_message_8,
                                             x_fnar_message_9                    => l_fnar.fnar_message_9,
                                             x_fnar_message_10                   => l_fnar.fnar_message_10,
                                             x_fnar_message_11                   => l_fnar.fnar_message_11,
                                             x_fnar_message_12                   => l_fnar.fnar_message_12,
                                             x_fnar_message_13                   => l_fnar.fnar_message_13,
                                             x_fnar_message_20                   => l_fnar.fnar_message_20,
                                             x_fnar_message_21                   => l_fnar.fnar_message_21,
                                             x_fnar_message_22                   => l_fnar.fnar_message_22,
                                             x_fnar_message_23                   => l_fnar.fnar_message_23,
                                             x_fnar_message_24                   => l_fnar.fnar_message_24,
                                             x_fnar_message_25                   => l_fnar.fnar_message_25,
                                             x_fnar_message_26                   => l_fnar.fnar_message_26,
                                             x_fnar_message_27                   => l_fnar.fnar_message_27,
                                             x_fnar_message_30                   => l_fnar.fnar_message_30,
                                             x_fnar_message_31                   => l_fnar.fnar_message_31,
                                             x_fnar_message_32                   => l_fnar.fnar_message_32,
                                             x_fnar_message_33                   => l_fnar.fnar_message_33,
                                             x_fnar_message_34                   => l_fnar.fnar_message_34,
                                             x_fnar_message_35                   => l_fnar.fnar_message_35,
                                             x_fnar_message_36                   => l_fnar.fnar_message_36,
                                             x_fnar_message_37                   => l_fnar.fnar_message_37,
                                             x_fnar_message_38                   => l_fnar.fnar_message_38,
                                             x_fnar_message_39                   => l_fnar.fnar_message_39,
                                             x_fnar_message_45                   => l_fnar.fnar_message_45,
                                             x_fnar_message_46                   => l_fnar.fnar_message_46,
                                             x_fnar_message_47                   => l_fnar.fnar_message_47,
                                             x_fnar_message_48                   => l_fnar.fnar_message_48,
                                             x_fnar_message_50                   => l_fnar.fnar_message_50,
                                             x_fnar_message_51                   => l_fnar.fnar_message_51,
                                             x_fnar_message_52                   => l_fnar.fnar_message_52,
                                             x_fnar_message_53                   => l_fnar.fnar_message_53,
                                             x_fnar_message_56                   => l_fnar.fnar_message_56,
                                             x_fnar_message_57                   => l_fnar.fnar_message_57,
                                             x_fnar_message_58                   => l_fnar.fnar_message_58,
                                             x_fnar_message_59                   => l_fnar.fnar_message_59,
                                             x_fnar_message_60                   => l_fnar.fnar_message_60,
                                             x_fnar_message_61                   => l_fnar.fnar_message_61,
                                             x_fnar_message_62                   => l_fnar.fnar_message_62,
                                             x_fnar_message_63                   => l_fnar.fnar_message_63,
                                             x_fnar_message_64                   => l_fnar.fnar_message_64,
                                             x_fnar_message_65                   => l_fnar.fnar_message_65,
                                             x_fnar_message_71                   => l_fnar.fnar_message_71,
                                             x_fnar_message_72                   => l_fnar.fnar_message_72,
                                             x_fnar_message_73                   => l_fnar.fnar_message_73,
                                             x_fnar_message_74                   => l_fnar.fnar_message_74,
                                             x_fnar_message_75                   => l_fnar.fnar_message_75,
                                             x_fnar_message_76                   => l_fnar.fnar_message_76,
                                             x_fnar_message_77                   => l_fnar.fnar_message_77,
                                             x_fnar_message_78                   => l_fnar.fnar_message_78,
                                             x_fnar_mesg_10_stu_fam_mem          => l_fnar.fnar_mesg_10_stu_fam_mem,
                                             x_fnar_mesg_11_stu_no_in_coll       => l_fnar.fnar_mesg_11_stu_no_in_coll,
                                             x_fnar_mesg_24_stu_avail_inc        => l_fnar.fnar_mesg_24_stu_avail_inc,
                                             x_fnar_mesg_26_stu_taxes            => l_fnar.fnar_mesg_26_stu_taxes,
                                             x_fnar_mesg_33_stu_home_value       => l_fnar.fnar_mesg_33_stu_home_value,
                                             x_fnar_mesg_34_stu_home_value       => l_fnar.fnar_mesg_34_stu_home_value,
                                             x_fnar_mesg_34_stu_home_equity      => l_fnar.fnar_mesg_34_stu_home_equity,
                                             x_fnar_mesg_35_stu_home_value       => l_fnar.fnar_mesg_35_stu_home_value,
                                             x_fnar_mesg_35_stu_home_equity      => l_fnar.fnar_mesg_35_stu_home_equity,
                                             x_fnar_mesg_36_stu_home_equity      => l_fnar.fnar_mesg_36_stu_home_equity,
                                             x_fnar_mesg_48_par_fam_mem          => l_fnar.fnar_mesg_48_par_fam_mem,
                                             x_fnar_mesg_49_par_no_in_coll       => l_fnar.fnar_mesg_49_par_no_in_coll,
                                             x_fnar_mesg_56_par_agi              => l_fnar.fnar_mesg_56_par_agi,
                                             x_fnar_mesg_62_par_taxes            => l_fnar.fnar_mesg_62_par_taxes,
                                             x_fnar_mesg_73_par_home_value       => l_fnar.fnar_mesg_73_par_home_value,
                                             x_fnar_mesg_74_par_home_value       => l_fnar.fnar_mesg_74_par_home_value,
                                             x_fnar_mesg_74_par_home_equity      => l_fnar.fnar_mesg_74_par_home_equity,
                                             x_fnar_mesg_75_par_home_value       => l_fnar.fnar_mesg_75_par_home_value,
                                             x_fnar_mesg_75_par_home_equity      => l_fnar.fnar_mesg_75_par_home_equity,
                                             x_fnar_mesg_76_par_home_equity      => l_fnar.fnar_mesg_76_par_home_equity,
                                             x_assumption_message_1              => l_fnar.assumption_message_1,
                                             x_assumption_message_2              => l_fnar.assumption_message_2,
                                             x_assumption_message_3              => l_fnar.assumption_message_3,
                                             x_assumption_message_4              => l_fnar.assumption_message_4,
                                             x_assumption_message_5              => l_fnar.assumption_message_5,
                                             x_assumption_message_6              => l_fnar.assumption_message_6,
                                             x_record_mark                       => l_fnar.record_mark,
                                             x_mode                              => 'R',
                                             x_fnar_message_55                   => l_fnar.fnar_message_55,
                                             x_fnar_message_49                   => l_fnar.fnar_message_49,
                                             x_opt_par_cola_adj_ind              => l_fnar.option_par_cola_adj_ind,
                                             x_opt_par_stu_fa_assets_ind         => l_fnar.option_par_stu_fa_assets_ind,
                                             x_opt_par_ipt_assets_ind            => l_fnar.option_par_ipt_assets_ind,
                                             x_opt_stu_ipt_assets_ind            => l_fnar.option_stu_ipt_assets_ind,
                                             x_opt_par_cola_adj_value            => l_fnar.option_par_cola_adj_value,
                                             x_legacy_record_flag                => l_fnar.legacy_record_flag,
                                             x_opt_ind_stu_ipt_assets_flag       => l_fnar.option_ind_stu_ipt_assets_flag,
                                             x_cust_parent_cont_adj_num          => l_fnar.cust_parent_cont_adj_num,
                                             x_custodial_parent_num              => l_fnar.custodial_parent_num,
                                             x_cust_par_base_prcnt_inc_amt       => l_fnar.cust_par_base_prcnt_inc_amt,
                                             x_cust_par_base_cont_inc_amt        => l_fnar.cust_par_base_cont_inc_amt,
                                             x_cust_par_base_cont_ast_amt        => l_fnar.cust_par_base_cont_ast_amt,
                                             x_cust_par_base_tot_cont_amt        => l_fnar.cust_par_base_tot_cont_amt,
                                             x_cust_par_opt_prcnt_inc_amt        => l_fnar.cust_par_opt_prcnt_inc_amt,
                                             x_cust_par_opt_cont_inc_amt         => l_fnar.cust_par_opt_cont_inc_amt,
                                             x_cust_par_opt_cont_ast_amt         => l_fnar.cust_par_opt_cont_ast_amt,
                                             x_cust_par_opt_tot_cont_amt         => l_fnar.cust_par_opt_cont_ast_amt,
                                             x_parents_email_txt                 => l_fnar.parents_email_txt,
                                             x_parent_1_birth_date               => l_fnar.parent_1_birth_date,
                                             x_parent_2_birth_date               => l_fnar.parent_2_birth_date
                                            );
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK TO SP_PROFILE_ID;
              fnd_message.set_name('IGF','IGF_AP_PROF_UPD_FAIL');
              fnd_file.put_line(fnd_file.log,g_tab_2 || fnd_message.get);
              RAISE SKIP_PROFILE_RECORD;
          END; -- End of PROFILE Update block

          fnd_message.set_name('IGF','IGF_AP_PROF_EFC_CALC_SUCCESS');
          fnd_file.put_line(fnd_file.log,g_tab_2 || fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);
          g_success := g_success + 1;

        EXCEPTION
          WHEN SKIP_PROFILE_RECORD THEN
            g_error := g_error + 1;
        END; -- End of PROFILE Prcoessing block

        -- Get the Next PROFILE Record
        FETCH c_all_profiles INTO l_profile;

      END LOOP;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END calculate_efc;


  PROCEDURE main(
                  errbuf           OUT NOCOPY    VARCHAR2,
                  retcode          OUT NOCOPY    NUMBER,
                  p_award_year     IN            VARCHAR2,
                  p_base_id        IN            igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_persid_grp     IN            igs_pe_persid_group_all.group_id%TYPE
            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 08-OCT-2003
  --
  --Purpose: This is the main procedure invoked when the concurrent job is called
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --  Who                When           What
  --  ridas          07-Feb-2006      Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
  --  tsailaja		   13/Jan/2006      Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  -------------------------------------------------------------------
  lv_status VARCHAR2(1);
  l_list    VARCHAR2(32767);

  l_processing_log igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' ';
  l_pers_number_log igf_lookups_view.meaning%TYPE DEFAULT igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_NUMBER') || ' ';

  -- Get base_ids from person id group
  CURSOR c_base_id(
                    cp_seq_number     igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                    cp_cal_type       igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                    cp_person_id      igf_ap_fa_base_rec_all.person_id%TYPE
                  ) IS
    SELECT base_id
      FROM igf_ap_fa_base_rec_all
     WHERE ci_sequence_number = cp_seq_number
       AND ci_cal_type        = cp_cal_type
       AND person_id          = cp_person_id;

  l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE;
  l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;

  -- Get all base ids in a award year
  CURSOR c_all_base_id(
                       cp_seq_number     igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                       cp_cal_type       igf_ap_fa_base_rec_all.ci_cal_type%TYPE
                      ) IS
    SELECT base_id
    FROM   igf_ap_fa_base_rec_all
    WHERE  ci_sequence_number = cp_seq_number
    AND    ci_cal_type        = cp_cal_type;

  TYPE cur_person_id_type IS REF CURSOR;
  lc_person_id cur_person_id_type;

  l_person_id igf_ap_fa_base_rec_all.person_id%TYPE;

  TYPE base_idRefCur IS REF CURSOR;
  lc_base_id base_idRefCur;
  lbase igf_ap_fa_base_rec_all.base_id%TYPE;

  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    --find cal type and sequence number
    l_cal_type    := TRIM(SUBSTR(p_award_year,1,10));
    l_seq_number  := TO_NUMBER(SUBSTR(p_award_year,11));
    errbuf        := NULL;
    retcode       := 0;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','l_cal_type:'||l_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','l_seq_number:'||l_seq_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','p_persid_grp:'||p_persid_grp);
    END IF;
    --Start Logging the parameters
    log_parameters(l_cal_type,l_seq_number,p_base_id,p_persid_grp);

    IF p_base_id IS NOT NULL AND p_persid_grp IS NOT NULL THEN
      --Error.Cant have both parameters as not null
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','Cant specify both base_id and persid_grp.exiting');
      END IF;
      fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;

    IF NOT igf_aw_gen_004.is_inas_integrated THEN
      --Error.INAS has to be integrated
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','INAS not integrated');
      END IF;
      fnd_message.set_name('IGF','IGF_AP_INAS_NOT_ITEGRATED');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      retcode := 2;
      RETURN;
    END IF;


    IF p_base_id IS NOT NULL THEN

      --log a message saying processing person number
      OPEN c_person_number(p_base_id);
      FETCH c_person_number INTO l_person_number;
      CLOSE c_person_number;

      fnd_file.put_line(fnd_file.log,l_processing_log || l_pers_number_log || l_person_number);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','calling calculate_efc with base_id:'||p_base_id);
      END IF;
      --base_id specified. so calculate EFC for all profiles of the current base_id
      calculate_efc(l_cal_type,l_seq_number,p_base_id);

    ELSIF p_persid_grp IS NOT NULL THEN
      --person_id_group specified. So, calculate EFC for all PROFILEs of all persons in the group
      --get the list of persons in the person id group

      --Bug #5021084. Added new parameter 'lv_group_type'
      l_list := igf_ap_ss_pkg.get_pid(p_persid_grp,lv_status,lv_group_type);

      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN lc_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_cal_type, l_seq_number, p_persid_grp;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN lc_base_id FOR ' SELECT base_id FROM igf_ap_fa_base_rec_all WHERE  ci_cal_type = :p_ci_cal_type AND  ci_sequence_number = :p_ci_sequence_number AND  person_id IN (' || l_list  || ') ' USING l_cal_type, l_seq_number;
      END IF;

      FETCH lc_base_id INTO lbase;
      IF lc_base_id%FOUND THEN
        WHILE lc_base_id%FOUND
        LOOP
          --calculate efc

          --log a message saying processing person number
          OPEN c_person_number(lbase);
          FETCH c_person_number INTO l_person_number;
          CLOSE c_person_number;

          fnd_file.put_line(fnd_file.log,l_processing_log || l_pers_number_log || l_person_number);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','calling calculate_efc with base_id:'||lbase);
          END IF;

          calculate_efc(l_cal_type,l_seq_number,lbase);

          FETCH lc_base_id INTO lbase;
        END LOOP;
      ELSE
        fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;
    ELSIF p_base_id IS NULL AND p_persid_grp IS NULL THEN
      --both person id and person id group is null
      --calculate efc for all persons in the award year

      FOR l_all_base_id IN c_all_base_id(l_seq_number,l_cal_type)
      LOOP

        --log a message saying processing person number
        OPEN c_person_number(l_all_base_id.base_id);
        FETCH c_person_number INTO l_person_number;
        CLOSE c_person_number;

        fnd_file.put_line(fnd_file.log,l_processing_log || l_pers_number_log || l_person_number);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_calc_im_efc.main.debug','calling calculate_efc with base_id:'||l_all_base_id.base_id);
        END IF;
        --calculate efc
        calculate_efc(l_cal_type,l_seq_number,l_all_base_id.base_id);

      END LOOP;

    END IF;

    g_total := g_success + g_error;

    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.output,' ');
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get || ' ',40) || g_total);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_COMPLETED');
    fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get || ' ',40) || g_success);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get || ' : ',40) || g_error);
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.output,' ');

    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.log,' ');
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get || ' ',40) || g_total);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_COMPLETED');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get || ' ',40) || g_success);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get || ' : ',40) || g_error);
    fnd_file.put_line(fnd_file.log,' ');
    fnd_file.put_line(fnd_file.log, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.log,' ');

    EXCEPTION
      WHEN OTHERS THEN
        retcode := 2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_CALC_IM_EFC.MAIN '||SQLERRM);
        errbuf := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;
  END main;

END igf_ap_calc_im_efc;

/
