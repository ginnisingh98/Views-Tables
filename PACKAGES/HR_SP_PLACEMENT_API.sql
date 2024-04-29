--------------------------------------------------------
--  DDL for Package HR_SP_PLACEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SP_PLACEMENT_API" AUTHID CURRENT_USER as
/* $Header: pesppapi.pkh 120.3 2006/05/04 03:44:57 snukala noship $ */
/*#
 * This package contains APIs that create and maintain the grade step
 * information for an employee's assignment.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Grade Step Placement
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_spp >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API puts a grade step onto an employee assignment.
 *
 * A grade step placement holds information about which step the 'Increment
 * Progression Points' process should put onto the assignment the next time you
 * run it. An employee assignment can be linked to only one grade step at any
 * point in time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An employee assignment and a grade scale with valid steps must all exist on
 * the effective date before a grade step placement can be created.
 *
 * <p><b>Post Success</b><br>
 * A grade step placement will be created.
 *
 * <p><b>Post Failure</b><br>
 * A grade step placement will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_business_group_id Uniquely identifies the business group in which
 * the grade step placement takes place. Must match the business group of the
 * employee assignment.
 * @param p_assignment_id Uniquely identifies the assignment for which the
 * grade step placement should be created. Assignment must be of type
 * 'Employee'.
 * @param p_step_id Uniquely identifies the grade step to place on the employee
 * assignment.
 * @param p_auto_increment_flag Indicates whether the 'Increment Progression
 * Points' process should change the grade step placement the next time you run
 * it. Valid values are 'Y' or 'N'.
 * @param p_reason The reason you put this grade step onto the employee
 * assignment.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_increment_number The number of grade steps the employee assignment
 * should move up the grade scale the next time you run the 'Increment
 * Progression Points' process. This value affects the process only if you set
 * the p_auto_increment_flag to 'Y'.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_placement_id If p_validate is false, uniquely identifies the grade
 * step placement created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade step placement. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created grade step placement. If
 * p_validate is true, then set to null
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created grade step placement. If p_validate is
 * true, then set to null.
 * @param p_replace_future_spp If there are any future placements existing
 * then set this parameter to true, otherwise set to false.
 * @rep:displayname Create Grade Step Placement
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_spp
  (p_validate			   in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in	  number
  ,p_assignment_id		   in	  number
  ,p_step_id			   in     number
  ,p_auto_increment_flag	   in	  varchar2 default 'N'
--  ,p_parent_spine_id		   in	  number
  ,p_reason			   in	  varchar2 default null
  ,p_request_id			   in	  number default null
  ,p_program_application_id	   in	  number default null
  ,p_program_id			   in	  number default null
  ,p_program_update_date    	   in	  date default null
  ,p_increment_number		   in	  number default null
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
  ,p_information_category          in     varchar2 default null
  ,p_placement_id		      out nocopy number
  ,p_object_version_number	      out nocopy number
  ,p_effective_start_date	      out nocopy date
  ,p_effective_end_date		      out nocopy date
  ,p_replace_future_spp            in     boolean default false --bug 2977842.
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_spp >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_spp
  (p_validate			   in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in	  number
  ,p_assignment_id		   in	  number
  ,p_step_id			   in     number
  ,p_auto_increment_flag	   in	  varchar2 default 'N'
--  ,p_parent_spine_id		   in	  number
  ,p_reason			   in	  varchar2 default null
  ,p_request_id			   in	  number default null
  ,p_program_application_id	   in	  number default null
  ,p_program_id			   in	  number default null
  ,p_program_update_date    	   in	  date default null
  ,p_increment_number		   in	  number default null
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
  ,p_information_category          in     varchar2 default null
  ,p_placement_id		      out nocopy number
  ,p_object_version_number	      out nocopy number
  ,p_effective_start_date	      out nocopy date
  ,p_effective_end_date		      out nocopy date
  ,p_replace_future_spp            in     boolean default false --bug 2977842.
  ,p_gsp_post_process_warning         out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_spp >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the employee assignment's grade step information.
 *
 * A grade step placement holds information about which step the 'Increment
 * Progression Points' process should put onto the assignment the next time you
 * run it. An employee assignment can be linked to only one grade step at any
 * point in time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A grade step placement must exist on the effective date of the update.
 *
 * <p><b>Post Success</b><br>
 * The grade step placement will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The grade step placement will not be updated and an error will be raised.
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
 * @param p_placement_id Uniquely identifies the grade step placement record to
 * be updated.
 * @param p_object_version_number Pass in the current version number of the
 * grade step placement to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated grade step
 * placement. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_step_id Uniquely identifies the grade step to place on the employee
 * assignment.
 * @param p_auto_increment_flag Indicates whether the 'Increment Progression
 * Points' process should change the grade step placement the next time you run
 * it. Valid values are 'Y' or 'N'.
 * @param p_reason The reason you put this grade step onto the employee
 * assignment.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_increment_number The number of grade steps the employee assignment
 * should move up the grade scale the next time you run the 'Increment
 * Progression Points' process. This value affects the process only if you set
 * the p_auto_increment_flag to 'Y'.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated grade step placement row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated grade step placement row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Grade Step Placement
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_spp
  (p_validate			   in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode		   in     varchar2 default hr_api.g_update
  ,p_placement_id                  in     number
  ,p_object_version_number         in out nocopy number
--  ,p_business_group_id		   in	  number   default hr_api.g_number
--  ,p_assignment_id		   in	  number   default hr_api.g_number
  ,p_step_id			   in     number   default hr_api.g_number
  ,p_auto_increment_flag           in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_increment_number              in     number   default hr_api.g_number
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          in out nocopy date
  ,p_effective_end_date		   in out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_spp >----------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_spp
  (p_validate			   in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode		   in     varchar2 default hr_api.g_update
  ,p_placement_id                  in     number
  ,p_object_version_number         in out nocopy number
--  ,p_business_group_id		   in	  number   default hr_api.g_number
--  ,p_assignment_id		   in	  number   default hr_api.g_number
  ,p_step_id			   in     number   default hr_api.g_number
  ,p_auto_increment_flag           in     varchar2 default hr_api.g_varchar2
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_increment_number              in     number   default hr_api.g_number
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date          in out nocopy date
  ,p_effective_end_date		   in out nocopy date
  ,p_gsp_post_process_warning         out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< delete_spp >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes a grade step from an employee assignment.
 *
 * A grade step placement holds information about which step the 'Increment
 * Progression Points' process should put onto the assignment the next time you
 * run it. An employee assignment can be linked to only one grade step at any
 * point in time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade step placement record must exist on the date it is to be deleted.
 *
 * <p><b>Post Success</b><br>
 * The grade step placement will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The grade step placement will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_placement_id Uniquely identifies the grade step placement record to
 * be deleted.
 * @param p_object_version_number Current version number of the grade step
 * placement to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted grade step placement row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted grade step placement row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @rep:displayname Delete Grade Step Placement
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_spp
  (p_validate			   in     boolean  default false
  ,p_effective_date		   in	  date
  ,p_datetrack_mode		   in	  varchar2 default hr_api.g_delete
  ,p_placement_id                  in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date		      out nocopy date
  ,p_effective_end_date		      out nocopy date
  );
  --
end hr_sp_placement_api;

 

/
