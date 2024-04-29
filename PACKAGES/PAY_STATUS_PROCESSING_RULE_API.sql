--------------------------------------------------------
--  DDL for Package PAY_STATUS_PROCESSING_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STATUS_PROCESSING_RULE_API" AUTHID CURRENT_USER as
/* $Header: pypprapi.pkh 120.1 2005/10/02 02:46:29 aroussel $ */
/*#
 * This package contains Status Processing Rule APIs.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Status Processing Rule
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_status_process_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to create a new Status Processing Rule (SPR)
 * as of the effective date.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The formula and the element to be used should be valid.
 *
 * <p><b>Post Success</b><br>
 * The status processing rule will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the status
 * processing rule is not created.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_type_id Element type id for the status processing rule.
 * @param p_business_group_id Business group for the status processing rule
 * @param p_legislation_code Legislation for the status processing rule
 * @param p_assignment_status_type_id Assignment Status type id for the status
 * processing rule.
 * @param p_formula_id Formula for the status processing rule
 * @param p_comments Status Processing Rule comment text.
 * @param p_legislation_subgroup Identifies the legislation of the predefined
 * data for the status processing rule.
 * @param p_status_processing_rule_id Unique identifier of the status
 * processing rule. If p_validate is false, this uniquely identifies the status
 * processing rule created. If p_validate is set to true, this parameter will
 * be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created status processing rule. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created status processing rule. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created status processing rule. If p_validate is true,
 * then the value will be null.
 * @param p_formula_mismatch_warning Returns true if any of the input values
 * for the element do not match the data type of any of the inputs of the
 * selected formula. Post Failure Error Messages are raised if any business
 * rule is violated and the status processing rule is not created.
 * @rep:displayname Create Status Process Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_status_process_rule
(
   p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_assignment_status_type_id      in     number   default null
  ,p_formula_id                     in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_legislation_subgroup           in     varchar2 default null
  ,p_status_processing_rule_id         out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
  ,p_formula_mismatch_warning          out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_status_process_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to update the Status Processing Rule (SPR).
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The status processing rule to be updated should exist. Also the formula to
 * be used should be valid.
 *
 * <p><b>Post Success</b><br>
 * The status processing rule will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the Status
 * processing rule is not updated.
 *
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
 * @param p_status_processing_rule_id Unique identifier of the status
 * processing rule being updated.
 * @param p_object_version_number Pass in the current version number of the
 * status processing rule to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated status
 * processing rule. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_formula_id Formula for the status processing rule
 * @param p_comments Status Processing Rule comment text.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated status processing rule row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated status processing rule row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_formula_mismatch_warning Returns true if any of the input values
 * for the element do not match the data type of any of the inputs of the
 * selected formula.
 * @rep:displayname Update Status Process Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_status_process_rule
(
   p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_status_processing_rule_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_formula_mismatch_warning        out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_status_process_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to delete a Status Processing Rule (SPR) as of
 * the effective date.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A status processing rule must exist.
 *
 * <p><b>Post Success</b><br>
 * The status processing rule will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the status
 * processing rule is not deleted.
 *
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
 * @param p_status_processing_rule_id Id of the status processing rule being
 * deleted.
 * @param p_object_version_number Pass in the current version number of the
 * status processing rule to be deleted. When the API completes if p_validate
 * is false, will be set to the new version number of the deleted status
 * processing rule. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted status processing rule row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted status processing rule row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @rep:displayname Delete Status Process Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_status_process_rule
  (p_validate                       in    BOOLEAN  DEFAULT FALSE
  ,p_effective_date                 in    date
  ,p_datetrack_mode                 in    varchar2
  ,p_status_processing_rule_id      in    number
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_effective_start_date              OUT NOCOPY DATE
  ,p_effective_end_date                OUT NOCOPY DATE);
--
END pay_status_processing_rule_api;

 

/
