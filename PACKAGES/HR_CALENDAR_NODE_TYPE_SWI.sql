--------------------------------------------------------
--  DDL for Package HR_CALENDAR_NODE_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_NODE_TYPE_SWI" AUTHID CURRENT_USER As
/* $Header: hrpgtswi.pkh 115.0 2003/04/25 13:06:13 cxsimpso noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: HR_CALENDAR_NODE_TYPE_API.create_node_type
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
PROCEDURE create_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_hierarchy_type               in     varchar2
  ,p_child_node_name              in     varchar2
  ,p_child_value_set              in     varchar2
  ,p_child_node_type              in     varchar2  default null
  ,p_parent_node_type             in     varchar2  default null
  ,p_hier_node_type_id            in     number
  ,p_description                  in     varchar2  default null
  ,p_object_version_number           out nocopy  number
  ,p_return_status                   out nocopy  varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_node_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: HR_CALENDAR_NODE_TYPE_API.delete_node_type
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
PROCEDURE delete_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hier_node_type_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy  varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_node_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: HR_CALENDAR_NODE_TYPE_API.update_node_type
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
PROCEDURE update_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_hier_node_type_id            in     number
  ,p_object_version_number        in out nocopy  number
  ,p_child_node_name              in     varchar2  default hr_api.g_varchar2
  ,p_child_value_set              in     varchar2  default hr_api.g_varchar2
  ,p_parent_node_type             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy  varchar2
  );
end HR_CALENDAR_NODE_TYPE_SWI;

 

/
