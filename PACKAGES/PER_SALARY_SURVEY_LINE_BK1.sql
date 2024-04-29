--------------------------------------------------------
--  DDL for Package PER_SALARY_SURVEY_LINE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SALARY_SURVEY_LINE_BK1" AUTHID CURRENT_USER as
/* $Header: pesslapi.pkh 120.2 2005/11/03 12:14:14 rthiagar noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_survey_line_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_survey_line_b
  (p_salary_survey_id              in     number
  ,p_survey_job_name_code          in     varchar2
  ,p_start_date                    in     date
  ,p_currency_code                 in     varchar2
  ,p_survey_region_code            in     varchar2
  ,p_survey_seniority_code         in     varchar2
  ,p_company_size_code             in     varchar2
  ,p_industry_code                 in     varchar2
  ,p_survey_age_code               in     varchar2
  ,p_end_date                      in     date
  ,p_differential                  in     number
  ,p_minimum_pay                   in     number
  ,p_mean_pay                      in     number
  ,p_maximum_pay                   in     number
  ,p_graduate_pay                  in     number
  ,p_starting_pay                  in     number
  ,p_percentage_change             in     number
  ,p_job_first_quartile            in     number
  ,p_job_median_quartile           in     number
  ,p_job_third_quartile            in     number
  ,p_job_fourth_quartile           in     number
  ,p_minimum_total_compensation    in     number
  ,p_mean_total_compensation       in     number
  ,p_maximum_total_compensation    in     number
  ,p_compnstn_first_quartile       in     number
  ,p_compnstn_median_quartile      in     number
  ,p_compnstn_third_quartile       in     number
  ,p_compnstn_fourth_quartile      in     number
/*Added for Enhancement 4021737 */
  ,p_tenth_percentile              in     number
  ,p_twenty_fifth_percentile       in     number
  ,p_fiftieth_percentile           in     number
  ,p_seventy_fifth_percentile      in     number
  ,p_ninetieth_percentile          in     number
  ,p_minimum_bonus                 in     number
  ,p_mean_bonus                    in     number
  ,p_maximum_bonus                 in     number
  ,p_minimum_salary_increase       in     number
  ,p_mean_salary_increase          in     number
  ,p_maximum_salary_increase       in     number
  ,p_min_variable_compensation     in     number
  ,p_mean_variable_compensation    in     number
  ,p_max_variable_compensation     in     number
  ,p_minimum_stock                 in     number
  ,p_mean_stock                    in     number
  ,p_maximum_stock                 in     number
  ,p_stock_display_type            in     varchar2
/*End Enhancement 4021737 */
  ,p_effective_date                in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
/*Added for Enhancement 4021737 */
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
/*End Enhancement 4021737 */
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_salary_survey_line_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_salary_survey_line_a
  (p_salary_survey_id              in     number
  ,p_survey_job_name_code          in     varchar2
  ,p_start_date                    in     date
  ,p_currency_code                 in     varchar2
  ,p_survey_region_code            in     varchar2
  ,p_survey_seniority_code         in     varchar2
  ,p_company_size_code             in     varchar2
  ,p_industry_code                 in     varchar2
  ,p_survey_age_code               in     varchar2
  ,p_end_date                      in     date
  ,p_differential                  in     number
  ,p_minimum_pay                   in     number
  ,p_mean_pay                      in     number
  ,p_maximum_pay                   in     number
  ,p_graduate_pay                  in     number
  ,p_starting_pay                  in     number
  ,p_percentage_change             in     number
  ,p_job_first_quartile            in     number
  ,p_job_median_quartile           in     number
  ,p_job_third_quartile            in     number
  ,p_job_fourth_quartile           in     number
  ,p_minimum_total_compensation    in     number
  ,p_mean_total_compensation       in     number
  ,p_maximum_total_compensation    in     number
  ,p_compnstn_first_quartile       in     number
  ,p_compnstn_median_quartile      in     number
  ,p_compnstn_third_quartile       in     number
  ,p_compnstn_fourth_quartile      in     number
/*Added for Enhancement 4021737 */
  ,p_tenth_percentile              in     number
  ,p_twenty_fifth_percentile       in     number
  ,p_fiftieth_percentile           in     number
  ,p_seventy_fifth_percentile      in     number
  ,p_ninetieth_percentile          in     number
  ,p_minimum_bonus                 in     number
  ,p_mean_bonus                    in     number
  ,p_maximum_bonus                 in     number
  ,p_minimum_salary_increase       in     number
  ,p_mean_salary_increase          in     number
  ,p_maximum_salary_increase       in     number
  ,p_min_variable_compensation     in     number
  ,p_mean_variable_compensation    in     number
  ,p_max_variable_compensation     in     number
  ,p_minimum_stock                 in     number
  ,p_mean_stock                    in     number
  ,p_maximum_stock                 in     number
  ,p_stock_display_type            in     varchar2
/*End Enhancement 4021737 */
  ,p_effective_date                in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
/*Added for Enhancement 4021737 */
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
/* End Enhancement 4021737 */
  ,p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in     number
  ,p_overlap_warning               in     boolean
  );
--
end PER_SALARY_SURVEY_LINE_BK1;

 

/
