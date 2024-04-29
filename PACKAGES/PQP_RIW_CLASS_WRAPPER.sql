--------------------------------------------------------
--  DDL for Package PQP_RIW_CLASS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RIW_CLASS_WRAPPER" AUTHID CURRENT_USER As
/* $Header: pqpriwclwr.pkh 120.0.12010000.3 2008/12/04 10:50:29 psengupt noship $ */

-- =============================================================================
-- InsUpd_Class: This procedure is called by the web-adi spreadsheet
-- to create  a Class in Oracle Learning Management from data
-- entered in the spreadsheet.
-- =============================================================================
PROCEDURE InsUpd_Class
  (p_effective_date               in     date      default sysdate
  ,p_event_id                     in     number    default null
  ,p_vendor_id                    in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_dummy_col_offering		  in	 varchar2
  ,p_parent_offering_id           in     number
  ,p_business_group_id            in     number
  ,p_organization_id              in     number    default null
  ,p_event_type                   in     varchar2
  ,p_object_version_number        in     number
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
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  ) ;
  end pqp_riw_class_wrapper;

/
