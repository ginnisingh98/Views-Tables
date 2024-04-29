--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CRIT_TYP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CRIT_TYP_API" as
/* $Header: bexctapi.pkb 115.4 2002/12/24 22:24:42 rpillay ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_CRIT_TYP_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CRIT_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_CRIT_TYP
  (p_validate                       in  boolean   default false
  ,p_ext_crit_typ_id                out nocopy number
  ,p_crit_typ_cd                    in  varchar2  default null
  ,p_ext_crit_prfl_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_crit_typ_id ben_ext_crit_typ.ext_crit_typ_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_CRIT_TYP';
  l_object_version_number ben_ext_crit_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_CRIT_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk1.create_EXT_CRIT_TYP_b
      (
       p_crit_typ_cd                    =>  p_crit_typ_cd
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_excld_flag                     =>  p_excld_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_CRIT_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_CRIT_TYP
    --
  end;
  --
  ben_xct_ins.ins
    (
     p_ext_crit_typ_id               => l_ext_crit_typ_id
    ,p_crit_typ_cd                   => p_crit_typ_cd
    ,p_ext_crit_prfl_id              => p_ext_crit_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_excld_flag                    => p_excld_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk1.create_EXT_CRIT_TYP_a
      (
       p_ext_crit_typ_id                =>  l_ext_crit_typ_id
      ,p_crit_typ_cd                    =>  p_crit_typ_cd
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_excld_flag                     =>  p_excld_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_CRIT_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_CRIT_TYP
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
  p_ext_crit_typ_id := l_ext_crit_typ_id;
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
    ROLLBACK TO create_EXT_CRIT_TYP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_crit_typ_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_CRIT_TYP;
    /* Inserted for nocopy changes */
    p_ext_crit_typ_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_EXT_CRIT_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CRIT_TYP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_TYP
  (p_validate                       in  boolean   default false
  ,p_ext_crit_typ_id                in  number
  ,p_crit_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_ext_crit_prfl_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CRIT_TYP';
  l_object_version_number ben_ext_crit_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_CRIT_TYP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk2.update_EXT_CRIT_TYP_b
      (
       p_ext_crit_typ_id                =>  p_ext_crit_typ_id
      ,p_crit_typ_cd                    =>  p_crit_typ_cd
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_excld_flag                     =>  p_excld_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CRIT_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_CRIT_TYP
    --
  end;
  --
  ben_xct_upd.upd
    (
     p_ext_crit_typ_id               => p_ext_crit_typ_id
    ,p_crit_typ_cd                   => p_crit_typ_cd
    ,p_ext_crit_prfl_id              => p_ext_crit_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_excld_flag                    => p_excld_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk2.update_EXT_CRIT_TYP_a
      (
       p_ext_crit_typ_id                =>  p_ext_crit_typ_id
      ,p_crit_typ_cd                    =>  p_crit_typ_cd
      ,p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_excld_flag                     =>  p_excld_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CRIT_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_CRIT_TYP
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
    ROLLBACK TO update_EXT_CRIT_TYP;
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
    ROLLBACK TO update_EXT_CRIT_TYP;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_EXT_CRIT_TYP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CRIT_TYP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_TYP
  (p_validate                       in  boolean  default false
  ,p_ext_crit_typ_id                in  number
  ,p_legislation_code               in  varchar2 default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CRIT_TYP';
  l_object_version_number ben_ext_crit_typ.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_CRIT_TYP;
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
    -- Start of API User Hook for the before hook of delete_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk3.delete_EXT_CRIT_TYP_b
      (
       p_ext_crit_typ_id                =>  p_ext_crit_typ_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CRIT_TYP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_CRIT_TYP
    --
  end;
  --
  ben_xct_del.del
    (
     p_ext_crit_typ_id               => p_ext_crit_typ_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_CRIT_TYP
    --
    ben_EXT_CRIT_TYP_bk3.delete_EXT_CRIT_TYP_a
      (
       p_ext_crit_typ_id                =>  p_ext_crit_typ_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CRIT_TYP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_CRIT_TYP
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
    ROLLBACK TO delete_EXT_CRIT_TYP;
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
    ROLLBACK TO delete_EXT_CRIT_TYP;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_EXT_CRIT_TYP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_crit_typ_id                   in     number
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
  ben_xct_shd.lck
    (
      p_ext_crit_typ_id                 => p_ext_crit_typ_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_CRIT_TYP_api;

/
