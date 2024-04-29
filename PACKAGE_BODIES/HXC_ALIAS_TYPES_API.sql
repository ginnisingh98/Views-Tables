--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_TYPES_API" as
/* $Header: hxchatapi.pkb 120.2 2005/09/23 10:41:01 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' hxc_alias_types_api. ';
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alias_types >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_types
  (p_validate                      in     boolean  default false,
   p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 out nocopy    number,
   p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_alias_type_id             hxc_alias_types.alias_type_id%TYPE;
  l_object_version_number     hxc_alias_types.object_version_number%TYPE;
  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_alias_types';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_alias_types;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_types_bk1.create_alias_types_b
      (p_alias_type            => p_alias_type,
       p_reference_object      => p_reference_object,
       p_alias_type_id         => p_alias_type_id,
       p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_types'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

  hxc_hat_ins.ins (
       p_alias_type                   => p_alias_type,
       p_reference_object             => p_reference_object,
       p_alias_type_id                => l_alias_type_id,
       p_object_version_number        => l_object_version_number
       );

  --
  -- Call After Process User Hook
  --
  begin
     hxc_alias_types_bk1.create_alias_types_a
      (p_alias_type            => p_alias_type,
       p_reference_object      => p_reference_object,
       p_alias_type_id         => p_alias_type_id,
       p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_types'
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
  p_alias_type_id          := l_alias_type_id;
  p_object_version_number  := l_object_version_number;
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
    rollback to create_alias_types;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_alias_type_id          := null;
    p_object_version_number  := null;

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_alias_types;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_alias_types;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_types >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_types
  (p_validate                      in     boolean  default false,
   p_alias_type                    in     varchar2,
   p_reference_object              in     varchar2,
   p_alias_type_id                 in     number,
   p_object_version_number         in out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number  hxc_alias_types.object_version_number%TYPE := p_object_version_number;
  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_alias_types';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_alias_types;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_types_bk1.update_alias_types_b
      (p_alias_type            => p_alias_type,
       p_reference_object      => p_reference_object,
       p_alias_type_id         => p_alias_type_id,
       p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_types'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  hxc_hat_upd.upd (
       p_alias_type                   => p_alias_type,
       p_reference_object             => p_reference_object,
       p_alias_type_id                => p_alias_type_id,
       p_object_version_number        => l_object_version_number
       );

  --
  -- Call After Process User Hook
  --
  begin
     hxc_alias_types_bk1.update_alias_types_a
      (p_alias_type            => p_alias_type,
       p_reference_object      => p_reference_object,
       p_alias_type_id         => p_alias_type_id,
       p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_alias_types'
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
  --
  -- Set all output arguments
  --
    p_object_version_number  := l_object_version_number;
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
    rollback to update_alias_types;
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
    rollback to update_alias_types;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_alias_types;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_types >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_types
  (p_validate                      in     boolean default FALSE,
   p_alias_type_id                 in     number,
   p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_alias_types';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_alias_types;
  --
  -- Truncate the time portion from all IN date parameters
  if g_debug then
	hr_utility.trace('Before calling Before User Hook');
  end if;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_alias_types_bk1.delete_alias_types_b
      (p_alias_type_id                 => p_alias_type_id,
       p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_types'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  if g_debug then
	hr_utility.trace ('Before Calling Row Handler');
  end if;
  hxc_hat_del.del (
       p_alias_type_id                => p_alias_type_id,
       p_object_version_number        => p_object_version_number
       );

  if g_debug then
	hr_utility.trace('Before calling after user hook');
  end if;
  --
  -- Call After Process User Hook
  --
  begin
     hxc_alias_types_bk1.delete_alias_types_a
      (p_alias_type_id         => p_alias_type_id,
       p_object_version_number => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_types'
        ,p_hook_type   => 'AP'
        );
  end;
  if g_debug then
	hr_utility.trace('After User hook');
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
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
    rollback to delete_alias_types;
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
    rollback to delete_alias_types;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_alias_types;
--

end hxc_alias_types_api;

/
