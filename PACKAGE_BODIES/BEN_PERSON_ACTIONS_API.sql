--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_ACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_ACTIONS_API" as
/* $Header: beactapi.pkb 120.0 2005/05/28 00:20:13 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_person_actions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_actions >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_actions
  (p_validate                       in  boolean   default false
  ,p_person_action_id               out nocopy number
  ,p_person_id                      in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_benefit_action_id              in  number    default null
  ,p_action_status_cd               in  varchar2  default null
  ,p_chunk_number                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_person_action_id ben_person_actions.person_action_id%TYPE;
  l_proc varchar2(72) := g_package||'create_person_actions';
  l_object_version_number ben_person_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_person_actions;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_person_actions
    --
    ben_person_actions_bk1.create_person_actions_b
      (
       p_person_id                      =>  p_person_id
      ,p_ler_id                         =>  p_ler_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_action_status_cd               =>  p_action_status_cd
      ,p_chunk_number                   =>  p_chunk_number
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_person_actions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_person_actions
    --
  end;
  --
  ben_act_ins.ins
    (
     p_person_action_id              => l_person_action_id
    ,p_person_id                     => p_person_id
    ,p_ler_id                        => p_ler_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_action_status_cd              => p_action_status_cd
    ,p_chunk_number                  => p_chunk_number
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_person_actions
    --
    ben_person_actions_bk1.create_person_actions_a
      (
       p_person_action_id               =>  l_person_action_id
      ,p_person_id                      =>  p_person_id
      ,p_ler_id                         =>  p_ler_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_action_status_cd               =>  p_action_status_cd
      ,p_chunk_number                   =>  p_chunk_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_person_actions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_person_actions
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
  p_person_action_id := l_person_action_id;
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
    ROLLBACK TO create_person_actions;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_action_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_person_action_id :=null;
    p_object_version_number := null;
    --
    ROLLBACK TO create_person_actions;
    raise;
    --
end create_person_actions;
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_actions >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_actions
  (p_validate                       in  boolean   default false
  ,p_person_action_id               in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_benefit_action_id              in  number    default hr_api.g_number
  ,p_action_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_chunk_number                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_person_actions';
  l_object_version_number ben_person_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_person_actions;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_person_actions
    --
    ben_person_actions_bk2.update_person_actions_b
      (
       p_person_action_id               =>  p_person_action_id
      ,p_person_id                      =>  p_person_id
      ,p_ler_id                         =>  p_ler_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_action_status_cd               =>  p_action_status_cd
      ,p_chunk_number                   =>  p_chunk_number
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_actions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_person_actions
    --
  end;
  --
  ben_act_upd.upd
    (
     p_person_action_id              => p_person_action_id
    ,p_person_id                     => p_person_id
    ,p_ler_id                        => p_ler_id
    ,p_benefit_action_id             => p_benefit_action_id
    ,p_action_status_cd              => p_action_status_cd
    ,p_chunk_number                  => p_chunk_number
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_person_actions
    --
    ben_person_actions_bk2.update_person_actions_a
      (
       p_person_action_id               =>  p_person_action_id
      ,p_person_id                      =>  p_person_id
      ,p_ler_id                         =>  p_ler_id
      ,p_benefit_action_id              =>  p_benefit_action_id
      ,p_action_status_cd               =>  p_action_status_cd
      ,p_chunk_number                   =>  p_chunk_number
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_actions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_person_actions
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
    ROLLBACK TO update_person_actions;
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
    p_object_version_number := l_object_version_number;
    --
    ROLLBACK TO update_person_actions;
    raise;
    --
end update_person_actions;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_actions >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_actions
  (p_validate                       in  boolean  default false
  ,p_person_action_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_person_actions';
  l_object_version_number ben_person_actions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_person_actions;
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
    -- Start of API User Hook for the before hook of delete_person_actions
    --
    ben_person_actions_bk3.delete_person_actions_b
      (
       p_person_action_id               =>  p_person_action_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_actions'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_person_actions
    --
  end;
  --
  ben_act_del.del
    (
     p_person_action_id              => p_person_action_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_person_actions
    --
    ben_person_actions_bk3.delete_person_actions_a
      (
       p_person_action_id               =>  p_person_action_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_actions'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_person_actions
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
    ROLLBACK TO delete_person_actions;
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
    p_object_version_number := l_object_version_number;
    --
    ROLLBACK TO delete_person_actions;
    raise;
    --
end delete_person_actions;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_person_action_id                   in     number
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
  ben_act_shd.lck
    (
      p_person_action_id                 => p_person_action_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_person_actions_api;

/
