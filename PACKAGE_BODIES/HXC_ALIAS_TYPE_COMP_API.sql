--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_TYPE_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_TYPE_COMP_API" as
/* $Header: hxcatcapi.pkb 120.2 2005/09/23 08:06:42 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  create_alias_type_comp.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alias_type_comp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);
  l_alias_type_component_id      hxc_alias_type_components.alias_type_component_id%TYPE;
  l_object_version_number        hxc_alias_type_components.object_version_number%TYPE;

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_alias_type_comp';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_alias_type_comp;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_type_comp_bk1.create_alias_type_comp_b
      (p_component_name          => p_component_name
      ,p_component_type          => p_component_type
      ,p_mapping_component_id    => p_mapping_component_id
      ,p_alias_type_id           => p_alias_type_id
      ,p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_type_comp'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
      hxc_atc_ins.ins (
        p_component_name                 => p_component_name
       ,p_component_type                 => p_component_type
       ,p_mapping_component_id           => p_mapping_component_id
       ,p_alias_type_id                  => p_alias_type_id
       ,p_alias_type_component_id        => l_alias_type_component_id
       ,p_object_version_number          => l_object_version_number
       );

  --
  -- Call After Process User Hook
  --
  begin
    hxc_alias_type_comp_bk1.create_alias_type_comp_a
      (p_component_name          => p_component_name
      ,p_component_type          => p_component_type
      ,p_mapping_component_id    => p_mapping_component_id
      ,p_alias_type_id           => p_alias_type_id
      ,p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_type_comp'
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
  p_alias_type_component_id := l_alias_type_component_id;
  p_object_version_number   := l_object_version_number;

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
    rollback to create_alias_type_comp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_alias_type_component_id:= null;
    p_object_version_number  := null;

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_alias_type_comp;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_alias_type_comp;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_type_comp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);
  l_object_version_number        hxc_alias_type_components.object_version_number%TYPE := p_object_version_number;

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	 l_proc:= g_package||'update_alias_type_comp';
	 hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_alias_type_comp;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_type_comp_bk1.update_alias_type_comp_b
      (p_component_name          => p_component_name
      ,p_component_type          => p_component_type
      ,p_mapping_component_id    => p_mapping_component_id
      ,p_alias_type_id           => p_alias_type_id
      ,p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_alias_type_comp'
        ,p_hook_type   => 'BP'
        );
  if g_debug then
	hr_utility.trace('After Before User Hook');
  end if;
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  if g_debug then
	hr_utility.trace('Before calling Row Handler');
  end if;
  hxc_atc_upd.upd (
        p_component_name                 => p_component_name
       ,p_component_type                 => p_component_type
       ,p_mapping_component_id           => p_mapping_component_id
       ,p_alias_type_id                  => p_alias_type_id
       ,p_alias_type_component_id        => p_alias_type_component_id
       ,p_object_version_number          => l_object_version_number
       );
  if g_debug then
	hr_utility.trace('After Calling Row Handler');
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  if g_debug then
	hr_utility.trace('Before After user hook');
  end if;
    hxc_alias_type_comp_bk1.update_alias_type_comp_a
      (p_component_name          => p_component_name
      ,p_component_type          => p_component_type
      ,p_mapping_component_id    => p_mapping_component_id
      ,p_alias_type_id           => p_alias_type_id
      ,p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_alias_type_comp'
        ,p_hook_type   => 'AP'
        );
  if g_debug then
	hr_utility.trace('After After user hook');
  end if;
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
  p_object_version_number   := l_object_version_number;

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
    rollback to update_alias_type_comp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_alias_type_comp;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_alias_type_comp;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_type_comp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_type_comp
  (p_validate                      in     boolean  default false
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);


begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	 l_proc:= g_package||'delete_alias_type_comp';
	 hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_alias_type_comp;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_type_comp_bk1.delete_alias_type_comp_b
      (p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_type_comp'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
      hxc_atc_del.del (
        p_alias_type_component_id        => p_alias_type_component_id
       ,p_object_version_number          => p_object_version_number
       );

  --
  -- Call After Process User Hook
  --
  begin
    hxc_alias_type_comp_bk1.delete_alias_type_comp_a
      (p_alias_type_component_id => p_alias_type_component_id
      ,p_object_version_number   => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_type_comp'
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
    rollback to delete_alias_type_comp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_alias_type_comp;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_alias_type_comp;
--
end hxc_alias_type_comp_api;

/
