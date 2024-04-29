--------------------------------------------------------
--  DDL for Package Body IGF_AP_PROFILE_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_PROFILE_MATCHING_PKG" AS
/* $Header: IGFAP16B.pls 120.9 2006/06/30 07:55:34 rajagupt ship $ */

    g_setup_score         igf_ap_record_match%ROWTYPE ;
-- #2376750  made cur_data global
    g_cur_data            igf_ap_css_interface%ROWTYPE ;
    INVALID_PROFILE_ERROR EXCEPTION;
    SKIP_PERSON           EXCEPTION;
    g_total_processed     NUMBER(8)  ;
    g_matched_rec         NUMBER(8)  ;
    g_unmatched_rec       NUMBER(8)  ;
    g_unmatched_added     NUMBER(8)  ;
    g_bad_rec             NUMBER(8)  ;
    g_duplicate_rec       NUMBER(8);
    g_record_inserted     BOOLEAN    ;
    g_total_rvw           NUMBER(8)  ;
    lv_record_status      igf_ap_match_Details.record_status%TYPE;
    g_force_add           VARCHAR2(1);
    g_create_inquiry      VARCHAR2(1);
    g_adm_source_type     VARCHAR2(30);
    g_ci_cal_type         igf_ap_batch_aw_map.ci_cal_type%TYPE;
    g_ci_sequence_number  igf_ap_batch_aw_map.ci_sequence_number%TYPE;
    g_match_code          VARCHAR2(30);
    g_school_code         VARCHAR2(30);
    g_rec_type            VARCHAR2(1);
    g_profile_year        VARCHAR2(30);
    g_active_profile      VARCHAR2(1);
    g_person_id           NUMBER;
    g_base_id             NUMBER;
    g_debug_seq           NUMBER := 0;

   CURSOR cur_setup_score (cp_match_code igf_ap_record_match_all.match_code%TYPE) IS
   SELECT *
   FROM   igf_ap_record_match
   WHERE  match_code = cp_match_code;

PROCEDURE log_debug_message(m VARCHAR2)
IS
-- for debugging/testing

BEGIN
   g_debug_seq := g_debug_seq + 1;
   --INSERT INTO RAN_DEBUG values (g_debug_seq,m);
  /* IF g_enable_debug_logging = 'Y' THEN
      g_debug_seq := g_debug_seq + 1;
  --    fnd_file.put_line(fnd_file.log, m);
  -- INSERT INTO RAN_DEBUG values (g_debug_seq,m);

   END IF; */
END log_debug_message;
  FUNCTION convert_int(col_value VARCHAR2) RETURN VARCHAR2 IS
 /*
  ||  Created By : rasahoo
  ||  Created On : 24-AUG-2004
  ||  Purpose : This function will return the  numberic value  of the given column value  , i.e taken through the parameter
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
      RETURN TO_NUMBER(col_value);

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.convert_int.exception','The exception is : ' || SQLERRM );
      END IF;
      RETURN col_value;
  END convert_int ;

PROCEDURE update_person_info (p_person_id igf_ap_fa_base_rec.person_id%TYPE)
   IS
     /*
     ||  Created By : upinjark
     ||  Created On : 19-Sept-2005
     ||  Purpose :Code is added to create Email address as a part of
     ||  IGS.M bug fix for bug 3944249. This is a replica of branch line
     ||  bug no 3941146. If no primary Email is
     ||  present Email Address will be created. If primary Email is present
     ||  then it will not update the Email address, but it will will log a
     ||  message that "E-Mail Id EMAIL_ID indicated in the PROFILE record
     ||  does not exist in System for the Person."
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who       When          What
     */
       l_msg_data              VARCHAR2(2000);
       l_msg_count             NUMBER;

       p_contact_points_rec       HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
       p_email_rec                HZ_CONTACT_POINT_V2PUB.email_rec_type := NULL;
       p_phone_rec                HZ_CONTACT_POINT_V2PUB.phone_rec_type;
       l_return_status             VARCHAR2(25);
       l_contact_point_id          hz_contact_points.contact_point_id%TYPE := NULL;
       l_chk_email                 hz_parties.email_address%TYPE;

       CURSOR c_chk_email_addr (cp_person_id   hz_parties.party_id%TYPE)
       IS
       SELECT email_address
       FROM  hz_parties
       WHERE party_id = cp_person_id
       AND   email_address IS NOT NULL;

   BEGIN

       IF g_cur_data.r_s_email_address IS NOT NULL THEN

               l_chk_email := NULL;
               OPEN c_chk_email_addr(p_person_id);
               FETCH c_chk_email_addr INTO l_chk_email;
               CLOSE c_chk_email_addr;

               p_contact_points_rec.contact_point_type :=  'EMAIL';
               p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
               p_contact_points_rec.owner_table_id := p_person_id;
               p_contact_points_rec.content_source_type := 'USER_ENTERED';
               p_contact_points_rec.created_by_module := 'IGF';
               p_email_rec.email_format := 'MAILHTML';
               p_email_rec.email_address := g_cur_data.r_s_email_address;

               /*IF l_chk_email = 'Y' THEN
                  -- Email already exists. Hence insert a new Non Primary e-mail address
                  p_contact_points_rec.primary_flag := NULL;
               ELSE
                  -- Email does not exist. Hence insert a new e-mail address as Primary
                  p_contact_points_rec.primary_flag := 'Y';
               END IF;*/

               IF l_chk_email IS NULL THEN
                -- new e-mail needs to be created
                 p_contact_points_rec.primary_flag := NULL;

                  HZ_CONTACT_POINT_V2PUB.create_contact_point(
                                               p_init_msg_list         => FND_API.G_FALSE,
                                               p_contact_point_rec     => p_contact_points_rec,
                                               p_email_rec             => p_email_rec,
                                               p_phone_rec             => p_phone_rec,
                                               x_return_status         => l_return_status,
                                               x_msg_count             => l_msg_count,
                                               x_msg_data              => l_msg_data,
                                               x_contact_point_id      => l_contact_point_id
                                                              );

               ELSE

                 IF LOWER(l_chk_email) <> LOWER(g_cur_data.r_s_email_address) THEN
                        fnd_message.set_name('IGF','IGF_AP_PROF_EMAIL_NTFND');
                        fnd_message.set_token('EMAIL_ID',g_cur_data.r_s_email_address);
                        fnd_file.put_line(fnd_file.log,fnd_message.get);
                 END IF;

               END IF;
     END IF;
     EXCEPTION
       WHEN others THEN
         IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_person_info.exception','The exception is : ' || SQLERRM );
         END IF;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_PROFILE_MATCHING_PKG.update_person_info');
         fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
   END update_person_info;

PROCEDURE create_email_address (p_person_id igf_ap_fa_base_rec.person_id%TYPE)
IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 11-Oct-2004
  ||  Purpose :Code is added to create Email address.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When          What
  */
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;

    p_contact_points_rec       HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
    p_email_rec                HZ_CONTACT_POINT_V2PUB.email_rec_type := NULL;
    p_phone_rec                HZ_CONTACT_POINT_V2PUB.phone_rec_type;
    l_return_status             VARCHAR2(25);
    l_contact_point_id          hz_contact_points.contact_point_id%TYPE := NULL;
