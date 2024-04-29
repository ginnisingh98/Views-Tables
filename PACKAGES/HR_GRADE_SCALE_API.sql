--------------------------------------------------------
--  DDL for Package HR_GRADE_SCALE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_SCALE_API" AUTHID CURRENT_USER as
/* $Header: pepgsapi.pkh 120.1.12000000.1 2007/01/22 01:19:51 appldev noship $ */
/*#
 * This package contains APIs that maintain grade scales.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Grade Scale
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------< get_grade_scale_starting_step >---------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_grade_scale_starting_step
  (p_grade_spine_id                in NUMBER
  ,p_effective_date                in DATE)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |-------------------------< create_grade_scale >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Grade Scale.
 *
 * This API works as follows. a) If the value passed to the optional parameter
 * p_ceiling_point_id is null, then API creates a Grade Scale with null Ceiling
 * Step defined. b) If a valid point id is passed to parameter
 * p_ceiling_point_id, then API creates a Grade Step (Ceiling Step) along with
 * the Grade Scale. This Ceiling Step will be associated with the new Grade
 * Scale created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * When creating a grade scale in the schema grade and pay scale should exist.
 *
 * <p><b>Post Success</b><br>
 * A valid grade scale is created.
 *
 * <p><b>Post Failure</b><br>
 * The grade scale will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Determines for which business group the grade
 * sclae will be created in.
 * @param p_parent_spine_id Foreign key to PER_PARENT_SPINES
 * @param p_grade_id Foreign key to PER_GRADES
 * @param p_ceiling_point_id If a valid point id is passed. Then a grade step
 * (Ceiling Step) along with the grade scale is created. This ceiling step will
 * be associated with the new Grade Scale.Foreign key to PER_SPINAL_POINTS
 * @param p_starting_step This value is used to increment the sequence of the
 * grade steps and the default value is 1.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_ceiling_step_id The ceiling step associated with the new Grade
 * Scale is passed out.
 * @param p_grade_spine_id If p_validate is false, then this uniquely
 * identifies the grade scale created. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created grade scale. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created grade scale. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade scale. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Grade Scale
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
-- ---------------------------------------------------------------------------
procedure create_grade_scale
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_grade_id                       in     number
  ,p_ceiling_point_id               in     number   default null
  ,p_starting_step                  in     number   default 1
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_ceiling_step_id                   out nocopy number
  ,p_grade_spine_id                    out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
 ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_grade_scale >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates a Grade Scale.
 *
 * This API updates a grade scale as identified by the in parameter
 * p_grade_spine_id and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade scale as identified by the in parameter p_grade_spine_id and the
 * in out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The grade scale is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the grade scale and raises an error.
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
 * @param p_grade_spine_id Identifies the grade scale record to be modify.
 * @param p_object_version_number Pass in the current version number of the
 * grade scale to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated grade scale. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_business_group_id Business group to which the grade scale belongs.
 * @param p_parent_spine_id Foreign key to PER_PARENT_SPINES
 * @param p_grade_id Foreign key to PER_GRADES
 * @param p_ceiling_step_id Foreign key to PER_SPINAL_POINTS
 * @param p_starting_step This value is used to increment the sequence of the
 * grade steps and the default value is 1.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated grade scale row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated &lt;ENTITY&gt; row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Grade Scale
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
procedure update_grade_scale
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date     default hr_api.g_date
  ,p_datetrack_mode                 in     varchar2
  ,p_grade_spine_id                 in     number
  ,p_object_version_number          in out nocopy number
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_parent_spine_id                in     number   default hr_api.g_number
  ,p_grade_id                       in     number   default hr_api.g_number
  ,p_ceiling_step_id                in     number   default hr_api.g_number
  ,p_starting_step                  in     number   default hr_api.g_number
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ) ;
-- ----------------------------------------------------------------------------
-- |---------------------< delete_grade_scale >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Grade Scale.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade scale as identified by the in parameter p_grade_spine_id and the
 * in out parameter p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The grade scale is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the grade scale and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date API modifies a database table with DateTrack
 * features
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_grade_spine_id Identifies the grade scale record to be deleted.
 * @param p_object_version_number Current version number of the grade scale to
 * be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted &lt;ENTITY&gt; row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted &lt;ENTITY&gt; row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Grade Scale
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_grade_scale
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_grade_spine_id                in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );

--
end hr_grade_scale_api;
--

 

/
