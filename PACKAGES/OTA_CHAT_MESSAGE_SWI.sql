--------------------------------------------------------
--  DDL for Package OTA_CHAT_MESSAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_MESSAGE_SWI" AUTHID CURRENT_USER As
/* $Header: otcmsswi.pkh 120.1 2005/08/03 14:27 asud noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_chat_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_message_api.create_chat_message
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
PROCEDURE create_chat_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_chat_id                      in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number
  ,p_target_person_id             in     number
  ,p_target_contact_id            in     number
  ,p_message_text                 in     varchar2
  ,p_business_group_id            in     number
  ,p_chat_message_id              in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_chat_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_message_api.update_chat_message
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
PROCEDURE update_chat_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_chat_id                      in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_target_person_id             in     number    default hr_api.g_number
  ,p_target_contact_id            in     number    default hr_api.g_number
  ,p_message_text                 in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_chat_message_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_chat_message >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_message_api.delete_chat_message
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
PROCEDURE delete_chat_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_chat_message_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_chat_message_swi;

 

/