BEGIN

    IF g_cur_data.r_s_email_address IS NOT NULL THEN
      p_contact_points_rec.contact_point_type :=  'EMAIL';
      p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
      p_contact_points_rec.owner_table_id := p_person_id;
      p_contact_points_rec.content_source_type := 'USER_ENTERED';
      p_contact_points_rec.created_by_module := 'IGF';
      p_email_rec.email_format := 'MAILHTML';
      p_email_rec.email_address := g_cur_data.r_s_email_address;

      p_contact_points_rec.primary_flag := NULL;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.create_email_address.debug','Before creating Email Address' );
        END IF;
         HZ_CONTACT_POINT_V2PUB.create_contact_point(
              p_init_msg_list         => FND_API.G_FALSE,
              p_contact_point_rec     => p_contact_points_rec,
              p_email_rec             => p_email_rec,
              p_phone_rec             => p_phone_rec,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              x_contact_point_id      => l_contact_point_id
                 );

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.create_email_address.debug','After creating Email Address' );
        END IF;
  END IF;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_email_address.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_PROFILE_MATCHING_PKG.create_email_address');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.create_email_address' || SQLERRM);
   END create_email_address;

  PROCEDURE  make_profile_inactive( cp_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
 /*
  ||  Created By : rasahoo
  ||  Created On : 24-AUG-2004
  ||  Purpose : Makes all profile records inactive
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    -- cursor to update the active_profile of igf_ap_css_profile to 'N'
    CURSOR cur_css_profile(x_base_id  igf_ap_fa_base_rec.base_id%TYPE) IS
   SELECT ROWID row_id, css.*
     FROM   igf_ap_css_profile_all css
     WHERE  base_id = x_base_id FOR UPDATE NOWAIT ;
  BEGIN
    -- Cursor  for updating the active_profile of all the old profile records of the student to 'n'
    FOR  css_profile_data IN cur_css_profile(cp_base_id) LOOP
        igf_ap_css_profile_pkg.update_row (
                         X_Mode                              => 'R',
                         x_rowid                             => css_profile_data.row_id,
                         x_cssp_id                           => css_profile_data.cssp_id,
                         x_base_id                           => css_profile_data.base_id,
                         x_system_record_type                => css_profile_data.system_record_type,
                         x_active_profile                    => 'N',
                         x_college_code                      => css_profile_data.college_code,
                         x_academic_year                     => css_profile_data.academic_year,
                         x_stu_record_type                   => css_profile_data.stu_record_type,
                         x_css_id_number                     => css_profile_data.css_id_number,
                         x_registration_receipt_date         => css_profile_data.registration_receipt_date,
                         x_registration_type                 => css_profile_data.registration_type,
                         x_application_receipt_date          => css_profile_data.application_receipt_date,
                         x_application_type                  => css_profile_data.application_type,
                         x_original_fnar_compute             => css_profile_data.original_fnar_compute,
                         x_revision_fnar_compute_date        => css_profile_data.revision_fnar_compute_date,
                         x_electronic_extract_date           => css_profile_data.electronic_extract_date,
                         x_institutional_reporting_type      => css_profile_data.institutional_reporting_type,
                         x_asr_receipt_date                  => css_profile_data.asr_receipt_date,
                         x_last_name                         => css_profile_data.last_name,
                         x_first_name                        => css_profile_data.first_name,
                         x_middle_initial                    => css_profile_data.middle_initial,
                         x_address_number_and_street         => css_profile_data.address_number_and_street,
                         x_city                              => css_profile_data.city,
                         x_state_mailing                     => css_profile_data.state_mailing,
                         x_zip_code                          => css_profile_data.zip_code,
                         x_s_telephone_number                => css_profile_data.s_telephone_number,
                         x_s_title                           => css_profile_data.s_title,
                         x_date_of_birth                     => css_profile_data.date_of_birth,
                         x_social_security_number            => css_profile_data.social_security_number,
                         x_state_legal_residence             => css_profile_data.state_legal_residence,
                         x_foreign_address_indicator         => css_profile_data.foreign_address_indicator,
                         x_foreign_postal_code               => css_profile_data.foreign_postal_code,
                         x_country                           => css_profile_data.country,
                         x_financial_aid_status              => css_profile_data.financial_aid_status,
                         x_year_in_college                   => css_profile_data.year_in_college,
                         x_marital_status                    => css_profile_data.marital_status,
                         x_ward_court                        => css_profile_data.ward_court,
                         x_legal_dependents_other            => css_profile_data.legal_dependents_other,
                         x_household_size                    => css_profile_data.household_size,
                         x_number_in_college                 => css_profile_data.number_in_college,
                         x_citizenship_status                => css_profile_data.citizenship_status,
                         x_citizenship_country               => css_profile_data.citizenship_country,
                         x_visa_classification               => css_profile_data.visa_classification,
                         x_tax_figures                       => css_profile_data.tax_figures,
                         x_number_exemptions                 => css_profile_data.number_exemptions,
                         x_adjusted_gross_inc                => css_profile_data.adjusted_gross_inc,
                         x_us_tax_paid                       => css_profile_data.us_tax_paid,
                         x_itemized_deductions               => css_profile_data.itemized_deductions,
                         x_stu_income_work                   => css_profile_data.stu_income_work,
                         x_spouse_income_work                => css_profile_data.spouse_income_work,
                         x_divid_int_inc                     => css_profile_data.divid_int_inc,
                         x_soc_sec_benefits                  => css_profile_data.soc_sec_benefits,
                         x_welfare_tanf                      => css_profile_data.welfare_tanf,
                         x_child_supp_rcvd                   => css_profile_data.child_supp_rcvd,
                         x_earned_income_credit              => css_profile_data.earned_income_credit,
                         x_other_untax_income                => css_profile_data.other_untax_income,
                         x_tax_stu_aid                       => css_profile_data.tax_stu_aid,
                         x_cash_sav_check                    => css_profile_data.cash_sav_check,
                         x_ira_keogh                         => css_profile_data.ira_keogh,
                         x_invest_value                      => css_profile_data.invest_value,
                         x_invest_debt                       => css_profile_data.invest_debt,
                         x_home_value                        => css_profile_data.home_value,
                         x_home_debt                         => css_profile_data.home_debt,
                         x_oth_real_value                    => css_profile_data.oth_real_value,
                         x_oth_real_debt                     => css_profile_data.oth_real_debt,
                         x_bus_farm_value                    => css_profile_data.bus_farm_value,
                         x_bus_farm_debt                     => css_profile_data.bus_farm_debt,
                         x_live_on_farm                      => css_profile_data.live_on_farm,
                         x_home_purch_price                  => css_profile_data.home_purch_price,
                         x_hope_ll_credit                    => css_profile_data.hope_ll_credit,
                         x_home_purch_year                   => css_profile_data.home_purch_year,
                         x_trust_amount                      => css_profile_data.trust_amount,
                         x_trust_avail                       => css_profile_data.trust_avail,
                         x_trust_estab                       => css_profile_data.trust_estab,
                         x_child_support_paid                => css_profile_data.child_support_paid,
                         x_med_dent_expenses                 => css_profile_data.med_dent_expenses,
                         x_vet_us                            => css_profile_data.vet_us,
                         x_vet_ben_amount                    => css_profile_data.vet_ben_amount,
                         x_vet_ben_months                    => css_profile_data.vet_ben_months,
                         x_stu_summer_wages                  => css_profile_data.stu_summer_wages,
                         x_stu_school_yr_wages               => css_profile_data.stu_school_yr_wages,
                         x_spouse_summer_wages               => css_profile_data.spouse_summer_wages,
                         x_spouse_school_yr_wages            => css_profile_data.spouse_school_yr_wages,
                         x_summer_other_tax_inc              => css_profile_data.summer_other_tax_inc,
                         x_school_yr_other_tax_inc           => css_profile_data.school_yr_other_tax_inc,
                         x_summer_untax_inc                  => css_profile_data.summer_untax_inc,
                         x_school_yr_untax_inc               => css_profile_data.school_yr_untax_inc,
                         x_grants_schol_etc                  => css_profile_data.grants_schol_etc,
                         x_tuit_benefits                     => css_profile_data.tuit_benefits,
                         x_cont_parents                      => css_profile_data.cont_parents,
                         x_cont_relatives                    => css_profile_data.cont_relatives,
                         x_p_siblings_pre_tuit               => css_profile_data.p_siblings_pre_tuit,
                         x_p_student_pre_tuit                => css_profile_data.p_student_pre_tuit,
                         x_p_household_size                  => css_profile_data.p_household_size,
                         x_p_number_in_college               => css_profile_data.p_number_in_college,
                         x_p_parents_in_college              => css_profile_data.p_parents_in_college,
                         x_p_marital_status                  => css_profile_data.p_marital_status,
                         x_p_state_legal_residence           => css_profile_data.p_state_legal_residence,
                         x_p_natural_par_status              => css_profile_data.p_natural_par_status,
                         x_p_child_supp_paid                 => css_profile_data.p_child_supp_paid,
                         x_p_repay_ed_loans                  => css_profile_data.p_repay_ed_loans,
                         x_p_med_dent_expenses               => css_profile_data.p_med_dent_expenses,
                         x_p_tuit_paid_amount                => css_profile_data.p_tuit_paid_amount,
                         x_p_tuit_paid_number                => css_profile_data.p_tuit_paid_number,
                         x_p_exp_child_supp_paid             => css_profile_data.p_exp_child_supp_paid,
                         x_p_exp_repay_ed_loans              => css_profile_data.p_exp_repay_ed_loans,
                         x_p_exp_med_dent_expenses           => css_profile_data.p_exp_med_dent_expenses,
                         x_p_exp_tuit_pd_amount              => css_profile_data.p_exp_tuit_pd_amount,
                         x_p_exp_tuit_pd_number              => css_profile_data.p_exp_tuit_pd_number,
                         x_p_cash_sav_check                  => css_profile_data.p_cash_sav_check,
                         x_p_month_mortgage_pay              => css_profile_data.p_month_mortgage_pay,
                         x_p_invest_value                    => css_profile_data.p_invest_value,
                         x_p_invest_debt                     => css_profile_data.p_invest_debt,
                         x_p_home_value                      => css_profile_data.p_home_value,
                         x_p_home_debt                       => css_profile_data.p_home_debt,
                         x_p_home_purch_price                => css_profile_data.p_home_purch_price,
                         x_p_own_business_farm               => css_profile_data.p_own_business_farm,
                         x_p_business_value                  => css_profile_data.p_business_value,
                         x_p_business_debt                   => css_profile_data.p_business_debt,
                         x_p_farm_value                      => css_profile_data.p_farm_value,
                         x_p_farm_debt                       => css_profile_data.p_farm_debt,
                         x_p_live_on_farm                    => css_profile_data.p_live_on_farm,
                         x_p_oth_real_estate_value           => css_profile_data.p_oth_real_estate_value,
                         x_p_oth_real_estate_debt            => css_profile_data.p_oth_real_estate_debt,
                         x_p_oth_real_purch_price            => css_profile_data.p_oth_real_purch_price,
                         x_p_siblings_assets                 => css_profile_data.p_siblings_assets,
                         x_p_home_purch_year                 => css_profile_data.p_home_purch_year,
                         x_p_oth_real_purch_year             => css_profile_data.p_oth_real_purch_year,
                         x_p_prior_agi                       => css_profile_data.p_prior_agi,
                         x_p_prior_us_tax_paid               => css_profile_data.p_prior_us_tax_paid,
                         x_p_prior_item_deductions           => css_profile_data.p_prior_item_deductions,
                         x_p_prior_other_untax_inc           => css_profile_data.p_prior_other_untax_inc,
                         x_p_tax_figures                     => css_profile_data.p_tax_figures,
                         x_p_number_exemptions               => css_profile_data.p_number_exemptions,
                         x_p_adjusted_gross_inc              => css_profile_data.p_adjusted_gross_inc,
                         x_p_wages_sal_tips                  => css_profile_data.p_wages_sal_tips,
                         x_p_interest_income                 => css_profile_data.p_interest_income,
                         x_p_dividend_income                 => css_profile_data.p_dividend_income,
                         x_p_net_inc_bus_farm                => css_profile_data.p_net_inc_bus_farm,
                         x_p_other_taxable_income            => css_profile_data.p_other_taxable_income,
                         x_p_adj_to_income                   => css_profile_data.p_adj_to_income,
                         x_p_us_tax_paid                     => css_profile_data.p_us_tax_paid,
                         x_p_itemized_deductions             => css_profile_data.p_itemized_deductions,
                         x_p_father_income_work              => css_profile_data.p_father_income_work,
                         x_p_mother_income_work              => css_profile_data.p_mother_income_work,
                         x_p_soc_sec_ben                     => css_profile_data.p_soc_sec_ben,
                         x_p_welfare_tanf                    => css_profile_data.p_welfare_tanf,
                         x_p_child_supp_rcvd                 => css_profile_data.p_child_supp_rcvd,
                         x_p_ded_ira_keogh                   => css_profile_data.p_ded_ira_keogh,
                         x_p_tax_defer_pens_savs             => css_profile_data.p_tax_defer_pens_savs,
                         x_p_dep_care_med_spending           => css_profile_data.p_dep_care_med_spending,
                         x_p_earned_income_credit            => css_profile_data.p_earned_income_credit,
                         x_p_living_allow                    => css_profile_data.p_living_allow,
                         x_p_tax_exmpt_int                   => css_profile_data.p_tax_exmpt_int,
                         x_p_foreign_inc_excl                => css_profile_data.p_foreign_inc_excl,
                         x_p_other_untax_inc                 => css_profile_data.p_other_untax_inc,
                         x_p_hope_ll_credit                  => css_profile_data.p_hope_ll_credit,
                         x_p_yr_separation                   => css_profile_data.p_yr_separation,
                       x_p_yr_divorce                      => css_profile_data.p_yr_divorce,
                       x_p_exp_father_inc                  => css_profile_data.p_exp_father_inc,
                       x_p_exp_mother_inc                  => css_profile_data.p_exp_mother_inc,
                       x_p_exp_other_tax_inc               => css_profile_data.p_exp_other_tax_inc,
                       x_p_exp_other_untax_inc             => css_profile_data.p_exp_other_untax_inc,
                       x_line_2_relation                   => css_profile_data.line_2_relation,
                       x_line_2_attend_college             => css_profile_data.line_2_attend_college,
                       x_line_3_relation                   => css_profile_data.line_3_relation,
                       x_line_3_attend_college             => css_profile_data.line_3_attend_college,
                       x_line_4_relation                   => css_profile_data.line_4_relation,
                       x_line_4_attend_college             => css_profile_data.line_4_attend_college,
                       x_line_5_relation                   => css_profile_data.line_5_relation,
                       x_line_5_attend_college             => css_profile_data.line_5_attend_college,
                       x_line_6_relation                   => css_profile_data.line_6_relation,
                       x_line_6_attend_college             => css_profile_data.line_6_attend_college,
                       x_line_7_relation                   => css_profile_data.line_7_relation,
                       x_line_7_attend_college             => css_profile_data.line_7_attend_college,
                       x_line_8_relation                   => css_profile_data.line_8_relation,
                       x_line_8_attend_college             => css_profile_data.line_8_attend_college,
                       x_p_age_father                      => css_profile_data.p_age_father,
                       x_p_age_mother                      => css_profile_data.p_age_mother,
                       x_p_div_sep_ind                     => css_profile_data.p_div_sep_ind,
                       x_b_cont_non_custodial_par          => css_profile_data.b_cont_non_custodial_par,
                       x_college_type_2                    => css_profile_data.college_type_2,
                       x_college_type_3                    => css_profile_data.college_type_3,
                       x_college_type_4                    => css_profile_data.college_type_4,
                       x_college_type_5                    => css_profile_data.college_type_5,
                       x_college_type_6                    => css_profile_data.college_type_6,
                       x_college_type_7                    => css_profile_data.college_type_7,
                       x_college_type_8                    => css_profile_data.college_type_8,
                       x_school_code_1                     => css_profile_data.school_code_1,
                       x_housing_code_1                    => css_profile_data.housing_code_1,
                       x_school_code_2                     => css_profile_data.school_code_2,
                       x_housing_code_2                    => css_profile_data.housing_code_2,
                       x_school_code_3                     => css_profile_data.school_code_3,
                       x_housing_code_3                    => css_profile_data.housing_code_3,
                       x_school_code_4                     => css_profile_data.school_code_4,
                       x_housing_code_4                    => css_profile_data.housing_code_4,
                       x_school_code_5                     => css_profile_data.school_code_5,
                       x_housing_code_5                    => css_profile_data.housing_code_5,
                       x_school_code_6                     => css_profile_data.school_code_6,
                       x_housing_code_6                    => css_profile_data.housing_code_6,
                       x_school_code_7                     => css_profile_data.school_code_7,
                       x_housing_code_7                    => css_profile_data.housing_code_7,
                       x_school_code_8                     => css_profile_data.school_code_8,
                       x_housing_code_8                    => css_profile_data.housing_code_8,
                       x_school_code_9                     => css_profile_data.school_code_9,
                       x_housing_code_9                    => css_profile_data.housing_code_9,
                       x_school_code_10                    => css_profile_data.school_code_10,
                       x_housing_code_10                   => css_profile_data.housing_code_10,
                       x_additional_school_code_1          => css_profile_data.additional_school_code_1,
                       x_additional_school_code_2          => css_profile_data.additional_school_code_2,
                       x_additional_school_code_3          => css_profile_data.additional_school_code_3,
                       x_additional_school_code_4          => css_profile_data.additional_school_code_4,
                       x_additional_school_code_5          => css_profile_data.additional_school_code_5,
                       x_additional_school_code_6          => css_profile_data.additional_school_code_6,
                       x_additional_school_code_7          => css_profile_data.additional_school_code_7,
                       x_additional_school_code_8          => css_profile_data.additional_school_code_8,
                       x_additional_school_code_9          => css_profile_data.additional_school_code_9,
                       x_additional_school_code_10         => css_profile_data.additional_school_code_10,
                       x_explanation_spec_circum           => css_profile_data.explanation_spec_circum,
                       x_signature_student                 => css_profile_data.signature_student,
                       x_signature_spouse                  => css_profile_data.signature_spouse,
                       x_signature_father                  => css_profile_data.signature_father,
                       x_signature_mother                  => css_profile_data.signature_mother,
                       x_month_day_completed               => css_profile_data.month_day_completed,
                       x_year_completed                    => css_profile_data.year_completed,
                       x_age_line_2                        => css_profile_data.age_line_2,
                       x_age_line_3                        => css_profile_data.age_line_3,
                       x_age_line_4                        => css_profile_data.age_line_4,
                       x_age_line_5                        => css_profile_data.age_line_5,
                       x_age_line_6                        => css_profile_data.age_line_6,
                       x_age_line_7                        => css_profile_data.age_line_7,
                       x_age_line_8                        => css_profile_data.age_line_8,
                       x_a_online_signature                => css_profile_data.a_online_signature,
                       x_question_1_number                 => css_profile_data.question_1_number,
                       x_question_1_size                   => css_profile_data.question_1_size,
                       x_question_1_answer                 => css_profile_data.question_1_answer,
                       x_question_2_number                 => css_profile_data.question_2_number,
                       x_question_2_size                   => css_profile_data.question_2_size,
                       x_question_2_answer                 => css_profile_data.question_2_answer,
                       x_question_3_number                 => css_profile_data.question_3_number,
                       x_question_3_size                   => css_profile_data.question_3_size,
                       x_question_3_answer                 => css_profile_data.question_3_answer,
                       x_question_4_number                 => css_profile_data.question_4_number,
                       x_question_4_size                   => css_profile_data.question_4_size,
                       x_question_4_answer                 => css_profile_data.question_4_answer,
                       x_question_5_number                 => css_profile_data.question_5_number,
                       x_question_5_size                   => css_profile_data.question_5_size,
                       x_question_5_answer                 => css_profile_data.question_5_answer,
                       x_question_6_number                 => css_profile_data.question_6_number,
                       x_question_6_size                   => css_profile_data.question_6_size,
                       x_question_6_answer                 => css_profile_data.question_6_answer,
                       x_question_7_number                 => css_profile_data.question_7_number,
                       x_question_7_size                   => css_profile_data.question_7_size,
                       x_question_7_answer                 => css_profile_data.question_7_answer,
                       x_question_8_number                 => css_profile_data.question_8_number,
                       x_question_8_size                   => css_profile_data.question_8_size,
                       x_question_8_answer                 => css_profile_data.question_8_answer,
                       x_question_9_number                 => css_profile_data.question_9_number,
                       x_question_9_size                   => css_profile_data.question_9_size,
                       x_question_9_answer                 => css_profile_data.question_9_answer,
                       x_question_10_number                => css_profile_data.question_10_number,
                       x_question_10_size                  => css_profile_data.question_10_size,
                       x_question_10_answer                => css_profile_data.question_10_answer,
                       x_question_11_number                => css_profile_data.question_11_number,
                       x_question_11_size                  => css_profile_data.question_11_size,
                       x_question_11_answer                => css_profile_data.question_11_answer,
                       x_question_12_number                => css_profile_data.question_12_number,
                       x_question_12_size                  => css_profile_data.question_12_size,
                       x_question_12_answer                => css_profile_data.question_12_answer,
                       x_question_13_number                => css_profile_data.question_13_number,
                       x_question_13_size                  => css_profile_data.question_13_size,
                       x_question_13_answer                => css_profile_data.question_13_answer,
                       x_question_14_number                => css_profile_data.question_14_number,
                       x_question_14_size                  => css_profile_data.question_14_size,
                       x_question_14_answer                => css_profile_data.question_14_answer,
                       x_question_15_number                => css_profile_data.question_15_number,
                       x_question_15_size                  => css_profile_data.question_15_size,
                       x_question_15_answer                => css_profile_data.question_15_answer,
                       x_question_16_number                => css_profile_data.question_16_number,
                       x_question_16_size                  => css_profile_data.question_16_size,
                       x_question_16_answer                => css_profile_data.question_16_answer,
                       x_question_17_number                => css_profile_data.question_17_number,
                       x_question_17_size                  => css_profile_data.question_17_size,
                       x_question_17_answer                => css_profile_data.question_17_answer,
                       x_question_18_number                => css_profile_data.question_18_number,
                       x_question_18_size                  => css_profile_data.question_18_size,
                       x_question_18_answer                => css_profile_data.question_18_answer,
                       x_question_19_number                => css_profile_data.question_19_number,
                       x_question_19_size                  => css_profile_data.question_19_size,
                       x_question_19_answer                => css_profile_data.question_19_answer,
                       x_question_20_number                => css_profile_data.question_20_number,
                       x_question_20_size                  => css_profile_data.question_20_size,
                       x_question_20_answer                => css_profile_data.question_20_answer,
                       x_question_21_number                => css_profile_data.question_21_number,
                       x_question_21_size                  => css_profile_data.question_21_size,
                       x_question_21_answer                => css_profile_data.question_21_answer,
                       x_question_22_number                => css_profile_data.question_22_number,
                       x_question_22_size                  => css_profile_data.question_22_size,
                       x_question_22_answer                => css_profile_data.question_22_answer,
                       x_question_23_number                => css_profile_data.question_23_number,
                       x_question_23_size                  => css_profile_data.question_23_size,
                       x_question_23_answer                => css_profile_data.question_23_answer,
                       x_question_24_number                => css_profile_data.question_24_number,
                       x_question_24_size                  => css_profile_data.question_24_size,
                       x_question_24_answer                => css_profile_data.question_24_answer,
                       x_question_25_number                => css_profile_data.question_25_number,
                       x_question_25_size                  => css_profile_data.question_25_size,
                       x_question_25_answer                => css_profile_data.question_25_answer,
                       x_question_26_number                => css_profile_data.question_26_number,
                       x_question_26_size                  => css_profile_data.question_26_size,
                       x_question_26_answer                => css_profile_data.question_26_answer,
                       x_question_27_number                => css_profile_data.question_27_number,
                       x_question_27_size                  => css_profile_data.question_27_size,
                       x_question_27_answer                => css_profile_data.question_27_answer,
                       x_question_28_number                => css_profile_data.question_28_number,
                       x_question_28_size                  => css_profile_data.question_28_size,
                       x_question_28_answer                => css_profile_data.question_28_answer,
                       x_question_29_number                => css_profile_data.question_29_number,
                       x_question_29_size                  => css_profile_data.question_29_size,
                       x_question_29_answer                => css_profile_data.question_29_answer,
                       x_question_30_number                => css_profile_data.question_30_number,
                       x_questions_30_size                 => css_profile_data.questions_30_size,
                       x_question_30_answer                => css_profile_data.question_30_answer,
                       x_coa_duration_efc_amt              => css_profile_data.coa_duration_efc_amt,
                       x_coa_duration_num                  => css_profile_data.coa_duration_num,
                       x_p_soc_sec_ben_student_amt         => css_profile_data.p_soc_sec_ben_student_amt,
                       x_p_tuit_fee_deduct_amt             => css_profile_data.p_tuit_fee_deduct_amt,
                       x_stu_lives_with_num                => css_profile_data.stu_lives_with_num,
                       x_stu_most_support_from_num         => css_profile_data.stu_most_support_from_num,
                       x_location_computer_num             => css_profile_data.location_computer_num
                      );


             END LOOP;
EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.make_profile_inactive.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_PROFILE_MATCHING_PKG.calculate_match_score' );
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.calculate_match_score' || SQLERRM);
      app_exception.raise_exception;
END make_profile_inactive;

FUNCTION remove_spl_chr(pv_ssn        igf_ap_isir_ints_all.current_ssn_txt%TYPE)
RETURN VARCHAR2
IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 24-Aug-2004
  ||  Purpose :        Strips the special charactes from SSN and returns just the number
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   ln_ssn VARCHAR2(20);

BEGIN
   ln_ssn := TRANSLATE (pv_ssn,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');
   RETURN ln_ssn;
EXCEPTION
   WHEN others THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.remove_spl_chr.exception','The exception is : ' || SQLERRM );
      END IF;
     RETURN '-1';
END remove_spl_chr;

PROCEDURE calculate_match_score(p_match_setup    igf_ap_record_match%ROWTYPE,
                                p_match_dtls_rec igf_ap_match_details%ROWTYPE,
                                p_apm_id         NUMBER,
                                p_person_id      NUMBER)
IS
 /*
  ||  Created By : rasahoo
  ||  Created On : 24-g-2004
  ||  Purpose :        Matches attributes as per record match setup and inserts a record in match details table
                       after deriving the total score.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR chk_match_dtls_exists_cur(cp_apm_id NUMBER, cp_person_id NUMBER) IS
   SELECT ROWID, ad.*
     FROM igf_ap_match_details ad
    WHERE apm_id = cp_apm_id
      AND person_id = cp_person_id;

   rec_match_dtls  chk_match_dtls_exists_cur%ROWTYPE;

   lv_rowid            VARCHAR2(30);
   lv_amd_id           NUMBER;
   l_ssn_match         igf_ap_match_details.ssn_match%TYPE;
   l_given_name_match  igf_ap_match_details.given_name_match%TYPE;
   l_surname_match     igf_ap_match_details.surname_match%TYPE;
   l_address_match     igf_ap_match_details.address_match%TYPE;
   l_city_match        igf_ap_match_details.city_match%TYPE;
   l_zip_match         igf_ap_match_details.zip_match%TYPE;
   l_email_id_match    igf_ap_match_details.email_id_match%TYPE;
   l_dob_match         igf_ap_match_details.dob_match%TYPE;
   l_gender_match      igf_ap_match_details.gender_match%TYPE;
   l_match_score       igf_ap_match_details.match_score%TYPE;

BEGIN
-- ===============  FIRST MATCH ATTRIBUTES ===============

   -- SSN MATCH

   IF remove_spl_chr(g_cur_data.SOCIAL_SECURITY_NUMBER) =  remove_spl_chr(p_match_dtls_rec.ssn_txt) THEN
         l_ssn_match := p_match_setup.ssn;
   END IF;

   -- FIRST NAME
   IF p_match_setup.given_name_mt_txt = 'EXACT' THEN
      -- First Name setup for exact match
      IF UPPER(g_cur_data.first_name) =  UPPER(p_match_dtls_rec.given_name_txt) THEN
         l_given_name_match := p_match_setup.given_name;
      END IF;

   ELSE
      -- First Name setup for Partial match
      IF UPPER(p_match_dtls_rec.given_name_txt) LIKE '%'|| UPPER(g_cur_data.first_name) || '%' THEN
         l_given_name_match := p_match_setup.given_name;
      END IF;
   END IF;


   -- LAST NAME
   IF p_match_setup.surname_mt_txt = 'EXACT' THEN
      -- Last Name setup for exact match
      IF UPPER(g_cur_data.last_name) =  UPPER(p_match_dtls_rec.sur_name_txt) THEN
         l_surname_match := p_match_setup.surname;
      END IF;

   ELSE -- last name setup for Partial match
      IF UPPER(p_match_dtls_rec.sur_name_txt) LIKE '%' || UPPER(g_cur_data.last_name) || '%' THEN
         l_surname_match := p_match_setup.surname;
      END IF;
   END IF;

   -- ADDRESS
   IF p_match_setup.address_mt_txt = 'EXACT' THEN
      -- Address setup for exact match
      IF UPPER(g_cur_data.address_number_and_street) =  UPPER(p_match_dtls_rec.address_txt) THEN
         l_address_match := p_match_setup.address;
      END IF;

   ELSIF p_match_setup.address_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match
        IF  UPPER(p_match_dtls_rec.address_txt) LIKE '%' || UPPER(g_cur_data.address_number_and_street) || '%' THEN
            l_address_match := p_match_setup.address;
        END IF;
   END IF;

     -- CITY
   IF p_match_setup.city_mt_txt = 'EXACT' THEN
      -- City setup for exact match
      IF UPPER(g_cur_data.CITY) =  UPPER(p_match_dtls_rec.city_txt) THEN
         l_city_match := p_match_setup.city;
      END IF;

   ELSIF p_match_setup.city_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match
      IF UPPER(p_match_dtls_rec.city_txt)  LIKE '%' || UPPER(g_cur_data.city) || '%' THEN
         l_city_match := p_match_setup.city;
      END IF;
   END IF;

      -- POSTAL CODE
   IF p_match_setup.zip_mt_txt = 'EXACT' THEN
      -- Zip Code setup for exact match
      IF UPPER(g_cur_data.zip_code) =  UPPER(p_match_dtls_rec.zip_txt) THEN
         l_zip_match := p_match_setup.zip;
      END IF;

   ELSIF p_match_setup.zip_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match
         IF UPPER(p_match_dtls_rec.zip_txt) LIKE '%' || UPPER(g_cur_data.zip_code) || '%' THEN
            l_zip_match := p_match_setup.zip;
         END IF;
   END IF;

   -- EMAIL ADDRESS
   IF p_match_setup.email_mt_txt = 'EXACT' THEN
      -- Email setup for exact match
      IF UPPER(g_cur_data.r_s_email_address) =  UPPER(p_match_dtls_rec.email_id_txt) THEN
         l_email_id_match := p_match_setup.email_num;
      END IF;

   ELSIF p_match_setup.email_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match
         IF UPPER(p_match_dtls_rec.email_id_txt) LIKE '%' || UPPER(g_cur_data.r_s_email_address) || '%' THEN
            l_email_id_match := p_match_setup.email_num;
         END IF;
   END IF;

      -- BIRTH DATE
   -- can only be setup for Exact or exclude
   IF p_match_setup.birth_dt_mt_txt = 'EXACT' THEN
      -- Birth date setup for exact match


     IF g_cur_data.date_of_birth IS NOT NULL THEN
      IF g_cur_data.date_of_birth =  TO_CHAR(p_match_dtls_rec.birth_date,'MMDDYYYY') THEN

         l_dob_match := p_match_setup.birth_dt;
      END IF;
     END IF;
   END IF;

 -- ===============  COMPUTE TOTAL SCORE  ===============

   l_match_score:=
         NVL(l_ssn_match,0)         +
         NVL(l_given_name_match,0)  +
         NVL(l_surname_match,0)     +
         NVL(l_address_match,0)     +
         NVL(l_city_match,0)        +
         NVL(l_zip_match ,0)        +
         NVL(l_email_id_match,0)    +
         NVL(l_dob_match,0)   ;

   -- check whether a match details rec already exists for this person and isir rec.
   OPEN chk_match_dtls_exists_cur(p_apm_id, p_person_id);
   FETCH chk_match_dtls_exists_cur INTO rec_match_dtls;
   CLOSE chk_match_dtls_exists_cur;

      IF rec_match_dtls.rowid IS NULL THEN

      lv_amd_id := NULL;
      lv_rowid  := NULL;

      -- insert a new match details rec

      igf_ap_match_details_pkg.insert_row(
              x_mode                => 'R',
              x_rowid               => lv_rowid,
              x_amd_id              => lv_amd_id,
              x_apm_id              => p_apm_id,
              x_person_id           => p_person_id ,
              x_ssn_match           => l_ssn_match ,
              x_given_name_match    => l_given_name_match,
              x_surname_match       => l_surname_match   ,
              x_dob_match           => l_dob_match       ,
              x_address_match       => l_address_match   ,
              x_city_match          => l_city_match      ,
              x_zip_match           => l_zip_match       ,
              x_match_score         => l_match_score     ,
              x_record_status       => g_cur_data.record_status,
              x_ssn_txt             => p_match_dtls_rec.ssn_txt         ,
              x_given_name_txt      => p_match_dtls_rec.given_name_txt  ,
              x_sur_name_txt        => p_match_dtls_rec.sur_name_txt    ,
              x_birth_date          => p_match_dtls_rec.birth_date      ,
              x_address_txt         => p_match_dtls_rec.address_txt     ,
              x_city_txt            => p_match_dtls_rec.city_txt        ,
              x_zip_txt             => p_match_dtls_rec.zip_txt         ,
              x_gender_txt          => NULL                             ,
              x_email_id_txt        => p_match_dtls_rec.email_id_txt    ,
              x_gender_match        => NULL                             ,
              x_email_id_match      => l_email_id_match
              );

   ELSE
      -- update existing rec

      igf_ap_match_details_pkg.update_row(
              x_mode                => 'R',
              x_rowid               => rec_match_dtls.rowid,
              x_amd_id              => rec_match_dtls.amd_id,
              x_apm_id              => rec_match_dtls.apm_id,
              x_person_id           => rec_match_dtls.person_id ,
              x_ssn_match           => l_ssn_match ,
              x_given_name_match    => rec_match_dtls.given_name_match,
              x_surname_match       => rec_match_dtls.surname_match   ,
              x_dob_match           => rec_match_dtls.dob_match       ,
              x_address_match       => rec_match_dtls.address_match   ,
              x_city_match          => rec_match_dtls.city_match      ,
              x_zip_match           => rec_match_dtls.zip_match       ,
              x_match_score         => rec_match_dtls.match_score     ,
              x_record_status       => rec_match_dtls.record_status,
              x_ssn_txt             => p_match_dtls_rec.ssn_txt     ,
              x_given_name_txt      => rec_match_dtls.given_name_txt  ,
              x_sur_name_txt        => rec_match_dtls.sur_name_txt    ,
              x_birth_date          => rec_match_dtls.birth_date      ,
              x_address_txt         => rec_match_dtls.address_txt     ,
              x_city_txt            => rec_match_dtls.city_txt        ,
              x_zip_txt             => rec_match_dtls.zip_txt         ,
              x_gender_txt          => rec_match_dtls.gender_txt      ,
              x_email_id_txt        => rec_match_dtls.email_id_txt    ,
              x_gender_match        => rec_match_dtls.gender_match     ,
              x_email_id_match      => rec_match_dtls.email_id_match
            );

   END IF;

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.calculate_match_score.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_PROFILE_MATCHING_PKG.calculate_match_score' );
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.calculate_match_score 1' || SQLERRM);
      app_exception.raise_exception;
END calculate_match_score;

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

  PROCEDURE create_fa_base_record(
                 pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                 pn_person_id       igf_ap_fa_base_rec_all.person_id%TYPE,
                 pn_base_id    OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE
                 ) IS

  /*
  ||  Created By : Meghana
  ||  Created On : 11-JUN-2001
  ||  Purpose : Create the base record for those who satisfies the matching process.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When          What
  ||  ridas     14-Feb-2006   Bug #5021084. Removed trunc function from
  ||                          cursor SSN_CUR.
  ||  rajagupt  6-Oct-2005    Bug#4068548 - added a new cursor ssn_cur
  ||  rasahoo   17-NOV-2003   FA 128 - ISIR update 2004-05
  ||                          added new parameter award_fmly_contribution_type to
  ||                          TBH call igf_ap_fa_base_rec_pkg
  ||  masehgal  11-Nov-2002   FA 101 - SAP Obsoletion
  ||                          removed packaging hold
  ||  masehgal  25-Sep-2002   FA 104 - To Do Enhancements
  ||                          Added manual_disb_hold in Fa Base insert
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
       SELECT iii.*, ibm.ci_sequence_number, ibm.ci_cal_type
       FROM   igf_ap_css_interface iii, igf_ap_batch_aw_map ibm
       WHERE  iii.css_id = pn_css_id
       AND    TO_NUMBER(iii.academic_year) = ibm.css_academic_year ;


  -- cursor to get the ssn no of a person
    CURSOR ssn_cur(cp_person_id number) IS
       SELECT api_person_id,api_person_id_uf, end_dt
       FROM   igs_pe_alt_pers_id
       WHERE  pe_person_id=cp_person_id
       AND    person_id_type like 'SSN'
       AND    SYSDATE < = NVL(end_dt,SYSDATE);



    rec_ssn_cur ssn_cur%ROWTYPE;
    lv_profile_value VARCHAR2(20);
    lv_rowid    VARCHAR2(30);
    lv_ci_cal_type    igf_ap_fa_base_rec.ci_cal_type%TYPE;
    ln_ci_sequence_number igf_ap_fa_base_rec.ci_cal_type%TYPE;
    retcode     NUMBER;
    errbuf      VARCHAR2(300);


  BEGIN

    FOR cur_css_interface_rec IN cur_css_interface( pn_css_id)
    LOOP

   -- check if the ssn no is available or not
    fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);

    IF(lv_profile_value = 'Y') THEN
    OPEN ssn_cur(pn_person_id) ;
    FETCH ssn_cur INTO rec_ssn_cur;
    IF ssn_cur%NOTFOUND THEN
       CLOSE ssn_cur;
       create_ssn(pn_person_id, cur_css_interface_rec.social_security_number );
     ELSE
     CLOSE ssn_cur;
     END IF;
     END IF;

    igf_ap_fa_base_rec_pkg.insert_row(
            x_mode                              => 'R',
            x_rowid                             => lv_rowid,
            x_base_id                           => pn_base_id,
            x_ci_cal_type                       => cur_css_interface_rec.ci_cal_type,
            x_person_id                         => pn_person_id,
            x_ci_sequence_number                => cur_css_interface_rec.ci_sequence_number,
            x_org_id                            => NULL,
            x_coa_pending                       => NULL,
            x_verification_process_run          => NULL,
            x_inst_verif_status_date            => NULL,
            x_manual_verif_flag                 => NULL,
            x_fed_verif_status                  => NULL,
            x_fed_verif_status_date             => NULL,
            x_inst_verif_status                 => NULL,
            x_nslds_eligible                    => NULL,
            x_ede_correction_batch_id           => NULL,
            x_fa_process_status_date            => NULL,
            x_isir_corr_status                  => NULL,
            x_isir_corr_status_date             => NULL,
            x_isir_status                       => NULL,
            x_isir_status_date                  => NULL,
            x_coa_code_f                        => NULL,
            x_coa_code_i                        => NULL,
            x_coa_f                             => NULL,
            x_coa_i                             => NULL,
            x_disbursement_hold                 => NULL,
            x_fa_process_status                 => NULL,
            x_notification_status               => NULL,
            x_notification_status_date          => NULL,
            x_packaging_status                  => NULL,
            x_packaging_status_date             => NULL,
            x_total_package_accepted            => NULL,
            x_total_package_offered             => NULL,
            x_admstruct_id                      => NULL,
            x_admsegment_1                      => NULL,
            x_admsegment_2                      => NULL,
            x_admsegment_3                      => NULL,
            x_admsegment_4                      => NULL,
            x_admsegment_5                      => NULL,
            x_admsegment_6                      => NULL,
            x_admsegment_7                      => NULL,
            x_admsegment_8                      => NULL,
            x_admsegment_9                      => NULL,
            x_admsegment_10                     => NULL,
            x_admsegment_11                     => NULL,
            x_admsegment_12                     => NULL,
            x_admsegment_13                     => NULL,
            x_admsegment_14                     => NULL,
            x_admsegment_15                     => NULL,
            x_admsegment_16                     => NULL,
            x_admsegment_17                     => NULL,
            x_admsegment_18                     => NULL,
            x_admsegment_19                     => NULL,
            x_admsegment_20                     => NULL,
            x_packstruct_id                     => NULL,
            x_packsegment_1                     => NULL,
            x_packsegment_2                     => NULL,
            x_packsegment_3                     => NULL,
            x_packsegment_4                     => NULL,
            x_packsegment_5                     => NULL,
            x_packsegment_6                     => NULL,
            x_packsegment_7                     => NULL,
            x_packsegment_8                     => NULL,
            x_packsegment_9                     => NULL,
            x_packsegment_10                    => NULL,
            x_packsegment_11                    => NULL,
            x_packsegment_12                    => NULL,
            x_packsegment_13                    => NULL,
            x_packsegment_14                    => NULL,
            x_packsegment_15                    => NULL,
            x_packsegment_16                    => NULL,
            x_packsegment_17                    => NULL,
            x_packsegment_18                    => NULL,
            x_packsegment_19                    => NULL,
            x_packsegment_20                    => NULL,
            x_miscstruct_id                     => NULL,
            x_miscsegment_1                     => NULL,
            x_miscsegment_2                     => NULL,
            x_miscsegment_3                     => NULL,
            x_miscsegment_4                     => NULL,
            x_miscsegment_5                     => NULL,
            x_miscsegment_6                     => NULL,
            x_miscsegment_7                     => NULL,
            x_miscsegment_8                     => NULL,
            x_miscsegment_9                     => NULL,
            x_miscsegment_10                    => NULL,
            x_miscsegment_11                    => NULL,
            x_miscsegment_12                    => NULL,
            x_miscsegment_13                    => NULL,
            x_miscsegment_14                    => NULL,
            x_miscsegment_15                    => NULL,
            x_miscsegment_16                    => NULL,
            x_miscsegment_17                    => NULL,
            x_miscsegment_18                    => NULL,
            x_miscsegment_19                    => NULL,
            x_miscsegment_20                    => NULL,
            x_prof_judgement_flg                => NULL,
            x_nslds_data_override_flg           => NULL,
            x_target_group                      => NULL,
            x_coa_fixed                         => NULL,
            x_coa_pell                          => NULL,
            x_profile_status                    => cur_css_interface_rec.institutional_reporting_type,
            x_profile_status_date               => TRUNC(SYSDATE),
            x_profile_fc                        => cur_css_interface_rec.im_inst_2_tot_family_cont,
            x_tolerance_amount                  => NULL,
            x_manual_disb_hold                  => NULL,
            x_pell_alt_expense                  => NULL,
            x_assoc_org_num                     => NULL,
            x_award_fmly_contribution_type      => '1',
            x_isir_locked_by                    => NULL,
            x_adnl_unsub_loan_elig_flag         => 'N',
            x_lock_awd_flag                     => 'N',
            x_lock_coa_flag                     => 'N'


        );



        IF pn_base_id IS NULL THEN
      FND_MESSAGE.SET_NAME ('IGF', 'IGF_AP_ERR_FA_REC');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      FND_FILE.PUT_LINE(fnd_file.log,sqlerrm);
    END IF;
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_fa_base_record.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_MATCHING_PROCESS_PKG.CREATE_FA_BASE_REC:');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.CREATE_FA_BASE_REC' || SQLERRM);
      app_exception.raise_exception;
  END create_fa_base_record;


  PROCEDURE create_fnar_data(pn_css_id           igf_ap_css_interface_all.css_id%TYPE,
                             pn_cssp_id          igf_ap_css_profile.cssp_id%TYPE
                                   ) IS

  /*
  ||  Created By : Meghana
  ||  Created On : 11-JUN-2001
  ||  Purpose : To create the FNAR matched record for all the matched records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    -- Get all the FNAR data for the matched PROFILE record.
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
      SELECT iii.*
      FROM   igf_ap_css_interface_all iii
      WHERE  css_id = pn_css_id;


    lv_rowid  VARCHAR2(30);
    ln_fnar_id  igf_ap_css_fnar.fnar_id%TYPE;
    retcode   NUMBER;
    errbuf    VARCHAR2(300);

        BEGIN

     -- Update FNAR data for the given student
           FOR cur_css_interface_rec IN cur_css_interface ( pn_css_id)
     LOOP

           igf_ap_css_fnar_pkg.insert_row (
                                           x_mode                              => 'R',
                                           x_rowid                             => lv_rowid,
                                           x_fnar_id                           => ln_fnar_id,
                                           x_cssp_id                           => pn_cssp_id,
                                           x_r_s_email_address                 => cur_css_interface_rec.r_s_email_address,
                                           x_eps_code                          => cur_css_interface_rec.eps_code,
                                           x_comp_css_dependency_status        => convert_int(cur_css_interface_rec.comp_css_dependency_status),
                                           x_stu_age                           => convert_int(cur_css_interface_rec.stu_age),
                                           x_assumed_stu_yr_in_coll            => convert_int(cur_css_interface_rec.assumed_stu_yr_in_coll),
                                           x_comp_stu_marital_status           => convert_int(cur_css_interface_rec.comp_stu_marital_status),
                                           x_stu_family_members                => convert_int(cur_css_interface_rec.stu_family_members),
                                           x_stu_fam_members_in_college        => convert_int(cur_css_interface_rec.stu_fam_members_in_college),
                                           x_par_marital_status                => convert_int(cur_css_interface_rec.par_marital_status),
                                           x_par_family_members                => convert_int(cur_css_interface_rec.par_family_members),
                                           x_par_total_in_college              => convert_int(cur_css_interface_rec.par_total_in_college),
                                           x_par_par_in_college                => convert_int(cur_css_interface_rec.par_par_in_college),
                                           x_par_others_in_college             => convert_int(cur_css_interface_rec.par_others_in_college),
                                           x_par_aesa                          => convert_int(cur_css_interface_rec.par_aesa),
                                           x_par_cesa                          => convert_int(cur_css_interface_rec.par_cesa),
                                           x_stu_aesa                          => convert_int(cur_css_interface_rec.stu_aesa),
                                           x_stu_cesa                          => convert_int(cur_css_interface_rec.stu_cesa),
                                           x_im_p_bas_agi_taxable_income       => convert_int(cur_css_interface_rec.im_p_bas_agi_taxable_income),
                                           x_im_p_bas_untx_inc_and_ben         => convert_int(cur_css_interface_rec.im_p_bas_untx_inc_and_ben),
                                           x_im_p_bas_inc_adj                  => convert_int(cur_css_interface_rec.im_p_bas_inc_adj),
                                           x_im_p_bas_total_income             => convert_int(cur_css_interface_rec.im_p_bas_total_income),
                                           x_im_p_bas_us_income_tax            => convert_int(cur_css_interface_rec.im_p_bas_us_income_tax),
                                           x_im_p_bas_st_and_other_tax         => convert_int(cur_css_interface_rec.im_p_bas_st_and_other_tax),
                                           x_im_p_bas_fica_tax                 => convert_int(cur_css_interface_rec.im_p_bas_fica_tax),
                                           x_im_p_bas_med_dental               => convert_int(cur_css_interface_rec.im_p_bas_med_dental),
                                           x_im_p_bas_employment_allow         => convert_int(cur_css_interface_rec.im_p_bas_employment_allow),
                                           x_im_p_bas_annual_ed_savings        => convert_int(cur_css_interface_rec.im_p_bas_annual_ed_savings),
                                           x_im_p_bas_inc_prot_allow_m         => convert_int(cur_css_interface_rec.im_p_bas_inc_prot_allow_m),
                                           x_im_p_bas_total_inc_allow          => convert_int(cur_css_interface_rec.im_p_bas_total_inc_allow),
                                           x_im_p_bas_cal_avail_inc            => convert_int(cur_css_interface_rec.im_p_bas_cal_avail_inc),
                                           x_im_p_bas_avail_income             => convert_int(cur_css_interface_rec.im_p_bas_avail_income),
                                           x_im_p_bas_total_cont_inc           => convert_int(cur_css_interface_rec.im_p_bas_total_cont_inc),
                                           x_im_p_bas_cash_bank_accounts       => convert_int(cur_css_interface_rec.im_p_bas_cash_bank_accounts),
                                           x_im_p_bas_home_equity              => convert_int(cur_css_interface_rec.im_p_bas_home_equity),
                                           x_im_p_bas_ot_rl_est_inv_eq         => convert_int(cur_css_interface_rec.im_p_bas_ot_rl_est_inv_eq),
                                           x_im_p_bas_adj_bus_farm_worth       => convert_int(cur_css_interface_rec.im_p_bas_adj_bus_farm_worth),
                                           x_im_p_bas_ass_sibs_pre_tui         => convert_int(cur_css_interface_rec.im_p_bas_ass_sibs_pre_tui),
                                           x_im_p_bas_net_worth                => convert_int(cur_css_interface_rec.im_p_bas_net_worth),
                                           x_im_p_bas_emerg_res_allow          => convert_int(cur_css_interface_rec.im_p_bas_emerg_res_allow),
                                           x_im_p_bas_cum_ed_savings           => convert_int(cur_css_interface_rec.im_p_bas_cum_ed_savings),
                                           x_im_p_bas_low_inc_allow            => convert_int(cur_css_interface_rec.im_p_bas_low_inc_allow),
                                           x_im_p_bas_total_asset_allow        => convert_int(cur_css_interface_rec.im_p_bas_total_asset_allow),
                                           x_im_p_bas_disc_net_worth           => convert_int(cur_css_interface_rec.im_p_bas_disc_net_worth),
                                           x_im_p_bas_total_cont_asset         => convert_int(cur_css_interface_rec.im_p_bas_total_cont_asset),
                                           x_im_p_bas_total_cont               => convert_int(cur_css_interface_rec.im_p_bas_total_cont),
                                           x_im_p_bas_num_in_coll_adj          => convert_int(cur_css_interface_rec.im_p_bas_num_in_coll_adj),
                                           x_im_p_bas_cont_for_stu             => convert_int(cur_css_interface_rec.im_p_bas_cont_for_stu),
                                           x_im_p_bas_cont_from_income         => convert_int(cur_css_interface_rec.im_p_bas_cont_from_income),
                                           x_im_p_bas_cont_from_assets         => convert_int(cur_css_interface_rec.im_p_bas_cont_from_assets),
                                           x_im_p_opt_agi_taxable_income       => convert_int(cur_css_interface_rec.im_p_opt_agi_taxable_income),
                                           x_im_p_opt_untx_inc_and_ben         => convert_int(cur_css_interface_rec.im_p_opt_untx_inc_and_ben),
                                           x_im_p_opt_inc_adj                  => convert_int(cur_css_interface_rec.im_p_opt_inc_adj),
                                           x_im_p_opt_total_income             => convert_int(cur_css_interface_rec.im_p_opt_total_income),
                                           x_im_p_opt_us_income_tax            => convert_int(cur_css_interface_rec.im_p_opt_us_income_tax),
                                           x_im_p_opt_st_and_other_tax         => convert_int(cur_css_interface_rec.im_p_opt_st_and_other_tax),
                                           x_im_p_opt_fica_tax                 => convert_int(cur_css_interface_rec.im_p_opt_fica_tax),
                                           x_im_p_opt_med_dental               => convert_int(cur_css_interface_rec.im_p_opt_med_dental),
                                           x_im_p_opt_elem_sec_tuit            => convert_int(cur_css_interface_rec.im_p_opt_elem_sec_tuit),
                                           x_im_p_opt_employment_allow         => convert_int(cur_css_interface_rec.im_p_opt_employment_allow),
                                           x_im_p_opt_annual_ed_savings        => convert_int(cur_css_interface_rec.im_p_opt_annual_ed_savings),
                                           x_im_p_opt_inc_prot_allow_m         => convert_int(cur_css_interface_rec.im_p_opt_inc_prot_allow_m),
                                           x_im_p_opt_total_inc_allow          => convert_int(cur_css_interface_rec.im_p_opt_total_inc_allow),
                                           x_im_p_opt_cal_avail_inc            => convert_int(cur_css_interface_rec.im_p_opt_cal_avail_inc),
                                           x_im_p_opt_avail_income             => convert_int(cur_css_interface_rec.im_p_opt_avail_income),
                                           x_im_p_opt_total_cont_inc           => convert_int(cur_css_interface_rec.im_p_opt_total_cont_inc),
                                           x_im_p_opt_cash_bank_accounts       => convert_int(cur_css_interface_rec.im_p_opt_cash_bank_accounts),
                                           x_im_p_opt_home_equity              => convert_int(cur_css_interface_rec.im_p_opt_home_equity),
                                           x_im_p_opt_ot_rl_est_inv_eq         => convert_int(cur_css_interface_rec.im_p_opt_ot_rl_est_inv_eq),
                                           x_im_p_opt_adj_bus_farm_worth       => convert_int(cur_css_interface_rec.im_p_opt_adj_bus_farm_worth),
                                           x_im_p_opt_ass_sibs_pre_tui         => convert_int(cur_css_interface_rec.im_p_opt_ass_sibs_pre_t),
                                           x_im_p_opt_net_worth                => convert_int(cur_css_interface_rec.im_p_opt_net_worth),
                                           x_im_p_opt_emerg_res_allow          => convert_int(cur_css_interface_rec.im_p_opt_emerg_res_allow),
                                           x_im_p_opt_cum_ed_savings           => convert_int(cur_css_interface_rec.im_p_opt_cum_ed_savings),
                                           x_im_p_opt_low_inc_allow            => convert_int(cur_css_interface_rec.im_p_opt_low_inc_allow),
                                           x_im_p_opt_total_asset_allow        => convert_int(cur_css_interface_rec.im_p_opt_total_asset_allow),
                                           x_im_p_opt_disc_net_worth           => convert_int(cur_css_interface_rec.im_p_opt_disc_net_worth),
                                           x_im_p_opt_total_cont_asset         => convert_int(cur_css_interface_rec.im_p_opt_total_cont_asset),
                                           x_im_p_opt_total_cont               => convert_int(cur_css_interface_rec.im_p_opt_total_cont),
                                           x_im_p_opt_num_in_coll_adj          => convert_int(cur_css_interface_rec.im_p_opt_num_in_coll_adj),
                                           x_im_p_opt_cont_for_stu             => convert_int(cur_css_interface_rec.im_p_opt_cont_for_stu),
                                           x_im_p_opt_cont_from_income         => convert_int(cur_css_interface_rec.im_p_opt_cont_from_income),
                                           x_im_p_opt_cont_from_assets         => convert_int(cur_css_interface_rec.im_p_opt_cont_from_assets),
                                           x_fm_p_analysis_type                => convert_int(cur_css_interface_rec.fm_p_analysis_type),
                                           x_fm_p_agi_taxable_income           => convert_int(cur_css_interface_rec.fm_p_agi_taxable_income),
                                           x_fm_p_untx_inc_and_ben             => convert_int(cur_css_interface_rec.fm_p_untx_inc_and_ben),
                                           x_fm_p_inc_adj                      => convert_int(cur_css_interface_rec.fm_p_inc_adj),
                                           x_fm_p_total_income                 => convert_int(cur_css_interface_rec.fm_p_total_income),
                                           x_fm_p_us_income_tax                => convert_int(cur_css_interface_rec.fm_p_us_income_tax),
                                           x_fm_p_state_and_other_taxes        => convert_int(cur_css_interface_rec.fm_p_state_and_other_taxes),
                                           x_fm_p_fica_tax                     => convert_int(cur_css_interface_rec.fm_p_fica_tax),
                                           x_fm_p_employment_allow             => convert_int(cur_css_interface_rec.fm_p_employment_allow),
                                           x_fm_p_income_prot_allow            => convert_int(cur_css_interface_rec.fm_p_income_prot_allow),
                                           x_fm_p_total_allow                  => convert_int(cur_css_interface_rec.fm_p_total_allow),
                                           x_fm_p_avail_income                 => convert_int(cur_css_interface_rec.fm_p_avail_income),
                                           x_fm_p_cash_bank_accounts           => convert_int(cur_css_interface_rec.fm_p_cash_bank_accounts),
                                           x_fm_p_ot_rl_est_inv_equity         => convert_int(cur_css_interface_rec.fm_p_ot_rl_est_inv_eq),
                                           x_fm_p_adj_bus_farm_net_worth       => convert_int(cur_css_interface_rec.fm_p_adj_bus_farm_net_worth),
                                           x_fm_p_net_worth                    => convert_int(cur_css_interface_rec.fm_p_net_worth),
                                           x_fm_p_asset_prot_allow             => convert_int(cur_css_interface_rec.fm_p_asset_prot_allow),
                                           x_fm_p_disc_net_worth               => convert_int(cur_css_interface_rec.fm_p_disc_net_worth),
                                           x_fm_p_total_contribution           => convert_int(cur_css_interface_rec.fm_p_total_contribution),
                                           x_fm_p_num_in_coll                  => convert_int(cur_css_interface_rec.fm_p_num_in_coll),
                                           x_fm_p_cont_for_stu                 => convert_int(cur_css_interface_rec.fm_p_cont_for_stu),
                                           x_fm_p_cont_from_income             => convert_int(cur_css_interface_rec.fm_p_cont_from_income),
                                           x_fm_p_cont_from_assets             => convert_int(cur_css_interface_rec.fm_p_cont_from_assets),
                                           x_im_s_bas_agi_taxable_income       => convert_int(cur_css_interface_rec.im_s_bas_agi_taxable_income),
                                           x_im_s_bas_untx_inc_and_ben         => convert_int(cur_css_interface_rec.im_s_bas_untx_inc_and_ben),
                                           x_im_s_bas_inc_adj                  => convert_int(cur_css_interface_rec.im_s_bas_inc_adj),
                                           x_im_s_bas_total_income             => convert_int(cur_css_interface_rec.im_s_bas_total_income),
                                           x_im_s_bas_us_income_tax            => convert_int(cur_css_interface_rec.im_s_bas_us_income_tax),
                                           x_im_s_bas_state_and_oth_taxes      => convert_int(cur_css_interface_rec.im_s_bas_st_and_oth_tax),
                                           x_im_s_bas_fica_tax                 => convert_int(cur_css_interface_rec.im_s_bas_fica_tax),
                                           x_im_s_bas_med_dental               => convert_int(cur_css_interface_rec.im_s_bas_med_dental),
                                           x_im_s_bas_employment_allow         => convert_int(cur_css_interface_rec.im_s_bas_employment_allow),
                                           x_im_s_bas_annual_ed_savings        => convert_int(cur_css_interface_rec.im_s_bas_annual_ed_savings),
                                           x_im_s_bas_inc_prot_allow_m         => convert_int(cur_css_interface_rec.im_s_bas_inc_prot_allow_m),
                                           x_im_s_bas_total_inc_allow          => convert_int(cur_css_interface_rec.im_s_bas_total_inc_allow),
                                           x_im_s_bas_cal_avail_income         => convert_int(cur_css_interface_rec.im_s_bas_cal_avail_income),
                                           x_im_s_bas_avail_income             => convert_int(cur_css_interface_rec.im_s_bas_avail_income),
                                           x_im_s_bas_total_cont_inc           => convert_int(cur_css_interface_rec.im_s_bas_total_cont_inc),
                                           x_im_s_bas_cash_bank_accounts       => convert_int(cur_css_interface_rec.im_s_bas_cash_bank_accounts),
                                           x_im_s_bas_home_equity              => convert_int(cur_css_interface_rec.im_s_bas_home_equity),
                                           x_im_s_bas_ot_rl_est_inv_eq         => convert_int(cur_css_interface_rec.im_s_bas_ot_rl_est_inv_eq),
                                           x_im_s_bas_adj_busfarm_worth        => convert_int(cur_css_interface_rec.im_s_bas_adj_bus_farm_worth),
                                           x_im_s_bas_trusts                   => convert_int(cur_css_interface_rec.im_s_bas_trusts),
                                           x_im_s_bas_net_worth                => convert_int(cur_css_interface_rec.im_s_bas_net_worth),
                                           x_im_s_bas_emerg_res_allow          => convert_int(cur_css_interface_rec.im_s_bas_emerg_res_allow),
                                           x_im_s_bas_cum_ed_savings           => convert_int(cur_css_interface_rec.im_s_bas_cum_ed_savings),
                                           x_im_s_bas_total_asset_allow        => convert_int(cur_css_interface_rec.im_s_bas_total_asset_allow),
                                           x_im_s_bas_disc_net_worth           => convert_int(cur_css_interface_rec.im_s_bas_disc_net_worth),
                                           x_im_s_bas_total_cont_asset         => convert_int(cur_css_interface_rec.im_s_bas_total_cont_asset),
                                           x_im_s_bas_total_cont               => convert_int(cur_css_interface_rec.im_s_bas_total_cont),
                                           x_im_s_bas_num_in_coll_adj          => convert_int(cur_css_interface_rec.im_s_bas_num_in_coll_adj),
                                           x_im_s_bas_cont_for_stu             => convert_int(cur_css_interface_rec.im_s_bas_cont_for_stu),
                                           x_im_s_bas_cont_from_income         => convert_int(cur_css_interface_rec.im_s_bas_cont_from_income),
                                           x_im_s_bas_cont_from_assets         => convert_int(cur_css_interface_rec.im_s_bas_cont_from_assets),
                                           x_im_s_est_agitaxable_income        => convert_int(cur_css_interface_rec.im_s_est_agi_taxable_income),
                                           x_im_s_est_untx_inc_and_ben         => convert_int(cur_css_interface_rec.im_s_est_untx_inc_and_ben),
                                           x_im_s_est_inc_adj                  => convert_int(cur_css_interface_rec.im_s_est_inc_adj),
                                           x_im_s_est_total_income             => convert_int(cur_css_interface_rec.im_s_est_total_income),
                                           x_im_s_est_us_income_tax            => convert_int(cur_css_interface_rec.im_s_est_us_income_tax),
                                           x_im_s_est_state_and_oth_taxes      => convert_int(cur_css_interface_rec.im_s_est_st_and_oth_tax),
                                           x_im_s_est_fica_tax                 => convert_int(cur_css_interface_rec.im_s_est_fica_tax),
                                           x_im_s_est_med_dental               => convert_int(cur_css_interface_rec.im_s_est_med_dental),
                                           x_im_s_est_employment_allow         => convert_int(cur_css_interface_rec.im_s_est_employment_allow),
                                           x_im_s_est_annual_ed_savings        => convert_int(cur_css_interface_rec.im_s_est_annual_ed_savings),
                                           x_im_s_est_inc_prot_allow_m         => convert_int(cur_css_interface_rec.im_s_est_inc_prot_allow_m),
                                           x_im_s_est_total_inc_allow          => convert_int(cur_css_interface_rec.im_s_est_total_inc_allow),
                                           x_im_s_est_cal_avail_income         => convert_int(cur_css_interface_rec.im_s_est_cal_avail_income),
                                           x_im_s_est_avail_income             => convert_int(cur_css_interface_rec.im_s_est_avail_income),
                                           x_im_s_est_total_cont_inc           => convert_int(cur_css_interface_rec.im_s_est_total_cont_inc),
                                           x_im_s_est_cash_bank_accounts       => convert_int(cur_css_interface_rec.im_s_est_cash_bank_accounts),
                                           x_im_s_est_home_equity              => convert_int(cur_css_interface_rec.im_s_est_home_equity),
                                           x_im_s_est_ot_rl_est_inv_eq         => convert_int(cur_css_interface_rec.im_s_est_ot_rl_est_inv_equ),
                                           x_im_s_est_adj_bus_farm_worth       => convert_int(cur_css_interface_rec.im_s_est_adj_bus_farm_worth),
                                           x_im_s_est_est_trusts               => convert_int(cur_css_interface_rec.im_s_est_est_trusts),
                                           x_im_s_est_net_worth                => convert_int(cur_css_interface_rec.im_s_est_net_worth),
                                           x_im_s_est_emerg_res_allow          => convert_int(cur_css_interface_rec.im_s_est_emerg_res_allow),
                                           x_im_s_est_cum_ed_savings           => convert_int(cur_css_interface_rec.im_s_est_cum_ed_savings),
                                           x_im_s_est_total_asset_allow        => convert_int(cur_css_interface_rec.im_s_est_total_asset_allow),
                                           x_im_s_est_disc_net_worth           => convert_int(cur_css_interface_rec.im_s_est_disc_net_worth),
                                           x_im_s_est_total_cont_asset         => convert_int(cur_css_interface_rec.im_s_est_total_cont_asset),
                                           x_im_s_est_total_cont               => convert_int(cur_css_interface_rec.im_s_est_total_cont),
                                           x_im_s_est_num_in_coll_adj          => convert_int(cur_css_interface_rec.im_s_est_num_in_coll_adj),
                                           x_im_s_est_cont_for_stu             => convert_int(cur_css_interface_rec.im_s_est_cont_for_stu),
                                           x_im_s_est_cont_from_income         => convert_int(cur_css_interface_rec.im_s_est_cont_from_income),
                                           x_im_s_est_cont_from_assets         => convert_int(cur_css_interface_rec.im_s_est_cont_from_assets),
                                           x_im_s_opt_agi_taxable_income       => convert_int(cur_css_interface_rec.im_s_opt_agi_taxable_income),
                                           x_im_s_opt_untx_inc_and_ben         => convert_int(cur_css_interface_rec.im_s_opt_untx_inc_and_ben),
                                           x_im_s_opt_inc_adj                  => convert_int(cur_css_interface_rec.im_s_opt_inc_adj),
                                           x_im_s_opt_total_income             => convert_int(cur_css_interface_rec.im_s_opt_total_income),
                                           x_im_s_opt_us_income_tax            => convert_int(cur_css_interface_rec.im_s_opt_us_income_tax),
                                           x_im_s_opt_state_and_oth_taxes      => convert_int(cur_css_interface_rec.im_s_opt_state_and_oth_taxes),
                                           x_im_s_opt_fica_tax                 => convert_int(cur_css_interface_rec.im_s_opt_fica_tax),
                                           x_im_s_opt_med_dental               => convert_int(cur_css_interface_rec.im_s_opt_med_dental),
                                           x_im_s_opt_employment_allow         => convert_int(cur_css_interface_rec.im_s_opt_employment_allow),
                                           x_im_s_opt_annual_ed_savings        => convert_int(cur_css_interface_rec.im_s_opt_annual_ed_savings),
                                           x_im_s_opt_inc_prot_allow_m         => convert_int(cur_css_interface_rec.im_s_opt_inc_prot_allow_m),
                                           x_im_s_opt_total_inc_allow          => convert_int(cur_css_interface_rec.im_s_opt_total_inc_allow),
                                           x_im_s_opt_cal_avail_income         => convert_int(cur_css_interface_rec.im_s_opt_cal_avail_income),
                                           x_im_s_opt_avail_income             => convert_int(cur_css_interface_rec.im_s_opt_avail_income),
                                           x_im_s_opt_total_cont_inc           => convert_int(cur_css_interface_rec.im_s_opt_total_cont_inc),
                                           x_im_s_opt_cash_bank_accounts       => convert_int(cur_css_interface_rec.im_s_opt_cash_bank_accounts),
                                           x_im_s_opt_ira_keogh_accounts       => convert_int(cur_css_interface_rec.im_s_opt_ira_keogh_accounts),
                                           x_im_s_opt_home_equity              => convert_int(cur_css_interface_rec.im_s_opt_home_equity),
                                           x_im_s_opt_ot_rl_est_inv_eq         => convert_int(cur_css_interface_rec.im_s_opt_ot_rl_est_inv_eq),
                                           x_im_s_opt_adj_bus_farm_worth       => convert_int(cur_css_interface_rec.im_s_opt_adj_bus_farm_worth),
                                           x_im_s_opt_trusts                   => convert_int(cur_css_interface_rec.im_s_opt_trusts),
                                           x_im_s_opt_net_worth                => convert_int(cur_css_interface_rec.im_s_opt_net_worth),
                                           x_im_s_opt_emerg_res_allow          => convert_int(cur_css_interface_rec.im_s_opt_emerg_res_allow),
                                           x_im_s_opt_cum_ed_savings           => convert_int(cur_css_interface_rec.im_s_opt_cum_ed_savings),
                                           x_im_s_opt_total_asset_allow        => convert_int(cur_css_interface_rec.im_s_opt_total_asset_allow),
                                           x_im_s_opt_disc_net_worth           => convert_int(cur_css_interface_rec.im_s_opt_disc_net_worth),
                                           x_im_s_opt_total_cont_asset         => convert_int(cur_css_interface_rec.im_s_opt_total_cont_asset),
                                           x_im_s_opt_total_cont               => convert_int(cur_css_interface_rec.im_s_opt_total_cont),
                                           x_im_s_opt_num_in_coll_adj          => convert_int(cur_css_interface_rec.im_s_opt_num_in_coll_adj),
                                           x_im_s_opt_cont_for_stu             => convert_int(cur_css_interface_rec.im_s_opt_cont_for_stu),
                                           x_im_s_opt_cont_from_income         => convert_int(cur_css_interface_rec.im_s_opt_cont_from_income),
                                           x_im_s_opt_cont_from_assets         => convert_int(cur_css_interface_rec.im_s_opt_cont_from_assets),
                                           x_fm_s_analysis_type                => convert_int(cur_css_interface_rec.fm_s_analysis_type),
                                           x_fm_s_agi_taxable_income           => convert_int(cur_css_interface_rec.fm_s_agi_taxable_income),
                                           x_fm_s_untx_inc_and_ben             => convert_int(cur_css_interface_rec.fm_s_untx_inc_and_ben),
                                           x_fm_s_inc_adj                      => convert_int(cur_css_interface_rec.fm_s_inc_adj),
                                           x_fm_s_total_income                 => convert_int(cur_css_interface_rec.fm_s_total_income),
                                           x_fm_s_us_income_tax                => convert_int(cur_css_interface_rec.fm_s_us_income_tax),
                                           x_fm_s_state_and_oth_taxes          => convert_int(cur_css_interface_rec.fm_s_state_and_oth_taxes),
                                           x_fm_s_fica_tax                     => convert_int(cur_css_interface_rec.fm_s_fica_tax),
                                           x_fm_s_employment_allow             => convert_int(cur_css_interface_rec.fm_s_employment_allow),
                                           x_fm_s_income_prot_allow            => convert_int(cur_css_interface_rec.fm_s_income_prot_allow),
                                           x_fm_s_total_allow                  => convert_int(cur_css_interface_rec.fm_s_total_allow),
                                           x_fm_s_cal_avail_income             => convert_int(cur_css_interface_rec.fm_s_cal_avail_income),
                                           x_fm_s_avail_income                 => convert_int(cur_css_interface_rec.fm_s_avail_income),
                                           x_fm_s_cash_bank_accounts           => convert_int(cur_css_interface_rec.fm_s_cash_bank_accounts),
                                           x_fm_s_ot_rl_est_inv_equity         => convert_int(cur_css_interface_rec.fm_s_ot_rl_est_inv_equity),
                                           x_fm_s_adj_bus_farm_worth           => convert_int(cur_css_interface_rec.fm_s_adj_bus_farm_worth),
                                           x_fm_s_trusts                       => convert_int(cur_css_interface_rec.fm_s_trusts),
                                           x_fm_s_net_worth                    => convert_int(cur_css_interface_rec.fm_s_net_worth),
                                           x_fm_s_asset_prot_allow             => convert_int(cur_css_interface_rec.fm_s_asset_prot_allow),
                                           x_fm_s_disc_net_worth               => convert_int(cur_css_interface_rec.fm_s_disc_net_worth),
                                           x_fm_s_total_cont                   => convert_int(cur_css_interface_rec.fm_s_total_cont),
                                           x_fm_s_num_in_coll                  => convert_int(cur_css_interface_rec.fm_s_num_in_coll),
                                           x_fm_s_cont_for_stu                 => convert_int(cur_css_interface_rec.fm_s_cont_for_stu),
                                           x_fm_s_cont_from_income             => convert_int(cur_css_interface_rec.fm_s_cont_from_income),
                                           x_fm_s_cont_from_assets             => convert_int(cur_css_interface_rec.fm_s_cont_from_assets),
                                           x_im_inst_resident_ind              => convert_int(cur_css_interface_rec.im_inst_resident_ind),
                                           x_institutional_1_budget_name       => cur_css_interface_rec.institutional_1_budget_name,
                                           x_im_inst_1_budget_duration         => convert_int(cur_css_interface_rec.im_inst_1_budget_duration),
                                           x_im_inst_1_tuition_fees            => convert_int(cur_css_interface_rec.im_inst_1_tuition_fees),
                                           x_im_inst_1_books_supplies          => convert_int(cur_css_interface_rec.im_inst_1_books_supplies),
                                           x_im_inst_1_living_expenses         => convert_int(cur_css_interface_rec.im_inst_1_living_expenses),
                                           x_im_inst_1_tot_expenses            => convert_int(cur_css_interface_rec.im_inst_1_tot_expenses),
                                           x_im_inst_1_tot_stu_cont            => convert_int(cur_css_interface_rec.im_inst_1_tot_stu_cont),
                                           x_im_inst_1_tot_par_cont            => convert_int(cur_css_interface_rec.im_inst_1_tot_par_cont),
                                           x_im_inst_1_tot_family_cont         => convert_int(cur_css_interface_rec.im_inst_1_tot_family_cont),
                                           x_im_inst_1_va_benefits             => convert_int(cur_css_interface_rec.im_inst_1_va_benefits),
                                           x_im_inst_1_ot_cont                 => convert_int(cur_css_interface_rec.im_inst_1_ot_cont),
                                           x_im_inst_1_est_financial_need      => convert_int(cur_css_interface_rec.im_inst_1_est_financial_need),
                                           x_institutional_2_budget_name       => cur_css_interface_rec.institutional_2_budget_name,
                                           x_im_inst_2_budget_duration         => convert_int(cur_css_interface_rec.im_inst_2_budget_duration),
                                           x_im_inst_2_tuition_fees            => convert_int(cur_css_interface_rec.im_inst_2_tuition_fees),
                                           x_im_inst_2_books_supplies          => convert_int(cur_css_interface_rec.im_inst_2_books_supplies),
                                           x_im_inst_2_living_expenses         => convert_int(cur_css_interface_rec.im_inst_2_living_expenses),
                                           x_im_inst_2_tot_expenses            => convert_int(cur_css_interface_rec.im_inst_2_tot_expenses),
                                           x_im_inst_2_tot_stu_cont            => convert_int(cur_css_interface_rec.im_inst_2_tot_stu_cont),
                                           x_im_inst_2_tot_par_cont            => convert_int(cur_css_interface_rec.im_inst_2_tot_par_cont),
                                           x_im_inst_2_tot_family_cont         => convert_int(cur_css_interface_rec.im_inst_2_tot_family_cont),
                                           x_im_inst_2_va_benefits             => convert_int(cur_css_interface_rec.im_inst_2_va_benefits),
                                           x_im_inst_2_est_financial_need      => convert_int(cur_css_interface_rec.im_inst_2_est_financial_need),
                                           x_institutional_3_budget_name       => cur_css_interface_rec.institutional_3_budget_name,
                                           x_im_inst_3_budget_duration         => convert_int(cur_css_interface_rec.im_inst_3_budget_duration),
                                           x_im_inst_3_tuition_fees            => convert_int(cur_css_interface_rec.im_inst_3_tuition_fees),
                                           x_im_inst_3_books_supplies          => convert_int(cur_css_interface_rec.im_inst_3_books_supplies),
                                           x_im_inst_3_living_expenses         => convert_int(cur_css_interface_rec.im_inst_3_living_expenses),
                                           x_im_inst_3_tot_expenses            => convert_int(cur_css_interface_rec.im_inst_3_tot_expenses),
                                           x_im_inst_3_tot_stu_cont            => convert_int(cur_css_interface_rec.im_inst_3_tot_stu_cont),
                                           x_im_inst_3_tot_par_cont            => convert_int(cur_css_interface_rec.im_inst_3_tot_par_cont),
                                           x_im_inst_3_tot_family_cont         => convert_int(cur_css_interface_rec.im_inst_3_tot_family_cont),
                                           x_im_inst_3_va_benefits             => convert_int(cur_css_interface_rec.im_inst_3_va_benefits),
                                           x_im_inst_3_est_financial_need      => convert_int(cur_css_interface_rec.im_inst_3_est_financial_need),
                                           x_fm_inst_1_federal_efc             => cur_css_interface_rec.fm_inst_1_federal_efc,
                                           x_fm_inst_1_va_benefits             => cur_css_interface_rec.fm_inst_1_va_benefits,
                                           x_fm_inst_1_fed_eligibility         => cur_css_interface_rec.fm_inst_1_fed_eligibility,
                                           x_fm_inst_1_pell                    => cur_css_interface_rec.fm_inst_1_pell,
                                           x_option_par_loss_allow_ind         => cur_css_interface_rec.option_par_loss_allow_ind,
                                           x_option_par_tuition_ind            => cur_css_interface_rec.option_par_tuition_ind,
                                           x_option_par_home_ind               => cur_css_interface_rec.option_par_home_ind,
                                           x_option_par_home_value             => cur_css_interface_rec.option_par_home_value,
                                           x_option_par_home_debt              => cur_css_interface_rec.option_par_home_debt,
                                           x_option_stu_ira_keogh_ind          => cur_css_interface_rec.option_stu_ira_keogh_ind,
                                           x_option_stu_home_ind               => cur_css_interface_rec.option_stu_home_ind,
                                           x_option_stu_home_value             => cur_css_interface_rec.option_stu_home_value,
                                           x_option_stu_home_debt              => cur_css_interface_rec.option_stu_home_debt,
                                           x_option_stu_sum_ay_inc_ind         => cur_css_interface_rec.option_stu_sum_ay_inc_ind,
                                           x_option_par_hope_ll_credit         => cur_css_interface_rec.option_par_hope_ll_credit,
                                           x_option_stu_hope_ll_credit         => cur_css_interface_rec.option_stu_hope_ll_credit,
                                           x_im_parent_1_8_months_bas          => cur_css_interface_rec.im_parent_1_8_months_bas,
                                           x_im_p_more_than_9_mth_ba           => cur_css_interface_rec.im_p_more_than_9_mth_ba,
                                           x_im_parent_1_8_months_opt          => cur_css_interface_rec.im_parent_1_8_months_opt,
                                           x_im_p_more_than_9_mth_op           => cur_css_interface_rec.im_p_more_than_9_mth_op,
                                           x_fnar_message_1                    => cur_css_interface_rec.fnar_message_1,
                                           x_fnar_message_2                    => cur_css_interface_rec.fnar_message_2,
                                           x_fnar_message_3                    => cur_css_interface_rec.fnar_message_3,
                                           x_fnar_message_4                    => cur_css_interface_rec.fnar_message_4,
                                           x_fnar_message_5                    => cur_css_interface_rec.fnar_message_5,
                                           x_fnar_message_6                    => cur_css_interface_rec.fnar_message_6,
                                           x_fnar_message_7                    => cur_css_interface_rec.fnar_message_7,
                                           x_fnar_message_8                    => cur_css_interface_rec.fnar_message_8,
                                           x_fnar_message_9                    => cur_css_interface_rec.fnar_message_9,
                                           x_fnar_message_10                   => cur_css_interface_rec.fnar_message_10,
                                           x_fnar_message_11                   => cur_css_interface_rec.fnar_message_11,
                                           x_fnar_message_12                   => cur_css_interface_rec.fnar_message_12,
                                           x_fnar_message_13                   => cur_css_interface_rec.fnar_message_13,
                                           x_fnar_message_20                   => cur_css_interface_rec.fnar_message_20,
                                           x_fnar_message_21                   => cur_css_interface_rec.fnar_message_21,
                                           x_fnar_message_22                   => cur_css_interface_rec.fnar_message_22,
                                           x_fnar_message_23                   => cur_css_interface_rec.fnar_message_23,
                                           x_fnar_message_24                   => cur_css_interface_rec.fnar_message_24,
                                           x_fnar_message_25                   => cur_css_interface_rec.fnar_message_25,
                                           x_fnar_message_26                   => cur_css_interface_rec.fnar_message_26,
                                           x_fnar_message_27                   => cur_css_interface_rec.fnar_message_27,
                                           x_fnar_message_30                   => cur_css_interface_rec.fnar_message_30,
                                           x_fnar_message_31                   => cur_css_interface_rec.fnar_message_31,
                                           x_fnar_message_32                   => cur_css_interface_rec.fnar_message_32,
                                           x_fnar_message_33                   => cur_css_interface_rec.fnar_message_33,
                                           x_fnar_message_34                   => cur_css_interface_rec.fnar_message_34,
                                           x_fnar_message_35                   => cur_css_interface_rec.fnar_message_35,
                                           x_fnar_message_36                   => cur_css_interface_rec.fnar_message_36,
                                           x_fnar_message_37                   => cur_css_interface_rec.fnar_message_37,
                                           x_fnar_message_38                   => cur_css_interface_rec.fnar_message_38,
                                           x_fnar_message_39                   => cur_css_interface_rec.fnar_message_39,
                                           x_fnar_message_45                   => cur_css_interface_rec.fnar_message_45,
                                           x_fnar_message_46                   => cur_css_interface_rec.fnar_message_46,
                                           x_fnar_message_47                   => cur_css_interface_rec.fnar_message_47,
                                           x_fnar_message_48                   => cur_css_interface_rec.fnar_message_48,
                                           x_fnar_message_50                   => cur_css_interface_rec.fnar_message_50,
                                           x_fnar_message_51                   => cur_css_interface_rec.fnar_message_51,
                                           x_fnar_message_52                   => cur_css_interface_rec.fnar_message_52,
                                           x_fnar_message_53                   => cur_css_interface_rec.fnar_message_53,
                                           x_fnar_message_56                   => cur_css_interface_rec.fnar_message_56,
                                           x_fnar_message_57                   => cur_css_interface_rec.fnar_message_57,
                                           x_fnar_message_58                   => cur_css_interface_rec.fnar_message_58,
                                           x_fnar_message_59                   => cur_css_interface_rec.fnar_message_59,
                                           x_fnar_message_60                   => cur_css_interface_rec.fnar_message_60,
                                           x_fnar_message_61                   => cur_css_interface_rec.fnar_message_61,
                                           x_fnar_message_62                   => cur_css_interface_rec.fnar_message_62,
                                           x_fnar_message_63                   => cur_css_interface_rec.fnar_message_63,
                                           x_fnar_message_64                   => cur_css_interface_rec.fnar_message_64,
                                           x_fnar_message_65                   => cur_css_interface_rec.fnar_message_65,
                                           x_fnar_message_71                   => cur_css_interface_rec.fnar_message_71,
                                           x_fnar_message_72                   => cur_css_interface_rec.fnar_message_72,
                                           x_fnar_message_73                   => cur_css_interface_rec.fnar_message_73,
                                           x_fnar_message_74                   => cur_css_interface_rec.fnar_message_74,
                                           x_fnar_message_75                   => cur_css_interface_rec.fnar_message_75,
                                           x_fnar_message_76                   => cur_css_interface_rec.fnar_message_76,
                                           x_fnar_message_77                   => cur_css_interface_rec.fnar_message_77,
                                           x_fnar_message_78                   => cur_css_interface_rec.fnar_message_78,
                                           x_fnar_mesg_10_stu_fam_mem          => cur_css_interface_rec.fnar_mesg_10_stu_fam_mem,
                                           x_fnar_mesg_11_stu_no_in_coll       => cur_css_interface_rec.fnar_mesg_11_stu_no_in_coll,
                                           x_fnar_mesg_24_stu_avail_inc        => cur_css_interface_rec.fnar_mesg_24_stu_avail_inc,
                                           x_fnar_mesg_26_stu_taxes            => cur_css_interface_rec.fnar_mesg_26_stu_taxes,
                                           x_fnar_mesg_33_stu_home_value       => cur_css_interface_rec.fnar_mesg_33_stu_home_value,
                                           x_fnar_mesg_34_stu_home_value       => cur_css_interface_rec.fnar_mesg_34_stu_home_value,
                                           x_fnar_mesg_34_stu_home_equity      => cur_css_interface_rec.fnar_mesg_34_stu_home_equity,
                                           x_fnar_mesg_35_stu_home_value       => cur_css_interface_rec.fnar_mesg_35_stu_home_value,
                                           x_fnar_mesg_35_stu_home_equity      => cur_css_interface_rec.fnar_mesg_35_stu_home_equity,
                                           x_fnar_mesg_36_stu_home_equity      => cur_css_interface_rec.fnar_mesg_36_stu_home_equity,
                                           x_fnar_mesg_48_par_fam_mem          => cur_css_interface_rec.fnar_mesg_48_par_fam_mem,
                                           x_fnar_mesg_49_par_no_in_coll       => cur_css_interface_rec.fnar_mesg_49_par_no_in_coll,
                                           x_fnar_mesg_56_par_agi              => cur_css_interface_rec.fnar_mesg_56_par_agi,
                                           x_fnar_mesg_62_par_taxes            => cur_css_interface_rec.fnar_mesg_62_par_taxes,
                                           x_fnar_mesg_73_par_home_value       => cur_css_interface_rec.fnar_mesg_73_par_home_value,
                                           x_fnar_mesg_74_par_home_value       => cur_css_interface_rec.fnar_mesg_74_par_home_value,
                                           x_fnar_mesg_74_par_home_equity      => cur_css_interface_rec.fnar_mesg_74_par_home_equity,
                                           x_fnar_mesg_75_par_home_value       => cur_css_interface_rec.fnar_mesg_75_par_home_value,
                                           x_fnar_mesg_75_par_home_equity      => cur_css_interface_rec.fnar_mesg_75_par_home_equity,
                                           x_fnar_mesg_76_par_home_equity      => cur_css_interface_rec.fnar_mesg_76_par_home_equity,
                                           x_assumption_message_1              => cur_css_interface_rec.assumption_message_1,
                                           x_assumption_message_2              => cur_css_interface_rec.assumption_message_2,
                                           x_assumption_message_3              => cur_css_interface_rec.assumption_message_3,
                                           x_assumption_message_4              => cur_css_interface_rec.assumption_message_4,
                                           x_assumption_message_5              => cur_css_interface_rec.assumption_message_5,
                                           x_assumption_message_6              => cur_css_interface_rec.assumption_message_6,
                                           x_record_mark                       => cur_css_interface_rec.record_mark,
                                           x_fnar_message_55                   => cur_css_interface_rec.fnar_message_55,
                                           x_fnar_message_49                   => cur_css_interface_rec.fnar_message_49,
                                           x_opt_par_cola_adj_ind              => cur_css_interface_rec.option_par_cola_adj_ind,
                                           x_opt_par_stu_fa_assets_ind         => cur_css_interface_rec.option_par_stu_fa_assets_ind,
                                           x_opt_par_ipt_assets_ind            => cur_css_interface_rec.option_par_ipt_assets_ind,
                                           x_opt_stu_ipt_assets_ind            => cur_css_interface_rec.option_stu_ipt_assets_ind,
                                           x_opt_par_cola_adj_value            => convert_int(cur_css_interface_rec.option_par_cola_adj_value),
                                           x_legacy_record_flag                => NULL,
                                           x_opt_ind_stu_ipt_assets_flag       => cur_css_interface_rec.option_ind_stu_ipt_assets_flag,
                                           x_cust_parent_cont_adj_num          => cur_css_interface_rec.cust_parent_cont_adj_num,
                                           x_custodial_parent_num              => cur_css_interface_rec.custodial_parent_num,
                                           x_cust_par_base_prcnt_inc_amt       => cur_css_interface_rec.cust_par_base_prcnt_inc_amt,
                                           x_cust_par_base_cont_inc_amt        => cur_css_interface_rec.cust_par_base_cont_inc_amt,
                                           x_cust_par_base_cont_ast_amt        => cur_css_interface_rec.cust_par_base_cont_ast_amt,
                                           x_cust_par_base_tot_cont_amt        => cur_css_interface_rec.cust_par_base_tot_cont_amt,
                                           x_cust_par_opt_prcnt_inc_amt        => cur_css_interface_rec.cust_par_opt_prcnt_inc_amt,
                                           x_cust_par_opt_cont_inc_amt         => cur_css_interface_rec.cust_par_opt_cont_inc_amt,
                                           x_cust_par_opt_cont_ast_amt         => cur_css_interface_rec.cust_par_opt_cont_ast_amt,
                                           x_cust_par_opt_tot_cont_amt         => cur_css_interface_rec.cust_par_opt_cont_ast_amt,
                                           x_parents_email_txt                 => cur_css_interface_rec.parents_email_txt,
                                           x_parent_1_birth_date               => cur_css_interface_rec.parent_1_birth_date,
                                           x_parent_2_birth_date               => cur_css_interface_rec.parent_2_birth_date
                                         );

           END LOOP;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_fnar_data.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.create_fnar_data');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.create_fnar_data'||SQLERRM);
      app_exception.raise_exception;
  END create_fnar_data;


  PROCEDURE create_person_record(
                      pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                      pn_person_id  OUT NOCOPY  igf_ap_fa_base_rec_all.person_id%TYPE,
                      pv_mesg_data  OUT NOCOPY  VARCHAR2,
                      p_called_from             VARCHAR2
                      )IS

  /*
  ||  Created By : Meghana
  ||  Created On : 12-JUN-2001
  ||  Purpose : Create a new person record .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who            When            What
  ||  skpandey         21-SEP-2005   Bug: 3663505
  ||                                 Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
  ||  bkkumar        08-Dec-2003     Bug# 3030541 changed the exception block
  ||                                 to assign the fnd_message.get to the  pv_mesg_data.
  ||  masehgal       16-Apr-2002     # 2320076  Made changes in the log file to include student details.
  ||  bkkumar        11-Aug-2003     Bug# 3084964 Added the check for the
  ||                                 HZ_GENERATE_PARTY_NUMBER profile value
  ||                                 and removed the hard coded strings.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
      SELECT iii.last_name, iii.middle_initial, iii.social_security_number,iii.first_name,iii.r_s_email_address,date_of_birth
      FROM   igf_ap_css_interface iii
      WHERE  iii.css_id = pn_css_id;

    ln_msg_count    NUMBER;
    lv_msg_data   VARCHAR2(2000);
    lv_return_status  VARCHAR2(1);
    lv_row_id   VARCHAR2(30);
    ln_person_number  hz_parties.party_number%TYPE;
    retcode     NUMBER;
    errbuf      VARCHAR2(300);
    l_object_version_number NUMBER;
  BEGIN

     IF FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_person_record','Profile value for HZ_GENERATE_PARTY_NUMBER is set to N' );
       END IF;
       fnd_message.set_name ('IGF','IGF_AP_HZ_GEN_PARTY_NUMBER');
       IF p_called_from = 'FORM' THEN
         pv_mesg_data := fnd_message.get;
         RETURN;
       ELSE
         fnd_file.put_line (FND_FILE.LOG, fnd_message.get);
         log_debug_message(fnd_message.get);
         app_exception.raise_exception;
       END IF;
     END IF;

     -- Create a new person by getting the details from css_interface table.
     FOR cur_css_interface_rec IN cur_css_interface (pn_css_id)
     LOOP
      BEGIN
        l_object_version_number := NULL;
        igs_pe_person_pkg.insert_row(
             x_MSG_COUNT                => ln_msg_count,
             x_MSG_DATA                 => lv_msg_data,
             x_RETURN_STATUS            => lv_return_status,
             x_ROWID                    => lv_row_id,
             x_PERSON_ID                => pn_person_id,
             x_PERSON_NUMBER            => ln_person_number,
             x_SURNAME                  => INITCAP(cur_css_interface_rec.last_name),
             x_MIDDLE_NAME              => cur_css_interface_rec.middle_initial,
             x_GIVEN_NAMES              => INITCAP(cur_css_interface_rec.first_name),
             x_SEX                      => 'UNSPECIFIED',
             x_TITLE                    => NULL,
             x_STAFF_MEMBER_IND         => NULL,
             x_DECEASED_IND             => NULL,
             x_SUFFIX                   => NULL,
             x_PRE_NAME_ADJUNCT         => NULL,
             x_ARCHIVE_EXCLUSION_IND    => NULL,
             x_ARCHIVE_DT               => NULL,
             x_PURGE_EXCLUSION_IND      => NULL,
             x_PURGE_DT                 => NULL,
             x_DECEASED_DATE            => NULL,
             x_PROOF_OF_INS             => NULL,
             x_PROOF_OF_IMMU            => NULL,
             x_BIRTH_DT                 => TO_DATE(cur_css_interface_rec.date_of_birth,'MMDDYYYY'),
             x_SALUTATION               => NULL,
             x_ORACLE_USERNAME          => NULL,
             x_PREFERRED_GIVEN_NAME     => INITCAP(cur_css_interface_rec.first_name),
             x_EMAIL_ADDR               => cur_css_interface_rec.r_s_email_address,
             x_LEVEL_OF_QUAL_ID         => NULL,
             x_MILITARY_SERVICE_REG     => NULL,
             x_VETERAN                  => NULL,
             x_HZ_PARTIES_OVN           => l_object_version_number,
             x_ATTRIBUTE_CATEGORY       => NULL,
             x_ATTRIBUTE1               => NULL,
             x_ATTRIBUTE2               => NULL,
             x_ATTRIBUTE3               => NULL,
             x_ATTRIBUTE4               => NULL,
             x_ATTRIBUTE5               => NULL,
             x_ATTRIBUTE6               => NULL,
             x_ATTRIBUTE7               => NULL,
             x_ATTRIBUTE8               => NULL,
             x_ATTRIBUTE9               => NULL,
             x_ATTRIBUTE10              => NULL,
             x_ATTRIBUTE11              => NULL,
             x_ATTRIBUTE12              => NULL,
             x_ATTRIBUTE13              => NULL,
             x_ATTRIBUTE14              => NULL,
             x_ATTRIBUTE15              => NULL,
             x_ATTRIBUTE16              => NULL,
             x_ATTRIBUTE17              => NULL,
             x_ATTRIBUTE18              => NULL,
             x_ATTRIBUTE19              => NULL,
	     x_ATTRIBUTE20              => NULL,
             x_PERSON_ID_TYPE           => 'SSN',
             x_API_PERSON_ID            => igf_ap_matching_process_pkg.format_SSN(cur_css_interface_rec.social_security_number)
             );
       EXCEPTION
        WHEN OTHERS THEN
           IF p_called_from = 'FORM' THEN
             pv_mesg_data := fnd_message.get;
           ELSE
             fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;
           RAISE SKIP_PERSON;
       END;
/* -- following code is commentned as these values are not set by SWS code
         IF pn_person_id IS NULL THEN
           g_bad_rec := nvl(g_bad_rec,0) + 1;
           IF p_called_from = 'FORM' THEN
             pv_mesg_data := lv_msg_data;
           ELSE
             fnd_file.put_line(fnd_file.log, lv_msg_data);
           END IF;
         END IF;

         fnd_file.put_line(fnd_file.log ,igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','STATUS') || ':' || lv_return_status);
         pv_mesg_data := lv_msg_data;
*/
    END LOOP;

  EXCEPTION
    WHEN SKIP_PERSON THEN
      RAISE SKIP_PERSON;
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_person_record.exception','The exception is : ' || SQLERRM );
      END IF;
       IF pn_person_id IS NULL THEN
          g_bad_rec := nvl(g_bad_rec,0) + 1;
       END IF;
       IF fnd_msg_pub.count_msg = 1 THEN
          pv_mesg_data := fnd_message.get;
       ELSIF fnd_msg_pub.count_msg > 1 THEN
          pv_mesg_data := SQLERRM;
       END IF ;
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.create_person_record');
       IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.create_person_record'||SQLERRM);
      app_exception.raise_exception;

  END create_person_record;


  PROCEDURE create_person_addr_record(pn_css_id        igf_ap_css_interface_all.css_id%TYPE,
                                            pn_person_id     igf_ap_fa_base_rec_all.person_id%TYPE
                                            )  IS

  /*
  ||  Created By : Meghana
  ||  Created On : 12-JUN-2001
  ||  Purpose : Create person address record after creating the person record for a new person.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rajagupt        29-Jun-06       bug #5348743, Added check to handle lv_return_status of warning type
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
      SELECT city, state_mailing, address_number_and_street, s_telephone_number, zip_code
      FROM   igf_ap_css_interface iii
      WHERE  css_id = pn_css_id;

    lv_row_id   VARCHAR2(30);
    retcode   NUMBER;
    errbuf      VARCHAR2(300);
    lv_msg_data   VARCHAR2(2000);
    lv_return_status  VARCHAR2(1);
    lv_location_id  hz_locations.location_id%TYPE;
    pd_last_update_date DATE;
    ln_party_site_id  hz_party_sites.party_site_id%TYPE;
    l_party_site_ovn   hz_party_sites.object_version_number%TYPE;
    l_location_ovn     hz_locations.object_version_number%TYPE;

  BEGIN

    FOR cur_css_interface_rec IN cur_css_interface( pn_css_id)
    LOOP

      igs_pe_person_addr_pkg.insert_row(
        P_ACTION                     => 'R',
        P_ROWID                      => lv_row_id,
        P_LOCATION_ID                => lv_location_id,
        P_START_DT                   => NULL,
        P_END_DT                     => NULL,
        P_COUNTRY                    => 'US',
        P_ADDRESS_STYLE              => NULL,
        P_ADDR_LINE_1                => INITCAP(cur_css_interface_rec.address_number_and_street),
        P_ADDR_LINE_2                => NULL,
        P_ADDR_LINE_3                => NULL,
        P_ADDR_LINE_4                => NULL,
        P_DATE_LAST_VERIFIED         => NULL,
        P_CORRESPONDENCE             => NULL,
        P_CITY                       => INITCAP(cur_css_interface_rec.city),
        P_STATE                      => cur_css_interface_rec.state_mailing,
        P_PROVINCE                   => NULL,
        P_COUNTY                     => NULL,
        P_POSTAL_CODE                => cur_css_interface_rec.zip_code,
        P_ADDRESS_LINES_PHONETIC     => NULL,
        P_DELIVERY_POINT_CODE        => NULL,
        P_OTHER_DETAILS_1            => NULL,
        P_OTHER_DETAILS_2            => NULL,
        P_OTHER_DETAILS_3            => NULL,
        L_RETURN_STATUS              => lv_return_status,
        L_MSG_DATA                   => lv_msg_data,
        P_PARTY_ID                   => pn_person_id,
        P_PARTY_SITE_ID              => ln_party_site_id,
        P_PARTY_TYPE                 => NULL,
        P_LAST_UPDATE_DATE           => pd_last_update_date,
        P_PARTY_SITE_OVN             => l_party_site_ovn,
        P_LOCATION_OVN               => l_location_ovn,
        P_STATUS                     => 'A'
      );
    END LOOP;

    IF lv_return_status = 'S' THEN
          FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_PER_ADD');
          FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);
    -- bug 5348743
      ELSIF lv_return_status ='W' THEN
          FND_FILE.PUT_LINE(fnd_file.log, lv_msg_data);
      ELSE
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_CRT_ADDR_FAILED');
         FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);
        -- FND_FILE.PUT_LINE(FND_FILE.LOG ,lv_msg_data||fnd_global.newline ||'Status:'||lv_return_status);
    END IF;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_person_addr_record.exception','The exception is : ' || SQLERRM );
      END IF;
      -- FND_FILE.PUT_LINE(FND_FILE.LOG ,lv_msg_data||fnd_global.newline ||'Status:'||lv_return_status);
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.create_person_addr_record');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.create_person_addr_record'|| SQLERRM);
  END create_person_addr_record;

PROCEDURE process_todo_items(p_base_id      NUMBER)
IS
  /*
  ||  Created By : hkodali
  ||  Created On : 3-Jan-2005
  ||  Purpose :    For updating TODO items for system todo type of PROFILE.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   CURSOR todo_items_for_profile_cur IS
   SELECT im.*
   FROM   igf_ap_td_item_mst im
   WHERE  im.system_todo_type_code = 'PROFILE' -- for PROFILE type only
     AND im.ci_cal_type = g_ci_cal_type
     AND im.ci_sequence_number = g_ci_sequence_number;

   CURSOR check_todo_exists_inst_cur(lp_base_id NUMBER, p_item_seq_num NUMBER) IS
     SELECT ii.rowid, ii.*
       FROM igf_ap_td_item_inst ii, igf_ap_td_item_mst im
      WHERE ii.item_sequence_number = im.todo_number
        AND im.system_todo_type_code = 'PROFILE'
        AND im.ci_cal_type = g_ci_cal_type
        AND im.ci_sequence_number = g_ci_sequence_number
        AND ii.item_sequence_number = p_item_seq_num
        AND ii.base_id = lp_base_id;

   l_todo_status igf_ap_td_item_inst_all.status%TYPE;

    check_todo_exists_inst_rec check_todo_exists_inst_cur%ROWTYPE;

    lv_rowid ROWID;

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_todo_items.debug','Beginning processing of TODO Items for BASE ID: ' || p_base_id || ', Active Profile: ' || g_active_profile );
   END IF;

log_debug_message(' Processing TODO items.... ');
   -- populate the variable with the status to be updated for the records
   IF g_active_profile = 'Y' THEN
      -- need to set the todo status for the records to COMPLETE
      l_todo_status := 'COM';

   ELSE
      -- need to set the todo status for the records to INCOMPLETE
      l_todo_status := 'REC';
   END IF;


   -- loop thru the records and update the status
   FOR todo_items_for_profile_rec IN todo_items_for_profile_cur
   LOOP
      check_todo_exists_inst_rec := NULL;
      OPEN check_todo_exists_inst_cur(p_base_id, todo_items_for_profile_rec.todo_number);
      FETCH check_todo_exists_inst_cur INTO check_todo_exists_inst_rec;

      IF check_todo_exists_inst_cur%NOTFOUND THEN

      log_debug_message(' Attaching new ISIR with item_sequence_number : ' || todo_items_for_profile_rec.todo_number || ' and TODO status : ' || l_todo_status || '  for Base ID: ' || p_base_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_todo_items.debug','Attaching new ISIR with item_sequence_number : ' || todo_items_for_profile_rec.todo_number || '  for Base ID: ' || p_base_id);
      END IF;

      -- insert new row
      lv_rowid := NULL;
      igf_ap_td_item_inst_pkg.insert_row (
             x_rowid                        => lv_rowid                                    ,
             x_base_id                      => p_base_id                                   ,
             x_item_sequence_number         => todo_items_for_profile_rec.todo_number         ,
             x_status                       => l_todo_status                               ,
             x_status_date                  => TRUNC(SYSDATE)                              ,
             x_add_date                     => TRUNC(SYSDATE)                              ,
             x_corsp_date                   => NULL                                        ,
             x_corsp_count                  => NULL                                        ,
             x_inactive_flag                => 'N'                                         ,
             x_freq_attempt                 => todo_items_for_profile_rec.freq_attempt        ,
             x_max_attempt                  => todo_items_for_profile_rec.max_attempt         ,
             x_required_for_application     => todo_items_for_profile_rec.required_for_application,
             x_mode                         => 'R'                                        ,
             x_legacy_record_flag           => NULL,
             x_clprl_id                     => NULL
          );
      ELSE

      log_debug_message(' Update TODO Items to Status : ' || l_todo_status);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_todo_items.debug','Processing TODO status to  : ' || l_todo_status || '  for Base ID: ' || p_base_id);
      END IF;

      -- update the status to complete
      igf_ap_td_item_inst_pkg.update_row (
             x_rowid                        => check_todo_exists_inst_rec.rowid               ,
             x_base_id                      => p_base_id                                      ,
             x_item_sequence_number         => check_todo_exists_inst_rec.item_sequence_number,
             x_status                       => l_todo_status                                  ,
             x_status_date                  => check_todo_exists_inst_rec.status_date         ,
             x_add_date                     => check_todo_exists_inst_rec.add_date            ,
             x_corsp_date                   => check_todo_exists_inst_rec.corsp_date          ,
             x_corsp_count                  => check_todo_exists_inst_rec.corsp_count         ,
             x_inactive_flag                => check_todo_exists_inst_rec.inactive_flag       ,
             x_freq_attempt                 => check_todo_exists_inst_rec.freq_attempt        ,
             x_max_attempt                  => check_todo_exists_inst_rec.max_attempt         ,
             x_required_for_application     => check_todo_exists_inst_rec.required_for_application,
             x_mode                         => 'R'                                            ,
             x_legacy_record_flag           => check_todo_exists_inst_rec.legacy_record_flag,
             x_clprl_id                     => check_todo_exists_inst_rec.clprl_id
          );
      END IF;


      CLOSE check_todo_exists_inst_cur;

      log_debug_message('Successfully processed TODO processing.');
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_todo_items.debug','Item No.: ' || todo_items_for_profile_rec.todo_number);
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.process_todo_items.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END process_todo_items;


  PROCEDURE create_profile_matched(pn_css_id             igf_ap_css_interface_all.css_id%TYPE,
                                   pn_cssp_id     OUT NOCOPY    igf_ap_css_profile.cssp_id%TYPE,
                                   pn_base_id            igf_ap_css_profile.base_id%TYPE,
                                   pn_system_record_type igf_ap_css_profile.system_record_type%TYPE
                                   )  IS
  /*
  ||  Created By : Meghana
  ||  Created On : 11-JUN-2001
  ||  Purpose : To create the profile matched record once the person satisfies the matching process.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
      SELECT ROWID row_id, iii.*
      FROM   igf_ap_css_interface_all iii
      WHERE  iii.css_id = pn_css_id;

    lv_rowid    VARCHAR2(30);
    ln_org_id       NUMBER ;
    ln_cssp_id      NUMBER ;
  BEGIN


    -- Insert Record in IGF_AP_CSS_PROFILE table
    FOR cur_css_interface_rec IN cur_css_interface ( pn_css_id)
    LOOP

       igf_ap_css_profile_pkg.insert_row(
                      x_mode                              => 'R',
                      x_rowid                             => lv_rowid,
                      x_cssp_id                           => pn_cssp_id,
                      x_base_id                           => pn_base_id,
                      x_system_record_type                => pn_system_record_type,
                      x_active_profile                    => g_active_profile,
                      x_college_code                      => cur_css_interface_rec.college_code,
                      x_academic_year                     => cur_css_interface_rec.academic_year,
                      x_stu_record_type                   => convert_int(cur_css_interface_rec.stu_record_type),
                      x_css_id_number                     => convert_int(cur_css_interface_rec.css_id_number),
                      x_registration_receipt_date         => cur_css_interface_rec.registration_receipt_date,
                      x_registration_type                 => convert_int(cur_css_interface_rec.registration_type),
                      x_application_receipt_date          => cur_css_interface_rec.application_receipt_date,
                      x_application_type                  => convert_int(cur_css_interface_rec.application_type),
                      x_original_fnar_compute             => cur_css_interface_rec.original_fnar_compute,
                      x_revision_fnar_compute_date        => cur_css_interface_rec.revision_fnar_compute_date,
                      x_electronic_extract_date           => cur_css_interface_rec.electronic_extract_date,
                      x_institutional_reporting_type      => convert_int(cur_css_interface_rec.institutional_reporting_type),
                      x_asr_receipt_date                  => cur_css_interface_rec.asr_receipt_date,
                      x_last_name                         => cur_css_interface_rec.last_name,
                      x_first_name                        => cur_css_interface_rec.first_name,
                      x_middle_initial                    => cur_css_interface_rec.middle_initial,
                      x_address_number_and_street         => cur_css_interface_rec.address_number_and_street,
                      x_city                              => cur_css_interface_rec.city,
                      x_state_mailing                     => cur_css_interface_rec.state_mailing,
                      x_zip_code                          => cur_css_interface_rec.zip_code,
                      x_s_telephone_number                => cur_css_interface_rec.s_telephone_number,
                      x_s_title                           => convert_int(cur_css_interface_rec.s_title),
                      x_date_of_birth                     => TO_DATE(cur_css_interface_rec.date_of_birth,'MMDDYYYY'),
                      x_social_security_number            => cur_css_interface_rec.social_security_number,
                      x_state_legal_residence             => cur_css_interface_rec.state_legal_residence,
                      x_foreign_address_indicator         => cur_css_interface_rec.foreign_address_indicator,
                      x_foreign_postal_code               => cur_css_interface_rec.foreign_postal_code,
                      x_country                           => cur_css_interface_rec.country,
                      x_financial_aid_status              => convert_int(cur_css_interface_rec.financial_aid_status),
                      x_year_in_college                   => convert_int(cur_css_interface_rec.year_in_college),
                      x_marital_status                    => convert_int(cur_css_interface_rec.marital_status),
                      x_ward_court                        => convert_int(cur_css_interface_rec.ward_court),
                      x_legal_dependents_other            => convert_int(cur_css_interface_rec.legal_dependents_other),
                      x_household_size                    => convert_int(cur_css_interface_rec.household_size),
                      x_number_in_college                 => convert_int(cur_css_interface_rec.number_in_college),
                      x_citizenship_status                => cur_css_interface_rec.citizenship_status,
                      x_citizenship_country               => cur_css_interface_rec.citizenship_country,
                      x_visa_classification               => convert_int(cur_css_interface_rec.visa_classification),
                      x_tax_figures                       => convert_int(cur_css_interface_rec.tax_figures),
                      x_number_exemptions                 => convert_int(cur_css_interface_rec.number_exemptions),
                      x_adjusted_gross_inc                => convert_int(cur_css_interface_rec.adjusted_gross_inc),
                      x_us_tax_paid                       => convert_int(cur_css_interface_rec.us_tax_paid),
                      x_itemized_deductions               => convert_int(cur_css_interface_rec.itemized_deductions),
                      x_stu_income_work                   => convert_int(cur_css_interface_rec.stu_income_work),
                      x_spouse_income_work                => convert_int(cur_css_interface_rec.spouse_income_work),
                      x_divid_int_inc                     => convert_int(cur_css_interface_rec.divid_int_inc),
                      x_soc_sec_benefits                  => convert_int(cur_css_interface_rec.soc_sec_benefits),
                      x_welfare_tanf                      => convert_int(cur_css_interface_rec.welfare_tanf),
                      x_child_supp_rcvd                   => convert_int(cur_css_interface_rec.child_supp_rcvd),
                      x_earned_income_credit              => convert_int(cur_css_interface_rec.earned_income_credit),
                      x_other_untax_income                => convert_int(cur_css_interface_rec.other_untax_income),
                      x_tax_stu_aid                       => convert_int(cur_css_interface_rec.tax_stu_aid),
                      x_cash_sav_check                    => convert_int(cur_css_interface_rec.cash_sav_check),
                      x_ira_keogh                         => convert_int(cur_css_interface_rec.ira_keogh),
                      x_invest_value                      => convert_int(cur_css_interface_rec.invest_value),
                      x_invest_debt                       => convert_int(cur_css_interface_rec.invest_debt),
                      x_home_value                        => convert_int(cur_css_interface_rec.home_value),
                      x_home_debt                         => convert_int(cur_css_interface_rec.home_debt),
                      x_oth_real_value                    => convert_int(cur_css_interface_rec.oth_real_value),
                      x_oth_real_debt                     => convert_int(cur_css_interface_rec.oth_real_debt),
                      x_bus_farm_value                    => convert_int(cur_css_interface_rec.bus_farm_value),
                      x_bus_farm_debt                     => convert_int(cur_css_interface_rec.bus_farm_debt),
                      x_live_on_farm                      => convert_int(cur_css_interface_rec.live_on_farm),
                      x_home_purch_price                  => convert_int(cur_css_interface_rec.home_purch_price),
                      x_hope_ll_credit                    => convert_int(cur_css_interface_rec.hope_ll_credit),
                      x_home_purch_year                   => convert_int(cur_css_interface_rec.home_purch_year),
                      x_trust_amount                      => convert_int(cur_css_interface_rec.trust_amount),
                      x_trust_avail                       => convert_int(cur_css_interface_rec.trust_avail),
                      x_trust_estab                       => convert_int(cur_css_interface_rec.trust_estab),
                      x_child_support_paid                => convert_int(cur_css_interface_rec.child_support_paid),
                      x_med_dent_expenses                 => convert_int(cur_css_interface_rec.med_dent_expenses),
                      x_vet_us                            => convert_int(cur_css_interface_rec.vet_us),
                      x_vet_ben_amount                    => convert_int(cur_css_interface_rec.vet_ben_amount),
                      x_vet_ben_months                    => convert_int(cur_css_interface_rec.vet_ben_months),
                      x_stu_summer_wages                  => convert_int(cur_css_interface_rec.stu_summer_wages),
                      x_stu_school_yr_wages               => convert_int(cur_css_interface_rec.stu_school_yr_wages),
                      x_spouse_summer_wages               => convert_int(cur_css_interface_rec.spouse_summer_wages),
                      x_spouse_school_yr_wages            => convert_int(cur_css_interface_rec.spouse_school_yr_wages),
                      x_summer_other_tax_inc              => convert_int(cur_css_interface_rec.summer_other_tax_inc),
                      x_school_yr_other_tax_inc           => convert_int(cur_css_interface_rec.school_yr_other_tax_inc),
                      x_summer_untax_inc                  => convert_int(cur_css_interface_rec.summer_untax_inc),
                      x_school_yr_untax_inc               => convert_int(cur_css_interface_rec.school_yr_untax_inc),
                      x_grants_schol_etc                  => convert_int(cur_css_interface_rec.grants_schol_etc),
                      x_tuit_benefits                     => convert_int(cur_css_interface_rec.tuit_benefits),
                      x_cont_parents                      => convert_int(cur_css_interface_rec.cont_parents),
                      x_cont_relatives                    => convert_int(cur_css_interface_rec.cont_relatives),
                      x_p_siblings_pre_tuit               => convert_int(cur_css_interface_rec.p_siblings_pre_tuit),
                      x_p_student_pre_tuit                => convert_int(cur_css_interface_rec.p_student_pre_tuit),
                      x_p_household_size                  => convert_int(cur_css_interface_rec.p_household_size),
                      x_p_number_in_college               => convert_int(cur_css_interface_rec.p_number_in_college),
                      x_p_parents_in_college              => convert_int(cur_css_interface_rec.p_parents_in_college),
                      x_p_marital_status                  => convert_int(cur_css_interface_rec.p_marital_status),
                      x_p_state_legal_residence           => cur_css_interface_rec.p_state_legal_residence,
                      x_p_natural_par_status              => convert_int(cur_css_interface_rec.p_natural_par_status),
                      x_p_child_supp_paid                 => convert_int(cur_css_interface_rec.p_child_supp_paid),
                      x_p_repay_ed_loans                  => convert_int(cur_css_interface_rec.p_repay_ed_loans),
                      x_p_med_dent_expenses               => convert_int(cur_css_interface_rec.p_med_dent_expenses),
                      x_p_tuit_paid_amount                => convert_int(cur_css_interface_rec.p_tuit_paid_amount),
                      x_p_tuit_paid_number                => convert_int(cur_css_interface_rec.p_tuit_paid_number),
                      x_p_exp_child_supp_paid             => convert_int(cur_css_interface_rec.p_exp_child_supp_paid),
                      x_p_exp_repay_ed_loans              => convert_int(cur_css_interface_rec.p_exp_repay_ed_loans),
                      x_p_exp_med_dent_expenses           => convert_int(cur_css_interface_rec.p_exp_med_dent_expenses),
                      x_p_exp_tuit_pd_amount              => convert_int(cur_css_interface_rec.p_exp_tuit_pd_amount),
                      x_p_exp_tuit_pd_number              => convert_int(cur_css_interface_rec.p_exp_tuit_pd_number),
                      x_p_cash_sav_check                  => convert_int(cur_css_interface_rec.p_cash_sav_check),
                      x_p_month_mortgage_pay              => convert_int(cur_css_interface_rec.p_month_mortgage_pay),
                      x_p_invest_value                    => convert_int(cur_css_interface_rec.p_invest_value),
                      x_p_invest_debt                     => convert_int(cur_css_interface_rec.p_invest_debt),
                      x_p_home_value                      => convert_int(cur_css_interface_rec.p_home_value),
                      x_p_home_debt                       => convert_int(cur_css_interface_rec.p_home_debt),
                      x_p_home_purch_price                => convert_int(cur_css_interface_rec.p_home_purch_price),
                      x_p_own_business_farm               => convert_int(cur_css_interface_rec.p_own_business_farm),
                      x_p_business_value                  => convert_int(cur_css_interface_rec.p_business_value),
                      x_p_business_debt                   => convert_int(cur_css_interface_rec.p_business_debt),
                      x_p_farm_value                      => convert_int(cur_css_interface_rec.p_farm_value),
                      x_p_farm_debt                       => convert_int(cur_css_interface_rec.p_farm_debt),
                      x_p_live_on_farm                    => convert_int(cur_css_interface_rec.p_live_on_farm),
                      x_p_oth_real_estate_value           => convert_int(cur_css_interface_rec.p_oth_real_estate_value),
                      x_p_oth_real_estate_debt            => convert_int(cur_css_interface_rec.p_oth_real_estate_debt),
                      x_p_oth_real_purch_price            => convert_int(cur_css_interface_rec.p_oth_real_purch_price),
                      x_p_siblings_assets                 => convert_int(cur_css_interface_rec.p_siblings_assets),
                      x_p_home_purch_year                 => convert_int(cur_css_interface_rec.p_home_purch_year),
                      x_p_oth_real_purch_year             => convert_int(cur_css_interface_rec.p_oth_real_purch_year),
                      x_p_prior_agi                       => convert_int(cur_css_interface_rec.p_prior_agi),
                      x_p_prior_us_tax_paid               => convert_int(cur_css_interface_rec.p_prior_us_tax_paid),
                      x_p_prior_item_deductions           => convert_int(cur_css_interface_rec.p_prior_item_deductions),
                      x_p_prior_other_untax_inc           => convert_int(cur_css_interface_rec.p_prior_other_untax_inc),
                      x_p_tax_figures                     => convert_int(cur_css_interface_rec.p_tax_figures),
                      x_p_number_exemptions               => convert_int(cur_css_interface_rec.p_number_exemptions),
                      x_p_adjusted_gross_inc              => convert_int(cur_css_interface_rec.p_adjusted_gross_inc),
                      x_p_wages_sal_tips                  => convert_int(cur_css_interface_rec.p_wages_sal_tips),
                      x_p_interest_income                 => convert_int(cur_css_interface_rec.p_interest_income),
                      x_p_dividend_income                 => convert_int( cur_css_interface_rec.p_dividend_income),
                      x_p_net_inc_bus_farm                => convert_int(cur_css_interface_rec.p_net_inc_bus_farm),
                      x_p_other_taxable_income            => convert_int(cur_css_interface_rec.p_other_taxable_income),
                      x_p_adj_to_income                   => convert_int(cur_css_interface_rec.p_adj_to_income),
                      x_p_us_tax_paid                     => convert_int(cur_css_interface_rec.p_us_tax_paid),
                      x_p_itemized_deductions             => convert_int(cur_css_interface_rec.p_itemized_deductions),
                      x_p_father_income_work              => convert_int(cur_css_interface_rec.p_father_income_work),
                      x_p_mother_income_work              => convert_int(cur_css_interface_rec.p_mother_income_work),
                      x_p_soc_sec_ben                     => convert_int(cur_css_interface_rec.p_soc_sec_ben),
                      x_p_welfare_tanf                    => convert_int(cur_css_interface_rec.p_welfare_tanf),
                      x_p_child_supp_rcvd                 => convert_int(cur_css_interface_rec.p_child_supp_rcvd),
                      x_p_ded_ira_keogh                   => convert_int(cur_css_interface_rec.p_ded_ira_keogh),
                      x_p_tax_defer_pens_savs             => convert_int(cur_css_interface_rec.p_tax_defer_pens_savs),
                      x_p_dep_care_med_spending           => convert_int(cur_css_interface_rec.p_dep_care_med_spending),
                      x_p_earned_income_credit            => convert_int(cur_css_interface_rec.p_earned_income_credit),
                      x_p_living_allow                    => convert_int(cur_css_interface_rec.p_living_allow),
                      x_p_tax_exmpt_int                   => convert_int(cur_css_interface_rec.p_tax_exmpt_int),
                      x_p_foreign_inc_excl                => convert_int(cur_css_interface_rec.p_foreign_inc_excl),
                      x_p_other_untax_inc                 => convert_int(cur_css_interface_rec.p_other_untax_inc),
                      x_p_hope_ll_credit                  => convert_int(cur_css_interface_rec.p_hope_ll_credit),
                      x_p_yr_separation                   => convert_int(cur_css_interface_rec.p_yr_separation),
                      x_p_yr_divorce                      => convert_int(cur_css_interface_rec.p_yr_divorce),
                      x_p_exp_father_inc                  => convert_int(cur_css_interface_rec.p_exp_father_inc),
                      x_p_exp_mother_inc                  => convert_int(cur_css_interface_rec.p_exp_mother_inc),
                      x_p_exp_other_tax_inc               => convert_int(cur_css_interface_rec.p_exp_other_tax_inc),
                      x_p_exp_other_untax_inc             => convert_int(cur_css_interface_rec.p_exp_other_untax_inc),
                      x_line_2_relation                   => convert_int(cur_css_interface_rec.line_2_relation),
                      x_line_2_attend_college             => convert_int(cur_css_interface_rec.line_2_attend_college),
                      x_line_3_relation                   => convert_int(cur_css_interface_rec.line_3_relation),
                      x_line_3_attend_college             => convert_int(cur_css_interface_rec.line_3_attend_college),
                      x_line_4_relation                   => convert_int(cur_css_interface_rec.line_4_relation),
                      x_line_4_attend_college             => convert_int(cur_css_interface_rec.line_4_attend_college),
                      x_line_5_relation                   => convert_int(cur_css_interface_rec.line_5_relation),
                      x_line_5_attend_college             => convert_int(cur_css_interface_rec.line_5_attend_college),
                      x_line_6_relation                   => convert_int(cur_css_interface_rec.line_6_relation),
                      x_line_6_attend_college             => convert_int(cur_css_interface_rec.line_6_attend_college),
                      x_line_7_relation                   => convert_int(cur_css_interface_rec.line_7_relation),
                      x_line_7_attend_college             => convert_int(cur_css_interface_rec.line_7_attend_college),
                      x_line_8_relation                   => convert_int(cur_css_interface_rec.line_8_relation),
                      x_line_8_attend_college             => convert_int(cur_css_interface_rec.line_8_attend_college),
                      x_p_age_father                      => convert_int(cur_css_interface_rec.p_age_father),
                      x_p_age_mother                      => convert_int(cur_css_interface_rec.p_age_mother),
                      x_p_div_sep_ind                     => convert_int(cur_css_interface_rec.p_div_sep_ind),
                      x_b_cont_non_custodial_par          => convert_int(cur_css_interface_rec.b_cont_non_custodial_par),
                      x_college_type_2                    => convert_int(cur_css_interface_rec.college_type_2),
                      x_college_type_3                    => convert_int(cur_css_interface_rec.college_type_3),
                      x_college_type_4                    => convert_int(cur_css_interface_rec.college_type_4),
                      x_college_type_5                    => convert_int(cur_css_interface_rec.college_type_5),
                      x_college_type_6                    => convert_int(cur_css_interface_rec.college_type_6),
                      x_college_type_7                    => convert_int(cur_css_interface_rec.college_type_7),
                      x_college_type_8                    => convert_int(cur_css_interface_rec.college_type_8),
                      x_school_code_1                     => cur_css_interface_rec.school_code_1,
                      x_housing_code_1                    => convert_int(cur_css_interface_rec.housing_code_1),
                      x_school_code_2                     => cur_css_interface_rec.school_code_2,
                      x_housing_code_2                    => convert_int(cur_css_interface_rec.housing_code_2),
                      x_school_code_3                     => cur_css_interface_rec.school_code_3,
                      x_housing_code_3                    => convert_int(cur_css_interface_rec.housing_code_3),
                      x_school_code_4                     => cur_css_interface_rec.school_code_4,
                      x_housing_code_4                    => convert_int(cur_css_interface_rec.housing_code_4),
                      x_school_code_5                     => cur_css_interface_rec.school_code_5,
                      x_housing_code_5                    => convert_int(cur_css_interface_rec.housing_code_5),
                      x_school_code_6                     => cur_css_interface_rec.school_code_6,
                      x_housing_code_6                    => convert_int(cur_css_interface_rec.housing_code_6),
                      x_school_code_7                     => cur_css_interface_rec.school_code_7,
                      x_housing_code_7                    => convert_int(cur_css_interface_rec.housing_code_7),
                      x_school_code_8                     => cur_css_interface_rec.school_code_8,
                      x_housing_code_8                    => convert_int(cur_css_interface_rec.housing_code_8),
                      x_school_code_9                     => cur_css_interface_rec.school_code_9,
                      x_housing_code_9                    => convert_int(cur_css_interface_rec.housing_code_9),
                      x_school_code_10                    => cur_css_interface_rec.school_code_10,
                      x_housing_code_10                   => convert_int(cur_css_interface_rec.housing_code_10),
                      x_additional_school_code_1          => cur_css_interface_rec.additional_school_code_1,
                      x_additional_school_code_2          => cur_css_interface_rec.additional_school_code_2,
                      x_additional_school_code_3          => cur_css_interface_rec.additional_school_code_3,
                      x_additional_school_code_4          => cur_css_interface_rec.additional_school_code_4,
                      x_additional_school_code_5          => cur_css_interface_rec.additional_school_code_5,
                      x_additional_school_code_6          => cur_css_interface_rec.additional_school_code_6,
                      x_additional_school_code_7          => cur_css_interface_rec.additional_school_code_7,
                      x_additional_school_code_8          => cur_css_interface_rec.additional_school_code_8,
                      x_additional_school_code_9          => cur_css_interface_rec.additional_school_code_9,
                      x_additional_school_code_10         => cur_css_interface_rec.additional_school_code_10,
                      x_explanation_spec_circum           => cur_css_interface_rec.explanation_spec_circum,
                      x_signature_student                 => convert_int(cur_css_interface_rec.signature_student),
                      x_signature_spouse                  => convert_int(cur_css_interface_rec.signature_spouse),
                      x_signature_father                  => convert_int(cur_css_interface_rec.signature_father),
                      x_signature_mother                  => convert_int(cur_css_interface_rec.signature_mother),
                      x_month_day_completed               => cur_css_interface_rec.month_day_completed,
                      x_year_completed                    => convert_int(cur_css_interface_rec.year_completed),
                      x_age_line_2                        => convert_int(cur_css_interface_rec.age_line_2),
                      x_age_line_3                        => convert_int(cur_css_interface_rec.age_line_3),
                      x_age_line_4                        => convert_int(cur_css_interface_rec.age_line_4),
                      x_age_line_5                        => convert_int(cur_css_interface_rec.age_line_5),
                      x_age_line_6                        => convert_int(cur_css_interface_rec.age_line_6),
                      x_age_line_7                        => convert_int(cur_css_interface_rec.age_line_7),
                      x_age_line_8                        => convert_int(cur_css_interface_rec.age_line_8),
                      x_a_online_signature                => convert_int(cur_css_interface_rec.a_online_signature),
                      x_question_1_number                 => cur_css_interface_rec.question_1_number,
                      x_question_1_size                   => cur_css_interface_rec.question_1_size,
                      x_question_1_answer                 => convert_int(cur_css_interface_rec.question_1_answer),
                      x_question_2_number                 => cur_css_interface_rec.question_2_number,
                      x_question_2_size                   => cur_css_interface_rec.question_2_size,
                      x_question_2_answer                 => convert_int(cur_css_interface_rec.question_2_answer),
                      x_question_3_number                 => cur_css_interface_rec.question_3_number,
                      x_question_3_size                   => cur_css_interface_rec.question_3_size,
                      x_question_3_answer                 => convert_int(cur_css_interface_rec.question_3_answer),
                      x_question_4_number                 => cur_css_interface_rec.question_4_number,
                      x_question_4_size                   => cur_css_interface_rec.question_4_size,
                      x_question_4_answer                 => convert_int(cur_css_interface_rec.question_4_answer),
                      x_question_5_number                 => cur_css_interface_rec.question_5_number,
                      x_question_5_size                   => cur_css_interface_rec.question_5_size,
                      x_question_5_answer                 => convert_int(cur_css_interface_rec.question_5_answer),
                      x_question_6_number                 => cur_css_interface_rec.question_6_number,
                      x_question_6_size                   => cur_css_interface_rec.question_6_size,
                      x_question_6_answer                 => convert_int(cur_css_interface_rec.question_6_answer),
                      x_question_7_number                 => cur_css_interface_rec.question_7_number,
                      x_question_7_size                   => cur_css_interface_rec.question_7_size,
                      x_question_7_answer                 => convert_int(cur_css_interface_rec.question_7_answer),
                      x_question_8_number                 => cur_css_interface_rec.question_8_number,
                      x_question_8_size                   => cur_css_interface_rec.question_8_size,
                      x_question_8_answer                 => convert_int(cur_css_interface_rec.question_8_answer),
                      x_question_9_number                 => cur_css_interface_rec.question_9_number,
                      x_question_9_size                   => cur_css_interface_rec.question_9_size,
                      x_question_9_answer                 => convert_int(cur_css_interface_rec.question_9_answer),
                      x_question_10_number                => cur_css_interface_rec.question_10_number,
                      x_question_10_size                  => cur_css_interface_rec.question_10_size,
                      x_question_10_answer                => convert_int(cur_css_interface_rec.question_10_answer),
                      x_question_11_number                => cur_css_interface_rec.question_11_number,
                      x_question_11_size                  => cur_css_interface_rec.question_11_size,
                      x_question_11_answer                => convert_int(cur_css_interface_rec.question_11_answer),
                      x_question_12_number                => cur_css_interface_rec.question_12_number,
                      x_question_12_size                  => cur_css_interface_rec.question_12_size,
                      x_question_12_answer                => convert_int(cur_css_interface_rec.question_12_answer),
                      x_question_13_number                => cur_css_interface_rec.question_13_number,
                      x_question_13_size                  => cur_css_interface_rec.question_13_size,
                      x_question_13_answer                => convert_int(cur_css_interface_rec.question_13_answer),
                      x_question_14_number                => cur_css_interface_rec.question_14_number,
                      x_question_14_size                  => cur_css_interface_rec.question_14_size,
                      x_question_14_answer                => convert_int(cur_css_interface_rec.question_14_answer),
                      x_question_15_number                => cur_css_interface_rec.question_15_number,
                      x_question_15_size                  => cur_css_interface_rec.question_15_size,
                      x_question_15_answer                => convert_int(cur_css_interface_rec.question_15_answer),
                      x_question_16_number                => cur_css_interface_rec.question_16_number,
                      x_question_16_size                  => cur_css_interface_rec.question_16_size,
                      x_question_16_answer                => convert_int(cur_css_interface_rec.question_16_answer),
                      x_question_17_number                => cur_css_interface_rec.question_17_number,
                      x_question_17_size                  => cur_css_interface_rec.question_17_size,
                      x_question_17_answer                => convert_int(cur_css_interface_rec.question_17_answer),
                      x_question_18_number                => cur_css_interface_rec.question_18_number,
                      x_question_18_size                  => cur_css_interface_rec.question_18_size,
                      x_question_18_answer                => convert_int(cur_css_interface_rec.question_18_answer),
                      x_question_19_number                => cur_css_interface_rec.question_19_number,
                      x_question_19_size                  => cur_css_interface_rec.question_19_size,
                      x_question_19_answer                => convert_int(cur_css_interface_rec.question_19_answer),
                      x_question_20_number                => cur_css_interface_rec.question_20_number,
                      x_question_20_size                  => cur_css_interface_rec.question_20_size,
                      x_question_20_answer                => convert_int(cur_css_interface_rec.question_20_answer),
                      x_question_21_number                => cur_css_interface_rec.question_21_number,
                      x_question_21_size                  => cur_css_interface_rec.question_21_size,
                      x_question_21_answer                => convert_int(cur_css_interface_rec.question_21_answer),
                      x_question_22_number                => cur_css_interface_rec.question_22_number,
                      x_question_22_size                  => cur_css_interface_rec.question_22_size,
                      x_question_22_answer                => convert_int(cur_css_interface_rec.question_22_answer),
                      x_question_23_number                => cur_css_interface_rec.question_23_number,
                      x_question_23_size                  => cur_css_interface_rec.question_23_size,
                      x_question_23_answer                => convert_int(cur_css_interface_rec.question_23_answer),
                      x_question_24_number                => cur_css_interface_rec.question_24_number,
                      x_question_24_size                  => cur_css_interface_rec.question_24_size,
                      x_question_24_answer                => convert_int(cur_css_interface_rec.question_24_answer),
                      x_question_25_number                => cur_css_interface_rec.question_25_number,
                      x_question_25_size                  => cur_css_interface_rec.question_25_size,
                      x_question_25_answer                => convert_int(cur_css_interface_rec.question_25_answer),
                      x_question_26_number                => cur_css_interface_rec.question_26_number,
                      x_question_26_size                  => cur_css_interface_rec.question_26_size,
                      x_question_26_answer                => convert_int(cur_css_interface_rec.question_26_answer),
                      x_question_27_number                => cur_css_interface_rec.question_27_number,
                      x_question_27_size                  => cur_css_interface_rec.question_27_size,
                      x_question_27_answer                => convert_int(cur_css_interface_rec.question_27_answer),
                      x_question_28_number                => cur_css_interface_rec.question_28_number,
                      x_question_28_size                  => cur_css_interface_rec.question_28_size,
                      x_question_28_answer                => convert_int(cur_css_interface_rec.question_28_answer),
                      x_question_29_number                => cur_css_interface_rec.question_29_number,
                      x_question_29_size                  => cur_css_interface_rec.question_29_size,
                      x_question_29_answer                => convert_int(cur_css_interface_rec.question_29_answer),
                      x_question_30_number                => cur_css_interface_rec.question_30_number,
                      x_questions_30_size                 => cur_css_interface_rec.questions_30_size,
                      x_question_30_answer                => convert_int(cur_css_interface_rec.question_30_answer),
                      x_legacy_record_flag                => NULL,
                      x_coa_duration_efc_amt            => NULL,
                      x_coa_duration_num                => NULL,
                      x_p_soc_sec_ben_student_amt         => convert_int(cur_css_interface_rec.p_soc_sec_ben_student_amt),
                      x_p_tuit_fee_deduct_amt             => convert_int(cur_css_interface_rec.p_tuit_fee_deduct_amt),
                      x_stu_lives_with_num                => cur_css_interface_rec.stu_lives_with_num,
                      x_stu_most_support_from_num         => cur_css_interface_rec.stu_most_support_from_num,
                      x_location_computer_num             => cur_css_interface_rec.location_computer_num
                      );

                END LOOP;

        EXCEPTION
          WHEN others THEN
          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_profile_matched.exception','The exception is : ' || SQLERRM );
          END IF;
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.create_profile_matched:');
          IGS_GE_MSG_STACK.ADD;
          fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
          log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.create_profile_matched:'||SQLERRM);
          app_exception.raise_exception;
  END create_profile_matched;


  FUNCTION is_fa_base_record_present(pn_person_id        igf_ap_match_details.person_id%TYPE,
                                           pn_cal_type         igf_ap_person_match_all.ci_cal_type%TYPE,
                                           pn_sequence_number  igf_ap_person_match_all.ci_sequence_number%TYPE,
                                           pn_base_id     OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE
                                           )RETURN BOOLEAN  IS

  /*
  ||  Created By : Meghana
  ||  Created On : 11-jun-2001
  ||  Purpose : To check whether the newly imported student has any matched record present in the FA_BASE_REC table in th egiven award year.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    -- Get all the records from base table which are having same person id and the given cal_type and sequence_number
    CURSOR cur_fa_base_record (pn_person_id NUMBER,
                               pn_cal_type VARCHAR2,
             pn_sequence_number NUMBER
             ) IS
      SELECT ifb.base_id
      FROM   igf_ap_fa_base_rec ifb
      WHERE  ifb.person_id = pn_person_id
      AND    ifb.ci_sequence_number = pn_sequence_number
      AND    ifb.ci_cal_type = pn_cal_type;

  BEGIN

    -- If  a base record is found for the given student then return 'TRUE' else return 'FALSE'
    FOR cur_fa_base_record_rec IN cur_fa_base_record ( pn_person_id, pn_cal_type, pn_sequence_number)
    LOOP
      pn_base_id := cur_fa_base_record_rec.base_id;
      RETURN TRUE;
    END LOOP;
    RETURN FALSE;
  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.is_fa_base_record_present.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.is_fa_base_record_present:');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
       log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.is_fa_base_record_present:'||SQLERRM);
      app_exception.raise_exception;
  END is_fa_base_record_present;

 PROCEDURE update_css_interface(pn_css_id          igf_ap_css_interface_all.css_id%TYPE,
                                pv_record_status   igf_ap_css_interface_all.record_status%TYPE,
                                pv_match_code      VARCHAR2
                                       )   IS

  /*
  ||  Created By : Meghana
  ||  Created On : 12-JUN-2001
  ||  Purpose : Update the record status to 'Matched / Unmatched' for all the successful/ non successfull persons.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_css_interface ( pn_css_id NUMBER) IS
      SELECT ROWID, iii.*
      FROM   igf_ap_css_interface_all iii
      WHERE  css_id = pn_css_id;

    lv_rowid  VARCHAR2(30);
    ln_org_id     NUMBER ;
    retcode NUMBER;
    errbuf    VARCHAR2(300);

  BEGIN

    -- Update record _status
    FOR cur_css_interface_rec IN cur_css_interface ( pn_css_id)
    LOOP

        igf_ap_css_interface_pkg.update_row (
                        X_Mode                              => 'R',
                        x_rowid                             => cur_css_interface_rec.ROWID,
                        x_css_id                            => cur_css_interface_rec.css_id,
                        x_record_status                     => pv_record_status ,
                        x_college_code                      => cur_css_interface_rec.college_code,
                        x_academic_year                     => cur_css_interface_rec.academic_year,
                        x_stu_record_type                   => cur_css_interface_rec.stu_record_type,
                        x_css_id_number                     => cur_css_interface_rec.css_id_number,
                        x_registration_receipt_date         => cur_css_interface_rec.registration_receipt_date,
                        x_registration_type                 => cur_css_interface_rec.registration_type,
                        x_application_receipt_date          => cur_css_interface_rec.application_receipt_date,
                        x_application_type                  => cur_css_interface_rec.application_type,
                        x_original_fnar_compute             => cur_css_interface_rec.original_fnar_compute,
                        x_revision_fnar_compute_date        => cur_css_interface_rec.revision_fnar_compute_date,
                        x_electronic_extract_date           => cur_css_interface_rec.electronic_extract_date,
                        x_institutional_reporting_type      => cur_css_interface_rec.institutional_reporting_type,
                        x_asr_receipt_date                  => cur_css_interface_rec.asr_receipt_date,
                        x_last_name                         => cur_css_interface_rec.last_name,
                        x_first_name                        => cur_css_interface_rec.first_name,
                        x_middle_initial                    => cur_css_interface_rec.middle_initial,
                        x_address_number_and_street         => cur_css_interface_rec.address_number_and_street,
                        x_city                              => cur_css_interface_rec.city,
                        x_state_mailing                     => cur_css_interface_rec.state_mailing,
                        x_zip_code                          => cur_css_interface_rec.zip_code,
                        x_s_telephone_number                => cur_css_interface_rec.s_telephone_number,
                        x_s_title                           => cur_css_interface_rec.s_title,
                        x_date_of_birth                     => cur_css_interface_rec.date_of_birth,
                        x_social_security_number            => cur_css_interface_rec.social_security_number,
                        x_state_legal_residence             => cur_css_interface_rec.state_legal_residence,
                        x_foreign_address_indicator         => cur_css_interface_rec.foreign_address_indicator,
                        x_foreign_postal_code               => cur_css_interface_rec.foreign_postal_code,
                        x_country                           => cur_css_interface_rec.country,
                        x_financial_aid_status              => cur_css_interface_rec.financial_aid_status,
                        x_year_in_college                   => cur_css_interface_rec.year_in_college,
                        x_marital_status                    => cur_css_interface_rec.marital_status,
                        x_ward_court                        => cur_css_interface_rec.ward_court,
                        x_legal_dependents_other            => cur_css_interface_rec.legal_dependents_other,
                        x_household_size                    => cur_css_interface_rec.household_size,
                        x_number_in_college                 => cur_css_interface_rec.number_in_college,
                        x_citizenship_status                => cur_css_interface_rec.citizenship_status,
                        x_citizenship_country               => cur_css_interface_rec.citizenship_country,
                        x_visa_classification               => cur_css_interface_rec.visa_classification,
                        x_tax_figures                       => cur_css_interface_rec.tax_figures,
                        x_number_exemptions                 => cur_css_interface_rec.number_exemptions,
                        x_adjusted_gross_inc                => cur_css_interface_rec.adjusted_gross_inc,
                        x_us_tax_paid                       => cur_css_interface_rec.us_tax_paid,
                        x_itemized_deductions               => cur_css_interface_rec.itemized_deductions,
                        x_stu_income_work                   => cur_css_interface_rec.stu_income_work,
                        x_spouse_income_work                => cur_css_interface_rec.spouse_income_work,
                        x_divid_int_inc                     => cur_css_interface_rec.divid_int_inc,
                        x_soc_sec_benefits                  => cur_css_interface_rec.soc_sec_benefits,
                        x_welfare_tanf                      => cur_css_interface_rec.welfare_tanf,
                        x_child_supp_rcvd                   => cur_css_interface_rec.child_supp_rcvd,
                        x_earned_income_credit              => cur_css_interface_rec.earned_income_credit,
                        x_other_untax_income                => cur_css_interface_rec.other_untax_income,
                        x_tax_stu_aid                       => cur_css_interface_rec.tax_stu_aid,
                        x_cash_sav_check                    => cur_css_interface_rec.cash_sav_check,
                        x_ira_keogh                         => cur_css_interface_rec.ira_keogh,
                        x_invest_value                      => cur_css_interface_rec.invest_value,
                        x_invest_debt                       => cur_css_interface_rec.invest_debt,
                        x_home_value                        => cur_css_interface_rec.home_value,
                        x_home_debt                         => cur_css_interface_rec.home_debt,
                        x_oth_real_value                    => cur_css_interface_rec.oth_real_value,
                        x_oth_real_debt                     => cur_css_interface_rec.oth_real_debt,
                        x_bus_farm_value                    => cur_css_interface_rec.bus_farm_value,
                        x_bus_farm_debt                     => cur_css_interface_rec.bus_farm_debt,
                        x_live_on_farm                      => cur_css_interface_rec.live_on_farm,
                        x_home_purch_price                  => cur_css_interface_rec.home_purch_price,
                        x_hope_ll_credit                    => cur_css_interface_rec.hope_ll_credit,
                        x_home_purch_year                   => cur_css_interface_rec.home_purch_year,
                        x_trust_amount                      => cur_css_interface_rec.trust_amount,
                        x_trust_avail                       => cur_css_interface_rec.trust_avail,
                        x_trust_estab                       => cur_css_interface_rec.trust_estab,
                        x_child_support_paid                => cur_css_interface_rec.child_support_paid,
                        x_med_dent_expenses                 => cur_css_interface_rec.med_dent_expenses,
                        x_vet_us                            => cur_css_interface_rec.vet_us,
                        x_vet_ben_amount                    => cur_css_interface_rec.vet_ben_amount,
                        x_vet_ben_months                    => cur_css_interface_rec.vet_ben_months,
                        x_stu_summer_wages                  => cur_css_interface_rec.stu_summer_wages,
                        x_stu_school_yr_wages               => cur_css_interface_rec.stu_school_yr_wages,
                        x_spouse_summer_wages               => cur_css_interface_rec.spouse_summer_wages,
                        x_spouse_school_yr_wages            => cur_css_interface_rec.spouse_school_yr_wages,
                        x_summer_other_tax_inc              => cur_css_interface_rec.summer_other_tax_inc,
                        x_school_yr_other_tax_inc           => cur_css_interface_rec.school_yr_other_tax_inc,
                        x_summer_untax_inc                  => cur_css_interface_rec.summer_untax_inc,
                        x_school_yr_untax_inc               => cur_css_interface_rec.school_yr_untax_inc,
                        x_grants_schol_etc                  => cur_css_interface_rec.grants_schol_etc,
                        x_tuit_benefits                     => cur_css_interface_rec.tuit_benefits,
                        x_cont_parents                      => cur_css_interface_rec.cont_parents,
                        x_cont_relatives                    => cur_css_interface_rec.cont_relatives,
                        x_p_siblings_pre_tuit               => cur_css_interface_rec.p_siblings_pre_tuit,
                        x_p_student_pre_tuit                => cur_css_interface_rec.p_student_pre_tuit,
                        x_p_household_size                  => cur_css_interface_rec.p_household_size,
                        x_p_number_in_college               => cur_css_interface_rec.p_number_in_college,
                        x_p_parents_in_college              => cur_css_interface_rec.p_parents_in_college,
                        x_p_marital_status                  => cur_css_interface_rec.p_marital_status,
                        x_p_state_legal_residence           => cur_css_interface_rec.p_state_legal_residence,
                        x_p_natural_par_status              => cur_css_interface_rec.p_natural_par_status,
                        x_p_child_supp_paid                 => cur_css_interface_rec.p_child_supp_paid,
                        x_p_repay_ed_loans                  => cur_css_interface_rec.p_repay_ed_loans,
                        x_p_med_dent_expenses               => cur_css_interface_rec.p_med_dent_expenses,
                        x_p_tuit_paid_amount                => cur_css_interface_rec.p_tuit_paid_amount,
                        x_p_tuit_paid_number                => cur_css_interface_rec.p_tuit_paid_number,
                        x_p_exp_child_supp_paid             => cur_css_interface_rec.p_exp_child_supp_paid,
                        x_p_exp_repay_ed_loans              => cur_css_interface_rec.p_exp_repay_ed_loans,
                        x_p_exp_med_dent_expenses           => cur_css_interface_rec.p_exp_med_dent_expenses,
                        x_p_exp_tuit_pd_amount              => cur_css_interface_rec.p_exp_tuit_pd_amount,
                        x_p_exp_tuit_pd_number              => cur_css_interface_rec.p_exp_tuit_pd_number,
                        x_p_cash_sav_check                  => cur_css_interface_rec.p_cash_sav_check,
                        x_p_month_mortgage_pay              => cur_css_interface_rec.p_month_mortgage_pay,
                        x_p_invest_value                    => cur_css_interface_rec.p_invest_value,
                        x_p_invest_debt                     => cur_css_interface_rec.p_invest_debt,
                        x_p_home_value                      => cur_css_interface_rec.p_home_value,
                        x_p_home_debt                       => cur_css_interface_rec.p_home_debt,
                        x_p_home_purch_price                => cur_css_interface_rec.p_home_purch_price,
                        x_p_own_business_farm               => cur_css_interface_rec.p_own_business_farm,
                        x_p_business_value                  => cur_css_interface_rec.p_business_value,
                        x_p_business_debt                   => cur_css_interface_rec.p_business_debt,
                        x_p_farm_value                      => cur_css_interface_rec.p_farm_value,
                        x_p_farm_debt                       => cur_css_interface_rec.p_farm_debt,
                        x_p_live_on_farm                    => cur_css_interface_rec.p_live_on_farm,
                        x_p_oth_real_estate_value           => cur_css_interface_rec.p_oth_real_estate_value,
                        x_p_oth_real_estate_debt            => cur_css_interface_rec.p_oth_real_estate_debt,
                        x_p_oth_real_purch_price            => cur_css_interface_rec.p_oth_real_purch_price,
                        x_p_siblings_assets                 => cur_css_interface_rec.p_siblings_assets,
                        x_p_home_purch_year                 => cur_css_interface_rec.p_home_purch_year,
                        x_p_oth_real_purch_year             => cur_css_interface_rec.p_oth_real_purch_year,
                        x_p_prior_agi                       => cur_css_interface_rec.p_prior_agi,
                        x_p_prior_us_tax_paid               => cur_css_interface_rec.p_prior_us_tax_paid,
                        x_p_prior_item_deductions           => cur_css_interface_rec.p_prior_item_deductions,
                        x_p_prior_other_untax_inc           => cur_css_interface_rec.p_prior_other_untax_inc,
                        x_p_tax_figures                     => cur_css_interface_rec.p_tax_figures,
                        x_p_number_exemptions               => cur_css_interface_rec.p_number_exemptions,
                        x_p_adjusted_gross_inc              => cur_css_interface_rec.p_adjusted_gross_inc,
                        x_p_wages_sal_tips                  => cur_css_interface_rec.p_wages_sal_tips,
                        x_p_interest_income                 => cur_css_interface_rec.p_interest_income,
                        x_p_dividend_income                 => cur_css_interface_rec.p_dividend_income,
                        x_p_net_inc_bus_farm                => cur_css_interface_rec.p_net_inc_bus_farm,
                        x_p_other_taxable_income            => cur_css_interface_rec.p_other_taxable_income,
                        x_p_adj_to_income                   => cur_css_interface_rec.p_adj_to_income,
                        x_p_us_tax_paid                     => cur_css_interface_rec.p_us_tax_paid,
                        x_p_itemized_deductions             => cur_css_interface_rec.p_itemized_deductions,
                        x_p_father_income_work              => cur_css_interface_rec.p_father_income_work,
                        x_p_mother_income_work              => cur_css_interface_rec.p_mother_income_work,
                        x_p_soc_sec_ben                     => cur_css_interface_rec.p_soc_sec_ben,
                        x_p_welfare_tanf                    => cur_css_interface_rec.p_welfare_tanf,
                        x_p_child_supp_rcvd                 => cur_css_interface_rec.p_child_supp_rcvd,
                        x_p_ded_ira_keogh                   => cur_css_interface_rec.p_ded_ira_keogh,
                        x_p_tax_defer_pens_savs             => cur_css_interface_rec.p_tax_defer_pens_savs,
                        x_p_dep_care_med_spending           => cur_css_interface_rec.p_dep_care_med_spending,
                        x_p_earned_income_credit            => cur_css_interface_rec.p_earned_income_credit,
                        x_p_living_allow                    => cur_css_interface_rec.p_living_allow,
                        x_p_tax_exmpt_int                   => cur_css_interface_rec.p_tax_exmpt_int,
                        x_p_foreign_inc_excl                => cur_css_interface_rec.p_foreign_inc_excl,
                        x_p_other_untax_inc                 => cur_css_interface_rec.p_other_untax_inc,
                        x_p_hope_ll_credit                  => cur_css_interface_rec.p_hope_ll_credit,
                        x_p_yr_separation                   => cur_css_interface_rec.p_yr_separation,
                        x_p_yr_divorce                      => cur_css_interface_rec.p_yr_divorce,
                        x_p_exp_father_inc                  => cur_css_interface_rec.p_exp_father_inc,
                        x_p_exp_mother_inc                  => cur_css_interface_rec.p_exp_mother_inc,
                        x_p_exp_other_tax_inc               => cur_css_interface_rec.p_exp_other_tax_inc,
                        x_p_exp_other_untax_inc             => cur_css_interface_rec.p_exp_other_untax_inc,
                        x_line_2_relation                   => cur_css_interface_rec.line_2_relation,
                        x_line_2_attend_college             => cur_css_interface_rec.line_2_attend_college,
                        x_line_3_relation                   => cur_css_interface_rec.line_3_relation,
                        x_line_3_attend_college             => cur_css_interface_rec.line_3_attend_college,
                        x_line_4_relation                   => cur_css_interface_rec.line_4_relation,
                        x_line_4_attend_college             => cur_css_interface_rec.line_4_attend_college,
                        x_line_5_relation                   => cur_css_interface_rec.line_5_relation,
                        x_line_5_attend_college             => cur_css_interface_rec.line_5_attend_college,
                        x_line_6_relation                   => cur_css_interface_rec.line_6_relation,
                        x_line_6_attend_college             => cur_css_interface_rec.line_6_attend_college,
                        x_line_7_relation                   => cur_css_interface_rec.line_7_relation,
                        x_line_7_attend_college             => cur_css_interface_rec.line_7_attend_college,
                        x_line_8_relation                   => cur_css_interface_rec.line_8_relation,
                        x_line_8_attend_college             => cur_css_interface_rec.line_8_attend_college,
                        x_p_age_father                      => cur_css_interface_rec.p_age_father,
                        x_p_age_mother                      => cur_css_interface_rec.p_age_mother,
                        x_p_div_sep_ind                     => cur_css_interface_rec.p_div_sep_ind,
                        x_b_cont_non_custodial_par          => cur_css_interface_rec.b_cont_non_custodial_par,
                        x_college_type_2                    => cur_css_interface_rec.college_type_2,
                        x_college_type_3                    => cur_css_interface_rec.college_type_3,
                        x_college_type_4                    => cur_css_interface_rec.college_type_4,
                        x_college_type_5                    => cur_css_interface_rec.college_type_5,
                        x_college_type_6                    => cur_css_interface_rec.college_type_6,
                        x_college_type_7                    => cur_css_interface_rec.college_type_7,
                        x_college_type_8                    => cur_css_interface_rec.college_type_8,
                        x_school_code_1                     => cur_css_interface_rec.school_code_1,
                        x_housing_code_1                    => cur_css_interface_rec.housing_code_1,
                        x_school_code_2                     => cur_css_interface_rec.school_code_2,
                        x_housing_code_2                    => cur_css_interface_rec.housing_code_2,
                        x_school_code_3                     => cur_css_interface_rec.school_code_3,
                        x_housing_code_3                    => cur_css_interface_rec.housing_code_3,
                        x_school_code_4                     => cur_css_interface_rec.school_code_4,
                        x_housing_code_4                    => cur_css_interface_rec.housing_code_4,
                        x_school_code_5                     => cur_css_interface_rec.school_code_5,
                        x_housing_code_5                    => cur_css_interface_rec.housing_code_5,
                        x_school_code_6                     => cur_css_interface_rec.school_code_6,
                        x_housing_code_6                    => cur_css_interface_rec.housing_code_6,
                        x_school_code_7                     => cur_css_interface_rec.school_code_7,
                        x_housing_code_7                    => cur_css_interface_rec.housing_code_7,
                        x_school_code_8                     => cur_css_interface_rec.school_code_8,
                        x_housing_code_8                    => cur_css_interface_rec.housing_code_8,
                        x_school_code_9                     => cur_css_interface_rec.school_code_9,
                        x_housing_code_9                    => cur_css_interface_rec.housing_code_9,
                        x_school_code_10                    => cur_css_interface_rec.school_code_10,
                        x_housing_code_10                   => cur_css_interface_rec.housing_code_10,
                        x_additional_school_code_1          => cur_css_interface_rec.additional_school_code_1,
                        x_additional_school_code_2          => cur_css_interface_rec.additional_school_code_2,
                        x_additional_school_code_3          => cur_css_interface_rec.additional_school_code_3,
                        x_additional_school_code_4          => cur_css_interface_rec.additional_school_code_4,
                        x_additional_school_code_5          => cur_css_interface_rec.additional_school_code_5,
                        x_additional_school_code_6          => cur_css_interface_rec.additional_school_code_6,
                        x_additional_school_code_7          => cur_css_interface_rec.additional_school_code_7,
                        x_additional_school_code_8          => cur_css_interface_rec.additional_school_code_8,
                        x_additional_school_code_9          => cur_css_interface_rec.additional_school_code_9,
                        x_additional_school_code_10         => cur_css_interface_rec.additional_school_code_10,
                        x_explanation_spec_circum           => cur_css_interface_rec.explanation_spec_circum,
                        x_signature_student                 => cur_css_interface_rec.signature_student,
                        x_signature_spouse                  => cur_css_interface_rec.signature_spouse,
                        x_signature_father                  => cur_css_interface_rec.signature_father,
                        x_signature_mother                  => cur_css_interface_rec.signature_mother,
                        x_month_day_completed               => cur_css_interface_rec.month_day_completed,
                        x_year_completed                    => cur_css_interface_rec.year_completed,
                        x_age_line_2                        => cur_css_interface_rec.age_line_2,
                        x_age_line_3                        => cur_css_interface_rec.age_line_3,
                        x_age_line_4                        => cur_css_interface_rec.age_line_4,
                        x_age_line_5                        => cur_css_interface_rec.age_line_5,
                        x_age_line_6                        => cur_css_interface_rec.age_line_6,
                        x_age_line_7                        => cur_css_interface_rec.age_line_7,
                        x_age_line_8                        => cur_css_interface_rec.age_line_8,
                        x_a_online_signature                => cur_css_interface_rec.a_online_signature,
                        x_question_1_number                 => cur_css_interface_rec.question_1_number,
                        x_question_1_size                   => cur_css_interface_rec.question_1_size,
                        x_question_1_answer                 => cur_css_interface_rec.question_1_answer,
                        x_question_2_number                 => cur_css_interface_rec.question_2_number,
                        x_question_2_size                   => cur_css_interface_rec.question_2_size,
                        x_question_2_answer                 => cur_css_interface_rec.question_2_answer,
                        x_question_3_number                 => cur_css_interface_rec.question_3_number,
                        x_question_3_size                   => cur_css_interface_rec.question_3_size,
                        x_question_3_answer                 => cur_css_interface_rec.question_3_answer,
                        x_question_4_number                 => cur_css_interface_rec.question_4_number,
                        x_question_4_size                   => cur_css_interface_rec.question_4_size,
                        x_question_4_answer                 => cur_css_interface_rec.question_4_answer,
                        x_question_5_number                 => cur_css_interface_rec.question_5_number,
                        x_question_5_size                   => cur_css_interface_rec.question_5_size,
                        x_question_5_answer                 => cur_css_interface_rec.question_5_answer,
                        x_question_6_number                 => cur_css_interface_rec.question_6_number,
                        x_question_6_size                   => cur_css_interface_rec.question_6_size,
                        x_question_6_answer                 => cur_css_interface_rec.question_6_answer,
                        x_question_7_number                 => cur_css_interface_rec.question_7_number,
                        x_question_7_size                   => cur_css_interface_rec.question_7_size,
                        x_question_7_answer                 => cur_css_interface_rec.question_7_answer,
                        x_question_8_number                 => cur_css_interface_rec.question_8_number,
                        x_question_8_size                   => cur_css_interface_rec.question_8_size,
                        x_question_8_answer                 => cur_css_interface_rec.question_8_answer,
                        x_question_9_number                 => cur_css_interface_rec.question_9_number,
                        x_question_9_size                   => cur_css_interface_rec.question_9_size,
                        x_question_9_answer                 => cur_css_interface_rec.question_9_answer,
                        x_question_10_number                => cur_css_interface_rec.question_10_number,
                        x_question_10_size                  => cur_css_interface_rec.question_10_size,
                        x_question_10_answer                => cur_css_interface_rec.question_10_answer,
                        x_question_11_number                => cur_css_interface_rec.question_11_number,
                        x_question_11_size                  => cur_css_interface_rec.question_11_size,
                        x_question_11_answer                => cur_css_interface_rec.question_11_answer,
                        x_question_12_number                => cur_css_interface_rec.question_12_number,
                        x_question_12_size                  => cur_css_interface_rec.question_12_size,
                        x_question_12_answer                => cur_css_interface_rec.question_12_answer,
                        x_question_13_number                => cur_css_interface_rec.question_13_number,
                        x_question_13_size                  => cur_css_interface_rec.question_13_size,
                        x_question_13_answer                => cur_css_interface_rec.question_13_answer,
                        x_question_14_number                => cur_css_interface_rec.question_14_number,
                        x_question_14_size                  => cur_css_interface_rec.question_14_size,
                        x_question_14_answer                => cur_css_interface_rec.question_14_answer,
                        x_question_15_number                => cur_css_interface_rec.question_15_number,
                        x_question_15_size                  => cur_css_interface_rec.question_15_size,
                        x_question_15_answer                => cur_css_interface_rec.question_15_answer,
                        x_question_16_number                => cur_css_interface_rec.question_16_number,
                        x_question_16_size                  => cur_css_interface_rec.question_16_size,
                        x_question_16_answer                => cur_css_interface_rec.question_16_answer,
                        x_question_17_number                => cur_css_interface_rec.question_17_number,
                        x_question_17_size                  => cur_css_interface_rec.question_17_size,
                        x_question_17_answer                => cur_css_interface_rec.question_17_answer,
                        x_question_18_number                => cur_css_interface_rec.question_18_number,
                        x_question_18_size                  => cur_css_interface_rec.question_18_size,
                        x_question_18_answer                => cur_css_interface_rec.question_18_answer,
                        x_question_19_number                => cur_css_interface_rec.question_19_number,
                        x_question_19_size                  => cur_css_interface_rec.question_19_size,
                        x_question_19_answer                => cur_css_interface_rec.question_19_answer,
                        x_question_20_number                => cur_css_interface_rec.question_20_number,
                        x_question_20_size                  => cur_css_interface_rec.question_20_size,
                        x_question_20_answer                => cur_css_interface_rec.question_20_answer,
                        x_question_21_number                => cur_css_interface_rec.question_21_number,
                        x_question_21_size                  => cur_css_interface_rec.question_21_size,
                        x_question_21_answer                => cur_css_interface_rec.question_21_answer,
                        x_question_22_number                => cur_css_interface_rec.question_22_number,
                        x_question_22_size                  => cur_css_interface_rec.question_22_size,
                        x_question_22_answer                => cur_css_interface_rec.question_22_answer,
                        x_question_23_number                => cur_css_interface_rec.question_23_number,
                        x_question_23_size                  => cur_css_interface_rec.question_23_size,
                        x_question_23_answer                => cur_css_interface_rec.question_23_answer,
                        x_question_24_number                => cur_css_interface_rec.question_24_number,
                        x_question_24_size                  => cur_css_interface_rec.question_24_size,
                        x_question_24_answer                => cur_css_interface_rec.question_24_answer,
                        x_question_25_number                => cur_css_interface_rec.question_25_number,
                        x_question_25_size                  => cur_css_interface_rec.question_25_size,
                        x_question_25_answer                => cur_css_interface_rec.question_25_answer,
                        x_question_26_number                => cur_css_interface_rec.question_26_number,
                        x_question_26_size                  => cur_css_interface_rec.question_26_size,
                        x_question_26_answer                => cur_css_interface_rec.question_26_answer,
                        x_question_27_number                => cur_css_interface_rec.question_27_number,
                        x_question_27_size                  => cur_css_interface_rec.question_27_size,
                        x_question_27_answer                => cur_css_interface_rec.question_27_answer,
                        x_question_28_number                => cur_css_interface_rec.question_28_number,
                        x_question_28_size                  => cur_css_interface_rec.question_28_size,
                        x_question_28_answer                => cur_css_interface_rec.question_28_answer,
                        x_question_29_number                => cur_css_interface_rec.question_29_number,
                        x_question_29_size                  => cur_css_interface_rec.question_29_size,
                        x_question_29_answer                => cur_css_interface_rec.question_29_answer,
                        x_question_30_number                => cur_css_interface_rec.question_30_number,
                        x_questions_30_size                 => cur_css_interface_rec.questions_30_size,
                        x_question_30_answer                => cur_css_interface_rec.question_30_answer,
                        x_r_s_email_address                 => cur_css_interface_rec.r_s_email_address,
                        x_eps_code                          => cur_css_interface_rec.eps_code,
                        x_comp_css_dependency_status        => cur_css_interface_rec.comp_css_dependency_status,
                        x_stu_age                           => cur_css_interface_rec.stu_age,
                        x_assumed_stu_yr_in_coll            => cur_css_interface_rec.assumed_stu_yr_in_coll,
                        x_comp_stu_marital_status           => cur_css_interface_rec.comp_stu_marital_status,
                        x_stu_family_members                => cur_css_interface_rec.stu_family_members,
                        x_stu_fam_members_in_college        => cur_css_interface_rec.stu_fam_members_in_college,
                        x_par_marital_status                => cur_css_interface_rec.par_marital_status,
                        x_par_family_members                => cur_css_interface_rec.par_family_members,
                        x_par_total_in_college              => cur_css_interface_rec.par_total_in_college,
                        x_par_par_in_college                => cur_css_interface_rec.par_par_in_college,
                        x_par_others_in_college             => cur_css_interface_rec.par_others_in_college,
                        x_par_aesa                          => cur_css_interface_rec.par_aesa,
                        x_par_cesa                          => cur_css_interface_rec.par_cesa,
                        x_stu_aesa                          => cur_css_interface_rec.stu_aesa,
                        x_stu_cesa                          => cur_css_interface_rec.stu_cesa,
                        x_im_p_bas_agi_taxable_income       => cur_css_interface_rec.im_p_bas_agi_taxable_income,
                        x_im_p_bas_untx_inc_and_ben         => cur_css_interface_rec.im_p_bas_untx_inc_and_ben,
                        x_im_p_bas_inc_adj                  => cur_css_interface_rec.im_p_bas_inc_adj,
                        x_im_p_bas_total_income             => cur_css_interface_rec.im_p_bas_total_income,
                        x_im_p_bas_us_income_tax            => cur_css_interface_rec.im_p_bas_us_income_tax,
                        x_im_p_bas_st_and_other_tax         => cur_css_interface_rec.im_p_bas_st_and_other_tax,
                        x_im_p_bas_fica_tax                 => cur_css_interface_rec.im_p_bas_fica_tax,
                        x_im_p_bas_med_dental               => cur_css_interface_rec.im_p_bas_med_dental,
                        x_im_p_bas_employment_allow         => cur_css_interface_rec.im_p_bas_employment_allow,
                        x_im_p_bas_annual_ed_savings        => cur_css_interface_rec.im_p_bas_annual_ed_savings,
                        x_im_p_bas_inc_prot_allow_m         => cur_css_interface_rec.im_p_bas_inc_prot_allow_m,
                        x_im_p_bas_total_inc_allow          => cur_css_interface_rec.im_p_bas_total_inc_allow,
                        x_im_p_bas_cal_avail_inc            => cur_css_interface_rec.im_p_bas_cal_avail_inc,
                        x_im_p_bas_avail_income             => cur_css_interface_rec.im_p_bas_avail_income,
                        x_im_p_bas_total_cont_inc           => cur_css_interface_rec.im_p_bas_total_cont_inc,
                        x_im_p_bas_cash_bank_accounts       => cur_css_interface_rec.im_p_bas_cash_bank_accounts,
                        x_im_p_bas_home_equity              => cur_css_interface_rec.im_p_bas_home_equity,
                        x_im_p_bas_ot_rl_est_inv_eq         => cur_css_interface_rec.im_p_bas_ot_rl_est_inv_eq,
                        x_im_p_bas_adj_bus_farm_worth       => cur_css_interface_rec.im_p_bas_adj_bus_farm_worth,
                        x_im_p_bas_ass_sibs_pre_tui         => cur_css_interface_rec.im_p_bas_ass_sibs_pre_tui,
                        x_im_p_bas_net_worth                => cur_css_interface_rec.im_p_bas_net_worth,
                        x_im_p_bas_emerg_res_allow          => cur_css_interface_rec.im_p_bas_emerg_res_allow,
                        x_im_p_bas_cum_ed_savings           => cur_css_interface_rec.im_p_bas_cum_ed_savings,
                        x_im_p_bas_low_inc_allow            => cur_css_interface_rec.im_p_bas_low_inc_allow,
                        x_im_p_bas_total_asset_allow        => cur_css_interface_rec.im_p_bas_total_asset_allow,
                        x_im_p_bas_disc_net_worth           => cur_css_interface_rec.im_p_bas_disc_net_worth,
                        x_im_p_bas_total_cont_asset         => cur_css_interface_rec.im_p_bas_total_cont_asset,
                        x_im_p_bas_total_cont               => cur_css_interface_rec.im_p_bas_total_cont,
                        x_im_p_bas_num_in_coll_adj          => cur_css_interface_rec.im_p_bas_num_in_coll_adj,
                        x_im_p_bas_cont_for_stu             => cur_css_interface_rec.im_p_bas_cont_for_stu,
                        x_im_p_bas_cont_from_income         => cur_css_interface_rec.im_p_bas_cont_from_income,
                        x_im_p_bas_cont_from_assets         => cur_css_interface_rec.im_p_bas_cont_from_assets,
                        x_im_p_opt_agi_taxable_income       => cur_css_interface_rec.im_p_opt_agi_taxable_income,
                        x_im_p_opt_untx_inc_and_ben         => cur_css_interface_rec.im_p_opt_untx_inc_and_ben,
                        x_im_p_opt_inc_adj                  => cur_css_interface_rec.im_p_opt_inc_adj,
                        x_im_p_opt_total_income             => cur_css_interface_rec.im_p_opt_total_income,
                        x_im_p_opt_us_income_tax            => cur_css_interface_rec.im_p_opt_us_income_tax,
                        x_im_p_opt_st_and_other_tax         => cur_css_interface_rec.im_p_opt_st_and_other_tax,
                        x_im_p_opt_fica_tax                 => cur_css_interface_rec.im_p_opt_fica_tax,
                        x_im_p_opt_med_dental               => cur_css_interface_rec.im_p_opt_med_dental,
                        x_im_p_opt_elem_sec_tuit            => cur_css_interface_rec.im_p_opt_elem_sec_tuit,
                        x_im_p_opt_employment_allow         => cur_css_interface_rec.im_p_opt_employment_allow,
                        x_im_p_opt_annual_ed_savings        => cur_css_interface_rec.im_p_opt_annual_ed_savings,
                        x_im_p_opt_inc_prot_allow_m         => cur_css_interface_rec.im_p_opt_inc_prot_allow_m,
                        x_im_p_opt_total_inc_allow          => cur_css_interface_rec.im_p_opt_total_inc_allow,
                        x_im_p_opt_cal_avail_inc            => cur_css_interface_rec.im_p_opt_cal_avail_inc,
                        x_im_p_opt_avail_income             => cur_css_interface_rec.im_p_opt_avail_income,
                        x_im_p_opt_total_cont_inc           => cur_css_interface_rec.im_p_opt_total_cont_inc,
                        x_im_p_opt_cash_bank_accounts       => cur_css_interface_rec.im_p_opt_cash_bank_accounts,
                        x_im_p_opt_home_equity              => cur_css_interface_rec.im_p_opt_home_equity,
                        x_im_p_opt_ot_rl_est_inv_eq         => cur_css_interface_rec.im_p_opt_ot_rl_est_inv_eq,
                        x_im_p_opt_adj_bus_farm_worth       => cur_css_interface_rec.im_p_opt_adj_bus_farm_worth,
                        x_im_p_opt_ass_sibs_pre_t           => cur_css_interface_rec.im_p_opt_ass_sibs_pre_t,
                        x_im_p_opt_net_worth                => cur_css_interface_rec.im_p_opt_net_worth,
                        x_im_p_opt_emerg_res_allow          => cur_css_interface_rec.im_p_opt_emerg_res_allow,
                        x_im_p_opt_cum_ed_savings           => cur_css_interface_rec.im_p_opt_cum_ed_savings,
                        x_im_p_opt_low_inc_allow            => cur_css_interface_rec.im_p_opt_low_inc_allow,
                        x_im_p_opt_total_asset_allow        => cur_css_interface_rec.im_p_opt_total_asset_allow,
                        x_im_p_opt_disc_net_worth           => cur_css_interface_rec.im_p_opt_disc_net_worth,
                        x_im_p_opt_total_cont_asset         => cur_css_interface_rec.im_p_opt_total_cont_asset,
                        x_im_p_opt_total_cont               => cur_css_interface_rec.im_p_opt_total_cont,
                        x_im_p_opt_num_in_coll_adj          => cur_css_interface_rec.im_p_opt_num_in_coll_adj,
                        x_im_p_opt_cont_for_stu             => cur_css_interface_rec.im_p_opt_cont_for_stu,
                        x_im_p_opt_cont_from_income         => cur_css_interface_rec.im_p_opt_cont_from_income,
                        x_im_p_opt_cont_from_assets         => cur_css_interface_rec.im_p_opt_cont_from_assets,
                        x_fm_p_analysis_type                => cur_css_interface_rec.fm_p_analysis_type,
                        x_fm_p_agi_taxable_income           => cur_css_interface_rec.fm_p_agi_taxable_income,
                        x_fm_p_untx_inc_and_ben             => cur_css_interface_rec.fm_p_untx_inc_and_ben,
                        x_fm_p_inc_adj                      => cur_css_interface_rec.fm_p_inc_adj,
                        x_fm_p_total_income                 => cur_css_interface_rec.fm_p_total_income,
                        x_fm_p_us_income_tax                => cur_css_interface_rec.fm_p_us_income_tax,
                        x_fm_p_state_and_other_taxes        => cur_css_interface_rec.fm_p_state_and_other_taxes,
                        x_fm_p_fica_tax                     => cur_css_interface_rec.fm_p_fica_tax,
                        x_fm_p_employment_allow             => cur_css_interface_rec.fm_p_employment_allow,
                        x_fm_p_income_prot_allow            => cur_css_interface_rec.fm_p_income_prot_allow,
                        x_fm_p_total_allow                  => cur_css_interface_rec.fm_p_total_allow,
                        x_fm_p_avail_income                 => cur_css_interface_rec.fm_p_avail_income,
                        x_fm_p_cash_bank_accounts           => cur_css_interface_rec.fm_p_cash_bank_accounts,
                        x_fm_p_ot_rl_est_inv_eq             => cur_css_interface_rec.fm_p_ot_rl_est_inv_eq,
                        x_fm_p_adj_bus_farm_net_worth       => cur_css_interface_rec.fm_p_adj_bus_farm_net_worth,
                        x_fm_p_net_worth                    => cur_css_interface_rec.fm_p_net_worth,
                        x_fm_p_asset_prot_allow             => cur_css_interface_rec.fm_p_asset_prot_allow,
                        x_fm_p_disc_net_worth               => cur_css_interface_rec.fm_p_disc_net_worth,
                        x_fm_p_total_contribution           => cur_css_interface_rec.fm_p_total_contribution,
                        x_fm_p_num_in_coll                  => cur_css_interface_rec.fm_p_num_in_coll,
                        x_fm_p_cont_for_stu                 => cur_css_interface_rec.fm_p_cont_for_stu,
                        x_fm_p_cont_from_income             => cur_css_interface_rec.fm_p_cont_from_income,
                        x_fm_p_cont_from_assets             => cur_css_interface_rec.fm_p_cont_from_assets,
                        x_im_s_bas_agi_taxable_income       => cur_css_interface_rec.im_s_bas_agi_taxable_income,
                        x_im_s_bas_untx_inc_and_ben         => cur_css_interface_rec.im_s_bas_untx_inc_and_ben,
                        x_im_s_bas_inc_adj                  => cur_css_interface_rec.im_s_bas_inc_adj,
                        x_im_s_bas_total_income             => cur_css_interface_rec.im_s_bas_total_income,
                        x_im_s_bas_us_income_tax            => cur_css_interface_rec.im_s_bas_us_income_tax,
                        x_im_s_bas_st_and_oth_tax           => cur_css_interface_rec.im_s_bas_st_and_oth_tax,
                        x_im_s_bas_fica_tax                 => cur_css_interface_rec.im_s_bas_fica_tax,
                        x_im_s_bas_med_dental               => cur_css_interface_rec.im_s_bas_med_dental,
                        x_im_s_bas_employment_allow         => cur_css_interface_rec.im_s_bas_employment_allow,
                        x_im_s_bas_annual_ed_savings        => cur_css_interface_rec.im_s_bas_annual_ed_savings,
                        x_im_s_bas_inc_prot_allow_m         => cur_css_interface_rec.im_s_bas_inc_prot_allow_m,
                        x_im_s_bas_total_inc_allow          => cur_css_interface_rec.im_s_bas_total_inc_allow,
                        x_im_s_bas_cal_avail_income         => cur_css_interface_rec.im_s_bas_cal_avail_income,
                        x_im_s_bas_avail_income             => cur_css_interface_rec.im_s_bas_avail_income,
                        x_im_s_bas_total_cont_inc           => cur_css_interface_rec.im_s_bas_total_cont_inc,
                        x_im_s_bas_cash_bank_accounts       => cur_css_interface_rec.im_s_bas_cash_bank_accounts,
                        x_im_s_bas_home_equity              => cur_css_interface_rec.im_s_bas_home_equity,
                        x_im_s_bas_ot_rl_est_inv_eq         => cur_css_interface_rec.im_s_bas_ot_rl_est_inv_eq,
                        x_im_s_bas_adj_bus_farm_worth       => cur_css_interface_rec.im_s_bas_adj_bus_farm_worth,
                        x_im_s_bas_trusts                   => cur_css_interface_rec.im_s_bas_trusts,
                        x_im_s_bas_net_worth                => cur_css_interface_rec.im_s_bas_net_worth,
                        x_im_s_bas_emerg_res_allow          => cur_css_interface_rec.im_s_bas_emerg_res_allow,
                        x_im_s_bas_cum_ed_savings           => cur_css_interface_rec.im_s_bas_cum_ed_savings,
                        x_im_s_bas_total_asset_allow        => cur_css_interface_rec.im_s_bas_total_asset_allow,
                        x_im_s_bas_disc_net_worth           => cur_css_interface_rec.im_s_bas_disc_net_worth,
                        x_im_s_bas_total_cont_asset         => cur_css_interface_rec.im_s_bas_total_cont_asset,
                        x_im_s_bas_total_cont               => cur_css_interface_rec.im_s_bas_total_cont,
                        x_im_s_bas_num_in_coll_adj          => cur_css_interface_rec.im_s_bas_num_in_coll_adj,
                        x_im_s_bas_cont_for_stu             => cur_css_interface_rec.im_s_bas_cont_for_stu,
                        x_im_s_bas_cont_from_income         => cur_css_interface_rec.im_s_bas_cont_from_income,
                        x_im_s_bas_cont_from_assets         => cur_css_interface_rec.im_s_bas_cont_from_assets,
                        x_im_s_est_agi_taxable_income       => cur_css_interface_rec.im_s_est_agi_taxable_income,
                        x_im_s_est_untx_inc_and_ben         => cur_css_interface_rec.im_s_est_untx_inc_and_ben,
                        x_im_s_est_inc_adj                  => cur_css_interface_rec.im_s_est_inc_adj,
                        x_im_s_est_total_income             => cur_css_interface_rec.im_s_est_total_income,
                        x_im_s_est_us_income_tax            => cur_css_interface_rec.im_s_est_us_income_tax,
                        x_im_s_est_st_and_oth_tax           => cur_css_interface_rec.im_s_est_st_and_oth_tax,
                        x_im_s_est_fica_tax                 => cur_css_interface_rec.im_s_est_fica_tax,
                        x_im_s_est_med_dental               => cur_css_interface_rec.im_s_est_med_dental,
                        x_im_s_est_employment_allow         => cur_css_interface_rec.im_s_est_employment_allow,
                        x_im_s_est_annual_ed_savings        => cur_css_interface_rec.im_s_est_annual_ed_savings,
                        x_im_s_est_inc_prot_allow_m         => cur_css_interface_rec.im_s_est_inc_prot_allow_m,
                        x_im_s_est_total_inc_allow          => cur_css_interface_rec.im_s_est_total_inc_allow,
                        x_im_s_est_cal_avail_income         => cur_css_interface_rec.im_s_est_cal_avail_income,
                        x_im_s_est_avail_income             => cur_css_interface_rec.im_s_est_avail_income,
                        x_im_s_est_total_cont_inc           => cur_css_interface_rec.im_s_est_total_cont_inc,
                        x_im_s_est_cash_bank_accounts       => cur_css_interface_rec.im_s_est_cash_bank_accounts,
                        x_im_s_est_home_equity              => cur_css_interface_rec.im_s_est_home_equity,
                        x_im_s_est_ot_rl_est_inv_equ        => cur_css_interface_rec.im_s_est_ot_rl_est_inv_equ,
                        x_im_s_est_adj_bus_farm_worth       => cur_css_interface_rec.im_s_est_adj_bus_farm_worth,
                        x_im_s_est_est_trusts               => cur_css_interface_rec.im_s_est_est_trusts,
                        x_im_s_est_net_worth                => cur_css_interface_rec.im_s_est_net_worth,
                        x_im_s_est_emerg_res_allow          => cur_css_interface_rec.im_s_est_emerg_res_allow,
                        x_im_s_est_cum_ed_savings           => cur_css_interface_rec.im_s_est_cum_ed_savings,
                        x_im_s_est_total_asset_allow        => cur_css_interface_rec.im_s_est_total_asset_allow,
                        x_im_s_est_disc_net_worth           => cur_css_interface_rec.im_s_est_disc_net_worth,
                        x_im_s_est_total_cont_asset         => cur_css_interface_rec.im_s_est_total_cont_asset,
                        x_im_s_est_total_cont               => cur_css_interface_rec.im_s_est_total_cont,
                        x_im_s_est_num_in_coll_adj          => cur_css_interface_rec.im_s_est_num_in_coll_adj,
                        x_im_s_est_cont_for_stu             => cur_css_interface_rec.im_s_est_cont_for_stu,
                        x_im_s_est_cont_from_income         => cur_css_interface_rec.im_s_est_cont_from_income,
                        x_im_s_est_cont_from_assets         => cur_css_interface_rec.im_s_est_cont_from_assets,
                        x_im_s_opt_agi_taxable_income       => cur_css_interface_rec.im_s_opt_agi_taxable_income,
                        x_im_s_opt_untx_inc_and_ben         => cur_css_interface_rec.im_s_opt_untx_inc_and_ben,
                        x_im_s_opt_inc_adj                  => cur_css_interface_rec.im_s_opt_inc_adj,
                        x_im_s_opt_total_income             => cur_css_interface_rec.im_s_opt_total_income,
                        x_im_s_opt_us_income_tax            => cur_css_interface_rec.im_s_opt_us_income_tax,
                        x_im_s_opt_state_and_oth_taxes      => cur_css_interface_rec.im_s_opt_state_and_oth_taxes,
                        x_im_s_opt_fica_tax                 => cur_css_interface_rec.im_s_opt_fica_tax,
                        x_im_s_opt_med_dental               => cur_css_interface_rec.im_s_opt_med_dental,
                        x_im_s_opt_employment_allow         => cur_css_interface_rec.im_s_opt_employment_allow,
                        x_im_s_opt_annual_ed_savings        => cur_css_interface_rec.im_s_opt_annual_ed_savings,
                        x_im_s_opt_inc_prot_allow_m         => cur_css_interface_rec.im_s_opt_inc_prot_allow_m,
                        x_im_s_opt_total_inc_allow          => cur_css_interface_rec.im_s_opt_total_inc_allow,
                        x_im_s_opt_cal_avail_income         => cur_css_interface_rec.im_s_opt_cal_avail_income,
                        x_im_s_opt_avail_income             => cur_css_interface_rec.im_s_opt_avail_income,
                        x_im_s_opt_total_cont_inc           => cur_css_interface_rec.im_s_opt_total_cont_inc,
                        x_im_s_opt_cash_bank_accounts       => cur_css_interface_rec.im_s_opt_cash_bank_accounts,
                        x_im_s_opt_ira_keogh_accounts       => cur_css_interface_rec.im_s_opt_ira_keogh_accounts,
                        x_im_s_opt_home_equity              => cur_css_interface_rec.im_s_opt_home_equity,
                        x_im_s_opt_ot_rl_est_inv_eq         => cur_css_interface_rec.im_s_opt_ot_rl_est_inv_eq,
                        x_im_s_opt_adj_bus_farm_worth       => cur_css_interface_rec.im_s_opt_adj_bus_farm_worth,
                        x_im_s_opt_trusts                   => cur_css_interface_rec.im_s_opt_trusts,
                        x_im_s_opt_net_worth                => cur_css_interface_rec.im_s_opt_net_worth,
                        x_im_s_opt_emerg_res_allow          => cur_css_interface_rec.im_s_opt_emerg_res_allow,
                        x_im_s_opt_cum_ed_savings           => cur_css_interface_rec.im_s_opt_cum_ed_savings,
                        x_im_s_opt_total_asset_allow        => cur_css_interface_rec.im_s_opt_total_asset_allow,
                        x_im_s_opt_disc_net_worth           => cur_css_interface_rec.im_s_opt_disc_net_worth,
                        x_im_s_opt_total_cont_asset         => cur_css_interface_rec.im_s_opt_total_cont_asset,
                        x_im_s_opt_total_cont               => cur_css_interface_rec.im_s_opt_total_cont,
                        x_im_s_opt_num_in_coll_adj          => cur_css_interface_rec.im_s_opt_num_in_coll_adj,
                        x_im_s_opt_cont_for_stu             => cur_css_interface_rec.im_s_opt_cont_for_stu,
                        x_im_s_opt_cont_from_income         => cur_css_interface_rec.im_s_opt_cont_from_income,
                        x_im_s_opt_cont_from_assets         => cur_css_interface_rec.im_s_opt_cont_from_assets,
                        x_fm_s_analysis_type                => cur_css_interface_rec.fm_s_analysis_type,
                        x_fm_s_agi_taxable_income           => cur_css_interface_rec.fm_s_agi_taxable_income,
                        x_fm_s_untx_inc_and_ben             => cur_css_interface_rec.fm_s_untx_inc_and_ben,
                        x_fm_s_inc_adj                      => cur_css_interface_rec.fm_s_inc_adj,
                        x_fm_s_total_income                 => cur_css_interface_rec.fm_s_total_income,
                        x_fm_s_us_income_tax                => cur_css_interface_rec.fm_s_us_income_tax,
                        x_fm_s_state_and_oth_taxes          => cur_css_interface_rec.fm_s_state_and_oth_taxes,
                        x_fm_s_fica_tax                     => cur_css_interface_rec.fm_s_fica_tax,
                        x_fm_s_employment_allow             => cur_css_interface_rec.fm_s_employment_allow,
                        x_fm_s_income_prot_allow            => cur_css_interface_rec.fm_s_income_prot_allow,
                        x_fm_s_total_allow                  => cur_css_interface_rec.fm_s_total_allow,
                        x_fm_s_cal_avail_income             => cur_css_interface_rec.fm_s_cal_avail_income,
                        x_fm_s_avail_income                 => cur_css_interface_rec.fm_s_avail_income,
                        x_fm_s_cash_bank_accounts           => cur_css_interface_rec.fm_s_cash_bank_accounts,
                        x_fm_s_ot_rl_est_inv_equity         => cur_css_interface_rec.fm_s_ot_rl_est_inv_equity,
                        x_fm_s_adj_bus_farm_worth           => cur_css_interface_rec.fm_s_adj_bus_farm_worth,
                        x_fm_s_trusts                       => cur_css_interface_rec.fm_s_trusts,
                        x_fm_s_net_worth                    => cur_css_interface_rec.fm_s_net_worth,
                        x_fm_s_asset_prot_allow             => cur_css_interface_rec.fm_s_asset_prot_allow,
                        x_fm_s_disc_net_worth               => cur_css_interface_rec.fm_s_disc_net_worth,
                        x_fm_s_total_cont                   => cur_css_interface_rec.fm_s_total_cont,
                        x_fm_s_num_in_coll                  => cur_css_interface_rec.fm_s_num_in_coll,
                        x_fm_s_cont_for_stu                 => cur_css_interface_rec.fm_s_cont_for_stu,
                        x_fm_s_cont_from_income             => cur_css_interface_rec.fm_s_cont_from_income,
                        x_fm_s_cont_from_assets             => cur_css_interface_rec.fm_s_cont_from_assets,
                        x_im_inst_resident_ind              => cur_css_interface_rec.im_inst_resident_ind,
                        x_institutional_1_budget_name       => cur_css_interface_rec.institutional_1_budget_name,
                        x_im_inst_1_budget_duration         => cur_css_interface_rec.im_inst_1_budget_duration,
                        x_im_inst_1_tuition_fees            => cur_css_interface_rec.im_inst_1_tuition_fees,
                        x_im_inst_1_books_supplies          => cur_css_interface_rec.im_inst_1_books_supplies,
                        x_im_inst_1_living_expenses         => cur_css_interface_rec.im_inst_1_living_expenses,
                        x_im_inst_1_tot_expenses            => cur_css_interface_rec.im_inst_1_tot_expenses,
                        x_im_inst_1_tot_stu_cont            => cur_css_interface_rec.im_inst_1_tot_stu_cont,
                        x_im_inst_1_tot_par_cont            => cur_css_interface_rec.im_inst_1_tot_par_cont,
                        x_im_inst_1_tot_family_cont         => cur_css_interface_rec.im_inst_1_tot_family_cont,
                        x_im_inst_1_va_benefits             => cur_css_interface_rec.im_inst_1_va_benefits,
                        x_im_inst_1_ot_cont                 => cur_css_interface_rec.im_inst_1_ot_cont,
                        x_im_inst_1_est_financial_need      => cur_css_interface_rec.im_inst_1_est_financial_need,
                        x_institutional_2_budget_name       => cur_css_interface_rec.institutional_2_budget_name,
                        x_im_inst_2_budget_duration         => cur_css_interface_rec.im_inst_2_budget_duration,
                        x_im_inst_2_tuition_fees            => cur_css_interface_rec.im_inst_2_tuition_fees,
                        x_im_inst_2_books_supplies          => cur_css_interface_rec.im_inst_2_books_supplies,
                        x_im_inst_2_living_expenses         => cur_css_interface_rec.im_inst_2_living_expenses,
                        x_im_inst_2_tot_expenses            => cur_css_interface_rec.im_inst_2_tot_expenses,
                        x_im_inst_2_tot_stu_cont            => cur_css_interface_rec.im_inst_2_tot_stu_cont,
                        x_im_inst_2_tot_par_cont            => cur_css_interface_rec.im_inst_2_tot_par_cont,
                        x_im_inst_2_tot_family_cont         => cur_css_interface_rec.im_inst_2_tot_family_cont,
                        x_im_inst_2_va_benefits             => cur_css_interface_rec.im_inst_2_va_benefits,
                        x_im_inst_2_est_financial_need      => cur_css_interface_rec.im_inst_2_est_financial_need,
                        x_institutional_3_budget_name       => cur_css_interface_rec.institutional_3_budget_name,
                        x_im_inst_3_budget_duration         => cur_css_interface_rec.im_inst_3_budget_duration,
                        x_im_inst_3_tuition_fees            => cur_css_interface_rec.im_inst_3_tuition_fees,
                        x_im_inst_3_books_supplies          => cur_css_interface_rec.im_inst_3_books_supplies,
                        x_im_inst_3_living_expenses         => cur_css_interface_rec.im_inst_3_living_expenses,
                        x_im_inst_3_tot_expenses            => cur_css_interface_rec.im_inst_3_tot_expenses,
                        x_im_inst_3_tot_stu_cont            => cur_css_interface_rec.im_inst_3_tot_stu_cont,
                        x_im_inst_3_tot_par_cont            => cur_css_interface_rec.im_inst_3_tot_par_cont,
                        x_im_inst_3_tot_family_cont         => cur_css_interface_rec.im_inst_3_tot_family_cont,
                        x_im_inst_3_va_benefits             => cur_css_interface_rec.im_inst_3_va_benefits,
                        x_im_inst_3_est_financial_need      => cur_css_interface_rec.im_inst_3_est_financial_need,
                        x_fm_inst_1_federal_efc             => cur_css_interface_rec.fm_inst_1_federal_efc,
                        x_fm_inst_1_va_benefits             => cur_css_interface_rec.fm_inst_1_va_benefits,
                        x_fm_inst_1_fed_eligibility         => cur_css_interface_rec.fm_inst_1_fed_eligibility,
                        x_fm_inst_1_pell                    => cur_css_interface_rec.fm_inst_1_pell,
                        x_option_par_loss_allow_ind         => cur_css_interface_rec.option_par_loss_allow_ind,
                        x_option_par_tuition_ind            => cur_css_interface_rec.option_par_tuition_ind,
                        x_option_par_home_ind               => cur_css_interface_rec.option_par_home_ind,
                        x_option_par_home_value             => cur_css_interface_rec.option_par_home_value,
                        x_option_par_home_debt              => cur_css_interface_rec.option_par_home_debt,
                        x_option_stu_ira_keogh_ind          => cur_css_interface_rec.option_stu_ira_keogh_ind,
                        x_option_stu_home_ind               => cur_css_interface_rec.option_stu_home_ind,
                        x_option_stu_home_value             => cur_css_interface_rec.option_stu_home_value,
                        x_option_stu_home_debt              => cur_css_interface_rec.option_stu_home_debt,
                        x_option_stu_sum_ay_inc_ind         => cur_css_interface_rec.option_stu_sum_ay_inc_ind,
                        x_option_par_hope_ll_credit         => cur_css_interface_rec.option_par_hope_ll_credit,
                        x_option_stu_hope_ll_credit         => cur_css_interface_rec.option_stu_hope_ll_credit,
                        x_im_parent_1_8_months_bas          => cur_css_interface_rec.im_parent_1_8_months_bas,
                        x_im_p_more_than_9_mth_ba           => cur_css_interface_rec.im_p_more_than_9_mth_ba,
                        x_im_parent_1_8_months_opt          => cur_css_interface_rec.im_parent_1_8_months_opt,
                        x_im_p_more_than_9_mth_op           => cur_css_interface_rec.im_p_more_than_9_mth_op,
                        x_fnar_message_1                    => cur_css_interface_rec.fnar_message_1,
                        x_fnar_message_2                    => cur_css_interface_rec.fnar_message_2,
                        x_fnar_message_3                    => cur_css_interface_rec.fnar_message_3,
                        x_fnar_message_4                    => cur_css_interface_rec.fnar_message_4,
                        x_fnar_message_5                    => cur_css_interface_rec.fnar_message_5,
                        x_fnar_message_6                    => cur_css_interface_rec.fnar_message_6,
                        x_fnar_message_7                    => cur_css_interface_rec.fnar_message_7,
                        x_fnar_message_8                    => cur_css_interface_rec.fnar_message_8,
                        x_fnar_message_9                    => cur_css_interface_rec.fnar_message_9,
                        x_fnar_message_10                   => cur_css_interface_rec.fnar_message_10,
                        x_fnar_message_11                   => cur_css_interface_rec.fnar_message_11,
                        x_fnar_message_12                   => cur_css_interface_rec.fnar_message_12,
                        x_fnar_message_13                   => cur_css_interface_rec.fnar_message_13,
                        x_fnar_message_20                   => cur_css_interface_rec.fnar_message_20,
                        x_fnar_message_21                   => cur_css_interface_rec.fnar_message_21,
                        x_fnar_message_22                   => cur_css_interface_rec.fnar_message_22,
                        x_fnar_message_23                   => cur_css_interface_rec.fnar_message_23,
                        x_fnar_message_24                   => cur_css_interface_rec.fnar_message_24,
                        x_fnar_message_25                   => cur_css_interface_rec.fnar_message_25,
                        x_fnar_message_26                   => cur_css_interface_rec.fnar_message_26,
                        x_fnar_message_27                   => cur_css_interface_rec.fnar_message_27,
                        x_fnar_message_30                   => cur_css_interface_rec.fnar_message_30,
                        x_fnar_message_31                   => cur_css_interface_rec.fnar_message_31,
                        x_fnar_message_32                   => cur_css_interface_rec.fnar_message_32,
                        x_fnar_message_33                   => cur_css_interface_rec.fnar_message_33,
                        x_fnar_message_34                   => cur_css_interface_rec.fnar_message_34,
                        x_fnar_message_35                   => cur_css_interface_rec.fnar_message_35,
                        x_fnar_message_36                   => cur_css_interface_rec.fnar_message_36,
                        x_fnar_message_37                   => cur_css_interface_rec.fnar_message_37,
                        x_fnar_message_38                   => cur_css_interface_rec.fnar_message_38,
                        x_fnar_message_39                   => cur_css_interface_rec.fnar_message_39,
                        x_fnar_message_45                   => cur_css_interface_rec.fnar_message_45,
                        x_fnar_message_46                   => cur_css_interface_rec.fnar_message_46,
                        x_fnar_message_47                   => cur_css_interface_rec.fnar_message_47,
                        x_fnar_message_48                   => cur_css_interface_rec.fnar_message_48,
                        x_fnar_message_50                   => cur_css_interface_rec.fnar_message_50,
                        x_fnar_message_51                   => cur_css_interface_rec.fnar_message_51,
                        x_fnar_message_52                   => cur_css_interface_rec.fnar_message_52,
                        x_fnar_message_53                   => cur_css_interface_rec.fnar_message_53,
                        x_fnar_message_56                   => cur_css_interface_rec.fnar_message_56,
                        x_fnar_message_57                   => cur_css_interface_rec.fnar_message_57,
                        x_fnar_message_58                   => cur_css_interface_rec.fnar_message_58,
                        x_fnar_message_59                   => cur_css_interface_rec.fnar_message_59,
                        x_fnar_message_60                   => cur_css_interface_rec.fnar_message_60,
                        x_fnar_message_61                   => cur_css_interface_rec.fnar_message_61,
                        x_fnar_message_62                   => cur_css_interface_rec.fnar_message_62,
                        x_fnar_message_63                   => cur_css_interface_rec.fnar_message_63,
                        x_fnar_message_64                   => cur_css_interface_rec.fnar_message_64,
                        x_fnar_message_65                   => cur_css_interface_rec.fnar_message_65,
                        x_fnar_message_71                   => cur_css_interface_rec.fnar_message_71,
                        x_fnar_message_72                   => cur_css_interface_rec.fnar_message_72,
                        x_fnar_message_73                   => cur_css_interface_rec.fnar_message_73,
                        x_fnar_message_74                   => cur_css_interface_rec.fnar_message_74,
                        x_fnar_message_75                   => cur_css_interface_rec.fnar_message_75,
                        x_fnar_message_76                   => cur_css_interface_rec.fnar_message_76,
                        x_fnar_message_77                   => cur_css_interface_rec.fnar_message_77,
                        x_fnar_message_78                   => cur_css_interface_rec.fnar_message_78,
                        x_fnar_mesg_10_stu_fam_mem          => cur_css_interface_rec.fnar_mesg_10_stu_fam_mem,
                        x_fnar_mesg_11_stu_no_in_coll       => cur_css_interface_rec.fnar_mesg_11_stu_no_in_coll,
                        x_fnar_mesg_24_stu_avail_inc        => cur_css_interface_rec.fnar_mesg_24_stu_avail_inc,
                        x_fnar_mesg_26_stu_taxes            => cur_css_interface_rec.fnar_mesg_26_stu_taxes,
                        x_fnar_mesg_33_stu_home_value       => cur_css_interface_rec.fnar_mesg_33_stu_home_value,
                        x_fnar_mesg_34_stu_home_value       => cur_css_interface_rec.fnar_mesg_34_stu_home_value,
                        x_fnar_mesg_34_stu_home_equity      => cur_css_interface_rec.fnar_mesg_34_stu_home_equity,
                        x_fnar_mesg_35_stu_home_value       => cur_css_interface_rec.fnar_mesg_35_stu_home_value,
                        x_fnar_mesg_35_stu_home_equity      => cur_css_interface_rec.fnar_mesg_35_stu_home_equity,
                        x_fnar_mesg_36_stu_home_equity      => cur_css_interface_rec.fnar_mesg_36_stu_home_equity,
                        x_fnar_mesg_48_par_fam_mem          => cur_css_interface_rec.fnar_mesg_48_par_fam_mem,
                        x_fnar_mesg_49_par_no_in_coll       => cur_css_interface_rec.fnar_mesg_49_par_no_in_coll,
                        x_fnar_mesg_56_par_agi              => cur_css_interface_rec.fnar_mesg_56_par_agi,
                        x_fnar_mesg_62_par_taxes            => cur_css_interface_rec.fnar_mesg_62_par_taxes,
                        x_fnar_mesg_73_par_home_value       => cur_css_interface_rec.fnar_mesg_73_par_home_value,
                        x_fnar_mesg_74_par_home_value       => cur_css_interface_rec.fnar_mesg_74_par_home_value,
                        x_fnar_mesg_74_par_home_equity      => cur_css_interface_rec.fnar_mesg_74_par_home_equity,
                        x_fnar_mesg_75_par_home_value       => cur_css_interface_rec.fnar_mesg_75_par_home_value,
                        x_fnar_mesg_75_par_home_equity      => cur_css_interface_rec.fnar_mesg_75_par_home_equity,
                        x_fnar_mesg_76_par_home_equity      => cur_css_interface_rec.fnar_mesg_76_par_home_equity,
                        x_assumption_message_1              => cur_css_interface_rec.assumption_message_1,
                        x_assumption_message_2              => cur_css_interface_rec.assumption_message_2,
                        x_assumption_message_3              => cur_css_interface_rec.assumption_message_3,
                        x_assumption_message_4              => cur_css_interface_rec.assumption_message_4,
                        x_assumption_message_5              => cur_css_interface_rec.assumption_message_5,
                        x_assumption_message_6              => cur_css_interface_rec.assumption_message_6,
                        x_record_mark                       => cur_css_interface_rec.record_mark,
                        x_option_par_cola_adj_ind           => cur_css_interface_rec.option_par_cola_adj_ind,
                        x_option_par_stu_fa_assets_ind      => cur_css_interface_rec.option_par_stu_fa_assets_ind,
                        x_option_par_ipt_assets_ind         => cur_css_interface_rec.option_par_ipt_assets_ind,
                        x_option_stu_ipt_assets_ind         => cur_css_interface_rec.option_stu_ipt_assets_ind,
                        x_option_par_cola_adj_value         => cur_css_interface_rec.option_par_cola_adj_value,
                        x_fnar_message_49                   => cur_css_interface_rec.fnar_message_49,
                        x_fnar_message_55                   => cur_css_interface_rec.fnar_message_55,
                        x_p_soc_sec_ben_student_amt         => cur_css_interface_rec.p_soc_sec_ben_student_amt,
                        x_p_tuit_fee_deduct_amt             => cur_css_interface_rec.p_tuit_fee_deduct_amt,
                        x_opt_ind_stu_ipt_assets_flag       => cur_css_interface_rec.option_ind_stu_ipt_assets_flag,
                        x_stu_lives_with_num                => cur_css_interface_rec.stu_lives_with_num,
                        x_stu_most_support_from_num         => cur_css_interface_rec.stu_most_support_from_num,
                        x_location_computer_num             => cur_css_interface_rec.location_computer_num,
                        x_cust_parent_cont_adj_num          => cur_css_interface_rec.cust_parent_cont_adj_num,
                        x_custodial_parent_num              => cur_css_interface_rec.custodial_parent_num,
                        x_cust_par_base_prcnt_inc_amt       => cur_css_interface_rec.cust_par_base_prcnt_inc_amt,
                        x_cust_par_base_cont_inc_amt        => cur_css_interface_rec.cust_par_base_cont_inc_amt,
                        x_cust_par_base_cont_ast_amt        => cur_css_interface_rec.cust_par_base_cont_ast_amt,
                        x_cust_par_base_tot_cont_amt        => cur_css_interface_rec.cust_par_base_tot_cont_amt,
                        x_cust_par_opt_prcnt_inc_amt        => cur_css_interface_rec.cust_par_opt_prcnt_inc_amt,
                        x_cust_par_opt_cont_inc_amt         => cur_css_interface_rec.cust_par_opt_cont_inc_amt,
                        x_cust_par_opt_cont_ast_amt         => cur_css_interface_rec.cust_par_opt_cont_ast_amt,
                        x_cust_par_opt_tot_cont_amt         => cur_css_interface_rec.cust_par_opt_tot_cont_amt,
                        x_parents_email_txt                 => cur_css_interface_rec.parents_email_txt,
                        x_parent_1_birth_date               => cur_css_interface_rec.parent_1_birth_date,
                        x_parent_2_birth_date               => cur_css_interface_rec.parent_2_birth_date,
                        x_match_code                        => pv_match_code
                      );

              END LOOP ;

  EXCEPTION
      WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.update_css_interface.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.update_css_interface:');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.update_css_interface:'||SQLERRM);
      app_exception.raise_exception;
  END update_css_interface;

  PROCEDURE create_admission_rec(
                                 p_person_id   igf_ap_fa_base_rec_all.person_id%TYPE,
                                 p_batch_year  igf_ap_css_interface_all.academic_year%TYPE
                                ) IS

    /*
    ||  Created By : vivuyyur
    ||  Created On : 14-JUN-2001
    ||  Purpose : Creates a enquiry record and instance record,
    ||            applicant and student else create its inquiry record and instance record.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    CURSOR cur_adm_cal_conf IS
    SELECT inq_cal_type
      FROM igs_ad_cal_conf;

    CURSOR cur_person_type IS
    SELECT person_type_code
      FROM igs_pe_person_types
     WHERE closed_ind = 'N'
       AND system_type = 'PROSPECT';

    l_person_type          igs_pe_person_types.person_type_code%TYPE;
    l_inq_cal_type         igs_ad_cal_conf.inq_cal_type%TYPE;
    l_rowid                ROWID;
    l_adm_seq              igs_ca_inst.sequence_number%TYPE;
    l_acad_cal_type        igs_ca_type.cal_type%TYPE;
    l_acad_seq             igs_ca_inst.sequence_number%TYPE;
    ln_typ_id              igs_pe_typ_instances_all.type_instance_id%TYPE;
    l_adm_alternate_code   igs_ca_inst.alternate_code%TYPE;
    l_message              VARCHAR2(30);
    lv_return_status       VARCHAR2(10);
    lv_msg_data            VARCHAR2(2000);
    lv_msg_count           NUMBER;
    l_igr_sql_stmt         VARCHAR2(5000);

  BEGIN
    -- Check if the parameter to create inquiry record is set to Y.
    IF (g_create_inquiry = 'Y') THEN

      OPEN cur_adm_cal_conf;
      FETCH cur_adm_cal_conf INTO l_inq_cal_type;
      IF cur_adm_cal_conf%NOTFOUND  THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_DEF_ADM_CAL');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        RETURN; -- bcoz we still process the student even if adm enquiry failed
      END IF;
      CLOSE cur_adm_cal_conf;

      igs_ad_gen_008.get_acad_cal(
                                  p_adm_cal_type       => l_inq_cal_type,
                                  p_adm_seq            => l_adm_seq,
                                  p_acad_cal_type      => l_acad_cal_type,
                                  p_acad_seq           => l_acad_seq,
                                  p_adm_alternate_code => l_adm_alternate_code,
                                  p_message            => l_message
                                 );

      IF l_message IS NOT NULL THEN
        FND_MESSAGE.Set_Name('IGS', 'IGS_AD_INQ_ADMCAL_SEQ_NOTDFN');
        FND_MESSAGE.Set_Token('CAL_TYPE', l_inq_cal_type);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        RETURN; -- bcoz we still process the student even if adm enquiry failed
      END IF;

      IF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN

            l_igr_sql_stmt := '
              DECLARE
                 x_rowid                varchar2(50);
                 l_enquiry_status       VARCHAR2(30);
                 l_enquiry_appl_number  igr_i_appl_all.enquiry_appl_number%TYPE;
                 l_sales_lead_id        igr_i_appl_all.sales_lead_id%TYPE ;
              BEGIN
                 l_enquiry_status := ''OSS_REGISTERED'';
                 igr_inquiry_pkg.insert_row(
                                            X_MODE                         => ''R'',
                                            X_ROWID                        => x_rowid,
                                            X_PERSON_ID                    => :1,
                                            X_ENQUIRY_APPL_NUMBER          => l_enquiry_appl_number,
                                            X_SALES_LEAD_ID                => l_sales_lead_id,
                                            X_ACAD_CAL_TYPE                => :2,
                                            X_ACAD_CI_SEQUENCE_NUMBER      => :3,
                                            X_ADM_CAL_TYPE                 => :4,
                                            X_ADM_CI_SEQUENCE_NUMBER       => :5,
                                            X_s_ENQUIRY_STATUS             => l_enquiry_status,
                                            X_ENQUIRY_DT                   => TRUNC(SYSDATE),
                                            X_INQUIRY_METHOD_CODE          => :6,
                                            X_REGISTERING_PERSON_ID        => NULL,
                                            X_OVERRIDE_PROCESS_IND         => ''N'',
                                            X_INDICATED_MAILING_DT         => NULL,
                                            X_LAST_PROCESS_DT              => NULL,
                                            X_COMMENTS                     => NULL,
                                            X_ORG_ID                       => igs_ge_gen_003.get_org_id,
                                            X_INQ_ENTRY_LEVEL_ID           => NULL,
                                            X_EDU_GOAL_ID                  => NULL,
                                            X_PARTY_ID                     => NULL,
                                            X_HOW_KNOWUS_ID                => NULL,
                                            X_WHO_INFLUENCED_ID            => NULL,
                                            X_SOURCE_PROMOTION_ID          => NULL,
                                            X_PERSON_TYPE_CODE             => NULL,
                                            X_FUNNEL_STATUS                => NULL,
                                            X_ATTRIBUTE_CATEGORY           => NULL,
                                            X_ATTRIBUTE1                   => NULL,
                                            X_ATTRIBUTE2                   => NULL,
                                            X_ATTRIBUTE3                   => NULL,
                                            X_ATTRIBUTE4                   => NULL,
                                            X_ATTRIBUTE5                   => NULL,
                                            X_ATTRIBUTE6                   => NULL,
                                            X_ATTRIBUTE7                   => NULL,
                                            X_ATTRIBUTE8                   => NULL,
                                            X_ATTRIBUTE9                   => NULL,
                                            X_ATTRIBUTE10                  => NULL,
                                            X_ATTRIBUTE11                  => NULL,
                                            X_ATTRIBUTE12                  => NULL,
                                            X_ATTRIBUTE13                  => NULL,
                                            X_ATTRIBUTE14                  => NULL,
                                            X_ATTRIBUTE15                  => NULL,
                                            X_ATTRIBUTE16                  => NULL,
                                            X_ATTRIBUTE17                  => NULL,
                                            X_ATTRIBUTE18                  => NULL,
                                            X_ATTRIBUTE19                  => NULL,
                                            X_ATTRIBUTE20                  => NULL,
                                            X_RET_STATUS                   => :7,
                                            X_MSG_DATA                     => :8,
                                            X_MSG_COUNT                    => :9,
                                            X_ACTION                       => ''Import'',
                                            X_ENABLED_FLAG                 => ''Y'',
                                            X_PKG_REDUCT_IND               => ''Y''
                                           );
              END;';

         EXECUTE IMMEDIATE l_igr_sql_stmt
             USING p_person_id, l_acad_cal_type, l_acad_seq, l_inq_cal_type, l_adm_seq,
             g_adm_source_type, OUT lv_return_status, OUT lv_msg_data, OUT lv_msg_count;
      ELSE
        FND_MESSAGE.Set_Name('IGS', 'IGS_AD_INQ_NOT_CRT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF; -- IGS Recruiting User

      IF lv_return_status IN ('E','U') THEN
        FOR i IN 1..lv_msg_count LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_msg_pub.get(p_encoded => fnd_api.g_false));
        END LOOP;
        RETURN; -- since error no need to proceed further
      ELSE
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_ADM_REC');
        FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);
      END IF;

    END IF;

    OPEN cur_person_type ;
    FETCH cur_person_type INTO l_person_type;
    IF cur_person_type%FOUND  THEN
      CLOSE cur_person_type;
      igs_pe_typ_instances_pkg.insert_row(
                                          X_ROWID                  => l_rowid,
                                          x_PERSON_ID              => p_person_id,
                                          x_COURSE_CD              => NULL,
                                          x_TYPE_INSTANCE_ID       => ln_typ_id,
                                          x_PERSON_TYPE_CODE       => l_person_type,
                                          x_CC_VERSION_NUMBER      => NULL,
                                          x_FUNNEL_STATUS          => NULL,
                                          x_ADMISSION_APPL_NUMBER  => NULL,
                                          x_NOMINATED_COURSE_CD    => NULL,
                                          x_NCC_VERSION_NUMBER     => NULL,
                                          x_SEQUENCE_NUMBER        => NULL,
                                          x_START_DATE             => TRUNC(SYSDATE),
                                          x_END_DATE               => NULL,
                                          x_CREATE_METHOD          => 'CREATE_ENQ_APPL_INSTANCE',
                                          x_ENDED_BY               => NULL,
                                          x_END_METHOD             => NULL,
                                          X_MODE                   => 'R',
                                          X_ORG_ID                 => igs_ge_gen_003.get_org_id
                                         );
    ELSE
      CLOSE cur_person_type;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_PERSON_TYPE');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.create_admission_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      IF cur_adm_cal_conf%ISOPEN THEN
        CLOSE cur_adm_cal_conf;
      END IF;
      IF cur_person_type%ISOPEN THEN
        CLOSE cur_person_type;
      END IF;
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_MATCH_PROFILE_PK.create_admission_rec');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_MATCH_PROFILE_PK.create_admission_rec'|| SQLERRM);
  END create_admission_rec;


  PROCEDURE update_person_match(pn_apm_id          igf_ap_person_match.apm_id%TYPE,
                                     pv_record_status   igf_ap_person_match.record_status%TYPE
                                     )   IS

  /*
  ||  Created By : Meghana
  ||  Created On : 20-JUN-2001
  ||  Purpose : Update the record status to 'Matched / Unmatched' for all the successful/ non successfull persons.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    lv_rowid  VARCHAR2(30);
    ln_org_id       NUMBER ;
    retcode   NUMBER;
    errbuf    VARCHAR2(300);

    CURSOR cur_person_match(pn_apm_id  igf_ap_person_match.apm_id%TYPE) IS
             SELECT apm.*
             FROM   igf_ap_person_match apm
             WHERE  apm.apm_id = pn_apm_id FOR UPDATE NOWAIT ;


  BEGIN

    -- Update record _status
     FOR person_data IN cur_person_match(pn_apm_id)
     LOOP

          igf_ap_person_match_pkg.update_row(
                 x_rowid               =>      person_data.row_id ,
                 x_apm_id              =>      pn_apm_id ,
                 x_css_id              =>      person_data.css_id ,
                 x_si_id               =>      person_data.si_id ,
                 x_record_type         =>      person_data.record_type,
                 x_date_run            =>      person_data.date_run ,
                 x_ci_sequence_number  =>      person_data.ci_sequence_number ,
                 x_ci_cal_type         =>    person_data.ci_cal_type ,
                 x_record_status       =>    pv_record_status ,
                 x_mode                =>      'R'
           );
           END  LOOP ;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.update_person_match.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.update_person_match:');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.update_person_match:'|| SQLERRM);
      app_exception.raise_exception;
  END update_person_match;


  PROCEDURE update_fa_base_rec(p_base_id    igf_ap_fa_base_rec.base_id%TYPE)  IS

  /*
  ||  Created By : vivuyyur
  ||  Created On : 25-JUN-2001
  ||  Purpose : To updatete the fa  basse record
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When          What
  ||  rasahoo    17-NOV-2003   FA 128 - ISIR update 2004-05
  ||                           added new parameter award_fmly_contribution_type to
  ||                           TBH call igf_ap_fa_base_rec_pkg
  ||  masehgal   11-Nov-2002   FA 101 - SAP Obsoletion
  ||                           removed packaging hold
  ||  masehgal   25-Sep-2002   FA 104 - To Do Enhancements
  ||                           Added manual_disb_hold in Fa Base update
  ||  (reverse chronological order - newest change first)
  */
       --  cursor to update the profile_status, profile_fc of igf_ap_fa_base_rec
       CURSOR cur_fabase(p_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
          SELECT *
    FROM   igf_ap_fa_base_rec
    WHERE  base_id = p_base_id FOR UPDATE NOWAIT ;

  BEGIN


        -- To update the fields profile_status ,profile_status_date ,profile_fc
              FOR   fabase_data IN cur_fabase(p_base_id)
              LOOP
                 igf_ap_fa_base_rec_pkg.update_row (
                       X_Mode                              => 'R',
                       x_rowid                             => fabase_data.row_id,
                       x_base_id                           => fabase_data.base_id,
                       x_ci_cal_type                       => fabase_data.ci_cal_type,
                       x_person_id                         => fabase_data.person_id,
                       x_ci_sequence_number                => fabase_data.ci_sequence_number,
                       x_org_id                            => fabase_data.org_id,
                       x_coa_pending                       => fabase_data.coa_pending,
                       x_verification_process_run          => fabase_data.verification_process_run,
                       x_inst_verif_status_date            => fabase_data.inst_verif_status_date,
                       x_manual_verif_flag                 => fabase_data.manual_verif_flag,
                       x_fed_verif_status                  => fabase_data.fed_verif_status,
                       x_fed_verif_status_date             => fabase_data.fed_verif_status_date,
                       x_inst_verif_status                 => fabase_data.inst_verif_status,
                       x_nslds_eligible                    => fabase_data.nslds_eligible,
                       x_ede_correction_batch_id           => fabase_data.ede_correction_batch_id,
                       x_fa_process_status_date            => fabase_data.fa_process_status_date,
                       x_isir_corr_status                  => fabase_data.isir_corr_status,
                       x_isir_corr_status_date             => fabase_data.isir_corr_status_date,
                       x_isir_status                       => fabase_data.isir_status,
                       x_isir_status_date                  => fabase_data.isir_status_date,
                       x_coa_code_f                        => fabase_data.coa_code_f,
                       x_coa_fixed                         => fabase_data.coa_fixed,
                       x_coa_code_i                        => fabase_data.coa_code_i,
                       x_coa_f                             => fabase_data.coa_f,
                       x_coa_i                             => fabase_data.coa_i,
                       x_coa_pell                          => fabase_data.coa_pell,
                       x_disbursement_hold                 => fabase_data.disbursement_hold,
                       x_fa_process_status                 => fabase_data.fa_process_status,
                       x_notification_status               => fabase_data.notification_status,
                       x_notification_status_date          => fabase_data.notification_status_date,
                       x_nslds_data_override_flg           => fabase_data.nslds_data_override_flg,
                       x_packaging_status                  => fabase_data.packaging_status,
                       x_prof_judgement_flg                => fabase_data.prof_judgement_flg,
                       x_packaging_status_date             => fabase_data.packaging_status_date,
                       x_target_group                      => fabase_data.target_group,
                       x_total_package_accepted            => fabase_data.total_package_accepted,
                       x_total_package_offered             => fabase_data.total_package_offered,
                       x_admstruct_id                      => fabase_data.admstruct_id,
                       x_admsegment_1                      => fabase_data.admsegment_1,
                       x_admsegment_2                      => fabase_data.admsegment_2,
                     x_admsegment_3                      => fabase_data.admsegment_3,
                     x_admsegment_4                      => fabase_data.admsegment_4,
                     x_admsegment_5                      => fabase_data.admsegment_5,
                     x_admsegment_6                      => fabase_data.admsegment_6,
                     x_admsegment_7                      => fabase_data.admsegment_7,
                     x_admsegment_8                      => fabase_data.admsegment_8,
                     x_admsegment_9                      => fabase_data.admsegment_9,
                     x_admsegment_10                     => fabase_data.admsegment_10,
                     x_admsegment_11                     => fabase_data.admsegment_11,
                     x_admsegment_12                     => fabase_data.admsegment_12,
                     x_admsegment_13                     => fabase_data.admsegment_13,
                     x_admsegment_14                     => fabase_data.admsegment_14,
                     x_admsegment_15                     => fabase_data.admsegment_15,
                     x_admsegment_16                     => fabase_data.admsegment_16,
                     x_admsegment_17                     => fabase_data.admsegment_17,
                     x_admsegment_18                     => fabase_data.admsegment_18,
                     x_admsegment_19                     => fabase_data.admsegment_19,
                     x_admsegment_20                     => fabase_data.admsegment_20,
                     x_packstruct_id                     => fabase_data.packstruct_id,
                     x_packsegment_1                     => fabase_data.packsegment_1,
                     x_packsegment_2                     => fabase_data.packsegment_2,
                     x_packsegment_3                     => fabase_data.packsegment_3,
                     x_packsegment_4                     => fabase_data.packsegment_4,
                     x_packsegment_5                     => fabase_data.packsegment_5,
                     x_packsegment_6                     => fabase_data.packsegment_6,
                     x_packsegment_7                     => fabase_data.packsegment_7,
                     x_packsegment_8                     => fabase_data.packsegment_8,
                     x_packsegment_9                     => fabase_data.packsegment_9,
                     x_packsegment_10                    => fabase_data.packsegment_10,
                     x_packsegment_11                    => fabase_data.packsegment_11,
                     x_packsegment_12                    => fabase_data.packsegment_12,
                     x_packsegment_13                    => fabase_data.packsegment_13,
                     x_packsegment_14                    => fabase_data.packsegment_14,
                     x_packsegment_15                    => fabase_data.packsegment_15,
                     x_packsegment_16                    => fabase_data.packsegment_16,
                     x_packsegment_17                    => fabase_data.packsegment_17,
                     x_packsegment_18                    => fabase_data.packsegment_18,
                     x_packsegment_19                    => fabase_data.packsegment_19,
                     x_packsegment_20                    => fabase_data.packsegment_20,
                     x_miscstruct_id                     => fabase_data.miscstruct_id,
                     x_miscsegment_1                     => fabase_data.miscsegment_1,
                     x_miscsegment_2                     => fabase_data.miscsegment_2,
                     x_miscsegment_3                     => fabase_data.miscsegment_3,
                     x_miscsegment_4                     => fabase_data.miscsegment_4,
                     x_miscsegment_5                     => fabase_data.miscsegment_5,
                     x_miscsegment_6                     => fabase_data.miscsegment_6,
                     x_miscsegment_7                     => fabase_data.miscsegment_7,
                     x_miscsegment_8                     => fabase_data.miscsegment_8,
                     x_miscsegment_9                     => fabase_data.miscsegment_9,
                     x_miscsegment_10                    => fabase_data.miscsegment_10,
                     x_miscsegment_11                    => fabase_data.miscsegment_11,
                     x_miscsegment_12                    => fabase_data.miscsegment_12,
                     x_miscsegment_13                    => fabase_data.miscsegment_13,
                     x_miscsegment_14                    => fabase_data.miscsegment_14,
                     x_miscsegment_15                    => fabase_data.miscsegment_15,
                     x_miscsegment_16                    => fabase_data.miscsegment_16,
                     x_miscsegment_17                    => fabase_data.miscsegment_17,
                     x_miscsegment_18                    => fabase_data.miscsegment_18,
                     x_miscsegment_19                    => fabase_data.miscsegment_19,
                     x_miscsegment_20                    => fabase_data.miscsegment_20,
                     x_profile_status                    => g_cur_data.institutional_reporting_type ,
                     x_profile_status_date               => TRUNC(SYSDATE),
                     x_profile_fc                        => g_cur_data.im_inst_2_tot_family_cont,
                     x_tolerance_amount                  => fabase_data.tolerance_amount,
                     x_manual_disb_hold                  => fabase_data.manual_disb_hold,
                     x_pell_alt_expense                  => fabase_data.pell_alt_expense,
                     x_assoc_org_num                     => fabase_data.assoc_org_num,
                     x_award_fmly_contribution_type      => fabase_data.award_fmly_contribution_type,
                     x_isir_locked_by                    => fabase_data.isir_locked_by,
                     x_adnl_unsub_loan_elig_flag         => fabase_data.adnl_unsub_loan_elig_flag,
                     x_lock_awd_flag                     => fabase_data.lock_awd_flag,
                     x_lock_coa_flag                     => fabase_data.lock_coa_flag
           );
              END LOOP ;
        EXCEPTION
        WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.update_fa_base_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.UPDATE_FA_BASE_REC:');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.UPDATE_FA_BASE_REC:'||SQLERRM );
      app_exception.raise_exception;
   END update_fa_base_rec ;

PROCEDURE  unmatched_rec(p_apm_id  igf_ap_person_match_all.apm_id%TYPE) IS
 /*
  ||  Created By : vivuyyur
  ||  Created On : 11-JUN-2000
  ||  Purpose : To create fa_base_rec ,person_record,admission record for the unmatched record
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bkkumar         11-Aug-2003     Bug# 3084964 Added the check for the
  ||                                  HZ_GENERATE_PARTY_NUMBER profile value
  ||  (reverse chronological order - newest change first)
  */
  fabase_data            igf_ap_fa_base_rec%ROWTYPE ;
  lv_person_id           igf_ap_person_v.person_id%TYPE ;
  lv_base_id             igf_ap_fa_base_rec.base_id%TYPE ;
  lv_cssp_id             igf_ap_css_profile.cssp_id%TYPE ;
  lv_mesg_data           VARCHAR2(2000);


  --  Cursor to  update the record_status of igf_ap_person_match to unmatched
  CURSOR cur_person_match(p_apm_id igf_ap_person_match.apm_id%TYPE) IS
  SELECT   apm.*
    FROM   igf_ap_person_match apm
   WHERE  apm.apm_id = p_apm_id FOR UPDATE NOWAIT ;

BEGIN
   -- here the profile check needs to be added
    IF FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
      RAISE INVALID_PROFILE_ERROR;
    END IF;


   IF (g_force_add = 'Y')THEN
     -- Creation of Person record for the unmatched record
         create_person_record(pn_css_id     => g_cur_data.css_id,
                              pn_person_id  => lv_person_id,
                              pv_mesg_data  => lv_mesg_data,
                              p_called_from => 'PLSQL') ;

       IF lv_person_id IS NOT NULL THEN
         -- Incrementing the  total no of person  records created
         g_unmatched_added   :=  g_unmatched_added + 1;

         -- Creation of Person address record for the unmatched record
         IGF_AP_PROFILE_MATCHING_PKG.create_person_addr_record(pn_css_id       => g_cur_data.css_id,
                                                               pn_person_id    => lv_person_id ) ;

            --Creation of admission record to be checked
         IF NOT igf_ap_matching_process_pkg.check_ptyp_code(lv_person_id)  AND g_create_inquiry = 'Y' THEN
            create_admission_rec(p_person_id       =>    lv_person_id,
                                 p_batch_year      =>    g_cur_data.academic_year
                                 ) ;
         END IF;
         -- Create Email Address
         create_email_address(lv_person_id);
         -- Creation of fa_base_record
         create_fa_base_record(pn_css_id        =>   g_cur_data.css_id,
                               pn_person_id     =>   lv_person_id ,
                               pn_base_id       =>   lv_base_id
                               );
         -- Inserting the record into igf_ap_css_profile with system_record_type as 'ORIGINAL'
   g_active_profile := 'Y';
         process_todo_items(lv_base_id);
         IGF_AP_PROFILE_MATCHING_PKG.create_profile_matched(pn_css_id             =>   g_cur_data.css_id,
                                                            pn_cssp_id            =>   lv_cssp_id ,
                                                            pn_base_id            =>   lv_base_id ,
                                                            pn_system_record_type =>   'ORIGINAL'
                                                           );
         -- To insert  the record into igf_ap_css_fnar
         IGF_AP_PROFILE_MATCHING_PKG.create_fnar_data(pn_css_id   =>   g_cur_data.css_id,
                                                      pn_cssp_id  =>   lv_cssp_id
                                                      ) ;

         --Opening the cursor to update the record_status  field to MATCHED
         FOR person_data IN  cur_person_match(p_apm_id) LOOP
           -- procedure to update the record_status of igf_ap_person_match to 'MATCHED'
           igf_ap_person_match_pkg.update_row(
             x_rowid                    =>      person_data.row_id ,
             x_apm_id                   =>      person_data.apm_id ,
             x_css_id                   =>      person_data.css_id ,
             x_si_id                    =>    person_data.si_id ,
             x_record_type              =>    person_data.record_type,
             x_date_run                 =>      person_data.date_run ,
             x_ci_sequence_number       =>      person_data.ci_sequence_number ,
             x_ci_cal_type              =>    person_data.ci_cal_type ,
             x_record_status            =>    'MATCHED' ,
             x_mode                     =>      'R'
            );
         END LOOP ;
         --  PROCEDURE to update the record_status of igf_ap_css_interface to 'MATCHED'
         IGF_AP_PROFILE_MATCHING_PKG.update_css_interface(pn_css_id        =>   g_cur_data.css_id,
                                                          pv_record_status =>  'MATCHED',
                                                          pv_match_code    => g_match_code
                                                         );
          g_matched_rec := g_matched_rec + 1 ;
          -- To update the fields profile_status ,profile_status_datae ,profile_fc
          update_fa_base_rec(p_base_id    =>    lv_base_id );
          FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_FORCE_ADD');
          FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);

        ELSE
          --Opening the cursor to update the record_status  field to UNMATCHED
          FOR person_data IN  cur_person_match(p_apm_id) LOOP
            -- procedure to update the record_status of igf_ap_person_match to 'UNMATCHED'
            igf_ap_person_match_pkg.update_row(
              x_rowid                   => person_data.row_id ,
              x_apm_id                  => person_data.apm_id ,
              x_css_id                  => person_data.css_id ,
              x_si_id                   => person_data.si_id ,
              x_record_type             => person_data.record_type,
              x_date_run                => person_data.date_run ,
              x_ci_sequence_number      => person_data.ci_sequence_number ,
              x_ci_cal_type             => person_data.ci_cal_type ,
              x_record_status           => 'UNMATCHED' ,
              x_mode                    => 'R'
              );
          END LOOP ;
          --  PROCEDURE to update the record_status of igf_ap_css_interface to 'UNMATCHED'
          IGF_AP_PROFILE_MATCHING_PKG.update_css_interface(pn_css_id        =>   g_cur_data.css_id,
                                                           pv_record_status =>  'UNMATCHED',
                                                           pv_match_code    =>   g_match_code);
         END IF;
      ELSE
            -- Incrementing the umamatched recs ,these record_status is going to be 'UNMATCHED'
            g_unmatched_rec   := g_unmatched_rec + 1 ;

            --Opening the cursor to update the record_status  field to UNMATCHED
            FOR person_data IN  cur_person_match(p_apm_id)
            LOOP
               -- procedure to update the record_status of igf_ap_person_match to 'UNMATCHED'
               igf_ap_person_match_pkg.update_row(
                 x_rowid                => person_data.row_id ,
                 x_apm_id               => person_data.apm_id ,
                 x_css_id               => person_data.css_id ,
                 x_si_id                => person_data.si_id ,
                 x_record_type          => person_data.record_type,
                 x_date_run             => person_data.date_run ,
                 x_ci_sequence_number   => person_data.ci_sequence_number ,
                 x_ci_cal_type          => person_data.ci_cal_type ,
                 x_record_status        => 'UNMATCHED' ,
                 x_mode                 => 'R'
                 );
            END LOOP ;
            --  PROCEDURE to update the record_status of igf_ap_css_interface to 'UNMATCHED'
            IGF_AP_PROFILE_MATCHING_PKG.update_css_interface(pn_css_id        =>   g_cur_data.css_id,
                                                             pv_record_status =>  'UNMATCHED',
                                                             pv_match_code    =>   g_match_code
                                                             );
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_REC_STATUS');
            FND_MESSAGE.SET_TOKEN('STATUS','UNMATCHED');
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
       END IF;
  EXCEPTION
    WHEN SKIP_PERSON THEN
      RAISE SKIP_PERSON;
    WHEN INVALID_PROFILE_ERROR THEN
      RAISE INVALID_PROFILE_ERROR;
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.unmatched_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.unmatched_rec');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.unmatched_rec'|| SQLERRM);
      app_exception.raise_exception;
  END unmatched_rec ;

 PROCEDURE rvw_fa_rec(p_apm_id    igf_ap_person_match_all.apm_id%TYPE ) IS
        /*
  ||  Created By : vivuyyur
  ||  Created On : 11-JUN-2000
  ||  Purpose : To update the record_status of igf_ap_person_match,igf_ap_css_interface to review
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

        person_data       igf_ap_person_match%ROWTYPE ;

  --  Cursor to  update the record_status of igf_ap_person_match to review
  CURSOR cur_person_match(p_apm_id  igf_ap_person_match.apm_id%TYPE) IS
       SELECT  apm.*
       FROM   igf_ap_person_match apm
       WHERE  apm.apm_id = p_apm_id FOR UPDATE NOWAIT ;

        BEGIN
            FOR person_data IN cur_person_match(p_apm_id)
            LOOP

            --Procedure to update the record_status of igf_ap_person_match to review
               igf_ap_person_match_pkg.update_row(
                                      x_rowid               =>      person_data.row_id ,
                                      x_apm_id              =>      person_data.apm_id ,
                                      x_css_id              =>      person_data.css_id ,
                                      x_si_id               =>    person_data.si_id ,
                                      x_record_type         =>    person_data.record_type,
                                      x_date_run            =>      person_data.date_run ,
                                      x_ci_sequence_number  =>      person_data.ci_sequence_number ,
                                      x_ci_cal_type         =>    person_data.ci_cal_type ,
                                      x_record_status      =>    'REVIEW' ,
                                      x_mode      =>      'R'
                                          );
      END  LOOP ;

      --  PROCEDURE to update the record_status of igf_ap_css_interface to 'REVIEW'
            IGF_AP_PROFILE_MATCHING_PKG.update_css_interface(pn_css_id         =>     g_cur_data.css_id,
                                                             pv_record_status  =>    'REVIEW',
                                                             pv_match_code    =>   g_match_code
                                                             );
            g_total_rvw := g_total_rvw +1;

            FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_REC_STATUS');
            FND_MESSAGE.SET_TOKEN('STATUS','REVIEW');
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

      EXCEPTION
      WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.rvw_fa_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.rvw_fa_rec');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.rvw_fa_rec'|| SQLERRM);
      app_exception.raise_exception;
  END    rvw_fa_rec ;

 PROCEDURE auto_fa_rec(p_person_id  igf_ap_match_details.person_id%TYPE ,
                              p_apm_id     igf_ap_person_match_all.apm_id%TYPE,
                              p_cal_type   igf_ap_person_match_all.ci_cal_type%TYPE,
                              p_seq_num    igf_ap_person_match_all.ci_sequence_number%TYPE
                              )   IS

   /*
  ||  Created By : vivuyyur
  ||  Created On : 11-JUN-2000
  ||  Purpose : check whether the fa_base_record exitst ,if  not creates fa_base_record
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  person_data       igf_ap_person_match%ROWTYPE;
  css_profile_data  igf_ap_css_profile%ROWTYPE ;
  css_profile_data1 igf_ap_css_profile%ROWTYPE ;
  fabase_data       igf_ap_fa_base_rec%ROWTYPE ;
  lv_base_id        igf_ap_css_profile.base_id%TYPE ;
  lv_cssp_id        igf_ap_css_profile.cssp_id%TYPE ;
  fa_base_found     BOOLEAN ;

  --  Cursor to  update the record_status of igf_ap_person_match to matched
  CURSOR cur_person_match(p_apm_id  igf_ap_person_match.apm_id%TYPE) IS
         SELECT apm.*
         FROM   igf_ap_person_match apm
         WHERE  apm.apm_id = p_apm_id FOR UPDATE NOWAIT ;

  --  cursor to update the profile_status, profile_fc of igf_ap_fa_base_rec
        CURSOR cur_fabase(x_base_id  igf_ap_fa_base_rec.base_id%TYPE) IS
           SELECT *
             FROM   igf_ap_fa_base_rec
           WHERE  base_id = x_base_id ;

        -- cursor to update the active_profile of igf_ap_css_profile to 'N'
    CURSOR cur_css_profile(x_base_id  igf_ap_fa_base_rec.base_id%TYPE) IS
   SELECT *
     FROM   igf_ap_css_profile
     WHERE  base_id = x_base_id FOR UPDATE NOWAIT ;


  BEGIN
    fa_base_found  := IGF_AP_PROFILE_MATCHING_PKG.is_fa_base_record_present(pn_person_id       =>   p_person_id,
                                                                            pn_cal_type        =>   p_cal_type,
                                                                            pn_sequence_number =>   p_seq_num ,
                                                                            pn_base_id         =>   lv_base_id
                                                                          );
    IF NOT(fa_base_found)  THEN
      IGF_AP_PROFILE_MATCHING_PKG.create_fa_base_record(pn_css_id    =>   g_cur_data.css_id,
                                                        pn_person_id =>   p_person_id ,
                                                        pn_base_id   =>   lv_base_id
                                                       );
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_ISIR_FA_BASE_CREATED');
      FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);
    END  IF;
       -- Cursor  for updating the active_profile of all the old profile records of the student to 'N'
       make_profile_inactive(lv_base_id);
       g_active_profile := 'Y';
       --  To insert the record into igf_ap_css_profile
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.debug','Calling Method: create_profile_matched' );
        END IF;

        process_todo_items(lv_base_id);
       create_profile_matched(pn_css_id             =>   g_cur_data.css_id,
            pn_cssp_id            =>   lv_cssp_id ,
            pn_base_id            =>   lv_base_id ,
            pn_system_record_type =>   'ORIGINAL'
           );

       -- To Insert the record into igf_ap_css_fnar table.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.debug','Calling Method: create_fnar_data' );
        END IF;
       create_fnar_data(pn_css_id   =>   g_cur_data.css_id,
                        pn_cssp_id  =>   lv_cssp_id
                        ) ;


       -- To update the fields profile_status ,profile_status_date ,profile_fc
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.debug','Calling Method: update_fa_base_rec' );
        END IF;
       update_fa_base_rec(p_base_id    =>    lv_base_id );

       --  Added following call to update_person_info() as bug fix 3944249 (IGS.M)
       -- Update Email address
       update_person_info(p_person_id);

       -- Delete the detals from person match amd match details.
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.debug','Calling Method: igf_ap_profile_gen_pkg.delete_person_match' );
        END IF;
       igf_ap_profile_gen_pkg.delete_person_match ( p_css_id  => g_cur_data.css_id);

       --  PROCEDURE to update the record_status of igf_ap_css_interface to 'MATCHED'
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.debug','Calling Method: update_css_interface' );
        END IF;
       update_css_interface(pn_css_id        => g_cur_data.css_id,
                     pv_record_status => 'MATCHED',
                            pv_match_code    =>   g_match_code
                    );
       g_matched_rec := g_matched_rec + 1 ;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.auto_fa_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.auto_fa_rec');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.auto_fa_rec'|| SQLERRM);
      app_exception.raise_exception;
  END  auto_fa_rec ;

PROCEDURE perform_record_matching(p_out_apm_id OUT NOCOPY igf_ap_person_match_all.apm_id%TYPE)
IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 24-AUG-2004
  ||  Purpose :    Performs matching of interface record with person record in system.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */
   -- table definition
   TYPE RecTab             IS TABLE OF    VARCHAR2(30);
   TYPE PersonIdTab        IS TABLE OF    hz_parties.party_id%TYPE;
   TYPE ssntab             IS TABLE OF    igs_pe_alt_pers_id.api_person_id_uf%TYPE;
   TYPE firstnametab       IS TABLE OF    hz_parties.person_first_name%TYPE;
   TYPE lastnametab        IS TABLE OF    hz_parties.person_last_name%TYPE;
   TYPE addresstab         IS TABLE OF    hz_parties.address1%TYPE;
   TYPE citytab            IS TABLE OF    hz_parties.city%TYPE;
   TYPE postalcodetab      IS TABLE OF    hz_parties.postal_code%TYPE;
   TYPE emailaddresstab    IS TABLE OF    hz_parties.email_address%TYPE;
   TYPE dobtab             IS TABLE OF    hz_person_profiles.date_of_birth%TYPE;
   TYPE gendertab          IS TABLE OF    hz_person_profiles.gender%TYPE;
   TYPE totmatchscoretab   IS TABLE OF    NUMBER;

   t_rec_tab            RecTab;
   t_pid_tab            PersonIdTab;
   t_prsn_SSN           ssntab;
   t_first_name         firstnametab;
   t_last_name          lastnametab;
   t_address            addresstab;
   t_city               citytab;
   t_postal_code        postalcodetab;
   t_email_address      emailaddresstab;
   t_dob_tab            dobtab;
   t_gender             gendertab;
   t_tot_match_score    totmatchscoretab;

   match_details_rec    igf_ap_match_details%ROWTYPE;
   lv_rowid             VARCHAR2(30);
   lv_apm_id            igf_ap_person_match.apm_id%TYPE;
   lv_ssn      igf_ap_match_details.ssn_txt%TYPE;
   lv_fname    igf_ap_match_details.given_name_txt%TYPE;
   lv_lname    igf_ap_match_details.sur_name_txt%TYPE;
   l_fname_exact_match VARCHAR2(1);
   l_lname_exact_match VARCHAR2(1);
   lv_tot              NUMBER;

   l_process_rec       VARCHAR2(1);
   CURSOR check_oss_person_match(p_apm_id NUMBER, p_person_id NUMBER) IS
   SELECT 'Y'
     FROM igf_ap_match_details ad
    WHERE apm_id = p_apm_id
      AND person_id = p_person_id;

   oss_person_match_rec check_oss_person_match%ROWTYPE;
