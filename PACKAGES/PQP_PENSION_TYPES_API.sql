--------------------------------------------------------
--  DDL for Package PQP_PENSION_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_TYPES_API" AUTHID CURRENT_USER As
/* $Header: pqptyapi.pkh 120.1.12000000.1 2007/01/16 04:28:57 appldev noship $ */
/*#
 * This package contains pension type APIs to create, update or delete pension
 * types.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Pension Type for Netherlands, United Kingdom and Hungary
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pension_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a pension type used to calculate of pension deductions.
 *
 * Various attributes can be recorded at the pension type level. Annual limits,
 * salary threshold , contribution percentages and conversion rules are some of
 * the details that can be associated with a pension type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The pension type will be successfully inserted into the database. For the
 * Netherlands localization, pension type balances and the balance
 * initialization element will be created.
 *
 * <p><b>Post Failure</b><br>
 * The pension type will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_pension_type_name {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_TYPE_NAME}
 * @param p_pension_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_CATEGORY}
 * @param p_pension_provider_type {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_PROVIDER_TYPE}
 * @param p_salary_calculation_method {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SALARY_CALCULATION_METHOD}
 * @param p_threshold_conversion_rule {@rep:casecolumn
 * PQP_PENSION_TYPES_F.THRESHOLD_CONVERSION_RULE}
 * @param p_contribution_conversion_rule {@rep:casecolumn
 * PQP_PENSION_TYPES_F.CONTRIBUTION_CONVERSION_RULE}
 * @param p_er_annual_limit {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_LIMIT}
 * @param p_ee_annual_limit {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_LIMIT}
 * @param p_er_annual_salary_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_SALARY_THRESHOLD}
 * @param p_ee_annual_salary_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_SALARY_THRESHOLD}
 * @param p_business_group_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PQP_PENSION_TYPES_F.LEGISLATION_CODE}
 * @param p_description {@rep:casecolumn PQP_PENSION_TYPES_F.DESCRIPTION}
 * @param p_minimum_age {@rep:casecolumn PQP_PENSION_TYPES_F.MINIMUM_AGE}
 * @param p_ee_contribution_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_PERCENT}
 * @param p_maximum_age {@rep:casecolumn PQP_PENSION_TYPES_F.MAXIMUM_AGE}
 * @param p_er_contribution_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_PERCENT}
 * @param p_ee_annual_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_CONTRIBUTION}
 * @param p_er_annual_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_CONTRIBUTION}
 * @param p_annual_premium_amount {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ANNUAL_PREMIUM_AMOUNT}
 * @param p_ee_contribution_bal_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_BAL_TYPE_ID}
 * @param p_er_contribution_bal_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_BAL_TYPE_ID}
 * @param p_balance_init_element_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.BALANCE_INIT_ELEMENT_TYPE_ID}
 * @param p_ee_contribution_fixed_rate {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_FIXED_RATE}
 * @param p_er_contribution_fixed_rate {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_FIXED_RATE}
 * @param p_pty_attribute_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE_CATEGORY}
 * @param p_pty_attribute1 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE1}
 * @param p_pty_attribute2 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE2}
 * @param p_pty_attribute3 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE3}
 * @param p_pty_attribute4 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE4}
 * @param p_pty_attribute5 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE5}
 * @param p_pty_attribute6 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE6}
 * @param p_pty_attribute7 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE7}
 * @param p_pty_attribute8 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE8}
 * @param p_pty_attribute9 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE9}
 * @param p_pty_attribute10 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE10}
 * @param p_pty_attribute11 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE11}
 * @param p_pty_attribute12 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE12}
 * @param p_pty_attribute13 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE13}
 * @param p_pty_attribute14 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE14}
 * @param p_pty_attribute15 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE15}
 * @param p_pty_attribute16 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE16}
 * @param p_pty_attribute17 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE17}
 * @param p_pty_attribute18 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE18}
 * @param p_pty_attribute19 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE19}
 * @param p_pty_attribute20 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE20}
 * @param p_pty_information_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION_CATEGORY}
 * @param p_pty_information1 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION1}
 * @param p_pty_information2 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION2}
 * @param p_pty_information3 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION3}
 * @param p_pty_information4 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION4}
 * @param p_pty_information5 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION5}
 * @param p_pty_information6 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION6}
 * @param p_pty_information7 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION7}
 * @param p_pty_information8 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION8}
 * @param p_pty_information9 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION9}
 * @param p_pty_information10 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION10}
 * @param p_pty_information11 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION11}
 * @param p_pty_information12 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION12}
 * @param p_pty_information13 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION13}
 * @param p_pty_information14 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION14}
 * @param p_pty_information15 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION15}
 * @param p_pty_information16 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION16}
 * @param p_pty_information17 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION17}
 * @param p_pty_information18 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION18}
 * @param p_pty_information19 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION19}
 * @param p_pty_information20 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION20}
 * @param p_special_pension_type_code {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SPECIAL_PENSION_TYPE_CODE}
 * @param p_pension_sub_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_SUB_CATEGORY}
 * @param p_pension_basis_calc_method {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_BASIS_CALC_METHOD}
 * @param p_pension_salary_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_SALARY_BALANCE}
 * @param p_recurring_bonus_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_PERCENT}
 * @param p_non_recurring_bonus_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_PERCENT}
 * @param p_recurring_bonus_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_BALANCE}
 * @param p_non_recurring_bonus_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_BALANCE}
 * @param p_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.STD_TAX_REDUCTION}
 * @param p_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SPL_TAX_REDUCTION}
 * @param p_sig_sal_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_SPL_TAX_REDUCTION}
 * @param p_sig_sal_non_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_NON_TAX_REDUCTION}
 * @param p_sig_sal_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_STD_TAX_REDUCTION}
 * @param p_sii_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_STD_TAX_REDUCTION}
 * @param p_sii_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_SPL_TAX_REDUCTION}
 * @param p_sii_non_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_NON_TAX_REDUCTION}
 * @param p_previous_year_bonus_included {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PREVIOUS_YEAR_BONUS_INCLUDED}
 * @param p_recurring_bonus_period {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_PERIOD}
 * @param p_non_recurring_bonus_period {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_PERIOD}
 * @param p_ee_age_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_AGE_THRESHOLD}
 * @param p_er_age_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_AGE_THRESHOLD}
 * @param p_ee_age_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_AGE_CONTRIBUTION}
 * @param p_er_age_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_AGE_CONTRIBUTION}
 * @param p_pension_type_id If p_validate is false, then this uniquely
 * identifies that pension type created. If p_validate is true then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created pension type. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created pension type. If p_validate is
 * true, then it is set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created pension type. If p_validate is true, then
 * set to null.
 * @param p_api_warning Holds warning messages raised by the API.
 * @rep:displayname Create Pension Type
 * @rep:category BUSINESS_ENTITY PQP_PENSION_AND_SAVING_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Create_Pension_Type
  (p_validate                     in     Boolean  default false
  ,p_effective_date               in     date
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2
  ,p_salary_calculation_method    in     varchar2
  ,p_threshold_conversion_rule    in     varchar2
  ,p_contribution_conversion_rule in     varchar2
  ,p_er_annual_limit              in     number
  ,p_ee_annual_limit              in     number
  ,p_er_annual_salary_threshold   in     number
  ,p_ee_annual_salary_threshold   in     number
  ,p_business_group_id            in     number   default null
  ,p_legislation_code             in     varchar2 default null
  ,p_description                  in     varchar2 default null
  ,p_minimum_age                  in     number   default null
  ,p_ee_contribution_percent      in     number   default null
  ,p_maximum_age                  in     number   default null
  ,p_er_contribution_percent      in     number   default null
  ,p_ee_annual_contribution       in     number   default null
  ,p_er_annual_contribution       in     number   default null
  ,p_annual_premium_amount        in     number   default null
  ,p_ee_contribution_bal_type_id  in     number   default null
  ,p_er_contribution_bal_type_id  in     number   default null
  ,p_balance_init_element_type_id in     number   default null
  ,p_ee_contribution_fixed_rate   in     number   default null --added for UK
  ,p_er_contribution_fixed_rate   in     number   default null --added for UK
  ,p_pty_attribute_category       in     varchar2 default null
  ,p_pty_attribute1               in     varchar2 default null
  ,p_pty_attribute2               in     varchar2 default null
  ,p_pty_attribute3               in     varchar2 default null
  ,p_pty_attribute4               in     varchar2 default null
  ,p_pty_attribute5               in     varchar2 default null
  ,p_pty_attribute6               in     varchar2 default null
  ,p_pty_attribute7               in     varchar2 default null
  ,p_pty_attribute8               in     varchar2 default null
  ,p_pty_attribute9               in     varchar2 default null
  ,p_pty_attribute10              in     varchar2 default null
  ,p_pty_attribute11              in     varchar2 default null
  ,p_pty_attribute12              in     varchar2 default null
  ,p_pty_attribute13              in     varchar2 default null
  ,p_pty_attribute14              in     varchar2 default null
  ,p_pty_attribute15              in     varchar2 default null
  ,p_pty_attribute16              in     varchar2 default null
  ,p_pty_attribute17              in     varchar2 default null
  ,p_pty_attribute18              in     varchar2 default null
  ,p_pty_attribute19              in     varchar2 default null
  ,p_pty_attribute20              in     varchar2 default null
  ,p_pty_information_category     in     varchar2 default null
  ,p_pty_information1             in     varchar2 default null
  ,p_pty_information2             in     varchar2 default null
  ,p_pty_information3             in     varchar2 default null
  ,p_pty_information4             in     varchar2 default null
  ,p_pty_information5             in     varchar2 default null
  ,p_pty_information6             in     varchar2 default null
  ,p_pty_information7             in     varchar2 default null
  ,p_pty_information8             in     varchar2 default null
  ,p_pty_information9             in     varchar2 default null
  ,p_pty_information10            in     varchar2 default null
  ,p_pty_information11            in     varchar2 default null
  ,p_pty_information12            in     varchar2 default null
  ,p_pty_information13            in     varchar2 default null
  ,p_pty_information14            in     varchar2 default null
  ,p_pty_information15            in     varchar2 default null
  ,p_pty_information16            in     varchar2 default null
  ,p_pty_information17            in     varchar2 default null
  ,p_pty_information18            in     varchar2 default null
  ,p_pty_information19            in     varchar2 default null
  ,p_pty_information20            in     varchar2 default null
  ,p_special_pension_type_code    in     varchar2  default null   -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default null   -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default null   -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default null   -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default null   -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default null   -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default null   -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default null   -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default null   -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default null   -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default null   -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default null   -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default null   -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default null   -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default null   -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default null   -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default null   -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default null   -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default null   -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default null   -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2  default null   -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2  default null   -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2  default null   -- added for ABP TAR fixes
  ,p_pension_type_id             out nocopy number
  ,p_object_version_number        out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_api_warning                  out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_pension_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a pension type.
 *
 * Various attributes can be updated at the pension type level. Annual limits,
 * salary threshold , contribution percentages and conversion rules are some of
 * the details that can be updated for a pension type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization and pension type must exist on the effective date.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * Pension type name, pension category and pension sub category cannot be
 * updated.
 *
 * <p><b>Post Success</b><br>
 * The pension type will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The pension type will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_pension_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_TYPE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * pension type to be updated. When the API completes, if p_validate is false
 * then it will be set to the new version number of the updated pension type.
 * If p_validate is true then it will be set to the same value which was passed
 * in.
 * @param p_pension_type_name {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_TYPE_NAME}
 * @param p_pension_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_CATEGORY}
 * @param p_pension_provider_type {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_PROVIDER_TYPE}
 * @param p_salary_calculation_method {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SALARY_CALCULATION_METHOD}
 * @param p_threshold_conversion_rule {@rep:casecolumn
 * PQP_PENSION_TYPES_F.THRESHOLD_CONVERSION_RULE}
 * @param p_contribution_conversion_rule {@rep:casecolumn
 * PQP_PENSION_TYPES_F.CONTRIBUTION_CONVERSION_RULE}
 * @param p_er_annual_limit {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_LIMIT}
 * @param p_ee_annual_limit {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_LIMIT}
 * @param p_er_annual_salary_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_SALARY_THRESHOLD}
 * @param p_ee_annual_salary_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_SALARY_THRESHOLD}
 * @param p_business_group_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PQP_PENSION_TYPES_F.LEGISLATION_CODE}
 * @param p_description {@rep:casecolumn PQP_PENSION_TYPES_F.DESCRIPTION}
 * @param p_minimum_age {@rep:casecolumn PQP_PENSION_TYPES_F.MINIMUM_AGE}
 * @param p_ee_contribution_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_PERCENT}
 * @param p_maximum_age {@rep:casecolumn PQP_PENSION_TYPES_F.MAXIMUM_AGE}
 * @param p_er_contribution_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_PERCENT}
 * @param p_ee_annual_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_ANNUAL_CONTRIBUTION}
 * @param p_er_annual_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_ANNUAL_CONTRIBUTION}
 * @param p_annual_premium_amount {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ANNUAL_PREMIUM_AMOUNT}
 * @param p_ee_contribution_bal_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_BAL_TYPE_ID}
 * @param p_er_contribution_bal_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_BAL_TYPE_ID}
 * @param p_balance_init_element_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.BALANCE_INIT_ELEMENT_TYPE_ID}
 * @param p_ee_contribution_fixed_rate {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_CONTRIBUTION_FIXED_RATE}
 * @param p_er_contribution_fixed_rate {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_CONTRIBUTION_FIXED_RATE}
 * @param p_pty_attribute_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE_CATEGORY}
 * @param p_pty_attribute1 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE1}
 * @param p_pty_attribute2 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE2}
 * @param p_pty_attribute3 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE3}
 * @param p_pty_attribute4 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE4}
 * @param p_pty_attribute5 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE5}
 * @param p_pty_attribute6 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE6}
 * @param p_pty_attribute7 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE7}
 * @param p_pty_attribute8 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE8}
 * @param p_pty_attribute9 {@rep:casecolumn PQP_PENSION_TYPES_F.PTY_ATTRIBUTE9}
 * @param p_pty_attribute10 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE10}
 * @param p_pty_attribute11 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE11}
 * @param p_pty_attribute12 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE12}
 * @param p_pty_attribute13 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE13}
 * @param p_pty_attribute14 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE14}
 * @param p_pty_attribute15 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE15}
 * @param p_pty_attribute16 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE16}
 * @param p_pty_attribute17 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE17}
 * @param p_pty_attribute18 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE18}
 * @param p_pty_attribute19 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE19}
 * @param p_pty_attribute20 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_ATTRIBUTE20}
 * @param p_pty_information_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION_CATEGORY}
 * @param p_pty_information1 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION1}
 * @param p_pty_information2 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION2}
 * @param p_pty_information3 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION3}
 * @param p_pty_information4 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION4}
 * @param p_pty_information5 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION5}
 * @param p_pty_information6 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION6}
 * @param p_pty_information7 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION7}
 * @param p_pty_information8 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION8}
 * @param p_pty_information9 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION9}
 * @param p_pty_information10 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION10}
 * @param p_pty_information11 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION11}
 * @param p_pty_information12 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION12}
 * @param p_pty_information13 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION13}
 * @param p_pty_information14 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION14}
 * @param p_pty_information15 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION15}
 * @param p_pty_information16 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION16}
 * @param p_pty_information17 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION17}
 * @param p_pty_information18 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION18}
 * @param p_pty_information19 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION19}
 * @param p_pty_information20 {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PTY_INFORMATION20}
 * @param p_special_pension_type_code {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SPECIAL_PENSION_TYPE_CODE}
 * @param p_pension_sub_category {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_SUB_CATEGORY}
 * @param p_pension_basis_calc_method {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_BASIS_CALC_METHOD}
 * @param p_pension_salary_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_SALARY_BALANCE}
 * @param p_recurring_bonus_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_PERCENT}
 * @param p_non_recurring_bonus_percent {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_PERCENT}
 * @param p_recurring_bonus_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_BALANCE}
 * @param p_non_recurring_bonus_balance {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_BALANCE}
 * @param p_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.STD_TAX_REDUCTION}
 * @param p_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SPL_TAX_REDUCTION}
 * @param p_sig_sal_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_SPL_TAX_REDUCTION}
 * @param p_sig_sal_non_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_NON_TAX_REDUCTION}
 * @param p_sig_sal_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SIG_SAL_STD_TAX_REDUCTION}
 * @param p_sii_std_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_STD_TAX_REDUCTION}
 * @param p_sii_spl_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_SPL_TAX_REDUCTION}
 * @param p_sii_non_tax_reduction {@rep:casecolumn
 * PQP_PENSION_TYPES_F.SII_NON_TAX_REDUCTION}
 * @param p_previous_year_bonus_included {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PREVIOUS_YEAR_BONUS_INCLUDED}
 * @param p_recurring_bonus_period {@rep:casecolumn
 * PQP_PENSION_TYPES_F.RECURRING_BONUS_PERIOD}
 * @param p_non_recurring_bonus_period {@rep:casecolumn
 * PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_PERIOD}
 * @param p_ee_age_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_AGE_THRESHOLD}
 * @param p_er_age_threshold {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_AGE_THRESHOLD}
 * @param p_ee_age_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.EE_AGE_CONTRIBUTION}
 * @param p_er_age_contribution {@rep:casecolumn
 * PQP_PENSION_TYPES_F.ER_AGE_CONTRIBUTION}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated pension type row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created pension type. If p_validate is true, then
 * set to null.
 * @param p_api_warning Holds warning messages raised by the API.
 * @rep:displayname Update Pension Type
 * @rep:category BUSINESS_ENTITY PQP_PENSION_AND_SAVING_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Update_Pension_Type
  (p_validate                     in     Boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_type_name            in     varchar2  default hr_api.g_varchar2
  ,p_pension_category             in     varchar2  default hr_api.g_varchar2
  ,p_pension_provider_type        in     varchar2  default hr_api.g_varchar2
  ,p_salary_calculation_method    in     varchar2  default hr_api.g_varchar2
  ,p_threshold_conversion_rule    in     varchar2  default hr_api.g_varchar2
  ,p_contribution_conversion_rule in     varchar2  default hr_api.g_varchar2
  ,p_er_annual_limit              in     number    default hr_api.g_number
  ,p_ee_annual_limit              in     number    default hr_api.g_number
  ,p_er_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_ee_annual_salary_threshold   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_minimum_age                  in     number    default hr_api.g_number
  ,p_ee_contribution_percent      in     number    default hr_api.g_number
  ,p_maximum_age                  in     number    default hr_api.g_number
  ,p_er_contribution_percent      in     number    default hr_api.g_number
  ,p_ee_annual_contribution       in     number    default hr_api.g_number
  ,p_er_annual_contribution       in     number    default hr_api.g_number
  ,p_annual_premium_amount        in     number    default hr_api.g_number
  ,p_ee_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_er_contribution_bal_type_id  in     number    default hr_api.g_number
  ,p_balance_init_element_type_id in     number    default hr_api.g_number
  ,p_ee_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_er_contribution_fixed_rate   in     number    default hr_api.g_number --added for UK
  ,p_pty_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pty_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pty_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pty_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pty_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pty_information20            in     varchar2  default hr_api.g_varchar2
  ,p_special_pension_type_code    in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number    default hr_api.g_number      -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number    default hr_api.g_number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number    default hr_api.g_number      -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number    default hr_api.g_number      -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number    default hr_api.g_number      -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2  default hr_api.g_varchar2    -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2  default hr_api.g_varchar2    -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2  default hr_api.g_varchar2    -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2  default hr_api.g_varchar2    -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2  default hr_api.g_varchar2    -- added for ABP TAR fixes
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_api_warning                  out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_pension_type >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a pension type.
 *
 * The pension type API deletes a pension type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The organization and pension type must exist on the effective date. The
 * pension type should not be attached to a provider and should not have any
 * pension schemes.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * A pension type cannot be deleted if it is attached to a pension provider or
 * referenced in a pension scheme.
 *
 * <p><b>Post Success</b><br>
 * The pension type will be successfully deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The pension type will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_pension_type_id {@rep:casecolumn
 * PQP_PENSION_TYPES_F.PENSION_TYPE_ID}
 * @param p_object_version_number Current version number of the pension type to
 * be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted pension type row which now exists as of
 * the effective date. If p_validate is true, or all row instances have been
 * deleted, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created pension type. If p_validate is true, then
 * set to null.
 * @param p_api_warning Holds warning messages raised by the API.
 * @rep:displayname Delete Pension Type
 * @rep:category BUSINESS_ENTITY PQP_PENSION_AND_SAVING_TYPE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Delete_Pension_Type
  (p_validate                     in     Boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_api_warning                     out nocopy varchar2
  );
--
end PQP_Pension_Types_api;

 

/
