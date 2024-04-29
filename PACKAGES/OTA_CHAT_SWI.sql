--------------------------------------------------------
--  DDL for Package OTA_CHAT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHAT_SWI" AUTHID CURRENT_USER As
/* $Header: otchaswi.pkh 120.2 2006/03/06 02:27 rdola noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------------< create_chat >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_api.create_chat
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
PROCEDURE create_chat
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_start_time_active            in     varchar2  default null
  ,p_end_time_active              in     varchar2  default NULL
  ,p_timezone_code                IN     VARCHAR2  DEFAULT NULL
  ,p_public_flag                  in     varchar2  default null
  ,p_chat_id                         in  number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< update_chat >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_api.update_chat
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
PROCEDURE update_chat
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2
  ,p_business_group_id            in     number
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_start_time_active            in     varchar2  default hr_api.g_varchar2
  ,p_end_time_active              in     varchar2  default hr_api.g_varchar2
  ,p_timezone_code                IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_chat_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_chat >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_chat_api.delete_chat
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
PROCEDURE delete_chat
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_chat_id                      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_chat_swi;

 

/
