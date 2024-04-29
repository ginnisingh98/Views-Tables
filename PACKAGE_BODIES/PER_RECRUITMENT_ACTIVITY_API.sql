--------------------------------------------------------
--  DDL for Package Body PER_RECRUITMENT_ACTIVITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUITMENT_ACTIVITY_API" as
/* $Header: peraaapi.pkb 115.9 2003/11/21 02:04:08 vvayanip ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'PER_RECRUITMENT_ACTIVITY_API.';
--
-- -----------------------------------------------------------------------------
-- |----------------------< CREATE_RECRUITMENT_ACTIVITY >----------------------|
-- -----------------------------------------------------------------------------
--
procedure CREATE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean  default false
  ,p_business_group_id             in   number
  ,p_date_start                    in   date
  ,p_name                          in   varchar2
  ,p_authorising_person_id         in   number     default null
  ,p_run_by_organization_id        in   number     default null
  ,p_internal_contact_person_id    in   number     default null
  ,p_parent_recruitment_activity   in   number     default null
  ,p_currency_code                 in   varchar2   default null
  ,p_actual_cost                   in   varchar2   default null
  ,p_comments                      in   long       default null
  ,p_contact_telephone_number      in   varchar2   default null
  ,p_date_closing                  in   date       default null
  ,p_date_end                      in   date       default null
  ,p_external_contact              in   varchar2   default null
  ,p_planned_cost                  in   varchar2   default null
  ,p_recruiting_site_id            in   number     default null
  ,p_recruiting_site_response      in   varchar2   default null
  ,p_last_posted_date              in   date       default null
  ,p_type                          in   varchar2   default null
  ,p_attribute_category            in   varchar2   default null
  ,p_attribute1                    in   varchar2   default null
  ,p_attribute2                    in   varchar2   default null
  ,p_attribute3                    in   varchar2   default null
  ,p_attribute4                    in   varchar2   default null
  ,p_attribute5                    in   varchar2   default null
  ,p_attribute6                    in   varchar2   default null
  ,p_attribute7                    in   varchar2   default null
  ,p_attribute8                    in   varchar2   default null
  ,p_attribute9                    in   varchar2   default null
  ,p_attribute10                   in   varchar2   default null
  ,p_attribute11                   in   varchar2   default null
  ,p_attribute12                   in   varchar2   default null
  ,p_attribute13                   in   varchar2   default null
  ,p_attribute14                   in   varchar2   default null
  ,p_attribute15                   in   varchar2   default null
  ,p_attribute16                   in   varchar2   default null
  ,p_attribute17                   in   varchar2   default null
  ,p_attribute18                   in   varchar2   default null
  ,p_attribute19                   in   varchar2   default null
  ,p_attribute20                   in   varchar2   default null
  ,p_posting_content_id            in   number     default null
  ,p_status                        in   varchar2   default null
  ,p_object_version_number           out nocopy  number
  ,p_recruitment_activity_id         out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc              varchar2(72) := g_package||'CREATE_RECRUITMENT_ACTIVITY ';
  l_object_version_number number;
  l_recruitment_activity_id number;
  l_effective_date      date          := trunc(p_date_start);
  l_date_start          date          := trunc(p_date_start);
  l_date_end            date          := trunc(p_date_end);
  l_date_closing        date          := trunc(p_date_closing);
--last_posted_date is not truncated to keep the time portion
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RECRUITMENT_ACTIVITY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
   PER_RECRUITMENT_ACTIVITY_BK1.create_recruitment_activity_b(
   p_business_group_id            => p_business_group_id
  ,p_authorising_person_id        => p_authorising_person_id
  ,p_run_by_organization_id       => p_run_by_organization_id
  ,p_internal_contact_person_id   => p_internal_contact_person_id
  ,p_parent_recruitment_activity  => p_parent_recruitment_activity
  ,p_currency_code                => p_currency_code
  ,p_date_start                   => l_date_start
  ,p_name                         => p_name
  ,p_actual_cost                  => p_actual_cost
  ,p_comments                     => p_comments
  ,p_contact_telephone_number     => p_contact_telephone_number
  ,p_date_closing                 => l_date_closing
  ,p_date_end                     => l_date_end
  ,p_external_contact             => p_external_contact
  ,p_planned_cost                 => p_planned_cost
  ,p_recruiting_site_id           => p_recruiting_site_id
  ,p_recruiting_site_response     => p_recruiting_site_response
  ,p_last_posted_date             => p_last_posted_date
  ,p_type                         => p_type
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
  ,p_posting_content_id           => p_posting_content_id
  ,p_status                       => p_status
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RECRUITMENT_ACTIVITY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_raa_ins.ins(
   p_business_group_id              => p_business_group_id
  ,p_date_start                     => l_date_start
  ,p_name                           => p_name
  ,p_authorising_person_id          => p_authorising_person_id
  ,p_run_by_organization_id         => p_run_by_organization_id
  ,p_internal_contact_person_id     => p_internal_contact_person_id
  ,p_parent_recruitment_activity    => p_parent_recruitment_activity
  ,p_currency_code                  => p_currency_code
  ,p_actual_cost                    => p_actual_cost
  ,p_comments                       => p_comments
  ,p_contact_telephone_number       => p_contact_telephone_number
  ,p_date_closing                   => p_date_closing
  ,p_date_end                       => l_date_end
  ,p_external_contact               => p_external_contact
  ,p_planned_cost                   => p_planned_cost
  ,p_recruiting_site_id             => p_recruiting_site_id
  ,p_recruiting_site_response       => p_recruiting_site_response
  ,p_last_posted_date               => p_last_posted_date
  ,p_type                           => p_type
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
  ,p_posting_content_id             => p_posting_content_id
  ,p_status                         => p_status
  ,p_object_version_number          => l_object_version_number
  ,p_recruitment_activity_id        => l_recruitment_activity_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  PER_RECRUITMENT_ACTIVITY_BK1.create_recruitment_activity_a(
   p_business_group_id             => p_business_group_id
  ,p_authorising_person_id         => p_authorising_person_id
  ,p_run_by_organization_id        => p_run_by_organization_id
  ,p_internal_contact_person_id    => p_internal_contact_person_id
  ,p_parent_recruitment_activity   =>  p_parent_recruitment_activity
  ,p_currency_code                 => p_currency_code
  ,p_date_start                    => l_date_start
  ,p_name                          => p_name
  ,p_actual_cost                   => p_actual_cost
  ,p_comments                      => p_comments
  ,p_contact_telephone_number      => p_contact_telephone_number
  ,p_date_closing                  => p_date_closing
  ,p_date_end                      => l_date_end
  ,p_external_contact              => p_external_contact
  ,p_planned_cost                  => p_planned_cost
  ,p_recruiting_site_id            => p_recruiting_site_id
  ,p_recruiting_site_response      => p_recruiting_site_response
  ,p_last_posted_date              => p_last_posted_date
  ,p_type                          => p_type
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_posting_content_id            => p_posting_content_id
  ,p_status                        => p_status
  ,p_object_version_number         => l_object_version_number
  ,p_recruitment_activity_id       => l_recruitment_activity_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RECRUITMENT_ACTIVITY'
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
  p_recruitment_activity_id := l_recruitment_activity_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RECRUITMENT_ACTIVITY ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_recruitment_activity_id := null;
    p_object_version_number   := null;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_recruitment_activity_id := null;
    p_object_version_number   := null;
    rollback to CREATE_RECRUITMENT_ACTIVITY ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_RECRUITMENT_ACTIVITY ;
--
-- -----------------------------------------------------------------------------
-- |----------------------< UPDATE_RECRUITMENT_ACTIVITY >----------------------|
-- -----------------------------------------------------------------------------
--
procedure UPDATE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean    default false
  ,p_recruitment_activity_id       in   number
  ,p_authorising_person_id         in   number     default hr_api.g_number
  ,p_run_by_organization_id        in   number     default hr_api.g_number
  ,p_internal_contact_person_id    in   number     default hr_api.g_number
  ,p_parent_recruitment_activity   in   number     default hr_api.g_number
  ,p_currency_code                 in   varchar2   default hr_api.g_varchar2
  ,p_date_start                    in   date       default hr_api.g_date
  ,p_name                          in   varchar2   default hr_api.g_varchar2
  ,p_actual_cost                   in   varchar2   default hr_api.g_varchar2
  ,p_comments                      in   long       default hr_api.g_varchar2
  ,p_contact_telephone_number      in   varchar2   default hr_api.g_varchar2
  ,p_date_closing                  in   date       default hr_api.g_date
  ,p_date_end                      in   date       default hr_api.g_date
  ,p_external_contact              in   varchar2   default hr_api.g_varchar2
  ,p_planned_cost                  in   varchar2   default hr_api.g_varchar2
  ,p_recruiting_site_id            in   number     default hr_api.g_number
  ,p_recruiting_site_response      in   varchar2   default hr_api.g_varchar2
  ,p_last_posted_date              in   date       default hr_api.g_date
  ,p_type                          in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_posting_content_id            in   number     default hr_api.g_number
  ,p_status                        in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number      in out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc            varchar2(72) := g_package||'UPDATE_RECRUITMENT_ACTIVITY ';
  l_effective_date  date         := trunc(p_date_start);
  l_date_start      date         := trunc(p_date_start);
  l_date_end        date         := trunc(p_date_end);
  l_date_closing    date         := trunc(p_date_closing);
  l_object_version_number number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_RECRUITMENT_ACTIVITY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
  PER_RECRUITMENT_ACTIVITY_BK2.UPDATE_RECRUITMENT_ACTIVITY_B (
     p_recruitment_activity_id       =>        p_recruitment_activity_id
    ,p_authorising_person_id         =>        p_authorising_person_id
    ,p_run_by_organization_id        =>        p_run_by_organization_id
    ,p_internal_contact_person_id    =>        p_internal_contact_person_id
    ,p_parent_recruitment_activity   =>        p_parent_recruitment_activity
    ,p_currency_code                 =>        p_currency_code
    ,p_date_start                    =>        l_date_start
    ,p_name                          =>        p_name
    ,p_actual_cost                   =>        p_actual_cost
    ,p_comments                      =>        p_comments
    ,p_contact_telephone_number      =>        p_contact_telephone_number
    ,p_date_closing                  =>        l_date_closing
    ,p_date_end                      =>        l_date_end
    ,p_external_contact              =>        p_external_contact
    ,p_planned_cost                  =>        p_planned_cost
    ,p_recruiting_site_id            =>        p_recruiting_site_id
    ,p_recruiting_site_response      =>        p_recruiting_site_response
    ,p_last_posted_date              =>        p_last_posted_date
    ,p_type                          =>        p_type
    ,p_attribute_category            =>        p_attribute_category
    ,p_attribute1                    =>        p_attribute1
    ,p_attribute2                    =>        p_attribute2
    ,p_attribute3                    =>        p_attribute3
    ,p_attribute4                    =>        p_attribute4
    ,p_attribute5                    =>        p_attribute5
    ,p_attribute6                    =>        p_attribute6
    ,p_attribute7                    =>        p_attribute7
    ,p_attribute8                    =>        p_attribute8
    ,p_attribute9                    =>        p_attribute9
    ,p_attribute10                   =>        p_attribute10
    ,p_attribute11                   =>        p_attribute11
    ,p_attribute12                   =>        p_attribute12
    ,p_attribute13                   =>        p_attribute13
    ,p_attribute14                   =>        p_attribute14
    ,p_attribute15                   =>        p_attribute15
    ,p_attribute16                   =>        p_attribute16
    ,p_attribute17                   =>        p_attribute17
    ,p_attribute18                   =>        p_attribute18
    ,p_attribute19                   =>        p_attribute19
    ,p_attribute20                   =>        p_attribute20
    ,p_posting_content_id            =>        p_posting_content_id
    ,p_status                        =>        p_status
    ,p_object_version_number         =>        l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RECRUITMENT_ACTIVITY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_raa_upd.upd(
   p_recruitment_activity_id       =>      p_recruitment_activity_id
  ,p_authorising_person_id         =>      p_authorising_person_id
  ,p_run_by_organization_id        =>      p_run_by_organization_id
  ,p_internal_contact_person_id    =>      p_internal_contact_person_id
  ,p_parent_recruitment_activity   =>      p_parent_recruitment_activity
  ,p_currency_code                 =>      p_currency_code
  ,p_date_start                    =>      l_date_start
  ,p_name                          =>      p_name
  ,p_actual_cost                   =>      p_actual_cost
  ,p_comments                      =>      p_comments
  ,p_contact_telephone_number      =>      p_contact_telephone_number
  ,p_date_closing                  =>      l_date_closing
  ,p_date_end                      =>      l_date_end
  ,p_external_contact              =>      p_external_contact
  ,p_planned_cost                  =>      p_planned_cost
  ,p_recruiting_site_id            =>      p_recruiting_site_id
  ,p_recruiting_site_response      =>      p_recruiting_site_response
  ,p_last_posted_date              =>      p_last_posted_date
  ,p_type                          =>      p_type
  ,p_attribute_category            =>      p_attribute_category
  ,p_attribute1                    =>      p_attribute1
  ,p_attribute2                    =>      p_attribute2
  ,p_attribute3                    =>      p_attribute3
  ,p_attribute4                    =>      p_attribute4
  ,p_attribute5                    =>      p_attribute5
  ,p_attribute6                    =>      p_attribute6
  ,p_attribute7                    =>      p_attribute7
  ,p_attribute8                    =>      p_attribute8
  ,p_attribute9                    =>      p_attribute9
  ,p_attribute10                   =>      p_attribute10
  ,p_attribute11                   =>      p_attribute11
  ,p_attribute12                   =>      p_attribute12
  ,p_attribute13                   =>      p_attribute13
  ,p_attribute14                   =>      p_attribute14
  ,p_attribute15                   =>      p_attribute15
  ,p_attribute16                   =>      p_attribute16
  ,p_attribute17                   =>      p_attribute17
  ,p_attribute18                   =>      p_attribute18
  ,p_attribute19                   =>      p_attribute19
  ,p_attribute20                   =>      p_attribute20
  ,p_posting_content_id            =>      p_posting_content_id
  ,p_status                        =>      p_status
  ,p_object_version_number         =>      l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  PER_RECRUITMENT_ACTIVITY_BK2.UPDATE_RECRUITMENT_ACTIVITY_A (
     p_recruitment_activity_id          =>         p_recruitment_activity_id
    ,p_authorising_person_id            =>         p_authorising_person_id
    ,p_run_by_organization_id           =>         p_run_by_organization_id
    ,p_internal_contact_person_id       =>         p_internal_contact_person_id
    ,p_parent_recruitment_activity      =>         p_parent_recruitment_activity
    ,p_currency_code                    =>         p_currency_code
    ,p_date_start                       =>         l_date_start
    ,p_name                             =>         p_name
    ,p_actual_cost                      =>         p_actual_cost
    ,p_comments                         =>         p_comments
    ,p_contact_telephone_number         =>         p_contact_telephone_number
    ,p_date_closing                     =>         l_date_closing
    ,p_date_end                         =>         l_date_end
    ,p_external_contact                 =>         p_external_contact
    ,p_planned_cost                     =>         p_planned_cost
    ,p_recruiting_site_id               =>         p_recruiting_site_id
    ,p_recruiting_site_response         =>         p_recruiting_site_response
    ,p_last_posted_date                 =>         p_last_posted_date
    ,p_type                             =>         p_type
    ,p_attribute_category               =>         p_attribute_category
    ,p_attribute1                       =>         p_attribute1
    ,p_attribute2                       =>         p_attribute2
    ,p_attribute3                       =>         p_attribute3
    ,p_attribute4                       =>         p_attribute4
    ,p_attribute5                       =>         p_attribute5
    ,p_attribute6                       =>         p_attribute6
    ,p_attribute7                       =>         p_attribute7
    ,p_attribute8                       =>         p_attribute8
    ,p_attribute9                       =>         p_attribute9
    ,p_attribute10                      =>         p_attribute10
    ,p_attribute11                      =>         p_attribute11
    ,p_attribute12                      =>         p_attribute12
    ,p_attribute13                      =>         p_attribute13
    ,p_attribute14                      =>         p_attribute14
    ,p_attribute15                      =>         p_attribute15
    ,p_attribute16                      =>         p_attribute16
    ,p_attribute17                      =>         p_attribute17
    ,p_attribute18                      =>         p_attribute18
    ,p_attribute19                      =>         p_attribute19
    ,p_attribute20                      =>         p_attribute20
    ,p_posting_content_id               =>         p_posting_content_id
    ,p_status                           =>         p_status
    ,p_object_version_number            =>         l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RECRUITMENT_ACTIVITY'
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
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_RECRUITMENT_ACTIVITY ;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number     := null;
    rollback to UPDATE_RECRUITMENT_ACTIVITY ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_RECRUITMENT_ACTIVITY;
--
-- -----------------------------------------------------------------------------
-- |--------------------< DELETE_RECRUITMENT_ACTIVITY >------------------------|
-- -----------------------------------------------------------------------------
--
procedure DELETE_RECRUITMENT_ACTIVITY
  (p_validate                      in   boolean    default false
  ,p_object_version_number         in   number
  ,p_recruitment_activity_id       in   number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc            varchar2(72) := g_package||'DELETE_RECRUITMENT_ACTIVITY ';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

  -- Issue a savepoint
  --
  savepoint DELETE_RECRUITMENT_ACTIVITY;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_RECRUITMENT_ACTIVITY_BK3.DELETE_RECRUITMENT_ACTIVITY_b
      ( p_object_version_number    => p_object_version_number
       ,p_recruitment_activity_id          => p_recruitment_activity_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RECRUITMENT_ACTIVITY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_raa_del.del(
   p_recruitment_activity_id      => p_recruitment_activity_id
  ,p_object_version_number        => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    PER_RECRUITMENT_ACTIVITY_BK3.DELETE_RECRUITMENT_ACTIVITY_a
      ( p_object_version_number    => p_object_version_number
       ,p_recruitment_activity_id          => p_recruitment_activity_id
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RECRUITMENT_ACTIVITY'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RECRUITMENT_ACTIVITY ;
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
    rollback to DELETE_RECRUITMENT_ACTIVITY ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_RECRUITMENT_ACTIVITY;
--
end PER_RECRUITMENT_ACTIVITY_API;

/
