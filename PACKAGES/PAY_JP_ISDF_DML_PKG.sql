--------------------------------------------------------
--  DDL for Package PAY_JP_ISDF_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ISDF_DML_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpisfa.pkh 120.2.12000000.2 2007/09/20 02:33:22 keyazawa noship $ */
--
function next_action_information_id return number;
--
procedure lock_pact(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_pact_v%rowtype);
--
procedure lock_assact(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_assact_v%rowtype);
--
procedure lock_emp(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_emp_v%rowtype);
--
procedure lock_entry(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_entry_v%rowtype);
--
procedure lock_calc_dct(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_calc_dct_v%rowtype);
--
procedure lock_life_gen(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_life_gen_v%rowtype);
--
procedure lock_life_pens(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_life_pens_v%rowtype);
--
procedure lock_nonlife(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_nonlife_v%rowtype);
--
procedure lock_social(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_social_v%rowtype);
--
procedure lock_mutual_aid(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_mutual_aid_v%rowtype);
--
procedure lock_spouse(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_spouse_v%rowtype);
--
procedure lock_spouse_inc(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_spouse_inc_v%rowtype);
--
procedure create_pact(
  p_action_information_id       in number,
  p_payroll_action_id           in number,
  p_action_context_type         in varchar2,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_payroll_id                  in number,
  p_organization_id             in number,
  p_assignment_set_id           in number,
  p_submission_period_status    in varchar2,
  p_submission_start_date       in date,
  p_submission_end_date         in date,
  p_tax_office_name             in varchar2,
  p_salary_payer_name           in varchar2,
  p_salary_payer_address        in varchar2,
  p_object_version_number       out nocopy number);
--
procedure update_pact(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_submission_period_status    in varchar2,
  p_submission_start_date       in date,
  p_submission_end_date         in date,
  p_tax_office_name             in varchar2,
  p_salary_payer_name           in varchar2,
  p_salary_payer_address        in varchar2);
--
procedure create_assact(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_tax_type                    in varchar2,
  p_transaction_status          in varchar2,
  p_finalized_date              in date,
  p_finalized_by                in number,
  p_user_comments               in varchar2,
  p_admin_comments              in varchar2,
  p_transfer_status             in varchar2,
  p_transfer_date               in date,
  p_expiry_date                 in date,
  p_object_version_number       out nocopy number);
--
procedure update_assact(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_transaction_status          in varchar2,
  p_finalized_date              in date,
  p_finalized_by                in number,
  p_user_comments               in varchar2,
  p_admin_comments              in varchar2,
  p_transfer_status             in varchar2,
  p_transfer_date               in date,
  p_expiry_date                 in date);
--
procedure create_emp(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_employee_number             in varchar2,
  p_last_name_kana              in varchar2,
  p_first_name_kana             in varchar2,
  p_last_name                   in varchar2,
  p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_object_version_number       out nocopy number);
--
procedure update_emp(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_postal_code                 in varchar2,
  p_address                     in varchar2);
--
procedure create_entry(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_ins_datetrack_update_mode    in varchar2,
  p_ins_element_entry_id         in number,
  p_ins_ee_object_version_number in number,
  p_life_gen_ins_prem            in number,
  p_life_gen_ins_prem_o          in number,
  p_life_pens_ins_prem           in number,
  p_life_pens_ins_prem_o         in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_long_ins_prem_o      in number,
  p_nonlife_short_ins_prem       in number default null,
  p_nonlife_short_ins_prem_o     in number default null,
  p_earthquake_ins_prem          in number,
  p_earthquake_ins_prem_o        in number,
  p_is_datetrack_update_mode     in varchar2,
  p_is_element_entry_id          in number,
  p_is_ee_object_version_number  in number,
  p_social_ins_prem              in number,
  p_social_ins_prem_o            in number,
  p_mutual_aid_prem              in number,
  p_mutual_aid_prem_o            in number,
  p_spouse_income                in number,
  p_spouse_income_o              in number,
  p_national_pens_ins_prem       in number,
  p_national_pens_ins_prem_o     in number,
  p_object_version_number        out nocopy number);
