--------------------------------------------------------
--  DDL for Package PAY_RI_AC_TAX_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RI_AC_TAX_RULE" AUTHID CURRENT_USER as
/* $Header: payacemptaxwrap.pkh 120.0 2005/09/10 03:49:03 psnellin noship $ */

PROCEDURE HR_DataPump
          (p_dp_mode                 IN Varchar2
          ,p_effective_date          IN Date
          ,p_spreadsheet_identifier  IN Varchar2
          );

procedure create_ac_emptaxrule
(
  p_business_group                 IN      number    default hr_api.g_number
  ,p_effective_date                 IN      date      default hr_api.g_date
  ,p_employee                       IN      varchar2  default hr_api.g_varchar2
  ,p_assignment                     IN      varchar2  default hr_api.g_varchar2
  ,p_legislation                    IN      varchar2  default hr_api.g_varchar2
  ,p_spreadsheet_identifier         IN      varchar2  default hr_api.g_varchar2
  ,p_sui_state                      IN      varchar2  default hr_api.g_varchar2
  ,p_state_prov_code                IN      varchar2  default hr_api.g_varchar2
  ,p_county                         IN      varchar2  default hr_api.g_varchar2
  ,p_city                           IN      varchar2  default hr_api.g_varchar2
  ,p_override_prov_of_emplt         IN      varchar2  default hr_api.g_varchar2
  ,p_basic_amt_flag                 IN      varchar2  default hr_api.g_varchar2
  ,p_basic_amt                      IN      number    default hr_api.g_number
  ,p_tax_credit                     IN      number    default hr_api.g_number
  ,p_filing_status_code             IN      varchar2  default hr_api.g_varchar2
  ,p_allowances                     IN      number    default hr_api.g_number
  ,p_additional_tax                 IN      number    default hr_api.g_number
  ,p_secondary_allowances           IN      number    default hr_api.g_number
  ,p_exemption_amt                  IN      number    default hr_api.g_number
  ,p_sit_optional_calc_ind          IN      varchar2  default hr_api.g_varchar2
  ,p_addtl_allowance_rate           IN      number    default hr_api.g_number
  ,p_pres_zone_dedn                 IN      number    default hr_api.g_number
  ,p_tax_exempt1                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt2                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt3                    IN      varchar2  default hr_api.g_varchar2
  ,p_tax_exempt4                    IN      varchar2  default hr_api.g_varchar2
  ,p_override_rate                  IN      number    default hr_api.g_number
  ,p_override_amount                IN      number    default hr_api.g_number
  ,p_override_supp_rate             IN      number    default hr_api.g_number
  ,p_annual_dedn                    IN      number    default hr_api.g_number
  ,p_labor_fund_contr               IN      number    default hr_api.g_number
  ,p_allowance_reject_date          IN      date      default hr_api.g_date
  ,p_eic_filing_status              IN      varchar2  default hr_api.g_varchar2
  ,p_statutory_employee             IN      varchar2  default hr_api.g_varchar2
  ,p_cumulative_taxation            IN      varchar2  default hr_api.g_varchar2
  ,p_non_resident                   IN      varchar2  default hr_api.g_varchar2
  ,p_sui_base_override_amount       IN      number    default hr_api.g_number
  ,p_school_district                IN      varchar2  default hr_api.g_varchar2
  ,p_comm_renumeration              IN      number    default hr_api.g_number
  ,p_comm_expenses                  IN      number    default hr_api.g_number
  ,p_spouse_or_equivalent           IN      varchar2  default hr_api.g_varchar2
  ,p_disability_status              IN      varchar2  default hr_api.g_varchar2
  ,p_number_of_dependents           IN      number    default hr_api.g_number
  ,p_number_of_infirm_dependents    IN      number    default hr_api.g_number
  ,p_sta_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_sta_information1               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information2               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information3               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information4               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information5               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information6               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information7               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information8               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information9               in     varchar2  default hr_api.g_varchar2
  ,p_sta_information10              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information11              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information12              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information13              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information14              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information15              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information16              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information17              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information18              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information19              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information20              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information21              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information22              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information23              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information24              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information25              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information26              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information27              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information28              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information29              in     varchar2  default hr_api.g_varchar2
  ,p_sta_information30              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information1               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information2               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information3               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information4               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information5               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information6               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information7               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information8               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information9               in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information10              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information11              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information12              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information13              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information14              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information15              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information16              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information17              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information18              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information19              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information20              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information21              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information22              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information23              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information24              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information25              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information26              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information27              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information28              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information29              in     varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information30              in     varchar2  default hr_api.g_varchar2
  ,p_additional_info1                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info2                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info3                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info4                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info5                in     varchar2  default hr_api.g_varchar2
  ,p_additional_info6                in     number  default hr_api.g_number
  ,p_additional_info7                in     number  default hr_api.g_number
  ,p_additional_info8                in     number  default hr_api.g_number
  ,p_additional_info9                in     number  default hr_api.g_number
  ,p_additional_info10               in     number  default hr_api.g_number
 );

end pay_ri_ac_tax_rule;

 

/
