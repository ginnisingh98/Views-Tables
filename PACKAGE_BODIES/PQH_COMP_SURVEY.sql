--------------------------------------------------------
--  DDL for Package Body PQH_COMP_SURVEY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COMP_SURVEY" as
/* $Header: pqhsuadi.pkb 120.1 2005/10/05 15:07:26 rthiagar noship $ */

-- This procedure is used within Web ADI for Compensation Survey to support
-- creation of new salary survey lines and to update existing survey lines
-- that are downloaded to a spread sheet.
procedure import_row
( P_survey_name               VARCHAR2   default null
, P_identifier                VARCHAR2   default null
, P_survey_company            VARCHAR2   default null
, P_survey_type               VARCHAR2   default null
, P_base_region               VARCHAR2   default null
, P_SALARY_SURVEY_ID          NUMBER     default null
, P_SALARY_SURVEY_LINE_ID     NUMBER     default null
, P_OBJECT_VERSION_NUMBER     NUMBER     default null
, P_SURVEY_JOB_NAME_CODE      VARCHAR2   default null
, P_SURVEY_REGION_CODE        VARCHAR2   default null
, P_SURVEY_SENIORITY_CODE     VARCHAR2   default null
, P_COMPANY_SIZE_CODE         VARCHAR2   default null
, P_INDUSTRY_CODE             VARCHAR2   default null
, P_SURVEY_AGE_CODE           VARCHAR2   default null
, P_CURRENCY_CODE             VARCHAR2   default null
, P_STOCK_DISPLAY_TYPE_CODE   VARCHAR2   default null
, P_SURVEY_JOB_NAME           VARCHAR2   default null
, P_SURVEY_REGION             VARCHAR2   default null
, P_SURVEY_SENIORITY          VARCHAR2   default null
, P_COMPANY_SIZE              VARCHAR2   default null
, P_INDUSTRY                  VARCHAR2   default null
, P_SURVEY_AGE                VARCHAR2   default null
, P_CURRENCY                  VARCHAR2   default null
, P_START_DATE                DATE       default null
, P_END_DATE                  DATE       default null
, P_DIFFERENTIAL              NUMBER     default null
, P_MINIMUM_PAY               NUMBER     default null
, P_MEAN_PAY                  NUMBER     default null
, P_MAXIMUM_PAY               NUMBER     default null
, P_GRADUATE_PAY              NUMBER     default null
, P_STARTING_PAY              NUMBER     default null
, P_PERCENTAGE_CHANGE         NUMBER     default null
, P_JOB_FIRST_QUARTILE        NUMBER     default null
, P_JOB_MEDIAN_QUARTILE       NUMBER     default null
, P_JOB_THIRD_QUARTILE        NUMBER     default null
, P_JOB_FOURTH_QUARTILE       NUMBER     default null
, P_MINIMUM_TOTAL_COMPENSATION  NUMBER   default null
, P_MEAN_TOTAL_COMPENSATION   NUMBER     default null
, P_MAXIMUM_TOTAL_COMPENSATION  NUMBER   default null
, P_COMPNSTN_FIRST_QUARTILE   NUMBER     default null
, P_COMPNSTN_MEDIAN_QUARTILE  NUMBER     default null
, P_COMPNSTN_THIRD_QUARTILE   NUMBER     default null
, P_COMPNSTN_FOURTH_QUARTILE  NUMBER     default null
, P_TENTH_PERCENTILE          NUMBER     default null
, P_TWENTY_FIFTH_PERCENTILE   NUMBER     default null
, P_FIFTIETH_PERCENTILE       NUMBER     default null
, P_SEVENTY_FIFTH_PERCENTILE  NUMBER     default null
, P_NINETIETH_PERCENTILE      NUMBER     default null
, P_MINIMUM_BONUS             NUMBER     default null
, P_MEAN_BONUS                NUMBER     default null
, P_MAXIMUM_BONUS             NUMBER     default null
, P_MINIMUM_SALARY_INCREASE   NUMBER     default null
, P_MEAN_SALARY_INCREASE      NUMBER     default null
, P_MAXIMUM_SALARY_INCREASE   NUMBER     default null
, P_MIN_VARIABLE_COMPENSATION NUMBER     default null
, P_MEAN_VARIABLE_COMPENSATION  NUMBER     default null
, P_MAX_VARIABLE_COMPENSATION NUMBER     default null
, P_MINIMUM_STOCK             NUMBER     default null
, P_MEAN_STOCK                NUMBER     default null
, P_MAXIMUM_STOCK             NUMBER     default null
, P_STOCK_DISPLAY_TYPE        VARCHAR2   default null
, P_ATTRIBUTE_CATEGORY        VARCHAR2   default null
, P_ATTRIBUTE1                VARCHAR2   default null
, P_ATTRIBUTE2                VARCHAR2   default null
, P_ATTRIBUTE3                VARCHAR2   default null
, P_ATTRIBUTE4                VARCHAR2   default null
, P_ATTRIBUTE5                VARCHAR2   default null
, P_ATTRIBUTE6                VARCHAR2   default null
, P_ATTRIBUTE7                VARCHAR2   default null
, P_ATTRIBUTE8                VARCHAR2   default null
, P_ATTRIBUTE9                VARCHAR2   default null
, P_ATTRIBUTE10               VARCHAR2   default null
, P_ATTRIBUTE11               VARCHAR2   default null
, P_ATTRIBUTE12               VARCHAR2   default null
, P_ATTRIBUTE13               VARCHAR2   default null
, P_ATTRIBUTE14               VARCHAR2   default null
, P_ATTRIBUTE15               VARCHAR2   default null
, P_ATTRIBUTE16               VARCHAR2   default null
, P_ATTRIBUTE17               VARCHAR2   default null
, P_ATTRIBUTE18               VARCHAR2   default null
, P_ATTRIBUTE19               VARCHAR2   default null
, P_ATTRIBUTE20               VARCHAR2   default null
, P_ATTRIBUTE21               VARCHAR2   default null
, P_ATTRIBUTE22               VARCHAR2   default null
, P_ATTRIBUTE23               VARCHAR2   default null
, P_ATTRIBUTE24               VARCHAR2   default null
, P_ATTRIBUTE25               VARCHAR2   default null
, P_ATTRIBUTE26               VARCHAR2   default null
, P_ATTRIBUTE27               VARCHAR2   default null
, P_ATTRIBUTE28               VARCHAR2   default null
, P_ATTRIBUTE29               VARCHAR2   default null
, P_ATTRIBUTE30               VARCHAR2   default null
, P_LAST_UPDATE_DATE          DATE       default null
, P_LAST_UPDATED_BY           NUMBER     default null
, P_LAST_UPDATE_LOGIN         NUMBER     default null
, P_CREATED_BY                NUMBER     default null
, P_CREATION_DATE             DATE       default null
) is

  --
  l_salary_survey_line_id     per_salary_survey_lines.salary_survey_line_id%TYPE;
  l_ssl_object_version_number per_salary_survey_lines.object_version_number%TYPE;
  --
  l_overlap_warning       boolean      := false;
  --
  -- This cursor gets the latest object version number to determine the row to be   -- updated.
  cursor c_object_version is
   select max(object_version_number)
     from per_salary_survey_lines
     where salary_survey_line_id = p_salary_survey_line_id
     and   salary_survey_id = p_salary_survey_id;

