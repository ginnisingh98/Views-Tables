--------------------------------------------------------
--  DDL for Package Body PQH_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATTRIBUTES_API" as
/* $Header: pqattapi.pkb 115.13 2003/03/25 04:16:57 sgoyal ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_ATTRIBUTES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_attribute_id                   out nocopy number
  ,p_attribute_name                 in  varchar2
  ,p_master_attribute_id            in  number    default null
  ,p_master_table_route_id          in  number    default null
  ,p_column_name                    in  varchar2  default null
  ,p_column_type                    in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default null
  ,p_width                          in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_region_itemname                in varchar2   default null
  ,p_attribute_itemname             in varchar2   default null
  ,p_decode_function_name           in varchar2   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_attribute_id pqh_attributes.attribute_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ATTRIBUTE';
  l_object_version_number pqh_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ATTRIBUTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk1.create_ATTRIBUTE_b
      (
       p_attribute_name                 =>  p_attribute_name
      ,p_master_attribute_id            =>  p_master_attribute_id
      ,p_master_table_route_id          =>  p_master_table_route_id
      ,p_column_name                    =>  p_column_name
      ,p_column_type                    =>  p_column_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_width                          =>  p_width
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_region_itemname                =>  p_region_itemname
      ,p_attribute_itemname             =>  p_attribute_itemname
      ,p_decode_function_name           =>  p_decode_function_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ATTRIBUTE
    --
  end;
  --
  pqh_att_ins.ins
    (
     p_attribute_id                  => l_attribute_id
    ,p_attribute_name                => p_attribute_name
    ,p_master_attribute_id           => p_master_attribute_id
    ,p_master_table_route_id         => p_master_table_route_id
    ,p_column_name                   => p_column_name
    ,p_column_type                   => p_column_type
    ,p_enable_flag                   => p_enable_flag
    ,p_width                         => p_width
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_region_itemname               => p_region_itemname
    ,p_attribute_itemname            => p_attribute_itemname
    ,p_decode_function_name          => p_decode_function_name
    );
  --
    p_attribute_id  := l_attribute_id ;
  --
    pqh_atl_ins.ins_tl(
       p_language_code  => p_language_code,
       p_attribute_id   => l_attribute_id ,
       p_attribute_name => p_attribute_name );

  begin
    --
    -- Start of API User Hook for the after hook of create_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk1.create_ATTRIBUTE_a
      (
       p_attribute_id                   =>  l_attribute_id
      ,p_attribute_name                 =>  p_attribute_name
      ,p_master_attribute_id            =>  p_master_attribute_id
      ,p_master_table_route_id          =>  p_master_table_route_id
      ,p_column_name                    =>  p_column_name
      ,p_column_type                    =>  p_column_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_width                          =>  p_width
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
    ,p_region_itemname               => p_region_itemname
    ,p_attribute_itemname            => p_attribute_itemname
    ,p_decode_function_name          => p_decode_function_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ATTRIBUTE
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
  p_attribute_id := l_attribute_id;
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
    ROLLBACK TO create_ATTRIBUTE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_attribute_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_attribute_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ATTRIBUTE;
    raise;
    --
end create_ATTRIBUTE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ATTRIBUTE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_attribute_id                   in  number
  ,p_attribute_name                 in  varchar2  default hr_api.g_varchar2
  ,p_master_attribute_id            in  number    default hr_api.g_number
  ,p_master_table_route_id          in  number    default hr_api.g_number
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_type                    in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_width                          in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_region_itemname                in varchar2   default hr_api.g_varchar2
  ,p_attribute_itemname             in varchar2   default hr_api.g_varchar2
  ,p_decode_function_name           in varchar2   default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ATTRIBUTE';
  l_object_version_number pqh_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ATTRIBUTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk2.update_ATTRIBUTE_b
      (
       p_attribute_id                   =>  p_attribute_id
      ,p_attribute_name                 =>  p_attribute_name
      ,p_master_attribute_id            =>  p_master_attribute_id
      ,p_master_table_route_id          =>  p_master_table_route_id
      ,p_column_name                    =>  p_column_name
      ,p_column_type                    =>  p_column_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_width                          =>  p_width
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
    ,p_region_itemname               => p_region_itemname
    ,p_attribute_itemname            => p_attribute_itemname
    ,p_decode_function_name          => p_decode_function_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ATTRIBUTE
    --
  end;
  --
  pqh_att_upd.upd
    (
     p_attribute_id                  => p_attribute_id
    ,p_attribute_name                => p_attribute_name
    ,p_master_attribute_id           => p_master_attribute_id
    ,p_master_table_route_id         => p_master_table_route_id
    ,p_column_name                   => p_column_name
    ,p_column_type                   => p_column_type
    ,p_enable_flag                   => p_enable_flag
    ,p_width                         => p_width
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_region_itemname               => p_region_itemname
    ,p_attribute_itemname            => p_attribute_itemname
    ,p_decode_function_name          => p_decode_function_name
    );
  --
     pqh_atl_upd.upd_tl
       (
       p_language_code  => p_language_code,
       p_attribute_id   => p_attribute_id ,
       p_attribute_name => p_attribute_name );
  --

  begin
    --
    -- Start of API User Hook for the after hook of update_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk2.update_ATTRIBUTE_a
      (
       p_attribute_id                   =>  p_attribute_id
      ,p_attribute_name                 =>  p_attribute_name
      ,p_master_attribute_id            =>  p_master_attribute_id
      ,p_master_table_route_id          =>  p_master_table_route_id
      ,p_column_name                    =>  p_column_name
      ,p_column_type                    =>  p_column_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_width                          =>  p_width
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
    ,p_region_itemname               => p_region_itemname
    ,p_attribute_itemname            => p_attribute_itemname
    ,p_decode_function_name          => p_decode_function_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ATTRIBUTE
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
    ROLLBACK TO update_ATTRIBUTE;
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
    ROLLBACK TO update_ATTRIBUTE;
    raise;
    --
end update_ATTRIBUTE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ATTRIBUTE
  (p_validate                       in  boolean  default false
  ,p_attribute_id                   in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ATTRIBUTE';
  l_object_version_number pqh_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ATTRIBUTE;
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
    -- Start of API User Hook for the before hook of delete_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk3.delete_ATTRIBUTE_b
      (
       p_attribute_id                   =>  p_attribute_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ATTRIBUTE
    --
  end;
  --
  --
  pqh_att_shd.lck
    (
      p_attribute_id               => p_attribute_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  pqh_atl_del.del_tl
    (
       p_attribute_id               => p_attribute_id
    );
  --
  pqh_att_del.del
    (
     p_attribute_id                  => p_attribute_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --

  begin
    --
    -- Start of API User Hook for the after hook of delete_ATTRIBUTE
    --
    pqh_ATTRIBUTES_bk3.delete_ATTRIBUTE_a
      (
       p_attribute_id                   =>  p_attribute_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ATTRIBUTE
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
    ROLLBACK TO delete_ATTRIBUTE;
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
    ROLLBACK TO delete_ATTRIBUTE;
    raise;
    --
end delete_ATTRIBUTE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_attribute_id                   in     number
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
  pqh_att_shd.lck
    (
      p_attribute_id                 => p_attribute_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_ATTRIBUTES_api;

/
