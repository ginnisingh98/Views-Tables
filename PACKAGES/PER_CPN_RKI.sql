--------------------------------------------------------
--  DDL for Package PER_CPN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CPN_RKI" AUTHID CURRENT_USER as
/* $Header: pecpnrhi.pkh 120.0 2005/05/31 07:14:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert	(
	p_competence_id                 in number,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_description                   in varchar2,
	p_date_from                     in date,
	p_date_to                       in date,
	p_behavioural_indicator         in varchar2,
	p_certification_required        in varchar2,
	p_evaluation_method             in varchar2,
	p_renewal_period_frequency      in number,
	p_renewal_period_units          in varchar2,
	p_min_level                     in number,
  	p_max_level                     in number,
        p_rating_scale_id               in number,
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
        p_competence_alias              in varchar2,
        p_competence_definition_id      in number
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
end per_cpn_rki;

 

/
