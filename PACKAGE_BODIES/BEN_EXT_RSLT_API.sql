--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RSLT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RSLT_API" as
/* $Header: bexrsapi.pkb 120.1 2005/06/08 14:27:15 tjesumic noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_RSLT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RSLT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RSLT
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_id                    out nocopy number
  ,p_run_strt_dt                    in  date      default null
  ,p_run_end_dt                     in  date      default null
  ,p_ext_stat_cd                    in  varchar2  default null
  ,p_tot_rec_num                    in  number    default null
  ,p_tot_per_num                    in  number    default null
  ,p_tot_err_num                    in  number    default null
  ,p_eff_dt                         in  date      default null
  ,p_ext_strt_dt                    in  date      default null
  ,p_ext_end_dt                     in  date      default null
  ,p_output_name                    in  varchar2  default null
  ,p_drctry_name                    in  varchar2  default null
  ,p_ext_dfn_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_request_id                     in  number    default null
  ,p_output_type                    in  varchar2  default null
  ,p_xdo_template_id                in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_rslt_id ben_ext_rslt.ext_rslt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_RSLT';
  l_object_version_number ben_ext_rslt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_RSLT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_RSLT
    --
    ben_EXT_RSLT_bk1.create_EXT_RSLT_b
      (
       p_run_strt_dt                    =>  p_run_strt_dt
      ,p_run_end_dt                     =>  p_run_end_dt
      ,p_ext_stat_cd                    =>  p_ext_stat_cd
      ,p_tot_rec_num                    =>  p_tot_rec_num
      ,p_tot_per_num                    =>  p_tot_per_num
      ,p_tot_err_num                    =>  p_tot_err_num
      ,p_eff_dt                         =>  p_eff_dt
      ,p_ext_strt_dt                    =>  p_ext_strt_dt
      ,p_ext_end_dt                     =>  p_ext_end_dt
      ,p_output_name                    =>  p_output_name
      ,p_drctry_name                    =>  p_drctry_name
      ,p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_output_type                    =>  p_output_type
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_RSLT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_RSLT
    --
  end;
  --
  ben_xrs_ins.ins
    (
     p_ext_rslt_id                   => l_ext_rslt_id
    ,p_run_strt_dt                   => p_run_strt_dt
    ,p_run_end_dt                    => p_run_end_dt
    ,p_ext_stat_cd                   => p_ext_stat_cd
    ,p_tot_rec_num                   => p_tot_rec_num
    ,p_tot_per_num                   => p_tot_per_num
    ,p_tot_err_num                   => p_tot_err_num
    ,p_eff_dt                        => p_eff_dt
    ,p_ext_strt_dt                   => p_ext_strt_dt
    ,p_ext_end_dt                    => p_ext_end_dt
    ,p_output_name                   => p_output_name
    ,p_drctry_name                   => p_drctry_name
    ,p_ext_dfn_id                    => p_ext_dfn_id
    ,p_business_group_id             => p_business_group_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_request_id                    => p_request_id
    ,p_output_type                    =>  p_output_type
    ,p_xdo_template_id                =>  p_xdo_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_RSLT
    --
    ben_EXT_RSLT_bk1.create_EXT_RSLT_a
      (
       p_ext_rslt_id                    =>  l_ext_rslt_id
      ,p_run_strt_dt                    =>  p_run_strt_dt
      ,p_run_end_dt                     =>  p_run_end_dt
      ,p_ext_stat_cd                    =>  p_ext_stat_cd
      ,p_tot_rec_num                    =>  p_tot_rec_num
      ,p_tot_per_num                    =>  p_tot_per_num
      ,p_tot_err_num                    =>  p_tot_err_num
      ,p_eff_dt                         =>  p_eff_dt
      ,p_ext_strt_dt                    =>  p_ext_strt_dt
      ,p_ext_end_dt                     =>  p_ext_end_dt
      ,p_output_name                    =>  p_output_name
      ,p_drctry_name                    =>  p_drctry_name
      ,p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_output_type                    =>  p_output_type
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_RSLT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_RSLT
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
  p_ext_rslt_id := l_ext_rslt_id;
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
    ROLLBACK TO create_EXT_RSLT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_rslt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_RSLT;
    p_ext_rslt_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_EXT_RSLT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RSLT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RSLT
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_id                    in  number
  ,p_run_strt_dt                    in  date      default hr_api.g_date
  ,p_run_end_dt                     in  date      default hr_api.g_date
  ,p_ext_stat_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_tot_rec_num                    in  number    default hr_api.g_number
  ,p_tot_per_num                    in  number    default hr_api.g_number
  ,p_tot_err_num                    in  number    default hr_api.g_number
  ,p_eff_dt                         in  date      default hr_api.g_date
  ,p_ext_strt_dt                    in  date      default hr_api.g_date
  ,p_ext_end_dt                     in  date      default hr_api.g_date
  ,p_output_name                    in  varchar2  default hr_api.g_varchar2
  ,p_drctry_name                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_dfn_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_output_type                    in  varchar2  default hr_api.g_varchar2
  ,p_xdo_template_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT';
  l_object_version_number ben_ext_rslt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_RSLT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_RSLT
    --
    ben_EXT_RSLT_bk2.update_EXT_RSLT_b
      (
       p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_run_strt_dt                    =>  p_run_strt_dt
      ,p_run_end_dt                     =>  p_run_end_dt
      ,p_ext_stat_cd                    =>  p_ext_stat_cd
      ,p_tot_rec_num                    =>  p_tot_rec_num
      ,p_tot_per_num                    =>  p_tot_per_num
      ,p_tot_err_num                    =>  p_tot_err_num
      ,p_eff_dt                         =>  p_eff_dt
      ,p_ext_strt_dt                    =>  p_ext_strt_dt
      ,p_ext_end_dt                     =>  p_ext_end_dt
      ,p_output_name                    =>  p_output_name
      ,p_drctry_name                    =>  p_drctry_name
      ,p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_output_type                    =>  p_output_type
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_RSLT
    --
  end;
  --
  ben_xrs_upd.upd
    (
     p_ext_rslt_id                   => p_ext_rslt_id
    ,p_run_strt_dt                   => p_run_strt_dt
    ,p_run_end_dt                    => p_run_end_dt
    ,p_ext_stat_cd                   => p_ext_stat_cd
    ,p_tot_rec_num                   => p_tot_rec_num
    ,p_tot_per_num                   => p_tot_per_num
    ,p_tot_err_num                   => p_tot_err_num
    ,p_eff_dt                        => p_eff_dt
    ,p_ext_strt_dt                   => p_ext_strt_dt
    ,p_ext_end_dt                    => p_ext_end_dt
    ,p_output_name                   => p_output_name
    ,p_drctry_name                   => p_drctry_name
    ,p_ext_dfn_id                    => p_ext_dfn_id
    ,p_business_group_id             => p_business_group_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_request_id                    => p_request_id
    ,p_output_type                    =>  p_output_type
      ,p_xdo_template_id                =>  p_xdo_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_RSLT
    --
    ben_EXT_RSLT_bk2.update_EXT_RSLT_a
      (
       p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_run_strt_dt                    =>  p_run_strt_dt
      ,p_run_end_dt                     =>  p_run_end_dt
      ,p_ext_stat_cd                    =>  p_ext_stat_cd
      ,p_tot_rec_num                    =>  p_tot_rec_num
      ,p_tot_per_num                    =>  p_tot_per_num
      ,p_tot_err_num                    =>  p_tot_err_num
      ,p_eff_dt                         =>  p_eff_dt
      ,p_ext_strt_dt                    =>  p_ext_strt_dt
      ,p_ext_end_dt                     =>  p_ext_end_dt
      ,p_output_name                    =>  p_output_name
      ,p_drctry_name                    =>  p_drctry_name
      ,p_ext_dfn_id                     =>  p_ext_dfn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_request_id                     =>  p_request_id
      ,p_output_type                    =>  p_output_type
      ,p_xdo_template_id                =>  p_xdo_template_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_RSLT
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
    ROLLBACK TO update_EXT_RSLT;
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
    ROLLBACK TO update_EXT_RSLT;
    raise;
    --
end update_EXT_RSLT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RSLT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT
  (p_validate                       in  boolean  default false
  ,p_ext_rslt_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT';
  l_object_version_number ben_ext_rslt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_RSLT;
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
    -- Start of API User Hook for the before hook of delete_EXT_RSLT
    --
    ben_EXT_RSLT_bk3.delete_EXT_RSLT_b
      (
       p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_RSLT
    --
  end;
  --
  ben_xrs_del.del
    (
     p_ext_rslt_id                   => p_ext_rslt_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_RSLT
    --
    ben_EXT_RSLT_bk3.delete_EXT_RSLT_a
      (
       p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_RSLT
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
    ROLLBACK TO delete_EXT_RSLT;
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
    ROLLBACK TO delete_EXT_RSLT;
    raise;
    --
end delete_EXT_RSLT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_rslt_id                   in     number
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
  ben_xrs_shd.lck
    (
      p_ext_rslt_id                 => p_ext_rslt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_RSLT_api;

/
