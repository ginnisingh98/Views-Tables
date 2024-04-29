--------------------------------------------------------
--  DDL for Package PER_CEL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEL_RKU" AUTHID CURRENT_USER as
/* $Header: pecelrhi.pkh 120.1.12010000.2 2008/08/06 09:06:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update	(
	p_competence_element_id         in number,
	p_object_version_number         in number,
	p_type                          in varchar2,
	p_business_group_id             in number,
	p_enterprise_id                 in number,
	p_competence_id                 in number,
--      p_member_competence_set_id      in number,
	p_proficiency_level_id          in number,
	p_high_proficiency_level_id     in number,
	p_weighting_level_id            in number,
	p_rating_level_id               in number,
	p_person_id                     in number,
	p_job_id                        in number,
	p_valid_grade_id                in number,
	p_position_id                   in number,
	p_organization_id               in number,
--      p_work_item_id                  in number,
--      p_competence_set_id             in number,
	p_parent_competence_element_id  in number,
	p_activity_version_id           in number,
	p_assessment_id                 in number,
	p_assessment_type_id            in number,
	p_mandatory                     in varchar2,
	p_effective_date_from           in date,
	p_effective_date_to             in date,
	p_group_competence_type         in varchar2,
	p_competence_type               in varchar2,
	p_normal_elapse_duration        in number,
	p_normal_elapse_duration_unit   in varchar2,
	p_sequence_number               in number,
	p_source_of_proficiency_level   in varchar2,
	p_line_score                    in number,
	p_certification_date            in date,
	p_certification_method          in varchar2,
	p_next_certification_date       in date,
	p_comments                      in varchar2,
	p_attribute_category            in varchar2,
	p_attribute1                    in varchar2,
	p_attribute2                    in varchar2,
	p_attribute3                    in varchar2,
	p_attribute4                    in varchar2,
	p_attribute5                    in varchar2,
	p_attribute6                    in varchar2,
	p_attribute7                    in varchar2,
	p_attribute8                    in varchar2,
	p_attribute9                    in varchar2,
	p_attribute10                   in varchar2,
	p_attribute11                   in varchar2,
	p_attribute12                   in varchar2,
	p_attribute13                   in varchar2,
	p_attribute14                   in varchar2,
	p_attribute15                   in varchar2,
	p_attribute16                   in varchar2,
	p_attribute17                   in varchar2,
	p_attribute18                   in varchar2,
	p_attribute19                   in varchar2,
	p_attribute20                   in varchar2,
        p_object_id                     in number,
        p_object_name                   in varchar2,
	p_party_id                      in number,  -- HR/TCA merge
    -- BUG3356369
        p_qualification_type_id         in number,
        p_unit_standard_type            in varchar2,
        p_status                        in varchar2,
        p_information_category          in varchar2,
        p_information1                  in varchar2,
        p_information2                  in varchar2,
        p_information3                  in varchar2,
        p_information4                  in varchar2,
        p_information5                  in varchar2,
        p_information6                  in varchar2,
        p_information7                  in varchar2,
        p_information8                  in varchar2,
        p_information9                  in varchar2,
        p_information10                 in varchar2,
        p_information11                 in varchar2,
        p_information12                 in varchar2,
        p_information13                 in varchar2,
        p_information14                 in varchar2,
        p_information15                 in varchar2,
        p_information16                 in varchar2,
        p_information17                 in varchar2,
        p_information18                 in varchar2,
        p_information19                 in varchar2,
        p_information20                 in varchar2,
        p_achieved_date                 in date,
        p_appr_line_score	        in number,
	p_object_version_number_o       in number,
	p_type_o                        in varchar2,
	p_business_group_id_o           in number,
	p_enterprise_id_o               in number,
	p_competence_id_o               in number,
--      p_member_competence_set_id_o    in number,
	p_proficiency_level_id_o        in number,
	p_high_proficiency_level_id_o   in number,
	p_weighting_level_id_o          in number,
	p_rating_level_id_o             in number,
	p_person_id_o                   in number,
	p_job_id_o                      in number,
	p_valid_grade_id_o              in number,
	p_position_id_o                 in number,
	p_organization_id_o             in number,
--      p_work_item_id_o                in number,
--      p_competence_set_id_o           in number,
	p_parent_competence_element_o   in number,
	p_activity_version_id_o         in number,
	p_assessment_id_o               in number,
	p_assessment_type_id_o          in number,
	p_mandatory_o                   in varchar2,
	p_effective_date_from_o         in date,
	p_effective_date_to_o           in date,
	p_group_competence_type_o       in varchar2,
	p_competence_type_o             in varchar2,
	p_normal_elapse_duration_o      in number,
	p_normal_elapse_duration_uni_o  in varchar2,
	p_sequence_number_o             in number,
	p_source_of_proficiency_leve_o  in varchar2,
	p_line_score_o                  in number,
	p_certification_date_o          in date,
	p_certification_method_o        in varchar2,
	p_next_certification_date_o     in date,
	p_comments_o                    in varchar2,
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
        p_object_id_o                   in number,
        p_object_name_o                 in varchar2,
	p_party_id_o                    in number -- HR/TCA merge
     -- BUG3356369
       ,p_qualification_type_id_o       in number
       ,p_unit_standard_type_o          in varchar2
       ,p_status_o                      in varchar2
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
       ,p_achieved_date_o               in date
       ,p_appr_line_score_o	        in number
      );

end per_cel_rku;

/
