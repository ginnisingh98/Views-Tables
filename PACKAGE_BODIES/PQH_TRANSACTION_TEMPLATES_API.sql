--------------------------------------------------------
--  DDL for Package Body PQH_TRANSACTION_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TRANSACTION_TEMPLATES_API" as
/* $Header: pqttmapi.pkb 115.4 2002/12/06 23:49:23 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_transaction_templates_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_transaction_template >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_transaction_template
  (p_validate                       in  boolean   default false
  ,p_transaction_template_id        out nocopy number
  ,p_enable_flag                    in  varchar2  default null
  ,p_template_id                    in  number    default null
  ,p_transaction_id                 in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_transaction_template_id pqh_transaction_templates.transaction_template_id%TYPE;
  l_proc varchar2(72) := g_package||'create_transaction_template';
  l_object_version_number pqh_transaction_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_transaction_template;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_transaction_template
    --
    pqh_transaction_templates_bk1.create_transaction_template_b
      (
       p_enable_flag                    =>  p_enable_flag
      ,p_template_id                    =>  p_template_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_transaction_template
    --
  end;
  --
  pqh_ttm_ins.ins
    (
     p_transaction_template_id       => l_transaction_template_id
    ,p_enable_flag                   => p_enable_flag
    ,p_template_id                   => p_template_id
    ,p_transaction_id                => p_transaction_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_transaction_template
    --
    pqh_transaction_templates_bk1.create_transaction_template_a
      (
       p_transaction_template_id        =>  l_transaction_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_template_id                    =>  p_template_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_transaction_template
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
  p_transaction_template_id := l_transaction_template_id;
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
    ROLLBACK TO create_transaction_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_transaction_template_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_transaction_template_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_transaction_template;
    raise;
    --
end create_transaction_template;
-- ----------------------------------------------------------------------------
-- |------------------------< update_transaction_template >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_transaction_template
  (p_validate                       in  boolean   default false
  ,p_transaction_template_id        in  number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_transaction_id                 in  number    default hr_api.g_number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_transaction_template';
  l_object_version_number pqh_transaction_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_transaction_template;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_transaction_template
    --
    pqh_transaction_templates_bk2.update_transaction_template_b
      (
       p_transaction_template_id        =>  p_transaction_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_template_id                    =>  p_template_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_transaction_template
    --
  end;
  --
  pqh_ttm_upd.upd
    (
     p_transaction_template_id       => p_transaction_template_id
    ,p_enable_flag                   => p_enable_flag
    ,p_template_id                   => p_template_id
    ,p_transaction_id                => p_transaction_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_transaction_template
    --
    pqh_transaction_templates_bk2.update_transaction_template_a
      (
       p_transaction_template_id        =>  p_transaction_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_template_id                    =>  p_template_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_transaction_template
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
    ROLLBACK TO update_transaction_template;
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
    ROLLBACK TO update_transaction_template;
    raise;
    --
end update_transaction_template;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_template >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_transaction_template
  (p_validate                       in  boolean  default false
  ,p_transaction_template_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_transaction_template';
  l_object_version_number pqh_transaction_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_transaction_template;
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
    -- Start of API User Hook for the before hook of delete_transaction_template
    --
    pqh_transaction_templates_bk3.delete_transaction_template_b
      (
       p_transaction_template_id        =>  p_transaction_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_transaction_template
    --
  end;
  --
  pqh_ttm_del.del
    (
     p_transaction_template_id       => p_transaction_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_transaction_template
    --
    pqh_transaction_templates_bk3.delete_transaction_template_a
      (
       p_transaction_template_id        =>  p_transaction_template_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRANSACTION_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_transaction_template
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
    ROLLBACK TO delete_transaction_template;
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
    ROLLBACK TO delete_transaction_template;
    raise;
    --
end delete_transaction_template;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_transaction_template_id                   in     number
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
  pqh_ttm_shd.lck
    (
      p_transaction_template_id                 => p_transaction_template_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_transaction_templates_api;

/
