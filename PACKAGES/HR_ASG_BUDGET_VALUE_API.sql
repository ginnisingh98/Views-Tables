--------------------------------------------------------
--  DDL for Package HR_ASG_BUDGET_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASG_BUDGET_VALUE_API" AUTHID CURRENT_USER as
/* $Header: peabvapi.pkh 120.1 2005/10/02 02:09:07 aroussel $ */
/*#
 * This package maintains assignment budget values.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment Budget Value
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_asg_budget_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an assignment budget value.
 *
 * An assignment budget value gives information on how much that assignment is
 * contributing to your enterprise. It has an associated unit; example values
 * are 'Full Time Equivalent', 'Headcount', 'Percentage Full Time'. Assignment
 * budget values are used primarily in reporting.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assignment must exist on the effective date
 *
 * <p><b>Post Success</b><br>
 * An assignment budget value will be created.
 *
 * <p><b>Post Failure</b><br>
 * An assignment budget value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Uniquely identifies the business group to create
 * the assignment budget value within. Must match the business group of the
 * parent assignment.
 * @param p_assignment_id Uniquely identifies the assignment with which the new
 * assignment budget value will be associated.
 * @param p_unit The unit of the budget value. Valid values are defined by the
 * lookup type 'BUDGET_MEASUREMENT_TYPE'.
 * @param p_value The actual number of units that this assignment budget value
 * represents.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_last_update_date Not used
 * @param p_last_updated_by Not used
 * @param p_last_update_login Not used
 * @param p_created_by Not used
 * @param p_creation_date Not used
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment budget value. If p_validate is
 * true, then the value will be null.
 * @param p_assignment_budget_value_id If p_validate is false, then this
 * uniquely identifies the created assignment budget value. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Assignment Budget Value
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ASG_BUDGET_VALUE
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_unit                          in     varchar2
  ,p_value                         in     number
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_last_update_date              in     date     default null
  ,p_last_updated_by               in     number   default null
  ,p_last_update_login             in     number   default null
  ,p_created_by                    in     number   default null
  ,p_creation_date                 in     date     default null
  ,p_object_version_number         out nocopy number
  ,p_assignment_budget_value_id    out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_asg_budget_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an assignment budget value.
 *
 * An assignment budget value gives information on how much that assignment is
 * contributing to your enterprise. It has an associated unit; example values
 * are 'Full Time Equivalent', 'Headcount', 'Percentage Full Time'. Assignment
 * budget values are used primarily in reporting.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An assignment budget value must exist
 *
 * <p><b>Post Success</b><br>
 * An assignment budget value will be updated.
 *
 * <p><b>Post Failure</b><br>
 * An assignment budget value will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_budget_value_id Uniquely identifies the assignment
 * budget value to be updated.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_business_group_id Uniquely identifies the business group to update
 * the assignment budget value within. Must match the business group of the
 * parent assignment.
 * @param p_unit The unit of the budget value. Valid values are defined by the
 * lookup type 'BUDGET_MEASUREMENT_TYPE'.
 * @param p_value The actual number of units that this assignment budget value
 * represents.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_last_update_date Not used
 * @param p_last_updated_by Not used
 * @param p_last_update_login Not used
 * @param p_created_by Not used
 * @param p_creation_date Not used
 * @param p_object_version_number Pass in the current version number of the
 * assignment budget value to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated assignment
 * budget value. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Assignment Budget Value
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ASG_BUDGET_VALUE
  (p_validate                      in     boolean  default false
  ,p_assignment_budget_value_id    in     number
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_unit                          in     varchar2 default hr_api.g_varchar2
  ,p_value                         in     number   default hr_api.g_number
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_last_update_date              in     date     default hr_api.g_date
  ,p_last_updated_by               in     number   default hr_api.g_number
  ,p_last_update_login             in     number   default hr_api.g_number
  ,p_created_by                    in     number   default hr_api.g_number
  ,p_creation_date                 in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_asg_budget_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Deletes an assignment budget value.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An assignment budget value must exist
 *
 * <p><b>Post Success</b><br>
 * An assignment budget value will be deleted
 *
 * <p><b>Post Failure</b><br>
 * An assignment budget value will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_budget_value_id Uniquely identifies the assignment
 * budget value to be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_object_version_number Current version number of the assignment
 * budget value to be deleted.
 * @rep:displayname Delete Assignment Budget Value
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ASG_BUDGET_VALUE
  (p_validate                      in     boolean  default false
  ,p_assignment_budget_value_id    in     number
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_object_version_number         in out nocopy number
  );
--
end hr_asg_budget_value_api;

 

/
