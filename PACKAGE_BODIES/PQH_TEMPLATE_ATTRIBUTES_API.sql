--------------------------------------------------------
--  DDL for Package Body PQH_TEMPLATE_ATTRIBUTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TEMPLATE_ATTRIBUTES_API" as
/* $Header: pqtatapi.pkb 115.10 2002/12/06 23:48:33 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_TEMPLATE_ATTRIBUTES_api.';
--
-- ----------------------------------------------------------------------------
--|------------------------< create_TEMPLATE_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_TEMPLATE_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_required_flag                  in  varchar2  default null
  ,p_view_flag                      in  varchar2  default null
  ,p_edit_flag                      in  varchar2  default null
  ,p_template_attribute_id          out nocopy number
  ,p_attribute_id                   in  number    default null
  ,p_template_id                    in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_template_attribute_id pqh_template_attributes.template_attribute_id%TYPE;
  l_proc varchar2(72) := g_package||'create_TEMPLATE_ATTRIBUTE';
  l_object_version_number pqh_template_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_TEMPLATE_ATTRIBUTES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk1.create_TEMPLATE_ATTRIBUTE_b
      (
       p_required_flag                  =>  p_required_flag
      ,p_view_flag                      =>  p_view_flag
      ,p_edit_flag                      =>  p_edit_flag
      ,p_attribute_id                   =>  p_attribute_id
      ,p_template_id                    =>  p_template_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_TEMPLATE_ATTRIBUTE
    --
  end;
  --
  pqh_tat_ins.ins
    (
     p_template_attribute_id         => l_template_attribute_id
    ,p_required_flag                 => p_required_flag
    ,p_view_flag                     => p_view_flag
    ,p_edit_flag                     => p_edit_flag
    ,p_attribute_id                  => p_attribute_id
    ,p_template_id                   => p_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk1.create_TEMPLATE_ATTRIBUTE_a
      (
       p_required_flag                  =>  p_required_flag
      ,p_view_flag                      =>  p_view_flag
      ,p_edit_flag                      =>  p_edit_flag
      ,p_template_attribute_id          =>  l_template_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_template_id                    =>  p_template_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_TEMPLATE_ATTRIBUTE
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
  p_template_attribute_id := l_template_attribute_id;
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
    ROLLBACK TO create_TEMPLATE_ATTRIBUTES;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_attribute_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_TEMPLATE_ATTRIBUTES;
    raise;
    --
end create_TEMPLATE_ATTRIBUTE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_TEMPLATE_ATTRIBUTE >-- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_TEMPLATE_ATTRIBUTE
  (p_validate                       in  boolean   default false
  ,p_required_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_view_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_edit_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_template_attribute_id          in  number
  ,p_attribute_id                   in  number    default hr_api.g_number
  ,p_template_id                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_TEMPLATE_ATTRIBUTE';
  l_object_version_number pqh_template_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_TEMPLATE_ATTRIBUTES;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk2.update_TEMPLATE_ATTRIBUTE_b
      (
       p_required_flag                  =>  p_required_flag
      ,p_view_flag                      =>  p_view_flag
      ,p_edit_flag                      =>  p_edit_flag
      ,p_template_attribute_id          =>  p_template_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_template_id                    =>  p_template_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_TEMPLATE_ATTRIBUTE
    --
  end;
  --
  pqh_tat_upd.upd
    (
     p_template_attribute_id         => p_template_attribute_id
    ,p_required_flag                 => p_required_flag
    ,p_view_flag                     => p_view_flag
    ,p_edit_flag                     => p_edit_flag
    ,p_attribute_id                  => p_attribute_id
    ,p_template_id                   => p_template_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk2.update_TEMPLATE_ATTRIBUTE_a
      (
       p_required_flag                  =>  p_required_flag
      ,p_view_flag                      =>  p_view_flag
      ,p_edit_flag                      =>  p_edit_flag
      ,p_template_attribute_id          =>  p_template_attribute_id
      ,p_attribute_id                   =>  p_attribute_id
      ,p_template_id                    =>  p_template_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_TEMPLATE_ATTRIBUTE
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
    ROLLBACK TO update_TEMPLATE_ATTRIBUTES;
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
    ROLLBACK TO update_TEMPLATE_ATTRIBUTES;
    raise;
    --
end update_TEMPLATE_ATTRIBUTE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_TEMPLATE_ATTRIBUTE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_TEMPLATE_ATTRIBUTE
  (p_validate                       in  boolean  default false
  ,p_template_attribute_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_TEMPLATE_ATTRIBUTE';
  l_object_version_number pqh_template_attributes.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_TEMPLATE_ATTRIBUTES;
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
    -- Start of API User Hook for the before hook of delete_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk3.delete_TEMPLATE_ATTRIBUTE_b
      (
       p_template_attribute_id          =>  p_template_attribute_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_TEMPLATE_ATTRIBUTE
    --
  end;
  --
  pqh_tat_del.del
    (
     p_template_attribute_id         => p_template_attribute_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_TEMPLATE_ATTRIBUTE
    --
    pqh_TEMPLATE_ATTRIBUTES_bk3.delete_TEMPLATE_ATTRIBUTE_a
      (
       p_template_attribute_id          =>  p_template_attribute_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TEMPLATE_ATTRIBUTE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_TEMPLATE_ATTRIBUTE
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
    ROLLBACK TO delete_TEMPLATE_ATTRIBUTES;
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
    ROLLBACK TO delete_TEMPLATE_ATTRIBUTES;
    raise;
    --
end delete_TEMPLATE_ATTRIBUTE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_template_attribute_id                   in     number
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
  pqh_tat_shd.lck
    (
      p_template_attribute_id      => p_template_attribute_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
--
-------------------------------------------------------------------------------
-- |----------------< create_update_copied_attribute >------------------------
-------------------------------------------------------------------------------
--
procedure create_update_copied_attribute
  (
   p_copied_attributes      in     pqh_prvcalc.t_attid_priv,
   p_template_id            in     number
  ) is
  --
  Cursor csr_tem_attr(p_attribute_id in number) is
   Select template_attribute_id,object_version_number
     From pqh_template_attributes
    Where template_id = p_template_id
      and attribute_id = p_attribute_id
      FOR UPDATE ;
  --
  cursor c_select_flag(p_attribute_id number, p_template_id number) is
  select 'x'
  from pqh_attributes att, pqh_txn_category_attributes tct, pqh_templates tem
  where
  att.attribute_id = p_attribute_id
  and att.attribute_id = tct.attribute_id
  and tem.template_id = p_template_id
  and tct.transaction_category_id = tem.transaction_category_id
  and nvl(tct.select_flag,'N')='Y';
  --
  l_template_attribute_id pqh_template_attributes.template_attribute_id%type;
  l_ovn                   pqh_template_attributes.object_version_number%type;
  l_view_flag             pqh_template_attributes.view_flag%type;
  l_edit_flag             pqh_template_attributes.edit_flag%type;
  --
  l_dummy		  varchar2(30);
  --
  l_proc varchar2(72) := g_package||'create_update_copied_attribute';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  For cnt in p_copied_attributes.FIRST .. p_copied_attributes.LAST loop
  --
    open c_select_flag(p_copied_attributes(cnt).attribute_id, p_template_id);
    fetch c_select_flag into l_dummy;
    if c_select_flag%found then
      --
      If  p_copied_attributes(cnt).mode_flag = 'E' then
          l_view_flag := 'Y';
          l_edit_flag := 'Y';
      elsif p_copied_attributes(cnt).mode_flag ='V' then
          l_view_flag := 'Y';
          l_edit_flag := 'N';
      Else
          l_view_flag := 'N';
          l_edit_flag := 'N';
      End if;
      --
     Open csr_tem_attr(p_attribute_id =>p_copied_attributes(cnt).attribute_id);
     --
     Fetch csr_tem_attr into l_template_attribute_id,l_ovn;
     --
     If csr_tem_attr%found then
        --
        pqh_TEMPLATE_ATTRIBUTES_api.update_TEMPLATE_ATTRIBUTE
        (p_validate                 => false
        ,p_required_flag            => p_copied_attributes(cnt).reqd_flag
        ,p_view_flag                => l_view_flag
        ,p_edit_flag                => l_edit_flag
        ,p_template_attribute_id    => l_template_attribute_id
        ,p_attribute_id             => p_copied_attributes(cnt).attribute_id
        ,p_template_id              => p_template_id
        ,p_object_version_number    => l_ovn
        ,p_effective_date           => sysdate);
        --
      Else
        --
        pqh_TEMPLATE_ATTRIBUTES_api.create_TEMPLATE_ATTRIBUTE
        (p_validate                 => false
        ,p_required_flag            => p_copied_attributes(cnt).reqd_flag
        ,p_view_flag                => l_view_flag
        ,p_edit_flag                => l_edit_flag
        ,p_template_attribute_id    => l_template_attribute_id
        ,p_attribute_id             => p_copied_attributes(cnt).attribute_id
        ,p_template_id              => p_template_id
        ,p_object_version_number    => l_ovn
        ,p_effective_date           => sysdate);

        --
      End if;
      --
      Close csr_tem_attr;
    end if;
    close c_select_flag;
  --

  End loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end create_update_copied_attribute;
--
--
end pqh_TEMPLATE_ATTRIBUTES_api;

/
