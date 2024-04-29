--------------------------------------------------------
--  DDL for Package Body PER_DE_ELE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DE_ELE_API" AS
/*$Header: perdeele.pkb 120.0.12000000.2 2007/03/20 15:17:27 abppradh noship $*/

-- This procedure acts as a cover api for German Tax Information. It calls the element entry
-- api.

-- Created 18.9.01  J.heer

PROCEDURE delete_tax_information
  (p_validate                      in     boolean  default false
  ,p_datetrack_delete_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  ) IS

BEGIN
  pay_element_entry_api.delete_element_entry
  (
   p_validate		    => p_validate
  ,p_datetrack_delete_mode  => p_datetrack_delete_mode
  ,p_effective_date         => p_effective_date
  ,p_element_entry_id       => p_element_entry_id
  ,p_object_version_number  => p_object_version_number
  ,p_effective_start_date   => p_effective_start_date
  ,p_effective_end_date     => p_effective_end_date
  ,p_delete_warning         => p_delete_warning );

END delete_tax_information;

PROCEDURE Update_tax_information
(
  p_validate                      in     boolean   default false,
  p_datetrack_update_mode         in     varchar2,
  p_effective_date                in     date,
  p_business_group_id             in     number,
  p_element_entry_id              in     number,
  p_object_version_number         in out nocopy number,
  p_entry_information_category varchar2  default 'DE_TAX INFORMATION',
  p_tax_year                   varchar2  default hr_api.g_varchar2,
  p_tax_card_number            varchar2  default hr_api.g_varchar2,
  p_issue_date                 varchar2  default hr_api.g_varchar2,
  p_card_issuer                varchar2  default hr_api.g_varchar2,
  p_tax_status                 varchar2  default hr_api.g_varchar2,
  p_tax_table                  varchar2  default hr_api.g_varchar2,
  p_tax_class                  varchar2  default hr_api.g_varchar2,
--p_tax_office                 varchar2  default hr_api.g_varchar2,
--p_tax_office_name            varchar2  default hr_api.g_varchar2,
  p_tax_organization_id        varchar2  default hr_api.g_varchar2,
  p_tax_card_location          varchar2  default hr_api.g_varchar2,
  p_no_of_children             varchar2  default hr_api.g_varchar2,
  p_yearly_tax_free_income     varchar2  default hr_api.g_varchar2,
  p_monthly_tax_free_income    varchar2  default hr_api.g_varchar2,
  p_additional_year_tax_income varchar2  default hr_api.g_varchar2,
  p_yearly_Income_Tax_Calc_Flag    varchar2  default hr_api.g_varchar2,
  p_chamber_contribution       varchar2  default hr_api.g_varchar2,
  p_pensioners_tax_flag        varchar2  default hr_api.g_varchar2,
  p_additional_mth_tax_income  varchar2  default hr_api.g_varchar2,
  p_employee_church_code       varchar2  default hr_api.g_varchar2,
  p_spouse_church_code         varchar2  default hr_api.g_varchar2,
  p_bundesland_church          varchar2  default hr_api.g_varchar2,
  p_yearly_church_tax_flag     varchar2  default hr_api.g_varchar2,
  p_max_church_tax_flag        varchar2  default hr_api.g_varchar2,
  p_updated                    varchar2  default hr_api.g_varchar2,
  p_effective_start_date             out nocopy date,
  p_effective_end_date               out nocopy date,
  p_update_warning                   out nocopy boolean
  ) is
  l_delete_warning             boolean;

