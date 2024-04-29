--------------------------------------------------------
--  DDL for Package PQP_ALIEN_TRANS_DATA_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ALIEN_TRANS_DATA_BK1" AUTHID CURRENT_USER as
/* $Header: pqatdapi.pkh 120.0 2005/05/29 01:42:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_alien_trans_data_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_alien_trans_data_b
  (
   p_person_id                      in  number
  ,p_data_source_type               in  varchar2
  ,p_tax_year                       in  number
  ,p_income_code                    in  varchar2
  ,p_withholding_rate               in  number
  ,p_income_code_sub_type           in  varchar2
  ,p_exemption_code                 in  varchar2
  ,p_maximum_benefit_amount         in  number
  ,p_retro_lose_ben_amt_flag        in  varchar2
  ,p_date_benefit_ends              in  date
  ,p_retro_lose_ben_date_flag       in  varchar2
  ,p_current_residency_status       in  varchar2
  ,p_nra_to_ra_date                 in  date
  ,p_target_departure_date          in  date
  ,p_tax_residence_country_code     in  varchar2
  ,p_treaty_info_update_date        in  date
  ,p_nra_exempt_from_fica           in  varchar2
  ,p_student_exempt_from_fica       in  varchar2
  ,p_addl_withholding_flag          in  varchar2
  ,p_addl_withholding_amt           in  number
  ,p_addl_wthldng_amt_period_type   in  varchar2
  ,p_personal_exemption             in  number
  ,p_addl_exemption_allowed         in  number
  ,p_number_of_days_in_usa          in  number
  ,p_wthldg_allow_eligible_flag     in  varchar2
  ,p_treaty_ben_allowed_flag        in  varchar2
  ,p_treaty_benefits_start_date     in  date
  ,p_ra_effective_date              in  date
  ,p_state_code                     in  varchar2
  ,p_state_honors_treaty_flag       in  varchar2
  ,p_ytd_payments                   in  number
  ,p_ytd_w2_payments                in  number
  ,p_ytd_w2_withholding             in  number
  ,p_ytd_withholding_allowance      in  number
  ,p_ytd_treaty_payments            in  number
  ,p_ytd_treaty_withheld_amt        in  number
  ,p_record_source                  in  varchar2
  ,p_visa_type                      in  varchar2
  ,p_j_sub_type                     in  varchar2
  ,p_primary_activity               in  varchar2
  ,p_non_us_country_code            in  varchar2
  ,p_citizenship_country_code       in  varchar2
  ,p_constant_addl_tax              in  number
  ,p_date_8233_signed               in  date
  ,p_date_w4_signed                 in  date
  ,p_error_indicator                in  varchar2
  ,p_prev_er_treaty_benefit_amt     in  number
  ,p_error_text                     in  varchar2
  ,p_effective_date                 in  date
  ,p_current_analysis               in  varchar2
  ,p_forecast_income_code           in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_alien_trans_data_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_alien_trans_data_a
  (
   p_alien_transaction_id           in  number
  ,p_person_id                      in  number
  ,p_data_source_type               in  varchar2
  ,p_tax_year                       in  number
  ,p_income_code                    in  varchar2
  ,p_withholding_rate               in  number
  ,p_income_code_sub_type           in  varchar2
  ,p_exemption_code                 in  varchar2
  ,p_maximum_benefit_amount         in  number
  ,p_retro_lose_ben_amt_flag        in  varchar2
  ,p_date_benefit_ends              in  date
  ,p_retro_lose_ben_date_flag       in  varchar2
  ,p_current_residency_status       in  varchar2
  ,p_nra_to_ra_date                 in  date
  ,p_target_departure_date          in  date
  ,p_tax_residence_country_code     in  varchar2
  ,p_treaty_info_update_date        in  date
  ,p_nra_exempt_from_fica           in  varchar2
  ,p_student_exempt_from_fica       in  varchar2
  ,p_addl_withholding_flag          in  varchar2
  ,p_addl_withholding_amt           in  number
  ,p_addl_wthldng_amt_period_type   in  varchar2
  ,p_personal_exemption             in  number
  ,p_addl_exemption_allowed         in  number
  ,p_number_of_days_in_usa          in  number
  ,p_wthldg_allow_eligible_flag     in  varchar2
  ,p_treaty_ben_allowed_flag        in  varchar2
  ,p_treaty_benefits_start_date     in  date
  ,p_ra_effective_date              in  date
  ,p_state_code                     in  varchar2
  ,p_state_honors_treaty_flag       in  varchar2
  ,p_ytd_payments                   in  number
  ,p_ytd_w2_payments                in  number
  ,p_ytd_w2_withholding             in  number
  ,p_ytd_withholding_allowance      in  number
  ,p_ytd_treaty_payments            in  number
  ,p_ytd_treaty_withheld_amt        in  number
  ,p_record_source                  in  varchar2
  ,p_visa_type                      in  varchar2
  ,p_j_sub_type                     in  varchar2
  ,p_primary_activity               in  varchar2
  ,p_non_us_country_code            in  varchar2
  ,p_citizenship_country_code       in  varchar2
  ,p_constant_addl_tax              in  number
  ,p_date_8233_signed               in  date
  ,p_date_w4_signed                 in  date
  ,p_error_indicator                in  varchar2
  ,p_prev_er_treaty_benefit_amt     in  number
  ,p_error_text                     in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_current_analysis               in  varchar2
  ,p_forecast_income_code           in  varchar2
);
--
end pqp_alien_trans_data_bk1;

 

/
