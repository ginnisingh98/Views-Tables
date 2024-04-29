--------------------------------------------------------
--  DDL for Package OTA_EVENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVENT_BK1" AUTHID CURRENT_USER AS
  /* $Header: otevtapi.pkh 120.2.12010000.3 2009/05/27 13:24:01 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_class_b >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_class_b
 (p_effective_date               in date,
  p_vendor_id                    in number,
  p_activity_version_id          in number,
  p_business_group_id            in number,
  p_organization_id              in number,
  p_event_type                   in varchar2,
  p_object_version_number        in number,
  p_title                        in varchar2,
  p_budget_cost                  in number,
  p_actual_cost                  in number,
  p_budget_currency_code         in varchar2,
  p_centre                       in varchar2,
  p_comments                     in varchar2,
  p_course_end_date              in date,
  p_course_end_time              in varchar2,
  p_course_start_date            in date ,
  p_course_start_time            in varchar2,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_enrolment_end_date           in date ,
  p_enrolment_start_date         in date ,
  p_language_id                  in number,
  p_user_status                  in varchar2,
  p_development_event_type       in varchar2,
  p_event_status                 in varchar2,
  p_price_basis                  in varchar2,
  p_currency_code                in varchar2,
  p_maximum_attendees            in number,
  p_maximum_internal_attendees   in number,
  p_minimum_attendees            in number,
  p_standard_price               in number,
  p_category_code                in varchar2,
  p_parent_event_id              in number,
  p_book_independent_flag        in varchar2,
  p_public_event_flag            in varchar2,
  p_secure_event_flag            in varchar2,
  p_evt_information_category     in varchar2,
  p_evt_information1             in varchar2,
  p_evt_information2             in varchar2,
  p_evt_information3             in varchar2,
  p_evt_information4             in varchar2,
  p_evt_information5             in varchar2,
  p_evt_information6             in varchar2,
  p_evt_information7             in varchar2,
  p_evt_information8             in varchar2,
  p_evt_information9             in varchar2,
  p_evt_information10            in varchar2,
  p_evt_information11            in varchar2,
  p_evt_information12            in varchar2,
  p_evt_information13            in varchar2,
  p_evt_information14            in varchar2,
  p_evt_information15            in varchar2,
  p_evt_information16            in varchar2,
  p_evt_information17            in varchar2,
  p_evt_information18            in varchar2,
  p_evt_information19            in varchar2,
  p_evt_information20            in varchar2,
  p_project_id                   in number,
  p_owner_id			         in number,
  p_line_id				         in number,
  p_org_id				         in number,
  p_training_center_id           in number,
  p_location_id 			     in number,
  p_offering_id			         in number,
  p_timezone			         in varchar2,
  p_parent_offering_id			 in number,
  p_data_source			         in varchar2,
  p_event_availability           in varchar2);


-- ----------------------------------------------------------------------------
-- |-------------------< create_class_a >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_class_a
 (p_effective_date               in date,
  p_vendor_id                    in number,
  p_activity_version_id          in number,
  p_business_group_id            in number,
  p_organization_id              in number,
  p_event_type                   in varchar2,
  p_object_version_number        in number,
  p_title                        in varchar2,
  p_budget_cost                  in number,
  p_actual_cost                  in number,
  p_budget_currency_code         in varchar2,
  p_centre                       in varchar2,
  p_comments                     in varchar2,
  p_course_end_date              in date,
  p_course_end_time              in varchar2,
  p_course_start_date            in date ,
  p_course_start_time            in varchar2,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_enrolment_end_date           in date ,
  p_enrolment_start_date         in date ,
  p_language_id                  in number,
  p_user_status                  in varchar2,
  p_development_event_type       in varchar2,
  p_event_status                 in varchar2,
  p_price_basis                  in varchar2,
  p_currency_code                in varchar2,
  p_maximum_attendees            in number,
  p_maximum_internal_attendees   in number,
  p_minimum_attendees            in number,
  p_standard_price               in number,
  p_category_code                in varchar2,
  p_parent_event_id              in number,
  p_book_independent_flag        in varchar2,
  p_public_event_flag            in varchar2,
  p_secure_event_flag            in varchar2,
  p_evt_information_category     in varchar2,
  p_evt_information1             in varchar2,
  p_evt_information2             in varchar2,
  p_evt_information3             in varchar2,
  p_evt_information4             in varchar2,
  p_evt_information5             in varchar2,
  p_evt_information6             in varchar2,
  p_evt_information7             in varchar2,
  p_evt_information8             in varchar2,
  p_evt_information9             in varchar2,
  p_evt_information10            in varchar2,
  p_evt_information11            in varchar2,
  p_evt_information12            in varchar2,
  p_evt_information13            in varchar2,
  p_evt_information14            in varchar2,
  p_evt_information15            in varchar2,
  p_evt_information16            in varchar2,
  p_evt_information17            in varchar2,
  p_evt_information18            in varchar2,
  p_evt_information19            in varchar2,
  p_evt_information20            in varchar2,
  p_project_id                   in number,
  p_owner_id			         in number,
  p_line_id				         in number,
  p_org_id				         in number,
  p_training_center_id           in number,
  p_location_id 			     in number,
  p_offering_id			         in number,
  p_timezone			         in varchar2,
  p_parent_offering_id			 in number,
  p_data_source			         in varchar2,
  p_event_id                     in number,
  p_event_availability           in varchar2);

END ota_event_bk1;

/
