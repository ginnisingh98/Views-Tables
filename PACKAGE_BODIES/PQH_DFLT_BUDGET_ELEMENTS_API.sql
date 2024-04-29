--------------------------------------------------------
--  DDL for Package Body PQH_DFLT_BUDGET_ELEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFLT_BUDGET_ELEMENTS_API" as
/* $Header: pqdelapi.pkb 115.4 2002/12/05 19:31:38 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_dflt_budget_elements_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_dflt_budget_element >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_budget_element
  (p_validate                       in  boolean   default false
  ,p_dflt_budget_element_id         out nocopy number
  ,p_dflt_budget_set_id             in  number    default null
  ,p_element_type_id                in  number    default null
  ,p_dflt_dist_percentage           in  number    default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dflt_budget_element_id pqh_dflt_budget_elements.dflt_budget_element_id%TYPE;
  l_proc varchar2(72) := g_package||'create_dflt_budget_element';
  l_object_version_number pqh_dflt_budget_elements.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_dflt_budget_element;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk1.create_dflt_budget_element_b
      (
       p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_dflt_budget_element'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_dflt_budget_element
    --
  end;
  --
  pqh_del_ins.ins
    (
     p_dflt_budget_element_id        => l_dflt_budget_element_id
    ,p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_element_type_id               => p_element_type_id
    ,p_dflt_dist_percentage          => p_dflt_dist_percentage
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk1.create_dflt_budget_element_a
      (
       p_dflt_budget_element_id         =>  l_dflt_budget_element_id
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_dflt_budget_element'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_dflt_budget_element
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
  p_dflt_budget_element_id := l_dflt_budget_element_id;
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
    ROLLBACK TO create_dflt_budget_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dflt_budget_element_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_dflt_budget_element_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_dflt_budget_element;
    raise;
    --
end create_dflt_budget_element;
-- ----------------------------------------------------------------------------
-- |------------------------< update_dflt_budget_element >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_budget_element
  (p_validate                       in  boolean   default false
  ,p_dflt_budget_element_id         in  number
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_dflt_dist_percentage           in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_dflt_budget_element';
  l_object_version_number pqh_dflt_budget_elements.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_dflt_budget_element;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk2.update_dflt_budget_element_b
      (
       p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_budget_element'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_dflt_budget_element
    --
  end;
  --
  pqh_del_upd.upd
    (
     p_dflt_budget_element_id        => p_dflt_budget_element_id
    ,p_dflt_budget_set_id            => p_dflt_budget_set_id
    ,p_element_type_id               => p_element_type_id
    ,p_dflt_dist_percentage          => p_dflt_dist_percentage
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk2.update_dflt_budget_element_a
      (
       p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_budget_set_id             =>  p_dflt_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_budget_element'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_dflt_budget_element
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
    ROLLBACK TO update_dflt_budget_element;
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
    ROLLBACK TO update_dflt_budget_element;
    raise;
    --
end update_dflt_budget_element;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_dflt_budget_element >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_budget_element
  (p_validate                       in  boolean  default false
  ,p_dflt_budget_element_id         in  number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_dflt_budget_element';
  l_object_version_number pqh_dflt_budget_elements.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_dflt_budget_element;
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
    -- Start of API User Hook for the before hook of delete_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk3.delete_dflt_budget_element_b
      (
       p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_budget_element'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_dflt_budget_element
    --
  end;
  --
  pqh_del_del.del
    (
     p_dflt_budget_element_id        => p_dflt_budget_element_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_dflt_budget_element
    --
    pqh_dflt_budget_elements_bk3.delete_dflt_budget_element_a
      (
       p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_budget_element'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_dflt_budget_element
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
    ROLLBACK TO delete_dflt_budget_element;
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
    ROLLBACK TO delete_dflt_budget_element;
    raise;
    --
end delete_dflt_budget_element;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dflt_budget_element_id                   in     number
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
  pqh_del_shd.lck
    (
      p_dflt_budget_element_id                 => p_dflt_budget_element_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_dflt_budget_elements_api;

/
