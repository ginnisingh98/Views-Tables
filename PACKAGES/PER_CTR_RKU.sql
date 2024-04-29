--------------------------------------------------------
--  DDL for Package PER_CTR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTR_RKU" AUTHID CURRENT_USER as
/* $Header: pectrrhi.pkh 120.2 2007/02/19 11:58:34 ssutar ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_contact_relationship_id      in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_contact_person_id            in number
  ,p_contact_type                 in varchar2
  ,p_comments                     in long
  ,p_primary_contact_flag         in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_date_start                   in date
  ,p_start_life_reason_id         in number
  ,p_date_end                     in date
  ,p_end_life_reason_id           in number
  ,p_rltd_per_rsds_w_dsgntr_flag  in varchar2
  ,p_personal_flag                in varchar2
  ,p_sequence_number              in number
  ,p_cont_attribute_category      in varchar2
  ,p_cont_attribute1              in varchar2
  ,p_cont_attribute2              in varchar2
  ,p_cont_attribute3              in varchar2
  ,p_cont_attribute4              in varchar2
  ,p_cont_attribute5              in varchar2
  ,p_cont_attribute6              in varchar2
  ,p_cont_attribute7              in varchar2
  ,p_cont_attribute8              in varchar2
  ,p_cont_attribute9              in varchar2
  ,p_cont_attribute10             in varchar2
  ,p_cont_attribute11             in varchar2
  ,p_cont_attribute12             in varchar2
  ,p_cont_attribute13             in varchar2
  ,p_cont_attribute14             in varchar2
  ,p_cont_attribute15             in varchar2
  ,p_cont_attribute16             in varchar2
  ,p_cont_attribute17             in varchar2
  ,p_cont_attribute18             in varchar2
  ,p_cont_attribute19             in varchar2
  ,p_cont_attribute20             in varchar2
  ,p_cont_information_category      in varchar2
  ,p_cont_information1              in varchar2
  ,p_cont_information2              in varchar2
  ,p_cont_information3              in varchar2
  ,p_cont_information4              in varchar2
  ,p_cont_information5              in varchar2
  ,p_cont_information6              in varchar2
  ,p_cont_information7              in varchar2
  ,p_cont_information8              in varchar2
  ,p_cont_information9              in varchar2
  ,p_cont_information10             in varchar2
  ,p_cont_information11             in varchar2
  ,p_cont_information12             in varchar2
  ,p_cont_information13             in varchar2
  ,p_cont_information14             in varchar2
  ,p_cont_information15             in varchar2
  ,p_cont_information16             in varchar2
  ,p_cont_information17             in varchar2
  ,p_cont_information18             in varchar2
  ,p_cont_information19             in varchar2
  ,p_cont_information20             in varchar2
  ,p_third_party_pay_flag         in varchar2
  ,p_bondholder_flag              in varchar2
  ,p_dependent_flag               in varchar2
  ,p_beneficiary_flag             in varchar2
  ,p_object_version_number        in number
  ,p_effective_date               in date
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_contact_person_id_o          in number
  ,p_contact_type_o               in varchar2
  ,p_comments_o                   in long
  ,p_primary_contact_flag_o       in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_date_start_o                 in date
  ,p_start_life_id_o              in number
  ,p_date_end_o                   in date
  ,p_end_life_id_o                in number
  ,p_rltd_per_dsgntr_flag_o       in varchar2
  ,p_personal_flag_o              in varchar2
  ,p_sequence_number_o            in number
  ,p_cont_attribute_category_o    in varchar2
  ,p_cont_attribute1_o            in varchar2
  ,p_cont_attribute2_o            in varchar2
  ,p_cont_attribute3_o            in varchar2
  ,p_cont_attribute4_o            in varchar2
  ,p_cont_attribute5_o            in varchar2
  ,p_cont_attribute6_o            in varchar2
  ,p_cont_attribute7_o            in varchar2
  ,p_cont_attribute8_o            in varchar2
  ,p_cont_attribute9_o            in varchar2
  ,p_cont_attribute10_o           in varchar2
  ,p_cont_attribute11_o           in varchar2
  ,p_cont_attribute12_o           in varchar2
  ,p_cont_attribute13_o           in varchar2
  ,p_cont_attribute14_o           in varchar2
  ,p_cont_attribute15_o           in varchar2
  ,p_cont_attribute16_o           in varchar2
  ,p_cont_attribute17_o           in varchar2
  ,p_cont_attribute18_o           in varchar2
  ,p_cont_attribute19_o           in varchar2
  ,p_cont_attribute20_o           in varchar2
  ,p_cont_information_category_o    in varchar2
  ,p_cont_information1_o            in varchar2
  ,p_cont_information2_o            in varchar2
  ,p_cont_information3_o            in varchar2
  ,p_cont_information4_o            in varchar2
  ,p_cont_information5_o            in varchar2
  ,p_cont_information6_o            in varchar2
  ,p_cont_information7_o            in varchar2
  ,p_cont_information8_o            in varchar2
  ,p_cont_information9_o            in varchar2
  ,p_cont_information10_o           in varchar2
  ,p_cont_information11_o           in varchar2
  ,p_cont_information12_o           in varchar2
  ,p_cont_information13_o           in varchar2
  ,p_cont_information14_o           in varchar2
  ,p_cont_information15_o           in varchar2
  ,p_cont_information16_o           in varchar2
  ,p_cont_information17_o           in varchar2
  ,p_cont_information18_o           in varchar2
  ,p_cont_information19_o           in varchar2
  ,p_cont_information20_o           in varchar2
  ,p_third_party_pay_flag_o       in varchar2
  ,p_bondholder_flag_o            in varchar2
  ,p_dependent_flag_o             in varchar2
  ,p_beneficiary_flag_o           in varchar2
  ,p_object_version_number_o      in number
);
end per_ctr_rku;

/
