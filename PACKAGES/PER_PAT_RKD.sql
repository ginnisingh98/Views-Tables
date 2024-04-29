--------------------------------------------------------
--  DDL for Package PER_PAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAT_RKD" AUTHID CURRENT_USER as
/* $Header: pepatrhi.pkh 120.0 2005/09/28 07:38 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_allocated_task_id            in number
  ,p_allocated_checklist_id_o     in number
  ,p_task_name_o                  in varchar2
  ,p_description_o                in varchar2
  ,p_performer_orig_system_o      in varchar2
  ,p_performer_orig_sys_id_o   in number
  ,p_task_owner_person_id_o       in number
  ,p_task_sequence_o              in number
  ,p_target_start_date_o          in date
  ,p_target_end_date_o            in date
  ,p_actual_start_date_o          in date
  ,p_actual_end_date_o            in date
  ,p_action_url_o                 in varchar2
  ,p_mandatory_flag_o             in varchar2
  ,p_status_o                     in varchar2
  ,p_object_version_number_o      in number
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
end per_pat_rkd;

 

/