BEGIN

 -- l_last_day_of_year := '31-DEC-' || to_char(p_effective_date,'YYYY');

  pay_element_entry_api.update_element_entry (
   p_validate 			   => p_validate
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_effective_date            	   => p_effective_date
  ,p_business_group_id        	   => p_business_group_id
  ,p_element_entry_id              => p_element_entry_id
  ,p_object_version_number  	   => p_object_version_number
  ,p_entry_information_category    => p_entry_information_category
  ,p_entry_information2		   => p_tax_year
  ,p_entry_information1            => p_tax_card_number
  ,p_entry_information3            => p_issue_date
  ,p_entry_information4            => p_card_issuer
--,p_entry_information5            => p_tax_office
--,p_entry_information6            => p_tax_office_name
  ,p_entry_information20           => p_tax_organization_id
  ,p_entry_information7            => p_tax_card_location
  ,p_entry_information8            => p_tax_status
  ,p_entry_information9            => p_tax_table
  ,p_entry_information10           => p_tax_class
  ,p_entry_information11           => p_no_of_children
  ,p_entry_information12           => p_yearly_tax_free_income
  ,p_entry_information13           => p_monthly_tax_free_income
  ,p_entry_information14           => p_additional_year_tax_income
  ,p_entry_information15           => p_Yearly_Income_Tax_Calc_flag
  ,p_entry_information16           => p_chamber_contribution
  ,p_entry_information17           => p_pensioners_tax_flag
  ,p_entry_information18           => p_additional_mth_tax_income
  ,p_entry_information19           => p_employee_church_code
  ,p_entry_information21           => p_spouse_church_code
  ,p_entry_information22           => hr_api.g_varchar2
  ,p_entry_information23           => p_bundesland_church
  ,p_entry_information24           => p_yearly_church_tax_flag
  ,p_entry_information25           => p_Max_church_tax_flag
  ,p_entry_information26           => p_updated
  ,p_entry_information27           => hr_api.g_varchar2
  ,p_entry_information28           => hr_api.g_varchar2
  ,p_entry_information29           => hr_api.g_varchar2
  ,p_entry_information30           => hr_api.g_varchar2
  ,p_updating_action_type          => hr_api.g_varchar2
  ,p_creator_type                  => hr_api.g_varchar2
  ,p_reason                        => hr_api.g_varchar2
  ,p_attribute_category            => hr_api.g_varchar2
  ,p_attribute1                    => hr_api.g_varchar2
  ,p_attribute2                    => hr_api.g_varchar2
  ,p_attribute3                    => hr_api.g_varchar2
  ,p_attribute4                    => hr_api.g_varchar2
  ,p_attribute5                    => hr_api.g_varchar2
  ,p_attribute6                    => hr_api.g_varchar2
  ,p_attribute7                    => hr_api.g_varchar2
  ,p_attribute8                    => hr_api.g_varchar2
  ,p_attribute9                    => hr_api.g_varchar2
  ,p_attribute10                   => hr_api.g_varchar2
  ,p_attribute11                   =>  hr_api.g_varchar2
  ,p_attribute12                   => hr_api.g_varchar2
  ,p_attribute13                   => hr_api.g_varchar2
  ,p_attribute14                   => hr_api.g_varchar2
  ,p_attribute15                   => hr_api.g_varchar2
  ,p_attribute16                   => hr_api.g_varchar2
  ,p_attribute17                   => hr_api.g_varchar2
  ,p_attribute18                   => hr_api.g_varchar2
  ,p_attribute19                   => hr_api.g_varchar2
  ,p_attribute20                   => hr_api.g_varchar2
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_update_warning            	   => p_update_warning
 );
 -- Following the update, check the Tax Card details and set the end date back to the last day of the year.
-- no longer required
/*  IF p_datetrack_update_mode in ('FUTURE_CHANGES','UPDATE_OVERRIDE') THEN
     pay_element_entry_api.delete_element_entry
    (
     p_datetrack_delete_mode  => 'DELETE'
    ,p_effective_date         => l_last_day_of_year
    ,p_element_entry_id       => p_element_entry_id
    ,p_object_version_number  => p_object_version_number
    ,p_effective_start_date   => p_effective_start_date
    ,p_effective_end_date     => p_effective_end_date
    ,p_delete_warning         => l_delete_warning );
  END IF;
*/
END Update_tax_information;


