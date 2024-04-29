--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_LISTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_LISTS_API" as
/* $Header: pqrltapi.pkb 115.6 2002/12/06 18:08:13 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_ROUTING_LISTS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_routing_list >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_routing_list
  (p_validate                       in  boolean   default false
  ,p_routing_list_id                out nocopy number
  ,p_routing_list_name              in  varchar2
  ,p_enable_flag	            in  varchar2	default 'Y'
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_routing_list_id pqh_routing_lists.routing_list_id%TYPE;
  l_proc varchar2(72) := g_package||'create_routing_list';
  l_object_version_number pqh_routing_lists.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_routing_list;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_routing_list
    --
    PQH_ROUTING_LISTS_bk1.create_routing_list_b
      (
       p_routing_list_name              =>  p_routing_list_name ,
       p_enable_flag			=>  p_enable_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROUTING_LIST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_routing_list
    --
  end;
  --
  pqh_rlt_ins.ins
    (
     p_routing_list_id               => l_routing_list_id
    ,p_routing_list_name             => p_routing_list_name
    ,p_enable_flag		     => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_routing_list
    --
    PQH_ROUTING_LISTS_bk1.create_routing_list_a
      (
       p_routing_list_id                =>  l_routing_list_id
      ,p_routing_list_name              =>  p_routing_list_name
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROUTING_LIST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_routing_list
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
  p_routing_list_id := l_routing_list_id;
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
    ROLLBACK TO create_routing_list;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_routing_list_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_routing_list_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_routing_list;
    raise;
    --
end create_routing_list;
-- ----------------------------------------------------------------------------
-- |------------------------< update_routing_list >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list
  (p_validate                       in  boolean   default false
  ,p_routing_list_id                in  number
  ,p_routing_list_name              in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag		    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_routing_list';
  l_object_version_number pqh_routing_lists.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_routing_list;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_routing_list
    --
    PQH_ROUTING_LISTS_bk2.update_routing_list_b
      (
       p_routing_list_id                =>  p_routing_list_id
      ,p_routing_list_name              =>  p_routing_list_name
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_LIST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_routing_list
    --
  end;
  --
  pqh_rlt_upd.upd
    (
     p_routing_list_id               => p_routing_list_id
    ,p_routing_list_name             => p_routing_list_name
    ,p_enable_flag		     => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_routing_list
    --
    PQH_ROUTING_LISTS_bk2.update_routing_list_a
      (
       p_routing_list_id                =>  p_routing_list_id
      ,p_routing_list_name              =>  p_routing_list_name
      ,p_enable_flag			=>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_LIST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_routing_list
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
    ROLLBACK TO update_routing_list;
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
    ROLLBACK TO update_routing_list;
    raise;
    --
end update_routing_list;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_routing_list >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_routing_list
  (p_validate                       in  boolean  default false
  ,p_routing_list_id                in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_routing_list';
  l_object_version_number pqh_routing_lists.object_version_number%TYPE;
  --
  cursor c1 is
   select routing_list_member_id,object_version_number
   from pqh_routing_list_members
   where routing_list_id = p_routing_list_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_routing_list;
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
    -- Start of API User Hook for the before hook of delete_routing_list
    --
    PQH_ROUTING_LISTS_bk3.delete_routing_list_b
      (
       p_routing_list_id                =>  p_routing_list_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_LIST'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_routing_list
    --
  end;
  --
  for r_routing_list_members in c1 loop
  pqh_routing_list_members_api.delete_routing_list_member
    (
     p_validate                => false
    ,p_routing_list_member_id  => r_routing_list_members.routing_list_member_id
    ,p_object_version_number   => r_routing_list_members.object_version_number
    ,p_effective_date          => sysdate
    );
  end loop;
  --
  pqh_rlt_del.del
    (
     p_routing_list_id               => p_routing_list_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_routing_list
    --
    PQH_ROUTING_LISTS_bk3.delete_routing_list_a
      (
       p_routing_list_id                =>  p_routing_list_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_LIST'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_routing_list
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
    ROLLBACK TO delete_routing_list;
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
    ROLLBACK TO delete_routing_list;
    raise;
    --
end delete_routing_list;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_routing_list_id                   in     number
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
  pqh_rlt_shd.lck
    (
      p_routing_list_id                 => p_routing_list_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end PQH_ROUTING_LISTS_api;

/
