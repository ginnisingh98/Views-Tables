--------------------------------------------------------
--  DDL for Package Body HXC_ALIAS_DEFINITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ALIAS_DEFINITIONS_API" as
/* $Header: hxchadapi.pkb 120.2 2005/09/23 08:09:15 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_alias_definitions_api.';
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_alias_definition >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id              out nocopy number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2 default null
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_prompt                        in     varchar2 default null
  ,p_timecard_field                in     varchar2
  ,p_object_version_number            out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  ,p_alias_type_id                 in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);
  l_object_version_number hxc_alias_definitions.object_version_number%TYPE;
  l_alias_definition_id   hxc_alias_definitions.alias_definition_id%TYPE;
  l_language_code         hxc_alias_definitions_tl.language%TYPE;

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_alias_definition';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_alias_definition;
  --
  -- Truncate the time portion from all IN date parameters
  --

  -- Validate the language parameter.  l_language_code should be passed
  -- to functions instead of p_language_code from now on, to allow
  -- an IN OUT parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  --
  -- Call Before Process User Hook
  --
  if g_debug then
	hr_utility.set_location('Entering:'|| l_proc, 20);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.create_alias_definition_b
      (p_alias_definition_name         => p_alias_definition_name
      ,p_alias_context_code            => p_alias_context_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_description                   => p_description
      ,p_prompt                        => p_prompt
      ,p_timecard_field                => p_timecard_field
      ,p_language_code                 => l_language_code
      ,p_alias_type_id 		       => p_alias_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_definition'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
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
  -- call row handler to insert record.
  --
  hxc_had_ins.ins
  (p_alias_definition_name          => p_alias_definition_name
  ,p_alias_context_code             => p_alias_context_code
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_timecard_field                 => p_timecard_field
  ,p_description                    => p_description
  ,p_prompt                         => p_prompt
  ,p_alias_definition_id            => l_alias_definition_id
  ,p_object_version_number          => l_object_version_number
  ,p_alias_type_id                 => p_alias_type_id
  );

/*
  -- Call row handler to insert into translated tables
  --
  hxc_dtl_ins.ins_tl
  (p_language_code                  => l_language_code
  ,p_alias_definition_id            => l_alias_definition_id
  ,p_alias_definition_name          => p_alias_definition_name
  ,p_description                    => p_description
  );
*/
  --
  -- Call After Process User Hook
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.create_alias_definition_a
      (p_alias_definition_id           => l_alias_definition_id
      ,p_alias_definition_name	       => p_alias_definition_name
      ,p_alias_context_code            => p_alias_context_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_description		       => p_description
      ,p_prompt                        => p_prompt
      ,p_timecard_field		       => p_timecard_field
      ,p_object_version_number         => l_object_version_number
      ,p_language_code                 => l_language_code
      ,p_alias_type_id                 => p_alias_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_alias_definition'
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
  p_alias_definition_id    := l_alias_definition_id;
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
    rollback to create_alias_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_alias_definition_id    := null;
    p_object_version_number  := null;
    -- p_some_warning           := <local_var_set_in_process_logic>;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_alias_definition;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_alias_definition;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_alias_definition >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id           in     number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2  default null
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_prompt                        in     varchar2 default null
  ,p_timecard_field                in     varchar2
  ,p_object_version_number         in out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  ,p_alias_type_id 		   in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);
  l_object_version_number hxc_alias_definitions.object_version_number%TYPE := p_object_version_number;
  l_language_code         hxc_alias_definitions_tl.language%TYPE;

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_alias_definition';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_alias_definition;
  --
  -- Truncate the time portion from all IN date parameters
  --

  -- Validate the language parameter.  l_language_code should be passed
  -- to functions instead of p_language_code from now on, to allow
  -- an IN OUT parameter to be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --

  --
  -- Call Before Process User Hook
  --
  if g_debug then
	hr_utility.set_location('Entering:'|| l_proc, 20);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.update_alias_definition_b
      (p_alias_definition_id	       => p_alias_definition_id
      ,p_alias_definition_name         => p_alias_definition_name
      ,p_alias_context_code            => p_alias_context_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_description                   => p_description
      ,p_prompt                        => p_prompt
      ,p_timecard_field                => p_timecard_field
      ,p_object_version_number	       => p_object_version_number
      ,p_language_code                 => l_language_code
      ,p_alias_type_id   	       => p_alias_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_alias_definition'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
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
  -- call row handler to update record.
  --
  hxc_had_upd.upd
  (p_alias_definition_id            => p_alias_definition_id
  ,p_object_version_number          => l_object_version_number
  ,p_alias_definition_name          => p_alias_definition_name
  ,p_alias_context_code            => p_alias_context_code
  ,p_business_group_id              => p_business_group_id
  ,p_legislation_code               => p_legislation_code
  ,p_timecard_field                 => p_timecard_field
  ,p_description                    => p_description
  ,p_prompt                         => p_prompt
  ,p_alias_type_id		    => p_alias_type_id
  );
  --
  -- Call row handler to update into translated tables
  --
/*
  hxc_dtl_upd.upd_tl
  (p_language_code                  => l_language_code
  ,p_alias_definition_id            => p_alias_definition_id
  ,p_alias_definition_name          => p_alias_definition_name
  ,p_description                    => p_description
  );
*/
  --
  -- Call After Process User Hook
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.update_alias_definition_a
      (p_alias_definition_id           => p_alias_definition_id
      ,p_alias_definition_name         => p_alias_definition_name
      ,p_alias_context_code            => p_alias_context_code
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_description                   => p_description
      ,p_prompt                        => p_prompt
      ,p_timecard_field                => p_timecard_field
      ,p_object_version_number         => l_object_version_number
      ,p_language_code                 => l_language_code
      ,p_alias_type_id		       => p_alias_type_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_alias_definition'
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
  p_object_version_number  := l_object_version_number;
  -- p_some_warning           := <local_var_set_in_process_logic>;
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
    rollback to update_alias_definition;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    -- p_some_warning           := <local_var_set_in_process_logic>;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_alias_definition;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end update_alias_definition;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_alias_definition >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72);

begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_alias_definition';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_alias_definition;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  if g_debug then
	hr_utility.set_location('Entering:'|| l_proc, 20);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.delete_alias_definition_b
      (p_alias_definition_id           => p_alias_definition_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_definition'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
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
  -- call row handler to delete record.
  --
  hxc_had_del.del
  (p_alias_definition_id            => p_alias_definition_id
  ,p_object_version_number          => p_object_version_number
  );

/*
  --  Remove all matching translation rows
  hxc_dtl_del.del_tl
  (p_alias_definition_id            => p_alias_definition_id
  );
*/  --
  -- Call After Process User Hook
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    hxc_alias_definitions_bk_1.delete_alias_definition_a
      (p_alias_definition_id           => p_alias_definition_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_alias_definition'
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
    rollback to delete_alias_definition;
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
    rollback to delete_alias_definition;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_alias_definition;
--
end hxc_alias_definitions_api;

/
