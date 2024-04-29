--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_FEDTAX_INF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_FEDTAX_INF_API" AUTHID CURRENT_USER as
/* $Header: pycatapi.pkh 120.1.12010000.1 2008/07/27 22:17:49 appldev ship $ */
/*#
 * This package contains Federal Tax Information APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee Federal Tax Information for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ca_emp_fedtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Canadian federal tax record for an existing assignment
 * with a Canadian location.
 *
 * the API will only complete successfully if a tax record does not already
 * exist
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An assignment with a Canadian location must exist
 *
 * <p><b>Post Success</b><br>
 * Canadian Federal tax information related to an employees assignment will be
 * sucessfully inserted into the database
 *
 * <p><b>Post Failure</b><br>
 * Tax record will not be created and appropriate error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_fed_tax_inf_id If p_validate is false, then this uniquely
 * identifies the federal tax record created. If p_validate is true, then set
 * to null.
 * @param p_effective_start_date Start Date when the tax record is created
 * @param p_effective_end_date End Date of the tax record created.
 * @param p_legislation_code must be 'CA'
 * @param p_assignment_id Assignment Id for which the Tax record is being
 * created
 * @param p_business_group_id Business Group of the Record corresponding to the
 * assignme id
 * @param p_employment_province to override the work province must be a valid
 * province code
 * @param p_tax_credit_amount tax credit amount and basic exempt amount cannot
 * be both NULL or both NOT NULL.The valid combinations are Basic Exempt = 'Y'
 * Tax Credit = NULL, Basic Exempt = 'N' Tax credit = some value
 * @param p_claim_code currently not used
 * @param p_basic_exemption_flag Mutually exclusive with tax credit amount
 * @param p_additional_tax The default value is 0
 * @param p_annual_dedn The default value is 0
 * @param p_total_expense_by_commission The default value is 0
 * @param p_total_remnrtn_by_commission The default value is 0
 * @param p_prescribed_zone_dedn_amt The default value is 0
 * @param p_other_fedtax_credits The default value is 0
 * @param p_cpp_qpp_exempt_flag If it is selected as 'Y' then the employee will
 * be exempt from CPP/QPP tax.If it is selected as 'N' then the employee will
 * not be exempt from CPP/QPP tax.
 * @param p_fed_exempt_flag If it is selected as 'Y' then the employee will be
 * exempt from Federal tax.If it is selected as 'N' then the employee will not
 * be exempt from Federal tax.
 * @param p_ei_exempt_flag If it is selected as 'Y' then the employee will be
 * exempt from Employment insurance tax.If it is selected as 'N' then the
 * employee will not be exempt from Employment insurance tax.
 * @param p_tax_calc_method Must be a valid tax calculation method , which is
 * the lookup codes for lookup type 'CA_TAX_CALC_METHOD'
 * @param p_fed_override_amount Default value = 0
 * @param p_fed_override_rate Default value = 0
 * @param p_ca_tax_information_category {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION_CATEGORY}
 * @param p_ca_tax_information1 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION1}
 * @param p_ca_tax_information2 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION2}
 * @param p_ca_tax_information3 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION3}
 * @param p_ca_tax_information4 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION4}
 * @param p_ca_tax_information5 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION5}
 * @param p_ca_tax_information6 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION6}
 * @param p_ca_tax_information7 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION7}
 * @param p_ca_tax_information8 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION8}
 * @param p_ca_tax_information9 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION9}
 * @param p_ca_tax_information10 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION10}
 * @param p_ca_tax_information11 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION11}
 * @param p_ca_tax_information12 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION12}
 * @param p_ca_tax_information13 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION13}
 * @param p_ca_tax_information14 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION14}
 * @param p_ca_tax_information15 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION15}
 * @param p_ca_tax_information16 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION16}
 * @param p_ca_tax_information17 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION17}
 * @param p_ca_tax_information18 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION18}
 * @param p_ca_tax_information19 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION19}
 * @param p_ca_tax_information20 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION20}
 * @param p_ca_tax_information21 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION21}
 * @param p_ca_tax_information22 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION22}
 * @param p_ca_tax_information23 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION23}
 * @param p_ca_tax_information24 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION24}
 * @param p_ca_tax_information25 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION25}
 * @param p_ca_tax_information26 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION26}
 * @param p_ca_tax_information27 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION27}
 * @param p_ca_tax_information28 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION28}
 * @param p_ca_tax_information29 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION29}
 * @param p_ca_tax_information30 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION30}
 * @param p_object_version_number Object Version Number for the Tax record
 * created
 * @param p_fed_lsf_amount Default value = 0
 * @param p_effective_date Date when the tax record is created
 * @rep:displayname Create Employee Federal Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_emp_fedtax_inf
(
   p_validate                       in boolean    default false
  ,p_emp_fed_tax_inf_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_employment_province            in  varchar2  default null
  ,p_tax_credit_amount              in  number    default null
  ,p_claim_code                     in  varchar2  default null
  ,p_basic_exemption_flag           in  varchar2  default null
  ,p_additional_tax                 in  number    default null
  ,p_annual_dedn                    in  number    default null
  ,p_total_expense_by_commission    in  number    default null
  ,p_total_remnrtn_by_commission    in  number    default null
  ,p_prescribed_zone_dedn_amt       in  number    default null
  ,p_other_fedtax_credits           in  varchar2  default null
  ,p_cpp_qpp_exempt_flag            in  varchar2  default null
  ,p_fed_exempt_flag                in  varchar2  default null
  ,p_ei_exempt_flag                 in  varchar2  default null
  ,p_tax_calc_method                in  varchar2  default null
  ,p_fed_override_amount            in  number    default null
  ,p_fed_override_rate              in  number    default null
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
  ,p_fed_lsf_amount                in  number    default null
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ca_emp_fedtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Canadian federal tax record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment,business group id should exist in canadian legislation.
 *
 * <p><b>Post Success</b><br>
 * The Federal tax record will be created
 *
 * <p><b>Post Failure</b><br>
 * The Federal tax record will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_fed_tax_inf_id PK of record
 * @param p_effective_start_date Start Date when the tax record is updated
 * @param p_effective_end_date End Date when the tax record is updated
 * @param p_legislation_code must be 'CA'
 * @param p_assignment_id Assignment Id for which the Tax record is being
 * updated
 * @param p_business_group_id {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.BUSINESS_GROUP_ID}
 * @param p_employment_province {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.EMPLOYMENT_PROVINCE}
 * @param p_tax_credit_amount {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.TAX_CREDIT_AMOUNT}
 * @param p_claim_code {@rep:casecolumn PAY_CA_EMP_FED_TAX_INFO_F.CLAIM_CODE}
 * @param p_basic_exemption_flag {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.BASIC_EXEMPTION_FLAG}
 * @param p_additional_tax {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.ADDITIONAL_TAX}
 * @param p_annual_dedn {@rep:casecolumn PAY_CA_EMP_FED_TAX_INFO_F.ANNUAL_DEDN}
 * @param p_total_expense_by_commission {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.TOTAL_EXPENSE_BY_COMMISSION}
 * @param p_total_remnrtn_by_commission {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.TOTAL_REMNRTN_BY_COMMISSION}
 * @param p_prescribed_zone_dedn_amt {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.PRESCRIBED_ZONE_DEDN_AMT}
 * @param p_other_fedtax_credits {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.OTHER_FEDTAX_CREDITS}
 * @param p_cpp_qpp_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CPP_QPP_EXEMPT_FLAG}
 * @param p_fed_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.FED_EXEMPT_FLAG}
 * @param p_ei_exempt_flag {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.EI_EXEMPT_FLAG}
 * @param p_tax_calc_method {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.TAX_CALC_METHOD}
 * @param p_fed_override_amount {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.FED_OVERRIDE_AMOUNT}
 * @param p_fed_override_rate {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.FED_OVERRIDE_RATE}
 * @param p_ca_tax_information_category {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION_CATEGORY}
 * @param p_ca_tax_information1 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION1}
 * @param p_ca_tax_information2 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION2}
 * @param p_ca_tax_information3 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION3}
 * @param p_ca_tax_information4 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION4}
 * @param p_ca_tax_information5 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION5}
 * @param p_ca_tax_information6 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION6}
 * @param p_ca_tax_information7 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION7}
 * @param p_ca_tax_information8 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION8}
 * @param p_ca_tax_information9 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION9}
 * @param p_ca_tax_information10 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION10}
 * @param p_ca_tax_information11 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION11}
 * @param p_ca_tax_information12 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION12}
 * @param p_ca_tax_information13 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION13}
 * @param p_ca_tax_information14 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION14}
 * @param p_ca_tax_information15 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION15}
 * @param p_ca_tax_information16 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION16}
 * @param p_ca_tax_information17 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION17}
 * @param p_ca_tax_information18 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION18}
 * @param p_ca_tax_information19 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION19}
 * @param p_ca_tax_information20 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION20}
 * @param p_ca_tax_information21 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION21}
 * @param p_ca_tax_information22 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION22}
 * @param p_ca_tax_information23 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION23}
 * @param p_ca_tax_information24 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION24}
 * @param p_ca_tax_information25 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION25}
 * @param p_ca_tax_information26 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION26}
 * @param p_ca_tax_information27 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION27}
 * @param p_ca_tax_information28 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION28}
 * @param p_ca_tax_information29 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION29}
 * @param p_ca_tax_information30 {@rep:casecolumn
 * PAY_CA_EMP_FED_TAX_INFO_F.CA_TAX_INFORMATION30}
 * @param p_object_version_number Object Version Number for the Tax record
 * updated
 * @param p_fed_lsf_amount Indicates the Federal labour sponsored funds amount.
 * @param p_effective_date Effective date of the Tax Record updated
 * @param p_datetrack_mode Datetrack mode of the record being updated
 * @rep:displayname Update Employee Federal Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_emp_fedtax_inf
  (
   p_validate                       in boolean    default false
  ,p_emp_fed_tax_inf_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_employment_province            in  varchar2  default hr_api.g_varchar2
  ,p_tax_credit_amount              in  number    default hr_api.g_number
  ,p_claim_code                     in  varchar2  default hr_api.g_varchar2
  ,p_basic_exemption_flag           in  varchar2  default hr_api.g_varchar2
  ,p_additional_tax                 in  number    default hr_api.g_number
  ,p_annual_dedn                    in  number    default hr_api.g_number
  ,p_total_expense_by_commission    in  number    default hr_api.g_number
  ,p_total_remnrtn_by_commission    in  number    default hr_api.g_number
  ,p_prescribed_zone_dedn_amt       in  number    default hr_api.g_number
  ,p_other_fedtax_credits           in  varchar2  default hr_api.g_varchar2
  ,p_cpp_qpp_exempt_flag            in  varchar2  default hr_api.g_varchar2
  ,p_fed_exempt_flag                in  varchar2  default hr_api.g_varchar2
  ,p_ei_exempt_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_tax_calc_method                in  varchar2  default hr_api.g_varchar2
  ,p_fed_override_amount            in  number    default hr_api.g_number
  ,p_fed_override_rate              in  number    default hr_api.g_number
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
  ,p_fed_lsf_amount                in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ca_emp_fedtax_inf >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Canadian federal tax record.
 *
 * associated with a Canadian employee assignment
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Canadian Federal tax record must exist
 *
 * <p><b>Post Success</b><br>
 * Canadian Federal tax information related to an employees assignment is
 * sucessfully deleted
 *
 * <p><b>Post Failure</b><br>
 * No Federal tax records are deleted
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_fed_tax_inf_id PK of record
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted employee federal tax information row
 * which now exists as of the effective date. If p_validate is true or all row
 * instances have been deleted then set to null
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted employee federal tax information row
 * which now exists as of the effective date. If p_validate is true or all row
 * instances have been deleted then set to null
 * @param p_object_version_number Current version number of the employee
 * federal tax information to be deleted
 * @param p_effective_date Effective date of the Tax Record deleted
 * @param p_datetrack_mode Datetrack mode of the record being deleted
 * @rep:displayname Delete Employee Federal Tax Information for Canada
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ca_emp_fedtax_inf
  (
   p_validate                       in boolean        default false
  ,p_emp_fed_tax_inf_id             in  number
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
--   p_emp_fed_tax_inf_id                 Yes  number   PK of record
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
   p_emp_fed_tax_inf_id          in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date
  );
--
procedure pull_tax_records( p_assignment_id   in number,
                           p_new_start_date  in date,
                           p_default_date    in date);

procedure check_hiring_date( p_assignment_id   in number,
                             p_default_date    in date,
                             p_s_start_date    in date);

procedure tax_record_already_present(p_assignment_id in number,
                                     p_effective_date in date,
                                     p_rec_present out nocopy varchar2) ;

procedure perform_assignment_validation(p_assignment_id in varchar2,
                                     p_effective_date in date);

procedure check_basic_exemption(p_basic_exemption_flag in varchar2,
                                p_tax_credit_amount in number) ;

procedure check_employment_province(p_employment_province in varchar2) ;

function convert_null_to_zero(p_value in number) return number;
end pay_ca_emp_fedtax_inf_api;


/
