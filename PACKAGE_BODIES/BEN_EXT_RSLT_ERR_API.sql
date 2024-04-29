--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RSLT_ERR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RSLT_ERR_API" as
/* $Header: bexreapi.pkb 115.4 2002/12/16 07:24:45 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_RSLT_ERR_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RSLT_ERR >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RSLT_ERR
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_err_id                out nocopy number
  ,p_err_num                        in  number    default null
  ,p_err_txt                        in  varchar2  default null
  ,p_typ_cd                         in  varchar2  default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_ext_rslt_id                    in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_rslt_err_id ben_ext_rslt_err.ext_rslt_err_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_RSLT_ERR';
  l_object_version_number ben_ext_rslt_err.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_RSLT_ERR;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk1.create_EXT_RSLT_ERR_b
      (
       p_err_num                        =>  p_err_num
      ,p_err_txt                        =>  p_err_txt
      ,p_typ_cd                         =>  p_typ_cd
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_RSLT_ERR'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_RSLT_ERR
    --
  end;
  --
  ben_xre_ins.ins
    (
     p_ext_rslt_err_id               => l_ext_rslt_err_id
    ,p_err_num                       => p_err_num
    ,p_err_txt                       => p_err_txt
    ,p_typ_cd                        => p_typ_cd
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_ext_rslt_id                   => p_ext_rslt_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk1.create_EXT_RSLT_ERR_a
      (
       p_ext_rslt_err_id                =>  l_ext_rslt_err_id
      ,p_err_num                        =>  p_err_num
      ,p_err_txt                        =>  p_err_txt
      ,p_typ_cd                         =>  p_typ_cd
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_RSLT_ERR'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_RSLT_ERR
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
  p_ext_rslt_err_id := l_ext_rslt_err_id;
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
    ROLLBACK TO create_EXT_RSLT_ERR;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_rslt_err_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_RSLT_ERR;
    p_ext_rslt_err_id := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_EXT_RSLT_ERR;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RSLT_ERR >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RSLT_ERR
  (p_validate                       in  boolean   default false
  ,p_ext_rslt_err_id                in  number
  ,p_err_num                        in  number    default hr_api.g_number
  ,p_err_txt                        in  varchar2  default hr_api.g_varchar2
  ,p_typ_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_ext_rslt_id                    in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT_ERR';
  l_object_version_number ben_ext_rslt_err.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_RSLT_ERR;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk2.update_EXT_RSLT_ERR_b
      (
       p_ext_rslt_err_id                =>  p_ext_rslt_err_id
      ,p_err_num                        =>  p_err_num
      ,p_err_txt                        =>  p_err_txt
      ,p_typ_cd                         =>  p_typ_cd
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT_ERR'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_RSLT_ERR
    --
  end;
  --
  ben_xre_upd.upd
    (
     p_ext_rslt_err_id               => p_ext_rslt_err_id
    ,p_err_num                       => p_err_num
    ,p_err_txt                       => p_err_txt
    ,p_typ_cd                        => p_typ_cd
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_ext_rslt_id                   => p_ext_rslt_id
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk2.update_EXT_RSLT_ERR_a
      (
       p_ext_rslt_err_id                =>  p_ext_rslt_err_id
      ,p_err_num                        =>  p_err_num
      ,p_err_txt                        =>  p_err_txt
      ,p_typ_cd                         =>  p_typ_cd
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_ext_rslt_id                    =>  p_ext_rslt_id
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RSLT_ERR'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_RSLT_ERR
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
    ROLLBACK TO update_EXT_RSLT_ERR;
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
    ROLLBACK TO update_EXT_RSLT_ERR;
    raise;
    --
end update_EXT_RSLT_ERR;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RSLT_ERR >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RSLT_ERR
  (p_validate                       in  boolean  default false
  ,p_ext_rslt_err_id                in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RSLT_ERR';
  l_object_version_number ben_ext_rslt_err.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_RSLT_ERR;
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
    -- Start of API User Hook for the before hook of delete_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk3.delete_EXT_RSLT_ERR_b
      (
       p_ext_rslt_err_id                =>  p_ext_rslt_err_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT_ERR'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_RSLT_ERR
    --
  end;
  --
  ben_xre_del.del
    (
     p_ext_rslt_err_id               => p_ext_rslt_err_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_RSLT_ERR
    --
    ben_EXT_RSLT_ERR_bk3.delete_EXT_RSLT_ERR_a
      (
       p_ext_rslt_err_id                =>  p_ext_rslt_err_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RSLT_ERR'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_RSLT_ERR
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
    ROLLBACK TO delete_EXT_RSLT_ERR;
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
    ROLLBACK TO delete_EXT_RSLT_ERR;
    raise;
    --
end delete_EXT_RSLT_ERR;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_rslt_err_id                   in     number
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
  ben_xre_shd.lck
    (
      p_ext_rslt_err_id                 => p_ext_rslt_err_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_RSLT_ERR_api;

/
