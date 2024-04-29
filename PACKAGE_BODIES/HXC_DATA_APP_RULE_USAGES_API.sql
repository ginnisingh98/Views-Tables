--------------------------------------------------------
--  DDL for Package Body HXC_DATA_APP_RULE_USAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DATA_APP_RULE_USAGES_API" as
/* $Header: hxcdruapi.pkb 120.2 2005/09/23 08:07:08 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_data_app_rule_usages_api.';
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_data_app_rule_usages >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_data_app_rule_usages
  (p_validate                      in     boolean  default false
  ,p_data_app_rule_usage_id        in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_data_app_rule_usages.object_version_number%TYPE;
  l_data_app_rule_usage_id hxc_data_app_rule_usages.data_app_rule_usage_id%TYPE;
--
Begin
--
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_data_app_rule_usages';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_data_app_rule_usages;
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
   hxc_data_app_rule_usages_bk_1.create_data_app_rule_usages_b
  (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
  ,p_object_version_number       => p_object_version_number
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
  ,p_effective_date              => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_data_app_rule_usages'
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
  hxc_dru_ins.ins
  (p_effective_date              => p_effective_date
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
  ,p_data_app_rule_usage_id      => l_data_app_rule_usage_id
  ,p_object_version_number       => l_object_version_number
  );
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_data_app_rule_usages_bk_1.create_data_app_rule_usages_a
  (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
  ,p_object_version_number       => p_object_version_number
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
  ,p_effective_date              => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_data_app_rule_usages'
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
  p_data_app_rule_usage_id      := l_data_app_rule_usage_id;
  p_object_version_number       := l_object_version_number;
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
    rollback to create_data_app_rule_usages;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_data_app_rule_usage_id      := null;
    p_object_version_number       := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_data_app_rule_usages;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_data_app_rule_usages;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_data_app_rule_usages>--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_data_app_rule_usages
  (p_validate                      in     boolean  default false
  ,p_data_app_rule_usage_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_data_app_rule_usages.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_data_app_rule_usages';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_data_app_rule_usages;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_data_app_rule_usages_bk_2.update_data_app_rule_usages_b
  (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
  ,p_object_version_number       => p_object_version_number
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
  ,p_effective_date              => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_data_app_rule_usages'
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
hxc_dru_upd.upd
  (p_effective_date              => p_effective_date
  ,p_data_app_rule_usage_id      => p_data_app_rule_usage_id
  ,p_object_version_number       => l_object_version_number
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
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
    hxc_data_app_rule_usages_bk_2.update_data_app_rule_usages_a
  (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
  ,p_object_version_number       => p_object_version_number
  ,p_approval_style_id           => p_approval_style_id
  ,p_time_entry_rule_id          => p_time_entry_rule_id
  ,p_time_recipient_id           => p_time_recipient_id
  ,p_effective_date              => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_data_app_rule_usages'
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
    ROLLBACK TO update_data_app_rule_usages;
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
    ROLLBACK TO update_data_app_rule_usages;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_data_app_rule_usages;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_data_app_rule_usages >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_data_app_rule_usages
  (p_validate                       in  boolean  default false
  ,p_data_app_rule_usage_id         in  number
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
	l_proc := g_package||'delete_data_app_rule_usages';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_data_app_rule_usages;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_data_app_rule_usages_bk_3.delete_data_app_rule_usages_b
          (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
          ,p_object_version_number       => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_data_app_rule_usages'
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
  hxc_dru_del.del
    (
     p_data_app_rule_usage_id      => p_data_app_rule_usage_id
    ,p_object_version_number       => p_object_version_number
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
        hxc_data_app_rule_usages_bk_3.delete_data_app_rule_usages_a
          (p_data_app_rule_usage_id      => p_data_app_rule_usage_id
          ,p_object_version_number       => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_data_app_rule_usages'
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
    ROLLBACK TO delete_data_app_rule_usages;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_data_app_rule_usages;
    raise;
    --
end delete_data_app_rule_usages;
--
end hxc_data_app_rule_usages_api;

/
