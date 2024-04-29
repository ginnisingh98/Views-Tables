--------------------------------------------------------
--  DDL for Package OTA_FORUM_THREAD_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_THREAD_SWI" AUTHID CURRENT_USER As
/* $Header: otftsswi.pkh 120.2 2005/09/20 14:36 asud noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_forum_thread >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_thread_api.create_forum_thread
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
PROCEDURE create_forum_thread
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_business_group_id            in     number
  ,p_subject                      in     varchar2
  ,p_private_thread_flag          in     varchar2
  ,p_last_post_date               in     date      default null
  ,p_reply_count                  in     number    default null
  ,p_forum_thread_id                 in  number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_forum_thread >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_thread_api.update_forum_thread
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
PROCEDURE update_forum_thread
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_business_group_id            in     number
  ,p_subject                      in     varchar2
  ,p_private_thread_flag          in     varchar2
  ,p_last_post_date               in     date      default hr_api.g_date
  ,p_reply_count                  in     number    default hr_api.g_number
  ,p_forum_thread_id              in  number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_forum_thread >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_thread_api.delete_forum_thread
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
PROCEDURE delete_forum_thread
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_thread_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_forum_thread_swi;

 

/
