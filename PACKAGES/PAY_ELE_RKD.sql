--------------------------------------------------------
--  DDL for Package PAY_ELE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELE_RKD" AUTHID CURRENT_USER as
/* $Header: pyelerhi.pkh 120.0 2005/05/29 04:33:12 appldev noship $ */
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
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_cost_allocation_keyflex_id_o in number
  ,p_assignment_id_o              in number
  ,p_updating_action_id_o         in number
  ,p_updating_action_type_o       in varchar2
  ,p_element_link_id_o            in number
  ,p_original_entry_id_o          in number
  ,p_creator_type_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
  ,p_creator_id_o                 in number
  ,p_reason_o                     in varchar2
  ,p_target_entry_id_o            in number
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
  ,p_entry_information_category_o in varchar2
  ,p_entry_information1_o         in varchar2
  ,p_entry_information2_o         in varchar2
  ,p_entry_information3_o         in varchar2
  ,p_entry_information4_o         in varchar2
  ,p_entry_information5_o         in varchar2
  ,p_entry_information6_o         in varchar2
  ,p_entry_information7_o         in varchar2
  ,p_entry_information8_o         in varchar2
  ,p_entry_information9_o         in varchar2
  ,p_entry_information10_o        in varchar2
  ,p_entry_information11_o        in varchar2
  ,p_entry_information12_o        in varchar2
  ,p_entry_information13_o        in varchar2
  ,p_entry_information14_o        in varchar2
  ,p_entry_information15_o        in varchar2
  ,p_entry_information16_o        in varchar2
  ,p_entry_information17_o        in varchar2
  ,p_entry_information18_o        in varchar2
  ,p_entry_information19_o        in varchar2
  ,p_entry_information20_o        in varchar2
  ,p_entry_information21_o        in varchar2
  ,p_entry_information22_o        in varchar2
  ,p_entry_information23_o        in varchar2
  ,p_entry_information24_o        in varchar2
  ,p_entry_information25_o        in varchar2
  ,p_entry_information26_o        in varchar2
  ,p_entry_information27_o        in varchar2
  ,p_entry_information28_o        in varchar2
  ,p_entry_information29_o        in varchar2
  ,p_entry_information30_o        in varchar2
  ,p_subpriority_o                in number
  ,p_personal_payment_method_id_o in number
  ,p_date_earned_o                in date
  ,p_object_version_number_o      in number
  ,p_source_id_o                  in number
  ,p_balance_adj_cost_flag_o      in varchar2
  ,p_element_type_id_o            in number
  ,p_all_entry_values_null_o      in varchar2
  );
--
end pay_ele_rkd;

 

/
