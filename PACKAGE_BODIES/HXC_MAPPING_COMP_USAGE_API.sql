--------------------------------------------------------
--  DDL for Package Body HXC_MAPPING_COMP_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MAPPING_COMP_USAGE_API" as
/* $Header: hxcmcuapi.pkb 120.2 2005/09/23 05:30:27 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_mapping_comp_usage_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_mapping_comp_usage>----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_mapping_comp_usage
  (p_validate                       in  boolean   default false
  ,p_mapping_comp_usage_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_mapping_id                     in     number
  ,p_mapping_component_id           in     number
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_mapping_comp_usages.object_version_number%TYPE;
	l_mapping_comp_usage_id hxc_mapping_comp_usages.mapping_comp_usage_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  --
  if g_debug then
  	l_proc := g_package||' create_mapping_comp_usage';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_mapping_comp_usage;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_mapping_comp_usage_BK_1.create_mapping_comp_usage_b
	  (p_mapping_comp_usage_id  => p_mapping_comp_usage_id
	  ,p_object_version_number  => p_object_version_number
          ,p_mapping_id             => p_mapping_id
          ,p_mapping_component_id   => p_mapping_component_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_mapping_comp_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
--
-- call row handler
--
hxc_mcu_ins.ins (
   p_mapping_id            => p_mapping_id
  ,p_mapping_component_id  => p_mapping_component_id
  ,p_mapping_comp_usage_id => l_mapping_comp_usage_id
  ,p_object_version_number => l_object_version_number );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_mapping_comp_usage_BK_1.create_mapping_comp_usage_a
	  (p_mapping_comp_usage_id  => l_mapping_comp_usage_id
	  ,p_object_version_number  => l_object_version_number
          ,p_mapping_id             => p_mapping_id
          ,p_mapping_component_id   => p_mapping_component_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_mapping_comp_usage'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 60);
  end if;
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
  --
  -- Set all output arguments
  --
  p_mapping_comp_usage_id := l_mapping_comp_usage_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_mapping_comp_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_mapping_comp_usage_id := null;
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO create_mapping_comp_usage;
    raise;
    --
END create_mapping_comp_usage;
/*
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_mapping_comp_usage>----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping_comp_usage
  (p_validate                       in  boolean   default false
  ,p_mapping_comp_usage_id          in  number
  ,p_object_version_number          in  out nocopy number
  ,p_mapping_id                     in
  ,p_mapping_component_id           in
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_mapping_comp_usages.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_mapping_comp_usage';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_mapping_comp_usage;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_mapping_comp_usage_BK_2.update_mapping_comp_usage_b
	  (p_mapping_comp_usage_id  => p_mapping_comp_usage_id
	  ,p_object_version_number  => p_object_version_number
          ,p_mapping_id             => p_mapping_id
          ,p_mapping_component_id   => p_mapping_component_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_mapping_comp_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
--
-- call row handler
--
hxc_mcu_upd.upd (
   p_mapping_component_id   => p_mapping_component_id
  ,p_mapping_comp_usage_id => p_mapping_comp_usage_id
  ,p_object_version_number => l_object_version_number );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_mapping_comp_usage_BK_2.update_mapping_comp_usage_a
	  (p_mapping_comp_usage_id  => p_mapping_comp_usage_id
	  ,p_object_version_number  => l_object_version_number
          ,p_mapping_id             => p_mapping_id
          ,p_mapping_component_id   => p_mapping_component_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_mapping_comp_usage'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_mapping_comp_usage;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO update_mapping_comp_usage;
    raise;
    --
END update_mapping_comp_usage;
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_mapping_comp_usage >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping_comp_usage
  (p_validate                       in  boolean  default false
  ,p_mapping_comp_usage_id          in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||'delete_mapping_comp_usage';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_mapping_comp_usage;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_mapping_comp_usage_BK_3.delete_mapping_comp_usage_b
	  (p_mapping_comp_usage_id => p_mapping_comp_usage_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_mapping_comp_usage_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
  hxc_mcu_del.del
    (
     p_mapping_comp_usage_id => p_mapping_comp_usage_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  --
  hxc_mapping_comp_usage_BK_3.delete_mapping_comp_usage_a
	  (p_mapping_comp_usage_id => p_mapping_comp_usage_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_mapping_comp_usage_a'
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
  	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_mapping_comp_usage;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_mapping_comp_usage;
    raise;
    --
end delete_mapping_comp_usage;
--
END hxc_mapping_comp_usage_api;

/
