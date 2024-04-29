--------------------------------------------------------
--  DDL for Package Body PAY_TIME_DEF_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TIME_DEF_USAGE_API" as
/* $Header: pytduapi.pkb 120.1 2005/06/14 14:24:45 tvankayl noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_TIME_DEF_USAGE_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_TIME_DEF_USAGE >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_def_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_usage_type                    in     varchar2
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  l_proc                  varchar2(72) := g_package||'create_time_def_usage';
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_time_def_usage;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    PAY_TIME_DEF_USAGE_BK1.create_time_def_usage_b
      (p_effective_date              => l_effective_date
      ,p_time_definition_id          => p_time_definition_id
      ,p_usage_type                  => p_usage_type
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_def_usage'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  pay_tdu_ins.ins
  (p_effective_date               => l_effective_date
  ,p_time_definition_id           => p_time_definition_id
  ,p_usage_type                   => p_usage_type
  ,p_object_version_number        => l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin

    PAY_TIME_DEF_USAGE_BK1.create_time_def_usage_a
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_usage_type                    => p_usage_type
      ,p_object_version_number         => l_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_def_usage'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_time_def_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_time_def_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_time_def_usage;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_time_def_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_def_usage
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_time_definition_id            in     number
  ,p_usage_type                    in     varchar2
  ,p_object_version_number         in     number
  )is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'delete_time_def_usage';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_time_def_usage;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pay_time_def_usage_bk3.delete_time_def_usage_b
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_usage_type                    => p_usage_type
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_def_usage'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  pay_tdu_del.del
  (p_time_definition_id    => p_time_definition_id
  ,p_usage_type            => p_usage_type
  ,p_object_version_number => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
    pay_time_def_usage_bk3.delete_time_def_usage_a
      (p_effective_date                => l_effective_date
      ,p_time_definition_id            => p_time_definition_id
      ,p_usage_type                    => p_usage_type
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_def_usage'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_time_def_usage;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_time_def_usage;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_time_def_usage;
--
end PAY_TIME_DEF_USAGE_API;

/
