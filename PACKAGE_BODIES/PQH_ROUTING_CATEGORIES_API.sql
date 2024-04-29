--------------------------------------------------------
--  DDL for Package Body PQH_ROUTING_CATEGORIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ROUTING_CATEGORIES_API" as
/* $Header: pqrctapi.pkb 115.11 2002/12/06 18:07:26 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_ROUTING_CATEGORIES_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ROUTING_CATEGORY >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ROUTING_CATEGORY
  (p_validate                       in  boolean   default false
  ,p_routing_category_id            out nocopy number
  ,p_transaction_category_id        in  number    default null
  ,p_enable_flag                    in  varchar2  default 'Y'
  ,p_default_flag                   in  varchar2  default null
  ,p_delete_flag                   in  varchar2  default null
  ,p_routing_list_id                in  number    default null
  ,p_position_structure_id          in  number    default null
  ,p_override_position_id           in  number    default null
  ,p_override_assignment_id         in  number    default null
  ,p_override_role_id             in  number    default null
  ,p_override_user_id             in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_routing_category_id pqh_routing_categories.routing_category_id%TYPE;
  l_proc varchar2(72) := g_package||'create_ROUTING_CATEGORY';
  l_object_version_number pqh_routing_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ROUTING_CATEGORY;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk1.create_ROUTING_CATEGORY_b
      (
       p_transaction_category_id        =>  p_transaction_category_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_default_flag                    =>  p_default_flag
      ,p_delete_flag                    =>  p_delete_flag
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_position_structure_id          =>  p_position_structure_id
      ,p_override_position_id           =>  p_override_position_id
      ,p_override_assignment_id         =>  p_override_assignment_id
      ,p_override_role_id             =>  p_override_role_id
      ,p_override_user_id             =>  p_override_user_id
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ROUTING_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ROUTING_CATEGORY
    --
  end;
  --
  pqh_rct_ins.ins
    (
     p_routing_category_id           => l_routing_category_id
    ,p_transaction_category_id       => p_transaction_category_id
    ,p_enable_flag                   => p_enable_flag
    ,p_default_flag                  => p_default_flag
    ,p_delete_flag                   => p_delete_flag
    ,p_routing_list_id               => p_routing_list_id
    ,p_position_structure_id         => p_position_structure_id
    ,p_override_position_id          => p_override_position_id
    ,p_override_assignment_id        => p_override_assignment_id
    ,p_override_role_id            => p_override_role_id
    ,p_override_user_id            => p_override_user_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk1.create_ROUTING_CATEGORY_a
      (
       p_routing_category_id            =>  l_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_default_flag                   =>  p_default_flag
      ,p_delete_flag                   =>  p_delete_flag
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_position_structure_id          =>  p_position_structure_id
      ,p_override_position_id           =>  p_override_position_id
      ,p_override_assignment_id         =>  p_override_assignment_id
      ,p_override_role_id               =>  p_override_role_id
      ,p_override_user_id               =>  p_override_user_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ROUTING_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ROUTING_CATEGORY
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
  p_routing_category_id := l_routing_category_id;
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
    ROLLBACK TO create_ROUTING_CATEGORY;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_routing_category_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_routing_category_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ROUTING_CATEGORY;
    raise;
    --
end create_ROUTING_CATEGORY;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ROUTING_CATEGORY >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ROUTING_CATEGORY
  (p_validate                       in  boolean   default false
  ,p_routing_category_id            in  number
  ,p_transaction_category_id        in  number    default hr_api.g_number
  ,p_enable_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_default_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_delete_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_routing_list_id                in  number    default hr_api.g_number
  ,p_position_structure_id          in  number    default hr_api.g_number
  ,p_override_position_id           in  number    default hr_api.g_number
  ,p_override_assignment_id         in  number    default hr_api.g_number
  ,p_override_role_id             in  number    default hr_api.g_number
  ,p_override_user_id             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ROUTING_CATEGORY';
  l_object_version_number pqh_routing_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ROUTING_CATEGORY;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk2.update_ROUTING_CATEGORY_b
      (
       p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_default_flag                    =>  p_default_flag
      ,p_delete_flag                    =>  p_delete_flag
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_position_structure_id          =>  p_position_structure_id
      ,p_override_position_id           =>  p_override_position_id
      ,p_override_assignment_id         =>  p_override_assignment_id
      ,p_override_role_id             =>  p_override_role_id
      ,p_override_user_id             =>  p_override_user_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ROUTING_CATEGORY
    --
  end;
  --
  pqh_rct_upd.upd
    (
     p_routing_category_id           => p_routing_category_id
    ,p_transaction_category_id       => p_transaction_category_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_default_flag                    =>  p_default_flag
      ,p_delete_flag                    =>  p_delete_flag
    ,p_routing_list_id               => p_routing_list_id
    ,p_position_structure_id         => p_position_structure_id
    ,p_override_position_id          => p_override_position_id
    ,p_override_assignment_id        => p_override_assignment_id
    ,p_override_role_id            => p_override_role_id
    ,p_override_user_id            => p_override_user_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk2.update_ROUTING_CATEGORY_a
      (
       p_routing_category_id            =>  p_routing_category_id
      ,p_transaction_category_id        =>  p_transaction_category_id
      ,p_enable_flag                    =>  p_enable_flag
      ,p_default_flag                    =>  p_default_flag
      ,p_delete_flag                    =>  p_delete_flag
      ,p_routing_list_id                =>  p_routing_list_id
      ,p_position_structure_id          =>  p_position_structure_id
      ,p_override_position_id           =>  p_override_position_id
      ,p_override_assignment_id         =>  p_override_assignment_id
      ,p_override_role_id             =>  p_override_role_id
      ,p_override_user_id             =>  p_override_user_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ROUTING_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ROUTING_CATEGORY
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
    ROLLBACK TO update_ROUTING_CATEGORY;
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
    ROLLBACK TO update_ROUTING_CATEGORY;
    raise;
    --
end update_ROUTING_CATEGORY;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ROUTING_CATEGORY >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ROUTING_CATEGORY
  (p_validate                       in  boolean  default false
  ,p_routing_category_id            in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_ROUTING_CATEGORY';
  l_object_version_number pqh_routing_categories.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ROUTING_CATEGORY;
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
    -- Start of API User Hook for the before hook of delete_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk3.delete_ROUTING_CATEGORY_b
      (
       p_routing_category_id            =>  p_routing_category_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_CATEGORY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ROUTING_CATEGORY
    --
  end;
  --
  pqh_rct_del.del
    (
     p_routing_category_id           => p_routing_category_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ROUTING_CATEGORY
    --
    pqh_ROUTING_CATEGORIES_bk3.delete_ROUTING_CATEGORY_a
      (
       p_routing_category_id            =>  p_routing_category_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ROUTING_CATEGORY'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ROUTING_CATEGORY
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
    ROLLBACK TO delete_ROUTING_CATEGORY;
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
    ROLLBACK TO delete_ROUTING_CATEGORY;
    raise;
    --
end delete_ROUTING_CATEGORY;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_routing_category_id                   in     number
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
  pqh_rct_shd.lck
    (
      p_routing_category_id                 => p_routing_category_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
------------------------------------------------------------------------------
--
Procedure disable_routing_categories
(p_transaction_category_id in pqh_transaction_categories.transaction_category_id%type,
 p_routing_type            in pqh_transaction_categories.member_cd%type) is
  --
  -- Declare cursors and local variables
  --
  type cur_type IS REF CURSOR;
  rct_cur          cur_type;
  sql_stmt         varchar2(1000);
  --
  l_routing_category_id    pqh_routing_categories.routing_category_id%type;
  l_object_version_number  pqh_routing_categories.object_version_number%type;
  --
  l_proc varchar2(72) := g_package||'disable_routing_categories';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  sql_stmt := 'Select routing_category_id,object_version_number from pqh_routing_categories where transaction_category_id = :t';
  --
  -- Select only the routing categories that belong to the current routing
  -- type of the transaction category.
  --
  If p_routing_type = 'R' then
     --
     sql_stmt := sql_stmt ||' and routing_list_id is not null';
     --
  Elsif p_routing_type = 'P' then
     --
     sql_stmt := sql_stmt ||' and position_structure_id is not null';
     --
  Else
     --
     sql_stmt := sql_stmt ||' and routing_list_id is null and position_structure_id is null';
     --
  End if;
  --
  Open rct_cur for sql_stmt using p_transaction_category_id;
  --
  loop
  --
       Fetch rct_cur into l_routing_category_id,l_object_version_number;
       --
       If rct_cur%notfound then
          exit;
       End if;
       --
       -- set all the selected routing categories to disabled.
       --
       pqh_ROUTING_CATEGORIES_api.update_ROUTING_CATEGORY
        (p_validate                       => false
        ,p_routing_category_id            => l_routing_category_id
        ,p_enable_flag                    => 'N'
        ,p_object_version_number          => l_object_version_number
        ,p_effective_date                 => sysdate
        );
       --
  End loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 70);
  --
End;
--
--
end pqh_ROUTING_CATEGORIES_api;

/
