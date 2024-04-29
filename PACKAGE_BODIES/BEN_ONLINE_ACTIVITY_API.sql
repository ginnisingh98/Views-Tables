--------------------------------------------------------
--  DDL for Package Body BEN_ONLINE_ACTIVITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ONLINE_ACTIVITY_API" as
/* $Header: beolaapi.pkb 115.2 2002/12/13 08:29:54 bmanyam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_online_activity_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_online_activity >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_online_activity
  (p_validate                       in  boolean   default false
  ,p_csr_activities_id              out nocopy number
  ,p_ordr_num                       in  number    default null
  ,p_function_name                  in  varchar2  default null
  ,p_user_function_name             in  varchar2  default null
  ,p_function_type                  in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_start_date                     in  date      default null
  ,p_end_date                       in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_csr_activities_id ben_csr_activities.csr_activities_id%TYPE;
  l_proc varchar2(72) := g_package||'create_online_activity';
  l_object_version_number ben_csr_activities.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_online_activity;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_online_activity
    --
    ben_online_activity_bk1.create_online_activity_b
      (
       p_ordr_num                       =>  p_ordr_num
      ,p_function_name                  =>  p_function_name
      ,p_user_function_name             =>  p_user_function_name
      ,p_function_type                  =>  p_function_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_online_activity'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_online_activity
    --
  end;
  --
  ben_ola_ins.ins
    (
     p_csr_activities_id             => l_csr_activities_id
    ,p_ordr_num                      => p_ordr_num
    ,p_function_name                 => p_function_name
    ,p_user_function_name            => p_user_function_name
    ,p_function_type                 => p_function_type
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_online_activity
    --
    ben_online_activity_bk1.create_online_activity_a
      (
       p_csr_activities_id              =>  l_csr_activities_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_function_name                  =>  p_function_name
      ,p_user_function_name             =>  p_user_function_name
      ,p_function_type                  =>  p_function_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_online_activity'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_online_activity
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
  p_csr_activities_id := l_csr_activities_id;
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
    ROLLBACK TO create_online_activity;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_csr_activities_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_online_activity;
	-- NOCOPY changes
    p_csr_activities_id := null;
    p_object_version_number  := null;
    -- NOCOPY changes

    raise;
    --
end create_online_activity;
-- ----------------------------------------------------------------------------
-- |------------------------< update_online_activity >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_online_activity
  (p_validate                       in  boolean   default false
  ,p_csr_activities_id              in  number
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_function_name                  in  varchar2  default hr_api.g_varchar2
  ,p_user_function_name             in  varchar2  default hr_api.g_varchar2
  ,p_function_type                  in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     in  date      default hr_api.g_date
  ,p_end_date                       in  date      default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_online_activity';
  l_object_version_number ben_csr_activities.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_online_activity;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_online_activity
    --
    ben_online_activity_bk2.update_online_activity_b
      (
       p_csr_activities_id              =>  p_csr_activities_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_function_name                  =>  p_function_name
      ,p_user_function_name             =>  p_user_function_name
      ,p_function_type                  =>  p_function_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_online_activity'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_online_activity
    --
  end;
  --
  ben_ola_upd.upd
    (
     p_csr_activities_id             => p_csr_activities_id
    ,p_ordr_num                      => p_ordr_num
    ,p_function_name                 => p_function_name
    ,p_user_function_name            => p_user_function_name
    ,p_function_type                 => p_function_type
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_start_date                    => p_start_date
    ,p_end_date                      => p_end_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_online_activity
    --
    ben_online_activity_bk2.update_online_activity_a
      (
       p_csr_activities_id              =>  p_csr_activities_id
      ,p_ordr_num                       =>  p_ordr_num
      ,p_function_name                  =>  p_function_name
      ,p_user_function_name             =>  p_user_function_name
      ,p_function_type                  =>  p_function_type
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_start_date                     =>  p_start_date
      ,p_end_date                       =>  p_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_online_activity'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_online_activity
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
    ROLLBACK TO update_online_activity;
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
    ROLLBACK TO update_online_activity;
    raise;
    --
end update_online_activity;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_online_activity >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_online_activity
  (p_validate                       in  boolean  default false
  ,p_csr_activities_id              in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_online_activity';
  l_object_version_number ben_csr_activities.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_online_activity;
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
    -- Start of API User Hook for the before hook of delete_online_activity
    --
    ben_online_activity_bk3.delete_online_activity_b
      (
       p_csr_activities_id              =>  p_csr_activities_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_online_activity'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_online_activity
    --
  end;
  --
  ben_ola_del.del
    (
     p_csr_activities_id             => p_csr_activities_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_online_activity
    --
    ben_online_activity_bk3.delete_online_activity_a
      (
       p_csr_activities_id              =>  p_csr_activities_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_online_activity'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_online_activity
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
    ROLLBACK TO delete_online_activity;
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
    ROLLBACK TO delete_online_activity;
    raise;
    --
end delete_online_activity;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_csr_activities_id                   in     number
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
  ben_ola_shd.lck
    (
      p_csr_activities_id                 => p_csr_activities_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_online_activity_api;

/
