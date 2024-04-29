--------------------------------------------------------
--  DDL for Package Body HXC_TIME_CATEGORY_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_CATEGORY_COMP_API" as
/* $Header: hxctccapi.pkb 120.2 2005/09/23 09:03:22 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_time_category_comp_api.';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_category_comp>----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_category_comp
  (p_validate                       in  boolean   default false
  ,p_time_category_comp_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_id               in  number
  ,p_ref_time_category_id           in number
  ,p_component_type_id                 number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_category_comps.object_version_number%TYPE;
	l_time_category_comp_id hxc_time_category_comps.time_category_comp_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' create_time_category_comp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_time_category_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_category_comp_BK_1.create_time_category_comp_b
  (p_time_category_comp_id    => p_time_category_comp_id
  ,p_object_version_number    => p_object_version_number
  ,p_time_category_id         => p_time_category_id
  ,p_ref_time_category_id     => p_ref_time_category_id
  ,p_component_type_id        => p_component_type_id
  ,p_flex_value_set_id        => p_flex_value_set_id
  ,p_value_id                 => p_value_id
  ,p_is_null                  => p_is_null
  ,p_equal_to                 => p_equal_to
  ,p_type                     => p_type
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_category_comp'
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
hxc_tcc_ins.ins (
   p_time_category_id         => p_time_category_id
  ,p_ref_time_category_id     => p_ref_time_category_id
  ,p_component_type_id        => p_component_type_id
  ,p_flex_value_set_id        => p_flex_value_set_id
  ,p_value_id                 => p_value_id
  ,p_is_null                  => p_is_null
  ,p_equal_to                 => p_equal_to
  ,p_type                     => p_type
  ,p_time_category_comp_id    => l_time_category_comp_id
  ,p_object_version_number    => l_object_version_number
  );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_category_comp_BK_1.create_time_category_comp_a
  (p_time_category_comp_id    => l_time_category_comp_id
  ,p_object_version_number    => l_object_version_number
  ,p_time_category_id         => p_time_category_id
  ,p_ref_time_category_id     => p_ref_time_category_id
  ,p_component_type_id        => p_component_type_id
  ,p_flex_value_set_id        => p_flex_value_set_id
  ,p_value_id                 => p_value_id
  ,p_is_null                  => p_is_null
  ,p_equal_to                 => p_equal_to
  ,p_type                     => p_type
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_category_comp'
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
  p_time_category_comp_id := l_time_category_comp_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_time_category_comp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_time_category_comp_id := null;
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
    ROLLBACK TO create_time_category_comp;
    raise;
    --
END create_time_category_comp;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_category_comp>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category_comp
  (p_validate                       in  boolean   default false
  ,p_time_category_comp_id           in  number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_id             number
  ,p_ref_time_category_id         number
  ,p_component_type_id            number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_category_comps.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||' update_time_category_comp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_time_category_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_category_comp_BK_2.update_time_category_comp_b
  (p_time_category_comp_id    => p_time_category_comp_id
  ,p_object_version_number    => p_object_version_number
  ,p_time_category_id         => p_time_category_id
  ,p_ref_time_category_id     => p_ref_time_category_id
  ,p_component_type_id        => p_component_type_id
  ,p_flex_value_set_id        => p_flex_value_set_id
  ,p_value_id                 => p_value_id
  ,p_is_null                  => p_is_null
  ,p_equal_to                 => p_equal_to
  ,p_type                     => p_type
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_category_comp'
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
hxc_tcc_upd.upd (
   p_time_category_id         => p_time_category_id
  ,p_ref_time_category_id     => p_ref_time_category_id
  ,p_component_type_id        => p_component_type_id
  ,p_flex_value_set_id        => p_flex_value_set_id
  ,p_value_id                 => p_value_id
  ,p_is_null                  => p_is_null
  ,p_equal_to                 => p_equal_to
  ,p_type                     => p_type
  ,p_time_category_comp_id    => p_time_category_comp_id
  ,p_object_version_number   => l_object_version_number
 );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_category_comp_BK_2.update_time_category_comp_a
	  (p_time_category_comp_id   => p_time_category_comp_id
	 ,p_object_version_number    => l_object_version_number
         ,p_time_category_id         => p_time_category_id
         ,p_ref_time_category_id     => p_ref_time_category_id
         ,p_component_type_id        => p_component_type_id
         ,p_flex_value_set_id        => p_flex_value_set_id
         ,p_value_id                 => p_value_id
         ,p_is_null                  => p_is_null
         ,p_equal_to                 => p_equal_to
         ,p_type                     => p_type
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_category_comp'
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
    ROLLBACK TO update_time_category_comp;
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
    ROLLBACK TO update_time_category_comp;
    raise;
    --
END update_time_category_comp;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_category_comp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category_comp
  (p_validate                       in  boolean  default false
  ,p_time_category_comp_id          in  number
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
  	l_proc := g_package||'delete_time_category_comp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_time_category_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
	    hxc_time_category_comp_BK_3.delete_time_category_comp_b
	  (p_time_category_comp_id => p_time_category_comp_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_category_comp_b'
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
  hxc_tcc_del.del
    (
     p_time_category_comp_id => p_time_category_comp_id
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
	hxc_time_category_comp_BK_3.delete_time_category_comp_a
	  (p_time_category_comp_id => p_time_category_comp_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_category_comp_a'
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
    ROLLBACK TO delete_time_category_comp;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_time_category_comp;
    raise;
    --
end delete_time_category_comp;
--
END hxc_time_category_comp_api;

/
