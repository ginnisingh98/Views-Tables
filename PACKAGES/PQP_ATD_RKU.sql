--------------------------------------------------------
--  DDL for Package PQP_ATD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ATD_RKU" AUTHID CURRENT_USER as
/* $Header: pqatdrhi.pkh 120.0.12010000.1 2008/07/28 11:08:00 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_alien_transaction_id           in number
 ,p_person_id                      in number
 ,p_data_source_type               in varchar2
 ,p_tax_year                       in number
 ,p_income_code                    in varchar2
 ,p_withholding_rate               in number
 ,p_income_code_sub_type           in varchar2
 ,p_exemption_code                 in varchar2
 ,p_maximum_benefit_amount         in number
 ,p_retro_lose_ben_amt_flag        in varchar2
 ,p_date_benefit_ends              in date
 ,p_retro_lose_ben_date_flag       in varchar2
 ,p_current_residency_status       in varchar2
 ,p_nra_to_ra_date                 in date
 ,p_target_departure_date          in date
 ,p_tax_residence_country_code     in varchar2
 ,p_treaty_info_update_date        in date
 ,p_nra_exempt_from_fica           in varchar2
 ,p_student_exempt_from_fica       in varchar2
 ,p_addl_withholding_flag          in varchar2
 ,p_addl_withholding_amt           in number
 ,p_addl_wthldng_amt_period_type   in varchar2
 ,p_personal_exemption             in number
 ,p_addl_exemption_allowed         in number
 ,p_number_of_days_in_usa          in number
 ,p_wthldg_allow_eligible_flag     in varchar2
 ,p_treaty_ben_allowed_flag        in varchar2
 ,p_treaty_benefits_start_date     in date
 ,p_ra_effective_date              in date
 ,p_state_code                     in varchar2
 ,p_state_honors_treaty_flag       in varchar2
 ,p_ytd_payments                   in number
 ,p_ytd_w2_payments                in number
 ,p_ytd_w2_withholding             in number
 ,p_ytd_withholding_allowance      in number
 ,p_ytd_treaty_payments            in number
 ,p_ytd_treaty_withheld_amt        in number
 ,p_record_source                  in varchar2
 ,p_visa_type                      in varchar2
 ,p_j_sub_type                     in varchar2
 ,p_primary_activity               in varchar2
 ,p_non_us_country_code            in varchar2
 ,p_citizenship_country_code       in varchar2
 ,p_constant_addl_tax              in number
 ,p_date_8233_signed               in date
 ,p_date_w4_signed                 in date
 ,p_error_indicator                in varchar2
 ,p_prev_er_treaty_benefit_amt     in number
 ,p_error_text                     in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_current_analysis               in varchar2
 ,p_forecast_income_code           in varchar2
 ,p_person_id_o                    in number
 ,p_data_source_type_o             in varchar2
 ,p_tax_year_o                     in number
 ,p_income_code_o                  in varchar2
 ,p_withholding_rate_o             in number
 ,p_income_code_sub_type_o         in varchar2
 ,p_exemption_code_o               in varchar2
 ,p_maximum_benefit_amount_o       in number
 ,p_retro_lose_ben_amt_flag_o      in varchar2
 ,p_date_benefit_ends_o            in date
 ,p_retro_lose_ben_date_flag_o     in varchar2
 ,p_current_residency_status_o     in varchar2
 ,p_nra_to_ra_date_o               in date
 ,p_target_departure_date_o        in date
 ,p_tax_residence_country_code_o   in varchar2
 ,p_treaty_info_update_date_o      in date
 ,p_nra_exempt_from_fica_o         in varchar2
 ,p_student_exempt_from_fica_o     in varchar2
 ,p_addl_withholding_flag_o        in varchar2
 ,p_addl_withholding_amt_o         in number
 ,p_addl_wthldng_amt_period_ty_o in varchar2
 ,p_personal_exemption_o           in number
 ,p_addl_exemption_allowed_o       in number
 ,p_number_of_days_in_usa_o        in number
 ,p_wthldg_allow_eligible_flag_o   in varchar2
 ,p_treaty_ben_allowed_flag_o      in varchar2
 ,p_treaty_benefits_start_date_o   in date
 ,p_ra_effective_date_o            in date
 ,p_state_code_o                   in varchar2
 ,p_state_honors_treaty_flag_o     in varchar2
 ,p_ytd_payments_o                 in number
 ,p_ytd_w2_payments_o              in number
 ,p_ytd_w2_withholding_o           in number
 ,p_ytd_withholding_allowance_o    in number
 ,p_ytd_treaty_payments_o          in number
 ,p_ytd_treaty_withheld_amt_o      in number
 ,p_record_source_o                in varchar2
 ,p_visa_type_o                    in varchar2
 ,p_j_sub_type_o                   in varchar2
 ,p_primary_activity_o             in varchar2
 ,p_non_us_country_code_o          in varchar2
 ,p_citizenship_country_code_o     in varchar2
 ,p_constant_addl_tax_o            in number
 ,p_date_8233_signed_o             in date
 ,p_date_w4_signed_o               in date
 ,p_error_indicator_o              in varchar2
 ,p_prev_er_treaty_benefit_amt_o   in number
 ,p_error_text_o                   in varchar2
 ,p_object_version_number_o        in number
 ,p_current_analysis_o             in  varchar2
 ,p_forecast_income_code_o         in  varchar2
  );
--
end pqp_atd_rku;

/
