--------------------------------------------------------
--  DDL for Package PAY_COST_ALLOCATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_COST_ALLOCATION_API" AUTHID CURRENT_USER as
/* $Header: pycalapi.pkh 120.2 2005/11/11 07:06:59 adkumar noship $ */
/*#
 * This package contains the Cost Allocation API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Cost Allocation
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cost_allocation >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new cost allocations.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Requires a valid assignment.
 *
 * <p><b>Post Success</b><br>
 * The cost allocation will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the cost allocation and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_proportion The proportion of costs allocated for this allocation.
 * (NB allocations should total 100 for each assignment)
 * @param p_business_group_id The cost allocations business group id
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_concat_segments The concatenated segment values 1..30.
 * @param p_request_id concurrent request id of the program that last updated
 * this row (foreign key to FND_CONCURRENT_REQUESTS.REQUEST_ID).
 * @param p_program_application_id application id of the program that last
 * updated this row (foreign key to FND_APPLICATION.APPLICATION_ID).
 * @param p_PROGRAM_ID application id of the program that last updated this
 * row (foreign key to FND_APPLICATION.APPLICATION_ID).
 * @param p_PROGRAM_UPDATE_DATE DATE  Concurrent Program who column -
 * date when a program last updated this row).
 * @param p_combination_name If p_validate is false, this uniquely identifies
 * the cost code combination created. If p_validate is set to true, this
 * parameter will be null.
 * @param p_cost_allocation_id If p_validate is false, this uniquely identifies
 * the cost allocation created. If p_validate is set to true, this parameter
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created cost allocation. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created cost allocation. If p_validate is true,
 * then set to null.
 * @param p_cost_allocation_keyflex_id If p_validate is false, this uniquely
 * identifies the Cost Allocation Keyflex created. If p_validate is set to
 * true, this parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created cost allocation. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Cost Allocation
 * @rep:category BUSINESS_ENTITY PAY_COST_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_proportion                    in     number
  ,p_business_group_id             in     number
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_combination_name                 out nocopy varchar2
  ,p_cost_allocation_id               out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_cost_allocation_keyflex_id    in out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cost_allocation >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates cost allocations.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The cost allocation should exists.
 *
 * <p><b>Post Success</b><br>
 * The cost allocation will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the cost allocation and raises an error.
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
 * @param p_cost_allocation_id The identifier of the cost allocation being
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * cost allocation to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated cost allocation.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_proportion The proportion of costs allocated for this allocation.
 * (NB allocations should total 100 for each assignment)
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_concat_segments The concatenated segment values 1..30.
 * @param p_request_id concurrent request id of the program that last updated
 * this row (foreign key to FND_CONCURRENT_REQUESTS.REQUEST_ID).
 * @param p_program_application_id application id of the program that last
 * updated this row (foreign key to FND_APPLICATION.APPLICATION_ID).
 * @param p_program_id application id of the program that last updated this
 * row (foreign key to FND_APPLICATION.APPLICATION_ID).
 * @param p_program_update_date date  Concurrent Program who column -
 * date when a program last updated this row).
 * @param p_combination_name If p_validate is false, this uniquely identifies
 * the cost code combination created. If p_validate is set to true, this
 * parameter will be null.
 * @param p_cost_allocation_keyflex_id If p_validate is false, this uniquely
 * identifies the Cost Allocation Keyflex updated. If p_validate is set to
 * true, this parameter will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated cost allocation row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated cost allocation row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Cost Allocation
 * @rep:category BUSINESS_ENTITY PAY_COST_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_proportion                    in     number   default hr_api.g_number
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number    default hr_api.g_number
  ,p_program_application_id        in     number    default hr_api.g_number
  ,p_program_id                    in     number    default hr_api.g_number
  ,p_program_update_date           in     date      default hr_api.g_date
  ,p_combination_name                 out nocopy varchar2
  ,p_cost_allocation_keyflex_id    in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cost_allocation >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes cost allocations.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The cost allocation should exists.
 *
 * <p><b>Post Success</b><br>
 * The cost allocation will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the cost allocation and raises an error.
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
 * @param p_cost_allocation_id The identifier of the cost allocation being
 * deleted.
 * @param p_object_version_number Pass in the current version number of the
 * cost allocation to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted cost allocation.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted cost allocation row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted cost allocation row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Cost Allocation
 * @rep:category BUSINESS_ENTITY PAY_COST_ALLOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_COST_ALLOCATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_cost_allocation_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
end PAY_COST_ALLOCATION_API;

 

/
