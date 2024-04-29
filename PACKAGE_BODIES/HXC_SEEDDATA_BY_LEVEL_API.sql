--------------------------------------------------------
--  DDL for Package Body HXC_SEEDDATA_BY_LEVEL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SEEDDATA_BY_LEVEL_API" as
/* $Header: hxchsdapi.pkb 120.2 2005/09/23 10:44:38 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_seeddata_by_level_api.';
g_debug		boolean :=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_seed_data_by_level >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in   number
  ,p_object_type                   in   varchar2
  ,p_hxc_required                  in     varchar2
  ,p_owner_application_id          in   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_seed_data_by_level';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_seed_data_by_level;

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.create_seed_data_by_level_b
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      ,p_hxc_required           => p_hxc_required
      ,p_owner_application_id   => p_owner_application_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_seed_data_by_level'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


  --
  -- Process Logic
  --
  hxc_hsd_ins.ins(
     p_hxc_required              => p_hxc_required
    ,p_owner_application_id      => p_owner_application_id
    ,p_object_id                 => p_object_id
    ,p_object_type               => p_object_type
    );


  --
  -- Call After Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.create_seed_data_by_level_a
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      ,p_hxc_required           => p_hxc_required
      ,p_owner_application_id   => p_owner_application_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_seed_data_by_level'
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_seed_data_by_level;
--

-- ----------------------------------------------------------------------------
-- |----------------------< update_seed_data_by_level >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in   number
  ,p_object_type                   in   varchar2
  ,p_hxc_required                  in     varchar2
  ,p_owner_application_id          in   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_seed_data_by_level';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_seed_data_by_level;

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.update_seed_data_by_level_b
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      ,p_hxc_required           => p_hxc_required
      ,p_owner_application_id   => p_owner_application_id
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_seed_data_by_level'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


  --
  -- Process Logic
  --
  hxc_hsd_upd.upd(
     p_hxc_required              => p_hxc_required
    ,p_owner_application_id      => p_owner_application_id
    ,p_object_id                 => p_object_id
    ,p_object_type               => p_object_type
    );


  --
  -- Call After Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.update_seed_data_by_level_a
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      ,p_hxc_required           => p_hxc_required
      ,p_owner_application_id   => p_owner_application_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_seed_data_by_level'
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_seed_data_by_level;


-- ----------------------------------------------------------------------------
-- |----------------------< delete_seed_data_by_level >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_seed_data_by_level
  (p_validate                      in     boolean  default false
  ,p_object_id                     in   number
  ,p_object_type                   in   varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_seed_data_by_level';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_seed_data_by_level;

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.delete_seed_data_by_level_b
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_seed_data_by_level'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  hxc_hsd_del.del(
    p_object_id                 => p_object_id
    ,p_object_type               => p_object_type
    );


  -- Call After Process User Hook
  --
  begin
    hxc_seeddata_by_level_bk1.delete_seed_data_by_level_a
      (p_object_id              => p_object_id
      ,p_object_type            => p_object_type
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_seed_data_by_level'
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_seed_data_by_level;
    --
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_seed_data_by_level;

end hxc_seeddata_by_level_api;

/
