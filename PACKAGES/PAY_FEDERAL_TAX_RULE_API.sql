--------------------------------------------------------
--  DDL for Package PAY_FEDERAL_TAX_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FEDERAL_TAX_RULE_API" AUTHID CURRENT_USER AS
/* $Header: pyfedapi.pkh 120.3 2007/07/16 02:07:21 ahanda noship $ */
/*#
 * This package contains federal tax rules APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Federal Tax Rule
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
--   None.
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
    p_emp_fed_tax_rule_id         in number
   ,p_object_version_number       in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date       out nocopy date
   ,p_validation_end_date         out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_fed_tax_rule >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API update the United States federal level tax details for an employee
 * assignment.
 *
 * It also maintains the associated Workers Compensation entries. This API is
 * licensed for use with Human Resources.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid federal tax rule record must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The federal tax rule for the assignment will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The federal tax rule will not be updated and an error will be raised.
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
 * @param p_emp_fed_tax_rule_id {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.EMP_FED_TAX_RULE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * federal tax rule to be updated. When the API completes, if P_VALIDATE is
 * false, then set the new version number of the updated federal tax rule. If
 * P_VALIDATE is true, then set to the same value which was passed in.
 * @param p_sui_state_code SUI state code.
 * @param p_additional_wa_amount The additional W4 withholding allowance
 * amount.
 * @param p_filing_status_code Filing status code. Valid values are identified
 * by 'US_FS_nn' where nn is the state code.
 * @param p_fit_override_amount {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FIT_OVERRIDE_AMOUNT}
 * @param p_fit_override_rate {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FIT_OVERRIDE_RATE}
 * @param p_withholding_allowances W4 withholding allowances.
 * @param p_cumulative_taxation Cumulative taxation flag. Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_eic_filing_status_code EIC filing status. Valid values are defined
 * by 'US_EIC_FILING_STATUS' lookup type.
 * @param p_fit_additional_tax Additional federal income tax.
 * @param p_fit_exempt Federal income tax exemption flag. Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_futa_tax_exempt FUTA exemption flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_medicare_tax_exempt Medicare exemption flag. Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_ss_tax_exempt SS exemption flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_wage_exempt Wage Reporting exemption flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_statutory_employee Statutory employee flag. Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_w2_filed_year {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.W2_FILED_YEAR}
 * @param p_supp_tax_override_rate {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.SUPP_TAX_OVERRIDE_RATE}
 * @param p_excessive_wa_reject_date {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.EXCESSIVE_WA_REJECT_DATE}
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
 * @param p_fed_information_category {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION_CATEGORY}
 * @param p_fed_information1 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION1}
 * @param p_fed_information2 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION2}
 * @param p_fed_information3 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION3}
 * @param p_fed_information4 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION4}
 * @param p_fed_information5 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION5}
 * @param p_fed_information6 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION6}
 * @param p_fed_information7 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION7}
 * @param p_fed_information8 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION8}
 * @param p_fed_information9 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION9}
 * @param p_fed_information10 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION10}
 * @param p_fed_information11 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION11}
 * @param p_fed_information12 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION12}
 * @param p_fed_information13 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION13}
 * @param p_fed_information14 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION14}
 * @param p_fed_information15 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION15}
 * @param p_fed_information16 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION16}
 * @param p_fed_information17 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION17}
 * @param p_fed_information18 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION18}
 * @param p_fed_information19 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION19}
 * @param p_fed_information20 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION20}
 * @param p_fed_information21 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION21}
 * @param p_fed_information22 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION22}
 * @param p_fed_information23 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION23}
 * @param p_fed_information24 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION24}
 * @param p_fed_information25 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION25}
 * @param p_fed_information26 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION26}
 * @param p_fed_information27 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION27}
 * @param p_fed_information28 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION28}
 * @param p_fed_information29 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION29}
 * @param p_fed_information30 {@rep:casecolumn
 * PAY_US_EMP_FED_TAX_RULES_F.FED_INFORMATION30}
 * @param p_effective_start_date If P_VALIDATE is false, then set to the
 * effective start date on the updated federal tax rule row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If P_VALIDATE is false, then set to the
 * effective end date on the updated federal tax rule row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Federal Tax Rule
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
procedure update_fed_tax_rule
(
   p_validate                       IN     boolean    default false
  ,p_effective_date                 IN     date
  ,p_datetrack_update_mode          IN     varchar2
  ,p_emp_fed_tax_rule_id            IN     number
  ,p_object_version_number          IN OUT nocopy number
  ,p_sui_state_code                 IN     varchar2  default hr_api.g_varchar2
  ,p_additional_wa_amount           IN     number    default hr_api.g_number
  ,p_filing_status_code             IN     varchar2  default hr_api.g_varchar2
  ,p_fit_override_amount            IN     number    default hr_api.g_number
  ,p_fit_override_rate              IN     number    default hr_api.g_number
  ,p_withholding_allowances         IN     number    default hr_api.g_number
  ,p_cumulative_taxation            IN     varchar2  default hr_api.g_varchar2
  ,p_eic_filing_status_code         IN     varchar2  default hr_api.g_varchar2
  ,p_fit_additional_tax             IN     number    default hr_api.g_number
  ,p_fit_exempt                     IN     varchar2  default hr_api.g_varchar2
  ,p_futa_tax_exempt                IN     varchar2  default hr_api.g_varchar2
  ,p_medicare_tax_exempt            IN     varchar2  default hr_api.g_varchar2
  ,p_ss_tax_exempt                  IN     varchar2  default hr_api.g_varchar2
  ,p_wage_exempt                    IN     varchar2  default hr_api.g_varchar2
  ,p_statutory_employee             IN     varchar2  default hr_api.g_varchar2
  ,p_w2_filed_year                  IN     number    default hr_api.g_number
  ,p_supp_tax_override_rate         IN     number    default hr_api.g_number
  ,p_excessive_wa_reject_date       IN     date      default hr_api.g_date
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
  ,p_fed_information_category       in     varchar2  default hr_api.g_varchar2
  ,p_fed_information1               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information2               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information3               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information4               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information5               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information6               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information7               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information8               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information9               in     varchar2  default hr_api.g_varchar2
  ,p_fed_information10              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information11              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information12              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information13              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information14              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information15              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information16              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information17              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information18              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information19              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information20              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information21              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information22              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information23              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information24              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information25              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information26              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information27              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information28              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information29              in     varchar2  default hr_api.g_varchar2
  ,p_fed_information30              in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           OUT nocopy date
  ,p_effective_end_date             OUT nocopy date
 );

--
end pay_federal_tax_rule_api;

/