PROCEDURE Insert_tax_information
(
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_entry_information_category    in     varchar2 default 'DE_TAX INFORMATION'
  ,p_tax_year                             varchar2  default hr_api.g_varchar2
  ,p_tax_card_number               in     varchar2  default hr_api.g_varchar2
  ,p_issue_date                    in     varchar2  default hr_api.g_varchar2
  ,p_card_issuer                   in     varchar2  default hr_api.g_varchar2
  ,p_tax_status                 	  varchar2  default hr_api.g_varchar2
  ,p_tax_table              	 	  varchar2  default hr_api.g_varchar2
  ,p_tax_class                            varchar2  default hr_api.g_varchar2
--,p_tax_office                           varchar2  default hr_api.g_varchar2
--,p_tax_office_name                      varchar2  default hr_api.g_varchar2
  ,p_tax_organization_id                  varchar2  default hr_api.g_varchar2
  ,p_tax_card_location                    varchar2  default hr_api.g_varchar2
  ,p_no_of_children                       varchar2  default hr_api.g_varchar2
  ,p_yearly_tax_free_income               varchar2  default hr_api.g_varchar2
  ,p_monthly_tax_free_income              varchar2  default hr_api.g_varchar2
  ,p_additional_year_tax_income           varchar2  default hr_api.g_varchar2
  ,p_yearly_Income_Tax_Calc_Flag          varchar2  default hr_api.g_varchar2
  ,p_chamber_contribution                 varchar2  default hr_api.g_varchar2
  ,p_pensioners_tax_flag                  varchar2  default hr_api.g_varchar2
  ,p_additional_mth_tax_income            varchar2  default hr_api.g_varchar2
--  ,p_effective_date_from                varchar2  default hr_api.g_varchar2
--  ,p_effective_date_to                  varchar2  default hr_api.g_varchar2
  ,p_employee_church_code                 varchar2  default hr_api.g_varchar2
  ,p_spouse_church_code                   varchar2  default hr_api.g_varchar2
  ,p_bundesland_church                    varchar2  default hr_api.g_varchar2
  ,p_yearly_church_tax_flag		  varchar2  default hr_api.g_varchar2
  ,p_max_church_tax_flag                  varchar2  default hr_api.g_varchar2
  ,p_updated                              varchar2  default hr_api.g_varchar2
  ,p_effective_start_date                       out nocopy date
  ,p_effective_end_date                         out nocopy date
  ,p_element_entry_id                           out nocopy number
  ,p_object_version_number                      out nocopy number
  ,p_create_warning                             out nocopy boolean ) is

BEGIN
  pay_element_entry_api.create_element_entry
  ( p_effective_date 			=> p_effective_date
   ,p_business_group_id			=> p_business_group_id
   ,p_assignment_id			=> p_assignment_id
   ,p_element_link_id			=> p_element_link_id
   ,p_entry_type			=> p_entry_type
   ,p_entry_information2		=> p_tax_year
   ,p_entry_information_category 	=> p_entry_information_category
   ,p_entry_information1          	=> p_tax_card_number
   ,p_entry_information3                => p_issue_date
   ,p_entry_information4                => p_card_issuer
-- ,p_entry_information5     		=> p_tax_office
-- ,p_entry_information6                => p_tax_office_name
   ,p_entry_information7   		=> p_tax_card_location
   ,p_entry_information8 		=> p_tax_status
   ,p_entry_information9 		=> p_tax_table
   ,p_entry_information10		=> p_tax_class
   ,p_entry_information11    		=> p_no_of_children
   ,p_entry_information12  		=> p_yearly_tax_free_income
   ,p_entry_information13   		=> p_monthly_tax_free_income
   ,p_entry_information14 		=> p_additional_year_tax_income
   ,p_entry_information15		=> p_Yearly_Income_Tax_Calc_flag
   ,p_entry_information16		=> p_chamber_contribution
   ,p_entry_information17		=> p_pensioners_tax_flag
   ,p_entry_information18		=> p_additional_mth_tax_income
   ,p_entry_information19               => p_employee_church_code
   ,p_entry_information20               => p_tax_organization_id
   ,p_entry_information21 	        => p_spouse_church_code
   ,p_entry_information23               => p_bundesland_church
   ,p_entry_information24               => p_yearly_church_tax_flag
   ,p_entry_information25               => p_Max_church_tax_flag
   ,p_entry_information26	        => p_updated
   ,p_effective_start_date           	=> p_effective_start_date
   ,p_effective_end_date              	=> p_effective_end_date
   ,p_element_entry_id               	=> p_element_entry_id
   ,p_object_version_number         	=> p_object_version_number
   ,p_create_warning                 	=> p_create_warning );

END Insert_tax_information;

PROCEDURE delete_tax_exemptions
  (p_validate                      in     boolean  default false
  ,p_datetrack_delete_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  ) IS

l_last_day_of_year           varchar2(11);

BEGIN
  pay_element_entry_api.delete_element_entry
  (
   p_validate               => p_validate
  ,p_datetrack_delete_mode  => p_datetrack_delete_mode
  ,p_effective_date         => p_effective_date
  ,p_element_entry_id       => p_element_entry_id
  ,p_object_version_number  => p_object_version_number
  ,p_effective_start_date   => p_effective_start_date
  ,p_effective_end_date     => p_effective_end_date
  ,p_delete_warning         => p_delete_warning );

