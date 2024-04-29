--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_FUND_SRCS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_FUND_SRCS_API" AUTHID CURRENT_USER as
/* $Header: pqwfsapi.pkh 120.0 2005/05/29 02:59:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_FUND_SRC >------------------------|
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
--   p_worksheet_bdgt_elmnt_id      Yes  number
--   p_distribution_percentage      No   number
--   p_cost_allocation_keyflex_id   Yes  number
--   p_project_id                   No   number
--   p_award_id                     No   number
--   p_task_id                      No   number
--   p_expenditure_type             No   varchar
--   p_organization_id              No   number
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_worksheet_fund_src_id        Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WORKSHEET_FUND_SRC
(
   p_validate                       in boolean    default false
  ,p_worksheet_fund_src_id          out nocopy number
  ,p_worksheet_bdgt_elmnt_id        in  number
  ,p_distribution_percentage        in  number    default null
  ,p_cost_allocation_keyflex_id     in  number
  ,p_project_id                     in  number    default null
  ,p_award_id                       in  number    default null
  ,p_task_id                        in  number    default null
  ,p_expenditure_type               in  varchar2  default null
  ,p_organization_id                in  number    default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_FUND_SRC >------------------------|
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
--   p_worksheet_fund_src_id        Yes  number    PK of record
--   p_worksheet_bdgt_elmnt_id      Yes  number
--   p_distribution_percentage      No   number
--   p_cost_allocation_keyflex_id   Yes  number
--   p_project_id                   No   number
--   p_award_id                     No   number
--   p_task_id                      No   number
--   p_expenditure_type             No   varchar
--   p_organization_id              No   number
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
procedure update_WORKSHEET_FUND_SRC
  (
   p_validate                       in boolean    default false
  ,p_worksheet_fund_src_id          in  number
  ,p_worksheet_bdgt_elmnt_id        in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ,p_project_id                     in  number    default hr_api.g_number
  ,p_award_id                       in  number    default hr_api.g_number
  ,p_task_id                        in  number    default hr_api.g_number
  ,p_expenditure_type               in  varchar2  default hr_api.g_varchar2
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_FUND_SRC >------------------------|
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
--   p_worksheet_fund_src_id        Yes  number    PK of record
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
procedure delete_WORKSHEET_FUND_SRC
  (
   p_validate                       in boolean        default false
  ,p_worksheet_fund_src_id          in  number
  ,p_object_version_number          in number
  );
--
--
end pqh_WORKSHEET_FUND_SRCS_api;

 

/
