--------------------------------------------------------
--  DDL for Package PAY_IE_PAYE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAYE_API" AUTHID CURRENT_USER as
/* $Header: pyipdapi.pkh 120.9 2008/01/11 06:59:21 rrajaman noship $ */
/*#
 * This package contains the PAYE Details API for Ireland.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname PAYE Detail for Ireland
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_ie_paye_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates PAYE Details for Ireland.
 *
 * A PAYE Detail record is created for an assignment. If P45 information is
 * entered, balance adjustments are created for the P45 data.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must belong to a payroll. To enter P45 details the assignment
 * must have the P45 Information Element linked.
 *
 * <p><b>Post Success</b><br>
 * A PAYE Details record is created for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PAYE Detail records are created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment for which you created the
 * PAYE Details record.
 * @param p_info_source Information Source uses IE_PAYE_INFO_SOURCE lookup to
 * explain where the information has come from.
 * @param p_tax_basis Tax Basis uses IE_PAYE_TAX_BASIS lookup for meaning.
 * @param p_certificate_start_date Tax Certificate Start Date.
 * @param p_tax_assess_basis Tax Assessment Basis uses IE_PAYE_ASSESS_BASIS
 * lookup for meaning.
 * @param p_certificate_issue_date Date the Tax Certificate was issued.
 * @param p_certificate_end_date Tax Certificate End Date.
 * @param p_weekly_tax_credit Weekly Tax Credit.
 * @param p_weekly_std_rate_cut_off Weekly Standard Rate Cut Off.
 * @param p_monthly_tax_credit Monthly Tax Credit.
 * @param p_monthly_std_rate_cut_off Monthly Standard Rate Cut Off.
 * @param p_tax_deducted_to_date This is the amount of tax deducted from
 * previous employment, as detailed on the employee's P45.
 * @param p_pay_to_date This is the amount of pay to date from previous
 * employment, as detailed on the employee's P45.
 * @param p_disability_benefit This is the amount of disability benefit
 * received from previous employment, as detailed on the employee's P45.
 * @param p_lump_sum_payment This is the amount of lump sum received from
 * previous employment, as detailed on the employee's P45.
 * @param p_paye_details_id If p_validate is false, then this uniquely
 * identifies the PAYE details record created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created PAYE Details record. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created PAYE Details record. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created PAYE Details record. If p_validate is
 * true, then set to null.
 * @param p_Tax_This_Employment Set to the Tax paid in this employment.
 * @param p_Previous_Employment_Start_Dt Set to the start date of the
 * previous employment.
 * @param p_Previous_Employment_End_Date Set to the end date of the
 * previous employment.
 * @param p_Pay_This_Employment Set to the pay amount in this employment.
 * @param p_PAYE_Previous_Employer Set to the PAYE paid to the previous
 * employer.
 * @param p_P45P3_Or_P46 Set to the type of report, P45 Part 3 or P46.
 * @param p_Already_Submitted Set to Y if P45 Part 3 or P46 has already been
 * submitted online, else set to N.
 * @rep:displayname Create PAYE Detail for Ireland
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ie_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date     default null
  ,p_certificate_end_date          in     date     default null
  ,p_weekly_tax_credit             in     number   default null
  ,p_weekly_std_rate_cut_off       in     number   default null
  ,p_monthly_tax_credit            in     number   default null
  ,p_monthly_std_rate_cut_off      in     number   default null
  ,p_tax_deducted_to_date          in     number   default null
  ,p_pay_to_date                   in     number   default null
  ,p_disability_benefit            in     number   default null
  ,p_lump_sum_payment              in     number   default null
  ,p_paye_details_id               out    nocopy number
  ,p_object_version_number         out    nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_Tax_This_Employment	      in    Number   default null
  ,p_Previous_Employment_Start_Dt	in	date	   default null
  ,p_Previous_Employment_End_Date	in	date	   default null
  ,p_Pay_This_Employment		in	number   default null
  ,p_PAYE_Previous_Employer		in	varchar2 default null
  ,p_P45P3_Or_P46				in	varchar2 default null
  ,p_Already_Submitted			in	varchar2 default null
  --,p_P45P3_Or_P46_Processed		in	varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ie_paye_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Updates PAYE Details for Ireland.
 *
 * A PAYE Detail record is Updated for an assignment. If P45 information is
 * entered, then balance adjustments are updated for the P45 data.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * PAYE Details must exist for the assignment at the time of the update.
 *
 * <p><b>Post Success</b><br>
 * A PAYE Details record is updated for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PAYE Detail records are updated and an error is raised.
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
 * @param p_paye_details_id Identifies the PAYE details record to be modified.
 * @param p_info_source Information Source uses IE_PAYE_INFO_SOURCE lookup to
 * explain where the information has come from.
 * @param p_tax_basis Tax Basis uses IE_PAYE_TAX_BASIS lookup for meaning.
 * @param p_certificate_start_date Tax Certificate Start Date.
 * @param p_tax_assess_basis Tax Assessment Basis uses IE_PAYE_ASSESS_BASIS
 * lookup for meaning.
 * @param p_certificate_issue_date Date the Tax Certificate was issued.
 * @param p_certificate_end_date Tax Certificate End Date.
 * @param p_weekly_tax_credit Weekly Tax Credit.
 * @param p_weekly_std_rate_cut_off Weekly Standard Rate Cut Off.
 * @param p_monthly_tax_credit Monthly Tax Credit.
 * @param p_monthly_std_rate_cut_off Monthly Standard Rate Cut Off.
 * @param p_tax_deducted_to_date This is the amount of tax deducted from
 * previous employment, as detailed on the employee's P45.
 * @param p_pay_to_date This is the amount of pay to date from previous
 * employment, as detailed on the employee's P45.
 * @param p_disability_benefit This is the amount of disability benefit
 * received at previous employment, as detailed on the employee's P45.
 * @param p_lump_sum_payment This is the amount of lump sum received at
 * previous employment, as detailed on the employee's P45.
 * @param p_object_version_number Pass in the current version number of the
 * PAYE Details record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated PAYE Details
 * record. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated PAYE Details row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated PAYE Details row which now exists as of
 * the effective date. If p_validate is true, then set to null.
* @param p_Tax_This_Employment Set to the Tax paid in this employment.
 * @param p_Previous_Employment_Start_Dt Set to the start date of the
 * previous employment.
 * @param p_Previous_Employment_End_Date Set to the end date of the
 * previous employment.
 * @param p_Pay_This_Employment Set to the pay amount in this employment.
 * @param p_PAYE_Previous_Employer Set to the PAYE paid to the previous
 * employer.
 * @param p_P45P3_Or_P46 Set to the type of report, P45 Part 3 or P46.
 * @param p_Already_Submitted Set to Y if P45 Part 3 or P46 has already been
 * submitted online, else set to N.
 * @rep:displayname Update PAYE Detail for Ireland
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ie_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_info_source                   in     varchar2
  ,p_tax_basis                     in     varchar2
  ,p_certificate_start_date        in     date
  ,p_tax_assess_basis              in     varchar2
  ,p_certificate_issue_date        in     date     default null
  ,p_certificate_end_date          in     date     default null
  ,p_weekly_tax_credit             in     number   default null
  ,p_weekly_std_rate_cut_off       in     number   default null
  ,p_monthly_tax_credit            in     number   default null
  ,p_monthly_std_rate_cut_off      in     number   default null
  ,p_tax_deducted_to_date          in     number   default null
  ,p_pay_to_date                   in     number   default null
  ,p_disability_benefit            in     number   default null
  ,p_lump_sum_payment              in     number   default null
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  ,p_Tax_This_Employment	      in    Number	default null
  ,p_Previous_Employment_Start_Dt   in	date		default null
  ,p_Previous_Employment_End_Date	in	date		default null
  ,p_Pay_This_Employment		in	number	default null
  ,p_PAYE_Previous_Employer		in	varchar2	default null
  ,p_P45P3_Or_P46				in	varchar2	default null
  ,p_Already_Submitted			in	varchar2	default null
  --,p_P45P3_Or_P46_Processed		in	varchar2	default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ie_paye_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API Deletes PAYE Details for Ireland.
 *
 * A PAYE Detail record is deleted for an assignment. If P45 information is
 * entered, then balance adjustments are deleted for the P45 data.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * PAYE Details must exist for the assignment at the time of the deletion.
 *
 * <p><b>Post Success</b><br>
 * A PAYE Details record is deleted for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PAYE Details records are deleted and an error raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_paye_details_id Identifies the PAYE details record to be deleted.
 * @param p_object_version_number Current version number of the PAYE Details
 * record to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted PAYE Details row which now exists as of
 * the effective date. If p_validate is true, or all row instances have been
 * deleted, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted PAYE Details row which now exists as of
 * the effective date. If p_validate is true, or all row instances have been
 * deleted, then set to null.
 * @rep:displayname Delete PAYE Detail for Ireland
 * @rep:category BUSINESS_ENTITY PAY_EMP_TAX_INFO
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ie_paye_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_paye_details_id               in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--
end pay_ie_paye_api;

/
