--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_API" AUTHID CURRENT_USER as
/* $Header: pyprlapi.pkh 120.13 2007/11/20 06:17:36 pgongada noship $ */
/*#
 * This package contains Payroll APIs.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Payroll
*/
--
g_api_dml  boolean;                               -- Global api dml status
g_package  varchar2(33) := '  pay_payroll_api.';
--

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a payroll.
 *
 * It creates the payroll and associated time periods.
 *
 *
 * <P> This version of the API is now out-of-date however it has been provided
 * to you for backward compatibility support and will be removed in the future.
 * Oracle recommends you to modify existing calling programs in advance of the
 * support being withdrawn thus avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Relevant payment methods and consolidation sets must be defined
 *
 * <p><b>Post Success</b><br>
 * The payroll and time periods will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The payroll will not be created and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_payroll_name Name of payroll to be created
 * @param p_payroll_type Type of payroll to be created. (PAYROLL_TYPE lookup
 * type of the HR_LOOKUPS)
 * @param p_period_type Type of periods to be created for this payroll. Foreign
 * key to PER_TIME_PERIOD_TYPE.
 * @param p_first_period_end_date End date for first period in this payroll
 * @param p_number_of_years Number of years to create payroll time periods for
 * @param p_pay_date_offset Number of days allowed for pay date offset
 * @param p_direct_deposit_date_offset Number of days allowed for direct
 * deposit offset
 * @param p_pay_advice_date_offset Number of days allowed for pay advice date
 * offset
 * @param p_cut_off_date_offset Number of days allowed for cut off date offset
 * @param p_midpoint_offset Number of days allowed for midpoint offset
 * @param p_default_payment_method_id Identifier for default payment method for
 * this payroll
 * @param p_consolidation_set_id Consolidation set identifier for this payroll
 * @param p_cost_allocation_keyflex_id Identifier for Cost allocation key
 * flexfield for this payroll
 * @param p_suspense_account_keyflex_id Identifier of Suspense account key
 * flexfield for this payroll
 * @param p_negative_pay_allowed_flag Flag to indicate if negative pay allowed
 * @param p_gl_set_of_books_id Identifier of General ledger set of books for
 * this payroll
 * @param p_soft_coding_keyflex_id Identifier for soft coding key flexfield for
 * this payroll
 * @param p_comments Payroll comment text
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
 * @param p_arrears_flag Flag to indicate if arrears payroll
 * @param p_period_reset_years Number of years after which the period start of
 * the next corresponding year is reset.
 * @param p_multi_assignments_flag Flag to indicate if multi Assignment payroll
 * @param p_organization_id Organization ID
 * @param p_prl_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_prl_information1 Developer Descriptive flexfield segment.
 * @param p_prl_information2 Developer Descriptive flexfield segment.
 * @param p_prl_information3 Developer Descriptive flexfield segment.
 * @param p_prl_information4 Developer Descriptive flexfield segment.
 * @param p_prl_information5 Developer Descriptive flexfield segment.
 * @param p_prl_information6 Developer Descriptive flexfield segment.
 * @param p_prl_information7 Developer Descriptive flexfield segment.
 * @param p_prl_information8 Developer Descriptive flexfield segment.
 * @param p_prl_information9 Developer Descriptive flexfield segment.
 * @param p_prl_information10 Developer Descriptive flexfield segment.
 * @param p_prl_information11 Developer Descriptive flexfield segment.
 * @param p_prl_information12 Developer Descriptive flexfield segment.
 * @param p_prl_information13 Developer Descriptive flexfield segment.
 * @param p_prl_information14 Developer Descriptive flexfield segment.
 * @param p_prl_information15 Developer Descriptive flexfield segment.
 * @param p_prl_information16 Developer Descriptive flexfield segment.
 * @param p_prl_information17 Developer Descriptive flexfield segment.
 * @param p_prl_information18 Developer Descriptive flexfield segment.
 * @param p_prl_information19 Developer Descriptive flexfield segment.
 * @param p_prl_information20 Developer Descriptive flexfield segment.
 * @param p_prl_information21 Developer Descriptive flexfield segment.
 * @param p_prl_information22 Developer Descriptive flexfield segment.
 * @param p_prl_information23 Developer Descriptive flexfield segment.
 * @param p_prl_information24 Developer Descriptive flexfield segment.
 * @param p_prl_information25 Developer Descriptive flexfield segment.
 * @param p_prl_information26 Developer Descriptive flexfield segment.
 * @param p_prl_information27 Developer Descriptive flexfield segment.
 * @param p_prl_information28 Developer Descriptive flexfield segment.
 * @param p_prl_information29 Developer Descriptive flexfield segment.
 * @param p_prl_information30 Developer Descriptive flexfield segment.
 * @param p_payroll_id If p_validate is false, this uniquely identifies the
 * Payroll created. If p_validate is set to true, this parameter will be null.
 * @param p_org_pay_method_usage_id If p_validate is false, this uniquely
 * identifies the Organization Payment Method Usage created. If p_validate is
 * set to true, this parameter will be null.
 * @param p_prl_object_version_number If p_validate is false, then set to the
 * version number of the created payroll. If p_validate is true, then the value
 * will be null.
 * @param p_opm_object_version_number If p_validate is false, then set to the
 * version number of the organisation payment method. If p_validate is true,
 * then the value will be null.
 * @param p_prl_effective_start_date If p_validate is false, then set to the
 * earliest effective
 * @param p_prl_effective_end_date If p_validate is false, then set to the
 * effective end date for the created payroll. If p_validate is true, then set
 * to null.
 * @param p_opm_effective_start_date If p_validate is false, then set to the
 * earliest effective
 * @param p_opm_effective_end_date If p_validate is false, then set to the
 * effective end date for the organisation payment methods. If p_validate is
 * true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created payroll comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @rep:displayname Create Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_payroll
