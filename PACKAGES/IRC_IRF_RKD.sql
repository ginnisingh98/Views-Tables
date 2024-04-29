--------------------------------------------------------
--  DDL for Package IRC_IRF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IRF_RKD" AUTHID CURRENT_USER as
/* $Header: irirfrhi.pkh 120.1 2008/04/16 07:34:00 vmummidi noship $ */
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
  ,p_referral_info_id             in number
  ,p_start_date                   in date
  ,p_end_date            	      in date
  ,p_object_id_o                  in number
  ,p_object_type_o                in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o            	      in date
  ,p_source_type_o           	  in varchar2
  ,p_source_name_o            	  in varchar2
  ,p_source_criteria1_o           in varchar2
  ,p_source_value1_o          	  in varchar2
  ,p_source_criteria2_o           in varchar2
  ,p_source_value2_o          	  in varchar2
  ,p_source_criteria3_o           in varchar2
  ,p_source_value3_o              in varchar2
  ,p_source_criteria4_o           in varchar2
  ,p_source_value4_o              in varchar2
  ,p_source_criteria5_o           in varchar2
  ,p_source_value5_o              in varchar2
  ,p_source_person_id_o           in number
  ,p_candidate_comment_o          in varchar2
  ,p_employee_comment_o           in varchar2
  ,p_irf_attribute_category_o     in varchar2
  ,p_irf_attribute1_o             in varchar2
  ,p_irf_attribute2_o             in varchar2
  ,p_irf_attribute3_o             in varchar2
  ,p_irf_attribute4_o             in varchar2
  ,p_irf_attribute5_o             in varchar2
  ,p_irf_attribute6_o             in varchar2
  ,p_irf_attribute7_o             in varchar2
  ,p_irf_attribute8_o             in varchar2
  ,p_irf_attribute9_o             in varchar2
  ,p_irf_attribute10_o            in varchar2
  ,p_irf_information_category_o   in varchar2
  ,p_irf_information1_o           in varchar2
  ,p_irf_information2_o           in varchar2
  ,p_irf_information3_o           in varchar2
  ,p_irf_information4_o           in varchar2
  ,p_irf_information5_o           in varchar2
  ,p_irf_information6_o           in varchar2
  ,p_irf_information7_o           in varchar2
  ,p_irf_information8_o           in varchar2
  ,p_irf_information9_o           in varchar2
  ,p_irf_information10_o          in varchar2
  ,p_object_created_by_o          in varchar2
  ,p_created_by_o                 in number
  ,p_object_version_number_o      in number
  );
--
end irc_irf_rkd;

/
