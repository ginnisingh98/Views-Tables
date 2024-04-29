--------------------------------------------------------
--  DDL for Package Body OTA_LP_MEMBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_MEMBER_API" as
/* $Header: otlpmapi.pkb 120.0 2005/05/29 07:22:19 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_LP_MEMBER_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_LEARNING_PATH_MEMBER >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_learning_path_id              in     number
  ,p_activity_version_id           in     number
  ,p_course_sequence               in     number
  ,p_duration                      in     number    default null
  ,p_duration_units                in     varchar2  default null
  ,p_attribute_category            in     varchar2  default null
  ,p_attribute1                    in     varchar2  default null
  ,p_attribute2                    in     varchar2  default null
  ,p_attribute3                    in     varchar2  default null
  ,p_attribute4                    in     varchar2  default null
  ,p_attribute5                    in     varchar2  default null
  ,p_attribute6                    in     varchar2  default null
  ,p_attribute7                    in     varchar2  default null
  ,p_attribute8                    in     varchar2  default null
  ,p_attribute9                    in     varchar2  default null
  ,p_attribute10                   in     varchar2  default null
  ,p_attribute11                   in     varchar2  default null
  ,p_attribute12                   in     varchar2  default null
  ,p_attribute13                   in     varchar2  default null
  ,p_attribute14                   in     varchar2  default null
  ,p_attribute15                   in     varchar2  default null
  ,p_attribute16                   in     varchar2  default null
  ,p_attribute17                   in     varchar2  default null
  ,p_attribute18                   in     varchar2  default null
  ,p_attribute19                   in     varchar2  default null
  ,p_attribute20                   in     varchar2  default null
  ,p_learning_path_section_id      in     number
  ,p_notify_days_before_target     in     number    default null
  ,p_learning_path_member_id          out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Learning Path Member';
  l_learning_path_member_id number;
  l_object_version_number   number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_learning_path_member;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_member_bk1.create_learning_path_member_b
  (p_effective_date              => l_effective_date
  ,p_business_group_id           => p_business_group_id
  ,p_learning_path_id            => p_learning_path_id
  ,p_activity_version_id         => p_activity_version_id
  ,p_course_sequence             => p_course_sequence
  ,p_duration                    => p_duration
  ,p_duration_units              => p_duration_units
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
  ,p_learning_path_section_id    => p_learning_path_section_id
  ,p_notify_days_before_target   => p_notify_days_before_target
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_learning_path_member'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lpm_ins.ins
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_learning_path_id               => p_learning_path_id
  ,p_activity_version_id            => p_activity_version_id
  ,p_course_sequence                => p_course_sequence
  ,p_duration                       => p_duration
  ,p_duration_units                 => p_duration_units
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
  ,p_learning_path_section_id       => p_learning_path_section_id
  ,p_notify_days_before_target      => p_notify_days_before_target
  ,p_object_version_number          => l_object_version_number
  ,p_learning_path_member_id        => l_learning_path_member_id
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_member_bk1.create_learning_path_member_a
  (p_effective_date                 => l_effective_date
  ,p_business_group_id              => p_business_group_id
  ,p_learning_path_id               => p_learning_path_id
  ,p_activity_version_id            => p_activity_version_id
  ,p_course_sequence                => p_course_sequence
  ,p_duration                       => p_duration
  ,p_duration_units                 => p_duration_units
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
  ,p_learning_path_section_id       => p_learning_path_section_id
  ,p_notify_days_before_target      => p_notify_days_before_target
  ,p_learning_path_member_id        => l_learning_path_member_id
  ,p_object_version_number          => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_learning_path_member'
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
  p_learning_path_member_id := l_learning_path_member_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_learning_path_member;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_learning_path_member_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_learning_path_member;
    p_learning_path_member_id := null;
    p_object_version_number :=  null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_learning_path_member;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_learning_path_member >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_member_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_activity_version_id           in     number   default hr_api.g_number
  ,p_course_sequence               in     number   default hr_api.g_number
  ,p_duration                      in     number   default hr_api.g_number
  ,p_duration_units                in     varchar2 default hr_api.g_varchar2
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
  ,p_notify_days_before_target     in     number default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Learning Path member';
  l_object_version_number   number       := p_object_version_number;
  l_effective_date          date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_learning_path_member;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --

  -- Call Before Process User Hook
  --
  begin
    ota_lp_member_bk2.update_learning_path_member_b
  (p_effective_date                 => l_effective_date
  ,p_learning_path_member_id        => p_learning_path_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_course_sequence                => p_course_sequence
  ,p_duration                       => p_duration
  ,p_duration_units                 => p_duration_units
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
  ,p_notify_days_before_target      => p_notify_days_before_target
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_learning_path_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_lpm_upd.upd
  (p_effective_date                 => l_effective_date
  ,p_learning_path_member_id        => p_learning_path_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_course_sequence                => p_course_sequence
  ,p_duration                       => p_duration
  ,p_duration_units                 => p_duration_units
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
  ,p_notify_days_before_target      => p_notify_days_before_target
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_member_bk2.update_learning_path_member_a
  (p_effective_date                 => l_effective_date
  ,p_learning_path_member_id        => p_learning_path_member_id
  ,p_object_version_number          => l_object_version_number
  ,p_activity_version_id            => p_activity_version_id
  ,p_course_sequence                => p_course_sequence
  ,p_duration                       => p_duration
  ,p_duration_units                 => p_duration_units
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
  ,p_notify_days_before_target      => p_notify_days_before_target
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_learning_path_MEMBER'
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
    rollback to update_learning_path_member;
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
    rollback to update_learning_path_member;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    p_object_version_number := l_object_version_number;
    raise;
end update_learning_path_member;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< order_course_sequence >------------------|
-- ----------------------------------------------------------------------------
--
procedure order_course_sequence(p_validate in  boolean,
                      p_learning_path_member_id in number)
IS
 CURSOR csr_get_lpm_sequence IS
   SELECT lpm.course_sequence, lpm.learning_path_id
   FROM ota_learning_path_members lpm
   WHERE lpm.learning_path_member_id = p_learning_path_member_id;

 CURSOR get_lpms(p_learning_path_id IN NUMBER, p_course_sequence IN NUMBER) IS
   SELECT lpm.learning_path_member_id, lpm.object_version_number, lpm.course_sequence
   FROM ota_learning_path_members lpm
   WHERE lpm.learning_path_id = p_learning_path_id
    AND lpm.course_sequence > p_course_sequence
   ORDER BY course_sequence;

  l_course_sequence ota_learning_path_members.course_sequence%TYPE;
  l_learning_path_id ota_learning_path_members.learning_path_id%TYPE;
  l_lpm_rec get_lpms%ROWTYPE;
  l_sequence  ota_learning_path_members.course_sequence%TYPE;
  l_proc  varchar2(72) := g_package||' order course sequence';
BEGIN
   hr_utility.set_location('Entering:'|| l_proc, 10);
   OPEN csr_get_lpm_sequence;
   FETCH csr_get_lpm_sequence INTO l_course_sequence,l_learning_path_id;
   CLOSE csr_get_lpm_sequence;

   l_sequence := l_course_sequence;

   FOR l_lpm_rec in get_lpms(l_learning_path_id, l_course_sequence)
   LOOP
     OTA_LP_MEMBER_API.update_learning_path_member(
                p_validate                => p_validate
               ,p_learning_path_member_id => l_lpm_rec.learning_path_member_id
               ,p_object_version_number   => l_lpm_rec.object_version_number
               ,p_effective_date          => trunc(sysdate)
               ,p_course_sequence         => l_sequence);
     l_sequence := l_sequence + 1;
   END LOOP;
   hr_utility.set_location('Leaving:'|| l_proc, 10);
END order_course_sequence;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path_member >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_learning_path_member_id       in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Learning Path Member';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_learning_path_member;
  --
  -- Call Before Process User Hook
  --
  begin
    ota_lp_member_bk3.delete_learning_path_member_b
    (p_learning_path_member_id     => p_learning_path_member_id
    ,p_object_version_number       => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEARNING_PATH_MEMBER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --  order_course_sequence(
  --      p_validate => p_validate
  --     ,p_learning_path_member_id        => p_learning_path_member_id);
  --
  -- Process Logic
  --
  OTA_lpm_del.del
  (p_learning_path_member_id        => p_learning_path_member_id
  ,p_object_version_number          => p_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
  ota_lp_member_bk3.delete_learning_path_member_a
  (p_learning_path_member_id     => p_learning_path_member_id
  ,p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LEARNING_PATH_MEMBER'
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
    rollback to delete_learning_path_member;
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
    rollback to delete_learning_path_member;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_learning_path_member;
--
end ota_lp_member_api;

/
