--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_USER_API" as
/* $Header: hrseuapi.pkb 120.3 2005/11/08 16:29:57 vbanner noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_security_user_api.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_security_user >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_security_user
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2 default 'Y'
  ,p_security_user_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) IS

  l_proc                  varchar2(72) := g_package||'create_security_user';
  l_security_user_id      number;
  l_object_version_number number;

BEGIN

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Pipe the main IN / IN OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    IF p_validate THEN
      hr_utility.trace('  p_validate                       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_validate                       '||
                          'FALSE');
    END IF;
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_user_id                        '||
                        to_char(p_user_id));
    hr_utility.trace('  p_security_profile_id            '||
                        to_char(p_security_profile_id));
    hr_utility.trace('  p_process_in_next_run_flag           '||
                        p_process_in_next_run_flag);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  SAVEPOINT create_security_user;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_user_bk1.create_security_user_b
      (p_effective_date               => p_effective_date
      ,p_user_id                      => p_user_id
      ,p_security_profile_id          => p_security_profile_id
	  ,p_process_in_next_run_flag     => p_process_in_next_run_flag);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_user'
        ,p_hook_type   => 'BP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  --
  -- Now call the insert row handler.
  --
  per_seu_ins.ins
    (p_effective_date               => p_effective_date
    ,p_user_id                      => p_user_id
    ,p_security_profile_id          => p_security_profile_id
    ,p_security_user_id             => l_security_user_id
    ,p_process_in_next_run_flag     => p_process_in_next_run_flag
    ,p_object_version_number        => l_object_version_number
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 40);
  END IF;

  --
  -- Call After Process User Hook
  --
  begin
    hr_security_user_bk1.create_security_user_a
      (p_effective_date               => p_effective_date
      ,p_user_id                      => p_user_id
      ,p_security_profile_id          => p_security_profile_id
      ,p_security_user_id             => l_security_user_id
      ,p_process_in_next_run_flag     => p_process_in_next_run_flag
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_security_user'
        ,p_hook_type   => 'AP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 50);
  END IF;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments
  --
  p_security_user_id             := l_security_user_id;
  p_object_version_number        := l_object_version_number;

  IF g_debug THEN
    --
    -- Pipe the main IN OUT / OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_security_user_id               '||
                        to_char(p_security_user_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_process_in_next_run_flag           '||
                        p_process_in_next_run_flag);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

    hr_utility.set_location('Leaving: '||l_proc, 60);

  END IF;

EXCEPTION

  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK to create_security_user;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_security_user_id             := null;
    p_object_version_number        := null;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
    END IF;

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured. Set the out
    -- parameters to null.
    --
    ROLLBACK to create_security_user;
    p_security_user_id             := null;
    p_object_version_number        := null;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 999);
    END IF;

    RAISE;

END create_security_user;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_security_user >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_security_user
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_security_user_id              in     number
  ,p_user_id                       in     number   default hr_api.g_number
  ,p_security_profile_id           in     number   default hr_api.g_number
  ,p_process_in_next_run_flag      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_del_static_lists_warning         out nocopy boolean
  ) IS

  l_proc                     varchar2(72) := g_package||'update_security_user';
  l_object_version_number    number       := p_object_version_number;
  l_del_static_lists_warning boolean;

BEGIN

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Pipe the main IN / IN OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    IF p_validate THEN
      hr_utility.trace('  p_validate                       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_validate                       '||
                          'FALSE');
    END IF;
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_security_user_id               '||
                        to_char(p_security_user_id));
    hr_utility.trace('  p_user_id                        '||
                        to_char(p_user_id));
    hr_utility.trace('  p_security_profile_id            '||
                        to_char(p_security_profile_id));
    hr_utility.trace('  p_process_in_next_run_flag           '||
                        p_process_in_next_run_flag);
    hr_utility.trace('  l_object_version_number          '||
                        to_char(l_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  SAVEPOINT update_security_user;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_user_bk2.update_security_user_b
      (p_effective_date               => p_effective_date
      ,p_security_user_id             => p_security_user_id
      ,p_user_id                      => p_user_id
      ,p_security_profile_id          => p_security_profile_id
      ,p_process_in_next_run_flag     => p_process_in_next_run_flag
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_user'
        ,p_hook_type   => 'BP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  --
  -- Now call the update row handler.
  --
  per_seu_upd.upd
    (p_effective_date               => p_effective_date
    ,p_security_user_id             => p_security_user_id
    ,p_object_version_number        => l_object_version_number
    ,p_user_id                      => p_user_id
    ,p_security_profile_id          => p_security_profile_id
    ,p_process_in_next_run_flag     => p_process_in_next_run_flag
    ,p_del_static_lists_warning     => l_del_static_lists_warning
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 40);
  END IF;

  --
  -- Call After Process User Hook
  --
  begin
    hr_security_user_bk2.update_security_user_a
      (p_effective_date               => p_effective_date
      ,p_security_user_id             => p_security_user_id
      ,p_user_id                      => p_user_id
      ,p_security_profile_id          => p_security_profile_id
      ,p_process_in_next_run_flag     => p_process_in_next_run_flag
      ,p_object_version_number        => l_object_version_number
      ,p_del_static_lists_warning     => l_del_static_lists_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_security_user'
        ,p_hook_type   => 'AP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 50);
  END IF;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments
  --
  p_object_version_number        := l_object_version_number;
  p_del_static_lists_warning     := l_del_static_lists_warning;

  IF g_debug THEN
    --
    -- Pipe the main IN OUT / OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_process_in_next_run_flag           '||
                        p_process_in_next_run_flag);
    IF p_del_static_lists_warning THEN
      hr_utility.trace('  p_del_static_lists_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_del_static_lists_warning       '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

    hr_utility.set_location('Leaving: '||l_proc, 60);

  END IF;

EXCEPTION

  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK to update_security_user;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number        := null;
    p_del_static_lists_warning     := l_del_static_lists_warning;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
    END IF;

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured. Set the out
    -- parameters to null.
    --
    ROLLBACK to update_security_user;
    p_object_version_number        := null;
    p_del_static_lists_warning     := null;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 999);
    END IF;

    RAISE;

END update_security_user;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_security_user >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_security_user
  (p_validate                      in     boolean  default false
  ,p_security_user_id              in     number
  ,p_object_version_number         in     number
  ,p_del_static_lists_warning      out    nocopy boolean
  ) IS

  l_proc                     varchar2(72) := g_package||'delete_security_user';
  l_del_static_lists_warning boolean;

BEGIN

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Pipe the main IN / IN OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    IF p_validate THEN
      hr_utility.trace('  p_validate                       '||
                        'TRUE');
    ELSE
      hr_utility.trace('  p_validate                       '||
                          'FALSE');
    END IF;
    hr_utility.trace('  p_security_user_id               '||
                        to_char(p_security_user_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  SAVEPOINT delete_security_user;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_security_user_bk3.delete_security_user_b
      (p_security_user_id             => p_security_user_id
      ,p_object_version_number        => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_security_user'
        ,p_hook_type   => 'BP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  --
  -- Now call the delete row handler.
  --
  per_seu_del.del
    (p_security_user_id             => p_security_user_id
    ,p_object_version_number        => p_object_version_number
    ,p_del_static_lists_warning     => l_del_static_lists_warning
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 40);
  END IF;

  --
  -- Call After Process User Hook
  --
  begin
    hr_security_user_bk3.delete_security_user_a
      (p_security_user_id             => p_security_user_id
      ,p_object_version_number        => p_object_version_number
      ,p_del_static_lists_warning     => l_del_static_lists_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_security_user'
        ,p_hook_type   => 'AP'
        );
  end;

  IF g_debug THEN
    hr_utility.set_location(l_proc, 50);
  END IF;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all output arguments
  --
  p_del_static_lists_warning     := l_del_static_lists_warning;

  IF g_debug THEN
    --
    -- Pipe the main IN OUT / OUT parameters for ease of debugging.
    --
    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    IF p_del_static_lists_warning THEN
      hr_utility.trace('  p_del_static_lists_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_del_static_lists_warning       '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

    hr_utility.set_location('Leaving: '||l_proc, 60);

  END IF;

EXCEPTION

  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK to delete_security_user;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_del_static_lists_warning := l_del_static_lists_warning;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
    END IF;

  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occured. Set the out
    -- parameters to null.
    --
    ROLLBACK to delete_security_user;
    p_del_static_lists_warning     := null;

    IF g_debug THEN
      hr_utility.set_location(' Leaving:'||l_proc, 999);
    END IF;

    RAISE;

END delete_security_user;
--
end hr_security_user_api;

/
