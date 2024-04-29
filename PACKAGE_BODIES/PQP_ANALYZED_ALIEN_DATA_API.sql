--------------------------------------------------------
--  DDL for Package Body PQP_ANALYZED_ALIEN_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ANALYZED_ALIEN_DATA_API" as
/* $Header: pqaadapi.pkb 115.4 2003/01/22 00:53:34 tmehra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'pqp_analyzed_alien_data_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_analyzed_alien_data >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_analyzed_alien_data
  (p_validate                       in  boolean   default false
  ,p_analyzed_data_id               out nocopy number
  ,p_assignment_id                  in  number    default null
  ,p_data_source                    in  varchar2  default null
  ,p_tax_year                       in  number    default null
  ,p_current_residency_status       in  varchar2  default null
  ,p_nra_to_ra_date                 in  date      default null
  ,p_target_departure_date          in  date      default null
  ,p_tax_residence_country_code     in  varchar2  default null
  ,p_treaty_info_update_date        in  date      default null
  ,p_number_of_days_in_usa          in  number    default null
  ,p_withldg_allow_eligible_flag    in  varchar2  default null
  ,p_ra_effective_date              in  date      default null
  ,p_record_source                  in  varchar2  default null
  ,p_visa_type                      in  varchar2  default null
  ,p_j_sub_type                     in  varchar2  default null
  ,p_primary_activity               in  varchar2  default null
  ,p_non_us_country_code            in  varchar2  default null
  ,p_citizenship_country_code       in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_date_8233_signed               in  date      default null
  ,p_date_w4_signed                 in  date      default null
  ) is
  -- p_date_8233_signed and p_date_w4_signed were added by Ashu Gupta
  -- on 07/27/2000
  --
  -- Declare cursors and local variables
  --
  l_analyzed_data_id pqp_analyzed_alien_data.analyzed_data_id%TYPE;
  l_proc varchar2(72) := g_package||'create_analyzed_alien_data';
  l_object_version_number pqp_analyzed_alien_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_analyzed_alien_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk1.create_analyzed_alien_data_b
      (
       p_assignment_id                  =>  p_assignment_id
      ,p_data_source                    =>  p_data_source
      ,p_tax_year                       =>  p_tax_year
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_withldg_allow_eligible_flag    =>  p_withldg_allow_eligible_flag
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_effective_date               => trunc(p_effective_date)
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_analyzed_alien_data
    --
  end;
  --
  pqp_aad_ins.ins
    (
     p_analyzed_data_id              => l_analyzed_data_id
    ,p_assignment_id                 => p_assignment_id
    ,p_data_source                   => p_data_source
    ,p_tax_year                      => p_tax_year
    ,p_current_residency_status      => p_current_residency_status
    ,p_nra_to_ra_date                => p_nra_to_ra_date
    ,p_target_departure_date         => p_target_departure_date
    ,p_tax_residence_country_code    => p_tax_residence_country_code
    ,p_treaty_info_update_date       => p_treaty_info_update_date
    ,p_number_of_days_in_usa         => p_number_of_days_in_usa
    ,p_withldg_allow_eligible_flag   => p_withldg_allow_eligible_flag
    ,p_ra_effective_date             => p_ra_effective_date
    ,p_record_source                 => p_record_source
    ,p_visa_type                     => p_visa_type
    ,p_j_sub_type                    => p_j_sub_type
    ,p_primary_activity              => p_primary_activity
    ,p_non_us_country_code           => p_non_us_country_code
    ,p_citizenship_country_code      => p_citizenship_country_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_date_8233_signed              =>  p_date_8233_signed
    ,p_date_w4_signed                =>  p_date_w4_signed
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk1.create_analyzed_alien_data_a
      (
       p_analyzed_data_id               =>  l_analyzed_data_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_data_source                    =>  p_data_source
      ,p_tax_year                       =>  p_tax_year
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_withldg_allow_eligible_flag    =>  p_withldg_allow_eligible_flag
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_analyzed_alien_data
    --
  end;
  --
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
  p_analyzed_data_id := l_analyzed_data_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_analyzed_alien_data;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_analyzed_data_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_analyzed_alien_data;
    p_analyzed_data_id := l_analyzed_data_id;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_analyzed_alien_data;
-- ----------------------------------------------------------------------------
-- |------------------------< update_analyzed_alien_data >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_analyzed_alien_data
  (p_validate                       in  boolean   default false
  ,p_analyzed_data_id               in  number
  ,p_assignment_id                  in  number    default hr_api.g_number
  ,p_data_source                    in  varchar2  default hr_api.g_varchar2
  ,p_tax_year                       in  number    default hr_api.g_number
  ,p_current_residency_status       in  varchar2  default hr_api.g_varchar2
  ,p_nra_to_ra_date                 in  date      default hr_api.g_date
  ,p_target_departure_date          in  date      default hr_api.g_date
  ,p_tax_residence_country_code     in  varchar2  default hr_api.g_varchar2
  ,p_treaty_info_update_date        in  date      default hr_api.g_date
  ,p_number_of_days_in_usa          in  number    default hr_api.g_number
  ,p_withldg_allow_eligible_flag    in  varchar2  default hr_api.g_varchar2
  ,p_ra_effective_date              in  date      default hr_api.g_date
  ,p_record_source                  in  varchar2  default hr_api.g_varchar2
  ,p_visa_type                      in  varchar2  default hr_api.g_varchar2
  ,p_j_sub_type                     in  varchar2  default hr_api.g_varchar2
  ,p_primary_activity               in  varchar2  default hr_api.g_varchar2
  ,p_non_us_country_code            in  varchar2  default hr_api.g_varchar2
  ,p_citizenship_country_code       in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_date_8233_signed               in  date      default hr_api.g_date
  ,p_date_w4_signed                 in  date      default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_analyzed_alien_data';
  l_object_version_number pqp_analyzed_alien_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_analyzed_alien_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk2.update_analyzed_alien_data_b
      (
       p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_data_source                    =>  p_data_source
      ,p_tax_year                       =>  p_tax_year
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_withldg_allow_eligible_flag    =>  p_withldg_allow_eligible_flag
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_analyzed_alien_data
    --
  end;
  --
  pqp_aad_upd.upd
    (
     p_analyzed_data_id              => p_analyzed_data_id
    ,p_assignment_id                 => p_assignment_id
    ,p_data_source                   => p_data_source
    ,p_tax_year                      => p_tax_year
    ,p_current_residency_status      => p_current_residency_status
    ,p_nra_to_ra_date                => p_nra_to_ra_date
    ,p_target_departure_date         => p_target_departure_date
    ,p_tax_residence_country_code    => p_tax_residence_country_code
    ,p_treaty_info_update_date       => p_treaty_info_update_date
    ,p_number_of_days_in_usa         => p_number_of_days_in_usa
    ,p_withldg_allow_eligible_flag   => p_withldg_allow_eligible_flag
    ,p_ra_effective_date             => p_ra_effective_date
    ,p_record_source                 => p_record_source
    ,p_visa_type                     => p_visa_type
    ,p_j_sub_type                    => p_j_sub_type
    ,p_primary_activity              => p_primary_activity
    ,p_non_us_country_code           => p_non_us_country_code
    ,p_citizenship_country_code      => p_citizenship_country_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_date_8233_signed              =>  p_date_8233_signed
    ,p_date_w4_signed                =>  p_date_w4_signed
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk2.update_analyzed_alien_data_a
      (
       p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_assignment_id                  =>  p_assignment_id
      ,p_data_source                    =>  p_data_source
      ,p_tax_year                       =>  p_tax_year
      ,p_current_residency_status       =>  p_current_residency_status
      ,p_nra_to_ra_date                 =>  p_nra_to_ra_date
      ,p_target_departure_date          =>  p_target_departure_date
      ,p_tax_residence_country_code     =>  p_tax_residence_country_code
      ,p_treaty_info_update_date        =>  p_treaty_info_update_date
      ,p_number_of_days_in_usa          =>  p_number_of_days_in_usa
      ,p_withldg_allow_eligible_flag    =>  p_withldg_allow_eligible_flag
      ,p_ra_effective_date              =>  p_ra_effective_date
      ,p_record_source                  =>  p_record_source
      ,p_visa_type                      =>  p_visa_type
      ,p_j_sub_type                     =>  p_j_sub_type
      ,p_primary_activity               =>  p_primary_activity
      ,p_non_us_country_code            =>  p_non_us_country_code
      ,p_citizenship_country_code       =>  p_citizenship_country_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      ,p_date_8233_signed               =>  p_date_8233_signed
      ,p_date_w4_signed                 =>  p_date_w4_signed
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_analyzed_alien_data
    --
  end;
  --
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_analyzed_alien_data;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_analyzed_alien_data;
    raise;
    --
end update_analyzed_alien_data;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_analyzed_alien_data >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_analyzed_alien_data
  (p_validate                       in  boolean  default false
  ,p_analyzed_data_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_analyzed_alien_data';
  l_object_version_number pqp_analyzed_alien_data.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_analyzed_alien_data;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk3.delete_analyzed_alien_data_b
      (
       p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_analyzed_alien_data
    --
  end;
  --
  pqp_aad_del.del
    (
     p_analyzed_data_id              => p_analyzed_data_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_analyzed_alien_data
    --
    pqp_analyzed_alien_data_bk3.delete_analyzed_alien_data_a
      (
       p_analyzed_data_id               =>  p_analyzed_data_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ANALYZED_ALIEN_DATA'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_analyzed_alien_data
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_analyzed_alien_data;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_analyzed_alien_data;
    raise;
    --
end delete_analyzed_alien_data;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_analyzed_data_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqp_aad_shd.lck
    (
      p_analyzed_data_id                 => p_analyzed_data_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqp_analyzed_alien_data_api;

/
