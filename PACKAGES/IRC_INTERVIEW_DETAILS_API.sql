--------------------------------------------------------
--  DDL for Package IRC_INTERVIEW_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INTERVIEW_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: iriidapi.pkh 120.1.12010000.3 2010/04/07 09:54:36 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_irc_interview_details >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure create_irc_interview_details
  (p_validate                      in     boolean  default false
  ,p_status                        in     varchar2  default hr_api.g_varchar2
  ,p_feedback                      in     varchar2  default hr_api.g_varchar2
  ,p_notes                         in     varchar2  default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_interview_details_id          out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_start_date                    out nocopy   date
  ,p_end_date                      out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_irc_interview_details >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--
-- {End Of Comments}
--
procedure update_irc_interview_details
  (p_validate                      in     boolean  default false
  ,p_interview_details_id          in     number
  ,p_status                        in     varchar2  default hr_api.g_varchar2
  ,p_feedback                      in     varchar2  default hr_api.g_varchar2
  ,p_notes                         in     varchar2  default hr_api.g_varchar2
  ,p_notes_to_candidate            in     varchar2  default hr_api.g_varchar2
  ,p_category                      in     varchar2  default hr_api.g_varchar2
  ,p_result                        in     varchar2  default hr_api.g_varchar2
  ,p_iid_information_category      in     varchar2  default hr_api.g_varchar2
  ,p_iid_information1              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information2              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information3              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information4              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information5              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information6              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information7              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information8              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information9              in     varchar2  default hr_api.g_varchar2
  ,p_iid_information10             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information11             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information12             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information13             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information14             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information15             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information16             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information17             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information18             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information19             in     varchar2  default hr_api.g_varchar2
  ,p_iid_information20             in     varchar2  default hr_api.g_varchar2
  ,p_event_id                      in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_interview_details >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure copy_interview_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  ,p_target_party_id      in number
  );
--
--
end irc_interview_details_api;

/
