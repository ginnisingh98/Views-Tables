--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_PRVTAX_INF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_PRVTAX_INF_API" AUTHID CURRENT_USER as
/* $Header: pycprapi.pkh 120.3.12000000.1 2007/01/17 18:12:09 appldev noship $ */
/*#
 * This package contains employee provincial tax information APIs for Canada.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee Provincial Tax Information for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ca_emp_prvtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person, work organization and work location must exist on the effective
 * date.
 *
 * <p><b>Post Success</b><br>
 * The employee provincial tax information will be successfully inserted into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The employee provincial tax information will not be created and appropriate
 * error message will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_province_tax_inf_id If p_validate is false, then this will
 * uniquely identifies the employee provincial tax information created. If
 * p_validate is true, then it is set to null.
 * @param p_effective_start_date Start Date when the employee provincial tax
 * record is created
 * @param p_effective_end_date End Date when the employee provincial tax tax
 * record is created
 * @param p_legislation_code must be 'CA'
 * @param p_assignment_id Assignment Id for which the employee provincial tax
 * record is being created
 * @param p_business_group_id Business Group of the assignment for which the
 * provincial tax record is being created
 * @param p_province_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROVINCE_CODE}
 * @param p_jurisdiction_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE}
 * @param p_tax_credit_amount {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TAX_CREDIT_AMOUNT}
 * @param p_basic_exemption_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.BASIC_EXEMPTION_FLAG}
 * @param p_deduction_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.DEDUCTION_CODE}
 * @param p_extra_info_not_provided {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.EXTRA_INFO_NOT_PROVIDED}
 * @param p_marriage_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.MARRIAGE_STATUS}
 * @param p_no_of_infirm_dependants {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NO_OF_INFIRM_DEPENDANTS}
 * @param p_non_resident_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NON_RESIDENT_STATUS}
 * @param p_disability_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.DISABILITY_STATUS}
 * @param p_no_of_dependants {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NO_OF_DEPENDANTS}
 * @param p_annual_dedn {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.ANNUAL_DEDN}
 * @param p_total_expense_by_commission {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TOTAL_EXPENSE_BY_COMMISSION}
 * @param p_total_remnrtn_by_commission {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TOTAL_REMNRTN_BY_COMMISSION}
 * @param p_prescribed_zone_dedn_amt {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PRESCRIBED_ZONE_DEDN_AMT}
 * @param p_additional_tax {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.ADDITIONAL_TAX}
 * @param p_prov_override_rate {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_OVERRIDE_RATE}
 * @param p_prov_override_amount {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_OVERRIDE_AMOUNT}
 * @param p_prov_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_EXEMPT_FLAG}
 * @param p_pmed_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PMED_EXEMPT_FLAG}
 * @param p_wc_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.WC_EXEMPT_FLAG}
 * @param p_qpp_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.QPP_EXEMPT_FLAG}
 * @param p_tax_calc_method {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TAX_CALC_METHOD}
 * @param p_other_tax_credit {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.OTHER_TAX_CREDIT}
 * @param p_ca_tax_information_category {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION_CATEGORY}
 * @param p_ca_tax_information1 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION1}
 * @param p_ca_tax_information2 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION2}
 * @param p_ca_tax_information3 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION3}
 * @param p_ca_tax_information4 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION4}
 * @param p_ca_tax_information5 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION5}
 * @param p_ca_tax_information6 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION6}
 * @param p_ca_tax_information7 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION7}
 * @param p_ca_tax_information8 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION8}
 * @param p_ca_tax_information9 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION9}
 * @param p_ca_tax_information10 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION10}
 * @param p_ca_tax_information11 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION11}
 * @param p_ca_tax_information12 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION12}
 * @param p_ca_tax_information13 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION13}
 * @param p_ca_tax_information14 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION14}
 * @param p_ca_tax_information15 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION15}
 * @param p_ca_tax_information16 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION16}
 * @param p_ca_tax_information17 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION17}
 * @param p_ca_tax_information18 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION18}
 * @param p_ca_tax_information19 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION19}
 * @param p_ca_tax_information20 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION20}
 * @param p_ca_tax_information21 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION21}
 * @param p_ca_tax_information22 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION22}
 * @param p_ca_tax_information23 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION23}
 * @param p_ca_tax_information24 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION24}
 * @param p_ca_tax_information25 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION25}
 * @param p_ca_tax_information26 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION26}
 * @param p_ca_tax_information27 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION27}
 * @param p_ca_tax_information28 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION28}
 * @param p_ca_tax_information29 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION29}
 * @param p_ca_tax_information30 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION30}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created employee provincial tax information. If
 * p_validate is true, then the value will be null
 * @param p_prov_lsp_amount PAY_CA_EMP_PROV_TAX_INFO_F.PROV_LSP_AMOUNT
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_ppip_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PPIP_EXEMPT_FLAG}
 * @rep:displayname Create Employee Provincial Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_emp_prvtax_inf
(
   p_validate                       in boolean    default false
  ,p_emp_province_tax_inf_id        out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_province_code                  in  varchar2  default null
  ,p_jurisdiction_code              in  varchar2  default null
  ,p_tax_credit_amount              in  number    default null
  ,p_basic_exemption_flag           in  varchar2  default null
  ,p_deduction_code                 in  varchar2  default null
  ,p_extra_info_not_provided        in  varchar2  default null
  ,p_marriage_status                in  varchar2  default null
  ,p_no_of_infirm_dependants        in  number    default null
  ,p_non_resident_status            in  varchar2  default null
  ,p_disability_status              in  varchar2  default null
  ,p_no_of_dependants               in  number    default null
  ,p_annual_dedn                    in  number    default null
  ,p_total_expense_by_commission    in  number    default null
  ,p_total_remnrtn_by_commission    in  number    default null
  ,p_prescribed_zone_dedn_amt       in  number    default null
  ,p_additional_tax                 in  number    default null
  ,p_prov_override_rate             in  number    default null
  ,p_prov_override_amount           in  number    default null
  ,p_prov_exempt_flag               in  varchar2  default null
  ,p_pmed_exempt_flag               in  varchar2  default null
  ,p_wc_exempt_flag                 in  varchar2  default null
  ,p_qpp_exempt_flag                in  varchar2  default null
  ,p_tax_calc_method                in  varchar2  default null
  ,p_other_tax_credit               in  number    default null
  ,p_ca_tax_information_category    in  varchar2  default null
  ,p_ca_tax_information1            in  varchar2  default null
  ,p_ca_tax_information2            in  varchar2  default null
  ,p_ca_tax_information3            in  varchar2  default null
  ,p_ca_tax_information4            in  varchar2  default null
  ,p_ca_tax_information5            in  varchar2  default null
  ,p_ca_tax_information6            in  varchar2  default null
  ,p_ca_tax_information7            in  varchar2  default null
  ,p_ca_tax_information8            in  varchar2  default null
  ,p_ca_tax_information9            in  varchar2  default null
  ,p_ca_tax_information10           in  varchar2  default null
  ,p_ca_tax_information11           in  varchar2  default null
  ,p_ca_tax_information12           in  varchar2  default null
  ,p_ca_tax_information13           in  varchar2  default null
  ,p_ca_tax_information14           in  varchar2  default null
  ,p_ca_tax_information15           in  varchar2  default null
  ,p_ca_tax_information16           in  varchar2  default null
  ,p_ca_tax_information17           in  varchar2  default null
  ,p_ca_tax_information18           in  varchar2  default null
  ,p_ca_tax_information19           in  varchar2  default null
  ,p_ca_tax_information20           in  varchar2  default null
  ,p_ca_tax_information21           in  varchar2  default null
  ,p_ca_tax_information22           in  varchar2  default null
  ,p_ca_tax_information23           in  varchar2  default null
  ,p_ca_tax_information24           in  varchar2  default null
  ,p_ca_tax_information25           in  varchar2  default null
  ,p_ca_tax_information26           in  varchar2  default null
  ,p_ca_tax_information27           in  varchar2  default null
  ,p_ca_tax_information28           in  varchar2  default null
  ,p_ca_tax_information29           in  varchar2  default null
  ,p_ca_tax_information30           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_prov_lsp_amount                in  number    default null
  ,p_effective_date                 in  date
  ,p_ppip_exempt_flag               in  varchar2  default null
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ca_emp_prvtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee provincial tax information record for an
 * assignment that affects the provincial tax calculation when a quickpay or
 * payroll run is processed for that employee.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person, employee provincial tax information must exist on the effective
 * date
 *
 * <p><b>Post Success</b><br>
 * The employee provincial tax information will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The employee provincial tax information record will not be updated and the
 * appropriate error message is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_province_tax_inf_id Primary Key of record
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated employee provincial tax information row
 * which now exists as of the effective date. If p_validate is true, then set
 * to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated employee provincial tax information row
 * which now exists as of the effective date. If p_validate is true, then set
 * to null.
 * @param p_legislation_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.LEGISLATION_CODE}
 * @param p_assignment_id Identifies the assignment for which you updated the
 * employee provincial tax information record
 * @param p_business_group_id {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.BUSINESS_GROUP_ID}
 * @param p_province_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROVINCE_CODE}
 * @param p_jurisdiction_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.JURISDICTION_CODE}
 * @param p_tax_credit_amount {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TAX_CREDIT_AMOUNT}
 * @param p_basic_exemption_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.BASIC_EXEMPTION_FLAG}
 * @param p_deduction_code {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.DEDUCTION_CODE}
 * @param p_extra_info_not_provided {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.EXTRA_INFO_NOT_PROVIDED}
 * @param p_marriage_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.MARRIAGE_STATUS}
 * @param p_no_of_infirm_dependants {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NO_OF_INFIRM_DEPENDANTS}
 * @param p_non_resident_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NON_RESIDENT_STATUS}
 * @param p_disability_status {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.DISABILITY_STATUS}
 * @param p_no_of_dependants {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.NO_OF_DEPENDANTS}
 * @param p_annual_dedn {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.ANNUAL_DEDN}
 * @param p_total_expense_by_commission {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TOTAL_EXPENSE_BY_COMMISSION}
 * @param p_total_remnrtn_by_commission {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TOTAL_REMNRTN_BY_COMMISSION}
 * @param p_prescribed_zone_dedn_amt {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PRESCRIBED_ZONE_DEDN_AMT}
 * @param p_additional_tax {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.ADDITIONAL_TAX}
 * @param p_prov_override_rate {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_OVERRIDE_RATE}
 * @param p_prov_override_amount {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_OVERRIDE_AMOUNT}
 * @param p_prov_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PROV_EXEMPT_FLAG}
 * @param p_pmed_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PMED_EXEMPT_FLAG}
 * @param p_wc_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.WC_EXEMPT_FLAG}
 * @param p_qpp_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.QPP_EXEMPT_FLAG}
 * @param p_tax_calc_method {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.TAX_CALC_METHOD}
 * @param p_other_tax_credit {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.OTHER_TAX_CREDIT}
 * @param p_ca_tax_information_category {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION_CATEGORY}
 * @param p_ca_tax_information1 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION1}
 * @param p_ca_tax_information2 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION2}
 * @param p_ca_tax_information3 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION3}
 * @param p_ca_tax_information4 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION4}
 * @param p_ca_tax_information5 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION5}
 * @param p_ca_tax_information6 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION6}
 * @param p_ca_tax_information7 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION7}
 * @param p_ca_tax_information8 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION8}
 * @param p_ca_tax_information9 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION9}
 * @param p_ca_tax_information10 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION10}
 * @param p_ca_tax_information11 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION11}
 * @param p_ca_tax_information12 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION12}
 * @param p_ca_tax_information13 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION13}
 * @param p_ca_tax_information14 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION14}
 * @param p_ca_tax_information15 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION15}
 * @param p_ca_tax_information16 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION16}
 * @param p_ca_tax_information17 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION17}
 * @param p_ca_tax_information18 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION18}
 * @param p_ca_tax_information19 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION19}
 * @param p_ca_tax_information20 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION20}
 * @param p_ca_tax_information21 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION21}
 * @param p_ca_tax_information22 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION22}
 * @param p_ca_tax_information23 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION23}
 * @param p_ca_tax_information24 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION24}
 * @param p_ca_tax_information25 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION25}
 * @param p_ca_tax_information26 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION26}
 * @param p_ca_tax_information27 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION27}
 * @param p_ca_tax_information28 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION28}
 * @param p_ca_tax_information29 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION29}
 * @param p_ca_tax_information30 {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.CA_TAX_INFORMATION30}
 * @param p_object_version_number Pass in the current version number of the
 * employee provincial tax information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * employee provincial tax information. If p_validate is true will be set to
 * the same value which was passed in
 * @param p_prov_lsp_amount PAY_CA_EMP_PROV_TAX_INFO_F.PROV_LSP_AMOUNT
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION. Modes available for
 * use with a particular record depend on the dates of previous record changes
 * and the effective date of this change
 * @param p_ppip_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_PROV_TAX_INFO_F.PPIP_EXEMPT_FLAG}
 * @rep:displayname Update Employee Provincial Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_emp_prvtax_inf
  (
   p_validate                       in boolean    default false
  ,p_emp_province_tax_inf_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_province_code                  in  varchar2  default hr_api.g_varchar2
  ,p_jurisdiction_code              in  varchar2  default hr_api.g_varchar2
  ,p_tax_credit_amount              in  number    default hr_api.g_number
  ,p_basic_exemption_flag           in  varchar2  default hr_api.g_varchar2
  ,p_deduction_code                 in  varchar2  default hr_api.g_varchar2
  ,p_extra_info_not_provided        in  varchar2  default hr_api.g_varchar2
  ,p_marriage_status                in  varchar2  default hr_api.g_varchar2
  ,p_no_of_infirm_dependants        in  number    default hr_api.g_number
  ,p_non_resident_status            in  varchar2  default hr_api.g_varchar2
  ,p_disability_status              in  varchar2  default hr_api.g_varchar2
  ,p_no_of_dependants               in  number    default hr_api.g_number
  ,p_annual_dedn                    in  number    default hr_api.g_number
  ,p_total_expense_by_commission    in  number    default hr_api.g_number
  ,p_total_remnrtn_by_commission    in  number    default hr_api.g_number
  ,p_prescribed_zone_dedn_amt       in  number    default hr_api.g_number
  ,p_additional_tax                 in  number    default hr_api.g_number
  ,p_prov_override_rate             in  number    default hr_api.g_number
  ,p_prov_override_amount           in  number    default hr_api.g_number
  ,p_prov_exempt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_pmed_exempt_flag               in  varchar2  default hr_api.g_varchar2
  ,p_wc_exempt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_qpp_exempt_flag                in  varchar2  default hr_api.g_varchar2
  ,p_tax_calc_method                in  varchar2  default hr_api.g_varchar2
  ,p_other_tax_credit               in  number    default hr_api.g_number
  ,p_ca_tax_information_category    in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information1            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information2            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information3            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information4            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information5            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information6            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information7            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information8            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information9            in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information10           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information11           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information12           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information13           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information14           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information15           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information16           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information17           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information18           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information19           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information20           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information21           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information22           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information23           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information24           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information25           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information26           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information27           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information28           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information29           in  varchar2  default hr_api.g_varchar2
  ,p_ca_tax_information30           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_prov_lsp_amount                in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_ppip_exempt_flag               in  varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_emp_prvtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Employee Provincial tax information record for an
 * assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person, employee provincial tax information must exist on the effective
 * date
 *
 * <p><b>Post Success</b><br>
 * The employee provincial tax information will be successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The employee provincial tax information record will not be deleted and the
 * appropriate error message is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_province_tax_inf_id Primary Key of record
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted employee provincial tax information row
 * which now exists as of the effective date. If p_validate is true or all row
 * instances have been deleted then set to null
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted employee provincial tax information row
 * which now exists as of the effective date. If p_validate is true or all row
 * instances have been deleted then set to null
 * @param p_object_version_number Current version number of the employee
 * provincial tax information to be deleted
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @rep:displayname Delete Employee Provincial Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ca_emp_prvtax_inf
  (
   p_validate                       in boolean        default false
  ,p_emp_province_tax_inf_id        in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_emp_province_tax_inf_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_emp_province_tax_inf_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );

/** Business Processes added **/

procedure pull_tax_records( p_assignment_id   in number,
                           p_new_start_date  in date,
                           p_default_date    in date,
                           p_province_code   in varchar2);

procedure check_hiring_date( p_assignment_id   in number,
                             p_default_date    in date,
                             p_s_start_date    in date,
                             p_prov_code       in varchar2);

procedure tax_record_already_present(p_assignment_id in number,
                                     p_province_code in varchar2,
                                     p_effective_date in date,
                                     p_rec_present out nocopy varchar2) ;

procedure perform_assignment_validation(p_assignment_id in varchar2,
                                     p_effective_date in date);

procedure check_basic_exemption(p_basic_exemption_flag in varchar2,
                                p_tax_credit_amount in number) ;

function convert_null_to_zero(p_value in number) return number ;
--
end pay_ca_emp_prvtax_inf_api;

 

/
