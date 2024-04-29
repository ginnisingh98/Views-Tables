--------------------------------------------------------
--  DDL for Package Body HR_CALENDAR_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CALENDAR_ENTRY_API" as
/* $Header: peentapi.pkb 120.0 2005/05/31 08:08:02 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(22) := 'HR_CALENDAR_ENTRY_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_calendar_entry >---------------------------|
-- ----------------------------------------------------------------------------
--
 procedure create_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2 default null
  ,p_start_min                     in     varchar2 default null
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2 default null
  ,p_end_min                       in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_hierarchy_id                  in     number   default null
  ,p_value_set_id                  in     number   default null
  ,p_organization_structure_id     in     number   default null
  ,p_org_structure_version_id      in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_identifier_key                in     varchar2 default null
  ,p_calendar_entry_id                out nocopy number
  ,p_object_version_number            out nocopy number
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(70) := g_package||'create_calendar_entry';
  l_calendar_entry_id      per_calendar_entries.calendar_entry_id%TYPE;
  l_object_version_number  per_calendar_entries.object_version_number%TYPE;
  l_leg_code               per_calendar_entries.legislation_code%TYPE;
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_calendar_entry;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  if p_legislation_code IS NOT NULL then
    l_leg_code := UPPER(p_legislation_code);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_ENTRY_BK1.create_calendar_entry_b
      (p_effective_date                => l_effective_date
      ,p_name                          => p_name
      ,p_type                          => p_type
      ,p_start_date                    => p_start_date
      ,p_start_hour                    => p_start_hour
      ,p_start_min                     => p_start_min
      ,p_end_date                      => p_end_date
      ,p_end_hour                      => p_end_hour
      ,p_end_min                       => p_end_min
      ,p_business_group_id             => p_business_group_id
      ,p_description                   => p_description
      ,p_hierarchy_id                  => p_hierarchy_id
      ,p_value_set_id                  => p_value_set_id
      ,p_organization_structure_id     => p_organization_structure_id
      ,p_org_structure_version_id      => p_org_structure_version_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_calendar_entry_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_ent_ins.ins
       (p_effective_date                => l_effective_date
       ,p_name                          => p_name
       ,p_type                          => p_type
       ,p_start_date                    => p_start_date
       ,p_start_hour                    => p_start_hour
       ,p_start_min                     => p_start_min
       ,p_end_date                      => p_end_date
       ,p_end_hour                      => p_end_hour
       ,p_end_min                       => p_end_min
       ,p_business_group_id             => p_business_group_id
       ,p_description                   => p_description
       ,p_hierarchy_id                  => p_hierarchy_id
       ,p_value_set_id                  => p_value_set_id
       ,p_organization_structure_id     => p_organization_structure_id
       ,p_org_structure_version_id      => p_org_structure_version_id
       ,p_legislation_code              => l_leg_code
       ,p_identifier_key                => p_identifier_key
       ,p_calendar_entry_id             => l_calendar_entry_id
       ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    HR_CALENDAR_ENTRY_BK1.create_calendar_entry_a
       (p_effective_date                => l_effective_date
       ,p_name                          => p_name
       ,p_type                          => p_type
       ,p_start_date                    => p_start_date
       ,p_start_hour                    => p_start_hour
       ,p_start_min                     => p_start_min
       ,p_end_date                      => p_end_date
       ,p_end_hour                      => p_end_hour
       ,p_end_min                       => p_end_min
       ,p_business_group_id             => p_business_group_id
       ,p_description                   => p_description
       ,p_hierarchy_id                  => p_hierarchy_id
       ,p_value_set_id                  => p_value_set_id
       ,p_organization_structure_id     => p_organization_structure_id
       ,p_org_structure_version_id      => p_org_structure_version_id
       ,p_calendar_entry_id             => l_calendar_entry_id
       ,p_object_version_number         => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_calendar_entry_a'
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
  p_calendar_entry_id      := l_calendar_entry_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_calendar_entry;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_calendar_entry_id      := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_calendar_entry;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_calendar_entry;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_calendar_entry >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_type                          in     varchar2 default hr_api.g_varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2 default hr_api.g_varchar2
  ,p_start_min                     in     varchar2 default hr_api.g_varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2 default hr_api.g_varchar2
  ,p_end_min                       in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  in     number   default hr_api.g_number
  ,p_value_set_id                  in     number   default hr_api.g_number
  ,p_organization_structure_id     in     number   default hr_api.g_number
  ,p_org_structure_version_id      in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(80) := g_package||'update_calendar_entry';
  l_calendar_entry_id      per_calendar_entries.calendar_entry_id%TYPE;
  l_object_version_number  per_calendar_entries.object_version_number%TYPE;
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_calendar_entry;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_ENTRY_BK2.update_calendar_entry_b
      (p_effective_date                => l_effective_date
      ,p_object_version_number         => l_object_version_number
      ,p_calendar_entry_id             => p_calendar_entry_id
      ,p_name                          => p_name
      ,p_type                          => p_type
      ,p_start_date                    => p_start_date
      ,p_start_hour                    => p_start_hour
      ,p_start_min                     => p_start_min
      ,p_end_date                      => p_end_date
      ,p_end_hour                      => p_end_hour
      ,p_end_min                       => p_end_min
      ,p_description                   => p_description
      ,p_hierarchy_id                  => p_hierarchy_id
      ,p_value_set_id                  => p_value_set_id
      ,p_organization_structure_id     => p_organization_structure_id
      ,p_org_structure_version_id      => p_org_structure_version_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_calendar_entry_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_ent_upd.upd
       (p_effective_date               => l_effective_date
       ,p_calendar_entry_id            => p_calendar_entry_id
       ,p_object_version_number        => l_object_version_number
       ,p_name                         => p_name
       ,p_type                         => p_type
       ,p_start_date                   => p_start_date
       ,p_start_hour                   => p_start_hour
       ,p_start_min                    => p_start_min
       ,p_end_date                     => p_end_date
       ,p_end_hour                     => p_end_hour
       ,p_end_min                      => p_end_min
       ,p_description                  => p_description
       ,p_hierarchy_id                 => p_hierarchy_id
       ,p_value_set_id                 => p_value_set_id
       ,p_organization_structure_id    => p_organization_structure_id
       ,p_org_structure_version_id     => p_org_structure_version_id
       ,p_business_group_id            => p_business_group_id
       );

  --
  --
  begin
      HR_CALENDAR_ENTRY_BK2.update_calendar_entry_a
       (p_effective_date                => l_effective_date
       ,p_calendar_entry_id             => p_calendar_entry_id
       ,p_object_version_number         => l_object_version_number
       ,p_name                          => p_name
       ,p_type                          => p_type
       ,p_start_date                    => p_start_date
       ,p_start_hour                    => p_start_hour
       ,p_start_min                     => p_start_min
       ,p_end_date                      => p_end_date
       ,p_end_hour                      => p_end_hour
       ,p_end_min                       => p_end_min
       ,p_description                   => p_description
       ,p_hierarchy_id                  => p_hierarchy_id
       ,p_value_set_id                  => p_value_set_id
       ,p_organization_structure_id     => p_organization_structure_id
       ,p_org_structure_version_id      => p_org_structure_version_id
       );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_calendar_entry_a'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_calendar_entry;
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
    rollback to update_calendar_entry;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_calendar_entry;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_calendar_entry >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_ev IS
  Select env.CAL_ENTRY_VALUE_ID, env.OBJECT_VERSION_NUMBER
  From per_cal_entry_values env
  Where env.calendar_entry_id =  p_calendar_entry_id
  Order By decode(env.parent_ENTRY_VALUE_ID,NULL,1,2) desc;

  --
  l_proc                  varchar2(72) := g_package||'delete_calendar_entry';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_calendar_entry;
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CALENDAR_ENTRY_BK3.delete_calendar_entry_b
     (p_calendar_entry_id       => p_calendar_entry_id,
      p_object_version_number   => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_calendar_entry_b',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- First delete any entry value children
  -- ensuring EVX are removed before EV
  --
  for del_rec in CSR_EV loop
    hr_cal_entry_value_api.DELETE_ENTRY_VALUE
     (P_VALIDATE              => false
     ,P_CAL_ENTRY_VALUE_ID    => del_rec.CAL_ENTRY_VALUE_ID
     ,P_OBJECT_VERSION_NUMBER => del_rec.OBJECT_VERSION_NUMBER);
  end loop;

  hr_utility.set_location(l_proc, 8);

  -- Process Logic
  --
  per_ent_del.del
  (p_calendar_entry_id             => p_calendar_entry_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 9);
  --
  --
  -- Call After Process User Hook
  begin
    HR_CALENDAR_ENTRY_BK3.delete_calendar_entry_a
     (p_calendar_entry_id       => p_calendar_entry_id,
      p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'delete_calendar_entry_a',
            p_hook_type   => 'AP'
           );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_calendar_entry;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_calendar_entry;
  --
  raise;
  --
end delete_calendar_entry;
--
end HR_CALENDAR_ENTRY_API;

/
