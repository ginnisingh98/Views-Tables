--------------------------------------------------------
--  DDL for Package HR_CALENDAR_ENTRY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_ENTRY_SWI" AUTHID CURRENT_USER As
/* $Header: hrentswi.pkh 120.0 2005/05/31 00:08:26 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_calendar_entry_api.create_calendar_entry
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
PROCEDURE create_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_start_date                   in     date
  ,p_start_hour                   in     varchar2  default null
  ,p_start_min                    in     varchar2  default null
  ,p_end_date                     in     date
  ,p_end_hour                     in     varchar2  default null
  ,p_end_min                      in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_description                  in     varchar2  default null
  ,p_hierarchy_id                 in     number    default null
  ,p_value_set_id                 in     number    default null
  ,p_organization_structure_id    in     number    default null
  ,p_org_structure_version_id     in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_identifier_key               in     varchar2  default null
  ,p_calendar_entry_id            in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_calendar_entry_api.delete_calendar_entry
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
PROCEDURE delete_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_calendar_entry_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_calendar_entry_api.update_calendar_entry
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
PROCEDURE update_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_calendar_entry_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_start_hour                   in     varchar2  default hr_api.g_varchar2
  ,p_start_min                    in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_end_hour                     in     varchar2  default hr_api.g_varchar2
  ,p_end_min                      in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_hierarchy_id                 in     number    default hr_api.g_number
  ,p_value_set_id                 in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_business_group_id             in     number   default null
  ,p_return_status                   out nocopy varchar2
  );
end hr_calendar_entry_swi;

 

/
