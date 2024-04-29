--------------------------------------------------------
--  DDL for Package Body HR_NAME_FORMAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAME_FORMAT_API" as
/* $Header: hrnmfapi.pkb 120.0 2005/05/31 01:34:09 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_name_format_api.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_name_format >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_name_format
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_format_name                   in     varchar2
  ,p_user_format_choice            in     varchar2
  ,p_format_mask                   in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_name_format_id                   out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_name_format_id          hr_name_formats.name_format_id%TYPE;
  l_object_version_number   hr_name_formats.object_version_number%TYPE;
  l_effective_date          date;
  l_proc                    varchar2(72) := g_package||'create_name_format';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_name_format;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_name_format_bk1.create_name_format_b
      (p_effective_date                => l_effective_date
      ,p_format_name                   => p_format_name
      ,p_legislation_code              => p_legislation_code
      ,p_user_format_choice            => p_user_format_choice
      ,p_format_mask                   => p_format_mask
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_name_format'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_nmf_ins.ins
     (p_effective_date              => l_effective_date
     ,p_format_name                 => p_format_name
     ,p_user_format_choice          => p_user_format_choice
     ,p_format_mask                 => p_format_mask
     ,p_legislation_code            => p_legislation_code
     ,p_name_format_id              => l_name_format_id
     ,p_object_version_number       => l_object_version_number
     );
  --
  -- Call After Process User Hook
  --
  begin
    hr_name_format_bk1.create_name_format_a
      (p_effective_date                => l_effective_date
      ,p_format_name                   => p_format_name
      ,p_legislation_code              => p_legislation_code
      ,p_user_format_choice            => p_user_format_choice
      ,p_format_mask                   => p_format_mask
      ,p_name_format_id                => l_name_format_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_name_format'
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
  -- Set all OUT parameters with out values
  --
  p_name_format_id         := l_name_format_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_name_format;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_name_format_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_name_format;
    --
    -- Reset OUT parameters to null
    --
    p_name_format_id         := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_name_format;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_name_format >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_name_format
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_name_format_id                in     number
  ,p_format_mask                   in     varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number   hr_name_formats.object_version_number%TYPE;
  l_effective_date          date;
  l_proc                    varchar2(72) := g_package||'update_name_format';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_name_format;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_object_version_number   := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_name_format_bk2.update_name_format_b
      (p_effective_date                => l_effective_date
      ,p_name_format_id                => p_name_format_id
      ,p_format_mask                   => p_format_mask
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_name_format'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_nmf_upd.upd
     (p_effective_date              => l_effective_date
     ,p_name_format_id              => p_name_format_id
     ,p_format_mask                 => p_format_mask
     ,p_object_version_number       => l_object_version_number
     );
  --
  -- Call After Process User Hook
  --
  begin
    hr_name_format_bk2.update_name_format_a
      (p_effective_date                => l_effective_date
      ,p_name_format_id                => p_name_format_id
      ,p_format_mask                   => p_format_mask
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_name_format'
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
  -- Set all OUT parameters with out values
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
    rollback to update_name_format;

    hr_utility.set_location(' Leaving:'||l_proc, 80);

end update_name_format;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_name_format >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_name_format
  (p_validate                      in     boolean  default false
  ,p_name_format_id                in     number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number   hr_name_formats.object_version_number%TYPE;
  l_effective_date          date;
  l_proc                    varchar2(72) := g_package||'delete_name_format';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_name_format;
  --
  l_object_version_number   := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_name_format_bk3.delete_name_format_b
      (p_name_format_id                => p_name_format_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_name_format'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_nmf_del.del
     (p_name_format_id              => p_name_format_id
     ,p_object_version_number       => l_object_version_number
     );
  --
  -- Call After Process User Hook
  --
  begin
    hr_name_format_bk3.delete_name_format_a
      (p_name_format_id                => p_name_format_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_name_format'
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
  -- Set all OUT parameters with out values
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
    rollback to delete_name_format;

    hr_utility.set_location(' Leaving:'||l_proc, 80);

end delete_name_format;
--
--
end hr_name_format_api;

/
