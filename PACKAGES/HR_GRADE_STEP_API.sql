--------------------------------------------------------
--  DDL for Package HR_GRADE_STEP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_STEP_API" AUTHID CURRENT_USER as
/* $Header: pespsapi.pkh 120.3.12000000.1 2007/01/22 04:39:16 appldev noship $ */
/*#
 * This package contains APIs that maintain grade steps.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Grade Step
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_grade_step >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new grade step for a given grade scale.
 *
 * Each grade step within the grade scale is linked to a point in the
 * associated pay scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A grade scale must exist before a grade step can be created within it. A
 * point must exist in the associated pay scale.
 *
 * <p><b>Post Success</b><br>
 * A grade step will be created.
 *
 * <p><b>Post Failure</b><br>
 * A grade step will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_business_group_id The business group that the grade step is created
 * in. Must be the same as the business group of the parent grade scale.
 * @param p_spinal_point_id Uniquely identifies the pay scale point the grade
 * step is linked to. The pay scale point must be within the pay scale
 * associated with the parent grade scale.
 * @param p_grade_spine_id Uniquely identifies the grade scale in which the
 * grade step is created.
 * @param p_sequence Must be the same as the sequence of the pay scale point.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_step_id If p_validate is false, uniquely identifies the grade step
 * created. If p_validate is true, set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created grade step. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created grade step. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade step. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Grade Step
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_grade_step
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_spinal_point_id               in     number
  ,p_grade_spine_id                in     number
  ,p_sequence                      in     number
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_information21                 in     varchar2 default null
  ,p_information22                 in     varchar2 default null
  ,p_information23                 in     varchar2 default null
  ,p_information24                 in     varchar2 default null
  ,p_information25                 in     varchar2 default null
  ,p_information26                 in     varchar2 default null
  ,p_information27                 in     varchar2 default null
  ,p_information28                 in     varchar2 default null
  ,p_information29                 in     varchar2 default null
  ,p_information30                 in     varchar2 default null
  ,p_step_id                       in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number            out nocopy number
 ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_grade_step >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a grade step for a given grade scale.
 *
 * Each grade step within the grade scale is linked to a point in the
 * associated pay scale. Only flexfield information can be updated for an
 * existing grade step.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade step must exist on the date of the update.
 *
 * <p><b>Post Success</b><br>
 * The grade step will be updated
 *
 * <p><b>Post Failure</b><br>
 * The grade step will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode ndicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_step_id Uniquely identifies the grade step to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * grade step to be updated. When the process completes if p_validate is false,
 * will be set to the new version number of the updated grade step. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_business_group_id The business group in which the grade step
 * exists. Must be the same as the business group of the parent grade scale. It
 * cannot be updated.
 * @param p_spinal_point_id Uniquely identifies which pay scale point the grade
 * step is linked to. The pay scale point must be within the pay scale
 * associated with the parent grade scale. It cannot be updated
 * @param p_grade_spine_id Uniquely identifies the grade scale in which the
 * grade step is created. It cannot be updated.
 * @param p_sequence Must be the same as the sequence of the pay scale point.
 * It cannot be updated
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated grade step row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated grade step row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Grade Step
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_grade_step
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_spinal_point_id               in     number   default hr_api.g_number
  ,p_grade_spine_id                in     number   default hr_api.g_number
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_grade_step >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a grade step for a given grade scale.
 *
 * Each grade step within the grade scale is linked to a point in the
 * associated pay scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade step must exist on the date it is to be deleted. The grade step
 * cannot be deleted if any employees are assigned to that step.
 *
 * <p><b>Post Success</b><br>
 * The grade step will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The grade step will not be deleted and an error will be raised.
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
 * @param p_step_id Uniquely identifies the grade step to be deleted.
 * @param p_object_version_number Current version number of the grade step to
 * be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted grade step row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted grade step row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete Grade Step
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_grade_step
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );

-- ----------------------------------------------------------------------------
-- |----------------------< delete_grade_step >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes grade scale record
--
-- Prerequisites:
--   The grade scale as identified by the in parameter p_step_id
--   and the in out parameter p_object_version_number must already exist.
--   There must be no records relating to the step_id in the
--   reference tables.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the absence record is created.
--   p_effective_date               Yes  date     Application effective date.
--   p_datetrack_mode               Yes  varchar2 Delete mode.
--   p_step_id                      Yes  number   Primary key of the grade step
--   p_object_version_number        Yes  number   If p_validate is false, set to
--                                                the version number of this
--                                                absence. If p_validate is true
--                                                  set to null.
--  P_called_from_del_grd_scale    yes    boolean  If false then performs the
--						   the ceiling step validations.
-- Post Success:
--
--   The grade scale is deleted.
--
--   Name
--   p_object_version_number        number   If p_validate is false then
--                                           new version number is returned
--                                           depending upon datetrack mode.
--                                           If p_validate is false true then
--                                           version number passed in is
--                                           returned.
--   p_effective_start_date         date     Effective start date of the
--                                           grade scale changes.
--   p_effective_end_date           date     Effective end date of the
--                                           grade scale changes.
--
-- Post Failure:
--   The API does not delete grade scale action and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure delete_grade_step
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_step_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_called_from_del_grd_scale       in   boolean -- bug 4096238
  );

--
end hr_grade_step_api;
--

 

/
