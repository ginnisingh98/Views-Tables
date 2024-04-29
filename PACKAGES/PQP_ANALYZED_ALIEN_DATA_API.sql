--------------------------------------------------------
--  DDL for Package PQP_ANALYZED_ALIEN_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ANALYZED_ALIEN_DATA_API" AUTHID CURRENT_USER as
/* $Header: pqaadapi.pkh 120.0 2005/05/29 01:39:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_analyzed_alien_data >------------------------|
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
--   p_assignment_id                Yes  number
--   p_data_source                  Yes  varchar2
--   p_tax_year                     Yes  number
--   p_current_residency_status     No   varchar2
--   p_nra_to_ra_date               No   date
--   p_target_departure_date        No   date
--   p_tax_residence_country_code   No   varchar2
--   p_treaty_info_update_date      No   date
--   p_number_of_days_in_usa        No   number
--   p_withldg_allow_eligible_flag  No   varchar2
--   p_ra_effective_date            No   date
--   p_record_source                No   varchar2
--   p_visa_type                    No   varchar2
--   p_j_sub_type                   No   varchar2
--   p_primary_activity             No   varchar2
--   p_non_us_country_code          No   varchar2
--   p_citizenship_country_code     No   varchar2
--   p_effective_date           Yes  date      Session Date.
--   p_date_8233_signed             No    date
--   p_date_w4_signed               No    date

--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_analyzed_data_id             Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_analyzed_alien_data
(
   p_validate                       in boolean    default false
  ,p_analyzed_data_id               out nocopy number
  ,p_assignment_id                  in  number    default null
  ,p_data_source                    in  varchar2  default null
  ,p_tax_year                       in  number    default null
  ,p_current_residency_status       in  varchar2  default null
  ,p_nra_to_ra_date                 in  date      default null
  ,p_target_departure_date          in  date      default null
  ,p_tax_residence_country_code     in  varchar2  default null
  ,p_treaty_info_update_date        in  date      default null
  ,p_number_of_days_in_usa          in  number    default null
  ,p_withldg_allow_eligible_flag    in  varchar2  default null
  ,p_ra_effective_date              in  date      default null
  ,p_record_source                  in  varchar2  default null
  ,p_visa_type                      in  varchar2  default null
  ,p_j_sub_type                     in  varchar2  default null
  ,p_primary_activity               in  varchar2  default null
  ,p_non_us_country_code            in  varchar2  default null
  ,p_citizenship_country_code       in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
  ,p_date_8233_signed               in  date      default null
  ,p_date_w4_signed                 in  date      default null

 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_analyzed_alien_data >------------------------|
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
--   p_analyzed_data_id             Yes  number    PK of record
--   p_assignment_id                Yes  number
--   p_data_source                  Yes  varchar2
--   p_tax_year                     Yes  number
--   p_current_residency_status     No   varchar2
--   p_nra_to_ra_date               No   date
--   p_target_departure_date        No   date
--   p_tax_residence_country_code   No   varchar2
--   p_treaty_info_update_date      No   date
--   p_number_of_days_in_usa        No   number
--   p_withldg_allow_eligible_flag  No   varchar2
--   p_ra_effective_date            No   date
--   p_record_source                No   varchar2
--   p_visa_type                    No   varchar2
--   p_j_sub_type                   No   varchar2
--   p_primary_activity             No   varchar2
--   p_non_us_country_code          No   varchar2
--   p_citizenship_country_code     No   varchar2
--   p_effective_date          Yes  date       Session Date.
--   p_date_8233_signed             No    date
--   p_date_w4_signed               No    date
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
procedure update_analyzed_alien_data
  (
   p_validate                       in boolean    default false
  ,p_analyzed_data_id               in  number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_data_source                    in  varchar2  default hr_api.g_varchar2
  ,p_tax_year                       in  number    default hr_api.g_number
  ,p_current_residency_status       in  varchar2  default hr_api.g_varchar2
  ,p_nra_to_ra_date                 in  date      default hr_api.g_date
  ,p_target_departure_date          in  date      default hr_api.g_date
  ,p_tax_residence_country_code     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_info_update_date        in  date      default hr_api.g_date
  ,p_number_of_days_in_usa          in  number    default hr_api.g_number
  ,p_withldg_allow_eligible_flag    in  varchar2  default hr_api.g_varchar2
  ,p_ra_effective_date              in  date      default hr_api.g_date
  ,p_record_source                  in  varchar2  default hr_api.g_varchar2
  ,p_visa_type                      in  varchar2  default hr_api.g_varchar2
  ,p_j_sub_type                     in  varchar2  default hr_api.g_varchar2
  ,p_primary_activity               in  varchar2  default hr_api.g_varchar2
  ,p_non_us_country_code            in  varchar2  default hr_api.g_varchar2
  ,p_citizenship_country_code       in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_date_8233_signed               in  date      default hr_api.g_date
  ,p_date_w4_signed                 in  date      default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_analyzed_alien_data >------------------------|
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
--   p_analyzed_data_id             Yes  number    PK of record
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
procedure delete_analyzed_alien_data
  (
   p_validate                       in boolean        default false
  ,p_analyzed_data_id               in  number
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
--   p_analyzed_data_id                 Yes  number   PK of record
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
    p_analyzed_data_id                 in number
   ,p_object_version_number        in number
  );
--
end pqp_analyzed_alien_data_api;

 

/
