--------------------------------------------------------
--  DDL for Package PAY_CITY_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CITY_TAX_RULE_API" AUTHID CURRENT_USER AS
/* $Header: pyctyapi.pkh 120.2 2007/05/01 22:38:19 ahanda noship $ */
/*#
 * This package contains city tax rules APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname City Tax Rule
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_city_tax_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a city tax rule record and the city tax percentage element
 * entry for an employee assignment.
 *
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A federal tax rule must exist for the assignment.
 *
 * <p><b>Post Success</b><br>
 * The city tax rule and percentage records will be successfully inserted into
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The city tax rule and percentage records will not be created and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_city_tax_rule_id If P_VALIDATE is false, then a unique value is
 * set for the city tax rule created. If P_VALIDATE is true, then set to null.
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * earliest effective start date for the created city tax rule. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date for the created city tax rule. If p_validate is true,
 * then set to null.
 * @param p_assignment_id Identifies the assignment for which the city tax rule
 * record is created.
 * @param p_state_code Two digit state code.
 * @param p_county_code Three digit county code.
 * @param p_city_code Four digit city code.
 * @param p_additional_wa_rate Additional W4 withholding allowance percentage
 * rate.
 * @param p_filing_status_code Filing status code. Valid values are identified
 * by 'US_FS_nn' where nn is the state code.
 * @param p_lit_additional_tax {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_ADDITIONAL_TAX}
 * @param p_lit_override_amount {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_OVERRIDE_AMOUNT}
 * @param p_lit_override_rate {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_OVERRIDE_RATE}
 * @param p_withholding_allowances W4 withholding allowance.
 * @param p_lit_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.LIT_EXEMPT}
 * @param p_sd_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.SD_EXEMPT}
 * @param p_ht_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.HT_EXEMPT}
 * @param p_wage_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.WAGE_EXEMPT}
 * @param p_school_district_code School District code. It must be NULL if a
 * school district code already exists for the specified assignment.
 * @param p_object_version_number If P_VALIDATE is false, then set to the
 * version number of the created city tax rule. If p_validate is true, then the
 * value will be null.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_cty_information_category {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION_CATEGORY}
 * @param p_cty_information1 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION1}
 * @param p_cty_information2 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION2}
 * @param p_cty_information3 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION3}
 * @param p_cty_information4 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION4}
 * @param p_cty_information5 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION5}
 * @param p_cty_information6 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION6}
 * @param p_cty_information7 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION7}
 * @param p_cty_information8 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION8}
 * @param p_cty_information9 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION9}
 * @param p_cty_information10 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION10}
 * @param p_cty_information11 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION11}
 * @param p_cty_information12 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION12}
 * @param p_cty_information13 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION13}
 * @param p_cty_information14 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION14}
 * @param p_cty_information15 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION15}
 * @param p_cty_information16 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION16}
 * @param p_cty_information17 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION17}
 * @param p_cty_information18 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION18}
 * @param p_cty_information19 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION19}
 * @param p_cty_information20 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION20}
 * @param p_cty_information21 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION21}
 * @param p_cty_information22 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION22}
 * @param p_cty_information23 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION23}
 * @param p_cty_information24 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION24}
 * @param p_cty_information25 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION25}
 * @param p_cty_information26 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION26}
 * @param p_cty_information27 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION27}
 * @param p_cty_information28 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION28}
 * @param p_cty_information29 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION29}
 * @param p_cty_information30 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION30}
 * @rep:displayname Create City Tax Rule
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_city_tax_rule
(
   p_validate                       in boolean    default false
  ,p_emp_city_tax_rule_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_assignment_id                  in  number    default null
  ,p_state_code                     in  varchar2  default null
  ,p_county_code                    in  varchar2  default null
  ,p_city_code                      in  varchar2  default null
  ,p_additional_wa_rate             in  number    default null
  ,p_filing_status_code             in  varchar2  default null
  ,p_lit_additional_tax             in  number    default null
  ,p_lit_override_amount            in  number    default null
  ,p_lit_override_rate              in  number    default null
  ,p_withholding_allowances         in  number    default null
  ,p_lit_exempt                     in  varchar2  default null
  ,p_sd_exempt                      in  varchar2  default null
  ,p_ht_exempt                      in  varchar2  default null
  ,p_wage_exempt                    in  varchar2  default null
  ,p_school_district_code           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_attribute_category             in     varchar2  default null
  ,p_attribute1                     in     varchar2  default null
  ,p_attribute2                     in     varchar2  default null
  ,p_attribute3                     in     varchar2  default null
  ,p_attribute4                     in     varchar2  default null
  ,p_attribute5                     in     varchar2  default null
  ,p_attribute6                     in     varchar2  default null
  ,p_attribute7                     in     varchar2  default null
  ,p_attribute8                     in     varchar2  default null
  ,p_attribute9                     in     varchar2  default null
  ,p_attribute10                    in     varchar2  default null
  ,p_attribute11                    in     varchar2  default null
  ,p_attribute12                    in     varchar2  default null
  ,p_attribute13                    in     varchar2  default null
  ,p_attribute14                    in     varchar2  default null
  ,p_attribute15                    in     varchar2  default null
  ,p_attribute16                    in     varchar2  default null
  ,p_attribute17                    in     varchar2  default null
  ,p_attribute18                    in     varchar2  default null
  ,p_attribute19                    in     varchar2  default null
  ,p_attribute20                    in     varchar2  default null
  ,p_attribute21                    in     varchar2  default null
  ,p_attribute22                    in     varchar2  default null
  ,p_attribute23                    in     varchar2  default null
  ,p_attribute24                    in     varchar2  default null
  ,p_attribute25                    in     varchar2  default null
  ,p_attribute26                    in     varchar2  default null
  ,p_attribute27                    in     varchar2  default null
  ,p_attribute28                    in     varchar2  default null
  ,p_attribute29                    in     varchar2  default null
  ,p_attribute30                    in     varchar2  default null
  ,p_cty_information_category       in     varchar2  default null
  ,p_cty_information1               in     varchar2  default null
  ,p_cty_information2               in     varchar2  default null
  ,p_cty_information3               in     varchar2  default null
  ,p_cty_information4               in     varchar2  default null
  ,p_cty_information5               in     varchar2  default null
  ,p_cty_information6               in     varchar2  default null
  ,p_cty_information7               in     varchar2  default null
  ,p_cty_information8               in     varchar2  default null
  ,p_cty_information9               in     varchar2  default null
  ,p_cty_information10              in     varchar2  default null
  ,p_cty_information11              in     varchar2  default null
  ,p_cty_information12              in     varchar2  default null
  ,p_cty_information13              in     varchar2  default null
  ,p_cty_information14              in     varchar2  default null
  ,p_cty_information15              in     varchar2  default null
  ,p_cty_information16              in     varchar2  default null
  ,p_cty_information17              in     varchar2  default null
  ,p_cty_information18              in     varchar2  default null
  ,p_cty_information19              in     varchar2  default null
  ,p_cty_information20              in     varchar2  default null
  ,p_cty_information21              in     varchar2  default null
  ,p_cty_information22              in     varchar2  default null
  ,p_cty_information23              in     varchar2  default null
  ,p_cty_information24              in     varchar2  default null
  ,p_cty_information25              in     varchar2  default null
  ,p_cty_information26              in     varchar2  default null
  ,p_cty_information27              in     varchar2  default null
  ,p_cty_information28              in     varchar2  default null
  ,p_cty_information29              in     varchar2  default null
  ,p_cty_information30              in     varchar2  default null
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_city_tax_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a city tax rule record for a particular employee
 * assignment.
 *
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid city tax rule record must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The city tax rule will be successfullly updated.
 *
 * <p><b>Post Failure</b><br>
 * The city tax rule will not be updated and error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_emp_city_tax_rule_id System generated primary key column.
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * effective start date on the updated city tax rule row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date on the updated city tax rule row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_additional_wa_rate Additional W4 withholding allowance percentage
 * rate.
 * @param p_filing_status_code Filing status code. Valid values are identified
 * by 'US_FS_nn' where nn is the state code.
 * @param p_lit_additional_tax {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_ADDITIONAL_TAX}
 * @param p_lit_override_amount {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_OVERRIDE_AMOUNT}
 * @param p_lit_override_rate {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.LIT_OVERRIDE_RATE}
 * @param p_withholding_allowances W4 withholding allowance.
 * @param p_lit_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.LIT_EXEMPT}
 * @param p_sd_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.SD_EXEMPT}
 * @param p_ht_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.HT_EXEMPT}
 * @param p_wage_exempt {@rep:casecolumn PAY_US_EMP_CITY_TAX_RULES_F.WAGE_EXEMPT}
 * @param p_school_district_code School District code. It must be NULL if a
 * school district code already exists for the specified assignment.
 * @param p_object_version_number Pass in the current version number of the
 * city tax rule to be updated. When the API completes, if P_VALIDATE is false,
 * then set to the new version number of the updated city tax rule. If
 * P_VALIDATE is true, then set to the same value which was passed in.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_cty_information_category {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION_CATEGORY}
 * @param p_cty_information1 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION1}
 * @param p_cty_information2 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION2}
 * @param p_cty_information3 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION3}
 * @param p_cty_information4 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION4}
 * @param p_cty_information5 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION5}
 * @param p_cty_information6 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION6}
 * @param p_cty_information7 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION7}
 * @param p_cty_information8 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION8}
 * @param p_cty_information9 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION9}
 * @param p_cty_information10 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION10}
 * @param p_cty_information11 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION11}
 * @param p_cty_information12 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION12}
 * @param p_cty_information13 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION13}
 * @param p_cty_information14 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION14}
 * @param p_cty_information15 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION15}
 * @param p_cty_information16 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION16}
 * @param p_cty_information17 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION17}
 * @param p_cty_information18 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION18}
 * @param p_cty_information19 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION19}
 * @param p_cty_information20 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION20}
 * @param p_cty_information21 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION21}
 * @param p_cty_information22 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION22}
 * @param p_cty_information23 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION23}
 * @param p_cty_information24 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION24}
 * @param p_cty_information25 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION25}
 * @param p_cty_information26 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION26}
 * @param p_cty_information27 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION27}
 * @param p_cty_information28 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION28}
 * @param p_cty_information29 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION29}
 * @param p_cty_information30 {@rep:casecolumn
 * PAY_US_EMP_CITY_TAX_RULES_F.CTY_INFORMATION30}
 * @rep:displayname Update City Tax Rule
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_city_tax_rule
  (
   p_validate                       in  boolean    default false
  ,p_emp_city_tax_rule_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_additional_wa_rate             in  number     default hr_api.g_number
  ,p_filing_status_code             in  varchar2   default hr_api.g_varchar2
  ,p_lit_additional_tax             in  number     default hr_api.g_number
  ,p_lit_override_amount            in  number     default hr_api.g_number
  ,p_lit_override_rate              in  number     default hr_api.g_number
  ,p_withholding_allowances         in  number     default hr_api.g_number
  ,p_lit_exempt                     in  varchar2   default hr_api.g_varchar2
  ,p_sd_exempt                      in  varchar2   default hr_api.g_varchar2
  ,p_ht_exempt                      in  varchar2   default hr_api.g_varchar2
  ,p_wage_exempt                    in  varchar2   default hr_api.g_varchar2
  ,p_school_district_code           in  varchar2   default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2  default hr_api.g_varchar2
  ,p_cty_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_cty_information1               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information2               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information3               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information4               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information5               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information6               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information7               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information8               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information9               in     varchar2  default hr_api.g_varchar2
  ,p_cty_information10              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information11              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information12              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information13              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information14              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information15              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information16              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information17              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information18              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information19              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information20              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information21              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information22              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information23              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information24              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information25              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information26              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information27              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information28              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information29              in     varchar2  default hr_api.g_varchar2
  ,p_cty_information30              in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process for datetrack is complicated and comprises of the
--   following processing
--   The processing steps are as follows:
--   1) The row to be updated or deleted must be locked.
--      By locking this row, the g_old_rec record data type is populated.
--   2) The datetrack mode is then validated to ensure the operation is
--      valid. If the mode is valid the validation start and end dates for
--      the mode will be derived and returned. Any required locking is
--      completed when the datetrack mode is validated.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_emp_county_tax_rule_id       Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_emp_city_tax_rule_id         in number
   ,p_object_version_number        in number
   ,p_effective_date               in date
   ,p_datetrack_mode               in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end pay_city_tax_rule_api;

/
