--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RCD_IN_FILE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RCD_IN_FILE_API" as
/* $Header: bexrfapi.pkb 120.1 2005/06/21 16:55:57 tjesumic noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_RCD_IN_FILE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RCD_IN_FILE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RCD_IN_FILE
  (p_validate                       in  boolean   default false
  ,p_ext_rcd_in_file_id             out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_sprs_cd                        in  varchar2  default null
  ,p_sort1_data_elmt_in_rcd_id      in  number    default null
  ,p_sort2_data_elmt_in_rcd_id      in  number    default null
  ,p_sort3_data_elmt_in_rcd_id      in  number    default null
  ,p_sort4_data_elmt_in_rcd_id      in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_ext_file_id                    in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_any_or_all_cd                  in  varchar2  default null
  ,p_hide_flag                      in  varchar2  default 'N'
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_chg_rcd_upd_flag               in  varchar2  default 'N'
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_rcd_in_file_id ben_ext_rcd_in_file.ext_rcd_in_file_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_RCD_IN_FILE';
  l_object_version_number ben_ext_rcd_in_file.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_RCD_IN_FILE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk1.create_EXT_RCD_IN_FILE_b
      (
       p_seq_num                        =>  p_seq_num
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_sort1_data_elmt_in_rcd_id      =>  p_sort1_data_elmt_in_rcd_id
      ,p_sort2_data_elmt_in_rcd_id      =>  p_sort2_data_elmt_in_rcd_id
      ,p_sort3_data_elmt_in_rcd_id      =>  p_sort3_data_elmt_in_rcd_id
      ,p_sort4_data_elmt_in_rcd_id      =>  p_sort4_data_elmt_in_rcd_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_hide_flag                      =>  p_hide_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_chg_rcd_upd_flag               =>  p_chg_rcd_upd_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_RCD_IN_FILE
    --
  end;
  --
  ben_xrf_ins.ins
    (
     p_ext_rcd_in_file_id            => l_ext_rcd_in_file_id
    ,p_seq_num                       => p_seq_num
    ,p_sprs_cd                       => p_sprs_cd
    ,p_sort1_data_elmt_in_rcd_id      =>  p_sort1_data_elmt_in_rcd_id
    ,p_sort2_data_elmt_in_rcd_id      =>  p_sort2_data_elmt_in_rcd_id
    ,p_sort3_data_elmt_in_rcd_id      =>  p_sort3_data_elmt_in_rcd_id
    ,p_sort4_data_elmt_in_rcd_id      =>  p_sort4_data_elmt_in_rcd_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_ext_file_id                   => p_ext_file_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_any_or_all_cd                 => p_any_or_all_cd
    ,p_hide_flag                     => p_hide_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_chg_rcd_upd_flag              => p_chg_rcd_upd_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk1.create_EXT_RCD_IN_FILE_a
      (
       p_ext_rcd_in_file_id             =>  l_ext_rcd_in_file_id
      ,p_seq_num                        =>  p_seq_num
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_sort1_data_elmt_in_rcd_id      =>  p_sort1_data_elmt_in_rcd_id
      ,p_sort2_data_elmt_in_rcd_id      =>  p_sort2_data_elmt_in_rcd_id
      ,p_sort3_data_elmt_in_rcd_id      =>  p_sort3_data_elmt_in_rcd_id
      ,p_sort4_data_elmt_in_rcd_id      =>  p_sort4_data_elmt_in_rcd_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_hide_flag                      =>  p_hide_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_chg_rcd_upd_flag               =>  p_chg_rcd_upd_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_RCD_IN_FILE
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
  p_ext_rcd_in_file_id := l_ext_rcd_in_file_id;
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
    ROLLBACK TO create_EXT_RCD_IN_FILE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_rcd_in_file_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_RCD_IN_FILE;
    p_ext_rcd_in_file_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_EXT_RCD_IN_FILE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RCD_IN_FILE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RCD_IN_FILE
  (p_validate                       in  boolean   default false
  ,p_ext_rcd_in_file_id             in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_sprs_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_sort1_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort2_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort3_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_sort4_data_elmt_in_rcd_id      in  number    default hr_api.g_number
  ,p_ext_rcd_id                     in  number    default hr_api.g_number
  ,p_ext_file_id                    in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_any_or_all_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_hide_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_chg_rcd_upd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RCD_IN_FILE';
  l_object_version_number ben_ext_rcd_in_file.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_RCD_IN_FILE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk2.update_EXT_RCD_IN_FILE_b
      (
       p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_seq_num                        =>  p_seq_num
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_sort1_data_elmt_in_rcd_id      =>  p_sort1_data_elmt_in_rcd_id
      ,p_sort2_data_elmt_in_rcd_id      =>  p_sort2_data_elmt_in_rcd_id
      ,p_sort3_data_elmt_in_rcd_id      =>  p_sort3_data_elmt_in_rcd_id
      ,p_sort4_data_elmt_in_rcd_id      =>  p_sort4_data_elmt_in_rcd_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_hide_flag                      =>  p_hide_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_chg_rcd_upd_flag               =>  p_chg_rcd_upd_flag
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_RCD_IN_FILE
    --
  end;
  --
  ben_xrf_upd.upd
    (
     p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    ,p_seq_num                       => p_seq_num
    ,p_sprs_cd                       => p_sprs_cd
    ,p_sort1_data_elmt_in_rcd_id     =>  p_sort1_data_elmt_in_rcd_id
    ,p_sort2_data_elmt_in_rcd_id     =>  p_sort2_data_elmt_in_rcd_id
    ,p_sort3_data_elmt_in_rcd_id     =>  p_sort3_data_elmt_in_rcd_id
    ,p_sort4_data_elmt_in_rcd_id     =>  p_sort4_data_elmt_in_rcd_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_ext_file_id                   => p_ext_file_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_any_or_all_cd                 => p_any_or_all_cd
    ,p_hide_flag                     => p_hide_flag
    ,p_rqd_flag                      => p_rqd_flag
    ,p_chg_rcd_upd_flag              => p_chg_rcd_upd_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk2.update_EXT_RCD_IN_FILE_a
      (
       p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_seq_num                        =>  p_seq_num
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_sort1_data_elmt_in_rcd_id      =>  p_sort1_data_elmt_in_rcd_id
      ,p_sort2_data_elmt_in_rcd_id      =>  p_sort2_data_elmt_in_rcd_id
      ,p_sort3_data_elmt_in_rcd_id      =>  p_sort3_data_elmt_in_rcd_id
      ,p_sort4_data_elmt_in_rcd_id      =>  p_sort4_data_elmt_in_rcd_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_ext_file_id                    =>  p_ext_file_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_hide_flag                      =>  p_hide_flag
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_chg_rcd_upd_flag               =>  p_chg_rcd_upd_flag
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_RCD_IN_FILE
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
    ROLLBACK TO update_EXT_RCD_IN_FILE;
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
    ROLLBACK TO update_EXT_RCD_IN_FILE;
    raise;
    --
end update_EXT_RCD_IN_FILE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RCD_IN_FILE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RCD_IN_FILE
  (p_validate                       in  boolean  default false
  ,p_ext_rcd_in_file_id             in  number
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RCD_IN_FILE';
  l_object_version_number ben_ext_rcd_in_file.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_RCD_IN_FILE;
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
    -- Start of API User Hook for the before hook of delete_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk3.delete_EXT_RCD_IN_FILE_b
      (
       p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_RCD_IN_FILE
    --
  end;
  --
  ben_xrf_del.del
    (
     p_ext_rcd_in_file_id            => p_ext_rcd_in_file_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_RCD_IN_FILE
    --
    ben_EXT_RCD_IN_FILE_bk3.delete_EXT_RCD_IN_FILE_a
      (
       p_ext_rcd_in_file_id             =>  p_ext_rcd_in_file_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RCD_IN_FILE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_RCD_IN_FILE
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
    ROLLBACK TO delete_EXT_RCD_IN_FILE;
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
    ROLLBACK TO delete_EXT_RCD_IN_FILE;
    raise;
    --
end delete_EXT_RCD_IN_FILE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_rcd_in_file_id                   in     number
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
  ben_xrf_shd.lck
    (
      p_ext_rcd_in_file_id                 => p_ext_rcd_in_file_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_RCD_IN_FILE_api;

/