begin

  -- If survey line id is null then a new row needs to be created for the survey
  -- line and hence the api for creating a new survey line is called.
if P_SALARY_SURVEY_LINE_ID is null then

    hr_salary_survey_line_api.create_salary_survey_line
    (p_validate                     => FALSE,
     p_salary_survey_id             => p_salary_survey_id,
     p_survey_job_name_code         => p_survey_job_name_code,
     p_survey_region_code           => p_survey_region_code,
     p_survey_seniority_code        => p_survey_seniority_code,
     p_company_size_code            => p_company_size_code,
     p_industry_code                => p_industry_code,
     p_survey_age_code              => p_survey_age_code,
     p_start_date                   => p_start_date,
     p_end_date                     => p_end_date,
     p_currency_code                => p_currency_code,
     p_differential                 => p_differential,
     p_minimum_pay                  => p_minimum_pay,
     p_mean_pay                     => p_mean_pay,
     p_maximum_pay                  => p_maximum_pay,
     p_graduate_pay                 => p_graduate_pay,
     p_starting_pay                 => p_starting_pay,
     p_percentage_change            => p_percentage_change,
     p_job_first_quartile           => p_job_first_quartile,
     p_job_median_quartile          => p_job_median_quartile,
     p_job_third_quartile           => p_job_third_quartile,
     p_job_fourth_quartile          => p_job_fourth_quartile,
     p_minimum_total_compensation   => p_minimum_total_compensation,
     p_mean_total_compensation      => p_mean_total_compensation,
     p_maximum_total_compensation   => p_maximum_total_compensation,
     p_compnstn_first_quartile      => p_compnstn_first_quartile,
     p_compnstn_median_quartile     => p_compnstn_median_quartile,
     p_compnstn_third_quartile      => p_compnstn_third_quartile,
     p_compnstn_fourth_quartile     => p_compnstn_fourth_quartile,
     p_tenth_percentile             => p_tenth_percentile,
     p_twenty_fifth_percentile      => p_twenty_fifth_percentile,
     p_fiftieth_percentile          => p_fiftieth_percentile,
     p_seventy_fifth_percentile     => p_seventy_fifth_percentile,
     p_ninetieth_percentile         => p_ninetieth_percentile,
     p_minimum_bonus                => p_minimum_bonus,
     p_mean_bonus                   => p_mean_bonus,
     p_maximum_bonus                => p_maximum_bonus,
     p_minimum_salary_increase      => p_minimum_salary_increase,
     p_mean_salary_increase         => p_mean_salary_increase,
     p_maximum_salary_increase      => p_maximum_salary_increase,
     p_min_variable_compensation    => p_min_variable_compensation,
     p_mean_variable_compensation   => p_mean_variable_compensation,
     p_max_variable_compensation    => p_max_variable_compensation,
     p_stock_display_type           => p_stock_display_type_code,
     p_minimum_stock                => p_minimum_stock,
     p_mean_stock                   => p_mean_stock,
     p_maximum_stock                => p_maximum_stock
    ,p_effective_date               => sysdate --l_effective_date
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_salary_survey_line_id        => l_salary_survey_line_id,
     p_ssl_object_version_number    => l_ssl_object_version_number,
     p_overlap_warning              => l_overlap_warning
    );

