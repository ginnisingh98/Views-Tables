--------------------------------------------------------
--  DDL for Package IRC_IID_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IID_RKI" AUTHID CURRENT_USER as
/* $Header: iriidrhi.pkh 120.1.12010000.1 2008/07/28 12:42:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--

procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_interview_details_id         in number
  ,p_status                       in varchar2
  ,p_feedback                     in varchar2
  ,p_notes                        in varchar2
  ,p_notes_to_candidate           in varchar2
  ,p_category                     in varchar2
  ,p_result                       in varchar2
  ,p_iid_information_category     in varchar2
  ,p_iid_information1             in varchar2
  ,p_iid_information2             in varchar2
  ,p_iid_information3             in varchar2
  ,p_iid_information4             in varchar2
  ,p_iid_information5             in varchar2
  ,p_iid_information6             in varchar2
  ,p_iid_information7             in varchar2
  ,p_iid_information8             in varchar2
  ,p_iid_information9             in varchar2
  ,p_iid_information10            in varchar2
  ,p_iid_information11            in varchar2
  ,p_iid_information12            in varchar2
  ,p_iid_information13            in varchar2
  ,p_iid_information14            in varchar2
  ,p_iid_information15            in varchar2
  ,p_iid_information16            in varchar2
  ,p_iid_information17            in varchar2
  ,p_iid_information18            in varchar2
  ,p_iid_information19            in varchar2
  ,p_iid_information20            in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_event_id                     in varchar2
  ,p_object_version_number        in number
  );
end irc_iid_rki;

/
