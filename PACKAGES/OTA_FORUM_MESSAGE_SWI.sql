--------------------------------------------------------
--  DDL for Package OTA_FORUM_MESSAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_MESSAGE_SWI" AUTHID CURRENT_USER As
/* $Header: otfmsswi.pkh 120.2 2005/09/20 14:32 asud noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_message_api.create_forum_message
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
PROCEDURE create_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_forum_thread_id              in     number
  ,p_business_group_id            in     number
  ,p_message_scope                in     varchar2
  ,p_message_body                 in     varchar2  default null
  ,p_parent_message_id            in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_target_person_id             in     number    default null
  ,p_target_contact_id            in     number    default null
  ,p_forum_message_id                in  number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_message_api.update_forum_message
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--  p_object_version_number will return the new ovn
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_forum_thread_id              in     number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_message_scope                in     varchar2  default hr_api.g_varchar2
  ,p_message_body                 in     varchar2  default hr_api.g_varchar2
  ,p_parent_message_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_target_person_id             in     number    default hr_api.g_number
  ,p_target_contact_id            in     number    default hr_api.g_number
  ,p_forum_message_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_message_api.delete_forum_message
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
PROCEDURE delete_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_message_id             in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_forum_message_swi;

 

/
