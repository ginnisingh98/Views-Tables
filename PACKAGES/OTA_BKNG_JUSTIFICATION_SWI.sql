--------------------------------------------------------
--  DDL for Package OTA_BKNG_JUSTIFICATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BKNG_JUSTIFICATION_SWI" AUTHID CURRENT_USER As
/* $Header: otbjsswi.pkh 120.1 2005/06/06 03:35 rdola noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< create_booking_justification >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_bkng_justification_api.create_booking_justification
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
PROCEDURE create_booking_justification
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_priority_level               in     varchar2
  ,p_justification_text           in     varchar2
  ,p_start_date_active            in     date
  ,p_end_date_active              in     date      default null
  ,p_booking_justification_id     in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_booking_justification >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_bkng_justification_api.update_booking_justification
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
PROCEDURE update_booking_justification
  (p_effective_date               in     date
  ,p_booking_justification_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_priority_level               in     varchar2  default hr_api.g_varchar2
  ,p_justification_text           in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_booking_justification >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_bkng_justification_api.delete_booking_justification
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
PROCEDURE delete_booking_justification
  (p_booking_justification_id     in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
 end ota_bkng_justification_swi;

 

/
