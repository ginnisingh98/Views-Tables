--------------------------------------------------------
--  DDL for Package PAY_BATCH_ELEMENT_ENTRY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_ELEMENT_ENTRY_BK2" AUTHID CURRENT_USER as
/* $Header: pybthapi.pkh 120.4 2005/10/28 05:44:22 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_batch_line_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_line_b
  (p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_batch_line_status             in     varchar2
  ,p_assignment_id                 in     number
  ,p_assignment_number             in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_date_earned                   in     date
  ,p_personal_payment_method_id    in     number
  ,p_subpriority                   in     number
  ,p_batch_sequence                in     number
  ,p_concatenated_segments         in     varchar2
  ,p_cost_allocation_keyflex_id    in     number
  ,p_effective_date                in     date
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_element_name                  in     varchar2
  ,p_element_type_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_reason                        in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_value_1                       in     varchar2
  ,p_value_2                       in     varchar2
  ,p_value_3                       in     varchar2
  ,p_value_4                       in     varchar2
  ,p_value_5                       in     varchar2
  ,p_value_6                       in     varchar2
  ,p_value_7                       in     varchar2
  ,p_value_8                       in     varchar2
  ,p_value_9                       in     varchar2
  ,p_value_10                      in     varchar2
  ,p_value_11                      in     varchar2
  ,p_value_12                      in     varchar2
  ,p_value_13                      in     varchar2
  ,p_value_14                      in     varchar2
  ,p_value_15                      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_batch_line_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_line_a
  (p_session_date                  in     date
  ,p_batch_id                      in     number
  ,p_batch_line_status             in     varchar2
  ,p_assignment_id                 in     number
  ,p_assignment_number             in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_entry_information_category    in     varchar2
  ,p_entry_information1            in     varchar2
  ,p_entry_information2            in     varchar2
  ,p_entry_information3            in     varchar2
  ,p_entry_information4            in     varchar2
  ,p_entry_information5            in     varchar2
  ,p_entry_information6            in     varchar2
  ,p_entry_information7            in     varchar2
  ,p_entry_information8            in     varchar2
  ,p_entry_information9            in     varchar2
  ,p_entry_information10           in     varchar2
  ,p_entry_information11           in     varchar2
  ,p_entry_information12           in     varchar2
  ,p_entry_information13           in     varchar2
  ,p_entry_information14           in     varchar2
  ,p_entry_information15           in     varchar2
  ,p_entry_information16           in     varchar2
  ,p_entry_information17           in     varchar2
  ,p_entry_information18           in     varchar2
  ,p_entry_information19           in     varchar2
  ,p_entry_information20           in     varchar2
  ,p_entry_information21           in     varchar2
  ,p_entry_information22           in     varchar2
  ,p_entry_information23           in     varchar2
  ,p_entry_information24           in     varchar2
  ,p_entry_information25           in     varchar2
  ,p_entry_information26           in     varchar2
  ,p_entry_information27           in     varchar2
  ,p_entry_information28           in     varchar2
  ,p_entry_information29           in     varchar2
  ,p_entry_information30           in     varchar2
  ,p_date_earned                   in     date
  ,p_personal_payment_method_id    in     number
  ,p_subpriority                   in     number
  ,p_batch_sequence                in     number
  ,p_concatenated_segments         in     varchar2
  ,p_cost_allocation_keyflex_id    in     number
  ,p_effective_date                in     date
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_element_name                  in     varchar2
  ,p_element_type_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_reason                        in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_value_1                       in     varchar2
  ,p_value_2                       in     varchar2
  ,p_value_3                       in     varchar2
  ,p_value_4                       in     varchar2
  ,p_value_5                       in     varchar2
  ,p_value_6                       in     varchar2
  ,p_value_7                       in     varchar2
  ,p_value_8                       in     varchar2
  ,p_value_9                       in     varchar2
  ,p_value_10                      in     varchar2
  ,p_value_11                      in     varchar2
  ,p_value_12                      in     varchar2
  ,p_value_13                      in     varchar2
  ,p_value_14                      in     varchar2
  ,p_value_15                      in     varchar2
  ,p_batch_line_id                 in     number
  ,p_object_version_number         in     number
  );
--
end pay_batch_element_entry_bk2;

 

/
