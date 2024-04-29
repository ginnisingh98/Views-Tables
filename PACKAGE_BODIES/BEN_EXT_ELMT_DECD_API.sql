--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ELMT_DECD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ELMT_DECD_API" as
/* $Header: bexddapi.pkb 120.1 2005/06/08 13:08:59 tjesumic noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_ELMT_DECD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_ELMT_DECD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_ELMT_DECD
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_decd_id          out nocopy number
  ,p_val                            in  varchar2  default null
  ,p_dcd_val                        in  varchar2  default null
  ,p_chg_evt_source                 in  varchar2  default null
  ,p_ext_data_elmt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_data_elmt_decd_id ben_ext_data_elmt_decd.ext_data_elmt_decd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_ELMT_DECD';
  l_object_version_number ben_ext_data_elmt_decd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_ELMT_DECD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk1.create_EXT_ELMT_DECD_b
      (
       p_val                            =>  p_val
      ,p_dcd_val                        =>  p_dcd_val
      ,p_chg_evt_source                 =>  p_chg_evt_source
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_ELMT_DECD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_ELMT_DECD
    --
  end;
  --
  ben_xdd_ins.ins
    (
     p_ext_data_elmt_decd_id         => l_ext_data_elmt_decd_id
    ,p_val                           => p_val
    ,p_dcd_val                       => p_dcd_val
    ,p_chg_evt_source                => p_chg_evt_source
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk1.create_EXT_ELMT_DECD_a
      (
       p_ext_data_elmt_decd_id          =>  l_ext_data_elmt_decd_id
      ,p_val                            =>  p_val
      ,p_dcd_val                        =>  p_dcd_val
      ,p_chg_evt_source                 =>  p_chg_evt_source
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               => p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_ELMT_DECD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_ELMT_DECD
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
  p_ext_data_elmt_decd_id := l_ext_data_elmt_decd_id;
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
    ROLLBACK TO create_EXT_ELMT_DECD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_data_elmt_decd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_ELMT_DECD;
    --
    -- NOCOPY changes.
    --
    p_ext_data_elmt_decd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end create_EXT_ELMT_DECD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_ELMT_DECD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_ELMT_DECD
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_decd_id          in  number
  ,p_val                            in  varchar2  default hr_api.g_varchar2
  ,p_dcd_val                        in  varchar2  default hr_api.g_varchar2
  ,p_chg_evt_source                 in  varchar2  default hr_api.g_varchar2
  ,p_ext_data_elmt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_ELMT_DECD';
  l_object_version_number ben_ext_data_elmt_decd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_ELMT_DECD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk2.update_EXT_ELMT_DECD_b
      (
       p_ext_data_elmt_decd_id          =>  p_ext_data_elmt_decd_id
      ,p_val                            =>  p_val
      ,p_dcd_val                        =>  p_dcd_val
      ,p_chg_evt_source                 =>  p_chg_evt_source
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_ELMT_DECD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_ELMT_DECD
    --
  end;
  --
  ben_xdd_upd.upd
    (
     p_ext_data_elmt_decd_id         => p_ext_data_elmt_decd_id
    ,p_val                           => p_val
    ,p_dcd_val                       => p_dcd_val
    ,p_chg_evt_source                => p_chg_evt_source
    ,p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk2.update_EXT_ELMT_DECD_a
      (
       p_ext_data_elmt_decd_id          =>  p_ext_data_elmt_decd_id
      ,p_val                            =>  p_val
      ,p_dcd_val                        =>  p_dcd_val
      ,p_chg_evt_source                 =>  p_chg_evt_source
      ,p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_ELMT_DECD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_ELMT_DECD
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
    ROLLBACK TO update_EXT_ELMT_DECD;
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
    ROLLBACK TO update_EXT_ELMT_DECD;
    --
    --  NOCOPY changes.
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    --
    raise;
    --
end update_EXT_ELMT_DECD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_ELMT_DECD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_ELMT_DECD
  (p_validate                       in  boolean  default false
  ,p_ext_data_elmt_decd_id          in  number
  ,p_legislation_code               in  varchar2 default null
  ,p_object_version_number          in  out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_ELMT_DECD';
  l_object_version_number ben_ext_data_elmt_decd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_ELMT_DECD;
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
    -- Start of API User Hook for the before hook of delete_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk3.delete_EXT_ELMT_DECD_b
      (
       p_ext_data_elmt_decd_id          =>  p_ext_data_elmt_decd_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_ELMT_DECD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_ELMT_DECD
    --
  end;
  --
  ben_xdd_del.del
    (
     p_ext_data_elmt_decd_id         => p_ext_data_elmt_decd_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_ELMT_DECD
    --
    ben_EXT_ELMT_DECD_bk3.delete_EXT_ELMT_DECD_a
      (
       p_ext_data_elmt_decd_id          =>  p_ext_data_elmt_decd_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_ELMT_DECD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_ELMT_DECD
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
    ROLLBACK TO delete_EXT_ELMT_DECD;
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
    ROLLBACK TO delete_EXT_ELMT_DECD;
    --
    --  NOCOPY changes.
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end delete_EXT_ELMT_DECD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_data_elmt_decd_id                   in     number
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
  ben_xdd_shd.lck
    (
      p_ext_data_elmt_decd_id                 => p_ext_data_elmt_decd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_ELMT_DECD_api;

/
