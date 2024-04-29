--------------------------------------------------------
--  DDL for Package OTA_OFFERING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OFFERING_SWI" AUTHID CURRENT_USER As
/* $Header: otoffswi.pkh 120.0.12000000.2 2007/02/06 15:22:47 vkkolla noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_offering >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_offering_api.create_offering
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
PROCEDURE create_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_activity_version_id          in     number    default null
  ,p_end_date                     in     date      default null
  ,p_owner_id                     in     number    default null
  ,p_delivery_mode_id             in     number    default null
  ,p_language_id                  in     number    default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_learning_object_id           in     number    default null
  ,p_player_toolbar_flag          in     varchar2  default null
  ,p_player_toolbar_bitset        in     number    default null
  ,p_player_new_window_flag       in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_price               in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_offering_id                  in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_description                  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_offering >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_offering_api.delete_offering
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
PROCEDURE delete_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offering_id                  in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_offering >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_offering_api.update_offering
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
PROCEDURE update_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_offering_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_delivery_mode_id             in     number    default hr_api.g_number
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_learning_object_id           in     number    default hr_api.g_number
  ,p_player_toolbar_flag          in     varchar2  default hr_api.g_varchar2
  ,p_player_toolbar_bitset        in     number    default hr_api.g_number
  ,p_player_new_window_flag       in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
    ,p_competency_update_level      in     varchar2  default hr_api.g_varchar2
    ,p_language_code                in     varchar2  default hr_api.g_varchar2
  );
end ota_offering_swi;

 

/