-- no longer required
-- Carry out a correction to fix the Tax card Details so that the end date is still the last day of the year

--  l_last_day_of_year := '31-DEC-' || to_char(p_effective_start_date,'YYYY');

/*  IF p_datetrack_delete_mode = 'FUTURE_CHANGES' THEN
     py_element_entry_api.delete_element_entry
    (
     p_datetrack_delete_mode  => 'DELETE'
    ,p_effective_date         => l_last_day_of_year
    ,p_element_entry_id       => p_element_entry_id
    ,p_object_version_number  => p_object_version_number
    ,p_effective_start_date   => p_effective_start_date
    ,p_effective_end_date     => p_effective_end_date
    ,p_delete_warning         => p_delete_warning );
  END IF;  */

END delete_tax_exemptions;

PROCEDURE Update_tax_exemptions
(
  p_validate                      in     boolean   default false,
  p_datetrack_update_mode         in     varchar2,
  p_effective_date                in     date,
  p_business_group_id             in     number,
  p_element_entry_id              in     number,
  p_object_version_number         in out nocopy number,
  p_entry_information_category varchar2  default 'DE_TAX EXEMPTIONS',
  p_form_number                varchar2  default hr_api.g_varchar2,
  p_issue_date                 varchar2  default hr_api.g_varchar2,
  p_valid_from                 varchar2  default hr_api.g_varchar2,
  p_valid_to                   varchar2  default hr_api.g_varchar2,
  p_tax_free_remuneration      varchar2  default hr_api.g_varchar2,
  -- p_assignment_id              varchar2  default hr_api.g_varchar2,
  p_effective_start_date             out nocopy date,
  P_effective_end_date               out nocopy date,
  p_update_warning                   out nocopy boolean
  ) is

BEGIN

  pay_element_entry_api.update_element_entry (
   p_validate                      => p_validate
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_element_entry_id              => p_element_entry_id
  ,p_object_version_number         => p_object_version_number
  ,p_entry_information_category    => p_entry_information_category
  ,p_entry_information1 	   => p_form_number
  ,p_entry_information2            => p_issue_date
  ,p_entry_information3 	   => p_valid_from
  ,p_entry_information4  	   => p_valid_to
  ,p_entry_information5	           => p_tax_free_remuneration
  ,p_entry_information6            => hr_api.g_varchar2
  ,p_entry_information7            => hr_api.g_varchar2
  ,p_entry_information8            => hr_api.g_varchar2
  ,p_entry_information9            => hr_api.g_varchar2
  ,p_entry_information10           => hr_api.g_varchar2
  ,p_entry_information11           => hr_api.g_varchar2
  ,p_entry_information12           => hr_api.g_varchar2
  ,p_entry_information13           => hr_api.g_varchar2
  ,p_entry_information14           => hr_api.g_varchar2
  ,p_entry_information15           => hr_api.g_varchar2
  ,p_entry_information16           => hr_api.g_varchar2
  ,p_entry_information17           => hr_api.g_varchar2
  ,p_entry_information18           => hr_api.g_varchar2
  ,p_entry_information19           => hr_api.g_varchar2
  ,p_entry_information20           => hr_api.g_varchar2
  ,p_entry_information21           => hr_api.g_varchar2
  ,p_entry_information22           => hr_api.g_varchar2
  ,p_entry_information23           => hr_api.g_varchar2
  ,p_entry_information24           => hr_api.g_varchar2
  ,p_entry_information25           => hr_api.g_varchar2
  ,p_entry_information26           => hr_api.g_varchar2
  ,p_entry_information27           => hr_api.g_varchar2
  ,p_entry_information28           => hr_api.g_varchar2
  ,p_entry_information29           => hr_api.g_varchar2
  ,p_entry_information30           => hr_api.g_varchar2
  ,p_updating_action_type          => hr_api.g_varchar2
  ,p_creator_type                  => hr_api.g_varchar2
  ,p_reason                        => hr_api.g_varchar2
  ,p_attribute_category            => hr_api.g_varchar2
  ,p_attribute1                    => hr_api.g_varchar2
  ,p_attribute2                    => hr_api.g_varchar2
  ,p_attribute3                    => hr_api.g_varchar2
  ,p_attribute4                    => hr_api.g_varchar2
  ,p_attribute5                    => hr_api.g_varchar2
  ,p_attribute6                    => hr_api.g_varchar2
  ,p_attribute7                    => hr_api.g_varchar2
  ,p_attribute8                    => hr_api.g_varchar2
  ,p_attribute9                    => hr_api.g_varchar2
  ,p_attribute10                   => hr_api.g_varchar2
  ,p_attribute11                   =>  hr_api.g_varchar2
  ,p_attribute12                   => hr_api.g_varchar2
  ,p_attribute13                   => hr_api.g_varchar2
  ,p_attribute14                   => hr_api.g_varchar2
  ,p_attribute15                   => hr_api.g_varchar2
  ,p_attribute16                   => hr_api.g_varchar2
  ,p_attribute17                   => hr_api.g_varchar2
  ,p_attribute18                   => hr_api.g_varchar2
  ,p_attribute19                   => hr_api.g_varchar2
  ,p_attribute20                   => hr_api.g_varchar2
  ,p_effective_start_date    	   => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_update_warning                => p_update_warning
 );

