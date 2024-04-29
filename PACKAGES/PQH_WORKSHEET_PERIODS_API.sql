--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_PERIODS_API" AUTHID CURRENT_USER as
/* $Header: pqwprapi.pkh 120.0 2005/05/29 03:02:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_PERIOD >------------------------|
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
--   p_end_time_period_id           Yes  number
--   p_worksheet_detail_id          Yes  number
--   p_budget_unit1_percent         No   number
--   p_budget_unit2_percent         No   number
--   p_budget_unit3_percent         No   number
--   p_budget_unit1_value           No   number
--   p_budget_unit2_value           No   number
--   p_budget_unit3_value           No   number
--   p_budget_unit1_value_type_cd   No   varchar2
--   p_budget_unit2_value_type_cd   No   varchar2
--   p_budget_unit3_value_type_cd   No   varchar2
--   p_start_time_period_id         Yes  number
--   p_budget_unit3_available       No   number
--   p_budget_unit2_available       No   number
--   p_budget_unit1_available       No   number
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_worksheet_period_id          Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WORKSHEET_PERIOD
(
   p_validate                       in boolean    default false
  ,p_worksheet_period_id            out nocopy number
  ,p_end_time_period_id             in  number
  ,p_worksheet_detail_id            in  number
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_start_time_period_id           in  number
  ,p_budget_unit3_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_PERIOD >------------------------|
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
--   p_worksheet_period_id          Yes  number    PK of record
--   p_end_time_period_id           Yes  number
--   p_worksheet_detail_id          Yes  number
--   p_budget_unit1_percent         No   number
--   p_budget_unit2_percent         No   number
--   p_budget_unit3_percent         No   number
--   p_budget_unit1_value           No   number
--   p_budget_unit2_value           No   number
--   p_budget_unit3_value           No   number
--   p_budget_unit1_value_type_cd   No   varchar2
--   p_budget_unit2_value_type_cd   No   varchar2
--   p_budget_unit3_value_type_cd   No   varchar2
--   p_start_time_period_id         Yes  number
--   p_budget_unit3_available       No   number
--   p_budget_unit2_available       No   number
--   p_budget_unit1_available       No   number
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
procedure update_WORKSHEET_PERIOD
  (
   p_validate                       in boolean    default false
  ,p_worksheet_period_id            in  number
  ,p_end_time_period_id             in  number    default hr_api.g_number
  ,p_worksheet_detail_id            in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_start_time_period_id           in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_PERIOD >------------------------|
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
--   p_worksheet_period_id          Yes  number    PK of record
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
procedure delete_WORKSHEET_PERIOD
  (
   p_validate                       in boolean        default false
  ,p_worksheet_period_id            in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
--
end pqh_WORKSHEET_PERIODS_api;

 

/