BEGIN
   -- First delete any existing match records.
  BEGIN
     igf_ap_profile_gen_pkg.delete_person_match ( p_css_id  => g_cur_data.css_id);
  EXCEPTION
    WHEN others THEN
     NULL;
  END;

      -- Inserting new student record into igf_ap_person_match table.
   lv_rowid := NULL;
   igf_ap_person_match_pkg.insert_row(
                    x_rowid                 => lv_rowid ,
                    x_apm_id                => p_out_apm_id,
                    x_css_id                => g_cur_data.css_id,
                    x_si_id                 => NULL ,
                    x_record_type           => 'PROFILE' ,
                    x_date_run              => TRUNC(SYSDATE),
                    x_ci_sequence_number    => g_ci_sequence_number ,
                    x_ci_cal_type           => g_ci_cal_type ,
                    x_record_status         => 'NEW' ,
                    x_mode                  => 'R');

   lv_ssn   :=  remove_spl_chr(g_cur_data.social_security_number) ;

      -- FNAME / GIVENNAME
   IF g_setup_score.given_name_mt_txt = 'EXACT' THEN
      l_fname_exact_match := 'Y';
      lv_fname := UPPER(TRIM(g_cur_data.first_name));

   ELSE
      l_fname_exact_match := 'N';
      lv_fname := '%' || UPPER(TRIM(g_cur_data.first_name)) || '%' ;

   END IF;

      -- LAST NAME / SURNAME
   IF g_setup_score.surname_mt_txt = 'EXACT' THEN
      l_lname_exact_match := 'Y';
      lv_lname := UPPER(TRIM(g_cur_data.last_name));

   ELSE
      l_lname_exact_match := 'N';
      lv_lname := '%' || UPPER(TRIM(g_cur_data.last_name)) || '%' ;

   END IF;
   SELECT rec_type,
          person_id,
          prsn_ssn,
          firstname,
          lastname,
          address,
          city,
          postal_code,
          email_address,
          date_of_birth,
          gender
   BULK COLLECT INTO
          t_rec_tab,
          t_pid_tab,
          t_prsn_ssn,
          t_first_name,
          t_last_name,
          t_address,
          t_city,
          t_postal_code,
          t_email_address,
          t_dob_tab,
          t_gender
   FROM
   (
          -- SSN matching records
          SELECT 'OSS' rec_type,
                hz.party_id person_id,
                api.api_person_id_uf prsn_ssn,  --Unformatted SSN value
                hz.person_first_name firstname,
                hz.person_last_name lastname,
                hz.address1 address,
                hz.city  city,
                hz.postal_code postal_code,
                hz.email_address email_address,
                hp.date_of_birth date_of_birth,
                hp.gender gender
           FROM ( SELECT apii.pe_person_id, apii.api_person_id_uf
                    FROM igs_pe_alt_pers_id apii, igs_pe_person_id_typ pit
                   WHERE apii.person_id_type = pit.person_id_type
                     AND pit.s_person_id_type = 'SSN'
                     AND SYSDATE BETWEEN apii.start_dt AND NVL (apii.end_dt, SYSDATE)) api,
                hz_parties hz,
                hz_person_profiles hp
          WHERE hz.party_id  = api.pe_person_id(+)
            AND hz.party_id  = hp.party_id
            AND hp.effective_end_date IS NULL
            AND (api.api_person_id_uf     = lv_ssn
                 -- First Name
                 OR (UPPER(hz.person_first_name)  =    UPPER(lv_fname) AND l_fname_exact_match = 'Y')
                 OR (UPPER(hz.person_first_name)  LIKE UPPER(lv_fname) AND l_fname_exact_match = 'N')
                 -- Last Name
                 OR (UPPER(hz.person_last_name)   =    UPPER(lv_lname) AND l_lname_exact_match = 'Y')
                 OR (UPPER(hz.person_last_name)   LIKE UPPER(lv_lname) AND l_lname_exact_match = 'N')
                )

   UNION
          --Source of SSN from HRMS
          SELECT 'HRM' rec_type,
                ppf.party_id person_id,  -- party id maps to HZ_parties.party_id
                remove_spl_chr(ppf.national_identifier) prsn_ssn,
                hz.person_first_name firstname,
                hz.person_last_name lastname,
                hz.address1 address,
                hz.city  city,
                hz.postal_code postal_code,
                hz.email_address email_address,
                hp.date_of_birth date_of_birth,
                hp.gender gender
           FROM per_all_people_f ppf,
                per_business_groups_perf pbg,
                per_person_types         ppt,
                hz_parties               hz,
                hz_person_profiles       hp
          WHERE IGS_EN_GEN_001.Check_HRMS_Installed = 'Y'
            AND pbg.legislation_code   = 'US'
            AND ppt.system_person_type = 'EMP'
            AND ppt.person_type_id     = ppf.person_type_id
            AND pbg.business_group_id  = ppf.business_group_id
            AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND ppf.party_id           = hz.party_id
            AND hz.party_id            = hp.party_id
            AND hp.effective_end_date IS NULL
            AND remove_spl_chr(ppf.national_identifier) = lv_ssn
   ) v_dataset ORDER BY 2        ;
   lv_tot := t_rec_tab.COUNT;

   FOR l_row IN 1..lv_tot
   LOOP
      l_process_rec := 'N'; -- initialize flag variable
      oss_person_match_rec := NULL;

      IF t_rec_tab(l_row) = 'OSS' THEN
         l_process_rec := 'Y'; -- process OSS matching records as usual.

      ELSE -- i.e. hrms match record for ssn
         -- this matching record is from HRMS. hence process only when SSN does not exist in OSS.
         OPEN check_oss_person_match(p_out_apm_id, t_pid_tab(l_row));
         FETCH check_oss_person_match INTO oss_person_match_rec;

         -- If rec found then ignore the record else process the record and insert into match table.
         IF check_oss_person_match%NOTFOUND THEN
            l_process_rec := 'Y';
         END IF;
         CLOSE check_oss_person_match;

      END IF; -- t_rec_tab

     IF l_process_rec = 'Y' THEN   -- process the record
         -- populate values into rec variable call for passing to process_match_person_rec proc
         match_details_rec.ssn_txt           := t_prsn_ssn(l_row);
         match_details_rec.given_name_txt    := t_first_name(l_row);
         match_details_rec.sur_name_txt      := t_last_name(l_row);
         match_details_rec.address_txt       := t_address(l_row);
         match_details_rec.city_txt          := t_city(l_row);
         match_details_rec.zip_txt           := t_postal_code(l_row);
         match_details_rec.email_id_txt      := t_email_address(l_row);
         match_details_rec.birth_date        := t_dob_tab(l_row);
         match_details_rec.gender_txt        := t_gender(l_row);

         -- call the procedure to match the attributes, compute score and insert rec into match details table
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.perform_record_matching.debug','Calling Method: calculate_match_score' );
           END IF;
           calculate_match_score(p_match_setup    =>  g_setup_score,
                                 p_match_dtls_rec =>  match_details_rec,
                                 p_apm_id         =>  p_out_apm_id,
                                 p_person_id      =>  t_pid_tab(l_row)
                             );

      END IF;

      IF check_oss_person_match%ISOPEN THEN
        CLOSE check_oss_person_match;
      END IF;
   END LOOP;
 EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.perform_record_matching.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_profile_matching_pkg.perform_record_matching');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      log_debug_message('igf_ap_profile_matching_pkg.perform_record_matching'|| SQLERRM);
      app_exception.raise_exception;