--
procedure update_entry(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_life_gen_ins_prem           in number,
  p_life_gen_ins_prem_o         in number,
  p_life_pens_ins_prem          in number,
  p_life_pens_ins_prem_o        in number,
  p_nonlife_long_ins_prem       in number,
  p_nonlife_long_ins_prem_o     in number,
  p_nonlife_short_ins_prem      in number default null,
  p_nonlife_short_ins_prem_o    in number default null,
  p_earthquake_ins_prem         in number,
  p_earthquake_ins_prem_o       in number,
  p_social_ins_prem             in number,
  p_social_ins_prem_o           in number,
  p_mutual_aid_prem             in number,
  p_mutual_aid_prem_o           in number,
  p_spouse_income               in number,
  p_spouse_income_o             in number,
  p_national_pens_ins_prem      in number,
  p_national_pens_ins_prem_o    in number);
--
procedure create_calc_dct(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_life_gen_ins_prem            in number,
  p_life_pens_ins_prem           in number,
  p_life_gen_ins_calc_prem       in number,
  p_life_pens_ins_calc_prem      in number,
  p_life_ins_deduction           in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_short_ins_prem       in number default null,
  p_earthquake_ins_prem          in number,
  p_nonlife_long_ins_calc_prem   in number,
  p_nonlife_short_ins_calc_prem  in number default null,
  p_earthquake_ins_calc_prem     in number,
  p_nonlife_ins_deduction        in number,
  p_national_pens_ins_prem       in number,
  p_social_ins_deduction         in number,
  p_mutual_aid_deduction         in number,
  p_sp_earned_income_calc        in number,
  p_sp_business_income_calc      in number,
  p_sp_miscellaneous_income_calc in number,
  p_sp_dividend_income_calc      in number,
  p_sp_real_estate_income_calc   in number,
  p_sp_retirement_income_calc    in number,
  p_sp_other_income_calc         in number,
  p_sp_income_calc               in number,
  p_spouse_income                in number,
  p_spouse_deduction             in number,
  p_object_version_number        out nocopy number);
--
procedure update_calc_dct(
  p_action_information_id        in number,
  p_object_version_number        in out nocopy number,
  p_status                       in varchar2,
  p_life_gen_ins_prem            in number,
  p_life_pens_ins_prem           in number,
  p_life_gen_ins_calc_prem       in number,
  p_life_pens_ins_calc_prem      in number,
  p_life_ins_deduction           in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_short_ins_prem       in number default null,
  p_earthquake_ins_prem          in number,
  p_nonlife_long_ins_calc_prem   in number,
  p_nonlife_short_ins_calc_prem  in number default null,
  p_earthquake_ins_calc_prem     in number,
  p_nonlife_ins_deduction        in number,
  p_national_pens_ins_prem       in number,
  p_social_ins_deduction         in number,
  p_mutual_aid_deduction         in number,
  p_sp_earned_income_calc        in number,
  p_sp_business_income_calc      in number,
  p_sp_miscellaneous_income_calc in number,
  p_sp_dividend_income_calc      in number,
  p_sp_real_estate_income_calc   in number,
  p_sp_retirement_income_calc    in number,
  p_sp_other_income_calc         in number,
  p_sp_income_calc               in number,
  p_spouse_income                in number,
  p_spouse_deduction             in number);
--
procedure create_life_gen(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_gen_ins_class               in varchar2,
  p_gen_ins_company_code        in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number);
