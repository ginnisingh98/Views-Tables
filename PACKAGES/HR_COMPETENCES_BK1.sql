--------------------------------------------------------
--  DDL for Package HR_COMPETENCES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCES_BK1" AUTHID CURRENT_USER as
/* $Header: pecpnapi.pkh 120.1 2005/11/28 03:21:27 dsaxby noship $ */
--
--
-- create_competence_b
--
Procedure create_competence_b	(
     p_effective_date               in  date      ,
--     p_name                         in  varchar2  ,
     p_business_group_id            in 	number    ,
     p_description                  in 	varchar2  ,
     p_competence_alias             in  varchar2  ,
     p_date_from                    in  date      ,
     p_date_to                      in  date	  ,
     p_behavioural_indicator        in 	varchar2  ,
     p_certification_required       in 	varchar2  ,
     p_evaluation_method            in 	varchar2  ,
     p_renewal_period_frequency     in 	number    ,
     p_renewal_period_units         in 	varchar2  ,
     p_rating_scale_id              in  number    ,
     p_attribute_category           in 	varchar2  ,
     p_attribute1                   in 	varchar2  ,
     p_attribute2                   in 	varchar2  ,
     p_attribute3                   in 	varchar2  ,
     p_attribute4                   in 	varchar2  ,
     p_attribute5                   in 	varchar2  ,
     p_attribute6                   in 	varchar2  ,
     p_attribute7                   in 	varchar2  ,
     p_attribute8                   in 	varchar2  ,
     p_attribute9                   in 	varchar2  ,
     p_attribute10                  in 	varchar2  ,
     p_attribute11                  in 	varchar2  ,
     p_attribute12                  in 	varchar2  ,
     p_attribute13                  in 	varchar2  ,
     p_attribute14                  in 	varchar2  ,
     p_attribute15                  in 	varchar2  ,
     p_attribute16                  in 	varchar2  ,
     p_attribute17                  in 	varchar2  ,
     p_attribute18                  in 	varchar2  ,
     p_attribute19                  in 	varchar2  ,
     p_attribute20                  in 	varchar2  ,
     p_segment1			    in  varchar2  ,
     p_segment2                     in  varchar2  ,
     p_segment3                     in  varchar2  ,
     p_segment4                     in  varchar2  ,
     p_segment5                     in  varchar2  ,
     p_segment6                     in  varchar2  ,
     p_segment7                     in  varchar2  ,
     p_segment8                     in  varchar2  ,
     p_segment9                     in  varchar2  ,
     p_segment10                    in  varchar2  ,
     p_segment11                    in  varchar2  ,
     p_segment12                    in  varchar2  ,
     p_segment13                    in  varchar2  ,
     p_segment14                    in  varchar2  ,
     p_segment15                    in  varchar2  ,
     p_segment16                    in  varchar2  ,
     p_segment17                    in  varchar2  ,
     p_segment18                    in  varchar2  ,
     p_segment19                    in  varchar2  ,
     p_segment20                    in  varchar2  ,
     p_segment21                    in  varchar2  ,
     p_segment22                    in  varchar2  ,
     p_segment23                    in  varchar2  ,
     p_segment24                    in  varchar2  ,
     p_segment25                    in  varchar2  ,
     p_segment26                    in  varchar2  ,
     p_segment27                    in  varchar2  ,
     p_segment28                    in  varchar2  ,
     p_segment29                    in  varchar2  ,
     p_segment30                    in  varchar2  ,
     p_concat_segments              in  varchar2,
     p_language_code                in  varchar2
    ,p_competence_cluster            in varchar2   -- BUG3356369
    ,p_unit_standard_id              in varchar2
    ,p_credit_type                   in varchar2
    ,p_credits                       in number
    ,p_level_type                    in varchar2
    ,p_level_number                  in number
    ,p_field                         in varchar2
    ,p_sub_field                     in varchar2
    ,p_provider                      in varchar2
    ,p_qa_organization               in varchar2
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
);
--
-- create_competence_a
--
Procedure create_competence_a	(
     p_competence_id                in  number    ,
     p_object_version_number        in 	number    ,
     p_effective_date               in  date      ,
     p_name                         in 	varchar2  ,
     p_business_group_id            in 	number   ,
     p_description                  in  	varchar2  ,
     p_competence_alias             in  varchar2  ,
     p_date_from                    in    date      ,
     p_date_to                      in    date	    ,
     p_behavioural_indicator        in 	varchar2  ,
     p_certification_required       in 	varchar2  ,
     p_evaluation_method            in 	varchar2  ,
     p_renewal_period_frequency     in 	number    ,
     p_renewal_period_units         in 	varchar2  ,
     p_rating_scale_id              in    number    ,
     p_attribute_category           in 	varchar2  ,
     p_attribute1                   in 	varchar2  ,
     p_attribute2                   in 	varchar2  ,
     p_attribute3                   in 	varchar2  ,
     p_attribute4                   in 	varchar2  ,
     p_attribute5                   in 	varchar2  ,
     p_attribute6                   in 	varchar2  ,
     p_attribute7                   in 	varchar2  ,
     p_attribute8                   in 	varchar2  ,
     p_attribute9                   in 	varchar2  ,
     p_attribute10                  in 	varchar2  ,
     p_attribute11                  in 	varchar2  ,
     p_attribute12                  in 	varchar2  ,
     p_attribute13                  in 	varchar2  ,
     p_attribute14                  in 	varchar2  ,
     p_attribute15                  in 	varchar2  ,
     p_attribute16                  in 	varchar2  ,
     p_attribute17                  in 	varchar2  ,
     p_attribute18                  in 	varchar2  ,
     p_attribute19                  in 	varchar2  ,
     p_attribute20                  in 	varchar2  ,
     p_segment1                     in  varchar2  ,
     p_segment2                     in  varchar2  ,
     p_segment3                     in  varchar2  ,
     p_segment4                     in  varchar2  ,
     p_segment5                     in  varchar2  ,
     p_segment6                     in  varchar2  ,
     p_segment7                     in  varchar2  ,
     p_segment8                     in  varchar2  ,
     p_segment9                     in  varchar2  ,
     p_segment10                    in  varchar2  ,
     p_segment11                    in  varchar2  ,
     p_segment12                    in  varchar2  ,
     p_segment13                    in  varchar2  ,
     p_segment14                    in  varchar2  ,
     p_segment15                    in  varchar2  ,
     p_segment16                    in  varchar2  ,
     p_segment17                    in  varchar2  ,
     p_segment18                    in  varchar2  ,
     p_segment19                    in  varchar2  ,
     p_segment20                    in  varchar2  ,
     p_segment21                    in  varchar2  ,
     p_segment22                    in  varchar2  ,
     p_segment23                    in  varchar2  ,
     p_segment24                    in  varchar2  ,
     p_segment25                    in  varchar2  ,
     p_segment26                    in  varchar2  ,
     p_segment27                    in  varchar2  ,
     p_segment28                    in  varchar2  ,
     p_segment29                    in  varchar2  ,
     p_segment30                    in  varchar2
    ,p_concat_segments              in varchar2
    ,p_competence_definition_id     in number
    ,p_language_code                in varchar2
    ,p_competence_cluster           in varchar2   -- BUG3356369
    ,p_unit_standard_id             in varchar2
    ,p_credit_type                  in varchar2
    ,p_credits                      in number
    ,p_level_type                   in varchar2
    ,p_level_number                 in number
    ,p_field                        in varchar2
    ,p_sub_field                    in varchar2
    ,p_provider                     in varchar2
    ,p_qa_organization              in varchar2
    ,p_information_category         in varchar2
    ,p_information1                 in varchar2
    ,p_information2                 in varchar2
    ,p_information3                 in varchar2
    ,p_information4                 in varchar2
    ,p_information5                 in varchar2
    ,p_information6                 in varchar2
    ,p_information7                 in varchar2
    ,p_information8                 in varchar2
    ,p_information9                 in varchar2
    ,p_information10                in varchar2
    ,p_information11                in varchar2
    ,p_information12                in varchar2
    ,p_information13                in varchar2
    ,p_information14                in varchar2
    ,p_information15                in varchar2
    ,p_information16                in varchar2
    ,p_information17                in varchar2
    ,p_information18                in varchar2
    ,p_information19                in varchar2
    ,p_information20                in varchar2
);

end hr_competences_bk1;

 

/
