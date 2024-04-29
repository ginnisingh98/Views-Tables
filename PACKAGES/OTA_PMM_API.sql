--------------------------------------------------------
--  DDL for Package OTA_PMM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_PMM_API" AUTHID CURRENT_USER as
/* $Header: otpmm02t.pkh 120.2 2006/10/12 10:49:37 niarora noship $ */
--
procedure ins
(
  p_program_membership_id        out nocopy number,
  p_event_id                     in out nocopy number,
  p_program_event_id             in number,
  p_object_version_number        out nocopy number,
  p_comments                     in varchar2         default null,
  p_group_name                   in varchar2         default null,
  p_required_flag                in varchar2         default null,
  p_role                         in varchar2         default null,
  p_sequence                     in number           default null,
  p_pmm_information_category     in varchar2         default null,
  p_pmm_information1             in varchar2         default null,
  p_pmm_information2             in varchar2         default null,
  p_pmm_information3             in varchar2         default null,
  p_pmm_information4             in varchar2         default null,
  p_pmm_information5             in varchar2         default null,
  p_pmm_information6             in varchar2         default null,
  p_pmm_information7             in varchar2         default null,
  p_pmm_information8             in varchar2         default null,
  p_pmm_information9             in varchar2         default null,
  p_pmm_information10            in varchar2         default null,
  p_pmm_information11            in varchar2         default null,
  p_pmm_information12            in varchar2         default null,
  p_pmm_information13            in varchar2         default null,
  p_pmm_information14            in varchar2         default null,
  p_pmm_information15            in varchar2         default null,
  p_pmm_information16            in varchar2         default null,
  p_pmm_information17            in varchar2         default null,
  p_pmm_information18            in varchar2         default null,
  p_pmm_information19            in varchar2         default null,
  p_pmm_information20            in varchar2         default null,
  p_activity_version_id          in number           default null,
  p_business_group_id            in number           default null,
  p_organization_id              in number           default null,
  p_title                        in varchar2         default null,
  p_course_end_date              in date             default null,
  p_course_start_date            in date             default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_enrolment_end_date           in date             default null,
  p_enrolment_start_date         in date             default null,
  p_language_id                  in number           default null,
  p_vendor_id                    in number           default null,
  p_event_status                 in varchar2         default null,
  p_maximum_attendees            in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_minimum_attendees            in number           default null,
  p_parent_offering_id           in number           default null, --upg_classic
  p_validate                     in boolean   default false,
  p_timezone                   in varchar2                   default null
);
--
procedure del
(
  p_program_membership_id              in number,
  p_object_version_number              in number,
  p_event_id                           in number,
  p_validate                           in boolean);
end ota_pmm_api;

 

/
