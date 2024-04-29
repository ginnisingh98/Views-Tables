--------------------------------------------------------
--  DDL for Package PQP_ALIEN_TRANS_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ALIEN_TRANS_DATA_API" AUTHID CURRENT_USER as
/* $Header: pqatdapi.pkh 120.0 2005/05/29 01:42:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_alien_trans_data >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_person_id                    No   number   Added by Ashu Gupta
--   p_data_source_type             Yes  varchar2
--   p_tax_year                     No   number
--   p_income_code                  Yes  varchar2
--   p_withholding_rate             No   number
--   p_income_code_sub_type         No   varchar2
--   p_exemption_code               No   varchar2
--   p_maximum_benefit_amount       No   number
--   p_retro_lose_ben_amt_flag      No   varchar2
--   p_date_benefit_ends            No   date
--   p_retro_lose_ben_date_flag     No   varchar2
--   p_current_residency_status     No   varchar2
--   p_nra_to_ra_date               No   date
--   p_target_departure_date        No   date
--   p_tax_residence_country_code   No   varchar2
--   p_treaty_info_update_date      No   date
--   p_nra_exempt_from_fica         No   varchar2
--   p_student_exempt_from_fica     No   varchar2
--   p_addl_withholding_flag        No   varchar2
--   p_addl_withholding_amt         No   number
--   p_addl_wthldng_amt_period_type No   varchar2
--   p_personal_exemption           No   number
--   p_addl_exemption_allowed       No   number
--   p_number_of_days_in_usa        No   number
--   p_wthldg_allow_eligible_flag   No   varchar2
--   p_treaty_ben_allowed_flag      No   varchar2
--   p_treaty_benefits_start_date   No   date
--   p_ra_effective_date            No   date
--   p_state_code                   No   varchar2
--   p_state_honors_treaty_flag     No   varchar2
--   p_ytd_payments                 No   number
--   p_ytd_w2_payments              No   number
--   p_ytd_w2_withholding           No   number
--   p_ytd_withholding_allowance    No   number
--   p_ytd_treaty_payments          No   number
--   p_ytd_treaty_withheld_amt      No   number
--   p_record_source                No   varchar2
--   p_visa_type                    No   varchar2
--   p_j_sub_type                   No   varchar2
--   p_primary_activity             No   varchar2
--   p_non_us_country_code          No   varchar2
--   p_citizenship_country_code     No   varchar2
--   p_constant_addl_tax            No   number
--   p_date_8233_signed             No   date
--   p_date_w4_signed               No   date
--   p_error_indicator              No   varchar2
--   p_prev_er_treaty_benefit_amt   No   number
--   p_error_text                   No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_alien_transaction_id         Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_alien_trans_data
(
   p_validate                       in boolean    default false
  ,p_alien_transaction_id           out nocopy number
  ,p_person_id                      in  number    default null -- Added by Ashu
  ,p_data_source_type               in  varchar2  default null
  ,p_tax_year                       in  number    default null
  ,p_income_code                    in  varchar2  default null
  ,p_withholding_rate               in  number    default null
  ,p_income_code_sub_type           in  varchar2  default null
  ,p_exemption_code                 in  varchar2  default null
  ,p_maximum_benefit_amount         in  number    default null
  ,p_retro_lose_ben_amt_flag        in  varchar2  default null
  ,p_date_benefit_ends              in  date      default null
  ,p_retro_lose_ben_date_flag       in  varchar2  default null
  ,p_current_residency_status       in  varchar2  default null
  ,p_nra_to_ra_date                 in  date      default null
  ,p_target_departure_date          in  date      default null
  ,p_tax_residence_country_code     in  varchar2  default null
  ,p_treaty_info_update_date        in  date      default null
  ,p_nra_exempt_from_fica           in  varchar2  default null
  ,p_student_exempt_from_fica       in  varchar2  default null
  ,p_addl_withholding_flag          in  varchar2  default null
  ,p_addl_withholding_amt           in  number    default null
  ,p_addl_wthldng_amt_period_type   in  varchar2  default null
  ,p_personal_exemption             in  number    default null
  ,p_addl_exemption_allowed         in  number    default null
  ,p_number_of_days_in_usa          in  number    default null
  ,p_wthldg_allow_eligible_flag     in  varchar2  default null
  ,p_treaty_ben_allowed_flag        in  varchar2  default null
  ,p_treaty_benefits_start_date     in  date      default null
  ,p_ra_effective_date              in  date      default null
  ,p_state_code                     in  varchar2  default null
  ,p_state_honors_treaty_flag       in  varchar2  default null
  ,p_ytd_payments                   in  number    default null
  ,p_ytd_w2_payments                in  number    default null
  ,p_ytd_w2_withholding             in  number    default null
  ,p_ytd_withholding_allowance      in  number    default null
  ,p_ytd_treaty_payments            in  number    default null
  ,p_ytd_treaty_withheld_amt        in  number    default null
  ,p_record_source                  in  varchar2  default null
  ,p_visa_type                      in  varchar2  default null
  ,p_j_sub_type                     in  varchar2  default null
  ,p_primary_activity               in  varchar2  default null
  ,p_non_us_country_code            in  varchar2  default null
  ,p_citizenship_country_code       in  varchar2  default null
  ,p_constant_addl_tax              in  number    default null
  ,p_date_8233_signed               in  date      default null
  ,p_date_w4_signed                 in  date      default null
  ,p_error_indicator                in  varchar2  default null
  ,p_prev_er_treaty_benefit_amt     in  number    default null
  ,p_error_text                     in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_current_analysis               in  varchar2  default null
  ,p_forecast_income_code           in  varchar2  default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_alien_trans_data >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_alien_transaction_id         Yes  number    PK of record
--   p_person_id                    No   number    Added by Ashu Gupta
--   p_data_source_type             Yes  varchar2
--   p_tax_year                     No   number
--   p_income_code                  Yes  varchar2
--   p_withholding_rate             No   number
--   p_income_code_sub_type         No   varchar2
--   p_exemption_code               No   varchar2
--   p_maximum_benefit_amount       No   number
--   p_retro_lose_ben_amt_flag      No   varchar2
--   p_date_benefit_ends            No   date
--   p_retro_lose_ben_date_flag     No   varchar2
--   p_current_residency_status     No   varchar2
--   p_nra_to_ra_date               No   date
--   p_target_departure_date        No   date
--   p_tax_residence_country_code   No   varchar2
--   p_treaty_info_update_date      No   date
--   p_nra_exempt_from_fica         No   varchar2
--   p_student_exempt_from_fica     No   varchar2
--   p_addl_withholding_flag        No   varchar2
--   p_addl_withholding_amt         No   number
--   p_addl_wthldng_amt_period_type No   varchar2
--   p_personal_exemption           No   number
--   p_addl_exemption_allowed       No   number
--   p_number_of_days_in_usa        No   number
--   p_wthldg_allow_eligible_flag   No   varchar2
--   p_treaty_ben_allowed_flag      No   varchar2
--   p_treaty_benefits_start_date   No   date
--   p_ra_effective_date            No   date
--   p_state_code                   No   varchar2
--   p_state_honors_treaty_flag     No   varchar2
--   p_ytd_payments                 No   number
--   p_ytd_w2_payments              No   number
--   p_ytd_w2_withholding           No   number
--   p_ytd_withholding_allowance    No   number
--   p_ytd_treaty_payments          No   number
--   p_ytd_treaty_withheld_amt      No   number
--   p_record_source                No   varchar2
--   p_visa_type                    No   varchar2
--   p_j_sub_type                   No   varchar2
--   p_primary_activity             No   varchar2
--   p_non_us_country_code          No   varchar2
--   p_citizenship_country_code     No   varchar2
--   p_constant_addl_tax            No   number
--   p_date_8233_signed             No   date
--   p_date_w4_signed               No   date
--   p_error_indicator              No   varchar2
--   p_prev_er_treaty_benefit_amt   No   number
--   p_error_text                   No   varchar2
--   p_effective_date          Yes  date       Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_alien_trans_data
  (
   p_validate                       in boolean    default false
  ,p_alien_transaction_id           in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_data_source_type               in  varchar2  default hr_api.g_varchar2
  ,p_tax_year                       in  number    default hr_api.g_number
  ,p_income_code                    in  varchar2  default hr_api.g_varchar2
  ,p_withholding_rate               in  number    default hr_api.g_number
  ,p_income_code_sub_type           in  varchar2  default hr_api.g_varchar2
  ,p_exemption_code                 in  varchar2  default hr_api.g_varchar2
  ,p_maximum_benefit_amount         in  number    default hr_api.g_number
  ,p_retro_lose_ben_amt_flag        in  varchar2  default hr_api.g_varchar2
  ,p_date_benefit_ends              in  date      default hr_api.g_date
  ,p_retro_lose_ben_date_flag       in  varchar2  default hr_api.g_varchar2
  ,p_current_residency_status       in  varchar2  default hr_api.g_varchar2
  ,p_nra_to_ra_date                 in  date      default hr_api.g_date
  ,p_target_departure_date          in  date      default hr_api.g_date
  ,p_tax_residence_country_code     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_info_update_date        in  date      default hr_api.g_date
  ,p_nra_exempt_from_fica           in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_fica       in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_flag          in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_amt           in  number    default hr_api.g_number
  ,p_addl_wthldng_amt_period_type   in  varchar2  default hr_api.g_varchar2
  ,p_personal_exemption             in  number    default hr_api.g_number
  ,p_addl_exemption_allowed         in  number    default hr_api.g_number
  ,p_number_of_days_in_usa          in  number    default hr_api.g_number
  ,p_wthldg_allow_eligible_flag     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_ben_allowed_flag        in  varchar2  default hr_api.g_varchar2
  ,p_treaty_benefits_start_date     in  date      default hr_api.g_date
  ,p_ra_effective_date              in  date      default hr_api.g_date
  ,p_state_code                     in  varchar2  default hr_api.g_varchar2
  ,p_state_honors_treaty_flag       in  varchar2  default hr_api.g_varchar2
  ,p_ytd_payments                   in  number    default hr_api.g_number
  ,p_ytd_w2_payments                in  number    default hr_api.g_number
  ,p_ytd_w2_withholding             in  number    default hr_api.g_number
  ,p_ytd_withholding_allowance      in  number    default hr_api.g_number
  ,p_ytd_treaty_payments            in  number    default hr_api.g_number
  ,p_ytd_treaty_withheld_amt        in  number    default hr_api.g_number
  ,p_record_source                  in  varchar2  default hr_api.g_varchar2
  ,p_visa_type                      in  varchar2  default hr_api.g_varchar2
  ,p_j_sub_type                     in  varchar2  default hr_api.g_varchar2
  ,p_primary_activity               in  varchar2  default hr_api.g_varchar2
  ,p_non_us_country_code            in  varchar2  default hr_api.g_varchar2
  ,p_citizenship_country_code       in  varchar2  default hr_api.g_varchar2
  ,p_constant_addl_tax              in  number    default hr_api.g_number
  ,p_date_8233_signed               in  date      default hr_api.g_date
  ,p_date_w4_signed                 in  date      default hr_api.g_date
  ,p_error_indicator                in  varchar2  default hr_api.g_varchar2
  ,p_prev_er_treaty_benefit_amt     in  number    default hr_api.g_number
  ,p_error_text                     in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_current_analysis               in  varchar2  default hr_api.g_varchar2
  ,p_forecast_income_code           in  varchar2  default hr_api.g_varchar2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_alien_trans_data >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_alien_transaction_id         Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_alien_trans_data
  (
   p_validate                       in boolean        default false
  ,p_alien_transaction_id           in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_alien_transaction_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_alien_transaction_id                 in number
   ,p_object_version_number        in number
  );
--
end pqp_alien_trans_data_api;

 

/
