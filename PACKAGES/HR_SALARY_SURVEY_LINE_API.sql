--------------------------------------------------------
--  DDL for Package HR_SALARY_SURVEY_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_SURVEY_LINE_API" AUTHID CURRENT_USER as
/* $Header: pesslapi.pkh 120.2 2005/11/03 12:14:14 rthiagar noship $ */
/*#
 * This package contains APIs to create and maintain a Salary Survey details
 * record.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Salary Survey Line
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_salary_survey_line >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Salary Survey detail record.
 *
 * A Salary Survey line records comparable salary figures from the industry.
 * The process records a survey line for a salary survey header.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A corresponding Salary Survey must exist.
 *
 * <p><b>Post Success</b><br>
 * Salary survey line is created for the salary survey header.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey Line will not be created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_salary_survey_id Identifies the parent survey for this survey line
 * and serves as a foreign key to PER_SALARY_SURVEYS.
 * @param p_survey_job_name_code The code specifying the job type that this
 * survey line applies to. Valid values are defined by 'SURVEY_JOB_NAME' lookup
 * type.
 * @param p_start_date {@rep:casecolumn PER_SALARY_SURVEY_LINES.START_DATE}
 * @param p_currency_code The code specifying the currency for the survey.
 * Serves as a foreign key to FND_CURRENCIES
 * @param p_survey_region_code The code specifying the Region that this survey
 * line applies to. Valid values are defined by 'SURVEY_REGION' lookup type.
 * @param p_survey_seniority_code The code specifying the Seniority that this
 * survey line applies to. Valid values are defined by 'SURVEY_SENIORITY'
 * lookup type.
 * @param p_company_size_code The code specifying the size of the company that
 * the survey line applies to. Valid values are defined by 'COMPANY_SIZE'
 * lookup type.
 * @param p_industry_code The code specifying the industry associated with the
 * survey line. Valid values are defined by 'INDUSTRY' lookup type.
 * @param p_survey_age_code The code specifying the Survey Age for the survey
 * line. Valid values are defined by 'SURVEY_AGE' lookup type.
 * @param p_end_date {@rep:casecolumn PER_SALARY_SURVEY_LINES.END_DATE}
 * @param p_differential {@rep:casecolumn PER_SALARY_SURVEY_LINES.DIFFERENTIAL}
 * @param p_minimum_pay The minimum pay for the job associated with the survey
 * line.
 * @param p_mean_pay The mean pay for the job associated with the survey line.
 * @param p_maximum_pay The maximum pay for the job associated with the survey
 * line.
 * @param p_graduate_pay The graduate pay for the job associated with the
 * survey line.
 * @param p_starting_pay The starting pay for the job associated with the
 * survey line.
 * @param p_percentage_change The percentage by which the pay figures have
 * changed.
 * @param p_job_first_quartile The job pay figure for the first quartile.
 * @param p_job_median_quartile The job pay figure for the median quartile.
 * @param p_job_third_quartile The job pay figure for the third quartile.
 * @param p_job_fourth_quartile The job pay figure for the fourth quartile.
 * @param p_minimum_total_compensation The minimum total compensation.
 * @param p_mean_total_compensation The mean total compensation.
 * @param p_maximum_total_compensation The maximum total compensation.
 * @param p_compnstn_first_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_FIRST_QUARTILE}
 * @param p_compnstn_median_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_MEDIAN_QUARTILE}
 * @param p_compnstn_third_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_THIRD_QUARTILE}
 * @param p_compnstn_fourth_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_FOURTH_QUARTILE}
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
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
 * @param p_salary_survey_line_id If p_validate is false, uniquely identifies
 * the survey line created. If p_validate is true, set to null.
 * @param p_ssl_object_version_number If p_validate is false, set to the object
 * version number of this survey line. If p_validate is true, set to null.
 * @param p_overlap_warning If this is set to true, then another survey line
 * exists within this survey with the same details and overlapping date range.
 * The existing survey line will be end dated and the new survey line as per
 * the details provided will be created.
 * @param p_twenty_fifth_percentile The twenty fifth percentile.
 * @param p_seventy_fifth_percentile The seventy fifth percentile.
 * @param p_stock_display_type The code specifying the type that the stock for this
 * survey line applies to. Valid values are defined by 'STOCK_DISPLAY_TYPE' lookup
 * type.
 * @param p_mean_stock The mean stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @param p_minimum_bonus The minimum bonus for the job associated with the survey
 * line.
 * @param p_tenth_percentile The tenth percentile.
 * @param p_min_variable_compensation The minimum variable compensation for the job
 * associated with the survey line.
 * @param p_maximum_stock The maximum stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @param p_fiftieth_percentile Fiftieth percentile
 * @param p_max_variable_compensation The maximum variable compensation for the job
 * associated with the survey line.
 * @param p_mean_bonus The mean bonus for the job associated with the survey line.
 * @param p_maximum_salary_increase The maximum salary increase for the job associated
 * with the survey line.
 * @param p_maximum_bonus The maximum bonus for the job associated with the survey line.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_minimum_salary_increase The minimum salary increase for the job associated
 * with the survey line.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_mean_salary_increase The mean salary increase for the job associated
 * with the survey line.
 * @param p_ninetieth_percentile The ninetieth Percentile.
 * @param p_mean_variable_compensation The mean variable compensation for the job
 * associated with the survey line.
 * @param p_minimum_stock The minimum stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @rep:displayname Create Salary Survey Line
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_salary_survey_line
  (p_validate                      in     boolean  default false
  ,p_salary_survey_id              in     number
  ,p_survey_job_name_code          in     varchar2
  ,p_start_date                    in     date
  ,p_currency_code                 in     varchar2
  ,p_survey_region_code            in     varchar2 default null
  ,p_survey_seniority_code         in     varchar2 default null
  ,p_company_size_code             in     varchar2 default null
  ,p_industry_code                 in     varchar2 default null
  ,p_survey_age_code               in     varchar2 default null
  ,p_end_date                      in     date     default null
  ,p_differential                  in     number   default null
  ,p_minimum_pay                   in     number   default null
  ,p_mean_pay                      in     number   default null
  ,p_maximum_pay                   in     number   default null
  ,p_graduate_pay                  in     number   default null
  ,p_starting_pay                  in     number   default null
  ,p_percentage_change             in     number   default null
  ,p_job_first_quartile            in     number   default null
  ,p_job_median_quartile           in     number   default null
  ,p_job_third_quartile            in     number   default null
  ,p_job_fourth_quartile           in     number   default null
  ,p_minimum_total_compensation    in     number   default null
  ,p_mean_total_compensation       in     number   default null
  ,p_maximum_total_compensation    in     number   default null
  ,p_compnstn_first_quartile       in     number   default null
  ,p_compnstn_median_quartile      in     number   default null
  ,p_compnstn_third_quartile       in     number   default null
  ,p_compnstn_fourth_quartile      in     number   default null
/* Added for Enhancement 4021737 */
  ,p_tenth_percentile              in     number   default null
  ,p_twenty_fifth_percentile       in     number   default null
  ,p_fiftieth_percentile           in     number   default null
  ,p_seventy_fifth_percentile      in     number   default null
  ,p_ninetieth_percentile          in     number   default null
  ,p_minimum_bonus                 in     number   default null
  ,p_mean_bonus                    in     number   default null
  ,p_maximum_bonus                 in     number   default null
  ,p_minimum_salary_increase       in     number   default null
  ,p_mean_salary_increase          in     number   default null
  ,p_maximum_salary_increase       in     number   default null
  ,p_min_variable_compensation     in     number   default null
  ,p_mean_variable_compensation    in     number   default null
  ,p_max_variable_compensation     in     number   default null
  ,p_minimum_stock                 in     number   default null
  ,p_mean_stock                    in     number   default null
  ,p_maximum_stock                 in     number   default null
  ,p_stock_display_type            in     varchar2 default null
