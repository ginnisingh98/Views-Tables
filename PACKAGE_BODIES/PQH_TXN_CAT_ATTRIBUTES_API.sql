--------------------------------------------------------
--  DDL for Package Body PQH_TXN_CAT_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TXN_CAT_ATTRIBUTES_API" as
/* $Header: pqtcaapi.pkb 115.8 2003/01/10 20:59:14 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_TXN_CAT_ATTRIBUTES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_TXN_CAT_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_TXN_CAT_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_txn_category_attribute_id      out nocopy number
  ,p_attribute_id                   in  number
  ,p_transaction_category_id        in  number
  ,p_value_set_id                   in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_transaction_table_route_id     in  number    default null
  ,p_form_column_name               in  varchar2  default null
  ,p_identifier_flag                in  varchar2  default null
  ,p_list_identifying_flag          in  varchar2  default null
  ,p_member_identifying_flag        in  varchar2  default null
  ,p_refresh_flag                   in  varchar2  default null
  ,p_select_flag                    in  varchar2  default null
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_txn_category_attribute_id pqh_txn_category_attributes.txn_category_attribute_id%TYPE;
  l_proc varchar2(72) := g_package||'create_TXN_CAT_ATTRIBUTE';
  l_object_version_number pqh_txn_category_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_TXN_CAT_ATTRIBUTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk1.create_TXN_CAT_ATTRIBUTE_b
      (
       p_attribute_id                   =>  p_attribute_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_value_set_id                   =>  p_value_set_id
      ,p_transaction_table_route_id     =>  p_transaction_table_route_id
      ,p_form_column_name               =>  p_form_column_name
      ,p_identifier_flag                =>  p_identifier_flag
      ,p_list_identifying_flag          =>  p_list_identifying_flag
      ,p_member_identifying_flag        =>  p_member_identifying_flag
      ,p_refresh_flag                   =>  p_refresh_flag
      ,p_select_flag                    =>  p_select_flag
      ,p_value_style_cd                 =>  p_value_style_cd
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_TXN_CAT_ATTRIBUTE
    --
  end;
  --
  pqh_tca_ins.ins
    (
     p_txn_category_attribute_id     => l_txn_category_attribute_id
    ,p_attribute_id                  => p_attribute_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_value_set_id                  => p_value_set_id
    ,p_object_version_number         => l_object_version_number
    ,p_transaction_table_route_id    => p_transaction_table_route_id
    ,p_form_column_name              => p_form_column_name
    ,p_identifier_flag               => p_identifier_flag
    ,p_list_identifying_flag         => p_list_identifying_flag
    ,p_member_identifying_flag       => p_member_identifying_flag
    ,p_refresh_flag                  => p_refresh_flag
    ,p_select_flag                  => p_select_flag
    ,p_value_style_cd                => p_value_style_cd
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk1.create_TXN_CAT_ATTRIBUTE_a
      (
       p_txn_category_attribute_id      =>  l_txn_category_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_value_set_id                   =>  p_value_set_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_transaction_table_route_id     =>  p_transaction_table_route_id
      ,p_form_column_name               =>  p_form_column_name
      ,p_identifier_flag                =>  p_identifier_flag
      ,p_list_identifying_flag          =>  p_list_identifying_flag
      ,p_member_identifying_flag        =>  p_member_identifying_flag
      ,p_refresh_flag                   =>  p_refresh_flag
      ,p_select_flag                    =>  p_select_flag
      ,p_value_style_cd                 =>  p_value_style_cd
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_TXN_CAT_ATTRIBUTE
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
  p_txn_category_attribute_id := l_txn_category_attribute_id;
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
    ROLLBACK TO create_TXN_CAT_ATTRIBUTE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_txn_category_attribute_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
     p_txn_category_attribute_id := l_txn_category_attribute_id;
  p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_TXN_CAT_ATTRIBUTE;
    raise;
    --
end create_TXN_CAT_ATTRIBUTE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_TXN_CAT_ATTRIBUTE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_TXN_CAT_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_txn_category_attribute_id      in  number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_value_set_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_transaction_table_route_id     in  number    default hr_api.g_number
  ,p_form_column_name               in  varchar2  default hr_api.g_varchar2
  ,p_identifier_flag                in  varchar2  default hr_api.g_varchar2
  ,p_list_identifying_flag          in  varchar2  default hr_api.g_varchar2
  ,p_member_identifying_flag        in  varchar2  default hr_api.g_varchar2
  ,p_refresh_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_select_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_value_style_cd                 in  varchar2
  ,p_effective_date                 in  date
  ,p_delete_attr_ranges_flag        in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_TXN_CAT_ATTRIBUTE';
  l_object_version_number pqh_txn_category_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_TXN_CAT_ATTRIBUTE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk2.update_TXN_CAT_ATTRIBUTE_b
      (
       p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_value_set_id                   =>  p_value_set_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_transaction_table_route_id     =>  p_transaction_table_route_id
      ,p_form_column_name               =>  p_form_column_name
      ,p_identifier_flag                =>  p_identifier_flag
      ,p_list_identifying_flag          =>  p_list_identifying_flag
      ,p_member_identifying_flag        =>  p_member_identifying_flag
      ,p_refresh_flag                   =>  p_refresh_flag
      ,p_select_flag                    =>  p_select_flag
      ,p_value_style_cd                 =>  p_value_style_cd
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_TXN_CAT_ATTRIBUTE
    --
  end;
  --
  pqh_tca_upd.upd
    (
     p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_attribute_id                  => p_attribute_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_value_set_id                  => p_value_set_id
    ,p_object_version_number         => l_object_version_number
    ,p_transaction_table_route_id    => p_transaction_table_route_id
    ,p_form_column_name              => p_form_column_name
    ,p_identifier_flag               => p_identifier_flag
    ,p_list_identifying_flag         => p_list_identifying_flag
    ,p_member_identifying_flag       => p_member_identifying_flag
    ,p_refresh_flag                  => p_refresh_flag
    ,p_select_flag                  => p_select_flag
    ,p_value_style_cd                => p_value_style_cd
    ,p_effective_date                => trunc(p_effective_date)
    ,p_delete_attr_ranges_flag       => p_delete_attr_ranges_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk2.update_TXN_CAT_ATTRIBUTE_a
      (
       p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_value_set_id                   =>  p_value_set_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_transaction_table_route_id     =>  p_transaction_table_route_id
      ,p_form_column_name               =>  p_form_column_name
      ,p_identifier_flag                =>  p_identifier_flag
      ,p_list_identifying_flag          =>  p_list_identifying_flag
      ,p_member_identifying_flag        =>  p_member_identifying_flag
      ,p_refresh_flag                   =>  p_refresh_flag
      ,p_select_flag                   =>  p_select_flag
      ,p_value_style_cd                 =>  p_value_style_cd
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_TXN_CAT_ATTRIBUTE
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
    ROLLBACK TO update_TXN_CAT_ATTRIBUTE;
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
    ROLLBACK TO update_TXN_CAT_ATTRIBUTE;
    raise;
    --
End update_TXN_CAT_ATTRIBUTE;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_TXN_CAT_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TXN_CAT_ATTRIBUTE
  (p_validate                       in  boolean  default false
  ,p_txn_category_attribute_id      in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_TXN_CAT_ATTRIBUTE';
  l_object_version_number pqh_txn_category_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_TXN_CAT_ATTRIBUTE;
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
    -- Start of API User Hook for the before hook of delete_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk3.delete_TXN_CAT_ATTRIBUTE_b
      (
       p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_TXN_CAT_ATTRIBUTE
    --
  end;
  --
  pqh_tca_del.del
    (
     p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_TXN_CAT_ATTRIBUTE
    --
    pqh_TXN_CAT_ATTRIBUTES_bk3.delete_TXN_CAT_ATTRIBUTE_a
      (
       p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TXN_CAT_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_TXN_CAT_ATTRIBUTE
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
    ROLLBACK TO delete_TXN_CAT_ATTRIBUTE;
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
    ROLLBACK TO delete_TXN_CAT_ATTRIBUTE;
    raise;
    --
end delete_TXN_CAT_ATTRIBUTE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_txn_category_attribute_id      in     number
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
  pqh_tca_shd.lck
    (
      p_txn_category_attribute_id  => p_txn_category_attribute_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--
end pqh_TXN_CAT_ATTRIBUTES_api;

/
