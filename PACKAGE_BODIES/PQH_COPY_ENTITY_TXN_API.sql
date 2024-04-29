--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_TXN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_TXN_API" as
/* $Header: pqcetapi.pkb 115.2 2000/06/18 21:31:04 pkm ship    $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_COPY_ENTITY_TXN_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_COPY_ENTITY_TXN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_COPY_ENTITY_TXN
  (p_validate                       in  boolean   default false
  ,p_copy_entity_txn_id             out number
  ,p_transaction_category_id        in  number    default null
  ,p_txn_category_attribute_id      in  number    default null
  ,p_context_business_group_id      in  number    default null
  ,p_datetrack_mode                 in  varchar2    default null
  ,p_context                        in  varchar2  default null
  ,p_action_date                    in  date      default null
  ,p_src_effective_date             in  date      default null
  ,p_number_of_copies               in  number    default null
  ,p_display_name                   in  varchar2  default null
  ,p_replacement_type_cd            in  varchar2  default null
  ,p_start_with                     in  varchar2    default null
  ,p_increment_by                   in  number    default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_copy_entity_txn_id pqh_copy_entity_txns.copy_entity_txn_id%TYPE;
  l_proc varchar2(72) := g_package||'create_COPY_ENTITY_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_COPY_ENTITY_TXN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk1.create_COPY_ENTITY_TXN_b
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_context_business_group_id      =>  p_context_business_group_id
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_context                        =>  p_context
      ,p_action_date                    =>  p_action_date
      ,p_src_effective_date             =>  p_src_effective_date
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_display_name                   =>  p_display_name
      ,p_replacement_type_cd            =>  p_replacement_type_cd
      ,p_start_with                     =>  p_start_with
      ,p_increment_by                   =>  p_increment_by
      ,p_status                         =>  p_status
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_COPY_ENTITY_TXN
    --
  end;
  --
  pqh_cet_ins.ins
    (
     p_copy_entity_txn_id            => l_copy_entity_txn_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_context_business_group_id     =>  p_context_business_group_id
    ,p_datetrack_mode                =>  p_datetrack_mode
    ,p_context                       => p_context
    ,p_action_date                   => p_action_date
    ,p_src_effective_date            => p_src_effective_date
    ,p_number_of_copies              => p_number_of_copies
    ,p_display_name                  => p_display_name
    ,p_replacement_type_cd           => p_replacement_type_cd
    ,p_start_with                    => p_start_with
    ,p_increment_by                  => p_increment_by
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk1.create_COPY_ENTITY_TXN_a
      (
       p_copy_entity_txn_id             =>  l_copy_entity_txn_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_context_business_group_id      =>  p_context_business_group_id
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_context                        =>  p_context
      ,p_action_date                    =>  p_action_date
      ,p_src_effective_date             =>  p_src_effective_date
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_display_name                   =>  p_display_name
      ,p_replacement_type_cd            =>  p_replacement_type_cd
      ,p_start_with                     =>  p_start_with
      ,p_increment_by                   =>  p_increment_by
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_COPY_ENTITY_TXN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_API.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_copy_entity_txn_id := l_copy_entity_txn_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_COPY_ENTITY_TXN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_copy_entity_txn_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_COPY_ENTITY_TXN;
    raise;
    --
end create_COPY_ENTITY_TXN;
-- ----------------------------------------------------------------------------
-- |------------------------< update_COPY_ENTITY_TXN >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_COPY_ENTITY_TXN
  (p_validate                       in  boolean   default false
  ,p_copy_entity_txn_id             in  number
  ,p_transaction_category_id        in  number    default hr_API.g_number
  ,p_txn_category_attribute_id      in  number    default hr_API.g_number
  ,p_context_business_group_id      in  number    default hr_api.g_number
  ,p_datetrack_mode                 in  varchar2  default hr_api.g_varchar2
  ,p_context                        in  varchar2  default hr_API.g_varchar2
  ,p_action_date                    in  date      default hr_API.g_date
  ,p_src_effective_date             in  date      default hr_API.g_date
  ,p_number_of_copies               in  number    default hr_API.g_number
  ,p_display_name                   in  varchar2  default hr_API.g_varchar2
  ,p_replacement_type_cd            in  varchar2  default hr_API.g_varchar2
  ,p_start_with                     in  varchar2  default hr_API.g_varchar2
  ,p_increment_by                   in  number    default hr_API.g_number
  ,p_status                         in  varchar2  default hr_API.g_varchar2
  ,p_object_version_number          in out number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_COPY_ENTITY_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_COPY_ENTITY_TXN;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk2.update_COPY_ENTITY_TXN_b
      (
       p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_context_business_group_id      =>  p_context_business_group_id
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_context                        =>  p_context
      ,p_action_date                    =>  p_action_date
      ,p_src_effective_date             =>  p_src_effective_date
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_display_name                   =>  p_display_name
      ,p_replacement_type_cd            =>  p_replacement_type_cd
      ,p_start_with                     =>  p_start_with
      ,p_increment_by                   =>  p_increment_by
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_COPY_ENTITY_TXN
    --
  end;
  --
  pqh_cet_upd.upd
    (
     p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_txn_category_attribute_id     => p_txn_category_attribute_id
    ,p_context_business_group_id     =>  p_context_business_group_id
    ,p_datetrack_mode                =>  p_datetrack_mode
    ,p_context                       => p_context
    ,p_action_date                   => p_action_date
    ,p_src_effective_date            => p_src_effective_date
    ,p_number_of_copies              => p_number_of_copies
    ,p_display_name                  => p_display_name
    ,p_replacement_type_cd           => p_replacement_type_cd
    ,p_start_with                    => p_start_with
    ,p_increment_by                  => p_increment_by
    ,p_status                        => p_status
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk2.update_COPY_ENTITY_TXN_a
      (
       p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_txn_category_attribute_id      =>  p_txn_category_attribute_id
      ,p_context_business_group_id      =>  p_context_business_group_id
      ,p_datetrack_mode                 =>  p_datetrack_mode
      ,p_context                        =>  p_context
      ,p_action_date                    =>  p_action_date
      ,p_src_effective_date             =>  p_src_effective_date
      ,p_number_of_copies               =>  p_number_of_copies
      ,p_display_name                   =>  p_display_name
      ,p_replacement_type_cd            =>  p_replacement_type_cd
      ,p_start_with                     =>  p_start_with
      ,p_increment_by                   =>  p_increment_by
      ,p_status                         =>  p_status
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_COPY_ENTITY_TXN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_API.validate_enabled;
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
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_COPY_ENTITY_TXN;
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
    ROLLBACK TO update_COPY_ENTITY_TXN;
    raise;
    --
end update_COPY_ENTITY_TXN;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_COPY_ENTITY_TXN >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_COPY_ENTITY_TXN
  (p_validate                       in  boolean  default false
  ,p_copy_entity_txn_id             in  number
  ,p_object_version_number          in out number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_COPY_ENTITY_TXN';
  l_object_version_number pqh_copy_entity_txns.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  pqh_cet_bus.chk_completed_target_err ( p_copy_entity_txn_id );
  --
  savepoint delete_COPY_ENTITY_TXN;
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
    -- Start of API User Hook for the before hook of delete_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk3.delete_COPY_ENTITY_TXN_b
      (
       p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_COPY_ENTITY_TXN
    --
  end;
  --
  pqh_cet_del.del
    (
     p_copy_entity_txn_id            => p_copy_entity_txn_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_COPY_ENTITY_TXN
    --
    PQH_COPY_ENTITY_TXN_bk3.delete_COPY_ENTITY_TXN_a
      (
       p_copy_entity_txn_id             =>  p_copy_entity_txn_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_API.cannot_find_prog_unit then
      hr_API.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_COPY_ENTITY_TXN'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_COPY_ENTITY_TXN
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_API.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_API.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_COPY_ENTITY_TXN;
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
    ROLLBACK TO delete_COPY_ENTITY_TXN;
    raise;
    --
end delete_COPY_ENTITY_TXN;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_copy_entity_txn_id                   in     number
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
  pqh_cet_shd.lck
    (
      p_copy_entity_txn_id                 => p_copy_entity_txn_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end PQH_COPY_ENTITY_TXN_API;

/
