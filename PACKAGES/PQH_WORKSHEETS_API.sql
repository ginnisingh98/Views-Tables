--------------------------------------------------------
--  DDL for Package PQH_WORKSHEETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEETS_API" AUTHID CURRENT_USER as
/* $Header: pqwksapi.pkh 120.0 2005/05/29 03:00:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET >------------------------|
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
--   p_budget_id                    Yes  number
--   p_worksheet_name               Yes  varchar2
--   p_version_number               Yes  number
--   p_action_date                  Yes  date
--   p_date_from                    No   date
--   p_date_to                      No   date
--   p_worksheet_mode_cd            No   varchar2
--   p_transaction_status                       No   varchar2
--   p_budget_version_id            Yes  number
--   p_propagation_method           No   varchar2
--   p_effective_date           Yes  date      Session Date.
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_worksheet_id                 Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WORKSHEET
(
   p_validate                       in boolean    default false
  ,p_worksheet_id                   out nocopy number
  ,p_budget_id                      in  number
  ,p_worksheet_name                 in  varchar2
  ,p_version_number                 in  number
  ,p_action_date                    in  date
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_worksheet_mode_cd              in  varchar2  default null
  ,p_transaction_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_version_id              in  number
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date            in  date
  ,p_wf_transaction_category_id     in  number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET >------------------------|
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
--   p_worksheet_id                 Yes  number    PK of record
--   p_budget_id                    Yes  number
--   p_worksheet_name               Yes  varchar2
--   p_version_number               Yes  number
--   p_action_date                  Yes  date
--   p_date_from                    No   date
--   p_date_to                      No   date
--   p_worksheet_mode_cd            No   varchar2
--   p_transaction_status                       No   varchar2
--   p_budget_version_id            Yes  number
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
procedure update_WORKSHEET
  (
   p_validate                       in boolean    default false
  ,p_worksheet_id                   in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_worksheet_name                 in  varchar2  default hr_api.g_varchar2
  ,p_version_number                 in  number    default hr_api.g_number
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_worksheet_mode_cd              in  varchar2  default hr_api.g_varchar2
  ,p_transaction_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_version_id              in  number    default hr_api.g_number
  ,p_propagation_method             in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  ,p_wf_transaction_category_id     in  number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET >------------------------|
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
--   p_worksheet_id                 Yes  number    PK of record
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
procedure delete_WORKSHEET
  (
   p_validate                       in boolean        default false
  ,p_worksheet_id                   in number
  ,p_object_version_number          in number
  ,p_effective_date                 in date
  );
--
--
end pqh_WORKSHEETS_api;

 

/
