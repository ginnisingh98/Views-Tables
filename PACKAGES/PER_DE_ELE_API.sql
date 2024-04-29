--------------------------------------------------------
--  DDL for Package PER_DE_ELE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DE_ELE_API" AUTHID CURRENT_USER AS
/*$Header: perdeele.pkh 120.1 2006/10/11 14:44:06 spendhar noship $*/


PROCEDURE delete_tax_information
  (p_validate                      in     boolean  default false
  ,p_datetrack_delete_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  );

PROCEDURE Update_tax_information
(
  p_validate                      in     boolean   default false,
  p_datetrack_update_mode         in     varchar2,
  p_effective_date                in     date,
  p_business_group_id             in     number,
  p_element_entry_id              in     number,
  p_object_version_number         in out nocopy number,
  p_entry_information_category varchar2  default 'DE_TAX INFORMATION',
  p_tax_year		       varchar2  default hr_api.g_varchar2,
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
--  p_assignment_id              varchar2  default hr_api.g_varchar2,
  p_updated		       varchar2  default hr_api.g_varchar2,
  p_effective_start_date             out nocopy date,
  p_effective_end_date               out nocopy date,
  p_update_warning                   out nocopy boolean
  );

PROCEDURE Insert_tax_information
(
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_link_id               in     number
  ,p_entry_type                    in     varchar2
  ,p_entry_information_category    in     varchar2 default 'DE_TAX INFORMATION'
  ,p_tax_year                      in     varchar2 default hr_api.g_varchar2
  ,p_tax_card_number               in     varchar2  default hr_api.g_varchar2
  ,p_issue_date                    in     varchar2  default hr_api.g_varchar2
  ,p_card_issuer                   in     varchar2  default hr_api.g_varchar2
  ,p_tax_status                           varchar2  default hr_api.g_varchar2
  ,p_tax_table                            varchar2  default hr_api.g_varchar2
  ,p_tax_class                            varchar2  default hr_api.g_varchar2
--,p_tax_office                 	  varchar2  default hr_api.g_varchar2
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
--,p_effective_date_from                  varchar2  default hr_api.g_varchar2
--,p_effective_date_to                    varchar2  default hr_api.g_varchar2
  ,p_employee_church_code                 varchar2  default hr_api.g_varchar2
  ,p_spouse_church_code                   varchar2  default hr_api.g_varchar2
  ,p_bundesland_church                    varchar2  default hr_api.g_varchar2
  ,p_yearly_church_tax_flag               varchar2  default hr_api.g_varchar2
  ,p_max_church_tax_flag                  varchar2  default hr_api.g_varchar2
  ,p_updated                              varchar2  default hr_api.g_varchar2
  ,p_effective_start_date                       out nocopy date
  ,p_effective_end_date                         out nocopy date
  ,p_element_entry_id                           out nocopy number
  ,p_object_version_number                      out nocopy number
  ,p_create_warning                             out nocopy boolean );

PROCEDURE delete_tax_exemptions
  (p_validate                      in     boolean  default false
  ,p_datetrack_delete_mode         in     varchar2
  ,p_effective_date                in     date
  ,p_element_entry_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_delete_warning                   out nocopy boolean
  );

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
  --p_assignment_id              varchar2  default hr_api.g_varchar2,
  p_effective_start_date             out nocopy date,
  P_effective_end_date               out nocopy date,
  p_update_warning                   out nocopy boolean
  );

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
  ,p_create_warning                             out nocopy boolean );

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
  );

PROCEDURE update_social_insurance_info
  (   p_validate     			in     boolean  default false
     ,p_datetrack_update_mode		in     varchar2
     ,p_effective_date  		in     date
     ,p_business_group_id             	in     number
     ,p_element_entry_id                in     number
     ,p_entry_information_category      in     varchar2  default 'DE_SOCIAL INSURANCE'
     ,p_contribution_key	        in     varchar2
     ,p_health_org_id                   in     number
     ,p_pension_org_id			in     number
     ,p_unemployment_org_id	        in     number
     ,p_special_care_org_id	        in     number
     ,p_occupation_key			in     varchar2
     ,p_people_class_key	        in     varchar2
     ,p_legal_area_code			in     varchar2
     ,p_health_insurance_number		in     number
     ,p_private_health_prov_id   	in     number
     ,p_private_health_contribution	in     number
     ,p_voluntary_pension_prov_id       in     number
     ,p_voluntary_pension_contr		in     number
     ,p_voluntary_pension_number        in     varchar2
     ,p_contribution_transfer_code      in     varchar2
     ,p_special_care_contribution	in     number
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
     ,p_update_warning                  out    nocopy boolean );


PROCEDURE insert_social_insurance_info
  (  p_validate                      	in     boolean  default false
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
    ,p_voluntary_pension_number        in     varchar2
    ,p_contribution_transfer_code      in     varchar2
    ,p_special_care_contribution       in     number
    ,p_privately_insured_flag	       in     varchar2
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
    ,p_create_warning                 out     nocopy boolean );

END PER_DE_ELE_API;

/
