--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_STYLES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_STYLES_API" as
/* $Header: hxchasapi.pkb 120.3 2006/06/08 14:58:58 gsirigin noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_approval_styles_api.';
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_styles >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_styles
  (p_validate                      in     boolean  default false
  ,p_approval_style_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number   default null
  ,p_legislation_code		   in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_run_recipient_extensions      in     varchar2 default null
  ,p_admin_role                    in     varchar2 default null
  ,p_error_admin_role              in     varchar2 default null
--  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_approval_styles.object_version_number%TYPE;
  l_approval_style_id     hxc_approval_styles.approval_style_id%TYPE;
--
Begin
--
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_approval_styles';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_approval_styles;
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
    hxc_approval_styles_bk_1.create_approval_styles_b
      (p_approval_style_id             => p_approval_style_id
      ,p_object_version_number         => p_object_version_number
      ,p_name                          => p_name
      ,p_business_group_id	       => p_business_group_id
      ,p_legislation_code	       => p_legislation_code
      ,p_description                   => p_description
      ,p_run_recipient_extensions      => p_run_recipient_extensions
      ,p_admin_role                    => p_admin_role
      ,p_error_admin_role              => p_error_admin_role
--    ,p_effective_date                => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_approval_styles'
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
  hxc_has_ins.ins
    (p_name                    => p_name
    ,p_business_group_id       => p_business_group_id
    ,p_legislation_code	       => p_legislation_code
    ,p_description             => p_description
    ,p_run_recipient_extensions=> p_run_recipient_extensions
    ,p_admin_role              => p_admin_role
    ,p_error_admin_role        => p_error_admin_role
    ,p_approval_style_id       => l_approval_style_id
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
    hxc_approval_styles_bk_1.create_approval_styles_a
      (p_approval_style_id             => p_approval_style_id
      ,p_object_version_number         => p_object_version_number
      ,p_name                          => p_name
      ,p_business_group_id	       => p_business_group_id
      ,p_legislation_code	       => p_legislation_code
      ,p_description                   => p_description
      ,p_run_recipient_extensions      => p_run_recipient_extensions
      ,p_admin_role                    => p_admin_role
      ,p_error_admin_role              => p_error_admin_role
   --   ,p_effective_date                => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_approval_styles'
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
  p_approval_style_id      := l_approval_style_id;
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
    rollback to create_approval_styles;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_approval_style_id      := null;
    p_object_version_number  := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_approval_styles;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_approval_styles;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_approval_styles>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_styles
  (p_validate                      in     boolean  default false
  ,p_approval_style_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number   default hr_api.g_number
  ,p_legislation_code		   in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_run_recipient_extensions      in     varchar2 default hr_api.g_varchar2
  ,p_admin_role                    in     varchar2 default hr_api.g_varchar2
  ,p_error_admin_role              in     varchar2 default hr_api.g_varchar2
 -- ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_approval_styles.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_approval_styles';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_approval_styles;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_approval_styles_bk_1.update_approval_styles_b
    (p_approval_style_id      => p_approval_style_id
    ,p_object_version_number  => p_object_version_number
    ,p_name                   => p_name
    ,p_business_group_id      => p_business_group_id
    ,p_legislation_code	      => p_legislation_code
    ,p_description            => p_description
    ,p_run_recipient_extensions=>p_run_recipient_extensions
    ,p_admin_role             => p_admin_role
    ,p_error_admin_role       => p_error_admin_role
  --  ,p_effective_date         => p_effective_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_approval_styles'
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
hxc_has_upd.upd
  (p_approval_style_id     => p_approval_style_id
  ,p_object_version_number => l_object_version_number
  ,p_name                  => p_name
  ,p_business_group_id     => p_business_group_id
  ,p_legislation_code      => p_legislation_code
  ,p_description           => p_description
  ,p_run_recipient_extensions=>p_run_recipient_extensions
  ,p_admin_role             => p_admin_role
  ,p_error_admin_role       => p_error_admin_role
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
    hxc_approval_styles_bk_1.update_approval_styles_a
  (p_approval_style_id     => p_approval_style_id
  ,p_object_version_number => p_object_version_number
  ,p_name                  => p_name
  ,p_business_group_id	   => p_business_group_id
  ,p_legislation_code	   => p_legislation_code
  ,p_description           => p_description
  ,p_run_recipient_extensions =>p_run_recipient_extensions
  ,p_admin_role             => p_admin_role
  ,p_error_admin_role       => p_error_admin_role
 -- ,p_effective_date        => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_approval_styles'
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
    ROLLBACK TO update_approval_styles;
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
    ROLLBACK TO update_approval_styles;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_approval_styles;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_styles >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_styles
  (p_validate                       in  boolean  default false
  ,p_approval_style_id              in  number
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
	l_proc := g_package||'delete_approval_styles';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_approval_styles;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_approval_styles_bk_1.delete_approval_styles_b
          (p_approval_style_id => p_approval_style_id
          ,p_object_version_number => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_approval_styles'
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
  hxc_has_del.del
    (
     p_approval_style_id     => p_approval_style_id
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
        hxc_approval_styles_bk_1.delete_approval_styles_a
          (p_approval_style_id => p_approval_style_id
          ,p_object_version_number => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_approval_styles'
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
    ROLLBACK TO delete_approval_styles;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_approval_styles;
    raise;
    --
end delete_approval_styles;
--
end hxc_approval_styles_api;

/
