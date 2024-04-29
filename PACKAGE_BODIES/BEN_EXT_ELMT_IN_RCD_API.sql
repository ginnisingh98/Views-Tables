--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ELMT_IN_RCD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ELMT_IN_RCD_API" as
/* $Header: bexerapi.pkb 115.4 2002/12/13 06:53:25 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_ELMT_IN_RCD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_ELMT_IN_RCD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_ELMT_IN_RCD
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_in_rcd_id        out nocopy number
  ,p_seq_num                        in  number    default null
  ,p_strt_pos                       in  number    default null
  ,p_dlmtr_val                      in  varchar2  default null
  ,p_rqd_flag                       in  varchar2  default 'N'
  ,p_sprs_cd                        in  varchar2  default null
  ,p_any_or_all_cd                  in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_ext_rcd_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_hide_flag                      in  varchar2  default 'N'
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_data_elmt_in_rcd_id ben_ext_data_elmt_in_rcd.ext_data_elmt_in_rcd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_ELMT_IN_RCD';
  l_object_version_number ben_ext_data_elmt_in_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_ELMT_IN_RCD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk1.create_EXT_ELMT_IN_RCD_b
      (
       p_seq_num                        =>  p_seq_num
      ,p_strt_pos                       =>  p_strt_pos
      ,p_dlmtr_val                      =>  p_dlmtr_val
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_hide_flag                      =>  p_hide_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_ELMT_IN_RCD
    --
  end;
  --
  ben_xer_ins.ins
    (
     p_ext_data_elmt_in_rcd_id       => l_ext_data_elmt_in_rcd_id
    ,p_seq_num                       => p_seq_num
    ,p_strt_pos                      => p_strt_pos
    ,p_dlmtr_val                     => p_dlmtr_val
    ,p_rqd_flag                      => p_rqd_flag
    ,p_sprs_cd                       => p_sprs_cd
    ,p_any_or_all_cd                 => p_any_or_all_cd
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_hide_flag                     => p_hide_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk1.create_EXT_ELMT_IN_RCD_a
      (
       p_ext_data_elmt_in_rcd_id        =>  l_ext_data_elmt_in_rcd_id
      ,p_seq_num                        =>  p_seq_num
      ,p_strt_pos                       =>  p_strt_pos
      ,p_dlmtr_val                      =>  p_dlmtr_val
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_hide_flag                      =>  p_hide_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_ELMT_IN_RCD
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
  p_ext_data_elmt_in_rcd_id := l_ext_data_elmt_in_rcd_id;
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
    ROLLBACK TO create_EXT_ELMT_IN_RCD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_data_elmt_in_rcd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_ELMT_IN_RCD;
    raise;
    --
end create_EXT_ELMT_IN_RCD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_ELMT_IN_RCD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_ELMT_IN_RCD
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_seq_num                        in  number    default hr_api.g_number
  ,p_strt_pos                       in  number    default hr_api.g_number
  ,p_dlmtr_val                      in  varchar2  default hr_api.g_varchar2
  ,p_rqd_flag                       in  varchar2  default hr_api.g_varchar2
  ,p_sprs_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_any_or_all_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_ext_rcd_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_hide_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_ELMT_IN_RCD';
  l_object_version_number ben_ext_data_elmt_in_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_ELMT_IN_RCD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk2.update_EXT_ELMT_IN_RCD_b
      (
       p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_seq_num                        =>  p_seq_num
      ,p_strt_pos                       =>  p_strt_pos
      ,p_dlmtr_val                      =>  p_dlmtr_val
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_hide_flag                      =>  p_hide_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_ELMT_IN_RCD
    --
  end;
  --
  ben_xer_upd.upd
    (
     p_ext_data_elmt_in_rcd_id       => p_ext_data_elmt_in_rcd_id
    ,p_seq_num                       => p_seq_num
    ,p_strt_pos                      => p_strt_pos
    ,p_dlmtr_val                     => p_dlmtr_val
    ,p_rqd_flag                      => p_rqd_flag
    ,p_sprs_cd                       => p_sprs_cd
    ,p_any_or_all_cd                 => p_any_or_all_cd
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_ext_rcd_id                    => p_ext_rcd_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_hide_flag                     => p_hide_flag
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk2.update_EXT_ELMT_IN_RCD_a
      (
       p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_seq_num                        =>  p_seq_num
      ,p_strt_pos                       =>  p_strt_pos
      ,p_dlmtr_val                      =>  p_dlmtr_val
      ,p_rqd_flag                       =>  p_rqd_flag
      ,p_sprs_cd                        =>  p_sprs_cd
      ,p_any_or_all_cd                  =>  p_any_or_all_cd
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_hide_flag                      =>  p_hide_flag
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_ELMT_IN_RCD
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
    ROLLBACK TO update_EXT_ELMT_IN_RCD;
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
    ROLLBACK TO update_EXT_ELMT_IN_RCD;
    raise;
    --
end update_EXT_ELMT_IN_RCD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_ELMT_IN_RCD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_IN_RCD
  (p_validate                       in  boolean  default false
  ,p_ext_data_elmt_in_rcd_id        in  number
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_ELMT_IN_RCD';
  l_object_version_number ben_ext_data_elmt_in_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_ELMT_IN_RCD;
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
    -- Start of API User Hook for the before hook of delete_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk3.delete_EXT_ELMT_IN_RCD_b
      (
       p_ext_data_elmt_in_rcd_id        => p_ext_data_elmt_in_rcd_id
      ,p_legislation_code               => p_legislation_code
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_ELMT_IN_RCD
    --
  end;
  --
  ben_xer_del.del
    (
     p_ext_data_elmt_in_rcd_id       => p_ext_data_elmt_in_rcd_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_ELMT_IN_RCD
    --
    ben_EXT_ELMT_IN_RCD_bk3.delete_EXT_ELMT_IN_RCD_a
      (
       p_ext_data_elmt_in_rcd_id        =>  p_ext_data_elmt_in_rcd_id
      ,p_legislation_code               => p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_ELMT_IN_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_ELMT_IN_RCD
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
    ROLLBACK TO delete_EXT_ELMT_IN_RCD;
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
    ROLLBACK TO delete_EXT_ELMT_IN_RCD;
    raise;
    --
end delete_EXT_ELMT_IN_RCD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_data_elmt_in_rcd_id                   in     number
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
  ben_xer_shd.lck
    (
      p_ext_data_elmt_in_rcd_id                 => p_ext_data_elmt_in_rcd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_ELMT_IN_RCD_api;

/