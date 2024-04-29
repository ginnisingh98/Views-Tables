--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_PREFS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_PREFS_API" as
/* $Header: pqcepapi.pkb 115.3 2002/12/05 19:31:15 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_copy_entity_prefs_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_pref >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_pref
  (p_validate                       in  boolean   default false
  ,p_copy_entity_pref_id            out nocopy number
  ,p_table_route_id                 in  number    default null
  ,p_copy_entity_txn_id             in  number    default null
  ,p_select_flag                    in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_copy_entity_pref_id pqh_copy_entity_prefs.copy_entity_pref_id%TYPE;
  l_proc varchar2(72) := g_package||'create_copy_entity_pref';
  l_object_version_number pqh_copy_entity_prefs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_copy_entity_pref;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk1.create_copy_entity_pref_b
      (
       p_table_route_id                 =>  p_table_route_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_select_flag                    =>  p_select_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_copy_entity_prefs
    --
  end;
  --
  pqh_cep_ins.ins
    (
     p_copy_entity_pref_id           => l_copy_entity_pref_id
    ,p_table_route_id                => p_table_route_id
    ,p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_select_flag                   => p_select_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk1.create_copy_entity_pref_a
      (
       p_copy_entity_pref_id            =>  l_copy_entity_pref_id
      ,p_table_route_id                 =>  p_table_route_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_select_flag                    =>  p_select_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_copy_entity_prefs
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
  p_copy_entity_pref_id := l_copy_entity_pref_id;
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
    ROLLBACK TO create_copy_entity_pref;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_copy_entity_pref_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_copy_entity_pref_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_copy_entity_pref;
    raise;
    --
end create_copy_entity_pref;
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_prefs >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_pref
  (p_validate                       in  boolean   default false
  ,p_copy_entity_pref_id            in  number
  ,p_table_route_id                 in  number    default hr_api.g_number
  ,p_copy_entity_txn_id             in  number    default hr_api.g_number
  ,p_select_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_pref';
  l_object_version_number pqh_copy_entity_prefs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_copy_entity_pref;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk2.update_copy_entity_pref_b
      (
       p_copy_entity_pref_id            =>  p_copy_entity_pref_id
      ,p_table_route_id                 =>  p_table_route_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_select_flag                    =>  p_select_flag
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_copy_entity_prefs
    --
  end;
  --
  pqh_cep_upd.upd
    (
     p_copy_entity_pref_id           => p_copy_entity_pref_id
    ,p_table_route_id                => p_table_route_id
    ,p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_select_flag                   => p_select_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk2.update_copy_entity_pref_a
      (
       p_copy_entity_pref_id            =>  p_copy_entity_pref_id
      ,p_table_route_id                 =>  p_table_route_id
      ,p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_select_flag                    =>  p_select_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_copy_entity_prefs
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
    ROLLBACK TO update_copy_entity_pref;
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
    ROLLBACK TO update_copy_entity_pref;
    raise;
    --
end update_copy_entity_pref;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_pref >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_pref
  (p_validate                       in  boolean  default false
  ,p_copy_entity_pref_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_copy_entity_pref';
  l_object_version_number pqh_copy_entity_prefs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_copy_entity_pref;
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
    -- Start of API User Hook for the before hook of delete_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk3.delete_copy_entity_pref_b
      (
       p_copy_entity_pref_id            =>  p_copy_entity_pref_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_copy_entity_prefs
    --
  end;
  --
  pqh_cep_del.del
    (
     p_copy_entity_pref_id           => p_copy_entity_pref_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_copy_entity_prefs
    --
    pqh_copy_entity_prefs_bk3.delete_copy_entity_pref_a
      (
       p_copy_entity_pref_id            =>  p_copy_entity_pref_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COPY_ENTITY_PREF'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_copy_entity_prefs
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
    ROLLBACK TO delete_copy_entity_pref;
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
    ROLLBACK TO delete_copy_entity_pref;
    raise;
    --
end delete_copy_entity_pref;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_copy_entity_pref_id                   in     number
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
  pqh_cep_shd.lck
    (
      p_copy_entity_pref_id                 => p_copy_entity_pref_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_copy_entity_prefs_api;

/