/*End Enhancement 4021737 */
  ,p_effective_date                in     date     default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
/*Added for Enhancement 4021737 */
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
/*End Enhancement 4021737 */
  ,p_salary_survey_line_id            out nocopy number
  ,p_ssl_object_version_number        out nocopy number
  ,p_overlap_warning                  out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_salary_survey_line >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Salary Survey line.
 *
 * This API allows you to update the details of a survey line. A Salary Survey
 * line records comparative salary figures from the industry. You record a
 * survey line for a salary survey header.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The salary_survey_line_id and object_version_number must all be valid and
 * exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The salary survey line is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey Line will not be updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_survey_job_name_code The code specifying the job type that this
 * survey line applies to. Valid values are defined by 'SURVEY_JOB_NAME' lookup
 * type.
 * @param p_start_date {@rep:casecolumn PER_SALARY_SURVEY_LINES.START_DATE}
 * @param p_currency_code The code specifying the currency for the survey.
 * Serves as a foreign key to FND_CURRENCIES
 * @param p_survey_region_code The code specifying the Region that this survey
 * line applies to. Valid values are defined by 'SURVEY_REGION' lookup type.
 * @param p_survey_seniority_code The code specifying the Seniority that this
 * survey line applies to. Valid values are defined by 'SURVEY_SENIORITY'
 * lookup type.
 * @param p_company_size_code The code specifying the size of the company that
 * the survey line applies to. Valid values are defined by 'COMPANY_SIZE'
 * lookup type.
 * @param p_industry_code The code specifying the industry associated with the
 * survey line. Valid values are defined by 'INDUSTRY' lookup type.
 * @param p_survey_age_code The code specifying the Survey Age for the survey
 * line. Valid values are defined by 'SURVEY_AGE' lookup type.
 * @param p_end_date {@rep:casecolumn PER_SALARY_SURVEY_LINES.END_DATE}
 * @param p_differential {@rep:casecolumn PER_SALARY_SURVEY_LINES.DIFFERENTIAL}
 * @param p_minimum_pay The minimum pay for the job associated with survey
 * line.
 * @param p_mean_pay The mean pay for the job associated with survey line.
 * @param p_maximum_pay The maximum pay for the job associated with survey
 * line.
 * @param p_graduate_pay The graduate pay for the job associated with survey
 * line.
 * @param p_starting_pay The starting pay for the job associated with survey
 * line.
 * @param p_percentage_change The percentage by which the pay figures have
 * changed.
 * @param p_job_first_quartile The job pay figure for the first quartile.
 * @param p_job_median_quartile The job pay figure for the median quartile.
 * @param p_job_third_quartile The job pay figure for the third quartile.
 * @param p_job_fourth_quartile The job pay figure for the fourth quartile.
 * @param p_minimum_total_compensation The minimum total compensation.
 * @param p_mean_total_compensation The mean total compensation.
 * @param p_maximum_total_compensation The maximum total compensation.
 * @param p_compnstn_first_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_FIRST_QUARTILE}
 * @param p_compnstn_median_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_MEDIAN_QUARTILE}
 * @param p_compnstn_third_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_THIRD_QUARTILE}
 * @param p_compnstn_fourth_quartile {@rep:casecolumn
 * PER_SALARY_SURVEY_LINES.COMPNSTN_FOURTH_QUARTILE}
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
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
 * @param p_salary_survey_line_id Uniquely identifies the survey line to be
 * updated.
 * @param p_ssl_object_version_number If p_validate is false, set to the object
 * version number of this survey line. If p_validate is true, set to null.
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
 * @param p_tenth_percentile The tenth percentile.
 * @param p_minimum_bonus The minimum bonus for the job associated with the survey
 * line.
 * @param p_mean_variable_compensation The mean variable compensation for the job
 * associated with the survey line.
 * @param p_maximum_stock The maximum stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @param p_twenty_fifth_percentile The twenty fifth percentile.
 * @param p_mean_salary_increase The mean salary increase for the job associated
 * with the survey line.
 * @param p_ninetieth_percentile The ninetieth percentile.
 * @param p_seventy_fifth_percentile The seventy fifth percentile.
 * @param p_maximum_bonus The maximum bonus for the job associated with the survey
 * line.
 * @param p_mean_stock The mean stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @param p_min_variable_compensation The minimum variable compensation for the job
 * associated with the survey line.
 * @param p_fiftieth_percentile The fiftieth percentile.
 * @param p_minimum_stock The minimum stock amount for the job associated with the survey
 * line. Depending on the p_stock_display_type, the stock value could either be the
 * number of shares or the money value of the shares.
 * @param p_maximum_salary_increase The maximum salary increase for the job associated
 * with the survey line.
 * @param p_max_variable_compensation The maximum variable compensation for the job
 * associated with the survey line.
 * @param p_mean_bonus The mean bonus for the job associated with the survey line.
 * @param p_minimum_salary_increase The minimum salary increase for the job associated
 * with the survey line.
 * @param p_stock_display_type The code specifying the type that the stock for this
 * survey line applies to. Valid values are defined by 'STOCK_DISPLAY_TYPE' lookup
 * type.
 * @rep:displayname Update Salary Survey Line
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_salary_survey_line
  (p_validate                      in     boolean  default false
  ,p_survey_job_name_code          in     varchar2
  ,p_start_date                    in     date
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_survey_region_code            in     varchar2 default hr_api.g_varchar2
  ,p_survey_seniority_code         in     varchar2 default hr_api.g_varchar2
  ,p_company_size_code             in     varchar2 default hr_api.g_varchar2
  ,p_industry_code                 in     varchar2 default hr_api.g_varchar2
  ,p_survey_age_code               in     varchar2 default hr_api.g_varchar2
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_differential                  in     number   default hr_api.g_number
  ,p_minimum_pay                   in     number   default hr_api.g_number
  ,p_mean_pay                      in     number   default hr_api.g_number
  ,p_maximum_pay                   in     number   default hr_api.g_number
  ,p_graduate_pay                  in     number   default hr_api.g_number
  ,p_starting_pay                  in     number   default hr_api.g_number
  ,p_percentage_change             in     number   default hr_api.g_number
  ,p_job_first_quartile            in     number   default hr_api.g_number
  ,p_job_median_quartile           in     number   default hr_api.g_number
  ,p_job_third_quartile            in     number   default hr_api.g_number
  ,p_job_fourth_quartile           in     number   default hr_api.g_number
  ,p_minimum_total_compensation    in     number   default hr_api.g_number
  ,p_mean_total_compensation       in     number   default hr_api.g_number
  ,p_maximum_total_compensation    in     number   default hr_api.g_number
  ,p_compnstn_first_quartile       in     number   default hr_api.g_number
  ,p_compnstn_median_quartile      in     number   default hr_api.g_number
  ,p_compnstn_third_quartile       in     number   default hr_api.g_number
  ,p_compnstn_fourth_quartile      in     number   default hr_api.g_number
/*Added for Enhancement 4021737 */
  ,p_tenth_percentile              in     number   default hr_api.g_number
  ,p_twenty_fifth_percentile       in     number   default hr_api.g_number
  ,p_fiftieth_percentile           in     number   default hr_api.g_number
  ,p_seventy_fifth_percentile      in     number   default hr_api.g_number
  ,p_ninetieth_percentile          in     number   default hr_api.g_number
  ,p_minimum_bonus                 in     number   default hr_api.g_number
  ,p_mean_bonus                    in     number   default hr_api.g_number
  ,p_maximum_bonus                 in     number   default hr_api.g_number
  ,p_minimum_salary_increase       in     number   default hr_api.g_number
  ,p_mean_salary_increase          in     number   default hr_api.g_number
  ,p_maximum_salary_increase       in     number   default hr_api.g_number
  ,p_min_variable_compensation     in     number   default hr_api.g_number
  ,p_mean_variable_compensation    in     number   default hr_api.g_number
  ,p_max_variable_compensation     in     number   default hr_api.g_number
  ,p_minimum_stock                 in     number   default hr_api.g_number
  ,p_mean_stock                    in     number   default hr_api.g_number
  ,p_maximum_stock                 in     number   default hr_api.g_number
  ,p_stock_display_type            in     varchar2 default hr_api.g_varchar2
/*End Enhancement 4021737 */
  ,p_effective_date                in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
/*Added for Enhancement 4021737 */
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
/*End Enhancement 4021737 */
  ,p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_survey_line >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a salary survey line.
 *
 * You can delete a Salary Survey line only when no mappings exist for the
 * salary survey line.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The salary_survey_line_id and object_version_number must both be valid and
 * exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The survey line is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey Line will not be deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_salary_survey_line_id Uniquely identifies the survey line to be
 * deleted.
 * @param p_ssl_object_version_number The version number of the survey line to
 * be deleted.
 * @rep:displayname Delete Salary Survey Line
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_salary_survey_line
  (p_validate                      in     boolean  default false
  ,p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in     number
  );
--
end hr_salary_survey_line_api ;

 

/