END Update_tax_exemptions;

PROCEDURE Insert_tax_exemptions
(
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_entry_information_category    in     varchar2 default 'DE_TAX EXEMPTIONS'
  ,p_form_number                varchar2  default hr_api.g_varchar2
  ,p_issue_date                 varchar2  default hr_api.g_varchar2
  ,p_valid_from                 varchar2  default hr_api.g_varchar2
  ,p_valid_to                   varchar2  default hr_api.g_varchar2
  ,p_tax_free_remuneration      varchar2  default hr_api.g_varchar2
  ,p_effective_start_date                       out nocopy date
  ,p_effective_end_date                         out nocopy date
  ,p_element_entry_id                           out nocopy number
  ,p_object_version_number                      out nocopy number
  ,p_create_warning                             out nocopy boolean ) is

BEGIN

  pay_element_entry_api.create_element_entry
  ( p_effective_date                    => p_effective_date
   ,p_business_group_id                 => p_business_group_id
   ,p_assignment_id                     => p_assignment_id
   ,p_element_link_id                   => p_element_link_id
   ,p_entry_type                        => p_entry_type
   ,p_entry_information_category        => p_entry_information_category
   ,p_entry_information1        	=> p_form_number
   ,p_entry_information2        	=> p_issue_date
   ,p_entry_information3        	=> p_valid_from
   ,p_entry_information4        	=> p_valid_to
   ,p_entry_information5 	     	=> p_tax_free_remuneration
   ,p_effective_start_date              => p_effective_start_date
   ,p_effective_end_date                => p_effective_end_date
   ,p_element_entry_id                  => p_element_entry_id
   ,p_object_version_number             => p_object_version_number
   ,p_create_warning                    => p_create_warning );

END Insert_tax_exemptions;

/*------------------------------------------------------------------------
                                Social Insurance

-------------------------------------------------------------------------*/

PROCEDURE delete_social_insurance_info
  (p_validate                      in     boolean  default false
  ,p_datetrack_delete_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  ) is

BEGIN

 pay_element_entry_api.delete_element_entry
  (
   p_validate               => p_validate
  ,p_datetrack_delete_mode  => p_datetrack_delete_mode
  ,p_effective_date         => p_effective_date
  ,p_element_entry_id       => p_element_entry_id
  ,p_object_version_number  => p_object_version_number
  ,p_effective_start_date   => p_effective_start_date
  ,p_effective_end_date     => p_effective_end_date
  ,p_delete_warning         => p_delete_warning );

END delete_social_insurance_info;


