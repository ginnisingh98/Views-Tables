--------------------------------------------------------
--  DDL for Package Body HR_FORM_DATA_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_DATA_GROUPS_API" as
/* $Header: hrfdgapi.pkb 115.4 2002/12/16 09:50:41 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_data_groups_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_data_group >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_application_id                in     number
  ,p_form_id                       in     number
  ,p_data_group_name               in     varchar2
  ,p_user_data_group_name          in     varchar2
  ,p_description                   in     varchar2 default null
  ,p_form_data_group_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;
  l_proc                varchar2(72) := g_package||'create_form_data_group';
  l_form_data_group_id    number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_data_group;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_data_groups_api_bk1.create_form_data_group_b
      (p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      ,p_application_id                => p_application_id
      ,p_form_id                       => p_form_id
      ,p_data_group_name               => p_data_group_name
      ,p_user_data_group_name          => p_user_data_group_name
      ,p_description                   => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_data_group'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fdg_ins.ins(p_application_id              => p_application_id
                 ,p_form_id                     => p_form_id
                 ,p_data_group_name             => p_data_group_name
                 ,p_form_data_group_id          => l_form_data_group_id
                 ,p_object_version_number       => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fgt_ins.ins_tl( p_language_code                => l_language_code
            ,p_form_data_group_id           => l_form_data_group_id
            ,p_user_data_group_name         => p_user_data_group_name
            ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 25);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_data_groups_api_bk1.create_form_data_group_a
            (p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                 => l_language_code
            ,p_application_id                => p_application_id
            ,p_form_id                       => p_form_id
            ,p_data_group_name               => p_data_group_name
            ,p_user_data_group_name          => p_user_data_group_name
            ,p_description                   => p_description
            ,p_form_data_group_id            => l_form_data_group_id
            ,p_object_version_number         => l_object_version_number
            );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_data_group_id     := l_form_data_group_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_data_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_data_group_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_data_group;
    -- Reset out parameters.
    p_form_data_group_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_data_group;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_form_data_group >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group
  (p_validate                      in     boolean  default false
  ,p_form_data_group_id            in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_data_group_item IS
  SELECT form_data_group_item_id
         ,object_version_number
  FROM hr_form_data_group_items
  WHERE form_data_group_id = p_form_data_group_id;

  l_proc                varchar2(72) := g_package||'delete_form_data_group';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_data_group;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_data_groups_api_bk2.delete_form_data_group_b
      (p_form_data_group_id            => p_form_data_group_id
       ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_data_group'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fdg_shd.lck( p_form_data_group_id           => p_form_data_group_id
                  ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  FOR cur_rec IN cur_data_group_item LOOP

    hr_form_data_group_items_api.delete_form_data_group_item(
               p_form_data_group_item_id      => cur_rec.form_data_group_item_id
               ,p_object_version_number       => cur_rec.object_version_number);

  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fgt_del.del_tl( p_form_data_group_id => p_form_data_group_id);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_fdg_del.del( p_form_data_group_id           => p_form_data_group_id
                  ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 50);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_data_groups_api_bk2.delete_form_data_group_a
      (p_form_data_group_id            => p_form_data_group_id
       ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 60);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_form_data_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_form_data_group;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_data_group;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_form_data_group >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_data_group
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  --,p_application_id                in     number
  --,p_form_id                       in     number
  ,p_form_data_group_id            in     number
  ,p_data_group_name               in     varchar2 default hr_api.g_varchar2
  ,p_user_data_group_name          in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'update_form_data_group';
  l_object_version_number number;
  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_data_group;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
     l_object_version_number := p_object_version_number;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_data_groups_api_bk3.update_form_data_group_b
      (p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      --,p_application_id                => p_application_id
      --,p_form_id                       => p_form_id
      ,p_data_group_name               => p_data_group_name
      ,p_user_data_group_name          => p_user_data_group_name
      ,p_description                   => p_description
      ,p_form_data_group_id            => p_form_data_group_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_data_group'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fdg_upd.upd( p_form_data_group_id           => p_form_data_group_id
                  --,p_application_id               => p_application_id
                  --,p_form_id                      => p_form_id
                  ,p_data_group_name              => p_data_group_name
                  ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fgt_upd.upd_tl( p_language_code                => l_language_code
                       ,p_form_data_group_id           => p_form_data_group_id
                       ,p_user_data_group_name         => p_user_data_group_name
                       ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_data_groups_api_bk3.update_form_data_group_a
      (p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      --,p_application_id                => p_application_id
      --,p_form_id                       => p_form_id
      ,p_form_data_group_id            => p_form_data_group_id
      ,p_data_group_name               => p_data_group_name
      ,p_user_data_group_name          => p_user_data_group_name
      ,p_description                   => p_description
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_data_group'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_form_data_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- Reset all in out arguments
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_form_data_group;
    -- Reset all in out arguments
    --
    p_object_version_number  := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_data_group;
--
end hr_form_data_groups_api;

/
