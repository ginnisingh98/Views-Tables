--------------------------------------------------------
--  DDL for Package HR_POS_HIERARCHY_ELE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POS_HIERARCHY_ELE_SWI" AUTHID CURRENT_USER As
/* $Header: hrpseswi.pkh 115.2 2002/12/03 01:07:14 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pos_hierarchy_ele >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.create_pos_hierarchy_ele
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
PROCEDURE create_pos_hierarchy_ele
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_parent_position_id           in     number
  ,p_pos_structure_version_id     in     number
  ,p_subordinate_position_id      in     number
  ,p_business_group_id            in     number
  ,p_hr_installed                 in     varchar2
  ,p_effective_date               in     date
  ,p_pos_structure_element_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.create_pos_hier_elem_internal
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
PROCEDURE create_pos_hier_elem_internal
  (p_parent_position_id           in     number
  ,p_pos_structure_version_id     in     number
  ,p_subordinate_position_id      in     number
  ,p_business_group_id            in     number
  ,p_hr_installed                 in     varchar2
  ,p_effective_date               in     date
  ,p_pos_structure_element_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pos_hierarchy_ele >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.delete_pos_hierarchy_ele
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
PROCEDURE delete_pos_hierarchy_ele
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pos_structure_element_id     in     number
  ,p_object_version_number        in     number
  ,p_hr_installed                 in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.delete_pos_hier_elem_internal
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
PROCEDURE delete_pos_hier_elem_internal
  (p_pos_structure_element_id     in     number
  ,p_object_version_number        in     number
  ,p_hr_installed                 in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pos_hierarchy_ele >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.update_pos_hierarchy_ele
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
PROCEDURE update_pos_hierarchy_ele
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pos_structure_element_id     in     number
  ,p_effective_date               in     date
  ,p_parent_position_id           in     number    default hr_api.g_number
  ,p_subordinate_position_id      in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_pos_hierarchy_ele_api.update_pos_hier_elem_internal
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
PROCEDURE update_pos_hier_elem_internal
  (p_pos_structure_element_id     in     number
  ,p_parent_position_id           in     number    default hr_api.g_number
  ,p_subordinate_position_id      in     number    default hr_api.g_number
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_pos_hierarchy_ele_swi;

 

/