END perform_record_matching ;

PROCEDURE process_unidentified_isir_rec IS
  /*
  ||  Created By : rasahoo
  ||  Created On : 24-AUG-2004
  ||  Purpose :        For processing ISIR recs with pell match type as 'U' i.e.
  ||                   first isir for the student. Separate procedure is created for this
  ||                   for clarity as it has quite a lot of steps
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   -- Cursor to get the person_id with highest match_score for a particulare apm_id
   CURSOR cur_get_max_data(cp_apm_id  igf_ap_person_match.apm_id%TYPE) IS
   SELECT person_id,
          match_score
     FROM igf_ap_match_details
    WHERE apm_id = cp_apm_id
    ORDER BY match_score DESC;

   lv_person_id      igf_ap_match_details.person_id%TYPE;
   ln_match_score    igf_ap_match_details.match_score%TYPE;
   ln_apm_id         igf_ap_match_details.apm_id%TYPE;

  BEGIN
    -- Unidentified ISIR. Hence first need to perform person match.
    -- call procedure for performing person match.
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_unidentified_isir_rec.debug','calling method: perform_record_matching');
    END IF;
    perform_record_matching(p_out_apm_id  => ln_apm_id); -- OUT parameter

    ln_match_score := 0;
    -- get the person record with the highest match_score
    OPEN  cur_get_max_data(ln_apm_id);
    FETCH cur_get_max_data INTO lv_person_id, ln_match_score;
    CLOSE cur_get_max_data;

    g_person_id := lv_person_id;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_unidentified_isir_rec.debug','Match Score:' || TO_CHAR(ln_match_score));
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_unidentified_isir_rec.debug','Min Score for Auto Creation:' || TO_CHAR(g_setup_score.min_score_auto_fa));
    END IF;

    -- compare total score against the setup scores
    IF ln_match_score >= g_setup_score.min_score_auto_fa  THEN
      -- person is deemed as matched.
      auto_fa_rec(p_person_id  =>        g_person_id ,
                  p_apm_id     =>        ln_apm_id ,
                  p_cal_type   =>        g_ci_cal_type,
                  p_seq_num    =>        g_ci_sequence_number
                );

      fnd_message.set_name('IGF','IGF_AP_ISIR_AUTO_FA');
      fnd_file.put_line(fnd_file.log, fnd_message.get);

   ELSIF ln_match_score >= g_setup_score.min_score_rvw_fa THEN
    -- record status to be updated to review
    rvw_fa_rec(p_apm_id     =>   ln_apm_id);
   ELSE
    -- match_score is less than the min_score_rvw_fa and hence to be marked as UNMATCHED.
    unmatched_rec(p_apm_id  =>   ln_apm_id);
   END IF ;

  EXCEPTION
    WHEN SKIP_PERSON THEN
      RAISE SKIP_PERSON;
    WHEN INVALID_PROFILE_ERROR THEN
      RAISE INVALID_PROFILE_ERROR;
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.process_unidentified_isir_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_profile_matching_pkg.process_unidentified_isir_rec');
      igs_ge_msg_stack.add;
      FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get||' '||SQLERRM);
      log_debug_message('igf_ap_profile_matching_pkg.process_unidentified_isir_rec'|| SQLERRM);
      app_exception.raise_exception;
  END process_unidentified_isir_rec;

PROCEDURE process_old_new_dup_records IS

   /*
  ||  Created By : rasahoo
  ||  Created On : 24-Aug-2004
  ||  Purpose    : Process records of types Old, New and Duplicate
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  css_profile_data  igf_ap_css_profile%ROWTYPE ;
  css_profile_data1 igf_ap_css_profile%ROWTYPE ;
  lv_cssp_id        igf_ap_css_profile.cssp_id%TYPE ;
  fa_base_found     BOOLEAN ;

   --  Cursor to  update the record_status of igf_ap_person_match to matched
   CURSOR cur_person_match(p_apm_id  igf_ap_person_match.apm_id%TYPE) IS
   SELECT  apm.*
   FROM   igf_ap_person_match apm
   WHERE  apm.apm_id = p_apm_id FOR UPDATE NOWAIT ;


  -- cursor to update the active_profile of igf_ap_css_profile to 'N'
  CURSOR  cur_css_profile(x_base_id  igf_ap_fa_base_rec.base_id%TYPE) IS
  SELECT  *
    FROM  igf_ap_css_profile
   WHERE  base_id = x_base_id FOR UPDATE NOWAIT ;

  --cursor to get the person_id from base_id
  CURSOR cur_get_person_id(cp_base_id  igf_ap_fa_base_rec.base_id%TYPE)
  IS
  SELECT person_id
    FROM igf_ap_fa_base_rec_all
   WHERE base_id = cp_base_id ;

  l_person_id igf_ap_fa_base_rec.person_id%TYPE ;

  BEGIN
  l_person_id := NULL;
   IF g_rec_type = 'D' THEN

      -- print the message that the record already exists....
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROF_EXISTS');
      FND_FILE.PUT_LINE(fnd_file.log, fnd_message.get);
      g_duplicate_rec := g_duplicate_rec + 1;
   ELSIF g_rec_type = 'O' THEN

      g_active_profile :='N';
      --  To insert the record into igf_ap_css_profile
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.debug','Processing Old Rec:calling method: create_profile_matched');
      END IF;

      process_todo_items(g_base_id);
      create_profile_matched(pn_css_id             =>   g_cur_data.css_id,
      pn_cssp_id            =>   lv_cssp_id ,
      pn_base_id            =>   g_base_id ,
      pn_system_record_type =>   'ORIGINAL'
      );

      -- To Insert the record into igf_ap_css_fnar table.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.debug','Processing Old Rec:calling method: create_fnar_data');
      END IF;
      create_fnar_data(pn_css_id   =>   g_cur_data.css_id,
                    pn_cssp_id  =>   lv_cssp_id
                    ) ;

      g_matched_rec := g_matched_rec + 1 ;
   ELSIF g_rec_type = 'N' THEN
      --
      make_profile_inactive(g_base_id);
      g_active_profile := 'Y';
      --  To insert the record into igf_ap_css_profile
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.debug','Processing New Rec:calling method: create_profile_matched');
      END IF;

      process_todo_items(g_base_id);
      -- add the call for todo processing
      create_profile_matched(pn_css_id  =>   g_cur_data.css_id,
      pn_cssp_id            =>   lv_cssp_id ,
      pn_base_id            =>   g_base_id ,
      pn_system_record_type =>   'ORIGINAL'
      );

      -- To Insert the record into igf_ap_css_fnar table.
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.debug','Processing New Rec:calling method: create_fnar_data');
      END IF;
      create_fnar_data(pn_css_id   =>   g_cur_data.css_id,
                    pn_cssp_id  =>   lv_cssp_id
                   ) ;


      -- To update the fields profile_status ,profile_status_date ,profile_fc
      update_fa_base_rec(p_base_id    =>    g_base_id );

      --  Added following call to update_person_info() as bug fix 3944249 (IGS.M)
      -- Update Email address
      OPEN cur_get_person_id (g_base_id);
      FETCH cur_get_person_id INTO l_person_id;
      CLOSE cur_get_person_id;

      update_person_info(l_person_id);

      g_matched_rec := g_matched_rec + 1 ;
   END IF;

      --  PROCEDURE to update the record_status of igf_ap_css_interface to 'MATCHED'
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.debug','calling method: update_css_interface');
      END IF;
      update_css_interface(pn_css_id        => g_cur_data.css_id,
                           pv_record_status => 'MATCHED',
                           pv_match_code    =>   g_match_code
                           );

   EXCEPTION
      WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.process_old_new_dup_records.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.process_old_new_dup_records');
      IGS_GE_MSG_STACK.ADD;
      FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get||' '||SQLERRM);
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.process_old_new_dup_records'|| SQLERRM);
      app_exception.raise_exception;
  END  process_old_new_dup_records ;

PROCEDURE main(
          errbuf            OUT NOCOPY VARCHAR2,
          retcode           OUT NOCOPY NUMBER,
          p_org_id          IN NUMBER,
          p_award_year      IN VARCHAR2,
          p_force_add       IN VARCHAR2,
          p_create_inquiry  IN VARCHAR2,
          p_adm_source_type IN VARCHAR2,
          p_match_code      IN VARCHAR2,
          p_school_code     IN VARCHAR2
        )  IS
  /*
  ||  Created By : vivuyyur
  ||  Created On : 11-JUN-2000
  ||  Purpose : Does the matching process
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rasahoo         24-Aug-2004     FA-138: ISIR/PROFILE Enhancements.
  ||  masehgal        30-May-2002     # 2382216  Changed message to display SSN
  ||                                  instead of Person Name in the Import Process
  ||                                  Log File
  ||  masehgal        23-May-2002     # 2376750  Added match_records procedure.
        ||                                  Separated record matching from main
  ||            Added call to match_records for matching
  ||  masehgal        16-Apr-02       # 2320076  Modified data in output file
  ||  (reverse chronological order - newest change first)
  */


   CURSOR cur_school_cd(cp_school_cd igf_ap_css_interface.college_code%TYPE)  IS
   SELECT 'Y'
     FROM igf_ap_css_interface
    WHERE college_code = cp_school_cd
      AND rownum =1 ;

   CURSOR cur_match_set(cp_match_code igf_ap_record_match_all.match_code%TYPE)  IS
   SELECT 'Y'
     FROM igf_ap_record_match
    WHERE match_code = cp_match_code
      AND enabled_flag = 'Y';

   l_valid_found VARCHAR2(1);

