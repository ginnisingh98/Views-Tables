--------------------------------------------------------
--  DDL for Package Body HXC_TIME_SOURCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_SOURCE_API" as
/* $Header: hxchtsapi.pkb 120.2 2005/09/23 05:26:25 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_time_source_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_source >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_source
  (p_validate                       in  boolean   default false
  ,p_time_source_id                 in  out nocopy hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_sources.object_version_number%TYPE
  ,p_name                           in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_sources.object_version_number%TYPE;
	l_time_source_id            hxc_time_sources.time_source_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  --
  if g_debug then
  	l_proc := g_package||' create_time_source';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_time_source;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_source_BK_1.create_time_source_b
	  (p_time_source_id         => p_time_source_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_source'
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
hxc_hts_ins.ins (
   p_effective_date	=> sysdate
  ,p_name 	        => p_name
  ,p_time_source_id     => l_time_source_id
  ,p_object_version_number => l_object_version_number );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_source_BK_1.create_time_source_a
	  (p_time_source_id             => l_time_source_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_source'
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
  p_time_source_id            := l_time_source_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_time_source;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_time_source_id         := null;
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
    ROLLBACK TO create_time_source;
    raise;
    --
END create_time_source;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_source>   --------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_source
  (p_validate                       in  boolean   default false
  ,p_time_source_id                 in  hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  out nocopy hxc_time_sources.object_version_number%TYPE
  ,p_name                           in     hxc_time_sources.name%TYPE
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_sources.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_time_source';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_time_source;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_source_BK_2.update_time_source_b
	  (p_time_source_id         => p_time_source_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_source'
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
hxc_hts_upd.upd (
   p_effective_date	=> sysdate
  ,p_name                  => p_name
  ,p_time_source_id        => p_time_source_id
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
    hxc_time_source_BK_2.update_time_source_a
	  (p_time_source_id         => p_time_source_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_source'
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
    ROLLBACK TO update_time_source;
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
    ROLLBACK TO update_time_source;
    raise;
    --
END update_time_source;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_source >   -------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_source
  (p_validate                       in  boolean  default false
  ,p_time_source_id                 in  hxc_time_sources.time_source_id%TYPE
  ,p_object_version_number          in  hxc_time_sources.object_version_number%TYPE
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
  	l_proc := g_package||'delete_time_source';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_time_source;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_time_source_BK_3.delete_time_source_b
	  (p_time_source_id        => p_time_source_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_source_b'
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
  hxc_hts_del.del
    (
     p_time_source_id        => p_time_source_id
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
  hxc_time_source_BK_3.delete_time_source_a
	  (p_time_source_id        => p_time_source_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_source_a'
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
    ROLLBACK TO delete_time_source;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_time_source;
    raise;
    --
end delete_time_source;
--
END hxc_time_source_api;

/