PROCEDURE update_social_insurance_info
  (   p_validate                        in     boolean  default false
     ,p_datetrack_update_mode           in     varchar2
     ,p_effective_date                  in     date
     ,p_business_group_id               in     number
     ,p_element_entry_id                in     number
     ,p_entry_information_category      in     varchar2  default 'DE_SOCIAL INSURANCE'
     ,p_contribution_key                in     varchar2
     ,p_health_org_id                   in     number
     ,p_pension_org_id                  in     number
     ,p_unemployment_org_id             in     number
     ,p_special_care_org_id             in     number
     ,p_occupation_key                  in     varchar2
     ,p_people_class_key                in     varchar2
     ,p_legal_area_code                 in     varchar2
     ,p_health_insurance_number         in     number
     ,p_private_health_prov_id          in     number
     ,p_private_health_contribution     in     number
     ,p_voluntary_pension_prov_id       in     number
     ,p_voluntary_pension_contr         in     number
     ,p_voluntary_pension_number        in     varchar2
     ,p_contribution_transfer_code      in     varchar2
     ,p_special_care_contribution       in     number
     ,p_privately_insured_flag          in     varchar2
     ,p_add_insurance_provider 	        in     number   default hr_api.g_number
     ,p_add_ins_memship_number	        in     varchar2 default hr_api.g_varchar2
     ,p_add_ins_status	                in     varchar2 default hr_api.g_varchar2
     ,p_add_ins_start_date	        in     date     default hr_api.g_date
     ,p_add_ins_end_date  	        in     date     default hr_api.g_date
     ,p_add_ins_end_reason              in     number   default hr_api.g_number
     ,p_effective_start_date            out    nocopy date
     ,p_effective_end_date              out    nocopy date
     ,p_object_version_number           in out nocopy number
     ,p_update_warning                  out    nocopy boolean )  is

BEGIN
   pay_element_entry_api.update_element_entry (
   p_validate                      => p_validate
  ,p_datetrack_update_mode         => p_datetrack_update_mode
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_element_entry_id              => p_element_entry_id
  ,p_object_version_number         => p_object_version_number
  ,p_entry_information_category    => p_entry_information_category
  ,p_entry_information1            => p_contribution_key
  ,p_entry_information2            => p_health_org_id
  ,p_entry_information3            => p_pension_org_id
  ,p_entry_information4   	   => p_unemployment_org_id
  ,p_entry_information5   	   => p_special_care_org_id
  ,p_entry_information6   	   => p_occupation_key
  ,p_entry_information7   	   => p_people_class_key
  ,p_entry_information8   	   => p_legal_area_code
  ,p_entry_information9   	   => p_health_insurance_number
  ,p_entry_information10           => p_private_health_prov_id
  ,p_entry_information11  	   => p_private_health_contribution
  ,p_entry_information12  	   => p_voluntary_pension_prov_id
  ,p_entry_information13  	   => p_voluntary_pension_contr
  ,p_entry_information14  	   => p_contribution_transfer_code
  ,p_entry_information15  	   => p_special_care_contribution
  ,p_entry_information16           => p_privately_insured_flag
  ,p_entry_information17           => p_voluntary_pension_number
  ,p_entry_information18           => p_add_insurance_provider
  ,p_entry_information19           => p_add_ins_memship_number
  ,p_entry_information20           => p_add_ins_status
  ,p_entry_information21           => fnd_date.date_to_canonical(p_add_ins_start_date)
  ,p_entry_information22           => fnd_date.date_to_canonical(p_add_ins_end_date)
  ,p_entry_information23           => p_add_ins_end_reason
  ,p_entry_information24           => hr_api.g_varchar2
  ,p_entry_information25           => hr_api.g_varchar2
  ,p_entry_information26           => hr_api.g_varchar2
  ,p_entry_information27           => hr_api.g_varchar2
  ,p_entry_information28           => hr_api.g_varchar2
  ,p_entry_information29           => hr_api.g_varchar2
  ,p_entry_information30           => hr_api.g_varchar2
  ,p_updating_action_type          => hr_api.g_varchar2
  ,p_creator_type                  => hr_api.g_varchar2
  ,p_reason                        => hr_api.g_varchar2
  ,p_attribute_category            => hr_api.g_varchar2
  ,p_attribute1                    => hr_api.g_varchar2
  ,p_attribute2                    => hr_api.g_varchar2
  ,p_attribute3                    => hr_api.g_varchar2
  ,p_attribute4                    => hr_api.g_varchar2
  ,p_attribute5                    => hr_api.g_varchar2
  ,p_attribute6                    => hr_api.g_varchar2
  ,p_attribute7                    => hr_api.g_varchar2
  ,p_attribute8                    => hr_api.g_varchar2
  ,p_attribute9                    => hr_api.g_varchar2
  ,p_attribute10                   => hr_api.g_varchar2
  ,p_attribute11                   => hr_api.g_varchar2
  ,p_attribute12                   => hr_api.g_varchar2
  ,p_attribute13                   => hr_api.g_varchar2
  ,p_attribute14                   => hr_api.g_varchar2
  ,p_attribute15                   => hr_api.g_varchar2
  ,p_attribute16                   => hr_api.g_varchar2
  ,p_attribute17                   => hr_api.g_varchar2
  ,p_attribute18                   => hr_api.g_varchar2
  ,p_attribute19                   => hr_api.g_varchar2
  ,p_attribute20                   => hr_api.g_varchar2
  ,p_effective_start_date	   => p_effective_start_date
  ,p_effective_end_date  	   => p_effective_end_date
  ,p_update_warning       	   => p_update_warning );

