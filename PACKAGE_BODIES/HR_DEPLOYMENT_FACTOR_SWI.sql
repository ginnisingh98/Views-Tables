--------------------------------------------------------
--  DDL for Package Body HR_DEPLOYMENT_FACTOR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEPLOYMENT_FACTOR_SWI" as
/* $Header: pedpfswi.pkb 120.0 2005/05/31 07:45:37 appldev noship $ */
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
  (p_validate                     in     number default hr_api.g_false_num
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
  l_validate boolean;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_dpmt_factor_swi;

  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);

  --    Call the Deployment API
  hr_deployment_factor_api.create_person_dpmt_factor
  (p_validate                     => l_validate
  ,p_effective_date               => p_effective_date
  ,p_person_id                    => p_person_id
  ,p_work_any_country             => p_work_any_country
  ,p_work_any_location            => p_work_any_location
  ,p_relocate_domestically        => p_relocate_domestically
  ,p_relocate_internationally     => p_relocate_internationally
  ,p_travel_required              => p_travel_required
  ,p_country1                     => p_country1
  ,p_country2                     =>  p_country2
  ,p_country3                     =>  p_country3
  ,p_work_duration                =>  p_work_duration
  ,p_work_schedule                => p_work_schedule
  ,p_work_hours                   => p_work_hours
  ,p_fte_capacity                 => p_fte_capacity
  ,p_visit_internationally        => p_visit_internationally
  ,p_only_current_location        => p_only_current_location
  ,p_no_country1                  => p_no_country1
  ,p_no_country2                  => p_no_country2
  ,p_no_country3                  => p_no_country3
  ,p_comments                     => p_comments
  ,p_earliest_available_date      => p_earliest_available_date
  ,p_available_for_transfer       =>  p_available_for_transfer
  ,p_relocation_preference        =>  p_relocation_preference
  ,p_attribute_category           =>  p_attribute_category
  ,p_attribute1                   =>  p_attribute1
  ,p_attribute2                   =>  p_attribute2
  ,p_attribute3                   =>  p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   =>  p_attribute6
  ,p_attribute7                   =>  p_attribute7
  ,p_attribute8                   =>  p_attribute8
  ,p_attribute9                   =>  p_attribute9
  ,p_attribute10                  =>  p_attribute10
  ,p_attribute11                  =>  p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  =>  p_attribute13
  ,p_attribute14                  =>  p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  =>  p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  =>  p_attribute18
  ,p_attribute19                  =>  p_attribute19
  ,p_attribute20                  =>  p_attribute20
  ,p_deployment_factor_id         => l_deployment_factor_id
  ,p_object_version_number        => l_object_version_number);

  --
  -- Truncate the time portion from all IN date parameters
  --

  -- Set all output arguments
  --
  p_deployment_factor_id   := l_deployment_factor_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_person_dpmt_factor_swi;
    --
    -- set in out parameters and set out parameters
    --
     p_deployment_factor_id   := null;
     p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    raise;
end create_person_dpmt_factor;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_dpmt_factor >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_dpmt_factor
  (p_validate                     in     number default hr_api.g_false_num
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
  --r
  -- Declare cursors and local vaiables
  --
  l_effective_date date;
  l_earliest_available_date date;
  l_proc                varchar2(72) := g_package||'update_person_dpmt_factor';
  l_object_version_number per_deployment_factors.object_version_number%type;
  l_ovn per_deployment_factors.object_version_number%type := p_object_version_number;
  l_api_updating boolean;
  l_validate boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_dpmt_factor_swi;

  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);

  hr_deployment_factor_api.update_person_dpmt_factor
  (p_validate                     => l_validate
  ,p_effective_date               => p_effective_date
  ,p_deployment_factor_id         => p_deployment_factor_id
  ,p_object_version_number        => p_object_version_number
  ,p_work_any_country             => p_work_any_country
  ,p_work_any_location            => p_work_any_location
  ,p_relocate_domestically        => p_relocate_domestically
  ,p_relocate_internationally     => p_relocate_internationally
  ,p_travel_required              => p_travel_required
  ,p_country1                     => p_country1
  ,p_country2                     =>  p_country2
  ,p_country3                     =>  p_country3
  ,p_work_duration                =>  p_work_duration
  ,p_work_schedule                => p_work_schedule
  ,p_work_hours                   => p_work_hours
  ,p_fte_capacity                 => p_fte_capacity
  ,p_visit_internationally        => p_visit_internationally
  ,p_only_current_location        => p_only_current_location
  ,p_no_country1                  => p_no_country1
  ,p_no_country2                  => p_no_country2
  ,p_no_country3                  => p_no_country3
  ,p_comments                     => p_comments
  ,p_earliest_available_date      => p_earliest_available_date
  ,p_available_for_transfer       =>  p_available_for_transfer
  ,p_relocation_preference        =>  p_relocation_preference
  ,p_attribute_category           =>  p_attribute_category
  ,p_attribute1                   =>  p_attribute1
  ,p_attribute2                   =>  p_attribute2
  ,p_attribute3                   =>  p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   =>  p_attribute6
  ,p_attribute7                   =>  p_attribute7
  ,p_attribute8                   =>  p_attribute8
  ,p_attribute9                   =>  p_attribute9
  ,p_attribute10                  =>  p_attribute10
  ,p_attribute11                  =>  p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  =>  p_attribute13
  ,p_attribute14                  =>  p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  =>  p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  =>  p_attribute18
  ,p_attribute19                  =>  p_attribute19
  ,p_attribute20                  =>  p_attribute20);

  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_person_dpmt_factor_swi;
    --
    -- set in out parameters and set out parameters
    --
     p_object_version_number  := l_ovn;
   --
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    raise;
end update_person_dpmt_factor;
--
end hr_deployment_factor_swi;

/