--
procedure update_life_gen(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number);
--
procedure delete_life_gen(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_life_pens(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_pens_ins_class              in varchar2,
  p_pens_ins_company_code       in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period_start_date       in date,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number);
--
procedure update_life_pens(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period_start_date       in date,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number);
--
procedure delete_life_pens(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_nonlife(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_nonlife_ins_class           in varchar2,
  p_nonlife_ins_term_type       in varchar2,
  p_nonlife_ins_company_code    in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_maturity_repayment          in varchar2 default null,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number);
--
procedure update_nonlife(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_nonlife_ins_term_type       in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_maturity_repayment          in varchar2 default null,
  p_annual_prem                 in number);
--
procedure delete_nonlife(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_social(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_ins_type                    in varchar2,
  p_ins_payee_name              in varchar2,
  p_debtor_name                 in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_national_pens_flag          in varchar2,
  p_object_version_number       out nocopy number);
--
procedure update_social(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_type                    in varchar2,
  p_ins_payee_name              in varchar2,
  p_debtor_name                 in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_national_pens_flag          in varchar2);
--
procedure delete_social(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_mutual_aid(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_enterprise_contract_prem    in number,
  p_pension_prem                in number,
  p_disable_sup_contract_prem   in number,
  p_object_version_number       out nocopy number);
--
procedure update_mutual_aid(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_enterprise_contract_prem    in number,
  p_pension_prem                in number,
  p_disable_sup_contract_prem   in number);
--
procedure delete_mutual_aid(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_spouse(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_full_name_kana              in varchar2,
  --p_last_name_kana              in varchar2,
  --p_first_name_kana             in varchar2,
  p_full_name                   in varchar2,
  --p_last_name                   in varchar2,
  --p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_emp_income                  in number,
  p_spouse_type                 in varchar2,
  p_widow_type                  in varchar2,
  p_spouse_dct_exclude          in varchar2,
  p_spouse_income_entry         in number,
  p_object_version_number       out nocopy number);
--
procedure update_spouse(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_full_name_kana              in varchar2,
  --p_last_name_kana              in varchar2,
  --p_first_name_kana             in varchar2,
  p_full_name                   in varchar2,
  --p_last_name                   in varchar2,
  --p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_emp_income                  in number,
  p_spouse_type                 in varchar2,
  p_widow_type                  in varchar2,
  p_spouse_dct_exclude          in varchar2,
  p_spouse_income_entry         in number);
--
procedure delete_spouse(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
procedure create_spouse_inc(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_sp_earned_income             in number,
  p_sp_earned_income_exp         in number,
  p_sp_business_income           in number,
  p_sp_business_income_exp       in number,
  p_sp_miscellaneous_income      in number,
  p_sp_miscellaneous_income_exp  in number,
  p_sp_dividend_income           in number,
  p_sp_dividend_income_exp       in number,
  p_sp_real_estate_income        in number,
  p_sp_real_estate_income_exp    in number,
  p_sp_retirement_income         in number,
  p_sp_retirement_income_exp     in number,
  p_sp_other_income              in number,
  p_sp_other_income_exp          in number,
  p_sp_other_income_exp_dct      in number,
  p_sp_other_income_exp_temp     in number,
  p_sp_other_income_exp_temp_exp in number,
  p_object_version_number        out nocopy number);
--
procedure update_spouse_inc(
  p_action_information_id        in number,
  p_object_version_number        in out nocopy number,
  p_status                       in varchar2,
  p_sp_earned_income             in number,
  p_sp_earned_income_exp         in number,
  p_sp_business_income           in number,
  p_sp_business_income_exp       in number,
  p_sp_miscellaneous_income      in number,
  p_sp_miscellaneous_income_exp  in number,
  p_sp_dividend_income           in number,
  p_sp_dividend_income_exp       in number,
  p_sp_real_estate_income        in number,
  p_sp_real_estate_income_exp    in number,
  p_sp_retirement_income         in number,
  p_sp_retirement_income_exp     in number,
  p_sp_other_income              in number,
  p_sp_other_income_exp          in number,
  p_sp_other_income_exp_dct      in number,
  p_sp_other_income_exp_temp     in number,
  p_sp_other_income_exp_temp_exp in number);
--
procedure delete_spouse_inc(
  p_action_information_id   in number,
  p_object_version_number   in number);
--
end pay_jp_isdf_dml_pkg;

 

/
