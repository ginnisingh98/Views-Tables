--------------------------------------------------------
--  DDL for Package Body PQH_ROLE_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROLE_TEMPLATES_API" as
/* $Header: pqrtmapi.pkb 115.5 2002/12/06 23:48:09 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_ROLE_TEMPLATES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_role_template >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_role_template
  (p_validate                       in  boolean   default false
  ,p_role_template_id               out nocopy number
  ,p_role_id                        in  number    default null
  ,p_transaction_category_id        in  number    default null
  ,p_template_id                    in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_role_template_id pqh_role_templates.role_template_id%TYPE;
  l_proc varchar2(72) := g_package||'create_role_template';
  l_object_version_number pqh_role_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_role_template;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_role_template
    --
    PQH_ROLE_TEMPLATES_bk1.create_role_template_b
      (
       p_role_id                        =>  p_role_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_template_id                    =>  p_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROLE_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_role_template
    --
  end;
  --
  pqh_rtm_ins.ins
    (
     p_role_template_id              => l_role_template_id
    ,p_role_id                       => p_role_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_template_id                   => p_template_id
    ,p_enable_flag                   => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_role_template
    --
    PQH_ROLE_TEMPLATES_bk1.create_role_template_a
      (
       p_role_template_id               =>  l_role_template_id
      ,p_role_id                        =>  p_role_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_template_id                    =>  p_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROLE_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_role_template
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
  p_role_template_id := l_role_template_id;
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
    ROLLBACK TO create_role_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_role_template_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
       p_role_template_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_role_template;
    raise;
    --
end create_role_template;
-- ----------------------------------------------------------------------------
-- |------------------------< update_role_template >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_role_template
  (p_validate                       in  boolean   default false
  ,p_role_template_id               in  number
  ,p_role_id                        in  number    default hr_api.g_number
  -- ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_role_template';
  l_object_version_number pqh_role_templates.object_version_number%TYPE;
  p_transaction_category_id        number(15) := hr_api.g_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_role_template;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_role_template
    --
    PQH_ROLE_TEMPLATES_bk2.update_role_template_b
      (
       p_role_template_id               =>  p_role_template_id
      ,p_role_id                        =>  p_role_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_template_id                    =>  p_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROLE_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_role_template
    --
  end;
  --
  pqh_rtm_upd.upd
    (
     p_role_template_id              => p_role_template_id
    ,p_role_id                       => p_role_id
    ,p_template_id                   => p_template_id
    ,p_enable_flag                   => p_enable_flag
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_role_template
    --
    PQH_ROLE_TEMPLATES_bk2.update_role_template_a
      (
       p_role_template_id               =>  p_role_template_id
      ,p_role_id                        =>  p_role_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_template_id                    =>  p_template_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROLE_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_role_template
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
    ROLLBACK TO update_role_template;
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
    ROLLBACK TO update_role_template;
    raise;
    --
end update_role_template;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_role_template >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_role_template
  (p_validate                       in  boolean  default false
  ,p_role_template_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_role_template';
  l_object_version_number pqh_role_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_role_template;
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
    -- Start of API User Hook for the before hook of delete_role_template
    --
    PQH_ROLE_TEMPLATES_bk3.delete_role_template_b
      (
       p_role_template_id               =>  p_role_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROLE_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_role_template
    --
  end;
  --
  pqh_rtm_del.del
    (
     p_role_template_id              => p_role_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_role_template
    --
    PQH_ROLE_TEMPLATES_bk3.delete_role_template_a
      (
       p_role_template_id               =>  p_role_template_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROLE_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_role_template
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
    ROLLBACK TO delete_role_template;
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
    ROLLBACK TO delete_role_template;
    raise;
    --
end delete_role_template;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_role_template_id                   in     number
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
  pqh_rtm_shd.lck
    (
      p_role_template_id                 => p_role_template_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end PQH_ROLE_TEMPLATES_api;

/
