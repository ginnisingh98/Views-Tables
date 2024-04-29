--------------------------------------------------------
--  DDL for Package PAY_BTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTL_RKD" AUTHID CURRENT_USER as
/* $Header: pybtlrhi.pkh 120.2 2005/10/17 00:50:22 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_batch_line_id                in number
  ,p_cost_allocation_keyflex_id_o in number
  ,p_element_type_id_o            in number
  ,p_assignment_id_o              in number
  ,p_batch_id_o                   in number
  ,p_batch_line_status_o          in varchar2
  ,p_assignment_number_o          in varchar2
  ,p_batch_sequence_o             in number
  ,p_concatenated_segments_o      in varchar2
  ,p_effective_date_o             in date
  ,p_element_name_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_reason_o                     in varchar2
  ,p_segment1_o                   in varchar2
  ,p_segment2_o                   in varchar2
  ,p_segment3_o                   in varchar2
  ,p_segment4_o                   in varchar2
  ,p_segment5_o                   in varchar2
  ,p_segment6_o                   in varchar2
  ,p_segment7_o                   in varchar2
  ,p_segment8_o                   in varchar2
  ,p_segment9_o                   in varchar2
  ,p_segment10_o                  in varchar2
  ,p_segment11_o                  in varchar2
  ,p_segment12_o                  in varchar2
  ,p_segment13_o                  in varchar2
  ,p_segment14_o                  in varchar2
  ,p_segment15_o                  in varchar2
  ,p_segment16_o                  in varchar2
  ,p_segment17_o                  in varchar2
  ,p_segment18_o                  in varchar2
  ,p_segment19_o                  in varchar2
  ,p_segment20_o                  in varchar2
  ,p_segment21_o                  in varchar2
  ,p_segment22_o                  in varchar2
  ,p_segment23_o                  in varchar2
  ,p_segment24_o                  in varchar2
  ,p_segment25_o                  in varchar2
  ,p_segment26_o                  in varchar2
  ,p_segment27_o                  in varchar2
  ,p_segment28_o                  in varchar2
  ,p_segment29_o                  in varchar2
  ,p_segment30_o                  in varchar2
  ,p_value_1_o                    in varchar2
  ,p_value_2_o                    in varchar2
  ,p_value_3_o                    in varchar2
  ,p_value_4_o                    in varchar2
  ,p_value_5_o                    in varchar2
  ,p_value_6_o                    in varchar2
  ,p_value_7_o                    in varchar2
  ,p_value_8_o                    in varchar2
  ,p_value_9_o                    in varchar2
  ,p_value_10_o                   in varchar2
  ,p_value_11_o                   in varchar2
  ,p_value_12_o                   in varchar2
  ,p_value_13_o                   in varchar2
  ,p_value_14_o                   in varchar2
  ,p_value_15_o                   in varchar2
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
  ,p_date_earned_o                in date
  ,p_personal_payment_method_id_o in number
  ,p_subpriority_o                in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_object_version_number_o      in number
  );
--
end pay_btl_rkd;

 

/