else -- P_SALARY_SURVEY_LINE_ID is not null
  -- If survey line id is not null then we get the object version number of the
  -- survey line to be updated and issue a call to the survey line update api.

   open c_object_version;
   fetch c_object_version into l_ssl_object_version_number;
   close c_object_version;

   hr_salary_survey_line_api.update_salary_survey_line
     (p_validate                     => FALSE,
      p_survey_job_name_code         => p_survey_job_name_code,
      p_survey_region_code           => p_survey_region_code,
      p_survey_seniority_code        => p_survey_seniority_code,
      p_company_size_code            => p_company_size_code,
      p_industry_code                => p_industry_code,
      p_survey_age_code              => p_survey_age_code,
      p_start_date                   => p_start_date,
      p_end_date                     => p_end_date,
      p_currency_code                => p_currency_code,
      p_differential                 => p_differential,
      p_minimum_pay                  => p_minimum_pay,
      p_mean_pay                     => p_mean_pay,
      p_maximum_pay                  => p_maximum_pay,
      p_graduate_pay                 => p_graduate_pay,
      p_starting_pay                 => p_starting_pay,
      p_percentage_change            => p_percentage_change,
      p_job_first_quartile           => p_job_first_quartile,
      p_job_median_quartile          => p_job_median_quartile,
      p_job_third_quartile           => p_job_third_quartile,
      p_job_fourth_quartile          => p_job_fourth_quartile,
      p_minimum_total_compensation   => p_minimum_total_compensation,
      p_mean_total_compensation      => p_mean_total_compensation,
      p_maximum_total_compensation   => p_maximum_total_compensation,
      p_compnstn_first_quartile      => p_compnstn_first_quartile,
      p_compnstn_median_quartile     => p_compnstn_median_quartile,
      p_compnstn_third_quartile      => p_compnstn_third_quartile,
      p_compnstn_fourth_quartile     => p_compnstn_fourth_quartile,
      p_tenth_percentile             => p_tenth_percentile,
      p_twenty_fifth_percentile      => p_twenty_fifth_percentile,
      p_fiftieth_percentile          => p_fiftieth_percentile,
      p_seventy_fifth_percentile     => p_seventy_fifth_percentile,
      p_ninetieth_percentile         => p_ninetieth_percentile,
      p_minimum_bonus                => p_minimum_bonus,
      p_mean_bonus                   => p_mean_bonus,
      p_maximum_bonus                => p_maximum_bonus,
      p_minimum_salary_increase      => p_minimum_salary_increase,
      p_mean_salary_increase         => p_mean_salary_increase,
      p_maximum_salary_increase      => p_maximum_salary_increase,
      p_min_variable_compensation    => p_min_variable_compensation,
      p_mean_variable_compensation   => p_mean_variable_compensation,
      p_max_variable_compensation    => p_max_variable_compensation,
      p_stock_display_type           => p_stock_display_type_code,
      p_minimum_stock                => p_minimum_stock,
      p_mean_stock                   => p_mean_stock,
      p_maximum_stock                => p_maximum_stock
     ,p_effective_date               => sysdate --l_effective_date
     ,p_attribute_category           => p_attribute_category
     ,p_attribute1                   => p_attribute1
     ,p_attribute2                   => p_attribute2
     ,p_attribute3                   => p_attribute3
     ,p_attribute4                   => p_attribute4
     ,p_attribute5                   => p_attribute5
     ,p_attribute6                   => p_attribute6
     ,p_attribute7                   => p_attribute7
     ,p_attribute8                   => p_attribute8
     ,p_attribute9                   => p_attribute9
     ,p_attribute10                  => p_attribute10
     ,p_attribute11                  => p_attribute11
     ,p_attribute12                  => p_attribute12
     ,p_attribute13                  => p_attribute13
     ,p_attribute14                  => p_attribute14
     ,p_attribute15                  => p_attribute15
     ,p_attribute16                  => p_attribute16
     ,p_attribute17                  => p_attribute17
     ,p_attribute18                  => p_attribute18
     ,p_attribute19                  => p_attribute19
     ,p_attribute20                  => p_attribute20
     ,p_attribute21                  => p_attribute21
     ,p_attribute22                  => p_attribute22
     ,p_attribute23                  => p_attribute23
     ,p_attribute24                  => p_attribute24
     ,p_attribute25                  => p_attribute25
     ,p_attribute26                  => p_attribute26
     ,p_attribute27                  => p_attribute27
     ,p_attribute28                  => p_attribute28
     ,p_attribute29                  => p_attribute29
     ,p_attribute30                  => p_attribute30
     ,p_salary_survey_line_id        => p_salary_survey_line_id
     ,p_ssl_object_version_number    => l_ssl_object_version_number
     );

end if; -- P_SALARY_SURVEY_LINE_ID is null

end import_row;

end PQH_COMP_SURVEY;

/
