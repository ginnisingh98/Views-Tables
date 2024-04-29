--------------------------------------------------------
--  DDL for Package Body HXC_RECURRING_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RECURRING_PERIODS_API" as
/* $Header: hxchrpapi.pkb 120.2 2005/09/23 10:43:08 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_recurring_periods_api.';
g_debug	   boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_recurring_periods >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_recurring_periods
  (p_validate                      in     boolean  default false
  ,p_recurring_period_id           in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_duration_in_days              in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default null
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_recurring_periods.object_version_number%TYPE;
  l_recurring_period_id     hxc_recurring_periods.recurring_period_id%TYPE;
--
Begin
--

  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_recurring_periods';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_recurring_periods;
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
   hxc_recurring_periods_bk_1.create_recurring_periods_b
  (p_recurring_period_id     => p_recurring_period_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_period_type             => p_period_type
  ,p_duration_in_days        => p_duration_in_days
  ,p_start_date              => p_start_date
  ,p_end_date                => p_end_date
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_recurring_periods'
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
  hxc_hrp_ins.ins
  (p_effective_date        => p_effective_date
  ,p_name                  => p_name
  ,p_period_type           => p_period_type
  ,p_duration_in_days      => p_duration_in_days
  ,p_start_date            => p_start_date
  ,p_end_date              => p_end_date
  ,p_recurring_period_id   => l_recurring_period_id
  ,p_object_version_number => l_object_version_number
  );
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_recurring_periods_bk_1.create_recurring_periods_a
  (p_recurring_period_id     => p_recurring_period_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_period_type             => p_period_type
  ,p_duration_in_days        => p_duration_in_days
  ,p_start_date              => p_start_date
  ,p_end_date                => p_end_date
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_recurring_periods'
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
  p_recurring_period_id    := l_recurring_period_id;
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
    rollback to create_recurring_periods;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_recurring_period_id    := null;
    p_object_version_number  := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_recurring_periods;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --

end create_recurring_periods;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_recurring_periods>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_recurring_periods
  (p_validate                      in     boolean  default false
  ,p_recurring_period_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_duration_in_days              in     number   default null
  ,p_start_date                    in     date	   default null
  ,p_end_date                      in     date     default null
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_recurring_periods.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_recurring_periods';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_recurring_periods;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_recurring_periods_bk_1.update_recurring_periods_b
  (p_recurring_period_id     => p_recurring_period_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_start_date              => p_start_date
  ,p_end_date                => p_end_date
  ,p_period_type             => p_period_type
  ,p_duration_in_days        => p_duration_in_days
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_recurring_periods'
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
hxc_hrp_upd.upd
  (
  p_effective_date         => p_effective_date
  , p_recurring_period_id    => p_recurring_period_id
  ,p_object_version_number  => l_object_version_number
  ,p_name                   => p_name
--  ,p_period_type            => p_period_type
--  ,p_duration_in_days       => p_duration_in_days
--  ,p_start_date             => p_start_date
--  ,p_end_date               => p_end_date
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
    hxc_recurring_periods_bk_1.update_recurring_periods_a
  (p_recurring_period_id     => p_recurring_period_id
  ,p_object_version_number   => p_object_version_number
  ,p_name                    => p_name
  ,p_period_type             => p_period_type
  ,p_duration_in_days        => p_duration_in_days
  ,p_start_date              => p_start_date
  ,p_end_date                => p_end_date
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_recurring_periods'
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
    ROLLBACK TO update_recurring_periods;
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
    ROLLBACK TO update_recurring_periods;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_recurring_periods;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_recurring_periods >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recurring_periods
  (p_validate                       in  boolean  default false
  ,p_recurring_period_id            in  number
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
	l_proc := g_package||'delete_recurring_periods';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_recurring_periods;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_recurring_periods_bk_1.delete_recurring_periods_b
          (p_recurring_period_id   => p_recurring_period_id
          ,p_object_version_number => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_recurring_periods'
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
    hr_utility.set_message(809, 'HXC_REC_PERIOD_DEL_NOT_ALLOWED');
  hr_utility.raise_error;

/*  hxc_hrp_del.del
    (
     p_recurring_period_id   => p_recurring_period_id
    ,p_object_version_number => p_object_version_number
    );
  --
  */

  --
  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  --
        hxc_recurring_periods_bk_1.delete_recurring_periods_a
          (p_recurring_period_id   => p_recurring_period_id
          ,p_object_version_number => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_recurring_periods'
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
    ROLLBACK TO delete_recurring_periods;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_recurring_periods;
    raise;
    --
end delete_recurring_periods;
--
end hxc_recurring_periods_api;

/
