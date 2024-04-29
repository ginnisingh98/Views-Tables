--------------------------------------------------------
--  DDL for Package OTA_FORUM_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FORUM_SWI" AUTHID CURRENT_USER As
/* $Header: otfrmswi.pkh 120.0 2005/06/24 07:57 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_forum >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_api.create_forum
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
PROCEDURE create_forum
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_message_type_flag            in     varchar2  default null
  ,p_allow_html_flag              in     varchar2  default null
  ,p_allow_attachment_flag        in     varchar2  default null
  ,p_auto_notification_flag       in     varchar2  default null
  ,p_public_flag                  in     varchar2  default null
  ,p_forum_id                        in  number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_forum >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_api.update_forum
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
PROCEDURE update_forum
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2
  ,p_business_group_id            in     number
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_message_type_flag            in     varchar2  default hr_api.g_varchar2
  ,p_allow_html_flag              in     varchar2  default hr_api.g_varchar2
  ,p_allow_attachment_flag        in     varchar2  default hr_api.g_varchar2
  ,p_auto_notification_flag       in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_forum_id                     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_forum >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_forum_api.delete_forum
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
PROCEDURE delete_forum
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_id                     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_forum_swi;

 

/
