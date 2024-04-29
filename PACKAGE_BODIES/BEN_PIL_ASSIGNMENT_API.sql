--------------------------------------------------------
--  DDL for Package Body BEN_PIL_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_ASSIGNMENT_API" as
/*  $Header: bepsgapi.pkb 120.0 2005/09/29 06:20:39 ssarkar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_pil_assignment_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_pil_assignment >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pil_assignment
  (
   p_validate                       in boolean       default false
  ,p_pil_assignment_id              out nocopy number
  ,p_per_in_ler_id                  in  number    default null
  ,p_applicant_assignment_id        in  number    default null
  ,p_offer_assignment_id            in  number    default null
  ,p_object_version_number          out nocopy number
   ) is
  --
  -- Declare cursors and local variables
  --
  l_pil_assignment_id       ben_pil_assignment.pil_assignment_id%TYPE;
  l_proc varchar2(72) :=    g_package||'create_pil_assignment';
  l_object_version_number   ben_pil_assignment.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_pil_assignment;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_pil_assignment
    --
    ben_pil_assignment_bk1.create_pil_assignment_b
      (
        p_per_in_ler_id                  => p_per_in_ler_id
       ,p_applicant_assignment_id        => p_applicant_assignment_id
       ,p_offer_assignment_id            => p_offer_assignment_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_pil_assignment'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_pil_assignment
    --
  end;
  --
  ben_psg_ins.ins
    (
     p_pil_assignment_id             => l_pil_assignment_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_applicant_assignment_id       => p_applicant_assignment_id
    ,p_offer_assignment_id           => p_offer_assignment_id
    ,p_object_version_number         => l_object_version_number

    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_pil_assignment
    --
    ben_pil_assignment_bk1.create_pil_assignment_a
      (
      p_pil_assignment_id              => l_pil_assignment_id
     ,p_per_in_ler_id                  => p_per_in_ler_id
     ,p_applicant_assignment_id        => p_applicant_assignment_id
     ,p_offer_assignment_id            => p_offer_assignment_id
     ,p_object_version_number          => l_object_version_number

    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_pil_assignment'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_pil_assignment
    --
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_pil_assignment_id     := l_pil_assignment_id;
  p_object_version_number := l_object_version_number;
  --

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_pil_assignment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pil_assignment_id      := null;
    p_object_version_number  := null;

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_pil_assignment;
    p_pil_assignment_id      := null;
    p_object_version_number  := null;
    raise;
    --
end create_pil_assignment;
-- ----------------------------------------------------------------------------
-- |------------------------< update_pil_assignment >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pil_assignment
  (
    p_validate                        in boolean    default false
   ,p_pil_assignment_id              in  number
   ,p_per_in_ler_id                  in  number    default hr_api.g_number
   ,p_applicant_assignment_id        in  number    default hr_api.g_number
   ,p_offer_assignment_id            in  number    default hr_api.g_number
   ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pil_assignment_id       ben_pil_assignment.pil_assignment_id%TYPE;
  l_proc varchar2(72)      := g_package||'update_pil_assignment';
  l_object_version_number  ben_pil_assignment.object_version_number%TYPE;
  --
begin

----hr_utility.trace_on(null,'TRACE-file');
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pil_assignment;
  --

  --
  -- Process Logic
  --
  l_pil_assignment_id     := p_pil_assignment_id;
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_pil_assignment
    --
    ben_pil_assignment_bk2.update_pil_assignment_b
      (
       p_pil_assignment_id              => l_pil_assignment_id
      ,p_per_in_ler_id                  => p_per_in_ler_id
      ,p_applicant_assignment_id        => p_applicant_assignment_id
      ,p_offer_assignment_id            => p_offer_assignment_id
      ,p_object_version_number          => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pil_assignment'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_pil_assignment
    --
  end;
  --
  ben_psg_upd.upd
    (
       p_pil_assignment_id              => l_pil_assignment_id
      ,p_per_in_ler_id                  => p_per_in_ler_id
      ,p_applicant_assignment_id        => p_applicant_assignment_id
      ,p_offer_assignment_id            => p_offer_assignment_id
      ,p_object_version_number          => l_object_version_number
   );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_pil_assignment
    --
    ben_pil_assignment_bk2.update_pil_assignment_a
      (
        p_pil_assignment_id               => l_pil_assignment_id
	,p_per_in_ler_id                  => p_per_in_ler_id
        ,p_applicant_assignment_id        => p_applicant_assignment_id
        ,p_offer_assignment_id            => p_offer_assignment_id
        ,p_object_version_number          => l_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_pil_assignment'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_pil_assignment
    --
  end;
  --

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

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_pil_assignment;
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
    ROLLBACK TO update_pil_assignment;
    raise;
    --
end update_pil_assignment;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pil_assignment >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pil_assignment
  (p_validate                       in  boolean  default false
  ,p_pil_assignment_id              in  number
  ,p_object_version_number          in out nocopy number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_pil_assignment';
  l_object_version_number ben_pil_assignment.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pil_assignment;
  --

  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_pil_assignment
    --
    ben_pil_assignment_bk3.delete_pil_assignment_b
      (
       p_pil_assignment_id              =>  p_pil_assignment_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pil_assignment'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_pil_assignment
    --
  end;
  --
  ben_psg_del.del
    (
     p_pil_assignment_id             => p_pil_assignment_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_pil_assignment
    --
    ben_pil_assignment_bk3.delete_pil_assignment_a
      (
       p_pil_assignment_id              =>  p_pil_assignment_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_pil_assignment'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_pil_assignment
    --
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_pil_assignment;
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
    ROLLBACK TO delete_pil_assignment;
    raise;
    --
end delete_pil_assignment;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pil_assignment_id              in     number
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
  ben_psg_shd.lck
    (
      p_pil_assignment_id          => p_pil_assignment_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end lck;
--
end ben_pil_assignment_api;

/
