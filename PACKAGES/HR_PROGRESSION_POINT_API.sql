--------------------------------------------------------
--  DDL for Package HR_PROGRESSION_POINT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROGRESSION_POINT_API" AUTHID CURRENT_USER as
/* $Header: pepspapi.pkh 120.1 2005/10/02 02:22:39 aroussel $ */
/*#
 * This package contains APIs that maintain points within pay scales.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Scale Point
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_progression_point >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new point within a pay scale.
 *
 * You can use any name for the point. The sequence of the points indicates how
 * an employee will progress up the pay scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A pay scale must exist before a point can be created within it.
 *
 * <p><b>Post Success</b><br>
 * A point will be created within the pay scale.
 *
 * <p><b>Post Failure</b><br>
 * A point will not be created within the pay scale and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the pay scale point is created. Must match the business group of the parent
 * pay scale.
 * @param p_parent_spine_id Uniquely identifies the pay scale in which the
 * point will be created.
 * @param p_sequence The incremental order of this point within the pay scale.
 * @param p_spinal_point The name or number of the progression point.
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
 * @param p_spinal_point_id If p_validate is false, uniquely identifies the pay
 * scale point created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created pay scale point. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Pay Scale Point
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_progression_point
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date     default null
  ,p_business_group_id              in     number
  ,p_parent_spine_id                in     number
  ,p_sequence                       in     number
  ,p_spinal_point                   in     varchar2
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
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
  ,p_spinal_point_id                out nocopy number
  ,p_object_version_number          out nocopy number
 ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_progression_point >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a point within a pay scale.
 *
 * You can use any name for the point. The sequence of the points indicates how
 * an employee will progress up the pay scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The point must exist in the pay scale on the date of the update.
 *
 * <p><b>Post Success</b><br>
 * A point will be updated.
 *
 * <p><b>Post Failure</b><br>
 * A point will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_spinal_point_id Uniquely identifies the pay scale point to be
 * updated.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the pay scale point is created. Must match the business group of the parent
 * pay scale, and you cannot update it.
 * @param p_parent_spine_id Uniquely identifies the pay scale in which the
 * point will be created. You cannot update it.
 * @param p_sequence The incremental order of this point within the pay scale.
 * @param p_spinal_point The name or number of the progression point
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
 * @param p_object_version_number Pass in the current version number of the pay
 * scale point to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated pay scale point. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Pay Scale Point
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_progression_point
  (p_validate                       in     boolean  default false
  ,p_spinal_point_id                in     number
  ,p_effective_date                 in     date     default hr_api.g_date
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_parent_spine_id                in     number   default hr_api.g_number
  ,p_sequence                       in     number   default hr_api.g_number
  ,p_spinal_point                   in     varchar2 default hr_api.g_varchar2
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
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
  ,p_object_version_number          in out nocopy number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_progression_point >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a point from a pay scale.
 *
 * You can use any name for the point. The sequence of the points indicates how
 * an employee will progress up the pay scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The point must exist in the pay scale on the date of the delete. You cannot
 * delete the pay scale point if any grade steps are associated with it.
 *
 * <p><b>Post Success</b><br>
 * The point will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The point will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_spinal_point_id Uniquely identifies the pay scale point to be
 * deleted.
 * @param p_object_version_number Current version number of the pay scale point
 * to be deleted.
 * @rep:displayname Delete Pay Scale Point
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_progression_point
  (p_validate                      in     boolean  default false
  ,p_spinal_point_id               in     number
  ,p_object_version_number         in     number
  );

--
end hr_progression_point_api;
--

 

/
