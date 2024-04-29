--------------------------------------------------------
--  DDL for Package Body HR_DEPLOYMENT_FACTOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEPLOYMENT_FACTOR_API" as
/* $Header: pedpfapi.pkb 115.6 2004/01/29 07:04:19 adudekul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_deployment_factor_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_dpmt_factor >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_visit_internationally        in     varchar2 default null
  ,p_only_current_location        in     varchar2 default null
  ,p_no_country1                  in     varchar2 default null
  ,p_no_country2                  in     varchar2 default null
  ,p_no_country3                  in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_earliest_available_date      in     date     default null
  ,p_available_for_transfer       in     varchar2 default null
  ,p_relocation_preference        in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_earliest_available_date date;
  l_proc                varchar2(72) := g_package||'create_person_dpmt_factor';
  l_deployment_factor_id per_deployment_factors.deployment_factor_id%type;
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_business_group_id per_all_people_f.business_group_id%type;
  --
  cursor get_bg is
  select business_group_id
  from per_all_people_f
  where person_id=p_person_id
  and   rownum = 1; -- Added for bug 3387339.
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_dpmt_factor;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  l_earliest_available_date:=trunc(p_earliest_available_date);
  --
  -- get the business group
  --
  open get_bg;
  fetch get_bg into l_business_group_id;
  close get_bg;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk1.create_person_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_person_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_ins.ins
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk1.create_person_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_person_dpmt_factor'
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
  p_deployment_factor_id   := l_deployment_factor_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_deployment_factor_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
     p_deployment_factor_id   := null;
     p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_person_dpmt_factor;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_dpmt_factor >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_visit_internationally        in     varchar2 default hr_api.g_varchar2
  ,p_only_current_location        in     varchar2 default hr_api.g_varchar2
  ,p_no_country1                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country2                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country3                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_earliest_available_date      in     date     default hr_api.g_date
  ,p_available_for_transfer       in     varchar2 default hr_api.g_varchar2
  ,p_relocation_preference        in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_earliest_available_date date;
  l_proc                varchar2(72) := g_package||'update_person_dpmt_factor';
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_ovn per_deployment_factors.object_version_number%type := p_object_version_number;
  l_api_updating boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_dpmt_factor;
  --
  l_object_version_number:=p_object_version_number;
  --
  l_api_updating:=per_dpf_shd.api_updating
  (p_deployment_factor_id=>p_deployment_factor_id
  ,p_object_version_number=>l_object_version_number);
  --
  if not l_api_updating
  then
    --
    hr_utility.set_location(l_proc, 20);
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  l_earliest_available_date:=trunc(p_earliest_available_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk2.update_person_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_person_id                     => per_dpf_shd.g_old_rec.person_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_person_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_upd.upd
      (p_effective_date                => l_effective_date
      ,p_person_id                     => per_dpf_shd.g_old_rec.person_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk2.update_person_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_person_id                     => per_dpf_shd.g_old_rec.person_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_comments                      => p_comments
      ,p_earliest_available_date       => l_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_person_dpmt_factor'
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
    rollback to update_person_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
     p_object_version_number  := l_ovn;
   --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_person_dpmt_factor;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_position_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_position_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_position_id                  in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_relocation_required          in     varchar2 default null
  ,p_passport_required            in     varchar2 default null
  ,p_location1                    in     varchar2 default null
  ,p_location2                    in     varchar2 default null
  ,p_location3                    in     varchar2 default null
  ,p_other_requirements           in     varchar2 default null
  ,p_service_minimum              in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_proc                varchar2(72) := g_package||'create_position_dpmt_factor';
  l_deployment_factor_id per_deployment_factors.deployment_factor_id%type;
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_business_group_id hr_all_positions_f.business_group_id%type;
  --
  cursor get_bg is
  select business_group_id
  from hr_all_positions_f
  where position_id=p_position_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_position_dpmt_factor;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  --
  -- get the business group id
  --
  open get_bg;
  fetch get_bg into l_business_group_id;
  close get_bg;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk3.create_position_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_position_id                   => p_position_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_position_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_ins.ins
      (p_effective_date                => l_effective_date
      ,p_position_id                   => p_position_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk3.create_position_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_position_id                   => p_position_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_position_dpmt_factor'
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
  p_deployment_factor_id   := l_deployment_factor_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_position_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_deployment_factor_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_position_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
    p_deployment_factor_id   := null;
    p_object_version_number  := null;
   --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_position_dpmt_factor;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_position_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_relocation_required          in     varchar2 default hr_api.g_varchar2
  ,p_passport_required            in     varchar2 default hr_api.g_varchar2
  ,p_location1                    in     varchar2 default hr_api.g_varchar2
  ,p_location2                    in     varchar2 default hr_api.g_varchar2
  ,p_location3                    in     varchar2 default hr_api.g_varchar2
  ,p_other_requirements           in     varchar2 default hr_api.g_varchar2
  ,p_service_minimum              in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_proc                varchar2(72) := g_package||'update_position_dpmt_factor';
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_ovn per_deployment_factors.object_version_number%type := p_object_version_number;
  l_api_updating boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_position_dpmt_factor;
  --
  l_object_version_number:=p_object_version_number;
  --
  l_api_updating:=per_dpf_shd.api_updating
  (p_deployment_factor_id=>p_deployment_factor_id
  ,p_object_version_number=>l_object_version_number);
  --
  if not l_api_updating
  then
    --
    hr_utility.set_location(l_proc, 20);
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk4.update_position_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_position_id                   => per_dpf_shd.g_old_rec.position_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_position_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_upd.upd
      (p_effective_date                => l_effective_date
      ,p_position_id                   => per_dpf_shd.g_old_rec.position_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk4.update_position_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_position_id                   => per_dpf_shd.g_old_rec.position_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_position_dpmt_factor'
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
    rollback to update_position_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_position_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_position_dpmt_factor;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_job_dpmt_factor >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_job_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_job_id                       in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_relocation_required          in     varchar2 default null
  ,p_passport_required            in     varchar2 default null
  ,p_location1                    in     varchar2 default null
  ,p_location2                    in     varchar2 default null
  ,p_location3                    in     varchar2 default null
  ,p_other_requirements           in     varchar2 default null
  ,p_service_minimum              in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_proc                varchar2(72) := g_package||'create_job_dpmt_factor';
  l_deployment_factor_id per_deployment_factors.deployment_factor_id%type;
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_business_group_id hr_all_positions_f.business_group_id%type;
  --
  cursor get_bg is
  select business_group_id
  from per_jobs_v
  where job_id=p_job_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_job_dpmt_factor;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  --
  -- get the business group id
  --
  open get_bg;
  fetch get_bg into l_business_group_id;
  close get_bg;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk5.create_job_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_job_id                        => p_job_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_job_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_ins.ins
      (p_effective_date                => l_effective_date
      ,p_job_id                        => p_job_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk5.create_job_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_job_id                        => p_job_id
      ,p_business_group_id             => l_business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_job_dpmt_factor'
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
  p_deployment_factor_id   := l_deployment_factor_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_job_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_deployment_factor_id   := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_job_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
     p_deployment_factor_id   := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_job_dpmt_factor;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_job_dpmt_factor >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job_dpmt_factor
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_relocation_required          in     varchar2 default hr_api.g_varchar2
  ,p_passport_required            in     varchar2 default hr_api.g_varchar2
  ,p_location1                    in     varchar2 default hr_api.g_varchar2
  ,p_location2                    in     varchar2 default hr_api.g_varchar2
  ,p_location3                    in     varchar2 default hr_api.g_varchar2
  ,p_other_requirements           in     varchar2 default hr_api.g_varchar2
  ,p_service_minimum              in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_proc                varchar2(72) := g_package||'update_job_dpmt_factor';
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_ovn per_deployment_factors.object_version_number%type := p_object_version_number;
  l_api_updating boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_job_dpmt_factor;
  --
  l_object_version_number:=p_object_version_number;
  --
  l_api_updating:=per_dpf_shd.api_updating
  (p_deployment_factor_id=>p_deployment_factor_id
  ,p_object_version_number=>l_object_version_number);
  --
  if not l_api_updating
  then
    --
    hr_utility.set_location(l_proc, 20);
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date:=trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_deployment_factor_bk6.update_job_dpmt_factor_b
      (p_effective_date                => l_effective_date
      ,p_job_id                        => per_dpf_shd.g_old_rec.job_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_job_dpmt_factor'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    per_dpf_upd.upd
      (p_effective_date                => l_effective_date
      ,p_job_id                        => per_dpf_shd.g_old_rec.job_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    hr_deployment_factor_bk6.update_job_dpmt_factor_a
      (p_effective_date                => l_effective_date
      ,p_job_id                        => per_dpf_shd.g_old_rec.job_id
      ,p_business_group_id             => per_dpf_shd.g_old_rec.business_group_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_work_duration
      ,p_work_schedule                 => p_work_schedule
      ,p_work_hours                    => p_work_hours
      ,p_fte_capacity                  => p_fte_capacity
      ,p_relocation_required           => p_relocation_required
      ,p_passport_required             => p_passport_required
      ,p_location1                     => p_location1
      ,p_location2                     => p_location2
      ,p_location3                     => p_location3
      ,p_other_requirements            => p_other_requirements
      ,p_service_minimum               => p_service_minimum
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
      ,p_deployment_factor_id          => p_deployment_factor_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_job_dpmt_factor'
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
    rollback to update_job_dpmt_factor;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_job_dpmt_factor;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_job_dpmt_factor;
--
end hr_deployment_factor_api;

/
