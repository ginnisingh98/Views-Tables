--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_VERSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_VERSION_SWI" AUTHID CURRENT_USER As
/* $Header: ottavswi.pkh 120.0.12010000.2 2009/08/11 12:46:22 smahanka ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_activity_version_api.create_activity_version
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
PROCEDURE create_activity_version
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_activity_id                  in     number
  ,p_superseded_by_act_version_id in     number    default null
  ,p_developer_organization_id    in     number
  ,p_controlling_person_id        in     number    default null
  ,p_version_name                 in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_intended_audience            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_maximum_attendees            in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_objectives                   in     varchar2  default null
  ,p_start_date                   in     date      default null
  ,p_success_criteria             in     varchar2  default null
  ,p_user_status                  in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_expenses_allowed             in     varchar2  default null
  ,p_professional_credit_type     in     varchar2  default null
  ,p_professional_credits         in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_tav_information_category     in     varchar2  default null
  ,p_tav_information1             in     varchar2  default null
  ,p_tav_information2             in     varchar2  default null
  ,p_tav_information3             in     varchar2  default null
  ,p_tav_information4             in     varchar2  default null
  ,p_tav_information5             in     varchar2  default null
  ,p_tav_information6             in     varchar2  default null
  ,p_tav_information7             in     varchar2  default null
  ,p_tav_information8             in     varchar2  default null
  ,p_tav_information9             in     varchar2  default null
  ,p_tav_information10            in     varchar2  default null
  ,p_tav_information11            in     varchar2  default null
  ,p_tav_information12            in     varchar2  default null
  ,p_tav_information13            in     varchar2  default null
  ,p_tav_information14            in     varchar2  default null
  ,p_tav_information15            in     varchar2  default null
  ,p_tav_information16            in     varchar2  default null
  ,p_tav_information17            in     varchar2  default null
  ,p_tav_information18            in     varchar2  default null
  ,p_tav_information19            in     varchar2  default null
  ,p_tav_information20            in     varchar2  default null
  ,p_inventory_item_id            in     number    default null
  ,p_organization_id              in     number    default null
  ,p_rco_id                       in     number    default null
  ,p_version_code                 in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_activity_version_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_competency_update_level        in     varchar2  default null
  ,p_eres_enabled       	    in     varchar2 default null
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_activity_version_api.delete_activity_version
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
PROCEDURE delete_activity_version
  (p_activity_version_id          in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_activity_version_api.update_activity_version
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
PROCEDURE update_activity_version
  (p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_id                  in     number    default hr_api.g_number
  ,p_superseded_by_act_version_id in     number    default hr_api.g_number
  ,p_developer_organization_id    in     number    default hr_api.g_number
  ,p_controlling_person_id        in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_version_name                 in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_intended_audience            in     varchar2  default hr_api.g_varchar2
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
  ,p_user_status                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_expenses_allowed             in     varchar2  default hr_api.g_varchar2
  ,p_professional_credit_type     in     varchar2  default hr_api.g_varchar2
  ,p_professional_credits         in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_tav_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tav_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information20            in     varchar2  default hr_api.g_varchar2
  ,p_inventory_item_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_rco_id                       in     number    default hr_api.g_number
  ,p_version_code                 in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
  ,p_eres_enabled       	    in     varchar2  default hr_api.g_varchar2

  );

  -- ----------------------------------------------------------------------------
  -- |------------------------< validate_delete_act_ver >-----------------------|
  -- ----------------------------------------------------------------------------
  -- {Start of comments}
  --
  --
  -- Description:
  --  This procedure is the self-service wrapper procedure to
  --  validate deletion of Activity
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
    procedure validate_delete_act_ver(
    p_activity_version_id in number,
    p_return_status out nocopy varchar2);
end ota_activity_version_swi;

/
