--------------------------------------------------------
--  DDL for Package PQP_RIW_COURSE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RIW_COURSE_WRAPPER" AUTHID CURRENT_USER As
/* $Header: pqpriwcowr.pkh 120.0.12010000.2 2008/12/04 10:51:35 psengupt noship $ */

-- =============================================================================
-- InsUpd_Course: This procedure is called by the web-adi spreadsheet
-- to create  a Course in Oracle Learning Management from data
-- entered in the spreadsheet.
-- =============================================================================
PROCEDURE InsUpd_Course
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
  ,p_activity_version_id          in     number    default null
  ,p_object_version_number        in number default null
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_competency_update_level        in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  );
end pqp_riw_course_wrapper;



/
