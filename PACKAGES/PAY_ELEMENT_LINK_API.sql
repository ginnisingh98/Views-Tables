--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_LINK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_LINK_API" AUTHID CURRENT_USER as
/* $Header: pypelapi.pkh 120.3.12010000.1 2008/07/27 23:21:44 appldev ship $ */
/*#
 * This package contains element link APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Element Link
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API will create an element link and element link input values.
 *
 * The main purpose of the element link is to describe what values are required
 * to be eligible for an element type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type should exist.
 *
 * <p><b>Post Success</b><br>
 * The element link and element link input values will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The element link and element link input values will not have been created
 * and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_business_group_id The business group for which the element link
 * will be created.
 * @param p_costable_type The costable type for the link. Valid values are
 * defined by 'COSTABLE_TYPE' lookup type.
 * @param p_payroll_id Set this to a valid payroll identifier to include the
 * payroll in the eligibility criteria.
 * @param p_job_id Set this to a valid job identifier to include the job in the
 * eligibility criteria.
 * @param p_position_id Set this to a valid position identifier to include the
 * position in the eligibility criteria.
 * @param p_people_group_id Set this to a valid people group identifier to
 * include the people group in the eligibility criteria.
 * @param p_cost_allocation_keyflex_id Set this to a valid cost allocation key
 * flexfield identifier to include the cost allocation key flexfield in the
 * eligibility criteria.
 * @param p_organization_id Set this to a valid organization identifier to
 * include the organization in the eligibility criteria.
 * @param p_location_id Set this to a valid location identifier to include the
 * location in the eligibility criteria.
 * @param p_grade_id Set this to a valid grade identifier to include the grade
 * in the eligibility criteria.
 * @param p_balancing_keyflex_id The balancing key flexfield identifier for the
 * link.
 * @param p_element_set_id {@rep:casecolumn PAY_ELEMENT_SETS.ELEMENT_SET_ID}
 * @param p_pay_basis_id Set this to a valid pay basis identifier to include
 * the salary basis in the eligibility criteria.
 * @param p_link_to_all_payrolls_flag Specifies whether any payroll will be
 * eligible for the element type. Valid values are defined by the 'YES_NO'
 * lookup type.
 * @param p_standard_link_flag Specifies whether the element link will be
 * standard. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_transfer_to_gl_flag Specifies whether the costing information is to
 * be transferred to GL. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_comments Element link comment text.
 * @param p_employment_category Set this to a valid employment category to
 * include the employment category in the eligibility criteria. Valid values
 * are defined by the 'EMP_CAT' lookup type.
 * @param p_qualifying_age Age required to qualify for the element link.
 * @param p_qualifying_length_of_service Length of service required to qualify
 * for the element link.
 * @param p_qualifying_units The units associated with the qualifying criteria.
 * Valid values are defined by 'QUALIFYING' lookup type.
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
 * @param p_cost_segment1 Costing key flexfield segment.
 * @param p_cost_segment2 Costing key flexfield segment.
 * @param p_cost_segment3 Costing key flexfield segment.
 * @param p_cost_segment4 Costing key flexfield segment.
 * @param p_cost_segment5 Costing key flexfield segment.
 * @param p_cost_segment6 Costing key flexfield segment.
 * @param p_cost_segment7 Costing key flexfield segment.
 * @param p_cost_segment8 Costing key flexfield segment.
 * @param p_cost_segment9 Costing key flexfield segment.
 * @param p_cost_segment10 Costing key flexfield segment.
 * @param p_cost_segment11 Costing key flexfield segment.
 * @param p_cost_segment12 Costing key flexfield segment.
 * @param p_cost_segment13 Costing key flexfield segment.
 * @param p_cost_segment14 Costing key flexfield segment.
 * @param p_cost_segment15 Costing key flexfield segment.
 * @param p_cost_segment16 Costing key flexfield segment.
 * @param p_cost_segment17 Costing key flexfield segment.
 * @param p_cost_segment18 Costing key flexfield segment.
 * @param p_cost_segment19 Costing key flexfield segment.
 * @param p_cost_segment20 Costing key flexfield segment.
 * @param p_cost_segment21 Costing key flexfield segment.
 * @param p_cost_segment22 Costing key flexfield segment.
 * @param p_cost_segment23 Costing key flexfield segment.
 * @param p_cost_segment24 Costing key flexfield segment.
 * @param p_cost_segment25 Costing key flexfield segment.
 * @param p_cost_segment26 Costing key flexfield segment.
 * @param p_cost_segment27 Costing key flexfield segment.
 * @param p_cost_segment28 Costing key flexfield segment.
 * @param p_cost_segment29 Costing key flexfield segment.
 * @param p_cost_segment30 Costing key flexfield segment.
 * @param p_balance_segment1 Balancing key flexfield segment.
 * @param p_balance_segment2 Balancing key flexfield segment.
 * @param p_balance_segment3 Balancing key flexfield segment.
 * @param p_balance_segment4 Balancing key flexfield segment.
 * @param p_balance_segment5 Balancing key flexfield segment.
 * @param p_balance_segment6 Balancing key flexfield segment.
 * @param p_balance_segment7 Balancing key flexfield segment.
 * @param p_balance_segment8 Balancing key flexfield segment.
 * @param p_balance_segment9 Balancing key flexfield segment.
 * @param p_balance_segment10 Balancing key flexfield segment.
 * @param p_balance_segment11 Balancing key flexfield segment.
 * @param p_balance_segment12 Balancing key flexfield segment.
 * @param p_balance_segment13 Balancing key flexfield segment.
 * @param p_balance_segment14 Balancing key flexfield segment.
 * @param p_balance_segment15 Balancing key flexfield segment.
 * @param p_balance_segment16 Balancing key flexfield segment.
 * @param p_balance_segment17 Balancing key flexfield segment.
 * @param p_balance_segment18 Balancing key flexfield segment.
 * @param p_balance_segment19 Balancing key flexfield segment.
 * @param p_balance_segment20 Balancing key flexfield segment.
 * @param p_balance_segment21 Balancing key flexfield segment.
 * @param p_balance_segment22 Balancing key flexfield segment.
 * @param p_balance_segment23 Balancing key flexfield segment.
 * @param p_balance_segment24 Balancing key flexfield segment.
 * @param p_balance_segment25 Balancing key flexfield segment.
 * @param p_balance_segment26 Balancing key flexfield segment.
 * @param p_balance_segment27 Balancing key flexfield segment.
 * @param p_balance_segment28 Balancing key flexfield segment.
 * @param p_balance_segment29 Balancing key flexfield segment.
 * @param p_balance_segment30 Balancing key flexfield segment.
 * @param p_cost_concat_segments Concatenated costing flexfield values.
 * @param p_balance_concat_segments Concatenated balancing flexfield values.
 * @param p_element_link_id If p_validate is false, this uniquely identifies
 * the element link created. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created element link comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element link. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created element link. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created element link. If p_validate is true, then
 * set to null.
 * @rep:displayname Create Element Link
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_LINK
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_element_link
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_element_type_id                 in     number
  ,p_business_group_id               in     number
  ,p_costable_type                   in     varchar2
  ,p_payroll_id                      in     number   default null
  ,p_job_id                          in     number   default null
  ,p_position_id                     in     number   default null
  ,p_people_group_id                 in     number   default null
  ,p_cost_allocation_keyflex_id      in     number   default null
  ,p_organization_id                 in     number   default null
  ,p_location_id                     in     number   default null
  ,p_grade_id                        in     number   default null
  ,p_balancing_keyflex_id            in     number   default null
  ,p_element_set_id                  in     number   default null
  ,p_pay_basis_id                    in     number   default null
  ,p_link_to_all_payrolls_flag       in     varchar2 default 'N'
  ,p_standard_link_flag              in     varchar2 default null
  ,p_transfer_to_gl_flag             in     varchar2 default 'N'
  ,p_comments                        in     varchar2 default null
  ,p_employment_category             in     varchar2 default null
  ,p_qualifying_age                  in     number   default null
  ,p_qualifying_length_of_service    in     number   default null
  ,p_qualifying_units                in     varchar2 default null
  ,p_attribute_category              in     varchar2 default null
  ,p_attribute1                      in     varchar2 default null
  ,p_attribute2                      in     varchar2 default null
  ,p_attribute3                      in     varchar2 default null
  ,p_attribute4                      in     varchar2 default null
  ,p_attribute5                      in     varchar2 default null
  ,p_attribute6                      in     varchar2 default null
  ,p_attribute7                      in     varchar2 default null
  ,p_attribute8                      in     varchar2 default null
  ,p_attribute9                      in     varchar2 default null
  ,p_attribute10                     in     varchar2 default null
  ,p_attribute11                     in     varchar2 default null
  ,p_attribute12                     in     varchar2 default null
  ,p_attribute13                     in     varchar2 default null
  ,p_attribute14                     in     varchar2 default null
  ,p_attribute15                     in     varchar2 default null
  ,p_attribute16                     in     varchar2 default null
  ,p_attribute17                     in     varchar2 default null
  ,p_attribute18                     in     varchar2 default null
  ,p_attribute19                     in     varchar2 default null
  ,p_attribute20                     in     varchar2 default null
  ,p_cost_segment1                   in     varchar2 default null
  ,p_cost_segment2                   in     varchar2 default null
  ,p_cost_segment3                   in     varchar2 default null
  ,p_cost_segment4                   in     varchar2 default null
  ,p_cost_segment5                   in     varchar2 default null
  ,p_cost_segment6                   in     varchar2 default null
  ,p_cost_segment7                   in     varchar2 default null
  ,p_cost_segment8                   in     varchar2 default null
  ,p_cost_segment9                   in     varchar2 default null
  ,p_cost_segment10                  in     varchar2 default null
  ,p_cost_segment11                  in     varchar2 default null
  ,p_cost_segment12                  in     varchar2 default null
  ,p_cost_segment13                  in     varchar2 default null
  ,p_cost_segment14                  in     varchar2 default null
  ,p_cost_segment15                  in     varchar2 default null
  ,p_cost_segment16                  in     varchar2 default null
  ,p_cost_segment17                  in     varchar2 default null
  ,p_cost_segment18                  in     varchar2 default null
  ,p_cost_segment19                  in     varchar2 default null
  ,p_cost_segment20                  in     varchar2 default null
  ,p_cost_segment21                  in     varchar2 default null
  ,p_cost_segment22                  in     varchar2 default null
  ,p_cost_segment23                  in     varchar2 default null
  ,p_cost_segment24                  in     varchar2 default null
  ,p_cost_segment25                  in     varchar2 default null
  ,p_cost_segment26                  in     varchar2 default null
  ,p_cost_segment27                  in     varchar2 default null
  ,p_cost_segment28                  in     varchar2 default null
  ,p_cost_segment29                  in     varchar2 default null
  ,p_cost_segment30                  in     varchar2 default null
  ,p_balance_segment1                in     varchar2 default null
  ,p_balance_segment2                in     varchar2 default null
  ,p_balance_segment3                in     varchar2 default null
  ,p_balance_segment4                in     varchar2 default null
  ,p_balance_segment5                in     varchar2 default null
  ,p_balance_segment6                in     varchar2 default null
  ,p_balance_segment7                in     varchar2 default null
  ,p_balance_segment8                in     varchar2 default null
  ,p_balance_segment9                in     varchar2 default null
  ,p_balance_segment10               in     varchar2 default null
  ,p_balance_segment11               in     varchar2 default null
  ,p_balance_segment12               in     varchar2 default null
  ,p_balance_segment13               in     varchar2 default null
  ,p_balance_segment14               in     varchar2 default null
  ,p_balance_segment15               in     varchar2 default null
  ,p_balance_segment16               in     varchar2 default null
  ,p_balance_segment17               in     varchar2 default null
  ,p_balance_segment18               in     varchar2 default null
  ,p_balance_segment19               in     varchar2 default null
  ,p_balance_segment20               in     varchar2 default null
  ,p_balance_segment21               in     varchar2 default null
  ,p_balance_segment22               in     varchar2 default null
  ,p_balance_segment23               in     varchar2 default null
  ,p_balance_segment24               in     varchar2 default null
  ,p_balance_segment25               in     varchar2 default null
  ,p_balance_segment26               in     varchar2 default null
  ,p_balance_segment27               in     varchar2 default null
  ,p_balance_segment28               in     varchar2 default null
  ,p_balance_segment29               in     varchar2 default null
  ,p_balance_segment30               in     varchar2 default null
  ,p_cost_concat_segments            in     varchar2
  ,p_balance_concat_segments         in     varchar2
  ,p_element_link_id		     out nocopy    number
  ,p_comment_id			     out nocopy    number
  ,p_object_version_number	     out nocopy    number
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an element link.
 *
 * The main purpose of the element link is to describe what values are required
 * to be eligible for an element type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element link must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element link will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The element link will not have been updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_link_id The element link to be updated.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_costable_type The costable type for the link. Valid values are
 * defined by 'COSTABLE_TYPE' lookup type.
 * @param p_element_set_id {@rep:casecolumn PAY_ELEMENT_SETS.ELEMENT_SET_ID}
 * @param p_multiply_value_flag Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_standard_link_flag Specifies whether the element link will be
 * standard. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_transfer_to_gl_flag Specifies whether the costing information is to
 * be transferred to GL. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_comments Comment
 * @param p_comment_id {@rep:casecolumn HR_COMMENTS.COMMENT_ID}
 * @param p_employment_category Obsolete parameter, do not use.
 * @param p_qualifying_age Age required to qualify for the element link.
 * @param p_qualifying_length_of_service Length of service required to qualify
 * for the element link.
 * @param p_qualifying_units The units associated with the qualifying criteria.
 * Valid values are defined by 'QUALIFYING' lookup type.
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
 * @param p_cost_segment1 Costing key flexfield segment.
 * @param p_cost_segment2 Costing key flexfield segment.
 * @param p_cost_segment3 Costing key flexfield segment.
 * @param p_cost_segment4 Costing key flexfield segment.
 * @param p_cost_segment5 Costing key flexfield segment.
 * @param p_cost_segment6 Costing key flexfield segment.
 * @param p_cost_segment7 Costing key flexfield segment.
 * @param p_cost_segment8 Costing key flexfield segment.
 * @param p_cost_segment9 Costing key flexfield segment.
 * @param p_cost_segment10 Costing key flexfield segment.
 * @param p_cost_segment11 Costing key flexfield segment.
 * @param p_cost_segment12 Costing key flexfield segment.
 * @param p_cost_segment13 Costing key flexfield segment.
 * @param p_cost_segment14 Costing key flexfield segment.
 * @param p_cost_segment15 Costing key flexfield segment.
 * @param p_cost_segment16 Costing key flexfield segment.
 * @param p_cost_segment17 Costing key flexfield segment.
 * @param p_cost_segment18 Costing key flexfield segment.
 * @param p_cost_segment19 Costing key flexfield segment.
 * @param p_cost_segment20 Costing key flexfield segment.
 * @param p_cost_segment21 Costing key flexfield segment.
 * @param p_cost_segment22 Costing key flexfield segment.
 * @param p_cost_segment23 Costing key flexfield segment.
 * @param p_cost_segment24 Costing key flexfield segment.
 * @param p_cost_segment25 Costing key flexfield segment.
 * @param p_cost_segment26 Costing key flexfield segment.
 * @param p_cost_segment27 Costing key flexfield segment.
 * @param p_cost_segment28 Costing key flexfield segment.
 * @param p_cost_segment29 Costing key flexfield segment.
 * @param p_cost_segment30 Costing key flexfield segment.
 * @param p_balance_segment1 Balancing key flexfield segment.
 * @param p_balance_segment2 Balancing key flexfield segment.
 * @param p_balance_segment3 Balancing key flexfield segment.
 * @param p_balance_segment4 Balancing key flexfield segment.
 * @param p_balance_segment5 Balancing key flexfield segment.
 * @param p_balance_segment6 Balancing key flexfield segment.
 * @param p_balance_segment7 Balancing key flexfield segment.
 * @param p_balance_segment8 Balancing key flexfield segment.
 * @param p_balance_segment9 Balancing key flexfield segment.
 * @param p_balance_segment10 Balancing key flexfield segment.
 * @param p_balance_segment11 Balancing key flexfield segment.
 * @param p_balance_segment12 Balancing key flexfield segment.
 * @param p_balance_segment13 Balancing key flexfield segment.
 * @param p_balance_segment14 Balancing key flexfield segment.
 * @param p_balance_segment15 Balancing key flexfield segment.
 * @param p_balance_segment16 Balancing key flexfield segment.
 * @param p_balance_segment17 Balancing key flexfield segment.
 * @param p_balance_segment18 Balancing key flexfield segment.
 * @param p_balance_segment19 Balancing key flexfield segment.
 * @param p_balance_segment20 Balancing key flexfield segment.
 * @param p_balance_segment21 Balancing key flexfield segment.
 * @param p_balance_segment22 Balancing key flexfield segment.
 * @param p_balance_segment23 Balancing key flexfield segment.
 * @param p_balance_segment24 Balancing key flexfield segment.
 * @param p_balance_segment25 Balancing key flexfield segment.
 * @param p_balance_segment26 Balancing key flexfield segment.
 * @param p_balance_segment27 Balancing key flexfield segment.
 * @param p_balance_segment28 Balancing key flexfield segment.
 * @param p_balance_segment29 Balancing key flexfield segment.
 * @param p_balance_segment30 Balancing key flexfield segment.
 * @param p_cost_concat_segments_in Concatenated costing flexfield values.
 * @param p_balance_concat_segments_in Concatenated balancing flexfield values.
 * @param p_object_version_number Pass in the current version number of the
 * element link to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated element link. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_cost_allocation_keyflex_id If p_validate is false, then this
 * identifies the cost allocation key flexfield. If p_validate is true, then
 * set to null.
 * @param p_balancing_keyflex_id If p_validate is false, then this identifies
 * the balancing key flexfield. If p_validate is true, then set to null.
 * @param p_cost_concat_segments_out If p_validate is false, set to
 * concatenated costing flexfield values. If p_validate is true, then set to
 * null.
 * @param p_balance_concat_segments_out If p_validate is false, set to
 * concatenated balancing flexfield values. If p_validate is true, then set to
 * null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated element link row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated element link row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Element Link
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_LINK
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_element_link
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_element_link_id		     in     number
  ,p_datetrack_mode		     in     varchar2
  ,p_costable_type                   in     varchar2 default hr_api.g_varchar2
  ,p_element_set_id                  in     number   default hr_api.g_number
  ,p_multiply_value_flag             in     varchar2 default hr_api.g_varchar2
  ,p_standard_link_flag              in     varchar2 default hr_api.g_varchar2
  ,p_transfer_to_gl_flag             in     varchar2 default hr_api.g_varchar2
  ,p_comments                        in     varchar2 default hr_api.g_varchar2
  ,p_comment_id                      in     varchar2 default hr_api.g_varchar2
  ,p_employment_category             in     varchar2 default hr_api.g_varchar2
  ,p_qualifying_age                  in     number   default hr_api.g_number
  ,p_qualifying_length_of_service    in     number   default hr_api.g_number
  ,p_qualifying_units                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category              in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                      in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                     in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment1                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment2                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment3                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment4                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment5                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment6                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment7                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment8                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment9                   in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment10                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment11                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment12                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment13                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment14                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment15                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment16                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment17                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment18                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment19                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment20                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment21                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment22                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment23                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment24                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment25                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment26                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment27                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment28                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment29                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_segment30                  in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment1                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment2                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment3                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment4                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment5                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment6                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment7                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment8                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment9                in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment10               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment11               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment12               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment13               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment14               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment15               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment16               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment17               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment18               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment19               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment20               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment21               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment22               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment23               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment24               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment25               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment26               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment27               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment28               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment29               in     varchar2 default hr_api.g_varchar2
  ,p_balance_segment30               in     varchar2 default hr_api.g_varchar2
  ,p_cost_concat_segments_in         in     varchar2 default hr_api.g_varchar2
  ,p_balance_concat_segments_in      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number	     in out nocopy number
  ,p_cost_allocation_keyflex_id      out nocopy    number
  ,p_balancing_keyflex_id            out nocopy    number
  ,p_cost_concat_segments_out        out nocopy    varchar2
  ,p_balance_concat_segments_out     out nocopy    varchar2
  ,p_effective_start_date	     out nocopy    date
  ,p_effective_end_date		     out nocopy    date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the element link.
 *
 * The role of this process is to perform a validated, date-effective delete of
 * an existing row in the pay_element_links_f table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element link must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element link and associated element link input values will have been
 * deleted.
 *
 * <p><b>Post Failure</b><br>
 * The element link and associated element link input values will not have been
 * deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_element_link_id The Element Link to be deleted.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_object_version_number Pass in the current version number of the
 * element link to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted element link. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted element link row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted element link row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_entries_warning Set to true if a warning has occurred during
 * delete.
 * @rep:displayname Delete Element Link
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_LINK
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_element_link
  (p_validate                    in        boolean  default false
  ,p_effective_date              in        date
  ,p_element_link_id             in        number
  ,p_datetrack_delete_mode       in        varchar2
  ,p_object_version_number       in out nocopy    number
  ,p_effective_start_date        out nocopy   	   date
  ,p_effective_end_date          out nocopy       date
  ,p_entries_warning		 out nocopy       boolean
);

end pay_element_link_api;

/
