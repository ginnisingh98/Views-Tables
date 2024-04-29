--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMN_API" as
/* $Header: pypucapi.pkb 120.0 2005/05/29 07:57:30 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_user_column_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_column >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_user_table_id                 in     number
  ,p_formula_id                    in     number   default null
  ,p_user_column_name              in     varchar2
  ,p_user_column_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_user_column';
  l_ovn                 number;
  l_user_column_id      number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_column;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_column_bk1.create_user_column_b
      (p_business_group_id     => p_business_group_id
      ,p_legislation_code      => p_legislation_code
      ,p_user_table_id         => p_user_table_id
      ,p_formula_id            => p_formula_id
      ,p_user_column_name      => p_user_column_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_column'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_puc_ins.ins
    (p_business_group_id     => p_business_group_id
    ,p_legislation_code      => p_legislation_code
    ,p_user_table_id         => p_user_table_id
    ,p_formula_id            => p_formula_id
    ,p_user_column_name      => p_user_column_name
    ,p_user_column_id        => l_user_column_id
    ,p_object_version_number => l_ovn
    );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_column_bk1.create_user_column_a
      (p_business_group_id     => p_business_group_id
      ,p_legislation_code      => p_legislation_code
      ,p_user_table_id         => p_user_table_id
      ,p_formula_id            => p_formula_id
      ,p_user_column_name      => p_user_column_name
      ,p_user_column_id        => l_user_column_id
      ,p_object_version_number => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_column'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_user_column_id         := l_user_column_id;
  p_object_version_number  := l_ovn;
  --
--For MLS------------------------------------------------------------------
pay_pct_ins.ins_tl(userenv('LANG'),p_user_column_id,p_user_column_name);
---------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_user_column;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_user_column_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_column;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_user_column;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_column >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column
  (p_validate                      in     boolean  default false
  ,p_user_column_id                in     number
  ,p_user_column_name              in     varchar2 default hr_api.g_varchar2
  ,p_formula_id                    in     number   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_formula_warning                  out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_user_column';
  l_ovn                 number       := p_object_version_number;
  l_formula_warning     boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_column;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_column_bk2.update_user_column_b
      (p_user_column_id        => p_user_column_id
      ,p_formula_id            => p_formula_id
      ,p_user_column_name      => p_user_column_name
      ,p_object_version_number => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_column'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_puc_upd.upd
    (p_formula_id            => p_formula_id
    ,p_user_column_name      => p_user_column_name
    ,p_user_column_id        => p_user_column_id
    ,p_object_version_number => l_ovn
    ,p_formula_warning       => l_formula_warning
    );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_column_bk2.update_user_column_a
      (p_formula_id            => p_formula_id
      ,p_user_column_name      => p_user_column_name
      ,p_user_column_id        => p_user_column_id
      ,p_object_version_number => l_ovn
      ,p_formula_warning       => l_formula_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_column'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_ovn;
  p_formula_warning := l_formula_warning;
  --
--For MLS------------------------------------------------------------------
pay_pct_upd.upd_tl(userenv('LANG'),p_user_column_id,p_user_column_name);
---------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_user_column;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_user_column;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_user_column;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_column >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column
  (p_validate                      in     boolean  default false
  ,p_user_column_id                in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_user_column';
  l_ovn                 number       := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_column;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_column_bk3.delete_user_column_b
      (p_user_column_id                 => p_user_column_id
      ,p_object_version_number          => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_column'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_puc_del.del
  (p_user_column_id        => p_user_column_id
  ,p_object_version_number => l_ovn
  );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_column_bk3.delete_user_column_a
      (p_user_column_id                => p_user_column_id
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_column'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_ovn;
  --
--For MLS------------------------------------------------------------------
pay_pct_del.del_tl(p_user_column_id);
---------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_user_column;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_user_column;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_user_column;
--
end pay_user_column_api;

/
