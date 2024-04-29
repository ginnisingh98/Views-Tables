--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_PARAMETER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_PARAMETER_API" as
/* $Header: bebbpapi.pkb 115.3 2002/12/13 06:52:52 hmani ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_batch_parameter_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_batch_parameter >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_batch_parameter
  (p_validate                       in  boolean   default false
  ,p_batch_parameter_id             out nocopy number
  ,p_batch_exe_cd                   in  varchar2  default null
  ,p_thread_cnt_num                 in  number    default null
  ,p_max_err_num                    in  number    default null
  ,p_chunk_size                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_batch_parameter_id    ben_batch_parameter.batch_parameter_id%TYPE;
  l_proc                  varchar2(72) := g_package||'create_batch_parameter';
  l_object_version_number ben_batch_parameter.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_batch_parameter;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_batch_parameter
    --
    ben_batch_parameter_bk1.create_batch_parameter_b
      (p_batch_exe_cd                   => p_batch_exe_cd
      ,p_thread_cnt_num                 => p_thread_cnt_num
      ,p_max_err_num                    => p_max_err_num
      ,p_chunk_size                     => p_chunk_size
      ,p_business_group_id              => p_business_group_id
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_parameter'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_batch_parameter
    --
  end;
  --
  ben_bbp_ins.ins
    (p_batch_parameter_id            => l_batch_parameter_id
    ,p_batch_exe_cd                  => p_batch_exe_cd
    ,p_thread_cnt_num                => p_thread_cnt_num
    ,p_max_err_num                   => p_max_err_num
    ,p_chunk_size                    => p_chunk_size
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_batch_parameter
    --
    ben_batch_parameter_bk1.create_batch_parameter_a
      (p_batch_parameter_id             => l_batch_parameter_id
      ,p_batch_exe_cd                   => p_batch_exe_cd
      ,p_thread_cnt_num                 => p_thread_cnt_num
      ,p_max_err_num                    => p_max_err_num
      ,p_chunk_size                     => p_chunk_size
      ,p_business_group_id              => p_business_group_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_batch_parameter'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_batch_parameter
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
  p_batch_parameter_id := l_batch_parameter_id;
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
    ROLLBACK TO create_batch_parameter;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_batch_parameter_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_batch_parameter;
    raise;
    --
end create_batch_parameter;
-- ----------------------------------------------------------------------------
-- |------------------------< update_batch_parameter >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_batch_parameter
  (p_validate                       in  boolean   default false
  ,p_batch_parameter_id             in  number
  ,p_batch_exe_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_thread_cnt_num                 in  number    default hr_api.g_number
  ,p_max_err_num                    in  number    default hr_api.g_number
  ,p_chunk_size                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_batch_parameter';
  l_object_version_number ben_batch_parameter.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_batch_parameter;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_batch_parameter
    --
    ben_batch_parameter_bk2.update_batch_parameter_b
      (p_batch_parameter_id             => p_batch_parameter_id
      ,p_batch_exe_cd                   => p_batch_exe_cd
      ,p_thread_cnt_num                 => p_thread_cnt_num
      ,p_max_err_num                    => p_max_err_num
      ,p_chunk_size                     => p_chunk_size
      ,p_business_group_id              => p_business_group_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_parameter'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_batch_parameter
    --
  end;
  --
  ben_bbp_upd.upd
    (p_batch_parameter_id            => p_batch_parameter_id
    ,p_batch_exe_cd                  => p_batch_exe_cd
    ,p_thread_cnt_num                => p_thread_cnt_num
    ,p_max_err_num                   => p_max_err_num
    ,p_chunk_size                    => p_chunk_size
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_batch_parameter
    --
    ben_batch_parameter_bk2.update_batch_parameter_a
      (p_batch_parameter_id             => p_batch_parameter_id
      ,p_batch_exe_cd                   => p_batch_exe_cd
      ,p_thread_cnt_num                 => p_thread_cnt_num
      ,p_max_err_num                    => p_max_err_num
      ,p_chunk_size                     => p_chunk_size
      ,p_business_group_id              => p_business_group_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_batch_parameter'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_batch_parameter
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
    ROLLBACK TO update_batch_parameter;
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
    ROLLBACK TO update_batch_parameter;
    raise;
    --
end update_batch_parameter;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_batch_parameter >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_parameter
  (p_validate                       in  boolean  default false
  ,p_batch_parameter_id             in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_batch_parameter';
  l_object_version_number ben_batch_parameter.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_batch_parameter;
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
    -- Start of API User Hook for the before hook of delete_batch_parameter
    --
    ben_batch_parameter_bk3.delete_batch_parameter_b
      (p_batch_parameter_id             => p_batch_parameter_id
      ,p_object_version_number          => p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_parameter'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_batch_parameter
    --
  end;
  --
  ben_bbp_del.del
    (p_batch_parameter_id            => p_batch_parameter_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_batch_parameter
    --
    ben_batch_parameter_bk3.delete_batch_parameter_a
      (p_batch_parameter_id             => p_batch_parameter_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_batch_parameter'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_batch_parameter
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
    ROLLBACK TO delete_batch_parameter;
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
    ROLLBACK TO delete_batch_parameter;
    raise;
    --
end delete_batch_parameter;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_batch_parameter_id             in     number
  ,p_object_version_number          in     number) is
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
  ben_bbp_shd.lck
    (p_batch_parameter_id         => p_batch_parameter_id
    ,p_object_version_number      => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_batch_parameter_api;

/
