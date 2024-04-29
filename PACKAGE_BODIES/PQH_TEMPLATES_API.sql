--------------------------------------------------------
--  DDL for Package Body PQH_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TEMPLATES_API" as
/* $Header: pqtemapi.pkb 115.11 2002/12/03 20:43:42 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_TEMPLATES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_GENERIC_TEMPLATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_GENERIC_TEMPLATE
  (p_validate                       in  boolean   default false
  ,p_template_name                  in  varchar2
  ,p_short_name                     in  varchar2
  ,p_template_id                    out nocopy number
  ,p_attribute_only_flag            in  varchar2  default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_create_flag                    in  varchar2  default null
  ,p_transaction_category_id        in  number
  ,p_under_review_flag              in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_freeze_status_cd               in  varchar2  default null
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2  default null
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ) is
  --
  -- Declare cursors and local variables
  --
  l_template_id pqh_templates.template_id%TYPE;
  l_proc varchar2(72) := g_package||'create_GENERIC_TEMPLATE';
  l_object_version_number pqh_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_TEMPLATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_GENERIC_TEMPLATE
    --
    PQH_TEMPLATES_BK1.create_GENERIC_TEMPLATE_b
      (
       p_template_name                  =>  p_template_name
      ,p_short_name                  =>  p_short_name
      ,p_attribute_only_flag            =>  p_attribute_only_flag
      ,p_enable_flag                    =>  p_enable_flag
      ,p_create_flag                    =>  p_create_flag
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_under_review_flag              =>  p_under_review_flag
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_template_type_cd               =>  p_template_type_cd
      ,p_legislation_code               =>  p_legislation_code
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_GENERIC_TEMPLATE
    --
  end;
  --
  pqh_tem_ins.ins
    (
     p_template_id                   => l_template_id
    ,p_template_name                 => p_template_name
      ,p_short_name                  =>  p_short_name
    ,p_attribute_only_flag           => p_attribute_only_flag
    ,p_enable_flag                   => p_enable_flag
    ,p_create_flag                   => p_create_flag
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_under_review_flag             => p_under_review_flag
    ,p_object_version_number         => l_object_version_number
    ,p_freeze_status_cd              => p_freeze_status_cd
    ,p_template_type_cd              => p_template_type_cd
    ,p_legislation_code              => p_legislation_code
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  p_template_id := l_template_id;
  --
  pqh_ttl_ins.ins_tl
       (
       p_language_code         => p_language_code,
       p_template_id           => l_template_id ,
       p_template_name         => p_template_name );
  --

  begin
    --
    -- Start of API User Hook for the after hook of create_GENERIC_TEMPLATE
    --
    PQH_TEMPLATES_BK1.create_GENERIC_TEMPLATE_a
      (
       p_template_name                  =>  p_template_name
      ,p_short_name                  =>  p_short_name
      ,p_template_id                    =>  l_template_id
      ,p_attribute_only_flag            =>  p_attribute_only_flag
      ,p_enable_flag                    =>  p_enable_flag
      ,p_create_flag                    =>  p_create_flag
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_under_review_flag              =>  p_under_review_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_template_type_cd               =>  p_template_type_cd
      ,p_legislation_code               =>  p_legislation_code
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_GENERIC_TEMPLATE
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
  p_template_id := l_template_id;
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
    ROLLBACK TO create_TEMPLATES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_template_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_TEMPLATES;
    raise;
    --
end create_GENERIC_TEMPLATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_GENERIC_TEMPLATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_GENERIC_TEMPLATE
  (p_validate                       in  boolean   default false
  ,p_template_name                  in  varchar2  default hr_api.g_varchar2
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_template_id                    in  number
  ,p_attribute_only_flag            in  varchar2  default hr_api.g_varchar2
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_create_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_under_review_flag              in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_freeze_status_cd               in  varchar2  default hr_api.g_varchar2
  ,p_template_type_cd               in  varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_GENERIC_TEMPLATE';
  l_object_version_number pqh_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_TEMPLATES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_GENERIC_TEMPLATE
    --
    pqh_TEMPLATES_bk2.update_GENERIC_TEMPLATE_b
      (
       p_template_name                  =>  p_template_name
      ,p_short_name                     =>  p_short_name
      ,p_template_id                    =>  p_template_id
      ,p_attribute_only_flag            =>  p_attribute_only_flag
      ,p_enable_flag                    =>  p_enable_flag
      ,p_create_flag                    =>  p_create_flag
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_under_review_flag              =>  p_under_review_flag
      ,p_object_version_number          =>  p_object_version_number
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_template_type_cd               =>  p_template_type_cd
      ,p_legislation_code               =>  p_legislation_code
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_GENERIC_TEMPLATE
    --
  end;
  --
  pqh_tem_upd.upd
    (
     p_template_id                   => p_template_id
    ,p_template_name                 => p_template_name
      ,p_short_name                     =>  p_short_name
    ,p_attribute_only_flag           => p_attribute_only_flag
    ,p_enable_flag                   => p_enable_flag
    ,p_create_flag                   => p_create_flag
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_under_review_flag             => p_under_review_flag
    ,p_object_version_number         => l_object_version_number
    ,p_freeze_status_cd              => p_freeze_status_cd
    ,p_template_type_cd              => p_template_type_cd
    ,p_legislation_code              => p_legislation_code
    ,p_effective_date                => trunc(p_effective_date)
    );
   --
  pqh_ttl_upd.upd_tl
       (
       p_language_code             => p_language_code,
       p_template_id               => p_template_id ,
       p_template_name             => p_template_name );
  --

  begin
    --
    -- Start of API User Hook for the after hook of update_GENERIC_TEMPLATE
    --
    pqh_TEMPLATES_bk2.update_GENERIC_TEMPLATE_a
      (
       p_template_name                  =>  p_template_name
      ,p_short_name                     =>  p_short_name
      ,p_template_id                    =>  p_template_id
      ,p_attribute_only_flag            =>  p_attribute_only_flag
      ,p_enable_flag                    =>  p_enable_flag
      ,p_create_flag                    =>  p_create_flag
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_under_review_flag              =>  p_under_review_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_freeze_status_cd               =>  p_freeze_status_cd
      ,p_template_type_cd               =>  p_template_type_cd
      ,p_legislation_code               =>  p_legislation_code
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_GENERIC_TEMPLATE
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
    ROLLBACK TO update_TEMPLATES;
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
    ROLLBACK TO update_TEMPLATES;
    raise;
    --
end update_GENERIC_TEMPLATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_GENERIC_TEMPLATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_GENERIC_TEMPLATE
  (p_validate                       in  boolean  default false
  ,p_template_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_GENERIC_TEMPLATE';
  l_object_version_number pqh_templates.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_TEMPLATES;
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
    -- Start of API User Hook for the before hook of delete_GENERIC_TEMPLATE
    --
    pqh_TEMPLATES_bk3.delete_GENERIC_TEMPLATE_b
      (
       p_template_id                    =>  p_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_GENERIC_TEMPLATE
    --
  end;
  --
  --
  -- Lock the base table
  --
  pqh_tem_shd.lck
    (
      p_template_id                => p_template_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  -- Delete row from translatable table.
  --
  pqh_ttl_del.del_tl
  (
   p_template_id   => p_template_id);
  --
  -- Delete row from base table.
  --
  pqh_tem_del.del
    (
     p_template_id                   => p_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_GENERIC_TEMPLATE
    --
    pqh_TEMPLATES_bk3.delete_GENERIC_TEMPLATE_a
      (
       p_template_id                    =>  p_template_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_GENERIC_TEMPLATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_GENERIC_TEMPLATE
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
    ROLLBACK TO delete_TEMPLATES;
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
    ROLLBACK TO delete_TEMPLATES;
    raise;
    --
end delete_GENERIC_TEMPLATE;
--
/**
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_template_id                   in     number
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
  pqh_tem_shd.lck
    (
      p_template_id                 => p_template_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
**/
--
end pqh_TEMPLATES_api;

/
