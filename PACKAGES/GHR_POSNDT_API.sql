--------------------------------------------------------
--  DDL for Package GHR_POSNDT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POSNDT_API" AUTHID CURRENT_USER as
/* $Header: ghposndt.pkh 120.7 2006/10/26 09:08:46 utokachi noship $ */
/*#
 * This package contains the procedures for Creating Federal HR Position
 * records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position DateTrack
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a position, a specific occurrence of a job within an
 * organization.
 *
 * This wrapper for the US Federal HR Product creates positions for version 11i
 * and beyond. The Delete wrapper is not included at this time.
 * For further information about parameters, see peposapi.pkh.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization and job is passed to the API, and and at least three
 * segments for position definition must have a value. Federal HR Requires
 * Segment values for Position Title, Position Description Number and
 * Agency/Subelement Code. Segment Sequence Number is optional.
 *
 * <p><b>Post Success</b><br>
 * The position will be created successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the position and an error is raised.
 * @param p_position_id If p_validate is false, this parameter uniquely
 * identifies the position created. If p_validate is true, sets null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created position. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created position. If p_validate is true, then set
 * to null.
 * @param p_position_definition_id If p_validate is false, this parameter
 * uniquely identifies the combination of segments passed. If p_validate is
 * true, sets null.
 * @param p_name If p_validate is false, concatenate all segments. If
 * p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false will be set to the
 * version number of the created Position. If p_validate is true, then the
 * value will be null.
 * @param p_job_id The Job for the position.
 * @param p_organization_id The Organization to which the position belongs.
 * @param p_effective_date Determines when the DateTrack operation begins.
 * @param p_date_effective The date on which the position becomes active.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_availability_status_id Current Status of the Position. Refers to
 * PER_SHARED_TYPES.
 * @param p_business_group_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.BUSINESS_GROUP_ID}
 * @param p_entry_step_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_STEP_ID}
 * @param p_entry_grade_rule_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.ENTRY_GRADE_RULE_ID}
 * @param p_location_id {@rep:casecolumn HR_ALL_POSITIONS_F.LOCATION_ID}
 * @param p_pay_freq_payroll_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PAY_FREQ_PAYROLL_ID}
 * @param p_position_transaction_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.POSITION_TRANSACTION_ID}
 * @param p_prior_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PRIOR_POSITION_ID}
 * @param p_relief_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.RELIEF_POSITION_ID}
 * @param p_entry_grade_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_GRADE_ID}
 * @param p_successor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUCCESSOR_POSITION_ID}
 * @param p_supervisor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUPERVISOR_POSITION_ID}
 * @param p_amendment_date {@rep:casecolumn HR_ALL_POSITIONS_F.AMENDMENT_DATE}
 * @param p_amendment_recommendation {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_RECOMMENDATION}
 * @param p_amendment_ref_number {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_REF_NUMBER}
 * @param p_bargaining_unit_cd Identifies the bargaining unit. Valid values are
 * defined by 'BARGAINING_UNIT_CODE' lookup_type
 * @param p_comments Comment text.
 * @param p_current_job_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_JOB_PROP_END_DATE}
 * @param p_current_org_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_ORG_PROP_END_DATE}
 * @param p_avail_status_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AVAIL_STATUS_PROP_END_DATE}
 * @param p_date_end {@rep:casecolumn HR_ALL_POSITIONS_F.DATE_END}
 * @param p_earliest_hire_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.EARLIEST_HIRE_DATE}
 * @param p_fill_by_date {@rep:casecolumn HR_ALL_POSITIONS_F.FILL_BY_DATE}
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_fte {@rep:casecolumn HR_ALL_POSITIONS_F.FTE}
 * @param p_max_persons {@rep:casecolumn HR_ALL_POSITIONS_F.MAX_PERSONS}
 * @param p_overlap_period {@rep:casecolumn HR_ALL_POSITIONS_F.OVERLAP_PERIOD}
 * @param p_overlap_unit_cd Valid values are defined by 'QUALIFYING_UNITS'
 * lookup_type.
 * @param p_pay_term_end_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_pay_term_end_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_permanent_temporary_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_permit_recruitment_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_position_type Valid values are defined by 'POSITION_TYPE'
 * lookup_type
 * @param p_posting_description Posting description
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_unit_cd Valid values are defined by
 * 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Is a replacement required when person
 * assigned is absent. 'YES_NO'
 * @param p_review_flag Valid values are defined by 'YES_NO' lookup_type
 * @param p_seasonal_flag Valid values are defined by 'YES_NO' lookup_type
 * @param p_security_requirements Security Requirements
 * @param p_status Valid values are defined by 'POSITION_STATUS' lookup_type.
 * @param p_term_start_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_term_start_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_update_source_cd Valid values are defined by 'YES_NO' lookup_type
 * @param p_working_hours Number of normal working hours.
 * @param p_works_council_approval_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_work_period_type_cd Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_work_term_end_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_work_term_end_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_proposed_fte_for_layoff Proposed FTE for layoff
 * @param p_proposed_date_for_layoff Proposed date for layoff
 * @param p_pay_basis_id {@rep:casecolumn PER_PAY_BASES.PAY_BASIS_ID}
 * @param p_supervisor_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_segment1 Component of the Position Key Flexfield for the Position
 * @param p_segment2 Component of the Position Key Flexfield for the Position
 * @param p_segment3 Component of the Position Key Flexfield for the Position
 * @param p_segment4 Component of the Position Key Flexfield for the Position
 * @param p_segment5 Component of the Position Key Flexfield for the Position
 * @param p_segment6 Component of the Position Key Flexfield for the Position
 * @param p_segment7 Component of the Position Key Flexfield for the Position
 * @param p_segment8 Component of the Position Key Flexfield for the Position
 * @param p_segment9 Component of the Position Key Flexfield for the Position
 * @param p_segment10 Component of the Position Key Flexfield for the Position
 * @param p_segment11 Component of the Position Key Flexfield for the Position
 * @param p_segment12 Component of the Position Key Flexfield for the Position
 * @param p_segment13 Component of the Position Key Flexfield for the Position
 * @param p_segment14 Component of the Position Key Flexfield for the Position
 * @param p_segment15 Component of the Position Key Flexfield for the Position
 * @param p_segment16 Component of the Position Key Flexfield for the Position
 * @param p_segment17 Component of the Position Key Flexfield for the Position
 * @param p_segment18 Component of the Position Key Flexfield for the Position
 * @param p_segment19 Component of the Position Key Flexfield for the Position
 * @param p_segment20 Component of the Position Key Flexfield for the Position
 * @param p_segment21 Component of the Position Key Flexfield for the Position
 * @param p_segment22 Component of the Position Key Flexfield for the Position
 * @param p_segment23 Component of the Position Key Flexfield for the Position
 * @param p_segment24 Component of the Position Key Flexfield for the Position
 * @param p_segment25 Component of the Position Key Flexfield for the Position
 * @param p_segment26 Component of the Position Key Flexfield for the Position
 * @param p_segment27 Component of the Position Key Flexfield for the Position
 * @param p_segment28 Component of the Position Key Flexfield for the Position
 * @param p_segment29 Component of the Position Key Flexfield for the Position
 * @param p_segment30 Component of the Position Key Flexfield for the Position
 * @param p_concat_segments Varchar2 concatenated string of segment values
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @rep:displayname Create Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_position
  (p_position_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         out nocopy number
  ,p_name                           out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ) ;
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a position, a specific occurrence of a job within an
 * organization.
 *
 * This wrapper for the US Federal HR Product updates positions for version 11i
 * and beyond.
 * For further information about parameters, see peposapi.pkh.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization and job is passed to the API, and and at least three
 * segments for position definition must have a value. Federal HR Requires
 * Segment values for Position Title, Position Description Number and
 * Agency/Subelement Code. Segment Sequence Number is optional.
 *
 * <p><b>Post Success</b><br>
 * The position will be updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the position and an error is raised.
 * @param p_position_id If p_validate is false, this parameter uniquely
 * identifies the position updated. If p_validate is true, sets null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the updated position. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the updated position. If p_validate is true, then set
 * to null.
 * @param p_position_definition_id If p_validate is false, this parameter
 * uniquely identifies the combination of segments passed. If p_validate is
 * true, sets null.
 * @param p_name If p_validate is false, concatenate all segments. If
 * p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false will be set to the
 * version number of the updated Position. If p_validate is true, then the
 * value will be null.
 * @param p_effective_date Determines when the DateTrack operation begins.
 * @param p_date_effective The date on which the position becomes active.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_availability_status_id Current Status of the Position. Refers to
 * PER_SHARED_TYPES.
 * HR_ALL_POSITIONS_F.BUSINESS_GROUP_ID}
 * @param p_entry_step_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_STEP_ID}
 * @param p_entry_grade_rule_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.ENTRY_GRADE_RULE_ID}
 * @param p_location_id {@rep:casecolumn HR_ALL_POSITIONS_F.LOCATION_ID}
 * @param p_pay_freq_payroll_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PAY_FREQ_PAYROLL_ID}
 * @param p_position_transaction_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.POSITION_TRANSACTION_ID}
 * @param p_prior_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PRIOR_POSITION_ID}
 * @param p_relief_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.RELIEF_POSITION_ID}
 * @param p_entry_grade_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_GRADE_ID}
 * @param p_successor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUCCESSOR_POSITION_ID}
 * @param p_supervisor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUPERVISOR_POSITION_ID}
 * @param p_amendment_date {@rep:casecolumn HR_ALL_POSITIONS_F.AMENDMENT_DATE}
 * @param p_amendment_recommendation {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_RECOMMENDATION}
 * @param p_amendment_ref_number {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_REF_NUMBER}
 * @param p_bargaining_unit_cd Identifies the bargaining unit. Valid values are
 * defined by 'BARGAINING_UNIT_CODE' lookup_type
 * @param p_comments Comment text.
 * @param p_current_job_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_JOB_PROP_END_DATE}
 * @param p_current_org_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_ORG_PROP_END_DATE}
 * @param p_avail_status_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AVAIL_STATUS_PROP_END_DATE}
 * @param p_date_end {@rep:casecolumn HR_ALL_POSITIONS_F.DATE_END}
 * @param p_earliest_hire_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.EARLIEST_HIRE_DATE}
 * @param p_fill_by_date {@rep:casecolumn HR_ALL_POSITIONS_F.FILL_BY_DATE}
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_fte {@rep:casecolumn HR_ALL_POSITIONS_F.FTE}
 * @param p_max_persons {@rep:casecolumn HR_ALL_POSITIONS_F.MAX_PERSONS}
 * @param p_overlap_period {@rep:casecolumn HR_ALL_POSITIONS_F.OVERLAP_PERIOD}
 * @param p_overlap_unit_cd Valid values are defined by 'QUALIFYING_UNITS'
 * lookup_type.
 * @param p_pay_term_end_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_pay_term_end_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_permanent_temporary_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_permit_recruitment_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_position_type Valid values are defined by 'POSITION_TYPE'
 * lookup_type
 * @param p_posting_description Posting description
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_unit_cd Valid values are defined by
 * 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Is a replacement required when person
 * assigned is absent. 'YES_NO'
 * @param p_review_flag Valid values are defined by 'YES_NO' lookup_type
 * @param p_seasonal_flag Valid values are defined by 'YES_NO' lookup_type
 * @param p_security_requirements Security Requirements
 * @param p_status Valid values are defined by 'POSITION_STATUS' lookup_type.
 * @param p_term_start_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_term_start_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_update_source_cd Valid values are defined by 'YES_NO' lookup_type
 * @param p_working_hours Number of normal working hours.
 * @param p_works_council_approval_flag Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_work_period_type_cd Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_work_term_end_day_cd Valid values are defined by 'DAY_CODE'
 * lookup_type.
 * @param p_work_term_end_month_cd Valid values are defined by 'MONTH_CODE'
 * lookup_type.
 * @param p_proposed_fte_for_layoff Proposed FTE for layoff
 * @param p_proposed_date_for_layoff Proposed date for layoff
 * @param p_pay_basis_id {@rep:casecolumn PER_PAY_BASES.PAY_BASIS_ID}
 * @param p_supervisor_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_ID}
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_segment1 Component of the Position Key Flexfield for the Position
 * @param p_segment2 Component of the Position Key Flexfield for the Position
 * @param p_segment3 Component of the Position Key Flexfield for the Position
 * @param p_segment4 Component of the Position Key Flexfield for the Position
 * @param p_segment5 Component of the Position Key Flexfield for the Position
 * @param p_segment6 Component of the Position Key Flexfield for the Position
 * @param p_segment7 Component of the Position Key Flexfield for the Position
 * @param p_segment8 Component of the Position Key Flexfield for the Position
 * @param p_segment9 Component of the Position Key Flexfield for the Position
 * @param p_segment10 Component of the Position Key Flexfield for the Position
 * @param p_segment11 Component of the Position Key Flexfield for the Position
 * @param p_segment12 Component of the Position Key Flexfield for the Position
 * @param p_segment13 Component of the Position Key Flexfield for the Position
 * @param p_segment14 Component of the Position Key Flexfield for the Position
 * @param p_segment15 Component of the Position Key Flexfield for the Position
 * @param p_segment16 Component of the Position Key Flexfield for the Position
 * @param p_segment17 Component of the Position Key Flexfield for the Position
 * @param p_segment18 Component of the Position Key Flexfield for the Position
 * @param p_segment19 Component of the Position Key Flexfield for the Position
 * @param p_segment20 Component of the Position Key Flexfield for the Position
 * @param p_segment21 Component of the Position Key Flexfield for the Position
 * @param p_segment22 Component of the Position Key Flexfield for the Position
 * @param p_segment23 Component of the Position Key Flexfield for the Position
 * @param p_segment24 Component of the Position Key Flexfield for the Position
 * @param p_segment25 Component of the Position Key Flexfield for the Position
 * @param p_segment26 Component of the Position Key Flexfield for the Position
 * @param p_segment27 Component of the Position Key Flexfield for the Position
 * @param p_segment28 Component of the Position Key Flexfield for the Position
 * @param p_segment29 Component of the Position Key Flexfield for the Position
 * @param p_segment30 Component of the Position Key Flexfield for the Position
 * @param p_concat_segments Varchar2 concatenated string of segment values
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_datetrack_mode Datetract mode Indicates which DateTrack mode to use when updating
 * the record.
 * @param p_valid_grades_changed_warning Set to true when either the position
 * date effective or date end have been modified and at least one valid grade
 * has been updated or deleted. Set to false when no valid grades were altered.
 * @rep:displayname Update Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}

procedure update_position
  (p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_name                           in out nocopy varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_datetrack_mode               in  varchar2
  ,p_valid_grades_changed_warning  out nocopy boolean
  ) ;

END ghr_posndt_api;

 

/
