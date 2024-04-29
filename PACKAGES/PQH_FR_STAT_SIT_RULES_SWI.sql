--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SIT_RULES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SIT_RULES_SWI" AUTHID CURRENT_USER As
/* $Header: pqstrswi.pkh 115.0 2003/10/15 12:14 svorugan noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_sit_rules_api.create_stat_situation_rule
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_statutory_situation_id       in     number
  ,p_processing_sequence          in     number
  ,p_txn_category_attribute_id    in     number
  ,p_from_value                   in     varchar2
  ,p_to_value                     in     varchar2  default null
  ,p_enabled_flag                 in     varchar2  default null
  ,p_required_flag                in     varchar2  default null
  ,p_exclude_flag                 in     varchar2  default null
  ,p_stat_situation_rule_id          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_sit_rules_api.delete_stat_situation_rule
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_stat_situation_rule_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_sit_rules_api.update_stat_situation_rule
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_stat_situation_rule_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_statutory_situation_id       in     number    default hr_api.g_number
  ,p_processing_sequence          in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_from_value                   in     varchar2  default hr_api.g_varchar2
  ,p_to_value                     in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_exclude_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_fr_stat_sit_rules_swi;

 

/
