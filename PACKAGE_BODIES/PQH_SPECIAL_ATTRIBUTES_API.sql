--------------------------------------------------------
--  DDL for Package Body PQH_SPECIAL_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SPECIAL_ATTRIBUTES_API" as
/* $Header: pqsatapi.pkb 115.5 2004/04/09 11:15:18 srajakum ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_special_attributes_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_special_attribute >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_special_attribute
  (p_validate                       in  boolean   default false
  ,p_special_attribute_id           out nocopy number
  ,p_txn_category_attribute_id      in  number    default null
  ,p_attribute_type_cd              in  varchar2  default null
  ,p_key_attribute_type              in  varchar2  default null
  ,p_enable_flag              in  varchar2  default null
  ,p_flex_code                      in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ddf_column_name                in  varchar2  default null
  ,p_ddf_value_column_name          in  varchar2  default null
  ,p_context                        in  varchar2  default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_special_attribute_id pqh_special_attributes.special_attribute_id%TYPE;
  l_proc varchar2(72) := g_package||'create_special_attribute';
  l_object_version_number pqh_special_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_special_attribute;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_special_attribute
    --
    pqh_special_attributes_bk1.create_special_attribute_b
      (
       p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_type_cd              =>  p_attribute_type_cd
      ,p_key_attribute_type             =>  p_key_attribute_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_flex_code                      =>  p_flex_code
      ,p_ddf_column_name                =>  p_ddf_column_name
      ,p_ddf_value_column_name          =>  p_ddf_value_column_name
      ,p_context                        =>  p_context
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_special_attribute'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_special_attribute
    --
  end;
  --
  pqh_sat_ins.ins
    (
     p_special_attribute_id          => l_special_attribute_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_attribute_type_cd             => p_attribute_type_cd
      ,p_key_attribute_type             =>  p_key_attribute_type
      ,p_enable_flag                    =>  p_enable_flag
    ,p_flex_code                     => p_flex_code
    ,p_object_version_number         => l_object_version_number
    ,p_ddf_column_name               => p_ddf_column_name
    ,p_ddf_value_column_name         => p_ddf_value_column_name
    ,p_context                       => p_context
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_special_attribute
    --
    pqh_special_attributes_bk1.create_special_attribute_a
      (
       p_special_attribute_id           =>  l_special_attribute_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_type_cd              =>  p_attribute_type_cd
      ,p_key_attribute_type             =>  p_key_attribute_type
      ,p_enable_flag                    =>  p_enable_flag
      ,p_flex_code                      =>  p_flex_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_ddf_column_name                =>  p_ddf_column_name
      ,p_ddf_value_column_name          =>  p_ddf_value_column_name
      ,p_context                        =>  p_context
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_special_attribute'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_special_attribute
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
  p_special_attribute_id := l_special_attribute_id;
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
    ROLLBACK TO create_special_attribute;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_special_attribute_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_special_attribute_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_special_attribute;
    raise;
    --
end create_special_attribute;
-- ----------------------------------------------------------------------------
-- |------------------------< update_special_attribute >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_special_attribute
  (p_validate                       in  boolean   default false
  ,p_special_attribute_id           in  number
  ,p_txn_category_attribute_id      in  number    default hr_api.g_number
  ,p_attribute_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_key_attribute_type              in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag              in  varchar2  default hr_api.g_varchar2
  ,p_flex_code                      in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ddf_column_name                in  varchar2  default hr_api.g_varchar2
  ,p_ddf_value_column_name          in  varchar2  default hr_api.g_varchar2
  ,p_context                        in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_special_attribute';
  l_object_version_number pqh_special_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_special_attribute;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_special_attribute
    --
    pqh_special_attributes_bk2.update_special_attribute_b
      (
       p_special_attribute_id           =>  p_special_attribute_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_type_cd              =>  p_attribute_type_cd
      ,p_key_attribute_type              =>  p_key_attribute_type
      ,p_enable_flag              =>  p_enable_flag
      ,p_flex_code                      =>  p_flex_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_ddf_column_name                =>  p_ddf_column_name
      ,p_ddf_value_column_name          =>  p_ddf_value_column_name
      ,p_context                        =>  p_context
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_special_attribute'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_special_attribute
    --
  end;
  --
  pqh_sat_upd.upd
    (
     p_special_attribute_id          => p_special_attribute_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_attribute_type_cd             => p_attribute_type_cd
      ,p_key_attribute_type              =>  p_key_attribute_type
      ,p_enable_flag              =>  p_enable_flag
    ,p_flex_code                     => p_flex_code
    ,p_object_version_number         => l_object_version_number
    ,p_ddf_column_name               => p_ddf_column_name
    ,p_ddf_value_column_name         => p_ddf_value_column_name
    ,p_context                       => p_context
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_special_attribute
    --
    pqh_special_attributes_bk2.update_special_attribute_a
      (
       p_special_attribute_id           =>  p_special_attribute_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_type_cd              =>  p_attribute_type_cd
      ,p_key_attribute_type              =>  p_key_attribute_type
      ,p_enable_flag              =>  p_enable_flag
      ,p_flex_code                      =>  p_flex_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_ddf_column_name                =>  p_ddf_column_name
      ,p_ddf_value_column_name          =>  p_ddf_value_column_name
      ,p_context                        =>  p_context
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_special_attribute'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_special_attribute
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
    ROLLBACK TO update_special_attribute;
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
    ROLLBACK TO update_special_attribute;
    raise;
    --
end update_special_attribute;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_special_attribute >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_special_attribute
  (p_validate                       in  boolean  default false
  ,p_special_attribute_id           in  number
  ,p_object_version_number          in number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_special_attribute';
  l_object_version_number pqh_special_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_special_attribute;
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
    -- Start of API User Hook for the before hook of delete_special_attribute
    --
    pqh_special_attributes_bk3.delete_special_attribute_b
      (
       p_special_attribute_id           =>  p_special_attribute_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_special_attribute'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_special_attribute
    --
  end;
  --
  pqh_sat_del.del
    (
     p_special_attribute_id          => p_special_attribute_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_special_attribute
    --
    pqh_special_attributes_bk3.delete_special_attribute_a
      (
       p_special_attribute_id           =>  p_special_attribute_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_special_attribute'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_special_attribute
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
    ROLLBACK TO delete_special_attribute;
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
    ROLLBACK TO delete_special_attribute;
    raise;
    --
end delete_special_attribute;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_special_attribute_id                   in     number
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
  pqh_sat_shd.lck
    (
      p_special_attribute_id                 => p_special_attribute_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--


end pqh_special_attributes_api;

/
