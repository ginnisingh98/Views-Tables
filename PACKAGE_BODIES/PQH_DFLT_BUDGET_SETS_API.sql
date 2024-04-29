--------------------------------------------------------
--  DDL for Package Body PQH_DFLT_BUDGET_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFLT_BUDGET_SETS_API" as
/* $Header: pqdstapi.pkb 115.4 2002/12/05 19:31:55 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_dflt_budget_sets_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_dflt_budget_set >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_budget_set
  (p_validate                       in  boolean   default false
  ,p_dflt_budget_set_id             out nocopy number
  ,p_dflt_budget_set_name           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dflt_budget_set_id pqh_dflt_budget_sets.dflt_budget_set_id%TYPE;
  l_proc varchar2(72) := g_package||'create_dflt_budget_set';
  l_object_version_number pqh_dflt_budget_sets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_dflt_budget_set;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk1.create_dflt_budget_set_b
      (
       p_dflt_budget_set_name           =>  p_dflt_budget_set_name
      ,p_business_group_id              =>  p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_dflt_budget_set'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_dflt_budget_set
    --
  end;
  --
  pqh_dst_ins.ins
    (
     p_dflt_budget_set_id            => l_dflt_budget_set_id
    ,p_dflt_budget_set_name          => p_dflt_budget_set_name
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk1.create_dflt_budget_set_a
      (
       p_dflt_budget_set_id             =>  l_dflt_budget_set_id
      ,p_dflt_budget_set_name           =>  p_dflt_budget_set_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_dflt_budget_set'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_dflt_budget_set
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
  p_dflt_budget_set_id := l_dflt_budget_set_id;
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
    ROLLBACK TO create_dflt_budget_set;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dflt_budget_set_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_dflt_budget_set_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_dflt_budget_set;
    raise;
    --
end create_dflt_budget_set;
-- ----------------------------------------------------------------------------
-- |------------------------< update_dflt_budget_set >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_budget_set
  (p_validate                       in  boolean   default false
  ,p_dflt_budget_set_id             in  number
  ,p_dflt_budget_set_name           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_dflt_budget_set';
  l_object_version_number pqh_dflt_budget_sets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_dflt_budget_set;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk2.update_dflt_budget_set_b
      (
       p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_dflt_budget_set_name           =>  p_dflt_budget_set_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_budget_set'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_dflt_budget_set
    --
  end;
  --
  pqh_dst_upd.upd
    (
     p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_dflt_budget_set_name          => p_dflt_budget_set_name
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk2.update_dflt_budget_set_a
      (
       p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_dflt_budget_set_name           =>  p_dflt_budget_set_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_budget_set'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_dflt_budget_set
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
    ROLLBACK TO update_dflt_budget_set;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_dflt_budget_set;
    raise;
    --
end update_dflt_budget_set;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_dflt_budget_set >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_set
  (p_validate                       in  boolean  default false
  ,p_dflt_budget_set_id             in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_dflt_budget_set';
  l_object_version_number pqh_dflt_budget_sets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_dflt_budget_set;
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
    -- Start of API User Hook for the before hook of delete_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk3.delete_dflt_budget_set_b
      (
       p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_budget_set'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_dflt_budget_set
    --
  end;
  --
  pqh_dst_del.del
    (
     p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_dflt_budget_set
    --
    pqh_dflt_budget_sets_bk3.delete_dflt_budget_set_a
      (
       p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_budget_set'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_dflt_budget_set
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
    ROLLBACK TO delete_dflt_budget_set;
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
    ROLLBACK TO delete_dflt_budget_set;
    raise;
    --
end delete_dflt_budget_set;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
/*
procedure lck
  (
   p_dflt_budget_set_id                   in     number
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
  pqh_dst_shd.lck
    (
      p_dflt_budget_set_id                 => p_dflt_budget_set_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
*/
--
end pqh_dflt_budget_sets_api;

/