CURSOR cur_css_id_number(cp_acad_year VARCHAR2, cp_css_id_number VARCHAR2) IS
SELECT max(STU_RECORD_TYPE) max_stu_record_type, base_id
  FROM igf_ap_css_profile
 WHERE TO_NUMBER(academic_year) = cp_acad_year
   AND  css_id_number = cp_css_id_number
   AND  STU_RECORD_TYPE <> 'M'
 GROUP BY base_id;

 rec_css_id_number cur_css_id_number%ROWTYPE;

-- Cursor to check duplicate
CURSOR cur_check_duplicate(cp_acad_year VARCHAR2, cp_css_id_number VARCHAR2,cp_stu_rec_type VARCHAR2) IS
SELECT 1
  FROM igf_ap_css_profile
 WHERE TO_NUMBER(academic_year) = cp_acad_year
   AND  css_id_number = cp_css_id_number
   AND  STU_RECORD_TYPE  = cp_stu_rec_type;
 l_duplicate NUMBER;
   -- Get all the newly imported records for doing the matching process.
  CURSOR cur_css_interface(cp_acad_year VARCHAR2,  cp_schoo_cd VARCHAR2)  IS
  SELECT *
    FROM igf_ap_css_interface
   WHERE record_status IN ('NEW','UNMATCHED','REVIEW')
     AND TO_NUMBER(academic_year) = cp_acad_year
     AND college_code= NVL(cp_schoo_cd, college_code);
   --  AND rownum <5  ;

  CURSOR cur_alt_code  ( x_ci_cal_type         igf_ap_fa_base_rec.ci_cal_type%TYPE ,
                         x_ci_sequence_number  igf_ap_fa_base_rec.ci_sequence_number%TYPE ) IS
  SELECT cal.alternate_code
    FROM igs_ca_inst cal
   WHERE cal.cal_type = x_ci_cal_type
     AND cal.sequence_number =  x_ci_sequence_number;

  CURSOR c_profile(cp_cal_type VARCHAR2,cp_seq_number NUMBER) IS
  SELECT css_academic_year
    FROM igf_ap_batch_aw_map_all
   WHERE ci_cal_type = cp_cal_type
     AND ci_sequence_number = cp_seq_number;

  -- Get ci_cal_type,ci_sequence_number from IGF_AP_BATCH_AW_MAP which maps to academic year of
  -- cur_css_interface.academic_year .
  CURSOR cur_batch_aw_map(lv_academic_year NUMBER) IS
  SELECT ci_cal_type,ci_sequence_number
    FROM igf_ap_batch_aw_map
   WHERE css_academic_year = lv_academic_year;

   --  Cursor to get the setup values from igf_ap_record_match
   CURSOR cur_setup_score(cp_match_code VARCHAR2) IS
   SELECT *
     FROM igf_ap_record_match
    WHERE match_code = cp_match_code;

   lv_apm_id      igf_ap_person_match.APM_ID%TYPE ;
   alt_code_rec   cur_alt_code%ROWTYPE;
   l_cal_type     igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
   l_seq_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
   l_profile_year igf_ap_batch_aw_map_all.css_academic_year%TYPE;
   l_profile      c_profile%ROWTYPE;
   INVALID_PARAMETER   EXCEPTION;

