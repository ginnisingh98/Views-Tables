--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_PERIOD_COMPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_PERIOD_COMPS_API" as
/* $Header: hxcapcapi.pkb 120.2 2005/09/23 08:04:10 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_approval_period_comps_api.';
g_debug	   boolean	:= hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_period_comps >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_period_comps
  (p_validate                      in     boolean  default false
  ,p_approval_period_comp_id       in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_approval_period_comps.object_version_number%TYPE;
  l_approval_period_comp_id hxc_approval_period_comps.approval_period_comp_id%TYPE;
--
Begin
--
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_approval_period_comps';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_approval_period_comps;
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
   hxc_approval_period_comps_bk_1.create_approval_period_comps_b
  (p_approval_period_comp_id => p_approval_period_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_approval_period_set_id  => p_approval_period_set_id
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_recurring_period_id     => p_recurring_period_id
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_approval_period_comps'
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
  hxc_apc_ins.ins
  (p_effective_date          => p_effective_date
  ,p_recurring_period_id     => p_recurring_period_id
  ,p_approval_period_set_id  => p_approval_period_set_id
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_approval_period_comp_id => l_approval_period_comp_id
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
    hxc_approval_period_comps_bk_1.create_approval_period_comps_a
  (p_approval_period_comp_id        => p_approval_period_comp_id
  ,p_object_version_number          => p_object_version_number
  ,p_approval_period_set_id         => p_approval_period_set_id
  ,p_time_recipient_id              => p_time_recipient_id
  ,p_recurring_period_id            => p_recurring_period_id
  ,p_effective_date                 => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_approval_period_comps'
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
  p_approval_period_comp_id       := l_approval_period_comp_id;
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
    rollback to create_approval_period_comps;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_approval_period_comp_id       := null;
    p_object_version_number  := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_approval_period_comps;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_approval_period_comps;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_approval_period_comps>-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_period_comps
  (p_validate                      in     boolean  default false
  ,p_approval_period_comp_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_approval_period_comps.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_approval_period_comps';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_approval_period_comps;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_approval_period_comps_bk_1.update_approval_period_comps_b
  (p_approval_period_comp_id => p_approval_period_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_approval_period_set_id  => p_approval_period_set_id
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_recurring_period_id     => p_recurring_period_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_approval_period_comps'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --insert into mtemp values('out of comp_b');
  --commit;
  --if g_debug then
	--hr_utility.set_location(l_proc, 30);
  --end if;
  --
  -- Process Logic
--
-- call row handler
--
--insert into mtemp values('calling hxc_hac_upd.upd');
 -- commit;
hxc_apc_upd.upd
  (p_effective_date          => p_effective_date
  ,p_approval_period_comp_id => p_approval_period_comp_id
  ,p_object_version_number   => l_object_version_number
  ,p_recurring_period_id     => p_recurring_period_id
  ,p_approval_period_set_id  => p_approval_period_set_id
  ,p_time_recipient_id       => p_time_recipient_id
  );
--
  --
  --insert into mtemp values('out of hax_hac_upd');
  --commit;

  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_approval_period_comps_bk_1.update_approval_period_comps_a
  (p_approval_period_comp_id => p_approval_period_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_recurring_period_id     => p_recurring_period_id
  ,p_approval_period_set_id  => p_approval_period_set_id
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_approval_period_comps'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --insert into mtemp values('out of comp_a');
  --commit;

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
  --insert into mtemp values('setting OVN value ');
  --commit;

  p_object_version_number := l_object_version_number;
  --
  --insert into mtemp values('OVN value set');
  --commit;

exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_approval_period_comps;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    --insert into mtemp values('OVN set to null');
    --commit;

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_approval_period_comps;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_approval_period_comps;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_period_comps >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_period_comps
  (p_validate                       in  boolean  default false
  ,p_approval_period_comp_id        in  number
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
	l_proc := g_package||'delete_approval_period_comps';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;--
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_approval_period_comps;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_approval_period_comps_bk_1.delete_approval_period_comps_b
          (p_approval_period_comp_id      => p_approval_period_comp_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_approval_period_comps'
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
  hxc_apc_del.del
    (
     p_approval_period_comp_id      => p_approval_period_comp_id
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
        hxc_approval_period_comps_bk_1.delete_approval_period_comps_a
          (p_approval_period_comp_id      => p_approval_period_comp_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_approval_period_comps'
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
    ROLLBACK TO delete_approval_period_comps;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_approval_period_comps;
    raise;
    --
end delete_approval_period_comps;
--
end hxc_approval_period_comps_api;

/
