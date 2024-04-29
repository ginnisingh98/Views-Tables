--------------------------------------------------------
--  DDL for Package IRC_INTERVIEW_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INTERVIEW_DETAILS_SWI" AUTHID CURRENT_USER As
/* $Header: iriidswi.pkh 120.0 2007/12/10 09:03:16 mkjayara noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_irc_interview_details >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.create_ame_attribute
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
PROCEDURE create_irc_interview_details
  (p_validate                      in     number    default hr_api.g_false_num
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
  ,p_interview_details_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_irc_interview_details >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.update_ame_attribute
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
PROCEDURE update_irc_interview_details
  (p_validate                      in     number    default hr_api.g_false_num
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
  ,p_object_version_number         in out nocopy number
  ,p_start_date                       out nocopy date
  ,p_end_date                         out nocopy date
  ,p_return_status                    out nocopy varchar2
  );
 end irc_interview_details_swi;

/
