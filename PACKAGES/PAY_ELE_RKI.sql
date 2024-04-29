--------------------------------------------------------
--  DDL for Package PAY_ELE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELE_RKI" AUTHID CURRENT_USER as
/* $Header: pyelerhi.pkh 120.0 2005/05/29 04:33:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_cost_allocation_keyflex_id   in number
  ,p_assignment_id                in number
  ,p_updating_action_id           in number
  ,p_updating_action_type         in varchar2
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_comment_id                   in number
  ,p_comments                     in varchar2
  ,p_creator_id                   in number
  ,p_reason                       in varchar2
  ,p_target_entry_id              in number
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_entry_information_category   in varchar2
  ,p_entry_information1           in varchar2
  ,p_entry_information2           in varchar2
  ,p_entry_information3           in varchar2
  ,p_entry_information4           in varchar2
  ,p_entry_information5           in varchar2
  ,p_entry_information6           in varchar2
  ,p_entry_information7           in varchar2
  ,p_entry_information8           in varchar2
  ,p_entry_information9           in varchar2
  ,p_entry_information10          in varchar2
  ,p_entry_information11          in varchar2
  ,p_entry_information12          in varchar2
  ,p_entry_information13          in varchar2
  ,p_entry_information14          in varchar2
  ,p_entry_information15          in varchar2
  ,p_entry_information16          in varchar2
  ,p_entry_information17          in varchar2
  ,p_entry_information18          in varchar2
  ,p_entry_information19          in varchar2
  ,p_entry_information20          in varchar2
  ,p_entry_information21          in varchar2
  ,p_entry_information22          in varchar2
  ,p_entry_information23          in varchar2
  ,p_entry_information24          in varchar2
  ,p_entry_information25          in varchar2
  ,p_entry_information26          in varchar2
  ,p_entry_information27          in varchar2
  ,p_entry_information28          in varchar2
  ,p_entry_information29          in varchar2
  ,p_entry_information30          in varchar2
  ,p_subpriority                  in number
  ,p_personal_payment_method_id   in number
  ,p_date_earned                  in date
  ,p_object_version_number        in number
  ,p_source_id                    in number
  ,p_balance_adj_cost_flag        in varchar2
  ,p_element_type_id              in number
  ,p_all_entry_values_null        in varchar2
  );
end pay_ele_rki;

 

/
