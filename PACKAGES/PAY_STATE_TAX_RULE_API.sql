--------------------------------------------------------
--  DDL for Package PAY_STATE_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STATE_TAX_RULE_API" AUTHID CURRENT_USER AS
/* $Header: pystaapi.pkh 120.2.12010000.1 2008/07/27 23:43:17 appldev ship $ */
/*#
 * This package contains state tax rules APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname State Tax Rule
*/
--
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
    p_emp_state_tax_rule_id        in         number
   ,p_object_version_number        in         number
   ,p_effective_date               in         date
   ,p_datetrack_mode               in 	      varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_state_tax_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new state tax rule for a given assignment.
 *
 * It also creates a new state tax percentage element entry. The API may be
 * called by providing all of the values for the new tax rule. It can also be
 * called with a flag that instructs the API to insert default values. This API
 * is licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A federal tax rule must exist for an assignment.
 *
 * <p><b>Post Success</b><br>
 * The state tax details will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The state tax rules will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_default_flag Determines whether default values are provided by the
 * API: 'Y' Insert default values, 'N': no default values. pyacplsa.xml 1733
 * @param p_assignment_id Identifies the assignment for which you create the
 * state tax rule record.
 * @param p_state_code Two digit state code.
 * @param p_additional_wa_amount Additional W4 withholding allowance amount.
 * @param p_filing_status_code Filing status code. Valid values are identified
 * by 'US_FS_nn' where nn is the state code.
 * @param p_remainder_percent {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.REMAINDER_PERCENT}
 * @param p_secondary_wa {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SECONDARY_WA}
 * @param p_sit_additional_tax {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_ADDITIONAL_TAX}
 * @param p_sit_override_amount {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OVERRIDE_AMOUNT}
 * @param p_sit_override_rate {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OVERRIDE_RATE}
 * @param p_withholding_allowances {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.WITHHOLDING_ALLOWANCES}
 * @param p_excessive_wa_reject_date {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.EXCESSIVE_WA_REJECT_DATE}
 * @param p_sdi_exempt SDI exempt flag. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_sit_exempt State income tax exempt flag. Valid values are defined
 * by 'YES_NO' lookup type.
 * @param p_sit_optional_calc_ind {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OPTIONAL_CALC_IND}
 * @param p_state_non_resident_cert Determines whether the assignment has a
 * state non-resident certificate. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_sui_exempt SUI exempt flag. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_wc_exempt Workers Compensation exemption flag .Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_wage_exempt Wage Reporting Exemption flag .Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_sui_wage_base_override_amoun {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SUI_WAGE_BASE_OVERRIDE_AMOUNT}
 * @param p_supp_tax_override_rate {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SUPP_TAX_OVERRIDE_RATE}
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
 * @param p_sta_information_category {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION_CATEGORY}
 * @param p_sta_information1 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION1}
 * @param p_sta_information2 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION2}
 * @param p_sta_information3 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION3}
 * @param p_sta_information4 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION4}
 * @param p_sta_information5 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION5}
 * @param p_sta_information6 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION6}
 * @param p_sta_information7 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION7}
 * @param p_sta_information8 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION8}
 * @param p_sta_information9 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION9}
 * @param p_sta_information10 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION10}
 * @param p_sta_information11 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION11}
 * @param p_sta_information12 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION12}
 * @param p_sta_information13 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION13}
 * @param p_sta_information14 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION14}
 * @param p_sta_information15 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION15}
 * @param p_sta_information16 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION16}
 * @param p_sta_information17 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION17}
 * @param p_sta_information18 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION18}
 * @param p_sta_information19 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION19}
 * @param p_sta_information20 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION20}
 * @param p_sta_information21 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION21}
 * @param p_sta_information22 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION22}
 * @param p_sta_information23 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION23}
 * @param p_sta_information24 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION24}
 * @param p_sta_information25 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION25}
 * @param p_sta_information26 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION26}
 * @param p_sta_information27 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION27}
 * @param p_sta_information28 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION28}
 * @param p_sta_information29 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION29}
 * @param p_sta_information30 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION30}
 * @param p_emp_state_tax_rule_id {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.EMP_STATE_TAX_RULE_ID}
 * @param p_object_version_number If P_VALIDATE is false, then set to the
 * version number of the created state tax rule. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * earliest effective start date for the created state tax rule. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date for the created state tax rule. If p_validate is true,
 * then set to null.
 * @rep:displayname Create State Tax Rule
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
procedure create_state_tax_rule
(
   p_validate                       IN      boolean   default false
  ,p_effective_date                 IN      date
  ,p_default_flag                   IN      varchar2  default null
  ,p_assignment_id                  IN      number
  ,p_state_code                     IN      varchar2
  ,p_additional_wa_amount           IN      number    default null
  ,p_filing_status_code             IN      varchar2  default null
  ,p_remainder_percent              IN      number    default null
  ,p_secondary_wa                   IN      number    default null
  ,p_sit_additional_tax             IN      number    default null
  ,p_sit_override_amount            IN      number    default null
  ,p_sit_override_rate              IN      number    default null
  ,p_withholding_allowances         IN      number    default null
  ,p_excessive_wa_reject_date       IN      date      default null
  ,p_sdi_exempt                     IN      varchar2  default null
  ,p_sit_exempt                     IN      varchar2  default null
  ,p_sit_optional_calc_ind          IN      varchar2  default null
  ,p_state_non_resident_cert        IN      varchar2  default null
  ,p_sui_exempt                     IN      varchar2  default null
  ,p_wc_exempt                      IN      varchar2  default null
  ,p_wage_exempt                    IN      varchar2  default null
  ,p_sui_wage_base_override_amoun   IN      number    default null
  ,p_supp_tax_override_rate         IN      number    default null
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
  ,p_sta_information_category       in     varchar2  default null
  ,p_sta_information1               in     varchar2  default null
  ,p_sta_information2               in     varchar2  default null
  ,p_sta_information3               in     varchar2  default null
  ,p_sta_information4               in     varchar2  default null
  ,p_sta_information5               in     varchar2  default null
  ,p_sta_information6               in     varchar2  default null
  ,p_sta_information7               in     varchar2  default null
  ,p_sta_information8               in     varchar2  default null
  ,p_sta_information9               in     varchar2  default null
  ,p_sta_information10              in     varchar2  default null
  ,p_sta_information11              in     varchar2  default null
  ,p_sta_information12              in     varchar2  default null
  ,p_sta_information13              in     varchar2  default null
  ,p_sta_information14              in     varchar2  default null
  ,p_sta_information15              in     varchar2  default null
  ,p_sta_information16              in     varchar2  default null
  ,p_sta_information17              in     varchar2  default null
  ,p_sta_information18              in     varchar2  default null
  ,p_sta_information19              in     varchar2  default null
  ,p_sta_information20              in     varchar2  default null
  ,p_sta_information21              in     varchar2  default null
  ,p_sta_information22              in     varchar2  default null
  ,p_sta_information23              in     varchar2  default null
  ,p_sta_information24              in     varchar2  default null
  ,p_sta_information25              in     varchar2  default null
  ,p_sta_information26              in     varchar2  default null
  ,p_sta_information27              in     varchar2  default null
  ,p_sta_information28              in     varchar2  default null
  ,p_sta_information29              in     varchar2  default null
  ,p_sta_information30              in     varchar2  default null
  ,p_emp_state_tax_rule_id             OUT  nocopy number
  ,p_object_version_number             OUT  nocopy number
  ,p_effective_start_date              OUT  nocopy date
  ,p_effective_end_date                OUT  nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_state_tax_rule >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the state tax details for an employee assignment.
 *
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid state tax rule record must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The state tax details will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The state tax rule will not be updated and an error raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_emp_state_tax_rule_id {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.EMP_STATE_TAX_RULE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * state tax rule to be updated. When the API completes, if P_VALIDATE is
 * false, then it will be set to the new version number of the updated state
 * tax rule. If P_VALIDATE is true, then it will be set to the same value which
 * was passed in.
 * @param p_additional_wa_amount Additional W4 withholding allowance amount.
 * @param p_filing_status_code Filing status code. Valid values are identified
 * by 'US_FS_nn' where nn is the state code.
 * @param p_remainder_percent {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.REMAINDER_PERCENT}
 * @param p_secondary_wa {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SECONDARY_WA}
 * @param p_sit_additional_tax {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_ADDITIONAL_TAX}
 * @param p_sit_override_amount {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OVERRIDE_AMOUNT}
 * @param p_sit_override_rate {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OVERRIDE_RATE}
 * @param p_withholding_allowances {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.WITHHOLDING_ALLOWANCES}
 * @param p_excessive_wa_reject_date {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.EXCESSIVE_WA_REJECT_DATE}
 * @param p_sdi_exempt SDI exempt flag. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_sit_exempt State income tax exempt flag. Valid values are defined
 * by 'YES_NO' lookup type.
 * @param p_sit_optional_calc_ind {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SIT_OPTIONAL_CALC_IND}
 * @param p_state_non_resident_cert Determines whether the assignment has a
 * state non-resident certificate. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_sui_exempt SUI exempt flag. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_wc_exempt Workers Compensation exemption flag .Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_wage_exempt Wage Reporting exemption flag .Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_sui_wage_base_override_amoun {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SUI_WAGE_BASE_OVERRIDE_AMOUNT}
 * @param p_supp_tax_override_rate {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.SUPP_TAX_OVERRIDE_RATE}
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
 * @param p_sta_information_category {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION_CATEGORY}
 * @param p_sta_information1 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION1}
 * @param p_sta_information2 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION2}
 * @param p_sta_information3 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION3}
 * @param p_sta_information4 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION4}
 * @param p_sta_information5 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION5}
 * @param p_sta_information6 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION6}
 * @param p_sta_information7 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION7}
 * @param p_sta_information8 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION8}
 * @param p_sta_information9 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION9}
 * @param p_sta_information10 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION10}
 * @param p_sta_information11 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION11}
 * @param p_sta_information12 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION12}
 * @param p_sta_information13 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION13}
 * @param p_sta_information14 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION14}
 * @param p_sta_information15 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION15}
 * @param p_sta_information16 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION16}
 * @param p_sta_information17 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION17}
 * @param p_sta_information18 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION18}
 * @param p_sta_information19 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION19}
 * @param p_sta_information20 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION20}
 * @param p_sta_information21 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION21}
 * @param p_sta_information22 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION22}
 * @param p_sta_information23 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION23}
 * @param p_sta_information24 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION24}
 * @param p_sta_information25 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION25}
 * @param p_sta_information26 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION26}
 * @param p_sta_information27 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION27}
 * @param p_sta_information28 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION28}
 * @param p_sta_information29 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION29}
 * @param p_sta_information30 {@rep:casecolumn
 * PAY_US_EMP_STATE_TAX_RULES_F.STA_INFORMATION30}
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * effective start date on the updated state tax rule row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date on the updated state tax rule row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update State Tax Rule
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
procedure update_state_tax_rule
(
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_datetrack_update_mode          in     varchar2
  ,p_emp_state_tax_rule_id          in     number
  ,p_object_version_number          in out nocopy number
  ,p_additional_wa_amount           in     number    default hr_api.g_number
  ,p_filing_status_code             in     varchar2  default hr_api.g_varchar2
  ,p_remainder_percent              in     number    default hr_api.g_number
  ,p_secondary_wa                   in     number    default hr_api.g_number
  ,p_sit_additional_tax             in     number    default hr_api.g_number
  ,p_sit_override_amount            in     number    default hr_api.g_number
  ,p_sit_override_rate              in     number    default hr_api.g_number
  ,p_withholding_allowances         in     number    default hr_api.g_number
  ,p_excessive_wa_reject_date       in     date      default hr_api.g_date
  ,p_sdi_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_sit_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_sit_optional_calc_ind          in     varchar2  default hr_api.g_varchar2
  ,p_state_non_resident_cert        in     varchar2  default hr_api.g_varchar2
  ,p_sui_exempt                     in     varchar2  default hr_api.g_varchar2
  ,p_wc_exempt                      in     varchar2  default hr_api.g_varchar2
  ,p_wage_exempt                    in     varchar2  default hr_api.g_varchar2
  ,p_sui_wage_base_override_amoun   in     number    default hr_api.g_number
  ,p_supp_tax_override_rate         in     number    default hr_api.g_number
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
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
 );

--
end pay_state_tax_rule_api ;

/
