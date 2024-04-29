--------------------------------------------------------
--  DDL for Package Body HXC_DEPOSIT_PROCESSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DEPOSIT_PROCESSES_API" as
/* $Header: hxchdpapi.pkb 120.2 2005/09/23 10:41:53 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_deposit_processes_api.';
g_debug	 boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_deposit_processes >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_deposit_processes
  (p_validate                      in     boolean  default false
  ,p_deposit_process_id            in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_deposit_processes.object_version_number%TYPE;
  l_deposit_process_id    hxc_deposit_processes.deposit_process_id%TYPE;
--
Begin
--
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc   := g_package||'create_deposit_processes ';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_deposit_processes;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
   hxc_deposit_processes_bk_1.create_deposit_processes_b
  (p_deposit_process_id      => p_deposit_process_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_time_source_id          => p_time_source_id
  ,p_mapping_id              => p_mapping_id
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_deposit_processes'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
  --

  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- call row handler
  --
  hxc_hdp_ins.ins
  (p_effective_date          => p_effective_date
  ,p_name                    => p_name
  ,p_time_source_id          => p_time_source_id
  ,p_mapping_id              => p_mapping_id
  ,p_deposit_process_id      => l_deposit_process_id
  ,p_object_version_number   => l_object_version_number
  );
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_deposit_processes_bk_1.create_deposit_processes_a
  (p_deposit_process_id             => p_deposit_process_id
  ,p_object_version_number          => p_object_version_number
  ,p_name                           => p_name
  ,p_time_source_id                 => p_time_source_id
  ,p_mapping_id                     => p_mapping_id
  ,p_effective_date                 => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_deposit_processes'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 60);
  end if;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --if g_debug then
	--hr_utility.set_location(' Leaving:'||l_proc, 70);
  --end if;
  --
  --
  -- Set all output arguments
  --
  p_deposit_process_id     := l_deposit_process_id;
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
    rollback to create_deposit_processes;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_deposit_process_id     := null;
    p_object_version_number  := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_deposit_processes;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_deposit_processes;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_deposit_processes>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_deposit_processes
  (p_validate                      in     boolean  default false
  ,p_deposit_process_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_time_source_id                in     number
  ,p_mapping_id                    in     number
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_deposit_processes.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_deposit_processes';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_deposit_processes;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_deposit_processes_bk_1.update_deposit_processes_b
  (p_deposit_process_id      => p_deposit_process_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_time_source_id          => p_time_source_id
  ,p_mapping_id              => p_mapping_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_deposit_processes'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --if g_debug then
	--hr_utility.set_location(l_proc, 30);
  --end if;
  --
  -- Process Logic
--
-- call row handler
--
hxc_hdp_upd.upd
  (p_effective_date          => p_effective_date
  ,p_deposit_process_id      => p_deposit_process_id
  ,p_object_version_number   => l_object_version_number
  ,p_name                    => p_name
  ,p_time_source_id          => p_time_source_id
  ,p_mapping_id              => p_mapping_id
  );
--
  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_deposit_processes_bk_1.update_deposit_processes_a
  (p_deposit_process_id      => p_deposit_process_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_time_source_id          => p_time_source_id
  ,p_mapping_id              => p_mapping_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_deposit_processes'
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
    ROLLBACK TO update_deposit_processes;
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
    ROLLBACK TO update_deposit_processes;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_deposit_processes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_deposit_processes >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_deposit_processes
  (p_validate                       in  boolean  default false
  ,p_deposit_process_id             in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_deposit_processes';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_deposit_processes;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_deposit_processes_bk_1.delete_deposit_processes_b
          (p_deposit_process_id           => p_deposit_process_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_deposit_processes'
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
  hxc_hdp_del.del
    (
     p_deposit_process_id           => p_deposit_process_id
    ,p_object_version_number        => p_object_version_number
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
        hxc_deposit_processes_bk_1.delete_deposit_processes_a
          (p_deposit_process_id           => p_deposit_process_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_deposit_processes'
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
    ROLLBACK TO delete_deposit_processes;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_deposit_processes;
    raise;
    --
end delete_deposit_processes;
--
end hxc_deposit_processes_api;

/
