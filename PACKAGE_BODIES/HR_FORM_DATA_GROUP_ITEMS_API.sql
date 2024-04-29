--------------------------------------------------------
--  DDL for Package Body HR_FORM_DATA_GROUP_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_DATA_GROUP_ITEMS_API" as
/* $Header: hrfgiapi.pkb 115.2 2002/12/08 05:12:25 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_data_group_items_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_form_data_group_item >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_data_group_item
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_item_id                  in     number
  ,p_form_data_group_id            in     number
  ,p_form_data_group_item_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_form_data_group_item';
  l_form_data_group_item_id number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_data_group_item;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_data_group_items_bk1.create_form_data_group_item_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_form_item_id                 => p_form_item_id
       ,p_form_data_group_id           => p_form_data_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_data_group_item'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fgi_ins.ins
            (p_form_item_id                 => p_form_item_id
            ,p_form_data_group_id           => p_form_data_group_id
            ,p_form_data_group_item_id      => l_form_data_group_item_id
            ,p_object_version_number        => l_object_version_number);

  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  begin
    hr_form_data_group_items_bk1.create_form_data_group_item_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_form_item_id                 => p_form_item_id
       ,p_form_data_group_id           => p_form_data_group_id
       ,p_form_data_group_item_id      => l_form_data_group_item_id
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_data_group_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 25);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_data_group_item_id := l_form_data_group_item_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_data_group_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_data_group_item_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_data_group_item;
    -- Reset out parameters.
    p_form_data_group_item_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_data_group_item;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_form_data_group_item >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group_item
  (p_validate                      in     boolean  default false
  ,p_form_data_group_item_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_data_group_item';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_data_group_item;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_data_group_items_bk2.delete_form_data_group_item_b
      (p_form_data_group_item_id      => p_form_data_group_item_id
       ,p_object_version_number       => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_data_group_item'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fgi_del.del( p_form_data_group_item_id      => p_form_data_group_item_id
                 ,p_object_version_number       => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_data_group_items_bk2.delete_form_data_group_item_a
      (p_form_data_group_item_id      => p_form_data_group_item_id
       ,p_object_version_number       => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_data_group_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 25);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_form_data_group_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_form_data_group_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_data_group_item;
--
end hr_form_data_group_items_api;

/
