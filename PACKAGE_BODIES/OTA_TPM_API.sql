--------------------------------------------------------
--  DDL for Package Body OTA_TPM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPM_API" as
/* $Header: ottpmapi.pkb 115.8 2004/03/03 05:16:35 rdola noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_TPM_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_TRAINING_PLAN_MEMBER >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_training_plan_id              in     number
  ,p_activity_version_id           in     number   default null
  ,p_activity_definition_id        in     number   default null
  ,p_member_status_type_id         in     varchar2
  ,p_target_completion_date        in     date     default null
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
  ,p_assignment_id                 in     number default null
  ,p_source_id                     in     number default  null
  ,p_source_function               in     varchar2 default null
  ,p_cancellation_reason           in     varchar2 default null
  ,p_earliest_start_date           in     date default null
  ,p_creator_person_id             in    number default null
  ,p_training_plan_member_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Training Plan Member';
  l_training_plan_member_id number;
  l_object_version_number   number;
  l_effective_date          date;
  l_member_status_type_id   varchar2(30) := p_member_status_type_id;
	l_person_id number(15);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_training_plan_member;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  if p_member_status_type_id = 'OTA_PLANNED' then

	-- Modified by rdola on 10th Apr 03
    --l_person_id := ota_training_plan_cmmn.get_person_id(p_training_plan_id);
    --ota_training_plan_cmmn.modify_tpc_status_on_create(l_person_id,p_earliest_start_date,p_target_completion_date,l_member_status_type_id);
 --      l_person_id := ota_trng_plan_util_ss.get_person_id(p_training_plan_id => p_training_plan_id);
 -- Modified for Bug#3479186
       ota_trng_plan_util_ss.modify_tpc_status_on_create(-- p_person_id               => l_person_id,
                                                         p_earliest_start_date     => p_earliest_start_date,
                                                         p_target_completion_date  => p_target_completion_date,
                                                         p_activity_version_id     => p_activity_version_id,
                                                         p_training_plan_id        => p_training_plan_id,
                                                         p_member_status_id        => l_member_status_type_id );


  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    OTA_TPM_api_bk1.create_training_plan_member_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_training_plan_id            => p_training_plan_id
  ,p_activity_version_id         => p_activity_version_id
  ,p_activity_definition_id      => p_activity_definition_id
  ,p_member_status_type_id       => l_member_status_type_id
  ,p_target_completion_date      => p_target_completion_date
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
  ,p_assignment_id               => p_assignment_id
  ,p_source_id                   => p_source_id
  ,p_source_function             => p_source_function
  ,p_cancellation_reason         => p_cancellation_reason
  ,p_earliest_start_date         => p_earliest_start_date
  ,p_creator_person_id           => p_creator_person_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_training_plan_member'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tpm_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_training_plan_id               => p_training_plan_id
  ,p_activity_version_id            => p_activity_version_id
  ,p_activity_definition_id         => p_activity_definition_id
  ,p_member_status_type_id          => l_member_status_type_id
  ,p_target_completion_date         => p_target_completion_date
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
  ,p_assignment_id                  => p_assignment_id
  ,p_source_id                      => p_source_id
  ,p_source_function                => p_source_function
  ,p_cancellation_reason            => p_cancellation_reason
  ,p_earliest_start_date            => p_earliest_start_date
  ,p_training_plan_member_id        => l_training_plan_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_creator_person_id              => p_creator_person_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_TPM_api_bk1.create_training_plan_member_a
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_training_plan_id               => p_training_plan_id
  ,p_activity_version_id            => p_activity_version_id
  ,p_activity_definition_id         => p_activity_definition_id
  ,p_member_status_type_id          => l_member_status_type_id
  ,p_target_completion_date         => p_target_completion_date
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
  ,p_assignment_id                  => p_assignment_id
  ,p_source_id                      => p_source_id
  ,p_source_function                => p_source_function
  ,p_cancellation_reason            => p_cancellation_reason
  ,p_earliest_start_date            => p_earliest_start_date
  ,p_training_plan_member_id        => l_training_plan_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_creator_person_id              => p_creator_person_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_training_plan_member'
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
  p_training_plan_member_id := l_training_plan_member_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_training_plan_member;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_training_plan_member_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_training_plan_member;
    p_training_plan_member_id := null;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_training_plan_member;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_training_plan_member >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_activity_version_id           in     number   default hr_api.g_number
  ,p_activity_definition_id        in     number   default hr_api.g_number
  ,p_member_status_type_id         in     varchar2 default hr_api.g_varchar2
  ,p_target_completion_date        in     date     default hr_api.g_date
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
  ,p_assignment_id                 in     number default hr_api.g_number
  ,p_source_id                     in     number default  hr_api.g_number
  ,p_source_function               in     varchar2 default hr_api.g_varchar2
  ,p_cancellation_reason           in     varchar2 default hr_api.g_varchar2
  ,p_earliest_start_date           in     date default hr_api.g_date
  ,p_creator_person_id             in    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update training plan member';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;
  l_member_status_type_id  varchar2(30) := p_member_status_type_id;
  l_person_id number(15);
  l_training_plan_id number(9);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_training_plan_member;

  select training_plan_id into l_training_plan_id from ota_training_plan_members
  where training_plan_member_id = p_training_plan_member_id;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  if p_member_status_type_id <> 'CANCELLED' then

	-- Modified by rdola on 10th Apr 03
    --l_person_id := ota_training_plan_cmmn.get_person_id(p_training_plan_id);
    --ota_training_plan_cmmn.modify_tpc_status_on_create(l_person_id,p_earliest_start_date,p_target_completion_date,l_member_status_type_id);
       l_person_id := ota_trng_plan_util_ss.get_person_id(p_training_plan_id => l_training_plan_id);
       -- Modified for Bug#3479186
       ota_trng_plan_util_ss.modify_tpc_status_on_update(-- p_person_id               => l_person_id,
                                                         p_earliest_start_date     => p_earliest_start_date,
                                                         p_target_completion_date  => p_target_completion_date,
                                                         p_activity_version_id     => p_activity_version_id,
                                                         p_training_plan_id        => l_training_plan_id,
                                                         p_member_status_id        => l_member_status_type_id );


  end if;
  -- Call Before Process User Hook
  --
  begin
    ota_tpm_api_bk2.update_training_plan_member_b
  (p_effective_date                 => l_effective_date
  ,p_training_plan_member_id        => p_training_plan_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_activity_definition_id         => p_activity_definition_id
  ,p_member_status_type_id          => l_member_status_type_id
  ,p_target_completion_date         => p_target_completion_date
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
  ,p_assignment_id                  => p_assignment_id
  ,p_source_id                      => p_source_id
  ,p_source_function                => p_source_function
  ,p_cancellation_reason            => p_cancellation_reason
  ,p_earliest_start_date            => p_earliest_start_date
  ,p_creator_person_id              => p_creator_person_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAINING_PLAN_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_tpm_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_training_plan_member_id        => p_training_plan_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_activity_definition_id         => p_activity_definition_id
  ,p_member_status_type_id          => l_member_status_type_id
  ,p_target_completion_date         => p_target_completion_date
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
  ,p_assignment_id                  => p_assignment_id
  ,p_source_id                      => p_source_id
  ,p_source_function                => p_source_function
  ,p_cancellation_reason            => p_cancellation_reason
  ,p_earliest_start_date            => p_earliest_start_date
  ,p_creator_person_id              => p_creator_person_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_TPM_api_bk2.update_training_plan_member_a
  (p_effective_date                 => l_effective_date
  ,p_training_plan_member_id        => p_training_plan_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_activity_definition_id         => p_activity_definition_id
  ,p_member_status_type_id          => l_member_status_type_id
  ,p_target_completion_date         => p_target_completion_date
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
  ,p_assignment_id                  => p_assignment_id
  ,p_source_id                      => p_source_id
  ,p_source_function                => p_source_function
  ,p_cancellation_reason            => p_cancellation_reason
  ,p_earliest_start_date            => p_earliest_start_date
  ,p_creator_person_id             => p_creator_person_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TRAINING_PLAN_MEMBER'
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
    rollback to update_training_plan_member;
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
    rollback to update_training_plan_member;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_training_plan_member;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_training_plan_member >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Training Plan Member';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_training_plan_member;
  --
  -- Call Before Process User Hook
  --
  begin
    OTA_TPM_api_bk3.delete_training_plan_member_b
    (p_training_plan_member_id     => p_training_plan_member_id
    ,p_object_version_number       => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAINING_PLAN_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  OTA_TPM_del.del
  (p_training_plan_member_id        => p_training_plan_member_id
  ,p_object_version_number          => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  OTA_TPM_api_bk3.delete_training_plan_member_a
  (p_training_plan_member_id     => p_training_plan_member_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TRAINING_PLAN_MEMBER'
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
    rollback to delete_training_plan_member;
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
    rollback to delete_training_plan_member;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_training_plan_member;
--
end ota_tpm_api;

/
