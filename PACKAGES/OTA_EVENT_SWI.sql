--------------------------------------------------------
--  DDL for Package OTA_EVENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVENT_SWI" AUTHID CURRENT_USER as
/* $Header: otevtswi.pkh 120.2.12010000.2 2009/05/05 12:41:48 pekasi ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_event_api.create_event
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
PROCEDURE create_event
  (p_effective_date               in     date      default sysdate
  ,p_event_id                     in     number
  ,p_vendor_id                    in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_business_group_id            in     number
  ,p_organization_id              in     number    default null
  ,p_event_type                   in     varchar2
  ,p_object_version_number        out nocopy number
  ,p_title                        in     varchar2
  ,p_budget_cost                  in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_centre                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_course_end_date              in     date      default null
  ,p_course_end_time              in     varchar2  default null
  ,p_course_start_date            in     date      default null
  ,p_course_start_time            in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_enrolment_end_date           in     date      default null
  ,p_enrolment_start_date         in     date      default null
  ,p_language_id                  in     number    default null
  ,p_user_status                  in     varchar2  default null
  ,p_development_event_type       in     varchar2  default null
  ,p_event_status                 in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_standard_price               in     number    default null
  ,p_category_code                in     varchar2  default null
  ,p_parent_event_id              in     number    default null
  ,p_book_independent_flag        in     varchar2  default null
  ,p_public_event_flag            in     varchar2  default null
  ,p_secure_event_flag            in     varchar2  default null
  ,p_evt_information_category     in     varchar2  default null
  ,p_evt_information1             in     varchar2  default null
  ,p_evt_information2             in     varchar2  default null
  ,p_evt_information3             in     varchar2  default null
  ,p_evt_information4             in     varchar2  default null
  ,p_evt_information5             in     varchar2  default null
  ,p_evt_information6             in     varchar2  default null
  ,p_evt_information7             in     varchar2  default null
  ,p_evt_information8             in     varchar2  default null
  ,p_evt_information9             in     varchar2  default null
  ,p_evt_information10            in     varchar2  default null
  ,p_evt_information11            in     varchar2  default null
  ,p_evt_information12            in     varchar2  default null
  ,p_evt_information13            in     varchar2  default null
  ,p_evt_information14            in     varchar2  default null
  ,p_evt_information15            in     varchar2  default null
  ,p_evt_information16            in     varchar2  default null
  ,p_evt_information17            in     varchar2  default null
  ,p_evt_information18            in     varchar2  default null
  ,p_evt_information19            in     varchar2  default null
  ,p_evt_information20            in     varchar2  default null
  ,p_project_id                   in     number    default null
  ,p_owner_id                     in     number    default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_training_center_id           in     number    default null
  ,p_location_id                  in     number    default null
  ,p_offering_id                  in     number    default null
  ,p_timezone                     in     varchar2  default null
  ,p_parent_offering_id           in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_event_availability           in     varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_event_api.delete_event
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
PROCEDURE delete_event
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_event_id                     in     number
  ,p_object_version_number        in     number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_event >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_event_api.update_event
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
PROCEDURE update_event
  (p_event_id                     in     number
  ,p_effective_date               in     date      default trunc(sysdate)
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_centre                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_course_end_date              in     date      default hr_api.g_date
  ,p_course_end_time              in     varchar2  default hr_api.g_varchar2
  ,p_course_start_date            in     date      default hr_api.g_date
  ,p_course_start_time            in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_enrolment_end_date           in     date      default hr_api.g_date
  ,p_enrolment_start_date         in     date      default hr_api.g_date
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_user_status                  in     varchar2  default hr_api.g_varchar2
  ,p_development_event_type       in     varchar2  default hr_api.g_varchar2
  ,p_event_status                 in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_category_code                in     varchar2  default hr_api.g_varchar2
  ,p_parent_event_id              in     number    default hr_api.g_number
  ,p_book_independent_flag        in     varchar2  default hr_api.g_varchar2
  ,p_public_event_flag            in     varchar2  default hr_api.g_varchar2
  ,p_secure_event_flag            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_evt_information1             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information2             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information3             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information4             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information5             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information6             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information7             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information8             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information9             in     varchar2  default hr_api.g_varchar2
  ,p_evt_information10            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information11            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information12            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information13            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information14            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information15            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information16            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information17            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information18            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information19            in     varchar2  default hr_api.g_varchar2
  ,p_evt_information20            in     varchar2  default hr_api.g_varchar2
  ,p_project_id                   in     number    default hr_api.g_number
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_line_id                      in     number    default hr_api.g_number
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_training_center_id           in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_offering_id                  in     number    default hr_api.g_number
  ,p_timezone                     in     varchar2  default hr_api.g_varchar2
  ,p_parent_offering_id           in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_event_availability           in     varchar2  default null
  );



procedure update_enrollment     (p_booking_id 	IN	NUMBER,
					   p_daemon_flag	IN	VARCHAR2,
					   p_daemon_type	IN	VARCHAR2,
					   p_booking_status_type_id        IN    NUMBER,
                                 p_event_id IN NUMBER,
                                 p_object_version_number IN NUMBER,
					   p_return_status out nocopy varchar2);


procedure upd2_update_event
  (
  p_event			         in varchar2,
  p_event_id                     in number,
  p_object_version_number        in out nocopy number,
  p_event_status                 in out nocopy varchar2,
  p_validate                     in number default hr_api.g_false_num,
  p_reset_max_attendees		   in number default hr_api.g_false_num,
  p_update_finance_line		   in varchar2 default 'N',
  p_booking_status_type_id	   in number default null,
  p_date_status_changed 	   in date default null,
  p_maximum_attendees		   in number default null,
  p_change_status		         in varchar2 default 'A',
  p_return_status                out nocopy varchar2,
  p_check_for_warning            in varchar2 default 'Y',
  p_message_name                 out nocopy varchar2);


PROCEDURE check_session_overlap
  ( p_event_id IN NUMBER
   ,p_parent_event_id IN NUMBER
   ,p_session_date IN DATE
   ,p_session_start_time IN VARCHAR2
   ,p_session_end_time IN VARCHAR2
   ,p_warning OUT NOCOPY VARCHAR2);


end ota_event_swi;

/
