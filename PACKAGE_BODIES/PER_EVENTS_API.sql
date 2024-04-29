--------------------------------------------------------
--  DDL for Package Body PER_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVENTS_API" as
/* $Header: peevtapi.pkb 115.8 2002/12/11 10:37:02 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' per_events_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_event

(p_validate                         in     BOOLEAN   default FALSE
,p_date_start                       in     DATE
,p_type                             in     VARCHAR2
,p_business_group_id                in     NUMBER    default NULL --HR/TCA merge
,p_location_id                      in     NUMBER    default NULL
,p_internal_contact_person_id       in     NUMBER    default NULL
,p_organization_run_by_id           in     NUMBER    default NULL
,p_assignment_id                    in     NUMBER    default NULL
,p_contact_telephone_number         in     VARCHAR2  default NULL
,p_date_end                         in     DATE      default NULL
,p_emp_or_apl                       in     VARCHAR2  default NULL
,p_event_or_interview               in     VARCHAR2  default NULL
,p_external_contact                 in     VARCHAR2  default NULL
,p_time_end                         in     VARCHAR2  default NULL
,p_time_start                       in     VARCHAR2  default NULL
,p_attribute_category               in     VARCHAR2  default NULL
,p_attribute1                       in     VARCHAR2  default NULL
,p_attribute2                       in     VARCHAR2  default NULL
,p_attribute3                       in     VARCHAR2  default NULL
,p_attribute4                       in     VARCHAR2  default NULL
,p_attribute5                       in     VARCHAR2  default NULL
,p_attribute6                       in     VARCHAR2  default NULL
,p_attribute7                       in     VARCHAR2  default NULL
,p_attribute8                       in     VARCHAR2  default NULL
,p_attribute9                       in     VARCHAR2  default NULL
,p_attribute10                      in     VARCHAR2  default NULL
,p_attribute11                      in     VARCHAR2  default NULL
,p_attribute12                      in     VARCHAR2  default NULL
,p_attribute13                      in     VARCHAR2  default NULL
,p_attribute14                      in     VARCHAR2  default NULL
,p_attribute15                      in     VARCHAR2  default NULL
,p_attribute16                      in     VARCHAR2  default NULL
,p_attribute17                      in     VARCHAR2  default NULL
,p_attribute18                      in     VARCHAR2  default NULL
,p_attribute19                      in     VARCHAR2  default NULL
,p_attribute20                      in     VARCHAR2  default NULL
,p_party_id                         in     NUMBER    default NULL
,p_event_id                         out nocopy    NUMBER
,p_object_version_number            out nocopy    NUMBER
 ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'create_event';
  l_event_id               number;
  l_object_version_number  number;
  l_date_start             date;
  l_date_end               date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_event;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_date_start := trunc(p_date_start);
     l_date_end   := trunc(p_date_end);

  --
  -- Call Before Process User Hook
  --
  begin
    per_events_bk1.create_event_b
      (p_date_start                     =>     l_date_start
      ,p_business_group_id              =>     p_business_group_id
      ,p_type                           =>     p_type
      ,p_location_id                    =>     p_location_id
      ,p_internal_contact_person_id     =>     p_internal_contact_person_id
      ,p_organization_run_by_id         =>     p_organization_run_by_id
      ,p_assignment_id                  =>     p_assignment_id
      ,p_contact_telephone_number       =>     p_contact_telephone_number
      ,p_date_end                       =>     l_date_end
      ,p_emp_or_apl                     =>     p_emp_or_apl
      ,p_event_or_interview             =>     p_event_or_interview
      ,p_external_contact               =>     p_external_contact
      ,p_time_end                       =>     p_time_end
      ,p_time_start                     =>     p_time_start
      ,p_attribute_category             =>     p_attribute_category
      ,p_attribute1                     =>     p_attribute1
      ,p_attribute2                     =>     p_attribute2
      ,p_attribute3                     =>     p_attribute3
      ,p_attribute4                     =>     p_attribute4
      ,p_attribute5                     =>     p_attribute5
      ,p_attribute6                     =>     p_attribute6
      ,p_attribute7                     =>     p_attribute7
      ,p_attribute8                     =>     p_attribute8
      ,p_attribute9                     =>     p_attribute9
      ,p_attribute10                    =>     p_attribute10
      ,p_attribute11                    =>     p_attribute11
      ,p_attribute12                    =>     p_attribute12
      ,p_attribute13                    =>     p_attribute13
      ,p_attribute14                    =>     p_attribute14
      ,p_attribute15                    =>     p_attribute15
      ,p_attribute16                    =>     p_attribute16
      ,p_attribute17                    =>     p_attribute17
      ,p_attribute18                    =>     p_attribute18
      ,p_attribute19                    =>     p_attribute19
      ,p_attribute20                    =>     p_attribute20
      ,p_party_id                       =>     p_party_id   --HR/TCA merge
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
per_evt_ins.ins
  (p_date_start                     =>     p_date_start
  ,p_business_group_id              =>     p_business_group_id
  ,p_type                           =>     p_type
  ,p_location_id                    =>     p_location_id
  ,p_internal_contact_person_id     =>     p_internal_contact_person_id
  ,p_organization_run_by_id         =>     p_organization_run_by_id
  ,p_assignment_id                  =>     p_assignment_id
  ,p_contact_telephone_number       =>     p_contact_telephone_number
  ,p_date_end                       =>     p_date_end
  ,p_emp_or_apl                     =>     p_emp_or_apl
  ,p_event_or_interview             =>     p_event_or_interview
  ,p_external_contact               =>     p_external_contact
  ,p_time_end                       =>     p_time_end
  ,p_time_start                     =>     p_time_start
  ,p_attribute_category             =>     p_attribute_category
  ,p_attribute1                     =>     p_attribute1
  ,p_attribute2                     =>     p_attribute2
  ,p_attribute3                     =>     p_attribute3
  ,p_attribute4                     =>     p_attribute4
  ,p_attribute5                     =>     p_attribute5
  ,p_attribute6                     =>     p_attribute6
  ,p_attribute7                     =>     p_attribute7
  ,p_attribute8                     =>     p_attribute8
  ,p_attribute9                     =>     p_attribute9
  ,p_attribute10                    =>     p_attribute10
  ,p_attribute11                    =>     p_attribute11
  ,p_attribute12                    =>     p_attribute12
  ,p_attribute13                    =>     p_attribute13
  ,p_attribute14                    =>     p_attribute14
  ,p_attribute15                    =>     p_attribute15
  ,p_attribute16                    =>     p_attribute16
  ,p_attribute17                    =>     p_attribute17
  ,p_attribute18                    =>     p_attribute18
  ,p_attribute19                    =>     p_attribute19
  ,p_attribute20                    =>     p_attribute20
  ,p_party_id                       =>     p_party_id   --HR/TCA merge
  ,p_event_id                       =>     l_event_id
  ,p_object_version_number          =>     l_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
    per_events_bk1.create_event_a
    (p_date_start                     =>     p_date_start
    ,p_business_group_id              =>     p_business_group_id
    ,p_type                           =>     p_type
    ,p_location_id                    =>     p_location_id
    ,p_internal_contact_person_id     =>     p_internal_contact_person_id
    ,p_organization_run_by_id         =>     p_organization_run_by_id
    ,p_assignment_id                  =>     p_assignment_id
    ,p_contact_telephone_number       =>     p_contact_telephone_number
    ,p_date_end                       =>     p_date_end
    ,p_emp_or_apl                     =>     p_emp_or_apl
    ,p_event_or_interview             =>     p_event_or_interview
    ,p_external_contact               =>     p_external_contact
    ,p_time_end                       =>     p_time_end
    ,p_time_start                     =>     p_time_start
    ,p_attribute_category             =>     p_attribute_category
    ,p_attribute1                     =>     p_attribute1
    ,p_attribute2                     =>     p_attribute2
    ,p_attribute3                     =>     p_attribute3
    ,p_attribute4                     =>     p_attribute4
    ,p_attribute5                     =>     p_attribute5
    ,p_attribute6                     =>     p_attribute6
    ,p_attribute7                     =>     p_attribute7
    ,p_attribute8                     =>     p_attribute8
    ,p_attribute9                     =>     p_attribute9
    ,p_attribute10                    =>     p_attribute10
    ,p_attribute11                    =>     p_attribute11
    ,p_attribute12                    =>     p_attribute12
    ,p_attribute13                    =>     p_attribute13
    ,p_attribute14                    =>     p_attribute14
    ,p_attribute15                    =>     p_attribute15
    ,p_attribute16                    =>     p_attribute16
    ,p_attribute17                    =>     p_attribute17
    ,p_attribute18                    =>     p_attribute18
    ,p_attribute19                    =>     p_attribute19
    ,p_attribute20                    =>     p_attribute20
    ,p_party_id                       =>     p_party_id   -- HR/TCA merge
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_event'
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
  p_event_id               := l_event_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_id               := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_event;
    --
    -- set in out parameters and set out parameters
    --
    p_event_id               := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_event;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_event
(p_validate                         in     BOOLEAN      default FALSE
,p_location_id                      in     NUMBER       default hr_api.g_number
,p_business_group_id                in     NUMBER       default hr_api.g_number
,p_internal_contact_person_id       in     NUMBER       default hr_api.g_number
,p_organization_run_by_id           in     NUMBER       default hr_api.g_number
,p_assignment_id                    in     NUMBER       default hr_api.g_number
,p_contact_telephone_number         in     VARCHAR2     default hr_api.g_varchar2
,p_date_end                         in     DATE         default hr_api.g_date
,p_emp_or_apl                       in     VARCHAR2     default hr_api.g_varchar2
,p_event_or_interview               in     VARCHAR2     default hr_api.g_varchar2
,p_external_contact                 in     VARCHAR2     default hr_api.g_varchar2
,p_time_end                         in     VARCHAR2     default hr_api.g_varchar2
,p_time_start                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute_category               in     VARCHAR2     default hr_api.g_varchar2
,p_attribute1                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute2                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute3                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute4                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute5                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute6                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute7                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute8                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute9                       in     VARCHAR2     default hr_api.g_varchar2
,p_attribute10                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute11                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute12                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute13                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute14                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute15                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute16                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute17                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute18                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute19                      in     VARCHAR2     default hr_api.g_varchar2
,p_attribute20                      in     VARCHAR2     default hr_api.g_varchar2
,p_date_start                       in     DATE         default hr_api.g_date
,p_type                             in     VARCHAR2     default hr_api.g_varchar2
,p_party_id                         in     NUMBER       default hr_api.g_number
,p_event_id                         in out nocopy NUMBER
,p_object_version_number            in out nocopy NUMBER
) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_event';
  l_event_id               number;
  l_object_version_number  number;
  l_date_start             date;
  l_date_end               date;                                                  l_ovn 	           number := p_object_version_number;
  l_temp_event_id 	   number := p_event_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_event;
  --
  -- Truncate the time portion from all IN date parameters
  --
     l_date_start := trunc(p_date_start);
     l_date_end   := trunc(p_date_end);

  --
  -- Call Before Process User Hook
  --
  begin
    per_events_bk2.update_event_b
        (p_event_id                     => p_event_id
        ,p_type                         => p_type
        ,p_location_id                  => p_location_id
        ,p_internal_contact_person_id   => p_internal_contact_person_id
        ,p_organization_run_by_id       => p_organization_run_by_id
        ,p_assignment_id                => p_assignment_id
        ,p_contact_telephone_number     => p_contact_telephone_number
        ,p_date_end                     => l_date_end
        ,p_emp_or_apl                   => p_emp_or_apl
        ,p_event_or_interview           => p_event_or_interview
        ,p_external_contact             => p_external_contact
        ,p_time_end                     => p_time_end
        ,p_time_start                   => p_time_start
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_party_id                     => p_party_id
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  -- None

  --
  -- Process Logic
  --
     l_object_version_number  := p_object_version_number;
     l_event_id               := p_event_id;
     per_evt_upd.upd
        (p_event_id                     => l_event_id
        ,p_object_version_number        => l_object_version_number
        ,p_date_start                   => p_date_start
        ,p_type                         => p_type
        ,p_business_group_id            => p_business_group_id
        ,p_location_id                  => p_location_id
        ,p_internal_contact_person_id   => p_internal_contact_person_id
        ,p_organization_run_by_id       => p_organization_run_by_id
        ,p_assignment_id                => p_assignment_id
        ,p_contact_telephone_number     => p_contact_telephone_number
        ,p_date_end                     => p_date_end
        ,p_emp_or_apl                   => p_emp_or_apl
        ,p_event_or_interview           => p_event_or_interview
        ,p_external_contact             => p_external_contact
        ,p_time_end                     => p_time_end
        ,p_time_start                   => p_time_start
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_party_id                     => p_party_id  -- HR/TCA merge
        );

  --
  -- Call After Process User Hook
  --
  begin
    per_events_bk2.update_event_a
        (p_event_id                     => p_event_id
        ,p_type                         => p_type
        ,p_location_id                  => p_location_id
        ,p_internal_contact_person_id   => p_internal_contact_person_id
        ,p_organization_run_by_id       => p_organization_run_by_id
        ,p_assignment_id                => p_assignment_id
        ,p_contact_telephone_number     => p_contact_telephone_number
        ,p_date_end                     => p_date_end
        ,p_emp_or_apl                   => p_emp_or_apl
        ,p_event_or_interview           => p_event_or_interview
        ,p_external_contact             => p_external_contact
        ,p_time_end                     => p_time_end
        ,p_time_start                   => p_time_start
        ,p_attribute_category           => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_party_id                     => p_party_id  -- HR/TCA merge
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_event'
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
  p_event_id               := l_event_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_event;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_id                := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_event;
    --
    -- set in out parameters and set out parameters
    --
    p_event_id                := l_temp_event_id;
    p_object_version_number  :=  l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_event;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_event
  (p_validate                in   boolean  default false
  ,p_event_id                in   number
  ,p_object_version_number   in   number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'delete_event';
  l_event_id               number;
  l_object_version_number  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_event;

  --
  -- Call Before Process User Hook
  --
  begin
    per_events_bk3.delete_event_b
      (p_event_id                      => p_event_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_event'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

-- NONE

  --
  -- Process Logic
  --
    per_evt_del.del
      (p_event_id                  => p_event_id
       ,p_object_version_number     => p_object_version_number);

  --
  -- Call After Process User Hook
  --
begin
    per_events_bk3.delete_event_a
      (p_event_id                      => p_event_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_event'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_event;
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
    rollback to delete_event;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_event;

--
end per_events_api;

/
