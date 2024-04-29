--------------------------------------------------------
--  DDL for Package HR_CAL_ENTRY_VALUE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ENTRY_VALUE_SWI" AUTHID CURRENT_USER As
/* $Header: hrenvswi.pkh 120.0 2005/05/31 00:09:05 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_cal_entry_value_api.create_entry_value
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
PROCEDURE create_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_calendar_entry_id            in     number
  ,p_hierarchy_node_id            in     number    default null
  ,p_value                        in     varchar2  default null
  ,p_org_structure_element_id     in     number    default null
  ,p_organization_id              in     number    default null
  ,p_override_name                in     varchar2  default null
  ,p_override_type                in     varchar2  default null
  ,p_parent_entry_value_id        in     number    default null
  ,p_cal_entry_value_id           in     number
  ,p_usage_flag                   in     varchar2
  ,p_identifier_key               in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_cal_entry_value_api.delete_entry_value
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
PROCEDURE delete_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_cal_entry_value_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_cal_entry_value_api.update_entry_value
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
PROCEDURE update_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_cal_entry_value_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_override_name                in     varchar2  default hr_api.g_varchar2
  ,p_override_type                in     varchar2  default hr_api.g_varchar2
  ,p_parent_entry_value_id        in     number    default hr_api.g_number
  ,p_usage_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end hr_cal_entry_value_swi;

 

/
