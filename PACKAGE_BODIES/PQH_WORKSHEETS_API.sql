--------------------------------------------------------
--  DDL for Package Body PQH_WORKSHEETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WORKSHEETS_API" as
/* $Header: pqwksapi.pkb 115.5 2002/12/06 23:49:58 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_WORKSHEETS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET
  (p_validate                       in  boolean   default false
  ,p_worksheet_id                   out nocopy number
  ,p_budget_id                      in  number
  ,p_worksheet_name                 in  varchar2
  ,p_version_number                 in  number
  ,p_action_date                    in  date
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_worksheet_mode_cd              in  varchar2  default null
  ,p_transaction_status             in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_version_id              in  number
  ,p_propagation_method             in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_wf_transaction_category_id     in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_worksheet_id pqh_worksheets.worksheet_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WORKSHEET';
  l_object_version_number pqh_worksheets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WORKSHEET;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WORKSHEET
    --
    pqh_WORKSHEETS_bk1.create_WORKSHEET_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_worksheet_name                 =>  p_worksheet_name
      ,p_version_number                 =>  p_version_number
      ,p_action_date                    =>  p_action_date
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_worksheet_mode_cd              =>  p_worksheet_mode_cd
      ,p_transaction_status             =>  p_transaction_status
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_wf_transaction_category_id     => p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WORKSHEET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WORKSHEET
    --
  end;
  --
  pqh_wks_ins.ins
    (
     p_worksheet_id                  => l_worksheet_id
    ,p_budget_id                     => p_budget_id
    ,p_worksheet_name                => p_worksheet_name
    ,p_version_number                => p_version_number
    ,p_action_date                   => p_action_date
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_worksheet_mode_cd             => p_worksheet_mode_cd
    ,p_transaction_status            => p_transaction_status
    ,p_object_version_number         => l_object_version_number
    ,p_budget_version_id             => p_budget_version_id
    ,p_propagation_method            => p_propagation_method
    ,p_effective_date                => trunc(p_effective_date)
    ,p_wf_transaction_category_id    => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WORKSHEET
    --
    pqh_WORKSHEETS_bk1.create_WORKSHEET_a
      (
       p_worksheet_id                   =>  l_worksheet_id
      ,p_budget_id                      =>  p_budget_id
      ,p_worksheet_name                 =>  p_worksheet_name
      ,p_version_number                 =>  p_version_number
      ,p_action_date                    =>  p_action_date
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_worksheet_mode_cd              =>  p_worksheet_mode_cd
      ,p_transaction_status             =>  p_transaction_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_wf_transaction_category_id     =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORKSHEET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WORKSHEET
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
  p_worksheet_id := l_worksheet_id;
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
    ROLLBACK TO create_WORKSHEET;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_worksheet_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_worksheet_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WORKSHEET;
    raise;
    --
end create_WORKSHEET;
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET
  (p_validate                       in  boolean   default false
  ,p_worksheet_id                   in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_worksheet_name                 in  varchar2  default hr_api.g_varchar2
  ,p_version_number                 in  number    default hr_api.g_number
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_worksheet_mode_cd              in  varchar2  default hr_api.g_varchar2
  ,p_transaction_status             in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_version_id              in  number    default hr_api.g_number
  ,p_propagation_method             in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_wf_transaction_category_id     in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WORKSHEET';
  l_object_version_number pqh_worksheets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WORKSHEET;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WORKSHEET
    --
    pqh_WORKSHEETS_bk2.update_WORKSHEET_b
      (
       p_worksheet_id                   =>  p_worksheet_id
      ,p_budget_id                      =>  p_budget_id
      ,p_worksheet_name                 =>  p_worksheet_name
      ,p_version_number                 =>  p_version_number
      ,p_action_date                    =>  p_action_date
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_worksheet_mode_cd              =>  p_worksheet_mode_cd
      ,p_transaction_status             =>  p_transaction_status
      ,p_object_version_number          =>  p_object_version_number
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_wf_transaction_category_id     =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WORKSHEET
    --
  end;
  --
  pqh_wks_upd.upd
    (
     p_worksheet_id                  => p_worksheet_id
    ,p_budget_id                     => p_budget_id
    ,p_worksheet_name                => p_worksheet_name
    ,p_version_number                => p_version_number
    ,p_action_date                   => p_action_date
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_worksheet_mode_cd             => p_worksheet_mode_cd
    ,p_transaction_status            => p_transaction_status
    ,p_object_version_number         => l_object_version_number
    ,p_budget_version_id             => p_budget_version_id
    ,p_propagation_method            => p_propagation_method
    ,p_effective_date                => trunc(p_effective_date)
    ,p_wf_transaction_category_id    => p_wf_transaction_category_id
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WORKSHEET
    --
    pqh_WORKSHEETS_bk2.update_WORKSHEET_a
      (
       p_worksheet_id                   =>  p_worksheet_id
      ,p_budget_id                      =>  p_budget_id
      ,p_worksheet_name                 =>  p_worksheet_name
      ,p_version_number                 =>  p_version_number
      ,p_action_date                    =>  p_action_date
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_worksheet_mode_cd              =>  p_worksheet_mode_cd
      ,p_transaction_status             =>  p_transaction_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_version_id              =>  p_budget_version_id
      ,p_propagation_method             =>  p_propagation_method
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_wf_transaction_category_id     =>  p_wf_transaction_category_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WORKSHEET
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
    ROLLBACK TO update_WORKSHEET;
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
    ROLLBACK TO update_WORKSHEET;
    raise;
    --
end update_WORKSHEET;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET
  (p_validate                       in  boolean  default false
  ,p_worksheet_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_WORKSHEET';
  l_object_version_number pqh_worksheets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WORKSHEET;
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
    -- Start of API User Hook for the before hook of delete_WORKSHEET
    --
    pqh_WORKSHEETS_bk3.delete_WORKSHEET_b
      (
       p_worksheet_id                   =>  p_worksheet_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WORKSHEET
    --
  end;
  --
  pqh_wks_del.del
    (
     p_worksheet_id                  => p_worksheet_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WORKSHEET
    --
    pqh_WORKSHEETS_bk3.delete_WORKSHEET_a
      (
       p_worksheet_id                   =>  p_worksheet_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WORKSHEET
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
    ROLLBACK TO delete_WORKSHEET;
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
    ROLLBACK TO delete_WORKSHEET;
    raise;
    --
end delete_WORKSHEET;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_worksheet_id                   in     number
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
  pqh_wks_shd.lck
    (
      p_worksheet_id                 => p_worksheet_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_WORKSHEETS_api;

/