BEGIN
  igf_aw_gen.set_org_id(p_org_id);

  fnd_stats.gather_table_stats(ownname => 'IGF', tabname => 'IGF_AP_CSS_INTERFACE_ALL' , cascade => TRUE);

  l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10))) ;
  l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11))      ;


  OPEN   cur_alt_code(l_cal_type,l_seq_number);
  FETCH  cur_alt_code INTO alt_code_rec;

  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
  FND_MESSAGE.SET_NAME('IGF','IGF_AW_PROC_AWD');
  FND_MESSAGE.SET_TOKEN('AWD_YR',alt_code_rec.alternate_code);
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  OPEN c_profile(l_cal_type,l_seq_number) ;
  FETCH c_profile INTO l_profile;

  l_profile_year :=l_profile.css_academic_year;

   -- School Code validation
   IF p_school_code IS NOT NULL THEN

      OPEN cur_school_cd (p_school_code);
      FETCH cur_school_cd INTO l_valid_found;

      IF cur_school_cd%NOTFOUND THEN
         CLOSE cur_school_cd;
         fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
         fnd_message.set_token('PARAM_TYPE', 'SCHOOL CODE');
         igs_ge_msg_stack.add;
         RAISE INVALID_PARAMETER;
      END IF ;
      CLOSE cur_school_cd;
   END IF;

   -- Validate Match code parameter
   OPEN cur_setup_score (p_match_code) ;
   FETCH cur_setup_score INTO g_setup_score;

   IF cur_setup_score%NOTFOUND THEN
      CLOSE cur_setup_score ;
      fnd_message.set_name('IGF','IGF_AP_SETUP_SCORE_NOT_FOUND');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE INVALID_PARAMETER;
   END IF;
   CLOSE cur_setup_score ;

  -- getting the values of ci_cal_type,ci_sequence_number
  OPEN cur_batch_aw_map(TO_NUMBER(l_profile_year)) ;
  FETCH cur_batch_aw_map INTO g_ci_cal_type,g_ci_sequence_number ;
  IF cur_batch_aw_map%NOTFOUND THEN
    CLOSE cur_batch_aw_map ;
    FND_MESSAGE.SET_NAME('IGF','IGF_AP_BATCH_YEAR_NOT_FOUND');
    IGS_GE_MSG_STACK.ADD;
    RAISE INVALID_PARAMETER;
  END IF ;

  -- Copying the parameter values to the gobal variable.
  IF LTRIM(RTRIM(p_create_inquiry)) = 'Y' AND LTRIM(RTRIM(p_adm_source_type)) IS NULL THEN
    FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_SOURCE_TYPE_REQ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    RAISE INVALID_PARAMETER;
  END IF;


  --intializing the variables
  g_force_add            := p_force_add;
  g_create_inquiry       := p_create_inquiry;
  g_adm_source_type      := p_adm_source_type;
  g_match_code           := p_match_code;
  g_school_code          := p_school_code;
  g_total_processed      :=    0 ;
  g_matched_rec          :=    0 ;
  g_unmatched_rec        :=    0 ;
  g_unmatched_added      :=    0 ;
  g_bad_rec              :=    0 ;
  g_total_rvw            :=    0 ;
  g_duplicate_rec        :=    0 ;
  g_ci_cal_type          := l_cal_type;
  g_ci_sequence_number   := l_seq_number;
  g_profile_year         := l_profile_year;
  g_active_profile       := 'N';

  OPEN cur_css_interface(l_profile_year,g_school_code );
  LOOP
    FETCH cur_css_interface INTO g_cur_data;
    EXIT WHEN cur_css_interface%NOTFOUND;
    BEGIN

      SAVEPOINT IGFAP16_MAIN_SP1;
      FND_FILE.PUT_LINE(fnd_file.log,' ');
      FND_FILE.PUT_LINE(fnd_file.log,RPAD('*',50,'*'));
      FND_MESSAGE.SET_NAME ('IGF','IGF_AP_STUD_SSN_DTL');
      FND_MESSAGE.SET_TOKEN('NAME',g_cur_data.first_name||' '||g_cur_data.last_name );
      FND_MESSAGE.SET_TOKEN('SSN',g_cur_data.social_security_number );
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

      FND_MESSAGE.SET_NAME ('IGF','IGF_AP_STUD_PROF_DTL');
      FND_MESSAGE.SET_TOKEN('CNUM',g_cur_data.css_id_number);
      FND_MESSAGE.SET_TOKEN('SRTYPE',g_cur_data.STU_RECORD_TYPE);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);


      OPEN cur_css_id_number(l_profile_year,g_cur_data.css_id_number);
      FETCH cur_css_id_number INTO rec_css_id_number;
      CLOSE cur_css_id_number;

     IF NVL(rec_css_id_number.max_stu_record_type,'0') <> '0' THEN
          g_base_id := rec_css_id_number.base_id;
        IF (rec_css_id_number.max_stu_record_type = g_cur_data.STU_RECORD_TYPE) THEN
          g_rec_type := 'D';
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','Record type is : D - Duplicate' );
            END IF;

        ELSIF  (rec_css_id_number.max_stu_record_type < g_cur_data.STU_RECORD_TYPE) THEN
          g_rec_type := 'N';
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','Record type is : N - New' );
            END IF;
        ELSIF (rec_css_id_number.max_stu_record_type > g_cur_data.STU_RECORD_TYPE) THEN
           l_duplicate := NULL;
                 OPEN cur_check_duplicate(l_profile_year,g_cur_data.css_id_number,g_cur_data.STU_RECORD_TYPE);
           FETCH cur_check_duplicate INTO l_duplicate;
           CLOSE cur_check_duplicate;
         IF l_duplicate IS NULL THEN
            g_rec_type := 'O';
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','Record type is : O - Old' );
            END IF;
         ELSE
           g_rec_type := 'D';
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','Record type is : D - Duplicate' );
            END IF;
          END IF;

       END IF;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','calling method: process_old_new_dup_records' );
         END IF;
        process_old_new_dup_records;

      ELSE
         g_rec_type := 'U';
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','Record type is : U - Unidentified' );
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_profile_matching_pkg.main.debug','calling method: process_unidentified_isir_rec' );
         END IF;
        process_unidentified_isir_rec;

      END IF;
      -- Incrementing the total processed records
      g_total_processed   := g_total_processed + 1 ;
      COMMIT;
    EXCEPTION
      WHEN SKIP_PERSON THEN
        ROLLBACK TO IGFAP16_MAIN_SP1;
        FND_MESSAGE.SET_NAME('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line (FND_FILE.LOG, fnd_message.get);

      WHEN INVALID_PROFILE_ERROR THEN
        ROLLBACK TO IGFAP16_MAIN_SP1;
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.main.exception','The exception is :The profile option "HZ: Generate Party Number" is set to No.');
        END IF;
        fnd_message.set_name ('IGF','IGF_AP_HZ_GEN_PARTY_NUMBER');
        fnd_file.put_line (FND_FILE.LOG, fnd_message.get);
      WHEN OTHERS THEN
        ROLLBACK TO IGFAP16_MAIN_SP1; -- already error message is printed
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.main.exception','The exception in main inner begin others, for skipping student');
        END IF;
        log_debug_message ('igf.plsql.igf_ap_profile_matching_pkg.main.exception'|| SQLERRM);
    END;
  END LOOP;

  retcode := 0;
  FND_MESSAGE.SET_NAME('IGF','IGF_AP_TOTAL_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.')||TO_CHAR(g_total_processed));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_MATCHED_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_matched_rec));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_UNMATCHED_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_unmatched_rec));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_DUP_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_duplicate_rec));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_BAD_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_bad_rec));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_NEW_PER_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_unmatched_added));

  FND_MESSAGE.SET_NAME('IGF','IGF_AP_RVW_RECS');
  FND_MESSAGE.SET_TOKEN('COUNT','');
  FND_FILE.PUT_LINE(fnd_file.output,RPAD(FND_MESSAGE.GET,50,'.') || TO_CHAR(g_total_rvw));

    IF cur_css_interface%ISOPEN THEN
      CLOSE cur_css_interface;
    END IF;
    IF c_profile%ISOPEN THEN
      CLOSE c_profile;
    END IF;
    IF cur_alt_code%ISOPEN THEN
      CLOSE cur_alt_code;
    END IF;
    IF cur_setup_score%ISOPEN THEN
      CLOSE cur_setup_score;
    END IF;
    IF cur_batch_aw_map%ISOPEN THEN
      CLOSE cur_batch_aw_map;
    END IF;

