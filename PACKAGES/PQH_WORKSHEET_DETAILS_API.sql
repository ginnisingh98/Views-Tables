--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: pqwdtapi.pkh 120.1.12000000.1 2007/01/17 00:29:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_DETAIL >------------------------|
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
--   p_worksheet_id                 Yes  number
--   p_organization_id              No   number
--   p_job_id                       No   number
--   p_position_id                  No   number
--   p_grade_id                     No   number
--   p_position_transaction_id      No   number
--   p_budget_detail_id             No   number
--   p_parent_worksheet_detail_id   No   number
--   p_user_id                      No   number
--   p_action_cd                    No   varchar2
--   p_budget_unit1_percent         No   number
--   p_budget_unit1_value           No   number
--   p_budget_unit2_percent         No   number
--   p_budget_unit2_value           No   number
--   p_budget_unit3_percent         No   number
--   p_budget_unit3_value           No   number
--   p_budget_unit1_value_type_cd   No   varchar2
--   p_budget_unit2_value_type_cd   No   varchar2
--   p_budget_unit3_value_type_cd   No   varchar2
--   p_status                       No   varchar2
--   p_budget_unit1_available       No   number
--   p_budget_unit2_available       No   number
--   p_budget_unit3_available       No   number
--   p_old_unit1_value              No   number
--   p_old_unit2_value              No   number
--   p_old_unit3_value              No   number
--   p_defer_flag                   No   varchar2
--   p_propagation_method           No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_worksheet_detail_id          Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WORKSHEET_DETAIL
(
   p_validate                       in boolean    default false
  ,p_worksheet_detail_id            out nocopy number
  ,p_worksheet_id                   in  number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_budget_detail_id               in  number    default null
  ,p_parent_worksheet_detail_id     in  number    default null
  ,p_user_id                        in  number    default null
  ,p_action_cd                      in  varchar2  default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_old_unit1_value                in  number    default null
  ,p_old_unit2_value                in  number    default null
  ,p_old_unit3_value                in  number    default null
  ,p_defer_flag                     in  varchar2  default null
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date            in  date
 );
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

procedure create_WORKSHEET_DETAIL_BP
(
   p_validate                       in boolean    default false
  ,p_worksheet_detail_id            out nocopy number
  ,p_worksheet_id                   in  number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_budget_detail_id               in  number    default null
  ,p_parent_worksheet_detail_id     in  number    default null
  ,p_user_id                        in  number    default null
  ,p_action_cd                      in  varchar2  default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_old_unit1_value                in  number    default null
  ,p_old_unit2_value                in  number    default null
  ,p_old_unit3_value                in  number    default null
  ,p_defer_flag                     in  varchar2  default null
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_copy_budget_periods            in varchar2   default 'N'
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_DETAIL >------------------------|
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
--   p_worksheet_detail_id          Yes  number    PK of record
--   p_worksheet_id                 Yes  number
--   p_organization_id              No   number
--   p_job_id                       No   number
--   p_position_id                  No   number
--   p_grade_id                     No   number
--   p_position_transaction_id      No   number
--   p_budget_detail_id             No   number
--   p_parent_worksheet_detail_id   No   number
--   p_user_id                      No   number
--   p_action_cd                    No   varchar2
--   p_budget_unit1_percent         No   number
--   p_budget_unit1_value           No   number
--   p_budget_unit2_percent         No   number
--   p_budget_unit2_value           No   number
--   p_budget_unit3_percent         No   number
--   p_budget_unit3_value           No   number
--   p_budget_unit1_value_type_cd   No   varchar2
--   p_budget_unit2_value_type_cd   No   varchar2
--   p_budget_unit3_value_type_cd   No   varchar2
--   p_status                       No   varchar2
--   p_budget_unit1_available       No   number
--   p_budget_unit2_available       No   number
--   p_budget_unit3_available       No   number
--   p_old_unit1_value              No   number
--   p_old_unit2_value              No   number
--   p_old_unit3_value              No   number
--   p_defer_flag                   No   varchar2
--   p_propagation_method           No   varchar2
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
procedure update_WORKSHEET_DETAIL
  (
   p_validate                       in boolean    default false
  ,p_worksheet_detail_id            in  number
  ,p_worksheet_id                   in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_budget_detail_id               in  number    default hr_api.g_number
  ,p_parent_worksheet_detail_id     in  number    default hr_api.g_number
  ,p_user_id                        in  number    default hr_api.g_number
  ,p_action_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_old_unit1_value                in  number    default hr_api.g_number
  ,p_old_unit2_value                in  number    default hr_api.g_number
  ,p_old_unit3_value                in  number    default hr_api.g_number
  ,p_defer_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_propagation_method             in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_DETAIL >------------------------|
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
--   p_worksheet_detail_id          Yes  number    PK of record
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
procedure delete_WORKSHEET_DETAIL
  (
   p_validate                       in boolean        default false
  ,p_worksheet_detail_id            in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
--
end pqh_WORKSHEET_DETAILS_api;

 

/
