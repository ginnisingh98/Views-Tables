--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_CONTEXTS_API" as
/* $Header: pqcecapi.pkb 115.6 2002/12/05 19:30:44 rpasapul ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_copy_entity_contexts_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_context >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_copy_entity_context
  (p_validate                       in  boolean   default false
  ,p_context                        in  varchar2
  ,p_application_short_name         in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_responsibility_key             in  varchar2  default null
  ,p_transaction_short_name         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_context pqh_copy_entity_contexts.context%TYPE;
  l_proc varchar2(72) := g_package||'create_copy_entity_context';
  l_object_version_number pqh_copy_entity_contexts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_copy_entity_context;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_copy_entity_context
    --
    pqh_copy_entity_contexts_bk1.create_copy_entity_context_b
      (
       p_application_short_name         =>  p_application_short_name
      ,p_legislation_code               =>  p_legislation_code
      ,p_responsibility_key             =>  p_responsibility_key
      ,p_transaction_short_name         =>  p_transaction_short_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'create_copy_entity_context'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_copy_entity_context
    --
  end;
  --
  pqh_cec_ins.ins
    (
     p_context                       => p_context
    ,p_application_short_name        => p_application_short_name
    ,p_legislation_code              => p_legislation_code
    ,p_responsibility_key            => p_responsibility_key
    ,p_transaction_short_name        => p_transaction_short_name
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_copy_entity_context
    --
    pqh_copy_entity_contexts_bk1.create_copy_entity_context_a
      (
       p_context                        =>  p_context
      ,p_application_short_name         =>  p_application_short_name
      ,p_legislation_code               =>  p_legislation_code
      ,p_responsibility_key             =>  p_responsibility_key
      ,p_transaction_short_name         =>  p_transaction_short_name
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_copy_entity_context'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_copy_entity_context
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
--  p_context := l_context;
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
    ROLLBACK TO create_copy_entity_context;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- p_context := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_copy_entity_context;
    raise;
    --
end create_copy_entity_context;
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_context >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_copy_entity_context
  (p_validate                       in  boolean   default false
  ,p_context                        in  varchar2
  ,p_application_short_name         in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_responsibility_key             in  varchar2  default hr_api.g_varchar2
  ,p_transaction_short_name         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_copy_entity_context';
  l_object_version_number pqh_copy_entity_contexts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_copy_entity_context;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_copy_entity_context
    --
    pqh_copy_entity_contexts_bk2.update_copy_entity_context_b
      (
       p_context                        =>  p_context
      ,p_application_short_name         =>  p_application_short_name
      ,p_legislation_code               =>  p_legislation_code
      ,p_responsibility_key             =>  p_responsibility_key
      ,p_transaction_short_name         =>  p_transaction_short_name
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_copy_entity_context'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_copy_entity_context
    --
  end;
  --
  pqh_cec_upd.upd
    (
     p_context                       => p_context
    ,p_application_short_name        => p_application_short_name
    ,p_legislation_code              => p_legislation_code
    ,p_responsibility_key            => p_responsibility_key
    ,p_transaction_short_name        => p_transaction_short_name
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_copy_entity_context
    --
    pqh_copy_entity_contexts_bk2.update_copy_entity_context_a
      (
       p_context                        =>  p_context
      ,p_application_short_name         =>  p_application_short_name
      ,p_legislation_code               =>  p_legislation_code
      ,p_responsibility_key             =>  p_responsibility_key
      ,p_transaction_short_name         =>  p_transaction_short_name
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_copy_entity_context'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_copy_entity_context
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
    ROLLBACK TO update_copy_entity_context;
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
    ROLLBACK TO update_copy_entity_context;
    raise;
    --
end update_copy_entity_context;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_context >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_copy_entity_context
  (p_validate                       in  boolean  default false
  ,p_context                        in  varchar2
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_copy_entity_context';
  l_object_version_number pqh_copy_entity_contexts.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_copy_entity_context;
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
    -- Start of API User Hook for the before hook of delete_copy_entity_context
    --
    pqh_copy_entity_contexts_bk3.delete_copy_entity_context_b
      (
       p_context                        =>  p_context
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_copy_entity_context'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_copy_entity_context
    --
  end;
  --
  pqh_cec_del.del
    (
     p_context                       => p_context
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_copy_entity_context
    --
    pqh_copy_entity_contexts_bk3.delete_copy_entity_context_a
      (
       p_context                        =>  p_context
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_copy_entity_context'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_copy_entity_context
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
    ROLLBACK TO delete_copy_entity_context;
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
    ROLLBACK TO delete_copy_entity_context;
    raise;
    --
end delete_copy_entity_context;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_context                   in     varchar2
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
  pqh_cec_shd.lck
    (
      p_context                 => p_context
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--
--
--





end pqh_copy_entity_contexts_api;

/
