--------------------------------------------------------
--  DDL for Package HR_NL_ABSENCE_ACTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ABSENCE_ACTION_API" AUTHID CURRENT_USER as
/* $Header: penaaapi.pkh 120.1 2005/10/02 02:18:47 aroussel $ */
/*#
 * This package contains Dutch Absence Action APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Absence Action for Netherlands
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_absence_action >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Absence Action.
 *
 * Create Absence Actions against an absence for a person in the Netherlands.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and absence must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * When the Absence Action is valid, the API sets the following
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an Absence Action and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_attendance_id Absence for which an action is to be created.
 * @param p_expected_date Expected date when the action is to be performed.
 * @param p_description Description of the action.
 * @param p_actual_start_date Actual start date of the action.
 * @param p_actual_end_date Actual end date of the action.
 * @param p_holder Holder (owner) of the action.
 * @param p_comments Comments on work done for the action.
 * @param p_document_file_name Name of the document associated with the action.
 * @param p_absence_action_id If p_validate is false, then this uniquely
 * identifies the absence action created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created absence action. If p_validate is true, then
 * the value will be null.
 * @param p_enabled Indication of whether action is enabled.
 * @rep:displayname Create Absence Action for the Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ABSENCE_ACTION
  (p_validate                      in     boolean  default false
  ,p_absence_attendance_id         in     number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date     default null
  ,p_actual_end_date               in     date     default null
  ,p_holder                        in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_document_file_name            in     varchar2 default null
  ,p_absence_action_id             out    nocopy  number
  ,p_object_version_number         out    nocopy  number
  ,p_enabled                       in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_absence_action >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Absence Action.
 *
 * Update Absence Actions against an absence for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The absence and Absence Action, as identified by the in parameters
 * p_absence_attendance_id and p_absence_action_id and the in out parameter
 * p_object_version_number, must already exist.
 *
 * <p><b>Post Success</b><br>
 * When the Absence Action is valid, the API sets the following
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Absence Action and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_attendance_id Absence for which an action is to be updated.
 * @param p_absence_action_id Absence Action to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * absence action to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated absence action. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_expected_date Expected date when the action is to be performed.
 * @param p_description Description of the action.
 * @param p_actual_start_date Actual start date of the action.
 * @param p_actual_end_date Actual end date of the action.
 * @param p_holder Holder (owner) of the action.
 * @param p_comments Comments on work done for the action.
 * @param p_document_file_name Name of the document associated with the action.
 * @param p_enabled Indication of whether action is enabled.
 * @rep:displayname Update Absence Action for Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ABSENCE_ACTION
  (p_validate                      in     boolean  default false
  ,p_absence_attendance_id         in     number
  ,p_absence_action_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_expected_date                 in     date
  ,p_description                   in     varchar2
  ,p_actual_start_date             in     date     default hr_api.g_date
  ,p_actual_end_date               in     date     default hr_api.g_date
  ,p_holder                        in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_document_file_name            in     varchar2 default hr_api.g_varchar2
  ,p_enabled                       in     varchar2 default hr_Api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_absence_action >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Absence Action.
 *
 * Delete Absence Actions against an absence for a person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Absence Action as identified by the in parameter p_absence_action_id and
 * the in out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Absence Action is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Absence Action and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_absence_action_id Absence Action to be deleted.
 * @param p_object_version_number Current version number of the absence action
 * to be deleted.
 * @rep:displayname Delete Absence Action for Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ABSENCE_ACTION
  (p_validate                      in     boolean  default false
  ,p_absence_action_id             in     number
  ,p_object_version_number         in     number
  );
--
end HR_NL_ABSENCE_ACTION_api;

 

/