EXCEPTION
  WHEN INVALID_PARAMETER THEN
    NULL; --bcoz message is already printed before raising

  WHEN others THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.main.exception','The exception is : ' || SQLERRM );
    END IF;
    IF cur_css_interface%ISOPEN THEN
      CLOSE cur_css_interface;
    END IF;
    IF c_profile%ISOPEN THEN
      CLOSE c_profile;
    END IF;
    IF cur_alt_code%ISOPEN THEN
      CLOSE cur_alt_code;
    END IF;
    IF cur_setup_score%ISOPEN  THEN
      CLOSE cur_setup_score;
    END IF;
    IF cur_batch_aw_map%ISOPEN THEN
      CLOSE cur_batch_aw_map;
    END IF;

    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.main');
    IGS_GE_MSG_STACK.ADD;
    retcode := 2;
    errbuf:= FND_MESSAGE.GET;
    rollback;
    FND_FILE.PUT_LINE(fnd_file.log,errbuf);
    igs_ge_msg_stack.conc_exception_hndl;

END main;

PROCEDURE ss_wrap_create_person_record (p_css_id  IN NUMBER)
  IS

  CURSOR cur_css_interface(cp_css_id IN NUMBER)  IS
  SELECT *
    FROM igf_ap_css_interface
   WHERE css_id = cp_css_id;

  CURSOR get_apm_id(cp_css_id NUMBER)
  IS
  SELECT apm_id
  FROM   igf_ap_person_match
  WHERE  css_id = cp_css_id;

      CURSOR cur_get_cal_sequence (cp_batch_year igf_ap_batch_aw_map.batch_year%TYPE) IS
      SELECT ibm.ci_cal_type, ibm.ci_sequence_number
        FROM IGF_AP_BATCH_AW_MAP ibm
       WHERE ibm.batch_year = cp_batch_year;

     rec_get_cal_sequence  cur_get_cal_sequence%ROWTYPE;

  l_apm_id NUMBER;

   BEGIN

    OPEN cur_css_interface(p_css_id);
    FETCH cur_css_interface INTO g_cur_data;
    CLOSE cur_css_interface;

      OPEN cur_get_cal_sequence (g_cur_data.academic_year);
    FETCH cur_get_cal_sequence INTO rec_get_cal_sequence;
    IF cur_get_cal_sequence%NOTFOUND THEN
      CLOSE cur_get_cal_sequence;
     -- x_return_status := 'E';
      RETURN;
    ELSE
      g_ci_cal_type := rec_get_cal_sequence.ci_cal_type;
      g_ci_sequence_number := rec_get_cal_sequence.ci_sequence_number;
      CLOSE cur_get_cal_sequence;
    END IF;

          g_force_add            := 'Y';
    g_create_inquiry       := 'N';
    g_adm_source_type      := 'N';
   -- g_match_code           := p_match_code;
    g_school_code          := NULL;
    g_total_processed      :=    0 ;
    g_matched_rec          :=    0 ;
    g_unmatched_rec        :=    0 ;
    g_unmatched_added      :=    0 ;
    g_bad_rec              :=    0 ;
    g_total_rvw            :=    0 ;
    g_duplicate_rec        :=    0 ;
    --g_profile_year         := l_profile_year;
    g_active_profile       := 'N';
    g_rec_type             := 'U';

    l_apm_id:= NULL;
    OPEN get_apm_id(p_css_id);
    FETCH get_apm_id INTO l_apm_id;
    CLOSE get_apm_id;

    unmatched_rec(l_apm_id);

 EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.unmatched_rec.exception','The exception is : ' || SQLERRM );
      END IF;
      log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.unmatched_rec'|| SQLERRM);
      app_exception.raise_exception;
