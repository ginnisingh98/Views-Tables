--------------------------------------------------------
--  DDL for Package PQH_WORKSHEET_BDGT_ELMNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_WORKSHEET_BDGT_ELMNTS_API" AUTHID CURRENT_USER as
/* $Header: pqwelapi.pkh 120.0 2005/05/29 02:58:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_BDGT_ELMNT >------------------------|
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
--   p_worksheet_budget_set_id      Yes  number
--   p_element_type_id              Yes  number
--   p_distribution_percentage      No   number
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_worksheet_bdgt_elmnt_id      Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_WORKSHEET_BDGT_ELMNT
(
   p_validate                       in boolean    default false
  ,p_worksheet_bdgt_elmnt_id        out nocopy number
  ,p_worksheet_budget_set_id        in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_BDGT_ELMNT >------------------------|
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
--   p_worksheet_bdgt_elmnt_id      Yes  number    PK of record
--   p_worksheet_budget_set_id      Yes  number
--   p_element_type_id              Yes  number
--   p_distribution_percentage      No   number
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
procedure update_WORKSHEET_BDGT_ELMNT
  (
   p_validate                       in boolean    default false
  ,p_worksheet_bdgt_elmnt_id        in  number
  ,p_worksheet_budget_set_id        in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_BDGT_ELMNT >------------------------|
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
--   p_worksheet_bdgt_elmnt_id      Yes  number    PK of record
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
procedure delete_WORKSHEET_BDGT_ELMNT
  (
   p_validate                       in boolean        default false
  ,p_worksheet_bdgt_elmnt_id        in number
  ,p_object_version_number          in number
  );
--
--
end pqh_WORKSHEET_BDGT_ELMNTS_api;

 

/
