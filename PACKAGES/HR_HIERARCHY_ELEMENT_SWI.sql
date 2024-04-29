--------------------------------------------------------
--  DDL for Package HR_HIERARCHY_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HIERARCHY_ELEMENT_SWI" AUTHID CURRENT_USER As
/* $Header: hroseswi.pkh 115.1 2002/12/03 00:35:32 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_hierarchy_element_api.create_hierarchy_element
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
PROCEDURE create_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id_parent       in     number
  ,p_org_structure_version_id     in     number
  ,p_organization_id_child        in     number
  ,p_business_group_id            in     number    default null
  ,p_effective_date               in     date
  ,p_date_from                    in     date
  ,p_security_profile_id          in     number
  ,p_view_all_orgs                in     varchar2
  ,p_end_of_time                  in     date
  ,p_hr_installed                 in     varchar2
  ,p_pa_installed                 in     varchar2
  ,p_pos_control_enabled_flag     in     varchar2
  ,p_warning_raised               in out nocopy varchar2
  ,p_org_structure_element_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_hierarchy_element_api.delete_hierarchy_element
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
PROCEDURE delete_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_org_structure_element_id     in     number
  ,p_object_version_number        in     number
  ,p_hr_installed                 in     varchar2
  ,p_pa_installed                 in     varchar2
  ,p_exists_in_hierarchy          in out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_hierarchy_element_api.update_hierarchy_element
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
PROCEDURE update_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_org_structure_element_id     in     number
  ,p_organization_id_parent       in     number    default hr_api.g_number
  ,p_organization_id_child        in     number    default hr_api.g_number
  ,p_pos_control_enabled_flag     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_hierarchy_element_swi;

 

/
