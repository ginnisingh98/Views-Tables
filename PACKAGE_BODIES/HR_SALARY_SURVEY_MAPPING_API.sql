--------------------------------------------------------
--  DDL for Package Body HR_SALARY_SURVEY_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SALARY_SURVEY_MAPPING_API" as
/* $Header: pessmapi.pkb 115.6 2003/12/24 12:04:23 hsajja ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_salary_survey_mapping_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_mapping >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_mapping
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_parent_id                     in     number
  ,p_parent_table_name             in     varchar2
  ,p_salary_survey_line_id         in     number
  ,p_location_id                   in     number   default null
  ,p_grade_id                      in     number   default null
  ,p_company_organization_id       in     number   default null
  ,p_company_age_code              in     varchar2 default null
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
  ,p_salary_survey_mapping_id         out nocopy number
  ,p_object_version_number            out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_mapping';
  l_effective_date	date;
  l_salary_survey_mapping_id  number;
  l_object_version_number     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_mapping;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
/*
  begin
    per_ssm_api_bk1.create_mapping_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_parent_id                     => p_parent_id
      ,p_parent_table_name             => p_parent_table_name
      ,p_salary_survey_line_id         => p_salary_survey_line_id
      ,p_location_id                   => p_location_id
      ,p_grade_id                      => p_grade_id
      ,p_company_organization_id       => p_company_organization_id
      ,p_company_age_code              => p_company_age_code
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_MAPPING'
        ,p_hook_type   => 'BP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_ssm_ins.ins(
  		 p_object_version_number        => l_object_version_number
  		,p_salary_survey_mapping_id 	=> l_salary_survey_mapping_id
  		,p_parent_id                    => p_parent_id
  		,p_parent_table_name        	=> p_parent_table_name
  		,p_salary_survey_line_id   	=> p_salary_survey_line_id
  		,p_business_group_id         	=> p_business_group_id
  		,p_location_id                  => p_location_id
  		,p_grade_id    			=> p_grade_id
  		,p_company_organization_id  	=> p_company_organization_id
  		,p_company_age_code    		=> p_company_age_code
  		,p_attribute_category  		=> p_attribute_category
  		,p_attribute1  			=> p_attribute1
  		,p_attribute2  			=> p_attribute2
  		,p_attribute3  			=> p_attribute3
  		,p_attribute4  			=> p_attribute4
  		,p_attribute5  			=> p_attribute5
  		,p_attribute6  			=> p_attribute6
  		,p_attribute7  	 		=> p_attribute7
  		,p_attribute8   		=> p_attribute8
  		,p_attribute9   		=> p_attribute9
  		,p_attribute10  		=> p_attribute10
  		,p_attribute11  		=> p_attribute11
  		,p_attribute12  		=> p_attribute12
  		,p_attribute13  		=> p_attribute13
  		,p_attribute14  		=> p_attribute14
  		,p_attribute15  		=> p_attribute15
  		,p_attribute16  		=> p_attribute16
  		,p_attribute17  		=> p_attribute17
  		,p_attribute18  		=> p_attribute18
  		,p_attribute19  		=> p_attribute19
  		,p_attribute20  		=> p_attribute20
  		,p_effective_date 		=> l_effective_date
  		);


  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
/*
  begin
    per_ssm_api_bk1.create_mapping_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_parent_id                     => p_parent_id
      ,p_parent_table_name             => p_parent_table_name
      ,p_salary_survey_line_id         => p_salary_survey_line_id
      ,p_location_id                   => p_location_id
      ,p_grade_id                      => p_grade_id
      ,p_company_organization_id       => p_company_organization_id
      ,p_company_age_code              => p_company_age_code
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_salary_survey_mapping_id      => p_salary_survey_mapping_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_MAPPING'
        ,p_hook_type   => 'AP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_salary_survey_mapping_id := l_salary_survey_mapping_id;
  p_object_version_number    := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_mapping;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_salary_survey_mapping_id := null;
    p_object_version_number    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_salary_survey_mapping_id := null;
    p_object_version_number    := null;
    rollback to create_mapping;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_mapping;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_mapping >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_location_id                   in     number
  ,p_grade_id                      in     number
  ,p_company_organization_id       in     number
  ,p_company_age_code              in     varchar2
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
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_mapping';
  l_salary_survey_mapping_id  number;
  l_object_version_number     number;
  l_effective_date	      date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_mapping;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
/*
  begin
    per_ssm_api_bk2.update_mapping_b
      (p_effective_date                => p_effective_date
      ,p_location_id                   => p_location_id
      ,p_grade_id                      => p_grade_id
      ,p_company_organization_id       => p_company_organization_id
      ,p_company_age_code              => p_company_age_code
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_salary_survey_mapping_id      => p_salary_survey_mapping_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_mapping'
        ,p_hook_type   => 'BP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_ssm_upd.upd
  (p_object_version_number        => l_object_version_number
  ,p_salary_survey_mapping_id     => p_salary_survey_mapping_id
  ,p_location_id                  => p_location_id
  ,p_grade_id                     => p_grade_id
  ,p_company_organization_id      => p_company_organization_id
  ,p_company_age_code             => p_company_age_code
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
  ,p_effective_date		  => l_effective_date
  );

  p_object_version_number := l_object_version_number;
  hr_utility.set_location(l_proc||' SSM OVN: '||l_object_version_number,49);


  hr_utility.set_location(l_proc, 50);
/*
  --
  -- Call After Process User Hook
  --
  begin
    per_ssm_api_bk2.update_mapping_a
      (p_effective_date                => p_effective_date
      ,p_location_id                   => p_location_id
      ,p_grade_id                      => p_grade_id
      ,p_company_organization_id       => p_company_organization_id
      ,p_company_age_code              => p_company_age_code
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_salary_survey_mapping_id      => p_salary_survey_mapping_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_mapping'
        ,p_hook_type   => 'AP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_mapping;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  :=  l_object_version_number;
    rollback to update_mapping;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_mapping;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_mapping >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping
  (p_validate                      in     boolean  default false
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_mapping';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_mapping;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    per_ssm_api_bk3.delete_mapping_b
      (p_salary_survey_mapping_id      => p_salary_survey_mapping_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_MAPPING'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --



  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_ssm_del.del
         (p_salary_survey_mapping_id           => p_salary_survey_mapping_id
  	 ,p_object_version_number              => p_object_version_number
  	 );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_ssm_api_bk3.delete_mapping_a
      (p_salary_survey_mapping_id      => p_salary_survey_mapping_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_MAPPING'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_mapping;
    --
   when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_mapping;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_mapping;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< mass_update >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_update
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id		   in     number
  ,p_job_id                        in     number   default null
  ,p_position_id                   in     number   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72) := g_package||'mass_update';
  l_effective_date		date;
  l_salary_survey_mapping_id	number;
  l_object_version_number	number;
  l_job_id			number;
  l_business_group_id		number;
  l_date_from			date;
  l_date_to			date;
  l_parent_date_from		date;
  l_parent_date_to			date;
  l_max_date_from		date;
  l_min_date_to			date;
  l_parent_table_name		varchar2(30);
  l_company_organization_id     number;
  l_grade_id			number;
  --
  cursor csr_get_job_dates is
     select j.date_from, nvl(j.date_to, hr_api.g_eot)
     from per_jobs j
     where j.job_id = p_job_id;
  --
  -- Changes 13-Oct-99 SCNair (per_positions to hr_positions_f)Date tracked position req
  --
  cursor csr_get_position_dates is
     select p.date_effective, nvl(hr_general.get_position_date_end(p.position_id), hr_general.end_of_time)
     from hr_positions_f p
     where p.position_id = p_position_id
     and   p.effective_end_date = hr_general.end_of_time;
  --
  cursor csr_get_mappings(c_table_name per_salary_survey_mappings.parent_table_name%TYPE) is
     select ssm.location_id location_id,
	    ssm.grade_id grade_id,
            ssm.company_organization_id company_organization_id,
	    ssm.company_age_code company_age_code,
	    ssl.survey_job_name_code survey_job_name_code,
 	    ssl.survey_region_code survey_region_code,
	    ssl.survey_seniority_code survey_seniority_code,
	    ssl.company_size_code company_size_code,
	    ssl.industry_code industry_code,
	    max(ssl.end_date) max_end_date
     from per_salary_survey_mappings ssm,
	  per_salary_survey_lines ssl
     where nvl(p_job_id,p_position_id) = ssm.parent_id
     and ssl.salary_survey_line_id = ssm.salary_survey_line_id
     and parent_table_name = c_table_name
     group by ssm.location_id,
	      ssm.grade_id,
              ssm.company_organization_id,
	      ssm.company_age_code,
	      ssl.survey_job_name_code,
 	      ssl.survey_region_code,
	      ssl.survey_seniority_code,
	      ssl.company_size_code,
	      ssl.industry_code;

  --
  cursor csr_get_grade_dates(c_grade_id number) is
     select g.date_from, nvl(g.date_to,hr_api.g_eot)
     from per_grades g
     where grade_id = c_grade_id;
  --
  cursor csr_get_org_dates(c_org_id number) is
     select o.date_from, nvl(o.date_to,hr_api.g_eot)
     from hr_all_organization_units o
     where o.organization_id = c_org_id;
  --
  cursor csr_get_ssl_ids(c_survey_job_name_code varchar2
     			,c_survey_region_code varchar2
     			,c_survey_seniority_code varchar2
     			,c_company_size_code varchar2
     			,c_industry_code varchar2
     			,c_date_from date
			,c_date_to date) is
     select salary_survey_line_id
     from per_salary_survey_lines ssl
     where ssl.start_date between c_date_from and c_date_to
     and nvl(ssl.survey_job_name_code,hr_api.g_varchar2) = nvl(c_survey_job_name_code,hr_api.g_varchar2)
     and nvl(ssl.survey_region_code,hr_api.g_varchar2) = nvl(c_survey_region_code,hr_api.g_varchar2)
     and nvl(ssl.survey_seniority_code,hr_api.g_varchar2) = nvl(c_survey_seniority_code,hr_api.g_varchar2)
     and nvl(ssl.company_size_code,hr_api.g_varchar2) = nvl(c_company_size_code,hr_api.g_varchar2)
     and nvl(ssl.industry_code,hr_api.g_varchar2) = nvl(c_industry_code,hr_api.g_varchar2);


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint mass_update;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
/*
  begin
    per_ssm_api_bk4.mass_update_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_job_id                        => p_job_id
      ,p_position_id                   => p_position_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'MASS_UPDATE'
        ,p_hook_type   => 'BP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  If p_job_id is null and p_position_id is null then
     hr_utility.set_location(l_proc, 50);
     fnd_message.set_name('PER','PER_52497_SSM_JOB_POS_NULL');
     fnd_message.raise_error;
  Elsif p_job_id is not null and p_position_id is not null then
     hr_utility.set_location(l_proc, 60);
     fnd_message.set_name('PER','PER_52498_SSM_JOB_POS_CONT_VAL');
     fnd_message.raise_error;
  Elsif p_job_id is not null then
     hr_utility.set_location(l_proc, 70);
     l_parent_table_name := 'PER_JOBS';
     open csr_get_job_dates;
     fetch csr_get_job_dates into l_parent_date_from, l_parent_date_to;
     If csr_get_job_dates%NOTFOUND then
	hr_utility.set_location(l_proc, 80);
	close csr_get_job_dates;
	fnd_message.set_name('PER','PER_52483_SSM_INVL_JOB_ID');
	fnd_message.raise_error;
     Else
	hr_utility.set_location(l_proc, 90);
	close csr_get_job_dates;
	l_max_date_from := l_parent_date_from;
	--
	l_min_date_to := l_parent_date_to;
	--
	For csr_get_mappings_rec in csr_get_mappings(l_parent_table_name) loop
	   hr_utility.set_location(l_proc, 100);
	   l_max_date_from := l_parent_date_from;
	   l_min_date_to := l_parent_date_to;
	   If csr_get_mappings_rec.max_end_date > l_max_date_from then
	      hr_utility.set_location(l_proc, 115);
	      l_max_date_from := csr_get_mappings_rec.max_end_date;
	   End If;
	   If csr_get_mappings_rec.grade_id is not null then
	      hr_utility.set_location(l_proc, 120);
	      open csr_get_grade_dates(csr_get_mappings_rec.grade_id);
	      fetch csr_get_grade_dates into l_date_from, l_date_to;
	      close csr_get_grade_dates;
	      hr_utility.set_location(l_proc, 130);
	      If l_date_from > l_max_date_from then
		 hr_utility.set_location(l_proc, 140);
	         l_max_date_from := l_date_from;
	      End If;
	      If l_date_to < l_min_date_to then
		 hr_utility.set_location(l_proc, 150);
	         l_min_date_to := l_date_to;
	      End If;
	   End If;
	   --
	   If csr_get_mappings_rec.company_organization_id is not null then
	      hr_utility.set_location(l_proc, 160);
 	      open csr_get_org_dates(csr_get_mappings_rec.company_organization_id);
	      fetch csr_get_org_dates into l_date_from, l_date_to;
	      close csr_get_org_dates;
	      hr_utility.set_location(l_proc, 170);
	      If l_date_from > l_max_date_from then
		 hr_utility.set_location(l_proc, 180);
	         l_max_date_from := l_date_from;
	      End If;
	      If l_date_to < l_min_date_to then
		 hr_utility.set_location(l_proc, 190);
	         l_min_date_to := l_date_to;
	      End If;
	      hr_utility.set_location(l_proc, 192);
	   End If;
	   --
	   hr_utility.set_location(l_proc||' Location ID: '||csr_get_mappings_rec.location_id,195);
	   hr_utility.set_location(l_proc||' Grade ID: '||csr_get_mappings_rec.grade_id,196);
	   hr_utility.set_location(l_proc||' Org ID: '||csr_get_mappings_rec.company_organization_id,197);
	   hr_utility.set_location(l_proc||' Comp Age Code: '||csr_get_mappings_rec.company_age_code,198);
	   --
	   For csr_get_ssl_ids_rec in csr_get_ssl_ids(csr_get_mappings_rec.survey_job_name_code
     						     ,csr_get_mappings_rec.survey_region_code
			     			     ,csr_get_mappings_rec.survey_seniority_code
     						     ,csr_get_mappings_rec.company_size_code
     					     	     ,csr_get_mappings_rec.industry_code
     						     ,l_max_date_from
						     ,l_min_date_to) Loop
	      hr_utility.set_location(l_proc||' SSL ID: '||csr_get_ssl_ids_rec.salary_survey_line_id,199);
	      --
	      hr_utility.set_location(l_proc, 200);
	      create_mapping
  		(p_validate                      => FALSE
  		,p_effective_date                => l_effective_date
  		,p_business_group_id             => p_business_group_id
  		,p_parent_id                     => p_job_id
  		,p_parent_table_name             => l_parent_table_name
  		,p_salary_survey_line_id         => csr_get_ssl_ids_rec.salary_survey_line_id
  		,p_location_id                   => csr_get_mappings_rec.location_id
  		,p_grade_id                      => csr_get_mappings_rec.grade_id
  		,p_company_organization_id       => csr_get_mappings_rec.company_organization_id
  		,p_company_age_code              => csr_get_mappings_rec.company_age_code
  		,p_salary_survey_mapping_id      => l_salary_survey_mapping_id
  		,p_object_version_number         => l_object_version_number
  		);
	      hr_utility.set_location(l_proc, 210);
	   End loop;
	End Loop;
     End If;
  Elsif p_position_id is not null then
     l_parent_table_name := 'PER_POSITIONS';
     open csr_get_position_dates;
     fetch csr_get_position_dates into l_parent_date_from, l_parent_date_to;
     If csr_get_position_dates%NOTFOUND then
	close csr_get_position_dates;
	fnd_message.set_name('PER','PER_52486_SSM_INVL_POS_ID');
	fnd_message.raise_error;
     Else
	close csr_get_position_dates;
	l_max_date_from := l_parent_date_from;
	--
	l_min_date_to := l_parent_date_to;
	--
	For csr_get_mappings_rec in csr_get_mappings(l_parent_table_name) loop
	   hr_utility.set_location(l_proc, 300);
	   l_max_date_from := l_parent_date_from;
	   l_min_date_to := l_parent_date_to;
	   If csr_get_mappings_rec.max_end_date > l_max_date_from then
	      hr_utility.set_location(l_proc, 310);
	      l_max_date_from := csr_get_mappings_rec.max_end_date;
	   End If;
	   If csr_get_mappings_rec.grade_id is not null then
	      hr_utility.set_location(l_proc, 320);
	      open csr_get_grade_dates(csr_get_mappings_rec.grade_id);
	      fetch csr_get_grade_dates into l_date_from, l_date_to;
	      close csr_get_grade_dates;
	      hr_utility.set_location(l_proc, 330);
	      If l_date_from > l_max_date_from then
		 hr_utility.set_location(l_proc, 340);
	         l_max_date_from := l_date_from;
	      End If;
	      If l_date_to < l_min_date_to then
		 hr_utility.set_location(l_proc, 350);
	         l_min_date_to := l_date_to;
	      End If;
	   End If;
	   --
	   If csr_get_mappings_rec.company_organization_id is not null then
	      hr_utility.set_location(l_proc, 360);
 	      open csr_get_org_dates(csr_get_mappings_rec.company_organization_id);
	      fetch csr_get_org_dates into l_date_from, l_date_to;
	      close csr_get_org_dates;
	      hr_utility.set_location(l_proc, 370);
	      If l_date_from > l_max_date_from then
		 hr_utility.set_location(l_proc, 380);
	         l_max_date_from := l_date_from;
	      End If;
	      If l_date_to < l_min_date_to then
		 hr_utility.set_location(l_proc, 390);
	         l_min_date_to := l_date_to;
	      End If;
	      hr_utility.set_location(l_proc, 392);
	   End If;
	   --
	   hr_utility.set_location(l_proc||' Location ID: '||csr_get_mappings_rec.location_id,395);
	   hr_utility.set_location(l_proc||' Grade ID: '||csr_get_mappings_rec.grade_id,396);
	   hr_utility.set_location(l_proc||' Org ID: '||csr_get_mappings_rec.company_organization_id,397);
	   hr_utility.set_location(l_proc||' Comp Age Code: '||csr_get_mappings_rec.company_age_code,398);
	   --
	   For csr_get_ssl_ids_rec in csr_get_ssl_ids(csr_get_mappings_rec.survey_job_name_code
     						     ,csr_get_mappings_rec.survey_region_code
			     			     ,csr_get_mappings_rec.survey_seniority_code
     						     ,csr_get_mappings_rec.company_size_code
     					     	     ,csr_get_mappings_rec.industry_code
     						     ,l_max_date_from
						     ,l_min_date_to) Loop
	      hr_utility.set_location(l_proc||' SSL ID: '||csr_get_ssl_ids_rec.salary_survey_line_id,399);
	      --
	      hr_utility.set_location(l_proc, 400);
	      create_mapping
  		(p_validate                      => FALSE
  		,p_effective_date                => l_effective_date
  		,p_business_group_id             => p_business_group_id
  		,p_parent_id                     => p_position_id
  		,p_parent_table_name             => l_parent_table_name
  		,p_salary_survey_line_id         => csr_get_ssl_ids_rec.salary_survey_line_id
  		,p_location_id                   => csr_get_mappings_rec.location_id
  		,p_grade_id                      => csr_get_mappings_rec.grade_id
  		,p_company_organization_id       => csr_get_mappings_rec.company_organization_id
  		,p_company_age_code              => csr_get_mappings_rec.company_age_code
  		,p_salary_survey_mapping_id      => l_salary_survey_mapping_id
  		,p_object_version_number         => l_object_version_number
  		);
	      hr_utility.set_location(l_proc, 410);
	   End loop;
	End Loop;
     End If;
  End If;
  hr_utility.set_location(l_proc, 500);
  --
  -- Call After Process User Hook
  --
/*
  begin
    per_ssm_api_bk4.mass_update_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_job_id                        => p_job_id
      ,p_position_id                   => p_position_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'MASS_UPDATE'
        ,p_hook_type   => 'AP'
        );
  end;
*/
  hr_utility.set_location(l_proc, 510);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 520);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to mass_update;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 530);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to mass_update;
    hr_utility.set_location(' Leaving:'||l_proc, 540);
    raise;
end mass_update;
--
end hr_salary_survey_mapping_api;

/
