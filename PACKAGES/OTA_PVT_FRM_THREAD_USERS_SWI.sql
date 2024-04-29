--------------------------------------------------------
--  DDL for Package OTA_PVT_FRM_THREAD_USERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PVT_FRM_THREAD_USERS_SWI" AUTHID CURRENT_USER As
/* $Header: otftuswi.pkh 120.1 2005/08/10 17:51 asud noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_pvt_frm_thread_user >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_pvt_frm_thread_users_api.create_pvt_frm_thread_user
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
PROCEDURE create_pvt_frm_thread_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_thread_id              in     number
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_business_group_id            in     number
  ,p_author_person_id             in     number    default null
  ,p_author_contact_id            in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_pvt_frm_thread_user >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_pvt_frm_thread_users_api.update_pvt_frm_thread_user
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
PROCEDURE update_pvt_frm_thread_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_thread_id              in     number
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_business_group_id            in     number
  ,p_author_person_id             in     number    default null
  ,p_author_contact_id            in     number    default null
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |----------------------< delete_pvt_frm_thread_user >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_pvt_frm_thread_users_api.delete_pvt_frm_thread_user
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
PROCEDURE delete_pvt_frm_thread_user
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_thread_id              in     number
  ,p_forum_id                     in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_pvt_frm_thread_users_swi;

 

/