END update_social_insurance_info;


PROCEDURE insert_social_insurance_info
  (  p_validate                         in     boolean  default false
    ,p_effective_date                   in     date
    ,p_business_group_id                in     number
    ,p_assignment_id                    in     number
    ,p_element_link_id                  in     number
    ,p_entry_type                       in     varchar2
    ,p_entry_information_category       in     varchar2 default 'DE_SOCIAL INSURANCE'
    ,p_contribution_key                in     varchar2
    ,p_health_org_id                   in     number
    ,p_pension_org_id                  in     number
    ,p_unemployment_org_id             in     number
    ,p_special_care_org_id             in     number
    ,p_occupation_key                  in     varchar2
    ,p_people_class_key                in     varchar2
    ,p_legal_area_code                 in     varchar2
    ,p_health_insurance_number         in     number
    ,p_private_health_prov_id          in     number
    ,p_private_health_contribution     in     number
    ,p_voluntary_pension_prov_id       in     number
    ,p_voluntary_pension_contr         in     number
    ,p_voluntary_pension_number	       in     varchar2
    ,p_contribution_transfer_code      in     varchar2
    ,p_special_care_contribution       in     number
    ,p_privately_insured_flag          in     varchar2
    ,p_add_insurance_provider 	       in     number   default null
    ,p_add_ins_memship_number	       in     varchar2 default null
    ,p_add_ins_status	               in     varchar2 default null
    ,p_add_ins_start_date	       in     date     default null
    ,p_add_ins_end_date  	       in     date     default null
    ,p_add_ins_end_reason              in     number   default null
    ,p_effective_start_date           out     nocopy date
    ,p_effective_end_date             out     nocopy date
    ,p_element_entry_id               out     nocopy number
    ,p_object_version_number          out     nocopy number
    ,p_create_warning                 out     nocopy boolean ) is

BEGIN

 pay_element_entry_api.create_element_entry
  ( p_effective_date                    => p_effective_date
   ,p_business_group_id                 => p_business_group_id
   ,p_assignment_id                     => p_assignment_id
   ,p_element_link_id                   => p_element_link_id
   ,p_entry_type                        => p_entry_type
   ,p_entry_information_category        => p_entry_information_category
   ,p_entry_information1            	=> p_contribution_key
   ,p_entry_information2            	=> p_health_org_id
   ,p_entry_information3         	=> p_pension_org_id
   ,p_entry_information4          	=> p_unemployment_org_id
   ,p_entry_information5          	=> p_special_care_org_id
   ,p_entry_information6       	     	=> p_occupation_key
   ,p_entry_information7            	=> p_people_class_key
   ,p_entry_information8            	=> p_legal_area_code
   ,p_entry_information9            	=> p_health_insurance_number
   ,p_entry_information10           	=> p_private_health_prov_id
   ,p_entry_information11           	=> p_private_health_contribution
   ,p_entry_information12           	=> p_voluntary_pension_prov_id
   ,p_entry_information13           	=> p_voluntary_pension_contr
   ,p_entry_information14           	=> p_contribution_transfer_code
   ,p_entry_information15           	=> p_special_care_contribution
   ,p_entry_information16               => p_privately_insured_flag
   ,p_entry_information17		=> p_voluntary_pension_number
   ,p_entry_information18               => p_add_insurance_provider
   ,p_entry_information19               => p_add_ins_memship_number
   ,p_entry_information20               => p_add_ins_status
   ,p_entry_information21               => fnd_date.date_to_canonical(p_add_ins_start_date)
   ,p_entry_information22               => fnd_date.date_to_canonical(p_add_ins_end_date)
   ,p_entry_information23               => p_add_ins_end_reason
   ,p_effective_start_date              => p_effective_start_date
   ,p_effective_end_date                => p_effective_end_date
   ,p_element_entry_id                  => p_element_entry_id
   ,p_object_version_number             => p_object_version_number
   ,p_create_warning                    => p_create_warning );

END insert_social_insurance_info;

END;

/
