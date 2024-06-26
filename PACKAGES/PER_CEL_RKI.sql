--------------------------------------------------------
--  DDL for Package PER_CEL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CEL_RKI" AUTHID CURRENT_USER as
/* $Header: pecelrhi.pkh 120.1.12010000.2 2008/08/06 09:06:10 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_competence_element_id         in number,
	p_object_version_number         in number,
	p_type                          in varchar2,
	p_business_group_id             in number,
	p_enterprise_id                 in number,
	p_competence_id                 in number,
--      p_member_competence_set_id      in number, column is currently not in use
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
	p_party_id                      in number
       ,p_qualification_type_id         in number
       ,p_unit_standard_type            in varchar2
       ,p_status                        in varchar2
       ,p_information_category          in varchar2
       ,p_information1                  in varchar2
       ,p_information2                  in varchar2
       ,p_information3                  in varchar2
       ,p_information4                  in varchar2
       ,p_information5                  in varchar2
       ,p_information6                  in varchar2
       ,p_information7                  in varchar2
       ,p_information8                  in varchar2
       ,p_information9                  in varchar2
       ,p_information10                 in varchar2
       ,p_information11                 in varchar2
       ,p_information12                 in varchar2
       ,p_information13                 in varchar2
       ,p_information14                 in varchar2
       ,p_information15                 in varchar2
       ,p_information16                 in varchar2
       ,p_information17                 in varchar2
       ,p_information18                 in varchar2
       ,p_information19                 in varchar2
       ,p_information20                 in varchar2
       ,p_achieved_date                 in date
       ,p_appr_line_score	        in number
       );

end per_cel_rki;

/
