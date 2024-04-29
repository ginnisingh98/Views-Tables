--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_GL_FLEX_MAPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_GL_FLEX_MAPS_API" as
/* $Header: pqbgmapi.pkb 115.4 2002/12/05 16:33:20 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_budget_gl_flex_maps_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_gl_flex_map >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_gl_flex_map
  (p_validate                       in  boolean   default false
  ,p_budget_gl_flex_map_id          out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_gl_account_segment             in  varchar2  default null
  ,p_payroll_cost_segment           in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_budget_gl_flex_map_id pqh_budget_gl_flex_maps.budget_gl_flex_map_id%TYPE;
  l_proc varchar2(72) := g_package||'create_budget_gl_flex_map';
  l_object_version_number pqh_budget_gl_flex_maps.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_budget_gl_flex_map;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk1.create_budget_gl_flex_map_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_gl_account_segment             =>  p_gl_account_segment
      ,p_payroll_cost_segment           =>  p_payroll_cost_segment
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_budget_gl_flex_map'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_budget_gl_flex_map
    --
  end;
  --
  pqh_bgm_ins.ins
    (
     p_budget_gl_flex_map_id         => l_budget_gl_flex_map_id
    ,p_budget_id                     => p_budget_id
    ,p_gl_account_segment            => p_gl_account_segment
    ,p_payroll_cost_segment          => p_payroll_cost_segment
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk1.create_budget_gl_flex_map_a
      (
       p_budget_gl_flex_map_id          =>  l_budget_gl_flex_map_id
      ,p_budget_id                      =>  p_budget_id
      ,p_gl_account_segment             =>  p_gl_account_segment
      ,p_payroll_cost_segment           =>  p_payroll_cost_segment
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_budget_gl_flex_map'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_budget_gl_flex_map
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
  p_budget_gl_flex_map_id := l_budget_gl_flex_map_id;
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
    ROLLBACK TO create_budget_gl_flex_map;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_budget_gl_flex_map_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_budget_gl_flex_map_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_budget_gl_flex_map;
    raise;
    --
end create_budget_gl_flex_map;
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_gl_flex_map >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_gl_flex_map
  (p_validate                       in  boolean   default false
  ,p_budget_gl_flex_map_id          in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_gl_account_segment             in  varchar2  default hr_api.g_varchar2
  ,p_payroll_cost_segment           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_budget_gl_flex_map';
  l_object_version_number pqh_budget_gl_flex_maps.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_budget_gl_flex_map;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk2.update_budget_gl_flex_map_b
      (
       p_budget_gl_flex_map_id          =>  p_budget_gl_flex_map_id
      ,p_budget_id                      =>  p_budget_id
      ,p_gl_account_segment             =>  p_gl_account_segment
      ,p_payroll_cost_segment           =>  p_payroll_cost_segment
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget_gl_flex_map'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_budget_gl_flex_map
    --
  end;
  --
  pqh_bgm_upd.upd
    (
     p_budget_gl_flex_map_id         => p_budget_gl_flex_map_id
    ,p_budget_id                     => p_budget_id
    ,p_gl_account_segment            => p_gl_account_segment
    ,p_payroll_cost_segment          => p_payroll_cost_segment
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk2.update_budget_gl_flex_map_a
      (
       p_budget_gl_flex_map_id          =>  p_budget_gl_flex_map_id
      ,p_budget_id                      =>  p_budget_id
      ,p_gl_account_segment             =>  p_gl_account_segment
      ,p_payroll_cost_segment           =>  p_payroll_cost_segment
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget_gl_flex_map'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_budget_gl_flex_map
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
    ROLLBACK TO update_budget_gl_flex_map;
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
    ROLLBACK TO update_budget_gl_flex_map;
    raise;
    --
end update_budget_gl_flex_map;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_budget_gl_flex_map >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_gl_flex_map
  (p_validate                       in  boolean  default false
  ,p_budget_gl_flex_map_id          in  number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_budget_gl_flex_map';
  l_object_version_number pqh_budget_gl_flex_maps.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_budget_gl_flex_map;
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
    -- Start of API User Hook for the before hook of delete_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk3.delete_budget_gl_flex_map_b
      (
       p_budget_gl_flex_map_id          =>  p_budget_gl_flex_map_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget_gl_flex_map'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_budget_gl_flex_map
    --
  end;
  --
  pqh_bgm_del.del
    (
     p_budget_gl_flex_map_id         => p_budget_gl_flex_map_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_budget_gl_flex_map
    --
    pqh_budget_gl_flex_maps_bk3.delete_budget_gl_flex_map_a
      (
       p_budget_gl_flex_map_id          =>  p_budget_gl_flex_map_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget_gl_flex_map'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_budget_gl_flex_map
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
    ROLLBACK TO delete_budget_gl_flex_map;
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
    ROLLBACK TO delete_budget_gl_flex_map;
    raise;
    --
end delete_budget_gl_flex_map;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_budget_gl_flex_map_id                   in     number
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
  pqh_bgm_shd.lck
    (
      p_budget_gl_flex_map_id                 => p_budget_gl_flex_map_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_budget_gl_flex_maps_api;

/
