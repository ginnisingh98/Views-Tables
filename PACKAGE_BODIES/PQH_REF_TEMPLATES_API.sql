--------------------------------------------------------
--  DDL for Package Body PQH_REF_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_REF_TEMPLATES_API" as
/* $Header: pqrftapi.pkb 115.5 2002/12/06 18:07:37 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_REF_TEMPLATES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_REF_TEMPLATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_REF_TEMPLATE
  (p_validate                       in  boolean   default false
  ,p_ref_template_id                out nocopy number
  ,p_base_template_id               in  number
  ,p_parent_template_id             in  number
  ,p_reference_type_cd              in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ref_template_id pqh_ref_templates.ref_template_id%TYPE;
  l_proc varchar2(72) := g_package||'create_REF_TEMPLATE';
  l_object_version_number pqh_ref_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_REF_TEMPLATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk1.create_REF_TEMPLATE_b
      (
       p_base_template_id               =>  p_base_template_id
      ,p_parent_template_id             =>  p_parent_template_id
      ,p_reference_type_cd              =>  p_reference_type_cd
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_REF_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_REF_TEMPLATE
    --
  end;
  --
  pqh_rft_ins.ins
    (
     p_ref_template_id               => l_ref_template_id
    ,p_base_template_id              => p_base_template_id
    ,p_parent_template_id            => p_parent_template_id
    ,p_reference_type_cd             => p_reference_type_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk1.create_REF_TEMPLATE_a
      (
       p_ref_template_id                =>  l_ref_template_id
      ,p_base_template_id               =>  p_base_template_id
      ,p_parent_template_id             =>  p_parent_template_id
      ,p_reference_type_cd             => p_reference_type_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REF_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_REF_TEMPLATE
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
  p_ref_template_id := l_ref_template_id;
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
    ROLLBACK TO create_REF_TEMPLATES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ref_template_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_ref_template_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_REF_TEMPLATES;
    raise;
    --
end create_REF_TEMPLATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_REF_TEMPLATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_REF_TEMPLATE
  (p_validate                       in  boolean   default false
  ,p_ref_template_id                in  number
  ,p_base_template_id               in  number    default hr_api.g_number
  ,p_parent_template_id             in  number    default hr_api.g_number
  ,p_reference_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_REF_TEMPLATE';
  l_object_version_number pqh_ref_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_REF_TEMPLATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk2.update_REF_TEMPLATE_b
      (
       p_ref_template_id                =>  p_ref_template_id
      ,p_base_template_id               =>  p_base_template_id
      ,p_parent_template_id             =>  p_parent_template_id
      ,p_reference_type_cd              =>  p_reference_type_cd
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REF_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_REF_TEMPLATE
    --
  end;
  --
  pqh_rft_upd.upd
    (
     p_ref_template_id               => p_ref_template_id
    ,p_base_template_id              => p_base_template_id
    ,p_parent_template_id            => p_parent_template_id
      ,p_reference_type_cd              =>  p_reference_type_cd
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk2.update_REF_TEMPLATE_a
      (
       p_ref_template_id                =>  p_ref_template_id
      ,p_base_template_id               =>  p_base_template_id
      ,p_parent_template_id             =>  p_parent_template_id
      ,p_reference_type_cd              =>  p_reference_type_cd
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REF_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_REF_TEMPLATE
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
    ROLLBACK TO update_REF_TEMPLATES;
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
    ROLLBACK TO update_REF_TEMPLATES;
    raise;
    --
end update_REF_TEMPLATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_REF_TEMPLATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_REF_TEMPLATE
  (p_validate                       in  boolean  default false
  ,p_ref_template_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_REF_TEMPLATE';
  l_object_version_number pqh_ref_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_REF_TEMPLATES;
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
    -- Start of API User Hook for the before hook of delete_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk3.delete_REF_TEMPLATE_b
      (
       p_ref_template_id                =>  p_ref_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REF_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_REF_TEMPLATE
    --
  end;
  --
  pqh_rft_del.del
    (
     p_ref_template_id               => p_ref_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_REF_TEMPLATE
    --
    pqh_REF_TEMPLATES_bk3.delete_REF_TEMPLATE_a
      (
       p_ref_template_id                =>  p_ref_template_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REF_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_REF_TEMPLATE
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
    ROLLBACK TO delete_REF_TEMPLATES;
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
    ROLLBACK TO delete_REF_TEMPLATES;
    raise;
    --
end delete_REF_TEMPLATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ref_template_id                   in     number
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
  pqh_rft_shd.lck
    (
      p_ref_template_id                 => p_ref_template_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_REF_TEMPLATES_api;

/
