--------------------------------------------------------
--  DDL for Package Body PQH_DFLT_FUND_SRCS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DFLT_FUND_SRCS_API" as
/* $Header: pqdfsapi.pkb 115.5 2002/11/27 23:43:12 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_dflt_fund_srcs_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_dflt_fund_src >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_dflt_fund_src
  (p_validate                       in  boolean   default false
  ,p_dflt_fund_src_id               out nocopy number
  ,p_dflt_budget_element_id         in  number    default null
  ,p_dflt_dist_percentage           in  number    default null
  ,p_project_id                     in  number    default null
  ,p_award_id                       in  number    default null
  ,p_task_id                        in  number    default null
  ,p_expenditure_type               in  varchar2  default null
  ,p_organization_id                in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_cost_allocation_keyflex_id     in  number    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dflt_fund_src_id pqh_dflt_fund_srcs.dflt_fund_src_id%TYPE;
  l_proc varchar2(72) := g_package||'create_dflt_fund_src';
  l_object_version_number pqh_dflt_fund_srcs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_dflt_fund_src;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk1.create_dflt_fund_src_b
      (
       p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_project_id                     =>  p_project_id
      ,p_award_id                       =>  p_award_id
      ,p_task_id                        =>  p_task_id
      ,p_expenditure_type               =>  p_expenditure_type
      ,p_organization_id                =>  p_organization_id
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_dflt_fund_src'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_dflt_fund_src
    --
  end;
  --
  pqh_dfs_ins.ins
    (
     p_dflt_fund_src_id              => l_dflt_fund_src_id
    ,p_dflt_budget_element_id        => p_dflt_budget_element_id
    ,p_dflt_dist_percentage          => p_dflt_dist_percentage
    ,p_project_id                    => p_project_id
    ,p_award_id                      => p_award_id
    ,p_task_id                       => p_task_id
    ,p_expenditure_type              => p_expenditure_type
    ,p_organization_id               => p_organization_id
    ,p_object_version_number         => l_object_version_number
    ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk1.create_dflt_fund_src_a
      (
       p_dflt_fund_src_id               =>  l_dflt_fund_src_id
      ,p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_project_id                     =>  p_project_id
      ,p_award_id                       =>  p_award_id
      ,p_task_id                        =>  p_task_id
      ,p_expenditure_type               =>  p_expenditure_type
      ,p_organization_id                =>  p_organization_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_dflt_fund_src'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_dflt_fund_src
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
  p_dflt_fund_src_id := l_dflt_fund_src_id;
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
    ROLLBACK TO create_dflt_fund_src;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dflt_fund_src_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_dflt_fund_src_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_dflt_fund_src;
    raise;
    --
end create_dflt_fund_src;
-- ----------------------------------------------------------------------------
-- |------------------------< update_dflt_fund_src >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_dflt_fund_src
  (p_validate                       in  boolean   default false
  ,p_dflt_fund_src_id               in  number
  ,p_dflt_budget_element_id         in  number    default hr_api.g_number
  ,p_dflt_dist_percentage           in  number    default hr_api.g_number
  ,p_project_id                     in  number    default hr_api.g_number
  ,p_award_id                       in  number    default hr_api.g_number
  ,p_task_id                        in  number    default hr_api.g_number
  ,p_expenditure_type               in  varchar2  default hr_api.g_varchar2
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_dflt_fund_src';
  l_object_version_number pqh_dflt_fund_srcs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_dflt_fund_src;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk2.update_dflt_fund_src_b
      (
       p_dflt_fund_src_id               =>  p_dflt_fund_src_id
      ,p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_project_id                     =>  p_project_id
      ,p_award_id                       =>  p_award_id
      ,p_task_id                        =>  p_task_id
      ,p_expenditure_type               =>  p_expenditure_type
      ,p_organization_id                =>  p_organization_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_fund_src'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_dflt_fund_src
    --
  end;
  --
  pqh_dfs_upd.upd
    (
     p_dflt_fund_src_id              => p_dflt_fund_src_id
    ,p_dflt_budget_element_id        => p_dflt_budget_element_id
    ,p_dflt_dist_percentage          => p_dflt_dist_percentage
    ,p_project_id                    => p_project_id
    ,p_award_id                      => p_award_id
    ,p_task_id                       => p_task_id
    ,p_expenditure_type              => p_expenditure_type
    ,p_organization_id               => p_organization_id
    ,p_object_version_number         => l_object_version_number
    ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk2.update_dflt_fund_src_a
      (
       p_dflt_fund_src_id               =>  p_dflt_fund_src_id
      ,p_dflt_budget_element_id         =>  p_dflt_budget_element_id
      ,p_dflt_dist_percentage           =>  p_dflt_dist_percentage
      ,p_project_id                     =>  p_project_id
      ,p_award_id                       =>  p_award_id
      ,p_task_id                        =>  p_task_id
      ,p_expenditure_type               =>  p_expenditure_type
      ,p_organization_id                =>  p_organization_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_dflt_fund_src'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_dflt_fund_src
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
    ROLLBACK TO update_dflt_fund_src;
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
    ROLLBACK TO update_dflt_fund_src;
    raise;
    --
end update_dflt_fund_src;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_dflt_fund_src >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_dflt_fund_src
  (p_validate                       in  boolean  default false
  ,p_dflt_fund_src_id               in  number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_dflt_fund_src';
  l_object_version_number pqh_dflt_fund_srcs.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_dflt_fund_src;
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
    -- Start of API User Hook for the before hook of delete_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk3.delete_dflt_fund_src_b
      (
       p_dflt_fund_src_id               =>  p_dflt_fund_src_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_fund_src'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_dflt_fund_src
    --
  end;
  --
  pqh_dfs_del.del
    (
     p_dflt_fund_src_id              => p_dflt_fund_src_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_dflt_fund_src
    --
    pqh_dflt_fund_srcs_bk3.delete_dflt_fund_src_a
      (
       p_dflt_fund_src_id               =>  p_dflt_fund_src_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_dflt_fund_src'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_dflt_fund_src
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
    ROLLBACK TO delete_dflt_fund_src;
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
    ROLLBACK TO delete_dflt_fund_src;
    raise;
    --
end delete_dflt_fund_src;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dflt_fund_src_id                   in     number
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
  pqh_dfs_shd.lck
    (
      p_dflt_fund_src_id                 => p_dflt_fund_src_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_dflt_fund_srcs_api;

/
