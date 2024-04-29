--------------------------------------------------------
--  DDL for Package IRC_IID_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IID_RKD" AUTHID CURRENT_USER as
/* $Header: iriidrhi.pkh 120.1.12010000.1 2008/07/28 12:42:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_interview_details_id         in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_status_o                     in varchar2
  ,p_feedback_o                   in varchar2
  ,p_notes_o                      in varchar2
  ,p_notes_to_candidate_o         in varchar2
  ,p_category_o                   in varchar2
  ,p_result_o                     in varchar2
  ,p_iid_information_category_o   in varchar2
  ,p_iid_information1_o           in varchar2
  ,p_iid_information2_o           in varchar2
  ,p_iid_information3_o           in varchar2
  ,p_iid_information4_o           in varchar2
  ,p_iid_information5_o           in varchar2
  ,p_iid_information6_o           in varchar2
  ,p_iid_information7_o           in varchar2
  ,p_iid_information8_o           in varchar2
  ,p_iid_information9_o           in varchar2
  ,p_iid_information10_o          in varchar2
  ,p_iid_information11_o          in varchar2
  ,p_iid_information12_o          in varchar2
  ,p_iid_information13_o          in varchar2
  ,p_iid_information14_o          in varchar2
  ,p_iid_information15_o          in varchar2
  ,p_iid_information16_o          in varchar2
  ,p_iid_information17_o          in varchar2
  ,p_iid_information18_o          in varchar2
  ,p_iid_information19_o          in varchar2
  ,p_iid_information20_o          in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_event_id_o                    in varchar2
  ,p_object_version_number_o      in number
  );
--
end irc_iid_rkd;

/
