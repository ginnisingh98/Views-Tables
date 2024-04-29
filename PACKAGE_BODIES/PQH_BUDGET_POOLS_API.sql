--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_POOLS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_POOLS_API" as
/* $Header: pqbplapi.pkb 115.7 2003/03/03 12:16:00 ggnanagu noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_budget_pools_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_reallocation_folder
(
   p_validate                       in boolean
  ,p_effective_date                 in  date
  ,p_folder_id                      out nocopy number
  ,p_name                           in  varchar2
  ,p_budget_version_id              in  number
  ,p_budget_unit_id                 in  number
  ,p_entity_type                    in  varchar2
  ,p_approval_status                in  varchar2
  ,p_object_version_number          out nocopy  number
  ,p_business_group_id              in  number
  ,p_wf_transaction_category_id     in number

 )  is
  --
  -- Declare cursors and local variables
  --
  l_folder_id pqh_budget_pools.pool_id%TYPE;
  l_proc varchar2(72) := g_package||'create_reallocation_folder';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_reallocation_folder;
  --
  --
  -- Check for Mandatory Arguments before calling the row handler
  If p_budget_version_id IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => l_proc,
                                p_argument => 'budget version id',
                                p_argument_value => p_budget_version_id);
  End If;
  If p_budget_unit_id IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => l_proc,
                                p_argument => 'budget unit id',
                                p_argument_value => p_budget_unit_id);
  End If;
  If p_entity_type IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => l_proc,
                                p_argument => 'entity type',
                                p_argument_value => p_entity_type);
  End If;
  If p_approval_status IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => l_proc,
                                p_argument => 'approval status',
                                p_argument_value => p_approval_status);
  End If;

  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_reallocation_folder
    --
    pqh_budget_pools_bk1.create_reallocation_folder_b
      (
       p_name                           =>  p_name
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_budget_unit_id                 =>  p_budget_unit_id
      ,p_entity_type                    =>  p_entity_type
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      ,p_approval_status                =>  p_approval_status
      ,p_wf_transaction_category_id     =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_reallocation_folder
    --
  end;
  --
  pqh_bpl_ins.ins
    (
     p_pool_id                       => l_folder_id
    ,p_name                          => p_name
    ,p_budget_version_id             => p_budget_version_id
    ,p_budget_unit_id                => p_budget_unit_id
    ,p_entity_type                   => p_entity_type
    ,p_approval_status                =>  p_approval_status
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_business_group_id             =>  p_business_group_id
    ,p_wf_transaction_category_id    => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_reallocation_folder
    --
    pqh_budget_pools_bk1.create_reallocation_folder_a
      (
       p_folder_id                      =>  l_folder_id
      ,p_name                           =>  p_name
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_budget_unit_id                 =>  p_budget_unit_id
      ,p_entity_type                    =>  p_entity_type
      ,p_approval_status                =>  p_approval_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      ,p_wf_transaction_category_id     => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_reallocation_folder
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
  p_folder_id := l_folder_id;
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
    ROLLBACK TO create_reallocation_folder;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_folder_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_reallocation_folder;
    raise;
    --
end create_reallocation_folder;
-- ----------------------------------------------------------------------------
-- |------------------------< update_reallocation_folder >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_folder
  (
   p_validate                       in boolean
  ,p_effective_date                 in  date
  ,p_folder_id                      in  number
  ,p_name                           in  varchar2
  ,p_budget_version_id              in  number
  ,p_budget_unit_id                 in  number
  ,p_entity_type                    in  varchar2
  ,p_approval_status                in  varchar2
  ,p_object_version_number          in out nocopy  number
  ,p_business_group_id              in  number
  ,p_wf_transaction_category_id     in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reallocation_folder';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_reallocation_folder;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_reallocation_folder
    --
    pqh_budget_pools_bk2.update_reallocation_folder_b
      (
       p_folder_id                      =>  p_folder_id
      ,p_name                           =>  p_name
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_budget_unit_id                 =>  p_budget_unit_id
      ,p_entity_type                    =>  p_entity_type
      ,p_approval_status                =>  p_approval_status
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      ,p_wf_transaction_category_id     =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_reallocation_folder
    --
  end;
  --
  pqh_bpl_upd.upd
    (
     p_pool_id                       => p_folder_id
    ,p_name                          => p_name
    ,p_budget_version_id             => p_budget_version_id
    ,p_budget_unit_id                => p_budget_unit_id
    ,p_approval_status                =>  p_approval_status
    ,p_entity_type                   => p_entity_type
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_business_group_id             =>  p_business_group_id
    ,p_wf_transaction_category_id    => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_reallocation_folder
    --
    pqh_budget_pools_bk2.update_reallocation_folder_a
      (
       p_folder_id                      =>  p_folder_id
      ,p_name                           =>  p_name
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_budget_unit_id                 =>  p_budget_unit_id
      ,p_approval_status                =>  p_approval_status
      ,p_entity_type                    =>  p_entity_type
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_business_group_id             =>  p_business_group_id
      ,p_wf_transaction_category_id    =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_reallocation_folder
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
    ROLLBACK TO update_reallocation_flolder;
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
    ROLLBACK TO update_reallocation_folder;
    raise;
    --
end update_reallocation_folder;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_folder
  (p_validate                       in  boolean
  ,p_folder_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_reallocation_folder';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_reallocation_folder;
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
    -- Start of API User Hook for the before hook of delete_reallocation_folder
    --
    pqh_budget_pools_bk3.delete_reallocation_folder_b
      (
       p_folder_id                      =>  p_folder_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                   => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_reallocation_folder
    --
  end;
  --
  pqh_bpl_del.del
    (
     p_pool_id                       => p_folder_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_reallocation_folder
    --
    pqh_budget_pools_bk3.delete_reallocation_folder_a
      (
       p_folder_id                      =>  p_folder_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOCATION_FOLDER'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_reallocation_folder
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
    ROLLBACK TO delete_reallocation_folder;
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
    ROLLBACK TO delete_reallocation_folder;
    raise;
    --
end delete_reallocation_folder;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reallocation_txn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_reallocation_txn
(
   p_validate                       in boolean
  ,p_effective_date                 in  date
  ,p_transaction_id                 out nocopy number
  ,p_name                           in  varchar2
  ,p_parent_folder_id               in  number
  ,p_object_version_number          out nocopy number
  ,p_business_group_id              in  number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_transaction_id pqh_budget_pools.pool_id%TYPE;
  l_proc varchar2(72) := g_package||'create_reallocation_txn';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_reallocation_txn;
  --
  --
  -- Check for Mandatory Arguments before calling the row handler
  If p_parent_folder_id IS NULL THEN
     hr_api.mandatory_arg_error(p_api_name => l_proc,
                                p_argument => 'parent folder id',
                                p_argument_value => p_parent_folder_id);
  End If;
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_reallocation_txn
    --
    pqh_budget_pools_bk4.create_reallocation_txn_b
      (
       p_name                           =>  p_name
      ,p_parent_folder_id               =>  p_parent_folder_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_REALLOCATION_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_reallocation_txn
    --
  end;
  --
  pqh_bpl_ins.ins
    (
     p_pool_id                       => l_transaction_id
    ,p_name                          => p_name
    ,p_parent_pool_id              => p_parent_folder_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_business_group_id             => p_business_group_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_reallocation_txn
    --
    pqh_budget_pools_bk4.create_reallocation_txn_a
      (
       p_transaction_id                      =>  l_transaction_id
      ,p_name                           =>  p_name
      ,p_parent_folder_id               =>  p_parent_folder_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REALLOCATION_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_reallocation_txn
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
  p_transaction_id := l_transaction_id;
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
    ROLLBACK TO create_reallocation_txn;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_transaction_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_transaction_id := null;
    p_object_version_number  := null;
    ROLLBACK TO create_reallocation_txn;
    raise;
    --
end create_reallocation_txn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_reallocation_txn >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_reallocation_txn
  (
   p_validate                       in      boolean
  ,p_effective_date                 in      date
  ,p_transaction_id                 in      number
  ,p_name                           in      varchar2
  ,p_parent_folder_id               in      number
  ,p_object_version_number          in out  nocopy  number
  ,p_business_group_id              in      number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reallocation_txn';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_reallocation_txn;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_reallocation_txn
    --
     pqh_budget_pools_bk5.update_reallocation_txn_b
      (
       p_transaction_id                 =>  p_transaction_id
      ,p_name                           =>  p_name
      ,p_parent_folder_id               =>  p_parent_folder_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_business_group_id              =>  p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOCATION_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_reallocation_txn
    --
  end;
  --
  pqh_bpl_upd.upd
    (
     p_pool_id                       => p_transaction_id
    ,p_name                          => p_name
    ,p_parent_pool_id              => p_parent_folder_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_business_group_id             => p_business_group_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_reallocation_txn
    --
    pqh_budget_pools_bk5.update_reallocation_txn_a
      (
       p_transaction_id                 =>  p_transaction_id
      ,p_name                           =>  p_name
      ,p_parent_folder_id               =>  p_parent_folder_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_business_group_id             => p_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOCATION_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_reallocation_txn
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
    ROLLBACK TO update_reallocation_txn;
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
    ROLLBACK TO update_reallocation_txn;
    raise;
    --
end update_reallocation_txn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reallocation_txn >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reallocation_txn
  (p_validate                       in  boolean
  ,p_transaction_id                        in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_reallocation_txn';
  l_object_version_number pqh_budget_pools.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_reallocation_txn;
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
    -- Start of API User Hook for the before hook of delete_reallocation_txn
    --
    pqh_budget_pools_bk6.delete_reallocation_txn_b
      (
       p_transaction_id                 =>  p_transaction_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOCATION_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_reallocation_txn
    --
  end;
  --
  pqh_bpl_del.del
    (
     p_pool_id                       => p_transaction_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_reallocation_txn
    --
    pqh_budget_pools_bk6.delete_reallocation_txn_a
      (
       p_transaction_id                 =>  p_transaction_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOCATION_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_reallocation_txn
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
    ROLLBACK TO delete_reallocation_txn;
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
    ROLLBACK TO delete_reallocation_txn;
    raise;
    --
end delete_reallocation_txn;
--
--

end pqh_budget_pools_api;

/
