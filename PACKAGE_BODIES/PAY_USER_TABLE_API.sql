--------------------------------------------------------
--  DDL for Package Body PAY_USER_TABLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_TABLE_API" as
/* $Header: pyputapi.pkb 120.0 2005/05/29 08:02:50 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_user_table_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_table >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_table
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_range_or_match                in     varchar2 default 'M'
  ,p_user_key_units                in     varchar2 default 'N'
  ,p_user_table_name               in     varchar2
  ,p_user_row_title                in     varchar2 default null
  ,p_user_table_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_user_table';
  l_effective_date      date;
  l_ovn                 number;
  l_user_table_id       number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_table;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_table_bk1.create_user_table_b
      (p_effective_date                => l_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_range_or_match                => p_range_or_match
      ,p_user_key_units                => p_user_key_units
      ,p_user_table_name               => p_user_table_name
      ,p_user_row_title                => p_user_row_title
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_table'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_put_ins.ins
    (p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_range_or_match                => p_range_or_match
    ,p_user_key_units                => p_user_key_units
    ,p_user_table_name               => p_user_table_name
    ,p_user_row_title                => p_user_row_title
    ,p_user_table_id                 => l_user_table_id
    ,p_object_version_number         => l_ovn
    );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_table_bk1.create_user_table_a
      (p_effective_date                => l_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_range_or_match                => p_range_or_match
      ,p_user_key_units                => p_user_key_units
      ,p_user_table_name               => p_user_table_name
      ,p_user_row_title                => p_user_row_title
      ,p_user_table_id                 => l_user_table_id
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_user_table'
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
  p_user_table_id          := l_user_table_id;
  p_object_version_number  := l_ovn;
  --
---For MLS----------------------------------------------------------------------
pay_ptt_ins.ins_tl(userenv('LANG'),p_user_table_id,
                             p_user_table_name,p_user_row_title);
--------------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_user_table;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_user_table_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_user_table;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_user_table;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_table >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_table
  (p_validate                      in     boolean  default false
  ,p_user_table_id                 in     number
  ,p_effective_date                in     date
  ,p_user_table_name               in     varchar2 default hr_api.g_varchar2
  ,p_user_row_title                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_user_table';
  l_ovn                 number       := p_object_version_number;
  l_effective_date      date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_table;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_table_bk2.update_user_table_b
      (p_effective_date                => l_effective_date
      ,p_user_table_id                 => p_user_table_id
      ,p_user_table_name               => p_user_table_name
      ,p_user_row_title                => p_user_row_title
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_table'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_put_upd.upd
  (p_effective_date        => l_effective_date
  ,p_user_table_id         => p_user_table_id
  ,p_user_table_name       => p_user_table_name
  ,p_user_row_title        => p_user_row_title
  ,p_object_version_number => l_ovn
  );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_table_bk2.update_user_table_a
      (p_effective_date                => l_effective_date
      ,p_user_table_id                 => p_user_table_id
      ,p_user_table_name               => p_user_table_name
      ,p_user_row_title                => p_user_row_title
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_user_table'
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
---For MLS----------------------------------------------------------------------
pay_ptt_upd.upd_tl(userenv('LANG'),p_user_table_id,
                             p_user_table_name,p_user_row_title);
--------------------------------------------------------------------------------
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_user_table;
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
    rollback to update_user_table;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_user_table;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_table >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_table
  (p_validate                      in     boolean  default false
  ,p_user_table_id                 in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_user_table';
  l_ovn                 number       := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_table;
  --
  -- Call Before Process User Hook
  --
  begin
    pay_user_table_bk3.delete_user_table_b
      (p_user_table_id                 => p_user_table_id
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_table'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pay_put_del.del
  (p_user_table_id         => p_user_table_id
  ,p_object_version_number => l_ovn
  );
  --
  -- Call After Process User Hook
  --
  begin
    pay_user_table_bk3.delete_user_table_a
      (p_user_table_id                 => p_user_table_id
      ,p_object_version_number         => l_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_user_table'
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
---For MLS----------------------------------------------------------------------
pay_ptt_del.del_tl(p_user_table_id);
--------------------------------------------------------------------------------

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_user_table;
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
    rollback to delete_user_table;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_user_table;
--
end pay_user_table_api;

/
