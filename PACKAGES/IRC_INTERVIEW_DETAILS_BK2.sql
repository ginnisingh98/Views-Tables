--------------------------------------------------------
--  DDL for Package IRC_INTERVIEW_DETAILS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_INTERVIEW_DETAILS_BK2" AUTHID CURRENT_USER as
/* $Header: iriidapi.pkh 120.1.12010000.3 2010/04/07 09:54:36 vmummidi ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_irc_interview_details_b >---------------|
-- ----------------------------------------------------------------------------
--
procedure update_irc_interview_details_b
               (p_interview_details_id          in     number
               ,p_status                        in     varchar2
               ,p_feedback                      in     varchar2
               ,p_notes                         in     varchar2
               ,p_notes_to_candidate            in     varchar2
               ,p_category                      in     varchar2
               ,p_result                        in     varchar2
               ,p_iid_information_category      in     varchar2
               ,p_iid_information1              in     varchar2
               ,p_iid_information2              in     varchar2
               ,p_iid_information3              in     varchar2
               ,p_iid_information4              in     varchar2
               ,p_iid_information5              in     varchar2
               ,p_iid_information6              in     varchar2
               ,p_iid_information7              in     varchar2
               ,p_iid_information8              in     varchar2
               ,p_iid_information9              in     varchar2
               ,p_iid_information10             in     varchar2
               ,p_iid_information11             in     varchar2
               ,p_iid_information12             in     varchar2
               ,p_iid_information13             in     varchar2
               ,p_iid_information14             in     varchar2
               ,p_iid_information15             in     varchar2
               ,p_iid_information16             in     varchar2
               ,p_iid_information17             in     varchar2
               ,p_iid_information18             in     varchar2
               ,p_iid_information19             in     varchar2
               ,p_iid_information20             in     varchar2
               ,p_object_version_number         in     number
               );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_irc_interview_details_a >---------------|
-- ----------------------------------------------------------------------------
--
procedure update_irc_interview_details_a
               (p_interview_details_id          in     number
               ,p_status                        in     varchar2
               ,p_feedback                      in     varchar2
               ,p_notes                         in     varchar2
               ,p_notes_to_candidate            in     varchar2
               ,p_category                      in     varchar2
               ,p_result                        in     varchar2
               ,p_iid_information_category      in     varchar2
               ,p_iid_information1              in     varchar2
               ,p_iid_information2              in     varchar2
               ,p_iid_information3              in     varchar2
               ,p_iid_information4              in     varchar2
               ,p_iid_information5              in     varchar2
               ,p_iid_information6              in     varchar2
               ,p_iid_information7              in     varchar2
               ,p_iid_information8              in     varchar2
               ,p_iid_information9              in     varchar2
               ,p_iid_information10             in     varchar2
               ,p_iid_information11             in     varchar2
               ,p_iid_information12             in     varchar2
               ,p_iid_information13             in     varchar2
               ,p_iid_information14             in     varchar2
               ,p_iid_information15             in     varchar2
               ,p_iid_information16             in     varchar2
               ,p_iid_information17             in     varchar2
               ,p_iid_information18             in     varchar2
               ,p_iid_information19             in     varchar2
               ,p_iid_information20             in     varchar2
               ,p_object_version_number         in     number
               );
--
--
end irc_interview_details_bk2;

/
