--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_INFO_API" AUTHID CURRENT_USER as
/* $Header: becpiapi.pkh 120.2 2005/10/17 04:59:32 steotia noship $ */
/*#
 * This package contains Compensation Workbench Person APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Compensation Workbench Person Information
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_person_info >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a snapshot of a person for compensation workbench
 * processing.
 *
 * The API Creates denormalized person information that is a snapshot in time
 * (as of the freeze date) from the HR Person Table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person should have a life event reason ID from BEN_PER_IN_LER table, a
 * person ID from PER_ALL_PEOPLE_F and an assignment ID from the
 * PER_ALL_ASSIGNMENTS_F table.
 *
 * <p><b>Post Success</b><br>
 * A snapshot of a person for compensation workbench processing will be
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The person information will not be inserted in the database.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_assignment_id Identifies the assignment of the Compensation
 * Workbench Person
 * @param p_person_id Identifies the person for whom you create the
 * Compensation Workbench Person record.
 * @param p_supervisor_id This parameter identifies the person ID of the
 * manager.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_full_name {@rep:casecolumn BEN_CWB_PERSON_INFO.FULL_NAME}
 * @param p_brief_name {@rep:casecolumn BEN_CWB_PERSON_INFO.BRIEF_NAME}
 * @param p_custom_name {@rep:casecolumn BEN_CWB_PERSON_INFO.CUSTOM_NAME}
 * @param p_supervisor_full_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_FULL_NAME}
 * @param p_supervisor_brief_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_BRIEF_NAME}
 * @param p_supervisor_custom_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_CUSTOM_NAME}
 * @param p_legislation_code This parameter specifies the legislation to which
 * the information type applies.
 * @param p_years_employed This parameter specifies the number of years
 * employed.
 * @param p_years_in_job This parameter specifies the number of years employed
 * in the person's assigned Job.
 * @param p_years_in_position This parameter specifies the number of years
 * employed in the person's assigned Position.
 * @param p_years_in_grade This parameter specifies the number of years
 * employed in the person's assigned Grade.
 * @param p_employee_number This parameter specifies the employee number
 * assigned to the Compensation Workbench Person.
 * @param p_start_date {@rep:casecolumn PER_ALL_PEOPLE_F.START_DATE}
 * @param p_original_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_adjusted_svc_date {@rep:casecolumn
 * PER_PERIODS_OF_SERVICE.ADJUSTED_SVC_DATE}
 * @param p_base_salary {@rep:casecolumn PER_PAY_PROPOSALS.PROPOSED_SALARY_N}
 * @param p_base_salary_change_date {@rep:casecolumn
 * PER_PAY_PROPOSALS.CHANGE_DATE}
 * @param p_payroll_name {@rep:casecolumn PAY_ALL_PAYROLLS_F.PAYROLL_NAME}
 * @param p_performance_rating {@rep:casecolumn
 * PER_PERFORMANCE_REVIEWS.PERFORMANCE_RATING}
 * @param p_performance_rating_type {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.PERFORMANCE_RATING_TYPE}
 * @param p_performance_rating_date {@rep:casecolumn
 * PER_PERFORMANCE_REVIEWS.REVIEW_DATE}
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID}
 * @param p_organization_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID}
 * @param p_job_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.JOB_ID}
 * @param p_grade_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.GRADE_ID}
 * @param p_position_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.POSITION_ID}
 * @param p_people_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID}
 * @param p_soft_coding_keyflex_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SOFT_CODING_KEYFLEX_ID}
 * @param p_location_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.LOCATION_ID}
 * @param p_pay_rate_id {@rep:casecolumn PER_PAY_BASES.RATE_ID}
 * @param p_assignment_status_type_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID}
 * @param p_frequency {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.FREQUENCY}
 * @param p_grade_annulization_factor {@rep:casecolumn
 * PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR}
 * @param p_pay_annulization_factor {@rep:casecolumn
 * PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR}
 * @param p_grd_min_val {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MIN_VAL}
 * @param p_grd_max_val {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MAX_VAL}
 * @param p_grd_mid_point {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MID_POINT}
 * @param p_grd_quartile {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_QUARTILE}
 * @param p_grd_comparatio {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_COMPARATIO}
 * @param p_emp_category {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.EMPLOYMENT_CATEGORY}
 * @param p_change_reason {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.CHANGE_REASON}
 * @param p_normal_hours {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_base_salary_frequency {@rep:casecolumn PER_PAY_BASES.PAY_BASIS}
 * @param p_new_assgn_ovn This parameter specifies the object version number
 * for assignment changes.
 * @param p_new_perf_event_id This parameter specifies the performance event
 * ID.
 * @param p_new_perf_review_id This parameter specifies the performance review
 * ID.
 * @param p_post_process_stat_cd {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.POST_PROCESS_STAT_CD}
 * @param p_feedback_rating This parameter specifies the feedback rating. Valid
 * values are Lookup Code from 'BEN_CWB_SUBMIT_FEEDBACK' lookups.
 * @param p_feedback_comments This parameter specifies the feedback Comments.
 * @param p_custom_segment1 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment2 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment3 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment4 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment5 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment6 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment7 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment8 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment9 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment10 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment11 Placeholder for custom defined numeric values.
 * @param p_custom_segment12 Placeholder for custom defined numeric values.
 * @param p_custom_segment13 Placeholder for custom defined numeric values.
 * @param p_custom_segment14 Placeholder for custom defined numeric values.
 * @param p_custom_segment15 Placeholder for custom defined numeric values.
 * @param p_ass_attribute_category This parameter specifies the assigment
 * attribute category.
 * @param p_ass_attribute1 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute2 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute3 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute4 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute5 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute6 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute7 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute8 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute9 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute10 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute11 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute12 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute13 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute14 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute15 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute16 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute17 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute18 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute19 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute20 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute21 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute22 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute23 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute24 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute25 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute26 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute27 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute28 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute29 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute30 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ws_comments {@rep:casecolumn BEN_CWB_PERSON_INFO.WS_COMMENTS}
 * @param p_people_group_name {@rep:casecolumn PAY_PEOPLE_GROUPS.GROUP_NAME}
 * @param p_people_group_segment1 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment2 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment3 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment4 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment5 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment6 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment7 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment8 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment9 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment10 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment11 Developer descriptive flexfield segment for
 * People Group.
 * @param p_cpi_attribute_category {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE_CATEGORY}
 * @param p_cpi_attribute1 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE1}
 * @param p_cpi_attribute2 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE2}
 * @param p_cpi_attribute3 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE3}
 * @param p_cpi_attribute4 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE4}
 * @param p_cpi_attribute5 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE5}
 * @param p_cpi_attribute6 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE6}
 * @param p_cpi_attribute7 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE7}
 * @param p_cpi_attribute8 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE8}
 * @param p_cpi_attribute9 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE9}
 * @param p_cpi_attribute10 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE10}
 * @param p_cpi_attribute11 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE11}
 * @param p_cpi_attribute12 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE12}
 * @param p_cpi_attribute13 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE13}
 * @param p_cpi_attribute14 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE14}
 * @param p_cpi_attribute15 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE15}
 * @param p_cpi_attribute16 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE16}
 * @param p_cpi_attribute17 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE17}
 * @param p_cpi_attribute18 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE18}
 * @param p_cpi_attribute19 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE19}
 * @param p_cpi_attribute20 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE20}
 * @param p_cpi_attribute21 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE21}
 * @param p_cpi_attribute22 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE22}
 * @param p_cpi_attribute23 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE23}
 * @param p_cpi_attribute24 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE24}
 * @param p_cpi_attribute25 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE25}
 * @param p_cpi_attribute26 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE26}
 * @param p_cpi_attribute27 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE27}
 * @param p_cpi_attribute28 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE28}
 * @param p_cpi_attribute29 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE29}
 * @param p_cpi_attribute30 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE30}
 * @param p_feedback_date This parameter specifies the feedback date.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Group Person Life Event Reason. If p_validate
 * is true, then the value will be null.
 * @param p_custom_segment16 Placeholder for custom defined numeric values.
 * @param p_custom_segment17 Placeholder for custom defined numeric values.
 * @param p_custom_segment18 Placeholder for custom defined numeric values.
 * @param p_custom_segment19 Placeholder for custom defined numeric values.
 * @param p_custom_segment20 Placeholder for custom defined numeric values.
 * @rep:displayname Create Person Information
 * @rep:category BUSINESS_ENTITY BEN_CWB_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number
  ,p_person_id                   in     number
  ,p_supervisor_id               in     number    default null
  ,p_effective_date              in     date      default null
  ,p_full_name                   in     varchar2  default null
  ,p_brief_name                  in     varchar2  default null
  ,p_custom_name                 in     varchar2  default null
  ,p_supervisor_full_name        in     varchar2  default null
  ,p_supervisor_brief_name       in     varchar2  default null
  ,p_supervisor_custom_name      in     varchar2  default null
  ,p_legislation_code            in     varchar2  default null
  ,p_years_employed              in     number    default null
  ,p_years_in_job                in     number    default null
  ,p_years_in_position           in     number    default null
  ,p_years_in_grade              in     number    default null
  ,p_employee_number             in     varchar2  default null
  ,p_start_date                  in     date      default null
  ,p_original_start_date         in     date      default null
  ,p_adjusted_svc_date           in     date      default null
  ,p_base_salary                 in     number    default null
  ,p_base_salary_change_date     in     date      default null
  ,p_payroll_name                in     varchar2  default null
  ,p_performance_rating          in     varchar2  default null
  ,p_performance_rating_type     in     varchar2  default null
  ,p_performance_rating_date     in     date      default null
  ,p_business_group_id           in     number    default null
  ,p_organization_id             in     number    default null
  ,p_job_id                      in     number    default null
  ,p_grade_id                    in     number    default null
  ,p_position_id                 in     number    default null
  ,p_people_group_id             in     number    default null
  ,p_soft_coding_keyflex_id      in     number    default null
  ,p_location_id                 in     number    default null
  ,p_pay_rate_id                 in     number    default null
  ,p_assignment_status_type_id   in     number    default null
  ,p_frequency                   in     varchar2  default null
  ,p_grade_annulization_factor   in     number    default null
  ,p_pay_annulization_factor     in     number    default null
  ,p_grd_min_val                 in     number    default null
  ,p_grd_max_val                 in     number    default null
  ,p_grd_mid_point               in     number    default null
  ,p_grd_quartile                in     varchar2  default null
  ,p_grd_comparatio              in     number    default null
  ,p_emp_category                in     varchar2  default null
  ,p_change_reason               in     varchar2  default null
  ,p_normal_hours                in     number    default null
  ,p_email_address               in     varchar2  default null
  ,p_base_salary_frequency       in     varchar2  default null
  ,p_new_assgn_ovn               in     number    default null
  ,p_new_perf_event_id           in     number    default null
  ,p_new_perf_review_id          in     number    default null
  ,p_post_process_stat_cd        in     varchar2  default null
  ,p_feedback_rating             in     varchar2  default null
  ,p_feedback_comments           in     varchar2  default null
  ,p_custom_segment1             in     varchar2  default null
  ,p_custom_segment2             in     varchar2  default null
  ,p_custom_segment3             in     varchar2  default null
  ,p_custom_segment4             in     varchar2  default null
  ,p_custom_segment5             in     varchar2  default null
  ,p_custom_segment6             in     varchar2  default null
  ,p_custom_segment7             in     varchar2  default null
  ,p_custom_segment8             in     varchar2  default null
  ,p_custom_segment9             in     varchar2  default null
  ,p_custom_segment10            in     varchar2  default null
  ,p_custom_segment11            in     number    default null
  ,p_custom_segment12            in     number    default null
  ,p_custom_segment13            in     number    default null
  ,p_custom_segment14            in     number    default null
  ,p_custom_segment15            in     number    default null
  ,p_custom_segment16            in     number    default null
  ,p_custom_segment17            in     number    default null
  ,p_custom_segment18            in     number    default null
  ,p_custom_segment19            in     number    default null
  ,p_custom_segment20            in     number    default null
  ,p_ass_attribute_category      in     varchar2  default null
  ,p_ass_attribute1              in     varchar2  default null
  ,p_ass_attribute2              in     varchar2  default null
  ,p_ass_attribute3              in     varchar2  default null
  ,p_ass_attribute4              in     varchar2  default null
  ,p_ass_attribute5              in     varchar2  default null
  ,p_ass_attribute6              in     varchar2  default null
  ,p_ass_attribute7              in     varchar2  default null
  ,p_ass_attribute8              in     varchar2  default null
  ,p_ass_attribute9              in     varchar2  default null
  ,p_ass_attribute10             in     varchar2  default null
  ,p_ass_attribute11             in     varchar2  default null
  ,p_ass_attribute12             in     varchar2  default null
  ,p_ass_attribute13             in     varchar2  default null
  ,p_ass_attribute14             in     varchar2  default null
  ,p_ass_attribute15             in     varchar2  default null
  ,p_ass_attribute16             in     varchar2  default null
  ,p_ass_attribute17             in     varchar2  default null
  ,p_ass_attribute18             in     varchar2  default null
  ,p_ass_attribute19             in     varchar2  default null
  ,p_ass_attribute20             in     varchar2  default null
  ,p_ass_attribute21             in     varchar2  default null
  ,p_ass_attribute22             in     varchar2  default null
  ,p_ass_attribute23             in     varchar2  default null
  ,p_ass_attribute24             in     varchar2  default null
  ,p_ass_attribute25             in     varchar2  default null
  ,p_ass_attribute26             in     varchar2  default null
  ,p_ass_attribute27             in     varchar2  default null
  ,p_ass_attribute28             in     varchar2  default null
  ,p_ass_attribute29             in     varchar2  default null
  ,p_ass_attribute30             in     varchar2  default null
  ,p_ws_comments                 in     varchar2  default null
  ,p_people_group_name           in     varchar2  default null
  ,p_people_group_segment1       in     varchar2  default null
  ,p_people_group_segment2       in     varchar2  default null
  ,p_people_group_segment3       in     varchar2  default null
  ,p_people_group_segment4       in     varchar2  default null
  ,p_people_group_segment5       in     varchar2  default null
  ,p_people_group_segment6       in     varchar2  default null
  ,p_people_group_segment7       in     varchar2  default null
  ,p_people_group_segment8       in     varchar2  default null
  ,p_people_group_segment9       in     varchar2  default null
  ,p_people_group_segment10      in     varchar2  default null
  ,p_people_group_segment11      in     varchar2  default null
  ,p_cpi_attribute_category      in     varchar2  default null
  ,p_cpi_attribute1              in     varchar2  default null
  ,p_cpi_attribute2              in     varchar2  default null
  ,p_cpi_attribute3              in     varchar2  default null
  ,p_cpi_attribute4              in     varchar2  default null
  ,p_cpi_attribute5              in     varchar2  default null
  ,p_cpi_attribute6              in     varchar2  default null
  ,p_cpi_attribute7              in     varchar2  default null
  ,p_cpi_attribute8              in     varchar2  default null
  ,p_cpi_attribute9              in     varchar2  default null
  ,p_cpi_attribute10             in     varchar2  default null
  ,p_cpi_attribute11             in     varchar2  default null
  ,p_cpi_attribute12             in     varchar2  default null
  ,p_cpi_attribute13             in     varchar2  default null
  ,p_cpi_attribute14             in     varchar2  default null
  ,p_cpi_attribute15             in     varchar2  default null
  ,p_cpi_attribute16             in     varchar2  default null
  ,p_cpi_attribute17             in     varchar2  default null
  ,p_cpi_attribute18             in     varchar2  default null
  ,p_cpi_attribute19             in     varchar2  default null
  ,p_cpi_attribute20             in     varchar2  default null
  ,p_cpi_attribute21             in     varchar2  default null
  ,p_cpi_attribute22             in     varchar2  default null
  ,p_cpi_attribute23             in     varchar2  default null
  ,p_cpi_attribute24             in     varchar2  default null
  ,p_cpi_attribute25             in     varchar2  default null
  ,p_cpi_attribute26             in     varchar2  default null
  ,p_cpi_attribute27             in     varchar2  default null
  ,p_cpi_attribute28             in     varchar2  default null
  ,p_cpi_attribute29             in     varchar2  default null
  ,p_cpi_attribute30             in     varchar2  default null
  ,p_feedback_date               in     date      default null
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_person_info >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a snapshot of a person for compensation workbench
 * processing.
 *
 * Updates denormalized person information that is a snapshot in time (as of
 * the freeze date) from the HR Person Table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Person record to update must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The person information will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The person information will not be updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_assignment_id Identifies the assignment of the Compensation
 * Workbench Person
 * @param p_person_id Identifies the person for whom you create the
 * Compensation Workbench Person record.
 * @param p_supervisor_id This parameter identifies the person ID of the
 * manager.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_full_name {@rep:casecolumn BEN_CWB_PERSON_INFO.FULL_NAME}
 * @param p_brief_name {@rep:casecolumn BEN_CWB_PERSON_INFO.BRIEF_NAME}
 * @param p_custom_name {@rep:casecolumn BEN_CWB_PERSON_INFO.CUSTOM_NAME}
 * @param p_supervisor_full_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_FULL_NAME}
 * @param p_supervisor_brief_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_BRIEF_NAME}
 * @param p_supervisor_custom_name {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.SUPERVISOR_CUSTOM_NAME}
 * @param p_legislation_code This parameter specifies the legislation to which
 * the information type applies.
 * @param p_years_employed This parameter specifies the number of years
 * employed.
 * @param p_years_in_job This parameter specifies the number of years employed
 * in the person's assigned Job.
 * @param p_years_in_position This parameter specifies the number of years
 * employed in the person's assigned position.
 * @param p_years_in_grade This parameter specifies the number of years
 * employed in the person's assigned grade.
 * @param p_employee_number This parameter specifies the employee Number
 * assigned to the Compensation Workbench Person.
 * @param p_start_date {@rep:casecolumn PER_ALL_PEOPLE_F.START_DATE}
 * @param p_original_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_adjusted_svc_date {@rep:casecolumn
 * PER_PERIODS_OF_SERVICE.ADJUSTED_SVC_DATE}
 * @param p_base_salary {@rep:casecolumn PER_PAY_PROPOSALS.PROPOSED_SALARY_N}
 * @param p_base_salary_change_date {@rep:casecolumn
 * PER_PAY_PROPOSALS.CHANGE_DATE}
 * @param p_payroll_name {@rep:casecolumn PAY_ALL_PAYROLLS_F.PAYROLL_NAME}
 * @param p_performance_rating {@rep:casecolumn
 * PER_PERFORMANCE_REVIEWS.PERFORMANCE_RATING}
 * @param p_performance_rating_type {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.PERFORMANCE_RATING_TYPE}
 * @param p_performance_rating_date {@rep:casecolumn
 * PER_PERFORMANCE_REVIEWS.REVIEW_DATE}
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID}
 * @param p_organization_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID}
 * @param p_job_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.JOB_ID}
 * @param p_grade_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.GRADE_ID}
 * @param p_position_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.POSITION_ID}
 * @param p_people_group_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID}
 * @param p_soft_coding_keyflex_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SOFT_CODING_KEYFLEX_ID}
 * @param p_location_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.LOCATION_ID}
 * @param p_pay_rate_id {@rep:casecolumn PER_PAY_BASES.RATE_ID}
 * @param p_assignment_status_type_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID}
 * @param p_frequency {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.FREQUENCY}
 * @param p_grade_annulization_factor {@rep:casecolumn
 * PER_PAY_BASES.GRADE_ANNUALIZATION_FACTOR}
 * @param p_pay_annulization_factor {@rep:casecolumn
 * PER_PAY_BASES.PAY_ANNUALIZATION_FACTOR}
 * @param p_grd_min_val {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MIN_VAL}
 * @param p_grd_max_val {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MAX_VAL}
 * @param p_grd_mid_point {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_MID_POINT}
 * @param p_grd_quartile {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_QUARTILE}
 * @param p_grd_comparatio {@rep:casecolumn BEN_CWB_PERSON_INFO.GRD_COMPARATIO}
 * @param p_emp_category {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.EMPLOYMENT_CATEGORY}
 * @param p_change_reason {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.CHANGE_REASON}
 * @param p_normal_hours {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_base_salary_frequency {@rep:casecolumn PER_PAY_BASES.PAY_BASIS}
 * @param p_new_assgn_ovn This parameter specifies the object version number
 * for assignment changes.
 * @param p_new_perf_event_id This parameter specifies the performance event
 * ID.
 * @param p_new_perf_review_id This parameter specifies the performance review
 * ID.
 * @param p_post_process_stat_cd {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.POST_PROCESS_STAT_CD}
 * @param p_feedback_rating This parameter specifies the feedback rating. Valid
 * values are Lookup Code from 'BEN_CWB_SUBMIT_FEEDBACK' lookups.
 * @param p_feedback_comments This parameter specifies the feedback comments.
 * @param p_custom_segment1 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment2 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment3 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment4 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment5 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment6 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment7 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment8 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment9 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment10 Placeholder for custom defined alphanumeric values.
 * @param p_custom_segment11 Placeholder for custom defined numeric values.
 * @param p_custom_segment12 Placeholder for custom defined numeric values.
 * @param p_custom_segment13 Placeholder for custom defined numeric values.
 * @param p_custom_segment14 Placeholder for custom defined numeric values.
 * @param p_custom_segment15 Placeholder for custom defined numeric values.
 * @param p_ass_attribute_category This parameter specifies the assigment
 * attribute category.
 * @param p_ass_attribute1 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute2 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute3 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute4 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute5 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute6 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute7 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute8 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute9 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute10 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute11 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute12 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute13 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute14 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute15 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute16 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute17 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute18 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute19 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute20 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute21 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute22 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute23 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute24 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute25 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute26 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute27 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute28 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute29 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ass_attribute30 Developer descriptive flexfield segment for
 * Assignment.
 * @param p_ws_comments {@rep:casecolumn BEN_CWB_PERSON_INFO.WS_COMMENTS}
 * @param p_people_group_name {@rep:casecolumn PAY_PEOPLE_GROUPS.GROUP_NAME}
 * @param p_people_group_segment1 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment2 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment3 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment4 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment5 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment6 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment7 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment8 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment9 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment10 Developer descriptive flexfield segment for
 * People Group.
 * @param p_people_group_segment11 Developer descriptive flexfield segment for
 * People Group.
 * @param p_cpi_attribute_category {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE_CATEGORY}
 * @param p_cpi_attribute1 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE1}
 * @param p_cpi_attribute2 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE2}
 * @param p_cpi_attribute3 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE3}
 * @param p_cpi_attribute4 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE4}
 * @param p_cpi_attribute5 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE5}
 * @param p_cpi_attribute6 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE6}
 * @param p_cpi_attribute7 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE7}
 * @param p_cpi_attribute8 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE8}
 * @param p_cpi_attribute9 {@rep:casecolumn BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE9}
 * @param p_cpi_attribute10 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE10}
 * @param p_cpi_attribute11 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE11}
 * @param p_cpi_attribute12 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE12}
 * @param p_cpi_attribute13 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE13}
 * @param p_cpi_attribute14 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE14}
 * @param p_cpi_attribute15 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE15}
 * @param p_cpi_attribute16 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE16}
 * @param p_cpi_attribute17 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE17}
 * @param p_cpi_attribute18 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE18}
 * @param p_cpi_attribute19 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE19}
 * @param p_cpi_attribute20 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE20}
 * @param p_cpi_attribute21 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE21}
 * @param p_cpi_attribute22 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE22}
 * @param p_cpi_attribute23 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE23}
 * @param p_cpi_attribute24 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE24}
 * @param p_cpi_attribute25 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE25}
 * @param p_cpi_attribute26 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE26}
 * @param p_cpi_attribute27 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE27}
 * @param p_cpi_attribute28 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE28}
 * @param p_cpi_attribute29 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE29}
 * @param p_cpi_attribute30 {@rep:casecolumn
 * BEN_CWB_PERSON_INFO.CPI_ATTRIBUTE30}
 * @param p_feedback_date This parameter specifies the feedback date.
 * @param p_object_version_number Pass in the current version number of the
 * Group Person Life Event Reason to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Group Person Life Event Reason. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_custom_segment16 Placeholder for custom defined numeric values.
 * @param p_custom_segment17 Placeholder for custom defined numeric values.
 * @param p_custom_segment18 Placeholder for custom defined numeric values.
 * @param p_custom_segment19 Placeholder for custom defined numeric values.
 * @param p_custom_segment20 Placeholder for custom defined numeric values.
 * @rep:displayname Update Person Information
 * @rep:category BUSINESS_ENTITY BEN_CWB_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_assignment_id               in     number    default hr_api.g_number
  ,p_person_id                   in     number    default hr_api.g_number
  ,p_supervisor_id               in     number    default hr_api.g_number
  ,p_effective_date              in     date      default hr_api.g_date
  ,p_full_name                   in     varchar2  default hr_api.g_varchar2
  ,p_brief_name                  in     varchar2  default hr_api.g_varchar2
  ,p_custom_name                 in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_full_name        in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_brief_name       in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_custom_name      in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code            in     varchar2  default hr_api.g_varchar2
  ,p_years_employed              in     number    default hr_api.g_number
  ,p_years_in_job                in     number    default hr_api.g_number
  ,p_years_in_position           in     number    default hr_api.g_number
  ,p_years_in_grade              in     number    default hr_api.g_number
  ,p_employee_number             in     varchar2  default hr_api.g_varchar2
  ,p_start_date                  in     date      default hr_api.g_date
  ,p_original_start_date         in     date      default hr_api.g_date
  ,p_adjusted_svc_date           in     date      default hr_api.g_date
  ,p_base_salary                 in     number    default hr_api.g_number
  ,p_base_salary_change_date     in     date      default hr_api.g_date
  ,p_payroll_name                in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating          in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_type     in     varchar2  default hr_api.g_varchar2
  ,p_performance_rating_date     in     date      default hr_api.g_date
  ,p_business_group_id           in     number    default hr_api.g_number
  ,p_organization_id             in     number    default hr_api.g_number
  ,p_job_id                      in     number    default hr_api.g_number
  ,p_grade_id                    in     number    default hr_api.g_number
  ,p_position_id                 in     number    default hr_api.g_number
  ,p_people_group_id             in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id      in     number    default hr_api.g_number
  ,p_location_id                 in     number    default hr_api.g_number
  ,p_pay_rate_id                 in     number    default hr_api.g_number
  ,p_assignment_status_type_id   in     number    default hr_api.g_number
  ,p_frequency                   in     varchar2  default hr_api.g_varchar2
  ,p_grade_annulization_factor   in     number    default hr_api.g_number
  ,p_pay_annulization_factor     in     number    default hr_api.g_number
  ,p_grd_min_val                 in     number    default hr_api.g_number
  ,p_grd_max_val                 in     number    default hr_api.g_number
  ,p_grd_mid_point               in     number    default hr_api.g_number
  ,p_grd_quartile                in     varchar2  default hr_api.g_varchar2
  ,p_grd_comparatio              in     number    default hr_api.g_number
  ,p_emp_category                in     varchar2  default hr_api.g_varchar2
  ,p_change_reason               in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                in     number    default hr_api.g_number
  ,p_email_address               in     varchar2  default hr_api.g_varchar2
  ,p_base_salary_frequency       in     varchar2  default hr_api.g_varchar2
  ,p_new_assgn_ovn               in     number    default hr_api.g_number
  ,p_new_perf_event_id           in     number    default hr_api.g_number
  ,p_new_perf_review_id          in     number    default hr_api.g_number
  ,p_post_process_stat_cd        in     varchar2  default hr_api.g_varchar2
  ,p_feedback_rating             in     varchar2  default hr_api.g_varchar2
  ,p_feedback_comments           in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment1             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment2             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment3             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment4             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment5             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment6             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment7             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment8             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment9             in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment10            in     varchar2  default hr_api.g_varchar2
  ,p_custom_segment11            in     number    default hr_api.g_number
  ,p_custom_segment12            in     number    default hr_api.g_number
  ,p_custom_segment13            in     number    default hr_api.g_number
  ,p_custom_segment14            in     number    default hr_api.g_number
  ,p_custom_segment15            in     number    default hr_api.g_number
  ,p_custom_segment16            in     number    default hr_api.g_number
  ,p_custom_segment17            in     number    default hr_api.g_number
  ,p_custom_segment18            in     number    default hr_api.g_number
  ,p_custom_segment19            in     number    default hr_api.g_number
  ,p_custom_segment20            in     number    default hr_api.g_number
  ,p_ass_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29             in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30             in     varchar2  default hr_api.g_varchar2
  ,p_ws_comments                 in     varchar2  default hr_api.g_varchar2
  ,p_people_group_name           in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment1       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment2       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment3       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment4       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment5       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment6       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment7       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment8       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment9       in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment10      in     varchar2  default hr_api.g_varchar2
  ,p_people_group_segment11      in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute21             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute22             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute23             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute24             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute25             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute26             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute27             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute28             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute29             in     varchar2  default hr_api.g_varchar2
  ,p_cpi_attribute30             in     varchar2  default hr_api.g_varchar2
  ,p_feedback_date               in     date      default hr_api.g_date
  ,p_object_version_number       in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_person_info >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Compensation Workbench information for a person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A Compensation Workbench Person record to delete must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The person information will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The person information will not be deleted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_group_per_in_ler_id This parameter identifies the Group Life Event
 * Reason ID of Compensation Workbench Person. Foreign key to BEN_PER_IN_LER.
 * @param p_object_version_number Current version number of the Group Person
 * Life Event Reason to be deleted.
 * @rep:displayname Delete Person Information
 * @rep:category BUSINESS_ENTITY BEN_CWB_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_info
  (p_validate                    in     boolean   default false
  ,p_group_per_in_ler_id         in     number
  ,p_object_version_number       in     number
  );

end BEN_CWB_PERSON_INFO_API;

 

/
