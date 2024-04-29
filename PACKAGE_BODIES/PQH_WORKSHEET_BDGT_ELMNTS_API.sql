--------------------------------------------------------
--  DDL for Package Body PQH_WORKSHEET_BDGT_ELMNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WORKSHEET_BDGT_ELMNTS_API" as
/* $Header: pqwelapi.pkb 115.3 2002/12/06 23:49:47 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_WORKSHEET_BDGT_ELMNTS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_WORKSHEET_BDGT_ELMNT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_WORKSHEET_BDGT_ELMNT
  (p_validate                       in  boolean   default false
  ,p_worksheet_bdgt_elmnt_id        out nocopy number
  ,p_worksheet_budget_set_id        in  number
  ,p_element_type_id                in  number
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_worksheet_bdgt_elmnt_id pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_WORKSHEET_BDGT_ELMNT';
  l_object_version_number pqh_worksheet_bdgt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_WORKSHEET_BDGT_ELMNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk1.create_WORKSHEET_BDGT_ELMNT_b
      (
       p_worksheet_budget_set_id        =>  p_worksheet_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_distribution_percentage        =>  p_distribution_percentage
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_WORKSHEET_BDGT_ELMNT
    --
  end;
  --
  PQH_WEL_ins.ins
    (
     p_worksheet_bdgt_elmnt_id       => l_worksheet_bdgt_elmnt_id
    ,p_worksheet_budget_set_id       => p_worksheet_budget_set_id
    ,p_element_type_id               => p_element_type_id
    ,p_distribution_percentage       => p_distribution_percentage
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk1.create_WORKSHEET_BDGT_ELMNT_a
      (
       p_worksheet_bdgt_elmnt_id        =>  l_worksheet_bdgt_elmnt_id
      ,p_worksheet_budget_set_id        =>  p_worksheet_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_distribution_percentage        =>  p_distribution_percentage
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_WORKSHEET_BDGT_ELMNT
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
  p_worksheet_bdgt_elmnt_id := l_worksheet_bdgt_elmnt_id;
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
    ROLLBACK TO create_WORKSHEET_BDGT_ELMNT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_worksheet_bdgt_elmnt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_worksheet_bdgt_elmnt_id := null;
    p_object_version_number  := null;
      --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_WORKSHEET_BDGT_ELMNT;
    raise;
    --
end create_WORKSHEET_BDGT_ELMNT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_WORKSHEET_BDGT_ELMNT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_WORKSHEET_BDGT_ELMNT
  (p_validate                       in  boolean   default false
  ,p_worksheet_bdgt_elmnt_id        in  number
  ,p_worksheet_budget_set_id        in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_WORKSHEET_BDGT_ELMNT';
  l_object_version_number pqh_worksheet_bdgt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_WORKSHEET_BDGT_ELMNT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk2.update_WORKSHEET_BDGT_ELMNT_b
      (
       p_worksheet_bdgt_elmnt_id        =>  p_worksheet_bdgt_elmnt_id
      ,p_worksheet_budget_set_id        =>  p_worksheet_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_distribution_percentage        =>  p_distribution_percentage
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_WORKSHEET_BDGT_ELMNT
    --
  end;
  --
  PQH_WEL_upd.upd
    (
     p_worksheet_bdgt_elmnt_id       => p_worksheet_bdgt_elmnt_id
    ,p_worksheet_budget_set_id       => p_worksheet_budget_set_id
    ,p_element_type_id               => p_element_type_id
    ,p_distribution_percentage       => p_distribution_percentage
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk2.update_WORKSHEET_BDGT_ELMNT_a
      (
       p_worksheet_bdgt_elmnt_id        =>  p_worksheet_bdgt_elmnt_id
      ,p_worksheet_budget_set_id        =>  p_worksheet_budget_set_id
      ,p_element_type_id                =>  p_element_type_id
      ,p_distribution_percentage        =>  p_distribution_percentage
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_WORKSHEET_BDGT_ELMNT
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
    ROLLBACK TO update_WORKSHEET_BDGT_ELMNT;
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
    ROLLBACK TO update_WORKSHEET_BDGT_ELMNT;
    raise;
    --
end update_WORKSHEET_BDGT_ELMNT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_WORKSHEET_BDGT_ELMNT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_WORKSHEET_BDGT_ELMNT
  (p_validate                       in  boolean  default false
  ,p_worksheet_bdgt_elmnt_id        in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_WORKSHEET_BDGT_ELMNT';
  l_object_version_number pqh_worksheet_bdgt_elmnts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_WORKSHEET_BDGT_ELMNT;
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
    -- Start of API User Hook for the before hook of delete_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk3.delete_WORKSHEET_BDGT_ELMNT_b
      (
       p_worksheet_bdgt_elmnt_id        =>  p_worksheet_bdgt_elmnt_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_WORKSHEET_BDGT_ELMNT
    --
  end;
  --
  PQH_WEL_del.del
    (
     p_worksheet_bdgt_elmnt_id       => p_worksheet_bdgt_elmnt_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_WORKSHEET_BDGT_ELMNT
    --
    pqh_WORKSHEET_BDGT_ELMNTS_bk3.delete_WORKSHEET_BDGT_ELMNT_a
      (
       p_worksheet_bdgt_elmnt_id        =>  p_worksheet_bdgt_elmnt_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_WORKSHEET_BDGT_ELMNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_WORKSHEET_BDGT_ELMNT
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
    ROLLBACK TO delete_WORKSHEET_BDGT_ELMNT;
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
    ROLLBACK TO delete_WORKSHEET_BDGT_ELMNT;
    raise;
    --
end delete_WORKSHEET_BDGT_ELMNT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_worksheet_bdgt_elmnt_id                   in     number
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
  PQH_WEL_shd.lck
    (
      p_worksheet_bdgt_elmnt_id                 => p_worksheet_bdgt_elmnt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_WORKSHEET_BDGT_ELMNTS_api;

/
