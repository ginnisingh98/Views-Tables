--------------------------------------------------------
--  DDL for Package OTA_OPEN_FC_ENROLLMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OPEN_FC_ENROLLMENT_SWI" AUTHID CURRENT_USER As
/* $Header: otfceswi.pkh 120.0 2005/06/24 07:54 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_open_fc_enrollment_api.create_open_fc_enrollment
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
PROCEDURE create_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_forum_id                     in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_chat_id                      in     number    default null
  ,p_enrollment_id                   in  number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_open_fc_enrollment_api.update_open_fc_enrollment
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
PROCEDURE update_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_enrollment_id                in     number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_forum_id                     in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_chat_id                      in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_open_fc_enrollment_api.delete_open_fc_enrollment
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
PROCEDURE delete_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrollment_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_open_fc_enrollment_swi;

 

/
