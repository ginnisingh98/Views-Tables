--------------------------------------------------------
--  DDL for Package PER_CTK_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTK_RKD" AUTHID CURRENT_USER as
/* $Header: pectkrhi.pkh 120.5 2006/09/06 06:03:49 sturlapa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_task_in_checklist_id         in number
  ,p_checklist_id_o               in number
  ,p_checklist_task_name_o        in varchar2
  ,p_eligibility_object_id_o      in number
  ,p_eligibility_profile_id_o     in number
  ,p_ame_attribute_identifier_o   in varchar2
  ,p_description_o                in varchar2
  ,p_mandatory_flag_o             in varchar2
  ,p_target_duration_o            in number
  ,p_target_duration_uom_o        in varchar2
  ,p_task_sequence_o              in number
  ,p_object_version_number_o      in number
  ,p_action_url_o                 in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o               in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in varchar2
  ,p_information11_o              in varchar2
  ,p_information12_o              in varchar2
  ,p_information13_o              in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o              in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o              in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o              in varchar2
  ,p_information20_o              in varchar2
  );
--
end per_ctk_rkd;

 

/