END ss_wrap_create_person_record;


  PROCEDURE ss_wrap_refresh_matches(
                                    p_css_id     IN NUMBER,
                                    p_match_code IN VARCHAR2,
                                    p_batch_year IN NUMBER
                                   ) IS

    CURSOR cur_get_cal_sequence (cp_batch_year igf_ap_batch_aw_map.batch_year%TYPE) IS
    SELECT ibm.ci_cal_type, ibm.ci_sequence_number
      FROM IGF_AP_BATCH_AW_MAP ibm
     WHERE ibm.batch_year = cp_batch_year;

    rec_get_cal_sequence  cur_get_cal_sequence%ROWTYPE;

    CURSOR cur_css_interface(cp_css_id IN NUMBER)  IS
    SELECT *
      FROM igf_ap_css_interface
     WHERE css_id = cp_css_id;

    CURSOR cur_setup_score(cp_match_code VARCHAR2) IS
    SELECT *
      FROM igf_ap_record_match
     WHERE match_code = cp_match_code;

  BEGIN
    OPEN cur_get_cal_sequence (p_batch_year);
    FETCH cur_get_cal_sequence INTO rec_get_cal_sequence;
    IF cur_get_cal_sequence%NOTFOUND THEN
      CLOSE cur_get_cal_sequence;
     -- x_return_status := 'E';
      RETURN;
    ELSE
      g_ci_cal_type := rec_get_cal_sequence.ci_cal_type;
      g_ci_sequence_number := rec_get_cal_sequence.ci_sequence_number;
      CLOSE cur_get_cal_sequence;
    END IF;

    g_force_add            := 'N';
    g_create_inquiry       := 'N';
    g_adm_source_type      := 'N';
    g_match_code           := p_match_code;
    g_school_code          := NULL;
    g_total_processed      := 0 ;
    g_matched_rec          := 0 ;
    g_unmatched_rec        := 0 ;
    g_unmatched_added      := 0 ;
    g_bad_rec              := 0 ;
    g_total_rvw            := 0 ;
    g_duplicate_rec        := 0 ;
    --g_profile_year         := l_profile_year;
    g_active_profile       := 'N';
    g_rec_type             := 'U';

    OPEN cur_setup_score (p_match_code) ;
    FETCH cur_setup_score INTO g_setup_score;
    CLOSE cur_setup_score ;

    OPEN cur_css_interface(p_css_id);
    FETCH cur_css_interface INTO g_cur_data;
    CLOSE cur_css_interface;

    process_unidentified_isir_rec;

  EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.ss_wrap_refresh_matches.exception','The exception is : ' || SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_PROFILE_MATCHING_PKG.ss_wrap_refresh_matches');
      IGS_GE_MSG_STACK.ADD;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
       log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.ss_wrap_refresh_matches'||SQLERRM);
     -- app_exception.raise_exception;
  END ss_wrap_refresh_matches;

 PROCEDURE ss_wrap_create_base_record ( p_css_id        IN          NUMBER,
                                        p_person_id     IN          NUMBER,
                                        p_batch_year    IN          NUMBER)
  AS
      CURSOR cur_get_cal_sequence (cp_batch_year igf_ap_batch_aw_map.batch_year%TYPE) IS
      SELECT ibm.ci_cal_type, ibm.ci_sequence_number
        FROM IGF_AP_BATCH_AW_MAP ibm
       WHERE ibm.batch_year = cp_batch_year;
       rec_get_cal_sequence  cur_get_cal_sequence%ROWTYPE;

         CURSOR cur_css_interface(cp_css_id IN NUMBER)  IS
      SELECT *
        FROM igf_ap_css_interface
       WHERE css_id = cp_css_id;

  fabase_data            igf_ap_fa_base_rec%ROWTYPE ;
  lv_person_id           igf_ap_person_v.person_id%TYPE ;
  lv_base_id             igf_ap_fa_base_rec.base_id%TYPE ;
  lv_cssp_id             igf_ap_css_profile.cssp_id%TYPE ;
  lv_mesg_data           VARCHAR2(2000);

  BEGIN

    OPEN cur_get_cal_sequence (p_batch_year);
    FETCH cur_get_cal_sequence INTO rec_get_cal_sequence;
    IF cur_get_cal_sequence%NOTFOUND THEN
      CLOSE cur_get_cal_sequence;
     -- x_return_status := 'E';
      RETURN;
    ELSE
      g_ci_cal_type := rec_get_cal_sequence.ci_cal_type;
      g_ci_sequence_number := rec_get_cal_sequence.ci_sequence_number;
      CLOSE cur_get_cal_sequence;
    END IF;
    g_force_add            := 'N';
    g_create_inquiry       := 'N';
    g_adm_source_type      := 'N';
   -- g_match_code           := p_match_code;
    g_school_code          := NULL;
    g_total_processed      :=    0 ;
    g_matched_rec          :=    0 ;
    g_unmatched_rec        :=    0 ;
    g_unmatched_added      :=    0 ;
    g_bad_rec              :=    0 ;
    g_total_rvw            :=    0 ;
    g_duplicate_rec        :=    0 ;
    --g_profile_year         := l_profile_year;
    g_active_profile       := 'N';
    g_rec_type             := 'U';

      OPEN cur_css_interface(p_css_id);
     FETCH cur_css_interface INTO g_cur_data;
     CLOSE cur_css_interface;

  IF NOT igf_ap_profile_matching_pkg.is_fa_base_record_present  ( pn_person_id       =>   p_person_id,
                                                                  pn_cal_type        =>   g_ci_cal_type,
                                                                  pn_sequence_number =>   g_ci_sequence_number ,
                                                                  pn_base_id         =>   lv_base_id
                                                                 ) THEN

         -- Creation of fa_base_record
         create_fa_base_record(pn_css_id        =>   g_cur_data.css_id,
                               pn_person_id     =>   p_person_id ,
                               pn_base_id       =>   lv_base_id
                               );
  END IF;


         -- Inserting the record into igf_ap_css_profile with system_record_type as 'ORIGINAL'
   make_profile_inactive(lv_base_id);
   g_active_profile:= 'Y';
         process_todo_items(lv_base_id);
         IGF_AP_PROFILE_MATCHING_PKG.create_profile_matched(pn_css_id             =>   g_cur_data.css_id,
                                                            pn_cssp_id            =>   lv_cssp_id ,
                                                            pn_base_id            =>   lv_base_id ,
                                                            pn_system_record_type =>   'ORIGINAL'
                                                           );
         -- To insert  the record into igf_ap_css_fnar
         IGF_AP_PROFILE_MATCHING_PKG.create_fnar_data(pn_css_id   =>   g_cur_data.css_id,
                                                      pn_cssp_id  =>   lv_cssp_id
                                                      ) ;

         --  PROCEDURE to update the record_status of igf_ap_css_interface to 'MATCHED'
         IGF_AP_PROFILE_MATCHING_PKG.update_css_interface(pn_css_id        =>   g_cur_data.css_id,
                                                          pv_record_status =>  'MATCHED',
                                                          pv_match_code    =>   g_match_code
                                                         );
          -- To update the fields profile_status ,profile_status_datae ,profile_fc
          update_fa_base_rec(p_base_id    =>    lv_base_id );
   EXCEPTION
      WHEN others THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_matching_pkg.ss_wrap_create_base_record.exception','The exception is : ' || SQLERRM );
        END IF;
         log_debug_message('IGF_AP_PROFILE_MATCHING_PKG.ss_wrap_create_base_record'|| SQLERRM);
        app_exception.raise_exception;
 END ss_wrap_create_base_record;

PROCEDURE ss_wrap_upload_Profile ( p_css_id        IN          NUMBER,
                                   x_msg_data      OUT NOCOPY  VARCHAR2,
                                   x_return_status OUT NOCOPY  VARCHAR2
                            )
IS
  /*
  ||  Created By : ugummall
  ||  Created On : 05-Aug-2004
  ||  Purpose : This Procedure does the following tasks.
  ||          1. Upload the PROFILE record from interface table to profile table.
  ||          2. Update PROFILE interface record status to "MATCHED".
  ||          3. Deletes corresponding records in match details and person match table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  */

  -- cursor to check wether duplicate profile exists or not in the system.
  CURSOR cur_check_duplicate_profile  ( cp_css_id_number    igf_ap_css_interface_all.css_id%TYPE,
                                        cp_stu_record_type  igf_ap_css_interface_all.stu_record_type%TYPE,
                                        cp_academic_year    igf_ap_css_interface_all.academic_year%TYPE
                                      ) IS
    SELECT  1
      FROM  IGF_AP_CSS_PROFILE prof
     WHERE  prof.css_id_number  = cp_css_id_number
      AND   prof.stu_record_type  = cp_stu_record_type
      AND   prof.academic_year  = cp_academic_year;

  -- cursor to get interface record.
  CURSOR cur_interface_record ( cp_css_id   igf_ap_css_interface_all.css_id%TYPE) IS
    SELECT  intr.*
      FROM  IGF_AP_CSS_INTERFACE intr
     WHERE  intr.css_id = cp_css_id;

  -- Cursor to get all old profile records to make active profile to 'N'
  CURSOR cur_profile_records(cp_css_id_number igf_ap_css_profile.css_id_number%TYPE) IS
    SELECT  prof.*
      FROM  IGF_AP_CSS_PROFILE prof
     WHERE  prof.css_id_number = cp_css_id_number  FOR UPDATE NOWAIT;

  CURSOR cur_get_base_id(cp_css_id_number igf_ap_css_profile.css_id_number%TYPE) IS
    SELECT  prof.base_id
      FROM  IGF_AP_CSS_PROFILE prof
     WHERE  prof.css_id_number  = cp_css_id_number;

      CURSOR cur_get_cal_sequence (cp_batch_year igf_ap_batch_aw_map.batch_year%TYPE) IS
      SELECT ibm.ci_cal_type, ibm.ci_sequence_number
        FROM IGF_AP_BATCH_AW_MAP ibm
       WHERE ibm.batch_year = cp_batch_year;

     rec_get_cal_sequence  cur_get_cal_sequence%ROWTYPE;

  rec_check_duplicate_profile cur_check_duplicate_profile%ROWTYPE;
  rec_profile_records cur_profile_records%ROWTYPE;
  rec_get_base_id cur_get_base_id%ROWTYPE;
  l_base_id igf_ap_css_profile_all.base_id%TYPE;
  lv_rowid  NUMBER;
  pn_cssp_id  NUMBER;

BEGIN

  fnd_msg_pub.initialize;
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := '';

  -- Get interface record.
  OPEN cur_interface_record(p_css_id);
  FETCH cur_interface_record INTO g_cur_data;
  CLOSE cur_interface_record;

      OPEN cur_get_cal_sequence (g_cur_data.academic_year);
    FETCH cur_get_cal_sequence INTO rec_get_cal_sequence;
    IF cur_get_cal_sequence%NOTFOUND THEN
      CLOSE cur_get_cal_sequence;
     -- x_return_status := 'E';
      RETURN;
    ELSE
      g_ci_cal_type := rec_get_cal_sequence.ci_cal_type;
      g_ci_sequence_number := rec_get_cal_sequence.ci_sequence_number;
      CLOSE cur_get_cal_sequence;
    END IF;
    g_force_add            := 'N';
    g_create_inquiry       := 'N';
    g_adm_source_type      := 'N';
   -- g_match_code           := p_match_code;
    g_school_code          := NULL;
    g_total_processed      :=    0 ;
    g_matched_rec          :=    0 ;
    g_unmatched_rec        :=    0 ;
    g_unmatched_added      :=    0 ;
    g_bad_rec              :=    0 ;
    g_total_rvw            :=    0 ;
    g_duplicate_rec        :=    0 ;
    --g_profile_year         := l_profile_year;
    g_active_profile       := 'N';
    g_rec_type             := 'U';


  OPEN cur_check_duplicate_profile(g_cur_data.css_id_number, g_cur_data.stu_record_type, g_cur_data.academic_year);
  FETCH cur_check_duplicate_profile INTO rec_check_duplicate_profile;
  IF (cur_check_duplicate_profile%FOUND) THEN
   g_rec_type := 'D';
   fnd_message.set_name('IGF','IGF_AP_PROFILE_EXISTS');
   fnd_file.put_line(fnd_file.log, fnd_message.get);
   x_return_status := 'S';
  ELSE
   g_rec_type := 'N';
   fnd_message.set_name('IGF','IGF_AP_PROFILE_UPLOADED');
   x_msg_data := fnd_message.get;
   x_return_status := 'S';
  END IF;

  -- Process new or duplicate record
  process_old_new_dup_records;

EXCEPTION WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_profile_gen_pkg.ss_upload_profile.exception','The exception is : ' || SQLERRM );
  END IF;
  fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','igf_ap_profile_gen_pkg.ss_upload_profile');
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  igs_ge_msg_stack.add;
  x_return_status := 'E';
END ss_wrap_upload_Profile;




END IGF_AP_PROFILE_MATCHING_PKG;

/