(
   p_validate                     in   boolean   default false,
   p_effective_date               in   date,
   p_payroll_name                 in   varchar2,
   p_payroll_type                 in   varchar2  default null,
   p_period_type                  in   varchar2,
   p_first_period_end_date        in   date,
   p_number_of_years              in   number,
   p_pay_date_offset              in   number    default 0,
   p_direct_deposit_date_offset   in   number    default 0,
   p_pay_advice_date_offset       in   number    default 0,
   p_cut_off_date_offset          in   number    default 0,
   p_midpoint_offset              in   number    default null,
   p_default_payment_method_id    in   number    default null,
   p_consolidation_set_id         in   number,
   p_cost_allocation_keyflex_id   in   number    default null,
   p_suspense_account_keyflex_id  in   number    default null,
   p_negative_pay_allowed_flag    in   varchar2  default 'N',
   p_gl_set_of_books_id           in   number    default null,
   p_soft_coding_keyflex_id       in   number    default null,
   p_comments                     in   varchar2  default null,
   p_attribute_category           in   varchar2  default null,
   p_attribute1                   in   varchar2  default null,
   p_attribute2                   in   varchar2  default null,
   p_attribute3                   in   varchar2  default null,
   p_attribute4                   in   varchar2  default null,
   p_attribute5                   in   varchar2  default null,
   p_attribute6                   in   varchar2  default null,
   p_attribute7                   in   varchar2  default null,
   p_attribute8                   in   varchar2  default null,
   p_attribute9                   in   varchar2  default null,
   p_attribute10                  in   varchar2  default null,
   p_attribute11                  in   varchar2  default null,
   p_attribute12                  in   varchar2  default null,
   p_attribute13                  in   varchar2  default null,
   p_attribute14                  in   varchar2  default null,
   p_attribute15                  in   varchar2  default null,
   p_attribute16                  in   varchar2  default null,
   p_attribute17                  in   varchar2  default null,
   p_attribute18                  in   varchar2  default null,
   p_attribute19                  in   varchar2  default null,
   p_attribute20                  in   varchar2  default null,
   p_arrears_flag                 in   varchar2  default 'N',
   p_period_reset_years           in   varchar2  default null,
   p_multi_assignments_flag       in   varchar2  default null,
   p_organization_id              in   number    default null,
   p_prl_information_category     in   varchar2  default null,
   p_prl_information1         	  in   varchar2  default null,
   p_prl_information2         	  in   varchar2  default null,
   p_prl_information3         	  in   varchar2  default null,
   p_prl_information4         	  in   varchar2  default null,
   p_prl_information5         	  in   varchar2  default null,
   p_prl_information6         	  in   varchar2  default null,
   p_prl_information7         	  in   varchar2  default null,
   p_prl_information8         	  in   varchar2  default null,
   p_prl_information9         	  in   varchar2  default null,
   p_prl_information10        	  in   varchar2  default null,
   p_prl_information11            in   varchar2  default null,
   p_prl_information12        	  in   varchar2  default null,
   p_prl_information13        	  in   varchar2  default null,
   p_prl_information14        	  in   varchar2  default null,
   p_prl_information15        	  in   varchar2  default null,
   p_prl_information16        	  in   varchar2  default null,
   p_prl_information17        	  in   varchar2  default null,
   p_prl_information18        	  in   varchar2  default null,
   p_prl_information19        	  in   varchar2  default null,
   p_prl_information20        	  in   varchar2  default null,
   p_prl_information21        	  in   varchar2  default null,
   p_prl_information22            in   varchar2  default null,
   p_prl_information23        	  in   varchar2  default null,
   p_prl_information24        	  in   varchar2  default null,
   p_prl_information25        	  in   varchar2  default null,
   p_prl_information26        	  in   varchar2  default null,
   p_prl_information27        	  in   varchar2  default null,
   p_prl_information28        	  in   varchar2  default null,
   p_prl_information29        	  in   varchar2  default null,
   p_prl_information30            in   varchar2  default null,
   p_payroll_id                   out  nocopy number,
   p_org_pay_method_usage_id      out  nocopy number,
   p_prl_object_version_number    out  nocopy number,
   p_opm_object_version_number    out  nocopy number,
   p_prl_effective_start_date     out  nocopy date,
   p_prl_effective_end_date       out  nocopy date,
   p_opm_effective_start_date     out  nocopy date,
   p_opm_effective_end_date       out  nocopy date,
   p_comment_id                   out  nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a payroll.
 *
 * This make the changes to the definition of the payroll as specified by
 * parameter values passed to this API.
 *
 * <P> This version of the API is now out-of-date however it has been provided
 * to you for backward compatibility support and will be removed in the future.
 * Oracle recommends you to modify existing calling programs in advance of the
 * support being withdrawn thus avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Relevant payment methods and consolidation sets must be defined
 *
 * <p><b>Post Success</b><br>
 * Payroll data will be updated.
 *
 * <p><b>Post Failure</b><br>
 * Payroll data will not be updated and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_payroll_id If p_validate is false, this uniquely identifies the
 * Payroll updated. If p_validate is set to true, this parameter will be null.
 * @param p_object_version_number Pass in the current version number of the
 * payroll to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated payroll. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_payroll_name Payroll Name
 * @param p_number_of_years Number of years to create time periods for
 * @param p_default_payment_method_id Identifier of Default payment method to
 * be used by this payroll
 * @param p_consolidation_set_id Consolidation set identifier for this payroll
 * @param p_cost_allocation_keyflex_id Identifier for Cost allocation key
 * flexfield for this payroll
 * @param p_suspense_account_keyflex_id Identifier of Suspense account key
 * flexfield for this payroll
 * @param p_negative_pay_allowed_flag Flag to indicate in negative pay allowed
 * @param p_soft_coding_keyflex_id Identifier of soft coding key flexfield for
 * this payroll
 * @param p_comments Payroll comment text.
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
 * @param p_arrears_flag Flag to indicate if arrears payroll
 * @param p_multi_assignments_flag Flag to indicate if multi Assignment payroll
 * @param p_prl_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_prl_information1 Developer Descriptive flexfield segment.
 * @param p_prl_information2 Developer Descriptive flexfield segment.
 * @param p_prl_information3 Developer Descriptive flexfield segment.
 * @param p_prl_information4 Developer Descriptive flexfield segment.
 * @param p_prl_information5 Developer Descriptive flexfield segment.
 * @param p_prl_information6 Developer Descriptive flexfield segment.
 * @param p_prl_information7 Developer Descriptive flexfield segment.
 * @param p_prl_information8 Developer Descriptive flexfield segment.
 * @param p_prl_information9 Developer Descriptive flexfield segment.
 * @param p_prl_information10 Developer Descriptive flexfield segment.
 * @param p_prl_information11 Developer Descriptive flexfield segment.
 * @param p_prl_information12 Developer Descriptive flexfield segment.
 * @param p_prl_information13 Developer Descriptive flexfield segment.
 * @param p_prl_information14 Developer Descriptive flexfield segment.
 * @param p_prl_information15 Developer Descriptive flexfield segment.
 * @param p_prl_information16 Developer Descriptive flexfield segment.
 * @param p_prl_information17 Developer Descriptive flexfield segment.
 * @param p_prl_information18 Developer Descriptive flexfield segment.
 * @param p_prl_information19 Developer Descriptive flexfield segment.
 * @param p_prl_information20 Developer Descriptive flexfield segment.
 * @param p_prl_information21 Developer Descriptive flexfield segment.
 * @param p_prl_information22 Developer Descriptive flexfield segment.
 * @param p_prl_information23 Developer Descriptive flexfield segment.
 * @param p_prl_information24 Developer Descriptive flexfield segment.
 * @param p_prl_information25 Developer Descriptive flexfield segment.
 * @param p_prl_information26 Developer Descriptive flexfield segment.
 * @param p_prl_information27 Developer Descriptive flexfield segment.
 * @param p_prl_information28 Developer Descriptive flexfield segment.
 * @param p_prl_information29 Developer Descriptive flexfield segment.
 * @param p_prl_information30 Developer Descriptive flexfield segment.
 * @param p_prl_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated payroll row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_prl_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated payroll row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created payroll comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @rep:displayname Update Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_payroll
(
   p_validate                     in   boolean   default false,
   p_effective_date               in   date,
   p_datetrack_mode               in   varchar2,
   p_payroll_id                   in out nocopy number,
   p_object_version_number        in out nocopy number,
   p_payroll_name                 in   varchar2  default hr_api.g_varchar2,
   p_number_of_years              in   number    default hr_api.g_number,
   p_default_payment_method_id    in   number    default hr_api.g_number,
   p_consolidation_set_id         in   number    default hr_api.g_number,
   p_cost_allocation_keyflex_id   in   number    default hr_api.g_number,
   p_suspense_account_keyflex_id  in   number    default hr_api.g_number,
   p_negative_pay_allowed_flag    in   varchar2  default hr_api.g_varchar2,
   p_soft_coding_keyflex_id       in   number    default hr_api.g_number,
   p_comments                     in   varchar2  default hr_api.g_varchar2,
   p_attribute_category           in   varchar2  default hr_api.g_varchar2,
   p_attribute1                   in   varchar2  default hr_api.g_varchar2,
   p_attribute2                   in   varchar2  default hr_api.g_varchar2,
   p_attribute3                   in   varchar2  default hr_api.g_varchar2,
   p_attribute4                   in   varchar2  default hr_api.g_varchar2,
   p_attribute5                   in   varchar2  default hr_api.g_varchar2,
   p_attribute6                   in   varchar2  default hr_api.g_varchar2,
   p_attribute7                   in   varchar2  default hr_api.g_varchar2,
   p_attribute8                   in   varchar2  default hr_api.g_varchar2,
   p_attribute9                   in   varchar2  default hr_api.g_varchar2,
   p_attribute10                  in   varchar2  default hr_api.g_varchar2,
   p_attribute11                  in   varchar2  default hr_api.g_varchar2,
   p_attribute12                  in   varchar2  default hr_api.g_varchar2,
   p_attribute13                  in   varchar2  default hr_api.g_varchar2,
   p_attribute14                  in   varchar2  default hr_api.g_varchar2,
   p_attribute15                  in   varchar2  default hr_api.g_varchar2,
   p_attribute16                  in   varchar2  default hr_api.g_varchar2,
   p_attribute17                  in   varchar2  default hr_api.g_varchar2,
   p_attribute18                  in   varchar2  default hr_api.g_varchar2,
   p_attribute19                  in   varchar2  default hr_api.g_varchar2,
   p_attribute20                  in   varchar2  default hr_api.g_varchar2,
   p_arrears_flag                 in   varchar2  default hr_api.g_varchar2,
   p_multi_assignments_flag       in   varchar2  default hr_api.g_varchar2,
   p_prl_information_category     in   varchar2  default hr_api.g_varchar2,
   p_prl_information1         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information2         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information3         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information4         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information5         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information6         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information7         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information8         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information9         	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information10        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information11            in   varchar2  default hr_api.g_varchar2,
   p_prl_information12        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information13        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information14        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information15        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information16        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information17        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information18        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information19        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information20        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information21        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information22            in   varchar2  default hr_api.g_varchar2,
   p_prl_information23        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information24        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information25        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information26        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information27        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information28        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information29        	  in   varchar2  default hr_api.g_varchar2,
   p_prl_information30            in   varchar2  default hr_api.g_varchar2,
   p_prl_effective_start_date     out  nocopy date,
   p_prl_effective_end_date       out  nocopy date,
   p_comment_id                   out  nocopy number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< lock_payroll >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure lock_payroll
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_payroll_id                       in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a payroll.
 *
 * Deleted the payroll and associated time periods according to datetrack mode.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Ensure payroll is valid for deleting
 *
 * <p><b>Post Success</b><br>
 * Relevant payroll and time period details have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * Payroll and time periods have not been deleted and an error raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either DELETE, FUTURE_CHANGE, DELETE_NEXT_CHANGE
 * or ZAP. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_payroll_id Payroll identifier of payroll to be deleted
 * @param p_object_version_number Pass in the current version number of the
 * payroll to be deleted. When the API completes if p_validate is false, will
 * be set to the new version number of the deleted payroll. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted payroll row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted payroll row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_payroll
  (p_validate                     in  boolean   default false
  ,p_effective_date               in  date
  ,p_datetrack_mode               in  varchar2
  ,p_payroll_id                   in  number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_payroll_id  in  number);
--
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process creates a payroll.
 *
 * It creates the payroll and associated time periods.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Relevant payment methods and consolidation sets must be defined
 *
 * <p><b>Post Success</b><br>
 * The payroll and time periods will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The payroll will not be created and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_payroll_name Name of payroll to be created
 * @param p_payroll_type Type of payroll to be created. (PAYROLL_TYPE lookup
 * type of the HR_LOOKUPS)
 * @param p_period_type Type of periods to be created for this payroll. Foreign
 * key to PER_TIME_PERIOD_TYPE.
 * @param p_first_period_end_date End date for first period in this payroll
 * @param p_number_of_years Number of years to create payroll time periods for
 * @param p_pay_date_offset Number of days allowed for pay date offset
 * @param p_direct_deposit_date_offset Number of days allowed for direct
 * deposit offset
 * @param p_pay_advice_date_offset Number of days allowed for pay advice date
 * offset
 * @param p_cut_off_date_offset Number of days allowed for cut off date offset
 * @param p_midpoint_offset Number of days allowed for midpoint offset
 * @param p_default_payment_method_id Identifier for default payment method for
 * this payroll
 * @param p_consolidation_set_id Consolidation set identifier for this payroll
 * @param p_cost_alloc_keyflex_id_in Identifier for Cost allocation key
 * flexfield for this payroll
 * @param p_susp_account_keyflex_id_in Identifier of Suspense account key
 * flexfield for this payroll
 * @param p_negative_pay_allowed_flag Flag to indicate if negative pay allowed
 * @param p_gl_set_of_books_id Identifier of General ledger set of books for
 * this payroll
 * @param p_soft_coding_keyflex_id_in Identifier for soft coding key flexfield for
 * this payroll
 * @param p_comments Payroll comment text
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
 * @param p_arrears_flag Flag to indicate if arrears payroll
 * @param p_period_reset_years Number of years after which the period start of
 * the next corresponding year is reset.
 * @param p_multi_assignments_flag Flag to indicate if multi Assignment payroll
 * @param p_organization_id Organization ID
 * @param p_prl_information1 Developer Descriptive flexfield segment.
 * @param p_prl_information2 Developer Descriptive flexfield segment.
 * @param p_prl_information3 Developer Descriptive flexfield segment.
 * @param p_prl_information4 Developer Descriptive flexfield segment.
 * @param p_prl_information5 Developer Descriptive flexfield segment.
 * @param p_prl_information6 Developer Descriptive flexfield segment.
 * @param p_prl_information7 Developer Descriptive flexfield segment.
 * @param p_prl_information8 Developer Descriptive flexfield segment.
 * @param p_prl_information9 Developer Descriptive flexfield segment.
 * @param p_prl_information10 Developer Descriptive flexfield segment.
 * @param p_prl_information11 Developer Descriptive flexfield segment.
 * @param p_prl_information12 Developer Descriptive flexfield segment.
 * @param p_prl_information13 Developer Descriptive flexfield segment.
 * @param p_prl_information14 Developer Descriptive flexfield segment.
 * @param p_prl_information15 Developer Descriptive flexfield segment.
 * @param p_prl_information16 Developer Descriptive flexfield segment.
 * @param p_prl_information17 Developer Descriptive flexfield segment.
 * @param p_prl_information18 Developer Descriptive flexfield segment.
 * @param p_prl_information19 Developer Descriptive flexfield segment.
 * @param p_prl_information20 Developer Descriptive flexfield segment.
 * @param p_prl_information21 Developer Descriptive flexfield segment.
 * @param p_prl_information22 Developer Descriptive flexfield segment.
 * @param p_prl_information23 Developer Descriptive flexfield segment.
 * @param p_prl_information24 Developer Descriptive flexfield segment.
 * @param p_prl_information25 Developer Descriptive flexfield segment.
 * @param p_prl_information26 Developer Descriptive flexfield segment.
 * @param p_prl_information27 Developer Descriptive flexfield segment.
 * @param p_prl_information28 Developer Descriptive flexfield segment.
 * @param p_prl_information29 Developer Descriptive flexfield segment.
 * @param p_prl_information30 Developer Descriptive flexfield segment.
 * @param p_cost_segment1 Cost Allocation Keyflex field segment.
 * @param p_cost_segment2 Cost Allocation Keyflex field segment.
 * @param p_cost_segment3 Cost Allocation Keyflex field segment.
 * @param p_cost_segment4 Cost Allocation Keyflex field segment.
 * @param p_cost_segment5 Cost Allocation Keyflex field segment.
 * @param p_cost_segment6 Cost Allocation Keyflex field segment.
 * @param p_cost_segment7 Cost Allocation Keyflex field segment.
 * @param p_cost_segment8 Cost Allocation Keyflex field segment.
 * @param p_cost_segment9 Cost Allocation Keyflex field segment.
 * @param p_cost_segment10 Cost Allocation Keyflex field segment.
 * @param p_cost_segment11 Cost Allocation Keyflex field segment.
 * @param p_cost_segment12 Cost Allocation Keyflex field segment.
 * @param p_cost_segment13 Cost Allocation Keyflex field segment.
 * @param p_cost_segment14 Cost Allocation Keyflex field segment.
 * @param p_cost_segment15 Cost Allocation Keyflex field segment.
 * @param p_cost_segment16 Cost Allocation Keyflex field segment.
 * @param p_cost_segment17 Cost Allocation Keyflex field segment.
 * @param p_cost_segment18 Cost Allocation Keyflex field segment.
 * @param p_cost_segment19 Cost Allocation Keyflex field segment.
 * @param p_cost_segment20 Cost Allocation Keyflex field segment.
 * @param p_cost_segment21 Cost Allocation Keyflex field segment.
 * @param p_cost_segment22 Cost Allocation Keyflex field segment.
 * @param p_cost_segment23 Cost Allocation Keyflex field segment.
 * @param p_cost_segment24 Cost Allocation Keyflex field segment.
 * @param p_cost_segment25 Cost Allocation Keyflex field segment.
 * @param p_cost_segment26 Cost Allocation Keyflex field segment.
 * @param p_cost_segment27 Cost Allocation Keyflex field segment.
 * @param p_cost_segment28 Cost Allocation Keyflex field segment.
 * @param p_cost_segment29 Cost Allocation Keyflex field segment.
 * @param p_cost_segment30 Cost Allocation Keyflex field segment.
 * @param p_cost_concat_segments_in Concatenated segments of the Cost
 * Allocation Key FlexField.
 * @param p_susp_segment1 Suspense Account Keyflex field segment.
 * @param p_susp_segment2 Suspense Account Keyflex field segment.
 * @param p_susp_segment3 Suspense Account Keyflex field segment.
 * @param p_susp_segment4 Suspense Account Keyflex field segment.
 * @param p_susp_segment5 Suspense Account Keyflex field segment.
 * @param p_susp_segment6 Suspense Account Keyflex field segment.
 * @param p_susp_segment7 Suspense Account Keyflex field segment.
 * @param p_susp_segment8 Suspense Account Keyflex field segment.
 * @param p_susp_segment9 Suspense Account Keyflex field segment.
 * @param p_susp_segment10 Suspense Account Keyflex field segment.
 * @param p_susp_segment11 Suspense Account Keyflex field segment.
 * @param p_susp_segment12 Suspense Account Keyflex field segment.
 * @param p_susp_segment13 Suspense Account Keyflex field segment.
 * @param p_susp_segment14 Suspense Account Keyflex field segment.
 * @param p_susp_segment15 Suspense Account Keyflex field segment.
 * @param p_susp_segment16 Suspense Account Keyflex field segment.
 * @param p_susp_segment17 Suspense Account Keyflex field segment.
 * @param p_susp_segment18 Suspense Account Keyflex field segment.
 * @param p_susp_segment19 Suspense Account Keyflex field segment.
 * @param p_susp_segment20 Suspense Account Keyflex field segment.
 * @param p_susp_segment21 Suspense Account Keyflex field segment.
 * @param p_susp_segment22 Suspense Account Keyflex field segment.
 * @param p_susp_segment23 Suspense Account Keyflex field segment.
 * @param p_susp_segment24 Suspense Account Keyflex field segment.
 * @param p_susp_segment25 Suspense Account Keyflex field segment.
 * @param p_susp_segment26 Suspense Account Keyflex field segment.
 * @param p_susp_segment27 Suspense Account Keyflex field segment.
 * @param p_susp_segment28 Suspense Account Keyflex field segment.
 * @param p_susp_segment29 Suspense Account Keyflex field segment.
 * @param p_susp_segment30 Suspense Account Keyflex field segment.
 * @param p_susp_concat_segments_in Concatenated segments of the Suspense
 * Account Key FlexField.
 * @param p_scl_segment1 Soft Coding Keyflex field segment.
 * @param p_scl_segment2 Soft Coding Keyflex field segment.
 * @param p_scl_segment3 Soft Coding Keyflex field segment.
 * @param p_scl_segment4 Soft Coding Keyflex field segment.
 * @param p_scl_segment5 Soft Coding Keyflex field segment.
 * @param p_scl_segment6 Soft Coding Keyflex field segment.
 * @param p_scl_segment7 Soft Coding Keyflex field segment.
 * @param p_scl_segment8 Soft Coding Keyflex field segment.
 * @param p_scl_segment9 Soft Coding Keyflex field segment.
 * @param p_scl_segment10 Soft Coding Keyflex field segment.
 * @param p_scl_segment11 Soft Coding Keyflex field segment.
 * @param p_scl_segment12 Soft Coding Keyflex field segment.
 * @param p_scl_segment13 Soft Coding Keyflex field segment.
 * @param p_scl_segment14 Soft Coding Keyflex field segment.
 * @param p_scl_segment15 Soft Coding Keyflex field segment.
 * @param p_scl_segment16 Soft Coding Keyflex field segment.
 * @param p_scl_segment17 Soft Coding Keyflex field segment.
 * @param p_scl_segment18 Soft Coding Keyflex field segment.
 * @param p_scl_segment19 Soft Coding Keyflex field segment.
 * @param p_scl_segment20 Soft Coding Keyflex field segment.
 * @param p_scl_segment21 Soft Coding Keyflex field segment.
 * @param p_scl_segment22 Soft Coding Keyflex field segment.
 * @param p_scl_segment23 Soft Coding Keyflex field segment.
 * @param p_scl_segment24 Soft Coding Keyflex field segment.
 * @param p_scl_segment25 Soft Coding Keyflex field segment.
 * @param p_scl_segment26 Soft Coding Keyflex field segment.
 * @param p_scl_segment27 Soft Coding Keyflex field segment.
 * @param p_scl_segment28 Soft Coding Keyflex field segment.
 * @param p_scl_segment29 Soft Coding Keyflex field segment.
 * @param p_scl_segment30 Soft Coding Keyflex field segment.
 * @param p_scl_concat_segments_in Concatenated segments of the Soft
 * Coding Key FlexField.
 * @param p_workload_shifting_level Work load shifting level.
 * @param p_payslip_view_date_offset Payslip view date offset.
 * @param p_payroll_id If p_validate is false, this uniquely identifies the
 * Payroll created. If p_validate is set to true, this parameter will be null.
 * @param p_org_pay_method_usage_id If p_validate is false, this uniquely
 * identifies the Organization Payment Method Usage created. If p_validate is
 * set to true, this parameter will be null.
 * @param p_prl_object_version_number If p_validate is false, then set to the
 * version number of the created payroll. If p_validate is true, then the value
 * will be null.
 * @param p_opm_object_version_number If p_validate is false, then set to the
 * version number of the organisation payment method. If p_validate is true,
 * then the value will be null.
 * @param p_prl_effective_start_date If p_validate is false, then set to the
 * earliest effective
 * @param p_prl_effective_end_date If p_validate is false, then set to the
 * effective end date for the created payroll. If p_validate is true, then set
 * to null.
 * @param p_opm_effective_start_date If p_validate is false, then set to the
 * earliest effective
 * @param p_opm_effective_end_date If p_validate is false, then set to the
 * effective end date for the organisation payment methods. If p_validate is
 * true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created payroll comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_cost_alloc_keyflex_id_out If p_validate is false, If a value is
 * provided to any of the cost allocation segments or p_cost_concat_segments_in
 * then it will be set to the id that is uniquely identifies the specified
 * segments in the PAY_ALLOCATION_KEYFLEX table. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to the value
 * specified. If p_validate is true, then will be null.
 * @param p_susp_account_keyflex_id_out If p_validate is false, If a value
 * is provided to any of the suspense account segments or
 * p_susp_concat_segments_in then it will be set to the id that is uniquely
 * identifies the specified segments in the PAY_ALLOCATION_KEYFLEX table.If any
 * value is provided to the parameter p_susp_account_keyflex_id_in then this
 * will be set to the value specified. If p_validate is true, then will be
 * null.
 * @param p_soft_coding_keyflex_id_out If p_validate is false, If a value is
 * provided to any of the soft coding segments or p_soft_concat_segments_in
 * then it will be set to the id that is uniquely identifies the specified
 * segments in the HR_SOFT_CODING_KEYFLEX table. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to the value
 * specified. If p_validate is true, then will be null.
 * @param p_cost_concat_segments_out If p_validate is false, If a value is
 * provided to any of the cost allocation segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to null.
 * If p_validate is true, then will be null.
 * @param p_susp_concat_segments_out If p_validate is false, If a value is
 * provided to any of the suspense account segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_susp_account_keyflex_id_in then this will be set to null. If
 * p_validate is true, then will be null.
 * @param p_scl_concat_segments_out If p_validate is false, If a value
 * is provided to any of the soft coding segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_soft_coding_keyflex_id_in then this will be set to null.
 * If p_validate is true, then will be null.
 * @rep:displayname Create Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_payroll
(
   p_validate                     in   boolean   default false,
   p_effective_date               in   date,
   p_payroll_name                 in   varchar2,
   p_consolidation_set_id         in   number,
   p_period_type                  in   varchar2,
   p_first_period_end_date        in   date,
   p_number_of_years              in   number,
   p_payroll_type                 in   varchar2  default null,
   p_pay_date_offset              in   number    default 0,
   p_direct_deposit_date_offset   in   number    default 0,
   p_pay_advice_date_offset       in   number    default 0,
   p_cut_off_date_offset          in   number    default 0,
   p_midpoint_offset              in   number    default null,
   p_default_payment_method_id    in   number    default null,
   p_cost_alloc_keyflex_id_in     in   number    default null,
   p_susp_account_keyflex_id_in   in   number    default null,
   p_negative_pay_allowed_flag    in   varchar2  default 'N',
   p_gl_set_of_books_id           in   number    default null,
   p_soft_coding_keyflex_id_in    in   number    default null,
   p_comments                     in   varchar2  default null,
   p_attribute_category           in   varchar2  default null,
   p_attribute1                   in   varchar2  default null,
   p_attribute2                   in   varchar2  default null,
   p_attribute3                   in   varchar2  default null,
   p_attribute4                   in   varchar2  default null,
   p_attribute5                   in   varchar2  default null,
   p_attribute6                   in   varchar2  default null,
   p_attribute7                   in   varchar2  default null,
   p_attribute8                   in   varchar2  default null,
   p_attribute9                   in   varchar2  default null,
   p_attribute10                  in   varchar2  default null,
   p_attribute11                  in   varchar2  default null,
   p_attribute12                  in   varchar2  default null,
   p_attribute13                  in   varchar2  default null,
   p_attribute14                  in   varchar2  default null,
   p_attribute15                  in   varchar2  default null,
   p_attribute16                  in   varchar2  default null,
   p_attribute17                  in   varchar2  default null,
   p_attribute18                  in   varchar2  default null,
   p_attribute19                  in   varchar2  default null,
   p_attribute20                  in   varchar2  default null,
   p_arrears_flag                 in   varchar2  default 'N',
   p_period_reset_years           in   varchar2  default null,
   p_multi_assignments_flag       in   varchar2  default null,
   p_organization_id              in   number    default null,
   p_prl_information1         	  in   varchar2  default null,
   p_prl_information2         	  in   varchar2  default null,
   p_prl_information3         	  in   varchar2  default null,
   p_prl_information4         	  in   varchar2  default null,
   p_prl_information5         	  in   varchar2  default null,
   p_prl_information6         	  in   varchar2  default null,
   p_prl_information7         	  in   varchar2  default null,
   p_prl_information8         	  in   varchar2  default null,
   p_prl_information9         	  in   varchar2  default null,
   p_prl_information10        	  in   varchar2  default null,
   p_prl_information11            in   varchar2  default null,
   p_prl_information12        	  in   varchar2  default null,
   p_prl_information13        	  in   varchar2  default null,
   p_prl_information14        	  in   varchar2  default null,
   p_prl_information15        	  in   varchar2  default null,
   p_prl_information16        	  in   varchar2  default null,
   p_prl_information17        	  in   varchar2  default null,
   p_prl_information18        	  in   varchar2  default null,
   p_prl_information19        	  in   varchar2  default null,
   p_prl_information20        	  in   varchar2  default null,
   p_prl_information21        	  in   varchar2  default null,
   p_prl_information22            in   varchar2  default null,
   p_prl_information23        	  in   varchar2  default null,
   p_prl_information24        	  in   varchar2  default null,
   p_prl_information25        	  in   varchar2  default null,
   p_prl_information26        	  in   varchar2  default null,
   p_prl_information27        	  in   varchar2  default null,
   p_prl_information28        	  in   varchar2  default null,
   p_prl_information29        	  in   varchar2  default null,
   p_prl_information30            in   varchar2  default null,

   p_cost_segment1                 in  varchar2 default null,
   p_cost_segment2                 in  varchar2 default null,
   p_cost_segment3                 in  varchar2 default null,
   p_cost_segment4                 in  varchar2 default null,
   p_cost_segment5                 in  varchar2 default null,
   p_cost_segment6                 in  varchar2 default null,
   p_cost_segment7                 in  varchar2 default null,
   p_cost_segment8                 in  varchar2 default null,
   p_cost_segment9                 in  varchar2 default null,
   p_cost_segment10                in  varchar2 default null,
   p_cost_segment11                in  varchar2 default null,
   p_cost_segment12                in  varchar2 default null,
   p_cost_segment13                in  varchar2 default null,
   p_cost_segment14                in  varchar2 default null,
   p_cost_segment15                in  varchar2 default null,
   p_cost_segment16                in  varchar2 default null,
   p_cost_segment17                in  varchar2 default null,
   p_cost_segment18                in  varchar2 default null,
   p_cost_segment19                in  varchar2 default null,
   p_cost_segment20                in  varchar2 default null,
   p_cost_segment21                in  varchar2 default null,
   p_cost_segment22                in  varchar2 default null,
   p_cost_segment23                in  varchar2 default null,
   p_cost_segment24                in  varchar2 default null,
   p_cost_segment25                in  varchar2 default null,
   p_cost_segment26                in  varchar2 default null,
   p_cost_segment27                in  varchar2 default null,
   p_cost_segment28                in  varchar2 default null,
   p_cost_segment29                in  varchar2 default null,
   p_cost_segment30                in  varchar2 default null,
   p_cost_concat_segments_in       in  varchar2 default null,

   p_susp_segment1                 in  varchar2 default null,
   p_susp_segment2                 in  varchar2 default null,
   p_susp_segment3                 in  varchar2 default null,
   p_susp_segment4                 in  varchar2 default null,
   p_susp_segment5                 in  varchar2 default null,
   p_susp_segment6                 in  varchar2 default null,
   p_susp_segment7                 in  varchar2 default null,
   p_susp_segment8                 in  varchar2 default null,
   p_susp_segment9                 in  varchar2 default null,
   p_susp_segment10                in  varchar2 default null,
   p_susp_segment11                in  varchar2 default null,
   p_susp_segment12                in  varchar2 default null,
   p_susp_segment13                in  varchar2 default null,
   p_susp_segment14                in  varchar2 default null,
   p_susp_segment15                in  varchar2 default null,
   p_susp_segment16                in  varchar2 default null,
   p_susp_segment17                in  varchar2 default null,
   p_susp_segment18                in  varchar2 default null,
   p_susp_segment19                in  varchar2 default null,
   p_susp_segment20                in  varchar2 default null,
   p_susp_segment21                in  varchar2 default null,
   p_susp_segment22                in  varchar2 default null,
   p_susp_segment23                in  varchar2 default null,
   p_susp_segment24                in  varchar2 default null,
   p_susp_segment25                in  varchar2 default null,
   p_susp_segment26                in  varchar2 default null,
   p_susp_segment27                in  varchar2 default null,
   p_susp_segment28                in  varchar2 default null,
   p_susp_segment29                in  varchar2 default null,
   p_susp_segment30                in  varchar2 default null,
   p_susp_concat_segments_in       in  varchar2 default null,

   p_scl_segment1                 in  varchar2 default null,
   p_scl_segment2                 in  varchar2 default null,
   p_scl_segment3                 in  varchar2 default null,
   p_scl_segment4                 in  varchar2 default null,
   p_scl_segment5                 in  varchar2 default null,
   p_scl_segment6                 in  varchar2 default null,
   p_scl_segment7                 in  varchar2 default null,
   p_scl_segment8                 in  varchar2 default null,
   p_scl_segment9                 in  varchar2 default null,
   p_scl_segment10                in  varchar2 default null,
   p_scl_segment11                in  varchar2 default null,
   p_scl_segment12                in  varchar2 default null,
   p_scl_segment13                in  varchar2 default null,
   p_scl_segment14                in  varchar2 default null,
   p_scl_segment15                in  varchar2 default null,
   p_scl_segment16                in  varchar2 default null,
   p_scl_segment17                in  varchar2 default null,
   p_scl_segment18                in  varchar2 default null,
   p_scl_segment19                in  varchar2 default null,
   p_scl_segment20                in  varchar2 default null,
   p_scl_segment21                in  varchar2 default null,
   p_scl_segment22                in  varchar2 default null,
   p_scl_segment23                in  varchar2 default null,
   p_scl_segment24                in  varchar2 default null,
   p_scl_segment25                in  varchar2 default null,
   p_scl_segment26                in  varchar2 default null,
   p_scl_segment27                in  varchar2 default null,
   p_scl_segment28                in  varchar2 default null,
   p_scl_segment29                in  varchar2 default null,
   p_scl_segment30                in  varchar2 default null,
   p_scl_concat_segments_in       in  varchar2 default null,

   p_workload_shifting_level      in  varchar2 default 'N',
   p_payslip_view_date_offset     in  number   default null,

   p_payroll_id                   out  nocopy number,
   p_org_pay_method_usage_id      out  nocopy number,
   p_prl_object_version_number    out  nocopy number,
   p_opm_object_version_number    out  nocopy number,
   p_prl_effective_start_date     out  nocopy date,
   p_prl_effective_end_date       out  nocopy date,
   p_opm_effective_start_date     out  nocopy date,
   p_opm_effective_end_date       out  nocopy date,
   p_comment_id                   out  nocopy number,

   p_cost_alloc_keyflex_id_out    out  nocopy number,
   p_susp_account_keyflex_id_out  out  nocopy number,
   p_soft_coding_keyflex_id_out   out  nocopy number,

   p_cost_concat_segments_out     out nocopy varchar2,
   p_susp_concat_segments_out     out nocopy varchar2,
   p_scl_concat_segments_out      out nocopy varchar2

   );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process make changes to the definition of the payroll as
 * specified by parameter values passed to it.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Relevant Payroll, payment methods and consolidation sets must be defined
 *
 * <p><b>Post Success</b><br>
 * The payroll and time periods will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The payroll will not be updated and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_payroll_name New payroll name.
 * @param p_number_of_years Number of years. It is used to create time
 * periods for the payroll.
 * @param p_default_payment_method_id Identifier for default payment method for
 * this payroll
 * @param p_consolidation_set_id Consolidation set identifier for this payroll
 * @param p_cost_alloc_keyflex_id_in Identifier for Cost allocation key
 * flexfield for this payroll
 * @param p_susp_account_keyflex_id_in Identifier of Suspense account key
 * flexfield for this payroll
 * @param p_negative_pay_allowed_flag Flag to indicate if negative pay allowed
 * @param p_soft_coding_keyflex_id_in Identifier for soft coding key flexfield for
 * this payroll
 * @param p_comments Payroll comment text
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
 * @param p_arrears_flag Flag to indicate if arrears payroll
 * @param p_multi_assignments_flag Flag to indicate if multi Assignment payroll
 * @param p_prl_information1 Developer Descriptive flexfield segment.
 * @param p_prl_information2 Developer Descriptive flexfield segment.
 * @param p_prl_information3 Developer Descriptive flexfield segment.
 * @param p_prl_information4 Developer Descriptive flexfield segment.
 * @param p_prl_information5 Developer Descriptive flexfield segment.
 * @param p_prl_information6 Developer Descriptive flexfield segment.
 * @param p_prl_information7 Developer Descriptive flexfield segment.
 * @param p_prl_information8 Developer Descriptive flexfield segment.
 * @param p_prl_information9 Developer Descriptive flexfield segment.
 * @param p_prl_information10 Developer Descriptive flexfield segment.
 * @param p_prl_information11 Developer Descriptive flexfield segment.
 * @param p_prl_information12 Developer Descriptive flexfield segment.
 * @param p_prl_information13 Developer Descriptive flexfield segment.
 * @param p_prl_information14 Developer Descriptive flexfield segment.
 * @param p_prl_information15 Developer Descriptive flexfield segment.
 * @param p_prl_information16 Developer Descriptive flexfield segment.
 * @param p_prl_information17 Developer Descriptive flexfield segment.
 * @param p_prl_information18 Developer Descriptive flexfield segment.
 * @param p_prl_information19 Developer Descriptive flexfield segment.
 * @param p_prl_information20 Developer Descriptive flexfield segment.
 * @param p_prl_information21 Developer Descriptive flexfield segment.
 * @param p_prl_information22 Developer Descriptive flexfield segment.
 * @param p_prl_information23 Developer Descriptive flexfield segment.
 * @param p_prl_information24 Developer Descriptive flexfield segment.
 * @param p_prl_information25 Developer Descriptive flexfield segment.
 * @param p_prl_information26 Developer Descriptive flexfield segment.
 * @param p_prl_information27 Developer Descriptive flexfield segment.
 * @param p_prl_information28 Developer Descriptive flexfield segment.
 * @param p_prl_information29 Developer Descriptive flexfield segment.
 * @param p_prl_information30 Developer Descriptive flexfield segment.
 * @param p_cost_segment1 Cost Allocation Keyflex field segment.
 * @param p_cost_segment2 Cost Allocation Keyflex field segment.
 * @param p_cost_segment3 Cost Allocation Keyflex field segment.
 * @param p_cost_segment4 Cost Allocation Keyflex field segment.
 * @param p_cost_segment5 Cost Allocation Keyflex field segment.
 * @param p_cost_segment6 Cost Allocation Keyflex field segment.
 * @param p_cost_segment7 Cost Allocation Keyflex field segment.
 * @param p_cost_segment8 Cost Allocation Keyflex field segment.
 * @param p_cost_segment9 Cost Allocation Keyflex field segment.
 * @param p_cost_segment10 Cost Allocation Keyflex field segment.
 * @param p_cost_segment11 Cost Allocation Keyflex field segment.
 * @param p_cost_segment12 Cost Allocation Keyflex field segment.
 * @param p_cost_segment13 Cost Allocation Keyflex field segment.
 * @param p_cost_segment14 Cost Allocation Keyflex field segment.
 * @param p_cost_segment15 Cost Allocation Keyflex field segment.
 * @param p_cost_segment16 Cost Allocation Keyflex field segment.
 * @param p_cost_segment17 Cost Allocation Keyflex field segment.
 * @param p_cost_segment18 Cost Allocation Keyflex field segment.
 * @param p_cost_segment19 Cost Allocation Keyflex field segment.
 * @param p_cost_segment20 Cost Allocation Keyflex field segment.
 * @param p_cost_segment21 Cost Allocation Keyflex field segment.
 * @param p_cost_segment22 Cost Allocation Keyflex field segment.
 * @param p_cost_segment23 Cost Allocation Keyflex field segment.
 * @param p_cost_segment24 Cost Allocation Keyflex field segment.
 * @param p_cost_segment25 Cost Allocation Keyflex field segment.
 * @param p_cost_segment26 Cost Allocation Keyflex field segment.
 * @param p_cost_segment27 Cost Allocation Keyflex field segment.
 * @param p_cost_segment28 Cost Allocation Keyflex field segment.
 * @param p_cost_segment29 Cost Allocation Keyflex field segment.
 * @param p_cost_segment30 Cost Allocation Keyflex field segment.
 * @param p_cost_concat_segments_in Concatenated segments of the Cost
 * Allocation Key FlexField.
 * @param p_susp_segment1 Suspense Account Keyflex field segment.
 * @param p_susp_segment2 Suspense Account Keyflex field segment.
 * @param p_susp_segment3 Suspense Account Keyflex field segment.
 * @param p_susp_segment4 Suspense Account Keyflex field segment.
 * @param p_susp_segment5 Suspense Account Keyflex field segment.
 * @param p_susp_segment6 Suspense Account Keyflex field segment.
 * @param p_susp_segment7 Suspense Account Keyflex field segment.
 * @param p_susp_segment8 Suspense Account Keyflex field segment.
 * @param p_susp_segment9 Suspense Account Keyflex field segment.
 * @param p_susp_segment10 Suspense Account Keyflex field segment.
 * @param p_susp_segment11 Suspense Account Keyflex field segment.
 * @param p_susp_segment12 Suspense Account Keyflex field segment.
 * @param p_susp_segment13 Suspense Account Keyflex field segment.
 * @param p_susp_segment14 Suspense Account Keyflex field segment.
 * @param p_susp_segment15 Suspense Account Keyflex field segment.
 * @param p_susp_segment16 Suspense Account Keyflex field segment.
 * @param p_susp_segment17 Suspense Account Keyflex field segment.
 * @param p_susp_segment18 Suspense Account Keyflex field segment.
 * @param p_susp_segment19 Suspense Account Keyflex field segment.
 * @param p_susp_segment20 Suspense Account Keyflex field segment.
 * @param p_susp_segment21 Suspense Account Keyflex field segment.
 * @param p_susp_segment22 Suspense Account Keyflex field segment.
 * @param p_susp_segment23 Suspense Account Keyflex field segment.
 * @param p_susp_segment24 Suspense Account Keyflex field segment.
 * @param p_susp_segment25 Suspense Account Keyflex field segment.
 * @param p_susp_segment26 Suspense Account Keyflex field segment.
 * @param p_susp_segment27 Suspense Account Keyflex field segment.
 * @param p_susp_segment28 Suspense Account Keyflex field segment.
 * @param p_susp_segment29 Suspense Account Keyflex field segment.
 * @param p_susp_segment30 Suspense Account Keyflex field segment.
 * @param p_susp_concat_segments_in Concatenated segments of the Suspense
 * Account Key FlexField.
 * @param p_scl_segment1 Soft Coding Keyflex field segment.
 * @param p_scl_segment2 Soft Coding Keyflex field segment.
 * @param p_scl_segment3 Soft Coding Keyflex field segment.
 * @param p_scl_segment4 Soft Coding Keyflex field segment.
 * @param p_scl_segment5 Soft Coding Keyflex field segment.
 * @param p_scl_segment6 Soft Coding Keyflex field segment.
 * @param p_scl_segment7 Soft Coding Keyflex field segment.
 * @param p_scl_segment8 Soft Coding Keyflex field segment.
 * @param p_scl_segment9 Soft Coding Keyflex field segment.
 * @param p_scl_segment10 Soft Coding Keyflex field segment.
 * @param p_scl_segment11 Soft Coding Keyflex field segment.
 * @param p_scl_segment12 Soft Coding Keyflex field segment.
 * @param p_scl_segment13 Soft Coding Keyflex field segment.
 * @param p_scl_segment14 Soft Coding Keyflex field segment.
 * @param p_scl_segment15 Soft Coding Keyflex field segment.
 * @param p_scl_segment16 Soft Coding Keyflex field segment.
 * @param p_scl_segment17 Soft Coding Keyflex field segment.
 * @param p_scl_segment18 Soft Coding Keyflex field segment.
 * @param p_scl_segment19 Soft Coding Keyflex field segment.
 * @param p_scl_segment20 Soft Coding Keyflex field segment.
 * @param p_scl_segment21 Soft Coding Keyflex field segment.
 * @param p_scl_segment22 Soft Coding Keyflex field segment.
 * @param p_scl_segment23 Soft Coding Keyflex field segment.
 * @param p_scl_segment24 Soft Coding Keyflex field segment.
 * @param p_scl_segment25 Soft Coding Keyflex field segment.
 * @param p_scl_segment26 Soft Coding Keyflex field segment.
 * @param p_scl_segment27 Soft Coding Keyflex field segment.
 * @param p_scl_segment28 Soft Coding Keyflex field segment.
 * @param p_scl_segment29 Soft Coding Keyflex field segment.
 * @param p_scl_segment30 Soft Coding Keyflex field segment.
 * @param p_scl_concat_segments_in Concatenated segments of the Soft
 * Coding Key FlexField.
 * @param p_workload_shifting_level Work load shifting level.
 * @param p_payslip_view_date_offset Payslip view date offset.
 * @param p_payroll_id If p_validate is false, this uniquely identifies the
 * Payroll to be updated. If p_validate is set to true, this parameter will be
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the updated payroll if the payroll is updated.
 * If p_validate is true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created payroll. If p_validate is true, then set
 * to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created payroll comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_cost_alloc_keyflex_id_out If p_validate is false, If a value is
 * provided to any of the cost allocation segments or p_cost_concat_segments_in
 * then it will be set to the id that is uniquely identifies the specified
 * segments in the PAY_ALLOCATION_KEYFLEX table. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to the value
 * specified. If p_validate is true, then will be null.
 * @param p_susp_account_keyflex_id_out If p_validate is false, If a value
 * is provided to any of the suspense account segments or
 * p_susp_concat_segments_in then it will be set to the id that is uniquely
 * identifies the specified segments in the PAY_ALLOCATION_KEYFLEX table.If any
 * value is provided to the parameter p_susp_account_keyflex_id_in then this
 * will be set to the value specified. If p_validate is true, then will be
 * null.
 * @param p_soft_coding_keyflex_id_out If p_validate is false, If a value is
 * provided to any of the soft coding segments or p_soft_concat_segments_in
 * then it will be set to the id that is uniquely identifies the specified
 * segments in the HR_SOFT_CODING_KEYFLEX table. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to the value
 * specified. If p_validate is true, then will be null.
 * @param p_cost_concat_segments_out If p_validate is false, If a value is
 * provided to any of the cost allocation segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_cost_alloc_keyflex_id_in then this will be set to null.
 * If p_validate is true, then will be null.
 * @param p_susp_concat_segments_out If p_validate is false, If a value is
 * provided to any of the suspense account segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_susp_account_keyflex_id_in then this will be set to null. If
 * p_validate is true, then will be null.
 * @param p_scl_concat_segments_out If p_validate is false, If a value
 * is provided to any of the soft coding segments then it will be set to the
 * concatinated string of the specified segments. If any value is provided to
 * the parameter p_soft_coding_keyflex_id_in then this will be set to null.
 * If p_validate is true, then will be null.
 * @rep:displayname Update Payroll
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_DEFINITION
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
   procedure update_payroll
   (
   p_validate                       in     boolean   default false,
   p_effective_date                 in     date,
   p_datetrack_mode                 in     varchar2,
   p_payroll_name                   in     varchar2  default hr_api.g_varchar2,
   p_number_of_years                in     number    default hr_api.g_number,
   p_default_payment_method_id      in     number    default hr_api.g_number,
   p_consolidation_set_id           in     number    default hr_api.g_number,
   p_cost_alloc_keyflex_id_in       in    number    default hr_api.g_number,
   p_susp_account_keyflex_id_in     in    number    default hr_api.g_number,
   p_negative_pay_allowed_flag      in     varchar2  default hr_api.g_varchar2,
   p_soft_coding_keyflex_id_in      in     number    default hr_api.g_number,
   p_comments                       in     varchar2  default hr_api.g_varchar2,
   p_attribute_category           in     varchar2  default hr_api.g_varchar2,
   p_attribute1                   in     varchar2  default hr_api.g_varchar2,
   p_attribute2                   in     varchar2  default hr_api.g_varchar2,
   p_attribute3                   in     varchar2  default hr_api.g_varchar2,
   p_attribute4                   in     varchar2  default hr_api.g_varchar2,
   p_attribute5                   in     varchar2  default hr_api.g_varchar2,
   p_attribute6                   in     varchar2  default hr_api.g_varchar2,
   p_attribute7                   in     varchar2  default hr_api.g_varchar2,
   p_attribute8                   in     varchar2  default hr_api.g_varchar2,
   p_attribute9                   in     varchar2  default hr_api.g_varchar2,
   p_attribute10                  in     varchar2  default hr_api.g_varchar2,
   p_attribute11                  in     varchar2  default hr_api.g_varchar2,
   p_attribute12                  in     varchar2  default hr_api.g_varchar2,
   p_attribute13                  in     varchar2  default hr_api.g_varchar2,
   p_attribute14                  in     varchar2  default hr_api.g_varchar2,
   p_attribute15                  in     varchar2  default hr_api.g_varchar2,
   p_attribute16                  in     varchar2  default hr_api.g_varchar2,
   p_attribute17                  in     varchar2  default hr_api.g_varchar2,
   p_attribute18                  in     varchar2  default hr_api.g_varchar2,
   p_attribute19                  in     varchar2  default hr_api.g_varchar2,
   p_attribute20                  in     varchar2  default hr_api.g_varchar2,
   p_arrears_flag                 in     varchar2  default hr_api.g_varchar2,
   p_multi_assignments_flag       in     varchar2  default hr_api.g_varchar2,
   p_prl_information1         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information2         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information3         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information4         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information5         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information6         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information7         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information8         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information9         	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information10        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information11            in     varchar2  default hr_api.g_varchar2,
   p_prl_information12        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information13        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information14        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information15        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information16        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information17        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information18        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information19        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information20        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information21        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information22            in     varchar2  default hr_api.g_varchar2,
   p_prl_information23        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information24        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information25        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information26        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information27        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information28        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information29        	  in     varchar2  default hr_api.g_varchar2,
   p_prl_information30            in     varchar2  default hr_api.g_varchar2,

   p_cost_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_cost_segment10                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment11                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment12                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment13                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment14                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment15                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment16                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment17                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment18                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment19                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment20                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment21                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment22                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment23                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment24                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment25                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment26                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment27                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment28                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment29                in  varchar2 default hr_api.g_varchar2,
   p_cost_segment30                in  varchar2 default hr_api.g_varchar2,
   p_cost_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_susp_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_susp_segment10                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment11                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment12                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment13                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment14                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment15                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment16                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment17                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment18                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment19                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment20                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment21                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment22                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment23                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment24                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment25                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment26                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment27                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment28                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment29                in  varchar2 default hr_api.g_varchar2,
   p_susp_segment30                in  varchar2 default hr_api.g_varchar2,
   p_susp_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_scl_segment1                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment2                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment3                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment4                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment5                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment6                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment7                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment8                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment9                 in  varchar2 default hr_api.g_varchar2,
   p_scl_segment10                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment11                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment12                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment13                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment14                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment15                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment16                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment17                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment18                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment19                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment20                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment21                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment22                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment23                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment24                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment25                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment26                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment27                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment28                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment29                in  varchar2 default hr_api.g_varchar2,
   p_scl_segment30                in  varchar2 default hr_api.g_varchar2,
   p_scl_concat_segments_in       in  varchar2 default hr_api.g_varchar2,

   p_workload_shifting_level      in  varchar2 default hr_api.g_varchar2,
   p_payslip_view_date_offset     in  number   default hr_api.g_number,

   p_payroll_id                   in out nocopy number,
   p_object_version_number        in out nocopy number,

   p_effective_start_date         out  nocopy date,
   p_effective_end_date           out  nocopy date,
   p_cost_alloc_keyflex_id_out    out  nocopy number,
   p_susp_account_keyflex_id_out  out  nocopy number,
   p_soft_coding_keyflex_id_out   out  nocopy number,

   p_comment_id                   out  nocopy number,
   p_cost_concat_segments_out     out  nocopy varchar2,
   p_susp_concat_segments_out     out  nocopy varchar2,
   p_scl_concat_segments_out      out  nocopy varchar2

   );
end pay_payroll_api;

/
