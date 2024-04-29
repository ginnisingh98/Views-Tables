--------------------------------------------------------
--  DDL for Package Body HR_SALARY_SURVEY_LINE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SALARY_SURVEY_LINE_API" as
/* $Header: pesslapi.pkb 120.0 2005/05/31 21:44:17 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_salary_survey_line_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_salary_survey_line>-------------------|
-- ----------------------------------------------------------------------------
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
/*Added for Enhancement 4021737 */
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
/* End Enhancement 4021737*/
  ,p_salary_survey_line_id            out nocopy number
  ,p_ssl_object_version_number        out nocopy number
  ,p_overlap_warning                  out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_salary_survey_line';
  --
  l_salary_survey_line_id     per_salary_survey_lines.salary_survey_line_id%TYPE;
  l_ssl_object_version_number per_salary_survey_lines.object_version_number%TYPE;
  --
  l_eot                   date         := hr_general.End_of_time;
  --
  l_start_date            date;
  l_end_date              date;
  --
  l_overlap_warning       boolean      := false;
  --
  c_salary_survey_line_id per_salary_survey_lines.salary_survey_line_id%TYPE;
  --
  cursor csr_date_overlap is
    select salary_survey_line_id
    from   per_salary_survey_lines
    where  l_start_date          > start_date
    and    end_date is null
    and    survey_job_name_code  = p_survey_job_name_code
    and    nvl(survey_region_code,hr_api.g_varchar2)
                                 = nvl(p_survey_region_code,hr_api.g_varchar2)
    and    nvl(survey_seniority_code,hr_api.g_varchar2)
                                 = nvl(p_survey_seniority_code,hr_api.g_varchar2)
    and    nvl(company_size_code,hr_api.g_varchar2)
                                 = nvl(p_company_size_code,hr_api.g_varchar2)
    and    nvl(industry_code,hr_api.g_varchar2)
                                 = nvl(p_industry_code,hr_api.g_varchar2)
    and    nvl(survey_age_code,hr_api.g_varchar2)
                                 = nvl(p_survey_age_code,hr_api.g_varchar2)
    and    salary_survey_line_id <> nvl(p_salary_survey_line_id,hr_api.g_number)
    and    salary_survey_id      =  nvl(p_salary_survey_id,hr_api.g_number);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_salary_survey_line;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from IN date parameters to be stored in the database.
  --
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
    per_salary_survey_line_bk1.create_salary_survey_line_b
             (p_salary_survey_id             => p_salary_survey_id,
              p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
/*Added for Enhancement 4021737 */
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30
/* End Enhancement 4021737 */
             );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_survey_line'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  --   If we have a date overlap and the end_date of the overlapping
  --   row found in the database is null then set the end date of the
  --   overlapping row in the database to a day before the start_date
  --   of the new row and then set the warning parameter to true.
  --
  open csr_date_overlap;
  --
  c_salary_survey_line_id := null;
  --
  fetch csr_date_overlap into c_salary_survey_line_id;
  --
  --
  --
  if c_salary_survey_line_id is not null then
    --
  --
  --
    update per_salary_survey_lines
    set    end_date = (l_start_date - 1)
    where  salary_survey_line_id = c_salary_survey_line_id;
    --
    l_overlap_warning := true;
    --
  end if;
  --
  close csr_date_overlap;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_ssl_ins.ins(p_salary_survey_line_id    => l_salary_survey_line_id,
              p_object_version_number        => l_ssl_object_version_number,
              p_salary_survey_id             => p_salary_survey_id,
              p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
/* Added for Enhancement 4021737 */
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30
/* End Enhancement 4021737 */
             );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_salary_survey_line_bk1.create_salary_survey_line_a
             (p_salary_survey_id             => p_salary_survey_id,
              p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
/*Added for Enhancement 4021737 */
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30,
/* End Enhancement 4021737 */
              p_salary_survey_line_id        => l_salary_survey_line_id,
              p_ssl_object_version_number    => l_ssl_object_version_number,
              p_overlap_warning              => l_overlap_warning
             );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_salary_survey_line'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_salary_survey_line_id      := l_salary_survey_line_id;
  p_ssl_object_version_number  := l_ssl_object_version_number;
  p_overlap_warning            := l_overlap_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_salary_survey_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_salary_survey_line_id     := null;
    p_ssl_object_version_number := null;
    p_overlap_warning           := l_overlap_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_salary_survey_line_id     := null;
    p_ssl_object_version_number := null;
    p_overlap_warning           := null;
    rollback to create_salary_survey_line;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end create_salary_survey_line;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_salary_survey_line >---------------------------|
