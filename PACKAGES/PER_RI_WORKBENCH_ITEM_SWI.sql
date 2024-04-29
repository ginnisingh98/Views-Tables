--------------------------------------------------------
--  DDL for Package PER_RI_WORKBENCH_ITEM_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_WORKBENCH_ITEM_SWI" AUTHID CURRENT_USER As
/* $Header: pewbiswi.pkh 115.0 2003/07/03 06:06:26 kavenkat noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_workbench_item >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_workbench_item_api.create_workbench_item
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
PROCEDURE create_workbench_item
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_item_code          in     varchar2
  ,p_workbench_item_name          in     varchar2
  ,p_workbench_item_description   in     varchar2
  ,p_menu_id                      in     number
  ,p_workbench_item_sequence      in     number
  ,p_workbench_parent_item_code   in     varchar2
  ,p_workbench_item_creation_date in     date
  ,p_workbench_item_type          in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_workbench_item >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_workbench_item_api.delete_workbench_item
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
PROCEDURE delete_workbench_item
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_item_code          in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_workbench_item >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_workbench_item_api.update_workbench_item
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
PROCEDURE update_workbench_item
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_item_code          in     varchar2
  ,p_workbench_item_name          in     varchar2  default hr_api.g_varchar2
  ,p_workbench_item_description   in     varchar2  default hr_api.g_varchar2
  ,p_menu_id                      in     number    default hr_api.g_number
  ,p_workbench_item_sequence      in     number    default hr_api.g_number
  ,p_workbench_parent_item_code   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_item_creation_date in     date      default hr_api.g_date
  ,p_workbench_item_type          in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_ri_workbench_item_swi;

 

/
