--------------------------------------------------------
--  DDL for Package OTA_FRM_OBJ_INCLUSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_OBJ_INCLUSION_SWI" AUTHID CURRENT_USER As
/* $Header: otfoiswi.pkh 120.1 2005/08/05 12:20 asud noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_frm_obj_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_frm_obj_inclusion_api.create_frm_obj_inclusion
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
PROCEDURE create_frm_obj_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_forum_id                     in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_frm_obj_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_frm_obj_inclusion_api.update_frm_obj_inclusion
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
PROCEDURE update_frm_obj_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_forum_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_frm_obj_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_frm_obj_inclusion_api.delete_frm_obj_inclusion
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
PROCEDURE delete_frm_obj_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_id                     in     number
  ,p_object_id                    in     number
  ,p_object_type                  in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_frm_obj_inclusion_swi;

 

/