-- ----------------------------------------------------------------------------
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
/* End Enhancement 4021737 */
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
/* End Enhancement 4021737 */
  ,p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_salary_survey_line';
  --
  l_start_date            date;
  l_end_date              date;
  --
  l_salary_survey_line_id     per_salary_survey_lines.salary_survey_line_id%TYPE;
  l_ssl_object_version_number per_salary_survey_lines.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_salary_survey_line;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate tine portion from all IN date parameters being stored in
  -- the database.
  l_start_date := trunc(p_start_date);
  l_end_date   := trunc(p_end_date);
  --
  -- Call Before Process User Hook
  --
  l_salary_survey_line_id     := p_salary_survey_line_id;
  l_ssl_object_version_number := p_ssl_object_version_number;
  --
  begin
    per_salary_survey_line_bk2.update_salary_survey_line_b
             (p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30,
              p_ssl_object_version_number    => l_ssl_object_version_number
             );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_survey_line'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_ssl_upd.upd(p_salary_survey_line_id    => l_salary_survey_line_id,
              p_object_version_number        => l_ssl_object_version_number,
              p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30
             );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_salary_survey_line_bk2.update_salary_survey_line_a
             (p_survey_job_name_code         => p_survey_job_name_code,
              p_survey_region_code           => p_survey_region_code,
              p_survey_seniority_code        => p_survey_seniority_code,
              p_company_size_code            => p_company_size_code,
              p_industry_code                => p_industry_code,
              p_survey_age_code              => p_survey_age_code,
              p_start_date                   => l_start_date,
              p_end_date                     => l_end_date,
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
/*Added for Enhancement 4021737 */
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
              p_minimum_stock                => p_minimum_stock,
              p_mean_stock                   => p_mean_stock,
              p_maximum_stock                => p_maximum_stock,
              p_stock_display_type           => p_stock_display_type,
/* End Enhancement 4021737 */
              p_effective_date               => p_effective_date,
              p_attribute_category           => p_attribute_category,
              p_attribute1                   => p_attribute1,
              p_attribute2                   => p_attribute2,
              p_attribute3                   => p_attribute3,
              p_attribute4                   => p_attribute4,
              p_attribute5                   => p_attribute5,
              p_attribute6                   => p_attribute6,
              p_attribute7                   => p_attribute7,
              p_attribute8                   => p_attribute8,
              p_attribute9                   => p_attribute9,
              p_attribute10                  => p_attribute10,
              p_attribute11                  => p_attribute11,
              p_attribute12                  => p_attribute12,
              p_attribute13                  => p_attribute13,
              p_attribute14                  => p_attribute14,
              p_attribute15                  => p_attribute15,
              p_attribute16                  => p_attribute16,
              p_attribute17                  => p_attribute17,
              p_attribute18                  => p_attribute18,
              p_attribute19                  => p_attribute19,
              p_attribute20                  => p_attribute20,
              p_attribute21                  => p_attribute21,
              p_attribute22                  => p_attribute22,
              p_attribute23                  => p_attribute23,
              p_attribute24                  => p_attribute24,
              p_attribute25                  => p_attribute25,
              p_attribute26                  => p_attribute26,
              p_attribute27                  => p_attribute27,
              p_attribute28                  => p_attribute28,
              p_attribute29                  => p_attribute29,
              p_attribute30                  => p_attribute30,
              p_salary_survey_line_id        => l_salary_survey_line_id,
              p_ssl_object_version_number    => l_ssl_object_version_number
             );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_salary_survey_line'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  -- Set all output arguments
  --
  p_ssl_object_version_number  := l_ssl_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_salary_survey_line;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ssl_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_ssl_object_version_number  := l_ssl_object_version_number;
    rollback to update_salary_survey_line;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end update_salary_survey_line;

--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_salary_survey_line >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_salary_survey_line
  (p_validate                      in     boolean  default false
  ,p_salary_survey_line_id         in     number
  ,p_ssl_object_version_number     in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_salary_survey_line';
  --
  l_salary_survey_line_id     per_salary_survey_lines.salary_survey_line_id%TYPE;
  l_ssl_object_version_number per_salary_survey_lines.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_salary_survey_line;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  l_salary_survey_line_id     := p_salary_survey_line_id;
  l_ssl_object_version_number := p_ssl_object_version_number;
  --
  begin
    per_salary_survey_line_bk3.delete_salary_survey_line_b
     (p_salary_survey_line_id       => l_salary_survey_line_id
     ,p_ssl_object_version_number   => l_ssl_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_survey_line'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_ssl_del.del(p_salary_survey_line_id     => l_salary_survey_line_id
                 ,p_object_version_number     => l_ssl_object_version_number
                 );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_salary_survey_line_bk3.delete_salary_survey_line_a
     (p_salary_survey_line_id       => l_salary_survey_line_id
     ,p_ssl_object_version_number   => l_ssl_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_salary_survey_line'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_salary_survey_line;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_salary_survey_line;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end delete_salary_survey_line;
--
end hr_salary_survey_line_api;

/
