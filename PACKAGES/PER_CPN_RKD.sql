--------------------------------------------------------
--  DDL for Package PER_CPN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPN_RKD" AUTHID CURRENT_USER as
/* $Header: pecpnrhi.pkh 120.0 2005/05/31 07:14:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
      p_competence_id                 in number,
      p_name_o                        in varchar2,
      p_business_group_id_o           in number,
      p_object_version_number_o       in number,
      p_description_o                 in varchar2,
      p_date_from_o                   in date,
      p_date_to_o                     in date,
      p_behavioural_indicator_o       in varchar2,
      p_certification_required_o      in varchar2,
      p_evaluation_method_o           in varchar2,
      p_renewal_period_frequency_o    in number,
      p_renewal_period_units_o        in varchar2,
      p_min_level_o                   in number,
      p_max_level_o                   in number,
      p_rating_scale_id_o             in number,
      p_attribute_category_o          in varchar2,
      p_attribute1_o                  in varchar2,
      p_attribute2_o                  in varchar2,
      p_attribute3_o                  in varchar2,
      p_attribute4_o                  in varchar2,
      p_attribute5_o                  in varchar2,
      p_attribute6_o                  in varchar2,
      p_attribute7_o                  in varchar2,
      p_attribute8_o                  in varchar2,
      p_attribute9_o                  in varchar2,
      p_attribute10_o                 in varchar2,
      p_attribute11_o                 in varchar2,
      p_attribute12_o                 in varchar2,
      p_attribute13_o                 in varchar2,
      p_attribute14_o                 in varchar2,
      p_attribute15_o                 in varchar2,
      p_attribute16_o                 in varchar2,
      p_attribute17_o                 in varchar2,
      p_attribute18_o                 in varchar2,
      p_attribute19_o                 in varchar2,
      p_attribute20_o                 in varchar2,
      p_competence_alias_o            in varchar2,
      p_competence_definition_id_o    in number
     ,p_competence_cluster_o          in varchar2   -- BUG3356369
     ,p_unit_standard_id_o            in varchar2
     ,p_credit_type_o                 in varchar2
     ,p_credits_o                     in number
     ,p_level_type_o                  in varchar2
     ,p_level_number_o                in number
     ,p_field_o                       in varchar2
     ,p_sub_field_o                   in varchar2
     ,p_provider_o                    in varchar2
     ,p_qa_organization_o             in varchar2
     ,p_information_category_o        in varchar2
     ,p_information1_o                in varchar2
     ,p_information2_o                in varchar2
     ,p_information3_o                in varchar2
     ,p_information4_o                in varchar2
     ,p_information5_o                in varchar2
     ,p_information6_o                in varchar2
     ,p_information7_o                in varchar2
     ,p_information8_o                in varchar2
     ,p_information9_o                in varchar2
     ,p_information10_o               in varchar2
     ,p_information11_o               in varchar2
     ,p_information12_o               in varchar2
     ,p_information13_o               in varchar2
     ,p_information14_o               in varchar2
     ,p_information15_o               in varchar2
     ,p_information16_o               in varchar2
     ,p_information17_o               in varchar2
     ,p_information18_o               in varchar2
     ,p_information19_o               in varchar2
     ,p_information20_o               in varchar2
   );

end per_cpn_rkd;

 

/
