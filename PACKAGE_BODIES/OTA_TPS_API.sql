--------------------------------------------------------
--  DDL for Package Body OTA_TPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPS_API" as
/* $Header: ottpsapi.pkb 115.10 2004/04/01 05:18:12 dbatra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_TPS_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_TRAINING_PLAN >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_training_plan(
   p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_organization_id               in     number   default null
  ,p_person_id                     in     number   default null
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_plan_source                   in     varchar2 default null --changed
  ,p_start_date                    in     date default null
  ,p_end_date                      in     date default null
  ,p_creator_person_id             in    number default null
  ,p_additional_member_flag       in varchar2 default null
  ,p_learning_path_id              in    number default null
  -- Modified for Bug#3479186
  ,p_contact_id              in    number    default null
  ,p_training_plan_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Training Plan';
  l_training_plan_id number;
  l_object_version_number   number;
  l_effective_date          date;

   --bug 3547628
  l_learning_path_id varchar2(4000);
  l_item_key     wf_items.item_key%type;
 -- l_contact_id number(15);
  l_person_id number(15);

  Cursor get_info_for_comp(crs_id number)
  is
  select person_id,learning_path_id
  from ota_training_plans
  where training_plan_id = crs_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_TRAINING_PLAN;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tps_api_bk1.create_training_plan_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_time_period_id              => p_time_period_id
  ,p_plan_status_type_id         => p_plan_status_type_id
  ,p_organization_id             => p_organization_id
  ,p_person_id                   => p_person_id
  ,p_budget_currency             => p_budget_currency
  ,p_name                        => p_name
  ,p_description                 => p_description
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_plan_source                 => p_plan_source  --changed
  ,p_start_date                  => p_start_date
  ,p_end_date                    => p_end_date
  ,p_creator_person_id          => p_creator_person_id
  ,p_additional_member_flag      => p_additional_member_flag
  ,p_learning_path_id            => p_learning_path_id
-- Modified for Bug#3479186
  ,p_contact_id                        => p_contact_id
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TRAINING_PLAN'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tps_ins.ins
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_time_period_id              => p_time_period_id
  ,p_plan_status_type_id         => p_plan_status_type_id
  ,p_organization_id             => p_organization_id
  ,p_person_id                   => p_person_id
  ,p_budget_currency             => p_budget_currency
  ,p_name                        => p_name
  ,p_description                 => p_description
  ,p_attribute_category          => p_attribute_category
  ,p_attribute1                  => p_attribute1
  ,p_attribute2                  => p_attribute2
  ,p_attribute3                  => p_attribute3
  ,p_attribute4                  => p_attribute4
  ,p_attribute5                  => p_attribute5
  ,p_attribute6                  => p_attribute6
  ,p_attribute7                  => p_attribute7
  ,p_attribute8                  => p_attribute8
  ,p_attribute9                  => p_attribute9
  ,p_attribute10                 => p_attribute10
  ,p_attribute11                 => p_attribute11
  ,p_attribute12                 => p_attribute12
  ,p_attribute13                 => p_attribute13
  ,p_attribute14                 => p_attribute14
  ,p_attribute15                 => p_attribute15
  ,p_attribute16                 => p_attribute16
  ,p_attribute17                 => p_attribute17
  ,p_attribute18                 => p_attribute18
  ,p_attribute19                 => p_attribute19
  ,p_attribute20                 => p_attribute20
  ,p_attribute21                 => p_attribute21
  ,p_attribute22                 => p_attribute22
  ,p_attribute23                 => p_attribute23
  ,p_attribute24                 => p_attribute24
  ,p_attribute25                 => p_attribute25
  ,p_attribute26                 => p_attribute26
  ,p_attribute27                 => p_attribute27
  ,p_attribute28                 => p_attribute28
  ,p_attribute29                 => p_attribute29
  ,p_attribute30                 => p_attribute30
  ,p_plan_source                 => p_plan_source  --changed
  ,p_start_date                  => p_start_date
  ,p_end_date                    => p_end_date
  ,p_creator_person_id           => p_creator_person_id
  ,p_additional_member_flag      => p_additional_member_flag
  ,p_learning_path_id            => p_learning_path_id
  -- Modified for Bug#3479186
  ,p_contact_id                        => p_contact_id
  ,p_training_plan_id            => l_training_plan_id
  ,p_object_version_number       => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_tps_api_bk1.create_training_plan_a
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_time_period_id                 => p_time_period_id
  ,p_plan_status_type_id            => p_plan_status_type_id
  ,p_organization_id                => p_organization_id
  ,p_person_id                      => p_person_id
  ,p_budget_currency                => p_budget_currency
  ,p_name                           => p_name
  ,p_description                    => p_description
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_plan_source                    => p_plan_source  --changed
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_creator_person_id              => p_creator_person_id
  ,p_additional_member_flag         => p_additional_member_flag
  ,p_learning_path_id               => p_learning_path_id
  -- Modified for Bug#3479186
  ,p_contact_id                        => p_contact_id
  ,p_training_plan_id               => l_training_plan_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TRAINING_PLAN'
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
  p_training_plan_id        := l_training_plan_id;
  p_object_version_number   := l_object_version_number;

  -- bug 3547628
  --for comptency update associated with LP

  OPEN get_info_for_comp(l_training_plan_id);
FETCH get_info_for_comp INTO l_person_id, l_learning_path_id;
CLOSE get_info_for_comp;
if l_person_id is not null and l_learning_path_id is not null
and p_plan_status_type_id = 'OTA_COMPLETED' then
  ota_competence_ss.create_wf_process(p_process 	=>'OTA_COMPETENCE_UPDATE_JSP_PRC',
            p_itemtype 		=>'HRSSA',
            p_person_id 	=> l_person_id,
            p_eventid       =>null,
            p_learningpath_ids => l_learning_path_id,
            p_itemkey    =>l_item_key);
end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_TRAINING_PLAN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_training_plan_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_TRAINING_PLAN;
    p_training_plan_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_training_plan;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_TRAINING_PLAN >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_training_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_plan_source                   in     varchar2 default hr_api.g_varchar2  --changed
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_creator_person_id             in     number
  ,p_additional_member_flag        in     varchar2 default hr_api.g_varchar2
  ,p_learning_path_id              in     number
  -- Modified for Bug#3479186
  ,p_contact_id              in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Training Plan';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
  --bug 3547628
  l_learning_path_id varchar2(4000);
  l_item_key     wf_items.item_key%type;
 -- l_contact_id number(15);
  l_person_id number(15);

  Cursor get_info_for_comp
  is
  select person_id,learning_path_id
  from ota_training_plans
  where training_plan_id = p_training_plan_id;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_TRAINING_PLAN;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tps_api_bk2.update_training_plan_b
  (p_effective_date                 => l_effective_date
  ,p_training_plan_id               => p_training_plan_id
  ,p_object_version_number          => p_object_version_number
  ,p_time_period_id                 => p_time_period_id
  ,p_plan_status_type_id            => p_plan_status_type_id
  ,p_budget_currency                => p_budget_currency
  ,p_name                           => p_name
  ,p_description                    => p_description
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_plan_source                    => p_plan_source  --changed
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_creator_person_id              => p_creator_person_id
  ,p_additional_member_flag         => p_additional_member_flag
  ,p_learning_path_id               => p_learning_path_id
 ,p_contact_id                        => p_contact_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAINING_PLAN'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tps_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_training_plan_id               => p_training_plan_id
  ,p_object_version_number          => p_object_version_number
  ,p_time_period_id                 => p_time_period_id
  ,p_plan_status_type_id            => p_plan_status_type_id
  ,p_budget_currency                => p_budget_currency
  ,p_name                           => p_name
  ,p_description                    => p_description
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_plan_source                      => p_plan_source  --changed
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_creator_person_id              => p_creator_person_id
  ,p_additional_member_flag         => p_additional_member_flag
  ,p_learning_path_id               => p_learning_path_id
  ,p_contact_id                        => p_contact_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_tps_api_bk2.update_training_plan_a
  (p_effective_date                 => l_effective_date
  ,p_training_plan_id               => p_training_plan_id
  ,p_object_version_number          => p_object_version_number
  ,p_time_period_id                 => p_time_period_id
  ,p_plan_status_type_id            => p_plan_status_type_id
  ,p_budget_currency                => p_budget_currency
  ,p_name                           => p_name
  ,p_description                    => p_description
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
  ,p_attribute21                    => p_attribute21
  ,p_attribute22                    => p_attribute22
  ,p_attribute23                    => p_attribute23
  ,p_attribute24                    => p_attribute24
  ,p_attribute25                    => p_attribute25
  ,p_attribute26                    => p_attribute26
  ,p_attribute27                    => p_attribute27
  ,p_attribute28                    => p_attribute28
  ,p_attribute29                    => p_attribute29
  ,p_attribute30                    => p_attribute30
  ,p_plan_source                    => p_plan_source  --changed
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_creator_person_id              => p_creator_person_id
  ,p_additional_member_flag         => p_additional_member_flag
  ,p_learning_path_id               => p_learning_path_id
  ,p_contact_id                        => p_contact_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAINING_PLAN'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  -- bug 3547628
  --for comptency update associated with LP

  OPEN get_info_for_comp;
FETCH get_info_for_comp INTO l_person_id, l_learning_path_id;
CLOSE get_info_for_comp;
if l_person_id is not null and l_learning_path_id is not null
and p_plan_status_type_id = 'OTA_COMPLETED' then
  ota_competence_ss.create_wf_process(p_process 	=>'OTA_COMPETENCE_UPDATE_JSP_PRC',
            p_itemtype 		=>'HRSSA',
            p_person_id 	=> l_person_id,
            p_eventid       =>null,
            p_learningpath_ids => l_learning_path_id,
            p_itemkey    =>l_item_key);
end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_TRAINING_PLAN;
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
    rollback to UPDATE_TRAINING_PLAN;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_training_plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_TRAINING_PLAN >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_training_plan
  (p_validate                      in     boolean  default false
  ,p_training_plan_id              in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Training Plan';
  l_budget_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_TRAINING_PLAN;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ota_tps_api_bk3.delete_training_plan_b
  (p_training_plan_id            => p_training_plan_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAINING_PLAN'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tps_del.del
  (p_training_plan_id        => p_training_plan_id
  ,p_object_version_number   => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_tps_api_bk3.delete_training_plan_a
  (p_training_plan_id            => p_training_plan_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAINING_PLAN'
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
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_TRAINING_PLAN;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_TRAINING_PLAN;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_training_plan;
--
end ota_tps_api;


/
