--------------------------------------------------------
--  DDL for Package Body OTA_LEARNING_PATH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LEARNING_PATH_API" as
/* $Header: otlpsapi.pkb 120.0 2005/05/29 07:23:32 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LEARNING_PATH_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_ACTIVITY_VERSION >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_learning_path
(
  p_effective_date               in date,
  p_validate                     in boolean   default false ,
  p_path_name                    in varchar2,
  p_business_group_id            in number  ,
  p_duration                     in number    default null,
  p_duration_units               in varchar2  default null,
  p_start_date_active            in date      default null,
  p_end_date_active              in date      default null,
  p_description                  in varchar2  default null,
  p_objectives                   in varchar2  default null,
  p_keywords                     in varchar2  default null,
  p_purpose                      in varchar2  default null,
  p_attribute_category           in varchar2  default null,
  p_attribute1                   in varchar2  default null,
  p_attribute2                   in varchar2  default null,
  p_attribute3                   in varchar2  default null,
  p_attribute4                   in varchar2  default null,
  p_attribute5                   in varchar2  default null,
  p_attribute6                   in varchar2  default null,
  p_attribute7                   in varchar2  default null,
  p_attribute8                   in varchar2  default null,
  p_attribute9                   in varchar2  default null,
  p_attribute10                  in varchar2  default null,
  p_attribute11                  in varchar2  default null,
  p_attribute12                  in varchar2  default null,
  p_attribute13                  in varchar2  default null,
  p_attribute14                  in varchar2  default null,
  p_attribute15                  in varchar2  default null,
  p_attribute16                  in varchar2  default null,
  p_attribute17                  in varchar2  default null,
  p_attribute18                  in varchar2  default null,
  p_attribute19                  in varchar2  default null,
  p_attribute20                  in varchar2  default null,
  p_path_source_code             in varchar2  default null,
  p_source_function_code         in varchar2  default null,
  p_assignment_id                in number    default null,
  p_source_id                    in number    default null,
  p_notify_days_before_target    in number    default null,
  p_person_id                    in number    default null,
  p_contact_id                   in number    default null,
  p_display_to_learner_flag      in varchar2  default null,
  p_public_flag                  in varchar2  default 'Y',
  p_competency_update_level        in     varchar2  default null,
  p_learning_path_id             out nocopy number,
  p_object_version_number        out nocopy number

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' create_learning_path';
  l_learning_path_id number;
  l_object_version_number   number;
  l_effective_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_LEARNING_PATH;
  l_effective_date := trunc(p_effective_date);


  begin
  ota_learning_path_bk1.create_learning_path_b
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_path_name                    => p_path_name
    ,p_business_group_id            => p_business_group_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
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
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_competency_update_level      => p_competency_update_level
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEARNING_PATH'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_lps_ins.ins
  (
   p_effective_date                 =>   p_effective_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_start_date_active              =>   p_start_date_active
  ,p_end_date_active                =>   p_end_date_active
  ,p_duration                       =>   p_duration
  ,p_duration_units                 =>   p_duration_units
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_path_source_code               =>   p_path_source_code
  ,p_source_function_code           =>   p_source_function_code
  ,p_assignment_id                  =>   p_assignment_id
  ,p_source_id                      =>   p_source_id
  ,p_notify_days_before_target      =>   p_notify_days_before_target
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_display_to_learner_flag        =>   p_display_to_learner_flag
  ,p_public_flag                    =>   p_public_flag
  ,p_competency_update_level      => p_competency_update_level
  ,p_learning_path_id               =>   l_learning_path_id
  ,p_object_version_number          =>   l_object_version_number
  );
  --
  -- Set all output arguments
  --
  p_learning_path_id        := l_learning_path_id;
  p_object_version_number   := l_object_version_number;


  ota_lpt_ins.ins_tl
    (  p_effective_date               => p_effective_date
      ,p_language_code                => USERENV('LANG')
      ,p_learning_path_id             => p_learning_path_id
      ,p_name                         => rtrim(p_path_name)
      ,p_description                  => p_description
      ,p_objectives                   => p_objectives
      ,p_purpose                      => p_purpose
      ,p_keywords                     => p_keywords
  );


  begin
  ota_learning_path_bk1.create_learning_path_a
  (  p_effective_date               => p_effective_date
    ,p_validate                     => p_validate
    ,p_path_name                    => p_path_name
    ,p_business_group_id            => p_business_group_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
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
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_competency_update_level      => p_competency_update_level
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LEARNING_PATH'
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
    rollback to CREATE_LEARNING_PATH;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_learning_path_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_LEARNING_PATH;
    p_learning_path_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_learning_path;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_LEARNING_PATH >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_learning_path
  (
  p_effective_date               in date,
  p_learning_path_id             in number,
  p_object_version_number        in out nocopy number,
  p_path_name                    in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_objectives                   in varchar2         default hr_api.g_varchar2,
  p_keywords                     in varchar2         default hr_api.g_varchar2,
  p_purpose                      in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_start_date_active            in date             default hr_api.g_date,
  p_end_date_active              in date             default hr_api.g_date,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_path_source_code             in varchar2         default hr_api.g_varchar2,
  p_source_function_code         in varchar2         default hr_api.g_varchar2,
  p_assignment_id                in number           default hr_api.g_number,
  p_source_id                    in number           default hr_api.g_number,
  p_notify_days_before_target    in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_display_to_learner_flag      in varchar2         default hr_api.g_varchar2,
  p_public_flag                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Learning Path';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_LEARNING_PATH;
  l_effective_date := trunc(p_effective_date);

  begin
  ota_learning_path_bk2.update_learning_path_b
  (p_effective_date               => p_effective_date
    ,p_learning_path_id             => p_learning_path_id
    ,p_object_version_number        => p_object_version_number
    ,p_path_name                    => p_path_name
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
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
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    ,p_competency_update_level      => p_competency_update_level
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEARNING_PATH'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  -- Process Logic
  --
  ota_lps_upd.upd
  (
   p_effective_date                 =>   p_effective_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_start_date_active            => p_start_date_active
  ,p_end_date_active              => p_end_date_active
  ,p_duration                       =>   p_duration
  ,p_duration_units                 =>   p_duration_units
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_path_source_code               =>   p_path_source_code
  ,p_source_function_code           =>   p_source_function_code
  ,p_assignment_id                  =>   p_assignment_id
  ,p_source_id                      =>   p_source_id
  ,p_notify_days_before_target      =>   p_notify_days_before_target
  ,p_person_id                      =>   p_person_id
  ,p_contact_id                     =>   p_contact_id
  ,p_display_to_learner_flag        =>   p_display_to_learner_flag
  ,p_public_flag                    =>   p_public_flag
  ,p_competency_update_level      => p_competency_update_level
  ,p_learning_path_id               =>   p_learning_path_id
  ,p_object_version_number          =>   p_object_version_number
  );

  ota_lpt_upd.upd_tl
 ( p_effective_date               => p_effective_date
  ,p_language_code                => USERENV('LANG')
  ,p_learning_path_id             => p_learning_path_id
  ,p_name                         => rtrim(p_path_name)
  ,p_description                  => p_description
  ,p_objectives                   => p_objectives
  ,p_purpose                      => p_purpose
  ,p_keywords                     => p_keywords
  );


  begin
  ota_learning_path_bk2.update_learning_path_a
  (p_effective_date               => p_effective_date
    ,p_learning_path_id             => p_learning_path_id
    ,p_object_version_number        => p_object_version_number
    ,p_path_name                    => p_path_name
    ,p_description                  => p_description
    ,p_objectives                   => p_objectives
    ,p_keywords                     => p_keywords
    ,p_purpose                      => p_purpose
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
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
    ,p_path_source_code             => p_path_source_code
    ,p_source_function_code         => p_source_function_code
    ,p_assignment_id                => p_assignment_id
    ,p_source_id                    => p_source_id
    ,p_notify_days_before_target    => p_notify_days_before_target
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_display_to_learner_flag      => p_display_to_learner_flag
    ,p_public_flag                  => p_public_flag
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => p_validate
    ,p_competency_update_level      => p_competency_update_level
    );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LEARNING_PATH'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_LEARNING_PATH;
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
    rollback to UPDATE_LEARNING_PATH;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_learning_path;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_LEARNING_PATH >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_learning_path
  (
  p_learning_path_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Learning Path';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_LEARNING_PATH;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  begin
  ota_learning_path_bk3.delete_learning_path_b
  (p_learning_path_id             => p_learning_path_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEARNING_PATH'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  ota_lpt_del.del_tl
    (p_learning_path_id   => p_learning_path_id
    );

  ota_lps_del.del
  (
  p_learning_path_id         => p_learning_path_id             ,
  p_object_version_number    => p_object_version_number
  );


  begin
  ota_learning_path_bk3.delete_learning_path_a
  (p_learning_path_id             => p_learning_path_id
    ,p_object_version_number        => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEARNING_PATH'
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
    rollback to DELETE_LEARNING_PATH;
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
    rollback to DELETE_LEARNING_PATH;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_learning_path;
--
end ota_learning_path_api;

/
