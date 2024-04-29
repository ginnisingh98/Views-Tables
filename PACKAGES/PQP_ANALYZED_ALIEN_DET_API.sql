--------------------------------------------------------
--  DDL for Package PQP_ANALYZED_ALIEN_DET_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ANALYZED_ALIEN_DET_API" AUTHID CURRENT_USER as
/* $Header: pqdetapi.pkh 120.0 2005/05/29 01:43:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_analyzed_alien_det >------------------------|
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
--   p_analyzed_data_id             Yes  number
--   p_income_code                  No   varchar2
--   p_withholding_rate             No   number
--   p_income_code_sub_type         No   varchar2
--   p_exemption_code               No   varchar2
--   p_maximum_benefit_amount       No   number
--   p_retro_lose_ben_amt_flag      No   varchar2
--   p_date_benefit_ends            No   date
--   p_retro_lose_ben_date_flag     No   varchar2
--   p_nra_exempt_from_ss           No   varchar2
--   p_nra_exempt_from_medicare     No   varchar2
--   p_student_exempt_from_ss       No   varchar2
--   p_student_exempt_from_medi     No   varchar2
--   p_addl_withholding_flag        No   varchar2
--   p_constant_addl_tax            No   number
--   p_addl_withholding_amt         No   number
--   p_addl_wthldng_amt_period_type No   varchar2
--   p_personal_exemption           No   number
--   p_addl_exemption_allowed       No   number
--   p_treaty_ben_allowed_flag      No   varchar2
--   p_treaty_benefits_start_date   No   date
--   p_effective_date               Yes  date      Session Date.
--   p_retro_loss_notification_sent No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_analyzed_data_details_id     Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_analyzed_alien_det
(
   p_validate                       in boolean    default false
  ,p_analyzed_data_details_id       out nocopy number
  ,p_analyzed_data_id               in  number    default null
  ,p_income_code                    in  varchar2  default null
  ,p_withholding_rate               in  number    default null
  ,p_income_code_sub_type           in  varchar2  default null
  ,p_exemption_code                 in  varchar2  default null
  ,p_maximum_benefit_amount         in  number    default null
  ,p_retro_lose_ben_amt_flag        in  varchar2  default null
  ,p_date_benefit_ends              in  date      default null
  ,p_retro_lose_ben_date_flag       in  varchar2  default null
  ,p_nra_exempt_from_ss             in  varchar2  default null
  ,p_nra_exempt_from_medicare       in  varchar2  default null
  ,p_student_exempt_from_ss         in  varchar2  default null
  ,p_student_exempt_from_medi       in  varchar2  default null
  ,p_addl_withholding_flag          in  varchar2  default null
  ,p_constant_addl_tax              in  number    default null
  ,p_addl_withholding_amt           in  number    default null
  ,p_addl_wthldng_amt_period_type   in  varchar2  default null
  ,p_personal_exemption             in  number    default null
  ,p_addl_exemption_allowed         in  number    default null
  ,p_treaty_ben_allowed_flag        in  varchar2  default null
  ,p_treaty_benefits_start_date     in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_retro_loss_notification_sent   in  varchar2 default null
  ,p_current_analysis               in  varchar2 default null
  ,p_forecast_income_code           in  varchar2 default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_analyzed_alien_det >------------------------|
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
--   p_analyzed_data_details_id     Yes  number    PK of record
--   p_analyzed_data_id             Yes  number
--   p_income_code                  No   varchar2
--   p_withholding_rate             No   number
--   p_income_code_sub_type         No   varchar2
--   p_exemption_code               No   varchar2
--   p_maximum_benefit_amount       No   number
--   p_retro_lose_ben_amt_flag      No   varchar2
--   p_date_benefit_ends            No   date
--   p_retro_lose_ben_date_flag     No   varchar2
--   p_nra_exempt_from_ss           No   varchar2
--   p_nra_exempt_from_medicare     No   varchar2
--   p_student_exempt_from_ss       No   varchar2
--   p_student_exempt_from_medi     No   varchar2
--   p_addl_withholding_flag        No   varchar2
--   p_constant_addl_tax            No   number
--   p_addl_withholding_amt         No   number
--   p_addl_wthldng_amt_period_type No   varchar2
--   p_personal_exemption           No   number
--   p_addl_exemption_allowed       No   number
--   p_treaty_ben_allowed_flag      No   varchar2
--   p_treaty_benefits_start_date   No   date
--   p_effective_date               Yes  date       Session Date.
--   p_retro_loss_notification_sent No   varchar2
--
-- Post Success:
--
--   Name                           Type           Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_analyzed_alien_det
  (
   p_validate                       in  boolean    default false
  ,p_analyzed_data_details_id       in  number
  ,p_analyzed_data_id               in  number    default hr_api.g_number
  ,p_income_code                    in  varchar2  default hr_api.g_varchar2
  ,p_withholding_rate               in  number    default hr_api.g_number
  ,p_income_code_sub_type           in  varchar2  default hr_api.g_varchar2
  ,p_exemption_code                 in  varchar2  default hr_api.g_varchar2
  ,p_maximum_benefit_amount         in  number    default hr_api.g_number
  ,p_retro_lose_ben_amt_flag        in  varchar2  default hr_api.g_varchar2
  ,p_date_benefit_ends              in  date      default hr_api.g_date
  ,p_retro_lose_ben_date_flag       in  varchar2  default hr_api.g_varchar2
  ,p_nra_exempt_from_ss             in  varchar2  default hr_api.g_varchar2
  ,p_nra_exempt_from_medicare       in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_ss         in  varchar2  default hr_api.g_varchar2
  ,p_student_exempt_from_medi       in  varchar2  default hr_api.g_varchar2
  ,p_addl_withholding_flag          in  varchar2  default hr_api.g_varchar2
  ,p_constant_addl_tax              in  number    default hr_api.g_number
  ,p_addl_withholding_amt           in  number    default hr_api.g_number
  ,p_addl_wthldng_amt_period_type   in  varchar2  default hr_api.g_varchar2
  ,p_personal_exemption             in  number    default hr_api.g_number
  ,p_addl_exemption_allowed         in  number    default hr_api.g_number
  ,p_treaty_ben_allowed_flag        in  varchar2  default hr_api.g_varchar2
  ,p_treaty_benefits_start_date     in  date      default hr_api.g_date
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_retro_loss_notification_sent   in  varchar2  default hr_api.g_varchar2
  ,p_current_analysis               in  varchar2  default hr_api.g_varchar2
  ,p_forecast_income_code           in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_analyzed_alien_det >------------------------|
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
--   p_analyzed_data_details_id     Yes  number   PK of record
--   p_effective_date               Yes  date     Session Date.
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
procedure delete_analyzed_alien_det
  (
   p_validate                       in boolean        default false
  ,p_analyzed_data_details_id       in number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
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
--   p_analyzed_data_details_id                 Yes  number   PK of record
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
    p_analyzed_data_details_id                 in number
   ,p_object_version_number        in number
  );
--
end pqp_analyzed_alien_det_api;

 

/
