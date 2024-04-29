--------------------------------------------------------
--  DDL for Package IRC_IPD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IPD_RKD" AUTHID CURRENT_USER as
/* $Header: iripdrhi.pkh 120.0 2005/07/26 15:09:47 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_pending_data_id              in number
  ,p_email_address_o              in varchar2
  ,p_vacancy_id_o                 in number
  ,p_last_name_o                  in varchar2
  ,p_first_name_o                 in varchar2
  ,p_user_password_o              in varchar2
  ,p_resume_file_name_o           in varchar2
  ,p_resume_description_o         in varchar2
  ,p_resume_mime_type_o           in varchar2
  ,p_source_type_o                in varchar2
  ,p_job_post_source_name_o       in varchar2
  ,p_posting_content_id_o         in number
  ,p_person_id_o                  in number
  ,p_processed_o                  in varchar2
  ,p_sex_o                        in varchar2
  ,p_date_of_birth_o              in date
  ,p_per_information_category_o   in varchar2
  ,p_per_information1_o           in varchar2
  ,p_per_information2_o           in varchar2
  ,p_per_information3_o           in varchar2
  ,p_per_information4_o           in varchar2
  ,p_per_information5_o           in varchar2
  ,p_per_information6_o           in varchar2
  ,p_per_information7_o           in varchar2
  ,p_per_information8_o           in varchar2
  ,p_per_information9_o           in varchar2
  ,p_per_information10_o          in varchar2
  ,p_per_information11_o          in varchar2
  ,p_per_information12_o          in varchar2
  ,p_per_information13_o          in varchar2
  ,p_per_information14_o          in varchar2
  ,p_per_information15_o          in varchar2
  ,p_per_information16_o          in varchar2
  ,p_per_information17_o          in varchar2
  ,p_per_information18_o          in varchar2
  ,p_per_information19_o          in varchar2
  ,p_per_information20_o          in varchar2
  ,p_per_information21_o          in varchar2
  ,p_per_information22_o          in varchar2
  ,p_per_information23_o          in varchar2
  ,p_per_information24_o          in varchar2
  ,p_per_information25_o          in varchar2
  ,p_per_information26_o          in varchar2
  ,p_per_information27_o          in varchar2
  ,p_per_information28_o          in varchar2
  ,p_per_information29_o          in varchar2
  ,p_per_information30_o          in varchar2
  ,p_error_message_o              in varchar2
  ,p_creation_date_o              in date
  ,p_last_update_date_o           in date
  ,p_allow_access_o               in varchar2
  ,p_visitor_resp_key_o           in varchar2
  ,p_visitor_resp_appl_id_o       in number
  ,p_security_group_key_o         in varchar2
  );
--
end irc_ipd_rkd;

 

/
