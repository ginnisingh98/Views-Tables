--------------------------------------------------------
--  DDL for Package PQH_RULE_SETS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_SETS_SWI" AUTHID CURRENT_USER As
/* $Header: pqrstswi.pkh 120.0 2005/05/29 02:39:28 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_sets_api.create_rule_set
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
PROCEDURE create_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default null
  ,p_rule_set_id                     out nocopy number
  ,p_rule_set_name                in     varchar2
  ,p_description		  in	 varchar2
  ,p_organization_structure_id    in     number    default null
  ,p_organization_id              in     number    default null
  ,p_referenced_rule_set_id       in     number    default null
  ,p_rule_level_cd                in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_short_name                   in     varchar2
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_rule_applicability           in     varchar2
  ,p_rule_category                in     varchar2
  ,p_starting_organization_id     in     number    default null
  ,p_seeded_rule_flag             in     varchar2  default 'N'
  ,p_status                       in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_sets_api.delete_rule_set
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
PROCEDURE delete_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_set_id                  in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rule_set >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_sets_api.update_rule_set
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
PROCEDURE update_rule_set
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_rule_set_id                  in     number
  ,p_rule_set_name                in     varchar2  default hr_api.g_varchar2
  ,p_description		  in 	 varchar2  default hr_api.g_varchar2
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_referenced_rule_set_id       in     number    default hr_api.g_number
  ,p_rule_level_cd                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_rule_applicability           in     varchar2  default hr_api.g_varchar2
  ,p_rule_category                in     varchar2  default hr_api.g_varchar2
  ,p_starting_organization_id     in     number    default hr_api.g_number
  ,p_seeded_rule_flag             in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_rule_sets_swi;

 

/
