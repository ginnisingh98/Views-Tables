--------------------------------------------------------
--  DDL for Package Body PQH_PTX_INFO_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_INFO_TYPES_API" as
/* $Header: pqptiapi.pkb 115.4 2002/12/06 18:07:04 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_ptx_info_types_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptx_info_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ptx_info_type
  (p_validate                       in  boolean   default false
  ,p_information_type               out nocopy varchar2
  ,p_active_inactive_flag           in  varchar2  default null
  ,p_description                    in  varchar2  default null
  ,p_multiple_occurences_flag       in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_information_type pqh_ptx_info_types.information_type%TYPE;
  l_proc varchar2(72) := g_package||'create_ptx_info_type';
  l_object_version_number pqh_ptx_info_types.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ptx_info_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ptx_info_type
    --
    pqh_ptx_info_types_bk1.create_ptx_info_type_b
      (
       p_active_inactive_flag           =>  p_active_inactive_flag
      ,p_description                    =>  p_description
      ,p_multiple_occurences_flag       =>  p_multiple_occurences_flag
      ,p_legislation_code               =>  p_legislation_code
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_PTX_INFO_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ptx_info_type
    --
  end;
  --
  pqh_pti_ins.ins
    (
     p_information_type              => l_information_type
    ,p_active_inactive_flag          => p_active_inactive_flag
    ,p_description                   => p_description
    ,p_multiple_occurences_flag      => p_multiple_occurences_flag
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ptx_info_type
    --
    pqh_ptx_info_types_bk1.create_ptx_info_type_a
      (
       p_information_type               =>  l_information_type
      ,p_active_inactive_flag           =>  p_active_inactive_flag
      ,p_description                    =>  p_description
      ,p_multiple_occurences_flag       =>  p_multiple_occurences_flag
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PTX_INFO_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ptx_info_type
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
  p_information_type := l_information_type;
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
    ROLLBACK TO create_ptx_info_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_information_type := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_information_type := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ptx_info_type;
    raise;
    --
end create_ptx_info_type;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptx_info_type >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ptx_info_type
  (p_validate                       in  boolean   default false
  ,p_information_type               in  varchar2
  ,p_active_inactive_flag           in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_multiple_occurences_flag       in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ptx_info_type';
  l_object_version_number pqh_ptx_info_types.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ptx_info_type;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ptx_info_type
    --
    pqh_ptx_info_types_bk2.update_ptx_info_type_b
      (
       p_information_type               =>  p_information_type
      ,p_active_inactive_flag           =>  p_active_inactive_flag
      ,p_description                    =>  p_description
      ,p_multiple_occurences_flag       =>  p_multiple_occurences_flag
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PTX_INFO_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ptx_info_type
    --
  end;
  --
  pqh_pti_upd.upd
    (
     p_information_type              => p_information_type
    ,p_active_inactive_flag          => p_active_inactive_flag
    ,p_description                   => p_description
    ,p_multiple_occurences_flag      => p_multiple_occurences_flag
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ptx_info_type
    --
    pqh_ptx_info_types_bk2.update_ptx_info_type_a
      (
       p_information_type               =>  p_information_type
      ,p_active_inactive_flag           =>  p_active_inactive_flag
      ,p_description                    =>  p_description
      ,p_multiple_occurences_flag       =>  p_multiple_occurences_flag
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PTX_INFO_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ptx_info_type
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
    ROLLBACK TO update_ptx_info_type;
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
    ROLLBACK TO update_ptx_info_type;
    raise;
    --
end update_ptx_info_type;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ptx_info_type >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ptx_info_type
  (p_validate                       in  boolean  default false
  ,p_information_type               in  varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ptx_info_type';
  l_object_version_number pqh_ptx_info_types.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ptx_info_type;
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
    -- Start of API User Hook for the before hook of delete_ptx_info_type
    --
    pqh_ptx_info_types_bk3.delete_ptx_info_type_b
      (
       p_information_type               =>  p_information_type
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PTX_INFO_TYPE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ptx_info_type
    --
  end;
  --
  pqh_pti_del.del
    (
     p_information_type              => p_information_type
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ptx_info_type
    --
    pqh_ptx_info_types_bk3.delete_ptx_info_type_a
      (
       p_information_type               =>  p_information_type
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PTX_INFO_TYPE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ptx_info_type
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
    ROLLBACK TO delete_ptx_info_type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ptx_info_type;
    raise;
    --
end delete_ptx_info_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_information_type                   in     number
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
  pqh_pti_shd.lck
    (
      p_information_type                 => p_information_type
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_ptx_info_types_api;

/
