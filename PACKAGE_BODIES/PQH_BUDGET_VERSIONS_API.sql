--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_VERSIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_VERSIONS_API" as
/* $Header: pqbvrapi.pkb 115.7 2002/12/05 19:30:21 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_budget_versions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_version >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_budget_version
  (p_validate                       in  boolean   default false
  ,p_budget_version_id              out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_version_number                 in  number    default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_transfered_to_gl_flag          in  varchar2  default null
  ,p_gl_status                      in  varchar2  default null
  ,p_xfer_to_other_apps_cd          in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_budget_version_id pqh_budget_versions.budget_version_id%TYPE;
  l_proc varchar2(72) := g_package||'create_budget_version';
  l_object_version_number pqh_budget_versions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_budget_version;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_budget_version
    --
    pqh_budget_versions_bk1.create_budget_version_b
      (
       p_budget_id                      =>  p_budget_id
      ,p_version_number                 =>  p_version_number
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_transfered_to_gl_flag          =>  p_transfered_to_gl_flag
      ,p_gl_status                      =>  p_gl_status
      ,p_xfer_to_other_apps_cd          =>  p_xfer_to_other_apps_cd
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_budget_version'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_budget_version
    --
  end;
  --
  pqh_bvr_ins.ins
    (
     p_budget_version_id             => l_budget_version_id
    ,p_budget_id                     => p_budget_id
    ,p_version_number                => p_version_number
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_transfered_to_gl_flag         => p_transfered_to_gl_flag
    ,p_gl_status                     => p_gl_status
    ,p_xfer_to_other_apps_cd         => p_xfer_to_other_apps_cd
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_budget_version
    --
    pqh_budget_versions_bk1.create_budget_version_a
      (
       p_budget_version_id              =>  l_budget_version_id
      ,p_budget_id                      =>  p_budget_id
      ,p_version_number                 =>  p_version_number
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_transfered_to_gl_flag          =>  p_transfered_to_gl_flag
      ,p_gl_status                      =>  p_gl_status
      ,p_xfer_to_other_apps_cd          =>  p_xfer_to_other_apps_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_budget_version'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_budget_version
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
  p_budget_version_id := l_budget_version_id;
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
    ROLLBACK TO create_budget_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_budget_version_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_budget_version_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_budget_version;
    raise;
    --
end create_budget_version;
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_version >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_budget_version
  (p_validate                       in  boolean   default false
  ,p_budget_version_id              in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_version_number                 in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_transfered_to_gl_flag          in  varchar2  default hr_api.g_varchar2
  ,p_gl_status                      in  varchar2  default hr_api.g_varchar2
  ,p_xfer_to_other_apps_cd          in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_budget_version';
  l_object_version_number pqh_budget_versions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_budget_version;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_budget_version
    --
    pqh_budget_versions_bk2.update_budget_version_b
      (
       p_budget_version_id              =>  p_budget_version_id
      ,p_budget_id                      =>  p_budget_id
      ,p_version_number                 =>  p_version_number
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_transfered_to_gl_flag          =>  p_transfered_to_gl_flag
      ,p_gl_status                      =>  p_gl_status
      ,p_xfer_to_other_apps_cd          =>  p_xfer_to_other_apps_cd
      ,p_object_version_number          =>  p_object_version_number
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget_version'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_budget_version
    --
  end;
  --
  pqh_bvr_upd.upd
    (
     p_budget_version_id             => p_budget_version_id
    ,p_budget_id                     => p_budget_id
    ,p_version_number                => p_version_number
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_transfered_to_gl_flag         => p_transfered_to_gl_flag
    ,p_gl_status                     => p_gl_status
    ,p_xfer_to_other_apps_cd         => p_xfer_to_other_apps_cd
    ,p_object_version_number         => l_object_version_number
    ,p_budget_unit1_value            => p_budget_unit1_value
    ,p_budget_unit2_value            => p_budget_unit2_value
    ,p_budget_unit3_value            => p_budget_unit3_value
    ,p_budget_unit1_available        => p_budget_unit1_available
    ,p_budget_unit2_available        => p_budget_unit2_available
    ,p_budget_unit3_available        => p_budget_unit3_available
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_budget_version
    --
    pqh_budget_versions_bk2.update_budget_version_a
      (
       p_budget_version_id              =>  p_budget_version_id
      ,p_budget_id                      =>  p_budget_id
      ,p_version_number                 =>  p_version_number
      ,p_date_from                      =>  p_date_from
      ,p_date_to                        =>  p_date_to
      ,p_transfered_to_gl_flag          =>  p_transfered_to_gl_flag
      ,p_gl_status                      =>  p_gl_status
      ,p_xfer_to_other_apps_cd          =>  p_xfer_to_other_apps_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_budget_unit1_value             =>  p_budget_unit1_value
      ,p_budget_unit2_value             =>  p_budget_unit2_value
      ,p_budget_unit3_value             =>  p_budget_unit3_value
      ,p_budget_unit1_available         =>  p_budget_unit1_available
      ,p_budget_unit2_available         =>  p_budget_unit2_available
      ,p_budget_unit3_available         =>  p_budget_unit3_available
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_budget_version'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_budget_version
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
    ROLLBACK TO update_budget_version;
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
    ROLLBACK TO update_budget_version;
    raise;
    --
end update_budget_version;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_budget_version >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_budget_version
  (p_validate                       in  boolean  default false
  ,p_budget_version_id              in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_budget_version';
  l_object_version_number pqh_budget_versions.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_budget_version;
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
    -- Start of API User Hook for the before hook of delete_budget_version
    --
    pqh_budget_versions_bk3.delete_budget_version_b
      (
       p_budget_version_id              =>  p_budget_version_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget_version'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_budget_version
    --
  end;
  --
  pqh_bvr_del.del
    (
     p_budget_version_id             => p_budget_version_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_budget_version
    --
    pqh_budget_versions_bk3.delete_budget_version_a
      (
       p_budget_version_id              =>  p_budget_version_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_budget_version'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_budget_version
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
    ROLLBACK TO delete_budget_version;
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
    ROLLBACK TO delete_budget_version;
    raise;
    --
end delete_budget_version;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_budget_version_id                   in     number
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
  pqh_bvr_shd.lck
    (
      p_budget_version_id                 => p_budget_version_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_budget_versions_api;

/
